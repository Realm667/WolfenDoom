/*
 * Copyright (c) 2017-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, Talon1024,
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

class Browning5 : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (3) Browning
	//$Color 14
	Weapon.SelectionOrder 400;
	Weapon.AmmoUse 1;
	Weapon.AmmoType "Browning5Loaded";
	Weapon.AmmoType2 "Ammo12Gauge";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 8;
	Weapon.UpSound "browning/select";
	Scale .5;
	Inventory.PickupMessage "$BROWNING";
	Tag "Browning Auto-5";
	+WEAPON.NOAUTOFIRE
	+NaziWeapon.NORAMPAGE
	}
	States
	{
	Select:
		BA5G A 0 A_Raise;
		BA5G A 1 A_Raise;
		Loop;
	Deselect:
		BA5G A 0 A_JumpIfReloading(3);
		BA5G A 0 A_Lower;
		BA5G A 1 A_Lower;
		Loop;
		BA5G E 1 Offset(-8,58) A_StartSound("browning/cock", CHAN_5);
		BA5G E 1 Offset(-8,60);
		BA5G E 1 Offset(-8,63);
		BA5G E 1 Offset(-9,67);
		BA5G E 1 Offset(-9,72);
		BA5G E 1 Offset(-10,75);
		BA5G E 2 Offset(-10,77);
		BA5G E 3 Offset(-11,78);
		BA5G E 1 Offset(-10,76);
		BA5G E 1 Offset(-8,68);
		BA5G E 1 Offset(-6,58);
		BA5G E 1 Offset(-4,46);
		BA5G E 1 Offset(-2,33);
		BA5G E 1 Offset(-1,32) A_Reloading(0);
		Loop;
	Ready:
		BA5G A 0 A_JumpIfInventory("Browning5Loaded",0,2);
		BA5G A 0 A_JumpIfInventory("Ammo12Gauge",1,2);
		BA5G A 1 A_WeaponReady;
		Loop;
		BA5G A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Fire:
		BA5G A 0 A_JumpIfReloading("ReloadFinish");
		BA5G A 0 A_JumpIfInventory("Browning5Loaded",1,1);
		Goto Dryfire;
		BA5G A 0 A_StartSound("browning/fire", CHAN_WEAPON);
		BA5G A 0 A_SpawnItemEx("ShotgunCasing",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		BA5G AAAAAAAAAA 0 A_FireProjectile("AutoShotgunTracer",frandom(-4.0,4.0),0,0,0,0,frandom(-3,3));
		BA5G A 0 A_TakeInventory("Browning5Loaded",1,TIF_NOTAKEINFINITE);
		BA5G A 0 A_JumpIf(waterlevel > 0,2);
		BA5G A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		BA5G A 0 A_AlertMonsters;
		BA5G A 1 A_GunFlash;
		BA5G A 1 Offset(0,42) A_SetPitch(pitch-(4.0*boa_recoilamount));
		BA5G A 1 Offset(0,47) A_SetPitch(pitch-(2.0*boa_recoilamount));
		BA5G A 1 Offset(0,36) A_SetPitch(pitch-(1.0*boa_recoilamount));
		BA5G A 1 Offset(0,34) A_SetPitch(pitch+(1.0*boa_recoilamount));
		BA5G A 4 Offset(0,33) A_SetPitch(pitch+(0.5*boa_recoilamount));
		BA5G A 1;
		TNT1 A 0 A_CheckReload;
		Goto Ready;
	Reload:
		BA5G E 1 Offset(-1,33) A_Reloading;
		BA5G E 1 Offset(-4,41);
		BA5G E 1 Offset(-6,46);
		BA5G E 1 Offset(-7,55);
		ReloadLoop:
		BA5G A 0 A_TakeInventory("Ammo12Gauge",1,TIF_NOTAKEINFINITE);
		BA5G A 0 A_GiveInventory("Browning5Loaded");
		BA5G E 1 Offset(-8,58) A_StartSound("browning/load", CHAN_5);
		BA5G E 1 Offset(-9,64);
		BA5G E 1 Offset(-10,70);
		BA5G E 1 Offset(-10,68);
		BA5G E 1 Offset(-9,66);
		BA5G E 1 Offset(-9,64);
		BA5G E 1 Offset(-9,62);
		BA5G E 1 Offset(-8,61) A_WeaponReady(WRF_NOBOB);
		BA5G E 1 Offset(-8,60) A_WeaponReady(WRF_NOBOB);
		BA5G E 2 Offset(-8,59) A_WeaponReady(WRF_NOBOB);
		BA5G E 3 Offset(-8,58) A_WeaponReady(WRF_NOBOB);
		BA5G A 0 A_JumpIfInventory("Browning5Loaded",0,"ReloadFinish");
		BA5G A 0 A_JumpIfInventory("Ammo12Gauge",1,"ReloadLoop");
		ReloadFinish:
		BA5G E 1 Offset(-8,58) A_StartSound("browning/cock", CHAN_5);
		BA5G E 1 Offset(-8,60);
		BA5G E 1 Offset(-8,63);
		BA5G E 1 Offset(-9,67);
		BA5G E 1 Offset(-9,72);
		BA5G E 1 Offset(-10,75);
		BA5G E 1 Offset(-10,77);
		BA5G E 2 Offset(-11,78);
		BA5G E 1 Offset(-10,76);
		BA5G E 1 Offset(-8,68);
		BA5G E 1 Offset(-6,58);
		BA5G E 1 Offset(-4,46);
		BA5G E 1 Offset(-2,33);
		BA5G E 1 Offset(-1,32) A_Reloading(0);
		Goto Ready;
	Flash:
		BA5G B 1 A_Light2;
		BA5G C 1;
		BA5G D 1 A_Light1;
		TNT1 A 1;
		Goto LightDone;
	Spawn:
		BA5P A -1;
		Stop;
	}
}

class Browning5Loaded : Ammo
{
	Default
	{
	Tag "$TAGGAUGE";
	Inventory.MaxAmount 5;
	+INVENTORY.IGNORESKILL
	Inventory.Icon "BROW01";
	}
}