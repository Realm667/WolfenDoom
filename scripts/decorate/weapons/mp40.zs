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

class MP40 : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (4) MP40
	//$Color 14
	Scale .5;
	Weapon.SelectionOrder 600;
	Weapon.AmmoType "MP40Loaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "Ammo9mm";
	Weapon.AmmoUse2 1;
	Weapon.UpSound "mp40/select";
	Tag "MP 40";
	Inventory.PickupMessage "$MP40";
	Weapon.AmmoGive2 32;
	}
	States
	{
	Ready:
		RIFG A 0 A_JumpIfInventory("MP40Loaded",0,2);
		RIFG A 0 A_JumpIfInventory("Ammo9mm",1,2);
		RIFG A 1 A_WeaponReady;
		Loop;
		RIFG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		RIFG A 0 A_Lower;
		RIFG A 1 A_Lower;
		Loop;
	Select:
		RIFG A 0 A_Raise;
		RIFG A 1 A_Raise;
		Loop;
	Fire:
		RIFG A 0 A_JumpIfInventory("MP40Loaded",1,1);
		Goto Dryfire;
		RIFG A 0 A_GunFlash;
		RIFG A 0 A_SetPitch(pitch-(0.5*boa_recoilamount));
		RIFG A 0 A_JumpIf(waterlevel > 0,2);
		RIFG A 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		RIFG A 0 A_StartSound("mp40/fire", CHAN_WEAPON, 0, frandom(0.6, 0.8));
		RIFG A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		RIFG A 0 A_AlertMonsters;
		RIFG A 1 A_FireProjectile("MP40Tracer",frandom(-1.4,1.4));
		RIFG B 1 Offset(0,38);
		RIFG B 1 Offset(0,44);
		RIFG B 1 Offset(0,40);
		RIFG A 0 A_JumpIfInventory("MP40Seq",1,"Fire2");
		TNT1 A 0 A_GiveInventory("MP40Seq");
		TNT1 A 0 A_CheckReload;
		Goto Ready;
	Fire2:
		RIFG A 1 Offset(0,36) A_TakeInventory("MP40Seq");
		TNT1 A 0 A_CheckReload;
		Goto Ready;
	Reload:
		RIFG A 1 Offset(0,35) A_StartSound("mp40/reload", CHAN_5, 0, frandom(0.6, 0.8));
		RIFG A 1 Offset(0,38);
		RIFG A 1 Offset(0,44);
		RIFG B 1 Offset(0,52);
		RIFG B 1 Offset(-1,54);
		RIFG B 1 Offset(-2,56);
		RIFG B 1 Offset(-3,58);
		RIFG B 1 Offset(-4,58);
		RIFG B 1 Offset(-4,57);
		RIFG B 1 Offset(-3,54);
		RIFG B 1 Offset(-3,51);
		RIFG B 1 Offset(-3,53);
		RIFG B 1 Offset(-3,55);
		RIFG B 15 Offset(-3,56);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("Ammo9mm",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("MP40Loaded");
		TNT1 A 0 A_JumpIfInventory("MP40Loaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("Ammo9mm",1,"ReloadLoop");
	ReloadFinish:
		RIFG B 1 Offset(-3,57);
		RIFG B 1 Offset(-3,59);
		RIFG B 1 Offset(-3,63);
		RIFG B 1 Offset(-3,67);
		RIFG B 1 Offset(-3,65);
		RIFG B 1 Offset(-3,62);
		RIFG B 1 Offset(-3,58);
		RIFG B 1 Offset(-3,55);
		RIFG B 1 Offset(-2,53);
		RIFG B 1 Offset(-2,49);
		RIFG B 1 Offset(-2,46);
		RIFG B 1 Offset(-2,45);
		RIFG B 1 Offset(-1,44);
		RIFG B 1 Offset(-1,46);
		RIFG B 1 Offset(-1,47);
		RIFG B 1 Offset(0,49) A_WeaponReady(WRF_NOBOB);
		RIFG A 1 Offset(0,44) A_WeaponReady(WRF_NOBOB);
		RIFG A 1 Offset(0,38) A_WeaponReady(WRF_NOBOB);
		RIFG A 1 Offset(0,35) A_WeaponReady(WRF_NOBOB);
		RIFG A 1 Offset(0,32) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Flash:
		RIFF A 1 A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		MP40 A -1;
		Stop;
	}
}

class MP40Loaded : Ammo
{
	Default
	{
	Tag "9x19mm";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 32;
	Inventory.Icon "WALT01";
	}
}

class MP40Seq : Inventory{}