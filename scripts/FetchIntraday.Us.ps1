param(
  [Parameter(Mandatory = $true)]
  [string]$Symbol,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath,

  [int]$Iteration = 1
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
  $uri = "https://query1.finance.yahoo.com/v8/finance/chart/${escapedSymbol}?range=1d&interval=1m&includePrePost=false"
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

function ConvertTo-EasternTime([int64]$UnixSeconds) {
  $utc = [DateTimeOffset]::FromUnixTimeSeconds($UnixSeconds).UtcDateTime
  $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Eastern Standard Time")
  return [System.TimeZoneInfo]::ConvertTimeFromUtc($utc, $timeZone)
}

$response = Invoke-YahooChart $normalizedSymbol
$result = @($response.chart.result) | Select-Object -First 1
if ($null -eq $result) {
  throw "Yahoo Finance intraday response did not contain chart result. Symbol=$normalizedSymbol"
}

$timestamps = @($result.timestamp)
$quote = @($result.indicators.quote) | Select-Object -First 1
if ($timestamps.Count -eq 0 -or $null -eq $quote) {
  throw "Yahoo Finance intraday response did not contain usable timestamps/quotes. Symbol=$normalizedSymbol"
}

$opens = @($quote.open)
$highs = @($quote.high)
$lows = @($quote.low)
$closes = @($quote.close)
$volumes = @($quote.volume)
$points = @()

for ($i = 0; $i -lt $timestamps.Count; $i++) {
  $close = ConvertTo-NumberOrNull $closes[$i]
  if ($null -eq $close) { continue }

  $localTime = ConvertTo-EasternTime ([int64]$timestamps[$i])
  $volume = 0
  if ($i -lt $volumes.Count -and $null -ne $volumes[$i]) { $volume = [int64]$volumes[$i] }

  $points += [ordered]@{
    time = $localTime.ToString("HH:mm:ss")
    price = [math]::Round($close, 2)
    volume = $volume
  }
}

if ($points.Count -eq 0) {
  throw "Yahoo Finance intraday response did not contain usable intraday prices. Symbol=$normalizedSymbol"
}

$lastTimestamp = [int64]$timestamps[$timestamps.Count - 1]
$lastLocalTime = ConvertTo-EasternTime $lastTimestamp
$resultObject = [ordered]@{
  symbol = $normalizedSymbol
  date = $lastLocalTime.ToString("yyyy-MM-dd")
  iteration = $Iteration
  simulatedTime = $points[-1].time
  isComplete = ($points[-1].time -ge "16:00:00")
  points = $points
  source = "yahoo-finance-chart-1m"
  updatedAt = (Get-Date).ToString("o")
}

Write-JsonFileUtf8 $OutputPath $resultObject
Write-Host "Wrote intraday US: $OutputPath points=$($points.Count) symbol=$normalizedSymbol"
