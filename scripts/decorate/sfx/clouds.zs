//Base Cloud Grey
class CloudBaseGrey : ParticleBase
{
	Default
	{
	+MISSILE
	+NOBLOCKMAP
	+NOGRAVITY
	Radius 1;
	Height 1;
	RenderStyle "Translucent";
	Alpha 0.1;
	Scale 0.5;
	+ParticleBase.CHECKPOSITION
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256, "Cloud1", "Cloud2");
	Cloud1:
		CLXG A 0;
		Goto Movement;
	Cloud2:
		CLXG B 0;
		Goto Movement;
	Movement:
		"####""###########" 3 A_FadeIn(0.05);
		"####" "#" 1000;
		Wait;
	}
}

class SmallCloudGrey : CloudBaseGrey  {	Default { Scale 1.0; } }
class MediumCloudGrey : CloudBaseGrey {	Default { Scale 2.0; } }
class LargeCloudGrey : CloudBaseGrey  {	Default { Scale 4.0; } }


//Base Cloud Tan
class CloudBaseTan : CloudBaseGrey
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256, "Cloud1", "Cloud2");
	Cloud1:
		CLXT A 0;
		Goto Movement;
	Cloud2:
		CLXT B 0;
		Goto Movement;
	}
}

//Grey Clouds
class SmallCloudTan : CloudBaseTan  { Default { Scale 1.0; } }
class MediumCloudTan : CloudBaseTan { Default { Scale 2.0; } }
class LargeCloudTan : CloudBaseTan  { Default { Scale 4.0; } }

//Base Cloud Dark
class CloudBaseDark : CloudBaseGrey
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256, "Cloud1", "Cloud2");
	Cloud1:
		CLXD A 0;
		Goto Movement;
	Cloud2:
		CLXD B 0;
		Goto Movement;
	}
}

//Grey Clouds
class SmallCloudDark : CloudBaseDark  {	Default	{ Scale 1.0; } }
class MediumCloudDark : CloudBaseDark { Default { Scale 2.0; } }
class LargeCloudDark : CloudBaseDark  { Default { Scale 4.0; } }