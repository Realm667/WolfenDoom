# Blade of Agony Add-ons

This directory contains the source files for the officially distributed
Blade of Agony add-ons. It replaces the former `Realm667/boa-addons`
repository and keeps add-on development next to the main game.

## Structure

- `source/<addon>/` contains the game payload, descriptor metadata, and
  preview images for one add-on.
- `add-on_builder.cmd` builds every source directory.
- `7za.exe` is the command-line archiver used by the builder.

## Descriptor metadata

Every `source/<addon>/addoninfo.txt` declares a stable `id`, semantic
`version`, minimum BoA and engine versions, dependencies, conflicts, load
ordering, multiplayer safety, campaign requirements, and a category. Keep
these values current whenever an add-on changes behavior or compatibility.

Validate all descriptors and numbered preview images before building:

```powershell
./validate_metadata.ps1
```

## Build

Run `add-on_builder.cmd` from this directory. Generated descriptor and payload
files are written together to `release/addons`:

```text
release/addons/addon_<name>.boa
release/addons/<name>.pk3
```

The generated archives are release artifacts and are intentionally excluded
from version control.

## Disclaimer

It is important for those working on these addons, that it is not possible to
predict all combinations of addons in a single run ON 3.1 RELEASE, where you are
forced mostly to play with just ONE ADDON.

With the imminent release of 3.2, now GREEN or RED indicators will show you
possibile choices among addons compatible with BoA before you launch a new
game (via our custom launcher). Though, it is possible that later or early
during your gameplay, issues might happen. In that case, let us know or open an
issue on this repository, maybe even with fixes for the problem.

--Ozymandias81, with help from hawkwind3
