param(
  [switch]$Mock,
  [ValidateSet("mock", "twse")]
  [string]$Provider = "mock",
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

function Resolve-ProviderName {
  if ($Mock) { return "mock" }
  return $Provider.ToLowerInvariant()
}

function Get-ProviderScript {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Intraday", "Daily")]
    [string]$Kind,

    [Parameter(Mandatory = $true)]
    [string]$ProviderName
  )

  $scriptName = switch ($ProviderName) {
    "mock" { "Fetch$Kind.Mock.ps1" }
    "twse" { "Fetch$Kind.Twse.ps1" }
    default { throw "Unsupported provider: $ProviderName" }
  }

  $scriptPath = Join-Path $PSScriptRoot $scriptName
  if (!(Test-Path $scriptPath)) {
    throw "Provider script not implemented yet: $scriptName"
  }

  return $scriptPath
}

$providerName = Resolve-ProviderName
$intradayProviderScript = Get-ProviderScript -Kind "Intraday" -ProviderName $providerName
$dailyProviderScript = Get-ProviderScript -Kind "Daily" -ProviderName $providerName

$groups = Read-JsonFileUtf8 $groupsPath
$symbols = @($groups | ForEach-Object { $_.symbols } | Sort-Object -Unique)
$startedAt = Get-Date
$iteration = 0

Write-Host "StockOverlayViewer data collector" -ForegroundColor Cyan
Write-Host "Provider: $providerName"
Write-Host "Intraday script: $([System.IO.Path]::GetFileName($intradayProviderScript))"
Write-Host "Daily script: $([System.IO.Path]::GetFileName($dailyProviderScript))"
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

    & $intradayProviderScript -Symbol $symbol -OutputPath $intradayFile -Iteration $Iteration

    if (!(Test-Path $dailyFile) -or $Once) {
      & $dailyProviderScript -Symbol $symbol -OutputPath $dailyFile
    }

    $symbolIndex[$symbol] = [ordered]@{
      intraday = "data/intraday/$symbol.json"
      daily = "data/daily/$symbol.json"
      status = $providerName
    }
  }

  $latest = [ordered]@{
    updatedAt = (Get-Date).ToString("o")
    mode = $providerName
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
