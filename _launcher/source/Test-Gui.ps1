param(
    [switch] $Multi,
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

    if ($Multi) {
        $multiButton = $null
        $findMulti = [RebuiltGuiTestNative+EnumProc] {
            param($handle, $state)
            if ((Read-Text $handle).StartsWith('Mehrere Addons') -or (Read-Text $handle).StartsWith('Select multiple')) {
                $script:multiButton = $handle
            }
            return $true
        }
        [void] [RebuiltGuiTestNative]::EnumChildWindows($window, $findMulti, [IntPtr]::Zero)
        if (-not $multiButton) {
            throw 'The multi-addon button was not found.'
        }
        [void] [RebuiltGuiTestNative]::PostMessage($multiButton, 0x00F5, [IntPtr]::Zero, [IntPtr]::Zero)

        $dialog = $null
        for ($attempt = 0; $attempt -lt 40 -and -not $dialog; $attempt++) {
            Start-Sleep -Milliseconds 250
            $findDialog = [RebuiltGuiTestNative+EnumProc] {
                param($handle, $state)
                [uint32] $owner = 0
                [void] [RebuiltGuiTestNative]::GetWindowThreadProcessId($handle, [ref] $owner)
                $title = Read-Text $handle
                if ($owner -eq $process.Id -and $handle -ne $window -and $title.StartsWith('Blade of Agony:')) {
                    $script:dialog = $handle
                }
                return $true
            }
            [void] [RebuiltGuiTestNative]::EnumWindows($findDialog, [IntPtr]::Zero)
        }
        if (-not $dialog) {
            throw 'The multi-addon dialog did not appear.'
        }

        $lists = [Collections.Generic.List[object]]::new()
        $moveRight = $null
        $apply = $null
        $findDialogControls = [RebuiltGuiTestNative+EnumProc] {
            param($handle, $state)
            $class = [Text.StringBuilder]::new(128)
            [void] [RebuiltGuiTestNative]::GetClassName($handle, $class, $class.Capacity)
            $text = Read-Text $handle
            if ($class.ToString().Contains('LISTBOX')) {
                $rect = [RebuiltGuiTestNative+Rect]::new()
                [void] [RebuiltGuiTestNative]::GetWindowRect($handle, [ref] $rect)
                $lists.Add([pscustomobject] @{ Handle = $handle; Left = $rect.Left })
            } elseif ($text -eq '>') {
                $script:moveRight = $handle
            } elseif ($text -in @('Apply', 'Anwenden')) {
                $script:apply = $handle
            }
            return $true
        }
        [void] [RebuiltGuiTestNative]::EnumChildWindows($dialog, $findDialogControls, [IntPtr]::Zero)
        $lists = @($lists | Sort-Object Left)
        if ($lists.Count -ne 2 -or -not $moveRight -or -not $apply) {
            throw 'The multi-addon dialog controls were incomplete.'
        }

        [void] [RebuiltGuiTestNative]::SendMessage($lists[0].Handle, 0x0186, [IntPtr] 0, [IntPtr]::Zero)
        [void] [RebuiltGuiTestNative]::SendMessage($moveRight, 0x00F5, [IntPtr]::Zero, [IntPtr]::Zero)
        [void] [RebuiltGuiTestNative]::PostMessage($apply, 0x00F5, [IntPtr]::Zero, [IntPtr]::Zero)
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

if (Test-Path -LiteralPath $screenshot) {
    Get-Item -LiteralPath $screenshot | Select-Object FullName, Length
}
Get-Content -LiteralPath $capture
'INI preservation: PASS'
