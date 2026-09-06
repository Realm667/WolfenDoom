# Launcher v2.6.13 Validation

Scope: #1696, rename the navigation entry and page heading to localized Start.

Passed: build, core, v2.5, v2.6 and WPF optimization regression suites.
The WPF suite asserts that both Nav_start and HeadingQuickLaunch read Start.
The rendered Start page was visually inspected. Layout, launch arguments,
independent Continue/New Campaign actions and multiplayer navigation passed.

Both labels reuse the existing localized Start key; stable automation IDs and
all process-start logic remain unchanged. UZDoom 5.0.1 remains the minimum.

Binaries are unsigned. Launch-argument regression tests use a recording engine;
this label-only release does not claim a new full campaign or multiplayer test.
