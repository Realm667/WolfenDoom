/*
 * Copyright (c) 2017-2021 Ozymandias81, Tormentor667, AFADoomer, Talon1024
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

////////////
//CRITTERS//
////////////

class Rottweiler : Nazi
{
	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Dog (Rottweiler)
	//$Color 4
	Height 48;
	Health 30;
	Speed 4;
	Mass 70;
	PainChance 180;
	SeeSound "dog/sight";
	PainSound "dog/pain";
	DeathSound "dog/death";
	ActiveSound "dog/active";
	HitObituary "$DOGS";
	-CANUSEWALLS
	-CANPUSHWALLS //dogs mustn't able to open doors imho, that's why there was -CANUSEWALLS before, but we use bumps on polys
	+NEVERTARGET //So the dogs don't get targeted by stealth (+FRIENDLY-abusing) guards
	Base.LoiterDistance 64;
	Nazi.TotaleGierDrop 0;
	}
	States
	{
	Spawn:
		DOGY A 0;
		Goto Look;
	Idle:
		"####" A 0 A_SetSpeed(4);
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
			if (target && target != goal) { Speed = 8; }
			else { Speed = 4; }
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
		"####" G 8 Fast A_CustomMeleeAttack(random(1,8)*3,"dog/attack","dog/attack");
		"####" FE 4 Fast;
		Goto See;
	Pain:
		"####" M 2;
		"####" M 2 A_Pain;
		"####" "#" 0 A_AlertMonsters(256); //mxd
		Goto See;
	Death:
		"####" H 8;
		"####" I 8 A_Scream;
		"####" J 6;
		"####" K -1 A_NoBlocking;
		Stop;
	Death.Fire:
		Goto Death.FireDogs;
	Raise:
		"####" KJIH 6;
		Goto See;
	}
}

class GermanShepherd : Rottweiler
{	Default
	{
	//$Title Dog (Shepherd)
	Health 20;
	Speed 5;
	Nazi.ZombieVariant "ZGermanShepherd";
	}
	States
	{
	Spawn:
		DOG2 A 0;
		Goto Look;
	Melee:
		"####" EF 2 Fast A_FaceTarget;
		"####" G 8 Fast A_CustomMeleeAttack(random(1,4)*3,"dog/attack","dog/attack");
		"####" FE 4 Fast;
		Goto See;
	}
}

class Doberman : Rottweiler
{	Default
	{
	//$Title Dog (Doberman)
	Health 25;
	Speed 6;
	Scale 0.62;
	}
	States
	{
	Spawn:
		DOG3 A 0;
		Goto Look;
	Melee:
		"####" EF 2 Fast A_FaceTarget;
		"####" G 8 Fast A_CustomMeleeAttack(random(1,6)*3,"dog/attack","dog/attack");
		"####" FE 4 Fast;
		Goto See;
	}
}

//FAMILIARS
class BatFamiliar : BatBase
{	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Bat
	//$Color 4
	Health 4;
	Radius 16;
	Height 32;
	FloatSpeed 2.33333333;
	Speed 3.33333334;
	PainChance 200;
	Scale 0.57;
	Monster;
	-CANPUSHWALLS
	-CANUSEWALLS
	-COUNTKILL
	-MTHRUSPECIES
	-THRUSPECIES
	+FLOAT
	+NOGRAVITY
	+NOINFIGHTING
	SeeSound "batfam/idle";
	PainSound "batfam/pain";
	DeathSound "batfam/death";
	ActiveSound "batfam/idle";
	HitObituary "$BAT";
	BatBase.MaxChaseTime 7;
	}
	States
	{
	Spawn:
		BFAM ABCB 3 A_LookThroughDisguise;
		Loop;
	See:
		BFAM A 1 A_Chase;
		"####" AA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_Chase;
		"####" CC 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_Chase;
		"####" DD 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		Loop;
	Melee:
		BFAM A 3 A_FaceTarget;
		"####" A 0 A_Jump(64,"Missed");
		"####" B 3 A_CustomMeleeAttack(Random(1, 4), "batfam/idle", "", "Pest");
		"####" CB 3 A_FaceTarget;
		Goto See;
	Missed: //here in order to avoid looping attacks, so the critter is less threatening
		"####" B 3;
		"####" CB 3 A_FaceTarget;
		Goto See;
	Pain:
		BFAM A 2;
		"####" A 2 A_Pain;
		Goto See;
	Death:
		BFAM D 5 A_ScreamAndUnblock;
		"####" EFD 5 {bMThruSpecies = TRUE; bThruSpecies = TRUE; bNoGravity = FALSE;}
		Goto Death+1;
	Crash:
		BFAM G 6 A_ScreamAndUnblock;
		"####" H 7;
		"####" I 8;
		"####" J -1 {bMThruSpecies = TRUE; bThruSpecies = TRUE; bNoGravity = FALSE;}
		Stop;
	}
}

class ZBatFamiliar : BatFamiliar
{	Default
	{
	//$Title Zyklon Bat
	FloatSpeed 3.33333333;
	Speed 4.33333334;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DamageFactor "Poison", 0;
	BloodColor "00 A0 7D";
	BloodType "ZombieBlood";
	HitObituary "$ZBAT";
	BatBase.MaxChaseTime 12;
	}
	States
	{
	Spawn:
		ZFAM ABCB 3 A_LookThroughDisguise;
		Loop;
	See:
		ZFAM A 1 A_Chase;
		"####" AA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_Chase;
		"####" CC 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_Chase;
		"####" DD 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		Loop;
	Melee:
		ZFAM A 3 A_FaceTarget;
		"####" A 0 A_Jump(72,"Missed");
		"####" B 3 A_CustomMeleeAttack(Random(1, 3), "batfam/idle", "", "UndeadPoison");
		"####" CB 3 A_FaceTarget;
		Goto See;
	Missed: //here in order to avoid looping attacks, so the critter is less threatening
		"####" B 3;
		"####" CB 3 A_FaceTarget;
		Goto See;
	Pain:
		ZFAM A 2;
		"####" A 2 A_Pain;
		Goto See;
	Death:
		ZFAM D 5 A_ScreamAndUnblock;
		"####" EFD 5 {bMThruSpecies = TRUE; bThruSpecies = TRUE; bNoGravity = FALSE;}
		Goto Death+1;
	Crash:
		ZFAM G 6 A_StartSound("batfam/crash");
		"####" H 7;
		"####" I 8;
		"####" J -1 {bMThruSpecies = TRUE; bThruSpecies = TRUE; bNoGravity = FALSE;}
		Stop;
	}
}

class RatFamiliar : Base
{	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Rat (attacking)
	//$Color 4
	Health 4;
	Radius 16;
	Height 24;
	Scale 0.30;
	Speed 3.66666667;
	PainChance 200;
	Monster;
	-CANPUSHWALLS
	-CANUSEWALLS
	-COUNTKILL
	-FLOAT
	-NOGRAVITY
	+NOINFIGHTING
	+FRIGHTENED
	SeeSound "rat/squeek";
	PainSound "batfam/pain";
	DeathSound "rat/death";
	ActiveSound "rat/active";
	HitObituary "$RAT";
	+Base.CANSQUISH
	}
	States
	{
	Spawn:
		MOUS A 3 A_LookThroughDisguise;
		Loop;
	See:
		MOUS A 1 A_Chase;
		"####" AA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		Loop;
	Melee:
		MOUS A 3 A_FaceTarget;
		"####" A 0 A_Jump(64,"Missed");
		"####" B 3 A_CustomMeleeAttack(Random(1, 2), "batfam/idle", "", "Pest");
		"####" BB 3 A_FaceTarget;
		Goto See;
	Missed: //here in order to avoid looping attacks, so the critter is less threatening
		"####" B 3;
		"####" BB 3 A_FaceTarget;
		Goto See;
	Pain:
		MOUS A 2;
		"####" A 2 A_Pain;
		Goto See;
	Death:
		MOUS H 5 A_ScreamAndUnblock;
		"####" IJKL 5;
		"####" M -1;
		Stop;
	}
}

//SPIDERS
class BigSpider : Base
{	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Spider (small)
	//$Color 4
	Health 15;
	Radius 8;
	Height 16;
	Speed 8;
	Mass 100;
	PainChance 150;
	Scale 0.33;
	MaxDropOffHeight 128;
	MaxStepHeight 16;
	Monster;
	-CANPUSHWALLS
	-CANUSEWALLS
	-COUNTKILL
	-MTHRUSPECIES
	-THRUSPECIES
	+DONTGIB
	+FLOORCLIP
	+NEVERFAST
	+NOINFIGHTING
	+THRUGHOST
	+FRIGHTENED
	Translation "176:191=164:167" , "32:47=164:167";
	BloodType "ScorpionBlood";
	BloodColor "DarkOrange1";
	SeeSound "spider1/sight";
	PainSound "spider1/pain";
	DeathSound "spider1/death";
	ActiveSound "spider1/active";
	HitObituary "$BSPIDER";
	Species "Spiders";
	+Base.CANSQUISH
	DamageFactor "Squish", 5.0;
	}
	States
	{
	Spawn:
		GAYS A 0 NODELAY A_SetScale(Scale.X + frandom(-0.1, 0.05));
		Goto Idle;
	Idle:
		GAYS A 10 A_LookThroughDisguise;
		Loop;
	See:
		GAYS A 0 A_StartSound("spider1/walk", CHAN_AUTO, 0, 0.4);
		"####" AABB 2 A_Chase;
		"####" B 0 A_StartSound("spider1/walk", CHAN_AUTO, 0, 0.4);
		"####" CCDD 2 A_Chase;
		"####" A 0 A_JumpIf(random(1, 24) == 1, "TryJump");
		Loop;
	TryJump:
		GAYS A 0 A_CheckFloor("Jump"); //don't jump if mid-air
		Goto See;
	Jump:
		GAYS A 0 A_FaceTarget;
		"####" A 0 ThrustThing((int) (angle*256/360), random(8, 12), 0, 0);
		"####" A 0 ThrustThingZ(0, random(30, 50), 0, 1);
		"####" A 0 A_StartSound("spider1/jump", CHAN_AUTO, 0, 0.2);
		"####" E 15;
		Goto See;
	Melee:
		GAYS A 4 A_FaceTarget;
		"####" E 4 A_CustomMeleeAttack(1, "spider1/melee", "", "Pest", TRUE);
		"####" E 9 A_FaceTarget;
		Goto See;
	Pain:
		GAYS C 5;
		"####" C 3 A_Pain;
		Goto See;
	Death.Squish:
		GAYR F 1 A_StartSound("shark/death", CHAN_7, 0, 0.125); // Play squishing sound
	Death:
		GAYR F 5;
		"####" E 5 A_Scream;
		"####" D 5 A_Fall;
		"####" C 5;
		"####" B 5;
		"####" A 5;
		"####" A -1 {bMThruSpecies = TRUE; bThruSpecies = TRUE;}
		Stop;
	}
}

class MiniSpider : BigSpider
{	Default
	{
	//$Title Spider (mini)
	Health 5;
	Radius 4;
	Height 8;
	Speed 12;
	Mass 50;
	PainChance 255;
	Scale 0.18;
	MaxDropOffHeight 64;
	MaxStepHeight 8;
	}
	States
	{
	Melee:
		GAYS A 4 A_FaceTarget;
		"####" E 4 A_CustomMeleeAttack(Random(0, 1), "spider1/melee", "", "Pest", TRUE);
		"####" E 9 A_FaceTarget;
		Goto See;
	}
}

class BigSpiderNest : BigSpider { Default { DamageFactor "Falling", 0.0; +LAXTELEFRAGDMG } }
class MiniSpiderNest : MiniSpider { Default { DamageFactor "Falling", 0.0; +LAXTELEFRAGDMG } }

//SCORPIONS
class Scorpion : Base
{	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Scorpion (normal)
	//$Color 4
	Radius 16;
	Height 16;
	Scale 0.6;
	Mass 20;
	Speed 6;
	Health 20;
	DamageFunction (random(1,8)); //jumpattacks
	MeleeRange 16;
	MaxTargetRange 112;
	MaxStepHeight 16;
	MaxDropOffHeight 128;
	Monster;
	+DONTMORPH
	+FLOORCLIP
	+LOOKALLAROUND
	+NOINFIGHTING
	+NOTRIGGER
	Species "Nazi";
	BloodType "ScorpionBlood";
	BloodColor "DarkOrange1";
	DeathSound "rat/death";
	Obituary "$SCORPSML";
	}
	States
	{
	Spawn:
		SCRP A 2;
	See:
		SCRP AAAA 1 A_Chase;
		SCRP A 0 A_Jump(16,"Procrastinate");
		SCRP BBBB 1 A_Chase;
		SCRP A 0 A_Jump(16,"Procrastinate");
		SCRP A 0 A_Jump(11,"TryJump");
		Loop;
	Melee:
		TNT1 A 0 A_FaceTarget;
		SCRP A 0 A_Jump(64,"Procrastinate");
		SCRP AB 6 A_CustomMeleeAttack(2*random(1,4),"scorpion/attacks","scorpion/attacks");
		Goto See;
	Missile:
		SCRP AB 4 A_FaceTarget;
		SCRP A 0 A_Jump(64,"Procrastinate");
		SCRP A 8 A_SkullAttack;
		SCRP B 5 A_Gravity;
		Goto See;
	TryJump:
		TNT1 A 0 A_CheckFloor("Jump"); //don't jump if mid-air
		Goto See;
	Jump:
		TNT1 A 0 ThrustThing((int) (angle*256/360),random(4,6),0,0);
		SCRP C 15 ThrustThingZ(0,random(30,40),0,1);
		Goto See;
	Procrastinate:
		SCRP "#" 35;
		SCRP "#" 0 A_Jump(128,"Procrastinate");
		Goto See;
	Death:
		TNT1 A 0 A_ScreamAndUnblock;
		TNT1 AAAAAAAA 0 A_SpawnItemEx("ScorpionChunk",0,0,4,random(-2,2),random(-2,2),random(5,10),random(0,256),0,100);
		Stop;
	}
}

class ScorpionBig : Base
{	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Scorpion (big)
	//$Color 4
	Radius 32;
	Height 48;
	Scale 1.0;
	Mass 100;
	Speed 4;
	Health 200;
	MeleeRange 32;
	MaxStepHeight 32;
	MaxDropOffHeight 256;
	PainChance 235;
	DamageFunction (2 * random(1,8)); //jumpattacks
	Monster;
	+DONTMORPH
	+FLOORCLIP
	+LOOKALLAROUND
	+NOINFIGHTING
	+NOTRIGGER
	Species "Nazi";
	ActiveSound "scorpion/see";
	SeeSound "scorpion/see";
	PainSound "scorpion/pains";
	DeathSound "scorpion/death";
	Obituary "$SCORPBIG";
	}
	States
	{
	Spawn:
		SCR2 A 2;
	See:
		SCR2 A 1 A_Chase;
		SCR2 AA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCR2 A 1 A_Chase;
		SCR2 AA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCR2 B 1 A_Chase;
		SCR2 BB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCR2 B 1 A_Chase;
		SCR2 BB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCR2 A 0 A_Jump(11,"TryJump");
		Loop;
	Melee:
		TNT1 A 0 A_FaceTarget;
		SCR2 AB 6 A_CustomMeleeAttack(3*random(1,4),"scorpion/attacks","scorpion/attacks");
		Goto See;
	Missile:
		SCR2 A 0 A_Jump(256,"Spit","Sting","Reach");
	Spit:
		SCR2 AB 4 A_FaceTarget;
		SCR2 B 8 A_SpawnProjectile("ScorpionSpit",8,0,0,2,3);
		Goto See;
	Sting:
		SCR2 AB 4 A_FaceTarget;
		SCR2 BBBB 4 A_SpawnProjectile("ScorpionNail",24,0,0);
		Goto See;
	Reach:
		SCR2 A 0 A_JumpIfCloser(224,2);
		Goto See;
		SCR2 AB 6 A_FaceTarget;
		SCR2 A 6 A_SkullAttack;
		SCR2 B 6 A_Gravity;
		Goto See;
	TryJump:
		TNT1 A 0 A_CheckFloor("Jump"); //don't jump if mid-air
		Goto See;
	Jump:
		TNT1 A 0 ThrustThing((int) (angle*256/360),random(4,6),0,0);
		TNT1 A 0 ThrustThingZ(0,random(30,40),0,1);
		SCR2 C 15 A_StartSound("scorpion/fall", CHAN_AUTO, 0, 1.5);
		Goto See;
	Pain:
		SCR2 A 2 A_Pain;
		Goto See;
	Death:
		TNT1 A 0 A_ScreamAndUnblock;
		TNT1 AAAAAAAA 0 A_SpawnItemEx("BigScorpionChunk",0,0,4,random(-2,2),random(-2,2),random(5,10),random(0,256),0,100);
		Stop;
	}
}

class ScorpionMK : ScorpionBig
{	Default
	{
	//$Title Scorpion MK (easteregg)
	//$Color 4
	Radius 48;
	Height 64;
	Mass 1000;
	Scale 1.5;
	Speed 6;
	Health 400;
	MeleeRange 64;
	MaxStepHeight 64;
	PainChance 195;
	DamageFunction (3 * random(1,8)); //jumpattacks
	Obituary "$SCORPMK"; //but doesn't get applied as expected
	DamageFactor "Electric", 1.2; //rayden
	DamageFactor "Fire", 0.0; //himself
	DamageFactor "Ice", 2.0; //subzero
	}
	States
	{
	Spawn:
		SCRP A 2;
	See:
		SCRP A 1 A_Chase;
		SCRP AA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCRP A 1 A_Chase;
		SCRP AA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCRP B 1 A_Chase;
		SCRP BB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCRP B 1 A_Chase;
		SCRP BB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		SCRP A 0 A_Jump(11,"TryJump");
		Loop;
	Melee:
		TNT1 A 0 A_FaceTarget;
		SCRP AB 6 A_CustomMeleeAttack(3*random(1,4),"scorpion/attacks","scorpion/attacks");
		Goto See;
	Missile:
		SCRP A 0 A_Jump(256,"Flame","Harpoon","Harpoon","Reach"); //more chances for harpoon, doesn't spit instead flames
	Flame:
		SCRP AB 4 A_FaceTarget;
		SCRP BBBBBBBB 1 A_SpawnProjectile("EnemyFlamerShot",32,0,0,CMF_AIMDIRECTION);
		Goto See;
	Harpoon: //probably require distinct attack to trigger proper obituary
		SCRP AB 4 A_FaceTarget;
		SCRP B 0 A_StartSound("scorpion/mk", CHAN_ITEM, 0, 1.5);
		SCRP B 4 A_SpawnProjectile("Harpoon",48,0,frandom(-2,2),CMF_AIMDIRECTION);
		Goto See;
	Reach:
		SCRP A 0 A_JumpIfCloser(224,2);
		Goto See;
		SCRP AB 6 A_FaceTarget;
		SCRP A 6 A_SkullAttack;
		SCRP B 6 A_Gravity;
		Goto See;
	TryJump:
		TNT1 A 0 A_CheckFloor("Jump"); //don't jump if mid-air
		Goto See;
	Jump:
		TNT1 A 0 ThrustThing((int) (angle*256/360),random(4,6),0,0);
		TNT1 A 0 ThrustThingZ(0,random(60,80),0,1);
		SCRP C 15 A_StartSound("scorpion/fall", CHAN_AUTO, 0, 1.5);
		Goto See;
	Pain:
		SCRP A 2 A_Pain;
		Goto See;
	Death:
		TNT1 A 0 A_ScreamAndUnblock;
		TNT1 AAAAAAAA 0 A_SpawnItemEx("MKScorpionChunk",0,0,4,random(-2,2),random(-2,2),random(5,10),random(0,256),0,100);
		Stop;
	}
}

//SHARKS
class Shark : Base
{	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Shark
	//$Color 4
	Base.Swimmer;
	Base.LoiterDistance 128;
	Radius 30;
	Height 30;
	Health 100;
	Mass 120;
	Speed 2.5;
	FloatSpeed 1;
	DamageFunction (random(1,5)*5);
	Monster;
	-CASTSPRITESHADOW  //needed for shadows
	-CANPUSHWALLS
	-CANUSEWALLS
	+FLOAT
	+FLOORCLIP
	+FORCEXYBILLBOARD
	+NEVERTARGET
	+NOGRAVITY
	+NOINFIGHTING
	+NOFRICTION
	Obituary "$SHARK";
	SeeSound "shark/sight";
	DeathSound "shark/death";
	ActiveSound "shark/active";
	}
	States
	{
	Spawn:
		SHRK A 0;
		Goto Look;
	Look:
		"####" BC 10 A_LookThroughDisguise;
		Loop;
	See:
		"####" A 0 {
			if (target && target != goal) { Speed = 2.5; }
			else { Speed = 1; }
		}
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null);
		Loop;
	Idle:
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_LookThroughDisguise;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_LookThroughDisguise;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_LookThroughDisguise;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_LookThroughDisguise;
		Loop;
	Missile:
		"####" A 10;
		"####" A 8 A_JumpAttack(20, frandom(0.5, 0.75), JAF_PRECISE | JAF_INTERCEPT);
		"####" A 0 A_Jump(256, "See");
	Melee:
		"####" A 10 A_FaceTarget;
		"####" F 8 A_CustomMeleeAttack(random(1,5)*5,"Chomp","Swipe");
		"####" A 10;
		"####" A 0 A_Jump(256, "See");
	Death:
		"####" A 0 A_Scream;
		"####" AAAAAAAA 0 A_SpawnProjectile("Gibs1",random(20,40),0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(-100,100));
		Stop;
	}
}

class LaserShark : Shark
{	Default
	{
	//$Category Monsters (BoA)/Critters
	//$Title Shark (Laser)
	//$Color 4
	Obituary "$SHARKL";
	}
	States
	{
	Spawn:
		SHRL A 0;
		Goto Look;
	Missile:
		"####" BC 10 A_FaceTarget(0, 0, FAF_MIDDLE);
		"####" EEEEEEEEEEEEEEE 1 A_FireLaser(Random(0, 1), "tesla/loop", 12, 0, 0.8);
		"####" B 2 A_StopLaser;
		"####" B 2 A_FaceTarget;
		"####" A 0 A_Jump(256, "See");
	}
}