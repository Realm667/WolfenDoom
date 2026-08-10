$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$addonRoot = Join-Path $repo '_addons'
$diagnostics = Join-Path $repo '_launcher\Blade of Agony - Launcher Diagnostics.exe'

& (Join-Path $addonRoot 'validate_metadata.ps1')
if (-not (Test-Path -LiteralPath $diagnostics)) {
    throw "Launcher diagnostics executable is missing: $diagnostics"
}

Push-Location $addonRoot
try {
    & '.\add-on_builder.cmd'
    if ($LASTEXITCODE -ne 0) {
        throw "Official add-on build failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

$staging = Join-Path $addonRoot 'release'
Copy-Item -LiteralPath (Join-Path $repo 'wolf_boa.txt') `
    -Destination (Join-Path $staging 'wolf_boa.txt') -Force

$conflicts = @{}
foreach ($directory in Get-ChildItem -LiteralPath (Join-Path $addonRoot 'source') -Directory) {
    $values = @{}
    foreach ($line in Get-Content -LiteralPath (Join-Path $directory.FullName 'addoninfo.txt')) {
        if ($line -match '^\s*([^#=/][^=]*)\s*=\s*(.*?)\s*$') {
            $values[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    $id = $values.id
    $conflicts[$id] = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase)
    foreach ($target in ($values.conflicts -split '[,;]')) {
        if (-not [string]::IsNullOrWhiteSpace($target)) {
            [void] $conflicts[$id].Add($target.Trim())
        }
    }
}

$matrix = @(& $diagnostics --base-directory $staging --validate-addon-matrix)
if ($LASTEXITCODE -ne 0) {
    throw "Launcher matrix validation failed with exit code $LASTEXITCODE."
}
$blockedPairs = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase)
$unexpected = [Collections.Generic.List[string]]::new()
foreach ($line in $matrix) {
    if ($line -notmatch '^BLOCK\s+([^:]+)') { continue }
    $members = @($matches[1] -split '\s+\+\s+')
    if ($members.Count -ne 2) {
        $unexpected.Add("An official add-on fails by itself: $line")
        continue
    }
    $left = $members[0].Trim()
    $right = $members[1].Trim()
    $declared =
        ($conflicts.ContainsKey($left) -and $conflicts[$left].Contains($right)) -or
        ($conflicts.ContainsKey($right) -and $conflicts[$right].Contains($left))
    if (-not $declared) {
        $unexpected.Add("Undeclared pairwise conflict: $line")
        continue
    }
    [void] $blockedPairs.Add((@($left, $right) | Sort-Object) -join '|')
}

foreach ($left in $conflicts.Keys) {
    foreach ($right in $conflicts[$left]) {
        $key = (@($left, $right) | Sort-Object) -join '|'
        if (-not $blockedPairs.Contains($key)) {
            $unexpected.Add("Declared conflict was not blocked: $left + $right")
        }
    }
}
if ($unexpected.Count -gt 0) {
    throw ($unexpected -join [Environment]::NewLine)
}

$passCount = @($matrix | Where-Object { $_ -match '^PASS\s' }).Count
"Validated $($conflicts.Count) add-ons across $($matrix.Count) single/pair combinations: $passCount compatible, $($blockedPairs.Count) declared conflicts."
