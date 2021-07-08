/*
 * Copyright (c) 2019-2021 Tormentor667, Ed the Bat, Ozymandias81, AFADoomer
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
//ATTACKS//
///////////

class HardAstroDroneBall : AstroDroneBall { Default { +MTHRUSPECIES} }

class AstroRobotSeekerBall : AstroDroneBall
{	Default
	{
	Radius 12;
	Height 16;
	Speed 7;
	MaxTargetRange 128;
	Scale 1.2;
	+SEEKERMISSILE
	}
	States
	{
	Spawn:
		ROBP A 0 NODELAY A_Jump(2,"PreciseLoop");
		"####" AB 4 A_SeekerMissile(8, random(15,30));
		Loop;
	PreciseLoop:
		"####" AB 4 A_SeekerMissile(8, random(60,90), SMF_PRECISE);
		Loop;
	}
}

class HardAstroRobotSeekerBall : AstroRobotSeekerBall { Default {+MTHRUSPECIES} }

class Destroyed_AstroSuite: Actor
{	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Astrostein Suite Guard Carcass (destroyable)
	//$Color 3
	Radius 16;
	Height 56;
	Health 50;
	Mass 400;
	Scale 0.70;
	+CASTSPRITESHADOW
	+FRIENDLY
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	}
	States
	{
	Spawn:
		ROB1 O -1;
		Stop;
	Death:
		ROB1 O 1 {A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1); A_SpawnItemEx("AstrosteinExplosion_Decorative", 0, 0, 40); A_NoBlocking();}
		"####" OO 0 A_SpawnItemEx("Debris_AstroSuite", random(8,40), random(16,44), random(32,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOO 0 A_SpawnItemEx("Debris_AstroSuite", random(16,56), random(32,56), random(56,64), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOOO 0 A_SpawnItemEx("Debris_AstroSuite", random(32,64), random(64,80), random(16,32), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOOOO 0 A_SpawnItemEx("Debris_MetalJunk", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOOOOOO 0 A_SpawnItemEx("Debris_MetalJunk", random(16,32), random(32,48), random(64,80), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Destroyed_AstroRobot : Destroyed_AstroSuite
{	Default
	{
	//$Title Astrostein Robot Carcass (destroyable)
	//$Color 3
	Radius 32;
	}
	States
	{
	Spawn:
		ROB2 O -1;
		Stop;
	Death:
		ROB2 O 1 {A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1); A_SpawnItemEx("AstrosteinExplosion_Decorative", 0, 0, 40); A_NoBlocking();}
		"####" OO 0 A_SpawnItemEx("Debris_AstroRobot", random(8,40), random(16,44), random(32,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOO 0 A_SpawnItemEx("Debris_AstroRobot", random(16,56), random(32,56), random(56,64), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOOO 0 A_SpawnItemEx("Debris_AstroRobot", random(32,64), random(64,80), random(16,32), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOOOO 0 A_SpawnItemEx("Debris_MetalJunk", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" OOOOOOO 0 A_SpawnItemEx("Debris_MetalJunk", random(16,32), random(32,48), random(64,80), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class AstroSuiteDropper : RandomSpawner { Default { DropItem "Destroyed_AstroSuite"; } }
class AstroRobotDropper : RandomSpawner { Default { DropItem "Destroyed_AstroRobot"; } }

////////////////
//DEATH EFFECT//
////////////////

class BaseLine : ParticleBase
{	Default
	{
	+BRIGHT
	+MISSILE
	+NOBLOCKMAP
	+NOGRAVITY
	+NOINTERACTION
	Radius 0;
	Height 0;
	RenderStyle "Add";
	Alpha 0.01;
	}
	States
	{
	Spawn:
		SPFX AAAAA 1 LIGHT("AstrosteinDeathLight") A_FadeIn(0.2);
		"####" A 1 LIGHT("AstrosteinDeathLight") A_FadeOut(0.06);
		Wait;
	}
}

class BaseLineXL : BaseLine
{	Default
	{
	Scale 5.0;
	}
}

////////////////
//REPLACEMENTS//
////////////////

class TeleportFog_Astro : TeleportFog replaces TeleportFog
{
	States
	{
	Spawn:
		TNT1 AAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("BaseLine", random(16, -16), random(16, -16), random(0, 16), 0, 0, random(1,3), 0, 129, 0);
		Stop;
	}
}

class TeleportFog_AstroLarge : TeleportFog_Astro
{
	States
	{
	Spawn:
		TNT1 AAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("BaseLineXL", random(512, -512), random(512, -512), random(128, -128), 0, 0, random(1,3), 0, 129, 0);
		Stop;
	}
}

///////////
//ENEMIES//
///////////

class AstroGuard : Guard
{	Default
	{
	//$Category Astrostein (BoA)/Monsters
	//$Title Astrostein Guard
	//$Color 4
	Scale 0.70;
	DropItem "AstroClipAmmo", 128;
	DropItem "AstroShotgunShell" ,32;
	Obituary "$AGUARD1";
	DeathSound "astrostein/guard_death";
	}
	States
	{
	Spawn:
		ATR2 A 0;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		ATD2 A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
	Missile.Aimed:
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" E 8 A_Jump(256,"See");
		Stop;
	Pain:
		"####" G 6 A_NaziPain(256);
		"####" G 0 A_Jump(256,"See");
		Stop;
	Death.Front:
	Death.Back:
	Death.Headshot:
		Stop;
	XDeath:
	Death:
		"####" A 0 A_Jump(256,"Disintegrate");
	}
}

class AstroGuard2 : AstroGuard
{	Default
	{
	//$Title Astrostein Guard 2
	Health 30;
	Scale 0.70;
	}
	States
	{
	Spawn:
		ATR1 A 0;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		ATD1 A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" E 8 A_Jump(256,"See");
		Stop;
	}
}

class AstroCommando : AstroGuard
{	Default
	{
	//$Title Astrostein Commando
	Health 80;
	Scale 0.65;
	Obituary "$AGUARD2";
	}
	States
	{
	Spawn:
		ATR3 A 0;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		ATD3 A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
		"####" E 5 A_FaceTarget;
	Missile.Aimed:
		"####" F 5 A_FaceTarget;
		"####" G 0 A_StartSound("astrochaingun/fire");
		"####" G 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" F 5 A_MonsterRefire(30,"See");
		Goto Missile+1;
	Pain:
		"####" H 6 A_NaziPain(256);
		"####" H 0 A_Jump(256,"See");
		Stop;
	}
}

class AstroOfficer : AstroGuard
{	Default
	{
	//$Title Astrostein Officer
	Speed 5.33;
	Health 30;
	Scale 0.67;
	Obituary "$AGUARD3";
	}
	States
	{
	Spawn:
		ATR5 A 0;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		ATD5 A 0;
	Dodge.Resume:
		Goto See.Normal;
	Missile:
	Missile.Aimed:
		"####" G 5 A_FaceTarget;
		"####" G 0 A_StartSound("astrochaingun/fire");
		"####" E 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",32,1,random(-8,8));
		"####" F 5 A_MonsterRefire(30,"See");
		"####" E 8 A_Jump(256,"See");
		Stop;
	}
}

class AstroElite : AstroGuard
{	Default
	{
	//$Title Astrostein Elite
	Speed 5.0;
	Health 30;
	Scale 0.63;
	DropItem "AstroShotgun", 64;
	DropItem "AstroShotgunShell", 192;
	Obituary "$AGUARD4";
	}
	States
	{
	Spawn:
		ATR4 A 0;
		Goto Look;
	See:
		Goto See.Dodge;
	Dodge:
		ATD4 A 0;
	Dodge.Resume:
		Goto See.Fast; //now more faster - ozy81
	Missile:
		"####" F 8 A_FaceTarget;
	Missile.Aimed:
		"####" G 8 A_FaceTarget;
		"####" H 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		"####" H 3 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		"####" H 3 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-4,4));
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		"####" H 3 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
		"####" H 3 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-4,4));
		Goto See;
	Pain:
		"####" I 6 A_NaziPain(256);
		"####" I 0 A_Jump(256,"See");
		Stop;
	Death.Fire: //We don't want different Death sequences than the Disintegrate one for Astrosteins, yeah?
	XDeath:
	Death:
		ATR4 I 0 A_Jump(256,"Disintegrate");
	}
}

class AstroSuiteGuard : AstroGuard
{	Default
	{
	//$Title Astrostein Suit Guard
	Speed 2;
	Scale 0.70;
	Health 200;
	Painchance 16;
	+LOOKALLAROUND
	+NOBLOOD
	}
	States
	{
		Spawn:
			ROB1 A 0;
			Goto Look;
		See:
			"####" "#" 0 {
				user_incombat = True;
				if (bStandStill) { SetStateLabel("See.Stand"); }
			}
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" # 0 A_PlayStepSound(Base.Mech, 1.0, 0.15);
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" # 0 A_PlayStepSound(Base.Mech, 1.0, 0.15);
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		Missile:
		Missile.Aimed:
			"####" EF 5 A_FaceTarget;
			"####" F 0 A_StartSound("astrochaingun/fire");
			"####" G 0 A_SpawnProjectile("EnemyAstroTracer",48,-10,random(-8,4));
			"####" G 0 A_SpawnProjectile("EnemyAstroTracer",40,-10,random(-8,4));
			"####" G 0 A_SpawnProjectile("EnemyAstroTracer",40,10,random(4,-8));
			"####" G 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,10,random(4,-8));
			"####" E 8 A_Jump(256,"See");
			Stop;
		Pain:
			"####" H 3;
			"####" H 3 A_Pain;
			"####" H 0 A_Jump(256,"See");
			Stop;
		Death.Fire: //We don't want different Death sequences than the Disintegrate one for Astrosteins, yeah?
		XDeath:
		Death:
		Disintegrate:
			"####" I 0 A_StartSound("astrostein/guard_death");
			"####" I 0 A_Scream;
			"####" IIIIIJJJJJKKKKKLLLLLMMMMMNNNNNOOOOO 1 A_SpawnItemEx("BaseLine", random(16, -16), random(16, -16), random(0, 8), 0, 0, random(1,3), 0, 129, 0);
			"####" O 1 A_SpawnItemEx("AstroSuiteDropper", 0, 0, 0);
			Stop;
	}
}

class AstroScientist : AstroGuard
{	Default
	{
	//$Title Astro Scientist
	Scale 0.67;
	+FRIGHTENED
	Obituary "$SCIENTIST";
	Nazi.CanSurrender 1;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		SCN2 N 0;
		Goto Look;
	SurrenderSprite:
		SC2S E 0;
	See:
		Goto See.Normal;
	Missile: //different brightmap & colors - ozy81
		SCN2 E 5 A_FaceTarget;
	Missile.Aimed:
		"####" F 5 A_FaceTarget;
		"####" O 0 A_StartSound("astrochaingun/fire");
		"####" O 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",48,1,random(-8,8));
		"####" E 8 A_Jump(256,"See");
		Stop;
	}
}

class AstroDrone : Nazi
{	Default
	{
	//$Category Astrostein (BoA)/Monsters
	//$Title Astrostein Drone
	//$Color 4
	Scale 0.5;
	Health 200;
	Radius 31;
	Mass 400;
	Speed 2.66666667;
	PainChance 128;
	-FLOORCLIP
	+FLOAT
	+LOOKALLAROUND
	+NOBLOOD
	+NOGRAVITY
	SeeSound "drone_sight";
	PainSound "drone_pain";
	DeathSound "astrostein/explosion";
	ActiveSound "drone_act";
	Obituary "$ADRONE";
	}
	States
	{
	Spawn:
		DRON A 0;
		Goto Look;
	See:
		DRON A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		Loop;
	Idle:
		DRON AAABBB 1 A_Wander;
		"####" A 0 A_Look;
		Loop;
	Missile:
	Missile.Aimed:
		DRON EG 5 A_FaceTarget;
		"####" E 5 A_SpawnProjectile("AstroDroneBall",54,1,random(-8,8));
		Goto See;
	Pain:
	Pain.Dagger:
		DRON H 3;
		"####" H 3 A_Pain;
		"####" H 6;
		Goto See;
	Disintegrate:
	Death:
		DRON M 0 A_Scream;
		"####" M 0 A_SpawnItemEx("AstrosteinExplosion_Medium", 0, 0, 48);
		"####" M 0 A_SpawnItemEx("GeneralExplosion_ShockwaveGreen", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE); //so an effect is spawn even with boomswitch at 0 --ozy81
		"####" M 0 {A_NoBlocking(); bNoGravity = FALSE;}
		"####" M -1;
		Stop;
	}
}

class AstroTurret : MGTurret
{
	Default
	{
	//$Category Astrostein (BoA)/Monsters
	//$Title Astrostein Turret
	//$Color 4
	Scale 0.65;
	Speed 0;
	Obituary "$MGTURRET";
	Health 50;
	Radius 15;
	Height 21;
	PainChance 100;
	-FLOAT
	+DONTFALL
	+DONTTHRUST
	+MISSILEEVENMORE
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		ASTR A 0 NODELAY { user_incombat = TRUE; } //mxd
		Goto Look;
	Missile:
		"####" A 10 A_FaceTarget;
	Missile.Aimed:
		"####" A 5 A_FaceTarget;
		"####" B 0 A_StartSound("astrochaingun/fire");
		"####" C 3 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",4,0,random(-8,8));
		"####" B 3 A_MonsterRefire(40,"See");
		"####" B 0 A_FaceTarget;
		Goto Missile+1;
	Disintegrate: //do not disappear unlike other enemies, doesn't make sense --ozy81
	Death:
		TNT1 A 0 A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1);
		TNT1 A 0 A_SpawnItemEx("AstrosteinExplosion_Small");
		ASTR D -1;
		Stop;
	Crash:
		TNT1 A 0;
		Stop;
	Idle:
		Goto Look;
	}
}

//////////
//BOSSES//
//////////

class AstroCyborg1 : NaziBoss
{
	Default
	{
	//$Category Astrostein (BoA)/Monsters
	//$Title Astrostein Cyborg (1)
	//$Color 4
	Base.BossIcon "BOSSICON";
	Tag "$TAGASTROCYBORG";
	Health 500;
	Radius 31;
	Height 56;
	Mass 400;
	Speed 2.66666667;
	Scale 0.67;
	PainChance 32;
	+BOSS
	+LOOKALLAROUND
	+NOBLOOD
	Obituary "$ACYBORG";
	SeeSound "astrostein/cyborg_sight";
	PainSound "astrostein/cyborg_pain";
	DeathSound "astrostein/cyborg_death";
	ActiveSound "astrostein/cyborg_act";
	DropItem "AstroRocketAmmo", 128;
	}
	States
	{
	Spawn:
		CYB1 J 0;
		Goto Look;
	See:
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		Loop;
	Missile:
	Missile.Aimed:
		CYB1 G 10 A_FaceTarget;
		"####" H 0 A_ArcProjectile("AstroRocket",32,-32,random(-8,8),0,0,AAPTR_TARGET,0,22);
		"####" H 2 A_ArcProjectile("AstroRocket",32, 32,random(-8,8),0,0,AAPTR_TARGET,0,22);
		Goto See;
	Pain:
	Pain.Dagger:
		CYB1 I 3;
		"####" I 9 A_Pain;
		Goto See;
	Death:
		CYB1 J 8 A_Scream;
		"####" J 0 A_NoBlocking;
		"####" "#" 0 A_SpawnItemEx("BaseLine", random(32, -32), random(32, -32), random(0, 24), 0, 0, random(1,3), 0, 129, 0);
		"####" "#" 1 A_FadeOut(0.05);
		Goto Death+2;
	}
}

class AstroCyborg2 : AstroCyborg1
{	Default
	{
	//$Category Astrostein (BoA)/Monsters
	//$Title Astrostein Cyborg (2)
	//$Color 4
	DropItem "AstroShotgunShell", 256;
	DropItem "AstroShotgunShell", 256;
	}
	States
	{
	Spawn:
		CYB2 H 0;
		Goto Look;
	See:
		CYB2 A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" A 1 A_NaziChase;
		"####" AA 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" B 1 A_NaziChase;
		"####" BB 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" C 1 A_NaziChase;
		"####" CC 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		"####" D 1 A_NaziChase;
		"####" DD 1 A_NaziChase(null,null,CHF_NOPLAYACTIVE);
		Loop;
	Missile:
	Missile.Aimed:
		CYB2 E 10 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("AstroDroneBall",54,-32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" F 3 A_SpawnProjectile("AstroDroneBall",54, 32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" E 3 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("AstroDroneBall",54,-32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" F 3 A_SpawnProjectile("AstroDroneBall",54, 32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" E 3 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("AstroDroneBall",54,-32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" F 3 A_SpawnProjectile("AstroDroneBall",54, 32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" E 3 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("AstroDroneBall",54,-32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" F 3 A_SpawnProjectile("AstroDroneBall",54, 32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" E 3 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("AstroDroneBall",54,-32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" F 3 A_SpawnProjectile("AstroDroneBall",54, 32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" E 3 A_FaceTarget;
		"####" F 0 A_SpawnProjectile("AstroDroneBall",54,-32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" F 3 A_SpawnProjectile("AstroDroneBall",54, 32,random(-16,16), CMF_AIMDIRECTION|CMF_BADPITCH, random(-8,8));
		"####" E 3 A_FaceTarget;
		Goto See;
	Pain:
	Pain.Dagger:
		CYB2 G 3;
		"####" G 9 A_Pain;
		Goto See;
	Death:
		CYB2 H 8 A_Scream;
		"####" H 0 A_NoBlocking;
		Goto Super::Death+2;
	}
}

class AstroRobot : AstroCyborg1
{	Default
	{
	//$Category Astrostein (BoA)/Monsters
	//$Title Astrostein Robot
	//$Color 4
	Base.BossIcon "BOSSICON";
	Tag "$TAGROBOTER";
	Health 750;
	Scale 0.70;
	+AVOIDMELEE
	Obituary "$AROBOTO";
	SeeSound "astrostein/robot_sight";
	PainSound "astrostein/robot_pain";
	DeathSound "astrostein/robot_death";
	ActiveSound "astrostein/robot_act";
	DropItem "AstroRocketAmmo", 160;
	}
	States
	{
	Spawn:
		ROB2 A 0;
		Goto Look;
	Missile:
	Missile.Aimed:
		ROB2 HG 5 A_FaceTarget;
		"####" G 0 A_Jump(128, "Missile2","Missile3");
		"####" F 0 A_SpawnProjectile("AstroRobotSeekerBall",64,-36,random(-8,8));
		"####" F 5 A_SpawnProjectile("AstroRobotSeekerBall",64,36,random(-8,8));
		Goto See;
	Missile2:
		"####" F 5 A_SpawnProjectile("AstroRobotSeekerBall",64,-36,random(-8,8));
		Goto See;
	Missile3:
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 0 A_SpawnProjectile("EnemyAstroTracer",64,-36,random(-8,8));
		"####" F 8 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",64,36,random(-8,8));
		Goto See;
	Pain:
	Pain.Dagger:
		ROB2 H 3;
		"####" H 9 A_Pain;
		Goto See;
	Death.Fire: //We don't want different Death sequences than the Disintegrate one for Astrosteins, yeah?
	XDeath:
	Death:
	Disintegrate:
		ROB2 H 4 A_Scream;
		"####" IJKLMNO 12;
		"####" O 1 A_SpawnItemEx("AstroRobotDropper", 0, 0, 0);
		Stop;
	}
}

class AstroUrsel : AstroCyborg1
{	Default
	{
	//$Title Ursel Metzger (Boss)
	Base.BossIcon "BOSSICON";
	Tag "$TAGURSEL";
	Speed 5;
	Scale 0.70;
	Health 1500;
	Painchance 16;
	+AVOIDMELEE
	+LOOKALLAROUND
	-NOBLOOD
	Obituary "$AURSEL";
	SeeSound "BossGirl/Sighted";
	PainSound "BossGirl/Pain";
	DeathSound "BossGirl/Death";
	ActiveSound "";
	DropItem "AstroRocketAmmo", 160;
	}
	States
	{
	Spawn:
		URSE A 0;
		Goto Look;
	See:
		URSE "#" 0 {
			user_incombat = True;
			if (bStandStill) { SetStateLabel("See.Stand"); }
		}
		"####" A 1 A_NaziChase;
		"####" AAA 1 A_NaziChase(null, null);
		"####" A 1 A_NaziChase;
		"####" AAA 1 A_NaziChase(null, null);
		"####" B 1 A_NaziChase;
		"####" # 0 A_PlayStepSound(Base.Mech, 1.0, 0.15);
		"####" BBB 1 A_NaziChase(null, null);
		"####" B 1 A_NaziChase;
		"####" BBB 1 A_NaziChase(null, null);
		"####" C 1 A_NaziChase;
		"####" CCC 1 A_NaziChase(null, null);
		"####" C 1 A_NaziChase;
		"####" CCC 1 A_NaziChase(null, null);
		"####" D 1 A_NaziChase;
		"####" # 0 A_PlayStepSound(Base.Mech, 1.0, 0.15);
		"####" DDD 1 A_NaziChase(null, null);
		"####" D 1 A_NaziChase;
		"####" DDD 1 A_NaziChase(null, null);
		"####" A 0 { return ResolveState("See"); }
	Missile:
	Missile.Aimed:
		URSE E 5 A_FaceTarget;
		"####" E 0 A_Jump(128, "Missile3");
		"####" E 0 A_Jump(128, 2);
		"####" E 0 A_Jump(128, "Missile2");
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_Jump(256,"See");
		Stop;
	Missile2: //3
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_Jump(256,"See");
		Stop;
	Missile2: //5
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_FaceTarget;
		"####" F 0 A_StartSound("astrochaingun/fire");
		"####" F 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,10,random(2,-2));
		"####" G 4 LIGHT("ASTROFIRE") A_SpawnProjectile("EnemyAstroTracer",40,4,random(2,-2));
		"####" E 5 A_Jump(256,"See");
		Stop;
	Pain:
	Pain.Dagger:
		URSE H 3;
		"####" H 9 A_Pain;
		Goto See;
	Death:
		URSE H 8 A_Scream;
		"####" H 0 A_NoBlocking;
		"####" "#" 0 A_SpawnItemEx("BaseLine", random(32, -32), random(32, -32), random(0, 24), 0, 0, random(1,3), 0, 129, 0);
		"####" "#" 1 A_FadeOut(0.05);
		Goto Death+2;
	}
}

class AstroHitler : NaziBoss
{	Default
	{
	//$Category Astrostein (BoA)/Monsters
	//$Title Hitler Cyborg
	//$Color 4
	Base.BossIcon "BOSSICO3";
	Tag "$TAGCYBERHITLER";
	Health 3000;
	Mass 1000;
	Height 72;
	Radius 36;
	Speed 0;
	Scale 2.0;
	PainChance 128;
	Monster;
	+BOSS
	+DONTTHRUST
	+FLOORCLIP
	+LOOKALLAROUND
	+NOBLOOD
	Obituary "$AHITLER";
	ActiveSound "astrostein/hitler_act";
	DeathSound "";
	SeeSound "";
	PainSound "";
	}
	States
	{
	Spawn:
		ADHI A 6 A_Look;
		Loop;
	See:
		ADHI ABC 6 A_Chase;
		Loop;
	Pain:
		ADHI E 3;
		"####" E 3 A_Pain;
		Goto See;
	Death:
		ADHI E 35 A_Scream;
		"####" E 0 A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1);
		"####" E 0 A_SpawnItemEx("GeneralExplosion_Medium");
		"####" E 25;
		"####" E 0 A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1);
		"####" E 0 A_SpawnItemEx("GeneralExplosion_Medium");
		"####" E 15;
		"####" E 0 A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1);
		"####" E 0 A_SpawnItemEx("GeneralExplosion_Large");
		"####" E 5;
		"####" E 0 A_StartSound("astrostein/explosion", CHAN_AUTO, 0, 1.0, 0.1);
		"####" E 0 A_SpawnItemEx("GeneralExplosion_Large");
		"####" FGHIJ 20;
		"####" J -1;
		Stop;
	}
}