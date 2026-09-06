# Launcher v2.6.10 Validation

Scope: visible startup loading animation. Game launch and multiplayer logic are
unchanged from v2.6.9.

## Checks

- Render four successive frames in each of four themes for normal loading, a
  disabled loading surface and a resized window. All 12 cases show more than
  20 pixels of visible segment movement, not merely an active animation clock.
- Verify accent/track pixel colors, bounded segment width, resizing and animation
  cleanup on unload. Inspect rendered before/after frames visually.
- WPF regression suite: campaign, save continuation, host/join, remembered role,
  duplicate-launch guard and responsive layouts.
- Core command/localization and release-integrity regression suites.
- Release ZIP and deployed files verified against their SHA-256 manifest.

## Limits

Rendering tests use isolated WPF fixtures and a recording engine. No new real
multiplayer session or physical controller test was performed. OS high-contrast
mode and multi-monitor DPI transitions were not toggled. Binaries remain unsigned.
