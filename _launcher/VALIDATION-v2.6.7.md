# Launcher v2.6.7 Validation

Scope: campaign selection in Quick Launch. Engine command construction, save
loading and multiplayer protocol behavior are unchanged from v2.6.6.

## Checks

- Core command, profile, localization, save compatibility and release-integrity
  regression suites, plus v2.5, v2.6 and v2.6.5 regressions.
- Official UZDoom 5.0.1 capability probe and co-op save-preparation regressions.
- Actual WPF controls with a recording engine: Main menu launches without a map
  or save target; From the beginning starts the selected episode; explicit mission
  selection passes the selected map. Continue loads the save independently.
- Episode changes reset mission selection to From the beginning and launch the
  correct episode map. Exported/imported profiles restore explicit missions.
- Main menu disables campaign fields without hiding them. No footer Start Mode
  selector or campaign radio option remains. Multiplayer retains separate controls.
- Shell rebuilds preserve campaign choices across themes and interface languages.
  New mission labels are translated in all ten supported interface languages.
- Equal campaign pane dimensions and 24-DIP spacing on wide windows; vertical
  stacking at narrow widths and larger text sizes; cropped 16:9 save previews.
- WPF renders inspected for default, narrow, large-text and theme variations.
- Release ZIP and deployed files verified against their SHA-256 manifest.

## Limits

Launch-argument tests use a recording engine and an isolated two-episode fixture.
Save-preview artwork is a fixture, not evidence of a full campaign playthrough.
The external UI Automation script was updated but not executed for this release.
No new real multiplayer session, physical controller test or multi-monitor DPI
transition was performed for this UI-only update. Prior engine runtime checks
and their limits are documented in v2.6.5. Binaries remain unsigned.
