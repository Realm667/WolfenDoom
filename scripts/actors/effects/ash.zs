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
        A_SpawnParticleEx(ashcolors[i], TexMan.CheckForTexture("ASHXA0"), STYLE_Shaded, SPF_RELATIVE | SPF_ROLL,
            /*lifetime*/ 250 * 2,
            /*size*/ frandom(6, 12),
            /*angle*/ angle + frandom(0.0, 1.0),
            /*pos*/ frandom(-args[0], args[0]), frandom(-args[0], args[0]), min(Args[1], zoffset),
            /*vel*/ frandom(0.0, 0.2), 0, 0,
            /*acc*/ 0, 0, -frandom(0.1, 0.3),
            /*startalphaf*/ 1.0,
            /*fadestepf*/ 0.0,
            rollvel: random(0, 1) ? 1 : -1);
	}
}