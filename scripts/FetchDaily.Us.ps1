param(
  [Parameter(Mandatory = $true)]
  [string]$Symbol,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$supportedSymbols = @("AAPL", "MSFT", "NVDA", "AMD", "TSM")
$normalizedSymbol = $Symbol.Trim().ToUpperInvariant()
if ($supportedSymbols -notcontains $normalizedSymbol) {
  throw "Unsupported US MVP symbol: $Symbol. Supported symbols: $($supportedSymbols -join ', ')"
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

function Invoke-YahooChart([string]$StockSymbol) {
  $escapedSymbol = [uri]::EscapeDataString($StockSymbol)
  $uri = "https://query1.finance.yahoo.com/v8/finance/chart/${escapedSymbol}?range=6mo&interval=1d&includePrePost=false"
  $headers = @{
    "User-Agent" = "Mozilla/5.0 StockOverlayViewer/1.0"
    "Accept" = "application/json,text/plain,*/*"
  }

  return Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -TimeoutSec 30
}

function ConvertTo-NumberOrNull($Value) {
  if ($null -eq $Value) { return $null }
  $number = 0.0
  if ([double]::TryParse([string]$Value, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$number)) {
    if ([double]::IsNaN($number) -or [double]::IsInfinity($number)) { return $null }
    return $number
  }
  return $null
}

function ConvertTo-EasternDate([int64]$UnixSeconds) {
  $utc = [DateTimeOffset]::FromUnixTimeSeconds($UnixSeconds).UtcDateTime
  $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Eastern Standard Time")
  return ([System.TimeZoneInfo]::ConvertTimeFromUtc($utc, $timeZone)).ToString("yyyy-MM-dd")
}

$response = Invoke-YahooChart $normalizedSymbol
$result = @($response.chart.result) | Select-Object -First 1
if ($null -eq $result) {
  throw "Yahoo Finance daily response did not contain chart result. Symbol=$normalizedSymbol"
}

$timestamps = @($result.timestamp)
$quote = @($result.indicators.quote) | Select-Object -First 1
if ($timestamps.Count -eq 0 -or $null -eq $quote) {
  throw "Yahoo Finance daily response did not contain usable timestamps/quotes. Symbol=$normalizedSymbol"
}

$opens = @($quote.open)
$highs = @($quote.high)
$lows = @($quote.low)
$closes = @($quote.close)
$volumes = @($quote.volume)
$candles = @()

for ($i = 0; $i -lt $timestamps.Count; $i++) {
  $open = ConvertTo-NumberOrNull $opens[$i]
  $high = ConvertTo-NumberOrNull $highs[$i]
  $low = ConvertTo-NumberOrNull $lows[$i]
  $close = ConvertTo-NumberOrNull $closes[$i]
  if ($null -eq $open -or $null -eq $high -or $null -eq $low -or $null -eq $close) { continue }

  $volume = 0
  if ($i -lt $volumes.Count -and $null -ne $volumes[$i]) { $volume = [int64]$volumes[$i] }

  $candles += [ordered]@{
    date = ConvertTo-EasternDate ([int64]$timestamps[$i])
    open = [math]::Round($open, 2)
    high = [math]::Round($high, 2)
    low = [math]::Round($low, 2)
    close = [math]::Round($close, 2)
    volume = $volume
  }
}

if ($candles.Count -eq 0) {
  throw "Yahoo Finance daily response did not contain usable candles. Symbol=$normalizedSymbol"
}

$resultObject = [ordered]@{
  symbol = $normalizedSymbol
  candles = @($candles | Sort-Object date)
  source = "yahoo-finance-chart-1d"
  updatedAt = (Get-Date).ToString("o")
}

Write-JsonFileUtf8 $OutputPath $resultObject
Write-Host "Wrote daily US: $OutputPath candles=$($candles.Count) symbol=$normalizedSymbol"
