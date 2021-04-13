class VolumetricLight_ConeDown : VolumetricBase
{
	Default
	{
	//$Title Volumetric Light, Downward (PLACE IT 256MP MINIMUM)
	}
	States
	{
	Spawn:
	Active:
		VOLT A 1 NODELAY A_SpawnItemEx("AlertLight", 0, 0, -112, 0, 0, 0, 0, SXF_SETMASTER | SXF_SETTRACER);
	ActiveLoop:
		VOLT A 1;
		Loop;
	Inactive:
		TNT1 A 1 A_RemoveTracer(RMVF_MISC);
		Loop;
	}
}

class VolumetricLight_ConeUp : VolumetricBase //spawn correct AlertLight & sprite
{
	Default
	{
	//$Title Volumetric Light, Upward
	//$Sprite VOLTB0
	}
	States
	{
	Spawn:
	Active:
		VOLT B 1 NODELAY A_SpawnItemEx("AlertLight", 0, 0, 112, 0, 0, 0, 0, SXF_SETMASTER | SXF_SETTRACER);
	ActiveLoop:
		VOLT B 1;
		Loop;
	Inactive:
		TNT1 A 1 A_RemoveTracer(RMVF_MISC);
		Loop;
	}
}

class VolumetricLight_ConePitch : VolumetricBase
{
	Default
	{
	//$Title Volumetric Light, Pitchable (NO ALERTLIGHT)
	+FLATSPRITE
	}
	States
	{
	Spawn:
	Active:
		VOLT A 1;
		Loop;
	Inactive:
		TNT1 A 1;
		Loop;
	}
}