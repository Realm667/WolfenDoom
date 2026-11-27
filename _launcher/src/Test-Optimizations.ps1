param([switch] $SkipBuild)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'BuildDefinition.ps1')
if (-not $SkipBuild) { & (Join-Path $project 'build.ps1') | Out-Null }
$fixture = Join-Path $project ('work\optimization-tests-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$sources += Join-Path $project 'OptimizationTests.cs'
$testExe = Join-Path $fixture 'OptimizationTests.exe'
$assets = @(
    ('/resource:' + (Join-Path $project 'assets\boa-logo.png') + ',BladeLauncher.boa-logo.png'),
    ('/resource:' + (Join-Path $project 'assets\fonts\UnicaOne\UnicaOne-Regular.ttf') + ',BladeLauncher.UnicaOne-Regular.ttf'),
    ('/resource:' + (Join-Path $project 'assets\main.ico') + ',BladeLauncher.main.ico')
)
& $compiler /nologo /codepage:65001 /debug:pdbonly /target:exe /main:BladeOfAgonyLauncher.OptimizationTests "/out:$testExe" @assets @references @sources
if ($LASTEXITCODE -ne 0) { throw 'Optimization tests failed to compile.' }
& $testExe $fixture
if ($LASTEXITCODE -ne 0) { throw 'Optimization regression tests failed.' }
