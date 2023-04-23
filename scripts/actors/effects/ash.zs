class AshSpawner : EffectSpawner
{
	static const Color ashcolors[] = { "A0 A0 A0", "80 80 80", "60 60 60", "45 45 45" };
	
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Ash Spawner
		//$Color 12
		//$Sprite ASHXA0
		//$Arg0 "Radius"
		//$Arg0Tooltip "Radius in map units\nDefault: 0"
		//$Arg1 "Height"
		//$Arg1Tooltip "Height in map units\nDefault: 0"
		//$Arg4 "Frequency"
		//$Arg4Tooltip "The lower the number, the heavier the ash fall\nRange: 0 - 255"
		Radius 1;
		Height 1;
		+CLIENTSIDEONLY
		+NOCLIP
		+NOGRAVITY
		EffectSpawner.SwitchVar "boa_snowswitch";
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
		Super.PostBeginPlay();

		if (!args[0] && !args[1])
		{
			args[0] = 128;
			args[1] = 64;
		}
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();
		int i = Random(0, 3);
		double zoffset = 0;
		if (manager) { zoffset = min(manager.particlez - pos.z, 0); }
		if (Random(0, 255) < Args[4]) { return; }
		A_SpawnParticleEx(
			ashcolors[i], // color1
			TexMan.CheckForTexture("ASHXA0"), // texture
			STYLE_Shaded, // style
			SPF_RELATIVE | SPF_ROLL, // flags
			250 * 2, // lifetime
			frandom(6, 12), // size
			angle + frandom(0.0, 1.0), // angle
			frandom(-args[0], args[0]), frandom(-args[0], args[0]), min(Args[1], zoffset), // pos xyz
			frandom(0.0, 0.2), 0, 0, // vel xyz
			0, 0, -frandom(0.1, 0.3), // acc xyz
			fadestepf: 0.0,
			rollvel: random(0, 1) ? 1 : -1
		);
	}
}

// THE FOLLOWING CLASSES ARE UNUSED, only re-added them for savegame compatibility -- N00b

class FloatingAshLight : ParticleBase
{
	Default
	{
		Radius 1;
		Height 1;
		Scale 0.15;
		Gravity 1.0;
		+MISSILE
		+NOBLOCKMAP
		-NOGRAVITY
		RenderStyle "Shaded";
		StencilColor "A0 A0 A0";
		ReactionTime 250;
	}

	States
	{
		Spawn1:
			ASHX ABCDEFGH 2 A_CountDown();
			Loop;
		Spawn2:
			ASHX HGFEDCBA 2 A_CountDown();
			Loop;
		Death:
			ASHX F 2 A_FadeOut(0.06);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		gravity = FRandom(0.1, 0.3);
		scale.x = scale.y = FRandom(0.09, 0.12);

		if (Random(0, 1)) { SetStateLabel("Spawn1"); }
		else { SetStateLabel("Spawn2"); }
	}
}

class FloatingAshGrey : FloatingAshLight { Default { StencilColor "80 80 80"; } }
class FloatingAshDarkGrey : FloatingAshLight { Default { StencilColor "60 60 60"; } }
class FloatingAshDark : FloatingAshLight { Default { StencilColor "45 45 45"; } }