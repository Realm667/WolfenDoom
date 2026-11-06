# Launcher 2.6.15 validation

Tested on Windows with the official UZDoom 5.0.1 binary (2026-09-05 build),
current BoA master 2994fadd1 plus the issue fixes, isolated configurations,
no user autoexec/autoload files, and no add-ons.

## Language selection — #1730

- 60 focused C# assertions passed: persistence and single-player/host/join
  command generation for all 11 explicit languages plus Auto and Use last
  settings, automatic preview cultures, retained preview, interface-language
  independence and legacy UK/Portuguese aliases.
- Real 5.0.1 runs consumed the rebuilt launcher's emitted language arguments.
  English US, English UK, European Portuguese and Auto were recognized in
  both full and simplified BoA menu descriptors. Use last settings retained
  seeded French and legacy `eng` configurations without a language override.
- Before-fix control reproduced selection -1 / Unknown for `en-US` in both
  menus. Patched runs resolved the expected entries and screenshots confirmed
  the English flags. Portuguese and other existing flag assets are preserved.
- BoA's menu accepts the existing default/enu/en, eng and ptg/pt aliases
  without rewriting the saved CVAR. New menu selections use modern codes.

## Launcher layout — #1728, layout request only

WPF regression tests assert that Displacement textures is the immediate next
sibling of Developer commentary. Desktop, narrow, large-text and theme render
checks passed. No Keen mission shortcut was added.

## Regression coverage

Core, v2.5, v2.6 and WPF optimization/campaign tests passed. The v2.5 fixture
assertion was narrowed to its own save00 record because discovery also found
an existing unrelated co-op test save; foreign-IWAD exclusion remains tested.
These checks do not establish full campaign or LAN/WAN multiplayer coverage.

Engine rendering tests used OpenGL on an RTX 4080 / NVIDIA 621.01. Vulkan,
other operating systems and physical controller interaction were not tested.
