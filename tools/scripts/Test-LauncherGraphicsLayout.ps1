# Run with Windows PowerShell -STA. Tests the distributed WPF executable, not a source rebuild.
[CmdletBinding()]
param([string] $Launcher)
$ErrorActionPreference = 'Stop'
if (-not $Launcher) { $Launcher = Join-Path $PSScriptRoot '..\..\_launcher\Blade of Agony - Launcher.exe' }
if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') { throw 'Run with powershell.exe -STA.' }
Add-Type -AssemblyName PresentationFramework
$assembly = [Reflection.Assembly]::LoadFrom((Resolve-Path -LiteralPath $Launcher).Path)
$fixture = [IO.Directory]::CreateDirectory((Join-Path ([IO.Path]::GetTempPath()) ('boa-layout-' + [guid]::NewGuid().ToString('N'))))
$private = [Reflection.BindingFlags]'Instance,NonPublic'
function Find-Control($node, $id) {
    if ($node -isnot [Windows.DependencyObject]) { return }
    if ([Windows.Automation.AutomationProperties]::GetAutomationId($node) -ceq $id) { return $node }
    foreach ($child in [Windows.LogicalTreeHelper]::GetChildren($node)) {
        $match = Find-Control $child $id
        if ($null -ne $match) { return $match }
    }
}
try {
    $type = $assembly.GetType('BladeOfAgonyLauncher.ModernMainWindow', $true)
    $window = [Activator]::CreateInstance($type, $private, $null, @($fixture.FullName), $null)
    # Build the real settings panel independently of campaign/save discovery.
    $localizer = $type.GetField('text', $private)
    $load = $localizer.FieldType.GetMethod('Load', [Reflection.BindingFlags]'Static,NonPublic,Public')
    $localizer.SetValue($window, $load.Invoke($null, @('en')))
    $panel = $type.GetMethod('BuildGraphicsSection', $private).Invoke($window, $null)
    $preset = Find-Control $panel 'DetailPreset'
    $textures = Find-Control $panel 'DisplacementTextures'
    $description = Find-Control $panel 'DetailPresetDescription'
    $commentary = Find-Control $panel 'DeveloperCommentary'
    if (-not ($preset -and $textures -and $description -and $commentary)) { throw 'Missing shared-settings control.' }
    $graphics = $textures.Parent
    $order = $graphics.Children.IndexOf($textures)
    if ($order -lt 1 -or $graphics.Children.IndexOf($preset.Parent) -ne ($order - 1) -or
        $graphics.Children.IndexOf($description) -ne ($order + 1) -or $graphics -eq $commentary.Parent) {
        throw 'Expected Detail preset, Displacement textures, description in Graphics; commentary in Game settings.'
    }
    $options = $type.GetField('options', $private).GetValue($window)
    $build = $assembly.GetType('BladeOfAgonyLauncher.LauncherCommand', $true).GetMethod('BuildArguments', [Reflection.BindingFlags]'Static,NonPublic')
    foreach ($enabled in @($false, $true)) {
        $textures.IsChecked = $enabled
        $argv = $build.Invoke($null, @($options))
        $index = $argv.IndexOf('boa_dt.pk3')
        if ($enabled -ne ($index -ge 0) -or ($enabled -and ($index -lt 1 -or $argv[$index - 1] -ne '-file'))) {
            throw "Displacement=$enabled produced unexpected launch arguments: $argv"
        }
    }
    Write-Output 'PASS: Graphics layout and single-player displacement arguments (off/on).'
} finally {
    # Only the unique temporary directory created above is owned by this test.
    if ($fixture.Exists) { $fixture.Delete($true) }
}
