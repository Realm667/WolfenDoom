# Launcher v2.6.8 Validation

Scope: removal of launch profiles and contextual campaign/multiplayer actions.

## Checks

- Core, v2.5, v2.6, v2.6.5 and WPF optimization regression suites.
- Recording-engine WPF tests for main menu, both episode beginnings, explicit
  mission selection, direct save continuation, host and join launch arguments.
- Multiplayer action disabled for Single player; no launch controls on unrelated
  pages; no footer Play button or launch-profile interface remains.
- Repeated multiplayer launch events start only one recording-engine process.
- Existing campaign settings survive normal persistence and shell rebuilds.
  Legacy profile configuration keys no longer inject a custom engine config.
- Profile commands and profile output removed from diagnostic help/UI output.
- Official UZDoom 5.0.1 capability and co-op save-preparation regressions.
- Equal campaign pane dimensions, 24-DIP column gap, bottom-aligned campaign
  action, narrow/large-text stacking and 16:9 save preview geometry.
- WPF renders inspected for campaign and multiplayer layouts. Both new action
  labels translated in all ten supported interface languages.
- Release binaries and ZIP verified against the SHA-256 release manifest.

## Limits

Launch-button tests use a recording engine, not a new multiplayer playthrough.
WPF rendering uses an isolated two-episode fixture and bundled preview artwork.
The external UI Automation script was updated but not executed for this release.
No physical controller, multi-monitor DPI transition, separate-machine multiplayer
or full campaign regression was performed. Prior real-engine runtime checks and
their limits are documented in v2.6.5. Binaries remain unsigned.
