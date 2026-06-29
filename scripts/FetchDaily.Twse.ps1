param(
  [Parameter(Mandatory = $true)]
  [string]$Symbol,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$symbolsPath = Join-Path $root "data\symbols.json"

function Read-JsonFileUtf8([string]$Path) {
  if (!(Test-Path $Path)) {
    throw "JSON file not found: $Path"
  }

  $json = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
  return $json | ConvertFrom-Json
}

function Write-JsonFileUtf8([string]$Path, $Value) {
  $dir = Split-Path -Parent $Path
  if (!(Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }

  $json = $Value | ConvertTo-Json -Depth 20
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $json, $utf8NoBom)
}

function ConvertTo-NumberOrNull($Value) {
  if ($null -eq $Value) { return $null }
  $text = [string]$Value
  $text = $text.Trim().Replace(",", "")
  if ([string]::IsNullOrWhiteSpace($text)) { return $null }
  if ($text -in @("-", "--", "_", "NaN", "X")) { return $null }

  $number = 0.0
  if ([double]::TryParse($text, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$number)) {
    return $number
  }

  return $null
}

function ConvertTo-IntOrZero($Value) {
  $number = ConvertTo-NumberOrNull $Value
  if ($null -eq $number) { return 0 }
  return [int64][math]::Round($number, 0)
}

function Convert-RocDateToIso([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
  $text = $Value.Trim()

  if ($text -match "^(\d{2,3})/(\d{1,2})/(\d{1,2})$") {
    $year = [int]$Matches[1] + 1911
    $month = [int]$Matches[2]
    $day = [int]$Matches[3]
    return (Get-Date -Year $year -Month $month -Day $day).ToString("yyyy-MM-dd")
  }

  if ($text -match "^(\d{4})/(\d{1,2})/(\d{1,2})$") {
    return ([datetime]::ParseExact($text, "yyyy/M/d", [System.Globalization.CultureInfo]::InvariantCulture)).ToString("yyyy-MM-dd")
  }

  return $null
}

function Get-SymbolMarket([string]$StockSymbol) {
  $symbols = Read-JsonFileUtf8 $symbolsPath
  $entry = $symbols.PSObject.Properties[$StockSymbol]
  if ($null -eq $entry) {
    throw "Symbol metadata not found in data/symbols.json: $StockSymbol"
  }

  $market = [string]$entry.Value.market
  if ([string]::IsNullOrWhiteSpace($market)) { return "TWSE" }
  return $market.ToUpperInvariant()
}

function Invoke-JsonGet([string]$Uri) {
  $headers = @{
    "User-Agent" = "Mozilla/5.0 StockOverlayViewer/1.0"
    "Accept" = "application/json,text/plain,*/*"
  }

  return Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get -TimeoutSec 30
}

function Convert-StockDayRowsToCandles($Rows) {
  $candles = @()

  foreach ($row in @($Rows)) {
    if ($null -eq $row -or $row.Count -lt 7) { continue }

    $date = Convert-RocDateToIso ([string]$row[0])
    $open = ConvertTo-NumberOrNull $row[3]
    $high = ConvertTo-NumberOrNull $row[4]
    $low = ConvertTo-NumberOrNull $row[5]
    $close = ConvertTo-NumberOrNull $row[6]
    $volume = ConvertTo-IntOrZero $row[1]

    if ($null -eq $date -or $null -eq $open -or $null -eq $high -or $null -eq $low -or $null -eq $close) {
      continue
    }

    $candles += [ordered]@{
      date = $date
      open = [math]::Round($open, 2)
      high = [math]::Round($high, 2)
      low = [math]::Round($low, 2)
      close = [math]::Round($close, 2)
      volume = $volume
    }
  }

  return @($candles | Sort-Object date)
}

function Get-TwseCandles([string]$StockSymbol) {
  $date = (Get-Date).ToString("yyyyMMdd")
  $uri = "https://www.twse.com.tw/rwd/zh/afterTrading/STOCK_DAY?date=$date&stockNo=$([uri]::EscapeDataString($StockSymbol))&response=json"
  $response = Invoke-JsonGet $uri
  return Convert-StockDayRowsToCandles $response.data
}

function Get-TpexCandles([string]$StockSymbol) {
  $date = (Get-Date).ToString("yyyy/MM/dd")
  $uri = "https://www.tpex.org.tw/www/zh-tw/afterTrading/tradingStock?code=$([uri]::EscapeDataString($StockSymbol))&date=$([uri]::EscapeDataString($date))&response=json"
  $response = Invoke-JsonGet $uri

  if ($null -ne $response.tables -and @($response.tables).Count -gt 0) {
    return Convert-StockDayRowsToCandles (@($response.tables)[0].data)
  }

  if ($null -ne $response.data) {
    return Convert-StockDayRowsToCandles $response.data
  }

  throw "TPEx daily response did not contain table data. Symbol=$StockSymbol"
}

$market = Get-SymbolMarket $Symbol
$candles = switch ($market) {
  "TWSE" { Get-TwseCandles $Symbol }
  "TPEX" { Get-TpexCandles $Symbol }
  "OTC" { Get-TpexCandles $Symbol }
  default { throw "Unsupported market for TWSE daily provider: $Symbol market=$market" }
}

if ($null -eq $candles -or @($candles).Count -eq 0) {
  throw "Daily provider returned no usable candles. Symbol=$Symbol market=$market"
}

$result = [ordered]@{
  symbol = $Symbol
  candles = @($candles)
  source = "twse-daily"
  updatedAt = (Get-Date).ToString("o")
}

Write-JsonFileUtf8 $OutputPath $result
Write-Host "Wrote daily TWSE: $OutputPath candles=$(@($candles).Count) market=$market"
