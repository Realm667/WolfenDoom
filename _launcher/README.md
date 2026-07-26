# Blade of Agony Launcher - Clean-room Rebuild

This project is a source-based reconstruction of the launcher shipped with
Blade of Agony 3.1. It was created from observed file formats, embedded UI
resources, and black-box command-line behavior. It is not a recovery of the
original Pascal source code.

## Features

- Launches `boa.exe` with the same detail, displacement, commentary, and
  language arguments as the original launcher.
- Scans `.boa` ZIP descriptors and reads localized `addoninfo.txt` metadata.
- Displays addon descriptions, requirements, credits, and preview images.
- Supports the original single-addon behavior (`-file addon_name.boa`).
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
`boa_dt.pk3`, the `.boa` descriptors, `launcher-resource`, and `language`.
The rebuilt launcher intentionally uses the game's existing data files.

## Diagnostics

The console diagnostics build accepts:

```text
--scan-addons
--print-command
--base-directory DIR
--detail last|default|verylow|low|normal|high|veryhigh
--displacement on|off
--language last|auto|cs|de|default|en-GB|es|fr|it|pl|ptg|ru|tr
--commentary on|off
--addon FILE
--multi-addon FILE
```

Example:

```powershell
& '.\dist\Blade of Agony - Launcher Diagnostics.exe' `
  --print-command --detail high --displacement on `
  --language en-GB --commentary on
```

## Compatibility notes

The original launcher is a native 64-bit Lazarus/FPC 3.2.0 application. No
Pascal project files were present in the game tree, so a faithful clean-room
rebuild is more maintainable than attempting to recover compiler-generated
code. The bundled Blade of Agony artwork and icon remain assets of their
respective owners and are included here solely for launcher compatibility.
