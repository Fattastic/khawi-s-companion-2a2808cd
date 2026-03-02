[CmdletBinding()]
param(
    [string]$Owner,
    [string]$Repo,
    [string]$SeedPath = 'docs/gamification_issues_seed.json',
    [switch]$Apply,
    [switch]$SkipMilestones,
    [switch]$SkipLabels,
    [switch]$SkipIssues,
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

function Set-Milestone {
    param(
        [string]$RepoSlug,
        [string]$Milestone,
        [switch]$Apply
    )

    $existing = $null
    $milestonesJson = gh api "repos/$RepoSlug/milestones?state=all&per_page=100" 2>$null
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($milestonesJson)) {
        $milestones = $milestonesJson | ConvertFrom-Json
        $existing = @($milestones | Where-Object { $_.title -eq $Milestone } | Select-Object -First 1)
    }

    if ($existing -and $existing.Count -gt 0) {
        Write-Output "OK: Milestone exists -> $Milestone"
        return
    }

    Invoke-Step -Description "Create milestone '$Milestone'" -Apply:$Apply -Command {
        gh api "repos/$RepoSlug/milestones" --method POST --field title="$Milestone" | Out-Null
    }
}

function Set-Label {
    param(
        [string]$LabelName,
        [string]$Color,
        [string]$Description,
        [switch]$Apply
    )

    Invoke-Step -Description "Create/update label '$LabelName'" -Apply:$Apply -Command {
        gh label create "$LabelName" --color "$Color" --description "$Description" --force | Out-Null
    }
}

function Test-IssueExists {
    param(
        [string]$RepoSlug,
        [string]$IssueTag
    )

    $query = "$IssueTag in:title"
    $result = gh issue list --repo "$RepoSlug" --search "$query" --json number,title --limit 20 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($result)) {
        return $false
    }

    $items = $result | ConvertFrom-Json
    return @($items | Where-Object { $_.title -like "$IssueTag*" }).Count -gt 0
}

function New-Issue {
    param(
        [string]$RepoSlug,
        $Issue,
        [switch]$Apply
    )

    $prefixedTitle = "$($Issue.id) $($Issue.title)"
    if (Test-IssueExists -RepoSlug $RepoSlug -IssueTag $Issue.id) {
        Write-Output "SKIP: Issue exists -> $($Issue.id)"
        return
    }

    $labelsCsv = ($Issue.labels -join ',')
    $body = $Issue.body

    Invoke-Step -Description "Create issue '$prefixedTitle'" -Apply:$Apply -Command {
        gh issue create `
            --repo "$RepoSlug" `
            --title "$prefixedTitle" `
            --body "$body" `
            --label "$labelsCsv" `
            --milestone "$($Issue.milestone)" | Out-Null
    }
}

try {
    Assert-Tool 'gh'
    $repoSlug = Resolve-Repo -Owner $Owner -Repo $Repo
    $seed = Import-Seed -path $SeedPath

    Write-Output "Target repo: $repoSlug"
    $modeLabel = 'DRY-RUN'
    if ($Apply) {
        $modeLabel = 'APPLY'
    }
    Write-Output "Mode: $modeLabel"

    if (-not $SkipMilestones) {
        Write-Output '--- Milestones ---'
        foreach ($m in $seed.milestones) {
            Set-Milestone -RepoSlug $repoSlug -Milestone $m -Apply:$Apply
        }
    }

    if (-not $SkipLabels) {
        Write-Output '--- Labels ---'
        foreach ($label in $seed.labels) {
            Set-Label -LabelName $label.name -Color $label.color -Description $label.description -Apply:$Apply
        }
    }

    if (-not $SkipIssues) {
        Write-Output '--- Issues ---'
        foreach ($issue in $seed.issues) {
            New-Issue -RepoSlug $repoSlug -Issue $issue -Apply:$Apply
        }
    }

    Write-Output 'Done.'
    Write-Output 'Tip: run once without -Apply to preview, then rerun with -Apply to execute.'
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
    }
    exit 1
}
