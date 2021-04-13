class Flare1 : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Flare (white)
	//$Color 12
	Height 16;
	Radius 16;
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	Scale 0.5;
	RenderStyle "Add";
	}
	States
	{
	Spawn:
	Active:
		FLAR A -1;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}

class Flare2 : Flare1
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Flare (fire)
	//$Color 12
	}
	States
	{
	Spawn:
	Active:
		FLAR B -1 BRIGHT;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}

class Flare3d : Flare1
{
	Default
	{
	+FORCEXYBILLBOARD
	Scale 1.2;
	}
}

class Flare_Sun : Flare1
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Flare (Sun)
	//$Color 12
	+FORCEXYBILLBOARD
	Scale 1.0;
	}
	States
	{
	Spawn:
	Active:
		SUNL A -1 BRIGHT;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}