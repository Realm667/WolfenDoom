# Launcher 2.6.16 validation

Tested on Windows with official UZDoom 5.0.1 (2026-09-05 build), BoA
master 5f58f250b plus the current fixes, isolated configuration/save paths,
and no personal autoexec or autoload files.

## Archive metadata and add-ons — #1710

- 21 targeted C# assertions passed: root and GitHub-style wrapped archives,
  mixed-case directory names, MAPINFO/language/manifest resolution, add-on
  acceptance, rejection of old versions, explicit missing-version errors,
  duplicate metadata, nested decoys, multiple roots and reserved folders.
- The unchanged prior launcher reproduces missing metadata for a wrapped
  archive, converting an unknown legacy game version into 0.0. Version
  requirements are retained; the fix is in metadata lookup, not add-ons.
- Two playable archives containing identical game resources were tested:
  normal root layout and WolfenDoom-master/ wrapper. Both passed launcher
  add-on compatibility checks and launched Instagib using launcher-generated
  arguments. UZDoom 5.0.1 loaded its event handler and the test confirmed
  InstagibDamage in the player's inventory in both cases.
- The reporter's exact archive was unavailable. This verifies the reproduced
  wrapper-layout failure, not every possible damaged/unofficial package.

## Regression coverage

Core, v2.5, v2.6 and WPF optimization/campaign regression suites passed,
including save discovery, dependency/load-order checks, configuration/cache
handling, language argument generation, responsive layout and engine floor.
The release's SHA-256 manifest is checked after its final build.

Engine tests used OpenGL on NVIDIA RTX 4080 / driver 621.01. This is not
full campaign, LAN/WAN, physical-controller, Vulkan or other-OS coverage.
