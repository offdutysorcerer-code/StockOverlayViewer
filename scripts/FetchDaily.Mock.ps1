param(
  [Parameter(Mandatory = $true)]
  [string]$Symbol,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

function Get-Seed([string]$symbol) {
  $digits = ($symbol.ToCharArray() | Where-Object { $_ -match "\d" }) -join ""
  if ([string]::IsNullOrWhiteSpace($digits)) { return 1000 }
  return [int]$digits
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

$seed = Get-Seed $Symbol
$basePrice = 50 + ($seed % 900)
$candles = @()

for ($i = 59; $i -ge 0; $i--) {
  $date = (Get-Date).Date.AddDays(-$i)
  $close = $basePrice + [math]::Sin($i / 4.0 + $seed) * 8 + (60 - $i) * 0.12

  $candles += [ordered]@{
    date = $date.ToString("yyyy-MM-dd")
    open = [math]::Round($close - 1, 2)
    high = [math]::Round($close + 3, 2)
    low = [math]::Round($close - 4, 2)
    close = [math]::Round($close, 2)
    volume = 5000 + [math]::Abs(($seed * ($i + 3)) % 50000)
  }
}

$result = [ordered]@{
  symbol = $Symbol
  candles = $candles
  source = "mock-powershell"
  updatedAt = (Get-Date).ToString("o")
}

Write-JsonFileUtf8 $OutputPath $result
Write-Host "Wrote daily mock: $OutputPath"
