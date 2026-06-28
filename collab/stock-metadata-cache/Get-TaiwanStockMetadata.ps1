# Get-TaiwanStockMetadata.ps1
# Purpose: Fetch complete Taiwan stock list (上市/上櫃) from TWSE Open API and save to project format.

$projectRoot = "D:\MarketResearch\Apps\StockOverlayViewer"
$outputFile = Join-Path $projectRoot "data\symbols.json"
$tempDir = Join-Path $projectRoot "collab\stock-metadata-cache"

# Ensure temp directory exists
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Force -Path $tempDir | Out-Null }

$today = Get-Date -Format "yyyyMMdd"

Write-Host "[1/4] Fetching TWSE Listed Stocks..." -ForegroundColor Cyan
try {
    # Use CSV format for better stability
    $urlListed = "https://openapi.twse.com.tw/v1/exchangeReport/TWSE_ALL.csv?date=$today&selectType=ALL"
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
    $csvContentListed = $webClient.DownloadString($urlListed)
    
    # Parse CSV: Stock Code, Name, Price, Change, etc.
    $listedData = $csvContentListed -split "`n" | Where-Object { $_ -ne "" } | ForEach-Object {
        $parts = $_ -split ","
        if ($parts.Count -ge 2) {
            [PSCustomObject]@{
                "股票代號" = $parts[0].Trim()
                "股票名稱" = $parts[1].Trim()
            }
        }
    }
} catch {
    Write-Warning "Failed to fetch listed stocks: $_"
    $listedData = @()
}

Write-Host "[2/4] Fetching TWSE OTC Stocks..." -ForegroundColor Cyan
try {
    $urlOtc = "https://openapi.twse.com.tw/v1/otter/allAllAll.csv?date=$today&selectType=ALL"
    $webClientOtc = New-Object System.Net.WebClient
    $webClientOtc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
    $csvContentOtc = $webClientOtc.DownloadString($urlOtc)
    
    # Parse CSV: Stock Code, Name, Price, Change, etc.
    $otcData = $csvContentOtc -split "`n" | Where-Object { $_ -ne "" } | ForEach-Object {
        $parts = $_ -split ","
        if ($parts.Count -ge 2) {
            [PSCustomObject]@{
                "證券代號" = $parts[0].Trim()
                "證券名稱" = $parts[1].Trim()
            }
        }
    }
} catch {
    Write-Warning "Failed to fetch OTC stocks: $_"
    $otcData = @()
}

Write-Host "[3/4] Processing data..." -ForegroundColor Cyan
$symbols = @{}

# Process Listed Stocks (上市)
if ($listedData) {
    foreach ($stock in $listedData) {
        $code = $stock["股票代號"]
        if ([string]::IsNullOrWhiteSpace($code)) { continue }
        
        $codeStr = $code.PadLeft(4, '0')
        
        $symbols[$codeStr] = @{
            "name" = $stock["股票名稱"]
            "displayName" = $stock["股票名稱"]
            "type" = "上市"
        }
    }
}

# Process OTC Stocks (上櫃)
if ($otcData) {
    foreach ($stock in $otcData) {
        $code = $stock["證券代號"]
        if ([string]::IsNullOrWhiteSpace($code)) { continue }
        
        $codeStr = $code.PadLeft(4, '0')
        
        if (-not $symbols.ContainsKey($codeStr)) {
            $symbols[$codeStr] = @{
                "name" = $stock["證券名稱"]
                "displayName" = $stock["證券名稱"]
                "type" = "上櫃"
            }
        }
    }
}

Write-Host "[4/4] Saving to $outputFile..." -ForegroundColor Cyan
$symbolsJson = $symbols | ConvertTo-Json -Depth 10

try {
    # Backup existing file if it exists and is not empty
    if ((Test-Path $outputFile) -and (Get-Item $outputFile).Length -gt 0) {
        $backupName = Join-Path $tempDir "symbols_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        Copy-Item $outputFile $backupName -Force
        Write-Host "Backup created: $backupName" -ForegroundColor Yellow
    }

    # Save new data
    Set-Content -Path $outputFile -Value $symbolsJson -Encoding UTF8
    Write-Host "Success! Updated $($symbols.Count) stocks." -ForegroundColor Green
} catch {
    Write-Error "Failed to save file: $_"
}
