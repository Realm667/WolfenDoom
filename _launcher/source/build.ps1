$ErrorActionPreference = 'Stop'

$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$output = Join-Path $project 'dist'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'

if (-not (Test-Path -LiteralPath $compiler)) {
    throw "The .NET Framework C# compiler was not found at $compiler"
}

New-Item -ItemType Directory -Force -Path $output | Out-Null

$sources = Get-ChildItem -LiteralPath $project -Filter '*.cs' -File |
    ForEach-Object { $_.FullName }

$references = @(
    '/reference:System.dll',
    '/reference:System.Core.dll',
    '/reference:System.Drawing.dll',
    '/reference:System.Windows.Forms.dll',
    '/reference:System.IO.Compression.dll',
    '/reference:System.IO.Compression.FileSystem.dll'
)

$common = @(
    '/nologo',
    '/optimize+',
    '/debug:pdbonly',
    '/platform:anycpu',
    ('/win32icon:' + (Join-Path $project 'assets\main.ico')),
    ('/resource:' + (Join-Path $project 'assets\launcher.jpg') + ',BladeLauncher.launcher.jpg')
) + $references

& $compiler @common `
    '/target:winexe' `
    ('/out:' + (Join-Path $output 'Blade of Agony - Launcher Rebuilt.exe')) `
    @sources
if ($LASTEXITCODE -ne 0) {
    throw "GUI build failed with exit code $LASTEXITCODE"
}

& $compiler @common `
    '/target:exe' `
    ('/out:' + (Join-Path $output 'Blade of Agony - Launcher Diagnostics.exe')) `
    @sources
if ($LASTEXITCODE -ne 0) {
    throw "Diagnostics build failed with exit code $LASTEXITCODE"
}

Get-ChildItem -LiteralPath $output -File |
    Select-Object Name, Length, LastWriteTime
