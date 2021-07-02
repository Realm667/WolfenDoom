/*
 * Copyright (c) 2017-2021 Ozymandias81, AFADoomer, Talon1024, Tormentor667
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

//////////
//OCCULT//
//////////
class BloodSkull : Base
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title Bloodskull
	//$Color 4
	Health 150;
	Radius 16;
	Height 56;
	Mass 9999;
	Speed 2;
	FloatSpeed 1;
	PainChance 50;
	Scale 0.5;
	Monster;
	+DONTFALL
	+FLOAT
	+NEVERRESPAWN
	+NOGRAVITY
	Obituary "$BLOSKULL";
	SeeSound "BSkull/See";
	PainSound "BSkull/Pain";
	DeathSound "BSkull/Death";
	Base.NoFear;
	}
	States
	{
	Spawn:
		SWBS AA 4 A_LookThroughDisguise;
		TNT1 A 0 A_SpawnItemEx("SkullBloodDrip",random(-2,2),random(-2,2),0,0,0,0,0,0);
		Loop;
	See:
		SWBS A 1 A_Chase;
		SWBS AAA 1 A_Chase(null,null);
		SWBS A 1 A_Chase;
		SWBS AAA 1 A_Chase(null,null);
		TNT1 A 0 A_SpawnItemEx("SkullBloodDrip",random(0,4),random(-2,2),0,0,0,0,0,0);
		Loop;
	Missile:
		SWBS A 2 A_FaceTarget;
		SWBS B 2 A_SpawnProjectile("BloodSpit",12,0,0,0,0);
		SWBS BA 2;
		TNT1 A 0 A_SpawnItemEx("SkullBloodDrip",random(-2,2),random(-2,2),0,0,0,0,0,0);
		Goto See;
	Pain:
		SWBS A 2 A_Pain;
		"####" A 0 A_Jump(256,"See");
	XDeath:
	Death:
		SWBS C 6 A_NoBlocking;
		SWBS D 5 A_Scream;
		TNT1 A 0 A_SetTranslucent(0.8,0);
		SWBS EF 4;
		"####" AAAAAAAA 0 A_SpawnItemEx("BloodSkullCloud",random(-16,16),random(-16,16),random(-24,24),0,0,0.3,0,128);
		SWBS GH 2;
		Stop;
	}
}

class ZyklonSkull : BloodSkull
{
	Default
	{
	//$Title Zyklonskull
	Health 50; //250
	//Speed 8
	//FloatSpeed 2
	PainChance 50;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DamageFactor "Poison", 0;
	BloodColor "00 A0 7D";
	BloodType "ZombieBlood";
	RenderStyle "Translucent";
	Alpha 0.8;
	+VISIBILITYPULSE
	Obituary "$ZLOSKULL";
	Species "Zombie";
	}
	States
	{
	Spawn:
		ZWBZ AA 4 A_LookThroughDisguise;
		TNT1 A 0 A_SpawnItemEx("ZSkullBloodDrip",random(-2,2),random(-2,2),0,0,0,0,0,0);
		Loop;
	See:
		ZWBZ A 1 A_Chase;
		ZWBZ AAA 1 A_Chase(null,null);
		ZWBZ A 1 A_Chase;
		ZWBZ AAA 1 A_Chase(null,null);
		TNT1 A 0 A_SpawnItemEx("ZSkullBloodDrip",random(0,4),random(-2,2),0,0,0,0,0,0);
		Loop;
	Missile:
		ZWBZ A 2 A_FaceTarget;
		ZWBZ B 2 A_SpawnProjectile("ZBloodSpit",12,0,0,0,0);
		ZWBZ BA 2;
		TNT1 A 0 A_SpawnItemEx("ZSkullBloodDrip",random(-2,2),random(-2,2),0,0,0,0,0,0);
		Goto See;
	Pain:
		ZWBZ A 2 A_Pain;
		"####" A 0 A_Jump(256,"See");
	XDeath:
	Death:
		ZWBZ C 6 A_NoBlocking;
		ZWBZ D 5 A_Scream;
		ZWBZ EF 4;
		"####" AAAAAAAA 0 A_SpawnItemEx("ZyklonZCloud4",random(-4,4),random(-4,4),random(-4,4),0,0,0.3,0);
		ZWBZ GH 2;
		Stop;
	}
}

class WereWaffenSS : WaffenSS
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title WereWaffen SS
	//$Color 4
	Base.NoMedicHeal;
	Health 160;
	Speed 4;
	PainChance 128;
	Scale 0.65;
	SeeSound "wolfman/see";
	PainSound "wolfman/pain";
	DeathSound "wolfman/death";
	Obituary "$WEREWAFF";
	DropItem "AmmoBox9mm", 128;
	DropItem "GrenadePickup", 32;
	DropItem "MP40", 128;
	}
	States
	{
	Spawn:
		WOFF N 0;
		Goto Look;
	See: //doesn't roll - ozy81
		Goto See.Fast;
	Pain:
		"####" E 6 A_NaziPain(256);
		Goto See;
	Missile:
		WOFF EF 4 A_FaceTarget;
		"####" G 0 A_StartSound("nazi/stg44", CHAN_WEAPON, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" G 2 A_SpawnProjectile("EnemyStGTracer",38,6,random(-4,4));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 2 A_MonsterRefire(96,"See");
		"####" F 0 A_FaceTarget;
		Goto Missile+2;
	Reload:
		WOFF E 0 {bNoPain = TRUE;}
		"####" E 20 A_StartSound("sten/reload", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("MauserRifleCasing", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Front:
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Fire:
		"####" # 0 A_SetScale(0.62);
		Goto Death.Fire.Random;
	Death.Electric:
		"####" # 0 A_SetScale(0.62);
		Goto Death.Electric.Random;
	Raise:
		"####" MLKJIE 5;
		Goto Super::Raise+1;
	XDeath:
		SLOP A 1 A_SetScale(0.77);
		Goto Super::XDeath+1;
	Disintegrate:
		"####" F 0 A_Jump(256,"Disintegration");
	}
}

class HitlerGhost : Nazi
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title Hitler's Ghost
	//$Color 4
	Tag "$TAGHITLERGHOST";
	Health 750;
	Mass 1000;
	Speed 2.167;
	FloatSpeed .67;
	PainChance 24;
	Scale 0.69;
	DamageFactor "Rocket", 0.2;
	-CASTSPRITESHADOW  //needed for shadows
	-FLOORCLIP
	+BOSS
	+FLOAT
	+NOBLOOD
	+NOGRAVITY
	Obituary "$SSGHOST";
	DeathSound "hitlerghost/die";
	SeeSound "hitlerghost/see";
	RenderStyle "Translucent";
	}
	States
	{
	Spawn:
		HGST A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		"####" A 1 A_Chase("Missile","Missile",CHF_FASTCHASE);
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		Loop;
	Missile:
		"####" A 4 A_FaceTarget;
		"####" D 4 A_SpawnProjectile("EnemyFlamebolt2",36);
		"####" A 4;
		Goto See;
	Pain:
		"####" A 0 A_Jump(256,"Pain1","Pain2","Pain3");
	Pain1:
		"####" AAA 3 ThrustThing((int) (Angle*256/360-192), 8, 1, 0);
		Goto PainDone;
	Pain2:
		"####" AAA 3 ThrustThing((int) (Angle*256/360-64), 8, 1, 0);
		Goto PainDone;
	Pain3:
		"####" A 1;
	PainDone:
		"####" A 4 A_Pain;
		"####" "#" 0 A_AlertMonsters(256); //mxd
		Goto See;
	Death:
		"####" E 6 A_Scream;
		"####" FGHI 6;
		"####" J -1 A_NoBlocking;
		Stop;
	Idle:
		Stop;
	}
}

class Geist : Nazi
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title Geist
	//$Color 4
	Health 100;
	Mass 1000;
	Radius 16;
	Scale 0.65;
	Speed 5;
	FloatSpeed 1.33;
	Alpha 0.5;
	RenderStyle "Translucent";
	-CASTSPRITESHADOW  //needed for shadows
	-FLOORCLIP
	+DONTFALL
	+FLOAT
	+LOOKALLAROUND
	+NOBLOOD
	+NOGRAVITY
	Obituary "$GEIST";
	PainChance 255;
	PainSound "geist/pain";
	DeathSound "geist/die";
	Base.NoFear;
	}
	States
	{
	Spawn:
		GEST A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Look:
		GEST ABCD 4 A_Look;
		Loop;
	See:
		GEST A 0 A_StartSound("geist/active", CHAN_VOICE, CHANF_LOOPING, 1.0);
		"####" A 0 A_SetTranslucent(0.1);
		"####" AAABBBCCCDDD 1 A_Chase;
		"####" A 0 A_SetTranslucent(0.2);
		"####" AAABBBCCCDDD 1 A_Chase;
		"####" A 0 A_SetTranslucent(0.3);
		"####" AAABBBCCCDDD 1 A_Chase;
		"####" A 0 A_SetTranslucent(0.4);
		"####" AAABBBCCCDDD 1 A_Chase;
		"####" A 0 A_SetTranslucent(0.5);
		"####" AAABBBCCCDDD 1 A_Chase;
		"####" A 0 A_SetTranslucent(0.4);
		"####" AAABBBCCCDDD 1 A_Chase;
		"####" A 0 A_SetTranslucent(0.3);
		"####" AAABBBCCCDDD 1 A_Chase;
		"####" A 0 A_SetTranslucent(0.2);
		"####" AAABBBCCCDDD 1 A_Chase;
		Loop;
	Melee:
		"####" A 1 A_SetTranslucent(0.1);
		"####" AA 1 A_FadeIn(0.2);
		"####" B 0 A_FaceTarget;
		"####" BCDABCD 3 A_CustomMeleeAttack(4);
		"####" AAAA 1 A_Fadeout(0.1);
		Goto See;
	Pain:
		"####" E 1 A_Pain;
		"####" E 1 A_SetTranslucent(0.4);
		"####" EEE 1 A_Fadeout(0.1);
		"####" "#" 0 A_AlertMonsters(256); //mxd
		Goto See;
	Death:
		"####" E 0 A_StopSound(CHAN_VOICE);
		"####" E 5 A_SetTranslucent(0.5);
		"####" E 6 A_Scream;
		"####" FG 6;
		"####" H 6 A_NoBlocking;
		Stop;
	Idle:
		Stop;
	}
}

class NaziGeist : Geist
{
	Default
	{
	//$Title Geist, Nazi Soldier (summon Geists, 6 max)
	Scale 0.66;
	Health 400;
	Radius 32;
	Speed 3.75;
	PainChance 128;
	}
	States
	{
	Spawn:
		GES2 A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Look:
		GES2 ABCD 6 A_Look;
		Loop;
	See:
		GES2 A 0 A_StartSound("geist/active", CHAN_VOICE, CHANF_LOOPING, 1.0);
		"####" A 0 A_SetTranslucent(0.1);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		"####" A 0 A_SetTranslucent(0.2);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		"####" A 0 A_SetTranslucent(0.3);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		"####" A 0 A_SetTranslucent(0.4);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		"####" A 0 A_SetTranslucent(0.5);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		"####" A 0 A_SetTranslucent(0.4);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		"####" A 0 A_SetTranslucent(0.3);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		"####" A 0 A_SetTranslucent(0.2);
		"####" A 1 A_Chase;
		"####" AAAAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBBBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCCCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDDDD 1 A_Chase(null,null);
		Loop;
	Missile:
		GES2 A 1 BRIGHT A_SetTranslucent(0.1);
		"####" AAABBB 1 BRIGHT A_FadeIn(0.1);
		"####" B 1 BRIGHT A_SetTranslucent(1.0);
		"####" CD 4 BRIGHT A_FaceTarget;
		"####" A 0 A_Jump(64,3);
		"####" A 4 BRIGHT {A_SpawnAtGoal("CreepyRaise", random(10,-10), random(10,-10), 32, 0, 0, 0, 0); A_PainAttack("Geist",random(0,360),PAF_NOSKULLATTACK | PAF_NOTARGET,6);}
		"####" A 0 A_Jump(128,3);
		"####" A 0 {A_SpawnAtGoal("CreepyRaise", random(10,-10), random(10,-10), 32, 0, 0, 0, 0); A_PainAttack("Geist",random(0,360),PAF_NOSKULLATTACK | PAF_NOTARGET,4);}
		"####" A 4 BRIGHT {A_SpawnAtGoal("CreepyRaise", random(10,-10), random(10,-10), 32, 0, 0, 0, 0); A_PainAttack("Geist",random(0,360),PAF_NOSKULLATTACK | PAF_NOTARGET,2);}
		"####" B 3 BRIGHT;
		"####" BCCCC 1 BRIGHT A_Fadeout(0.1);
		"####" D 4 BRIGHT;
		Goto See;
	Pain:
		GES2 E 1 A_Pain;
		"####" E 1 A_SetTranslucent(0.4);
		"####" EEE 1 A_Fadeout(0.1);
		"####" "#" 0 A_AlertMonsters(256); //mxd
		Goto See;
	Death:
		GES2 E 0 A_StopSound(CHAN_VOICE);
		"####" E 5 A_SetTranslucent(0.5);
		"####" E 6 A_Scream;
		"####" F 5;
		"####" G 4 A_NoBlocking;
		"####" G 0 A_SpawnItemEx("Stahlhelm",0,8,64,frandom(0.1,-0.1),frandom(0.1,-0.1),frandom(0.1,-0.1),0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class UndeadMonk : HitlerGhost
{
	Default
	{
	//$Title Undead Monk
	Health 200;
	Scale 0.67;
	DamageFactor "Rocket", 1.0;
	-BOSS
	+LOOKALLAROUND
	Obituary "$UNDEADM";
	DeathSound "monk/death";
	PainSound "monk/pain";
	SeeSound "monk/see";
	Base.NoFear;
	}
	States
	{
	Spawn:
		MONK A 0;
		Goto Look;
	Missile: //mxd. Added cause firing offset
		"####" A 4 A_FaceTarget;
		"####" D 4 LIGHT("OTTOFIRE") A_SpawnProjectile("EnemyFlamebolt2",68);
		"####" A 4;
		Goto See;
	}
}

class ZyklonMonk : UndeadMonk
{
	Default
	{
	//$Title Zyklon Monk
	Health 250;
	DamageFactor "MutantPoison", 0.0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0.0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DamageFactor "Poison", 0.0;
	Obituary "$UNDEADZ";
	}
	States
	{
	Spawn:
		MONZ A 0;
		Goto Look;
	Missile:
		"####" A 6 A_FaceTarget;
		"####" D 6 A_SpawnProjectile("ZFlameBall",68);
		"####" A 6;
		Goto See;
	}
}

class SSTemplar : Guard
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title SS Templar
	Obituary "$SSCULT";
	Health 100;
	Mass 125;
	Speed 2.66666667;
	Scale 0.7;
	PainChance 128;
	DropItem "Ammo12Gauge", 96;
	DropItem "Ammo12Gauge", 128;
	DropItem "TrenchShotgun", 32;
	PainSound "sstemplar/pain";
	DeathSound "sstemplar/die";
	SeeSound "sstemplar/see";
	ActiveSound "sstemplar/idle";
	}
	States
	{
	Spawn:
		SSCT N 0;
		Goto Look;
	See:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		SSCT A 0 A_Jump(32, "Run");
		"####" A 0 A_SetSpeed(2.66666667);
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
		"####" D 0 A_Jump(32, "Idle");
		"####" # 0 A_PlayStepSound();
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null);
		"####" E 1 A_NaziChase;
		"####" EE 1 A_NaziChase(null,null);
		"####" E 1 A_NaziChase;
		"####" EE 1 A_NaziChase(null,null);
		Loop;
	Run:
		SSCT A 0 A_Jump(24, "See");
		"####" A 0 A_SetSpeed(4.66666667);
		"####" A 1 A_NaziChase;
		"####" A 1 A_NaziChase(null,null);
		"####" A 1 A_NaziChase;
		"####" A 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" B 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" B 1 A_NaziChase;
		"####" B 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" C 1 A_NaziChase(null,null);
		"####" C 1 A_NaziChase;
		"####" C 1 A_NaziChase(null,null);
		"####" D 1 A_NaziChase;
		"####" D 1 A_NaziChase(null,null);
		"####" # 0 A_PlayStepSound();
		"####" D 1 A_NaziChase;
		"####" D 1 A_NaziChase(null,null);
		"####" E 1 A_NaziChase;
		"####" E 1 A_NaziChase(null,null);
		"####" E 1 A_NaziChase;
		"####" E 1 A_NaziChase(null,null);
		Loop;
	Missile:
		"####" F 4 A_FaceTarget;
	Missile.Aimed:
		"####" F 4 A_FaceTarget;
		"####" G 0 A_StartSound("sstemplar/shoot", CHAN_6);
		"####" G 0 {user_count++; if(user_count > 11) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_SpawnProjectile("EnemyShotgunTracer",48,-8,random(-2,2));
		"####" G 0 A_SpawnItemEx("ShotgunCasing", 16,0,60, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 4 LIGHT("PRIESTF");
		"####" F 2 A_MonsterRefire(15,"See");
		"####" F 8 A_FaceTarget;
		"####" G 0 A_StartSound("sstemplar/shoot", CHAN_7);
		"####" G 0 {user_count++; if(user_count > 11) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" G 0 A_SpawnProjectile("EnemyShotgunTracer",48,-8,random(-2,2));
		"####" G 0 A_SpawnItemEx("ShotgunCasing", 16,0,60, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 4 LIGHT("PRIESTF");
		"####" F 8;
		Goto See;
	Pain:
		SSCT H 6 A_NaziPain(256);
		Goto See;
	Reload: //ozy81
		SSCT F 0 {bNoPain = TRUE;}
		"####" F 8 A_StartSound("browning/cock", CHAN_WEAPON, 0, frandom (0.6,0.8), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("ShotgunCasing", 16,0,60, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 8 A_StartSound("browning/cock", CHAN_WEAPON, 0, frandom (0.6,0.8), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("ShotgunCasing", 12,0,54, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	Death.Rifle:
	Death:
		SSCT I 6;
		"####" J 6 A_Scream;
		"####" KL 6;
		"####" M 6 A_UnblockAndDrop;
		"####" O 6;
		"####" P -1;
		Stop;
	Raise:
		SSCT POMLKJI 6;
		Goto See;
	Idle:
		SSCT AAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class PlagueDoc : Guard
{
	Default
	{
	//$Category Monsters (BoA)/Occult
	//$Title Plague Doctor (young)
	Nazi.NoAltDeath 1;
	Nazi.CanSurrender 1;
	Nazi.CrouchChance 0;
	Obituary "$SCIENTIST";
	}
	States
	{
	Spawn:
		PDOC N 0;
		Goto Look;
	SurrenderSprite:
		PDCS E 0;
	See:
		Goto See.Fast;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		"####" I 0 A_CheckFadeDeath;
		PDOA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 10; //spill blood? - ozy81
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	}
}

class SSOccult : SSOfficer
{
	Default
	{
	//$Title SS Occult Officer (Random Flame/Electric Attacks, no weapons)
	Obituary "$SSOCCULT";
	Health 125;
	Nazi.ZombieVariant "SSZombieOfficer";
	DamageFactor "Electric", 0.5;
	DamageFactor "Fire", 0.5;
	DropItem "Medikit_Small", 64;
	DropItem "Bandages", 8;
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
		SSOC A 5 A_FaceTarget;
	Missile.Aimed:
		SSOC E 0 A_JumpIfCloser(radius+256,"TeslaMissile");
		"####" EEDD 3 A_FaceTarget;
		"####" E 4 A_SpawnProjectile("OccultBlazeFlames",0,0,0,CMF_CHECKTARGETDEAD);
		"####" E 3;
		"####" D 4 A_SpawnProjectile("OccultBlazeFlames2",0,0,0,CMF_CHECKTARGETDEAD);
		"####" D 3;
		SSOF A 0;
		Goto See;
	TeslaMissile:
		SSOC ABB 6 A_FaceTarget;
		"####" CC 4 {
			A_StartSound("tesla/kill");
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 0, CMF_AIMDIRECTION, 0);
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 180, CMF_AIMDIRECTION, 0);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 32, 0, -90, true);
			A_LightningAttack("LightningBeamZap2", 0, 0, 32, 0, 0, false);
		}
		"####" B 6;
		"####" CC 4 {
			A_StartSound("tesla/kill");
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 0, CMF_AIMDIRECTION, 0);
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 180, CMF_AIMDIRECTION, 0);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 32, 0, -90, true);
			A_LightningAttack("LightningBeamZap2", 0, 0, 32, 0, 0, false);
		}
		"####" A 6;
		SSOF A 0;
		Goto See;
	Pain:
		SSOF H 6 A_NaziPain(256);
		"####" H 0 A_Jump(256,"See");
	Death: //no altdeath or embedded drops for occult soldiers
		SSOC F 5;
		"####" G 5 A_Scream;
		"####" H 5 A_NoBlocking;
		SSOF L 5;
		"####" M 5;
		"####" M -1;
		Stop;
	Idle:
		SSOF AAAA 1 A_Wander;
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

class SSOccultFire : SSOccult
{
	Default
	{
	//$Title SS Occult Officer (Flame Attacks, no weapons)
	//$Sprite SSOCE0
	Nazi.ZombieVariant "SSZombieOfficer";
	}
	States
	{
	Missile:
		SSOC A 5 A_FaceTarget;
	Missile.Aimed:
		SSOC EEDD 3 A_FaceTarget;
		"####" E 4 LIGHT("OTTOFIRE") A_SpawnProjectile("OccultBlazeFlames",0,0,0,CMF_CHECKTARGETDEAD);
		"####" E 3;
		"####" D 4 LIGHT("OTTOFIRE") A_SpawnProjectile("OccultBlazeFlames2",0,0,0,CMF_CHECKTARGETDEAD);
		"####" D 3;
		SSOF A 0;
		Goto See;
	}
}

class SSOccultElectric : SSOccultFire
{
	Default
	{
	//$Title SS Occult Officer (Thunder Attacks, no weapons)
	//$Sprite SSOCB0
	Nazi.ZombieVariant "SSZombieOfficer";
	}
	States
	{
	Missile:
		SSOC A 5 A_FaceTarget;
	Missile.Aimed:
		SSOC ABB 6 A_FaceTarget;
		"####" CC 4 {
			A_StartSound("tesla/kill");
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 0, CMF_AIMDIRECTION, 0);
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 180, CMF_AIMDIRECTION, 0);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 32, 0, -90, true);
			A_LightningAttack("LightningBeamZap2", 0, 0, 32, 0, 0, false);
		}
		"####" B 6;
		"####" CC 4 {
			A_StartSound("tesla/kill");
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 0, CMF_AIMDIRECTION, 0);
			A_SpawnProjectile("TPortLightningWaveSpawner", 50, 0, 180, CMF_AIMDIRECTION, 0);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,50,0,0,0,0,0,160);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 32, 0, -90, true);
			A_LightningAttack("LightningBeamZap2", 0, 0, 32, 0, 0, false);
		}
		"####" A 6;
		SSOF A 0;
		Goto See;
	}
}