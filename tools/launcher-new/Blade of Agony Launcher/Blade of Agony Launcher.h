#pragma once

#include "resource.h"

TCHAR SettingsFile[] = TEXT("./boa-launcher.ini");
TCHAR IWadName[] = TEXT("BOA_Chapter3.ipk3");
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

TCHAR DetailSettingsStrings[DETAIL_END][50] = {
	TEXT("Use Last Settings"),
	TEXT("Reset to Default Settings"),
	TEXT("Very Low Detail (fastest)"),
	TEXT("Low Detail (faster)"),
	TEXT("'Normal' Detail"),
	TEXT("High Detail (prettier)"),
	TEXT("Very High Detail (beautiful)"),
};

TCHAR CmdDetailString[DETAIL_END][50] = {
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

TCHAR DisplacementTexturesStrings[DIS_END][50] = {
	TEXT("Do not use displacement textures (faster)"),
	TEXT("Use displacement textures (beautiful)"),
};

TCHAR CmdDisplacementString[DIS_END][50] = {
	TEXT(""),
	TEXT("-file BOA_Displacement.pk3"),
};

struct LauncherSettings
{
	bool DontShow = false;
	int DisplacementTextures = DIS_YES;
	int Detail = DETAIL_UNCHANGED;
};

extern LauncherSettings settings;
