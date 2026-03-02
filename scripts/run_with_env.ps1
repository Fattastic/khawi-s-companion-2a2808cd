# Run Flutter with --dart-define values from .env
# Usage: .\scripts\run_with_env.ps1 [-Device windows]

param(
  [string]$Device = "windows"
)

$envPath = Join-Path $PSScriptRoot "..\.env"
if (-not (Test-Path $envPath)) {
  Write-Error "Missing .env at $envPath"
  exit 1
}

$defines = @()
Get-Content $envPath | ForEach-Object {
  $line = $_.Trim()
  if ($line -eq "" -or $line.StartsWith("#")) { return }
  $parts = $line.Split("=",2)
  if ($parts.Count -ne 2) { return }
  $key = $parts[0].Trim()
  $value = $parts[1].Trim()
  if ($value -eq "") { return }
  $defines += "--dart-define=$key=$value"
}

if ($defines.Count -eq 0) {
  Write-Error "No dart-define entries found in .env"
  exit 1
}

$cmd = @("flutter","run","-d",$Device) + $defines
Write-Host ("Running: " + ($cmd -join " "))
& $cmd
