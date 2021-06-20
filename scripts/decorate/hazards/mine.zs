/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer,
 *                         Talon1024
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

class Mine : GrenadeBase
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title Mine
		//$Color 3
		Radius 30;
		Height 12;
		Health 1000;
		+ACTIVATEMCROSS
		+DONTGIB
		+DONTTHRUST
		+LOOKALLAROUND
		+NOBLOOD
		+NOICEDEATH
		+NOTAUTOAIMED
		+SHOOTABLE
		+TOUCHY
		DeathSound "panzer/explode";
		Obituary "$OBMINE";
		GrenadeBase.FearDistance 128;
		GrenadeBase.SplashType "Mine";
		DamageFactor "Explosion", 0;
	}
	States
	{
	Spawn:
	See:
		MINE A 6 A_Chase;
		Loop;
	Death:
		"####" A 8 A_StartSound("MINEF");
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnGroundSplash;
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Medium");
		"####" A 0 A_SpawnItemEx("ZCrater");
		Stop;
	}
}

class MineInvisible : Mine
{
	Default
	{
		//$Title Mine (invisible)
		Radius 24;
		Height 12;
		RenderStyle "None";
	}
}

class PlacedMine : Mine
{
	Default
	{
		//$Title Friendly Mine (from Deployable item)
		Health 1;
		GrenadeBase.FearDistance 24;
		Obituary "$OBDMINE";
		DeathSound "clusterbomb/explode";
		-TOUCHY
	}

	States
	{
		Spawn:
			BOAM A -1;
			Wait;
		Death:
			"####" A 8
			{
				Actor mo = Spawn("Smoke_Small", pos);
				if (mo) { mo.vel.z = 0.25; }
				
				A_StartSound("MINEF");
			}
			"####" A 35;
			"####" A 3
			{
				A_StartSound("mine/player/launch", CHAN_AUTO);
				A_StartSound("EXPLOSION_SOUND", CHAN_AUTO, 0, 0.25);
			}
			"####" A 8
			{
				A_SpawnGroundSplash();

				Actor crater = Spawn("ZCrater", pos);
				if (crater) { crater.scale /= 2; }

				vel.z += 8.0;
			}
			"####" A 0
			{
				A_Scream();
				A_StartSound("nebelwerfer/xplode", CHAN_AUTO);

				Actor mo = Spawn("FriendlyExplosion_Medium", pos);
				if (tracer && mo) { mo.master = tracer; }

				Spawn("KD_HL2SmokeGenerator", pos);
				Spawn("KD_HL2SparkGenerator", pos);

				for (int i = 0; i < 20; ++i) { A_SpawnItemEx("ClusterBomb_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0); }

				Radius_Quake(10,10,0,16,0);
			}
			Stop;
	}

	override void Tick()
	{
		Super.Tick();

		if (!bTouchy && tracer)
		{
			bTouchy = !!(Distance3D(tracer) > radius + 64.0);
		}
	}
}

class BossEnemyPlacedMine : PlacedMine
{
	States
	{
	Spawn:
		BOAM A 35 NODELAY A_CheckProximity("SpawnWait", "HimmlerBoss", radius+64, 1, CPXF_SETTARGET); //wait 1 sec
	See:
		"####" A 0 A_CheckProximity("SpawnWait", "HimmlerBoss", radius+64, 1, CPXF_SETTARGET);
		"####" A 35 {A_Chase(); bTouchy = TRUE; A_CheckProximity("SpawnWait", "HimmlerBoss", radius+64, 1, CPXF_SETTARGET);}
		Loop;
	Death:
		"####" A 8 A_StartSound("MINEF");
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnGroundSplash;
		"####" A 0 A_SpawnItemEx("EnemyExplosion_Medium");
		"####" A 0 A_SpawnItemEx("ZCrater");
		Stop;
	}
}

class UnderwaterMine : Mine
{
	int user_theta;
	Default
	{
		//$Title Underwater Mine
		Radius 16;
		Height 128;
		Health 300;
		+NOGRAVITY
	}
	States
	{
	Spawn:
	See:
		UWMI HIJKL 6 A_Chase;
		Loop;
	Death:
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_Medium",0,0,64);
		UWMI H 12 A_Scream;
	Shock:
		UWMI H 0 A_SpawnProjectile("Bubble",random(64,76),0,user_theta,2);
		"####" H 0 { user_theta = user_theta+20; }
		"####" H 0 A_JumpIf(user_theta==360,1);
		Loop;
		"####" H 1 A_RemoveTarget(RMVF_EVERYTHING, "UnderwaterMineChain");
		UWMI A 0 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		"####" ABCDE 6;
		"####" F -1;
		Stop;
	}
}

class UnderwaterMineChain: Actor
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title Underwater Mine (longer Chain)
		//$Color 3
		Radius 16;
		Height 128;
		Mass 9999999;
		+NOGRAVITY
	}
	States
	{
	Spawn:
		UWMI G -1;
		Stop;
	}
}