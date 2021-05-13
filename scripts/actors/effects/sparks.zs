// Sparks
class SparkBase : ParticleBase
{
	int fadespeed;
	String sparkcolor;

	Property SparkColor:sparkcolor;

	Default
	{
		Height 1;
		Radius 2;
		Mass 0;
		Speed 1.0;
		+BRIGHT
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		Gravity 0.125;
		RenderStyle "Add";
		Scale 0.025;
	}

	States
	{
		Spawn:
			"####" E 1 BRIGHT;
			Loop;
		Death:
			"####" E 1 BRIGHT A_FadeOut(0.1 * fadespeed);
			Loop;
		Frames:
			SPKW A 0;
			SPKR A 0;
			SPKO A 0;
			SPKY A 0;
			SPKG A 0;
			SPKB A 0;
			SPKP A 0;
	}

	override void Tick()
	{
		Super.Tick();

		if (waterlevel) { Destroy(); }
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		CVar boa_sparkswitch = CVar.FindCVar("boa_sparkswitch");
		if (boa_sparkswitch) { fadespeed = max(1, 6 - boa_sparkswitch.GetInt()); }
		else { fadespeed = 1; }

		if (
			sparkcolor ~== "White" || sparkcolor ~== "Red" || sparkcolor ~== "Orange" ||
			sparkcolor ~== "Yellow" || sparkcolor ~== "Green" || sparkcolor ~== "Blue" || 
			sparkcolor ~== "Purple"
		)
		{
			int spr = GetSpriteIndex(String.Format("SPK%s", sparkcolor.left(1)));
			if (spr != -1) { sprite = spr; }
		}
		else
		{
			sprite = GetSpriteIndex("SPKW");
			A_SetRenderStyle(alpha, STYLE_AddShaded);
			SetShade(sparkcolor);
		}

		Speed = FRandom(0.25, 4.0); 

		// If it has a target (was fired as a projectile), set velocity directly, 
		// not just speed, since A_SpawnProjectile automatically sets the spark 
		// velocity amount to the default speed (1.0) on spawn
		if (target) { vel *= Speed; }
	}
}

class SparkW : SparkBase
{
	Default
	{
		SparkBase.SparkColor "White";
	}
}

class SparkR : SparkBase
{
	Default
	{
		SparkBase.SparkColor "Red";
	}
}

class SparkO : SparkBase
{
	Default
	{
		SparkBase.SparkColor "Orange";
	}
}

class SparkY : SparkBase
{
	Default
	{
		SparkBase.SparkColor "Yellow";
	}
}

class SparkG : SparkBase
{
	Default
	{
		SparkBase.SparkColor "Green";
	}
}

class SparkB : SparkBase
{
	Default
	{
		SparkBase.SparkColor "Blue";
	}
}

class SparkP : SparkBase
{
	Default
	{
		SparkBase.SparkColor "Purple";
	}
}

// Flares
class FlareBase : ParticleBase
{
	String flarecolor;

	Property FlareColor:flarecolor;

	Default
	{
		Height 0;
		Radius 0;
		Mass 0;
		+BRIGHT
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.25;
	}

	States
	{
		Spawn:
			"####" # 1 A_FadeOut(0.1, FTF_REMOVE);
			Loop;
		Frames:
			SPKW A 0;
			SPKR A 0;
			SPKO A 0;
			SPKY A 0;
			SPKG A 0;
			SPKB A 0;
			SPKP A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();


		if (
			flarecolor ~== "White" || flarecolor ~== "Red" || flarecolor ~== "Orange" ||
			flarecolor ~== "Yellow" || flarecolor ~== "Green" || flarecolor ~== "Blue" || 
			flarecolor ~== "Purple"
		)
		{
			int spr = GetSpriteIndex(String.Format("SPK%s", flarecolor.left(1)));
			if (spr != -1) { sprite = spr; }

			A_AttachLightDef("flarelight", flarecolor .. "SparkFlare");
		}
		else
		{
			sprite = GetSpriteIndex("SPKW");
			A_SetRenderStyle(alpha, STYLE_AddShaded);
			SetShade(flarecolor);

			A_AttachLight("flarelight", DynamicLight.PointLight , flarecolor, 12.0, 0.0, DYNAMICLIGHT.LF_ATTENUATE);
		}

		frame = Random(0, 5);
	}
}

class SparkFlareW : FlareBase
{
	Default
	{
		FlareBase.FlareColor "White";
	}
}

class SparkFlareR : FlareBase
{
	Default
	{
		FlareBase.FlareColor "Red";
	}
}

class SparkFlareO : FlareBase
{
	Default
	{
		FlareBase.FlareColor "Orange";
	}
}

class SparkFlareY : FlareBase
{
	Default
	{
		FlareBase.FlareColor "Yellow";
	}
}


class SparkFlareG : FlareBase
{
	Default
	{
		FlareBase.FlareColor "Green";
	}
}

class SparkFlareB : FlareBase
{
	Default
	{
		FlareBase.FlareColor "Blue";
	}
}

class SparkFlareP : FlareBase
{
	Default
	{
		FlareBase.FlareColor "Purple";
	}
}

// Spawners
class SparkSpawnerBase : EffectSpawner
{
	String sparkcolor;
	Property SparkColor:sparkcolor;

	Default
	{
		//$Category Special Effects (BoA)
		//$Color 12
		//$Sprite UNKNA0
		//$Arg0 "Direction"
		//$Arg0Tooltip "0 is up, 1 is down, 2 is forward (downfacing spawners should be placed 8 map units below the ceiling)"
		//$Arg0Type 11
		//$Arg0Enum { 0 = "Up"; 1 = "Down"; 2 = "Forward"; }
		//$Arg1 "Frequency"
		//$Arg1Tooltip "Values are divided by 16 so you can't get a spawner that spawns every time. Only used if third argument is 0."
		//$Arg2 "ACS-only"
		//$Arg2Tooltip "'False' spawns it automatically (using the 2nd argument for frequency), 'True' makes it ACS-only"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "False"; 1 = "True"; }
		Height 8;
		Radius 4;
		+CLIENTSIDEONLY
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		EffectSpawner.Range 1024;
		+EffectSpawner.ALLOWTICKDELAY
		SparkSpawnerBase.SparkColor "Cyan";
	}

	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 10;
			TNT1 A 0 { if (args[2] == 0 && Random(0, 255) < args[1] / 16) { SetStateLabel("Active"); return; } }
			Loop;
		Active:
			TNT1 A 1 SpawnFlare();
			TNT1 A 0 SpawnEffect();
			Goto Spawn;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		sparkcolor = sparkcolor.left(1);

		if (args[2] > 0) { Deactivate(self); }
	}

	void SpawnFlare()
	{
		if (manager && manager.effectmanager && !manager.effectmanager.InRange(pos, boa_sfxlod)) { return; }
		
		if (!CheckRange(1280, true)) { A_StartSound("World/Spark", CHAN_AUTO); }

		A_SpawnItemEx("SparkFlare" .. sparkcolor);
	}

	override void SpawnEffect()
	{
		if (manager && manager.effectmanager && !manager.effectmanager.InRange(pos, boa_sfxlod)) { return; }

		Super.SpawnEffect();

		String sparktype = "Spark" .. sparkcolor;

		int delay = 0;
		if (manager)
		{
			delay = manager.GetDelay(chunkx, chunky);

			if (manager.effectmanager && manager.effectmanager.effectblocks[chunkx][chunky])
			{
				delay = int(2 * delay * manager.effectmanager.effectblocks[chunkx][chunky].cullinterval);
			}
		}

		for (int s = 0; s < 32 - delay; s++)
		{
			if (args[0] == 0) { A_SpawnProjectile(sparktype,0,0,random(0,360),CMF_AIMDIRECTION,random(-67,-113)); } // Up
			else if (args[0] == 1) { A_SpawnProjectile(sparktype,0,0,random(0,360),CMF_AIMDIRECTION,random(67,113)); } // Down
			else { A_SpawnProjectile(sparktype,0,0,random(-23,23),CMF_AIMDIRECTION,random(-157,-203)); } // Ahead
		}

		if (args[2] > 0) { Deactivate(self); }
	}
}

class WhiteSparkSpawner : SparkSpawnerBase
{
	Default
	{
		SparkSpawnerBase.SparkColor "White";
	}
}

class RedSparkSpawner : SparkSpawnerBase
{
	Default
	{
		SparkSpawnerBase.SparkColor "Red";
	}
}

class OrangeSparkSpawner : SparkSpawnerBase
{
	Default
	{
		SparkSpawnerBase.SparkColor "Orange";
	}
}

class YellowSparkSpawner : SparkSpawnerBase
{
	Default
	{
		SparkSpawnerBase.SparkColor "Yellow";
	}
}

class GreenSparkSpawner : SparkSpawnerBase
{
	Default
	{
		SparkSpawnerBase.SparkColor "Green";
	}
}

class BlueSparkSpawner : SparkSpawnerBase
{
	Default
	{
		SparkSpawnerBase.SparkColor "Blue";
	}
}

class PurpleSparkSpawner : SparkSpawnerBase
{
	Default
	{
		SparkSpawnerBase.SparkColor "Purple";
	}
}

// Projectiles
class AstroDroneBall : Actor
{
	ParticleManager manager;

	Default
	{
		Radius 6;
		Height 8;
		Speed 10;
		FastSpeed 20;
		Damage 5;
		Projectile;
		+RANDOMIZE;
		RenderStyle "Add";
		Scale 0.5;
		SeeSound "astrochaingun/fire";
		DeathSound "astroplasmaexplode";
	}

	States
	{
		Spawn:
			ROBP AB 4 SpawnSpark();
			Loop;
		Death:
			TNT1 AAAAA 0 SpawnSpark();
			TNT1 A 0 A_SpawnItemEx("SparkFlareG");
			ROBP CDEG 6 BRIGHT;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		manager = ParticleManager.GetManager();
	}

	void SpawnSpark()
	{
		if (curState && manager) { tics = curState.tics + manager.GetDelay(0, 0, self); }

		A_SpawnItemEx("SparkG", 0, 0, 0, random(1,2), random(1,2), random(1,2), random(1,360), SXF_CLIENTSIDE);
	}
}

class AstroRocket : Actor
{
	ParticleManager manager;

	Default
	{
		Radius 8;
		Height 16;
		Projectile;
		Speed 12;
		Damage 20;
		Gravity 0.125;
		RenderStyle "Add";
		BounceType "Grenade";
		BounceFactor 0.9;
		WallBounceFactor 0.9;
		BounceCount 5;
		SeeSound "astrolauncher/fire";
		DeathSound "astrolauncher/explode";
		BounceSound "astrolauncher/bounce";
		Decal "BFGScorch";
		Obituary "$OBASTROR";
		-NOGRAVITY
		+THRUGHOST
		+WINDTHRUST
	}

	States
	{
		Spawn:
			ASRK BC 4 LIGHT("ASTRWEP1") SpawnSpark();
			Loop;
		Death:
			TNT1 AAAAA 0 SpawnSpark();
			TNT1 A 0
			{
				A_SpawnItemEx("SparkFlareG");
				A_SpawnItemEx("ZPlasma");
				A_Explode();
			}
			ASRK DEF 4;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		manager = ParticleManager.GetManager();
	}

	void SpawnSpark()
	{
		if (curState && manager) { tics = curState.tics + manager.GetDelay(0, 0, self); }

		A_SpawnItemEx("SparkG", 0, 0, 0, random(1,2), random(1,2), random(1,2), random(1,360), SXF_CLIENTSIDE);
	}
}
