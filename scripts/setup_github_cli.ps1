[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$SkipAuthCheck,
    [switch]$NonInteractive,
    [string]$Token
)

$ErrorActionPreference = 'Stop'
if ($null -ne (Get-Variable -Name PSNativeCommandUseErrorActionPreference -Scope Global -ErrorAction SilentlyContinue)) {
    $global:PSNativeCommandUseErrorActionPreference = $false
}

function Test-CommandExists([string]$name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Install-GhWithWinget {
    winget install --id GitHub.cli --exact --source winget --accept-source-agreements --accept-package-agreements
}

function Install-GhWithChoco {
    choco install gh -y
}

function Install-GhWithScoop {
    scoop install gh
}

function Install-GhPortableFromGitHub {
    $releaseApi = 'https://api.github.com/repos/cli/cli/releases/latest'
    $headers = @{ 'User-Agent' = 'Khawi-Setup-Script' }

    Write-Output 'Installer: direct-download (portable zip)'
    $release = Invoke-RestMethod -Uri $releaseApi -Headers $headers -Method Get
    $asset = $release.assets | Where-Object { $_.name -match 'windows_amd64\.zip$' } | Select-Object -First 1

    if (-not $asset) {
        throw 'Unable to find a windows_amd64.zip asset in the latest GitHub CLI release.'
    }

    $toolsRoot = Join-Path $PSScriptRoot '.tools'
    $installRoot = Join-Path $toolsRoot 'gh'
    $zipPath = Join-Path $toolsRoot 'gh_portable.zip'

    New-Item -ItemType Directory -Force -Path $toolsRoot | Out-Null
    if (Test-Path $installRoot) {
        Remove-Item -Path $installRoot -Recurse -Force
    }

    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $installRoot -Force
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue

    $ghExe = Get-ChildItem -Path $installRoot -Recurse -Filter gh.exe -File | Select-Object -First 1
    if (-not $ghExe) {
        throw 'Portable install completed, but gh.exe was not found.'
    }

    $binPath = Split-Path -Parent $ghExe.FullName

    if (-not (($env:PATH -split ';') -contains $binPath)) {
        $env:PATH = "$binPath;$env:PATH"
    }

    Write-Output "gh portable install path: $binPath"
}

function Install-GhIfMissing {
    if (Test-CommandExists 'gh') {
        Write-Output 'gh: already installed.'
        return
    }

    if (-not $Install) {
        Write-Output 'gh: not installed.'
        Write-Output 'Re-run with -Install to attempt automatic installation.'
        Write-Output 'Manual install URL: https://cli.github.com/'
        exit 1
    }

    Write-Output 'Attempting to install gh...'

    if (Test-CommandExists 'winget') {
        Write-Output 'Installer: winget'
        Install-GhWithWinget
    }
    elseif (Test-CommandExists 'choco') {
        Write-Output 'Installer: choco'
        Install-GhWithChoco
    }
    elseif (Test-CommandExists 'scoop') {
        Write-Output 'Installer: scoop'
        Install-GhWithScoop
    }
    else {
        Install-GhPortableFromGitHub
    }

    if (-not (Test-CommandExists 'gh')) {
        throw 'gh installation attempted but command is still unavailable in this shell. Open a new terminal and retry.'
    }

    Write-Output 'gh: installed successfully.'
}

function Test-Auth {
    if ($SkipAuthCheck) {
        Write-Output 'Auth check skipped.'
        return
    }

    try {
        gh auth status 1>$null 2>$null
    }
    catch {
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Output 'gh auth: OK.'
        return
    }

    $effectiveToken = $Token
    if ([string]::IsNullOrWhiteSpace($effectiveToken)) {
        $effectiveToken = $env:GH_TOKEN
    }
    if ([string]::IsNullOrWhiteSpace($effectiveToken)) {
        $effectiveToken = $env:GITHUB_TOKEN
    }

    if (-not [string]::IsNullOrWhiteSpace($effectiveToken)) {
        Write-Output 'gh auth: attempting token-based login...'
        try {
            $effectiveToken | gh auth login --hostname github.com --with-token 1>$null 2>$null
        }
        catch {
        }
        if ($LASTEXITCODE -eq 0) {
            Write-Output 'gh auth: token login successful.'
            return
        }
        Write-Output 'gh auth: token login failed.'
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Output 'gh auth: not authenticated.'
        if ($NonInteractive) {
            Write-Output 'NonInteractive mode: not attempting interactive login.'
            Write-Output 'Set GH_TOKEN (or GITHUB_TOKEN) and rerun, or run manually: gh auth login'
            exit 2
        }

        Write-Output 'Run: gh auth login'
        exit 1
    }
}

function Test-RepoContext {
    try {
        gh repo view 1>$null 2>$null
    }
    catch {
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Output 'Repo context: not available in current directory or no access via gh.'
        Write-Output 'Either run inside target repo, or pass -Owner/-Repo to orchestrator scripts.'
        return
    }

    $slug = $null
    try {
        $slug = gh repo view --json nameWithOwner -q .nameWithOwner
    }
    catch {
    }

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($slug)) {
        Write-Output 'Repo context: available, but name lookup failed.'
        return
    }

    Write-Output "Repo context: OK ($slug)"
}

try {
    Write-Output "NonInteractive: $NonInteractive"
    Install-GhIfMissing
    Test-Auth
    Test-RepoContext

    Write-Output ''
    Write-Output 'Next commands:'
    Write-Output '1) Readiness check:'
    Write-Output '   ./scripts/run_gamification_issue_ops.ps1 -InstallHints'
    Write-Output '2) Preview create+sync:'
    Write-Output '   ./scripts/run_gamification_issue_ops.ps1'
    Write-Output '3) Apply full flow:'
    Write-Output '   ./scripts/run_gamification_issue_ops.ps1 -RunCreate -RunSync -RunCleanup -InstallHints -Apply'
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    exit 1
}
