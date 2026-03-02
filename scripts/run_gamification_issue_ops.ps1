[CmdletBinding()]
param(
    [string]$Owner,
    [string]$Repo,
    [string]$SeedPath = 'docs/gamification_issues_seed.json',
    [switch]$Apply,
    [switch]$RunCreate,
    [switch]$RunSync,
    [switch]$RunCleanup,
    [switch]$ContinueOnStageError,
    [switch]$QuietPreflight,
    [switch]$InstallHints,
    [ValidateSet('not planned', 'completed')]
    [string]$CleanupCloseReason = 'not planned',
    [string]$CleanupComment = 'Closed by automation: issue ID not present in current gamification seed.'
)

$ErrorActionPreference = 'Stop'

function New-CommonParams {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$SeedPath,
        [switch]$Apply,
        [switch]$QuietPreflight
    )

    $commonParams = @{}

    if ($Owner) {
        $commonParams.Owner = $Owner
    }

    if ($Repo) {
        $commonParams.Repo = $Repo
    }

    if ($SeedPath) {
        $commonParams.SeedPath = $SeedPath
    }

    if ($Apply) {
        $commonParams.Apply = $true
    }

    if ($QuietPreflight) {
        $commonParams.QuietPreflight = $true
    }

    return $commonParams
}

function Invoke-Stage {
    param(
        [string]$ScriptPath,
        [hashtable]$StageParams,
        [string]$StageName
    )

    if (-not (Test-Path -Path $ScriptPath)) {
        throw "Missing stage script: $ScriptPath"
    }

    Write-Output "=== $StageName ==="
    & $ScriptPath @StageParams
    if ($LASTEXITCODE -ne 0) {
        throw "Stage failed: $StageName"
    }
}

function Invoke-StageWithPolicy {
    param(
        [string]$ScriptPath,
        [hashtable]$StageParams,
        [string]$StageName,
        [switch]$ContinueOnStageError,
        [ref]$FailedStages
    )

    try {
        Invoke-Stage -ScriptPath $ScriptPath -StageParams $StageParams -StageName $StageName
    }
    catch {
        $FailedStages.Value += $StageName
        if ($ContinueOnStageError) {
            Write-Output "WARN: $($_.Exception.Message)"
            return
        }

        throw
    }
}

function Get-PreflightReport {
    param(
        [string]$Owner,
        [string]$Repo,
        [switch]$RunCreate,
        [switch]$RunSync,
        [switch]$RunCleanup
    )

    $issues = @()
    $notes = @()

    $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $ghCmd) {
        $issues += 'GitHub CLI (`gh`) is not installed.'
        $notes += 'Install GitHub CLI: https://cli.github.com/'
    }
    else {
        $hasTokenEnv = -not [string]::IsNullOrWhiteSpace($env:GH_TOKEN) -or -not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)
        $isAuthenticated = $false

        try {
            gh auth status 1>$null 2>$null
        }
        catch {
        }

        if ($LASTEXITCODE -eq 0) {
            $isAuthenticated = $true
        }
        else {
            try {
                gh api user 1>$null 2>$null
            }
            catch {
            }

            if ($LASTEXITCODE -eq 0) {
                $isAuthenticated = $true
            }
        }

        if (-not $isAuthenticated) {
            $issues += 'GitHub CLI is not authenticated.'
            if ($hasTokenEnv) {
                $notes += 'A token variable is set but auth still failed. Verify token scope and host, then retry.'
            }
            else {
                $notes += 'Authenticate: gh auth login (interactive) or set GH_TOKEN/GITHUB_TOKEN for non-interactive runs.'
            }
        }

        if (-not ($Owner -and $Repo)) {
            try {
                gh repo view 1>$null 2>$null
            }
            catch {
            }
            if ($LASTEXITCODE -ne 0) {
                $issues += 'Repository context could not be resolved automatically.'
                $notes += 'Either run inside a repo with gh access, or pass -Owner and -Repo explicitly.'
            }
        }
    }

    if (-not (Test-Path -Path $SeedPath)) {
        $issues += "Seed file not found: $SeedPath"
        $notes += 'Ensure docs/gamification_issues_seed.json exists or pass -SeedPath.'
    }

    $stagesRequested = $RunCreate -or $RunSync -or $RunCleanup
    if (-not $stagesRequested) {
        $notes += 'Default stage selection is create + sync (cleanup is explicit).'
    }

    return [pscustomobject]@{
        IsReady = ($issues.Count -eq 0)
        Issues = $issues
        Notes = $notes
    }
}

function Show-PreflightReport {
    param($Report)

    if ($Report.IsReady) {
        Write-Output 'Preflight: OK'
        if ($Report.Notes.Count -gt 0) {
            foreach ($note in $Report.Notes) {
                Write-Output "- $note"
            }
        }
        return
    }

    Write-Output 'Preflight: FAILED'
    foreach ($item in $Report.Issues) {
        Write-Output "- $item"
    }

    if ($Report.Notes.Count -gt 0) {
        Write-Output ''
        Write-Output 'Suggested actions:'
        foreach ($note in $Report.Notes) {
            Write-Output "- $note"
        }
    }
}

try {
    # Default behavior: run create + sync only (cleanup must be explicit)
    $hasExplicitStages = $RunCreate -or $RunSync -or $RunCleanup
    if (-not $hasExplicitStages) {
        $RunCreate = $true
        $RunSync = $true
    }

    $commonParams = New-CommonParams `
        -Owner $Owner `
        -Repo $Repo `
        -SeedPath $SeedPath `
        -Apply:$Apply `
        -QuietPreflight:$QuietPreflight

    $modeLabel = 'DRY-RUN'
    if ($Apply) {
        $modeLabel = 'APPLY'
    }
    Write-Output "Mode: $modeLabel"
    Write-Output "Stages: create=$RunCreate, sync=$RunSync, cleanup=$RunCleanup"
    Write-Output "ContinueOnStageError: $ContinueOnStageError"
    Write-Output "QuietPreflight: $QuietPreflight"
    Write-Output "InstallHints: $InstallHints"

    if ($InstallHints) {
        $preflight = Get-PreflightReport `
            -Owner $Owner `
            -Repo $Repo `
            -RunCreate:$RunCreate `
            -RunSync:$RunSync `
            -RunCleanup:$RunCleanup

        Show-PreflightReport -Report $preflight
        if (-not $preflight.IsReady) {
            exit 1
        }
    }

    $failedStages = @()

    if ($RunCreate) {
        Invoke-StageWithPolicy `
            -ScriptPath './scripts/create_gamification_issues.ps1' `
            -StageParams $commonParams `
            -StageName 'Create Milestones/Labels/Issues' `
            -ContinueOnStageError:$ContinueOnStageError `
            -FailedStages ([ref]$failedStages)
    }

    if ($RunSync) {
        Invoke-StageWithPolicy `
            -ScriptPath './scripts/sync_gamification_issues.ps1' `
            -StageParams $commonParams `
            -StageName 'Sync Existing Issues' `
            -ContinueOnStageError:$ContinueOnStageError `
            -FailedStages ([ref]$failedStages)
    }

    if ($RunCleanup) {
        $cleanupParams = @{}
        foreach ($key in $commonParams.Keys) {
            $cleanupParams[$key] = $commonParams[$key]
        }
        $cleanupParams.CloseReason = $CleanupCloseReason
        if ($CleanupComment) {
            $cleanupParams.Comment = $CleanupComment
        }

        Invoke-StageWithPolicy `
            -ScriptPath './scripts/cleanup_gamification_issues.ps1' `
            -StageParams $cleanupParams `
            -StageName 'Cleanup Stale Issues' `
            -ContinueOnStageError:$ContinueOnStageError `
            -FailedStages ([ref]$failedStages)
    }

    if ($failedStages.Count -gt 0) {
        Write-Output "Completed with stage failures: $($failedStages -join ', ')"
        exit 1
    }

    Write-Output 'Done.'
    Write-Output 'Tip: run without -Apply to preview; add -Apply to execute changes.'
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    exit 1
}
