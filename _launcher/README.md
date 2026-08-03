# Blade of Agony Launcher

Version 2.2.1 is a modern WPF launcher for Blade of Agony and UZDoom 4.14.3
or 5.x. It is a clean-room replacement for the original native launcher and
remains portable: no installer or additional UI runtime is required on
supported Windows systems.

## Interface

- Responsive four-area navigation for Quick Launch, Add-ons, Multiplayer, and
  Diagnostics.
- Persistent launch summary and primary Play action.
- Official Blade of Agony header logo and live UZDoom product version read
  from the adjacent `boa.exe`.
- Bundled Unica One typography for the Blade of Agony title and sidebar
  navigation; no network connection or system font installation is required.
- Unica One page headlines for Quick Launch, Add-ons, Multiplayer, and
  Diagnostics.
- Independent game and interface languages, including separate English (US)
  and English (UK) game options plus European Portuguese.
- Blade of Agony, Dark, Light, and Wolfenstein 3D designs.
- Per-monitor DPI awareness, Windows text scaling, keyboard navigation,
  accessible automation names, high-contrast support, and animated page
  transitions.
- Runtime reflow with compact icon navigation on narrow windows.
- Saves and restores the user-adjusted launcher window size.

## Blade of Agony integration

- Reads episodes, campaign maps, skills, and localized names at runtime from
  `MAPINFO` and `language.csv` inside `boa.ipk3`.
- Also reads unpacked files when the launcher is run from the current
  `wolfendoom.git` development tree.
- Supports a normal main-menu launch or a direct episode/map/skill start.
- Shows the selected mission, difficulty, and game language in the footer
  for direct campaign starts.
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
- Keeps the 16:9 preview visible, uses cover cropping, and provides a
  wrapping previous/next carousel for all numbered preview images.
- Scrolls long descriptions, requirements, and compatibility messages.
- Understands optional descriptor fields:
  `id`, `version`, `minBoAVersion`, `minEngineVersion`, `requires`,
  `conflicts`, `loadAfter`, `multiplayerSafe`, `newCampaignRequired`, and
  `category`.
- Detects missing payloads, declared dependencies/conflicts, minimum engine
  versions, ordering mistakes, invalid archives, and overlapping PK3 paths.

## Multiplayer

- Provides single-player, host co-op, and join co-op modes.
- Host setup supports 2-4 players, episode/map selection, all five BoA
  difficulties, UDP port, and `sv_cheats`.
- Join setup supports host name or IPv4 address and port.
- Multiplayer validates only `boa.exe` as UZDoom 4.14.3 or 5.x and
  `boa.ipk3`.
- All selected add-ons and `boa_dt.pk3` are excluded from multiplayer
  commands. The single-player add-on selection is retained for later use.
- UZDoom 4.14.3 receives its legacy language aliases (`enu`, `eng`, and
  `pt`); UZDoom 5.x receives IETF BCP 47 language tags and the explicit
  `-coop` option when hosting.

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
dist/licenses/UnicaOne-OFL.txt
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
MAPINFO parsing, add-on isolation, numbered preview discovery, embedded
font resources, real archive overlaps, UZDoom 4.14.3/5.x command generation,
and graphics profiles. The GUI suite checks the accessibility tree, compact
layout, Quick Launch controls, navigation, language and player choices,
window-size persistence, add-on selection, and the wrapping 16:9 preview
carousel.

## Third-party assets

Unica One is distributed under the SIL Open Font License 1.1. Its license is
embedded in the launcher and copied to `dist/licenses/UnicaOne-OFL.txt`.

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
--players 2..4
--map MAP
--host HOSTNAME_OR_IPV4
--port 1..65535
--skill 1..5
--cheats on|off
--no-addons
--multi-addon FILE
```
