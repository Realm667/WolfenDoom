# Blade of Agony Add-ons

This directory contains the source files for the officially distributed
Blade of Agony add-ons. It replaces the former `Realm667/boa-addons`
repository and keeps add-on development next to the main game.

## Structure

- `source/<addon>/` contains the game payload, descriptor metadata, and
  preview images for one add-on.
- `add-on_builder.cmd` builds every source directory.
- `7za.exe` is the command-line archiver used by the builder.

## Build

Run `add-on_builder.cmd` from this directory. Generated descriptor and payload
files are written together to `release/addons`:

```text
release/addons/addon_<name>.boa
release/addons/<name>.pk3
```

The generated archives are release artifacts and are intentionally excluded
from version control.
