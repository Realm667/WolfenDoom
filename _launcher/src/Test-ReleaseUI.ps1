param([string]$Executable = (Join-Path $PSScriptRoot 'dist/Blade of Agony - Launcher.exe'))
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework
$asm = [Reflection.Assembly]::LoadFrom((Resolve-Path $Executable))
$flags = [Reflection.BindingFlags]'Public,NonPublic,Static,Instance'
function Kind($name) { $asm.GetType("BladeOfAgonyLauncher.$name",$true) }
function Field($obj,$name) { ,$obj.GetType().GetField($name,$flags).GetValue($obj) }
function Assert($value,$label) { if (!$value) { throw $label } }
function Luminance($brush) {
    $c = $brush.Color
    $v = foreach ($n in $c.R,$c.G,$c.B) { $x=$n/255.0; if ($x -le .04045) { $x/12.92 } else { [Math]::Pow(($x+.055)/1.055,2.4) } }
    .2126*$v[0]+.7152*$v[1]+.0722*$v[2]
}
function Ratio($a,$b) { $x=Luminance $a; $y=Luminance $b; ([Math]::Max($x,$y)+.05)/([Math]::Min($x,$y)+.05) }
Assert ($asm.GetName().Version.ToString() -eq '2.6.25.0') 'Unexpected assembly version'
foreach ($name in 'BladeOfAgony','Light','Dark','Wolfenstein3D') {
    $theme=[Enum]::Parse((Kind LauncherTheme),$name)
    $pal=(Kind ThemePalette).GetMethod('Create',$flags).Invoke($null,@($theme))
    foreach($fill in 'ButtonFill','GoodFill','ErrorFill') { Assert ((Ratio (Field $pal AccentText) (Field $pal $fill)) -ge 4.5) "$name $fill contrast" }
    foreach($ink in 'Warning','Good','Error') { Assert ((Ratio (Field $pal $ink) (Field $pal Surface)) -ge 4.5) "$name $ink contrast" }
}
foreach($code in 'en','de','es','fr','ptb','it','ru','cs','tr','pl') {
    $loc=(Kind ModernLocalization).GetMethod('Load',$flags).Invoke($null,@($code))
    $values=Field $loc values
    foreach($key in 'Show all saves','Verify installation','Advanced launch options','Save backup created: {0}','Report saved: {0} passed, {1} blocked.','Crash:Engine') {
        Assert ($values.ContainsKey($key) -and ($code -eq 'en' -or $values[$key] -ne $key)) "$code $key"
        foreach($placeholder in [regex]::Matches($key,'\{\d+\}')) { Assert ($values[$key].Contains($placeholder.Value)) "$code placeholder" }
    }
}
'Packaged EXE: version, ten interface languages, message placeholders and four theme contrast palettes: PASS'
