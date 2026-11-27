$project = $PSScriptRoot
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$framework = Split-Path $compiler
$wpf = Join-Path $framework 'WPF'
$assemblyText = Get-Content -LiteralPath (Join-Path $project 'AssemblyInfo.cs') -Raw
$versionMatch = [regex]::Match($assemblyText, 'const string Number = "([0-9]+\.[0-9]+\.[0-9]+)"')
if (-not $versionMatch.Success) { throw 'LauncherVersion.Number is missing from AssemblyInfo.cs.' }
$launcherVersion = $versionMatch.Groups[1].Value
$sourceNames = @(
    'WpfProgram.cs', 'ModernMainWindow.cs', 'ModernQuickLaunch.cs', 'ModernMultiplayer.cs', 'ModernLocalization.cs', 'ReleaseLocalization.cs', 'CampaignPage.cs', 'AddonsPage.cs', 'MultiplayerPage.cs', 'DiagnosticsPage.cs', 'LauncherControls.cs',
    'LauncherCore.cs', 'LauncherInfrastructure.cs', 'RuntimeServices.cs',
    'SavegameService.cs', 'EngineCapabilities.cs',
    'MultiplayerSession.cs', 'MultiplayerSettings.cs', 'CoopSaveService.cs', 'DiagnosticsPackage.cs', 'GamepadNavigation.cs',
    'BoaContentCatalog.cs', 'AddonDescriptor.cs', 'AddonCompatibility.cs',
    'IniFile.cs', 'AssemblyInfo.cs'
)
$sources = $sourceNames | ForEach-Object { Join-Path $project $_ }
$references = @('System.dll', 'System.Core.dll', 'System.Drawing.dll',
    'System.IO.Compression.dll', 'System.IO.Compression.FileSystem.dll',
    'System.Web.Extensions.dll', 'System.Runtime.Serialization.dll', (Join-Path $framework 'System.Xaml.dll'),
    (Join-Path $wpf 'WindowsBase.dll'), (Join-Path $wpf 'PresentationCore.dll'),
    (Join-Path $wpf 'PresentationFramework.dll')) | ForEach-Object { '/reference:' + $_ }
$releasePaths = @(
    '.gitattributes',
    'Blade of Agony - Launcher.exe',
    'boa-launcher.json', 'README.md', 'CHANGELOG.md', "VALIDATION-v$launcherVersion.md", 'licenses/UnicaOne-OFL.txt',
    'launcher-resource/detail-default.cfg', 'launcher-resource/detail-high.cfg',
    'launcher-resource/detail-low.cfg', 'launcher-resource/detail-normal.cfg',
    'launcher-resource/detail-veryhigh.cfg', 'launcher-resource/detail-verylow.cfg',
    'launcher-resource/texfilt-nnx.cfg', 'launcher-resource/texfilt-none.cfg',
    'launcher-resource/texfilt-tri.cfg'
)
