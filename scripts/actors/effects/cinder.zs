class CinderSpawner : EffectSpawner
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Cinder Spawner (floor)
		//$Color 12
		//$Arg0 "Radius"
		//$Arg0Tooltip "Radius in map units"
		//$Arg1 "Height"
		//$Arg1Tooltip "Z-dimension (bottom is the z-level the spawner is on)"
		//$Arg2 "Min. Speed"
		//$Arg2Tooltip "Minimum speed the particles have, randomized between min. and max."
		//$Arg3 "Max. Speed"
		//$Arg3Tooltip "Maximum speed the particles have, randomized between min. and max."
		//$Arg4 "Frequency"
		//$Arg4Tooltip "0 is always, 255 is never at a per-tic basis"
		Radius 1;
		Height 1;
		+CLIENTSIDEONLY
		+NOCLIP
		+NOGRAVITY
		EffectSpawner.Range 1024;
		EffectSpawner.SwitchVar "boa_cinderswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 5 SpawnEffect();
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!args[0] && !args[2] && !args[3])
		{
			args[0] = 128;
			args[2] = 1;
			args[3] = 8;
		}
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("FloatingCinder", random(-Args[0],Args[0]), random(-Args[0],Args[0]), random(0,Args[1]), random(Args[2],Args[3]), 0, random(-Args[2],Args[2]), random(-4, 4), 128, Args[4]);
	}
}

////////////////
// SKY CINDER //
////////////////
class CinderSpawnerSky : SnowSpawner
{
	Default
	{
		//$Title Cinder Spawner (ceiling)
		//$Sprite EMBRA0
		//$Arg1Tooltip "The lower the number, the heavier the amount of cinders\nRange: 0 - 255"
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (args[0] == 0) { args[0] = 128; }
	}

	override void SpawnEffect()
	{
		EffectSpawner.SpawnEffect();

		if (args[2]) { A_SpawnItemEx("FloatingCinder", random(-Args[0], Args[0]), 0, 0, frandom(-1.0, 1.0), frandom(-1.0, 1.0),frandom(-1.0, -3.0), random(0, 359), 0, Args[1]); }
		else { A_SpawnItemEx("FloatingCinder", random(-Args[0], Args[0]), random(-Args[0], Args[0]), 0, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, 0, Args[1]); }
	}
}

class FloatingCinder : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Radius 0;
		Height 0;
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.8;
		Scale 0.04;
	}

	States
	{
		Spawn:
			EMBR A 128 BRIGHT;
		Death:
			EMBR A 1 BRIGHT A_FadeOut(0.06, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		scale.x = scale.y = FRandom(0.03, 0.06);
		tics = 8 * (16 + Random(0, 8)); // Not quite what the previous A_Jump logic did, but similar
	}
}

class FloatingCinder2 : FloatingCinder
{
	Default
	{
		+NOINTERACTION
	}
}