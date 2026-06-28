param(
    [string]$OutputPath,
    [int]$RetryCount = 3
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $projectRoot "data\symbols.json"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$updatedAt = [DateTimeOffset]::Now.ToString("o")

function Get-OfficialJson {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $lastError = $null
    for ($attempt = 1; $attempt -le $RetryCount; $attempt += 1) {
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "StockOverlayViewer/1.0"
            $bytes = $client.DownloadData($Uri)
            $json = [Text.Encoding]::UTF8.GetString($bytes)
            $data = @($json | ConvertFrom-Json)
            if ($data.Count -eq 0) {
                throw "$Label returned no records."
            }
            return $data
        }
        catch {
            $lastError = $_
            if ($attempt -lt $RetryCount) {
                Start-Sleep -Seconds ([Math]::Min($attempt * 2, 5))
            }
        }
    }

    throw "Failed to download $Label after $RetryCount attempts: $($lastError.Exception.Message)"
}

function Add-Symbol {
    param(
        [hashtable]$Symbols,
        [string]$Code,
        [string]$DisplayName,
        [string]$Name,
        [string]$Market,
        [string]$Industry,
        [string]$Source
    )

    $normalizedCode = "$Code".Trim()
    if ($normalizedCode -notmatch "^\d{4}$") {
        return
    }

    $normalizedDisplayName = "$DisplayName".Trim()
    if ([string]::IsNullOrWhiteSpace($normalizedDisplayName)) {
        return
    }

    $normalizedName = "$Name".Trim()
    if ([string]::IsNullOrWhiteSpace($normalizedName)) {
        $normalizedName = $normalizedDisplayName
    }

    $Symbols[$normalizedCode] = [ordered]@{
        name = $normalizedName
        displayName = $normalizedDisplayName
        market = $Market
        industry = "$Industry".Trim()
        source = $Source
        updatedAt = $updatedAt
    }
}

Write-Host "[1/4] Downloading TWSE listed-company metadata..." -ForegroundColor Cyan
$twse = Get-OfficialJson -Uri "https://openapi.twse.com.tw/v1/exchangeReport/STOCK_DAY_ALL" -Label "TWSE listed-company metadata"

Write-Host "[2/4] Downloading TPEx OTC-company metadata..." -ForegroundColor Cyan
$tpex = Get-OfficialJson -Uri "https://www.tpex.org.tw/openapi/v1/mopsfin_t187ap03_O" -Label "TPEx OTC-company metadata"

$symbols = @{}

foreach ($stock in $twse) {
    Add-Symbol -Symbols $symbols -Code $stock.Code -DisplayName $stock.Name -Name $stock.Name -Market "TWSE" -Industry "" -Source "twse-openapi:STOCK_DAY_ALL"
}

foreach ($stock in $tpex) {
    Add-Symbol -Symbols $symbols -Code $stock.SecuritiesCompanyCode -DisplayName $stock.CompanyAbbreviation -Name $stock.Symbol -Market "TPEx" -Industry $stock.SecuritiesIndustryCode -Source "tpex-openapi:mopsfin_t187ap03_O"
}

$twseCount = @($symbols.GetEnumerator() | Where-Object { $_.Value.market -eq "TWSE" }).Count
$tpexCount = @($symbols.GetEnumerator() | Where-Object { $_.Value.market -eq "TPEx" }).Count

if ($twseCount -lt 500 -or $tpexCount -lt 300) {
    throw "Validation failed. Expected at least 500 TWSE and 300 TPEx stocks; received TWSE=$twseCount, TPEx=$tpexCount."
}

Write-Host "[3/4] Validated $($symbols.Count) stocks (TWSE=$twseCount, TPEx=$tpexCount)." -ForegroundColor Green

$orderedSymbols = [ordered]@{}
foreach ($code in @($symbols.Keys | Sort-Object)) {
    $orderedSymbols[$code] = $symbols[$code]
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

$tempFile = Join-Path $outputDirectory ("symbols.{0}.tmp" -f [Guid]::NewGuid().ToString("N"))
try {
    $json = $orderedSymbols | ConvertTo-Json -Depth 5
    [IO.File]::WriteAllText($tempFile, $json + [Environment]::NewLine, $utf8NoBom)

    $verification = [IO.File]::ReadAllText($tempFile, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $verifiedCount = @($verification.PSObject.Properties).Count
    if ($verifiedCount -ne $symbols.Count) {
        throw "Written metadata verification failed: expected $($symbols.Count), found $verifiedCount."
    }

    Move-Item -Path $tempFile -Destination $OutputPath -Force
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

Write-Host "[4/4] Saved UTF-8 metadata to $OutputPath." -ForegroundColor Green
Write-Output ([PSCustomObject]@{
    outputPath = $OutputPath
    total = $symbols.Count
    twse = $twseCount
    tpex = $tpexCount
    updatedAt = $updatedAt
} | ConvertTo-Json -Compress)
