/*
 * Copyright (c) 2015-2021 Ed the Bat, Ozymandias81, MaxED
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

class G43 : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (4) Gewehr 43
	//$Color 14
	Scale 0.35;
	Weapon.SelectionOrder 750;
	Weapon.AmmoType "G43Loaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "MauserAmmo";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 10;
	Inventory.PickupMessage "$G43";
	Tag "Gewehr 43";
	Weapon.UpSound "g43/select";
	+WEAPON.NOAUTOFIRE;
	+NaziWeapon.NORAMPAGE
	}
	States
	{
	Select:
		M1GG A 0 A_Raise;
		M1GG A 1 A_Raise;
		Loop;
	Deselect:
		M1GG A 0 A_Lower;
		M1GG A 1 A_Lower;
		Loop;
	Ready:
		M1GG A 0 A_JumpIfInventory("G43Loaded",0,2);
		M1GG A 0 A_JumpIfInventory("MauserAmmo",1,2);
		M1GG A 1 A_WeaponReady;
		Loop;
		M1GG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Fire:
		M1GG A 0 A_JumpIfInventory("G43Loaded",1,1);
		Goto Dryfire;
		M1GG A 0 A_StartSound("g43/fire",CHAN_WEAPON);
		M1GG A 0 A_GunFlash;
		M1GG A 0 A_SpawnItemEx("MauserRifleCasing",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		M1GG A 0 A_AlertMonsters;
		M1GG A 1 A_FireProjectile("G43Tracer");
		M1GG A 0 A_JumpIf(waterlevel > 0,2);
		M1GG A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		M1GG A 1 A_SetPitch(pitch-(1.4*boa_recoilamount));
		M1GG CDEDC 1;
		TNT1 A 0 A_CheckReload;
		M1GG AAFFFA 1 A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Reload:
		M1GG A 1 Offset(0,35) A_StartSound("g43/reload",CHAN_5);
		M1GG A 1 Offset(-2,38);
		M1GG A 1 Offset(-4,44);
		M1GG A 1 Offset(-6,52);
		M1GG A 1 Offset(-7,57);
		M1GG C 1 Offset(-8,62);
		M1GG C 1 Offset(-9,67);
		M1GG C 1 Offset(-10,72);
		M1GG C 1 Offset(-11,77);
		M1GG C 1 Offset(-11,80);
		M1GG D 1 Offset(-12,82);
		M1GG D 1 Offset(-12,84);
		M1GG D 1 Offset(-13,86);
		M1GG E 1 Offset(-13,87);
		M1GG E 2 Offset(-14,88);
		M1GG E 3 Offset(-14,89);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("MauserAmmo",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("G43Loaded");
		TNT1 A 0 A_JumpIfInventory("G43Loaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("MauserAmmo",1,"ReloadLoop");
	ReloadFinish:
		M1GG D 2 Offset(-10,96);
		M1GG D 1 Offset(-6,100);
		M1GG C 1 Offset(-7,90);
		M1GG C 1 Offset(-6,80);
		M1GG C 1 Offset(-4,70);
		M1GG A 1 Offset(-2,60);
		M1GG A 1 Offset(0,50);
		M1GG A 1 Offset(0,40);
		M1GG A 1 Offset(0,32);
		Goto Ready;
	Flash:
		M1GF A 1 A_Light2;
		M1GF B 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		M1GP A -1;
		Stop;
	}
}

class G43Loaded : Ammo
{
	Default
	{
	Tag "7.92x57mm";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 10;
	Inventory.Icon "MAUS01";
	}
}