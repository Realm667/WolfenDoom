/*
 * Copyright (c) 2018-2021 Ozymandias81, AFADoomer
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

class TeslaLoaded : Ammo
{
	Default
	{
	Tag "$TAGLOADD";
	+INVENTORY.IGNORESKILL
	Inventory.MaxAmount 30;
	Inventory.Icon "TESL01";
	}
}

class TeslaCannon : NaziAstroWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (8) Tesla Cannon
	-WEAPON.CHEATNOTWEAPON
	Scale 1.0; //for pickup
	Weapon.SelectionOrder 10105;
	Weapon.AmmoType "TeslaLoaded";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "TeslaCell";
	Weapon.AmmoUse2 1;
	Weapon.AmmoGive2 20;
	Weapon.UpSound "tesla/raise";
	Inventory.PickupMessage "$TESLAC";
	Obituary "$OBTESLAC";
	Tag "$TAGTESLA";
	}
	States
	{
	Select:
		PULS B 0 A_Raise;
		PULS B 1 A_Raise;
		Loop;
	Deselect:
		PULS B 0 A_StopSound(CHAN_WEAPON);
		PULS B 0 A_Lower;
		PULS B 1 A_Lower;
		Loop;
	Ready:
		PULS B 0 A_StartSound("tesla/hum", CHAN_WEAPON, CHANF_LOOPING, 2.0);
		PULS B 0 A_JumpIfInventory("TeslaLoaded",0,2);
		PULS B 0 A_JumpIfInventory("TeslaCell",1,7);
		PULS B 1 A_WeaponReady;
		PULS B 1 A_WeaponReady;
		PULS C 1 A_WeaponReady;
		PULS C 1 A_WeaponReady;
		PULS D 1 A_WeaponReady;
		PULS D 1 A_WeaponReady;
		Loop;
		PULS B 1 A_WeaponReady (WRF_ALLOWRELOAD);
		PULS B 1 A_WeaponReady (WRF_ALLOWRELOAD);
		PULS C 1 A_WeaponReady (WRF_ALLOWRELOAD);
		PULS C 1 A_WeaponReady (WRF_ALLOWRELOAD);
		PULS D 1 A_WeaponReady (WRF_ALLOWRELOAD);
		PULS D 1 A_WeaponReady (WRF_ALLOWRELOAD);
		Loop;
	Fire:
		PULS E 0 A_JumpIf(waterlevel>= 2,"Suicide");
		PULS E 0 A_JumpIfInventory("TeslaLoaded",1,1);
		Goto Dryfire;
		PULS E 0 A_AlertMonsters;
		PULS E 0 A_StartSound("tesla/fire", CHAN_WEAPON, CHANF_LOOPING, 2.0);
		PULS EF 1;
		PULS F 0 A_SetBlend("Purple",0.050,5);
		PULS GF 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamPri");
		}
		PULS E 0 {
			TakeInventory("TeslaLoaded", 1, TIF_NOTAKEINFINITE); // Only take ammo once per firing, not with every lightning spawn
			A_ReFire();
		}
		Goto Ready;
	Suicide:
		PULS E 0 A_SetBlend("Purple",0.25,5);
		PULS E 1 A_StartSound("tesla/kill", CHAN_WEAPON, CHANF_LOOPING, 1.0);
		PULS F 2 A_SetBlend("Purple",0.75,5);
		PULS G 2 A_SetBlend("Purple",1.25,5);
		PULS F 2 A_SetBlend("Purple",2.75,5);
		PULS F 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		PULS G 1 A_SetBlend("White",3.25,5);
		PULS E 2 A_SetBlend("White",4.75,5);
		PULS G 2 A_SetBlend("White",5.25,5);
		PULS F 2 A_SetBlend("White",6.75,5);
		PULS E 1 A_SetBlend("White",7.25,5);
		PULS FGE 1 { A_GunFlash("Flash"); A_DamageSelf(9999999, "Electric", DMSS_FOILINVUL | DMSS_NOPROTECT, "BoAPlayer"); A_WeaponReady(WRF_NOFIRE|WRF_NOBOB); }
		Goto Ready;
	AltFire:
		PULS E 0 A_StopSound(CHAN_WEAPON);
		PULS E 0 A_JumpIf(waterlevel>= 2,"Suicide");
		PULS E 0 A_StartSound("tesla/alt", CHAN_WEAPON, CHANF_LOOPING, 2.0);
		PULS E 0 A_JumpIfInventory("TeslaLoaded",1,1);
		Goto Dryfire;
		PULS E 0 A_AlertMonsters;
		PULS E 0 A_CheckReload;
	AltFire.Hold1:
		PULS E 0 A_JumpIf(waterlevel>= 2,"Suicide");
		PULS E 0 A_JumpIfInventory("TeslaLoaded",1,1);
		Goto Dryfire;
		PULS E 0 A_SetBlend("Purple",0.050,5);
		PULS E 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
			TakeInventory("TeslaLoaded", 1, TIF_NOTAKEINFINITE);
		}
		PULS F 1;
		PULS G 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
		}
		PULS F 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
		}
		PULS G 1;
		PULS E 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
		}
		PULS E 0 A_Refire ("AltFire.Hold2");
		Goto Ready;
	AltFire.Hold2:
		PULS E 0 A_JumpIf(waterlevel>= 2,"Suicide");
		PULS E 0 A_JumpIfInventory("TeslaLoaded",1,1);
		Goto Dryfire;
		PULS E 0 A_SetBlend("Purple",0.050,5);
		PULS F 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
			TakeInventory("TeslaLoaded", 1, TIF_NOTAKEINFINITE);
		}
		PULS G 1;
		PULS E 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
		}
		PULS E 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
		}
		PULS F 1;
		PULS G 1 {
			A_GunFlash("Flash");
			A_SpawnLightning("LightningBeamAlt");
		}
		PULS E 0 A_Refire("AltFire.Hold1");
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIfInventory("TeslaCell",1,2);
		PULS H 1 Offset(0,35) A_StartSound("weapon/dryfire", CHAN_WEAPON);
		Goto Ready;
		PULS H 1 Offset(0,35) A_StartSound("mp40/reload", CHAN_WEAPON);
		PULS H 1 Offset(0,38);
		PULS H 1 Offset(0,44);
		PULS H 1 Offset(0,52);
		PULS H 1 Offset(-1,54);
		PULS H 1 Offset(-2,56);
		PULS H 1 Offset(-3,58);
		PULS H 1 Offset(-4,58);
		PULS H 1 Offset(-4,57);
		PULS H 1 Offset(-3,54);
		PULS H 1 Offset(-3,51);
		PULS H 1 Offset(-3,53);
		PULS H 1 Offset(-3,55);
		PULS H 7 Offset(-3,56);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("TeslaCell",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("TeslaLoaded");
		TNT1 A 0 A_JumpIfInventory("TeslaLoaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("TeslaCell",1,"ReloadLoop");
	ReloadFinish:
		PULS H 1 Offset(-3,57);
		PULS H 1 Offset(-3,59);
		PULS H 1 Offset(-3,63);
		PULS H 1 Offset(-3,67);
		PULS H 1 Offset(-3,65);
		PULS H 1 Offset(-3,62);
		PULS H 1 Offset(-3,58);
		PULS H 1 Offset(-3,55);
		PULS H 1 Offset(-2,53);
		PULS H 1 Offset(-2,49);
		PULS H 1 Offset(-2,46);
		PULS H 1 Offset(-2,45);
		PULS H 1 Offset(-1,44);
		PULS H 1 Offset(-1,46);
		PULS H 1 Offset(-1,47);
		PULS B 1 Offset(0,49) A_WeaponReady(WRF_NOBOB);
		PULS C 1 Offset(0,44) A_WeaponReady(WRF_NOBOB);
		PULS D 1 Offset(0,38) A_WeaponReady(WRF_NOBOB);
		PULS B 1 Offset(0,35) A_WeaponReady(WRF_NOBOB);
		PULS C 1 Offset(0,32) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Flash:
		TNT1 A 1 BRIGHT A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		PULS A -1 LIGHT("TESLAW");
		Stop;
	}
}