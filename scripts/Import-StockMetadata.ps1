# Import-StockMetadata.ps1
# Purpose: Import stock metadata from local CSV/JSON files to update data/symbols.json.
# Usage: 
#   .\scripts\Import-StockMetadata.ps1 -FilePath "C:\path\to\stocks.csv"
#   .\scripts\Import-StockMetadata.ps1 -JsonFile "C:\path\to\stocks.json"

param(
    [string]$FilePath,
    [string]$JsonFile,
    [string]$OutputFile
)

$projectRoot = "D:\MarketResearch\Apps\StockOverlayViewer"
if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = Join-Path $projectRoot "data\symbols.json"
} elseif (-not [System.IO.Path]::IsPathRooted($OutputFile)) {
    $OutputFile = Join-Path (Get-Location) $OutputFile
}
$outputFile = [System.IO.Path]::GetFullPath($OutputFile)

if (-not $FilePath -and -not $JsonFile) {
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  .\scripts\Import-StockMetadata.ps1 -FilePath `"C:\path\to\stocks.csv`"" -ForegroundColor Yellow
    Write-Host "  .\scripts\Import-StockMetadata.ps1 -JsonFile `"C:\path\to\stocks.json`"" -ForegroundColor Yellow
    exit 1
}

$symbols = @{}

if ($FilePath) {
    if (-not (Test-Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        exit 1
    }
    
    Write-Host "[1/3] Reading CSV file: $FilePath" -ForegroundColor Cyan
    
    # Try to detect format and parse accordingly
    $content = Get-Content $FilePath -Raw
    $lines = $content -split "`n" | Where-Object { $_ -ne "" }
    
    if ($lines.Count -gt 0) {
        # Assume first line is header
        $header = $lines[0] -split ","
        
        for ($i = 1; $i -lt $lines.Count; $i++) {
            $parts = $lines[$i] -split ","
            
            if ($parts.Count -ge 2) {
                # Try to find code and name columns
                $codeIdx = -1
                $nameIdx = -1
                
                for ($j = 0; $j -lt $header.Count; $j++) {
                    $h = $header[$j].Trim().ToLower()
                    if ($h -match "代號|code|stock.*code") { $codeIdx = $j }
                    if ($h -match "名稱|name|stock.*name") { $nameIdx = $j }
                }
                
                # Fallback: assume first column is code, second is name
                if ($codeIdx -eq -1) { $codeIdx = 0 }
                if ($nameIdx -eq -1) { $nameIdx = 1 }
                
                $code = $parts[$codeIdx].Trim()
                $name = $parts[$nameIdx].Trim()
                
                if ([string]::IsNullOrWhiteSpace($code)) { continue }
                
                $codeStr = $code.PadLeft(4, '0')
                $symbols[$codeStr] = @{
                    "name" = $name
                    "displayName" = $name
                }
            }
        }
    }
    
    Write-Host "[2/3] Parsed $($symbols.Count) stocks from CSV." -ForegroundColor Green
}

if ($JsonFile) {
    if (-not (Test-Path $JsonFile)) {
        Write-Error "JSON file not found: $JsonFile"
        exit 1
    }
    
    Write-Host "[1/3] Reading JSON file: $JsonFile" -ForegroundColor Cyan
    
    $jsonText = [System.IO.File]::ReadAllText($JsonFile, [System.Text.Encoding]::UTF8)
    $jsonData = $jsonText | ConvertFrom-Json
    
    foreach ($key in $jsonData.PSObject.Properties.Name) {
        $item = $jsonData.$key
        
        if ($item.name -and $item.displayName) {
            $symbols[$key] = @{
                "name" = $item.name
                "displayName" = $item.displayName
            }
        } elseif ($item.name) {
            $symbols[$key] = @{
                "name" = $item.name
                "displayName" = $item.name
            }
        } else {
            # Assume simple object: key is code, value is name string
            $codeStr = $key.PadLeft(4, '0')
            $symbols[$codeStr] = @{
                "name" = $item
                "displayName" = $item
            }
        }
    }
    
    Write-Host "[2/3] Parsed $($symbols.Count) stocks from JSON." -ForegroundColor Green
}

Write-Host "[3/3] Saving to $outputFile..." -ForegroundColor Cyan

# Backup existing file
if ((Test-Path $outputFile) -and (Get-Item $outputFile).Length -gt 0) {
    $backupName = Join-Path $projectRoot "collab\stock-metadata-cache\symbols_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Copy-Item $outputFile $backupName -Force
    Write-Host "Backup created: $backupName" -ForegroundColor Yellow
}

# Save new data as UTF-8 without BOM, matching docs/Contract.md.
$symbolsJson = $symbols | ConvertTo-Json -Depth 10
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outputFile, $symbolsJson + [Environment]::NewLine, $utf8NoBom)
Write-Host "Success! Updated $($symbols.Count) stocks." -ForegroundColor Green
