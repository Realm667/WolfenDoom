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

class UMG43 : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (8) UMG 43
	//$Color 14
	Scale 0.35;
	Inventory.PickupMessage "$UMG43";
	Inventory.PickupSound "chaingun/get";
	Tag "UMG 43";
	Weapon.AmmoGive 30;
	Weapon.AmmoType "Ammo9mm";
	Weapon.AmmoUse 1;
	Weapon.AmmoType2 "Ammo9mm";
	Weapon.AmmoUse2 4;
	Weapon.SelectionOrder 900;
	Weapon.UpSound "chaingun/select";
	-WEAPON.AMMO_CHECKBOTH
	-WEAPON.NOALERT
	}
	States
	{
	Select:
		UMGG A 0 A_Raise;
		UMGG A 1 A_Raise;
		Loop;
	Deselect:
		UMGG A 0 A_StopSound(CHAN_5);
		UMGG A 0 A_Lower;
		UMGG A 1 A_Lower;
		Loop;
	Ready:
		UMGG A 0 A_ClearRefire;
		UMGG A 0 A_StopSound(CHAN_5);
		UMGG A 1 A_WeaponReady;
		Wait;
	Fire:
		UMGG A 0 A_StartSound("chaingun/start");
		UMGG A 1 A_StartSound("chaingun/loop", CHAN_5, CHANF_LOOPING, 1.0);
		UMGG AAABBBCCD 1;
		UMGG D 1 A_Refire;
	FireFinish:
		UMGG D 1 A_WeaponReady(WRF_NOPRIMARY);
		UMGG D 0 Offset(0,32) A_StartSound("chaingun/stop", CHAN_5);
		UMGG ABCDABCDAABBBCCCCDDDDD 1 A_WeaponReady;
		Goto Ready;
	Hold:
		UMGG A 0 A_GunFlash("Flash1A");
		UMGG A 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG A 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UMGG A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG E 1 Offset(0,34) A_FireProjectile("ChaingunTracer",frandom(-5.0,5.0),1,0,0,0,frandom(-3.0,3.0));
		UMGG E 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG E 0 A_JumpIf(waterlevel > 0,2);
		UMGG E 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG E 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG F 1 Offset(0,36) A_FireProjectile("ChaingunTracer",frandom(-5,5),1,0,0,0,frandom(-3,3));
		UMGG F 0 A_GunFlash("Flash2A");
		UMGG F 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG F 0 A_JumpIf(waterlevel > 0,2);
		UMGG F 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UMGG F 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG G 1 Offset(0,37) A_FireProjectile("ChaingunTracer",frandom(-5.0,5.0),1,0,0,0,frandom(-3.0,3.0));
		UMGG G 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG G 0 A_JumpIf(waterlevel > 0,2);
		UMGG G 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG G 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG H 1 Offset(0,35) A_FireProjectile("ChaingunTracer",frandom(-5,5),1,0,0,0,frandom(-3,3));
		UMGG E 1 A_Refire;
		Goto FireFinish;
	Flash1A:
		UMGF A 0 A_Jump(128, "Flash1B");
		UMGF A 1 A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Flash1B:
		UMGF C 1 A_Light2;
		Goto Flash1A+1;
	Flash2A:
		UMGF B 0 A_Jump(128, "Flash2B");
		UMGF B 1 A_Light2;
		Goto Flash1A+1;
	Flash2B:
		UMGF D 1 A_Light2;
		Goto Flash1A+1;
	AltFire:
		UMGG A 0 A_GunFlash("AltFlash1");
		UMGG E 0 A_SetPitch(pitch-0.3*(boa_recoilamount));
		UMGG A 0 A_StartSound("chaingun/altfire", CHAN_WEAPON);
		UMGG AA 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG E 1 {
			A_FireProjectile("ChaingunTracer",frandom(-0.5,0.5),1,-2.0,0.0,0,frandom(-0.5,0.5));
			A_FireProjectile("ChaingunTracer",frandom(-0.5,0.5),0,2.0,0.0,0,frandom(-0.5,0.5));
		}
		UMGG E 0 A_JumpIf(waterlevel > 0,2);
		UMGG E 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG E 2;
		UMGG A 3;
		UMGG A 0 A_GunFlash("AltFlash2");
		UMGG A 0 A_SetPitch(pitch-0.6*(boa_recoilamount));
		UMGG A 0 A_StartSound("chaingun/altfire", CHAN_WEAPON);
		UMGG AA 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG I 1 {
			A_FireProjectile("ChaingunTracer",frandom(-0.5,0.5),0,0.0,2.0,0,frandom(-0.5,0.5));
			A_FireProjectile("ChaingunTracer",frandom(-0.5,0.5),0,0.0,-2.0,0,frandom(-0.5,0.5));
		}
		UMGG I 0 A_JumpIf(waterlevel > 0,2);
		UMGG I 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG I 2;
		UMGG A 3;
		UMGG E 1 A_Refire;
		Goto Ready;
	AltFlash1:
		UMGF A 2 A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	AltFlash2:
		UMGF E 2 A_Light2;
		TNT1 A 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		UMGP A -1;
		Stop;
	}
}