# Launcher v2.6.11 Validation

Scope: Chapter terminology in launcher-facing labels and content diagnostics.

- Verify Chapter in the campaign destination, chapter field and generated names.
- Verify localized chapter labels on campaign and multiplayer pages after shell
  rebuilds; check translations for all ten interface languages.
- Core content parsing, command generation and localization regressions.
- WPF campaign/save/multiplayer, role persistence, layout and loading regressions.
- Verify release manifest, packaged files and deployed files using SHA-256.

Engine `-episode`, MAPINFO `episode`, internal identifiers and serialized schema
keys remain unchanged for compatibility. Existing names supplied by the game are
preserved. Historical changelog entries retain their original wording.

Tests use isolated fixtures and a recording engine. No new real multiplayer
session, physical controller test or OS-level DPI/high-contrast transition was
performed for this terminology update. Binaries remain unsigned.
