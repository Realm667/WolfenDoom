# Launcher v2.6.12 Validation

Scope: program-wide UZDoom 5.0.1 minimum.

Result: core, v2.5, v2.6, v2.6.5, optimization/WPF and official legacy-engine
rejection suites passed. The multiplayer render was also visually inspected.

- Version boundaries: reject older releases, unknown versions and 5.0.1
  prereleases; accept 5.0.1 and numerically newer versions, including future majors.
- Check preflight, multiplayer status, release channel and process-start guards
  for single player, host, join, save continuation and Safe Mode.
- Verify older manifests cannot lower the minimum; generated manifests use 5.0.1.
- Run core, v2.5, v2.6, v2.6.5 and WPF optimization regression suites.
- Check rejection of the official UZDoom 4.14.3 binary and capability detection
  using the official UZDoom 5.0.1 binary.
- Verify packaged and deployed release files against their SHA-256 manifest.

Launch regression tests use a recording engine. No new real multiplayer session,
full campaign playthrough or physical controller test is included in this update.
Acceptance of future version numbers is not a runtime certification of unreleased
engines; optional features still depend on capability detection. Binaries are unsigned.
