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

//////////
//BOSSES// 
//////////
class AngelOfDeath : Base
{	Default
	{
	//$Category Monsters (BoA)/Occult/Bosses
	//$Title Angel Of Death (Boss)
	//$Color 4
	Base.BossIcon "BOSSICO3";
	Tag "$TAGBOSSOCCULT";
	Health 3000;
	Radius 48;
	Height 96;
	Mass 2000;
	Speed 6;
	PainChance 64;
	Scale 1.0;
	Monster;
	+BOSS
	+FLOAT
	+FLOATBOB
	+NOGRAVITY
	Obituary "$AODE1";
	HitObituary "$AODE2";
	SeeSound "aode/sight";
	ActiveSound "aode/active";
	PainSound "aode/pain";
	DeathSound "aode/death";
	BloodType "BossBlood";
	BloodColor "DarkSeaGreen";
	DamageFactor "Rocket", 0.2;
	DamageFactor "Electric", 1.2;
	}
	States
	{
	Spawn:
		AODE A 1 A_LookThroughDisguise;
		Loop;
	See:
		"####" ABCDCB 2 A_FastChase;
		Loop;
	Melee:
		"####" EF 5;
		"####" G 6 A_CustomMeleeAttack(6,"aode/melee","","Melee",TRUE);
		Goto See;
	Missile:
		"####" E 0 A_Jump(96, "SeekerBlast");
		"####" E 0 A_JumpIfCloser(512, "CloseRange");
		Goto LongRange;
	CloseRange:
		"####" E 0 A_Jump(176, "RapidFire");
		Goto SpreadFire;
	LongRange:
		"####" E 0 A_Jump(176, "SpreadFire");
		Goto RapidFire;
	SeekerBlast:
		"####" E 0 A_StartSound("aode/fire");
		AODE F 8 A_FaceTarget;
		"####" G 8 A_SpawnProjectile("AODEBlastPod", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		Goto See;
	RapidFire:
		"####" EF 8 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 5 A_FaceTarget;
		Goto See;
	SpreadFire:
		AODE EF 8 A_FaceTarget;
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" EF 8 A_FaceTarget;
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" E 5 A_FaceTarget;
		Goto See;
	Pain:
		TNT1 A 0 A_Jump(50, "PainSpam");
		AODE H 2;
		AODE H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-48, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR | SXF_TRANSFERSCALE);
		"####" H 4 A_Pain;
		Goto See;
	PainSpam:
		AODE H 2;
		AODE H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-48, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR | SXF_TRANSFERSCALE);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 5, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 25, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 45, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 65, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 85, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 105, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 125, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 145, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 165, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 185, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 205, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 225, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 245, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 265, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 285, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 305, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 325, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 345, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" H 4 A_Pain;
		Goto See;
	Death:
		"####" L 0 {bFloatBob = FALSE;}
		"####" L 5 A_Scream;
		"####" L 2 A_Fall;
		Wait;
	Crash:
		"####" MNOPQRS 10;
		"####" T -1;
		Stop;
	}
}

class AngelOfDeath_End : AngelOfDeath
{	Default
	{
	//$Title Angel Of Death, Final Battle (Boss)
	//$Sprite AODEG0
	Health 8000;
	WoundHealth 3000;
	Speed 10;
	-REFLECTIVE
	+INVULNERABLE
	+ALLOWPAIN
	PainChance "Fire", 0;
	PainChance "Normal", 0;
	PainChance "OccultFire", 48;
	PainChance "Rocket", 0;
	PainChance "MutantPoison", 0;
	PainChance "Poison", 0;
	PainChance "UndeadPoison", 0;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DamageFactor "Rocket", 0;
	DamageFactor "Normal", 0;
	DamageFactor "Fire", 0;
	DamageFactor "OccultFire", 2.0;
	Species "Zombie";
	DropItem "Rune_Fa", 255;
	DropItem "Rune_Gibor", 255;
	}
	States
	{
	Spawn:
		AODE A 1 A_LookThroughDisguise;
		Loop;
	See:
		"####" A 1 {A_UnsetReflective(); bAllowPain = TRUE; bVisibilityPulse = FALSE;}
		"####" A 0 A_JumpIf(health<3000, "See.Wound");
		"####" ABCDCB 2 A_FastChase;
		Loop;
	See.Wound:
		"####" A 0 A_SpawnItemEx("ZyklonZCloud2",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		"####" A 1 {A_FastChase(); A_UnsetReflective(); bAllowPain = TRUE; bVisibilityPulse = FALSE;}
		"####" A 0 A_SpawnItemEx("AODEClone1", 0, 0, 0, 0, 0, 0, 0, 0);
		"####" B 1 A_FastChase;
		"####" B 0 A_SpawnItemEx("AODEClone2", 0, 0, 0, 0, 0, 0, 0, 0);
		"####" C 1 A_FastChase;
		"####" C 0 A_SpawnItemEx("AODEClone3", 0, 0, 0, 0, 0, 0, 0, 0);
		"####" D 1 A_FastChase;
		"####" D 0 A_SpawnItemEx("AODEClone4", 0, 0, 0, 0, 0, 0, 0, 0);
		"####" D 0 A_SpawnItemEx("ZyklonZCloud2",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		"####" A 1 A_FastChase;
		"####" A 0 A_SpawnItemEx("AODEClone1", 0, 0, 0, 0, 0, 0, 0, 0);
		"####" B 1 A_FastChase;
		"####" B 0 A_SpawnItemEx("AODEClone2", 0, 0, 0, 0, 0, 0, 0, 0);
		"####" C 1 A_FastChase;
		"####" C 0 A_SpawnItemEx("AODEClone3", 0, 0, 0, 0, 0, 0, 0, 0);
		"####" D 1 A_FastChase;
		"####" D 0 A_SpawnItemEx("AODEClone4", 0, 0, 0, 0, 0, 0, 0, 0);
		Loop;
	See.Cloak: //reflective, to mimic Hitler behaviors
		"####" A 0 {A_SetReflective(); bAllowPain = FALSE; bVisibilityPulse = TRUE;}
		"####" A 2 A_SetTranslucent(0.95, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.90, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.85, STYLE_TRANSLUCENT);
		"####" D 2 A_SetTranslucent(0.80, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.75, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.70, STYLE_TRANSLUCENT);
		"####" A 2 A_SetTranslucent(0.65, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.60, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.55, STYLE_TRANSLUCENT);
		"####" D 2 A_SetTranslucent(0.50, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.45, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.40, STYLE_TRANSLUCENT);
		"####" A 2 A_SetTranslucent(0.35, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.30, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.25, STYLE_TRANSLUCENT);
		"####" D 2 A_SetTranslucent(0.20, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.15, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.10, STYLE_TRANSLUCENT);
	Cloak.Loop:
		"####" A 0 A_SpawnItemEx("ZyklonZCloud2",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,0);
		"####" A 0 {user_count++; if(user_count > 4) {user_count = 0; return ResolveState("Cloak.Stop");} return ResolveState(null);}
		"####" ABCDCB 2 A_Wander;
		Loop;
	Cloak.Stop:
		"####" A 2 A_SetTranslucent(0.10, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.15, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.20, STYLE_TRANSLUCENT);
		"####" D 2 A_SetTranslucent(0.25, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.30, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.35, STYLE_TRANSLUCENT);
		"####" A 2 A_SetTranslucent(0.40, STYLE_TRANSLUCENT);
		"####" B 2 A_SetTranslucent(0.45, STYLE_TRANSLUCENT);
		"####" C 2 A_SetTranslucent(0.50, STYLE_TRANSLUCENT);
		"####" D 1 A_SetTranslucent(0.55, STYLE_TRANSLUCENT);
		"####" C 1 A_SetTranslucent(0.60, STYLE_TRANSLUCENT);
		"####" B 1 A_SetTranslucent(0.65, STYLE_TRANSLUCENT);
		"####" A 1 A_SetTranslucent(0.70, STYLE_TRANSLUCENT);
		"####" B 1 A_SetTranslucent(0.75, STYLE_TRANSLUCENT);
		"####" C 1 A_SetTranslucent(0.80, STYLE_TRANSLUCENT);
		"####" D 1 A_SetTranslucent(0.85, STYLE_TRANSLUCENT);
		"####" C 1 A_SetTranslucent(0.90, STYLE_TRANSLUCENT);
		"####" B 1 A_SetTranslucent(0.95, STYLE_TRANSLUCENT);
		"####" A 1 A_SetTranslucent(1.0, STYLE_NONE);
		"####" A 1 {A_UnsetReflective(); bAllowPain = TRUE; bVisibilityPulse = FALSE; }
		Goto See.Wound;
	Melee:
		"####" E 0 A_JumpIf(health<3000, "Melee.Wound");
		"####" EF 4;
		"####" G 5 A_CustomMeleeAttack(6,"aode/melee","","Melee",TRUE);
		Goto See;
	Missile:
		"####" "#" 0 A_JumpIf(health<3000, "Missile.Wound");
		"####" E 0 A_Jump(96, "SeekerBlast");
		"####" E 0 A_JumpIfCloser(512, "CloseRange");
		Goto LongRange;
	CloseRange:
		"####" E 0 A_Jump(176, "RapidFire");
		Goto SpreadFire;
	LongRange:
		"####" E 0 A_Jump(176, "SpreadFire");
		Goto RapidFire;
	SeekerBlast:
		"####" E 0 A_StartSound("aode/fire");
		AODE F 8 A_FaceTarget;
		"####" G 8 A_SpawnProjectile("AODEBlastPod", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		Goto See;
	RapidFire:
		"####" EF 6 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 4 A_FaceTarget;
		Goto See;
	SpreadFire:
		AODE EF 6 A_FaceTarget;
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 5 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" EF 6 A_FaceTarget;
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 4 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" E 4 A_FaceTarget;
		Goto See;
	Pain:
		TNT1 A 0 A_JumpIf(health<3000, "Pain.Wound");
		TNT1 A 0 A_Jump(50, "PainSpam");
		AODE H 2;
		AODE H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-48, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR | SXF_TRANSFERSCALE);
		"####" H 4 A_Pain;
		Goto See;
	PainSpam:
		"####" "#" 0 A_JumpIf(health<3000, "PainSpam.Wound");
		AODE H 2;
		AODE H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-48, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR | SXF_TRANSFERSCALE);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 5, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 25, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 45, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 65, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 85, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 105, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 125, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 145, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 165, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 185, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 205, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 225, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 245, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 265, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 285, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 305, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 325, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 345, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" H 3 A_Pain;
		Goto See;
	ZyklonBursts:
		AODE UUUUU 1 A_SpawnProjectile("ZFlamebolt",56,0);
		"####" E 6 A_MonsterRefire(10,"See.Wound");
		Goto Missile.Wound;
	SeekerBlast.Wound:
		"####" E 0 A_StartSound("aode/fire");
		AODE F 8 A_FaceTarget;
		"####" G 8 A_SpawnProjectile("AODEBlastPod", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		Goto See.Wound;
	Melee.Wound:
		"####" EF 3;
		"####" G 4 A_CustomMeleeAttack(12,"aode/melee","","Melee",TRUE);
		Goto See.Wound;
	Missile.Wound:
		"####" E 0 A_Jump(32, "See.Cloak");
		"####" E 0 A_Jump(96, "SeekerBlast.Wound");
		"####" E 0 A_JumpIfCloser(384, "ZyklonBursts");
		Goto LongRange.Wound;
	CloseRange.Wound:
		"####" E 0 A_Jump(176, "RapidFire.Wound");
		Goto SpreadFire.Wound;
	LongRange.Wound:
		"####" E 0 A_Jump(176, "SpreadFire.Wound");
		Goto RapidFire.Wound;
	RapidFire.Wound:
		"####" EF 5 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 0 A_FaceTarget;
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" G 0 A_SpawnItemEx("SparkFlareG", 68, 38, random(52,58));
		"####" G 3 A_FaceTarget;
		Goto See.Wound;
	SpreadFire.Wound:
		AODE EF 4 A_FaceTarget;
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" EF 4 A_FaceTarget;
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 0 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-7,7), CMF_AIMOFFSET|CMF_OFFSETPITCH|CMF_BADPITCH, random(-3,3));
		"####" G 3 A_SpawnProjectile("AODEPlasmaBlast", 68, 38, random(-4,4));
		"####" E 3 A_FaceTarget;
		Goto See.Wound;
	Pain.Wound:
		"####" "#" 0 A_Jump(50, "PainSpam.Wound");
		AODE H 2;
		AODE H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-48, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR | SXF_TRANSFERSCALE);
		"####" H 4 A_Pain;
		Goto See.Wound;
	PainSpam.Wound:
		AODE H 2;
		AODE H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-48, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR | SXF_TRANSFERSCALE);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 5, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 25, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 45, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 65, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 85, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 105, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 125, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 145, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 165, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 185, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 205, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 225, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 245, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 265, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 285, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 305, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 325, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" F 0 A_SpawnProjectile("AODEPainPlasmaBlast", 75, 0, 345, CMF_CHECKTARGETDEAD|CMF_BADPITCH, 0);
		"####" H 3 A_Pain;
		Goto See.Wound;
	Death:
		"####" L 0 {bFloatBob = FALSE;}
		"####" L 5 A_Scream;
		"####" L 2 A_NoBlocking;
		"####" L 2; // Prevent items dropping more than once
		Wait;
	Crash:
		"####" MNOPQRS 10;
		"####" T -1;
		Stop;
	}
}

class SmokeMonster : Base
{	Default
	{
	//$Category Monsters (BoA)/Occult/Bosses
	//$Title SmokeMonster (Boss)
	//$Color 4
	//$Sprite SMMOA0
	Base.BossIcon "BOSSICO3";
	Tag "$TAGBOSSOCCULT";
	Health 3000;
	Height 56;
	Mass 10000000;
	Speed 4;
	DamageFunction (random(1,8));
	PainChance 64; //more chances for teleport himself now, old was 10
	DamageType "Smoke";
	DamageFactor "Smoke", 0;
	DamageFactor "Rocket", 0.2;
	MeleeThreshold 192;
	Monster;
	+BOSS
	-CASTSPRITESHADOW  //needed for shadows
	+DONTFALL
	+DONTHARMCLASS
	+DONTMORPH
	+EXTREMEDEATH
	+FLOAT
	+FLOATBOB
	+FLOORCLIP
	+FORCERADIUSDMG
	+NEVERRESPAWN
	+NOBLOOD
	+NOBLOODDECALS
	+NOGRAVITY
	+NOICEDEATH
	+THRUSPECIES
	Obituary "$SMOKEMO";
	SeeSound "Smoke/See";
	DeathSound "Smoke/Die";
	Species "Smoke";
	}
	States
	{
	Spawn:
		TNT1 A 1 A_LookThroughDisguise;
		TNT1 AAAAAA 0 { if (!CheckRange(1200, true)) { A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER); } }
		Loop;
	See:
		TNT1 A 0 A_JumpIf(user_saw>=1,"Walk");
		TNT1 A 0 A_StartSound("Smoke/Tick", CHAN_7, CHANF_LOOPING, 1.0);
		TNT1 A 0 { user_saw = 1; }
	Walk:
		TNT1 A 1 A_Chase;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		Loop;
	Missile:
		TNT1 A 0 A_StartSound("Smoke/charge");
	Melee:
		TNT1 A 1 A_SkullAttack;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 0 A_JumpIfTargetInLOS("Melee",75);
		TNT1 A 0 A_Jump(8,"Walk");
		TNT1 A 0 A_Stop;
		Goto See;
	Pain:
		TNT1 A 1 A_StartSound("Smoke/pain");
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 0 A_Jump(256,"SmokePain1","SmokePain2","SmokePain3");
	SmokePain1:
		TNT1 A 1 ThrustThing((int) (Angle*256/360-192), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-192), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-192), 8, 1, 0);
	PainEnd:
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_Stop;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		Goto See;
	SmokePain2:
		TNT1 A 1 ThrustThing((int) (Angle*256/360-64), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-64), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-64), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		Goto PainEnd;
	SmokePain3:
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		Goto PainEnd;
	Death:
		TNT1 A 1;
		TNT1 A 0 A_StopSound(CHAN_7);
		TNT1 A 0 A_Scream;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 AAA 1 A_SpawnItemEx("MonsterHole",0,0,8,random(-7,7),random(-7,7),random(-7,7),random(1,360), SXF_SETMASTER);
		TNT1 AA 1 A_SpawnItemEx("MonsterHole",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		Dead:
		TNT1 A 0 { user_saw = 0; }
		TNT1 A 0 A_UnSetSolid;
		TNT1 B -1;
		Stop;
	Teleport:
		TNT1 A 0 A_SetReflective;
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 A 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Chase(null,null,CHF_NIGHTMAREFAST);
		TNT1 A 0 A_Jump(128,50);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Chase(null,null,CHF_NIGHTMAREFAST);
		TNT1 A 0 A_Jump(128,50);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Chase(null,null,CHF_NIGHTMAREFAST);
		TNT1 A 1;
		TNT1 A 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 0 A_UnSetReflective;
		Goto See;
	}
}

class ZyklonMonsterBall : ZyklonBBall {
	Default
	{
		DamageFunction (5 * random(1,8));
	}
}

class ZyklonMonster : Nazi
{	Default
	{
	//$Category Monsters (BoA)/Occult/Bosses
	//$Title ZyklonMonster, Final Battle (Boss)
	//$Sprite ZMMOA0
	//$Color 4
	Base.BossIcon "BOSSICO3";
	Tag "$TAGBOSSOCCULT";
	Health 4500;
	WoundHealth 2500;
	Height 56;
	Mass 10000000;
	DamageFunction (random(1,8));
	Speed 6;
	+ALLOWPAIN
	+BOSS
	-CASTSPRITESHADOW  //needed for shadows
	+DONTFALL
	+DONTHARMCLASS
	+DONTMORPH
	+EXTREMEDEATH
	+FLOAT
	+FLOATBOB
	+FLOORCLIP
	+FORCERADIUSDMG
	+LOOKALLAROUND
	+NEVERRESPAWN
	+NOBLOOD
	+NOBLOODDECALS
	+NOGRAVITY
	+NOICEDEATH
	+INVULNERABLE
	DamageType "Smoke";
	DamageFactor "Electric", 0;
	DamageFactor "Fire", 0;
	DamageFactor "Normal", 0;
	DamageFactor "OccultFire", 1.0;
	DamageFactor "Rocket", 0;
	DamageFactor "Smoke", 0;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	PainChance "Electric", 0;
	PainChance "Fire", 0;
	PainChance "Normal", 0;
	PainChance "OccultFire", 48;
	PainChance "Rocket", 0;
	PainChance "MutantPoison", 0;
	PainChance "Poison", 0;
	PainChance "UndeadPoison", 0;
	DeathSound "Smoke/Die";
	SeeSound "Smoke/See";
	Obituary "$ZMOKEMO";
	Species "Zombie";
	DropItem "Rune_Tyr", 256, 1;
	}
	States
	{
	Spawn:
		TNT1 A 1 A_LookThroughDisguise;
		TNT1 AAAAAA 0 { if (!CheckRange(1200, true)) { A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER); } }
		Loop;
	See:
		TNT1 A 0 A_JumpIf(user_saw>=1,"Walk");
		TNT1 A 0 A_StartSound("Smoke/Tick", CHAN_7, CHANF_LOOPING, 1.0);
		TNT1 A 0 { user_saw = 1; }
	Walk:
		TNT1 A 1 A_Chase;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_Chase;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		Loop;
	Missile:
		TNT1 A 0 A_StartSound("Smoke/charge");
		TNT1 A 0 A_Jump(96,"Missile.Monsters");
		TNT1 A 1 { A_SpawnAtGoal("CreepyRaise", 0, 0, 0, 0, 0, 0, 0); A_SpawnProjectile("ZyklonMonsterBall",-16,16,-16,16,random(-16,16)); }
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 { A_SpawnAtGoal("CreepyRaise", 0, 0, 0, 0, 0, 0, 0); A_SpawnProjectile("ZyklonMonsterBall",-16,16,-16,16,random(-16,16)); }
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 { A_SpawnAtGoal("CreepyRaise", 0, 0, 0, 0, 0, 0, 0); A_SpawnProjectile("ZyklonMonsterBall",-16,16,-16,16,random(-16,16)); }
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 { A_SpawnAtGoal("CreepyRaise", 0, 0, 0, 0, 0, 0, 0); A_SpawnProjectile("ZyklonMonsterBall",-16,16,-16,16,random(-16,16)); }
		Goto See;
	Missile.Monsters:
		TNT1 A 0 A_Jump(256,1,2);
		TNT1 A 1 { A_SpawnAtGoal("CreepyRaise", 0, 0, 0, 0, 0, 0, 0); A_PainAttack("ZyklonSkull",random(0,360),PAF_NOSKULLATTACK | PAF_NOTARGET,3); }
		TNT1 A 1 { A_SpawnAtGoal("CreepyRaise", 0, 0, 0, 0, 0, 0, 0); A_PainAttack("ZBatFamiliar",random(0,360),PAF_NOSKULLATTACK | PAF_NOTARGET,3); }
		Goto See;
	Melee:
		TNT1 A 0 A_StartSound("Smoke/charge");
		TNT1 A 1 A_SkullAttack;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_FaceTarget;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 0 A_JumpIfTargetInLOS("Melee",75);
		TNT1 A 0 A_Jump(8,"Walk");
		TNT1 A 0 A_Stop;
		Goto See;
	Pain:
		TNT1 A 1 A_StartSound("Smoke/pain");
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 0 A_Jump(256,"SmokePain1","SmokePain2","SmokePain3");
	SmokePain1:
		TNT1 A 1 ThrustThing((int) (Angle*256/360-192), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-192), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-192), 8, 1, 0);
	PainEnd:
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_Stop;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		Goto See;
	SmokePain2:
		TNT1 A 1 ThrustThing((int) (Angle*256/360-64), 8, 1, 0);
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-64), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1 ThrustThing((int) (Angle*256/360-64), 8, 1, 0);
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		Goto PainEnd;
	SmokePain3:
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1 A_SpawnItemEx("ZyklonCritter",random(-4,4),random(-4,4),0,0,SXF_NOCHECKPOSITION,0); //sometimes can spawn a monster
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		Goto PainEnd;
	Death:
		TNT1 A 1;
		TNT1 A 0 A_StopSound(CHAN_7);
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_Explode;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-3,3),random(-3,3),random(-3,3),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-4,4),random(-4,4),random(-4,4),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-5,5),random(-5,5),random(-5,5),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 A 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-6,6),random(-6,6),random(-6,6),random(1,360), SXF_SETMASTER);
		TNT1 AAA 1 A_SpawnItemEx("MonsterHole2",0,0,8,random(-7,7),random(-7,7),random(-7,7),random(1,360), SXF_SETMASTER);
		TNT1 AA 1 A_SpawnItemEx("MonsterHole2",0,0,8,random(-8,8),random(-8,8),random(-8,8),random(1,360), SXF_SETMASTER);
		Dead:
		TNT1 A 0 { user_saw = 0; }
		TNT1 A 0 A_UnSetSolid;
		TNT1 B -1;
		Stop;
	Teleport:
		TNT1 A 0 A_SetReflective;
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 A 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Chase(null, null, CHF_NIGHTMAREFAST);
		TNT1 A 0 A_Jump(128,50);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Chase(null, null, CHF_NIGHTMAREFAST);
		TNT1 A 0 A_Jump(128,50);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Chase(null, null, CHF_NIGHTMAREFAST);
		TNT1 A 1;
		TNT1 A 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole2",0,0,8,random(-2,2),random(-2,2),random(-2,2),random(1,360), SXF_SETMASTER);
		TNT1 A 0 A_UnSetReflective;
		Goto See;
	}
}

class NaziLoper : Nazi
{
	bool noachievement[MAXPLAYERS];

	Default
	{
		//$Category Monsters (BoA)/Occult
		//$Title Nazi Loper
		//$Color 4
		Tag "$TAGLOPER";
		Health 950;
		Height 64;
		Radius 24;
		Mass 300;
		Speed 7;
		DamageFunction (8 * random(1,8)); //jump attacks
		DefThreshold 32;
		Scale 0.65;
		PainChance 64;
		DamageFactor "Rocket", 0.2;
		DamageFactor "Electric", 0.0;
		+BOSS
		+MISSILEMORE
		+NORADIUSDMG //or the ZTracer will kill the Loper :D
		MaxStepHeight 16;
		MaxDropOffHeight 128;
		MaxTargetRange 1024;
		Obituary "$LOPRHIT2";
		HitObituary "$LOPRHIT1";
		SeeSound "loper/wakeup";
		DeathSound "loper/death";
	}

	States
	{
		Spawn:
			LOPR A 0 NODELAY A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, CMF_AIMDIRECTION, 0);
			"####" A 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, CMF_AIMDIRECTION, 0);
			"####" A 1;
			Goto Look;
		See:
			Goto See.Boss3;
		Melee:
			"####" E 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, CMF_AIMDIRECTION, 0);
			"####" E 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, CMF_AIMDIRECTION, 0);
			"####" E 8 A_FaceTarget;
			"####" E 0 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" FG 8 A_CustomMeleeAttack(2*random(2,10),"loper/attack","loper/attack","Melee",TRUE);
			Goto Look;
		Missile:
			"####" E 0 A_Jump(160,"Missile3");  // Leap attack
			"####" E 0 A_Jump(random(128,192),"Missile2");
			"####" EE 2 LIGHT("LOPERLIT"){
				A_StartSound("tesla/kill");
				A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, CMF_AIMDIRECTION, 0);
				A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, CMF_AIMDIRECTION, 0);
				A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
				A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
				A_LightningAttack("LightningBeamZap2", 0, 0, random(4,8), 0, 0, false);
			}
			"####" EE 8 A_FaceTarget;
			"####" EE 2 LIGHT("LOPERLIT"){
				A_StartSound("tesla/kill");
				A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, CMF_AIMDIRECTION, 0);
				A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, CMF_AIMDIRECTION, 0);
				A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
				A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
				A_LightningAttack("LightningBeamZap2", 0, 0, random(4,8), 0, 0, false);
			}
			"####" EE 8 A_FaceTarget;
			Goto Look;
		Missile2:
			"####" A 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, 2, 0);
			"####" A 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, 2, 0);
			"####" A 0 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" A 0 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" A 0 ThrustThing((int) (angle*256/360),random(4,6),0,0);
			"####" AE 6 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" H 8 ThrustThingZ(0,random(30,40),0,1);
			"####" E 6 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" FG 17 LIGHT("LOPERLIT") A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" G 1 LIGHT("LOPERLIT") Radius_Quake(10,10,0,16,0);
			"####" G 0 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" G 0 A_Jump(128,"Missile4");
			"####" GF 4 LIGHT("LOPERLIT"){
				A_StartSound("tesla/kill");
				A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, CMF_AIMDIRECTION, 0);
				A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, CMF_AIMDIRECTION, 0);
				A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
				A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
				A_LightningAttack("LightningBeamZap2", 0, 0, 4, 0, 0, false);
				A_LightningAttack("LightningBeamZap2", 0, 0, 4, 60, 0, false);
				A_LightningAttack("LightningBeamZap2", 0, 0, 4, 120, 0, false);
				A_LightningAttack("LightningBeamZap2", 0, 0, 4, 180, 0, false);
				A_LightningAttack("LightningBeamZap2", 0, 0, 4, 240, 0, false);
				A_LightningAttack("LightningBeamZap2", 0, 0, 4, 320, 0, false);
			}
			"####" G 8 A_FaceTarget;
			Goto Look;
		Missile3:
			"####" A 0 A_JumpIfCloser(1024, 1);
			Goto Look;
			"####" CE 8 A_FaceTarget;
			"####" H 8;
			"####" F 1;
			"####" G 1 A_JumpAttack(30, .5, JAF_ARC | (random(0, 1) ? JAF_INTERCEPT : 0));
			"####" E 3;
			"####" C 5;
			Goto Look;
		Missile4:
			"####" GF 4 LIGHT("LOPERLIT");
			"####" G 0 A_LightningAttack("LightningBeamPillarZap2", 0, 0, 8, 0, -90, true);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,40,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,80,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,120,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,160,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,200,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,240,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,280,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,320,2,0);
			"####" G 0 LIGHT("LOPERLIT") A_SpawnProjectile("ZTracer",0,0,360,2,0);
			"####" G 8 A_FaceTarget;
			Goto Look;
		Pain:
			"####" I 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, 2, 0);
			"####" I 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, 2, 0);
			"####" I 0 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" I 6 A_NaziPain(256);
			"####" I 0 A_Jump(256,"See");
			Stop;
		Death.Fire:
		Death:
		XDeath:
			"####" I 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 0, 2, 0);
			"####" I 0 A_SpawnProjectile("TPortLightningWaveSpawner", 8, 0, 180, 2, 0);
			"####" I 6 A_Scream;
			"####" I 1 LIGHT("LOPERLIT") A_SpawnItemEx("GeneralExplosion_Medium");
			"####" I 1 LIGHT("LOPERLIT") Radius_Quake(10,10,0,16,0);
			"####" J 8;
			"####" K 1 {A_SpawnItemEx("Debris_Loper", random(8,-8), random(8,-8), random(54,64), frandom(0.5,0.7), frandom(0.5,0.7), frandom(0.5,0.7), random(0,360), SXF_CLIENTSIDE); A_NoBlocking();}
			"####" K 6;
			"####" LM 8;
			"####" N -1;
			Stop;
		Raise:
			"####" NMLKJIE 8;
			Goto Look;
	}
}

class FatMan : NaziBoss
{	Default
	{
	//$Category Monsters (BoA)/Bosses
	//$Title General Giftmacher (Boss)
	//$Color 4
	Base.BossIcon "BOSSICO2";
	Tag "$TAGGIFTMACHER";
	PainChance 32;
	-FLOAT		//we don't want him to fly, yeah? ;)
	-NOGRAVITY	//we don't want him to fly, yeah?
	Obituary "$OTTOBOSS";
	PainSound "boss/pain";
	ActiveSound "giftm/active";
	SeeSound "giftm/sight";
	DeathSound "giftm/die";
	DropItem "NebAmmo";
	}
	States
	{
	Spawn:
		OTTO A 0;
		Goto Look;
	Missile:
		OTTO E 10 A_FaceTarget;
		"####" E 0 A_Jump(128,"FlameGun","GasBomb");
		"####" F 8 A_SpawnProjectile("MiniRocket",42,12);
		"####" E 8;
		Goto See.BossFast;
	FlameGun:
		OTTO FFFFF 1 A_SpawnProjectile("EnemyFlamerShot",42,12);
		"####" E 6 A_MonsterRefire(10,"See");
		Goto Missile;
	GasBomb:
		OTTO F 4 A_ArcProjectile("GasBomb",42,12,random(-16,16));
		"####" E 8;
		Goto Missile;
	Pain:
		OTTO G 6 A_NaziPain(256);
		Goto See;
	Death:
		OTTO G 5;
		"####" H 8 A_Scream;
		"####" I 10;
		"####" J -1 A_NoBlocking;
		Stop;
	Raise:
		OTTO JIHG 5;
		Goto See;
	}
}

class FatMan2 : FatMan
{	Default
	{
	//$Title General Giftmacher (Boss, disappearing)
	//$Sprite OTTOK0
	DeathSound "hitlerghost/die";
	}
	States
	{
	Missile: //no Alt Attacks
		OTTO E 10 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("MiniRocket",42,12);
		"####" E 8;
		Goto See.BossFast;
	Death:
		OTTO KL 10 A_Scream;
		"####" KKKK 0 A_SpawnItemEx("PowerPlantSmokePuff", random(-8,8), random(-8,8), random(0,16), random(0,1), random(0,1), random(1,3));
		"####" KLKLKL 5 A_Fadeout(0.1); //laughs
		Stop;
	}
}

class RocketMan : NaziBoss
{	Default
	{
	//$Category Monsters (BoA)/Bosses
	//$Title General Schwabbelhals (Boss)
	//$Color 4
	Base.BossIcon "BOSSICO2";
	Tag "$TAGSCHWABBELHALS";
	Health 300;
	PainChance 64;
	Mass 200;
	+LOOKALLAROUND
	Obituary "$FATMAN";
	ActiveSound "schwabb/active";
	SeeSound "schwabb/sight";
	DeathSound "schwabb/die";
	}
	States
	{
	Spawn:
		SCHW A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.Boss;
	Missile:
		"####" E 10 A_FaceTarget;
		"####" F 6 A_SpawnProjectile("MiniMiniRocket",40,22);
		"####" E 6 A_FaceTarget;
		"####" G 6 A_SpawnProjectile("MiniMiniRocket",40,-18);
		"####" E 6 A_FaceTarget;
		"####" F 6 A_SpawnProjectile("MiniMiniRocket",40,22);
		"####" E 6 A_FaceTarget;
		"####" G 6 A_SpawnProjectile("MiniMiniRocket",40,-18);
		Goto See;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" H 5;
		"####" I 8 A_Scream;
		"####" J 10;
		"####" K 0 A_NoBlocking;
		"####" K -1 A_BossDeath;
		Stop;
	Raise:
		"####" KJIH 5;
		Goto See;
	Idle:
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class GoeringBoss : RocketMan
{	Default
	{
	//$Title General Goering (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGGOERING";
	Health 2000;
	PainChance 64;
	Mass 200;
	+LOOKALLAROUND
	Obituary "$GOERING";
	ActiveSound "goering/active";
	SeeSound "goering/sight";
	DeathSound "goering/die";
	DropItem "FlameAmmo", 128;
	DropItem "FlameAmmo", 128;
	DropItem "Medikit_Large", 192;
	}
	States
	{
	Spawn:
		GOER A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.Boss;
	Idle:
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	Missile:
		"####" E 0 A_Jump(128, "Missile2");
	Missile1:
		"####" E 8 A_FaceTarget;
		"####" F 5 A_ArcProjectile("ClusterBomb",40,22,random(-16,16));
		Goto See;
	Missile2:
		"####" E 5 A_FaceTarget;
		"####" G 5 A_SpawnProjectile("GoeringProjectile",40,-18);
		Goto See;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	Raise:
		"####" KJIH 5;
		Goto See;
	Death:
		"####" H 5;
		"####" I 8 A_Scream;
		"####" J 10;
		"####" K 0 A_NoBlocking;
		"####" K -1 A_BossDeath;
		Stop;
	}
}

class HimmlerBoss : RocketMan
{	Default
	{
	//$Title Himmler (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGHIMMLER";
	Health 1200;
	PainChance 8; //prevent UMG43 and nebelwerfer to stop the Boss attacking player, needs to be applied to many bosses - ozy81
	Mass 200;
	+LOOKALLAROUND
	+MISSILEMORE
	Obituary "$HIMMLER";
	ActiveSound "himmler/active";
	SeeSound "himmler/sight";
	DeathSound "himmler/die";
	DamageFactor "Electric", 0.5;
	DamageFactor "Fire", 0.5;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DropItem "DeployableMine", 128;
	DropItem "NebAmmo", 128;
	}
	States
	{
	Spawn:
		HIMM A 0;
		Goto Look;
	Missile:
		HIMM E 10 A_FaceTarget;
		"####" E 0 A_Jump(128,"DropMine", "Mortar");
	Rocket:
		"####" F 4 A_SpawnProjectile("NebRocketEnemy",44,18);
		"####" E 12;
		"####" G 4 A_SpawnProjectile("NebRocketEnemy",44,-18);
		"####" E 12;
		"####" P 0 A_SpawnProjectile("NebRocketEnemy",44,18);
		"####" P 4 A_SpawnProjectile("NebRocketEnemy",44,-18);
		Goto See;
	Mortar:
		HIMM O 8 A_ArcProjectile("HimmlerMortar",40,28,0,CMF_SAVEPITCH,random(-30,-45));
		"####" N 6;
		Goto See;
	DropMine:
		"####" E 0 A_StartSound("grenade/bounce", CHAN_WEAPON);
		HIMM M 12 A_SpawnItemEx("BossEnemyPlacedMine", 32, 0, 0, random(20,80), 0, 0, 0, SXF_SETMASTER);
		"####" L 6;
		Goto See;
	Pain:
		HIMM I 6 A_NaziPain(256);
		Goto See;
	Raise:
		HIMM KJHE 5;
		Goto See;
	Death:
		HIMM I 5;
		"####" H 8 A_Scream;
		"####" J 10;
		"####" K -1 A_NoBlocking;
		Stop;
	}
}

class GoebbelsBoss : RocketMan
{	Default
	{
	//$Title Goebbels (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGGOEBBELS";
	Health 1200;
	PainChance 64;
	Mass 200;
	+LOOKALLAROUND
	Obituary "$GOEBELS";
	ActiveSound "goebbs/active";
	SeeSound "goebbs/sight";
	DeathSound "goebbs/die";
	DamageFactor "Electric", 0.7;
	DamageFactor "Fire", 0.2;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DropItem "FlameAmmo", 128;
	DropItem "NebAmmo", 64;
	MaxTargetRange 1024;
	}
	States
	{
	Spawn:
		GOEB A 0;
		Goto Look;
	Missile:
		GOEB E 10 A_FaceTarget;
		"####" E 0 A_Jump(128,"Missile2");
		"####" F 4 A_ArcProjectile("ClusterBomb",44,12);
		"####" E 6;
		Goto See;
	Missile2:
		GOEB F 1 A_ArcProjectile("HandGrenade",44,12,frandom(-4,4));
		"####" E 6;
		Goto See;
	Pain:
		GOEB H 6 A_NaziPain(256);
		Goto See;
	Raise:
		GOEB JIGH 5;
		Goto See;
	Death:
		GOEB H 5;
		"####" G 8 A_Scream;
		"####" I 10;
		"####" J -1 A_NoBlocking;
		Stop;
	}
}

class BattonBoss : RocketMan
{	Default
	{
	//$Title Berlin Feldmarschall with Batton (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGFELDMARSCHALL";
	Speed 4;
	Health 800;
	Obituary "$BATTBOSS";
	SeeSound "Boss1/Sighted";
	DeathSound "Boss1/Death";
	DropItem "FlameAmmo";
	DropItem "Pyrolight", 64;
	}
	States
	{
	Spawn:
		BATT A 0;
		Goto Look;
	See:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto See.BossFast;
	Missile:
		BATT E 10 A_FaceTarget;
		"####" E 0 A_JumpIfCloser(384,"ProperMissile");
		"####" F 4 A_SpawnProjectile("EnemyFlamebolt",44,14);
		"####" E 6;
		Goto See;
	ProperMissile:
		BATT FFFFF 1 A_SpawnProjectile("EnemyFlamerShot",44,14);
		"####" E 6 A_MonsterRefire(10,"See");
		Goto Missile;
	Pain:
		BATT H 6 A_NaziPain(256);
		Goto See;
	Death:
		BATT H 5;
		"####" G 0 A_SpawnItemEx("Debris_Batton", 12, 0, 32, random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" G 8 A_Scream;
		"####" I 10;
		"####" J -1 A_NoBlocking;
		Stop;
	Idle:
		BATT AAAAAA 1 A_Wander;
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

class MaskedBoss : RocketMan
{	Default
	{
	//$Title Masked (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGMASKED";
	Health 800;
	PainChance 8;
	Mass 200;
	+LOOKALLAROUND
	+MISSILEMORE
	Obituary "$MASKED";
	ActiveSound "masked/active"; //not present
	SeeSound "masked/sight"; //not present
	DeathSound "masked/die"; //not present
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DropItem "Ammo9mm", 128;
	DropItem "Ammo9mm", 128;
	DropItem "AmmoBox9mm", 128;
	DropItem "NebAmmo", 128;
	}
	States
	{
	Spawn:
		MASZ A 0;
		Goto Look;
	Missile:
		MASZ E 10 A_FaceTarget;
		"####" E 0 A_Jump(128,"Mortar","ZMortar");
	Chaingun:
		MASZ F 0 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" FF 0 A_SpawnProjectile("GoeringBall",54,30,random(-11,11));
		"####" FF 0 A_SpawnProjectile("GoeringBall",54,-30,random(-11,11));
		"####" F 0 {user_count2++; if(user_count2 > 47) {user_count2 = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" F 2 LIGHT("DEKNBFIR");
		"####" G 2 A_MonsterRefire(20,"See");
		Loop;
	Mortar:
		MASZ H 4 A_ArcProjectile("HimmlerMortar",72,30,0,CMF_SAVEPITCH,random(-45,-60));
		MASZ I 4 A_ArcProjectile("HimmlerMortar",75,-30,0,CMF_SAVEPITCH,random(-45,-60));
		"####" L 6;
		Goto See;
	ZMortar:
		MASZ J 4 A_ArcProjectile("ZMortar",72,30,0,CMF_SAVEPITCH,random(-45,-60));
		MASZ K 4 A_ArcProjectile("ZMortar",72,-30,0,CMF_SAVEPITCH,random(-45,-60));
		"####" L 6;
		Goto See;
	Retreat:
		MASZ A 0 A_SetSpeed(7);
		"####" A 0 {bFrightened = TRUE;}
		"####" A 0 {user_count2++; if(user_count > 47) {user_count = 0; return ResolveState("Retreat2");} return ResolveState(null);}
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_StartSound("hitler/walk");
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_StartSound("hitler/walk");
		"####" A 0 {bFrightened = FALSE;}
		"####" A 0 A_SetSpeed(3.5);
		Goto Missile;
	Retreat2:
		MASZ A 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat+3");} return ResolveState(null);}
		Goto Retreat+4;
	Pain:
		MASZ M 6 A_NaziPain(256);
		Goto See;
	Raise:
		MASZ PONM 5;
		Goto See;
	Death:
		MASZ M 5;
		"####" N 8 A_Scream;
		"####" O 10;
		"####" P -1 A_NoBlocking;
		Stop;
	}
}

class BattonBoss2 : BattonBoss
{	Default
	{
	//$Title Luftwaffe Pilot with Batton (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGLWPILOT";
	Speed 8; //very fast
	Health 700;
	Obituary "$NAVYBOSS";
	DropItem "FlameAmmo";
	DropItem "Pyrolight", 64;
	}
	States
	{
	Spawn:
		BNAV A 0;
		Goto Look;
	See:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto See.BossFast;
	Missile:
		BNAV E 10 A_FaceTarget;
		"####" E 0 A_JumpIfCloser(384,"ProperMissile");
		"####" F 4 A_SpawnProjectile("EnemyFlamebolt",44,14);
		"####" E 6;
		Goto See;
	ProperMissile:
		BNAV FFFFF 1 A_SpawnProjectile("EnemyFlamerShot",44,14);
		"####" E 6 A_MonsterRefire(10,"See");
		Goto Missile;
	Pain:
		BNAV H 6 A_NaziPain(256);
		Goto See;
	Death:
		BNAV H 5;
		"####" G 0 A_SpawnItemEx("Debris_Batton2", 12, 0, 32, random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" G 8 A_Scream;
		"####" I 10;
		"####" J -1 A_NoBlocking;
		Stop;
	Idle:
		BNAV AAAAAA 1 A_Wander;
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

class FlamerMan : RocketMan
{	Default
	{
	//$Title Friedhelm Hass (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGHASS";
	Speed 3.67;
	Health 700;
	Obituary "$FLAMEBOY";
	ActiveSound "fried/active";
	SeeSound "fried/sight";
	DeathSound "fried/die";
	DropItem "FlameAmmo";
	DropItem "Pyrolight", 64;
	}
	States
	{
	Spawn:
		FLAM A 0;
		Goto Look;
	See:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto See.Fast;
	Missile:
		FLAM E 10 A_FaceTarget;
		"####" E 0 A_JumpIfCloser(384,"ProperMissile");
		"####" F 4 A_SpawnProjectile("EnemyFlamebolt",44,12);
		"####" E 6;
		Goto See;
	ProperMissile:
		FLAM FFFFF 1 A_SpawnProjectile("EnemyFlamerShot",44,12);
		"####" E 6 A_MonsterRefire(10,"See");
		Goto Missile;
	Pain:
		FLAM G 6 A_NaziPain(256);
		Goto See;
	Death:
		FLAM G 5;
		"####" H 8 A_Scream;
		"####" I 10;
		"####" J -1 A_NoBlocking;
		Stop;
	Raise:
		FLAM JIHGE 5;
		Goto See;
	Idle:
		FLAM AAAAAA 1 A_Wander;
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

class MadDoctor : RocketMan
{	Default
	{
	//$Title Dr Schabbs Jr. (Boss)
	Base.BossIcon "BOSSICO1";
	Tag "$TAGSCHABBSJR";
	Health 400;
	Mass 4000;
	PainChance 64;
	Obituary "$SCHABBS1";
	ActiveSound "";
	SeeSound "fatman/sight"; //generic boss sounds
	DeathSound "fatman/death";
	DropItem "Medikit_Medium";
	}
	States
	{
	Spawn:
		SCHB A 0;
		Goto Look;
	Missile:
		SCHB E 10 A_FaceTarget;
		"####" E 0 A_Jump(255, "Missile1", "Missile2", "Missile3");
	Missile1:
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, 0, 0, random(30,50));
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" F 8 A_SpawnProjectile("FlyingNeedle",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" A 8;
		Goto See;
	Missile2:
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, 0, 0, random(30,50));
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, 0, 0, random(30,50));
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, 0, 0, random(30,50));
		"####" F 8 A_SpawnProjectile("FlyingNeedle",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" A 8;
		Goto See;
	Missile3:
		"####" F 0 A_SpawnProjectile("FlyingNeedleNoGrav",32,12, random(12,-12));
		"####" F 0 A_SpawnProjectile("FlyingNeedleNoGrav",32,12, random(12,-12));
		"####" F 8 A_SpawnProjectile("FlyingNeedleNoGrav",32,12, random(12,-12));
		"####" A 8;
		Goto See;
	Pain:
		"####" G 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" G 8;
		"####" H 12;
		"####" I 16 A_Scream;
		"####" J -1 A_NoBlocking;
		Stop;
	}
}

class MadDoctor2 : MadDoctor
{	Default
	{
	//$Title Dr Schabbs Sr. (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGSCHABBSSR";
	Health 600;
	+MISSILEEVENMORE
	Obituary "$SCHABBS2";
	SeeSound "schabbs/sight";
	ActiveSound "schabbs/active";
	DeathSound "schabbs/die";
	DropItem "Medikit_Medium";
	}
	States
	{
	Spawn:
		SCH2 A 0;
		Goto Look;
	Missile:
		SCH2 E 10 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("FlyingNeedle",32,12, 0, 0, random(30,50));
		"####" FF 0 A_SpawnProjectile("FlyingNeedle",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" F 8 A_SpawnProjectile("FlyingNeedle",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" A 8;
		Goto See;
	}
}

class MadDoctor3 : MadDoctor
{	Default
	{
	//$Title Dr. Mengele, Masked (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGMENGELE";
	Health 1600;
	PainChance 0;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	+MISSILEMORE
	-MISSILEEVENMORE
	Obituary "$MENGELE";
	DropItem "Medikit_Large";
	ActiveSound "mengele/active";
	SeeSound "mengele/sight";
	DeathSound "mengele/die";
	}
	States
	{
	Spawn:
		MENZ A 0;
		Goto Look;
	Missile:
		MENZ E 0 A_Jump(128, "Missile2", "Missile3");
	Missile1:
		MENZ E 10 A_FaceTarget;
		"####" FFF 0 A_SpawnProjectile("FlyingNeedleZ",32,12, 0, 0, random(30,50));
		"####" FFF 0 A_SpawnProjectile("FlyingNeedleZ",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" F 8 A_SpawnProjectile("FlyingNeedleZ",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" A 6 A_FaceTarget;
		Goto See;
	Missile2:
		MENZ GHIJK 12 A_FaceTarget;
		"####" L 8 A_SpawnProjectile("MengeleBomb",32,12, random(-64,64), 0, random(20,40));
		Goto See;
	Missile3:
		MENZ MN 12 A_FaceTarget;
		"####" O 1 A_FaceTarget;
		"####" P 0 A_SpawnProjectile("MengeleFireSpawner",16,0,32,0);
		"####" P 8 A_SpawnProjectile("MengeleFireSpawner",16,0,-32,0);
		"####" OPPO 4 A_FaceTarget;
		Goto See;
	Pain:
		"####" R 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" R 8;
		"####" Q 10;
		"####" S 12 A_Scream;
		"####" T 10 ;
		"####" U -1 A_NoBlocking;
		Stop;
	}
}

class MadDoctor3B : MadDoctor3 //unused
{	Default
	{
	//$Title Dr. Mengele, On Duty (Boss)
	}
	States
	{
	Spawn:
		MENG A 0;
		Goto Look;
	Missile:
		MENG E 0 A_Jump(128, "Missile2", "Missile3");
	Missile1:
		MENG E 10 A_FaceTarget;
		"####" FFF 0 A_SpawnProjectile("FlyingNeedleZ",32,12, 0, 0, random(30,50));
		"####" FFF 0 A_SpawnProjectile("FlyingNeedleZ",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" F 8 A_SpawnProjectile("FlyingNeedleZ",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" A 6 A_FaceTarget;
		Goto See;
	Missile2:
		MENG GHIJK 12 A_FaceTarget;
		"####" L 8 A_SpawnProjectile("MengeleBomb",32,12, random(-64,64), 0, random(20,40));
		Goto See;
	Missile3:
		MENG MN 12 A_FaceTarget;
		"####" O 1 A_FaceTarget;
		"####" P 0 A_SpawnProjectile("MengeleFireSpawner",16,0,32,0);
		"####" P 8 A_SpawnProjectile("MengeleFireSpawner",16,0,-32,0);
		"####" OPPO 4 A_FaceTarget;
		Goto See;
	Pain:
		MENG R 6 A_NaziPain(256);
		Goto See;
	Death:
		MENG R 8;
		"####" Q 10;
		"####" S 12 A_Scream;
		"####" T 10 ;
		"####" U -1 A_NoBlocking;
		Stop;
	}
}

class MadDoctor4 : MadDoctor
{	Default
	{
	//$Title Dr Morell (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGMORELL";
	Health 900;
	+MISSILEEVENMORE
	Obituary "$MORELL";
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DamageFactor "Poison", 0;
	DropItem "Medikit_Large";
	DropItem "AdrenalineKit";
	ActiveSound "morell/active";
	SeeSound "morell/sight";
	DeathSound "morell/die";
	}
	States
	{
	Spawn:
		MRLL A 0;
		Goto Look;
	Missile:
		MRLL E 0 A_Jump(128,"Missile2");
		"####" E 10 A_FaceTarget;
		"####" FFF 0 A_SpawnProjectile("FlyingNeedleZ",32,12, 0, 0, random(30,50));
		"####" FFF 0 A_SpawnProjectile("FlyingNeedleZ",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" F 8 A_SpawnProjectile("FlyingNeedleZ",32,12, random(-20,20), CMF_AIMDIRECTION|CMF_BADPITCH, random(20,40));
		"####" A 6;
		Goto See;
	Missile2:
		MRLL E 0 A_Jump(128,"Missile3");
		"####" G 10 A_FaceTarget;
		"####" HH 2 A_ArcProjectile("FlyingHack",32,-12,random(-8,8));
		"####" H 3 A_ArcProjectile("FlyingHack",32,-12);
		"####" C 8;
		Goto See;
	Missile3:
		"####" E 5 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("FlyingNeedleZNoGrav",32,12, random(12,-12));
		"####" F 0 A_SpawnProjectile("FlyingNeedleZNoGrav",32,12, random(12,-12));
		"####" F 4 A_SpawnProjectile("FlyingNeedleZNoGrav",32,12, random(12,-12));
		"####" A 8;
		Goto See;
	Pain:
		"####" J 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" J 8;
		"####" I 10;
		"####" K 12 A_Scream;
		"####" L 10;
		"####" M -1 A_NoBlocking;
		Stop;
	}
}

class MadCook : MadDoctor
{	Default
	{
	//$Title Cook Fritz Bratwurst (Boss)
	Obituary "$MADCOOK";
	Tag "$TAGBRATWURST";
	Health 400;
	Speed 5;
	+AVOIDMELEE
	+MISSILEMORE
	ActiveSound "";
	SeeSound "Boss2/Sighted";
	PainSound "boss/pain";
	DeathSound "Boss2/Death";
	}
	States
	{
	Spawn:
		COOK A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		COOK E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadCook2 : MadCook
{	Default
	{
	//$Title Cook Max Gulasch (Boss)
	Tag "$TAGGULASCH";
	}
	States
	{
	Spawn:
		COOG A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		COOG E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadCook3 : MadCook
{	Default
	{
	//$Title Cook AFADoomer (Boss)
	Tag "$TAGAFADOOM";
	}
	States
	{
	Spawn:
		AFAB A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		AFAB E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadCook4 : MadCook
{	Default
	{
	//$Title Cook DoomJedi (Boss)
	Tag "$TAGDOOMJEDI";
	}
	States
	{
	Spawn:
		DJED A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		DJED E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadCook5 : MadCook
{	Default
	{
	//$Title Cook DoomJuan (Boss)
	Tag "$TAGDOOMJUAN";
	}
	States
	{
	Spawn:
		DMJN A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		DMJN E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadCook6 : MadCook
{	Default
	{
	//$Title Cook Ozymandias81 (Boss)
	Tag "$TAGOZYMAN";
	}
	States
	{
	Spawn:
		OZYM A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		OZYM E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadCook7 : MadCook
{	Default
	{
	//$Title Cook Tormentor667 (Boss)
	Tag "$TAGTORM667";
	}
	States
	{
	Spawn:
		TORM A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		TORM E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadCook8 : MadCook
{	Default
	{
	//$Title Cook Komuto Kherovato (Boss)
	SeeSound "Komuto/Sighted";
	PainSound "Komuto/Pain";
	DeathSound "Komuto/Death";
	DropItem "AstroMedikit";
	Tag "$TAGKOMUTO";
	}
	States
	{
	Spawn:
		KOMU A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	Pain:
		"####" K 6 A_NaziPain(256);
		Goto See;
	Missile:
		KOMU E 10 A_FaceTarget;
		"####" FF 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" F 3 A_ArcProjectile("FlyingHack",32,12);
		"####" A 8;
		Goto See;
	}
}

class MadButcher : MadDoctor
{	Default
	{
	//$Title Mad Butcher (Boss)
	Tag "$TAGMADBUTCHER";
	Health 550;
	Obituary "$BUTCHER";
	DropItem "Medikit_Medium";
	}
	States
	{
	Spawn:
		BTCN A 0;
		Goto Look;
	Missile:
		BTCN E 6 A_FaceTarget;
		"####" E 0 A_Jump(128, "Missile2", "Missile3");
		"####" F 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" C 8;
		Goto See;
	Missile2:
		"####" F 2 A_ArcProjectile("FlyingHack",32,12,random(-2,2));
		"####" E 4 A_FaceTarget;
		"####" F 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" C 8;
		Goto See;
	Missile3:
		"####" F 2 A_ArcProjectile("FlyingHack",32,12,random(-2,2));
		"####" E 4 A_FaceTarget;
		"####" F 2 A_ArcProjectile("FlyingHack",32,12,random(-8,8));
		"####" E 4 A_FaceTarget;
		"####" F 2 A_ArcProjectile("FlyingHack",32,12,random(-12,12));
		"####" C 8;
		Goto See;
	Pain:
		"####" G 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" G 8;
		"####" H 12;
		"####" I 16 A_Scream;
		"####" J -1 A_NoBlocking;
		Stop;
	}
}

class General : RocketMan
{	Default
	{
	//$Title General Fettgesicht (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGFETTGESICHT";
	Obituary "$BGENERAL";
	Health 800;
	Mass 1000;
	+MISSILEEVENMORE
	Nazi.ZombieVariant "ZombieGeneral";
	ActiveSound "fettges/active";
	SeeSound "fettges/sight";
	DeathSound "fettges/die";
	DropItem "NebAmmo", 128;
	DropItem "NebAmmo", 128;
	DropItem "NebAmmo", 128;
	}
	States
	{
	Spawn:
		FETT A 0;
		Goto Look;
	Missile:
		FETT E 10 A_FaceTarget;
		"####" E 0 A_Jump(128,"ChainGun");
		"####" F 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8;
		Goto See;
	ChainGun:
		FETT H 0 A_FaceTarget;
		"####" H 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" H 2 A_SpawnProjectile("EnemyChaingunTracer",40,-20,random(-11,11));
		"####" G 0 A_SpawnItemEx("Casing9mm", -12,0,36, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_MonsterRefire(10,"See");
		Loop;
	Pain:
		FETT I 6 A_NaziPain(256);
		Goto See;
	Death:
		FETT J 5;
		"####" K 8 A_Scream;
		"####" L 10;
		"####" M -1 A_NoBlocking;
		Stop;
	Raise:
		FETT MLKJ 5;
		Goto See;
	}
}

class BerlinGeneral1 : General
{	Default
	{
	//$Title Berlin Officer, Rockets (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGFELDMARSCHALL";
	Health 600;
	Mass 1000;
	+MISSILEEVENMORE
	Obituary "$BERLING";
	SeeSound "Boss3/Sighted";
	DeathSound "Boss3/Death";
	DropItem "NebAmmo", 128;
	}
	States
	{
	Spawn:
		BOFF A 0;
		Goto Look;
	Missile:
		BOFF E 10 A_FaceTarget;
		"####" F 0 A_Jump(32,"Missile2");
		"####" F 4 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 4 A_FaceTarget;
		"####" F 4 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8;
		Goto See;
	Missile:
		BOFF F 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 8;
		Goto See;
	Pain:
		BOFF H 6 A_NaziPain(256);
		Goto See;
	Death:
		BOFF H 5;
		"####" G 8 A_Scream;
		"####" I 10;
		"####" J -1 A_NoBlocking;
		Stop;
	Raise:
		BOFF MLKJ 5;
		Goto See;
	}
}

class BerlinGeneral2 : BerlinGeneral1
{	Default
	{
		//$Title Berlin Officer, Chaingun (Boss)
		DropItem "AmmoBox9mm", 128;
	}
	States
	{
	Spawn:
		BOF2 A 0;
		Goto Look;
	Missile:
		BOF2 E 4 A_FaceTarget;
		"####" E 0 A_Jump(64,"Missile2");
		"####" E 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 2 A_SpawnProjectile("EnemyChaingunTracer",43,24,random(-3,3));
		"####" E 0 A_SpawnItemEx("Casing9mm", 20,0,40, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("See");} return ResolveState(null);}
		"####" E 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" G 2 A_SpawnProjectile("EnemyChaingunTracer",43,24,random(-6,6));
		"####" E 0 A_SpawnItemEx("Casing9mm", 20,0,40, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("See");} return ResolveState(null);}
		"####" E 2 A_MonsterRefire(10,"See");
		Loop;
	Missile2:
		BOF2 E 0 A_FaceTarget;
		"####" E 0 A_Jump(64,"Missile2");
		"####" E 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 2 A_SpawnProjectile("EnemyChaingunTracer",43,24,random(-3,3));
		"####" E 0 A_SpawnItemEx("Casing9mm", 20,0,40, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("See");} return ResolveState(null);}
		"####" E 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" G 2 A_SpawnProjectile("EnemyChaingunTracer",43,24,random(-6,6));
		"####" E 0 A_SpawnItemEx("Casing9mm", 20,0,40, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("See");} return ResolveState(null);}
		"####" E 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 2 A_SpawnProjectile("EnemyChaingunTracer",43,24,random(-9,9));
		"####" E 0 A_SpawnItemEx("Casing9mm", 20,0,40, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("See");} return ResolveState(null);}
		"####" E 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" G 2 A_SpawnProjectile("EnemyChaingunTracer",43,24,random(-12,12));
		"####" E 0 A_SpawnItemEx("Casing9mm", 20,0,40, random(-3,-4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("See");} return ResolveState(null);}
		"####" E 2 A_MonsterRefire(10,"See");
		Loop;
	Pain:
		BOF2 I 6 A_NaziPain(256);
		Goto See;
	Death:
		BOF2 I 5;
		"####" H 8 A_Scream;
		"####" J 10;
		"####" K -1 A_NoBlocking;
		Stop;
	Raise:
		BOF2 KJHIE 5;
		Goto See;
	}
}

class MarineGeneral : General
{	Default
	{
	//$Title General Seeteufel (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGSEETEUFEL";
	Health 800;
	Mass 1000;
	+MISSILEEVENMORE
	Obituary "$GENERAL";
	ActiveSound "seeteuf/active";
	SeeSound "seeteuf/sight";
	DeathSound "seeteuf/die";
	DropItem "NebAmmo", 128;
	DropItem "NebAmmo", 128;
	DropItem "NebAmmo", 128;
	Nazi.ZombieVariant ""; // Needed because he inherits from Fettgesicht
	}
	States
	{
	Spawn:
		SEET A 0;
		Goto Look;
	Missile:
		SEET J 10 A_FaceTarget;
		"####" K 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" J 8 A_FaceTarget;
		"####" K 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" J 8 A_FaceTarget;
		"####" K 8 A_SpawnProjectile("MiniRocket",43,24);
		"####" J 8;
		Goto See;
	Pain:
		SEET L 6 A_NaziPain(256);
		Goto See;
	Death:
		SEET L 5;
		"####" M 8 A_Scream;
		"####" N 10;
		"####" O -1 A_NoBlocking;
		Stop;
	Raise:
		SEET ONML 5;
		Goto See;
	}
}

class AirshipGeneral : MarineGeneral
{	Default
	{
	//$Title General Eisenhimmel (Boss)
	Tag "$TAGEISENHIMMEL";
	ActiveSound "eisen/active";
	SeeSound "eisen/sight";
	DeathSound "eisen/die";
	}
}

class RommelBoss : General
{	Default
	{
	//$Title Rommel (Boss)
	Base.BossIcon "BOSSICO1";
	Tag "$TAGROMMEL";
	Health 1600;
	Mass 1000;
	Speed 10;
	+MISSILEEVENMORE
	Obituary "$ROMMEL";
	SeeSound "Boss3/Sighted";
	DeathSound "Boss3/Death";
	DropItem "NebAmmoBox", 128;
	DropItem "NazisBackpack", 96;
	}
	States
	{
	Spawn:
		ROMM A 0;
		Goto Look;
	Missile:
		ROMM E 6 A_FaceTarget;
		"####" F 0 A_Jump(32,"Missile2");
		"####" F 3 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 2 A_FaceTarget;
		"####" F 3 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 5;
		Goto See;
	Missile:
		ROMM F 5 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 5 A_FaceTarget;
		"####" F 5 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 5 A_FaceTarget;
		"####" F 5 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 5 A_FaceTarget;
		"####" F 5 A_SpawnProjectile("MiniRocket",43,24);
		"####" E 5;
		Goto See;
	Pain:
		ROMM H 6 A_NaziPain(256);
		Goto See;
	Death:
		ROMM H 5;
		"####" G 8 A_Scream;
		"####" I 10;
		"####" J -1 A_NoBlocking;
		Stop;
	Raise:
		ROMM MLKJ 5;
		Goto See;
	}
}

class Totengraber_Healthy : RocketMan
{	Default
	{
	//$Title Totengraber, healthy (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGTOTENGRAEBER";
	Health 1000;
	DamageFactor "Poison", 0;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	PainChance 16;
	+MISSILEMORE
	Obituary "$TOTENS";
	ActiveSound "toten/active";
	SeeSound "toten/sight";
	DeathSound "hitlerghost/die"; //laughs
	}
	States
	{
	Spawn:
		TOTH A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.Boss;
	Missile:
		"####" E 0 A_Jump(128, "Missile2");
		"####" E 10 A_FaceTarget;
		"####" F 6 LIGHT("TOTHFIRE") A_ArcProjectile("ZyklonBBomb",40,22,random(-10,10), 0, random(-1,-20));
		"####" E 6 A_FaceTarget;
		"####" F 6 LIGHT("TOTHFIRE") A_ArcProjectile("ZyklonBBomb",40,22,random(-10,10), 0, random(-1,-20));
		Goto See;
	Missile2:
		"####" E 10 A_FaceTarget;
		"####" G 2 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-16,16));
		"####" E 2;
		"####" G 2 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-16,16));
		"####" E 2;
		"####" G 2 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-16,16));
		"####" E 2;
		"####" G 2 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-16,16));
		"####" E 2;
		Goto See;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" A 10 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AAAA 0 A_SpawnItemEx("PowerPlantSmokePuff", random(-8,8), random(-8,8), random(0,16), random(0,1), random(0,1), random(1,3));
		"####" AAAAAAAAAA 5 A_Fadeout(0.1); //laughs
		Stop;
	Idle:
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class Totengraber_Wounded : RocketMan
{	Default
	{
	//$Title Totengraber, wounded (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGTOTENGRAEBER";
	Health 1000;
	PainChance 16;
	+MISSILEMORE
	DamageFactor "Poison", 0;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	Obituary "$TOTENS";
	ActiveSound "toten/active";
	SeeSound "toten/sight";
	DeathSound "toten/die";
	Nazi.Healer 2; //HLR_ZOMBIES value as defined in ZScript, not sure why the enum isn't recognized in Decorate...
	Nazi.HealSound "creepy/born";
	}
	States
	{
	Spawn:
		TOTW A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.BossBleeding;
	Heal:
		"####" E 6 A_SpawnAtGoal("CreepyRaiseFlat", random(10,-10), random(10,-10), 0, 0, 0, 0, 0);
		"####" E 0 A_HealGoal;
		Goto See;
	Missile:
		"####" E 0 A_Jump(128, "Missile2");
		"####" E 10 A_FaceTarget;
		"####" EEE 0 A_SpawnItemEx("SkullBloodDrip",8,random(-4,-8),56,0,0,0,0,0);
		"####" FF 0 LIGHT("TOTHFIRE") A_SpawnProjectile("ZyklonBBomb",40,22,random(-30,30), CMF_AIMDIRECTION, random(-1,-40));
		"####" F 6 LIGHT("TOTHFIRE") A_SpawnProjectile("ZyklonBBomb",40,22,0,random(-30,30), CMF_AIMDIRECTION, random(-1,-40));
		Goto See;
	Missile2:
		"####" E 10 A_FaceTarget;
		"####" EEE 0 A_SpawnItemEx("SkullBloodDrip",8,random(-4,-8),56,0,0,0,0,0);
		"####" G 3 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-32,32));
		"####" E 2;
		"####" G 2 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-32,32));
		"####" E 2;
		"####" G 4 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-32,32));
		"####" E 2;
		"####" EEE 0 A_SpawnItemEx("SkullBloodDrip",8,random(-4,-8),56,0,0,0,0,0);
		"####" G 6 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-32,32));
		"####" E 2;
		"####" G 3 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-32,32));
		"####" E 2;
		"####" G 2 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-14,random(-32,32));
		"####" E 2;
		Goto See;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" H 5;
		"####" I 8 A_Scream;
		TOTH J 10;
		"####" K 0 A_NoBlocking;
		"####" K -1 A_BossDeath;
		Stop;
	Raise:
		TOTW KJIH 5;
		Goto See;
	Idle:
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class Mengele_Healthy : RocketMan
{
	Default
	{
	//$Title Dr. Mengele, healthy (Boss)
	Base.BossIcon "BOSSICO2";
	Base.NoFear;
	Tag "$TAGMENGELE";
	Health 1000;
	Speed 4;
	DamageFactor "Poison", 0;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	PainChance 16;
	+MISSILEMORE
	Obituary "$MENGELE";
	ActiveSound "mengele/active";
	SeeSound "mengele/sight";
	PainSound "mengele/pain";
	DeathSound "hitlerghost/die";
	}
	States
	{
	Spawn:
		MNG1 A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.Boss;
	Missile:
		"####" E 0 A_Jump(128, "Missile2");
		"####" E 10 A_FaceTarget;
		"####" "#" 0 A_Jump(128, 2);
		"####" F 6 LIGHT("TOTHFIRE") A_ArcProjectile("ZyklonBBomb",40,22,random(-10,10), 0, random(-1,-20));
		Goto See;
		"####" L 6 LIGHT("TOTHFIRE") A_ArcProjectile("ZyklonBBomb",40,-22,random(-10,10), 0, random(-1,-20));
		Goto See;
	Missile2:
		"####" E 10 A_FaceTarget;
		"####" F 4 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,22,random(-16,16));
		"####" E 4;
		"####" L 4 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-22,random(-16,16));
		Goto See;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" A 10 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AAAA 0 A_SpawnItemEx("PowerPlantSmokePuff", random(-8,8), random(-8,8), random(0,16), random(0,1), random(0,1), random(1,3));
		"####" AAAAAAAAAA 5 A_Fadeout(0.1); //laughs
		Stop;
	Idle:
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class Mengele_Wounded : RocketMan
{	Default
	{
	//$Title Dr. Mengele, wounded (Boss)
	Base.BossIcon "BOSSICO2";
	Base.NoFear;
	Tag "$TAGMENGELE";
	Health 1000;
	Speed 3;
	PainChance 16;
	+MISSILEMORE
	DamageFactor "Poison", 0;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	Obituary "$MENGELE";
	Nazi.Healer 2;
	Nazi.HealSound "creepy/born";
	ActiveSound "mengele/active"; //maybe creepier?
	SeeSound "mengele/sight"; //maybe creepier?
	PainSound "mengele/pain"; //maybe creepier?
	DeathSound "mengele/die"; //maybe creepier?
	}
	States
	{
	Spawn:
		MNG2 A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.BossBleeding;
	Heal:
		"####" E 6 A_SpawnAtGoal("CreepyRaiseFlat", random(10,-10), random(10,-10), 0, 0, 0, 0, 0);
		"####" E 0 A_HealGoal;
		Goto See;
	Missile:
		"####" E 0 A_Jump(128, "Missile2");
		"####" E 10 A_FaceTarget;
		"####" EEE 0 A_SpawnItemEx("SkullBloodDrip",8,random(-4,-8),56,0,0,0,0,0);
		"####" L 3 LIGHT("TOTHFIRE") A_SpawnProjectile("ZyklonBBomb",40,-22,random(-30,30), CMF_AIMDIRECTION, random(-1,-40));
		"####" F 3 LIGHT("TOTHFIRE") A_SpawnProjectile("ZyklonBBomb",40,22,0,random(-30,30), CMF_AIMDIRECTION, random(-1,-40));
		Goto See;
	Missile2:
		"####" E 10 A_FaceTarget;
		"####" EEE 0 A_SpawnItemEx("SkullBloodDrip",8,random(-4,-8),56,0,0,0,0,0);
		"####" F 6 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,22,random(-32,32));
		"####" E 5;
		"####" L 6 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-22,random(-32,32));
		"####" E 5;
		"####" F 6 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,22,random(-32,32));
		"####" E 5;
		"####" EEE 0 A_SpawnItemEx("SkullBloodDrip",8,random(-4,-8),56,0,0,0,0,0);
		"####" L 6 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-22,random(-32,32));
		"####" E 5;
		"####" F 6 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,22,random(-32,32));
		"####" E 5;
		"####" L 6 LIGHT("TOT2FIRE") A_SpawnProjectile("ZyklonBBall",40,-22,random(-32,32));
		"####" E 2;
		Goto See;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" H 5;
		"####" G 8 A_Scream;
		"####" I 12;
		"####" J 16;
		"####" K 0 A_NoBlocking;
		"####" K -1 A_BossDeath;
		Stop;
	Raise:
		MNG2 KJIGH 5;
		Goto See;
	Idle:
		"####" AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class DeathKnight : Nazi
{	Default
	{
	//$Category Monsters (BoA)/Bosses
	//$Title Todesritter (Boss)
	//$Color 4
	Tag "$TAGTODESRITTER";
	Health 3000;
	Radius 64;
	Height 96;
	Mass 1000;
	Speed 3.5;
	Scale 0.75;
	PainChance 20;
	DamageFactor "Rocket", 0.2;
	+BOSS
	+LOOKALLAROUND
	+MISSILEEVENMORE
	+NORADIUSDMG
	Obituary "$DKNIGHT";
	SeeSound "deathknight/sight";
	PainSound "boss/pain";
	DeathSound "deathknight/death";
	DropItem "Ammo9mm", 128;
	DropItem "Ammo9mm", 128;
	DropItem "AmmoBox9mm", 128;
	DropItem "NebAmmo", 256;
	Nazi.TotaleGierDrop 3;
	}
	States
	{
	Spawn:
		DKGT A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		"####" A 1 A_NaziChase;
		"####" AAA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_NaziChase;
		"####" AAA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BBB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BBB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_StartSound("hitler/walk");
		"####" C 1 A_NaziChase;
		"####" CCC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CCC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_NaziChase;
		"####" DDD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_NaziChase;
		"####" DDD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_StartSound("hitler/walk");
		Loop;
	Missile:
		DKGT E 10 A_FaceTarget;
		"####" E 0 A_Jump(40,"AlphaStrike");
		"####" E 0 A_Jump(128,"Chaingun");
		"####" F 3 LIGHT("OTTOFIRE") A_SpawnProjectile("NebRocketEnemy",80,24);
		"####" F 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 3 A_MonsterRefire(10,"See");
		"####" G 3 LIGHT("OTT2FIRE") A_SpawnProjectile("NebRocketEnemy",80,-24);
		"####" G 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 3 A_MonsterRefire(20,"See");
		"####" F 3 LIGHT("OTTOFIRE") A_SpawnProjectile("NebRocketEnemy",80,24);
		"####" F 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 3 A_MonsterRefire(30,"See");
		"####" G 3 LIGHT("OTT2FIRE") A_SpawnProjectile("NebRocketEnemy",80,-24);
		"####" G 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 3;
		Goto See;
	Chaingun:
		DKGT I 0 A_FaceTarget;
		"####" I 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" II 0 A_SpawnProjectile("EnemyChaingunTracer",54,30,random(-11,11));
		"####" II 0 A_SpawnProjectile("EnemyChaingunTracer",54,-30,random(-11,11));
		"####" II 0 A_SpawnItemEx("Casing9mm", 32,0,58, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" II 0 A_SpawnItemEx("Casing9mm", 32,0,58, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" I 0 {user_count2++; if(user_count2 > 47) {user_count2 = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" I 2 LIGHT("DEKNBFIR");
		"####" H 2 A_MonsterRefire(20,"See");
		Loop;
	AlphaStrike:
		DKGT K 0 A_FaceTarget;
		"####" K 0 A_SpawnProjectile("NebRocketEnemy",80,24);
		"####" K 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" K 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" KK 0 A_SpawnProjectile("EnemyChaingunTracer",54,30,random(-11,11));
		"####" KK 0 A_SpawnProjectile("EnemyChaingunTracer",54,-30,random(-11,11));
		"####" KK 0 A_SpawnItemEx("Casing9mm", 32,0,58, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" KK 0 A_SpawnItemEx("Casing9mm", 32,0,58, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" K 0 {user_count2++; if(user_count2 > 47) {user_count2 = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" K 2 LIGHT("DEKNBFIR");
		"####" L 0 A_SpawnProjectile("NebRocketEnemy",80,-24);
		"####" K 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" L 8 A_MonsterRefire(15,"See");
		Loop;
	Retreat:
		DKGT A 0 A_SetSpeed(7);
		"####" A 0 {bFrightened = TRUE;}
		"####" A 0 {user_count2++; if(user_count > 47) {user_count = 0; return ResolveState("Retreat2");} return ResolveState(null);}
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_Chase;
		"####" AAA 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_StartSound("hitler/walk");
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_StartSound("hitler/walk");
		"####" A 0 {bFrightened = FALSE;}
		"####" A 0 A_SetSpeed(3.5);
		Goto Missile;
	Retreat2:
		DKGT A 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Retreat+3");} return ResolveState(null);}
		Goto Retreat+4;
	Pain:
		DKGT M 6 A_NaziPain(256);
		Goto See;
	Death:
		DKGT M 5 A_Scream;
		"####" NOP 12;
		"####" Q 10 A_NoBlocking;
		"####" R 8;
		"####" S -1;
		Stop;
	Idle:
		Stop;
	}
}

class Longinus_Hitler : NaziBoss
{
	double user_rumbleoffset;
	int user_count5;
	int user_count6;
	Default
	{
		//$Category Monsters (BoA)/Bosses
		//$Title Adolf Hitler, Longinus (Boss)
		//$Color 4
		Base.BossIcon "BOSSICO3";
		Tag "$TAGHITLER";
		Health 100000;
		WoundHealth 50000;
		Mass 16000;
		Painchance 16;
		Radius 64;
		Height 192;
		Speed 2.5;
		Scale 2.0;
		-NODAMAGE //for ReflectiveOrb
		+ALLOWPAIN
		+INVULNERABLE
		+NOFEAR
		+MISSILEMORE //these two added by N00b
		+MISSILEEVENMORE
		PainChance 0; // No pain reaction, except for Occult Fire attacks.
		PainChance "OccultFire", 8; //changed from 24, else you could stun him with repeated alternative attacks --N00b
		DamageFactor "Rocket", 0.0;
		DamageFactor "OccultFire", 5.0;
		Obituary "$LHITLER";
		SeeSound "hitler/sight";
		PainSound "hitler/pain";
		DeathSound "hitler/death";
		ActiveSound "hitler/active";
		DropItem "SpearOfDestiny_End", 256;
		Nazi.Healer 2;
		Nazi.HealSound "creepy/born";
		Nazi.HealDistance 256;
		Alpha 0.0;
	}
	States
	{
	Appear:
		SHI1 A 0 A_StartSound("hitlerghost/die", CHAN_AUTO, 0, 1.0);
		"####" A -1;
		Stop;
	Spawn:
		SHI1 A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		Goto See.BossGiant;
	Wound:
		"####" KLM 3;
	Wounded: // Set/define the 'wounded' state sprite here!  NaziBoss class will automatically force the enemy to use this base sprite when 'wounded' is set to true!
		SHI2 "#" 0 {
			A_SpawnItemEx("HitlerChaingun", random(8,-8), random(8,-8), random(54,64), random(1,6), random(1,6), random(1,6), random(0,360), SXF_NOCHECKPOSITION);
			WoundHealth = 0; // Reset the WoundHealth to zero so that this block will only get activated when he's initially wounded
			wounded = true; // Set to true so that NaziBoss code will force the new sprite from here on
			bNoPain = true; } // now he is enraged and does not feel pain
		Goto See;
	Heal:
		"####" E 1 {bNoDamage = FALSE; A_UnsetReflective(); } //force Invulnerability removal - Ozy81
		"####" E 17 A_SpawnAtGoal("CreepyRaiseFlat", random(10,-10), random(10,-10), 0, 0, 0, 0, 0);
		"####" S 18 A_HealGoal;
		Goto See;
	Missile: // Phase 1: 2 attacks (Chaingun/RumbleStomp) + Tesla for close range
		"####" "#" 0 A_JumpIfCloser(radius + 256, "TeslaMissile");
		"####" "#" 0 A_JumpIf(wounded,"Missile.Wounded");
		"####" E 0 A_Jump(128,"RumbleStomp");
		Goto Chaingun;
	Missile.Wounded: // Phase 2: 4 attacks (RumbleStomp/ZyklonGrenade/PushAway/ReflectiveOrb) + Tesla for close range (processed before)
		"####" E 0 A_Jump(192,"RumbleStomp","ZyklonGrenade","PushAway");
		Goto ReflectiveOrb;
	Chaingun:
		"####" E 6 A_StartSound("chaingun/start", CHAN_AUTO);
		"####" E 0 A_StartSound("chaingun/loop", CHAN_AUTO);
	Chaingun.Loop:
		"####" FF 2 LIGHT("HAIL3FIR") A_SpawnProjectile("EnemyChaingunTracer2",102,-56,random(-11,11));
		"####" FF 0 A_SpawnItemEx("Casing9mm2", 102,0,-72, random(3,4), random(-1,1), random(4,6), random(110,160),SXF_NOCHECKPOSITION);
		"####" I 0 {user_count2++; if(user_count2 > 5) {user_count2 = 0; return ResolveState("See");} return ResolveState(null);}
		"####" GG 2 LIGHT("HAIL3FIR") A_SpawnProjectile("EnemyChaingunTracer2",102,-56,random(-11,11));
		"####" GG 0 A_SpawnItemEx("Casing9mm2", 102,0,-72, random(3,4), random(-1,1), random(4,6), random(110,160),SXF_NOCHECKPOSITION);
		"####" I 0 {user_count2++; if(user_count2 > 5) {user_count2 = 0; return ResolveState("See");} return ResolveState(null);}
		"####" I 0 {user_count3++; if(user_count3 > 5) {return ResolveState("See");} return ResolveState(null);} //limit continuous refire
		"####" G 2 A_MonsterRefire(20,"See");
		Goto Chaingun;
	
	//zombie reinforcements, tests multitasking skills and reaction (stop firing projectiles immediately)
	ReflectiveOrb:
		"####" S 0 {user_count4++; if(user_count4 > 1) {return ResolveState("RumbleStomp");} return ResolveState(null);} //limit changed to 1 --N00b
		"####" S 1 {user_count4 = 0; user_count5 = 0; user_count6 = 0; bNoDamage = TRUE; A_SetReflective();}
		"####" S 1 A_SpawnItemEx("ReflectiveOrb",0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
		"####" S 1 A_SetTics(35*3);
		"####" S 1 {bNoDamage = FALSE; A_UnsetReflective(); }
		Goto See;
		
	//also tests the player's multitasking and dodging skills
	//this is the default attack which can be spammed indefinitely
	RumbleStomp:
		"####" C 1 {bNoDamage = FALSE; A_UnsetReflective();} //force Invulnerability removal - Ozy81
		"####" C 6;
		"####" E 0 { user_count4 = 0; user_count5 = 0; user_count6 = 0; A_FaceTarget(); }
		"####" E 4;
		"####" H 8 LIGHT("ZYKOFIR2");
		"####" H 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" H 1 Radius_Quake(10,10,0,16,0);
		"####" E 12
		{
			user_rumbleoffset = frandom(0.0, 360.0);
			for (user_count = 0; user_count < 8; user_count++)
			{
				A_SpawnProjectile("RumbleWaves",0,0,user_rumbleoffset+user_count*45.0,CMF_CHECKTARGETDEAD);
			}
		}
		"####" C 6;
		"####" E 0 A_FaceTarget;
		"####" E 4;
		"####" H 8 LIGHT("ZYKOFIR2");
		"####" H 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" H 1 Radius_Quake(10,10,0,16,0);
		"####" E 12
		{
			user_rumbleoffset = frandom(0.0, 360.0);
			for (user_count = 0; user_count < 8; user_count++)
			{
				A_SpawnProjectile("RumbleWaves",0,0,user_rumbleoffset+user_count*45.0,CMF_CHECKTARGETDEAD);
			}
		}
		"####" C 6;
		"####" E 0 A_FaceTarget;
		"####" E 4;
		"####" H 8 LIGHT("ZYKOFIR2");
		"####" H 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" H 1 Radius_Quake(10,10,0,16,0);
		"####" E 12
		{
			user_rumbleoffset = frandom(0.0, 360.0);
			for (user_count = 0; user_count < 8; user_count++)
			{
				A_SpawnProjectile("RumbleWaves",0,0,user_rumbleoffset+user_count*45.0,CMF_CHECKTARGETDEAD);
			}
		}
		"####" C 4;
		Goto See;
	
	//instant area denial attack, prevent player from standing at one place (e. g. soul fountain) for too long
	ZyklonGrenade:
		"####" C 2 {user_count5++; if(user_count5 > 1) {return ResolveState("RumbleStomp");} return ResolveState(null);} //change attack type
		"####" C 6 {user_count4 = 0; user_count6 = 0; bNoDamage = FALSE; A_UnsetReflective();} //also needed here... --N00b
		"####" E 8 A_FaceTarget;
		"####" T 16 A_FaceTarget;
		"####" V 14 A_FaceTarget;
		"####" W 10 {
			A_StartSound("grenade/throw");
			A_ArcProjectile("ZyklonGrenadePacket",50,16,frandom(-30.0,30.0),CMF_CHECKTARGETDEAD);
			A_ArcProjectile("ZyklonGrenadePacket",50,16,frandom(-30.0,30.0),CMF_CHECKTARGETDEAD);
			A_ArcProjectile("ZyklonGrenadePacket",50,16,frandom(-30.0,30.0),CMF_CHECKTARGETDEAD);
			A_ArcProjectile("ZyklonGrenadePacket",50,16,frandom(-30.0,30.0),CMF_CHECKTARGETDEAD);
		}
		"####" U 10;
		"####" C 6;
		Goto See;
	
	//quick attack, deals zero damage but thrusts the player away (so they can fall from the arena)
	//prevents the player from sniping at Hitler from a large distance (close to the arena boundary)
	PushAway:
		"####" C 2 {user_count6++; if(user_count6 > 1) {return ResolveState("ReflectiveOrb");} return ResolveState(null);} //change attack type
		"####" C 4 {user_count4 = 0; user_count5 = 0; bNoDamage = FALSE; A_UnsetReflective();}
		"####" Y 12 A_FaceTarget;
		"####" X 16 A_FaceTarget;
		"####" Y 10 A_FaceTarget;
		"####" Z 6
		{
			A_QuakeEx(7,7,7,57,0,2048,"world/quake",QF_SCALEDOWN|QF_WAVE,6,6,6);
			A_RadiusThrust(1800, 4096, RTF_NOIMPACTDAMAGE|RTF_NOTMISSILE, 2048);
			A_RadiusThrust(200, 4096, RTF_NOIMPACTDAMAGE|RTF_NOTMISSILE|RTF_THRUSTZ, 2048);
			//add a red area effect here?
		}
		"####" Z 10;
		"####" C 6;
		Goto See;
	TeslaMissile:
		"####" EHH 6 A_FaceTarget;
		"####" IJ 4 {
			A_StartSound("tesla/kill");
			A_SpawnItemEx("MouthLightning",0,0,160,0,0,0,0,0);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 160, 0, -90, false);
			A_LightningAttack("LightningBeamZap2", 0, 0, 160, 0, 0, false);
			A_LightningAttack("LightningBeamAlt2", 0, 0, 160, 0, 0, false);
			A_LightningAttack("LightningBeamAlt2", 0, 0, 160, 0, 0, false);
			A_LightningAttack("LightningBeamAlt2", 0, 0, 160, 0, 0, false);
		}
		"####" H 6;
		"####" JI 4 {
			A_StartSound("tesla/kill");
			A_SpawnItemEx("MouthLightning",0,0,160,0,0,0,0,0);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 160, 0, -90, false);
			A_LightningAttack("LightningBeamZap2", 0, 0, 160, 0, 0, false);
			A_LightningAttack("LightningBeamAlt2", 0, 0, 160, 0, 0, false);
			A_LightningAttack("LightningBeamAlt2", 0, 0, 160, 0, 0, false);
			A_LightningAttack("LightningBeamAlt2", 0, 0, 160, 0, 0, false);
		}
		"####" H 6;
		"####" E 4;
		Goto See;
	Pain:
		"####" N 6 {
			A_NaziPain(256, True, -96);
			if (wounded) { frame = 5; } // Use frame F instead of N for pain state when wounded
		}
		Goto See;
	Death:
		SHI2 K 5;
		SHI2 L 8 A_Scream;
		SHI2 MN 12;
		SHI2 O 8;
		SHI2 P 7 A_NoBlocking;
		SHI2 Q 9 A_SpawnItemEx("Bridge24_3d");
	Dead:
		SHI2 R 4 A_SetScale(max(Scale.X * 0.98, 1.0));
		Loop;
	}

	override void PostBeginPlay()
	{
		SetStateLabel("Appear");

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (isFrozen()) { return; }

		if (InStateSequence(CurState, FindState("Appear")))
		{
			bDormant = true;

			alpha += 0.01;
			A_SetRenderStyle(alpha, STYLE_Translucent);

			if (alpha == 1.0)
			{
				A_StopSound(CHAN_AUTO);
				A_StartSound("hitlerghost/die", CHAN_AUTO, 0, 10.0);
				RestoreRenderStyle();

				bDormant = false;

				SetState(SpawnState);
			}
		}
		else if (GetRenderStyle() != Default.GetRenderStyle())
		{
			alpha = 1.0;
			RestoreRenderStyle();
		}

		Super.Tick();
	}
}

class ChairGuy : Nazi
{
	Default {
	//$Category Monsters (BoA)/Bosses
	//$Title Graf Holzbein (Boss)
	//$Color 4
	Base.BossIcon "BOSSICO2";
	Tag "$TAGHOLZBEIN";
	Height 64;
	Health 1000;
	Mass 100000;
	PainChance 64;
	Scale 0.67;
	DamageFactor "Rocket", 0.2;
	+BOSS
	+FLOAT
	+LOOKALLAROUND
	+MISSILEEVENMORE
	+NOGRAVITY
	Obituary "$CHAIRMAN";
	PainSound "boss/pain";
	SeeSound "holz/sight";
	DeathSound "holz/death";
	ActiveSound "holz/active";
	DropItem "GrenadePickup",128;
	DropItem "GrenadePickup",128;
	DropItem "GrenadePickup",128;
	Nazi.TotaleGierDrop 3;
	}
	States
	{
	Spawn:
		KRIS A 0;
		"####" "#" 0 { user_incombat = TRUE; } //mxd
		Goto Look;
	See:
		KRIS A 1 A_NaziChase;
		"####" AAA 1 A_NaziChase(null,null);
		"####" A 1 A_NaziChase;
		"####" AAA 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" BBB 1 A_NaziChase(null,null);
		"####" B 1 A_NaziChase;
		"####" BBB 1 A_NaziChase(null,null);
		Loop;
	Missile:
		KRIS E 14 A_FaceTarget;
		KRIS E 0 A_Jump(144,"SeekerMissile","SeekerMissile2");
		"####" F 8 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMiniRocket",66,22);
		"####" E 8 A_FaceTarget;
		"####" G 8 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMiniRocket",66,-22);
		"####" E 14 A_FaceTarget;
		"####" F 8 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMiniRocket",66,22);
		"####" E 8 A_FaceTarget;
		"####" G 8 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMiniRocket",66,-22);
		Goto See;
	SeekerMissile:
		"####" F 10 LIGHT("OTTOFIRE") A_SpawnProjectile("SeekerRocket",66,22);
		"####" E 8 A_FaceTarget;
		"####" G 10 LIGHT("OTT2FIRE") A_SpawnProjectile("SeekerRocket",66,-22);
		"####" E 8 A_FaceTarget;
		"####" F 10 LIGHT("OTTOFIRE") A_SpawnProjectile("SeekerRocket",66,22);
		"####" E 8 A_FaceTarget;
		"####" G 10 LIGHT("OTT2FIRE") A_SpawnProjectile("SeekerRocket",66,-22);
		Goto See;
	SeekerMissile2:
		"####" F 8 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMiniRocket",66,22);
		"####" E 8 A_FaceTarget;
		"####" G 10 LIGHT("OTT2FIRE") A_SpawnProjectile("SeekerRocket",66,-22);
		"####" E 8 A_FaceTarget;
		"####" F 10 LIGHT("OTTOFIRE") A_SpawnProjectile("SeekerRocket",66,22);
		"####" E 8 A_FaceTarget;
		"####" G 8 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMiniRocket",66,-22);
		Goto See;
	Death:
	Death.Fire:
	XDeath:
		KRIS H 8 A_Scream;
		"####" HHH 8 A_SetAngle(angle+45);
		"####" HHHHHH 6 A_SetAngle(angle+45);
		"####" HHHHHHHHH 4 A_SetAngle(angle+45);
		"####" HHHHHHHHHHHH 2 A_SetAngle(angle+45);
		"####" HHHHHHHHHHHHHHH 1 A_SetAngle(angle+45);
		"####" H 0 {A_NoBlocking(); A_SpawnItemEx("ZombieNuke",0,0,0);}
		Stop;
	Idle:
		KRIS AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	}
}

class SuperSoldier : NaziBoss
{
	Default
	{
	//$Category Monsters (BoA)/Bosses
	//$Title Hans Grosse (Boss)
	//$Color 4
	Obituary "$SUPASOLD";
	Tag "$TAGUEBER";
	Health 500;
	Radius 24;
	Height 64;
	Mass 500;
	PainChance 40;
	+LOOKALLAROUND
	SeeSound "Boss1/Sighted";
	PainSound "boss/pain";
	DeathSound "Boss1/Death";
	DropItem "Ammo9mm", 64;
	DropItem "AmmoBox9mm", 64;
	DropItem "Medikit_Small", 32;
	}
	States
	{
	Spawn:
		HANS A 0;
		Goto Look;
	Missile:
		HANS E 4 A_FaceTarget;
		"####" E 5 A_StartSound("chaingun/start", CHAN_AUTO);
		"####" E 1 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" E 10 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_MonsterRefire(20,"See");
		"####" G 0 A_FaceTarget;
 		Goto Missile+4;
	Pain:
		"####" H 6 A_NaziPain(256);
		Goto See;
	Retreat:
		"####" A 0 A_SetSpeed(5);
		"####" A 0 {bFrightened = TRUE;}
		"####" AABBCCDDAABBCCDDAABBCCDD 2 A_Chase;
		"####" AABBCCDDAABBCCDDAABBCCDD 2 A_Chase;
		"####" A 0 A_SetSpeed(2);
		"####" A 0 {bFrightened = FALSE;}
		Goto See;
	Death:
		"####" I 5;
		"####" J 8 A_Scream;
		"####" K 12;
		"####" L -1 A_NoBlocking;
		Stop;
	Raise:
		"####" LKJI 5;
		Goto See;
	}
}

class SuperSoldier_SS : SuperSoldier
{
	Default
	{
	//$Title Hans Grosse, SS (Boss)
	Tag "$TAGSSUEBER";
	Scale 0.63;
	}
	States
	{
	Spawn:
		HASS A 0;
		Goto Look;
	Missile:
		"####" E 0 A_Jump(160,"Missile2");
		"####" E 0 A_Jump(8,"Missile3"); //very rare
		"####" E 4 A_FaceTarget;
		"####" E 5 A_StartSound("chaingun/start", CHAN_AUTO);
		"####" E 1 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" E 10 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_MonsterRefire(20,"See");
		"####" G 0 A_FaceTarget;
 		Goto Missile+4;
	Missile2:
		HASS HMN 6 A_FaceTarget;
		"####" O 4 LIGHT("SUPAFIRE") A_ArcProjectile("ClusterBomb",56,0,random(-16,16));
		"####" NMH 6;
		Goto See;
	Missile3:
		HASS HMN 6 A_FaceTarget;
		"####" O 4 LIGHT("SUPAFIRE") A_ArcProjectile("ClusterBomb",56,0,random(-16,16));
		"####" HMN 6 A_FaceTarget;
		"####" O 4 LIGHT("SUPAFIRE") A_ArcProjectile("ClusterBomb",56,0,random(-32,-16));
		"####" HMN 6 A_FaceTarget;
		"####" O 4 LIGHT("SUPAFIRE") A_ArcProjectile("ClusterBomb",56,0,random(32,16));
		"####" NMH 6;
		Goto See;
	Retreat:
		HASS A 0 A_SetSpeed(5);
		Goto Super::Retreat+3;
	}
}

class SuperSoldier_Afrika : SuperSoldier
{
	Default
	{
	//$Title Hans Grosse, Afrika (Boss)
	Tag "$TAGAFRIKAUEBER";
	Scale 0.63;
	+AVOIDMELEE
	MaxTargetRange 1024;
	DropItem "GrenadePickup",128;
	DropItem "GrenadePickup",128;
	}
	States
	{
	Spawn:
		HAFR A 0;
		Goto Look;
	Missile:
		HAFR E 12 A_FaceTarget;
		"####" E 0 A_Jump(64,"Missile2");
		"####" E 0 A_Jump(16,"Missile3");
		"####" F 8;
		"####" G 6 A_ArcProjectile("HandGrenade",50,16,frandom(-2,2),CMF_AIMDIRECTION); //one grenade will aim straight
		"####" F 8;
		"####" I 6 A_ArcProjectile("HansGrenade",50,-16,frandom(-16,16));
		"####" I 0 A_Jump(64,"Retreat");
		"####" I 0 A_Jump(32,"Missile2");
		"####" E 6;
		Goto See;
	Missile2:
		HAFR E 12 A_FaceTarget;
		"####" H 8;
		"####" I 0 A_ArcProjectile("HansGrenade",50,16,frandom(-16,16));
		"####" I 8 A_ArcProjectile("HandGrenade",50,-16,frandom(-16,16));
		"####" E 10;
		"####" E 0 A_Jump(96,"Retreat");
		Goto See;
	Missile3:
		HAFR E 6 A_FaceTarget;
		"####" F 4;
		"####" G 6 A_ArcProjectile("HandGrenade",50,16,frandom(-16,16));
		"####" F 4;
		"####" I 6 A_ArcProjectile("HandGrenade",50,-16,frandom(-16,16));
		"####" I 0 A_Jump(64,"Retreat");
		"####" E 3;
		"####" H 4;
		"####" I 0 A_ArcProjectile("HansGrenade",50,16,frandom(-16,16));
		"####" I 8 A_ArcProjectile("HansGrenade",50,-16,frandom(-16,16));
		"####" E 5;
		"####" E 0 A_Jump(96,"Retreat");
		Goto See;
	Retreat:
		HAFR A 0 A_SetSpeed(6);
		Goto Super::Retreat+3;
	Pain:
		"####" E 6 A_NaziPain(256);
		Goto See;
	Death:
		"####" J 5;
		"####" K 8 A_Scream;
		"####" L 12;
		"####" M -1 A_NoBlocking;
		Stop;
	Raise:
		"####" MLKJE 5;
		Goto See;
	}
}

class SuperSoldier_Arctic : SuperSoldier
{
	Default
	{
	//$Title Hans Grosse, Arctic (Boss)
	Tag "$TAGARCTICUEBER";
	Scale 0.63;
	}
	States
	{
	Spawn:
		HART A 0;
		Goto Look;
	Missile:
		"####" E 0 A_Jump(160,"Missile2");
		"####" E 4 A_FaceTarget;
		"####" E 5 A_StartSound("chaingun/start", CHAN_AUTO);
		"####" E 1 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" E 8 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_MonsterRefire(20,"See");
		"####" G 0 A_FaceTarget;
 		Goto Missile+4;
	Missile2:
		"####" HMN 12 A_FaceTarget;
		"####" O 0 A_StartSound("IceFire", CHAN_WEAPON, 0, frandom(0.5,0.8));
		"####" O 4 LIGHT("ICEBALL") A_SpawnProjectile("IceDart",50,0,0,CMF_AIMDIRECTION);
		"####" NMH 12;
		"####" H 0 A_Jump(64,"Retreat");
		Goto See;
	Retreat:
		HART A 0 A_SetSpeed(4);
		Goto Super::Retreat+3;
	}
}

class SuperSoldier_Wehrmacht : SuperSoldier
{
	Default
	{
	//$Title Hans Grosse, Wehrmacht (Boss)
	Tag "$TAGWEHRUEBER";
	Scale 0.63;
	}
	States
	{
	Spawn:
		HWER A 0;
		Goto Look;
	Missile:
		HWER E 4 A_FaceTarget;
		"####" E 0 A_Jump(128,"Missile2");
		"####" E 5 A_StartSound("chaingun/start", CHAN_AUTO);
		"####" F 1 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" F 6 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" G 2 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" G 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" F 4 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" H 2 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" H 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" H 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" F 4 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" G 2 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" G 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" F 4 A_MonsterRefire(20,"See");
		"####" F 0 A_FaceTarget;
 		Goto Missile+5;
	Missile2:
		HWER E 12 A_FaceTarget;
		"####" I 8;
		"####" J 6 A_ArcProjectile("HandGrenade",50,16,frandom(-2,2));
		"####" J 0 A_Jump(64,"Retreat");
		"####" E 6;
		Goto See;
	Retreat:
		HWER A 0 A_SetSpeed(5);
		Goto Super::Retreat+3;
	Pain:
		HWER E 6 A_NaziPain(256);
		Goto See;
	Death:
		HWER K 5;
		"####" L 8 A_Scream;
		"####" M 12;
		"####" N -1 A_NoBlocking;
		Stop;
	Raise:
		"####" NMLKE 5;
		Goto See;
	}
}

class SuperSoldier_Navy : SuperSoldier
{
	Default
	{
	//$Title Hans Grosse, Navy (Boss)
	Tag "$TAGNAVYUEBER";
	Scale 0.63;
	}
	States
	{
	Spawn:
		HARP A 0;
		Goto Look;
	Melee:
		"####" N 4 A_FaceTarget;
		"####" Q 5 A_CustomMeleeAttack(5*random(2,4));
		"####" N 4 A_FaceTarget;
		"####" Q 5 A_CustomMeleeAttack(5*random(2,4));
		Goto See;
	Missile:
		"####" E 0 A_Jump(192,"Missile2");
		"####" E 4 A_FaceTarget;
		"####" E 5 A_StartSound("chaingun/start", CHAN_AUTO);
		"####" E 1 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" E 10 A_FaceTarget;
		"####" E 0 A_Jump(8,"Missile2");
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 47) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 47) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 47) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_MonsterRefire(20,"See");
		"####" G 0 A_FaceTarget;
 		Goto Missile+4;
	Missile2:
		"####" MN 10 A_FaceTarget;
		"####" O 4 A_SpawnProjectile("Harpoon",44,20,frandom(-2,2),CMF_AIMDIRECTION);
		"####" P 4 A_FaceTarget;
		Goto See;
	Retreat:
		HARP A 0 A_SetSpeed(5);
		Goto Super::Retreat+3;
	}
}

class SuperSoldier_Girl : SuperSoldier
{
	Default
	{
	//$Title Gretel Grosse (Boss)
	Obituary "$SUPAGIRL";
	Tag "$TAGGRETELJR";
	Speed 5;
	+MISSILEEVENMORE
	+MISSILEMORE
	SeeSound "BossGirl/Sighted";
	PainSound "BossGirl/Pain";
	DeathSound "BossGirl/Death";
	DropItem "Ammo9mm", 128;
	DropItem "AmmoBox9mm", 128;
	DropItem "Medikit_Small", 32;
	}
	States
	{
	Spawn:
		WBO4 A 0;
		Goto Look;
	Missile:
		WBO4 E 20 A_FaceTarget;
		"####" F 0 A_StartSound("browning/fire", CHAN_WEAPON);
		"####" F 0 A_SpawnProjectile("EnemyPistolTracer",44,20,frandom(-6,6));
		"####" F 0 A_SpawnProjectile("EnemyPistolTracer",44,-20,frandom(-6,6));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 11) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" FG 3 LIGHT("SUPAFIRE") A_FaceTarget;
		"####" F 0 A_StartSound("browning/fire", CHAN_WEAPON);
		"####" F 0 A_SpawnProjectile("EnemyPistolTracer",44,20,frandom(-6,6));
		"####" F 0 A_SpawnProjectile("EnemyPistolTracer",44,-20,frandom(-6,6));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 11) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" FG 6 LIGHT("SUPAFIRE");
		Goto See;
	Retreat:
		WBO4 A 0 A_SetSpeed(6);
		Goto Super::Retreat+3;
	}
}

class SuperSoldier_Elsa : SuperSoldier_Girl
{
	Default
	{
	//$Title Elsa (Boss)
	Base.BossIcon "BOSSICO2";
	Tag "$TAGELSA";
	Health 750;
	Scale 0.63;
	Speed 7;
	Obituary "$SUPAELSA";
	DropItem "Medikit_Small", 96;
	}
	States
	{
	Spawn:
		ELSA A 0;
		Goto Look;
	Missile:
		ELSA E 20 A_FaceTarget;
		"####" E 0 A_Jump(192,"Missile2");
		"####" E 0 A_Jump(128,"Missile3");
		"####" E 0 A_Jump(64,"Missile4");
		"####" F 0 A_StartSound("browning/fire", CHAN_WEAPON);
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,20,frandom(-6,6));
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,-20,frandom(-6,6));
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" FG 2 LIGHT("SUPAFIRE") A_FaceTarget;
		"####" F 0 A_StartSound("browning/fire", CHAN_WEAPON);
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,20,frandom(-6,6));
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,-20,frandom(-6,6));
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" FG 2 LIGHT("SUPAFIRE") A_FaceTarget;
		"####" F 0 A_StartSound("browning/fire", CHAN_WEAPON);
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,20,frandom(-6,6));
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,-20,frandom(-6,6));
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" FG 2 LIGHT("SUPAFIRE");
		Goto See;
	Missile2:
		ELSA E 6 A_FaceTarget;
		"####" F 0 A_StartSound("supaproj/fire", CHAN_WEAPON);
		"####" F 4 { A_ArcProjectile("RedBounceBall",44,20,random(-2,2)); A_ArcProjectile("RedBounceBall",44,-20,random(-2,2)); }
		"####" F 0 {user_count++; if(user_count2 > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 5 A_FaceTarget;
		"####" G 0 A_StartSound("supaproj/fire", CHAN_WEAPON);
		"####" G 4 { A_ArcProjectile("RedBounceBall",44,20,random(-2,2)); A_ArcProjectile("RedBounceBall",44,-20,random(-2,2)); }
		"####" G 0 {user_count++; if(user_count2 > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 5 A_MonsterRefire(15,"See");
		"####" E 0 A_FaceTarget;
		Goto Missile+1;
	Missile3:
		ELSA E 5 A_FaceTarget;
		"####" F 3 { A_ArcProjectile("ClusterBomb",44,20,random(-16,16)); A_ArcProjectile("ClusterBomb",44,-20,random(-16,16)); }
		"####" F 0 {user_count++; if(user_count3 > 7) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 4 A_FaceTarget;
		"####" F 3 { A_ArcProjectile("ClusterBomb",44,20,random(-32,16)); A_ArcProjectile("ClusterBomb",44,-20,random(-32,16)); }
		"####" F 0 {user_count++; if(user_count3 > 7) {user_count = 0; return ResolveState("See");} return ResolveState(null);}
		"####" E 4 A_FaceTarget;
		"####" F 3 { A_ArcProjectile("ClusterBomb",44,20,random(32,16)); A_ArcProjectile("ClusterBomb",44,-20,random(32,16)); }
		"####" F 0 {user_count++; if(user_count3 > 7) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 5;
		Goto See;
	Missile4:
		ELSA E 10 A_FaceTarget;
		"####" F 0 A_StartSound("browning/fire", CHAN_WEAPON);
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,20,frandom(-6,6));
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,-20,frandom(-6,6));
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" F 3 LIGHT("SUPAFIRE") A_ArcProjectile("ClusterBomb",56,0,random(-4,4));
		"####" F 0 {user_count++; if(user_count3 > 7) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 4 A_FaceTarget;
		"####" FG 2 LIGHT("SUPAFIRE") A_FaceTarget;
		"####" F 0 A_StartSound("browning/fire", CHAN_WEAPON);
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,20,frandom(-6,6));
		"####" FFFF 0 A_SpawnProjectile("EnemyPistolTracer",44,-20,frandom(-6,6));
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" FFFF 0 A_SpawnItemEx("Casing9mm", 12,0,36, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 23) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" F 3 { A_ArcProjectile("ClusterBomb",44,20,random(-4,4)); A_ArcProjectile("ClusterBomb",44,-20,random(-4,4)); }
		"####" F 0 {user_count++; if(user_count3 > 7) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 4 A_FaceTarget;
		"####" F 0 A_StartSound("supaproj/fire", CHAN_WEAPON);
		"####" F 4 { A_ArcProjectile("RedBounceBall",44,20,random(-2,2)); A_ArcProjectile("RedBounceBall",44,-20,random(-2,2)); }
		"####" F 0 {user_count++; if(user_count2 > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 4 A_FaceTarget;
		"####" G 0 A_StartSound("supaproj/fire", CHAN_WEAPON);
		"####" G 4 { A_ArcProjectile("RedBounceBall",44,20,random(-2,2)); A_ArcProjectile("RedBounceBall",44,-20,random(-2,2)); }
		"####" G 0 {user_count++; if(user_count2 > 15) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" E 4 A_FaceTarget;
		Goto See;
	Pain:
		ELSA E 6 A_NaziPain(256);
		Goto See;
	Retreat:
		ELSA A 0 A_SetSpeed(6);
		"####" A 0 {bFrightened = TRUE;}
		"####" AABBCCDDAABBCCDDAABBCCDD 2 A_Chase;
		"####" A 0 A_SetSpeed(2);
		"####" A 0 {bFrightened = FALSE;}
		Goto See;
	Death:
		ELSA H 7;
		"####" I 8 A_Scream;
		"####" J 12;
		"####" J -1 A_NoBlocking;
		Stop;
	Raise: //unused
		ELSA JIHE 5;
		Goto See;
	}
}

class SuperSoldier_Elite : SuperSoldier
{
	Default
	{
	//$Title Elite Ubersoldat (Boss)
	Tag "$TAGELITEUEBER";
	Health 850;
	Obituary "$SUPAELIT";
	DropItem "Ammo9mm", 128;
	DropItem "Ammo9mm", 128;
	DropItem "AmmoBox9mm", 128;
	DropItem "Medikit_Small", 96;
	}
	States
	{
	Spawn:
		TRAN A 0;
		Goto Look;
	Missile:
		TRAN E 6 A_FaceTarget;
		"####" E 4 A_StartSound("chaingun/start", CHAN_AUTO);
		"####" E 0 A_StartSound("chaingun/loop", CHAN_AUTO);
		"####" E 10 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_FaceTarget;
		"####" F 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,20,random(-11,11));
		"####" F 1 LIGHT("SUPAFIRE") A_SpawnProjectile("EnemyChaingunTracer",44,-20,random(-11,11));
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 A_SpawnItemEx("Casing9mm", 12,0,46, random(3,4), random(-1,1), random(4,6), random(55,80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Retreat");} return ResolveState(null);}
		"####" G 2 A_MonsterRefire(20,"See");
		"####" G 0 A_FaceTarget;
		Goto Missile+4;
	Retreat:
		TRAN A 0 A_SetSpeed(4);
		Goto Super::Retreat+3;
	}
}

class Blondi : NaziBoss
{
	Default
	{
	//$Category Monsters (BoA)/Bosses
	//$Title Blondi (Boss)
	//$Color 4
	Base.BossIcon "BOSSICO1";
	Base.LoiterDistance 64;
	Tag "$TAGBLONDI";
	PainChance 8;
	Height 64;
	Health 400;
	Speed 6;
	Mass 140;
	Scale 1.2;
	SeeSound "dog/sight";
	PainSound "dog/pain";
	DeathSound "dog/death";
	ActiveSound "dog/active";
	HitObituary "$BLONDI";
	DamageFactor "Rocket", 1.0;
	Nazi.TotaleGierDrop 0;
	-CANUSEWALLS
	-CANPUSHWALLS
	+NEVERTARGET
	}
	States
	{
	Spawn:
		BLON A 0;
		Goto Look;
	Idle:
		"####" A 0 A_SetSpeed(6);
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
			if (target && target != goal) { Speed = 10; }
			else { Speed = 6; }
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
		"####" G 8 Fast A_CustomMeleeAttack(random(6,9)*4,"dog/attack","dog/attack");
		"####" FE 4 Fast;
		Goto See;
	Missile:
		"####" N 8 Fast A_FaceTarget;
		"####" N 0 A_StartSound("dog/sight", CHAN_AUTO, 0, 1.0, 0.1);
		"####" N 1 Radius_Quake(10,10,0,16,0);
		"####" O 4 A_SpawnProjectile("BarkWaves",38,0,0,CMF_CHECKTARGETDEAD);
		"####" N 8 Fast A_FaceTarget;
		"####" N 0 A_StartSound("dog/sight", CHAN_AUTO, 0, 1.0, 0.1);
		"####" N 1 Radius_Quake(10,10,0,16,0);
		"####" O 4 A_SpawnProjectile("BarkWaves",38,0,0,CMF_CHECKTARGETDEAD);
		"####" N 4;
		Goto See;
	Pain:
		"####" M 2;
		"####" M 2 A_Pain;
		"####" "#" 0 A_AlertMonsters(256);
		Goto See;
	Death:
		"####" H 8;
		"####" I 12 A_Scream;
		"####" J 6;
		"####" K -1 A_NoBlocking;
		Stop;
	Death.Fire:
		Goto Death.FireBlondi;
	Raise:
		"####" KJIH 6;
		Goto See;
	}
}

class PhantomBoss : RocketMan
{
	Default
	{
	//$Title Erik The Phantom (Boss)
	Tag "$TAGERIK";
	Base.BossIcon "BOSSICO2";
	Base.NoFear;
	Nazi.Healer 2;
	Nazi.HealSound "creepy/born";
	Health 850;
	PainChance 16;
	Obituary "$PHANTOM";
	ActiveSound "nazombie/act";
	SeeSound "nazombie/sighted";
	PainSound "nazombie/pain";
	DeathSound "nazombie/act";
	DamageFactor "Electric", 0.8;
	DamageFactor "Fire", 0.5;
	DamageFactor "MutantPoison", 0;
	DamageFactor "MutantPoisonAmbience", 0;
	DamageFactor "Normal", 0.5;
	DamageFactor "Poison", 0;
	DamageFactor "UndeadPoison", 0;
	DamageFactor "UndeadPoisonAmbience", 0;
	DropItem "Medikit_Large", 96;
	DropItem "Medikit_Small", 128;
	Species "Phantom";
	}
	States
	{
	Spawn:
		PHAN A 0;
		Goto Look;
	Missile:
		PHAN E 0 A_Jump(96,"Missile3");
		PHAN E 0 A_Jump(128,"Missile2");
		PHAN E 12 A_FaceTarget;
		"####" F 8 A_SpawnProjectile("BossDagger",32,12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" C 6;
		Goto See;
	Missile2:
		PHAN U 12 A_FaceTarget;
		"####" V 8 A_SpawnProjectile("BossDagger",32,-12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" W 12 A_FaceTarget;
		"####" X 8 A_SpawnProjectile("BossDagger",32,12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" C 8;
		Goto See;
	Missile3:
		PHAN U 12 A_FaceTarget;
		"####" V 8 A_SpawnProjectile("BossDagger",32,-12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" W 12 A_FaceTarget;
		"####" X 8 A_SpawnProjectile("BossDagger",32,12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" C 8;
		"####" V 8 A_SpawnProjectile("BossDagger",32,-12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" W 12 A_FaceTarget;
		"####" X 8 A_SpawnProjectile("BossDagger",32,12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" C 8;
		"####" E 12 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("BossDagger",32,-12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" F 8 A_SpawnProjectile("BossDagger",32,12,random(-2,2),CMF_CHECKTARGETDEAD);
		"####" C 8;
		Goto See;
	Melee: //Drain power attack planned
		"####" K 12 A_FaceTarget;
		"####" L 8;
		"####" M 0 GiveBody(5);
		"####" MN 4 A_CustomMeleeAttack(5, "Smoke/See", "");
		"####" NMN 4;
		Goto See;
	Heal:
		"####" P 6;
		"####" O 3 A_SpawnAtGoal("CreepyRaiseFlat", random(10,-10), random(10,-10), 0, 0, 0, 0, 0);
		"####" O 0 A_HealGoal;
		"####" POP 12;
		Goto See;
	Pain:
		"####" G 6 A_NaziPain(256);
		Goto See;
	Death:
		PHAN G 5;
		"####" H 8 A_Scream;
		"####" I 12;
		"####" J 0 A_NoBlocking; //now 50 souls total
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 5, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 25, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 35, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 45, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 65, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 85, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 95, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 105, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 115, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 125, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 145, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 155, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("SoulSuperBig", 32, 0, 165, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 185, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 205, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 225, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 245, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 265, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 275, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 285, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 295, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 305, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 315, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 325, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 335, CMF_BADPITCH, 0);
		"####" J 0 A_SpawnProjectile("Soul", 32, 0, 345, CMF_BADPITCH, 0);
		"####" J -1 A_BossDeath;
		Stop;
	Raise:
		PHAN KJIH 5;
		Goto See;
	Idle:
		PHAN AAAAAAAA 1 A_Wander;
		"####" A 0 A_Look;
		"####" BBBBBBBB 1 A_Wander;
		"####" A 0 A_Look;
		"####" CCCCCCCC 1 A_Wander;
		"####" A 0 A_Look;
		"####" DDDDDDDD 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	Play:
		"####" QRSQSRQ 1 A_SetTics(random(10,30));
		"####" QQ 1 A_SetTics(random(10,40));
		Loop;
	Stand:
		PHAN T 8;
		Wait;
	}
}