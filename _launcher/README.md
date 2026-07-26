# Blade of Agony Launcher - Clean-room Rebuild

This project is a source-based reconstruction of the launcher shipped with
Blade of Agony 3.1. It was created from observed file formats, embedded UI
resources, and black-box command-line behavior. It is not a recovery of the
original Pascal source code.

## Features

- Launches `boa.exe` with the same detail, displacement, commentary, and
  language arguments as the original launcher.
- Offers the ten languages present in `boa.ipk3/language.csv`, defaults to
  English, persists the selection, and normalizes GZDoom aliases.
- Scans `.boa` ZIP descriptors exclusively from `addons` and reads localized
  `addoninfo.txt` metadata.
- Selects multiple addons directly in the main list with Ctrl plus the primary
  mouse button.
- Provides an exclusive `No addons` list entry instead of a separate checkbox.
- Displays preview images in a fixed 16:9 viewport using centered cover
  cropping. The viewport always consumes the complete width of the details
  column, without letterboxing or unused side areas.
- Supports single-addon loading from `addons`
  (`-file addons/addon_name.boa`).
- Supports ordered multi-addon loading through each descriptor's
  `gameinfo.txt` `LOAD` entries.
- Reads the existing gettext `.po` files from `language`.
- Updates only owned keys in `boa-launcher.ini` and preserves unrelated
  sections such as co-op settings.
- Rejects absolute and parent-traversing paths from addon descriptors.
- Includes a command-line diagnostics build for reproducible tests.

## Build

Run from Windows PowerShell:

```powershell
.\build.ps1
```

The script uses the C# compiler included with the 64-bit .NET Framework and
creates both executables in `dist`.

## Install

Place `Blade of Agony - Launcher Rebuilt.exe` next to `boa.exe`, `boa.ipk3`,
`boa_dt.pk3`, `launcher-resource`, and `language`. Place every `.boa`
descriptor in `addons` next to its corresponding PK3 data. Root-level `.boa`
files are intentionally ignored.

## Diagnostics

The console diagnostics build accepts:

```text
--scan-addons
--verify-preview
--print-command
--base-directory DIR
--detail last|default|verylow|low|normal|high|veryhigh
--displacement on|off
--language en|de|es|ru|ptb|pt|br|it|tr|trk|fr|cs|pl|plk
--commentary on|off
--no-addons
--addon FILE
--multi-addon FILE
```

Example:

```powershell
& '.\dist\Blade of Agony - Launcher Diagnostics.exe' `
  --print-command --detail high --displacement on `
  --language en --commentary on
```

## Compatibility notes

The original launcher is a native 64-bit Lazarus/FPC 3.2.0 application. No
Pascal project files were present in the game tree, so a faithful clean-room
rebuild is more maintainable than attempting to recover compiler-generated
code. The bundled Blade of Agony artwork and icon remain assets of their
respective owners and are included here solely for launcher compatibility.
