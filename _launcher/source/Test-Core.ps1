$ErrorActionPreference = 'Stop'

$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Split-Path -Parent $project
$sandbox = Join-Path $workspace 'work\launcher-probe\sandbox'
$diagnostics = Join-Path $project 'dist\Blade of Agony - Launcher Diagnostics.exe'

function Assert-Command([string[]] $Arguments, [string] $Expected) {
    if ($Arguments -notcontains '--multiplayer') {
        $Arguments += @('--multiplayer', 'single')
    }
    $actual = (& $diagnostics --base-directory $sandbox --print-command @Arguments | Out-String).Trim()
    if ($actual -ne $Expected) {
        throw "Command mismatch.`nExpected: $Expected`nActual:   $actual"
    }
}

Assert-Command @(
    '--no-addons',
    '--detail', 'last',
    '--displacement', 'off',
    '--language', 'last',
    '--commentary', 'off'
) 'boa.exe -iwad boa.ipk3 +set boa_devcomswitch 0'

Assert-Command @(
    '--no-addons',
    '--detail', 'default',
    '--displacement', 'off',
    '--language', 'last',
    '--commentary', 'off'
) 'boa.exe -iwad boa.ipk3 +exec launcher-resource/detail-default.cfg +set boa_devcomswitch 0'

Assert-Command @(
    '--no-addons',
    '--detail', 'verylow',
    '--displacement', 'off',
    '--language', 'last',
    '--commentary', 'off'
) 'boa.exe -iwad boa.ipk3 +exec launcher-resource/detail-verylow.cfg +set boa_devcomswitch 0'

Assert-Command @(
    '--no-addons',
    '--detail', 'veryhigh',
    '--displacement', 'on',
    '--language', 'de',
    '--commentary', 'on'
) 'boa.exe -iwad boa.ipk3 -file boa_dt.pk3 +exec launcher-resource/detail-veryhigh.cfg +set boa_devcomswitch 1 +set language de'

Assert-Command @(
    '--displacement', 'off',
    '--commentary', 'off',
    '--language', 'last',
    '--addon', 'addons/addon_behaviour.boa'
) 'boa.exe -iwad boa.ipk3 -file addons/addon_behaviour.boa +set boa_devcomswitch 0'

Assert-Command @(
    '--displacement', 'on',
    '--commentary', 'on',
    '--language', 'last',
    '--multi-addon', 'addons/addon_behaviour.boa',
    '--multi-addon', 'addons/addon_confiscated_weapons.boa'
) 'boa.exe -iwad boa.ipk3 -file addons/behaviour.pk3 addons/confiscated_weapons.pk3 -file boa_dt.pk3 +set boa_devcomswitch 1'

Assert-Command @(
    '--no-addons',
    '--detail', 'last',
    '--displacement', 'off',
    '--language', 'de',
    '--commentary', 'off',
    '--multiplayer', 'host',
    '--players', '4',
    '--map', 'C1M2',
    '--port', '5030',
    '--skill', '3',
    '--cheats', 'off'
) 'boa.exe -iwad boa.ipk3 +set boa_devcomswitch 0 +set language de -host 4 -port 5030 -skill 3 +set sv_cheats 0 +map C1M2'

Assert-Command @(
    '--no-addons',
    '--detail', 'last',
    '--displacement', 'off',
    '--language', 'en',
    '--commentary', 'off',
    '--multiplayer', 'join',
    '--host', '192.168.1.25',
    '--port', '5040'
) 'boa.exe -iwad boa.ipk3 +set boa_devcomswitch 0 +set language en -join 192.168.1.25:5040'

$languageCases = @{
    'en' = 'en'
    'de' = 'de'
    'es' = 'es'
    'ru' = 'ru'
    'ptb' = 'ptb'
    'pt' = 'ptb'
    'br' = 'ptb'
    'it' = 'it'
    'tr' = 'tr'
    'trk' = 'tr'
    'fr' = 'fr'
    'cs' = 'cs'
    'pl' = 'pl'
    'plk' = 'pl'
    'default' = 'en'
}
foreach ($language in $languageCases.Keys) {
    $expectedLanguage = $languageCases[$language]
    Assert-Command @(
        '--no-addons',
        '--detail', 'last',
        '--displacement', 'off',
        '--commentary', 'off',
        '--language', $language
    ) "boa.exe -iwad boa.ipk3 +set boa_devcomswitch 0 +set language $expectedLanguage"
}

foreach ($language in @('en', 'de', 'es', 'ru', 'ptb', 'it', 'tr', 'fr', 'cs', 'pl')) {
    $ui = & $diagnostics --base-directory $sandbox --print-ui --language $language
    if ($ui -notcontains "Language=$language") {
        throw "UI diagnostics did not retain language $language."
    }
    if ($language -ne 'en' -and $ui -contains 'HostCoop=Host co-op') {
        throw "Multiplayer UI was not localized for $language."
    }
    if ($language -ne 'en' -and $ui -contains 'Dark=Dark') {
        throw "Theme UI was not localized for $language."
    }
}

$themeCases = @{
    'dark' = 'Dark'
    'light' = 'Light'
    'boa' = 'BladeOfAgony'
    'blade-of-agony' = 'BladeOfAgony'
}
$defaultThemeUi = & $diagnostics `
    --base-directory (Join-Path $project 'dist\nonexistent-default-theme') `
    --print-ui
if ($defaultThemeUi -notcontains 'Theme=Dark') {
    throw 'A launcher configuration without Theme did not default to Dark.'
}
foreach ($theme in $themeCases.Keys) {
    $ui = & $diagnostics --base-directory $sandbox --print-ui --theme $theme
    if ($ui -notcontains "Theme=$($themeCases[$theme])") {
        throw "Theme diagnostics did not normalize $theme."
    }
}

$scan = & $diagnostics --base-directory $sandbox --scan-addons
if (($scan | Measure-Object).Count -ne 2) {
    throw 'Addon scan did not return both sandbox descriptors.'
}
if (-not ($scan -match 'addons/behaviour.pk3') -or -not ($scan -match 'addons/confiscated_weapons.pk3')) {
    throw 'Addon scan did not resolve both LOAD entries.'
}
if (($scan | Where-Object { $_ -notmatch '^addons/addon_[^\t]+\.boa\t' } | Measure-Object).Count -ne 0) {
    throw 'Addon scan returned a descriptor outside the addons directory.'
}
$previewTest = (& $diagnostics --verify-preview | Out-String).Trim()
if ($previewTest -ne 'Preview 16:9 cover-crop tests: PASS') {
    throw 'Preview geometry diagnostics failed.'
}

'Core command tests: PASS'
'Language and alias tests: PASS'
'Launcher localization tests: PASS'
'Theme selection and localization tests: PASS'
'Multiplayer host/join command tests: PASS'
'Addons-directory descriptor tests: PASS'
'Preview 16:9 cover-crop tests: PASS'
