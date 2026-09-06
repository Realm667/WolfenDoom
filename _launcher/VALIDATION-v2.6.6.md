# Launcher v2.6.6 Validation

Scope: Quick Launch layout and action hierarchy. Engine argument construction and
multiplayer behavior are unchanged from v2.6.5.

## Checks

- Core command, profile, localization, save compatibility and release-integrity
  regression suites.
- v2.6.5 password, engine capability, session and co-op save-preparation regressions
  against the official UZDoom 5.0.1 executable.
- Real WPF component tests with a recording engine: Continue passes the selected
  save filename; normal Play opens the main menu; the campaign radio option updates
  the footer and Play starts the campaign without loading a save.
- Equal pane widths/heights, aligned tops and 24-DIP column spacing on wide windows.
- Vertically stacked, non-overlapping panes at 760-DIP width and with larger text.
- Save preview aspect ratio remains 16:9; unavailable previews collapse cleanly.
- Start Mode belongs to the footer, game language to shared settings, and mission
  selection is shown only in advanced mode. Multiplayer hides the single-player
  footer selector. Empty-save handling leaves no stale Continue action.
- Controller Accept expands/collapses the profile accordion through the WPF handler.
- Rendered WPF screenshots inspected at normal, narrow and large-text sizes and
  across the existing themes. New campaign labels have translations in all ten
  supported interface languages.
- Release ZIP and deployed files checked against their SHA-256 manifest.

## Limits

Screenshots use an isolated fixture and bundled artwork as a save-preview fixture.
No physical controller, multi-monitor DPI transition, full campaign playthrough or
separate-machine multiplayer test was performed for this UI-only update.
The prior engine runtime checks and their limits are documented in v2.6.5.
Binaries remain unsigned because no signing certificate was supplied.
