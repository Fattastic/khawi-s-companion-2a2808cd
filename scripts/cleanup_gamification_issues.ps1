[CmdletBinding()]
param(
    [string]$Owner,
    [string]$Repo,
    [string]$SeedPath = 'docs/gamification_issues_seed.json',
    [switch]$Apply,
    [switch]$QuietPreflight,
    [ValidateSet('not planned', 'completed')]
    [string]$CloseReason = 'not planned',
    [string]$Comment = 'Closed by automation: issue ID not present in current gamification seed.'
)

$ErrorActionPreference = 'Stop'

function Assert-Tool([string]$name) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required tool not found: $name"
    }
}

function Resolve-Repo {
    param([string]$Owner, [string]$Repo)

    if ($Owner -and $Repo) {
        return "$Owner/$Repo"
    }

    $nameWithOwner = gh repo view --json nameWithOwner -q .nameWithOwner 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($nameWithOwner)) {
        throw 'Unable to resolve repository. Provide -Owner and -Repo, or run inside a gh-authenticated repo context.'
    }

    return $nameWithOwner.Trim()
}

function Get-SeedIds([string]$path) {
    if (-not (Test-Path -Path $path)) {
        throw "Seed file not found: $path"
    }

    $seed = Get-Content -Raw -Path $path | ConvertFrom-Json
    $ids = @{}
    foreach ($issue in $seed.issues) {
        $ids[[string]$issue.id] = $true
    }
    return $ids
}

function Invoke-Step {
    param(
        [string]$Description,
        [scriptblock]$Command,
        [switch]$Apply
    )

    if ($Apply) {
        Write-Output "APPLY: $Description"
        & $Command
    } else {
        Write-Output "DRY-RUN: $Description"
    }
}

function Get-OpenGamificationIssues {
    param([string]$RepoSlug)

    $results = gh issue list --repo "$RepoSlug" --state open --search "GAMI- in:title" --json number,title,url --limit 500
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($results)) {
        return @()
    }

    return ($results | ConvertFrom-Json)
}

function Get-IssueId([string]$title) {
    if ($title -match '^(GAMI-\d+)') {
        return $Matches[1]
    }
    return $null
}

function Close-Issue {
    param(
        [string]$RepoSlug,
        [int]$Number,
        [string]$Reason,
        [string]$Comment,
        [switch]$Apply
    )

    Invoke-Step -Description "Close issue #$Number with reason '$Reason'" -Apply:$Apply -Command {
        gh issue close $Number --repo "$RepoSlug" --reason "$Reason" --comment "$Comment" | Out-Null
    }
}

try {
    Assert-Tool 'gh'
    $repoSlug = Resolve-Repo -Owner $Owner -Repo $Repo
    $seedIds = Get-SeedIds -path $SeedPath

    Write-Output "Target repo: $repoSlug"
    $modeLabel = 'DRY-RUN'
    if ($Apply) {
        $modeLabel = 'APPLY'
    }
    Write-Output "Mode: $modeLabel"

    $openIssues = Get-OpenGamificationIssues -RepoSlug $repoSlug
    if (-not $openIssues -or $openIssues.Count -eq 0) {
        Write-Output 'No open GAMI issues found.'
        Write-Output 'Done.'
        exit 0
    }

    $stale = @()
    foreach ($issue in $openIssues) {
        $id = Get-IssueId -title ([string]$issue.title)
        if (-not $id) {
            continue
        }

        if (-not $seedIds.ContainsKey($id)) {
            $stale += $issue
        }
    }

    if ($stale.Count -eq 0) {
        Write-Output 'No stale GAMI issues found (all open IDs exist in seed).'
        Write-Output 'Done.'
        exit 0
    }

    Write-Output "Stale issues found: $($stale.Count)"
    foreach ($issue in $stale) {
        Write-Output "- #$($issue.number): $($issue.title)"
    }

    foreach ($issue in $stale) {
        Close-Issue -RepoSlug $repoSlug -Number ([int]$issue.number) -Reason $CloseReason -Comment $Comment -Apply:$Apply
    }

    Write-Output 'Done.'
    Write-Output 'Tip: run without -Apply to preview, then with -Apply to close stale issues.'
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    if (-not $QuietPreflight) {
        Write-Output ''
        Write-Output 'Preflight checklist:'
        Write-Output '1) Install GitHub CLI: https://cli.github.com/'
        Write-Output '2) Authenticate: gh auth login'
        Write-Output '3) Verify repo access: gh repo view'
        Write-Output '4) If needed, pass explicit repo: -Owner <owner> -Repo <repo>'
        Write-Output '5) Ensure seed exists: docs/gamification_issues_seed.json'
    }
    exit 1
}
