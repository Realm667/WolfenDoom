#pragma once

#include "resource.h"

TCHAR SettingsFile[] = TEXT("./boa-launcher.ini");
TCHAR IWadName[] = TEXT("BOA_Chapter3.ipk3");
TCHAR SourcePortName[] = TEXT("gzdoom.exe");

enum DetailSettings
{
	DETAIL_UNCHANGED,
	DETAIL_LOW,
	DETAIL_MEDIUM,
	DETAIL_HIGH,
	DETAIL_END
};

TCHAR DetailSettingsStrings[DETAIL_END][50] = {
	TEXT("Use Last Settings"),
	TEXT("Low Detail (faster)"),
	TEXT("Moderate Detail"),
	TEXT("High Detail"),
};

TCHAR CmdDetailString[DETAIL_END][50] = {
	TEXT(""),
	TEXT("+lowdetail"),
	TEXT("+mediumdetail"),
	TEXT("+highdetail"),
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
