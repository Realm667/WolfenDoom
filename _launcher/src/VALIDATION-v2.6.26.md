# 2.6.26 regression checks

- Live A/B in C1M1 using the standalone boa.ipk3 and UZDoom 5.0.3: with the option enabled, the player remained dead through 135 Use inputs passed to DeathThink. With the option disabled and no previous save, the same input restarted the map.

- Run Test-Optimizations.ps1 to check explicit campaign versus main-menu add-on warnings, persisted death policy, all five difficulty levels and isolation from Continue and co-op.
- Run Test-ReleaseUI.ps1 against the built launcher. Package with package.ps1 -SkipBuild to check SHA-256 hashes.
