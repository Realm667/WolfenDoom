/*
 * Copyright (c) 2020 Kevin Caccamo, AFADoomer
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

/*
Soul Fountain - gives souls and health to any players standing near it

For final battle with Hitler on C3M6_B
*/
class SoulFountain : SwitchableDecoration
{
	int count;
	int soulmax;
	int healthmax;

	Property MaxSouls: soulmax;
	Property MaxHealth: healthmax;

	Default
	{
		//$Category Misc (BoA)
		//$Title Soul Fountain
		//$Arg0 "Maximum souls for player"
		//$Arg0Default 150
		//$Arg1 "Maximum health for player"
		//$Arg1Default 200
		//$Sprite SWRLZ0
		Height 32;
		Radius 64;
		RenderStyle "Add";
		SoulFountain.MaxSouls 150;
		SoulFountain.MaxHealth 200;
		-SOLID
		-SHOOTABLE
		+NOBLOCKMAP
		+FLATSPRITE
		+NOGRAVITY
	}

	States
	{
	Spawn:
		SWRL YXWVUTSRQPONMLKJIHGFEDCBA 2 A_SpawnVFX;
		Loop;
	Inactive:
		SWRL YXWVUTSRQPONMLKJIHGFEDCBA 2 A_FadeOut(.05, FTF_CLAMP);
		TNT1 A -1;
		Stop;
	Active:
		SWRL YXWVUTSRQPONMLKJIHGFEDCBA 2 A_FadeIn(.05, FTF_CLAMP);
		Goto Spawn;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		// Match size to scaled size
		A_SetSize(radius * scale.x, height * scale.y);

		// Use arguments to override default amounts if they are set
		if (args[0]) { soulmax = args[0]; }
		if (args[1]) { healthmax = args[1]; }

		count = 0;
	}

	void A_SpawnVFX()
	{
		double SpawnRadius = Radius;
		Vector3 SpawnPointOffset = (FRandom[creepyvfx](-SpawnRadius, SpawnRadius), FRandom[creepyvfx](-SpawnRadius, SpawnRadius), -32.0);
		Vector3 SpawnPoint = Pos + SpawnPointOffset;

		// Spawn one of three effect actors 
		Actor s = Spawn("FountainSoul" .. Random(0, 2), SpawnPoint, NO_REPLACE);
		if (s)
		{
			s.master = self;
			s.vel.z = 3.5;
		}

		count += 1;
		if (count == 2)
		{
			A_Fountain();
			count = 0;
		}
	}

	void A_Fountain()
	{
		double distance = Radius;
		distance *= distance;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (playeringame[i] && Distance2DSquared(players[i].mo) < distance)
			{
				A_GiveShit(players[i].mo, 1);
			}
		}
	}

	void A_GiveShit(Actor to, int amount)
	{
		Inventory souls = to.FindInventory("Soul");
		if (!souls || souls.amount < soulmax)
		{
			to.A_GiveInventory("Soul", amount);
		}
		if (to.health < healthmax)
		{
			to.GiveBody(amount);
		}
	}

	override void Tick()
	{
		Super.Tick();

		// Give the swirl a green glow
		if (bDormant) { A_RemoveLight("Glow"); }
		else { A_AttachLight("Glow", DynamicLight.PointLight, 0x78FF73, int(0.25 * Radius * alpha / Default.alpha), 0, DynamicLight.LF_ATTENUATE, (0.0, 0.0, 32.0)); }
	}
}

// Lightweight flying soul look-alike that spirals up around the spawner
class FountainSoul0 : SimpleActor
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 3.0;
		Alpha 0.8;
		Scale 1.0;
		RenderStyle "Translucent";
		Projectile;
		DistanceCheck "boa_sfxlod";
		+BRIGHT
		+CLIENTSIDEONLY
		+NOINTERACTION
	}

	States
	{
		Spawn:
			AMM3 ABCD 5;
		FadeOut:
			AMM3 ABCD 5 A_FadeOut(0.15);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		scale *= 1.0 + FRandom(-0.7, 0.3);

		A_StartSound("DSSLPU", CHAN_VOICE, 0, 0.05 * scale.x, ATTN_STATIC, 1.3 - scale.x);
	}

	override void Tick()
	{
		if (globalfreeze || level.frozen) { return; }

		vel.z = Default.Speed;

		A_AttachLight("Glow", DynamicLight.PointLight, 0x78FF73, int(24 * scale.x * alpha / Default.alpha), 0, DynamicLight.LF_ATTENUATE, (0.0, 0.0, 32.0));

		if (Level.time % 2 == 0)
		{
			Actor sf = Spawn("SoulTrail", pos - vel);
			if (sf) { sf.master = self; }
		}

		if (master) { Orbit(master, -1); }

		Super.Tick();
	}

	void Orbit(Actor center, int dir = 1, double offset = 0.0)
	{
		if (!center) { return; }

		vel.xy = RotateVector((Speed - Default.Speed, dir * Speed), AngleTo(center) + offset);
	}
}

// ZScriptified, silent, scaled down version of DamnedSoul
class FountainSoul1 : SimpleActor
{
	Default
	{	
		Radius 2;
		Height 2;
		Speed 1;
		Alpha 0;
		Scale 0.65;
		RenderStyle "Add";
		Projectile;
		+BRIGHT
		+CLIENTSIDEONLY
		+NOINTERACTION
	}

	States
	{
		Spawn:
			HADE D 1 {
				alpha += 0.03;
				if (alpha >= 0.36) { SetStateLabel("Linger"); }
			}
			Loop;
		Linger:
			HADE D 4;
		FadeOut:
			HADE D 1 A_FadeOut(0.02);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		scale *= 1.0 + FRandom(-0.7, 0.3);
	}
}

// Green spark that matches the swirl color
class FountainSoul2 : SparkG
{
	Default
	{
		+NOGRAVITY
		+NOINTERACTION
		SparkBase.SparkColor "18a476"; // Swirl green
	}

	States
	{
		Spawn:
			"####" E 35 Bright; // Only stick around for one second before fading out
			Goto Death;
	}
}