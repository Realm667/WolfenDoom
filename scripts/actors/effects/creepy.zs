/*
 * Copyright (c) 2021 Maelstrom, Ozymandias81, AFADoomer
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

//This actor is based over Maelstrom's Phantom attacks
class CreepyGhost : ParticleBase
{
	Default
	{
		Radius 16;
		Height 32;
		Health 1;
		Mass 500;
		Speed 16;
		Damage 1;
		DamageType "Creepy";
		Projectile;
		-SOLID
		+FLOAT
		+FRIENDLY
		+LOOKALLAROUND
		+NOBLOCKMONST
		+NOBLOOD
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.5;
	}

	States
	{
		Spawn:
			SPI1 A 0 A_StartSound("creepy/born");
		See:
			"####" AABB 2 A_FastChase;
			Loop;
		Melee:
			"####" A 4 A_FaceTarget;
			"####" B 2 A_Die;
			Stop;
		Death:
			"####" E 0 A_Explode(100, int(Radius + 16));
			"####" E 0 A_StartSound("creepy/dies");
		DeathLoop:
			"####" FGHIJ 2;
			Stop;
	}
}

class CreepyGhost2 : CreepyGhost
{
	Default
	{
		ReactionTime 128;
		+NOBLOCKMAP
	}

	States
	{
		Spawn:
			SPI1 A 0 A_StartSound("creepy/born");
		See:
			"####" AABB 2 { A_FastChase(); A_Countdown(); }
			Loop;
		Death:
			"####" E 0 A_StartSound("creepy/dies");
			"####" FGHIJ 2 A_Fadeout(0,004);
			Stop;
	}
}

class CreepyGhostSpawner : EffectSpawner
{
	int count, spawnflags, amount;
	class<Actor> spawnclass;
	double spawnangle;

	Property SpawnClass:spawnclass;
	Property SpawnFlags:spawnflags;
	Property SpawnCycles:amount;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Creepy Ghosts Spawner (DO NOT SET THIS DORMANT)
		//$Color 12
		//$Sprite SPI1A1
		-SOLID
		+CLIENTSIDEONLY
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+NOSECTOR
		+EffectSpawner.AllowTickDelay
		-EffectSpawner.DoActivation
		CreepyGhostSpawner.SpawnClass "CreepyGhost";
		CreepyGhostSpawner.SpawnFlags SXF_NOCHECKPOSITION | SXF_SETMASTER | SXF_CLIENTSIDE;
		CreepyGhostSpawner.SpawnCycles 8;
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Wait;
		Active:
			TNT1 A 1 SpawnEffect();
			Loop;
		Hold:
			TNT1 A 35;
			Loop;
		Inactive:
			TNT1 A -1 A_RemoveChildren(TRUE, RMVF_MISC);
			Stop;
	}

	// The original actor spawned 296 actors all at once; this one spaces them out by at 
	// least one tic per bach of spawns, but the end effect is the same after a few seconds
	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (spawnangle == 0) { A_SpawnItemEx(spawnclass, Random(-128, 128), 0, 0, 0, 0, Random(1, 4), Random(0, 360), spawnflags, 128); }

		count += A_SpawnItemEx(spawnclass, Random(32, 192), 0, 0, 0, 0, Random(1, 4), spawnangle, spawnflags, 0);
		count += A_SpawnItemEx(spawnclass, Random(32, 192), 0, 0, 0, 0, Random(1, 4), spawnangle + 10, spawnflags, 0);
		count += A_SpawnItemEx(spawnclass, Random(32, 192), 0, 0, 0, 0, Random(1, 4), spawnangle + 20, spawnflags, 0);
		count += A_SpawnItemEx(spawnclass, Random(32, 192), 0, 0, 0, 0, Random(1, 4), spawnangle + 30, spawnflags, 0);
		count += A_SpawnItemEx(spawnclass, Random(32, 192), 0, 0, 0, 0, Random(1, 4), spawnangle + 40, spawnflags, 0);
		count += A_SpawnItemEx(spawnclass, Random(32, 192), 0, 0, 0, 0, Random(1, 4), spawnangle + 50, spawnflags, 0);

		spawnangle = (spawnangle + 60) % 360;

		double ratescaling = manager ? max(0.1, 1.0 - (manager.tickdelay / 10)) : 1.0; // Scale the max number spawned in more effects-intense areas

		if (count >= amount * 36 * ratescaling / 4) { SetStateLabel("Hold"); }
	}
}

class CreepyGhostSpawner2 : CreepyGhostSpawner
{
	Default
	{
		CreepyGhostSpawner.SpawnClass "CreepyGhost";
		+EffectSpawner.DoActivation
		CreepyGhostSpawner.SpawnCycles 15;
	}

	States
	{
		Hold:
			"####" A 1 A_Countdown();
			Loop;
		Death:
			"####" A -1;
			Stop;
	}
}

//This actor is used by Totengraber_Wounded for his Raise effect
class CreepyRaise : SimpleActor
{
	Default
	{
		Radius 40;
		Height 60;
		Renderstyle "Add";
		Alpha 0.0;
		Scale 0.0;
		-SOLID
		+BRIGHT
		+NOGRAVITY
		+NOINTERACTION
	}

	States
	{
		Spawn:
			SWRL A 0;
			SWRL A 0 A_StartSound("creepyrift/short", CHAN_AUTO);
			SWRL AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIII 1
			{
				scale.x += 0.0125;
				scale.y += 0.0125;
				A_FadeIn(0.025);
			}
			SWRL J 4;
			SWRL KKKKLLLLMMMMNNNNOOOOPPPPQQQQRRRRSSSS 1
			{
				scale.x -= 0.0125;
				scale.y -= 0.0125;
				A_FadeOut(0.025);
			}
			Stop;
	}

	override void Tick()
	{
		Super.Tick();

		A_AttachLight("Glow", DynamicLight.PointLight, 0x78FF73, int(0.5 * Radius * alpha / 1.0), 0, DynamicLight.LF_ATTENUATE);
	}
}

class CreepyRaiseFlat : CreepyRaise
{
	Default
	{
		+FLATSPRITE
	}

	override void Tick()
	{
		Super.Tick();

		if (globalfreeze || level.Frozen) { return; }

		if (level.time % int(2 / max(0.001, scale.x))  == 0)
		{
			double r = Radius * scale.x * 1.5;

			// Swirl-green sparks
			Actor s = Spawn("FountainSoul2", pos + (FRandom(-r, r), FRandom(-r, r), 0));
			if (s)
			{
				s.alpha = alpha;
				s.vel.z = 3.0;
				s.tics = 5;
			}
		}
	}
}