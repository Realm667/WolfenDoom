$ErrorActionPreference = 'Stop'
$fixture = Join-Path $PSScriptRoot ('work/standalone-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
foreach ($file in 'boa.ipk3','boa-launcher.ini','uzdoom.exe','Blade of Agony - Launcher.exe') {
    [IO.File]::WriteAllText((Join-Path $fixture $file), 'keep this fixture')
}
$ini = Join-Path $fixture 'boa-launcher.ini'
$protected = (Get-FileHash -LiteralPath $ini).Hash
& (Join-Path $PSScriptRoot 'build.ps1') -StandaloneDirectory $fixture | Out-Null
$dist = Join-Path $PSScriptRoot 'dist'
$manifest = Get-Content -Raw -LiteralPath (Join-Path $fixture 'release-manifest.json') | ConvertFrom-Json
foreach ($entry in $manifest.files) {
    if ((Get-FileHash -LiteralPath (Join-Path $fixture $entry.path)).Hash -ne $entry.sha256) { throw $entry.path }
}
$launcher = Join-Path $fixture 'Blade of Agony - Launcher.exe'
$time = [IO.File]::GetLastWriteTimeUtc($launcher)
& (Join-Path $PSScriptRoot 'Sync-Standalone.ps1') -Source $dist -Destination $fixture
if ([IO.File]::GetLastWriteTimeUtc($launcher) -ne $time) { throw 'Unchanged launcher rewritten.' }
$bad = Join-Path $fixture 'invalid-source'
New-Item -ItemType Directory -Path $bad | Out-Null
$manifest.files[0].path = 'boa-launcher.ini'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $bad 'release-manifest.json')
try {
    & (Join-Path $PSScriptRoot 'Sync-Standalone.ps1') -Source $bad -Destination $fixture
    throw 'Unexpected acceptance of invalid manifest.'
} catch { if ($_.Exception.Message -ne 'Unexpected release file list.') { throw } }
foreach ($file in 'boa.ipk3','boa-launcher.ini','uzdoom.exe') {
    if ((Get-FileHash -LiteralPath (Join-Path $fixture $file)).Hash -ne $protected) { throw "Overwritten: $file" }
}
'PASS: integrated standalone deployment, release hashes, idempotence, settings and engine preservation, invalid manifest rejection.'
