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

class AstroShotgun : NaziAstroWeapon
{
	Default
	{
	//$Title (3) Astrostein Shotgun
	Weapon.SelectionOrder 400;
	Weapon.AmmoType "AstroShotgunLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "AstroShotgunShell";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 8;
 	Weapon.UpSound "shotgun/select";
 	Inventory.PickupMessage "$PROTON";
	Obituary "$OBPROTON";
	Tag "$TAGPROTF";
	}
	States
	{
  	Select:
		ASSG B 0 A_Raise;
		ASSG B 1 A_Raise;
		Loop;
  	Deselect:
		ASSG B 0 A_Lower;
		ASSG B 1 A_Lower;
		Loop;
	Ready:
		ASSG B 0 A_JumpIfInventory("AstroShotgunLoaded",0,2);
		ASSG B 0 A_JumpIfInventory("AstroShotgunShell",1,2);
		ASSG B 1 A_WeaponReady;
		Loop;
		ASSG B 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Fire:
		ASSG B 0 A_JumpIfInventory("AstroShotgunLoaded",1,1);
		Goto Dryfire;
		ASSG C 0 A_AlertMonsters;
		ASSG C 0 A_StartSound("astroshotgun/fire", CHAN_WEAPON);
		ASSG C 0 A_TakeInventory("AstroShotgunLoaded",1,TIF_NOTAKEINFINITE);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",-4.5,0);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",-3.0,0);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",-1.5,0);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",0.0,0);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",1.5,0);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",3.0,0);
		ASSG C 3 A_FireProjectile("AstroTracerPlayer",4.5,0);
		ASSG D 3;
		ASSG EF 5;
		ASSG B 17;
		ASSG B 0 A_ReFire;
		Goto Ready;
	AltFire:
		ASSG B 0 A_JumpIfInventory("AstroShotgunLoaded",1,1);
		Goto Dryfire;
		ASSG C 0 A_AlertMonsters;
		ASSG C 0 A_StartSound("astroshotgun/fire", CHAN_WEAPON);
		ASSG C 0 A_TakeInventory("AstroShotgunLoaded",1,TIF_NOTAKEINFINITE);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,1.5);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,3.0);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,4.5);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,0.0);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,-1.5);
		ASSG C 0 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,-4.5);
		ASSG C 3 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,-3.0);
		ASSG D 3;
		ASSG EF 5;
		ASSG B 17;
		ASSG B 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIfInventory("AstroShotgunShell",1,2);
		ASSG B 1 Offset(0,35) A_StartSound("weapon/dryfire", CHAN_WEAPON);	//replace this sound?
		Goto Ready;
		ASSG B 1 Offset(0,35) A_StartSound("mp40/reload", CHAN_WEAPON);	//replace this sound?
		ASSG B 1 Offset(0,38);
		ASSG B 1 Offset(0,44);
		ASSG B 1 Offset(0,52);
		ASSG B 1 Offset(-1,54);
		ASSG B 1 Offset(-2,56);
		ASSG B 1 Offset(-3,58);
		ASSG B 1 Offset(-4,58);
		ASSG B 1 Offset(-4,57);
		ASSG B 1 Offset(-3,54);
		ASSG B 1 Offset(-3,51);
		ASSG B 1 Offset(-3,53);
		ASSG B 1 Offset(-3,55);
		ASSG B 1 Offset(-3,56);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("AstroShotgunShell",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("AstroShotgunLoaded");
		TNT1 A 0 A_JumpIfInventory("AstroShotgunLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("AstroShotgunShell",1,"ReloadLoop");
	ReloadFinish:
		ASSG B 1 Offset(-3,57);
		ASSG B 1 Offset(-3,59);
		ASSG B 1 Offset(-3,63);
		ASSG B 1 Offset(-3,67);
		ASSG B 1 Offset(-3,65);
		ASSG B 1 Offset(-3,62);
		ASSG B 1 Offset(-3,58);
		ASSG B 1 Offset(-3,55);
		ASSG B 1 Offset(-2,53);
		ASSG B 1 Offset(-2,49);
		ASSG B 1 Offset(-2,46);
		ASSG B 1 Offset(-2,45);
		ASSG B 1 Offset(-1,44);
		ASSG B 1 Offset(-1,46);
		ASSG B 1 Offset(-1,47);
		ASSG B 1 Offset(0,49) A_WeaponReady(WRF_NOBOB);
		ASSG B 1 Offset(0,44) A_WeaponReady(WRF_NOBOB);
		ASSG B 1 Offset(0,38) A_WeaponReady(WRF_NOBOB);
		ASSG B 1 Offset(0,35) A_WeaponReady(WRF_NOBOB);
		ASSG B 1 Offset(0,32) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Spawn:
		ASSG A -1;
		Stop;
	}
}

class AstroShotgunLoaded : Ammo
{
	Default
	{
	Tag "$TAGPROTC";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 8;
	Inventory.Icon "AST101";
	}
}

class AstroShotgunShell : Ammo
{
	Default
	{
	//$Category Astrostein (BoA)/Ammo
	//$Title Protonenflinte (ammo, +5)
	//$Color 6
	Scale 0.50;
	Tag "$TAGPROTC";
	Inventory.PickupMessage "$AFLINTE";
	Inventory.Amount 5;
	Inventory.MaxAmount 100;
	Inventory.Icon "AST101";
	Ammo.BackpackAmount 10;
	Ammo.BackpackMaxAmount 100;
	}
	States
	{
	Spawn:
		ASSL A -1 LIGHT("ASTRAMM1");
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class AstroRocketlauncher : NaziAstroWeapon
{
	Default
	{
	//$Title (5) Astrostein RocketLauncher
	Weapon.SelectionOrder 1400;
	Weapon.AmmoType "AstroRocketLauncherLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "AstroRocketAmmo";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 5;
	Weapon.UpSound "weapons/rezup"; //mxd
	Inventory.PickupMessage "$ENERGIE";
	Obituary "$OBENERGIE";
	Tag "$TAGENB95";
	+WEAPON.NOAUTOFIRE
	}
	States
	{
	Select:
		ASRL B 0 A_Raise;
		ASRL B 1 A_Raise;
		Loop;
	Deselect:
		ASRL B 0 A_Lower;
		ASRL B 1 A_Lower;
		Loop;
	Ready:
		ASRL B 0 A_JumpIfInventory("AstroRocketLauncherLoaded",0,2);
		ASRL B 0 A_JumpIfInventory("AstroRocketAmmo",1,2);
		ASRL B 1 A_WeaponReady;
		Loop;
		ASRL B 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Fire:
		ASRL B 0 A_JumpIfInventory("AstroRocketLauncherLoaded",1,1);
		Goto Dryfire;
		ASRL CD 4;
		ASRL E 0 A_AlertMonsters;
		ASRL E 0 A_TakeInventory("AstroRocketLauncherLoaded",1,TIF_NOTAKEINFINITE);
		ASRL E 4 A_FireProjectile("AstroRocket", 0, 0);
		ASRL D 4;
		ASRL C 21;
		ASRL C 0 A_ReFire;
		Goto Ready;
	AltFire:
		ASRL B 0 A_JumpIfInventory("AstroRocketLauncherLoaded",1,1);
		Goto Dryfire;
		ASRL CD 4;
		ASRL E 0 A_AlertMonsters;
		ASRL E 0 A_TakeInventory("AstroRocketLauncherLoaded",1,TIF_NOTAKEINFINITE);
		ASRL E 4 A_FireProjectile("AstroRocket_Slow", 0, 0);
		ASRL D 4;
		ASRL C 30;
		ASRL C 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIfInventory("AstroRocketAmmo",1,2);
		ASRL B 1 Offset(0,35) A_StartSound("weapon/dryfire", CHAN_WEAPON);	//replace this sound?
		Goto Ready;
		ASRL B 1 Offset(0,35) A_StartSound("mp40/reload", CHAN_WEAPON);
		ASRL B 1 Offset(0,38);
		ASRL B 1 Offset(0,44);
		ASRL B 1 Offset(0,52);
		ASRL B 1 Offset(-1,54);
		ASRL B 1 Offset(-2,56);
		ASRL B 1 Offset(-3,58);
		ASRL B 1 Offset(-4,58);
		ASRL B 1 Offset(-4,57);
		ASRL B 1 Offset(-3,54);
		ASRL B 1 Offset(-3,51);
		ASRL B 1 Offset(-3,53);
		ASRL B 1 Offset(-3,55);
		ASRL B 1 Offset(-3,56);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("AstroRocketAmmo",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("AstroRocketLauncherLoaded");
		TNT1 A 0 A_JumpIfInventory("AstroRocketLauncherLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("AstroRocketAmmo",1,"ReloadLoop");
	ReloadFinish:
		ASRL B 1 Offset(-3,57);
		ASRL B 1 Offset(-3,59);
		ASRL B 1 Offset(-3,63);
		ASRL B 1 Offset(-3,67);
		ASRL B 1 Offset(-3,65);
		ASRL B 1 Offset(-3,62);
		ASRL B 1 Offset(-3,58);
		ASRL B 1 Offset(-3,55);
		ASRL B 1 Offset(-2,53);
		ASRL B 1 Offset(-2,49);
		ASRL B 1 Offset(-2,46);
		ASRL B 1 Offset(-2,45);
		ASRL B 1 Offset(-1,44);
		ASRL B 1 Offset(-1,46);
		ASRL B 1 Offset(-1,47);
		ASRL B 1 Offset(0,49) A_WeaponReady(WRF_NOBOB);
		ASRL B 1 Offset(0,44) A_WeaponReady(WRF_NOBOB);
		ASRL B 1 Offset(0,38) A_WeaponReady(WRF_NOBOB);
		ASRL B 1 Offset(0,35) A_WeaponReady(WRF_NOBOB);
		ASRL B 1 Offset(0,32) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Spawn:
		ASRL A -1 LIGHT("ASTRWEP1");
		Stop;
	}
}

class AstroRocket_Slow : AstroRocket
{
	Default
	{
	Speed 4;
	Damage 30;
	Scale 1.5;
	+NOGRAVITY
	BounceType "None";
	}
}

class AstroRocketLauncherLoaded : Ammo
{
	Default
	{
	Tag "$TAGENUNT";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 5;
	Inventory.Icon "AST301";
	}
}

class AstroRocketAmmo : Ammo
{
	Default
	{
	//$Category Astrostein (BoA)/Ammo
	//$Title Energiegewehr (ammo, +50)
	//$Color 6
	Tag "$TAGENUNT";
	Inventory.PickupMessage "$AENERGY";
	Inventory.MaxAmount 50;
	Inventory.Icon "AST301";
	Ammo.BackpackAmount 5;
	Ammo.BackpackMaxAmount 100;
	}
	States
	{
	Spawn:
		ASRK A -1 LIGHT("ASTRAMM1");
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class AstroChaingun : NaziAstroWeapon
{
	Default
	{
	//$Title (4) Astrostein Chaingun
	Weapon.SelectionOrder 700;
	Weapon.AmmoType "AstroChaingunLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "AstroClipAmmo";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 20;
	Weapon.UpSound "weapons/rezup"; //mxd
	Inventory.PickupMessage "$REPETIE";
	Obituary "$OBREPETIE";
	Tag "$TAGREPLZ";
	}
	States
	{
	Select:
		ASCG C 0 A_Raise;
		ASCG C 1 A_Raise;
		Loop;
	Deselect:
		ASCG B 0 A_Lower;
		ASCG B 1 A_Lower;
		Loop;
	Ready:
		ASCG B 0 A_JumpIfInventory("AstroChaingunLoaded",0,2);
		ASCG B 0 A_JumpIfInventory("AstroClipAmmo",1,2);
		ASCG B 1 A_WeaponReady;
		Loop;
		ASCG B 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Fire:
		ASCG B 0 A_JumpIfInventory("AstroChaingunLoaded",1,1);
		Goto Dryfire;
		ASCG D 0 A_AlertMonsters;
		ASCG D 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		ASCG D 0 A_TakeInventory("AstroChaingunLoaded",1,TIF_NOTAKEINFINITE);
		ASCG D 4 A_FireProjectile("AstroTracerPlayer",frandom(-1.0,1.0),0,0,0,0,frandom(-1.0,1.0));
		ASCG D 0 A_JumpIfInventory("AstroChaingunLoaded",1,1);
		Goto Ready;
		ASCG D 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		ASCG E 0 A_TakeInventory("AstroChaingunLoaded",1,TIF_NOTAKEINFINITE);
		ASCG E 4 A_FireProjectile("AstroTracerPlayer",frandom(-1.0,1.0),0,0,0,0,frandom(-1.0,1.0));
		ASCG D 0 A_ReFire;
		Goto Ready;
	AltFire:
		ASCG B 0 A_JumpIfInventory("AstroChaingunLoaded",1,1);
		Goto Dryfire;
		ASCG D 0 A_AlertMonsters;
		ASCG D 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		ASCG D 0 A_TakeInventory("AstroChaingunLoaded",1,TIF_NOTAKEINFINITE);
		ASCG D 6 A_FireProjectile("AstroTracerPlayer",frandom(-0.2,0.2),0,0,0,0,frandom(-0.2,0.2));
		ASCG D 0 A_JumpIfInventory("AstroChaingunLoaded",1,1);
		Goto Ready;
		ASCG D 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		ASCG E 0 A_TakeInventory("AstroChaingunLoaded",1,TIF_NOTAKEINFINITE);
		ASCG E 6 A_FireProjectile("AstroTracerPlayer",frandom(-0.2,0.2),0,0,0,0,frandom(-0.2,0.2));
		ASCG D 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIfInventory("AstroClipAmmo",1,2);
		ASCG B 1 Offset(0,35) A_StartSound("weapon/dryfire", CHAN_WEAPON);	//replace this sound?
		Goto Ready;
		ASCG B 1 Offset(0,35) A_StartSound("mp40/reload", CHAN_WEAPON);	//replace this sound?
		ASCG B 1 Offset(0,38);
		ASCG B 1 Offset(0,44);
		ASCG B 1 Offset(0,52);
		ASCG B 1 Offset(-1,54);
		ASCG B 1 Offset(-2,56);
		ASCG B 1 Offset(-3,58);
		ASCG B 1 Offset(-4,58);
		ASCG B 1 Offset(-4,57);
		ASCG B 1 Offset(-3,54);
		ASCG B 1 Offset(-3,51);
		ASCG B 1 Offset(-3,53);
		ASCG B 1 Offset(-3,55);
		ASCG B 15 Offset(-3,56);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("AstroClipAmmo",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("AstroChaingunLoaded");
		TNT1 A 0 A_JumpIfInventory("AstroChaingunLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("AstroClipAmmo",1,"ReloadLoop");
	ReloadFinish:
		ASCG B 1 Offset(-3,57);
		ASCG B 1 Offset(-3,59);
		ASCG B 1 Offset(-3,63);
		ASCG B 1 Offset(-3,67);
		ASCG B 1 Offset(-3,65);
		ASCG B 1 Offset(-3,62);
		ASCG B 1 Offset(-3,58);
		ASCG B 1 Offset(-3,55);
		ASCG B 1 Offset(-2,53);
		ASCG B 1 Offset(-2,49);
		ASCG B 1 Offset(-2,46);
		ASCG B 1 Offset(-2,45);
		ASCG B 1 Offset(-1,44);
		ASCG B 1 Offset(-1,46);
		ASCG B 1 Offset(-1,47);
		ASCG B 1 Offset(0,49) A_WeaponReady(WRF_NOBOB);
		ASCG B 1 Offset(0,44) A_WeaponReady(WRF_NOBOB);
		ASCG B 1 Offset(0,38) A_WeaponReady(WRF_NOBOB);
		ASCG B 1 Offset(0,35) A_WeaponReady(WRF_NOBOB);
		ASCG B 1 Offset(0,32) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Spawn:
		ASCG A -1 LIGHT("ASTRWEP2");
		Stop;
	}
}

class AstroChaingunLoaded : Ammo
{
	Default
	{
	Tag "$TAGLAZRD";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 30;
	Inventory.Icon "AST201";
	}
}

class AstroClipAmmo : Ammo
{
	Default
	{
	//$Category Astrostein (BoA)/Ammo
	//$Title Repetierlaser (ammo, +10)
	//$Color 6
	Scale 0.50;
	Tag "$TAGLAZRD";
	Inventory.PickupMessage "$ALASER";
	Inventory.Amount 10;
	Inventory.MaxAmount 200;
	Inventory.Icon "AST201";
	Ammo.BackpackAmount 20;
	Ammo.BackpackMaxAmount 200;
	}
	States
	{
	Spawn:
		ASCL A -1 LIGHT("ASTRAMM3");
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

///////////////////////////////////////////////////////////
///// ASTRO SHOCKER ///////////////////////////////////////
///////////////////////////////////////////////////////////

class AstrosteinMelee : NaziAstroWeapon
{
	Default
	{
	//$Title (1) Astrostein Melee
	Tag "$TAGSHOKR";
	Scale 1.0;
	Weapon.Kickback 0;
	Weapon.SelectionOrder 2200;
	Weapon.ReadySound "weapons/rezidle";
	Inventory.PickupMessage "$ELEKTRO";
	Obituary "$OBELEKTRO";
	-WEAPON.AMMO_CHECKBOTH
	-WEAPON.NOALERT
	+WEAPON.MELEEWEAPON
	+WEAPON.AMMO_OPTIONAL
	}
	States
	{
	Select:
		REZG C 0 A_StartSound("weapons/rezup", CHAN_BODY, 0, 1.0); //mxd. UpSound will be cut off by ReadySound
	SelectLoop:
		REZG C 0 A_Raise;
		REZG C 1 A_Raise;
		Loop;
	Deselect:
		REZG C 0 A_Lower;
		REZG C 1 A_Lower;
		Loop;
	Ready:
		REZG CD 4 A_WeaponReady;
		Loop;
	Fire:
		REZG AB 3 A_Saw("weapons/rezfull","weapons/rezhit",2,"ElektroshockerPuff");
		REZG B 0 A_ReFire;
		Goto Ready;
	Spawn:
		REZN A -1;
		Stop;
	}
}

class ElektroshockerPuff : BulletPuff
{
	Default
	{
	+BLOODLESSIMPACT
	+PUFFONACTORS
	DamageType "Reznator";
	RenderStyle "Add";
	Alpha 0.8;
	VSpeed 0;
	DamageType "Melee";
	}
	States
	{
	Spawn:
	Melee:
		TNT1 AAAAA 0 A_SpawnItemEx("SparkG", 0, 0, 0, random(1,2), random(1,2), random(1,2), random(1,360), SXF_CLIENTSIDE);
		TNT1 A 0 A_SpawnItemEx("SparkFlareG");
		RZAP ACEGH 2 BRIGHT;
		Stop;
	}
}

///////////////////////////////////////////////////////////////////
/////// ASTROSTEIN PISTOL /////////////////////////////////////////
///////////////////////////////////////////////////////////////////


class AstroPistolLoaded : Ammo
{
	Default
	{
	Tag "$TAGLAZRD";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 10;
	Inventory.Icon "AST201";
	}
}

class AstroLuger : NaziAstroWeapon //quite the same code from Luger P08 - ozy81
{
	Default
	{
	//$Title (2) Astrostein Luger
	Tag "Astro Luger";
	Scale 1.0;
	Weapon.SelectionOrder 200;
	Weapon.AmmoType "AstroPistolLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "AstroClipAmmo";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 8;
	Weapon.UpSound "luger/select";
	+WEAPON.NOAUTOFIRE
	Obituary "$OBALUGER";
	Inventory.PickupMessage "$ALUGER";
	}
	States
	{
	Ready:
		PLPI A 0 A_JumpIfInventory("AstroPistolLoaded",0,2);
		PLPI A 0 A_JumpIfInventory("AstroClipAmmo",1,2);
		PLPI A 1 A_WeaponReady;
		Loop;
		PLPI A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PLPI A 0 A_Lower;
		PLPI A 1 A_Lower;
		Loop;
	Select:
		PLPI A 0 A_Raise;
		PLPI A 1 A_Raise;
		Loop;
	Fire:
		PLPI A 0 A_JumpIfInventory("AstroPistolLoaded",1,1);
		Goto Dryfire;
		PLPI A 0 A_GunFlash;
		PLPI A 0 A_SetPitch(pitch-(0.2*boa_recoilamount));
		PLPI A 0 A_JumpIf(waterlevel > 0,2);
		PLPI A 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		PLPI A 0 A_AlertMonsters;
		PLPI A 0 A_TakeInventory("AstroPistolLoaded",1,TIF_NOTAKEINFINITE);
		PLPI B 1 A_FireProjectile("AstroTracerPlayer",0,0,0,0,0,frandom(-0.2,0.2));
		PLPI B 1;
		PLPI B 1 Offset(0,36) A_SetPitch(pitch-(0.2*boa_recoilamount));
		PLPI B 1 Offset(0,41) A_CheckReload;
		PLPI C 1 Offset(0,35) A_WeaponReady(WRF_NOBOB);
		PLPI C 1 Offset(0,33) A_WeaponReady(WRF_NOBOB);
		PLPI C 1 Offset(0,31) A_WeaponReady(WRF_NOBOB);
		PLPI A 1 Offset(0,32) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Reload:
		PLPI A 1 Offset(0,35) A_StartSound("luger/reload", CHAN_5);
		PLPI A 1 Offset(0,38);
		PLPI A 1 Offset(0,44);
		PLPI A 1 Offset(0,52);
		PLPI A 1 Offset(0,62);
		PLPI A 1 Offset(0,72);
		PLPI A 1 Offset(0,82);
		TNT1 A 11;
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("AstroClipAmmo",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("AstroPistolLoaded");
		TNT1 A 0 A_JumpIfInventory("AstroPistolLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("AstroClipAmmo",1,"ReloadLoop");
	ReloadFinish:
		PLPI A 1 Offset(0,82);
		PLPI A 1 Offset(0,72);
		PLPI A 1 Offset(0,62);
		PLPI A 1 Offset(0,52);
		PLPI A 1 Offset(0,44);
		PLPI A 1 Offset(0,38);
		PLPI A 1 Offset(0,35);
		PLPI A 1 Offset(0,32);
		Goto Ready;
	Flash:
		PLPI A 1 BRIGHT A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		PLSP A -1;
		Stop;
	}
}

///////////////////////////////////////////////////////////////////////////////
/////// ASTROSTEIN HANDGRANATE ////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// See scripts/actors/weapons/grenade.txt for AstroGrenadePickup
class AstroGrenadeToken : ParallelInventory { Default { ParallelInventory.Type "GrenadePickup"; } }

class AstroHandGrenade : HandGrenade
{
	Default
	{
		BounceFactor 0.4;
		WallBounceFactor 0.8;
		Scale 0.25;
		GrenadeBase.Icon "HUD_GRAS";
	}

	States
	{
		Spawn:
			ASGR A 2 A_Countdown;
			ASGR ACDEFGH 2;
			Loop;
		Death:
			ASGR I 35 A_SkipIfHit;
			TNT1 A 0 A_SpawnGroundSplash;
			TNT1 A 0 A_AlertMonsters;
			TNT1 A 0 A_SetScale(1.75,1.75);
			TNT1 A 0 A_SetTranslucent(0.75,1);
			TNT1 A 0 A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1);
			TNT1 A 1 A_SpawnItemEx("AstrosteinExplosion_Medium");
			TNT1 A 1 Radius_Quake(10,10,0,16,0);
			Stop;
	}

	override void PostBeginPlay()
	{
		floorclip -= 4;
		Super.PostBeginPlay();
	}
}