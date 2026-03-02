param(
  [Parameter(Mandatory = $false)]
  [string]$GoogleSecretJsonPath = "",

  [Parameter(Mandatory = $false)]
  [switch]$NoRestart
)

$ErrorActionPreference = "Stop"

function Resolve-GoogleSecretPath {
  param([string]$PathHint)

  if ($PathHint -and (Test-Path $PathHint)) {
    return (Resolve-Path $PathHint).Path
  }

  # Try to find a client_secret_*.json under workspace sibling folder "Khawi-client"
  $workspaceRoot = Split-Path -Parent $PSScriptRoot  # ...\Khawi_Flutter
  $repoRoot = Split-Path -Parent $workspaceRoot      # ...\Khawi
  $candidateDir = Join-Path $repoRoot "Khawi-client"

  if (Test-Path $candidateDir) {
    $match = Get-ChildItem -Path $candidateDir -Filter "client_secret_*.json" -File -ErrorAction SilentlyContinue |
      Select-Object -First 1
    if ($match) {
      return $match.FullName
    }
  }

  throw "Google client secret JSON not found. Pass -GoogleSecretJsonPath or place it under $candidateDir as client_secret_*.json"
}

$secretPath = Resolve-GoogleSecretPath -PathHint $GoogleSecretJsonPath

# Parse the Google OAuth client JSON (web client)
$json = Get-Content -Raw -Path $secretPath | ConvertFrom-Json

if (-not $json.web) {
  throw "Expected a Google OAuth 'web' client JSON (missing .web)."
}

$clientId = $json.web.client_id
$clientSecret = $json.web.client_secret

if (-not $clientId -or -not $clientSecret) {
  throw "Missing client_id/client_secret in Google OAuth JSON."
}

# Export env vars for Supabase CLI (in this PowerShell session)
$env:SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID = $clientId
$env:SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET = $clientSecret

Write-Host "Loaded Google OAuth env vars for local Supabase (client id set; secret set)." -ForegroundColor Green
Write-Host "Note: For local Google OAuth you must add this Authorized redirect URI in Google Cloud Console:" -ForegroundColor Yellow
Write-Host "  http://127.0.0.1:54321/auth/v1/callback" -ForegroundColor Yellow
Write-Host "And run Flutter web on a fixed port (recommended):" -ForegroundColor Yellow
Write-Host "  flutter run -d chrome --web-port=3000 --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=<local publishable>" -ForegroundColor Yellow

if (-not $NoRestart) {
  Push-Location (Split-Path -Parent $PSScriptRoot) # ...\Khawi_Flutter
  try {
    # Work around occasional Windows Docker name conflicts for the vector container.
    # Safe to ignore failures.
    try {
      docker rm -f supabase_vector_Khawi_flutter | Out-Null
    } catch {
      # ignore
    }

    supabase stop
    try {
      docker rm -f supabase_vector_Khawi_flutter | Out-Null
    } catch {
      # ignore
    }
    supabase start
  } finally {
    Pop-Location
  }
}
