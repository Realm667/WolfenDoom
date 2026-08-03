# Changelog

## 2.2.1

### Changed

- Renamed the primary bottom-right action button from Launch to Play in the
  English interface.
- Launcher version increased to 2.2.1.

### Verified

- Added automated core and WPF accessibility checks for the Play label.
- Re-ran command generation, localization, content parsing, add-on,
  multiplayer, responsive-layout, and window-persistence tests.

## 2.2.0

### Added

- Added UZDoom 5.x compatibility while retaining support for the bundled
  UZDoom 4.14.3 release.
- Added separate English (US) and English (UK) game-language choices.
- Added persistence for the user-adjusted launcher window size.

### Changed

- Limited hosted Blade of Agony sessions to the supported range of 2-4
  players.
- Renamed the sidebar Start entry to Quick Launch.
- Changed the Portuguese game-language option to Portuguese (European).
- UZDoom 5.x commands now use IETF BCP 47 language tags and the explicit
  `-coop` hosting option; UZDoom 4.14.3 keeps its legacy language aliases.
- Engine compatibility checks now accept UZDoom 4.14.3 and all UZDoom 5.x
  releases.
- Launcher version increased to 2.2.0.

### Verified

- Added automated UZDoom 5 command and compatibility tests using a synthetic
  5.0 engine fixture.
- Verified the 2-4 player limit, language choices, Quick Launch label, and
  window-size save/restore behavior through the WPF accessibility tree.
- Re-ran command generation, localization, content parsing, add-on
  compatibility, responsive-layout, multiplayer, and graphics profile tests.

## 2.1.1

### Changed

- Changed the Light theme accent color to `#668197`.
- Applied Unica One to the Quick Launch, Add-ons, Multiplayer, and
  Diagnostics page headlines.
- Expanded the direct campaign footer status with the selected difficulty
  and full game-language name.
- Centered icon-button glyphs without inherited text-button padding.
- Launcher version increased to 2.1.1.

### Fixed

- Accent-colored buttons and selected navigation entries now use white text
  and icons in the Light theme.
- Fixed clipped previous/next glyphs in the multi-image add-on slider.

### Verified

- Verified the exact Light theme accent and accent-text colors.
- Verified all four page headline font resources, localized direct-start
  details, slider wrapping, 16:9 preview bounds, and unclipped arrow buttons.
- Re-ran command generation, localization, content parsing, compatibility,
  responsive-layout, multiplayer, and graphics profile tests.

## 2.1.0

### Added

- Added a previous/next screenshot carousel for add-ons containing multiple
  numbered preview images.
- Added a visible image counter and cyclic navigation in both directions.
- Bundled Unica One directly with the launcher and applied it to the Blade of
  Agony header title and sidebar navigation.
- Included the Unica One SIL Open Font License in the executable resources
  and release distribution.

### Changed

- Add-on preview discovery now reads the numbered JPG, JPEG, and PNG files
  actually present in each `.boa` archive and sorts them numerically.
- Launcher version increased to 2.1.0.

### Fixed

- Restored a consistent 36-pixel control height for Start page combo boxes
  whose WPF height was previously unset (`NaN`).

### Verified

- Tested four-image and three-image add-on descriptors from the current
  Blade of Agony standalone files.
- Verified carousel navigation, wrapping, counter updates, Unica One loading,
  Start control heights, accessibility IDs, and the 16:9 preview bounds.
- Re-ran command generation, localization, content parsing, compatibility,
  responsive-layout, multiplayer, and graphics profile tests.

## 2.0.2

### Changed

- Replaced raw Detail Preset CFG listings with concise explanations of their
  visual-quality and performance differences.
- Vertically centered all combo-box content, including the Interface
  Language and Design selectors in the header.
- Applied explicit high-quality bitmap scaling to the header logo.
- Reused the centered launcher checkbox template for add-on rows.
- Disabled add-on order buttons whenever the active item cannot move in that
  direction.
- Launcher version increased to 2.0.2.

### Fixed

- Disabled combo boxes now render their selected text with a muted foreground
  instead of appearing active.
- Fixed vertically misaligned add-on checkboxes and titles.
- Preserved the active add-on while rebuilding the list so repeated Move Up
  and Move Down commands operate on the intended entry.

### Verified

- Verified Move Up and Move Down with two enabled add-ons by checking their
  resulting UI positions.
- Re-ran command generation, content parsing, compatibility, accessibility,
  responsive-layout, multiplayer, and 16:9 add-on preview tests.

## 2.0.1

### Added

- Added exact, profile-specific graphics values to the Detail Preset
  tooltips, read from the distributed CFG files.
- Added an accessible Blade of Agony logo and live UZDoom version read from
  the `boa.exe` product metadata in the launcher directory.

### Changed

- Replaced the previous header thumbnail with the official Blade of Agony
  logo and changed the title casing to `Blade of Agony`.
- Left-aligned all sidebar navigation entries.
- Sorted campaign missions by chapter, mission number, and map part, with
  introduction maps first and optional `M0` missions last.
- Vertically centered the custom checkbox indicators and labels.
- Reduced the add-on author line size to leave more room for descriptions.
- Removed the redundant Exit button from the footer.
- Launcher version increased to 2.0.1.

### Verified

- Verified the mission order against the current `wolfendoom.git` MAPINFO.
- Verified the displayed engine version against the bundled `boa.exe`.
- Re-ran command generation, content parsing, compatibility, accessibility,
  responsive-layout, multiplayer, and 16:9 add-on preview tests.

## 2.0.0

### Added

- Rebuilt the launcher interface in WPF with responsive layout, per-monitor
  DPI awareness, animation, text scaling, high-contrast support, accessible
  automation names, and full keyboard navigation.
- Added flat navigation for Start, Add-ons, Multiplayer, and Diagnostics.
- Added a persistent launch summary and status area.
- Added runtime parsing of episodes, campaign maps, and all five skills from
  the final `boa.ipk3` `MAPINFO`.
- Added localized map, episode, and skill names from `language.csv`.
- Added main-menu and direct campaign-start modes.
- Added visible add-on checkboxes, selection count, deterministic load-order
  controls, and inline compatibility reporting.
- Added optional descriptor metadata for IDs, versions, dependencies,
  conflicts, load ordering, minimum versions, multiplayer safety, campaign
  restart requirements, and categories.
- Added detection of missing payloads, invalid archives, engine-version
  requirements, and overlapping PK3 paths.
- Added a dedicated diagnostics view for the engine, main game, content
  source, add-ons, and generated command.
- Added command-line content, multiplayer, and add-on diagnostics.

### Changed

- Changed branded themes to use their colors for navigation and emphasis
  while keeping content surfaces neutral and readable.
- Changed the add-on description and compatibility area to a scrollable
  region with an always-visible, cover-cropped 16:9 preview.
- Changed multiplayer to load only UZDoom 4.14.3 and `boa.ipk3`; selected
  add-ons and `boa_dt.pk3` are now excluded from host and join commands.
- Changed campaign and co-op map selection from free text to data read from
  the current Blade of Agony content.
- Kept interface and game languages fully independent after the WPF rewrite.
- Launcher version increased to 2.0.0.

### Fixed

- Forced `boa_steamswitch 1` after every detail profile to preserve current
  Blade of Agony steam-spawner behavior.
- Removed duplicate `boa_grasslod` assignments from the distributed detail
  profiles.
- Prevented a persisted multiplayer state from affecting launches initiated
  from the Start or Add-ons areas.

### Verified

- Tested against `wolfendoom.git` commit `cc83160d7`.
- Parsed 3 episodes, 33 campaign maps, and 5 skills from both the development
  tree and the final `boa.ipk3`.
- Verified the bundled engine as UZDoom 4.14.3.
- Verified that multiplayer commands contain no add-on or displacement PK3.
- Detected real overlapping files between the existing music add-ons.
- Verified the live accessibility tree, compact layout, and a 311x175 16:9
  add-on preview.

## 1.7.0

### Added

- Added the Wolfenstein 3D design using `#860000` as its background and
  `#857E7E` as its accent color.
- Added full-value tooltips to both Graphics dropdowns.
- Added automatically widened Graphics dropdown lists so long options remain
  readable while choosing.
- Added a read-only RichEdit addon description with a vertical scrollbar for
  overflowing text.
- Added `wolfenstein3d`, `wolfenstein-3d`, and `wolf3d` theme aliases.

### Changed

- Changed the default design from Dark to Blade of Agony.
- Changed the interface-language default to English, independently of the
  selected or legacy game language.
- Extended theme diagnostics and live color tests to all four designs.
- Launcher version increased to 1.7.0.

### Verified

- Measured the live Wolfenstein 3D background as `#860000` and accent as
  `#857E7E`.
- Verified Blade of Agony and English as defaults for configurations without
  their respective settings.
- Verified that the addon description is hosted in a scrollable RichEdit
  control.
- Re-ran independent language, multiplayer, addon selection, command, INI,
  theme, and 16:9 preview tests.

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
