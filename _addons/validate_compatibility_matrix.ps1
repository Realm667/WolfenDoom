$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$addonRoot = Join-Path $repo '_addons'
$launcher = Join-Path $repo '_launcher\Blade of Agony - Launcher.exe'

& (Join-Path $addonRoot 'validate_metadata.ps1')
if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
    throw "Launcher executable is missing: $launcher"
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
Copy-Item -LiteralPath (Join-Path $repo 'boa-launcher.json') -Destination $staging -Force

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

# Pipe stdout so PowerShell waits for the GUI executable even in a console.
$matrix = @(& $launcher --base-directory $staging --validate-addon-matrix | Out-String -Stream)
if ($LASTEXITCODE -ne 0) {
    throw "Launcher matrix validation failed with exit code $LASTEXITCODE."
}
$blockedPairs = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase)
$unexpected = [Collections.Generic.List[string]]::new()
$pending = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$ids = @($conflicts.Keys | Sort-Object)
if (!$ids.Count) { throw 'No official add-ons found.' }
for ($i = 0; $i -lt $ids.Count; $i++) {
    [void] $pending.Add($ids[$i])
    for ($j = $i + 1; $j -lt $ids.Count; $j++) {
        [void] $pending.Add("$($ids[$i])|$($ids[$j])")
    }
}
$expectedCount = $pending.Count
foreach ($line in $matrix) {
    if ($line -notmatch '^(PASS|BLOCK)\s+([^:]+)') { continue }
    $result = $matches[1]
    $members = @($matches[2].Trim() -split '\s+\+\s+')
    $key = ($members | Sort-Object) -join '|'
    if (!$pending.Remove($key)) {
        $unexpected.Add("Unknown or duplicate matrix result: $line")
        continue
    }
    if ($result -eq 'PASS') { continue }
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
if ($pending.Count) {
    $unexpected.Add("Missing matrix results: $(@($pending | Sort-Object) -join ', ')")
}
if ($unexpected.Count -gt 0) {
    throw ($unexpected -join [Environment]::NewLine)
}

$passCount = @($matrix | Where-Object { $_ -match '^PASS\s' }).Count
"Validated $($conflicts.Count) add-ons across $expectedCount single/pair combinations: $passCount compatible, $($blockedPairs.Count) declared conflicts."
