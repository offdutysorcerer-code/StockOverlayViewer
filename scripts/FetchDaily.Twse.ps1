param(
  [Parameter(Mandatory = $true)]
  [string]$Symbol,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

throw @"
TWSE daily provider is not implemented yet.
Provider switching is now wired through StartDataCollector.ps1 so this file can be implemented without changing the frontend data contract.
Symbol: $Symbol
OutputPath: $OutputPath
"@
