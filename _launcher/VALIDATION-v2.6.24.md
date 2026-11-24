# HQ mission debug room (#1697)

Verified in the original INTERMAP on UZDoom 5.0.3 using the launcher's generated
single-player commands and automated menu/use input:

- Debug off: player movement stopped at linedef 6082. Debug on: the same route
  entered sector 1431. Exterior switch 6080 kept special 0 in both runs.
- Chose Chapter 1 / C1M2 at the selector. After HQ reloaded, Miller presented
  the Exodus briefing and projector slides. Using Dirty Douglas after the briefing
  loaded C1M2 with the player alive. No direct mission warp was used.
- Loaded an in-room debug save without the debug argument: the selector was
  inactive, the player could leave, and the entrance then blocked re-entry.
- The generated multiplayer host and safe-mode commands omit the HQ debug option.
