$ErrorActionPreference = 'Stop'

$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Split-Path -Parent $project
$sandbox = Join-Path $workspace 'work\launcher-probe\sandbox'
$diagnostics = Join-Path $project 'dist\Blade of Agony - Launcher Diagnostics.exe'

function Assert-Command([string[]] $Arguments, [string] $Expected) {
    $actual = (& $diagnostics --base-directory $sandbox --print-command @Arguments | Out-String).Trim()
    if ($actual -ne $Expected) {
        throw "Command mismatch.`nExpected: $Expected`nActual:   $actual"
    }
}

Assert-Command @(
    '--detail', 'last',
    '--displacement', 'off',
    '--language', 'last',
    '--commentary', 'off'
) 'boa.exe -iwad boa.ipk3 +set boa_devcomswitch 0'

Assert-Command @(
    '--detail', 'default',
    '--displacement', 'off',
    '--language', 'last',
    '--commentary', 'off'
) 'boa.exe -iwad boa.ipk3 +exec launcher-resource/detail-default.cfg +set boa_devcomswitch 0'

Assert-Command @(
    '--detail', 'verylow',
    '--displacement', 'off',
    '--language', 'last',
    '--commentary', 'off'
) 'boa.exe -iwad boa.ipk3 +exec launcher-resource/detail-verylow.cfg +set boa_devcomswitch 0'

Assert-Command @(
    '--detail', 'veryhigh',
    '--displacement', 'on',
    '--language', 'de',
    '--commentary', 'on'
) 'boa.exe -iwad boa.ipk3 -file boa_dt.pk3 +exec launcher-resource/detail-veryhigh.cfg +set boa_devcomswitch 1 +set language de'

Assert-Command @(
    '--displacement', 'off',
    '--commentary', 'off',
    '--language', 'last',
    '--addon', 'addon_behaviour.boa'
) 'boa.exe -iwad boa.ipk3 -file addon_behaviour.boa +set boa_devcomswitch 0'

Assert-Command @(
    '--displacement', 'on',
    '--commentary', 'on',
    '--language', 'last',
    '--multi-addon', 'addon_behaviour.boa',
    '--multi-addon', 'addon_confiscated_weapons.boa'
) 'boa.exe -iwad boa.ipk3 -file addons/behaviour.pk3 addons/confiscated_weapons.pk3 -file boa_dt.pk3 +set boa_devcomswitch 1'

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
        '--detail', 'last',
        '--displacement', 'off',
        '--commentary', 'off',
        '--language', $language
    ) "boa.exe -iwad boa.ipk3 +set boa_devcomswitch 0 +set language $expectedLanguage"
}

$scan = & $diagnostics --base-directory $sandbox --scan-addons
if (($scan | Measure-Object).Count -ne 2) {
    throw 'Addon scan did not return both sandbox descriptors.'
}
if (-not ($scan -match 'addons/behaviour.pk3') -or -not ($scan -match 'addons/confiscated_weapons.pk3')) {
    throw 'Addon scan did not resolve both LOAD entries.'
}

'Core command tests: PASS'
'Language and alias tests: PASS'
'Addon descriptor tests: PASS'
