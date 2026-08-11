# Blade of Agony Launcher

Version 2.6.1 is a modern WPF launcher for Blade of Agony and UZDoom 4.14.3
or 5.x. It is a clean-room replacement for the original native launcher and
remains portable: no installer or additional UI runtime is required on
supported Windows systems.

## Interface

- Responsive four-area navigation for Quick Launch, Add-ons, Multiplayer, and
  Diagnostics.
- Persistent launch summary with Play as the normal Start Mode action and a
  separate Continue Campaign action for the latest readable savegame.
- Official Blade of Agony header logo and live UZDoom product version read
  from the adjacent `uzdoom.exe`.
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
- A launch preflight verifies the engine, main game, writable data and save
  paths, selected add-ons, and supported command surface before UZDoom starts.
- UZDoom configuration discovery supports portable, Documents/My Games,
  Documents/MyGames, and roaming-user locations without requiring an existing
  INI file.
- Saves and restores the user-adjusted launcher window size.
- Named built-in and user launch profiles with validated import/export;
  profiles include the selected add-ons and their load order.
- Profiles can be duplicated, renamed, favorited, compared with current
  settings, and assigned an isolated UZDoom configuration.
- Compatibility-aware add-on selection: compatible choices are highlighted
  in green, while only the add-ons involved in a blocking clash turn red.
- Full launcher animations are always enabled. XInput controller navigation
  activates automatically whenever a compatible controller is connected.

## Blade of Agony integration

- Reads episodes, campaign maps, skills, and localized names at runtime from
  `MAPINFO` and `language.csv` inside `boa.ipk3`.
- Also reads unpacked files when the launcher is run from the current
  `wolfendoom.git` development tree.
- Reads `.zds` `info.json` metadata and save previews for one-click campaign
  continuation through UZDoom's `-loadgame` option.
- Passes a canonical absolute save path to `-loadgame`, preventing UZDoom
  from prepending its active save directory a second time.
- Lists only savegames whose `Game WAD` metadata identifies `boa.ipk3`;
  saves belonging to other games are omitted from Continue Campaign.
- Discovers UZDoom saves in `%USERPROFILE%\Saved Games\UZDoom` on Windows,
  honors an explicit `save_dir` in UZDoom configuration, and retains the
  local `save/` folder as a legacy fallback.
- Binds newly written saves to engine, game, add-on, and load-order hashes;
  mismatched content is blocked before Continue.
- Supports a normal main-menu launch or an advanced direct mission start.
- Separates Main Menu, New Campaign, and Mission Select into explicit start
  modes while keeping Play as the single normal launch action.
- Shows up to twelve recent compatible saves and can create timestamped local
  backups before continuing.
- Clearly identifies Mission Select as an advanced path that can bypass
  campaign state, inventory, and briefings.
- Detects an interrupted previous run and offers Safe Mode with an isolated
  configuration, no add-ons, no displacement pack, and windowed rendering.
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
  and BoA versions, ordering mistakes, invalid archives, and overlapping PK3
  paths.
- Treats identical ZScript source paths as blocking conflicts and prevents
  UZDoom from starting combinations that would fail during script compilation.
- Distributes the restored `z_boa_addon_README.txt` credits document referenced
  by Confiscated Weapons and ZikShadow's Personal Addon.
- Enforces `newCampaignRequired` before launch and records the selected
  add-on fingerprints beside newly created saves.
- Resolves declared `requires` and `loadAfter` relationships into a stable load
  order and provides pairwise official-add-on matrix validation.

## Multiplayer

- Provides single-player, host co-op, and join co-op modes.
- Host setup supports 2-4 players, episode/map selection, all five BoA
  difficulties, UDP port, and `sv_cheats`.
- Join setup supports host name or IPv4 address and port.
- Multiplayer validates only `uzdoom.exe` as UZDoom 4.14.3 or 5.x and
  `boa.ipk3`.
- All selected add-ons and `boa_dt.pk3` are excluded from multiplayer
  commands. The single-player add-on selection is retained for later use.
- UZDoom 4.14.3 receives its legacy language aliases (`enu`, `eng`, and
  `pt`); UZDoom 5.x receives IETF BCP 47 language tags and the explicit
  `-coop` option when hosting.
- Probes UZDoom 5 with `-help-all` once per executable hash and caches support
  for `-loadgame`, `-episode`, `-coop`, `-password`, `-optfile`, and
  `-config`, with version-based fallback for engines that cannot be probed.
- Imports and exports privacy-safe `.boa-session` files containing exact
  engine and `boa.ipk3` hashes, map, skill, port, and player settings. Lobby
  passwords are never written to disk.

## Support and recovery

- Creates a redacted ZIP support package containing versions, SHA-256 file
  identities, engine capabilities, command line, add-on order, compatibility
  findings, last-run data, and the latest available engine log.
- Removes passwords, host/IP information, usernames, and local game paths
  from exported diagnostics.
- Keeps runtime data in `launcher-data/` and user profiles in
  `launcher-profiles/` next to the portable launcher.
- Falls back to per-user or temporary runtime storage when the installation
  directory is read-only.
- Classifies recognized renderer, ZScript/add-on, savegame, missing-file, and
  fatal-engine signatures from the latest log and recommends a recovery path.
- Labels detected engines as Stable, Preview, or Unsupported; UZDoom preview
  builds remain usable but are clearly identified.

## Content manifest

The optional `boa-launcher.json` file in `boa.ipk3` is the authoritative,
versioned launcher contract for BoA version, minimum engine version, languages,
episodes, and missions. The launcher safely falls back to MAPINFO when the
manifest is absent.

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
uzdoom.exe
boa.ipk3
boa_dt.pk3
launcher-resource/
addons/
language/
```

The engine must retain its official `uzdoom.exe` filename. The legacy
`boa.exe` filename is no longer detected or launched.

The launcher reads the final `MAPINFO` directly from `boa.ipk3`; no extracted
copy is required.

## Tests

```powershell
.\Test-Core.ps1
.\Test-V25.ps1
.\Test-V26.ps1
.\Test-ModernGui.ps1
```

The core suite checks commands, language aliases, interface localization,
MAPINFO parsing, add-on isolation, numbered preview discovery, embedded
font resources, real archive overlaps, UZDoom 4.14.3/5.x command generation,
and graphics profiles. The GUI suite checks the accessibility tree, compact
layout, Quick Launch controls, navigation, language and player choices,
window-size persistence, add-on selection, and the wrapping 16:9 preview
carousel.
The v2.5 suite additionally checks save parsing, compatibility binding,
profiles, capability detection, session parity and password privacy, Safe
Mode isolation, automatic controller navigation, full animation defaults,
support-package redaction, strict `uzdoom.exe` selection, and v2.5
localization.
The v2.6 suite checks missing-config startup resilience, launch preflight,
versioned game manifests, dependency-aware add-on ordering, pairwise matrix
validation, and the SHA-256 release manifest.

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
--print-capabilities
--scan-saves
--print-save-roots
--check-save FILE
--save-profile NAME
--list-profiles
--validate-session FILE
--create-session FILE
--create-diagnostics ZIP
--preflight
--print-launcher-manifest
--generate-launcher-manifest FILE
--validate-addon-matrix
--resolve-addon-order
--analyze-last-crash
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
--password VALUE
--continue FILE
--safe-mode
--no-addons
--multi-addon FILE
```
