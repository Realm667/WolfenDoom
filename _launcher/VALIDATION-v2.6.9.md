# Launcher v2.6.9 Validation

Scope: themed startup feedback and multiplayer role selection.

## Checks

- WPF startup indicator rendered for all four themes. Pixel samples stay within
  the theme accent/track colors; indicator is nonblank and animated; animation
  clocks are stopped when the loading control is unloaded.
- Actual startup control uses the configured theme accent.
- Multiplayer page has no Single player radio option and defaults to Host.
  Join selection survives campaign navigation and normal settings persistence.
- Page changes retain imported session rules/password requirements. Campaign
  navigation restores single-player behavior without losing the remembered role.
- Recording-engine tests cover host/join, campaign destinations, save continuation,
  hidden-button guards and duplicate-launch prevention.
- Core, v2.5, v2.6, v2.6.5 and WPF regression suites.
- Official UZDoom 5.0.1 capability and co-op save-preparation checks.
- Release ZIP and deployed binaries checked against their SHA-256 manifest.

## Limits

WPF tests use isolated fixtures and a recording engine. No new real multiplayer
playthrough, physical controller or multi-monitor DPI transition was tested.
The high-contrast palette remains supported but was not toggled at OS level.
The external UI Automation script was updated but not executed. Prior real-engine
runtime checks are documented in v2.6.5. Binaries remain unsigned.
