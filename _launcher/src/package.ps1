param([switch] $SkipBuild)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'BuildDefinition.ps1')
if (-not $SkipBuild) { & (Join-Path $project 'build.ps1') | Out-Null }
$dist = Join-Path $project 'dist'
$package = Join-Path $project "package-v$launcherVersion"
$archive = Join-Path $project "Blade-of-Agony-Launcher-v$launcherVersion.zip"
if ((Test-Path -LiteralPath $package) -or (Test-Path -LiteralPath $archive)) {
    throw 'This release package already exists; verify it before creating a replacement.'
}
$manifest = Get-Content -LiteralPath (Join-Path $dist 'release-manifest.json') -Raw | ConvertFrom-Json
if ($manifest.launcherVersion -ne $launcherVersion) { throw 'Release manifest version mismatch.' }
New-Item -ItemType Directory -Path $package | Out-Null
foreach ($relative in ($releasePaths + 'release-manifest.json')) {
    $source = Join-Path $dist $relative
    $target = Join-Path $package $relative
    New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $target
}
foreach ($entry in $manifest.files) {
    $file = Get-Item -LiteralPath (Join-Path $package $entry.path)
    if ($file.Length -ne $entry.size -or (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash -ne $entry.sha256) {
        throw "Release integrity mismatch: $($entry.path)"
    }
}
Compress-Archive -Path (Join-Path $package '*') -DestinationPath $archive -CompressionLevel Optimal
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    $files = @($zip.Entries | Where-Object { $_.Name })
    if ($files.Count -ne $releasePaths.Count + 1) { throw 'Unexpected ZIP file count.' }
    foreach ($entry in $manifest.files) {
        $member = $files | Where-Object { $_.FullName.Replace('\', '/') -eq $entry.path }
        if (@($member).Count -ne 1 -or $member.Length -ne $entry.size) { throw "ZIP member mismatch: $($entry.path)" }
        $stream = $member.Open()
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $hash = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-', '') }
        finally { $stream.Dispose(); $sha.Dispose() }
        if ($hash -ne $entry.sha256) { throw "ZIP checksum mismatch: $($entry.path)" }
    }
} finally { $zip.Dispose() }
Get-Item -LiteralPath $archive | Select-Object FullName,Length
Get-FileHash -LiteralPath $archive -Algorithm SHA256
