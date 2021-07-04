/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, Talon1024,
 *                         AFADoomer
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
	Weapon.SelectionOrder 800;
	Inventory.PickupMessage "$PYRO";
	Weapon.AmmoType "PyrolightLoaded";
	Weapon.AmmoType2 "FlameAmmo";
	Weapon.AmmoUse 1;
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 50;
	Weapon.UpSound "flamer/select";
	Tag "$TAGPYROL";
	Scale 0.5;
	}
	States
	{
	Ready:
		FFTR A 0 A_JumpIfInventory("PyrolightLoaded",10,4);
		FFTR A 0 A_JumpIfInventory("FlameAmmo",1,2);
		FFTR A 1 A_WeaponReady(WRF_NOSECONDARY);
		Loop;
		FFTR A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_NOSECONDARY);
		Loop;
		FFTR A 0 A_JumpIfInventory("PyrolightLoaded",0,2);
		FFTR A 0 A_JumpIfInventory("FlameAmmo",1,2);
		FFTR A 1 A_WeaponReady;
		Loop;
		FFTR A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		FFTR A 0 A_Lower;
		FFTR A 1 A_Lower;
		Loop;
	Select:
		FFTR A 0 A_Raise;
		FFTR A 1 A_Raise;
		Loop;
	Fire:
		FFTR A 0 A_JumpIf(waterlevel>= 2,"NoWay");
		FFTR A 0 A_JumpIfInventory("PyrolightLoaded",1,1);
		Goto Dryfire;
		FFTF A 0 A_Light2;
		FFTF A 0 A_AlertMonsters;
		FFTF A 1 Offset(0,35) A_FireProjectile("Flamebolt");
		FFTF A 1 Offset(0,36);
		FFTF A 0 A_Light0;
		FFTR A 0 A_Refire;
		FFTR A 20 A_GunFlash;
		Goto Ready;
	Flash:
		FFTF B 2 A_StartSound("flamer/steam",CHAN_5);
		FFTF CDEF 2;
		Stop;
	NoWay:
		FFTR A 1 A_WeaponReady(WRF_NOFIRE|WRF_NOBOB);
		Goto Ready;
	AltFire:
		FFTR A 0 A_JumpIf(waterlevel>= 2,"NoWay");
		FFTR A 0 A_JumpIfInventory("PyrolightLoaded",10,1);
		Goto Dryfire;
		FFTF A 0 A_TakeInventory("PyrolightLoaded",10,TIF_NOTAKEINFINITE);
		FFTF A 0 A_StartSound("flamer/napalm",CHAN_WEAPON);
		FFTF A 0 A_AlertMonsters;
		FFTF A 1 A_FireProjectile("Flameball",0,0);
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
		FFTR B 1 Offset(0,38);
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
		FFTR B 0 A_TakeInventory("FlameAmmo",1,TIF_NOTAKEINFINITE);
		FFTR B 0 A_GiveInventory("PyrolightLoaded");
		FFTR B 0 A_JumpIfInventory("PyrolightLoaded",0,"ReloadFinish");
		FFTR B 0 A_JumpIfInventory("FlameAmmo",1,"ReloadLoop");
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
		FFTR A 1 Offset(1,33);
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
	Default
	{
	DamageFunction (random(1,4));
	Alpha 0.9;
	RenderStyle "Add";
	Speed 25;
	Radius 16;
	Scale 0.1;
	Projectile;
	+BLOODLESSIMPACT
	+RIPPER
	+WINDTHRUST
	SeeSound "flamer/fire";
	DamageType "Fire";
	Decal "Scorch";
	Obituary "$OBPYRO";
	ProjectileKickback 20;
	GrenadeBase.FearDistance 96;
	}
	States
	{
	Spawn:
		"####" A 0 NODELAY A_Jump(256, "Flame1", "Flame2", "Flame3", "Flame4");
		Stop;
	Flame1:
		FLM1 A 0;
		Goto Animation;
	Flame2:
		FLM2 A 0;
		Goto Animation;
	Flame3:
		FLM3 A 0;
		Goto Animation;
	Flame4:
		FLM4 A 0;
		Goto Animation;
	Animation:
		"####" AAAAA 3 BRIGHT LIGHT("BOAFLAMW")
			{
				A_SetScale(Scale.X+0.05);
				A_FadeOut(0.05);
				A_Explode(2,16);
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);
					return A_Jump(256, "Smoke1", "Smoke2", "Smoke3");
				}
				return ResolveState(null);
			}
		"####" A 0 A_Jump(128, "Smoke1", "Smoke2", "Smoke3");
		Goto Death;
	Smoke1:
		"####" A 0 A_SpawnItemEx("FlamerSmoke1");
		Goto Death;
	Smoke2:
		"####" A 0 A_SpawnItemEx("FlamerSmoke2");
		Goto Death;
	Smoke3:
		"####" A 0 A_SpawnItemEx("FlamerSmoke3");
		Goto Death;
	Death:
		"####" A 0 A_SpawnItemEx("ZScorch");
	Death.Loop:
		"####" A 1 LIGHT("BOAFLAMW")
			{
				A_SetScale(Scale.X+0.05);
				A_FadeOut(0.05);
				A_Explode(2,64);
			}
		Goto Death.Loop;
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
		FBAL A 2 BRIGHT LIGHT("BOAFLMW2")
			{
				A_SpawnItemEx("TracerSpark", random(-32,32), random(-32,32), random(-32,32), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SpawnItemEx("TracerSpark", random(-32,32), random(-32,32), random(-32,32), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SpawnItemEx("TracerSpark", random(-32,32), random(-32,32), random(-32,32), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 64);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);
					return ResolveState("Death");
				}
				return ResolveState(null);
			}
		"####" A 0 A_Jump(192, "Smoke1", "Smoke2", "Smoke3");
		Loop;
	Smoke1:
		"####" A 0 A_SpawnItemEx("FlamerSmoke1");
		"####" A 0 A_Jump (192,1,2);
		"####" A 0 A_SpawnItemEx("Flame_Small");
		"####" A 0 A_SpawnItemEx("Flame_Small");
		Goto Spawn;
	Smoke2:
		"####" A 0 A_SpawnItemEx("FlamerSmoke2");
		"####" A 0 A_Jump (192,1,2);
		"####" A 0 A_SpawnItemEx("Flame_Small");
		"####" A 0 A_SpawnItemEx("Flame_Small");
		Goto Spawn;
	Smoke3:
		"####" A 0 A_SpawnItemEx("FlamerSmoke3");
		"####" A 0 A_Jump (192,1,2);
		"####" A 0 A_SpawnItemEx("Flame_Small");
		"####" A 0 A_SpawnItemEx("Flame_Small");
		Goto Spawn;
	Death:
		"####" A 0 A_SpawnItemEx("NebFloor");
		"####" A 0 A_SpawnItemEx("NebSmokeFloor");
		"####" A 0 A_SpawnItemEx("NebSmokeMushroom",0,0,0);
		"####" A 0 A_SpawnItemEx("NebSmokePillar",0,0,0,0,0,2);
		"####" A 0 A_SetScale(1.0);
		"####" AAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("TracerSpark", random(-32,32), random(-32,32), random(-32,32), random(-4,4), random(-4,4), random(-4,4), random(0,359));
		FBLX A 2 BRIGHT LIGHT("BOAFLMW2") { A_Explode(96,128); A_SpawnItemEx("ZScorch"); }
		FBLX A 0 A_RadiusGive("BlurShaderControl", 128, RGF_PLAYERS | RGF_GIVESELF, 80);
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
		"####" A 0 A_SpawnItemEx("NebFloor");
		"####" A 0 A_SpawnItemEx("NebSmokeFloor");
		"####" A 0 A_SpawnItemEx("NebSmokeMushroom",0,0,0);
		"####" A 0 A_SpawnItemEx("NebSmokePillar",0,0,0,0,0,2);
		"####" A 0 A_SetScale(1.0);
		"####" AAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("TracerSpark", random(-32,32), random(-32,32), random(-32,32), random(-4,4), random(-4,4), random(-4,4), random(0,359));
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnitemEx("ClusterBomb_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0);
		FBLX A 2 BRIGHT LIGHT("BOAFLMW2") { A_Explode(96,128); A_SpawnItemEx("ZScorch"); }
		FBLX A 0 A_RadiusGive("BlurShaderControl", 128, RGF_PLAYERS | RGF_GIVESELF, 80);
		FBLX BCDEFGHIJK 2 BRIGHT LIGHT("BOAFLMW2");
		Stop;
	}
}

class Flameball_Scenery : Flameball { Default { +NEVERTARGET } }

//Flames and particles
class FlamerSmoke1: Actor
{
	Default
	{
	Height 2;
	Radius 1;
	+CLIENTSIDEONLY
	+DONTSPLASH
	+FORCEXYBILLBOARD
	+MISSILE
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	+WINDTHRUST
	Alpha 0.1;
	Scale 0.3;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		SMOC A 0;
	FadeIn:
		"####" A 0 ThrustThingZ(0,random(2,6),0,0);
		"####" A 0 ThrustThing(random(0,255),random(0,1),0,0);
		"####" AAAAAAAA 1 A_FadeIn(.05);
	FadeOut:
		"####" AAAA 3 A_FadeOut(.05);
		Loop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class FlamerSmoke2 : FlamerSmoke1 { Default { Scale 0.5; } }
class FlamerSmoke3 : FlamerSmoke1 { Default { Scale 0.7; } }