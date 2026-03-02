$choice = Read-Host "Run with [1] Local Supabase or [2] Cloud Supabase? (default is 1)"
if ($choice -eq "2") {
    $url = "https://oxcustajfzeqibnkjthp.supabase.co"
    $key = "sb_publishable_jjF9aK40I9cWynRsw2vKeQ_3dtvVsaz"
    Write-Host "Using CLOUD Supabase..." -ForegroundColor Cyan
}
else {
    $url = "http://127.0.0.1:54321"
    $key = "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"
    Write-Host "Using LOCAL Supabase..." -ForegroundColor Cyan
}

Write-Host "Ensuring Web is enabled..." -ForegroundColor Yellow
flutter config --enable-web

Write-Host "Checking connected devices..." -ForegroundColor Yellow
flutter devices

$flutterArgs = @(
    "run",
    "-d",
    "chrome",
    "--web-port=4200",
    "--dart-define=SUPABASE_URL=$url",
    "--dart-define=SUPABASE_ANON_KEY=$key",
    "--dart-define=SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=129754711874-3mjqg3b9jdqff9f65mensv7u0maila8e.apps.googleusercontent.com"
)

Write-Host "Launching Khawi with args: $flutterArgs" -ForegroundColor Green
& flutter $flutterArgs
