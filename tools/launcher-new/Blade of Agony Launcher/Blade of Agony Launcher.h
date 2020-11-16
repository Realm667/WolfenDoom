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
	TEXT("+boa_default"),
	TEXT("+boa_verylow"),
	TEXT("+boa_low"),
	TEXT("+boa_normal"),
	TEXT("+boa_high"),
	TEXT("+boa_veryhigh"),
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
	LANGUAGE_MAX = 9
};

TCHAR LanguagesList[][50] = {
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
	TEXT("+language en"), // en
	TEXT("+language de"), // de
	TEXT("+language es"), // es
	TEXT("+language ru"), // ru
	TEXT("+language pt"), // pt
	TEXT("+language it"), // it
	TEXT("+language trk"), // trk
	TEXT("+language fr"), // fr
	TEXT("+language cs"), // cs
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

TCHAR TexFilterSettingsCmd[][120] = {
	TEXT(""),
	TEXT("+gl_texture_filter 0 +gl_texture_filter_anisotropic 0 +gl_texture_hqresizemode 6 +gl_texture_hqresizemult 1"),
	TEXT("+gl_texture_filter 4 +gl_texture_filter_anisotropic 8 +gl_texture_hqresizemode 6 +gl_texture_hqresizemult 1"),
	TEXT("+gl_texture_filter 4 +gl_texture_filter_anisotropic 16 +gl_texture_hqresizemode 6 +gl_texture_hqresizemult 2"),
};

struct LauncherSettings
{
	bool DontShow = false;
	int DisplacementTextures = DIS_YES;
	int Detail = DETAIL_UNCHANGED;
	bool DevCommentary = false;
	int Language = 0;
	int TexFilter = TEXFILT_UNCHANGED;
};

extern LauncherSettings settings;

