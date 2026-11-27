param(
    [string] $SigningCertificateThumbprint = ''
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'BuildDefinition.ps1')
$distributionOutput = Join-Path $project 'dist'
$output = Join-Path $project ('work\build-' + [Guid]::NewGuid().ToString('N'))
$readmeText = Get-Content -LiteralPath (Join-Path $project 'README.md') -Raw
$changelogText = Get-Content -LiteralPath (Join-Path $project 'CHANGELOG.md') -Raw
if ($readmeText -notmatch ('Version ' + [regex]::Escape($launcherVersion)) -or
    $changelogText -notmatch ('(?m)^## ' + [regex]::Escape($launcherVersion) + '\r?$')) {
    throw "README.md, CHANGELOG.md, and AssemblyInfo.cs do not agree on $launcherVersion."
}

if (-not (Test-Path -LiteralPath $compiler)) {
    throw "The .NET Framework C# compiler was not found at $compiler"
}

New-Item -ItemType Directory -Force -Path $output | Out-Null

$common = @(
    '/nologo',
    '/optimize+',
    '/codepage:65001',
    '/debug:pdbonly',
    '/platform:anycpu',
    '/main:BladeOfAgonyLauncher.WpfProgram',
    ('/win32icon:' + (Join-Path $project 'assets\main.ico')),
    ('/win32manifest:' + (Join-Path $project 'app.manifest')),
    ('/resource:' + (Join-Path $project 'assets\launcher.jpg') + ',BladeLauncher.launcher.jpg'),
    ('/resource:' + (Join-Path $project 'assets\boa-logo.png') + ',BladeLauncher.boa-logo.png'),
    ('/resource:' + (Join-Path $project 'assets\fonts\UnicaOne\UnicaOne-Regular.ttf') + ',BladeLauncher.UnicaOne-Regular.ttf'),
    ('/resource:' + (Join-Path $project 'assets\fonts\UnicaOne\OFL.txt') + ',BladeLauncher.UnicaOne-OFL.txt'),
    ('/resource:' + (Join-Path $project 'assets\main.ico') + ',BladeLauncher.main.ico')
) + $references

& $compiler @common `
    '/target:winexe' `
    ('/out:' + (Join-Path $output 'Blade of Agony - Launcher.exe')) `
    @sources
if ($LASTEXITCODE -ne 0) {
    throw "GUI build failed with exit code $LASTEXITCODE"
}

$resourceSource = Join-Path $project 'distribution\launcher-resource'
$resourceTarget = Join-Path $output 'launcher-resource'
if (Test-Path -LiteralPath $resourceSource) {
    New-Item -ItemType Directory -Force -Path $resourceTarget | Out-Null
    Copy-Item -Path (Join-Path $resourceSource '*') `
        -Destination $resourceTarget -Force
}

$licenseTarget = Join-Path $output 'licenses'
New-Item -ItemType Directory -Force -Path $licenseTarget | Out-Null
Copy-Item -LiteralPath (Join-Path $project 'assets\fonts\UnicaOne\OFL.txt') `
    -Destination (Join-Path $licenseTarget 'UnicaOne-OFL.txt') -Force

foreach ($document in @('README.md', 'CHANGELOG.md', "VALIDATION-v$launcherVersion.md")) {
    Copy-Item -LiteralPath (Join-Path $project $document) `
        -Destination (Join-Path $output $document) -Force
}
$boaManifest = Join-Path $project 'distribution\boa-launcher.json'
Copy-Item -LiteralPath (Join-Path $project 'distribution\.gitattributes') -Destination (Join-Path $output '.gitattributes')
if (Test-Path -LiteralPath $boaManifest) {
    Copy-Item -LiteralPath $boaManifest `
        -Destination (Join-Path $output 'boa-launcher.json') -Force
}

if (-not [string]::IsNullOrWhiteSpace($SigningCertificateThumbprint)) {
    $certificate = Get-ChildItem Cert:\CurrentUser\My |
        Where-Object { $_.Thumbprint -eq $SigningCertificateThumbprint } |
        Select-Object -First 1
    if (-not $certificate) {
        throw "Signing certificate $SigningCertificateThumbprint was not found."
    }
    foreach ($executable in @(
        'Blade of Agony - Launcher.exe'
    )) {
        $signature = Set-AuthenticodeSignature `
            -FilePath (Join-Path $output $executable) `
            -Certificate $certificate `
            -HashAlgorithm SHA256
        if ($signature.Status -ne 'Valid') {
            throw "Authenticode signing failed for ${executable}: $($signature.StatusMessage)"
        }
    }
}

$utf8 = [Text.UTF8Encoding]::new($false)
foreach ($relative in $releasePaths) {
    if ([IO.Path]::GetExtension($relative) -in @('.md', '.json', '.cfg', '.txt') -or $relative -eq '.gitattributes') {
        $path = Join-Path $output $relative
        $content = [IO.File]::ReadAllText($path).Replace("`r`n", "`n")
        [IO.File]::WriteAllText($path, $content, $utf8)
    }
}
$releaseFiles = $releasePaths | Sort-Object | ForEach-Object {
    Get-Item -LiteralPath (Join-Path $output $_)
}
$manifestFiles = foreach ($file in $releaseFiles) {
    [ordered]@{
        path = $file.FullName.Substring($output.Length + 1).Replace('\', '/')
        size = $file.Length
        sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}
$releaseManifest = [ordered]@{
    formatVersion = 1
    launcherVersion = $launcherVersion
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    signed = -not [string]::IsNullOrWhiteSpace($SigningCertificateThumbprint)
    files = @($manifestFiles)
}
[IO.File]::WriteAllText(
    (Join-Path $output 'release-manifest.json'),
    ($releaseManifest | ConvertTo-Json -Depth 5).Replace("`r`n", "`n"),
    [Text.UTF8Encoding]::new($false))

New-Item -ItemType Directory -Force -Path $distributionOutput | Out-Null
Get-ChildItem -LiteralPath $output | Copy-Item -Destination $distributionOutput -Recurse -Force
foreach ($obsolete in @('Blade of Agony - Launcher Diagnostics.exe', 'Blade of Agony - Launcher Diagnostics.pdb')) {
    $obsoletePath = Join-Path $distributionOutput $obsolete
    if (Test-Path -LiteralPath $obsoletePath) {
        Remove-Item -LiteralPath $obsoletePath -Force
    }
}
$resolvedOutput = [IO.Path]::GetFullPath($output)
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $project 'work')) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($expectedRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Build staging directory is outside the workspace.'
}
Remove-Item -LiteralPath $resolvedOutput -Recurse -Force
Get-ChildItem -LiteralPath $distributionOutput -File |
    Select-Object Name, Length, LastWriteTime
