/*
 * Copyright (c) 2015-2022 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

class PestSpawner : Actor
{
	Class<Actor> spawnactor;

	Property SpawnActor:spawnactor;

	Default
	{
		//$Category Fauna (BoA)
		//$Color 0
		//$Arg0 "Amount"
		//$Arg0Tooltip "Amount to spawn (default 5)"
		//$Arg0Default 5
		//$Arg1 "Radius"
		//$Arg1Tooltip "Radius in map units (default 8)"
		//$Arg1Default 8

		Radius 2;
		Height 2;
		+NOINTERACTION
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!args[0]) { args[0] = 5; }
		if (!args[1]) { args[1] = 8; }

		for (int s = 0; s < args[0]; s++)
		{
			Spawn(spawnactor, pos + (FRandom(-args[1], args[1]), FRandom(-args[1], args[1]), 0));
		}
	}
}

class Pest : Base
{
	Default
	{
		Health 1;
		-CANUSEWALLS
		-CANPUSHWALLS
		+AMBUSH
		+FLOORCLIP
		+FRIGHTENED
		+LOOKALLAROUND
		+NEVERRESPAWN
		+TOUCHY
		+VULNERABLE
	}

	States
	{
		Vanish:
			TNT1 A 1;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		angle = Random(0, 359);
		movedir = Random(0, 7);
		interval = Random(15, 35);
	}

	override void Tick()
	{
		Super.Tick();

		if (IsFrozen() || globalfreeze || health <= 0 || !target) { return;}

		if (GetAge() % interval == 0) { movedir = (movedir + Random(-1, 1)) % 8; }
	}
}

class RatSpawner: PestSpawner
{
	Default
	{
		//$Title Rats
		//$Sprite MOUSA1
		PestSpawner.SpawnActor "ScurryRat";
	}
}

class ScurryRat : Pest
{
	Default
	{
		Radius 8;
		Height 8;
		Mass 50;
		Speed 8;
		Scale 0.20;
		ActiveSound "rat/active";
		DeathSound "rat/death";
		SeeSound "rat/squeek";
	}

	States
	{
		Spawn:
			MOUS A 10 A_LookThroughDisguise(0, 0, 0, 0, 360, "See");
			Loop;
		See:
			"####" A 1 A_Chase();
			"####" A 1 A_Chase(null, null, CHF_NOPLAYACTIVE);
			"####" A 0 A_CheckSight ("Vanish");
			"####" B 1 A_Chase();
			"####" B 1 A_Chase(null, null, CHF_NOPLAYACTIVE);
			"####" B 0 A_CheckSight ("Vanish");
			Loop;
		Death:
			"####" H 3 A_ScreamAndUnblock;
			"####" IJKL 3;
			"####" M -1;
			Stop;
	}
}

class RoachSpawner : PestSpawner
{
	Default
	{
		//$Title Roaches
		//$Arg0Default 30
		//$Arg1Default 64
		//$Sprite BUGSA0
		PestSpawner.SpawnActor "Roach";
	}

	override void PostBeginPlay()
	{
		if (!args[0]) { args[0] = 30; }
		if (!args[1]) { args[1] = 64; }

		Super.PostBeginPlay();
	}
}

class Roach : Pest
{
	Default
	{
		Radius 1;
		Height 1;
		Mass 1;
		Speed 3;
		Scale 0.25;
		ActiveSound "spider1/walk";
		SeeSound "";
		DeathSound "shark/death";
		+FLATSPRITE
	}

	States
	{
		Spawn:
			BUGS A 10 {
				tics = Random(1, 20);
				A_LookThroughDisguise(0, 0, 0, 0, 360, "See");
			}
			Loop;
		See:
			"####" ## 1 A_Chase(null, null, (GetAge() % (interval * 3) == 0 ? 0 : CHF_NORANDOMTURN) | CHF_NOPLAYACTIVE);
			"####" # 0 {
				if (ActiveSound) { A_StartSound(ActiveSound, CHAN_VOICE, CHANF_DEFAULT, 0.5 * scale.x, ATTN_NORM, 1.0 / scale.x); }
				if (
					(BlockingMobj && BlockingMobj.bSolid) ||
					(BlockingLine && !(BlockingLine.flags & Line.ML_TWOSIDED))
				) { Destroy(); }
				return A_CheckSight("Vanish");
			}
			Loop;
		Death:
			"####" E -1 {
				if (DeathSound) { A_StartSound(DeathSound, CHAN_VOICE, CHANF_DEFAULT, 0.5 * scale.x, ATTN_NORM, 1.0 / scale.x); }
				scale.x *= RandomPick(-1, 1);
			}
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		double factor = FRandom(0.4, 1.2);
		scale *= factor;
		speed *= factor;
	}

	override void Tick()
	{
		Super.Tick();

		if (IsFrozen() || globalfreeze || health <= 0) { return; }

		if (level.time % 5 == 0) { frame = (frame + 1) % 4; }
	}
}