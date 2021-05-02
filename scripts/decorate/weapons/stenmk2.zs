/*
 * Copyright (c) 2017-2021 Ozymandias81, AFADoomer
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

class Sten : NaziWeapon //Rate of fire: ~500 rounds/min - Wikipedia
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (4) STEN
	//$Color 14
	Scale 0.50;
	Weapon.SelectionOrder 600;
	Inventory.PickupMessage "$STEN";
	Weapon.AmmoType "StenLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "Ammo9mm";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 32;
	Weapon.UpSound "sten/select";
	Tag "STEN Mk II";
	+WEAPON.NOAUTOFIRE //had to add this to make the altfire non-automatic --N00b
	}
	States
	{
	Ready:
		STEN A 0 A_JumpIfInventory("StenLoaded",0,2);
		STEN A 0 A_JumpIfInventory("Ammo9mm",1,2);
		STEN A 1 A_WeaponReady;
		Loop;
		STEN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		STEN A 0 A_Lower;
		STEN A 1 A_Lower;
		Loop;
	Select:
		STEN A 0 A_Raise;
		STEN A 1 A_Raise;
		Loop;
	Fire:
		STEN A 0 A_JumpIfInventory("StenLoaded",1,1);
		Goto Dryfire;
		STEN A 0 A_StartSound("sten/fire", CHAN_WEAPON);
		STEN A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		STEN A 0 A_AlertMonsters(384); // buffed a bit --N00b
		STEN B 1 A_FireProjectile("StenTracer",frandom(-1.5,1.5),1,0,0,0,frandom(-1.0,1.0));
		STEN B 1 Offset(0,40) A_SetPitch(pitch-(0.5*boa_recoilamount));
		STEN B 0 A_JumpIf(waterlevel > 0,2);
		STEN B 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		STEN A 1 Offset(0,34);
		TNT1 A 0 A_Refire;
		Goto Ready;
	Hold:
		STEN A 0 A_JumpIfInventory("StenLoaded",1,1);
		Goto Dryfire;
		STEN A 0 A_StartSound("sten/fire", CHAN_WEAPON);
		STEN A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		STEN A 0 A_AlertMonsters;
		STEN B 1 Offset(0,36) A_FireProjectile("StenTracer",frandom(-1.5,1.5),1,0,0,0,frandom(-1.0,1.0));
		STEN B 0 A_JumpIf(waterlevel > 0,2);
		STEN B 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		STEN B 1 Offset(0,40) A_SetPitch(pitch-(0.5*boa_recoilamount));
		STEN A 1 Offset(0,34);
		TNT1 A 0 A_Refire;
		Goto Ready;
	Altfire: // semi-auto, as it is difficult to fire exactly one shot --N00b
		STEN A 0 A_JumpIfInventory("StenLoaded",1,1);
		Goto Dryfire;
		STEN A 0 A_StartSound("sten/fire", CHAN_WEAPON);
		STEN A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		STEN A 0 A_AlertMonsters(384);
		STEN A 0 A_TakeInventory("StenLoaded",1,TIF_NOTAKEINFINITE); // take the round manually (see ammotypes) --N00b
		STEN B 1 A_FireProjectile("StenTracer",frandom(-1.5,1.5),0,0,0,0,frandom(-1.0,1.0));
		STEN B 1 Offset(0,40) A_SetPitch(pitch-(0.5*boa_recoilamount));
		STEN B 0 A_JumpIf(waterlevel > 0,2);
		STEN B 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		STEN A 1 Offset(0,34);
		STEN A 3; // balance the DPS --N00b
		Goto Ready;
	Reload:
		STEN A 1 Offset(0,38) A_StartSound("sten/reload", CHAN_5);
		STEN A 1 Offset(0,44);
		STEN A 1 Offset(0,56);
		STEN A 1 Offset(-2,60);
		STEN A 1 Offset(-4,72);
		STEN A 1 Offset(-7,80);
		STEN A 1 Offset(-10,82);
		STEN A 20 Offset(-11,84);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("Ammo9mm",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("StenLoaded");
		TNT1 A 0 A_JumpIfInventory("StenLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("Ammo9mm",1,"ReloadLoop");
	ReloadFinish:
		STEN A 1 Offset(-10,84);
		STEN A 1 Offset(-10,90);
		STEN A 1 Offset(-10,98);
		STEN A 1 Offset(-10,110);
		STEN A 1 Offset(-10,98);
		STEN A 1 Offset(-10,88);
		STEN A 1 Offset(-10,78);
		STEN A 1 Offset(-10,74);
		STEN A 1 Offset(-10,70);
		STEN A 1 Offset(-9,68);
		STEN A 1 Offset(-8,60);
		STEN A 1 Offset(-7,54);
		STEN A 1 Offset(-5,48);
		STEN A 1 Offset(-3,42);
		STEN A 1 Offset(-1,36);
		STEN A 1 Offset(0,32);
		TNT1 A 0 A_Refire; // to compensate the effect of +NOAUTOFIRE --N00b
		Goto Ready;
	Spawn:
		STEN Z -1;
		Stop;
	}
}

class StenLoaded : Ammo
{
	Default
	{
	Tag "9x19mm";
	Inventory.MaxAmount 32;
	+INVENTORY.IGNORESKILL
	Inventory.Icon "WALT01";
	}
}