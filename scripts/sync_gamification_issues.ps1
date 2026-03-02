[CmdletBinding()]
param(
    [string]$Owner,
    [string]$Repo,
    [string]$SeedPath = 'docs/gamification_issues_seed.json',
    [switch]$Apply,
    [switch]$QuietPreflight
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

function Import-Seed([string]$path) {
    if (-not (Test-Path -Path $path)) {
        throw "Seed file not found: $path"
    }

    return (Get-Content -Raw -Path $path | ConvertFrom-Json)
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

function Get-MilestoneMap {
    param([string]$RepoSlug)

    $milestonesJson = gh api "repos/$RepoSlug/milestones?state=all&per_page=100"
    $milestones = $milestonesJson | ConvertFrom-Json

    $map = @{}
    foreach ($m in $milestones) {
        $map[$m.title] = [int]$m.number
    }

    return $map
}

function Find-IssueByTag {
    param(
        [string]$RepoSlug,
        [string]$IssueTag
    )

    $query = "$IssueTag in:title"
    $result = gh issue list --repo "$RepoSlug" --search "$query" --json number,title --limit 20 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($result)) {
        return $null
    }

    $items = $result | ConvertFrom-Json
    $match = $items | Where-Object { $_.title -like "$IssueTag*" } | Select-Object -First 1
    return $match
}

function Sync-Issue {
    param(
        [string]$RepoSlug,
        $Issue,
        [int]$MilestoneNumber,
        [switch]$Apply
    )

    $existing = Find-IssueByTag -RepoSlug $RepoSlug -IssueTag $Issue.id
    if (-not $existing) {
        Write-Output "SKIP: Issue not found -> $($Issue.id)"
        return
    }

    $payload = @{
        title = "$($Issue.id) $($Issue.title)"
        body = [string]$Issue.body
        labels = @($Issue.labels)
        milestone = $MilestoneNumber
    }

    $json = $payload | ConvertTo-Json -Depth 6

    Invoke-Step -Description "Sync issue #$($existing.number) ($($Issue.id))" -Apply:$Apply -Command {
        $tmp = [System.IO.Path]::GetTempFileName()
        try {
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($tmp, $json, $utf8NoBom)
            gh api "repos/$RepoSlug/issues/$($existing.number)" --method PATCH --header "Content-Type: application/json" --input "$tmp" | Out-Null
        }
        finally {
            if (Test-Path $tmp) {
                Remove-Item -Path $tmp -Force
            }
        }
    }
}

try {
    Assert-Tool 'gh'
    $repoSlug = Resolve-Repo -Owner $Owner -Repo $Repo
    $seed = Import-Seed -path $SeedPath
    $milestoneMap = Get-MilestoneMap -RepoSlug $repoSlug

    Write-Output "Target repo: $repoSlug"
    $modeLabel = 'DRY-RUN'
    if ($Apply) {
        $modeLabel = 'APPLY'
    }
    Write-Output "Mode: $modeLabel"
    Write-Output '--- Issue Sync ---'

    foreach ($issue in $seed.issues) {
        if (-not $milestoneMap.ContainsKey($issue.milestone)) {
            Write-Output "SKIP: Milestone missing for $($issue.id) -> $($issue.milestone)"
            continue
        }

        $milestoneNumber = [int]$milestoneMap[$issue.milestone]
        Sync-Issue -RepoSlug $repoSlug -Issue $issue -MilestoneNumber $milestoneNumber -Apply:$Apply
    }

    Write-Output 'Done.'
    Write-Output 'Tip: run without -Apply to preview, then with -Apply to execute updates.'
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    if (-not $QuietPreflight) {
        Write-Output ''
        Write-Output 'Preflight checklist:'
        Write-Output '1) Install GitHub CLI: https://cli.github.com/'
        Write-Output '2) Authenticate: gh auth login'
        Write-Output '3) Verify repo access: gh repo view'
        Write-Output '4) Ensure milestones exist (run create script first)'
        Write-Output '5) If needed, pass explicit repo: -Owner <owner> -Repo <repo>'
    }
    exit 1
}
