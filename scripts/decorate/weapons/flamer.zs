/*
 * Copyright (c) 2015-2022 Tormentor667, Ozymandias81, Ed the Bat, MaxED, Talon1024,
 *						 AFADoomer
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

class Pyrolight : NaziWeapon
{
	Default
	{
		//$Category Weapons (BoA)
		//$Title (5) Pyrolight
		//$Color 14
		Scale 0.5;
		Tag "$TAGPYROL";
		Inventory.PickupMessage "$PYRO";
		Weapon.AmmoType "PyrolightLoaded";
		Weapon.AmmoType2 "FlameAmmo";
		Weapon.AmmoUse 1;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive2 50;
		Weapon.SelectionOrder 800;
		Weapon.UpSound "flamer/select";
	}

	States
	{
		Ready:
			FFTR A 1 {
				int readyflags = 0;
				if (
					invoker.Owner.CheckInventory(invoker.AmmoType2, 1) && 
					!invoker.Owner.CheckInventory(invoker.AmmoType1, GetDefaultByType(invoker.AmmoType1).MaxAmount)
				) { readyflags |= WRF_ALLOWRELOAD; }
				if (waterlevel >= 2) { readyflags |= WRF_NOFIRE | WRF_NOBOB; }

				A_WeaponReady(readyflags);
			}
			Loop;
		Deselect:
			FFTR A 1 A_Lower(12);
			Loop;
		Select:
			FFTR A 1 A_Raise(12);
			Loop;
		Fire:
			FFTR A 0 A_JumpIf(waterlevel >= 2, "Ready");
			FFTR A 0 A_JumpIfInventory(invoker.AmmoType1, 1, "Fire.Loaded");
			Goto Dryfire;
		Fire.Loaded:
			FFTF A 1 Offset(0,35) {
				A_Light2();
				A_AlertMonsters();
				A_FireProjectile("Flamebolt");
			}
			FFTF A 1 Offset(0,36);
			FFTF A 20 {
				A_Light0();
				A_Refire();
				A_GunFlash();
			}
			Goto Ready;
		Flash:
			FFTF B 2 A_StartSound("flamer/steam",CHAN_5);
			FFTF CDEF 2;
			Stop;
		AltFire:
			FFTR A 0 A_JumpIf(waterlevel >= 2, "Ready");
			FFTR A 0 A_JumpIfInventory(invoker.AmmoType1, 1, "AltFire.Loaded");
			Goto DryFire;
		AltFire.Loaded:
			FFTF A 1 {
				int amt = min((invoker.FindInventory(invoker.AmmoType1)).amount, 10);
				A_TakeInventory(invoker.AmmoType1, amt, TIF_NOTAKEINFINITE);
				A_StartSound("flamer/napalm", CHAN_WEAPON, 0, amt / 10.0);
				A_AlertMonsters();
				Actor p = A_FireProjectile("Flameball", 0, 0);
				if (p && amt < 10)
				{
					// Reduce range of final partial shot, if there are less then 10 ammo remaining
					p.alpha *= amt / 10.0;
				}
			}
			FFTF A 1 Offset(0,34);
			FFTF A 1 Offset(0,36);
			FFTR A 1 Offset(0,40);
			FFTR A 1 Offset(0,44);
			FFTR A 1 Offset(0,45);
			FFTR A 1 Offset(0,43);
			FFTR A 1 Offset(0,40);
			FFTR A 1 Offset(0,36);
			FFTR A 11 Offset(0,32) A_GunFlash;
			Goto Ready;
		Reload:
			FFTR B 1 Offset(0,35) A_StartSound("flamer/reload",CHAN_5);
			FFTR B 1 Offset(0,38) A_Reloading(true);
			FFTR B 1 Offset(0,40);
			FFTR B 1 Offset(0,42);
			FFTR B 1 Offset(0,44);
			FFTR B 1 Offset(0,47);
			FFTR C 1 Offset(0,50);
			FFTR C 1 Offset(0,52);
			FFTR C 1 Offset(-1,54);
			FFTR C 1 Offset(-2,56);
			FFTR D 1 Offset(-3,58);
			FFTR D 1 Offset(-4,58);
			FFTR D 1 Offset(-4,57);
			FFTR D 1 Offset(-4,56);
			FFTR E 1 Offset(-4,55);
			FFTR E 1 Offset(-3,54);
			FFTR E 1 Offset(-3,53);
			FFTR E 1 Offset(-3,52);
			FFTR F 1 Offset(-3,51);
			FFTR F 1 Offset(-3,52);
			FFTR F 1 Offset(-3,53);
			FFTR F 1 Offset(-3,55);
			FFTR F 1 Offset(-3,56) A_SpawnItemEx("PyroCasing",-12,8,32,8,random(-2,2),random(0,4),random(55,80),SXF_NOCHECKPOSITION);
		ReloadLoop:
			FFTR B 0 A_TakeInventory(invoker.AmmoType2,1,TIF_NOTAKEINFINITE);
			FFTR B 0 A_GiveInventory(invoker.AmmoType1);
			FFTR B 0 A_JumpIfInventory(invoker.AmmoType1,0,"ReloadFinish");
			FFTR B 0 A_JumpIfInventory(invoker.AmmoType2,1,"ReloadLoop");
		ReloadFinish:
			FFTR F 1 Offset(-3,57);
			FFTR F 1 Offset(-3,59);
			FFTR F 1 Offset(-3,61);
			FFTR F 1 Offset(-3,63);
			FFTR F 1 Offset(-3,65);
			FFTR F 1 Offset(-3,67);
			FFTR F 1 Offset(-3,65);
			FFTR F 1 Offset(-3,64);
			FFTR F 1 Offset(-3,63);
			FFTR E 1 Offset(-3,62);
			FFTR E 1 Offset(-3,58);
			FFTR E 1 Offset(-3,55);
			FFTR E 1 Offset(-2,53);
			FFTR E 1 Offset(-2,51);
			FFTR E 1 Offset(-2,49);
			FFTR E 1 Offset(-2,48);
			FFTR E 1 Offset(-2,46);
			FFTR E 1 Offset(-2,45);
			FFTR D 1 Offset(-1,44);
			FFTR D 1 Offset(-1,46);
			FFTR D 1 Offset(-1,47);
			FFTR D 1 Offset(0,49);
			FFTR D 1 Offset(0,47);
			FFTR D 1 Offset(0,45);
			FFTR D 1 Offset(0,44);
			FFTR D 1 Offset(0,42);
			FFTR D 1 Offset(0,40);
			FFTR C 1 Offset(0,38);
			FFTR C 1 Offset(0,37);
			FFTR C 1 Offset(0,36);
			FFTR C 1 Offset(0,35);
			FFTR C 1 Offset(0,34);
			FFTR C 1 Offset(0,33);
			FFTR C 1 Offset(0,32);
			FFTR C 1 Offset(2,34);
			FFTR C 1 Offset(4,36);
			FFTR B 1 Offset(6,38);
			FFTR B 1 Offset(8,40);
			FFTR B 1 Offset(8,41);
			FFTR B 1 Offset(8,42);
			FFTR B 1 Offset(8,43);
			FFTR B 1 Offset(8,44);
			FFTR B 1 Offset(8,45);
			FFTR B 1 Offset(8,46);
			FFTR B 1 Offset(8,47);
			FFTR B 1 Offset(8,48);
			FFTR B 1 Offset(8,47);
			FFTR B 1 Offset(8,46);
			FFTR B 1 Offset(8,45);
			FFTR B 1 Offset(8,44);
			FFTR B 1 Offset(8,43);
			FFTR A 1 Offset(8,44);
			FFTR A 1 Offset(9,45);
			FFTR A 1 Offset(10,46);
			FFTR A 1 Offset(9,47);
			FFTR A 1 Offset(8,48);
			FFTR A 1 Offset(7,47);
			FFTR A 1 Offset(6,46);
			FFTR A 1 Offset(5,45);
			FFTR A 1 Offset(6,44);
			FFTR A 1 Offset(7,43);
			FFTR A 1 Offset(8,42);
			FFTR A 1 Offset(4,40);
			FFTR A 1 Offset(3,35);
			FFTR A 1 Offset(2,34);
			FFTR A 1 Offset(1,33) A_Reloading(false);
			Goto Ready;
		Spawn:
			FLMT A -1;
			Loop;
	}
}

class PyrolightLoaded : Ammo
{
	Default
	{
		Tag "$TAGPETRO";
		Inventory.MaxAmount 50;
		+INVENTORY.IGNORESKILL
		Inventory.Icon "FLAM02";
	}
}

class Flamebolt : GrenadeBase
{
	ParticleManager manager;

	Default
	{
		Radius 16;
		Speed 25;
		Scale 0.1;
		Alpha 0.9;
		DamageFunction (Random(1, 4));
		DamageType "Fire";
		Decal "Scorch";
		Obituary "$OBPYRO";
		ProjectileKickback 20;
		RenderStyle "Add";
		SeeSound "flamer/fire";
		GrenadeBase.FearDistance 96;
		Projectile;
		+BLOODLESSIMPACT
		+RIPPER
		+WINDTHRUST
	}

	States
	{
		Spawn:
			"####" AAAAA 3 BRIGHT LIGHT("BOAFLAMW") {
				A_SetScale(Scale.X + 0.05);
				A_FadeOut(0.05);
				A_Explode(2,16);
				A_RadiusGive("HeatShaderControl", radius + 64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0)
				{
					vel *= 0;
					SpawnSmoke();
					SetStateLabel("Death");
				}
			}
			"####" A 0 SpawnSmoke();
		Death:
			"####" A 0 A_SpawnItemEx("ZScorch");
		Death.Loop:
			"####" A 1 LIGHT("BOAFLAMW") {
				scale += (0.05, 0.05);
				A_FadeOut(0.05);
				A_Explode(2, 64);
			}
			Goto Death.Loop;
		Sprites:
			FLM1 A 0;
			FLM2 A 0;
			FLM3 A 0;
			FLM4 A 0;
	}

	override void PostBeginPlay()
	{
		manager = ParticleManager.GetManager();

		sprite = GetSpriteIndex("FLM" .. Random(1, 4));

		Super.PostBeginPlay();
	}

	virtual void SpawnSmoke()
	{
		Spawn("FlamerSmoke" .. Random(1, 3), pos);
	}

	virtual void SpawnFlame()
	{
		Spawn("Flame_Small", pos);
	}
}

class Flameball : Flamebolt
{
	Default
	{
		Damage 30;
		Speed 20;
		Scale 0.3;
		-RIPPER
		+WINDTHRUST
		SeeSound "flamer/napalm";
		DeathSound "nebelwerfer/xplode";
		RenderStyle "Add";
		GrenadeBase.FearDistance 256;
	}

	States
	{
		Spawn:
			FBAL A 2 BRIGHT LIGHT("BOAFLMW2") {
				if (alpha < Default.alpha) { A_FadeOut(0.05); }

				int maxsparks = 3;
				if (manager) { maxsparks = int(maxsparks * manager.particlescaling); }
				for (int s = 0; s < maxsparks; s++)
				{
					A_SpawnItemEx("TracerSpark", random(-32,32), random(-32,32), random(-32,32), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				}

				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 64);
				if (waterlevel > 0 || alpha <= 0)
				{
					vel *= 0;
					SetStateLabel("Death");
				}
			}
			"####" A 0 {
				SpawnSmoke();
				SpawnFlame();
				if (Random() > 192) { SpawnFlame(); }
			}
			Loop;
		Death:
			FBLX A 2 BRIGHT LIGHT("BOAFLMW2") {
				A_SpawnItemEx("NebFloor");
				A_SpawnItemEx("NebSmokeFloor");
				A_SpawnItemEx("NebSmokeMushroom",0,0,0);
				A_SpawnItemEx("NebSmokePillar",0,0,0,0,0,2);
				A_SetScale(1.0);

				int maxsparks = 20;
				if (manager) { maxsparks = int(maxsparks * manager.particlescaling); }
				for (int s = 0; s < maxsparks; s++)
				{
					A_SpawnItemEx("TracerSpark", random(-32,32), random(-32,32), random(-32,32), random(-4,4), random(-4,4), random(-4,4), random(0,359));
				}

				A_Explode(96, 128);
				A_SpawnItemEx("ZScorch");
				A_RadiusGive("BlurShaderControl", 128, RGF_PLAYERS | RGF_GIVESELF, 80);
			}
			FBLX BCDEFGHIJK 2 BRIGHT LIGHT("BOAFLMW2");
			Stop;
	}
}

class Flameball_Neb : Flameball
{
	Default
	{
		Scale 0.1;
	}

	States
	{
		Death:
			"####" A 0 {
				for (int t = 0; t < 40; t++)
				{
					A_SpawnitemEx("ClusterBomb_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0);
				}
			}
			Goto Super::Death;
	}
}

class Flameball_Scenery : Flameball { Default { +NEVERTARGET } }

//Flames and particles
class FlamerSmoke1: ParticleBase
{
	Default
	{
		Height 2;
		Radius 1;
		Alpha 0.1;
		Scale 0.3;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+WINDTHRUST
	}

	States
	{
		Spawn:
			SMOC AAAAAAAA 1 NoDelay A_FadeIn(.05);
		FadeOut:
			SMOC A 3 A_FadeOut(.05);
			Loop;
	}

	override void PostBeginPlay()
	{
		if (!boa_smokeswitch)
		{
			Destroy();
			return;
		}

		vel.z = FRandom(0.5, 1.5);
		vel.xy = RotateVector((Random(0, 1), 0), Random(0, 359));

		Super.PostBeginPlay();
	}
}

class FlamerSmoke2 : FlamerSmoke1 { Default { Scale 0.5; } }
class FlamerSmoke3 : FlamerSmoke1 { Default { Scale 0.7; } }