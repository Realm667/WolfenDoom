/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED,
 *                         Nash Muhandes, Talon1024, AFADoomer
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

// Base Tracer actors moved to ZScript: scripts/actors/tracers.txt
class TankSpark : TracerSpark //use this as blood for vehicles et similae
{
	Default
	{
	Speed 0.2;
	Scale 0.4;
	Mass 125;
	}
	States
	{
	Spawn:
		PUFF A 2;
		"####" AEFGHI 4 BRIGHT A_SetTranslucent(.8,1);
		"####" J 1 BRIGHT A_SetTranslucent(.8,1);
		"####" K 2 BRIGHT A_SetTranslucent(.7,1);
		"####" K 1 BRIGHT A_SetTranslucent(.6,1);
		"####" K 2 BRIGHT A_SetTranslucent(.5,1);
		"####" K 1 BRIGHT A_SetTranslucent(.4,1);
		"####" K 2 BRIGHT A_SetTranslucent(.3,1);
		"####" K 1 BRIGHT A_SetTranslucent(.2,1);
		"####" K 0 {bWindThrust = FALSE;}
		Stop;
	}
}

//////////////////////////////////////////////////////////////////
////////////////// PLAYER WEAPON TRACERS /////////////////////////
//////////////////////////////////////////////////////////////////

//The Player's variants on the tracers, so they have different speeds and damages based on which weapon is being used.
// Base class defined in ZScript

//Muzzle velocity: 1,148-1,312 ft/s (350-400 m/s) - Wikipedia
class LugerTracer : PlayerTracer
{
	Default
	{
	ProjectileKickback 60;
	DamageFunction (random(3,17));
	Speed 100;
	}
}

//Muzzle velocity: 1,200 ft/s (365 m/s) - Wikipedia
class WaltherTracer : LugerTracer
{
	Default
	{
	DamageFunction (random(6,18));
	Speed 90;
	}
}

class ShotgunTracer : PlayerTracer
{
	Default
	{
	Scale .3;
	DamageFunction (random(5,15));
	DamageType "Pellet";
	+BULLETTRACER.NORICOCHET
	}
}

class AutoShotgunTracer : ShotgunTracer	{ Default { Obituary "$OBAUTOSH"; } }

//Muzzle velocity: 1,312 ft/s (400 m/s) - Wikipedia
class MP40Tracer : PlayerTracer
{
	Default
	{
	DamageFunction (random(9,14));
	Speed 90;
	}
}

//Muzzle velocity: 1,001 ft/s (305 m/s) - Wikipedia
class StenTracer : PlayerTracer { Default { DamageFunction (random(9,14)); } }

//Muzzle velocity: 935 ft/s (285 m/s) - Wikipedia
class ThompsonTracer : PlayerTracer
{
	Default
	{
	ProjectileKickback 100;
	DamageFunction (random(14,18));
	Speed 120;
	}
}

//Muzzle velocity: 2,822 ft/s (860 m/s) - Wikipedia
class Kar98kTracer : PlayerTracer
{
	Default
	{
	ProjectileKickback 100;
	DamageFunction (random(40,65));
	Speed 180;
	Obituary "$OBMAUSER";
	DamageType "Rifle";
	}
}

class Kar98kTracer2 : Kar98kTracer { Default { DamageFunction (random(60,85)); } }

//Muzzle velocity: 2,448-2,546 ft/s (746-776 m/s) - Wikipedia
class G43Tracer : Kar98kTracer
{
	Default
	{
	DamageFunction (random(26,55));
	Speed 150;
	Obituary "$OBG43";
	DamageType "Rifle";
	}
}

class ChaingunTracer : PlayerTracer
{
	Default
	{
	DamageFunction (random(11,15));
	Speed 90;
	DamageType "Rifle";
	}
}

//////////////////////////////////////////////////////////////////
//////////////// SHELLS & CASINGS ////////////////////////////////
//////////////////////////////////////////////////////////////////
class Casing9mm : ParticleBase
{
	Default
	{
	Scale .075;
	Projectile;
	-NOBLOCKMAP
	-NOGRAVITY
	+NOTRIGGER // Prevent casings from breaking mirrors - Talon1024
	+BOUNCEONACTORS
	+FORCEXYBILLBOARD
	+MTHRUSPECIES //let's avoid these to be blocked by shark blockers - ozy81
	+THRUSPECIES //let's avoid these to be blocked by shark blockers - ozy81
	+WINDTHRUST
	BounceType "Doom";
	BounceSound "bulletcasing/bounce";
	BounceFactor .5;
	WallBounceFactor .2;
	Mass 5;
	Radius 3;
	Height 3;
	Species "Player"; //let's avoid these to be blocked by shark blockers - ozy81
	}
	States
	{
	Spawn:
		CAS1 ABCDEFGH 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd. This presumes all cases have the same ammout of frames...
		"####" A 2 A_ScaleVelocity(0.7);
		"####" B 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" C 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" E 2 A_ScaleVelocity(0.7);
		"####" F 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" G 2 A_ScaleVelocity(0.7);
		"####" H 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
	SwimLoop: // Don't spawn more bubbles after the first batch
		"####" ABCDEFGH 2;
		Loop;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_Jump(256,1,2,3);
		"####" ACG 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_casinglifetime); //try to run tics into seconds for a player-friendly setting
	Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Casing9mm2 : Casing9mm { Default { Scale 0.75; } }

class Casing45ACP : Casing9mm
{
	Default
	{
	Scale .1;
	}
	States
	{
	Spawn:
		CAS3 ABCDEFGH 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	}
}

class ShotgunCasing : Casing9mm
{
	Default
	{
	WallBounceSound "shellcasing/bounce";
	BounceSound "shellcasing/bounce";
	DeathSound "shellcasing/stop";
	Scale .175;
	}
	States
	{
	Spawn:
		CAS2 ABCDEFGH 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	}
}

class MauserRifleCasing : Casing9mm
{
	Default
	{
	Scale .15;
	}
	States
	{
	Spawn:
		CAS4 ABCDEFGH 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	}
}

class PyroCasing : ShotgunCasing
{
	Default
	{
	Scale 0.48;
	}
	States
	{
	Spawn:
		PYCS ABCDEFGH 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	}
}

class EnfieldRifleCasing : MauserRifleCasing {}
class GarandRifleCasing : MauserRifleCasing {}
class RevolverCasing : Casing9mm {}
class STGCasing : MauserRifleCasing {}
class TokarevCasing : Casing9mm {}

/////////////////////////////////////////////////////////////
/////////////////// MUTANT PROJECTILES //////////////////////
/////////////////////////////////////////////////////////////

//Nifty new mutants variations for tracers
class MutantTracer : BulletTracer
{
	Default
	{
	DamageType "MutantPoison";
	BulletTracer.Trail "MutantTrail";
	}
	States
	{
	Spawn:
		TNT1 A 1 BRIGHT A_JumpIfTracerCloser(96,"Whiz");
		Loop;
	}
}

class MutantTrail: TracerTrail {}

/////////////////////////////////////////////////////////////
/////////////////// ASTROSTEIN PROJECTILES //////////////////
/////////////////////////////////////////////////////////////

//Variant for Enemies
class AstroTracer : BulletTracer
{
	Default
	{
	+BLOODLESSIMPACT
	DamageType "AstroPoison";
	DeathType "Disintegrate";
	BulletTracer.Trail "AstroTrail";
	+BULLETTRACER.NOINERTIA
	+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 1 BRIGHT A_JumpIfTracerCloser(96,"Whiz");
		Loop;
	Whiz:
		TNT1 A -1 BRIGHT A_SpawnItemEx("AstroWhizzer");
		Stop;
	Death:
	Crash:
		TNT1 AAAAA 0 A_SpawnItemEx("SparkG", 0, 0, 0, random(1,2), random(1,2), random(1,2), random(1,360), SXF_CLIENTSIDE);
		TNT1 A 0 { A_SpawnItemEx("SparkFlareG"); A_SpawnItemEx("ZBulletChip"); }
		TNT1 A 8 A_StartSound("astroricochet");
		Stop;
	XDeath:
		TNT1 AAAAA 0 A_SpawnItemEx("SparkG", 0, 0, 0, random(1,2), random(1,2), random(1,2), random(1,360), SXF_CLIENTSIDE);
		TNT1 A 0 A_SpawnItemEx("SparkFlareG");
		TNT1 A 1 A_StartSound("astrohitflesh");
		Stop;
	}
}

class EnemyAstroTracer : AstroTracer { Default { DamageFunction (random(2,4)); } }

class AstroWhizzer: Actor
{
	States
	{
	Spawn:
		TNT1 A 1 A_StartSound("astrowhiz");
		Stop;
	}
}

class AstroTrail: TracerTrail { Default { TracerTrail.FadeRate 0.0; } } // Don't fade the laser beams

//Variant for Players
class AstroTracerPlayer : AstroTracer
{
	Default
	{
	ProjectileKickback 60;
	DamageFunction (random(3,17));
	Speed 100;
	}
}

//Robots tracers
class ProtoTracer : BulletTracer
{
	Default
	{
	+BLOODLESSIMPACT
	DamageType "AstroPoison";
	DeathType "Disintegrate";
	BulletTracer.Trail "ProtoTrail";
	}
	States
	{
	Spawn:
		TNT1 A 1 BRIGHT A_JumpIfTracerCloser(96,"Whiz");
		Loop;
	Whiz:
		TNT1 A -1 BRIGHT A_SpawnItemEx("AstroWhizzer");
		Stop;
	Death:
	Crash:
		TNT1 AAAAA 0 A_SpawnItemEx("SparkR", 0, 0, 0, random(1,2), random(1,2), random(1,2), random(1,360), SXF_CLIENTSIDE);
		TNT1 A 0 { A_SpawnItemEx("SparkFlareR"); A_SpawnItemEx("ZBulletChip"); }
		TNT1 A 8 A_StartSound("astroricochet");
		Stop;
	XDeath:
		TNT1 AAAAA 0 A_SpawnItemEx("SparkR", 0, 0, 0, random(1,2), random(1,2), random(1,2), random(1,360), SXF_CLIENTSIDE);
		TNT1 A 0 A_SpawnItemEx("SparkFlareR");
		TNT1 A 1 A_StartSound("astrohitflesh");
		Stop;
	}
}

class EnemyProtoTracer : ProtoTracer { Default { DamageFunction (random(1,3)); } }
class ProtoTrail: TracerTrail { Default { TracerTrail.FadeRate 0.0; } } // Don't fade the laser beams

/////////////////////////////////////////////////////////////
/////////////////// SKILL SETTINGS //////////////////////////
/////////////////////////////////////////////////////////////

// Enemy tracer variants for Normal mode.
class EnemyChaingunTracer : BulletTracer 			{Default { DamageFunction (random(6,8)); } }
class EnemyChaingunTracer2 : BulletTracer 			{Default { Scale 2.0; DamageFunction (random(6,8)); } }
class EnemyMutantTracer : MutantTracer				{Default { DamageFunction (random(2,4)); } }
class EnemyPistolTracer : BulletTracer				{Default { DamageFunction (random(4,8)); } }
class EnemyRifleTracer : BulletTracer				{Default { DamageFunction (random(15,30)); } }
class EnemySMGTracer : BulletTracer					{Default { DamageFunction (random(6,7)); } }
class EnemyShotgunTracer : BulletTracer 			{Default { DamageFunction (random(3,7)); } }
class EnemyStGTracer : BulletTracer					{Default { DamageFunction (random(7,8)); } }
class REnemyPistolTracer : BulletTracer				{Default { +THRUSPECIES DamageFunction (random(4,8)); Species "Player"; } }
class REnemyRifleTracer : BulletTracer				{Default { +THRUSPECIES DamageFunction (random(15,30)); Species "Player"; } }
class REnemySMGTracer : BulletTracer				{Default { +THRUSPECIES DamageFunction (random(6,7)); Species "Player"; } }

// Enemy tracer variants for Baby mode
class BabyEnemyAstroTracer : EnemyAstroTracer		{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyChaingunTracer : EnemyChaingunTracer	{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyChaingunTracer2 : EnemyChaingunTracer2	{Default { Scale 2.0; Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyMutantTracer : EnemyMutantTracer		{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyPistolTracer : EnemyPistolTracer		{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyProtoTracer : EnemyProtoTracer		{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyRifleTracer : EnemyRifleTracer		{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemySMGTracer : EnemySMGTracer			{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyShotgunTracer : EnemyShotgunTracer	{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyEnemyStGTracer : EnemyStGTracer			{Default { Speed 30; FastSpeed 35; Gravity 3; } }
class BabyREnemyPistolTracer : REnemyPistolTracer	{Default { +THRUSPECIES Speed 30; FastSpeed 35; Species "Player"; Gravity 3;} }
class BabyREnemyRifleTracer : REnemyRifleTracer		{Default { +THRUSPECIES Speed 30; FastSpeed 35; Species "Player"; Gravity 3;} }
class BabyREnemySMGTracer : REnemySMGTracer			{Default { +THRUSPECIES Speed 30; FastSpeed 35; Species "Player"; Gravity 3;} }

// Enemy tracer variants for Easy mode
class EasyEnemyAstroTracer : EnemyAstroTracer		{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyChaingunTracer : EnemyChaingunTracer	{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyChaingunTracer2 : EnemyChaingunTracer2	{Default { Scale 2.0; Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyMutantTracer : EnemyMutantTracer		{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyPistolTracer : EnemyPistolTracer		{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyProtoTracer : EnemyProtoTracer		{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyRifleTracer : EnemyRifleTracer		{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemySMGTracer : EnemySMGTracer			{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyShotgunTracer : EnemyShotgunTracer	{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyEnemyStGTracer : EnemyStGTracer			{Default { Speed 50; FastSpeed 55; Gravity 6; } }
class EasyREnemyPistolTracer : REnemyPistolTracer	{Default { +THRUSPECIES Speed 50; FastSpeed 55; Species "Player"; Gravity 6; } }
class EasyREnemyRifleTracer : REnemyRifleTracer		{Default { +THRUSPECIES Speed 50; FastSpeed 55; Species "Player"; Gravity 6; } }
class EasyREnemySMGTracer : REnemySMGTracer			{Default { +THRUSPECIES Speed 50; FastSpeed 55; Species "Player"; Gravity 6; } }

// Enemy tracer variants for Hard and Nightmare mode
class HardEnemyAstroTracer : EnemyAstroTracer		{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemyChaingunTracer : EnemyChaingunTracer	{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemyChaingunTracer2 : EnemyChaingunTracer2	{Default { +MTHRUSPECIES Scale 2.0; Speed 90; FastSpeed 95;} }
class HardEnemyMutantTracer : EnemyMutantTracer		{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemyPistolTracer : EnemyPistolTracer		{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemyProtoTracer : EnemyProtoTracer		{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemyRifleTracer : EnemyRifleTracer		{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemySMGTracer : EnemySMGTracer			{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemyShotgunTracer : EnemyShotgunTracer	{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardEnemyStGTracer : EnemyStGTracer			{Default { +MTHRUSPECIES Speed 90; FastSpeed 95;} }
class HardREnemyPistolTracer : REnemyPistolTracer	{Default { +THRUSPECIES Speed 90; FastSpeed 95; Species "Player"; } }
class HardREnemyRifleTracer : REnemyRifleTracer		{Default { +THRUSPECIES Speed 90; FastSpeed 95; Species "Player"; } }
class HardREnemySMGTracer : REnemySMGTracer			{Default { +THRUSPECIES Speed 90; FastSpeed 95; Species "Player"; } }

// SmokeSpawners for weapons //
class PistolSmokeSpawner : GunSmokeSpawner { Default { GunSmokeSpawner.SmokeClass "PistolSmoke"; } }
class PistolSmoke : GunSmoke { Default { Alpha 0.2; Scale 3; } }
class ShotSmokeSpawner : GunSmokeSpawner { Default { GunSmokeSpawner.SmokeClass "ShotSmoke"; } }
class ShotSmoke : GunSmoke { Default { Alpha 0.75; Scale 3; } }
class ChainSmokeSpawner : GunSmokeSpawner { Default { GunSmokeSpawner.SmokeClass "ChainSmoke"; } }
class ChainSmoke : PistolSmoke { Default { Alpha 0.5; Scale 2; } }
class TurrSmokeSpawner : GunSmokeSpawner { Default { GunSmokeSpawner.SmokeClass "TurrSmoke"; } }
class TurrCoolSmoke : GunSmoke { Default { Alpha 0.3; Scale 4; } }
class TurrSmoke : GunSmoke { Default { Alpha 0.5; Scale 7; } }