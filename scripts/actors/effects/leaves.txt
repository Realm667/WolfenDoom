class LeavesSpawner : CinderSpawner
{
	Default
	{
		//$Title Leaves Spawner (vertical)
		//$Sprite LEFYA0
		+FLATSPRITE
		+LOOKALLAROUND
		+ROLLSPRITE
		EffectSpawner.Range 2400;
		EffectSpawner.SwitchVar "boa_leavesswitch";
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
		EffectSpawner.SpawnEffect();

		A_SpawnItemEx("FloatingLeaves", random(-Args[0],Args[0]), random(-Args[0],Args[0]), random(0,Args[1]), random(Args[2],Args[3]), 0, random(-Args[2],Args[2]), random(-4, 4), 128, Args[4]);
	}
}

class LeavesSpawnerHorizontal : LeavesSpawner //ZScript version of original code by T667
{
	Default
	{
		//$Title Leaves Spawner (horizontal)
	}


	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 3 SpawnEffect();
			Loop;
	}

	override void SpawnEffect()
	{
		EffectSpawner.SpawnEffect();

		A_SpawnItemEx("FloatingLeavesNoGravity", 0, random(-Args[0],Args[0]), random(0,Args[1]), random(Args[2],Args[3]), 0, 0, frandom(-4.0, 4.0), 128, Args[4]);
	}
}

class FloatingLeaves : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Radius 2;
		Height 4;
		Gravity 0.125;
		Scale 0.5;
		+DONTSPLASH
		+MISSILE
		+DROPOFF
		+NOTELEPORT
		+CANNOTPUSH
		+WINDTHRUST
		+FLATSPRITE
		+ROLLCENTER
		+ROLLSPRITE
		+ParticleBase.CHECKPOSITION
	}

	States
	{
		Spawn:
			LEFY ABCDEFGH 6 LeafFloat();
			Loop;
		Swim: //mxd
			"####" A 2 Swim();
			"####" B 2;
			"####" C 2 Swim();
			"####" D 2;
			"####" E 2 Swim();
			"####" F 2;
			"####" G 2 Swim();
			"####" H 2;
			Loop;
		Death:
			"####" A 1 {
				roll = 0;
				angle = 0;
				pitch = 0;

				bRollSprite = FALSE;

				frame = Random(1, 8);
			}
		DeathWait:
			"####" "#" 1 A_FadeOut(0.06); //change this if you plan to make leaves disappear fastly or slowly
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		scale.x += FRandom(0.15, 0.45);
		scale.y += FRandom(0.15, 0.45);
	}

	void LeafFloat()
	{
		gravity = FRandom(0.0525,0.0725);
		A_SetRoll(roll + FRandom(-55.5, 55.5), SPF_INTERPOLATE);
		angle += Random(-15, 15);
		pitch += FRandom(-55.25, 55.25);

		if (waterlevel == 3)
		{
			mass = 350;
			SetStateLabel("Swim");
		}
	}

	void Swim()
	{
		vel *= 0.7;
		A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
	}
}

class FloatingLeavesNoGravity : FloatingLeaves
{
	Default
	{
		+NOGRAVITY
		-FLATSPRITE
	}

	States
	{
		Spawn:
			LEFY ABCDEFGH 6 LeafFloat();
			Loop;
	}
}