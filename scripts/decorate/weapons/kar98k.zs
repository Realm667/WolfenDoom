/*
 * Copyright (c) 2015-2021 Ed the Bat, Ozymandias81, MaxED, Talon1024
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

class Kar98k : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (5) Karabiner 98k
	//$Color 14
	Scale 0.45;
	Weapon.AmmoType "Kar98kLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "MauserAmmo";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 5;
	Weapon.UpSound "mauser/select";
	Inventory.PickupMessage "$KAR98K";
	Weapon.SelectionOrder 750;
	+WEAPON.NOAUTOFIRE
	+NaziWeapon.NORAMPAGE
	Tag "Karabiner 98k";
	}
	States
	{
	Ready:
		KAR9 A 0 A_JumpIfInventory("SniperZoom",1,"ScopedReady");
		KAR9 A 0 A_JumpIfInventory("Kar98kLoaded",0,2);
		KAR9 A 0 A_JumpIfInventory("MauserAmmo",1,2);
		KAR9 A 1 A_WeaponReady;
		Loop;
		KAR9 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	ScopedReady:
		SCO1 A 0 A_JumpIfInventory("Kar98kLoaded",0,2);
		SCO1 A 0 A_JumpIfInventory("MauserAmmo",1,2);
		SCO1 A 1 A_WeaponReady(WRF_NOBOB);
		Goto Ready;
		SCO1 A 1 A_WeaponReady(WRF_NOBOB|WRF_ALLOWRELOAD);
		Goto Ready;
	Select:
		KAR9 A 0 A_Raise;
		KAR9 A 1 A_Raise;
		Loop;
	Deselect:
		KAR9 A 0 A_JumpIfReloading(4);
		KAR9 A 0 A_JumpIfInventory("SniperZoom",1,"ScopedDeselect");
		KAR9 A 0 A_Lower;
		KAR9 A 1 A_Lower;
		Loop;
		KAR9 A 5 A_StartSound("mauser/shut", CHAN_5);
		KAR9 A 1 Offset(4,60);
		KAR9 A 1 Offset(0,51);
		KAR9 A 1 Offset(-4,42);
		KAR9 A 2 Offset(-8,36);
		KAR9 A 1 Offset(-6,35);
		KAR9 A 1 Offset(-4,34);
		KAR9 A 2 Offset(-2,33) A_Reloading(0);
		Loop;
	ScopedDeselect:
		SCO1 A 0 A_TakeInventory("SniperZoom");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 1 A_ZoomFactor(1.0);
		Goto Deselect;
	Fire:
		KAR9 A 0 A_JumpIfReloading("ReloadEnd");
		KAR9 A 0 A_JumpIfInventory("Kar98kLoaded",1,1);
		Goto Dryfire;
		KAR9 A 0 A_AlertMonsters;
		KAR9 A 0 A_StartSound("mauser/fire", CHAN_WEAPON);
		KAR9 A 0 A_SpawnItemEx("MauserRifleCasing",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		KAR9 A 0 A_JumpIfInventory("SniperZoom", 1, "ScopedFire");
		KAR9 A 0 A_GunFlash;
		KAR9 A 2 A_FireProjectile("Kar98kTracer");
		KAR9 A 0 A_JumpIf(waterlevel > 0,2);
		KAR9 A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		KAR9 A 2 Offset(0,40) A_SetPitch(pitch-(4.0*boa_recoilamount));
		KAR9 A 1 Offset(0,36) A_SetPitch(pitch-(2.0*boa_recoilamount));
		KAR9 B 1 Offset(0,32)A_SetPitch(pitch+(1.0*boa_recoilamount));
		KAR9 A 0 A_StartSound("mauser/cock", CHAN_5);
		KAR9 C 3 A_SetPitch(pitch+(1.0*boa_recoilamount));
		KAR9 D 1 A_SetPitch(pitch+(0.5*boa_recoilamount));
		KAR9 E 3;
		KAR9 F 5;
		KAR9 E 3;
		KAR9 D 1;
		KAR9 C 4;
		KAR9 B 1 A_CheckReload;
		Goto Ready;
	ScopedFire:
		SCO1 A 2 A_FireProjectile("Kar98kTracer2");
		SCO1 A 0 A_JumpIf(height<=30,"ScopedFireLowRecoil");
		SCO1 A 0 A_JumpIf(waterlevel > 0,2);
		SCO1 A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		SCO1 A 2 A_SetPitch(pitch-(4.0*boa_recoilamount));
		SCO1 A 1 A_SetPitch(pitch-(2.0*boa_recoilamount));
		SCO1 A 1 A_SetPitch(pitch+(1.0*boa_recoilamount));
		SCO1 A 0 A_StartSound("mauser/cock", CHAN_5);
		SCO1 A 3 A_SetPitch(pitch+(1.0*boa_recoilamount));
		SCO1 A 17 A_SetPitch(pitch+(0.5*boa_recoilamount));
		SCO1 A 1 A_CheckReload;
		Goto Ready;
	ScopedFireLowRecoil:
		SCO1 A 0 A_JumpIf(waterlevel > 0,2);
		SCO1 A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		SCO1 A 2 A_SetPitch(pitch-(2.0*boa_recoilamount));
		SCO1 A 1 A_SetPitch(pitch-(1.0*boa_recoilamount));
		SCO1 A 1 A_SetPitch(pitch+(0.5*boa_recoilamount));
		SCO1 A 0 A_StartSound("mauser/cock", CHAN_5);
		SCO1 A 3 A_SetPitch(pitch+(0.5*boa_recoilamount));
		SCO1 A 17 A_SetPitch(pitch+(0.25*boa_recoilamount));
		SCO1 A 1 A_CheckReload;
		Goto Ready;
	Flash:
		KARF A 1 A_Light2;
		KARF B 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	AltFire:
		KAR9 A 0 A_JumpIfReloading("ReloadEnd");
		SCO1 A 0 A_JumpIfInventory("SniperZoom",1,"ZoomOut");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 0 A_GiveInventory("SniperZoom");
		SCO1 A 3 A_ZoomFactor(12.0);
		Goto Ready;
	ZoomOut:
		SCO1 A 0 A_TakeInventory("SniperZoom");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 3 A_ZoomFactor(1.0);
		Goto Ready;
	Reload:
		SCO1 A 0 A_Reloading;
		SCO1 A 0 A_JumpIfInventory("SniperZoom",1,2);
		SCO1 A 0 A_Jump(256,4);
		SCO1 A 0 A_TakeInventory("SniperZoom");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 3 A_ZoomFactor(1.0);
		KAR9 A 5;
		KAR9 A 1 A_StartSound("mauser/open", CHAN_5);
		KAR9 A 1 Offset(-4,34);
		KAR9 A 1 Offset(-6,35);
		KAR9 A 2 Offset(-8,36);
		KAR9 A 2 Offset(-4,42);
		KAR9 A 1 Offset(0,51);
		KAR9 A 1 Offset(4,60);
		KAR9 A 2 Offset(5,74);
		KAR9 A 3 Offset(6,76);
		KAR9 A 5;
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("MauserAmmo",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("Kar98kLoaded");
		KAR9 A 1 Offset(6,80) A_StartSound("mauser/insert",5);
		KAR9 A 1 Offset(6,84);
		KAR9 A 1 Offset(6,87);
		KAR9 A 1 Offset(7,90);
		KAR9 A 1 Offset(8,92);
		KAR9 A 8 Offset(8,92);
		KAR9 A 1 Offset(9,88);
		KAR9 A 1 Offset(8,82);
		KAR9 A 1 Offset(7,77) A_WeaponReady(WRF_NOBOB);
		TNT1 A 0 A_JumpIfInventory("Kar98kLoaded",0,"ReloadEnd");
		TNT1 A 0 A_JumpIfInventory("MauserAmmo",1,"ReloadLoop");
	ReloadEnd:
		KAR9 A 5 A_StartSound("mauser/shut", CHAN_5);
		KAR9 A 1 Offset(4,60);
		KAR9 A 1 Offset(0,51);
		KAR9 A 1 Offset(-4,42);
		KAR9 A 2 Offset(-8,36);
		KAR9 A 1 Offset(-6,35);
		KAR9 A 1 Offset(-4,34);
		KAR9 A 2 Offset(-2,33) A_Reloading(0);
		Goto Ready;
	Spawn:
		K98K A -1;
		Stop;
	}
}

class SniperZoom : Inventory{}

class Kar98kLoaded : Ammo
{
	Default
	{
	Tag "7.92x57mm";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 5;
	Inventory.Icon "MAUS01";
	}
}