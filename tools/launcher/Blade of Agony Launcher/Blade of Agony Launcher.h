#pragma once

#include "resource.h"

TCHAR SettingsFile[] = TEXT("./boa-launcher.ini");
TCHAR IWadName[] = TEXT("boa.ipk3");
TCHAR SourcePortName[] = TEXT("gzdoom.exe");

enum DetailSettings
{
	DETAIL_UNCHANGED,
	DETAIL_DEFAULT,
	DETAIL_VERYLOW,
	DETAIL_LOW,
	DETAIL_NORMAL,
	DETAIL_HIGH,
	DETAIL_VERYHIGH,
	DETAIL_END
};

TCHAR DetailSettingsStrings[][50] = {
	TEXT("Use Last Settings"),
	TEXT("Reset to Default Settings"),
	TEXT("Very Low Detail (fastest)"),
	TEXT("Low Detail (faster)"),
	TEXT("Normal Detail"),
	TEXT("High Detail (prettier)"),
	TEXT("Very High Detail (beautiful)"),
};

TCHAR DetailSettingsCmd[][50] = {
	TEXT(""),
	TEXT("+exec launcher-resource/detail-default.cfg"),
	TEXT("+exec launcher-resource/detail-verylow.cfg"),
	TEXT("+exec launcher-resource/detail-low.cfg"),
	TEXT("+exec launcher-resource/detail-normal.cfg"),
	TEXT("+exec launcher-resource/detail-high.cfg"),
	TEXT("+exec launcher-resource/detail-veryhigh.cfg"),
};

enum LoadDisplacementTextures
{
	DIS_NO,
	DIS_YES,
	DIS_END
};

TCHAR DisplacementTexturesStrings[][50] = {
	TEXT("Do not use displacement textures (faster)"),
	TEXT("Use displacement textures (beautiful)"),
};

TCHAR DisplacementTexturesCmd[][50] = {
	TEXT(""),
	TEXT("-file boa_dt.pk3"),
};

enum UseDeveloperCommentary
{
	DEVC_NO,
	DEVC_YES,
	DEVC_END
};

TCHAR DeveloperCommentaryCmd[][50] = {
	TEXT("+set boa_devcomswitch 0"),
	TEXT("+set boa_devcomswitch 1")
};

enum Languages
{
	LANGUAGE_UNCHANGED = 0,
	LANGUAGE_MAX = 10
};

TCHAR LanguagesList[][50] = {
	TEXT("Use last setting"), // unchanged
	TEXT("English"), // en
	TEXT("German"), // de
	TEXT("Spanish"), // es
	TEXT("Russian"), // ru
	TEXT("Portugese"), // pt
	TEXT("Italian"), // it
	TEXT("Turkish"), // trk
	TEXT("French"), // fr
	TEXT("Czech"), // cs
};

TCHAR LanguagesCmd[][50] = {
	TEXT(""), //unchanged
	TEXT("+set language en"), // en
	TEXT("+set language de"), // de
	TEXT("+set language es"), // es
	TEXT("+set language ru"), // ru
	TEXT("+set language pt"), // pt
	TEXT("+set language it"), // it
	TEXT("+set language trk"), // trk
	TEXT("+set language fr"), // fr
	TEXT("+set language cs"), // cs
};

enum TexFilterSettings
{
	TEXFILT_UNCHANGED,
	TEXFILT_NONE,
	TEXFILT_TRILINEAR,
	TEXFILT_TRILINEARNNX,
	TEXFILT_END
};

TCHAR TexFilterSettingsStrings[][50] = {
	TEXT("Use Last Settings"),
	TEXT("No Texture Filtering (recommended)"),
	TEXT("Trilinear"),
	TEXT("Trilinear (with Normal2x)"),
};

TCHAR TexFilterSettingsCmd[][50] = {
	TEXT(""),
	TEXT("+exec launcher-resource/texfilt-none.cfg"),
	TEXT("+exec launcher-resource/texfilt-tri.cfg"),
	TEXT("+exec launcher-resource/texfilt-nnx.cfg"),
};

struct LauncherSettings
{
	bool DontShow = false;
	int DisplacementTextures = DIS_YES;
	int Detail = DETAIL_UNCHANGED;
	bool DevCommentary = false;
	int Language = LANGUAGE_UNCHANGED;
	int TexFilter = TEXFILT_UNCHANGED;
};

extern LauncherSettings settings;

// this enables the prettier (i.e. not Windows 95-like) theming for the dialog box window

#pragma comment(linker,"/manifestdependency:\"" \
    "type='win32' " \
    "name='Microsoft.Windows.Common-Controls' " \
    "version='6.0.0.0' " \
    "processorArchitecture='*' "  \
    "publicKeyToken='6595b64144ccf1df' " \
    "language='*'\"")
