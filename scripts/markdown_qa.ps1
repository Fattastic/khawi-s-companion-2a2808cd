param(
    [string]$RootPath = ".",
    [string[]]$TodoMarkers = @("TODO", "FIXME", "TBD", "XXX", "WIP"),
    [string[]]$ExcludeDirs = @("build")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $RootPath)) {
    Write-Error "Root path not found: $RootPath"
    exit 2
}

$todoRegex = "\\b(" + (($TodoMarkers | ForEach-Object { [regex]::Escape($_) }) -join "|") + ")\\b"
$excludeDirRegex = if ($ExcludeDirs.Count -gt 0) {
    '(\\|/)(' + (($ExcludeDirs | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')(\\|/)'
} else {
    $null
}

$mdFiles = Get-ChildItem -Path $RootPath -Recurse -Filter *.md -File |
    Where-Object {
        if (-not $excludeDirRegex) {
            return $true
        }
        return $_.FullName -notmatch $excludeDirRegex
    }

$duplicateHeadings = @()
$headingSkips = @()
$todoHits = @()

foreach ($file in $mdFiles) {
    $lines = Get-Content -Path $file.FullName
    $headings = @()
    $inFence = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -match '^\s*```') {
            $inFence = -not $inFence
            continue
        }

        if ($inFence) {
            continue
        }

        if ($line -match '^(#{1,6})\s+(.+?)\s*$') {
            $level = $Matches[1].Length
            $text = $Matches[2].Trim()
            $headings += [pscustomobject]@{
                Level = $level
                Text  = $text
                Line  = ($i + 1)
            }

            if ($text -match $todoRegex) {
                $todoHits += [pscustomobject]@{
                    File = $file.FullName
                    Line = ($i + 1)
                    Kind = "Heading"
                    Text = $text
                }
            }
        }

        if ($line -match $todoRegex) {
            $todoHits += [pscustomobject]@{
                File = $file.FullName
                Line = ($i + 1)
                Kind = "Line"
                Text = $line.Trim()
            }
        }
    }

    $groups = $headings |
        Group-Object { $_.Text.ToLowerInvariant() } |
        Where-Object { $_.Count -gt 1 }

    foreach ($group in $groups) {
        $duplicateHeadings += [pscustomobject]@{
            File    = $file.FullName
            Heading = $group.Group[0].Text
            Count   = $group.Count
            Lines   = ($group.Group.Line -join ", ")
        }
    }

    for ($j = 1; $j -lt $headings.Count; $j++) {
        $prev = $headings[$j - 1]
        $curr = $headings[$j]
        if (($curr.Level - $prev.Level) -gt 1) {
            $headingSkips += [pscustomobject]@{
                File      = $file.FullName
                PrevLevel = $prev.Level
                PrevText  = $prev.Text
                CurrLevel = $curr.Level
                CurrText  = $curr.Text
                Line      = $curr.Line
            }
        }
    }
}

Write-Output "MD_FILES=$($mdFiles.Count)"
Write-Output "DUPLICATE_HEADINGS=$($duplicateHeadings.Count)"
Write-Output "HEADING_LEVEL_SKIPS=$($headingSkips.Count)"
Write-Output "TODO_LIKE_HITS=$($todoHits.Count)"

if ($duplicateHeadings.Count -gt 0) {
    Write-Output "--- DUPLICATE HEADINGS ---"
    ($duplicateHeadings | Sort-Object File, Heading | Format-Table -AutoSize | Out-String -Width 300).TrimEnd()
}

if ($headingSkips.Count -gt 0) {
    Write-Output "--- HEADING LEVEL SKIPS ---"
    ($headingSkips | Sort-Object File, Line | Format-Table -AutoSize | Out-String -Width 300).TrimEnd()
}

if ($todoHits.Count -gt 0) {
    Write-Output "--- TODO-LIKE HITS ---"
    ($todoHits | Sort-Object File, Line | Format-Table -AutoSize | Out-String -Width 300).TrimEnd()
}

if (($duplicateHeadings.Count + $headingSkips.Count + $todoHits.Count) -gt 0) {
    exit 1
}

exit 0
