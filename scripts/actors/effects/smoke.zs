// ZScript conversions of:
/////////////////////////////
// ACTORS FOR REGULAR MAPS // by GuardSoul, optimized and improved by Tormentor667
/////////////////////////////

class SmokeBase : ParticleBase
{
	double maxalpha;
	bool fade;
	int intics, outtics;

	Property MaxAlpha:maxalpha;
	Property FadeInTics:intics;
	Property FadeOutTics:outtics;

	Default
	{
		+ROLLSPRITE
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		roll = Random[Smoke](1, 360);
	}

	// Handle fade in and fade out here, optionally passing in a scale change amount
	void DoFade(double instep = 0.04, double outstep = 0.025, double scaledelta = 1.0)
	{
		if (!fade && alpha < maxalpha)
		{
			tics = max(1, intics);
			alpha = min(maxalpha, alpha + instep);
		}
		else
		{
			fade = true;
			tics = max(1, outtics);

			A_FadeOut(outstep, FTF_REMOVE);

			scale *= scaledelta;
		}
	}
}

class PuffSmoke : SmokeBase
{
	transient CVar boa_smoketype;

	Default
	{
		DistanceCheck "boa_sfxlod";
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+NOINTERACTION
		+WINDTHRUST
		RenderStyle "Translucent";
		Alpha 0.1;
		Scale 0.04;
		SmokeBase.FadeInTics 1;
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.04, 0.025, 1.02);
			Loop;
		Frames:
			GRM1 A 0;
			GRM2 A 0;
			GRM3 A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		boa_smoketype = CVar.FindCVar("boa_smoketype");

		if (!boa_smoketype.GetBool())
		{
			if (!maxalpha) { maxalpha = 0.46; }
			if (!outtics) { outtics = 2; }
		}
		else
		{
			if (!maxalpha) { maxalpha = 0.7; }
			if (!outtics) { outtics = 3; }
		}

		scale.x *= FRandom[Smoke](0.7, 1.0);
		scale.y *= FRandom[Smoke](0.7, 1.0);

		int spr = GetSpriteIndex("GRM" .. Random[Smoke](1, 3));
		if (spr != -1) { sprite = spr; }
	}
}

class WaterSmoke : PuffSmoke //needed for 3d toilet & 3d hydrants - ozy81
{
	Default
	{
		Alpha 0.2;
		Scale 0.03;
		SmokeBase.MaxAlpha 0.44;
		SmokeBase.FadeOutTics 2;
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.03, 0.015);
			Loop;
		Frames:
			WTSA A 0;
			WTSC A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		scale.x *= FRandom[Smoke](0.4, 0.7);
		scale.y *= FRandom[Smoke](0.4, 0.7);

		int spr = GetSpriteIndex(String.Format("WTS%c", RandomPick[Smoke](65, 67))); // A or C
		if (spr != -1) { sprite = spr; }
	}
}

class BodySmoke : PuffSmoke //needed for burnt bodies - ozy81
{
	Default
	{
		Scale 0.15;
	}
}

class BodySmokeSpawner : EffectSpawner
{
	Default
	{
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			"####" A 12 SpawnEffect();
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("BodySmoke", Random[Smoke](-3, 3), Random[Smoke](-3, 3), 0, 0, 0, FRandom[Smoke](0.2, 1.0));
	}

	override void Tick()
	{
		Super.Tick();

		if (master && master.tics == -1) { Destroy(); }
	}
}

class WaterSmokePuff : WaterSmoke
{
	Default
	{
		Scale 0.18;
	}
}

class WaterSmokePuffSmall : WaterSmoke
{
	Default
	{
		Scale 0.10;
	}
}

class TankSmoke : PuffSmoke
{
	Default
	{
		Radius 1;
		Height 1;
		Scale 0.9;
		Speed 2;
		Alpha 0.0001;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		-DROPOFF
		+DONTSPLASH
		SmokeBase.FadeOutTics 2;
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.05, 0.025);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		int spr = GetSpriteIndex("GRM" .. Random[Smoke](1, 2));
		if (spr != -1) { sprite = spr; }
	}
}

class TankSmokeSpawner : EffectSpawner
{
	Default
	{
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			MDLA A 12 SpawnEffect();
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnProjectile("TankSmoke", 58, 0, Random[Smoke](0, 360), CMF_AIMDIRECTION, Random[Smoke](-70, -130));
	}	
}

class PowerPlantSmokePuff : PuffSmoke
{
	Default
	{
		Scale 0.64;
	}
}

class PowerPlantSmokePuffSmall : PuffSmoke
{
	Default
	{
		Scale 0.32;
		SmokeBase.MaxAlpha 1.2;
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.1, 0.025, 1.02);
			Loop;
	}
}

class PowerPlantSmokePuffLarge : PuffSmoke
{
	Default
	{
		Scale 1.0;
		SmokeBase.FadeOutTics 4;
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.04, 0.02, 1.02);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		int spr = GetSpriteIndex("GRM" .. Random[Smoke](1, 2));
		if (spr != -1) { sprite = spr; }
	}
}

class PowerPlantSmokeGenerator : EffectSpawner
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Smoke Generator (Normal)
		//$Color 12
		+CLIENTSIDEONLY
		+INVULNERABLE
		+NOGRAVITY
		+NOINTERACTION
		+SHOOTABLE
		EffectSpawner.Range 1200;
		EffectSpawner.SwitchVar "boa_smokeswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 8 SpawnEffect();
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("PowerPlantSmokePuff", FRandom[Smoke](-8.0,8.0), FRandom[Smoke](-8.0,8.0), 0, FRandom[Smoke](0.2, -0.2), FRandom[Smoke](0.2, -0.2), FRandom[Smoke](0.5, 1.5));
	}
}

class PowerPlantSmokeGeneratorSmall : PowerPlantSmokeGenerator
{
	Default
	{
		//$Title Smoke Generator (Small)
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("PowerPlantSmokePuffSmall", FRandom[Smoke](-4.0,4.0), FRandom[Smoke](-4.0,4.0), 0, FRandom[Smoke](0.1, -0.1), FRandom[Smoke](0.1, -0.1), FRandom[Smoke](0.25, 0.75));
	}
}

class PowerPlantSmokeGenerator2 : PowerPlantSmokeGenerator
{
	Default
	{
		//$Title Smoke Generator (Large)
		//$Color 12
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("PowerPlantSmokePuffLarge", FRandom[Smoke](-32.0,32.0), FRandom[Smoke](-32.0,32.0), 0, FRandom[Smoke](0.3, -0.3), FRandom[Smoke](0.3, -0.3), FRandom[Smoke](0.75, 2.0));
	}
}

// ZScript conversions of:
/////////////////////////////
// ACTORS FOR VOLCANO MAPS // by Tormentor667
/////////////////////////////

class VolcanoPuffSmoke : SmokeBase
{
	Default
	{
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+NOINTERACTION
		+WINDTHRUST
		RenderStyle "Translucent";
		Alpha 0.0; // In DECORATE this was 1.0, so alpha was always above 1.0, and the actor just blinked into existence and then disappeared...
		Scale 8;
		SmokeBase.FadeInTics 1;
		SmokeBase.FadeOutTics 8;
		SmokeBase.MaxAlpha 1.0;
	}

	States
	{
		Spawn:
			GRM3 A 1 DoFade(0.1, 0.05);
			Loop;
	}
}

class VolcanoSmokeGenerator : EffectSpawner
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Volcano Smoke Generator (Huge)
		//$Color 12
		+INVULNERABLE
		+NOGRAVITY
		+NOINTERACTION
		+SHOOTABLE
		+EffectSpawner.DONTCULL
		EffectSpawner.SwitchVar "boa_smokeswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 15 SpawnEffect();
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		bool sp;
		Actor mo;

		[sp, mo] = A_SpawnItemEx("VolcanoPuffSmoke", Random[Smoke](-128,128), Random[Smoke](-128,128), 0, Random[Smoke](1,5), Random[Smoke](1,5), Random[Smoke](10,20), Random[Smoke](1,359));
		if (sp && mo)
		{
			mo.scale.x *= scale.x;
			mo.scale.y *= scale.y;
		}
	}
}

// ZScript conversions of:
///////////////////
// AMBIENT SMOKE //
///////////////////

class AmbientSmokeSB : SmokeBase
{
	Default
	{
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+NOINTERACTION
		+WINDTHRUST
		RenderStyle "Translucent";
		Alpha 0.001;
		Scale 0.3;
		SmokeBase.FadeInTics 1;
		SmokeBase.FadeOutTics 3;
		SmokeBase.MaxAlpha 0.091; // Odd values because we're matching old DECORATE code
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.005, 0.005);
			Loop;
		Frames:
			GRM1 A 0;
			GRM2 A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		int spr = GetSpriteIndex("GRM" .. Random[Smoke](1, 2));
		if (spr != -1) { sprite = spr; }
	}
}

class AmbientSmoke : AmbientSmokeSB
{
	Default
	{
		DistanceCheck "boa_sfxlod";
	}
}

class AmbientSmokeGenerator : EffectSpawner
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Ambient Smoke Generator (small, up)
		//$Color 12
		//$Arg0 "Radius"
		//$Arg0Tooltip "Radius in map units\nDefault: 0"
		//$Arg1 "Frequency"
		//$Arg1Tooltip "Frequency, the lower the number, the heavier the smoke\nRange: 0 - 255"
		//$Arg2 "Type"
		//$Arg2Tooltip "Set SkyBox to have variant which doesn't have LOS"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "Normal"; 1 = "SkyBox"; }
		+CLIENTSIDEONLY
		+NOINTERACTION
		EffectSpawner.Range 1200;
		EffectSpawner.SwitchVar "boa_smokeswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 8 SpawnEffect();
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (args[2])
		{
			range = boa_sfxlod;
			bAllowTickDelay = false;
		}
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (args[2])
		{
			bDontCull = true; // Do not cull
			A_SpawnItemEx("AmbientSmokeSB", Random[Smoke](-Args[0], Args[0]), Random[Smoke](-Args[0], Args[0]), Random[Smoke](0,48), 0, 0, 0.5, 0, 0, Args[1]);
		}
		else { A_SpawnItemEx("AmbientSmoke", Random[Smoke](-Args[0], Args[0]), Random[Smoke](-Args[0], Args[0]), Random[Smoke](0,48), 0, 0, 0.5, 0, 0, Args[1]); }
	}
}

class AmbientSmokeGeneratorDown : AmbientSmokeGenerator
{
	Default
	{
		//$Title Ambient Smoke Generator (small, down)
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (args[2])
		{
			bDontCull = true; // Do not cull
			A_SpawnItemEx("AmbientSmokeSB", Random[Smoke](-Args[0], Args[0]), Random[Smoke](-Args[0], Args[0]), Random[Smoke](0,-48), 0, 0, 0.5, 0, 0, Args[1]);
		}
		else { A_SpawnItemEx("AmbientSmoke", Random[Smoke](-Args[0], Args[0]), Random[Smoke](-Args[0], Args[0]), Random[Smoke](0,-48), 0, 0, -0.5, 0, 0, Args[1]); }
	}
}

class AmbientSmoke_Large : AmbientSmoke
{
	Default
	{
		Scale 3.0;
		SmokeBase.FadeInTics 2;
		SmokeBase.FadeOutTics 6;
		SmokeBase.MaxAlpha 0.201;
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.008, 0.008);
			Loop;
	}
}

class AmbientSmokeGenerator_Large : AmbientSmokeGenerator
{
	Default
	{
		//$Title Ambient Smoke Generator (large, up)
		//$Arg0 "Radius *10"
		//$Arg0Tooltip "Radius in map units *10\nDefault: 0"
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("AmbientSmoke_Large", Random[Smoke](-Args[0]*10, Args[0]*10), Random[Smoke](-Args[0]*10, Args[0]*10), Random[Smoke](64,256), 0, 0, Random[Smoke](1,4), 0, 0, Args[1]);
	}
}

class AmbientSmokeGeneratorDown_Large : AmbientSmokeGeneratorDown
{
	Default
	{
		//$Title Ambient Smoke Generator (large, down)
		//$Arg0 "Radius *10"
		//$Arg0Tooltip "Radius in map units *10\nDefault: 0"
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("AmbientSmoke_Large", Random[Smoke](-Args[0]*10, Args[0]*10), Random[Smoke](-Args[0]*10, Args[0]*10), Random[Smoke](-64,-128),   0, 0, Random[Smoke](-1,-4), 0, 0, Args[1]);
	}
}

// Dark Smoke
class DarkSmokeBase : ParticleBase
{
	Default
	{
		Height 2;
		Radius 1;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+WINDTHRUST
		Alpha 0.7;
		Scale 0.3;
	}

	States
	{
		Spawn:
			"####" A 3 A_FadeOut(0.01, FTF_REMOVE);
			Loop;
		Frames:
			DKSM A 0;
			DKS2 A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		int spr = GetSpriteIndex(String.Format("DKS%c", RandomPick[Smoke](77, 50))); // M or 2
		if (spr != -1) { sprite = spr; }		
	}
}

class DarkSmoke1 : DarkSmokeBase
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Thrust(1, FRandom[Smoke](0, 22.5));
		vel.z = FRandom[Smoke](3, 6) / 4;
	}

}

class DarkSmoke2 : DarkSmokeBase
{
	Default
	{
		Scale 0.6;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Thrust(FRandom[Smoke](1, 2), FRandom[Smoke](0, 22.5));
		vel.z = FRandom[Smoke](5, 9) / 4;
	}
}

class DarkSmoke3 : DarkSmokeBase
{
	Default
	{
		Scale 1.0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Thrust(FRandom[Smoke](2, 4), FRandom[Smoke](0, 22.5));
		vel.z = FRandom[Smoke](9, 15) / 4;
	}
}

class DarkSmokeSpawner : EffectSpawner
{
	int count;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Dark Smoke Spawner
		//$Color 12
		//$Arg0 "Size"
		//$Arg0Type 11
		//$Arg0Enum { 0 = "Small"; 1 = "Medium"; 2 = "Large"; }
		Height 40;
		Radius 30;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		EffectSpawner.Range 1200;
		EffectSpawner.SwitchVar "boa_smokeswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 0 A_Jump(256, 1 ,2, 3);
			TNT1 A 2 SpawnEffect();
			TNT1 A 4 SpawnEffect();
			TNT1 A 6 SpawnEffect();
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		// A_SpawnItemEx("DarkSmoke" .. min(3, args[0] + 1));

		int variant = clamp(args[0], 0, 2);
		TextureID smoke = TexMan.CheckForTexture(String.Format("DKS%cA0", RandomPick[Smoke](77, 50))); // M or 2

		// Calculate size
		static const double sizes[] = { 0.3, 0.6, 1.0 };
		double size = sizes[variant] * 384.;

		// Calculate Z vel
		static const double velzmin[] = { .75, 1.25, 2.25 }; // (3, 5, 9) / 4
		static const double velzmax[] = { 1.5, 2.25, 3.75 }; // (6, 9, 15) / 4
		double velz = FRandom[Smoke](velzmin[variant], velzmax[variant]);

		// Calculate args for Thrust(speed, angle)
		static const double speedmin[] = { 1, 1, 2 };
		static const double speedmax[] = { 1, 2, 4 };
		double speed = FRandom[Smoke](speedmin[variant], speedmax[variant]);
		double angle = FRandom[Smoke](0, 22.5);
		double velx = cos(angle) * speed;
		double vely = sin(angle) * speed;

		A_SpawnParticleEx(
			"FFFFFF", // color1
			smoke, // texture
			STYLE_Normal, // style
			SPF_ROLL, // flags
			300, // lifetime (100 (1./0.01) * 3)
			size, // size
			angle, // angle
			velx: velx, // velx
			vely: vely, // vely
			velz: velz, // velz
			startalphaf: 0.7, // startalphaf
			fadestepf: 0.0033333333333, // fadestepf (0.01 / 3)
			startroll: Random[Smoke](0, 360), // startroll
			rollvel: FRandom[Smoke](0.6, 0.8) // rollvel
		);
	}
}