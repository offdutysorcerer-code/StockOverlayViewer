param(
  [Parameter(Mandatory = $true)]
  [string]$Symbol,

  [ValidateSet("Intraday", "Daily")]
  [string]$Mode = "Intraday"
)

# Placeholder for future data fetching automation.
# Possible implementations:
# 1. Invoke a broker API.
# 2. Call a Python script and parse JSON.
# 3. Use browser automation to fetch quote data.
# 4. Read cached data from local files.

$result = [ordered]@{
  symbol = $Symbol
  mode = $Mode
  source = "placeholder"
  updatedAt = (Get-Date).ToString("o")
  message = "Real data provider is not implemented yet."
}

$result | ConvertTo-Json -Depth 5
