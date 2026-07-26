# Blade of Agony Launcher

Version 2.0.2 is a modern WPF launcher for Blade of Agony and the bundled
UZDoom 4.14.3 engine. It is a clean-room replacement for the original native
launcher and remains portable: no installer or additional UI runtime is
required on supported Windows systems.

## Interface

- Responsive four-area navigation for Start, Add-ons, Multiplayer, and
  Diagnostics.
- Persistent launch summary and primary Launch action.
- Official Blade of Agony header logo and live UZDoom product version read
  from the adjacent `boa.exe`.
- Independent game and interface languages for all ten Blade of Agony
  language codes.
- Blade of Agony, Dark, Light, and Wolfenstein 3D designs.
- Per-monitor DPI awareness, Windows text scaling, keyboard navigation,
  accessible automation names, high-contrast support, and animated page
  transitions.
- Runtime reflow with compact icon navigation on narrow windows.

## Blade of Agony integration

- Reads episodes, campaign maps, skills, and localized names at runtime from
  `MAPINFO` and `language.csv` inside `boa.ipk3`.
- Also reads unpacked files when the launcher is run from the current
  `wolfendoom.git` development tree.
- Supports a normal main-menu launch or a direct episode/map/skill start.
- Sorts missions by chapter, mission number, and map part while keeping
  introduction maps first and optional `M0` missions last.
- Keeps `boa_steamswitch` enabled after every graphics profile, as required
  by current BoA Zyklon steam spawners.
- Ships corrected copies of all six detail profiles without duplicate
  `boa_grasslod` assignments.
- Explains the visual-quality and performance differences between detail
  profiles in concise, user-focused tooltips.

## Add-ons

- Scans descriptors only from `addons/*.boa`.
- Supports normal Ctrl/Shift list selection and visible checkboxes.
- Includes an exclusive `No add-ons` item and a selected-item count.
- Preserves deterministic load order and provides move-up/down controls.
- Keeps the 16:9 preview visible, uses cover cropping, and scrolls long
  descriptions, requirements, and compatibility messages.
- Understands optional descriptor fields:
  `id`, `version`, `minBoAVersion`, `minEngineVersion`, `requires`,
  `conflicts`, `loadAfter`, `multiplayerSafe`, `newCampaignRequired`, and
  `category`.
- Detects missing payloads, declared dependencies/conflicts, minimum engine
  versions, ordering mistakes, invalid archives, and overlapping PK3 paths.

## Multiplayer

- Provides single-player, host co-op, and join co-op modes.
- Host setup supports 2-8 players, episode/map selection, all five BoA
  difficulties, UDP port, and `sv_cheats`.
- Join setup supports host name or IPv4 address and port.
- Multiplayer validates only `boa.exe` as UZDoom 4.14.3 and `boa.ipk3`.
- All selected add-ons and `boa_dt.pk3` are excluded from multiplayer
  commands. The single-player add-on selection is retained for later use.
- No UZDoom 5 preview support is included.

## Build

Run from Windows PowerShell:

```powershell
.\build.ps1
```

The build uses the Windows .NET Framework compiler and WPF assemblies already
included with Windows. It creates:

```text
dist/Blade of Agony - Launcher.exe
dist/Blade of Agony - Launcher Diagnostics.exe
dist/launcher-resource/*.cfg
```

## Install

Place `Blade of Agony - Launcher.exe` in the same directory as:

```text
boa.exe
boa.ipk3
boa_dt.pk3
launcher-resource/
addons/
language/
```

The launcher reads the final `MAPINFO` directly from `boa.ipk3`; no extracted
copy is required.

## Tests

```powershell
.\Test-Core.ps1
.\Test-ModernGui.ps1
```

The core suite checks commands, language aliases, interface localization,
MAPINFO parsing, add-on isolation, real archive overlaps, UZDoom 4.14.3, and
graphics profiles. The GUI suite checks the accessibility tree, compact
layout, navigation, add-on selection, and the live 16:9 preview bounds.

## Diagnostics

Useful commands:

```text
--print-command
--print-ui
--print-content
--scan-addons
--check-addons
--check-multiplayer
--base-directory DIR
--detail last|default|verylow|low|normal|high|veryhigh
--displacement on|off
--language CODE
--interface-language CODE
--theme dark|light|boa|wolfenstein3d
--direct-start on|off
--multiplayer single|host|join
--players 2..8
--map MAP
--host HOSTNAME_OR_IPV4
--port 1..65535
--skill 1..5
--cheats on|off
--no-addons
--multi-addon FILE
```
