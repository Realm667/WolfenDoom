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
- Exercised the rebuilt multi-addon dialog through Windows UI messages.
- Confirmed that unrelated `boa-launcher.ini` sections and keys survive a
  GUI launch.
- Verified all ten `language.csv` language groups and canonicalized the
  aliases `pt`/`br`, `trk`, and `plk`.
