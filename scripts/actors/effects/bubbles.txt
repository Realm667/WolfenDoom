class BubbleSpawner : EffectSpawner
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Underwater Bubble Spawner
		//$Color 12
		//$Sprite SBUBA0
		Radius 2;
		Height 2;
		+NOINTERACTION
		EffectSpawner.Range 1280;
		EffectSpawner.SwitchVar "boa_bubbleswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 2 SpawnEffect();
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx("Bubble", random (-16, 16), 0, 0, 0, 0, 2, random (0, 360), 0, 128);
	}
}

class Bubble : ParticleBase
{
	int ticker;

	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Scale 0.05;
		Alpha 0.25;
		RenderStyle "Add";
		Projectile;
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
		+NOCLIP
	}

	States
	{
		Spawn:
			SBUB A 1;
			Loop;
	}

	override void Tick()
	{
		if (!waterlevel) { Destroy(); } // Disappear at water surface
		else if (pos.z + height == ceilingz) // Fade out on ceilings
		{
			ticker++;

			if (ticker > 70)
			{
				alpha -= 0.01;
				if (alpha <= 0) { Destroy(); }
			}
		}

		if (Random() < 32) // Randomly move slightly on x/y axis
		{
			angle = Random(0, 360);
			vel.xy = RotateVector((-0.1, 0), angle);
		}

		Super.Tick();
	}
}

class PlayerBubble : Bubble
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		vel.z += FRandom(1.0, 3.0);
	}
}