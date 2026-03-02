[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification='Script helper blocks are internal and not exported cmdlets.')]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('docs-ci', 'app-backend')]
    [string]$Part,

    [switch]$ShowOnly
)

$ErrorActionPreference = 'Stop'

$docsCiFiles = @(
    '.github/workflows/main.yml',
    '.github/workflows/markdown-qa.yml',
    '.github/PULL_REQUEST_TEMPLATE.md',
    '.vscode/tasks.json',
    'scripts/markdown_qa.ps1',
    'README.md',
    'ENV_SETUP.md',
    'PERFORMANCE_ANALYSIS.md',
    'docs/KHAWI_REFINEMENT_BATCHES.md',
    'docs/feature_inventory.md',
    'docs/branch_protection_setup.md',
    'docs/contributor_workflow.md',
    'docs/PR_DRAFTS.md',
    'docs/PR_SPLIT_FILESETS.md'
)

function Assert-GitRepo {
    $inside = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $inside -ne 'true') {
        throw 'Not inside a git repository.'
    }
}

function Show-List([string[]]$files) {
    Write-Output "FILES=$($files.Count)"
    $files | ForEach-Object { Write-Output $_ }
}

$applyDocsCiStaging = {
    Write-Output 'Resetting index (working tree unchanged)...'
    git reset | Out-Null

    foreach ($path in $docsCiFiles) {
        if (Test-Path -Path $path) {
            git add -- $path
        } else {
            Write-Warning "Missing path: $path"
        }
    }

    Write-Output 'Staged docs/ci files:'
    git diff --cached --name-only
}

$applyAppBackendStaging = {
    Write-Output 'Resetting index (working tree unchanged)...'
    git reset | Out-Null

    Write-Output 'Staging all changes...'
    git add -A

    Write-Output 'Unstaging docs/ci files so only app/backend remains...'
    foreach ($path in $docsCiFiles) {
        if (Test-Path -Path $path) {
            git restore --staged -- $path
        }
    }

    Write-Output 'Staged app/backend files:'
    git diff --cached --name-only
}

Assert-GitRepo

if ($ShowOnly) {
    if ($Part -eq 'docs-ci') {
        Show-List $docsCiFiles
    } else {
        Write-Output 'app-backend mode stages all changed files except the docs-ci list.'
        Write-Output 'Run without -ShowOnly to apply staging.'
        Show-List $docsCiFiles
    }
    exit 0
}

if ($Part -eq 'docs-ci') {
    & $applyDocsCiStaging
} else {
    & $applyAppBackendStaging
}

Write-Output 'Done.'
