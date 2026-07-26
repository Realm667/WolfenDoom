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

    if (-not $SkipScreenshot) {
        $rect = [RebuiltGuiTestNative+Rect]::new()
        [void] [RebuiltGuiTestNative]::GetWindowRect($window, [ref] $rect)
        [void] [RebuiltGuiTestNative]::SetForegroundWindow($window)
        Start-Sleep -Milliseconds 400
        $bitmap = [Drawing.Bitmap]::new($rect.Right - $rect.Left, $rect.Bottom - $rect.Top)
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
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

    $play = $null
    $childCallback = [RebuiltGuiTestNative+EnumProc] {
        param($handle, $state)
        $text = Read-Text $handle
        if ($text -in @('Play', 'Spielen')) {
            $script:play = $handle
        }
        return $true
    }
    [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $childCallback, [IntPtr]::Zero)
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

if (Test-Path -LiteralPath $screenshot) {
    Get-Item -LiteralPath $screenshot | Select-Object FullName, Length
}
Get-Content -LiteralPath $capture
'INI preservation: PASS'
