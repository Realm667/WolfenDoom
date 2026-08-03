$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot 'source'
$required = @(
    'id', 'version', 'minBoAVersion', 'minEngineVersion', 'requires',
    'conflicts', 'loadAfter', 'multiplayerSafe', 'newCampaignRequired',
    'category', 'title', 'description', 'previewImages'
)
$ids = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase)
foreach ($addon in Get-ChildItem -LiteralPath $root -Directory) {
    $path = Join-Path $addon.FullName 'addoninfo.txt'
    if (-not (Test-Path -LiteralPath $path)) {
        throw "$($addon.Name): addoninfo.txt is missing."
    }
    $values = @{}
    foreach ($line in Get-Content -LiteralPath $path -Encoding UTF8) {
        if ($line -match '^\s*([^#=/][^=]*)\s*=\s*(.*?)\s*$') {
            $values[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    foreach ($key in $required) {
        if (-not $values.ContainsKey($key)) {
            throw "$($addon.Name): required metadata '$key' is missing."
        }
    }
    if (-not $ids.Add($values.id)) {
        throw "$($addon.Name): duplicate id '$($values.id)'."
    }
    if ($values.version -notmatch '^\d+\.\d+\.\d+$') {
        throw "$($addon.Name): version must use semantic x.y.z format."
    }
    if ($values.multiplayerSafe -notmatch '^(true|false)$' -or
        $values.newCampaignRequired -notmatch '^(true|false)$') {
        throw "$($addon.Name): boolean metadata must be true or false."
    }
    [int] $previewCount = 0
    if (-not [int]::TryParse($values.previewImages, [ref] $previewCount)) {
        throw "$($addon.Name): previewImages must be an integer."
    }
    $previews = @(Get-ChildItem -LiteralPath (Join-Path $addon.FullName 'preview') -File -ErrorAction SilentlyContinue | Where-Object Name -Match '^\d+\.(jpg|jpeg|png)$')
    if ($previews.Count -ne $previewCount) {
        throw "$($addon.Name): expected $previewCount preview images, found $($previews.Count)."
    }
}
"Validated $($ids.Count) official add-on descriptors."
