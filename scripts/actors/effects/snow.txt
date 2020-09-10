// Zscript version of:
///////////////////////////////////
// SNOW SPAWNERS by Tormentor667 //
//   improved by  Ceeb & MaxED   //
///////////////////////////////////

class SnowSpawner : EffectSpawner
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Snow Spawner
		//$Color 12
		//$Sprite SNOWA0
		//$Arg0 "Radius"
		//$Arg0Tooltip "Radius in map units\nDefault: 0"
		//$Arg1 "Frequency"
		//$Arg1Tooltip "The lower the number, the heavier the snowfall\nRange: 0 - 255"
		//$Arg2 "Area"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "Square"; 1 = "Circle"; }
		Radius 1;
		Height 3;
		+CLIENTSIDEONLY
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+NOSECTOR
		+SPAWNCEILING;
		EffectSpawner.Range 1024;
		EffectSpawner.SwitchVar "boa_snowswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 6 SpawnEffect();
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!args[0]) { args[0] = 128; }
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (args[2]) { A_SpawnItemEx("SnowParticle", random(-Args[0], Args[0]), 0, 0, frandom(-1.0, 1.0), frandom(-1.0, 1.0),frandom(-1.0, -3.0), random(0, 359), 0, Args[1]); }
		else { A_SpawnItemEx("SnowParticle", random(-Args[0], Args[0]), random(-Args[0], Args[0]), 0, frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), 0, 0, Args[1]); }
	}
}

class SnowParticle : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Radius 1;
		Height 3;
		Projectile;
		RenderStyle "Add";
		Alpha 0.6;
		Scale 0.6;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
	}

	States
	{
		Spawn:
			SNOW AAAAAAAA 1 NoDelay A_FadeIn(0.05);
			SNOW A -1;
			Stop;
		Death:
			SNOW A 1 A_FadeOut(0.02, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		scale.x = scale.y = FRandom(0.3, 0.6);
	}
}