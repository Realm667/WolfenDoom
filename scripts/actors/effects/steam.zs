/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, AFADoomer
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

class SteamSpawner : EffectSpawner
{
	int zoffset;
	double velx, velz;
	int ang;
	int freq;
	String snd;
	int sndflags;
	Class<Actor> particle;

	Property Particle:particle;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Steam Spawner
		//$Color 12
		//$Sprite STEMA0
		//$Arg0 "Direction"
		//$Arg0Tooltip "0 is up, 1 is down, 2 is forward (downfacing spawners should be placed 4 map units below the ceiling), 3 spawns aligned to angle/pitch of actor"
		//$Arg0Type 11
		//$Arg0Enum { 0 = "Up"; 1 = "Down"; 2 = "Forward"; 3 = "Dynamic"; }
		//$Arg0Default 3
		//$Arg1 "Type"
		//$Arg1Tooltip "Second argument chooses if it's a constant spawner, or spawns in bursts. Burst spawners use the third argument and play a different sound."
		//$Arg1Type 11
		//$Arg1Enum { 0 = "Constant"; 1 = "Bursts"; }
		//$Arg2 "Frequency"
		//$Arg2Tooltip "Third argument controls the frequency of the bursts (divided by 16. I.e, 128 will end up as 8). This is only used by the second argument."
		//$Arg3 "Sound"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Yes"; 1 = "No"; }
		Height 2;
		Radius 1;
		Mass 0;
		+CLIENTSIDEONLY
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		EffectSpawner.Range 2048;
		EffectSpawner.SwitchVar "boa_steamswitch";
		+EffectSpawner.ALLOWTICKDELAY
		SteamSpawner.Particle "SteamParticle";
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
		snd = args[1] > 0 && args[2] < 128 ? "STEAM_BURST" : "STEAM_SMALL";
		sndflags = args[1] > 0 ? CHANF_OVERLAP : CHANF_LOOPING;

		zoffset = args[0] == 0 ? 1 : 0;
		freq = args[2] + 1 / 16; // This math is incorrect, based on the description in the args above, but is how it was originally. *shrug* Order of operations matter!

		Super.PostBeginPlay();
	}

	override void Activate(Actor activator)
	{
		if (!args[1] && !args[3]) { A_StartSound(snd, 10, sndflags, 1.0); } // Constant steam plays a looped sound once on activation

		Super.Activate(activator);
	}

	override void Deactivate(Actor activator)
	{
		A_StopSound(10);

		Super.Deactivate(activator);
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if ((!args[1] || Random(0, 255) < freq))
		{
			if (args[1] && !args[3]) { A_StartSound(snd, 10, sndflags, 1.0); } // Each burst plays a sound on spawn

			Actor mo;

			if (args[0] < 3) // Original directional spawns
			{
				velx = args[0] < 2 ? 0.1 * Random(0, 4) : 0.1 * Random(35, 40);
				velz = args[0] < 2 ? (args[0] == 1 ? -1 : 1) * 0.1 * Random(35, 40) : 0.1 * Random(-5, 5);
				ang = args[0] < 2 ? Random(0, 360) : Random(-8, 8);

				bool sp;
				[sp, mo] = A_SpawnItemEx(particle, 0, 0, zoffset, velx, 0, velz, ang, 128);
			}
			else
			{
				mo = Spawn(particle);
				if (mo)
				{
					mo.alpha *= scale.x;
					mo.SetOrigin(pos + (FRandom(-2, 2), FRandom(-2, 2), FRandom(-2, 2)), false);
					mo.Vel3DFromAngle(0.1 * Random(35, 40) * scale.x, angle, pitch);
				}
			}

			if (mo && mo.bMissile && mo.Damage) { mo.ChangeStatNum(Thinker.STAT_DEFAULT - 6); } // Let damaging steam actors be seen by the grenade avoidance code
		}
	}
}

class SteamParticle : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Height 1;
		Radius 1;
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
		+WINDTHRUST
		+ROLLSPRITE
		Scale 0.04;
		Alpha 0.65;
	}

	States
	{
		Spawn:
			STEM A 0;
			"####" A 2 A_SetScale(Scale.X + 0.013, Scale.Y + 0.013);
			"####" A 0 A_FadeOut(0.04, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		roll = Random(1, 360);
	}
}

class ZyklonBSteamSpawner : SteamSpawner
{
	Default
	{
		//$Title Zyklon B Steam Spawner
		//$Sprite ZTEMA0
		SteamSpawner.Particle "ZyklonBSteamParticle";
	}
}

class ZyklonBSteamParticle : SteamParticle
{
	Default
	{
		Height 16;
		Radius 8;
		DamageFunction (random(1,8));
		PoisonDamage 4;
		DamageType "UndeadPoisonAmbience";
		Projectile;
	}

	States
	{
		Spawn:
			ZTEM A 0;
			"####" A 2 A_SetScale(Scale.X+0.013, Scale.Y+0.013);
			"####" A 0 A_FadeOut(.04,FTF_REMOVE);
			Loop;
	}
}

class ZyklonBSteamSpawner_C3M6A : SteamSpawner
{
	Default
	{
		//$Title Zyklon B Steam Spawner (long range)
		//$Sprite ZTEMA0
		SteamSpawner.Particle "ZyklonBSteamParticle_C3M6A";
	}
}

class ZyklonBSteamParticle_C3M6A : ZyklonBSteamParticle
{
	Default
	{
		DamageFunction (2*random(1,8));
		PoisonDamage 8;
	}

    States
	{
		Spawn:
			ZTEM A 0;
			"####" A 2 A_SetScale(Scale.X+0.002, Scale.Y+0.002);
			"####" A 0 A_FadeOut(.001,FTF_REMOVE);
			Loop;
	}
}
