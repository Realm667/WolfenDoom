# Reverse-engineering notes

## Original binary

- File: `Blade of Agony - Launcher.exe`
- SHA-256: `934102F55B85ACA3465CAD2F1DBAE0139BCEB04828B5000D046863D0DE048831`
- Size: 3,350,528 bytes
- Format: native 64-bit PE32+ Windows executable
- Toolchain marker: `FPC 3.2.0-r45643 [2020/09/01] for x86_64 - Win64`
- UI framework: Lazarus LCL 2.0.10
- Managed/.NET metadata: none
- Packing/protection: no evidence of a packer or obfuscator
- Signature: unsigned

No `.pas`, `.lpr`, `.lpi`, or `.lfm` source files were present below the
project tree. The executable's `FORM1` and `FORM2` resources, launcher image,
icon, manifest, localized gettext catalogs, and runtime behavior were
therefore used to define a clean-room compatibility target.

## Interface design references

The 1.5 interface refresh uses the following current product and platform
guidance:

- Linear's design refresh informed the quieter visual hierarchy, restrained
  borders, and the principle that structure should be perceived without every
  section requiring a visible container.
- Raycast informed the compact, fast, keyboard-accessible multiplayer mode
  selector.
- Microsoft Fluent progressive-disclosure guidance informed hiding settings
  that are irrelevant to the selected network mode.
- Microsoft dialog guidance informed showing validation errors beside the
  affected input instead of interrupting the user with a modal dialog.

## Observed command behavior

Base invocation:

```text
boa.exe -iwad boa.ipk3 +set boa_devcomswitch 0
```

Argument order:

```text
-iwad IWAD
[-file single-addon.boa]
[-file ordered/multi1.pk3 ordered/multi2.pk3]
[-file boa_dt.pk3]
[+exec launcher-resource/detail-*.cfg]
+set boa_devcomswitch 0|1
[+set language CODE]
[-host PLAYERS -port PORT -skill SKILL +set sv_cheats 0|1 +map MAP]
[-join HOST:PORT]
```

Single-addon mode passes the selected `.boa` descriptor itself. Multi-addon
mode instead resolves every descriptor's `LOAD` entry and emits one ordered
`-file` group. This difference was verified with a harmless replacement
`boa.exe` that records its arguments.

## Descriptor format

`.boa` files are ZIP archives containing:

- `addoninfo.txt` with localized `key = value` metadata
- `gameinfo.txt` with quoted `IWAD` and one or more `LOAD` entries
- optional `preview/icon.png`
- optional `preview/1.jpg`, `preview/2.jpg`, and so on

The rebuild reads entries without extracting them and rejects rooted paths,
empty paths, `.` segments, and `..` traversal segments.

## Verification

- Parsed all 15 descriptors in the supplied standalone directory.
- Matched the original base, detail, displacement, commentary, and language
  command combinations.
- Matched original single-addon behavior.
- Matched original ordered multi-addon behavior.
- Exercised the rebuilt GUI against a recording `boa.exe` stub.
- Exercised Ctrl-style multi-selection in the rebuilt main addon list through
  Windows UI messages.
- Confirmed that only `addons/*.boa` is scanned and root descriptors are
  ignored.
- Confirmed that `No addons` removes all addon arguments and persists the
  disabled state.
- Verified the 16:9 preview bounds and centered cover-crop geometry for wide
  and tall source images.
- Confirmed that unrelated `boa-launcher.ini` sections and keys survive a
  GUI launch.
- Verified all ten `language.csv` language groups and canonicalized the
  aliases `pt`/`br`, `trk`, and `plk`.
- Confirmed through the GZDoom source that the host count includes the host,
  UDP port 5029 is the engine default, `-port` selects the host port, and join
  targets accept `host:port`.
- Confirmed through the GZDoom startup source that `-skill` selects the skill
  and `+map` accepts named maps such as Blade of Agony's `C1M1`.
- Verified host and join command matrices with the diagnostics executable and
  exercised an actual host launch against the recording `boa.exe` stub.
- Changed the game language through the live WinForms selector and confirmed
  that launcher labels, addon metadata, persisted language, and the generated
  `+set language` argument all changed together.
- Verified Dark as the default for configurations without a `Theme` key.
- Measured the live GUI backgrounds for Dark (`#3B3B3B`), Light (`#F0F0F0`),
  and Blade of Agony (`#11273A`) as well as the Blade of Agony accent
  (`#668197`).
- Confirmed that theme selection persists and that dark title-bar styling
  follows both dark designs on supported Windows versions.
- Replaced high-contrast native field chrome with custom-painted one-pixel
  borders and theme-aware chevrons, steppers, checkboxes, group boxes, and
  list frames.
- Verified that the replacement numeric controls preserve loaded and saved
  multiplayer player-count, port, and skill values.
- Verified the live single-player, host, and join layouts and confirmed that
  only the controls relevant to each mode remain visible.
- Verified localized inline validation and defensive normalization for invalid
  multiplayer map and host input.
- Separated the persisted game and interface language states. A live German
  interface with Spanish selected for the game retained German controls while
  launching with `+set language es`.
- Verified that localized addon metadata follows the interface language and
  that legacy INIs without `InterfaceLanguage` inherit their existing
  `Language` value once.
