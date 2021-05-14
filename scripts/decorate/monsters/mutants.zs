/*
 * Copyright (c) 2017-2021 Ozymandias81, AFADoomer, Tormentor667, Talon1024
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

///////////
//MUTANTS//
///////////

class Mutant : MutantStandard
{
	Default
	{
	//$Category Monsters (BoA)/Mutants
	//$Title Mutant (Projectile)
	//$Color 4
	Health 90;
	Obituary "$MUTANT";
	+MISSILEEVENMORE
	+MISSILEMORE
	DropItem "Ammo9mm", 128;
	}
	States
	{
	Spawn:
		MTNT A 0 NODELAY ACS_NamedExecuteAlways("DisableMutants",0); //mxd
		Goto Look;
	See:
		"####" A 0 A_SetSpeed(4);
		Goto See.MutantFasterAlt;
	Missile:
		MTNT F 18 A_FaceTarget;
		MTNT G 0 A_StartSound("walther/fire", CHAN_WEAPON);
		MTNT G 7 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer",45,0,random(-1,1));
		MTNT G 0 A_SpawnItemEx("Casing9mm", 0,0,47, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTNT F 8 A_FaceTarget;
		MTNT H 0 A_StartSound("walther/fire", CHAN_WEAPON);
		MTNT H 7 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer",45,0,random(-1,1));
		MTNT H 0 A_SpawnItemEx("Casing9mm", 0,0,47, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTNT F 8 A_MonsterRefire(64,"See");
		MTNT F 0 A_FaceTarget;
		Goto Missile+1;
	Pain:
		"####" I 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" J 3;
		"####" K 3 A_Scream;
		"####" L 3 A_UnblockAndDrop;
		"####" MN 3;
		"####" O -1;
		Stop;
	Idle:
		"####" A 0 A_SetSpeed(1.5);
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		"####" EEEEEEEE 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	Raise:
		"####" ONMLKJ 4;
		Goto See;
	}
}

class MutantMelee : Mutant
{
	Default
	{
	//$Title Mutant (Melee)
	DropItem "";
	Speed 6;
	+LOOKALLAROUND
	}
	States
	{
	Spawn:
		MLMT A 0 NODELAY ACS_NamedExecuteAlways("DisableMutants",0); //mxd
		Goto Look;
	See:
		"####" A 0 A_SetSpeed(6);
		Goto See.MutantFasterAlt;
	See.MutantFasterAlt:
		// Mutant Walk Pattern, offset frames (BCDE walk instead of ABCD)
		"####" "#" 0 { user_incombat = True; }
		"####" B 1 A_MeleeMutantChase;
		"####" B 1 A_MeleeMutantChase(null, null);
		"####" # 0 A_PlayStepSound();
		"####" B 1 A_MeleeMutantChase;
		"####" B 1 A_MeleeMutantChase(null, null);
		"####" C 1 A_MeleeMutantChase;
		"####" C 1 A_MeleeMutantChase(null, null);
		"####" C 1 A_MeleeMutantChase;
		"####" C 1 A_MeleeMutantChase(null, null);
		"####" D 1 A_MeleeMutantChase;
		"####" D 1 A_MeleeMutantChase(null, null);
		"####" D 1 A_MeleeMutantChase;
		"####" D 1 A_MeleeMutantChase(null, null);
		"####" E 1 A_MeleeMutantChase;
		"####" E 1 A_MeleeMutantChase(null, null);
		"####" # 0 A_PlayStepSound();
		"####" E 1 A_MeleeMutantChase;
		"####" E 1 A_MeleeMutantChase(null, null);
		"####" A 0 { return ResolveState("See"); }
	Melee:
		MLMT F 4 A_FaceTarget;
		MLMT G 5 A_CustomMeleeAttack(5*random(1,5));
		MLMT F 4 A_FaceTarget;
		MLMT H 5 A_CustomMeleeAttack(5*random(1,5));
		Goto See;
	Missile:
		MLMT Q 8 A_FaceTarget;
		MLMT RS 4 A_FaceTarget;
		MLMT T 4 A_SpawnProjectile("FlyingCleaver",43,8,random(-2,2));
		MLMT UV 4 A_FaceTarget;
		MLMT W 4 A_SpawnProjectile("FlyingCleaver",43,-8,random(-2,2));
		MLMT XY 8 A_FaceTarget;
		MLMT Q 4 A_FaceTarget;
		Goto See;
	}
}

class SuperMutant : Mutant
{
	Default
	{
	//$Title Mutant (Super)
	Health 180;
	Scale 0.75;
	Obituary "$SUPAMUTN";
	}
	States
	{
	Spawn:
		SUPM A 0 NODELAY ACS_NamedExecuteAlways("DisableSuperMutants",0); //mxd
		Goto Look;
	See:
		"####" A 0 A_SetSpeed(5);
		Goto See.MutantFasterAlt;
	Missile:
		SUPM F 6 A_FaceTarget;
		SUPM G 0 A_StartSound("supaproj/fire", CHAN_WEAPON);
		SUPM G 4 LIGHT("MUTNFIRE") A_SpawnProjectile("MutantBounceBall",40,random(-22,-20),random(-1,1));
		SUPM G 0 {user_count++; if(user_count > 3) {user_count = 0; return ResolveState("See.MutantFasterAlt");} return ResolveState(null);}
		SUPM F 5 A_FaceTarget;
		SUPM P 0 A_StartSound("supaproj/fire", CHAN_WEAPON);
		SUPM P 4 LIGHT("MUTNFIRE") A_SpawnProjectile("MutantBounceBall",40,random(18,20),random(-1,1));
		SUPM P 0 {user_count++; if(user_count > 3) {user_count = 0; return ResolveState("See.MutantFasterAlt");} return ResolveState(null);}
		SUPM H 5 A_MonsterRefire(15,"See");
		SUPM H 0 A_FaceTarget;
		Goto Missile+1;
	}
}

class BigMutant1 : Mutant
{
	Default
	{
	//$Title Giant Mutant (UMG43)
	//$Sprite MTB1A0
	Health 400;
	Mass 250;
	Scale 1.0;
	PainChance 64;
	Obituary "$GMUTANT1";
	+NEVERFAST
	}
	States
	{
	Spawn:
		MTB1 A 0 NODELAY ACS_NamedExecuteAlways("DisableBigMutants", 0); //mxd
		Goto Look;
	See:
		"####" A 0 A_SetSpeed(5);
		Goto See.MutantFaster;
	Melee:
		MTB1 F 4 A_FaceTarget;
		MTB1 G 5 A_CustomMeleeAttack(8*random(1,5));
		MTB1 F 4 A_FaceTarget;
		MTB1 H 5 A_CustomMeleeAttack(8*random(1,5));
		Goto See;
	Missile:
		MTB1 E 0 A_Jump(128,"Missile2");
		MTB1 E 0 A_Jump(96,"Missile3");
		MTB1 E 3;
		MTB1 E 7 A_FaceTarget;
		MTB1 F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 F 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, -4, 0);
		MTB1 F 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 F 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, 0, 0);
		MTB1 F 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 F 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, 4, 0);
		MTB1 F 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 F 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, 8, 0);
		MTB1 F 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 F 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, 12, 0);
		MTB1 F 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 F 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, 16, 0);
		MTB1 F 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		Goto See;
	Missile2:
		MTB1 E 3;
		MTB1 E 7 A_FaceTarget;
		MTB1 G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 G 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, 4, 0);
		MTB1 G 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 G 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, 0, 0);
		MTB1 G 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 G 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, -4, 0);
		MTB1 G 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 G 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, -8, 0);
		MTB1 G 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 G 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, -12, 0);
		MTB1 G 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 G 2 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer", 62, 0, -16, 0);
		MTB1 G 2 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		Goto See;
	Missile3:
		MTB1 E 4;
		MTB1 E 10 A_FaceTarget;
		MTB1 F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 FFF 0 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer",64,0,frandom(-4,4));
		MTB1 FFF 0 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 EG 3 A_FaceTarget;
		MTB1 G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		MTB1 GGG 0 LIGHT("MUTNFIRE") A_SpawnProjectile("EnemyMutantTracer",64,0,frandom(-4,4));
		MTB1 GGG 0 A_SpawnItemEx("Casing9mm", 0,0,54, RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		MTB1 EF 3 A_FaceTarget;
		Goto See;
	Death:
		"####" I 5;
		"####" J 6;
		"####" K 7 A_Scream;
		"####" L 8 A_UnblockAndDrop;
		"####" M -1;
		Stop;
	Idle:
		"####" A 0 A_SetSpeed(2.5);
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		"####" EEEEEEEE 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	Death.Fire:
		"####" # 0 A_SetScale(0.65);
		Goto Death.Fire.Random;
	Raise:
		"####" MMMLKJI 4;
		Goto See;
	XDeath:
		Goto XDeath.Big;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	}
}

class BigMutant2 : BigMutant1
{
	Default
	{
	//$Title Giant Mutant (MutantRockets)
	//$Sprite MTB2A0
	Health 450;
	PainChance 64;
	Obituary "$GMUTANT2";
	DropItem "NebAmmo", 128, 2;
	}
	States
	{
	Spawn:
		MTB2 A 0 NODELAY ACS_NamedExecuteAlways("DisableBigMutants", 0); //mxd
		Goto Look;
	Melee:
		MTB2 E 4 A_FaceTarget;
		MTB2 F 5 A_CustomMeleeAttack(8*random(1,5));
		MTB2 E 4 A_FaceTarget;
		MTB2 G 5 A_CustomMeleeAttack(8*random(1,5));
		Goto See;
	Missile:
		MTB2 E 20 A_FaceTarget;
		MTB2 E 0 A_Jump(96,"Missile2");
		MTB2 E 0 A_Jump(192,"Missile3");
		MTB2 F 6 A_SpawnProjectile("MutantRocket",62,0,random(-8,-16));
		MTB2 E 8 A_FaceTarget;
		Goto See;
	Missile2:
		MTB2 G 8 A_SpawnProjectile("MutantRocket",62,0,random(8,16));
		MTB2 E 20 A_FaceTarget;
		Goto See;
	Missile3:
		MTB2 F 0 A_SpawnProjectile("MutantRocket", 62,0,random(-8,-16));
		MTB2 F 0;
		MTB2 G 8 A_SpawnProjectile("MutantRocket", 62,0, 0);
		MTB2 E 20 A_FaceTarget;
		Goto See;
	}
}

class UberMutant : Mutant
{
	Default
	{
	//$Category Monsters (BoA)/Bosses
	//$Title Ubermutant (Boss)
	//$Color 4
	Tag "$TAGUEBERMUTANT";
	Health 2000;
	Radius 24;
	Height 64;
	Mass 1000;
	Speed 2.66666667;
	PainChance 50;
	DamageFactor "Rocket", 0.02;
	+BOSS
	+LOOKALLAROUND
	+NORADIUSDMG
	Obituary "$UBERMUTN";
	SeeSound "baron/sight";
	DeathSound "baron/death";
	}
	States
	{
	Spawn:
		UBMU A 0 NODELAY ACS_NamedExecuteAlways("DisableSuperMutants", 0); //mxd
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Look:
		UBMU AB 10 A_Look;
		Loop;
	See:
		"####" "#" 0 {bNoRadiusDMG = TRUE;}
		Goto See.BossFast;
	Melee:
	Missile:
		UBMU EF 8 A_FaceTarget;
		"####" E 0 {bNoRadiusDMG = FALSE;}
		UBMU G 0 A_Jump(64,"Chaingun");
		UBMU G 0 A_Jump(128,"Missile2");
		UBMU G 0 A_Jump(192,"Missile3");
		UBMU G 4 LIGHT("MUTNROCK") A_SpawnProjectile("MutantRocket",44,0,0);
		"####" G 0 {bNoRadiusDMG = TRUE;}
		Goto See;
	Missile2:
		UBMU G 4 LIGHT("MUTNROCK") A_SpawnProjectile("MutantRocket",44,0,random(8,16));
		UBMU EF 5 A_FaceTarget;
		UBMU G 4 LIGHT("MUTNROCK") A_SpawnProjectile("MutantRocket",44,0,0);
		"####" G 0 {bNoRadiusDMG = TRUE;}
		Goto See;
	Missile3:
		UBMU G 0 LIGHT("MUTNROCK") A_SpawnProjectile("MutantRocket",44,0,random(-8,-16));
		UBMU G 0 LIGHT("MUTNROCK") A_SpawnProjectile("MutantRocket",44,0, 0);
		UBMU G 5 LIGHT("MUTNROCK") A_SpawnProjectile("MutantRocket",44,0,random(8,16));
		UBMU EF 5 A_FaceTarget;
		"####" F 0 {bNoRadiusDMG = TRUE;}
		Goto See;
	Chaingun:
		UBMU G 0 A_FaceTarget;
		UBMU G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-1,1));
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-4,4));
		UBMU GG 0 A_SpawnItemEx("Casing9mm", 0,0,46, RandomPick(-8, 8), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		UBMU G 3 LIGHT("MUTNFIRE");
		UBMU G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-1,1));
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-4,4));
		UBMU GG 0 A_SpawnItemEx("Casing9mm", 0,0,46, RandomPick(-8, 8), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		UBMU G 3 LIGHT("MUTNFIRE");
		UBMU G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-1,1));
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-4,4));
		UBMU GG 0 A_SpawnItemEx("Casing9mm", 0,0,46, RandomPick(-8, 8), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		UBMU G 3 LIGHT("MUTNFIRE");
		UBMU G 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-1,1));
		UBMU G 0 A_SpawnProjectile("EnemyMutantTracer",44,0,random(-4,4));
		UBMU GG 0 A_SpawnItemEx("Casing9mm", 0,0,46, RandomPick(-8, 8), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		UBMU G 3 LIGHT("MUTNFIRE");
		UBMU G 4 A_MonsterRefire(20,"See");
		"####" G 0 {bNoRadiusDMG = TRUE;}
		Goto Missile+2;
	Pain:
		UBMU H 6 A_NaziPain(256);
		Goto See;
	Death:
		UBMU I 6;
		UBMU I 8 A_Scream;
		UBMU J 8;
		UBMU J 8 A_UnblockAndDrop;
		UBMU KL 10;
		UBMU M -1 A_BossDeath;
		Stop;
	Raise:
		UBMU MLKJJII 6;
		Goto See;
	}
}
