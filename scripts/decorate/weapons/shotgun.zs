/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, MaxED, Talon1024
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

class TrenchShotgun : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (3) Trench Shotgun
	//$Color 14
	Weapon.SelectionOrder 400;
	Weapon.AmmoType "TrenchShotgunLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "Ammo12Gauge";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 8;
	Weapon.UpSound "shotgun/select";
	Inventory.PickupMessage "$TRENSSG";
	+WEAPON.NOAUTOFIRE
	+NaziWeapon.NORAMPAGE
	Scale .5;
	Tag "M1897 Trenchgun";
	}
	States
	{
	Select:
		SHTG A 0 A_Raise;
		SHTG A 1 A_Raise;
		Loop;
	Deselect:
		SHTG A 0 A_JumpIfReloading(3);
		SHTG A 0 A_Lower;
		SHTG A 1 A_Lower;
		Loop;
		SHTG C 1 Offset(3,35) A_StartSound("shotgun/pump");
		SHTG C 1 Offset(-1,38);
		SHTG D 1 Offset(-4,41);
		SHTG D 1 Offset(-1,33);
		SHTG E 1 Offset(-2,37);
		SHTG E 1 Offset(-3,43);
		SHTG D 1 Offset(-2,40);
		SHTG D 1 Offset(-4,41);
		SHTG C 1 Offset(-1,38);
		SHTG C 1 Offset(3,35);
		SHTG B 1 Offset(-1,38);
		SHTG B 1 Offset(2,36);
		SHTG B 1 Offset(5,34) A_Reloading(0);
		Loop;
	Ready:
		SHTG A 0 A_JumpIfInventory("TrenchShotgunLoaded",0,2);
		SHTG A 0 A_JumpIfInventory("Ammo12Gauge",1,2);
		SHTG A 1 A_WeaponReady;
		Loop;
		SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Fire:
		SHTG A 0 A_JumpIfReloading("ReloadFinish");
		SHTG A 0 A_JumpIfInventory("TrenchShotgunLoaded",1,1);
		Goto Dryfire;
		SHTG A 0 A_TakeInventory("TrenchShotgunLoaded",1,TIF_NOTAKEINFINITE);
		SHTG A 0 A_StartSound("shotgun/fire", CHAN_WEAPON);
		SHTG A 0 A_AlertMonsters;
		SHTG AAAAAAAAAA 0 A_FireProjectile("ShotgunTracer",frandom(-2.0,2.0),0,0,0,0,frandom(-1.5,1.5));
		SHTG F 1 A_GunFlash;
		SHTG F 0 A_JumpIf(waterlevel > 0,2);
		SHTG F 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		SHTG F 1 A_SetPitch(pitch-(4.0*boa_recoilamount));
		SHTG F 1 Offset(0,40) A_SetPitch(pitch-(2.0*boa_recoilamount));
		SHTG F 1 Offset(0,36) A_SetPitch(pitch-(1.0*boa_recoilamount));
		SHTG A 1 Offset(0,34) A_SetPitch(pitch+(1.0*boa_recoilamount));
		SHTG A 1 Offset(0,33) A_SetPitch(pitch+(0.5*boa_recoilamount));
		SHTG A 7 A_WeaponReady(WRF_NOFIRE);
		SHTG A 1 Offset(-1,33);
		SHTG B 1 Offset(5,34) A_StartSound("shotgun/pump", CHAN_5);
		SHTG B 1 Offset(2,36);
		SHTG B 1 Offset(-1,38);
		SHTG C 1 Offset(3,35);
		SHTG C 1 Offset(-1,38);
		SHTG D 1 Offset(-4,41);
		SHTG D 1 Offset(-4,43) A_SpawnItemEx("ShotgunCasing",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		SHTG E 1 Offset(-4,45);
		SHTG E 1 Offset(-3,44);
		SHTG D 1 Offset(-2,40);
		SHTG D 1 Offset(-4,41);
		SHTG C 1 Offset(-1,38);
		SHTG C 1 Offset(-1,37);
		SHTG B 1 Offset(1,36);
		SHTG B 1 Offset(2,36);
		SHTG BA 1 Offset(5,34);
		TNT1 A 0 A_CheckReload;
		Goto Ready;
	Reload:
		SHTG A 1 Offset(-1,33) A_Reloading;
		SHTG B 1 Offset(5,34);
		SHTG B 1 Offset(2,36);
		SHTG B 1 Offset(-1,38);
		SHTG C 1 Offset(3,35);
		SHTG C 1 Offset(-1,38);
		SHTG C 1 Offset(-4,41);
		SHTG C 1 Offset(-6,46);
		SHTG C 1 Offset(-7,55);
	ReloadLoop:
		SHTG A 0 A_TakeInventory("Ammo12Gauge",1,TIF_NOTAKEINFINITE);
		SHTG A 0 A_GiveInventory("TrenchShotgunLoaded");
		SHTG C 1 Offset(-8,58) A_StartSound("shotgun/load", CHAN_WEAPON);
		SHTG C 1 Offset(-9,64);
		SHTG C 1 Offset(-10,70);
		SHTG C 1 Offset(-10,68);
		SHTG C 1 Offset(-9,66);
		SHTG C 1 Offset(-9,64);
		SHTG C 1 Offset(-9,62);
		SHTG C 1 Offset(-8,61) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY);
		SHTG C 1 Offset(-8,60) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY);
		SHTG C 2 Offset(-8,59) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY);
		SHTG C 3 Offset(-8,58) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY);
		SHTG A 0 A_JumpIfInventory("TrenchShotgunLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("Ammo12Gauge",1,"ReloadLoop");
	ReloadFinish:
		SHTG C 1 Offset(3,35) A_StartSound("shotgun/pump");
		SHTG C 1 Offset(-1,38);
		SHTG D 1 Offset(-4,41);
		SHTG D 1 Offset(-1,33);
		SHTG E 1 Offset(-2,37);
		SHTG E 1 Offset(-3,43);
		SHTG D 1 Offset(-2,40);
		SHTG D 1 Offset(-4,41);
		SHTG C 1 Offset(-1,38);
		SHTG C 1 Offset(3,35);
		SHTG B 1 Offset(-1,38);
		SHTG B 1 Offset(2,36);
		SHTG B 1 Offset(5,34) A_Reloading(0);
		Goto Ready;
	Flash:
		SHTF A 1 A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		SHOT A -1;
		Stop;
	}
}

class TrenchShotgunLoaded : Ammo
{
	Default
	{
	Tag "12 Gauge";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 8;
	Inventory.Icon "BROW01";
	}
}