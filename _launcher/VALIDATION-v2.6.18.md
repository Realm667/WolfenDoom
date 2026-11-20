# Launcher v2.6.18 validation

Tested on Windows with the WPF regression suite, Core, V25 and V26 checks.

- Isolated engine fixture recorded actual arguments for main menu, chapter, mission,
  Continue, host, join and recovery. A locked main game blocked recovery, produced
  a localized reason and preserved its marker. A successful retry did not change
  the subsequent normal launch. Safe Mode ignored an alternate multi-add-on IWAD.
- Damaged embedded PNG: Continue remained enabled and the preview collapsed.
- Verified preset derivation after manual changes, contextual action labels,
  compact no-save order, four themes, keyboard/controller navigation and DPI layout.
- Startup benchmark (#1711): three alternating fresh processes per version,
  same local fixture with UZDoom 5.0.3, 1,112,651,832-byte boa.ipk3, 15 official
  descriptors and 20 synthetic saves, existing filesystem and launcher caches.
  Process start to first enabled campaign action via UI Automation (milliseconds):

| Version | Samples | Median |
| --- | --- | ---: |
| 2.6.14 | 1212, 1117, 1156 | 1156 |
| 2.6.17 | 1157, 1129, 1135 | 1135 |
| 2.6.18 | 1079, 971, 1069 | 1069 |

These are local interactive-start measurements, not time to complete the save scan.
The reported 25-second delay was not reproduced. No claim is made about cold
disks or the reporter's PC. Use Measure-Startup.ps1 with an isolated game folder
to compare executables on an affected system.
