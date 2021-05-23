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

class ZombieKazi : ZombieStandard
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title ZombieKazi (Wehrmacht)
	//$Color 4
	//Base.LightThreshold 135 //deactivated for now as the day/night cycle was deactivated
	Health 60;
	Speed 8;
	+NOVERTICALMELEERANGE
	Obituary "$NAZOKAZI";
	DropItem "Ammo9mm", 64;
	DropItem "GrenadePickup", 16;
	DropItem "Soul";
	}
	States
	{
	Spawn:
		ZKAZ N 0;
		Goto Look;
	Pain:
		"####" H 6 A_NaziPain(256, True, -8, "ZPain_Overlay");
		"####" H 0 A_Jump(256,"See");
	Pain.Fire:
	Pain.Electric:
        "####" H 1 A_Jump(192,"Pain");
		"####" H 0 A_XDie;
		Stop;
	Pain.Rocket:
	Melee:
		"####" E 0 A_XDie;
		Stop;
	Missile:
		"####" E 0 A_JumpIfCloser(192,"Melee",TRUE);
		"####" EF 20 A_FaceTarget;
		"####" G 0 A_StartSound("nazombie/vomit", CHAN_WEAPON);
		"####" G 12 A_SpawnProjectile("ZombieVomit",54,0,0, CMF_AIMDIRECTION);
		"####" E 8;
		Goto See;
	XDeath: //what a fall through :P
	Disintegrate:
	Death:
    Death.Fire:
    Death.Electric:
    Death.Rocket:
		"####" F 5 A_Quake(5,27,0,512);
		"####" I 0 { A_SpawnItemEx("ZombieNuke",0,0,0); A_SpawnItemEx("KaZomBoom",0,0,0); }
		"####" IIIIIIIIIIIIIIII 0 A_SpawnItemEx("Debris_Bone", random(8,-8), random(8,-8), random(54,64), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE);
		"####" I 1 {A_SpawnItemEx("Debris_Skull", random(8,-8), random(8,-8), random(54,64), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE); A_NoBlocking();}
		"####" J 4 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
		"####" KLM 4;
		"####" U -1 { A_UnSetSolid(); A_SetFloorclip(); }
		Stop;
	}
}

class AKZombieKazi : ZombieKazi //slower
{
	Default
	{
	//$Title ZombieKazi (Afrika Korps)
	}
	States
	{
	Spawn:
		ZKAF N 0;
		Goto Look;
	Melee:
		"####" E 0 A_Die;
		Stop;
	Missile:
		"####" E 0 A_JumpIfCloser(192,"Melee",TRUE);
		"####" EF 20 A_FaceTarget;
		"####" G 0 A_StartSound("nazombie/vomit", CHAN_WEAPON);
		"####" G 16 A_SpawnProjectile("ZombieVomit",54,0,0, CMF_AIMDIRECTION);
		"####" E 8;
		Goto See;
	}
}

class SSZombieKazi : ZombieKazi //faster
{
	Default
	{
	//$Title ZombieKazi (SS)
	}
	States
	{
	Spawn:
		ZKSS N 0;
		Goto Look;
	Melee:
		"####" E 0 A_Die;
		Stop;
	Missile:
		"####" E 0 A_JumpIfCloser(192,"Melee",TRUE);
		"####" EF 15 A_FaceTarget;
		"####" G 0 A_StartSound("nazombie/vomit", CHAN_WEAPON);
		"####" G 8 A_SpawnProjectile("ZombieVomit",54,0,0, CMF_AIMDIRECTION);
		"####" E 8;
		Goto See;
	}
}

class ZombieBrain : ZombieStandard
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title Zombie Brain Eater (Wehrmacht)
	//$Color 4
	Base.NoMedicHeal;
	 //Base.LightThreshold 135 //deactivated for now as the day/night cycle was deactivated
	Nazi.ZombieVariant "ZombieBrain";
	Health 60;
	Speed 2;
	+QUICKTORETALIATE
	Obituary "$NAZOBITE";
	DropItem "Ammo9mm", 32;
	DropItem "Soul";
	}
	States
	{
	Spawn:
		ZBIT N 0;
		Goto Look;
	See:
		"####" "#" 0 A_JumpIfCloser (radius + 320, "Run");
		"####" "#" 0 A_SetSpeed(2);
		Goto See.Normal;
	Run:
		"####" "#" 0 A_SetSpeed(6);
		"####" "#" 0 A_Jump(256,"RunLoop");
		Stop;
	Melee:
		"####" F 4 A_FaceTarget;
		"####" G 5 A_CustomMeleeAttack(5*random(2,4), "nazombie/pain", "", "UndeadPoison", TRUE);
		"####" F 4 A_FaceTarget;
		"####" G 5 A_CustomMeleeAttack(5*random(2,4), "nazombie/pain", "", "UndeadPoison", TRUE);
		Goto See;
	Missile:
		"####" EF 20 A_FaceTarget;
		"####" G 0 A_StartSound("nazombie/vomit", CHAN_WEAPON);
		"####" G 12 A_SpawnProjectile("ZombieVomit",54,0,0, CMF_AIMDIRECTION);
		"####" E 8;
		Goto See;
	Pain:
		"####" F 6 A_NaziPain(256, True, -8, "ZPain_Overlay");
		"####" F 0 A_Jump(256,"See");
	Death:
		"####" I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
		"####" M -1;
		Stop;
	Raise:
		"####" MLKJI 5;
		"####" I 0 A_Jump(256,"See");
		Stop;
	}
}

class AKZombieBrain : ZombieBrain //slower
{
	Default
	{
	//$Title Zombie Brain Eater (Afrika Korps)
	Nazi.ZombieVariant "AKZombieBrain";
	-QUICKTORETALIATE
	}
	States
	{
	Spawn:
		ZBAF N 0;
		Goto Look;
	Run:
		"####" "#" 0 A_SetSpeed(4);
		"####" "#" 0 A_Jump(256,"RunLoop");
		Stop;
	}
}

class SSZombieBrain : ZombieBrain //faster
{
	Default
	{
	//$Title Zombie Brain Eater (SS)
	Nazi.ZombieVariant "SSZombieBrain";
	Speed 4;
	}
	States
	{
	Spawn:
		ZBSS N 0;
		Goto Look;
	See:
		"####" "#" 0 A_JumpIfCloser (radius + 320, "Run");
		"####" "#" 0 A_SetSpeed(4);
		Goto See.Normal;
	Run:
		"####" "#" 0 A_SetSpeed(8);
		"####" "#" 0 A_Jump(256,"RunLoop");
		Stop;
	}
}

class ZombieOfficer : ZombieBrain
{
	Default
	{
	//$Title Zombie Officer (Wehrmacht)
	Nazi.ZombieVariant "ZombieOfficer";
	Speed 3;
	-QUICKTORETALIATE
	DropItem "MP40", 192;
	DropItem "Ammo9mm", 32;
	DropItem "Soul";
	}
	States
	{
	Spawn:
		ZOFF N 0;
		Goto Look;
	See:
		Goto See.Normal;
	Melee:
		"####" E 12 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/stg44", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" H 8 A_SpawnProjectile("EnemySMGTracer",30,6,30);
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" H 8 A_SpawnProjectile("EnemySMGTracer",30,4,15);
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" H 8 A_SpawnProjectile("EnemySMGTracer",30,2,0);
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" E 4 A_FaceTarget;
		Goto See;
	Missile:
		"####" E 10 A_FaceTarget;
		"####" F 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" F 4 A_SpawnProjectile("EnemySMGTracer",30,18,90);
		"####" F 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" F 4 A_SpawnProjectile("EnemySMGTracer",30,16,80);
		"####" F 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" F 4 A_SpawnProjectile("EnemySMGTracer",30,14,70);
		"####" F 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" G 4 A_SpawnProjectile("EnemySMGTracer",30,12,60);
		"####" G 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" G 4 A_SpawnProjectile("EnemySMGTracer",30,10,50);
		"####" G 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" G 4 A_SpawnProjectile("EnemySMGTracer",30,8,40);
		"####" G 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" H 4 A_SpawnProjectile("EnemySMGTracer",30,6,30);
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" H 4 A_SpawnProjectile("EnemySMGTracer",30,4,15);
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" H 4 A_SpawnProjectile("EnemySMGTracer",30,2,0);
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" E 8 A_MonsterRefire(96,"See");
		"####" E 0 A_FaceTarget;
		Goto Missile+2;
	Reload:
		"####" E 0 {bNoPain = TRUE;}
		"####" E 25 A_StartSound("sten/reload", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Pain:
		"####" I 6 A_NaziPain(256, True, -8, "ZPain_Overlay");
		"####" I 0 A_Jump(256,"See");
	Death:
		"####" I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
		"####" M 5;
		"####" O -1;
		Stop;
	Raise:
		"####" OMLKJI 5;
		"####" I 0 A_Jump(256,"See");
		Stop;
	}
}

class AKZombieOfficer : ZombieOfficer //slower
{
	Default
	{
	//$Title Zombie Officer (Afrika Korps)
	Nazi.ZombieVariant "AKZombieOfficer";
	Speed 2;
	}
	States
	{
	Spawn:
		ZOAF N 0;
		Goto Look;
	See:
		Goto See.Normal;
	}
}

class SSZombieOfficer : ZombieOfficer //faster
{
	Default
	{
	//$Title Zombie Officer (SS)
	Nazi.ZombieVariant "SSZombieOfficer";
	Speed 5;
	}
	States
	{
	Spawn:
		ZOSS N 0;
		Goto Look;
	See:
		Goto See.Fast;
	}
}

class ZGermanShepherd : ZombieStandard
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title Zombie German Shepherd
	//$Color 4
	Base.LoiterDistance 64;
	Base.NoMedicHeal;
	Nazi.ZombieVariant "ZGermanShepherd";
	Height 48;
	Health 50;
	Speed 5;
	Mass 100;
	PainChance 180;
	MaxStepHeight 16;
	SeeSound "cerb/sight";
	PainSound "cerb/pain";
	DeathSound "cerb/death";
	ActiveSound "cerb/act";
	Obituary "$ZDOGS";
	HitObituary "$ZDOGS";
	-CANUSEWALLS
	-CANPUSHWALLS
	+NEVERTARGET
	DropItem "Soul";
	}
	States
	{
	Spawn:
		ZDOG A 0;
		Goto Look;
	Idle:
		"####" A 0 A_SetSpeed(5);
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	See:
		"####" A 0 {
			user_incombat = True;

			if (target && target != goal) { Speed = 7; }
			else { Speed = 5; }
		}
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		Loop;
	Melee:
		"####" EF 2 Fast A_FaceTarget;
		"####" G 8 Fast A_CustomMeleeAttack(random(1,6)*3, "dog/attack", "dog/attack", "UndeadPoison", TRUE);
		"####" FE 4 Fast;
		Goto See;
	Pain:
		"####" M 2;
		"####" M 2 A_NaziPain(256, True, -8, "ZPain_Overlay");
		"####" "#" 0 A_Jump(256,"See");
	XDeath: //what a fall through :P
	Death.Electric:
	Disintegrate:
	Death:
		"####" H 8;
		"####" I 8 A_Scream;
		"####" J 6 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
		"####" K -1 A_NoBlocking;
		Stop;
	Death.Fire:
		Goto Death.FireDogs;
	Raise:
		"####" KKKJIH 8;
		"####" I 0 A_Jump(256,"See");
		Stop;
	}
}

class ZombieGeneral : RocketMan
{
	Default
	{
	//$Title General Fettgesicht, Zombiefied (Boss)
	Base.BossIcon "BOSSICO2";
	Base.LightThreshold 190;
	Nazi.ZombieVariant "ZombieGeneral";
	Tag "$TAGZFETTGESICHT";
	Health 1000;
	Obituary "$ZGENERAL";
	ActiveSound "nazombie/act";
	SeeSound "nazombie/sighted";
	PainSound "nazombie/pain";
	DeathSound "nazombie/act";
	BloodColor "00 A0 7D";
	BloodType "ZombieBlood";
	DamageFactor "Electric", 0.8;
	DamageFactor "Fire", 1.2;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DropItem "NebAmmoBox", 128;
	DropItem "NebAmmoBox", 128;
	DropItem "Soul", 255, 5;
	Species "Zombie";
	}
	States
	{
	Spawn:
		ZFET A 0;
		Goto Look;
	Missile:
		ZFET E 10 A_FaceTarget;
		"####" E 0 A_Jump(96,"ChainGun","GasBomb");
		"####" F 8 A_SpawnProjectile("ZombieRocket",43,24);
		"####" E 8 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("ZombieRocket",43,24);
		"####" E 8 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("ZombieRocket",43,24);
		"####" E 8;
		Goto See;
	ChainGun:
		ZFET H 0 A_FaceTarget;
		"####" H 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" H 2 A_SpawnProjectile("EnemyChaingunTracer",40,-20,random(-11,11));
		"####" G 0 A_SpawnItemEx("Casing9mm", -12,0,36, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_MonsterRefire(64,"See");
		Loop;
	GasBomb:
		ZFET F 4 LIGHT("OTTOFIRE") A_SpawnProjectile("GasBomb",43,24,random(-16,16));
		"####" E 8;
		Goto Missile;
	Pain:
		ZFET I 6 A_NaziPain(256);
		Goto See;
	Death:
		ZFET J 5;
		"####" K 7 A_Scream;
		"####" L 9 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
		"####" M -1 A_NoBlocking;
		Stop;
	Raise:
		ZFET MLKJ 5;
		Goto See;
	}
}

class ZombieZyklonstein : RocketMan
{
	Default
	{
	//$Title Zyklonstein (Boss)
	Base.BossIcon "BOSSICO2";
	Base.LightThreshold 190;
	Tag "$TAGZZYKLONSTEIN";
	Health 1200;
	Obituary "$ZZYKLON";
	ActiveSound "nazombie/act";
	SeeSound "nazombie/sighted";
	PainSound "nazombie/pain";
	DeathSound "nazombie/act";
	BloodColor "00 A0 7D";
	BloodType "ZombieBlood";
	DamageFactor "Electric", 0.8;
	DamageFactor "Fire", 1.2;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DropItem "FlameAmmo", 128;
	DropItem "FlameAmmo", 128;
	DropItem "SoulSuperBig", 255;
	DropItem "SoulSuperBig", 255;
	DropItem "SoulSuperBig", 255;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	Species "Zombie";
	}
	States
	{
	Spawn:
		ZSKL A 0;
		Goto Look;
	Missile:
		ZSKL E 0 A_Jump(128,"Chaingun");
		"####" E 10 A_FaceTarget;
		"####" E 0 A_JumpIfCloser(384,"ZyklonFlame");
		"####" F 4 A_SpawnProjectile("ZFlameBall",44,12);
		"####" E 6;
		Goto See;
	ZyklonFlame:
		ZSKL FFFFF 1 A_SpawnProjectile("ZFlamebolt",44,12);
		"####" E 6 A_MonsterRefire(10,"See");
		Goto Missile;
	Chaingun:
		ZSKL H 0 A_FaceTarget;
		"####" H 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" H 2 A_SpawnProjectile("EnemyChaingunTracer",40,-20,random(-11,11));
		"####" G 0 A_SpawnItemEx("Casing9mm", -12,0,36, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_MonsterRefire(64,"See");
		Loop;
	Pain:
		ZSKL I 6 A_NaziPain(256);
		Goto See;
	Death:
		ZSKL J 5;
		"####" K 7 A_Scream;
		"####" L 9 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
		"####" M -1 A_NoBlocking;
		Stop;
	Raise:
		ZSKL MLKJ 5;
		Goto See;
	}
}

class ZombieButcher : RocketMan
{
	Default
	{
	//$Title Zombie Butcher (Boss)
	Tag "$TAGZBUTCHER";
	Base.BossIcon "BOSSICO2";
	Base.LightThreshold 190;
	Health 650;
	Obituary "$ZBUTCHER";
	ActiveSound "nazombie/act";
	SeeSound "nazombie/sighted";
	PainSound "nazombie/pain";
	DeathSound "nazombie/act";
	BloodColor "00 A0 7D";
	BloodType "ZombieBlood";
	DamageFactor "Electric", 0.8;
	DamageFactor "Fire", 1.2;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DropItem "Medikit_Medium";
	DropItem "SoulSuperBig", 255;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	DropItem "Soul", 255, 5;
	Species "Zombie";
	}
	States
	{
	Spawn:
		BTCZ A 0;
		Goto Look;
	Missile:
		BTCZ E 6 A_FaceTarget;
		"####" E 0 A_Jump(128, "Missile2", "Missile3");
		"####" F 2 A_ArcProjectile("ZFlyingHack",32,12,random(-8,8));
		"####" C 8;
		Goto See;
	Missile2:
		BTCZ F 2 A_ArcProjectile("ZFlyingHack",32,12,random(-2,2));
		"####" E 4 A_FaceTarget;
		"####" F 2 A_ArcProjectile("ZFlyingHack",32,12,random(-8,8));
		"####" C 8;
		Goto See;
	Missile3:
		BTCZ F 2 A_ArcProjectile("ZFlyingHack",32,12,random(-2,2));
		"####" E 4 A_FaceTarget;
		"####" F 2 A_ArcProjectile("ZFlyingHack",32,12,random(-8,8));
		"####" E 4 A_FaceTarget;
		"####" F 2 A_ArcProjectile("ZFlyingHack",32,12,random(-12,12));
		"####" C 8;
		Goto See;
	Pain:
		BTCZ G 6 A_NaziPain(256);
		Goto See;
	Death:
		BTCZ G 7;
		"####" H 8;
		"####" I 9 A_Scream;
		"####" J -1 A_NoBlocking;
		Stop;
	}
}

// C3M6_A variants --N00b

class ZombieKaziRuthless: ZombieKazi
{
	Default
	{
	DamageFactor "Normal", 1.0;
	Health 40;
	+JUMPDOWN
	-NOVERTICALMELEERANGE
	+DOHARMSPECIES
	DropItem "GrenadePickup", 64;
	DropItem "Bandages", 32;
	DropItem "Soul";
	DropItem "Soul", 128;
	DropItem "SoulBig", 32;
    Speed 10.0;
	}
	States
	{
    Missile:
		"####" E 0 A_JumpIfCloser(192,"Melee",TRUE);
		"####" EF 20 A_FaceTarget;
		"####" G 0 A_StartSound("nazombie/vomit", CHAN_WEAPON);
		"####" G 12 A_SpawnProjectile("ZombieVomit_C3M6A",54,0,0, CMF_AIMDIRECTION);
		"####" E 8;
		"####" A 0 { return ResolveState("See"); }
	}
}

class ZombieBrainRuthless: ZombieBrain
{
	Default
	{
	DamageFactor "Normal", 1.0;
	Health 30;
	+JUMPDOWN
	DropItem "Bandages", 16;
	DropItem "Ammo9mm", 64;
	DropItem "MauserAmmo", 32;
	DropItem "Soul";
	DropItem "Soul", 64;
    Speed 12.0;
	}
	States
	{
    Missile:
		"####" EF 20 A_FaceTarget;
		"####" G 0 A_StartSound("nazombie/vomit", CHAN_WEAPON);
		"####" G 12 A_SpawnProjectile("ZombieVomit_C3M6A",54,0,0, CMF_AIMDIRECTION);
		"####" E 8;
		"####" A 0 { return ResolveState("See"); }
	}
}

class ZombieOfficerRuthless: ZombieOfficer
{
	Default
	{
	+JUMPDOWN
	+MISSILEMORE
	+MISSILEEVENMORE //spams MP40 bullet salvos
	DropItem "";
	//only spawned on ramps
	}
}

class ZGermanShepherdRuthless: ZGermanShepherd
{
	Default
	{
	DamageFactor "Normal", 1.0;
	Health 15;
	+JUMPDOWN
	DropItem "DogFood", 64;
	DropItem "Soul";
	DropItem "Soul", 64;
    Speed 14.0;
	}
}
