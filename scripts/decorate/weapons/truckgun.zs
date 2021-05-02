/*
 * Copyright (c) 2016-2021 Tormentor667, Ozymandias81
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

// Truck sequence weapon
class TruckWeapon : UMG43
{
	Default
	{
	Weapon.AmmoUse 0;
	+WEAPON.AMMO_OPTIONAL
	}
	States
	{
	Select:
		TNT1 A 1 A_Raise;
		TNT1 A 0 A_Raise;
		Wait;
	Deselect:
		TNT1 A 1 A_Lower;
		TNT1 A 0 A_Lower;
		Wait;
	Ready:
		UMGG A 0 A_ClearRefire;
		UMGG A 0 A_StopSound(5);
		UMGG A 1 A_WeaponReady(WRF_NOSWITCH);
		Wait;
	FireFinish:
		UMGG D 0 Offset(0,32) A_StartSound("chaingun/stop", CHAN_5);
		UMGG DABCDABCDAABBBCCCCDDDDD 1 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;
	Hold:
		UMGG A 0 A_JumpIf(height<=30,"Hold.LowRecoil");
		UMGG A 0 A_GunFlash("Flash1A");
		UMGG A 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG A 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG A 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UMGG A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG E 1 Offset(0,34) A_FireProjectile("ChaingunTracer",frandom(-5.0,5.0),1,0,0,0,frandom(-3.0,3.0));
		UMGG E 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG E 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG E 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG F 1 Offset(0,36) A_FireProjectile("ChaingunTracer",frandom(-5,5),1,0,0,0,frandom(-3,3));
		UMGG F 0 A_GunFlash("Flash2A");
		UMGG F 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG F 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UMGG F 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG G 1 Offset(0,37) A_FireProjectile("ChaingunTracer",frandom(-5.0,5.0),1,0,0,0,frandom(-3.0,3.0));
		UMGG G 0 A_SetPitch(pitch-(0.34*boa_recoilamount));
		UMGG G 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG G 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG H 1 Offset(0,35) A_FireProjectile("ChaingunTracer",frandom(-5,5),1,0,0,0,frandom(-3,3));
		UMGG E 1 A_Refire;
		Goto FireFinish;
	Hold.LowRecoil:
		UMGG A 0 A_GunFlash("Flash1A");
		UMGG A 0 A_SetPitch(pitch-(0.17*boa_recoilamount));
		UMGG A 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG A 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UMGG A 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG E 1 Offset(0,34) A_FireProjectile("ChaingunTracer",frandom(-5.0,5.0),1,0,0,0,frandom(-3.0,3.0));
		UMGG E 0 A_SetPitch(pitch-(0.17*boa_recoilamount));
		UMGG E 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG E 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG F 1 Offset(0,36) A_FireProjectile("ChaingunTracer",frandom(-5,5),1,0,0,0,frandom(-3,3));
		UMGG F 0 A_GunFlash("Flash2A");
		UMGG F 0 A_SetPitch(pitch-(0.17*boa_recoilamount));
		UMGG F 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UMGG F 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG G 1 Offset(0,37) A_FireProjectile("ChaingunTracer",frandom(-5.0,5.0),1,0,0,0,frandom(-3.0,3.0));
		UMGG G 0 A_SetPitch(pitch-(0.17*boa_recoilamount));
		UMGG G 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		UMGG G 0 A_SpawnItemEx("Casing9mm",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		UMGG H 1 Offset(0,35) A_FireProjectile("ChaingunTracer",frandom(-5,5),1,0,0,0,frandom(-3,3));
		UMGG E 1 A_Refire;
		Goto FireFinish;
	}
}