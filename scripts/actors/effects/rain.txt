// Zscript version of the DECORATE Rain Spawner by Tormentor667
class RainSpawner : EffectSpawner
{
	Class<Actor> raindrop;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Rain Spawner
		//$Color 12
		//$Arg0 "Radius"
		//$Arg0Tooltip "Radius in map units\nDefault: 0"
		//$Arg1 "Frequency"
		//$Arg1Tooltip "Frequency, the lower the number, the heavier the rainfall\nRange: 0 - 255"
		//$Arg2 "Sound"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "Yes"; 1 = "No"; }
		//$Arg3 "Drop Length"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Long"; 1 = "Short"; }
		//$Arg3Tooltip "Drop length, use long (0) for heavy rainfall and short (1) for a mizzle"
		//$Arg4 "Pitch"
		//$Arg4Tooltip "The rainfall's pitch, for maps with wind and storm, use angle for direction.\nThe higher the number, the heavier the wind.\nRange: 0 - 75, where 75 is almost horizontal rain"
		Radius 1;
		Height 1;
		YScale 0.1;
		+NOCLIP
		+NOGRAVITY
		+SPAWNCEILING;
		EffectSpawner.Range 1200;
		EffectSpawner.SwitchVar "boa_rainswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 1 SpawnEffect();
			Loop;
	}

	override void PostBeginPlay()
	{
		if (!args[3]) { raindrop = "RainDropLong"; }
		else { raindrop = "RainDropShort"; }

		if (args[0] == 0) { args[0] = 128; }

		Super.PostBeginPlay();
	}

	override void Activate(Actor activator)
	{
		if (!args[2] && switchcvar && switchcvar.GetBool()) { A_StartSound("Ambient/Rain", 7, CHANF_LOOPING, 1.0); }

		Super.Activate(activator);
	}

	override void Deactivate(Actor activator)
	{
		A_StopSound(7);

		Super.Deactivate(activator);
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx(raindrop, Random(-Args[0], Args[0]), Random(-Args[0], Args[0]), -2, Args[4], 0, -(args[3] ? 20 : 40) + (Args[4] / 2), 0, SXF_TRANSFERPITCH | SXF_CLIENTSIDE, Args[1]);
	}
}

class RainDropShort : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Height 1;
		Radius 4;
		RenderStyle "Translucent";
		Alpha 0.7;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
	}

	States
	{
		Spawn:
			MDLA A 0;
		Rainfall:
			"####" A 4;
			Loop;
		Death:
			RNDR A 0 {
				Scale = (0.10, 0.10);
				alpha = FRandom(0.8, 0.2);
			}
		RainDeath:
			"####" A 1 {
				Scale.x += 0.05;
				Scale.y += 0.05;
				A_FadeOut(0.1, FTF_REMOVE);
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Scale.x += FRandom(-0.05, 0.05);
		Scale.y += FRandom(-0.05, 0.05);
		alpha = FRandom(0.7, 0.4);
	}

	override void Tick()
	{
		if (waterlevel) { Destroy(); return; }
		Super.Tick();
	}
}

class RainDropLong : RainDropShort {}