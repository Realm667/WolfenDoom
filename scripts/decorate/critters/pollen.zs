class PollenAir : EffectBase
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Pollen
		//$Color 0
		DistanceCheck "boa_sfxlod";
		Radius 1;
		Height 1;
		Speed 1;
		Mass 5;
		Scale 0.1;
		-PUSHABLE
		+CANNOTPUSH
		+CANPASS
		+DONTOVERLAP
		+FLOATBOB
		+FRIENDLY
		+NOBLOCKMAP
		+NOGRAVITY
		+NOLIFTDROP
		+NOTARGET
		+RANDOMIZE
		+SPAWNFLOAT
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		CRIT A 2 A_Wander;
		Loop;
	}
}