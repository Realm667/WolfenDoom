/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Guardsoul, Ed the Bat,
 *                         MaxED, AFADoomer, Talon1024
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

/////////
//NAZIS//
/////////

class BasicGuard : NaziStandard
{
	Default
	{
	Health 20;
	Obituary "$GUARD";
	DropItem "Ammo9mm", 192;
	DropItem "Luger9mm", 64;
	}
	States
	{
	Spawn:
		GARD N 1;
		Goto Look;
	See:
		Goto See.Dodge; // Use this as the See state for any actors that need to dodge/roll
	Dodge:
		GADD A 0; // This state is never accessed directly, but is necessary to define the sprite to be used for the dodge animation
	Dodge.Resume:
		Goto See.Normal; // This is the See variation (See.Fast, See.Normal, See.Boss, etc.) that the actor will use when not dodging
	Missile:
		"####" E 10 A_FaceTarget;
	Missile.Aimed:
		"####" F 10 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",54,1,random(-8,8));
		"####" F 8 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_Jump(256,"See");
		Stop;
	Reload: //ozy81
		"####" E 0 {bNoPain = TRUE;}
		"####" E 30 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		"####" "#" 0 A_Jump(256, "See"); //So that inheriting actors go to their own See State
	Death:
		"####" I 0 A_CheckFadeDeath;
		"####" I 5 A_RandomDeathAnim; //altdeaths break Raise states atm, except for those actors which have kept proper frame name, only a couple - ozy81
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M 5 A_CheckAltDeath;
		"####" M -1;
		Stop;
	Death.Fade:
		"####" M 1 A_FadeOut(0.005,FTF_REMOVE);
		Loop;
	Death.Alt1:
		"####" "#" 0 A_SpawnItemEx("Guard_Wounded_NoCount", flags: SXF_SETMASTER);
		"####" "#" -1; // In case A_SpawnItemEx fails
		Stop;
	}
}

class Guard : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Afrika Korps
	//$Title Afrika Korps Guard (Pistol)
	//$Color 4
	Nazi.ZombieVariant "AKZombieBrain";
	}
	States
	{
	Death.Front:
		GARA I 0 A_CheckFadeDeath;
		GARA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		GARB I 0 A_CheckFadeDeath;
		GARB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		GAHA I 0 A_CheckFadeDeath;
		GAHA I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class GiantGuard : Guard
{
	Default
	{
	//$Title Afrika Korps Giant Guard (Easter Egg, no fadedeath)
	//$Sprite GARDF1
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "Ammo9mm", 255;
	DropItem "GrenadePickup", 255;
	DropItem "GrenadePickup", 255;
	DropItem "GrenadePickup", 255;
	DropItem "GrenadePickup", 255;
	DropItem "GrenadePickup", 255;
	Health 500;
	Height 280;
	Mass 9999;
	Scale 2.90;
	Nazi.NoAltDeath 1;
	}
	States
	{
	See:
		Goto See.Normal;
	Missile: //different because tall
		"####" E 5 A_FaceTarget;
	Missile.Aimed:
		"####" F 5 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",254,1,random(-8,8));
		"####" F 8 A_SpawnItemEx("Casing9mm", 1, 0, 256, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_Jump(256,"See");
		Stop;
	Reload: //ozy81
		"####" E 0 {bNoPain = TRUE;}
		"####" E 30 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("Casing9mm", 1, 0, 256, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Pain:
		"####" H 6 A_NaziPain(0, True, -64);
		Goto See;
	Death:
		"####" I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M 5;
		"####" M -1;
		Stop;
	Death.Fire:
		"####" # 0 A_SetScale(2.80);
		Goto Death.Fire.Random;
	Death.Electric:
		"####" # 0 A_SetScale(2.80);
		Goto Death.Electric.Random;
	XDeath:
		Goto XDeath.Giant;
	}
}

class SSGuard : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/SS
	//$Title SS Guard (Pistol)
	//$Color 4
	Health 40;
	Speed 2.67;
	Obituary "$SSGUARD";
	Nazi.FrightMultiplier 0.9;
	Nazi.ZombieVariant "SSZombieBrain";
	}
	States
	{
	Spawn:
		SSPG N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		SSPD A 0;
	Dodge.Resume:
		Goto See.Fast;
	Idle:
		"####" AAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	Death.Alt1:
		"####" "#" 0 A_SpawnItemEx("SSGuard_Wounded_NoCount", flags: SXF_SETMASTER);
		"####" "#" -1;
		Stop;
	Death.Front:
		SSPA I 0 A_CheckFadeDeath;
		SSPA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		SSPB I 0 A_CheckFadeDeath;
		SSPB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		SPHS I 0 A_CheckFadeDeath;
		SPHS I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class WGuard : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Guard (Pistol)
	//$Color 4
	Health 30;
	Speed 2.5;
	PainChance 185;
	Obituary "$WGUARD";
	+MISSILEEVENMORE
	+MISSILEMORE
	Nazi.ZombieVariant "ZombieBrain";
	}
	States
	{
	Spawn:
		GRD2 N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		GRDD A 0;
	Dodge.Resume:
		Goto See.Fast;
	Missile: //slightly fast than Afrika & SS ones, also he shoot 2 rounds instead of one: this means reloading after 4 shoots - ozy81
		"####" E 9 A_FaceTarget;
	Missile.Aimed:
		"####" F 9 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 7 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",54,1,random(-6,6));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 9 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 7 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",54,1,random(-10,10));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 3) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 8;
		Goto See;
	Death.Alt1:
		"####" "#" 0 A_SpawnItemEx("WGuard_Wounded_NoCount", flags: SXF_SETMASTER);
		"####" "#" -1;
		Stop;
	Death.Front:
		GRDA I 0 A_CheckFadeDeath;
		GRDA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		GRDB I 0 A_CheckFadeDeath;
		GRDB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		GRHW I 0 A_CheckFadeDeath;
		GRHW I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class MP40Guard : Guard
{
	Default
	{
	//$Title Afrika Korps Guard (MP40)
	Obituary "$MPGUARD";
	SeeSound "Nazi2/Sighted";
	PainSound "Nazi2/Pain";
	DeathSound "Nazi2/Death";
	DropItem "Ammo9mm", 192;
	DropItem "GrenadePickup", 16;
	DropItem "MP40", 96;
	Nazi.NoAltDeath 1;
	}
	States
	{
	Spawn:
		MGRD N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		MGDD A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile: //he can shoot 8 times, 4 rounds per shoot - ozy81
		"####" E 8 A_FaceTarget;
	Missile.Aimed:
		"####" F 8 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" G 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 2 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" G 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 2 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" G 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 2 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" G 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		Goto See;
	Reload: //ozy81
		MGRD E 0 {bNoPain = TRUE;}
		"####" E 30 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Front:
		MGRA I 0 A_CheckFadeDeath;
		MGRA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		MGRB I 0 A_CheckFadeDeath;
		MGRB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		MGHA I 0 A_CheckFadeDeath;
		MGHA I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class LOfficer : MP40Guard //this has MP40 and it is more rapid than any other Officer
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Luftwaffe Officer
	Health 100;
	Speed 3.25;
	PainChance 100;
	Obituary "$LOFFICER";
	+MISSILEMORE
	Nazi.FrightMultiplier 0.5;
	Nazi.ZombieVariant "ZombieOfficer";
	}
	States
	{
	Spawn:
		LOFR N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		LOF2 A 0;
	Dodge.Resume:
		Goto See.Faster;
	Missile:
		"####" E 3 A_FaceTarget;
	Missile.Aimed:
		"####" E 3 A_FaceTarget;
		"####" F 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" F 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" F 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 2 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-12,12));
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" E 3 A_MonsterRefire(96,"See");
		"####" E 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		LOFR E 0 {bNoPain = TRUE;}
		"####" E 40 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Headshot: //no such state --N00b
		Stop;
	Death.Front:
		LOFA I 0 A_CheckFadeDeath;
		LOFA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		LOFB I 0 A_CheckFadeDeath;
		LOFB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	}
}

class SSMP40Guard : SSGuard
{
	Default
	{
	//$Title SS Guard (MP40)
	SeeSound "Nazi2/Sighted";
	PainSound "Nazi2/Pain";
	DeathSound "Nazi2/Death";
	DropItem "Ammo9mm", 192;
	DropItem "GrenadePickup", 16;
	DropItem "MP40", 96;
	Obituary "$SSMPGURD";
	Nazi.FrightMultiplier 0.9;
	Nazi.NoAltDeath 1;
	}
	States
	{
	Spawn:
		SSMG N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		SSMD A 0;
	Dodge.Resume:
		Goto See.Fast;
	Missile:
		"####" E 7 A_FaceTarget;
	Missile.Aimed:
		"####" F 7 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 31) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 3 A_MonsterRefire(10,"See");
		"####" E 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		SSMG E 0 {bNoPain = TRUE;}
		"####" E 35 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Front:
		SSMA I 0 A_CheckFadeDeath;
		SSMA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		SSMB I 0 A_CheckFadeDeath;
		SSMB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		SMHS I 0 A_CheckFadeDeath;
		SMHS I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	NaziSalute: //for c3m5_c --N00b
		SSMG A 0;
		"####" Y 8;
		"####" Z 14;
		"####" Y 6;
		Goto Spawn;
	}
}

class WMP40Guard : MP40Guard
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Guard (MP40)
	Health 30;
	Speed 2.5;
	Obituary "$WMPGUARD";
	+MISSILEMORE
	Nazi.ZombieVariant "ZombieBrain";
	}
	States
	{
	Spawn:
		MGR2 N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		MDR2 A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
		"####" E 3 A_FaceTarget;
	Missile.Aimed:
		"####" E 3 A_FaceTarget;
		"####" F 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" F 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" F 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 2 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-12,12));
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" E 3 A_MonsterRefire(96,"See");
		"####" E 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		MGR2 E 0 {bNoPain = TRUE;}
		"####" E 40 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Front:
		MDRA I 0 A_CheckFadeDeath;
		MDRA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		MDRB I 0 A_CheckFadeDeath;
		MDRB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		MGHW I 0 A_CheckFadeDeath;
		MGHW I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class WMP40GuardSleep : WMP40Guard
{
	Default
	{
	//$Title Wehrmacht Guard, Sleeping (MP40)
	//$Sprite MGR2O0
	SeeSound "";
	ActiveSound "Nazi2/Sighted";
	Base.NoMedicHeal;
	Nazi.ZombieVariant "";
	Nazi.IdleSound ""; // Don't talk when you're asleep
	}
	States
	{
	Spawn:
	Missile.Aimed: // This state label is only used to determine the frame used for AMBUSH monsters, so use it here so that the AMBUSH flag has no effect on the enemy's frames
		MGR2 O 0;
		Goto Look;
	Look:
		"####" O 0 A_StartSound("nazi/snore", CHAN_VOICE, 0, 1.0, ATTN_STATIC);
		"####" O 40 A_NaziLook;
		"####" PPP 10 A_SpawnItemEx("SleepEffect", random(-2,2), random(-2,2), random(24,32), 0, 0, 1, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
		Loop;
	See: //doesn't roll - ozy81
		"####" "#" 0 { user_incombat = True; } //mxd
		"####" "#" 0 {user_count2++; if(user_count2 > 1) {user_count2 = 0; return ResolveState("SeeLoop");} return ResolveState(null);}
		"####" Q 35;
		"####" R 8 A_ActiveSound;
	SeeLoop:
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(" "," ");
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(" "," ");
		"####" B 1 A_Chase;
		"####" # 0 A_PlayStepSound();
		"####" BBB 1 A_Chase(" "," ");
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(" "," ");
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(" "," ");
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(" "," ");
		"####" D 1 A_Chase;
		"####" # 0 A_PlayStepSound();
		"####" DDD 1 A_Chase(" "," ");
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(" "," ");
		Loop;
	Missile:
		"####" E 3 A_FaceTarget;
		"####" E 3 A_FaceTarget;
		"####" F 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" F 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-8,8));
		"####" F 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 2 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/mp40", CHAN_WEAPON); A_AlertMonsters(768); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",40,4,random(-12,12));
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" E 3 A_MonsterRefire(96,"SeeLoop");
		"####" E 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		MGR2 E 0 {bNoPain = TRUE;}
		"####" E 40 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto SeeLoop;
	Pain:
		"####" H 6 A_NaziPain(256);
		"####" H 0 A_Jump(256,"SeeLoop");
	}
}

class WToilet : WGuard
{
	Default
	{
	//$Category Monsters (BoA)/Toilet Soldiers
	//$Title Toilet Wehrmacht Guard (Pistol)
	+CANPASS
	+FIXMAPTHINGPOS
	Nazi.CrouchChance 0;
	Nazi.FrightMultiplier 0.0;
	Nazi.ZombieVariant "";
	}
	States
	{
	Spawn:
		GRDT A 1;
		"####" A 0 A_Jump(256,"Look.WC");
		Goto Look.WC;
	Look.Fart:
		"####" A 0 A_StartSound("nazi/farts", CHAN_AUTO, 0, frandom(0.1,1.0));
		"####" A 0 A_Jump(256,"Look.WC");
		Stop;
	Look.WC:
		"####" A 1 { A_Look(); A_SetTics(random(40,100)); }
		"####" B 1 { A_Look(); A_SetTics(random(100,400)); }
		"####" A 0 A_Jump(16,"Look.Fart");
		Loop;
	See: //doesn't roll - ozy81
		"####" A 0 { user_incombat = True; } //mxd
		"####" A 0 A_Jump(256,"See.Shot");
		Stop;
	See.Shot:
		"####" A 16;
		"####" A 8;
		"####" A 0 A_Jump(256, "Missile");
		Stop;
	Missile:
		"####" A 10 A_FaceTarget;
	Missile.Aimed:
		"####" C 10 A_FaceTarget;
		"####" D 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" D 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",32,1,random(-8,8));
		"####" C 8 A_SpawnItemEx("Casing9mm", 1, 0, 32, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" C 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" C 0 A_Jump(64, "LeaveWC");
		"####" C 0 A_Jump(256, "See");
		Stop;
	Reload:
		"####" C 0 {bNoPain = TRUE;}
		"####" C 30 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" C 0 A_SpawnItemEx("Casing9mm", 1, 0, 32, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" C 0 {bNoPain = FALSE;}
		"####" C 0 A_Jump(64, "LeaveWC");
		"####" C 0 A_Jump(256, "See");
		Stop;
	LeaveWC:
		"####" A 9 ReplaceWith("WGuard", "See");
		Stop;
	Pain:
		"####" E 6 A_NaziPain(0, True, -4);
		"####" E 0 A_Jump(192, "LeaveWC");
		"####" E 0 A_Jump(256, "See+1");
		Stop;
	Death:
		"####" F 0 {bCanPass = FALSE;}
		"####" F 0 {bNoGravity = TRUE;}
		"####" F 5;
		"####" G 5 A_Scream;
		"####" H 5 A_UnblockAndDrop;
		"####" I 5;
		"####" I 0 A_StartSound("nazi/farts", CHAN_AUTO, 0, frandom(0.5,1.0));
		"####" J 5 A_CheckAltDeath;
		"####" J -1;
		Stop;
	Death.Alt1:
		"####" J -1 A_SpawnItemEx("Shit", random(-16,16), 0, 0, SXF_NOCHECKPOSITION);
		Stop;
	}
}

class WToilet2 : WToilet
{
	Default
	{
	//$Title Peeing Wehrmacht Guard (Pistol)
	}
	States
	{
	Spawn:
		GRDP A 1;
		Goto Look;
	Look:
		GRDP A 0 A_StartSound("nazi/peeing", CHAN_VOICE, 0, frandom(0.5,0.8), ATTN_STATIC);
		"####" ACBDEFDGIHBC 1 { A_Look(); A_SetTics(random(20,40)); }
		Loop;
	See: //doesn't roll - ozy81
		GRDP A 0 A_StopSound(CHAN_VOICE);
		"####" A 0 { user_incombat = True; } //mxd
		"####" J 35;
	LeaveWC:
		GRDP A 2 ReplaceWith("WGuard", "See");
		Stop;
	Pain:
		"####" K 6 A_NaziPain(0, True);
		"####" K 0 A_Jump(256, "LeaveWC");
		Stop;
	Death:
		GRD2 I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	}
}

class SSToilet : WToilet
{
	Default
	{
	//$Title Toilet SS Officer (Pistol)
	Nazi.ZombieVariant "";
	}
	States
	{
	Spawn:
		SSOT A 1;
		Goto Look.WC;
	See: //doesn't roll - ozy81
		"####" A 0 { user_incombat = True; } //mxd
		"####" A 0 A_Jump(256,"See.Shot");
		Stop;
	Missile.Aimed:
		"####" C 6 A_FaceTarget;
		"####" D 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" D 6 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",32,1,random(-8,8));
		"####" C 6 A_SpawnItemEx("Casing9mm", 1, 0, 32, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" C 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" C 0 A_Jump(64, "LeaveWC");
		"####" C 0 A_Jump(256, "See+1");
		Stop;
	Reload:
		"####" C 0 {bNoPain = TRUE;}
		"####" C 20 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" C 0 A_SpawnItemEx("Casing9mm", 1, 0, 32, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" C 0 {bNoPain = FALSE;}
		"####" C 0 A_Jump(64, "LeaveWC");
		"####" C 0 A_Jump(256, "See+1");
	LeaveWC:
		"####" A 9 ReplaceWith("SSOfficer", "See");
		Stop;
	Death:
		SSOT F 0 {bCanPass = FALSE;}
		Goto Super::Death+1;
	Death.Alt1:
		SSOT J -1 A_SpawnItemEx("Shit", random(-16,16), 0, 0, SXF_NOCHECKPOSITION);
		Stop;
	}
}

class SSToilet2 : WToilet
{
	Default
	{
	//$Title Peeing SS Officer (Pistol)
	}
	States
	{
	Spawn:
		SSOP A 1;
		Goto Look;
	Look:
		SSOP A 0 A_StartSound("nazi/peeing", CHAN_VOICE, 0, frandom(0.5,0.8), ATTN_STATIC);
		"####" ACBDEFDGIHBC 1 { A_Look(); A_SetTics(random(20,40)); }
		Loop;
	See: //doesn't roll - ozy81
		"####" A 0 { user_incombat = True; } //mxd
		SSOP A 0 A_StopSound(CHAN_VOICE);
		"####" J 35;
	LeaveWC:
		"####" A 9 ReplaceWith("SSOfficer", "See");
		Stop;
	Pain:
		SSOP K 6 A_NaziPain(0, True);
		"####" K 0 A_Jump(256, "LeaveWC");
		Stop;
	Death:
		SSOF I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	}
}

class Officer : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Afrika Korps
	//$Title Afrika Korps Officer
	//$Color 4
	Speed 3.5;
	Obituary "$OFFICER";
	SeeSound "Nazi4/Sighted";
	PainSound "Nazi4/Pain";
	DeathSound "Nazi4/Death";
	Nazi.FrightMultiplier 0.8;
	Nazi.ZombieVariant "AKZombieOfficer";
	}
	States
	{
	Spawn:
		OFFI N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		OFFD A 0;
	Dodge.Resume:
		Goto See.Faster;
	Missile:
		"####" E 4 A_FaceTarget;
	Missile.Aimed:
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 6 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",52,1,random(-4,4));
		"####" F 5 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_Jump(256,"See");
		Stop;
	Death.Alt1:
		"####" "#" 0 A_SpawnItemEx("Officer_Wounded_NoCount", flags: SXF_SETMASTER);
		"####" "#" -1;
		Stop;
	Death.Front:
		OFFA I 0 A_CheckFadeDeath;
		OFFA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		OFFB I 0 A_CheckFadeDeath;
		OFFB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		OFHA I 0 A_CheckFadeDeath;
		OFHA I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	Idle:
		"####" AAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class SSOfficer : Officer
{
	Default
	{
	//$Category Monsters (BoA)/SS
	//$Title SS Officer
	Health 40;
	Speed 4.5;
	Obituary "$SSOFFICE";
	Nazi.FrightMultiplier 0.7;
	Nazi.ZombieVariant "SSZombieOfficer";
	}
	States
	{
	Spawn:
		SSOF N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		SSOD A 0;
	Dodge.Resume:
		Goto See.Faster;
	Missile: //2 shoots per round
		"####" E 5 A_FaceTarget;
	Missile.Aimed:
		"####" F 5 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 5 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",52,1,random(-6,6));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 5 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",52,1,random(-6,6));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 3) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 4;
		"####" F 0 A_Jump(256,"See");
		Stop;
	Death.Alt1:
		"####" "#" 0 A_SpawnItemEx("SSOfficer_Wounded_NoCount", flags: SXF_SETMASTER);
		"####" "#" -1;
		Stop;
	Death.Front:
		SSOA I 0 A_CheckFadeDeath;
		SSOA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		SSOB I 0 A_CheckFadeDeath;
		SSOB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		SOHS I 0 A_CheckFadeDeath;
		SOHS I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	Idle:
		"####" AAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	NaziSalute: //for c3m5_c --N00b
		SSOF A 1;
		"####" Y 8;
		"####" Z 14;
		"####" Y 6;
		Goto Spawn;
	}
}

class WOfficer : Officer
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Officer
	Health 30;
	Speed 4;
	PainChance 180;
	Obituary "$WOFFICER";
	+MISSILEEVENMORE
	+MISSILEMORE
	Nazi.FrightMultiplier 0.8;
	Nazi.ZombieVariant "ZombieOfficer";
	}
	States
	{
	Spawn:
		OFR2 N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		OFD2 A 0;
	Dodge.Resume:
		Goto See.Faster;
	Missile: //4 shoots per round
		"####" E 4 A_FaceTarget;
	Missile.Aimed:
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 5 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",52,1,random(-4,4));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 5 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",52,1,random(-6,6));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 5 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",52,1,random(-8,8));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 5 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",52,1,random(-8,8));
		"####" G 0 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 1) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 3;
		"####" F 0 A_Jump(256,"See");
		Stop;
	Death.Alt1:
		"####" "#" 0 A_SpawnItemEx("WOfficer_Wounded_NoCount", flags: SXF_SETMASTER);
		"####" "#" -1;
		Stop;
	Death.Front:
		OFRA I 0 A_CheckFadeDeath;
		OFRA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		OFRB I 0 A_CheckFadeDeath;
		OFRB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		OFHW I 0 A_CheckFadeDeath;
		OFHW I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class RifleGuard : MP40Guard
{
	Default
	{
	//$Title Afrika Korps Guard (Rifle)
	Obituary "$RIFLSOLD";
	SeeSound "Nazi3/Sighted";
	DropItem "G43", 96;
	DropItem "MauserAmmo", 192, 5;
	MaxTargetRange 768;
	}
	States
	{
	Spawn:
		RGRD N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		RGDD A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
		"####" E 10 A_FaceTarget;
	Missile.Aimed:
		"####" F 20 A_FaceTarget;
		"####" G 0 { A_StartSound("mauser/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyRifleTracer",40,8,random(-4,4));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 8,0,42, random(3,4), random(-4,4), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 8;
		"####" F 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_StartSound("mauser/cock", CHAN_AUTO, 0, 0.25);
		"####" E 10 A_FaceTarget;
		Goto See;
	Reload: //ozy81
		"####" E 0 {bNoPain = TRUE;}
		"####" E 30 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 20 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("MauserRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Front:
		RGRA I 0 A_CheckFadeDeath;
		RGRA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		RGRB I 0 A_CheckFadeDeath;
		RGRB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		RGHA I 0 A_CheckFadeDeath;
		RGHA I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class WRifleGuard : RifleGuard
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Guard (Rifle)
	Health 30;
	Speed 2.5;
	Obituary "$WRIFSOLD";
	+MISSILEMORE
	MaxTargetRange 800;
	Nazi.ZombieVariant "ZombieBrain";
	}
	States
	{
	Spawn:
		RGR2 N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		RGD2 A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
		"####" E 10 A_FaceTarget;
	Missile.Aimed:
		"####" F 20 A_FaceTarget;
		"####" G 0 { A_StartSound("mauser/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 8 LIGHT("NAZIFIRE")A_SpawnProjectile("EnemyRifleTracer",44,5,random(-4,4));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 1, 0, 56, random(1,2), random(-4,4), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("mauser/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 8 LIGHT("NAZIFIRE")A_SpawnProjectile("EnemyRifleTracer",44,5,random(-10,10));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 4;
		"####" F 0 {user_count++; if(user_count > 4) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 4 A_StartSound("mauser/cock", CHAN_AUTO, 0, 0.25);
		"####" E 10 A_FaceTarget;
		Goto See;
	Death.Front:
		RGDA I 0 A_CheckFadeDeath;
		RGDA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		RGDB I 0 A_CheckFadeDeath;
		RGDB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot:
		RGHW I 0 A_CheckFadeDeath;
		RGHW I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class WShotgunGuard : WRifleGuard
{
	Default
	{
	//$Title Wehrmacht Guard (Shotgun)
	Health 40;
	Speed 2.75; //a bit faster and tougher than the riflemen
	Obituary "$WSGSOLD";
	DropItem "TrenchShotgun", 64;
	DropItem "Ammo12Gauge", 192;
	MaxTargetRange 512;
	}
	States
	{
	Spawn:
		SGR2 N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		SGD2 A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
		"####" E 7 A_FaceTarget;
	Missile.Aimed:
		"####" F 15 A_FaceTarget; //faster reaction
		"####" G 0 { A_StartSound("shotgun/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" G 8 LIGHT("NAZIFIRE")
		{
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
			A_SpawnProjectile("EnemyShotgunTracer",44,5,random(-6,6));
		}
		"####" G 0 A_SpawnItemEx("ShotgunCasing", 1, 0, 56, random(1,2), random(-4,4), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 4;
		"####" F 0 {user_count++; if(user_count > 8) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 4 A_StartSound("shotgun/pump", CHAN_AUTO, 0, 0.25);
		"####" E 8 A_FaceTarget;
		Goto See;
	Reload:
		"####" E 0 {bNoPain = TRUE;}
		"####" E 25 A_StartSound("shotgun/load", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 17 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM); //mauser/insert sound
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Front:
		SGRA I 0 A_CheckFadeDeath;
		SGRA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		SGRB I 0 A_CheckFadeDeath;
		SGRB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Death.Headshot: //placeholder
		RGHW I 0 A_CheckFadeDeath;
		RGHW I 5 A_Scream;
		"####" J 5 A_GibsUnblockAndDrop;
		"####" K 3;
		"####" L 3;
		"####" M -1;
		Stop;
	}
}

class ArcticRifleGuard : RifleGuard
{
	Default
	{
	//$Category Monsters (BoA)/Arctic
	//$Title Arctic Guard (Rifle)
	Health 50;
	Speed 2;
	Obituary "$ARIFSOLD";
	+MISSILEEVENMORE
	MaxTargetRange 896;
	Nazi.ZombieVariant "";
	}
	States
	{
	Spawn:
		SNRF N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		SNRD A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile: //a bit slower and sharp than other ones, but it has +20hp - ozy81
		"####" E 7 A_FaceTarget;
	Missile.Aimed:
		"####" E 16 A_FaceTarget;
		"####" F 0 { A_StartSound("mauser/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" F 9 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyRifleTracer",40,8,random(-4,4));
		"####" F 0 A_SpawnItemEx("MauserRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 5 A_FaceTarget;
		"####" E 0 { A_StartSound("mauser/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" F 9 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyRifleTracer",40,8,random(-12,12));
		"####" F 0 A_SpawnItemEx("MauserRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 6;
		"####" E 0 {user_count++; if(user_count > 4) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" E 4 A_StartSound("mauser/cock", CHAN_AUTO, 0, 0.25);
		"####" E 7 A_FaceTarget;
		Goto See;
	Death.Back:
	Death.Headshot: //no such state --N00b
		Stop;
	Death.Front:
		SNRA I 0 A_CheckFadeDeath;
		SNRA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class WaffenSS : SSMP40Guard
{
	Default
	{
	//$Title Waffen SS
	Health 80;
	Obituary "$SSWAFFEN";
	SeeSound "Nazi3/Sighted";
	DropItem "Ammo9mm", 192;
	DropItem "GrenadePickup", 32;
	DropItem "MP40", 96;
	Nazi.FrightMultiplier 0.9;
	Nazi.ZombieVariant "";
	Nazi.TotaleGierDrop 2;
	}
	States
	{
	Spawn:
		WAFF N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		WAFD A 0;
	Dodge.Resume:
		Goto See.Fast;
	Missile:
		"####" E 6 A_FaceTarget;
	Missile.Aimed:
		"####" F 6 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM); A_AlertMonsters(1024); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",38,6,random(-4,4));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 4 A_MonsterRefire(96,"See");
		"####" F 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		WAFF E 0 {bNoPain = TRUE;}
		"####" E 25 A_StartSound("sten/reload", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Back:
	Death.Headshot: //no such state --N00b
		Stop;
	Death.Front:
		WAFA I 0 A_CheckFadeDeath;
		WAFA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class ArcticWaffen : WaffenSS
{
	Default
	{
	//$Category Monsters (BoA)/Arctic
	//$Title Waffen Arctic
	Health 90;
	Obituary "$ARWAFFEN";
	DropItem "Ammo9mm", 192;
	DropItem "GrenadePickup", 8;
	DropItem "MP40", 96;
	}
	States
	{
	Spawn:
		SNWF N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		SNWD A 0;
	Dodge.Resume:
		Goto See.Fast;
	Missile: //slightly slow than the SS variant, also it has less chances to drop a grenade and +10hp
		"####" E 7 A_FaceTarget;
	Missile.Aimed:
		"####" F 7 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM); A_AlertMonsters(1024); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",38,6,random(-4,4));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 4 A_MonsterRefire(96,"See");
		"####" F 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		SNWF E 0 {bNoPain = TRUE;}
		"####" E 28 A_StartSound("sten/reload", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Back:
	Death.Headshot: //no such state --N00b
		Stop;
	Death.Front:
		SWDA I 0 A_CheckFadeDeath;
		SWDA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class Paratrooper : WaffenSS
{
	Default
	{
	//$Title Paratrooper
	Health 90;
	Scale 0.64;
	Obituary "$PARATROP";
	DropItem "Ammo9mm", 192;
	DropItem "MP40", 96;
	}
	States
	{
	Spawn:
		PARA N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		PARD A 0;
	Dodge.Resume:
		Goto See.Fast;
	Missile:
		"####" E 7 A_FaceTarget;
	Missile.Aimed:
		"####" F 7 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM); A_AlertMonsters(1024); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",38,6,random(-4,4));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 4 A_MonsterRefire(64,"See");
		"####" F 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		PARA E 0 {bNoPain = TRUE;}
		"####" E 35 A_StartSound("sten/reload", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		PADA I 0 A_CheckFadeDeath;
		PADA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class Sniper : NaziStandard
{
	Default
	{
		//$Category Monsters (BoA)/Afrika Korps
		//$Title Afrika Korps Sniper
		//$Color 4
		Base.NoMedicHeal;
		Health 50;
		Speed 0;
		Mass 1000;
		SeeSound "";
		Obituary "$SNIPER";
		DropItem "Kar98k", 72;
		DropItem "MauserAmmo", 192, 5;
		MaxTargetRange 0;
		+LOOKALLAROUND
		+Nazi.IGNOREFOG;
	}
	States
	{
		Spawn:
			SNIA F 0;
			Goto Look;
		See:
			SNIA F 0;
			Goto See.Sniper;
		Pain:
			SNIA I 9 A_NaziPain(256);
			Goto See;
		Melee:
		Missile:
			SNIA F 32 A_FaceTarget;
			"####" G 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
			"####" G 0 A_FaceTarget;
			"####" G 8 LIGHT("NAZIFIRE")A_SpawnProjectile("EnemyRifleTracer",44,5);
			"####" G 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
			"####" F 32;
			"####" F 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
			"####" F 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
			Goto See;
		Reload: //ozy81
			SNIA E 0 {bNoPain = TRUE;}
			"####" E 20 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
			"####" F 20 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
			"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
			"####" F 0 {bNoPain = FALSE;}
			Goto See;
		Death:
			"####" # 0 { mass = 70; }
			SNIA I 5 A_RandomDeathAnim;
			"####" J 5 A_Scream;
			"####" K 5 A_UnblockAndDrop;
			"####" L 5;
			"####" M -1;
			Stop;
		Death.Front:
			SNA1 I 0 A_CheckFadeDeath;
			SNA1 I 5 A_Scream;
			"####" J 5 A_UnblockAndDrop;
			"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
			"####" L 5;
			"####" M 5;
			"####" N 5;
			"####" O -1;
			Stop;
		Death.Back:
			SNB1 I 0 A_CheckFadeDeath;
			SNB1 I 5 A_Scream;
			"####" J 5 A_UnblockAndDrop;
			"####" KLM 5;
			"####" N -1;
			Stop;
		Raise: //raise is forced here due to inheritances
			SNIA MLKJI 5;
		Idle:
			Goto Look;
	}
}

class WSniper : Sniper
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Sniper
	//$Sprite RGR2F1
	Nazi.ZombieVariant "ZombieBrain";
	}
	States
	{
	Spawn:
		SNW2 F 0;
		Goto Look;
	See:
		SNW2 F 0;
		Goto See.Sniper;
	Pain:
		SNIW I 9 A_NaziPain(256);
		Goto See;
	Melee:
	Missile:
		SNW2 F 32 A_FaceTarget;
		"####" G 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" G 0 A_FaceTarget;
		"####" G 8 LIGHT("NAZIFIRE")A_SpawnProjectile("EnemyRifleTracer",44,5);
		"####" G 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 32;
		"####" F 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Reload: //ozy81
		SNW2 E 0 {bNoPain = TRUE;}
		"####" E 20 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" F 20 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		SNIW I 5 A_RandomDeathAnim;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	Death.Front:
		SNWA I 0 A_CheckFadeDeath;
		SNWA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		SNWB I 0 A_CheckFadeDeath;
		SNWB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Raise:
		SNIW MLKJI 5;
	Idle:
		Goto Look;
	}
}

class WSniper_Switchable : WSniper
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Sniper (switchable)
	//$Sprite RGR2F1
	}
	States
	{
	Spawn:
		SNW2 F -1;
		Stop;
	Active:
		"####" "#" 0;
		Goto Look;
	}
}

class Sniper_Crouch : NaziStandard
{
	Default
	{
	//$Category Monsters (BoA)/Afrika Korps
	//$Title Afrika Korps Sniper (crouch)
	//$Color 4
	Base.NoMedicHeal;
	Health 50;
	Speed 0;
	Mass 1000;
	SeeSound "";
	Obituary "$SNIPER";
	DropItem "Kar98k", 48;
	DropItem "MauserAmmo", 192, 5;
	+DROPOFF
	+LOOKALLAROUND
	}
	States
	{
	Spawn:
		SNIA C 0;
		Goto Look;
	See:
		"####" C 0;
		Goto See.Sniper;
	Pain:
		"####" N 6 A_NaziPain(256);
		Goto See;
	Melee:
	Missile:
		"####" C 28 A_FaceTarget; //a bit fast than normal one
		"####" D 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" G 0 A_FaceTarget;
		"####" D 8 LIGHT("NAZIFIRE")A_SpawnProjectile("EnemyRifleTracer",34,5);
		"####" D 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 34, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" C 28;
		"####" C 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" C 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Reload: //ozy81
		SNIA B 0 {bNoPain = TRUE;}
		"####" B 20 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" C 20 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		"####" # 0 { mass = 70; }
		"####" K 7 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" M -1;
		Stop;
	Raise:
		"####" MLKJI 5;
		Goto See;
	Idle:
		Goto Look;
	}
}

class WSniper_Crouch : Sniper_Crouch
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Sniper (crouch)
	//$Sprite SNIWC0
	}
	States
	{
	Spawn:
		SNIW C 0;
		Goto Look;
	Reload: //ozy81
		SNIW B 0 {bNoPain = TRUE;}
		"####" B 20 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" C 20 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	}
}

class WSniper_CrouchSwitchable : WSniper_Crouch
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Sniper (switchable, crouch)
	//$Sprite SNIWC0
	}
	States
	{
	Spawn:
		SNIW C -1;
		Stop;
	Active:
		"####" "#" 0;
		Goto Look;
	}
}

class ArcticSniper : NaziStandard
{
	Default
	{
	//$Category Monsters (BoA)/Arctic
	//$Title Arctic Sniper
	//$Color 4
	Base.NoMedicHeal;
	Health 60;
	Speed 0;
	Mass 1000;
	SeeSound "";
	Obituary "$SNIPER";
	DropItem "Kar98k", 72;
	DropItem "MauserAmmo", 192, 5;
	+LOOKALLAROUND
	}
	States
	{
	Spawn:
		SNSP A 0;
		Goto Look;
	See:
		SNSP A 0;
		Goto See.Statisch;
	Pain:
		SNRF I 6 A_NaziPain(256);
		Goto See;
	Melee:
	Missile: //attack & reload are slightly fast than other snipers - ozy81
		SNSP B 28 A_FaceTarget;
		"####" B 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" B 0 A_FaceTarget;
		"####" C 7 LIGHT("NAZIFIRE")A_SpawnProjectile("EnemyRifleTracer",44,5);
		"####" C 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" A 28;
		"####" A 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" A 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Reload: //ozy81
		SNSP A 0 {bNoPain = TRUE;}
		"####" A 16 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" A 16 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" A 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		"####" # 0 { mass = 70; }
		SNRF I 5 A_RandomDeathAnim;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		SNDA I 0 A_CheckFadeDeath;
		SNDA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Raise:
		"####" MLKJI 5;
	Idle:
		Goto Look;
	}
}

class ArcticSniper_Crouch : NaziStandard
{
	Default
	{
	//$Category Monsters (BoA)/Arctic
	//$Title Arctic Sniper (crouch)
	//$Color 4
	Base.NoMedicHeal;
	Health 50;
	Speed 0;
	Mass 1000;
	SeeSound "";
	Obituary "$SNIPER";
	DropItem "Kar98k", 72;
	DropItem "MauserAmmo", 192, 5;
	+DROPOFF
	+LOOKALLAROUND
	}
	States
	{
	Spawn:
		SNSP D 0;
		Goto Look;
	See:
		SNSP D 0;
		Goto See.Statisch;
	Pain:
		SNSP N 6 A_NaziPain(256);
		Goto See;
	Melee:
	Missile: //attack & reload are slightly fast than other snipers - ozy81
		SNSP E 24 A_FaceTarget; //a bit fast than normal one
		"####" E 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" E 0 A_FaceTarget;
		"####" F 7 LIGHT("NAZIFIRE")A_SpawnProjectile("EnemyRifleTracer",34,5);
		"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 34, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" D 24;
		"####" D 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" D 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Reload: //ozy81
		SNSP D 0 {bNoPain = TRUE;}
		"####" D 16 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" D 16 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" D 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" D 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		"####" # 0 { mass = 70; }
		SNRF K 7 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" M -1;
		Stop;
	Raise:
		SNRF MLKJI 5;
		Goto See;
	Idle:
		Goto Look;
	}
}

class WGrenadier: Sniper_Crouch
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Grenadier
	//$Sprite WGRNA0
	SeeSound "Nazi1/Sighted";
	PainSound "Nazi1/Pain";
	DeathSound "Nazi1/Death";
	DropItem "GrenadePickup", 32;
	Obituary "$GRENADIER";
	MaxTargetRange 1024;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		WGRN A 0;
		Goto Look;
	See:
		"####" A 0;
		Goto See.Statisch;
	Pain:
		"####" D 6 A_NaziPain(256, True, -12);
		Goto See;
    Pain.Fire:
	Pain.Electric:
        "####" D 1 A_Jump(192,"Pain");
    Pain.Rocket:
		"####" D 0 A_XDie;
		Stop;
	Melee:
	Missile:
		"####" B 0 A_JumpIfInTargetLOS("Missile.Aimed",90,JLOSF_DEADNOJUMP,radius+1024,0);
		Goto Idle;
	Missile.Aimed:
		"####" B 20 A_FaceTarget;
		"####" B 0 A_JumpIfCloser(radius+384,"Missile4",TRUE);
		"####" B 0 A_Jump(64,"Missile2");
		"####" B 0 A_Jump(16,"Missile3");
		"####" C 4 A_ArcProjectile("VeryFastGrenade",32,16,frandom(-4,4),CMF_OFFSETPITCH,8);
		"####" A 28;
		Goto See;
	Missile2:
		"####" B 30 A_FaceTarget;
		"####" C 8 A_ArcProjectile("HandGrenade",24,16,frandom(-4,4));
		"####" A 15;
		"####" B 30 A_FaceTarget;
		"####" C 8 A_ArcProjectile("VerySlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION);
		Goto See;
	Missile3:
		"####" B 25 A_FaceTarget;
		"####" C 8 A_ArcProjectile("HandGrenade",24,16,frandom(-4,4));
		"####" A 10;
		"####" B 30 A_FaceTarget;
		"####" C 8 A_ArcProjectile("SlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION);
		"####" A 15;
		"####" B 35 A_FaceTarget;
		"####" C 8 A_ArcProjectile("VerySlowGrenade",24,16,frandom(-16,16));
		Goto See;
	Missile4:
		"####" B 10 A_FaceTarget;
		"####" C 8 A_ArcProjectile("SlowGrenade",24,16,frandom(-4,4),CMF_AIMDIRECTION);
		"####" A 20;
		Goto See;
	Death:
		WGRN D 0 A_Jump(64, "XDeath");
		"####" D 5;
		"####" E 5 A_Scream;
		"####" F 5 A_UnblockAndDrop;
		"####" G 5;
		"####" H -1;
		Stop;
	XDeath:
    Death.Fire:
    Death.Electric:
    Death.Rocket:
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_Nazis",0,0,32);
		Goto Super::Death.Fire;
	Idle:
		Goto Look;
	}
}

class AGrenadier : WGrenadier
{
	Default
	{
	//$Category Monsters (BoA)/Afrika Korps
	//$Title Afrika Korps Grenadier
	//$Sprite AGRNA1
	Obituary "$GRENADIER";
	}
	States
	{
	Spawn:
		AGRN A 0;
		Goto Look;
	Missile.Aimed:
		"####" B 25 A_FaceTarget;
		"####" B 0 A_JumpIfCloser(radius+384,"Missile4",TRUE);
		"####" B 0 A_Jump(64,"Missile2");
		"####" B 0 A_Jump(16,"Missile3");
		"####" C 6 A_ArcProjectile("VeryFastGrenade",32,16,frandom(-4,4),CMF_OFFSETPITCH,8);
		"####" A 30;
		Goto See;
	Missile2:
		"####" B 35 A_FaceTarget;
		"####" C 9 A_ArcProjectile("HandGrenade",24,16,frandom(-4,4));
		"####" A 20;
		"####" B 30 A_FaceTarget;
		"####" C 9 A_ArcProjectile("VerySlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION);
		Goto See;
	Missile3:
		"####" B 28 A_FaceTarget;
		"####" C 8 A_ArcProjectile("HandGrenade",24,16,frandom(-4,4));
		"####" A 15;
		"####" B 30 A_FaceTarget;
		"####" C 8 A_ArcProjectile("SlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION);
		"####" A 15;
		"####" B 38 A_FaceTarget;
		"####" C 8 A_ArcProjectile("VerySlowGrenade",24,16,frandom(-16,16));
		Goto See;
	Missile4:
		"####" B 15 A_FaceTarget;
		"####" C 8 A_ArcProjectile("SlowGrenade",24,16,frandom(-4,4),CMF_AIMDIRECTION);
		"####" A 25;
		Goto See;
	Death:
		AGRN D 0 A_Jump(64, "XDeath");
		"####" D 5;
		"####" E 5 A_Scream;
		"####" F 5 A_UnblockAndDrop;
		"####" G 5;
		"####" H -1;
		Stop;
	}
}

class SGrenadier : WGrenadier
{
	Default
	{
	//$Category Monsters (BoA)/SS
	//$Title SS Grenadier
	//$Sprite SGRNA0
	Obituary "$GRENADIER";
	}
	States
	{
	Spawn:
		SGRN A 0;
		Goto Look;
	Missile.Aimed:
		"####" B 15 A_FaceTarget;
		"####" B 0 A_JumpIfCloser(radius+384,"Missile4",TRUE);
		"####" B 0 A_Jump(64,"Missile2");
		"####" B 0 A_Jump(16,"Missile3");
		"####" C 4 A_ArcProjectile("VeryFastGrenade",32,16,frandom(-4,4),CMF_OFFSETPITCH,8);
		"####" A 20;
		Goto See;
	Missile2:
		"####" B 25 A_FaceTarget;
		"####" C 6 A_ArcProjectile("HandGrenade",24,16,frandom(-4,4));
		"####" A 15;
		"####" B 25 A_FaceTarget;
		"####" C 6 A_ArcProjectile("VerySlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION);
		Goto See;
	Missile3:
		"####" B 20 A_FaceTarget;
		"####" C 6 A_ArcProjectile("HandGrenade",24,16,frandom(-4,4));
		"####" A 5;
		"####" B 25 A_FaceTarget;
		"####" C 6 A_ArcProjectile("SlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION);
		"####" A 12;
		"####" B 30 A_FaceTarget;
		"####" C 6 A_ArcProjectile("VerySlowGrenade",24,16,frandom(-16,16));
		Goto See;
	Missile4:
		"####" B 8 A_FaceTarget;
		"####" C 6 A_ArcProjectile("SlowGrenade",24,16,frandom(-4,4),CMF_AIMDIRECTION);
		"####" A 15;
		Goto See;
	Death:
		SGRN D 0 A_Jump(64, "XDeath");
		"####" D 5;
		"####" E 5 A_Scream;
		"####" F 5 A_UnblockAndDrop;
		"####" G 5;
		"####" H -1;
		Stop;
	}
}

class WPanzerGuard : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Wehrmacht
	//$Title Wehrmacht Panzerschreck Guard
	//$Color 4
	Base.NoMedicHeal;
	Health 50;
	Speed 0;
	Mass 1000;
	SeeSound "";
	Obituary "$WPANZER";
	DropItem "Panzerschreck", 255;
	DropItem "PanzerAmmo", 48, 2;
	-DONTHARMSPECIES
	+DROPOFF
	+LOOKALLAROUND
	}
	States
	{
	Spawn:
		WPNZ A 0;
		Goto Look;
	See:
		"####" A 0;
		Goto See.Statisch;
	Pain:
		"####" D 6 A_NaziPain(256);
		Goto See;
    Pain.Fire:
	Pain.Electric:
        "####" D 1 A_Jump(192,"Pain");
    Pain.Rocket:
		"####" D 0 A_XDie;
		Stop;
	Melee:
	Missile:
		"####" B 0 A_JumpIfInTargetLOS("Missile.Aimed", 45, JLOSF_DEADNOJUMP | JLOSF_CLOSENOJUMP, radius+1024, radius+128); //try avoid shoot at his feet while near him
		Goto Idle;
	Missile.Aimed:
		"####" A 1 { A_SetTics(random(30,45)); A_FaceTarget(); }
		"####" B 0 { A_StartSound("panzer/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" B 4;
		"####" B 0 A_Jump(128,"Missile.AimedBadly");
		"####" C 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPanzerRocket", 34, -10);
		"####" A 40;
		"####" A 0 {user_count++; if(user_count > 1) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" A 0;
		Goto See;
	Missile.AimedBadly:
		"####" C 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPanzerRocket", 34, -10, random(-12,12));
		"####" A 40;
		"####" A 0 {user_count++; if(user_count > 1) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" A 0;
		Goto See;
	Reload: //ozy81
		"####" A 0 {bNoPain = TRUE;}
		"####" A 70 A_StartSound("panzer/load", CHAN_ITEM, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		"####" # 0 { mass = 70; }
		"####" D 0 A_Jump(64,"Death.Boom");
		"####" D 3;
		"####" E 5;
		MGR2 K 7 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" M -1;
		Stop;
	XDeath:
    Death.Fire:
    Death.Electric:
    Death.Rocket:
		Goto Super::XDeath.Boom;
	Raise: //not used
		MGR2 MLK 5;
		WPNZ ED 2;
		Goto See;
	Idle:
		Goto Look;
	}
}

class FlamerSoldier : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Nazi Flamer (Soldier)
	//$Color 4
	Health 100;
	Mass 70;
	Obituary "$FLAMEBOY";
	DropItem "FlameAmmo", 192;
	DropItem "Pyrolight", 48;
	MaxTargetRange 256;
	Base.NoMedicHeal;
	Nazi.FrightMultiplier 0.75;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		FLSL A 0;
		Goto Look;
	See:
		Goto See.Normal;
	Missile: //fires 10 times before reaching reload state
		"####" F 5;
	Missile.Aimed:
		"####" F 10 A_FaceTarget;
		"####" HHHHH 1 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyFlamerShot",38,4);
		"####" G 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 6 A_MonsterRefire(10,"See");
		Goto Missile+1;
	Reload: //ozy81
		"####" F 0 {bNoPain = TRUE;}
		"####" F 40 A_StartSound("flamer/reload", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("PyroCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	Pain:
		FLSL I 6 A_NaziPain(256);
		"####" I 0 A_Jump(256,"See");
		Stop;
	Pain.Fire:
	Pain.Electric:
        "####" I 1 A_Jump(192,"Pain");
    Pain.Rocket:
		"####" I 0 A_XDie;
		Stop;
	Death:
		"####" J 0 A_Jump(64, "XDeath");
		"####" J 5;
		"####" K 5 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" M 5;
		"####" N -1;
		Stop;
	XDeath:
    Death.Fire:
    Death.Electric:
    Death.Rocket:
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_Nazis",0,0,32);
		Goto Super::Death.Fire;
	}
}

class AKFlamerSoldier : FlamerSoldier
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Afrika Korps Flamer (Soldier)
	//$Color 4
	Health 80;
	Obituary "$AKFLAMEBOY";
	}
	States
	{
	Spawn:
		FLS2 A 0;
		Goto Look;
	See:
		Goto See.Normal;
	Pain:
		FLS2 I 6 A_NaziPain(256);
		"####" I 0 A_Jump(256,"See");
		Stop;
	}
}

class Gestapo : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Gestapo Officer
	//$Color 4
	Speed 3.5;
	Health 80;
	Obituary "$GESTAPO";
	DropItem "Ammo9mm", 172;
	DropItem "AmmoBox9mm", 16;
	DropItem "Luger9mm", 96;
	Nazi.FrightMultiplier 0.5;
	Nazi.NoAltDeath 1;
	}
	States
	{
	Spawn:
		GSAP N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		GSAD A 0;
	Dodge.Resume:
		Goto See.Normal;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		GSAA I 0 A_CheckFadeDeath;
		GSAA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class Mechanic : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Mechanic (Pistol)
	//$Color 4
	Health 50;
	Speed 2.37;
	Obituary "$MECHANIC";
	Nazi.FrightMultiplier 0.5;
	Nazi.CanSurrender 1;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		MNIC O 1 {
			if (user_incombat) { return ResolveState("Look"); }
			return ResolveState(null);
		}
		MNIC N 1;
		Goto Look;
	SurrenderSprite:
		MNIS E 0;
	See:
		Goto See.Loop;
	See.Loop:
		"####" "#" 0 {
			if (!user_incombat) {
				user_incombat = TRUE;
				user_count2++;
				if(user_count2 < 2) { A_SpawnItemEx("ToolBox",0,-8,22,0,0,0,0,SXF_NOCHECKPOSITION); }
			}
		}
		"####" A 1 A_NaziChase; // This line is causing crashes on C3M6_B for some reason... - Looks like setting mechanics MBF Strife Friendly trigger a problem
		"####" AA 1 A_NaziChase(null,null);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" # 0 A_PlayStepSound();
		"####" BB 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null);
		"####" D 1 A_NaziChase;
		"####" # 0 A_PlayStepSound();
		"####" DD 1 A_NaziChase(null,null);
		Loop;
	Idle:
		"####" AAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	Missile:
		"####" E 8 A_FaceTarget;
	Missile.Aimed:
		"####" F 8 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",54,1,random(-8,8));
		"####" F 8 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_Jump(256, "See.Loop");
		//"####" F 0 A_Jump(256,"See.Dodge");
		Stop;
	Reload:
		"####" F 0 {bNoPain = TRUE;}
		"####" F 30 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		"####" "#" 0 A_Jump(256, "See.Loop");
		//"####" "#" 0 A_Jump(256, "See.Dodge");
	Pain:
		"####" H 6 A_NaziPain(256);
		"####" H 0 A_Jump(256, "See.Loop");
		//"####" H 0 A_Jump(256, "See.Dodge");
		Stop;
	Pain.Silent:
		"####" H 6 A_NaziPain(64, False);
		"####" H 0 A_StartSound("Nazi1/Pain", CHAN_AUTO, 0, frandom (0.2,0.4), ATTN_NORM);
		"####" H 0 A_Jump(256, "See.Loop");
		//"####" H 0 A_Jump(256, "See.Dodge");
		Stop;
	Raise:
		"####" M 35;
		"####" LKJ 5;
		"####" I 5 A_Jump(256, "See.Loop");
		//"####" I 5 A_Jump(256, "See.Dodge");
		Stop;
	Death:
		"####" I 5 A_RandomDeathAnim;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		"####" I 0 A_CheckFadeDeath;
		MNIA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

//Wounded variants//
class WGuard_Wounded : Nazi //ozy81
{
	Default
	{
		//$Category Monsters (BoA)/Wounded Soldiers
		//$Title Wounded Guard (Pistol, Wehrmacht)
		//$Color 4
		Base.NoMedicHeal;
		Nazi.ZombieVariant "";
		Health 5;
		Speed 0;
		Obituary "$WNDWGUARD";
		MONSTER;
		-SOLID
		+FLOORCLIP
		+LOOKALLAROUND
		+NOPAIN
	}

	States
	{
		Spawn:
			GRD2 O 0;
			"####" "#" 0 A_RemoveMaster;
			Goto Spawn.Loop;
		Spawn.Loop:
			"####" O 150 { A_Look(); user_count4 = 0; }
			Loop;
		See:
			"####" O random(175, 350);
			// Prevent wounded guards from blocking you
			"####" O 7 A_CheckRange(64, 1, true);
			Goto See;
			"####" PQ 1 {A_SetTics(random(5,7)); bSolid = TRUE; bPushable = TRUE;}
		SeeLoop:
			"####" R 1 { A_Chase(); user_count4 += 1; if (user_count4 > 50) { A_Die(); } }
			"####" R 1 A_SetTics(random(1,14));
			Loop;
		Idle:
			// A_Chase sets this state if this guy doesn't have a target
			// see src/playsim/p_enemy.cpp line 2343
			// and src/playsim/p_mobj.cpp line 7253
			"####" "#" 0 A_Jump(256, "Spawn");
		Missile:
			"####" S 7 A_FaceTarget;
			"####" T 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
			"####" T 7 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",27,1,random(-8,8));
			"####" T 0 A_SpawnItemEx("Casing9mm", 1,0,27, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
			"####" S 14;
			"####" T 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
			"####" T 7 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",27,1,random(-16,16));
			"####" T 0 A_SpawnItemEx("Casing9mm", 1,0,27, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
			"####" T 0 {user_count++; if(user_count > 3) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
			"####" S 14;
			Goto SeeLoop;
		Reload:
			"####" R 0 {bNoPain = TRUE;}
			"####" R 30 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
			"####" R 0 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
			"####" R 0 {bNoPain = FALSE;}
			"####" "#" 0 A_Jump(256, "SeeLoop");
		Death:
			"####" U 7;
			"####" V 5 A_UnblockAndDrop;
			"####" W 5;
			"####" M -1 {A_DropItem("Ammo9mm",0,192); A_DropItem("Luger9mm",0,64);} //assign dropped items here in order to make possible to avoid it on NoCount variants
			Stop;
		Death_NoCount:
			"####" U 7;
			"####" V 5 A_UnblockAndDrop;
			"####" W 5;
			"####" M -1;
			Stop;
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		AchievementTracker.CheckAchievement(source.PlayerNumber(), AchievementTracker.ACH_STAYDEAD);

		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
	}
}

class WGuard_Wounded_NoCount : WGuard_Wounded
{
	Default
	{
	-COUNTKILL
	}
	States
	{
	Death:
		Goto Death_NoCount;
	}
}

class Guard_Wounded : WGuard_Wounded
{
	Default
	{
	//$Title Wounded Guard (Pistol, Afrika Korps)
	Obituary "$WNDGUARD";
	}
	States
	{
	Spawn:
		GARD O 0;
		"####" "#" 0 A_RemoveMaster;
		Goto Spawn.Loop;
	}
}

class Guard_Wounded_NoCount : Guard_Wounded
{
	Default
	{
	-COUNTKILL
	}
	States
	{
	Death:
		Goto Death_NoCount;
	}
}

class SSGuard_Wounded : WGuard_Wounded
{
	Default
	{
	//$Title Wounded Guard (Pistol, SS)
	Obituary "$WNDSSGUARD";
	}
	States
	{
	Spawn:
		SSPG O 0;
		"####" "#" 0 A_RemoveMaster;
		Goto Spawn.Loop;
	}
}

class SSGuard_Wounded_NoCount : SSGuard_Wounded
{
	Default
	{
	-COUNTKILL
	}
	States
	{
	Death:
		Goto Death_NoCount;
	}
}

class Officer_Wounded : WGuard_Wounded
{
	Default
	{
	//$Title Officer Wounded (Pistol, Afrika Korps)
	Obituary "$WNDOFFICER";
	}
	States
	{
	Spawn:
		OFFI O 0;
		"####" "#" 0 A_RemoveMaster;
		Goto Spawn.Loop;
	}
}

class Officer_Wounded_NoCount : Officer_Wounded
{
	Default
	{
	-COUNTKILL
	}
	States
	{
	Death:
		Goto Death_NoCount;
	}
}

class SSOfficer_Wounded : WGuard_Wounded
{
	Default
	{
	//$Title Officer Wounded (Pistol, SS)
	Obituary "$WNDSSOFFICER";
	}
	States
	{
	Spawn:
		SSOF O 0;
		"####" "#" 0 A_RemoveMaster;
		Goto Spawn.Loop;
	}
}

class SSOfficer_Wounded_NoCount : SSOfficer_Wounded
{
	Default
	{
	-COUNTKILL
	}
	States
	{
	Death:
		Goto Death_NoCount;
	}
}

class WOfficer_Wounded : WGuard_Wounded
{
	Default
	{
	//$Title Officer Wounded (Pistol, Wehrmacht)
	Obituary "$WNDWOFFICER";
	}
	States
	{
	Spawn:
		OFR2 O 0;
		"####" "#" 0 A_RemoveMaster;
		Goto Spawn.Loop;
	}
}

class WOfficer_Wounded_NoCount : WOfficer_Wounded
{
	Default
	{
	-COUNTKILL
	}
	States
	{
	Death:
		Goto Death_NoCount;
	}
}

class MiniShip : Nazi
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Miniship
	//$Color 4
	Health 375;
	Speed 3.25;
	Mass 2000;
	PainChance 96;
	FloatSpeed 0.87;
	Obituary "$NAZISHIP";
	-FLOORCLIP
	+FLOAT
	+LOOKALLAROUND
	+NOBLOODDECALS
	+NOGRAVITY
	BloodType "TankSpark";
	PainSound "metal/pain";
	DeathSound "world/barrelboom";
	Base.Swimmer 1;
	Nazi.FrightMultiplier 0.0;
	}
	States
	{
	Spawn:
		SHIP A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(null,null);
		Loop;
	Missile:
		SHIP A 10 A_FaceTarget;
		"####" A 0 A_StartSound("miniship/fire", CHAN_WEAPON);
		"####" B 8 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",26,7,random(-11,11));
		"####" A 8 A_FaceTarget;
		"####" A 0 A_StartSound("miniship/fire", CHAN_WEAPON);
		"####" C 8 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",26,-7,random(-11,11));
		"####" A 8;
		Goto See;
	Pain:
		SHIP A 3;
		"####" A 3 A_Pain;
		"####" A 1 ThrustThing((int) (Angle*256/360+192), 4, 1, 0);
		"####" A 1 ThrustThing((int) (Angle*256/360+128), 2, 1, 0);
		"####" A 1 ThrustThing((int) (Angle*256/360+64), 4, 1, 0);
		"####" "#" 0 A_AlertMonsters(256); //mxd
		Goto See;
	Death:
		SHIP A -1;
		Wait;
	Crash:
		TNT1 A 0 A_SetFloorClip;
		"####" A 0 A_Scream;
		"####" AAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Tank", random(8,-8), random(8,-8), random(54,64), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", random(8,-8), random(8,-8), random(54,64), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("ZombieNuke",0,0,0);
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Small",0,0,32);
		Stop;
	Idle:
		SHIP AAAAAAAA 1 A_Wander;
		SHIP A 0 A_Look;
		Loop;
	}
}

class MGTurret : MiniShip
{
	Default
	{
	//$Category Monsters (BoA)/Defensive Devices
	//$Title Automatic Turret (shootable)
	Base.Swimmer 0;
	Health 50;
	Radius 2;
	Height 32;
	Mass 9999;
	Speed 0;
	-CASTSPRITESHADOW
	+DONTCORPSE
	+MISSILEEVENMORE
	+NOPAIN
	-FLOAT
	-NOGRAVITY
	Obituary "$MGTURRET";
	}
	States
	{
	Spawn:
		GTUR A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.Statisch;
	Melee:
	Missile:
		"####" A 4 A_StartSound("chaingun/start", CHAN_WEAPON);
		"####" A 1 A_StartSound("chaingun/loop", CHAN_WEAPON);
		"####" A 5 A_FaceTarget;
		"####" B 0 { A_StartSound("chaingun/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" C 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyChaingunTracer",20,0,random(-11,11));
		"####" B 3 A_MonsterRefire(20,"See");
		"####" B 0 A_FaceTarget;
		Goto Missile+3;
	Death:
		GTUR G 0 A_SetFloorClip;
		"####" G 0 A_Scream;
		"####" G 0 A_SpawnItemEx("GeneralExplosion_Nazis",0,0,32);
		"####" G -1;
		Stop;
	Idle:
		Goto Look;
	}
}

class MGTurretCeiling : MGTurret
{
	Default
	{
	//$Title Automatic Turret (ceiling, shootable)
	Height 26;
	+DONTFALL
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		GTUR D 0 NODELAY { user_incombat = TRUE; } //mxd
		Goto Look;
	See: //needs to be different
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null);
		Loop;
	Missile:
		"####" D 4 A_StartSound("chaingun/start", CHAN_WEAPON);
		"####" D 1 A_StartSound("chaingun/loop", CHAN_WEAPON);
		"####" D 5 A_FaceTarget;
		"####" E 0 { A_StartSound("chaingun/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" F 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyChaingunTracer",Height-8,0,random(-11,11));
		"####" E 3 A_MonsterRefire(20,"See");
		"####" E 0 A_FaceTarget;
		Goto Missile+3;
	Death:
		GTUR H 0;
		"####" H 0 A_Scream;
		"####" H 0 A_SpawnItemEx("GeneralExplosion_Nazis",0,0,32);
		"####" H -1;
		Stop;
	Idle:
		Goto Look;
	}
}

class MGTurretInvisible : MGTurret
{
	Default
	{
	//$Title Automatic Turret (invisible, non-shootable)
	Health -1;
	Obituary "$MGTHIDE";
	-COUNTKILL
	-SHOOTABLE
	-SOLID
	+NOGRAVITY //mxd
	RenderStyle "None";
	}
	States
	{
	Missile: //mxd. Same as MGTurret, but without the dynamic light
		"####" A 4 A_StartSound("chaingun/start", CHAN_WEAPON);
		"####" A 1 A_StartSound("chaingun/loop", CHAN_WEAPON);
		"####" A 5 A_FaceTarget;
		"####" B 0 { A_StartSound("chaingun/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" C 3 A_SpawnProjectile("EnemyChaingunTracer",20,0,random(-11,11));
		"####" B 3 A_MonsterRefire(30,"See");
		"####" B 0 A_FaceTarget;
		Goto Missile+3;
	}
}

class CTurret : ControllableBase
{
	Default
	{
	//$Category Monsters (BoA)/Turrets
	//$Title Controllable Turret (Afrika Guards only)
	//$Color 4
	Health 100;
	Radius 8;
	Height 32;
	Speed 0;
	Scale 0.62;
	+DONTTHRUST
	+LOOKALLAROUND
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	ControllableBase.Controllers "Guard|WGuard";
	ControllableBase.Replacements "MGTurretSoldier|MGTurretSoldierW";
	DeathSound "world/barrelboom";
	}
	States
	{
	Spawn:
		SMGS X 0 NODELAY; //do not wait for usability or multiple turrets will spawn on Crash.Replace states - ozy81
		Goto Active;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Nazis",0,0,32);
		Stop;
	}
}

class MGTurretSoldier : MGTurret
{
	Default
	{
	//$Category Monsters (BoA)/Turrets
	//$Title Stationary Turret Soldier (Afrika Korps)
	Health 100;
	MaxTargetRange 3072;
	Height 56;
	Radius 16;
	PainChance 32;
	Scale 0.62;
	+CASTSPRITESHADOW
	-NOBLOODDECALS
	+DONTTHRUST
	BloodType "Nashgore_Blood";
	SeeSound "Nazi1/Sighted";
	PainSound "Nazi1/Pain";
	DeathSound "Nazi1/Death";
	}
	States
	{
	Spawn:
		SMGS A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Missile:
		SMGS A 4 A_StartSound("chaingun/start", CHAN_WEAPON);
		"####" A 1 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" A 5 A_FaceTarget;
		"####" B 0 { A_StartSound("chaingun/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" C 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyChaingunTracer",34,-2,random(-11,11));
		"####" C 0 A_SpawnItemEx("Casing9mm", 0,0,36, random(2,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" B 3 A_MonsterRefire(10,"See");
		"####" B 0 A_FaceTarget;
		Goto Missile+3;
	Pain: //added this here because it doesn't use H frames for pain states
		SMGS D 6 A_NaziPain(256);
		"####" D 0 A_Jump(256,"See");
		Stop;
	Death:
		SMGS A 0 A_Scream;
		"####" A 0 A_Jump(128,"Replace");
		"####" D 6;
		"####" EFG 6;
		"####" H -1 A_UnblockAndDrop;
		Stop;
	Replace:
		"####" "#" 0 {
			bSolid = false;
			bNoClip = true;
		}
		"####" I 0 A_SpawnItemEx("CTurret",0,0,0);
	SoldierDie:
		"####" I 0 A_Scream;
		"####" I 6;
		"####" JK 4;
		"####" K 0 A_Jump(256,"SoldierDead");
	SoldierDead:
		GARD L 2;
		"####" M -1 A_UnblockAndDrop;
		Stop;
	}
}

class MGTurretSoldierW : MGTurretSoldier
{
	Default
	{
	//$Title Stationary Turret Soldier (Wehrmacht)
	}
	States
	{
	Spawn:
		SMGF A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Missile:
		SMGF A 4 A_StartSound("chaingun/start", CHAN_WEAPON);
		"####" A 1 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" A 5 A_FaceTarget;
		"####" B 0 { A_StartSound("chaingun/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" C 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyChaingunTracer",34,-2,random(-11,11));
		"####" C 0 A_SpawnItemEx("Casing9mm", 0,0,36, random(2,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" B 3 A_MonsterRefire(10,"See");
		"####" B 0 A_FaceTarget;
		Goto Missile+3;
	Pain: //added this here because it doesn't have H frames for pain states
		SMGF D 6 A_NaziPain(256);
		"####" D 0 A_Jump(256,"See");
		Stop;
	Death:
		SMGF A 0 A_Scream;
		"####" A 0 A_Jump(128,"Replace");
		"####" D 6;
		"####" EFG 6;
		"####" H -1 A_UnblockAndDrop;
		Stop;
	Replace:
		"####" "#" 0 {
			bSolid = false;
			bNoClip = true;
		}
		"####" I 0 A_SpawnItemEx("CTurret",0,0,0);
		"####" I 0 A_Jump(256,"SoldierDie");
	SoldierDead:
		GRD2 L 2;
		"####" M -1 A_UnblockAndDrop;
		Stop;
	}
}

//////////
//ELITES//
//////////
class EliteFlamer : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Elite
	//$Title Elite Soldier (Flamer)
	//$Color 4
	Health 450;
	Mass 120;
	Speed 4;
	MaxTargetRange 400;
	Obituary "$FLAMEBOY";
	+MISSILEMORE
	SeeSound "eliteflamer/sight";
	PainSound "eliteflamer/pain";
	DeathSound "eliteflamer/death";
	DropItem "FlameAmmo";
	DropItem "Pyrolight", 48;
	Base.NoMedicHeal;
	Nazi.FrightMultiplier 0.25;
	Nazi.CrouchChance 0;
	Nazi.TotaleGierDrop 2;
	}
	States
	{
	Spawn:
		ELTF A 0 A_NaziLook;
		Goto Look;
	See:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		ELTF A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" D 1 A_Chase(null,null,CHF_FASTCHASE);
		"####" DD 1 A_NaziChase(null,null);
		Loop;
	Missile:
		ELTF E 0 A_StartSound("ammo/cell1");
		"####" E 7 A_FaceTarget;
	Missile.Aimed:
		"####" E 8 A_FaceTarget;
		"####" E 0 A_Jump(60,"ProperMissile2");
	ProperMissileStart:
		ELTF F 0 A_FaceTarget;
		"####" FG 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6);
		"####" G 0 A_MonsterRefire(20,"See");
		"####" E 0 A_JumpIfCloser(400,"ProperMissileStart");
		Goto See;
	ProperMissile2:
		ELTF F 0 A_FaceTarget;
		"####" F 0 { user_count = 0; }
		"####" F 0 { user_offset = RandomPick(-3, 3); } //mxd
		"####" F 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6);
	Wave1:
		ELTF F 0 A_SetAngle(angle + user_offset);
		"####" G 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6,angle,CMF_ABSOLUTEANGLE|CMF_BADPITCH);
		"####" F 0 A_SetAngle(angle + user_offset);
		"####" F 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6,angle,CMF_ABSOLUTEANGLE|CMF_BADPITCH);
		"####" F 0 { user_count = user_count+1; }
		"####" F 0 A_JumpIf(user_count>=5,1);
		Loop;
	Wave2:
		ELTF F 0 A_SetAngle(angle - user_offset);
		"####" G 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6,angle,CMF_ABSOLUTEANGLE|CMF_BADPITCH);
		"####" F 0 A_SetAngle(angle - user_offset);
		"####" F 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6,angle,CMF_ABSOLUTEANGLE|CMF_BADPITCH);
		"####" F 0 { user_count = user_count+1; }
		"####" F 0 A_JumpIf(user_count>=15,1);
		Loop;
	Wave3:
		ELTF F 0 A_SetAngle(angle + user_offset);
		"####" G 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6,angle,CMF_ABSOLUTEANGLE|CMF_BADPITCH);
		"####" F 0 A_SetAngle(angle + user_offset);
		"####" F 2 LIGHT("BOAFLAMW") A_SpawnProjectile("EnemyFlamerShot",42,6,angle,CMF_ABSOLUTEANGLE|CMF_BADPITCH);
		"####" F 0 { user_count = user_count+1; }
		"####" F 0 A_JumpIf(user_count>=20,1);
		Loop;
		ELTF E 6;
		Goto See;
	Death:
		ELTF H 0 A_Jump(64, "XDeath");
		"####" H 5;
		"####" I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K -1;
		Stop;
	Death.Electric:
	XDeath:
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_Nazis",0,0,32);
		Goto Death.Fire;
	}
}

class EliteAssaulter : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Elite
	//$Title Elite Soldier (MP40)
	//$Color 4
	Health 350;
	Mass 120;
	PainChance 160;
	Speed 3.66666667;
	Obituary "$ELITASS";
	+MISSILEMORE
	SeeSound "eliteassaulter/sight";
	PainSound "eliteassaulter/pain";
	DeathSound "eliteassaulter/death";
	DropItem "Ammo9mm", 192;
	DropItem "GrenadePickup", 16;
	DropItem "MP40", 96;
	Base.NoMedicHeal;
	Nazi.FrightMultiplier 0.25;
	Nazi.NoAltDeath 1;
	Nazi.TotaleGierDrop 2;
	}
	States
	{
	Spawn:
		ELTA N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		ELDA A 0;
	Dodge.Resume:
		Goto See.Loop;
	See.Loop:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		ELTA A 0 A_SetSpeed(3.66666667);
		"####" A 0 {bFrightened = FALSE;}
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" D 1 A_Chase(null,null,CHF_FASTCHASE);
		"####" DD 1 A_NaziChase(null,null);
		Loop;
	Pain:
		ELTA E 6 A_NaziPain(256);
		Goto See;
	Pain.Silent:
		"####" E 6 A_NaziPain(64, False);
		"####" E 0 A_StartSound("Nazi1/Pain", CHAN_AUTO, 0, frandom (0.2,0.4), ATTN_NORM);
		Goto See;
	Missile.Aimed: //4 shoot per round, which are a total of 8
		ELTA E 0 {if(user_count2 > 1) {return ResolveState("Missile.NoGrenada");} return ResolveState(null);}
		"####" E 0 A_Jump(50,"Grenada");
	Missile.NoGrenada:
		"####" E 0 A_StartSound("ammo/cell2");
		"####" EF 12 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",39,5,random(-6,6));
		"####" G 0 {user_count++; if(user_count > 31) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",39,5,random(-5,5));
		"####" G 0 {user_count++; if(user_count > 31) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",39,5,random(-4,4));
		"####" G 0 {user_count++; if(user_count > 31) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",39,5,random(-3,3));
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 10 A_FaceTarget;
		"####" F 0 {user_count++; if(user_count > 31) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_MonsterRefire(15,"See");
		Goto Missile.Aimed+4;
	Grenada: //only 4 grenades then always retreat once triggered - ozy81
		ELTA EF 7 A_FaceTarget;
		"####" E 0 {user_count2++;}
		"####" E 4 A_ArcProjectile("HandGrenade");
	Retreat:
		ELTA A 0 A_SetSpeed(8);
		"####" A 0 {bFrightened = TRUE;}
		"####" AABBCCDDAABBCCDDAABBCCDD 1 A_Chase;
		"####" A 0 {bFrightened = FALSE;}
		Goto Missile.Aimed;
	Reload:
		ELTA E 0 {bNoPain = TRUE;}
		"####" E 35 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		ETNA I 0 A_CheckFadeDeath;
		ETNA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class EliteSoldatRifler : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Elite
	//$Title Elite Soldier (Rifle)
	//$Color 4
	Health 300;
	Mass 120;
	PainChance 80;
	Speed 4.66666667;
	Obituary "$ELITRIFL";
	+MISSILEEVENMORE
	SeeSound "eliterifler/Sight";
	PainSound "eliteassaulter/pain";
	DeathSound "eliterifler/death";
	DropItem "G43", 96;
	DropItem "GrenadePickup", 16;
	DropItem "MauserAmmo", 192, 5;
	Base.NoMedicHeal;
	Nazi.FrightMultiplier 0.25;
	Nazi.NoAltDeath 1;
	Nazi.TotaleGierDrop 2;
	}
	States
	{
	Spawn:
		ELTR N 1;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		ELDR A 0;
	Dodge.Resume:
		Goto See.Loop;
	See.Loop:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		ELTR A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" D 1 A_Chase(null,null,CHF_FASTCHASE);
		"####" DD 1 A_NaziChase(null,null);
		Loop;
	Pain: //uses #E frames, #H are not needed because they would be exactly the same - Mask, expressionless - ozy81
		ELTR E 6 A_NaziPain(256);
		Goto See;
	Pain.Silent:
		ELTR E 6 A_NaziPain(64, False);
		"####" E 0 A_StartSound("Nazi1/Pain", CHAN_AUTO, 0, frandom (0.2,0.4), ATTN_NORM);
		Goto See;
	Missile:
		ELTR E 0 A_JumpIfCloser(1000,"ProperMissile");
		Goto Camping;
	ProperMissile:
		"####" E 9 A_FaceTarget;
	Missile.Aimed:
		"####" F 9 A_FaceTarget;
		"####" G 0 { A_StartSound("mauser/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" G 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyRifleTracer",39,7,random(-4,4));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 7,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 4 A_StartSound("mauser/cock", CHAN_AUTO, 0, 0.25);
		"####" E 14;
		Goto See;
	Camping:
		ELTR O 4 A_JumpIfCloser(540,"CampingDone");
		"####" P 6;
	CampingContinue:
		ELTR Q 0 A_JumpIfCloser(540,"CampingDone");
		"####" Q 0 A_Jump(6,"CampingDone");
		"####" Q 0 A_JumpIfCloser(8000,"CampingFire");
		"####" Q 6 A_FaceTarget;
		Loop;
	CampingFire:
		ELTR Q 0 A_JumpIfCloser(540,"CampingDone");
		"####" Q 10 A_FaceTarget;
		"####" R 0 { A_StartSound("mauser/fire", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" R 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyRifleTracer",32,5,random(-1,1));
		"####" Q 20;
		Goto CampingContinue;
	CampingDone:
		ELTR QPO 2;
		Goto See;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		ETFA I 0 A_CheckFadeDeath;
		ETFA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

///////////
//SPECIAL//
///////////
class Scientist : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Scientist (young)
	//$Color 4
	+FRIGHTENED
	Obituary "$SCIENTIST";
	Nazi.NoAltDeath 1;
	Nazi.CanSurrender 1;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		SCN2 N 1;
		Goto Look;
	SurrenderSprite:
		SC2S E 0;
	See: //dodge code preserved for modders --ozy81
		Goto See.Normal;
			//	Goto See.Dodge;
			//Dodge:
			//	SCD2 A 0;
			//Dodge.Resume:
			//	Goto See.Normal;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		SCNA I 0 A_CheckFadeDeath;
		SCNA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class Scientist2 : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/Others
	//$Title Scientist (old)
	//$Color 4
	+FRIGHTENED
	Obituary "$SCIENTIST";
	Nazi.NoAltDeath 1;
	Nazi.CanSurrender 1;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		SCNT N 1;
		Goto Look;
	SurrenderSprite:
		SCNS E 0;
	See:
		Goto See.Normal;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		SCTA I 0 A_CheckFadeDeath;
		SCTA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class ScientistGutenberg : Scientist2
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title Prof. Klaus Gutenberg
	+FRIENDLY
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		GUTB N 1;
		Goto Look;
	See:
		Goto See.Normal;
	}
}

class DirtyDarren : BasicGuard
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title Dirty Douglas
	//$Color 4
	Translation 1;
	PainChance 255;
	Obituary "$DARREN";
	DropItem "";
	SeeSound "";
	Species "Ally";
	+FRIENDLY
	+USESPECIAL
	Nazi.NoAltDeath 1;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		DARR N 1;
		Goto Look;
	See:
		Goto See.Normal;
	Missile:
		"####" E 5 A_FaceTarget;
	Missile.Aimed:
		"####" F 5 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" G 8 LIGHT("NAZIFIRE") A_SpawnProjectile("ThompsonTracer",32,0,random(-8,8));
		"####" F 8 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_Jump(256,"See");
		Stop;
	Death.Front:
	Death.Back:
	Death.Headshot:
		Stop;
	}
}
//////////
//ALLIED//
//////////
class Marine1 : DirtyDarren
{
	Default
	{
	//$Title Sgt. Ascher (Marine Uniform)
	Obituary "$MARINE";
	DamageFactor "Knife", 0;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		PARS A 0;
		Goto Look;
	Missile:
		"####" F 6 A_FaceTarget;
	Missile.Aimed:
		"####" G 6 A_FaceTarget;
		"####" H 0 { A_StartSound("nazi/stg44", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" H 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",38,6,random(-4,4));
		"####" H 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 4 A_MonsterRefire(10,"See");
		"####" G 0 A_FaceTarget;
		Goto Missile+2;
	Reload:
		"####" F 0 {bNoPain = TRUE;}
		"####" F 25 A_StartSound("sten/reload", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		"####" J 5;
		"####" K 5 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" MN 5;
		"####" O -1;
		Stop;
	Pain:
		"####" J 6 A_NaziPain;
		"####" J 0 A_Jump(256,"See");
		Stop;
	Raise:
		"####" ONMLKJ 5;
		Goto See;
	Disintegrate:
		Goto Disintegrate.Alt2;
	}
}

class Marine1B : Marine1
{
	Default
	{
	//$Category Monsters (BoA)/Allied Soldiers
	//$Title Marine Paratrooper (Pistol)
	DamageFactor "Bullet", 0.05;
	DamageFactor "Normal", 0.05;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		PARP A 0;
		Goto Look;
	Missile:
		"####" F 5 A_FaceTarget;
	Missile.Aimed:
		"####" G 5 A_FaceTarget;
		"####" H 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" H 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",54,1,random(-8,8));
		"####" G 8 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_Jump(256,"See");
	Reload: //ozy81
		"####" F 0 {bNoPain = TRUE;}
		"####" F 30 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		"####" "#" 0 A_Jump(256, "See"); //So that inheriting actors go to their own See State
	Death:
		"####" K 5;
		"####" L 5 A_Scream;
		"####" M 5 A_UnblockAndDrop;
		"####" N 3;
		"####" O -1;
		Stop;
	Raise:
		"####" ONMLKJ 5;
		Goto See;
	Disintegrate:
		Goto Disintegrate.Alt2;
	}
}

class Marine2A : Marine1
{
	Default
	{
	//$Category Monsters (BoA)/Allied Soldiers
	//$Title Marine, Brown (Rifle)
	DamageFactor "Bullet", 0.05;
	DamageFactor "Normal", 0.05;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		ARMH A 0;
		Goto Look;
	Missile:
		"####" F 3 A_FaceTarget;
	Missile.Aimed:
		"####" F 3 A_FaceTarget;
		"####" G 0 { A_StartSound("nazi/stg44", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" GH 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",38,6,random(-4,4));
		"####" H 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 4 A_MonsterRefire(10,"See");
		"####" G 0 A_FaceTarget;
		Goto Missile+2;
	Pain:
		"####" I 6 A_NaziPain;
		"####" I 0 A_Jump(256,"See");
		Stop;
	Disintegrate:
		Goto Disintegrate.Alt1;
	}
}

class Marine2B : Marine1
{
	Default
	{
	//$Category Monsters (BoA)/Allied Soldiers
	//$Title Marine, Green (Rifle)
	DamageFactor "Bullet", 0.05;
	DamageFactor "Normal", 0.05;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		MARH A 0;
		Goto Look;
	Missile:
		"####" F 6 A_FaceTarget;
	Missile.Aimed:
		"####" G 6 A_FaceTarget;
		"####" H 0 { A_StartSound("nazi/stg44", CHAN_WEAPON); A_AlertMonsters(1024); }
		"####" H 3 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyStGTracer",38,6,random(-4,4));
		"####" H 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0{user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 4 A_MonsterRefire(10,"See");
		"####" G 0 A_FaceTarget;
		Goto Missile+2;
	Disintegrate:
		Goto Disintegrate.Alt2;
	}
}

class Marine3A : Marine1
{
	Default
	{
	//$Category Monsters (BoA)/Allied Soldiers
	//$Title Marine, Brown (Pistol)
	DamageFactor "Bullet", 0.05;
	DamageFactor "Normal", 0.05;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		ARH2 A 0;
		Goto Look;
	Missile:
		"####" F 5 A_FaceTarget;
	Missile.Aimed:
		"####" G 5 A_FaceTarget;
		"####" H 0 { A_StartSound("nazi/pistol", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" H 8 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",54,1,random(-8,8));
		"####" G 8 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_Jump(256,"See");
	Reload: //ozy81
		"####" F 0 {bNoPain = TRUE;}
		"####" F 30 A_StartSound("luger/reload", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		"####" "#" 0 A_Jump(256, "See");
	Death:
		"####" J 5;
		"####" K 5 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" M 5;
		"####" N -1;
		Stop;
	Pain:
		"####" I 6 A_NaziPain;
		"####" I 0 A_Jump(256,"See");
		Stop;
	Raise:
		"####" NMLKJ 5;
		Goto See;
	Disintegrate:
		Goto Disintegrate.Alt1;
	}
}

class Marine3B : Marine3A
{
	Default
	{
	//$Category Monsters (BoA)/Allied Soldiers
	//$Title Marine, Green (Pistol)
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		MAH2 A 0;
		Goto Look;
	Disintegrate:
		Goto Disintegrate.Alt1;
	}
}

class Marine_Talk1 : Marine1
{
	Default
	{
	//$Category Conversation Stuff (BoA)
	//$Title Talking Marine 1
	//$Color 5
	Nazi.CrouchChance 0;
	}
}

class Marine_Talk2 : Marine2A
{
	Default
	{
	//$Category Conversation Stuff (BoA)
	//$Title Talking Marine 2
	//$Color 5
	Nazi.CrouchChance 0;
	}
}

class Dummy_Talk1 : Base
{
	Default
	{
	//$Category Conversation Stuff (BoA)
	//$Title Talking Dummy (1)
	//$Color 5
	Radius 8;
	Height 64;
	+INVISIBLE
	+SOLID
	}
}

class Dummy_Talk2 : Base
{
	Default
	{
	//$Category Conversation Stuff (BoA)
	//$Title Talking Dummy (2)
	//$Color 5
	Radius 8;
	Height 64;
	+INVISIBLE
	+SOLID
	}
}

class Dummy_Talk3 : Base
{
	Default
	{
	//$Category Conversation Stuff (BoA)
	//$Title Door Messages
	//$Color 5
	Radius 8;
	Height 64;
	-CASTSPRITESHADOW
	+INVISIBLE
	+SOLID
	}
}