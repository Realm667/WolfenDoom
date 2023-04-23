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
		CinderSpawner.SpawnCinder(self, (frandom(-args[0],args[0]),frandom(-args[0],args[0]),frandom(0,args[1])),
			(frandom(args[2],args[3]),0,frandom(-args[2],args[2])), 4, args[4]);
	}
	
	static void SpawnCinder(Actor a, Vector3 p = (4,64,1024), Vector3 v = (4,64,1024), double halfang = 180, int failchance = 160)
	{
		if (Random(0, 255) < failchance) { return; }
		// GZDoom allows neither non-constant default parameters nor constant vectors.
		if (p == (4,64,1024)) { p = (frandom(-8,8),frandom(-8,8),frandom(0,32)); }
		if (v == (4,64,1024)) { v = (1,0,frandom(1,3)); }
		a.A_SpawnParticleEx(
			/*color1*/ "FFFFFF",
			/*texture*/ TexMan.CheckForTexture("EMBRA0"),
			/*style*/ STYLE_Add,
			/*flags*/ SPF_FULLBRIGHT | SPF_RELATIVE,
			/*lifetime*/ 8 * (16 + Random(0, 8)),
			/*size*/ frandom(3, 6),
			/*angle*/ frandom(-halfang, halfang),
			/*posoff*/ p.x, p.y, p.z,
			/*vel*/ v.x, v.y, v.z,
			/*acc*/ 0, 0, 0,
			/*startalphaf*/ 0.8,
			/*fadestepf*/ 0.0);
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

		double zoffset = 0;
		if (manager) { zoffset = min(manager.particlez - pos.z, 0); }
		if (Random(0, 255) < Args[1]) { return; }
		
		if (args[2]) { CinderSpawner.SpawnCinder(self, (frandom(-args[0],args[0]), 0, zoffset),
				(frandom(-1.0,1.0),frandom(-1.0,1.0),frandom(-1.0,-3.0)), 180, args[1]); }
		else { CinderSpawner.SpawnCinder(self, (frandom(-args[0],args[0]), frandom(-args[0], args[0]), zoffset),
				(frandom(-1.0,1.0),frandom(-1.0,1.0),frandom(-1.0,-3.0)), 0, args[1]); }
	}
}

// THE FOLLOWING CLASSES ARE UNUSED, only re-added them for savegame compatibility -- N00b

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