# Blade of Agony Launcher - Clean-room Rebuild

This project is a source-based reconstruction of the launcher shipped with
Blade of Agony 3.1. It was created from observed file formats, embedded UI
resources, and black-box command-line behavior. It is not a recovery of the
original Pascal source code.

## Features

- Launches `boa.exe` with the same detail, displacement, commentary, and
  language arguments as the original launcher.
- Offers the ten languages present in `boa.ipk3/language.csv`, defaults to
  English, persists the selection, and normalizes GZDoom aliases. Changing the
  game language immediately changes the launcher language as well.
- Restores cooperative multiplayer setup with single-player, host, and join
  modes. Host settings cover total player count, start map, UDP port, skill,
  and `sv_cheats`; join mode accepts a host name or IPv4 address and port.
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
- Reads the existing gettext `.po` files from `language` and supplies built-in
  launcher strings for all ten supported game languages.
- Updates only owned keys in `boa-launcher.ini`, migrates the original
  `[Launcher co-op]` settings, and preserves unrelated sections and keys.
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
--print-ui
--base-directory DIR
--detail last|default|verylow|low|normal|high|veryhigh
--displacement on|off
--language en|de|es|ru|ptb|pt|br|it|tr|trk|fr|cs|pl|plk
--commentary on|off
--multiplayer single|host|join
--players 2..8
--map C1M1
--host HOSTNAME_OR_IPV4
--port 1..65535
--skill 1..5
--cheats on|off
--no-addons
--addon FILE
--multi-addon FILE
```

Example:

```powershell
& '.\dist\Blade of Agony - Launcher Diagnostics.exe' `
  --print-command --detail high --displacement on `
  --language de --commentary on --multiplayer host `
  --players 2 --map C1M1 --port 5029 --skill 2 --cheats on
```

The resulting multiplayer portion is:

```text
-host 2 -port 5029 -skill 2 +set sv_cheats 1 +map C1M1
```

Joining the same host uses:

```text
-join 192.168.1.25:5029
```

## Compatibility notes

The original launcher is a native 64-bit Lazarus/FPC 3.2.0 application. No
Pascal project files were present in the game tree, so a faithful clean-room
rebuild is more maintainable than attempting to recover compiler-generated
code. The bundled Blade of Agony artwork and icon remain assets of their
respective owners and are included here solely for launcher compatibility.
