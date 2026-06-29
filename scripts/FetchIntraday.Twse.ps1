param(
  [Parameter(Mandatory = $true)]
  [string]$Symbol,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath,

  [int]$Iteration = 1
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
  if ($text -in @("-", "--", "_", "NaN")) { return $null }

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

function Get-MisChannel([string]$StockSymbol) {
  $market = Get-SymbolMarket $StockSymbol
  switch ($market) {
    "TWSE" { return "tse_$StockSymbol.tw" }
    "TPEX" { return "otc_$StockSymbol.tw" }
    "OTC" { return "otc_$StockSymbol.tw" }
    default { throw "Unsupported market for TWSE intraday provider: $StockSymbol market=$market" }
  }
}

function Invoke-JsonGet([string]$Uri) {
  $headers = @{
    "User-Agent" = "Mozilla/5.0 StockOverlayViewer/1.0"
    "Accept" = "application/json,text/plain,*/*"
  }

  return Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get -TimeoutSec 20
}

function Get-ExistingPoints([string]$Path, [string]$Date, [int]$CurrentIteration) {
  if ($CurrentIteration -le 1) { return @() }
  if (!(Test-Path $Path)) { return @() }

  try {
    $existing = Read-JsonFileUtf8 $Path
    if ($existing.date -ne $Date) { return @() }
    if ($existing.source -ne "twse-mis") { return @() }
    return @($existing.points)
  }
  catch {
    Write-Warning "Could not read existing intraday file; it will be replaced. Path=$Path Error=$($_.Exception.Message)"
    return @()
  }
}

$channel = Get-MisChannel $Symbol
$uri = "https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=$([uri]::EscapeDataString($channel))&json=1&delay=0"
$response = Invoke-JsonGet $uri
$msg = @($response.msgArray) | Select-Object -First 1

if ($null -eq $msg) {
  throw "TWSE MIS intraday response did not contain msgArray data. Symbol=$Symbol Channel=$channel"
}

$price = ConvertTo-NumberOrNull $msg.z
if ($null -eq $price) {
  $price = ConvertTo-NumberOrNull $msg.y
}
if ($null -eq $price) {
  throw "TWSE MIS intraday response did not contain a usable price. Symbol=$Symbol Channel=$channel"
}

$rawDate = [string]$msg.d
$rawTime = [string]$msg.t
if ($rawDate -match "^\d{8}$") {
  $date = [datetime]::ParseExact($rawDate, "yyyyMMdd", [System.Globalization.CultureInfo]::InvariantCulture).ToString("yyyy-MM-dd")
}
else {
  $date = (Get-Date).ToString("yyyy-MM-dd")
}

if ([string]::IsNullOrWhiteSpace($rawTime) -or $rawTime -in @("-", "--")) {
  $time = (Get-Date).ToString("HH:mm:ss")
}
else {
  $time = $rawTime
}

$volume = ConvertTo-IntOrZero $msg.v
if ($volume -eq 0) {
  $volume = ConvertTo-IntOrZero $msg.tv
}

$currentPoint = [ordered]@{
  time = $time
  price = [math]::Round($price, 2)
  volume = $volume
}

$pointsByTime = [ordered]@{}
foreach ($point in (Get-ExistingPoints -Path $OutputPath -Date $date -CurrentIteration $Iteration)) {
  if ($null -ne $point -and ![string]::IsNullOrWhiteSpace([string]$point.time)) {
    $pointsByTime[[string]$point.time] = [ordered]@{
      time = [string]$point.time
      price = ConvertTo-NumberOrNull $point.price
      volume = ConvertTo-IntOrZero $point.volume
    }
  }
}
$pointsByTime[$currentPoint.time] = $currentPoint
$points = @($pointsByTime.GetEnumerator() | Sort-Object Name | ForEach-Object { $_.Value })

$result = [ordered]@{
  symbol = $Symbol
  date = $date
  iteration = $Iteration
  simulatedTime = $time
  isComplete = ((Get-Date).TimeOfDay -ge ([TimeSpan]::Parse("13:30:00")))
  points = $points
  source = "twse-mis"
  updatedAt = (Get-Date).ToString("o")
}

Write-JsonFileUtf8 $OutputPath $result
Write-Host "Wrote intraday TWSE: $OutputPath points=$($points.Count) time=$time channel=$channel"
