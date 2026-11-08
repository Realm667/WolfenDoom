# Launcher v2.6.17 validation

Minimum raised to UZDoom 5.0.3 on 2026-11-06.

- Build completed successfully.
- Test-Optimizations.ps1: version boundaries, launch preflight, multiplayer,
  save/safe-mode guards and old manifests passed; stable 5.0.3 is accepted,
  5.0.1, 5.0.2 and 5.0.3 prereleases are rejected. Existing UI/cache tests passed.
- Test-Core.ps1, Test-V25.ps1 and Test-V26.ps1 passed, including command generation,
  session parity, save filtering, metadata and release SHA-256 checks.
- An older installed standalone engine is now correctly rejected by Test-Core;
  the test no longer assumes any existing uzdoom.exe is supported.
- Historical 5.0.1 validation records remain historical. The official 5.0.3
  runtime was exercised separately with a fresh BoA archive and isolated
  two-process multiplayer effects probes; these are not a campaign/WAN audit.

No public release, commit or push was performed by this task.
