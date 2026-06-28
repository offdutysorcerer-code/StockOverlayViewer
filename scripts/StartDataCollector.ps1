param(
  [switch]$Mock,
  [int]$IntervalSeconds = 10,
  [int]$DurationSeconds = 0,
  [switch]$Once
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $root "data"
$groupsPath = Join-Path $dataPath "groups.json"
$intradayPath = Join-Path $dataPath "intraday"
$dailyPath = Join-Path $dataPath "daily"
$latestPath = Join-Path $dataPath "latest.json"

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

$groups = Read-JsonFileUtf8 $groupsPath
$symbols = @($groups | ForEach-Object { $_.symbols } | Sort-Object -Unique)
$startedAt = Get-Date
$iteration = 0

Write-Host "StockOverlayViewer data collector" -ForegroundColor Cyan
Write-Host "Mode: $(if ($Mock) { 'mock' } else { 'real provider not implemented, fallback mock' })"
Write-Host "Symbols: $($symbols -join ', ')"
Write-Host "IntervalSeconds: $IntervalSeconds"
if ($DurationSeconds -gt 0) { Write-Host "DurationSeconds: $DurationSeconds" }

if (!(Test-Path $intradayPath)) { New-Item -ItemType Directory -Path $intradayPath -Force | Out-Null }
if (!(Test-Path $dailyPath)) { New-Item -ItemType Directory -Path $dailyPath -Force | Out-Null }

function Update-Once {
  param([int]$Iteration)

  $symbolIndex = [ordered]@{}

  foreach ($symbol in $symbols) {
    $intradayFile = Join-Path $intradayPath "$symbol.json"
    $dailyFile = Join-Path $dailyPath "$symbol.json"

    & (Join-Path $PSScriptRoot "FetchIntraday.Mock.ps1") -Symbol $symbol -OutputPath $intradayFile -Iteration $Iteration

    if (!(Test-Path $dailyFile)) {
      & (Join-Path $PSScriptRoot "FetchDaily.Mock.ps1") -Symbol $symbol -OutputPath $dailyFile
    }

    $symbolIndex[$symbol] = [ordered]@{
      intraday = "data/intraday/$symbol.json"
      daily = "data/daily/$symbol.json"
      status = "mock"
    }
  }

  $latest = [ordered]@{
    updatedAt = (Get-Date).ToString("o")
    mode = "mock"
    iteration = $Iteration
    symbols = $symbolIndex
  }

  Write-JsonFileUtf8 $latestPath $latest
  Write-Host "Updated latest index: $latestPath" -ForegroundColor Green
}

while ($true) {
  $iteration += 1
  Update-Once -Iteration $iteration

  if ($Once) { break }

  if ($DurationSeconds -gt 0) {
    $elapsed = ((Get-Date) - $startedAt).TotalSeconds
    if ($elapsed -ge $DurationSeconds) {
      Write-Host "Duration reached. Data collector stopped." -ForegroundColor Yellow
      break
    }
  }

  Start-Sleep -Seconds $IntervalSeconds
}
