# Changelog

## 1.3.0

### Added

- Cooperative multiplayer modes for hosting and joining UZDoom/GZDoom games.
- Host controls for total player count, start map, UDP port, skill, and
  `sv_cheats`.
- Join controls for host name or IPv4 address and UDP port.
- Built-in launcher translations for all ten Blade of Agony game languages.
- Diagnostics for localized UI strings and multiplayer command generation.

### Changed

- The launcher UI now switches language immediately when the game language is
  changed.
- Localized addon metadata is reloaded for the selected game language.
- Existing `[Launcher co-op]` settings are migrated and persisted, including
  compatibility with the original `Enabled=1` host configuration.
- Launcher version increased to 1.3.0.

### Verified

- Confirmed original-style game language startup through
  `+set language <code>`.
- Verified host startup with `-host`, `-port`, `-skill`, `+set sv_cheats`, and
  `+map`.
- Verified join startup with `-join host:port`.
- Exercised host and join launches against a recording `boa.exe` test stub.
- Verified live German UI switching and the 16:9 addon preview viewport.

## 1.2.1

- Expanded addon previews to the full details-column width while preserving
  centered 16:9 cover cropping.

## 1.2.0

- Restricted descriptor discovery to `addons/*.boa`.
- Added Ctrl-based multiple addon selection to the main list.
- Added the exclusive `No addons` list entry.
- Added full-width 16:9 cover-cropped addon previews.

