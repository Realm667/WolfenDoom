/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED
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

class Walther9mm : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (2) Walther
	//$Color 14
	Scale 0.50;
	Weapon.SelectionOrder 9997;
	Weapon.AmmoType "Walther9mmLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "Ammo9mm";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 8;
	Weapon.UpSound "walther/select";
	Tag "Walther P38";
	Inventory.PickupMessage "$P38WALT";
	}
	States
	{
	Ready:
		WALG A 0 A_JumpIfInventory("Walther9mmLoaded",0,2);
		WALG A 0 A_JumpIfInventory("Ammo9mm",1,2);
		WALG A 1 A_WeaponReady;
		Loop;
		WALG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		WALG B 0 A_Lower;
		WALG B 1 A_Lower;
		Loop;
	Select:
		WALG A 0 A_Raise;
		WALG A 1 A_Raise;
		Loop;
	Fire:
		WALG A 0 A_JumpIfInventory("Walther9mmLoaded",1,1);
		Goto Dryfire;
		WALG A 0 A_GunFlash;
		WALG A 0 A_SetPitch(pitch-(0.2*boa_recoilamount));
		WALG A 0 A_JumpIf(waterlevel > 0,2);
		WALG A 0 A_FireProjectile("PistolSmokeSpawner",0,0,0,random(-4,4),0,0);
		WALG A 0 A_StartSound("walther/fire", CHAN_WEAPON);
		WALG A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		WALG A 0 A_AlertMonsters;
		WALG A 1 A_FireProjectile("WaltherTracer");
		WALG B 2;
		WALG A 1 A_SetPitch(pitch-(0.2*boa_recoilamount));
		WALG A 1 Offset(0,36);
		WALG A 1 Offset(0,41);
		WALG A 1 Offset(0,35);
		TNT1 A 0 A_CheckReload;
		WALG A 1 Offset(0,32) A_Jump(128,"Ready");
		Goto Ready;
	Reload:
		WALG A 1 Offset(0,35) A_StartSound("walther/reload", CHAN_5);
		WALG A 1 Offset(0,38);
		WALG A 1 Offset(0,44);
		WALG A 1 Offset(0,52);
		WALG B 1 Offset(0,62);
		WALG B 1 Offset(0,72);
		WALG B 1 Offset(0,82);
		TNT1 A 8;
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("Ammo9mm",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("Walther9mmLoaded");
		TNT1 A 0 A_JumpIfInventory("Walther9mmLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("Ammo9mm",1,"ReloadLoop");
	ReloadFinish:
		WALG B 1 Offset(0,82);
		WALG B 1 Offset(0,72);
		WALG B 1 Offset(0,62);
		WALG B 1 Offset(0,52);
		WALG A 1 Offset(0,44);
		WALG A 1 Offset(0,38);
		WALG A 1 Offset(0,35);
		WALG A 1 Offset(0,32);
		Goto Ready;
	Flash:
		WALF A 1 A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		WALP A -1;
		Stop;
	}
}

class Walther9mmLoaded : Ammo
{
	Default
	{
	Tag "9x19mm";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 8;
	Inventory.Icon "WALT01";
	}
}