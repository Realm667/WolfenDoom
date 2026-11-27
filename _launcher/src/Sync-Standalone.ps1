param(
    [Parameter(Mandatory)][string] $Source,
    [Parameter(Mandatory)][string] $Destination
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'BuildDefinition.ps1')
$Source = (Resolve-Path -LiteralPath $Source).ProviderPath
$Destination = (Resolve-Path -LiteralPath $Destination).ProviderPath
if (!(Test-Path -LiteralPath (Join-Path $Destination 'boa.ipk3') -PathType Leaf)) {
    throw "Not a standalone game directory: $Destination"
}
$manifestFile = 'release-manifest.json'
$manifest = Get-Content -LiteralPath (Join-Path $Source $manifestFile) -Raw | ConvertFrom-Json
if ($manifest.launcherVersion -ne $launcherVersion -or $manifest.formatVersion -ne 1) { throw 'Unexpected launcher manifest version.' }
$entries = @($manifest.files)
if ($entries.Count -ne $releasePaths.Count -or (Compare-Object $releasePaths @($entries.path))) { throw 'Unexpected release file list.' }

# Validate every input before touching the destination. Never deploy settings, even
# if an INI is accidentally added to a future release definition and its manifest.
foreach ($entry in $entries) {
    if ($entry.path -match '(?i)\.ini$|(^|[/\\])\.\.([/\\]|$)|[:\\]' -or [IO.Path]::IsPathRooted($entry.path)) { throw "Protected or invalid path: $($entry.path)" }
    $file = Get-Item -LiteralPath (Join-Path $Source $entry.path)
    if ($file.Length -ne $entry.size -or (Get-FileHash -LiteralPath $file.FullName).Hash -ne $entry.sha256) { throw "Invalid release file: $($entry.path)" }
}
$entries += [pscustomobject]@{ path=$manifestFile; sha256=(Get-FileHash -LiteralPath (Join-Path $Source $manifestFile)).Hash }
$changed = 0
foreach ($entry in $entries) {
    $target = Join-Path $Destination $entry.path
    if ((Test-Path -LiteralPath $target -PathType Leaf) -and (Get-FileHash -LiteralPath $target).Hash -eq $entry.sha256) { continue }
    $parent = Split-Path -Parent $target
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    $temp = Join-Path $parent ([IO.Path]::GetRandomFileName())
    try {
        [IO.File]::Copy((Join-Path $Source $entry.path), $temp)
        if ((Get-FileHash -LiteralPath $temp).Hash -ne $entry.sha256) { throw "Copy mismatch: $target" }
        if ([IO.File]::Exists($target)) {
            # Use the four-argument overload with a null backup path.
            [IO.File]::Replace($temp, $target, [System.Management.Automation.Language.NullString]::Value, $true)
        } else { [IO.File]::Move($temp, $target) }
        $changed++
    } finally {
        if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) }
    }
}
Write-Host "Standalone launcher $launcherVersion verified ($changed files updated): $Destination"
