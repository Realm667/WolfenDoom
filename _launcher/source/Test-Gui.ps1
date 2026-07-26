param(
    [switch] $Multi,
    [switch] $NoAddons,
    [switch] $SkipScreenshot
)

$ErrorActionPreference = 'Stop'

$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Split-Path -Parent $project
$sandbox = Join-Path $workspace 'work\launcher-probe\sandbox'
$launcher = Join-Path $project 'dist\Blade of Agony - Launcher Rebuilt.exe'
$capture = Join-Path $sandbox 'captured-launches.txt'
$screenshot = Join-Path $project 'dist\launcher-gui-test.png'

if (Test-Path -LiteralPath $capture) {
    Remove-Item -LiteralPath $capture
}

Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class RebuiltGuiTestNative
{
    public delegate bool EnumProc(IntPtr handle, IntPtr state);

    [StructLayout(LayoutKind.Sequential)]
    public struct Rect
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumProc callback, IntPtr state);

    [DllImport("user32.dll")]
    public static extern bool EnumChildWindows(IntPtr parent, EnumProc callback, IntPtr state);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr handle, out uint processId);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetWindowText(IntPtr handle, StringBuilder text, int count);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetClassName(IntPtr handle, StringBuilder text, int count);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr handle, out Rect rect);

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr handle, uint message, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool PrintWindow(IntPtr handle, IntPtr deviceContext, uint flags);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr handle);

    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr handle, uint message, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern int GetDlgCtrlID(IntPtr handle);
}
'@

function Read-Text([IntPtr] $Handle) {
    $buffer = [Text.StringBuilder]::new(512)
    [void] [RebuiltGuiTestNative]::GetWindowText($Handle, $buffer, $buffer.Capacity)
    return $buffer.ToString()
}

function Capture-Window([IntPtr] $Handle) {
    $rect = [RebuiltGuiTestNative+Rect]::new()
    [void] [RebuiltGuiTestNative]::GetWindowRect($Handle, [ref] $rect)
    $bitmap = [Drawing.Bitmap]::new($rect.Right - $rect.Left, $rect.Bottom - $rect.Top)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $deviceContext = $graphics.GetHdc()
        try {
            [void] [RebuiltGuiTestNative]::PrintWindow($Handle, $deviceContext, 2)
        }
        finally {
            $graphics.ReleaseHdc($deviceContext)
        }
    }
    finally {
        $graphics.Dispose()
    }
    return $bitmap
}

$startInfo = [Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $launcher
$startInfo.Arguments = '--base-directory "' + $sandbox + '"'
$startInfo.WorkingDirectory = $sandbox
$startInfo.UseShellExecute = $true
$process = [Diagnostics.Process]::Start($startInfo)

try {
    $window = $null
    for ($attempt = 0; $attempt -lt 40 -and -not $window; $attempt++) {
        Start-Sleep -Milliseconds 250
        $callback = [RebuiltGuiTestNative+EnumProc] {
            param($handle, $state)
            [uint32] $owner = 0
            [void] [RebuiltGuiTestNative]::GetWindowThreadProcessId($handle, [ref] $owner)
            if ($owner -eq $process.Id -and (Read-Text $handle) -eq 'Blade of Agony') {
                $script:window = $handle
            }
            return $true
        }
        [void] [RebuiltGuiTestNative]::EnumWindows($callback, [IntPtr]::Zero)
    }
    if (-not $window) {
        throw 'The rebuilt launcher window did not appear.'
    }

    $previewViewport = $null
    $findPreview = [RebuiltGuiTestNative+EnumProc] {
        param($handle, $state)
        if ((Read-Text $handle) -eq 'AddonPreviewViewport') {
            $script:previewViewport = $handle
        }
        return $true
    }
    [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $findPreview, [IntPtr]::Zero)
    if (-not $previewViewport) {
        throw 'The addon preview viewport was not found.'
    }
    $previewRect = [RebuiltGuiTestNative+Rect]::new()
    [void] [RebuiltGuiTestNative]::GetWindowRect($previewViewport, [ref] $previewRect)
    $previewWidth = $previewRect.Right - $previewRect.Left
    $previewHeight = $previewRect.Bottom - $previewRect.Top
    if ($previewWidth -lt 1 -or $previewHeight -lt 1 -or
        [Math]::Abs(($previewWidth / [double] $previewHeight) - (16 / 9)) -gt 0.02) {
        throw "The live preview viewport is not 16:9: ${previewWidth}x${previewHeight}"
    }

    $languageCombo = $null
    $findLanguageCombo = [RebuiltGuiTestNative+EnumProc] {
        param($handle, $state)
        $class = [Text.StringBuilder]::new(128)
        [void] [RebuiltGuiTestNative]::GetClassName($handle, $class, $class.Capacity)
        if ($class.ToString().Contains('COMBOBOX') -and
            [RebuiltGuiTestNative]::SendMessage($handle, 0x0146, [IntPtr]::Zero, [IntPtr]::Zero).ToInt32() -eq 10) {
            $script:languageCombo = $handle
        }
        return $true
    }
    [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $findLanguageCombo, [IntPtr]::Zero)
    if (-not $languageCombo) {
        throw 'The game-language selector was not found.'
    }
    [void] [RebuiltGuiTestNative]::SendMessage($languageCombo, 0x014E, [IntPtr] 1, [IntPtr]::Zero)
    $languageControlId = [RebuiltGuiTestNative]::GetDlgCtrlID($languageCombo)
    $languageChanged = [IntPtr] (($languageControlId -band 0xffff) -bor (1 -shl 16))
    [void] [RebuiltGuiTestNative]::SendMessage($window, 0x0111, $languageChanged, $languageCombo)
    Start-Sleep -Milliseconds 500

    $germanPlay = $null
    $findGermanPlay = [RebuiltGuiTestNative+EnumProc] {
        param($handle, $state)
        if ((Read-Text $handle) -eq 'Spielen') {
            $script:germanPlay = $handle
        }
        return $true
    }
    [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $findGermanPlay, [IntPtr]::Zero)
    if (-not $germanPlay) {
        throw 'Changing the game language did not localize the launcher to German.'
    }

    $themeCandidates = [Collections.Generic.List[object]]::new()
    $findThemeCombo = [RebuiltGuiTestNative+EnumProc] {
        param($handle, $state)
        $class = [Text.StringBuilder]::new(128)
        [void] [RebuiltGuiTestNative]::GetClassName($handle, $class, $class.Capacity)
        if ($class.ToString().Contains('COMBOBOX') -and
            [RebuiltGuiTestNative]::SendMessage($handle, 0x0146, [IntPtr]::Zero, [IntPtr]::Zero).ToInt32() -eq 3) {
            $comboRect = [RebuiltGuiTestNative+Rect]::new()
            [void] [RebuiltGuiTestNative]::GetWindowRect($handle, [ref] $comboRect)
            $script:themeCandidates.Add([pscustomobject] @{
                Handle = $handle
                Top = $comboRect.Top
            })
        }
        return $true
    }
    [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $findThemeCombo, [IntPtr]::Zero)
    $themeCombo = ($themeCandidates | Sort-Object Top | Select-Object -First 1).Handle
    if (-not $themeCombo) {
        throw 'The design selector was not found.'
    }
    $themeControlId = [RebuiltGuiTestNative]::GetDlgCtrlID($themeCombo)
    $themeChanged = [IntPtr] (($themeControlId -band 0xffff) -bor (1 -shl 16))
    foreach ($themeCase in @(
        [pscustomobject] @{ Index = 0; Color = '3B3B3B'; Name = 'Dark' },
        [pscustomobject] @{ Index = 1; Color = 'F0F0F0'; Name = 'Light' },
        [pscustomobject] @{ Index = 2; Color = '11273A'; Name = 'Blade of Agony' }
    )) {
        [void] [RebuiltGuiTestNative]::SendMessage(
            $themeCombo, 0x014E, [IntPtr] $themeCase.Index, [IntPtr]::Zero)
        [void] [RebuiltGuiTestNative]::SendMessage(
            $window, 0x0111, $themeChanged, $themeCombo)
        Start-Sleep -Milliseconds 250
        $themeBitmap = Capture-Window $window
        try {
            $pixel = $themeBitmap.GetPixel(20, 200)
            $actualColor = '{0:X2}{1:X2}{2:X2}' -f $pixel.R, $pixel.G, $pixel.B
            if ($actualColor -ne $themeCase.Color) {
                throw "$($themeCase.Name) background mismatch: #$actualColor"
            }
            if ($themeCase.Index -eq 2) {
                $accentPixel = $themeBitmap.GetPixel(760, 680)
                $accentColor = '{0:X2}{1:X2}{2:X2}' -f `
                    $accentPixel.R, $accentPixel.G, $accentPixel.B
                if ($accentColor -ne '668197') {
                    throw "Blade of Agony accent mismatch: #$accentColor"
                }
            }
        }
        finally {
            $themeBitmap.Dispose()
        }
    }

    if (-not $SkipScreenshot) {
        $rect = [RebuiltGuiTestNative+Rect]::new()
        [void] [RebuiltGuiTestNative]::GetWindowRect($window, [ref] $rect)
        [void] [RebuiltGuiTestNative]::SetForegroundWindow($window)
        Start-Sleep -Milliseconds 400
        $bitmap = [Drawing.Bitmap]::new($rect.Right - $rect.Left, $rect.Bottom - $rect.Top)
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try {
            try {
                $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
            }
            catch {
                $deviceContext = $graphics.GetHdc()
                try {
                    [void] [RebuiltGuiTestNative]::PrintWindow($window, $deviceContext, 2)
                }
                finally {
                    $graphics.ReleaseHdc($deviceContext)
                }
            }
        }
        finally {
            $graphics.Dispose()
        }
        $bitmap.Save($screenshot, [Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
    }

    if ($Multi -or $NoAddons) {
        $addonList = $null
        $findAddonList = [RebuiltGuiTestNative+EnumProc] {
            param($handle, $state)
            $class = [Text.StringBuilder]::new(128)
            [void] [RebuiltGuiTestNative]::GetClassName($handle, $class, $class.Capacity)
            if ($class.ToString().Contains('LISTBOX')) {
                $script:addonList = $handle
            }
            return $true
        }
        [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $findAddonList, [IntPtr]::Zero)
        if (-not $addonList) {
            throw 'The addon list was not found.'
        }

        [void] [RebuiltGuiTestNative]::SendMessage($addonList, 0x0185, [IntPtr]::Zero, [IntPtr] -1)
        if ($Multi) {
            [void] [RebuiltGuiTestNative]::SendMessage($addonList, 0x0185, [IntPtr] 1, [IntPtr] 1)
            [void] [RebuiltGuiTestNative]::SendMessage($addonList, 0x0185, [IntPtr] 1, [IntPtr] 2)
        } else {
            [void] [RebuiltGuiTestNative]::SendMessage($addonList, 0x0185, [IntPtr] 1, [IntPtr] 0)
        }
        $controlId = [RebuiltGuiTestNative]::GetDlgCtrlID($addonList)
        $selectionChanged = [IntPtr] (($controlId -band 0xffff) -bor (1 -shl 16))
        [void] [RebuiltGuiTestNative]::SendMessage($window, 0x0111, $selectionChanged, $addonList)
        Start-Sleep -Milliseconds 500
    }

    $playCandidates = [Collections.Generic.List[object]]::new()
    $childCallback = [RebuiltGuiTestNative+EnumProc] {
        param($handle, $state)
        $class = [Text.StringBuilder]::new(128)
        [void] [RebuiltGuiTestNative]::GetClassName($handle, $class, $class.Capacity)
        if ($class.ToString().Contains('BUTTON')) {
            $buttonRect = [RebuiltGuiTestNative+Rect]::new()
            [void] [RebuiltGuiTestNative]::GetWindowRect($handle, [ref] $buttonRect)
            $script:playCandidates.Add([pscustomobject] @{
                Handle = $handle
                Left = $buttonRect.Left
                Top = $buttonRect.Top
            })
        }
        return $true
    }
    [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $childCallback, [IntPtr]::Zero)
    $bottomTop = ($playCandidates | Measure-Object -Property Top -Maximum).Maximum
    $play = ($playCandidates |
        Where-Object { $_.Top -ge ($bottomTop - 10) } |
        Sort-Object Left |
        Select-Object -First 1).Handle
    if (-not $play) {
        throw 'The Play button was not found.'
    }
    [void] [RebuiltGuiTestNative]::SendMessage($play, 0x00F5, [IntPtr]::Zero, [IntPtr]::Zero)

    for ($attempt = 0; $attempt -lt 40 -and -not (Test-Path -LiteralPath $capture); $attempt++) {
        Start-Sleep -Milliseconds 250
    }
}
finally {
    if (-not $process.HasExited) {
        $process.Kill()
        $process.WaitForExit()
    }
}

if (-not (Test-Path -LiteralPath $capture)) {
    throw 'The rebuilt launcher did not start the probe executable.'
}

$ini = Get-Content -LiteralPath (Join-Path $sandbox 'boa-launcher.ini') -Raw
foreach ($required in @('[Launcher co-op]', 'Players=2', '[Addon]')) {
    if (-not $ini.Contains($required)) {
        throw "The launcher did not preserve INI content: $required"
    }
}
if (-not $ini.Contains('Theme=BladeOfAgony')) {
    throw 'The selected Blade of Agony design was not persisted.'
}
if ($Multi) {
    if (-not $ini.Contains('addonFileName=addons/addon_confiscated_weapons.boa;addons/addon_behaviour.boa')) {
        throw 'The Ctrl-style multi-selection was not persisted in list order.'
    }
    'Ctrl multi-selection persistence: PASS'
} elseif ($NoAddons) {
    if (-not $ini.Contains('LaunchWithAddon=0')) {
        throw 'The No addons selection did not disable addons.'
    }
    'No-addons selection: PASS'
}
if ($previewWidth -gt 0) {
    "Live preview viewport ${previewWidth}x${previewHeight}: PASS"
}
"Game language -> launcher localization: PASS"
"Dark, Light, and Blade of Agony theme colors: PASS"

if (Test-Path -LiteralPath $screenshot) {
    Get-Item -LiteralPath $screenshot | Select-Object FullName, Length
}
Get-Content -LiteralPath $capture
'INI preservation: PASS'
