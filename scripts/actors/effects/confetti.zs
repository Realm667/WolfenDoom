class ConfettiSpawner : SnowSpawner
{
	Default
	{
		//$Title Confetti Spawner
		//$Sprite CONFA0
		//$Arg1Tooltip "The lower the number, the heavier the amount of confetti\nRange: 0 - 255"
	}

	override void SpawnEffect()
	{
		EffectSpawner.SpawnEffect();

		if (args[2]) { A_SpawnItemEx("ConfettiParticle", Random[Confetti](-Args[0], Args[0]), 0, 0, FRandom[Confetti](-1.0, 1.0), FRandom[Confetti](-1.0, 1.0), FRandom[Confetti](-4.0, 4.0), Random[Confetti](0, 359), SXF_TRANSFERPITCH | SXF_CLIENTSIDE, Args[1]); }
		else { A_SpawnItemEx("ConfettiParticle", Random[Confetti](-Args[0], Args[0]), Random[Confetti](-Args[0], Args[0]), 0, FRandom[Confetti](-1.0, 1.0), FRandom[Confetti](-1.0, 1.0), FRandom[Confetti](-4.0, 4.0), 0, SXF_TRANSFERPITCH | SXF_CLIENTSIDE, Args[1]); }
	}
}

class ConfettiParticle : ParticleBase
{
	transient CVar boa_debrislifetime;

	Default
	{
		DistanceCheck "boa_sfxlod";
		Radius 2;
		Height 2;
		Damage 0;
		Scale 0.5;
		Projectile;
		-BLOCKEDBYSOLIDACTORS
		-NOGRAVITY
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FLATSPRITE
		+INTERPOLATEANGLES
		+NOBLOCKMAP
		+ROLLSPRITE
		+WINDTHRUST
	}

	States
	{
		Spawn:
			CONF "#" 1 {
				tics = Random[Confetti](1, 3);

				A_SetRoll(roll + RandomPick[Confetti](-1, 1) * FRandom[Confetti](-30.5, 60.5), SPF_INTERPOLATE);
				angle += Random[Confetti](-45, 45);
				pitch += FRandom[Confetti](-95.25, 95.25);
			}
			Loop;
		Death:
			"####" "#" 1 {
				roll = 0;
				angle = 0;
				pitch = 0;

				bRollSprite = FALSE;

				tics = (boa_debrislifetime ? 35 * boa_debrislifetime.GetInt() / 4 : 35);
			}
		DeathWait:
			"####" "#" 1 A_FadeOut(0.1);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		boa_debrislifetime = CVar.FindCVar("boa_debrislifetime");

		gravity = FRandom[Confetti](0.0005, 0.0225);
		frame = Random[Confetti](0, 5);
	}
}