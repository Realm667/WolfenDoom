class FireSpawner : HeatEffectGiver
{
	static const string suffixes[] = { "Small", "Medium", "Large", "Huge", "Immense", "Inferno" };

	String suffix;
	double smokescale;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Fire Spawner
		//$Color 12
		//$Arg0 "Size"
		//$Arg0Type 11
		//$Arg0Enum { 0 = "Small"; 1 = "Medium"; 2 = "Large"; 3 = "Huge"; 4 = "Immense"; 5 = "Inferno"; }
		//$Arg1 "Sound"
		//$Arg1Type 11
		//$Arg1Enum { 0 = "Yes"; 1 = "No"; }
		//$Arg2 "Smoke"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "Yes"; 1 = "No"; }
		Height 40;
		Radius 30;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+NOCLIP
		+NOGRAVITY
		EffectSpawner.SwitchVar "boa_fireswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 35; // Delay on activation is in original DECORATE
			TNT1 A 0 {
				StartSound();
				A_AttachLightDef("Flicker", "FireSpawner" .. suffix);
			}
		ActiveLoop:
			TNT1 A 1 SpawnEffect();
			Loop;
	}

	override void PostBeginPlay()
	{
		suffix = suffixes[args[0]];
		
		if (args[0] < 3) { EffectSpawner.PostBeginPlay(); } // Skip the standard EffectGiver PostBeginPlay, because that sets the actor's size to the full height of the sector
		else // For extra-large flames, just run necessary initialization without adding the spawner to the effects manager queue...  Assume it's a major set piece that shouldn't disappear across the map.
		{
			SwitchableDecoration.PostBeginPlay();

			if (switchvar.length()) { switchcvar = CVar.FindCVar(switchvar); }

			manager = ParticleManager.GetManager();

			if (bDormant || SpawnFlags & MTF_DORMANT) { Deactivate(null); }
			else { Activate(null); }

			tics += Random(0, 35);
		}

		A_SetSize(Radius * scale.x + 32, Height * scale.y + 32);

		if (switchcvar && !switchcvar.GetBool()) { Deactivate(null); return; }
	}

	override void SpawnEffect()
	{
		if (bAllowTickDelay && manager) { tics = curState.tics + manager.GetDelay(chunkx, chunky); } // Double tickdelay for these spawners

		if (switchcvar)
		{
			if (!switchcvar.GetBool()) { Deactivate(self); return; }

			tics += 5 - switchcvar.GetInt();  // Set tics according to the cvar
		}

		int spawntype = RandomPick(3, 2, 1, 1, 1, 1, 1); // Replicates the random spawns of the old A_Jump calls... Embers, smoke, or flame

		if (!suffix.length()) { suffix = "Small"; }

		if (spawntype == 1 || spawntype == 3) { Spawn("Flame_" .. suffix, pos); }
		if (spawntype == 3) { Spawn("Ember_" .. suffix, pos); }
		if (spawntype == 2 && !args[2]) { Spawn("Smoke_" .. suffix, pos); }
	}

	override void Deactivate(Actor activator)
	{
		Super.Deactivate(activator);

		if (!args[1])
		{
			A_StartSound("SFX/FireDie", CHAN_7);
			A_StopSound(CHAN_6);
		}

		A_RemoveLight("Flicker");
	}

	void StartSound()
	{
		if (args[1]) { return; }

		A_StartSound("SFX/FireStart", CHAN_7);

		switch(args[0])
		{
			default:
			case 0:
				A_StartSound("SFX/FireLoop1", CHAN_6, CHANF_LOOPING, 1.0);
				break;
			case 1:
				A_StartSound("SFX/FireLoop2", CHAN_6, CHANF_LOOPING, 1.0);
				break;
			case 2:
				A_StartSound("SFX/FireLoop3", CHAN_6, CHANF_LOOPING, 1.0);
				break;
			case 3:
				A_StartSound("SFX/FireLoop3", CHAN_6, CHANF_LOOPING, 4.0);
				break;
			case 4:
				A_StartSound("SFX/FireLoop3", CHAN_6, CHANF_LOOPING, 8.0);
				break;
			case 5:
				A_StartSound("SFX/FireLoop3", CHAN_6, CHANF_LOOPING, 16.0);
				break;
		}
	}
}

//Flames and particles
class FlameBase : ParticleBase
{
	double scaleamt, thrustmin, thrustmax, thrustminz, thrustmaxz;

	Property ScaleAmt:scaleamt;
	Property Thrust:thrustmin, thrustmax;
	Property ThrustZ:thrustminz, thrustmaxz;

	Default
	{
		Height 2;
		Radius 1;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.8;
		Scale 0.20;
		FlameBase.ScaleAmt 0.0125;
		FlameBase.Thrust 0, 1;
		FlameBase.ThrustZ 2, 6;
	}

	States
	{
		Spawn:
			"####" A 2 BRIGHT {
				scale.x -= scaleamt;
				scale.y -= scaleamt;

			 	A_FadeOut(0.05, FTF_REMOVE);
			}
			Loop;
		Frames:
			FLM1 A 0;
			FLM2 A 0;
			FLM3 A 0;
			FLM4 A 0;
			FLM5 A 0;
			FLM6 A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Thrust(FRandom(thrustmin, thrustmax), Random(0, 359));
		vel.z = FRandom(thrustminz, thrustmaxz) / 4; // Divide desired vel.z by 4 because ThrustThingZ divides by 4 internally, and I want to use the same input numbers as the original code.

		int spr = GetSpriteIndex("FLM" .. Random(1, 6));
		if (spr != -1) { sprite = spr; }
	}
}

class Flame_Small : FlameBase {}

class Flame_Medium : FlameBase
{
	Default
	{
		Scale 0.4;
		FlameBase.ScaleAmt 0.025;
		FlameBase.Thrust 0, 3;
		FlameBase.ThrustZ 4, 12;
	}
}

class Flame_Large : FlameBase
{
	Default
	{
		Scale 0.7;
		FlameBase.ScaleAmt 0.04;
		FlameBase.Thrust 0, 4;
		FlameBase.ThrustZ 8, 24;
	}
}

class Flame_Huge : Flame_Large
{
	Default
	{
		Scale 3.4;
	}
}

class Flame_Immense : Flame_Large
{
	Default
	{
		Scale 7.7;
	}
}

class Flame_Inferno : Flame_Large
{
	Default
	{
		Scale 14.4;
	}
}

class FireSmokeBase : ParticleBase
{
	double thrustmin, thrustmax, thrustminz, thrustmaxz;

	Property Thrust:thrustmin, thrustmax;
	Property ThrustZ:thrustminz, thrustmaxz;

	Default
	{
		Height 2;
		Radius 1;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+WINDTHRUST
		Alpha 0.8;
		Scale 0.5;
		FireSmokeBase.Thrust 0, 1;
		FireSmokeBase.ThrustZ 2, 6;
	}

	States
	{
		Spawn:
			SMOC A 3 A_FadeOut(.05);
			Loop;
	}


	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Thrust(FRandom(thrustmin, thrustmax), Random(0, 359));
		vel.z = FRandom(thrustminz, thrustmaxz) / 4; // Divide desired vel.z by 4 because ThrustThingZ divides by 4 internally, and I want to use the same input numbers as the original code.
	}
}

class Smoke_Small : FireSmokeBase {}

class Smoke_Medium : FireSmokeBase
{
	Default
	{
		Scale 0.75;
		FireSmokeBase.ThrustZ 3, 9;
	}
}

class Smoke_Large : FireSmokeBase
{
	Default
	{
		Scale 1.0;
		FireSmokeBase.ThrustZ 4, 12;
	}
}

class Smoke_Huge : FireSmokeBase
{
	Default
	{
		Scale 3.0;
	}
}

class Smoke_Immense : FireSmokeBase
{
	Default
	{
		Scale 7.0;
	}
}

class Smoke_Inferno : FireSmokeBase
{
	Default
	{
		Scale 12.0;
	}
}

class EmberBase : ParticleBase
{
	double thrustmin, thrustmax, thrustminz, thrustmaxz;
	int delay;

	Property Thrust:thrustmin, thrustmax;
	Property ThrustZ:thrustminz, thrustmaxz;
	Property Delay:delay;

	Default
	{
		Height 2;
		Radius 1;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.8;
		Scale 0.05;
		DistanceCheck "boa_sfxlod";
		EmberBase.Thrust 0, 1;
		EmberBase.ThrustZ 1, 4;
		EmberBase.Delay 32;
	}

	States
	{
		Spawn:
			EMBR A -1;
		FadeLoop:
			EMBR A 2 BRIGHT A_FadeOut(0.05, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Thrust(FRandom(thrustmin, thrustmax), Random(0, 359));
		vel.z = FRandom(thrustminz, thrustmaxz) / 4;

		tics = delay;
	}
}

class Ember_Small : EmberBase {}

class Ember_Medium : EmberBase
{
	Default
	{
		EmberBase.ThrustZ 4, 8;
		EmberBase.Delay 64;
	}
}

class Ember_Large : Ember_Medium {}

class Ember_Huge : Ember_Medium
{
	Default
	{
		Scale 2.0;
		EmberBase.Delay 72;
	}
}

class Ember_Immense : Ember_Medium
{
	Default
	{
		Scale 6.0;
		EmberBase.Delay 80;
	}
}

class Ember_Inferno : Ember_Medium
{
	Default
	{
		Scale 12.0;
		EmberBase.Delay 96;
	}
}

class BarrelFireSpawner : EffectSpawner
{
	int count;

	Default
	{
		Height 40;
		Radius 30;
		Projectile;
		DamageType "Fire";
		-NOGRAVITY
		+CLIENTSIDEONLY
		+DONTSPLASH
		+NODAMAGETHRUST
		+NOEXPLODEFLOOR
		+THRUGHOST
		Gravity 0.125;
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 1 SpawnEffect();
			TNT1 A 1 SpawnEffect();
			TNT1 A 1 SpawnEffect();
			TNT1 A 1 SpawnEffect();
			TNT1 A 1 SpawnEffect();
			TNT1 A 1 A_Explode(Random(1, 2), 8, 0);
			TNT1 A 0 {
				count++;

				if (count > 6)
				{
					if (Random() < 192) { Deactivate(self); }
					else { count = 0; }
				}
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		A_StartSound("SFX/FireStart", CHAN_7, 0, FRandom(0.4, 0.8), ATTN_STATIC);
		A_StartSound("SFX/FireLoop1", CHAN_6, CHANF_LOOPING, FRandom(0.2, 0.4), ATTN_STATIC);
	}

	override void Deactivate(Actor activator)
	{
		Super.Deactivate(activator);

		A_StartSound("SFX/FireDie", CHAN_7);
		A_StopSound(CHAN_6);
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		bool spawned;
		Actor mo;

		if (count == 0 && Random(0, 7) == 0) // 1 in 8 chance of spawning embers on the first loop
		{
			A_SpawnItemEx("Ember_Small");
			A_SpawnItemEx("Ember_Medium");
			A_SpawnItemEx("Ember_Small");
			A_Explode(Random(1, 2), 8, 0);
		}
		else
		{
			A_SpawnItemEx("Flame_Small");
		}
	}
}

// Zyklon flames
class ZFlame1A : FlameBase
{
	Default
	{
		+ROLLSPRITE
		Scale 0.3;
		Alpha 0.3;
	}

	States
	{
		Spawn:
			ZFLM A 2 {
				A_FadeOut(0.05);
				A_SetRoll(roll - 25, SPF_INTERPOLATE);
				scale.x -= 0.0125;
				scale.y -= 0.0125;
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Thrust(FRandom(thrustmin, thrustmax), Random(0, 359));
		vel.z = FRandom(thrustminz, thrustmaxz) / 4;
	}
}

class ZFlame1B : ZFlame1A
{
	Default
	{
		DistanceCheck "boa_sfxlod";
	}

	States
	{
		Spawn:
			ZFLM B 2 {
				A_FadeOut(0.05);
				A_SetRoll(roll - 25, SPF_INTERPOLATE);
				scale.x -= 0.0125;
				scale.y -= 0.0125;
			}
			Loop;
	}
}
