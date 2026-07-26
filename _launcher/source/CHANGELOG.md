# Changelog

## 1.6.0

### Added

- Added an independent interface-language selector to the launcher header.
- Added the persisted `InterfaceLanguage` INI setting.
- Added localized header labels for every supported interface language.
- Added backward-compatible migration: configurations without
  `InterfaceLanguage` initially inherit the existing game-language value.
- Added diagnostics and regression coverage for mixed game/interface language
  combinations.

### Changed

- Moved the design selector from the Game section to the launcher header.
- Kept the game-language selector in the Game section.
- Changing the game language now affects only the generated
  `+set language <code>` game argument.
- Changing the interface language now affects launcher controls and localized
  addon metadata without changing the selected game language.
- Extended the launcher window vertically to preserve the full content area
  beneath the new header toolbar.
- Launcher version increased to 1.6.0.

### Verified

- Verified a German launcher interface with Spanish game language in the live
  GUI and confirmed `+set language es` in the recorded launch command.
- Verified independent persistence as `InterfaceLanguage=de` and
  `Language=es`.
- Verified migration of legacy configurations containing only `Language`.
- Re-ran all themes, multiplayer modes, addon selections, command generation,
  INI preservation, and 16:9 preview tests.

## 1.5.0

### Added

- Added a keyboard-accessible segmented control for single-player, host
  co-op, and join co-op selection.
- Added progressive disclosure for multiplayer settings: single-player hides
  all network fields, host shows server settings, and join shows only the
  connection target and UDP port.
- Added localized inline validation for host start maps and join addresses.
- Added error-colored field borders and disabled the Play action while the
  currently required multiplayer input is invalid.
- Added built-in translations for the new section headings and validation
  messages in all ten supported launcher languages.

### Changed

- Reorganized settings into clear Graphics, Game, and Multiplayer sections.
- Increased the default window and settings-column size for improved
  readability without reducing the 16:9 addon preview.
- Updated the interface to Segoe UI 9 and removed the unnecessary frame
  around the bottom action area.
- Replaced font-dependent preview arrows with centered, custom-painted
  chevron buttons.
- Updated the live GUI test to verify all three multiplayer visibility states
  and to sample theme colors from actual control bounds.
- Launcher version increased to 1.5.0.

### Verified

- Verified single-player, host, and join progressive-disclosure states against
  the live launcher window.
- Verified defensive normalization of invalid map and host values.
- Re-ran host/join commands, all language aliases, all three themes, addon
  scanning and selection, INI preservation, and 16:9 cover-crop tests.

## 1.4.1

### Changed

- Replaced bright native field frames with subdued one-pixel theme borders.
- Replaced native dropdown buttons with flat theme-colored buttons and
  chevrons.
- Replaced native numeric steppers with compact theme-colored step controls.
- Replaced native checkboxes, multiplayer group borders, and addon-list frames
  with consistent custom-painted controls.
- Removed the permanently visible native description scrollbar.
- Reduced border contrast to `#525252` in Dark, `#355066` in Blade of Agony,
  and `#C8C8C8` in Light.
- Launcher version increased to 1.4.1.

### Verified

- Re-ran all three live theme color tests.
- Re-ran language switching, host/join command, addon multi-selection,
  no-addon selection, INI persistence, and 16:9 preview tests.

## 1.4.0

### Added

- Dark design as the new default, using `#3B3B3B` as its base color.
- Optional Light design.
- Optional Blade of Agony design using `#11273A` as its base and `#668197` as
  its accent color.
- Localized design names for every supported launcher language.
- Dark Windows title-bar integration on supported Windows versions.

### Changed

- Buttons, inputs, lists, disabled addon rows, preview details, multiplayer
  controls, and selection highlights now follow the active design.
- The selected design is persisted as `Theme=Dark`, `Theme=Light`, or
  `Theme=BladeOfAgony` in `boa-launcher.ini`.
- Launcher version increased to 1.4.0.

### Verified

- Measured the rendered background and accent colors directly from the live
  launcher window.
- Verified immediate switching between all three designs and INI persistence.
- Re-ran language, multiplayer, addon selection, and 16:9 preview regressions.

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
