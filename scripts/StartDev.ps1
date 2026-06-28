$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$apiPath = Join-Path $root "backend\StockOverlay.Api"
$frontendPath = Join-Path $root "frontend"

Write-Host "StockOverlayViewer dev launcher" -ForegroundColor Cyan
Write-Host "Root: $root"

if (Test-Path (Join-Path $apiPath "Program.cs.txt")) {
  Write-Host "Program.cs.txt exists. MCP could not write .cs directly." -ForegroundColor Yellow
  Write-Host "After running dotnet new web, rename/copy Program.cs.txt to Program.cs." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Backend suggested command:" -ForegroundColor Green
Write-Host "cd `"$apiPath`""
Write-Host "dotnet run --urls http://localhost:5088"

Write-Host ""
Write-Host "Frontend suggested command:" -ForegroundColor Green
Write-Host "cd `"$frontendPath`""
Write-Host "python -m http.server 5174"
Write-Host "Open http://localhost:5174"
