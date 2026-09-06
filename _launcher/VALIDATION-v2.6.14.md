# Launcher v2.6.14 Validation

Scope: remove the standalone Diagnostics executable from builds and releases.

Result: core, v2.5, v2.6, WPF optimization, official UZDoom 5.0.1 and
legacy-engine rejection suites passed without the separate Diagnostics EXE.

- Build and package contain only the normal Launcher executable.
- Core, v2.5 and v2.6 diagnostic suites target the normal GUI executable with
  explicit output redirection and exit-code handling.
- WPF tests retain the in-app Diagnostics page and campaign/multiplayer flows.
- Official UZDoom 5.0.1 detection and older-engine rejection remain covered.
- Verify release manifest, ZIP contents and deployed files with SHA-256.

Historical versioned packages are preserved. No gameplay behavior was changed;
no new real multiplayer session or physical-controller test was performed.
Binaries remain unsigned.
