param(
  [int]$Port = 5174
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$frontendPath = Join-Path $root "frontend"
$dataPath = Join-Path $root "data"
$groupsPath = Join-Path $dataPath "groups.json"
$symbolsPath = Join-Path $dataPath "symbols.json"
$collectorPidPath = Join-Path $dataPath "collector.pid"
$prefix = "http://localhost:$Port/"

function Get-ContentType([string]$Path) {
  $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
  switch ($extension) {
    ".html" { return "text/html; charset=utf-8" }
    ".css"  { return "text/css; charset=utf-8" }
    ".js"   { return "application/javascript; charset=utf-8" }
    ".json" { return "application/json; charset=utf-8" }
    default  { return "application/octet-stream" }
  }
}

function Write-TextResponse($Context, [int]$StatusCode, [string]$Text, [string]$ContentType = "text/plain; charset=utf-8") {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
  $Context.Response.StatusCode = $StatusCode
  $Context.Response.ContentType = $ContentType
  $Context.Response.Headers.Add("Cache-Control", "no-store")
  $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $Context.Response.Close()
}

function Write-JsonResponse($Context, [int]$StatusCode, $Value) {
  $json = $Value | ConvertTo-Json -Depth 30
  Write-TextResponse $Context $StatusCode $json "application/json; charset=utf-8"
}

function Read-RequestBody($Request) {
  $reader = New-Object System.IO.StreamReader($Request.InputStream, $Request.ContentEncoding)
  try { return $reader.ReadToEnd() } finally { $reader.Close() }
}

function Write-JsonFileUtf8([string]$Path, [string]$JsonText) {
  $parsed = $JsonText | ConvertFrom-Json
  $json = $parsed | ConvertTo-Json -Depth 30
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $json, $utf8NoBom)
}

function Resolve-RequestPath([string]$RawPath) {
  $relativePath = [Uri]::UnescapeDataString($RawPath.TrimStart("/"))
  if ([string]::IsNullOrWhiteSpace($relativePath)) { $relativePath = "index.html" }
  if ($relativePath -eq "favicon.ico") { return $null }
  if ($relativePath.StartsWith("data/")) {
    $dataRelative = $relativePath.Substring(5).Replace("/", "\")
    return Join-Path $dataPath $dataRelative
  }
  return Join-Path $frontendPath ($relativePath.Replace("/", "\"))
}

function Find-Value($Object, [string[]]$Names) {
  foreach ($name in $Names) {
    if ($Object.PSObject.Properties.Name -contains $name) {
      $value = $Object.$name
      if ($null -ne $value -and "$value".Trim() -ne "") { return "$value" }
    }
  }
  return ""
}

function Lookup-Symbol([string]$Symbol) {
  $normalized = $Symbol.Trim().ToUpperInvariant()
  if (Test-Path $symbolsPath) {
    try {
      $json = [System.IO.File]::ReadAllText($symbolsPath, [System.Text.Encoding]::UTF8)
      $symbols = $json | ConvertFrom-Json
      $property = $symbols.PSObject.Properties[$normalized]
      if ($null -ne $property) {
        $item = $property.Value
        return [ordered]@{
          symbol = $normalized
          displayName = "$($item.displayName)"
          name = "$($item.name)"
          market = "$($item.market)"
          industry = "$($item.industry)"
          source = "$($item.source)"
          updatedAt = "$($item.updatedAt)"
        }
      }
    }
    catch {
      Write-Warning "Failed to read local symbol metadata: $($_.Exception.Message)"
    }
  }

  return [ordered]@{
    symbol = $normalized
    displayName = ""
    name = ""
    market = "unknown"
    source = "not-found"
    updatedAt = (Get-Date).ToString("o")
  }
}

function Get-CollectorProcess() {
  if (!(Test-Path $collectorPidPath)) { return $null }
  $pidText = [System.IO.File]::ReadAllText($collectorPidPath).Trim()
  if ([string]::IsNullOrWhiteSpace($pidText)) { return $null }
  try {
    $process = Get-Process -Id ([int]$pidText) -ErrorAction Stop
    return $process
  } catch {
    Remove-Item $collectorPidPath -Force -ErrorAction SilentlyContinue
    return $null
  }
}

function Start-Collector([int]$IntervalSeconds, [int]$DurationSeconds) {
  $existing = Get-CollectorProcess
  if ($null -ne $existing) {
    return [ordered]@{ status = "already-running"; pid = $existing.Id; intervalSeconds = $IntervalSeconds; durationSeconds = $DurationSeconds }
  }

  $collectorScript = Join-Path $PSScriptRoot "StartDataCollector.ps1"
  $args = @(
    "-NoLogo",
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $collectorScript,
    "-Mock",
    "-IntervalSeconds", $IntervalSeconds,
    "-DurationSeconds", $DurationSeconds
  )

  $process = Start-Process -FilePath "powershell.exe" -ArgumentList $args -WorkingDirectory $root -PassThru -WindowStyle Minimized
  [System.IO.File]::WriteAllText($collectorPidPath, "$($process.Id)", [System.Text.Encoding]::ASCII)
  return [ordered]@{ status = "started"; pid = $process.Id; intervalSeconds = $IntervalSeconds; durationSeconds = $DurationSeconds; updatedAt = (Get-Date).ToString("o") }
}

function Stop-Collector() {
  $process = Get-CollectorProcess
  if ($null -eq $process) {
    return [ordered]@{ status = "not-running"; updatedAt = (Get-Date).ToString("o") }
  }
  Stop-Process -Id $process.Id -Force
  Remove-Item $collectorPidPath -Force -ErrorAction SilentlyContinue
  return [ordered]@{ status = "stopped"; pid = $process.Id; updatedAt = (Get-Date).ToString("o") }
}

function Handle-Api($Context) {
  $path = $Context.Request.Url.AbsolutePath
  $method = $Context.Request.HttpMethod

  if ($method -eq "GET" -and $path -eq "/api/symbols/lookup") {
    $symbol = $Context.Request.QueryString["symbol"]
    if ([string]::IsNullOrWhiteSpace($symbol)) {
      Write-JsonResponse $Context 400 @{ error = "MissingSymbol"; message = "symbol query parameter is required" }
      return $true
    }
    Write-JsonResponse $Context 200 (Lookup-Symbol $symbol.Trim())
    return $true
  }

  if ($method -eq "POST" -and $path -eq "/api/groups/save") {
    Write-JsonFileUtf8 $groupsPath (Read-RequestBody $Context.Request)
    Write-JsonResponse $Context 200 @{ status = "saved"; path = "data/groups.json"; updatedAt = (Get-Date).ToString("o") }
    return $true
  }

  if ($method -eq "POST" -and $path -eq "/api/symbols/save") {
    Write-JsonFileUtf8 $symbolsPath (Read-RequestBody $Context.Request)
    Write-JsonResponse $Context 200 @{ status = "saved"; path = "data/symbols.json"; updatedAt = (Get-Date).ToString("o") }
    return $true
  }

  if ($method -eq "POST" -and $path -eq "/api/collector/start") {
    $intervalText = $Context.Request.QueryString["intervalSeconds"]
    if ([string]::IsNullOrWhiteSpace($intervalText)) { $intervalText = "2" }
    $interval = [int]$intervalText
    $durationText = $Context.Request.QueryString["durationSeconds"]
    if ([string]::IsNullOrWhiteSpace($durationText)) { $durationText = "60" }
    $duration = [int]$durationText
    if ($interval -lt 1) { $interval = 1 }
    if ($duration -lt 1) { $duration = 60 }
    Write-JsonResponse $Context 200 (Start-Collector $interval $duration)
    return $true
  }

  if ($method -eq "POST" -and $path -eq "/api/collector/stop") {
    Write-JsonResponse $Context 200 (Stop-Collector)
    return $true
  }

  if ($method -eq "GET" -and $path -eq "/api/collector/status") {
    $process = Get-CollectorProcess
    if ($null -eq $process) { Write-JsonResponse $Context 200 @{ status = "not-running" } }
    else { Write-JsonResponse $Context 200 @{ status = "running"; pid = $process.Id } }
    return $true
  }

  return $false
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()

Write-Host "Starting StockOverlayViewer frontend..." -ForegroundColor Cyan
Write-Host "Frontend: $frontendPath"
Write-Host "Data:     $dataPath"
Write-Host "URL:      $prefix" -ForegroundColor Green
Write-Host "API:      /api/collector/start, /api/collector/stop, /api/symbols/lookup"
Write-Host "Press Ctrl+C to stop."

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    if (Handle-Api $context) { continue }

    $filePath = Resolve-RequestPath $context.Request.Url.AbsolutePath
    if ($null -eq $filePath -or !(Test-Path $filePath) -or (Get-Item $filePath).PSIsContainer) {
      Write-TextResponse $context 404 "Not Found"
      continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $context.Response.StatusCode = 200
    $context.Response.ContentType = Get-ContentType $filePath
    $context.Response.Headers.Add("Cache-Control", "no-store")
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.Close()
  }
} finally {
  Stop-Collector | Out-Null
  if ($listener.IsListening) { $listener.Stop() }
  $listener.Close()
}
