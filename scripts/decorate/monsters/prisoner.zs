/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, MaxED, AFADoomer,
 *                         Talon1024
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

class PrisonerAgentTalk: StatistBarkeeper
{
	Default
	{
	//$Category Conversation Stuff (BoA)/NPCs
	//$Title Cpt. James Ryan (uniform, talking)
	//$Color 5
	Scale 0.67;
	Mass 100;
	Radius 6;
	Height 52;
	+SOLID
	+INVULNERABLE
	}
	States
	{
	Spawn:
		FREE A -1;
		Stop;
	}
}

class PrisonerDeco : PrisonerAgentTalk
{
	Default
	{
	//$Title Cpt. James Ryan (decoration for scenes)
	+CLIENTSIDEONLY
	+NOINTERACTION
	-SOLID
	}
}

class PrisonerFree : DirtyDarren
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title Cpt. James Ryan (uniform, npc)
	//$Color 4
	Obituary "$MARINE";
	}
	States
	{
	Spawn:
		FREE A 0;
		Goto Look;
	See:
		Goto See.Normal;
	Death:
		"####" J 5;
		"####" K 5 A_Scream;
		"####" L 5 A_NoBlocking;
		"####" MN 5;
		"####" O -1;
		Stop;
	Pain:
		"####" I 6 A_NaziPain;
		"####" I 0 A_Jump(256,"See");
		Stop;
	Raise:
		"####" ONMLKJ 5;
		Goto See;
	CapturedDarren:
		FREE O random(105,175);
		"####" P 35;
		Loop;
	ShootCapturedDarren: // Length is 27 tics
		FREE Q 2 A_StartSound("nazi/pistol");
		"####" Q 0 A_SpawnItemEx("NashGore_Blood", 2.0, 9.0, 36.0);
		"####" Q 0 A_StartSound("Nazi1/Death");
		"####" RSTUV 5;
		"####" V 0 A_SpawnItemEx("DyingDarren", 0.0, -16.0, 0.0);
		Goto Spawn;
	DreamDisappear:
		FREE A 1 A_FadeOut(0.01);
		Loop;
	// Used in C1M4 scripted scene
	Stand:
		FREE A -1;
		Stop;
	Draw:
		"####" F 5;
		"####" G -1;
		Stop;
	Fire:
		"####" H 5 LIGHT("NAZIFIRE") {
			A_StartSound("g43/fire");
			A_SpawnProjectile("ThompsonTracer", 32, 0, Random(-8, 8));
		}
		"####" G 15;
		"####" F -1;
		Stop;
	}
}

class DyingDarren: Actor
{
	Default
	{
	Translation 1;
	Scale 0.65;
	+FLOORCLIP
	}
	States
	{
	Spawn:
		DARR M -1;
		Stop;
	}
}

class HealingParticle: Actor
{
	Default
	{
	+DONTSPLASH
	+FORCEXYBILLBOARD
	+MISSILE
	+NOBLOCKMAP
	+NOGRAVITY
	Radius 0;
	Height 0;
	RenderStyle "Add";
	Alpha 0.01;
	Scale 0.4;
	}
	States
	{
	Spawn:
		HELX A 0 NODELAY A_SetScale(frandom(0.2, 0.6));
		"####" AAAAAAAAAA 1 A_FadeIn(0.07);
		"####" AAAAAAAAAA 8 A_FadeOut(0.08);
	Death:
		"####" A 1 BRIGHT A_FadeOut(0.1);
		Loop;
	}
}

class PrisonerMedikitCounter : Inventory { Default { Inventory.MaxAmount 3; } }

class PrisonerEnemyBoss : DirtyDarren
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title Cpt. James Ryan (uniform, boss, hostile)
	//$Color 4
	Tag "$TAGJRYAN";
	Obituary "$MARINE";
	Health 1200;
	SeeSound "prisoner/sight";
	DeathSound "prisoner/death";
	PainSound "prisoner/pain";
	Painchance 40;
	Painchance "Fire", 8;
	Mass 800;
	Speed 5;
	Species "Nazi";
	-FRIENDLY //Since DirtyDarren is set - ozy81
	+AVOIDMELEE
	+BOSS
	+LOOKALLAROUND
	+MISSILEEVENMORE
	+MISSILEMORE
	}
	States
	{
	Spawn:
		FREE A 0;
		Goto Look;
	Heal:
		"####" F 0 A_StartSound("misc/health_pkup");
		"####" F 0 A_GiveInventory("PrisonerMedikitCounter", 1);
		"####" F 0 A_GiveInventory("Health", 500);
		"####" FFFFFFFFFF 2 A_SpawnItemEx("HealingParticle", random(10,-10), random(10,-10), random(16,64), 0, 0, random(1, 2), 0);
	See:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
	SeeLoop:
		"####" E 1 A_Chase(null,null,CHF_FASTCHASE);
		"####" EEE 1 A_Chase(null,null);
		"####" E 1 A_Chase;
		"####" EEE 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" # 0 A_PlayStepSound();
		"####" BBB 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null);
		"####" C 1 A_Chase(null,null,CHF_FASTCHASE);
		"####" CCC 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" # 0 A_PlayStepSound();
		"####" DDD 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null);
		Loop;
	Missile:
		"####" A 0 A_JumpIfInventory("PrisonerMedikitCounter", 3, 2);
		"####" A 0 A_JumpIfHealthLower(600, "Heal");
		"####" A 0 A_Jump(192, "MP40");
	Grenade:
		"####" F 16 A_FaceTarget;
		"####" F 10 A_ArcProjectile("HandGrenade",40,4,random(-8,8));
		Goto See;
	MP40:
		"####" FG 5 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" G 2 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		Goto See;
	Reload:
		"####" F 0 {bNoPain = TRUE;}
		"####" F 30 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" F 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		"####" "#" 0 A_Jump(256, "See");
	Death:
		"####" J 8;
		"####" K 8 A_Scream;
		"####" L 8 A_NoBlocking;
		"####" MN 8;
		"####" N -1;
		Stop;
	Pain:
		"####" I 6 A_NaziPain;
		Goto See;
	// Cheese-proofing - Talon1024
	// I would also like to add a "grenade toss" sound, but if I do, it will
	// affect all other enemies that toss grenades...
	Pain.Fire:
		"####" I 6 A_NaziPain;
		"####" I 0 A_Jump(64, "See");
		"####" F 3 A_FaceTarget;
		"####" F 10 A_ArcProjectile("HandGrenade",40,4,random(-8,8));
		Goto See;
	Raise:
		"####" NMLKJ 5;
		Goto See;
	}
}

class PrisonerEnemyBoss_End : ZombieStandard
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title Undead James Ryan (uniform, boss, hostile)
	//$Color 4
	Base.BossIcon "BOSSICO3";
	Tag "$TAGZJRYAN";
	Obituary "$ZRYAN";
	Health 4000;
	WoundHealth 2000;
	Painchance 40;
	Mass 800;
	Speed 6;
	+AVOIDMELEE
	+BOSS
	+LOOKALLAROUND
	+MISSILEMORE
	+INVULNERABLE
	DamageFactor "Rocket", 0.0;
	DropItem "Rune_Fa", 256;
	}
	States
	{
	Spawn:
		RYAZ A 0;
		Goto Look;
	Heal:
		"####" F 0 A_StartSound("misc/health_pkup");
		"####" F 0 A_GiveInventory("PrisonerMedikitCounter", 1);
		"####" F 0 A_GiveInventory("Health", 500);
		"####" FFFFFFFFFF 2 A_SpawnItemEx("HealingParticle", random(10,-10), random(10,-10), random(16,64), 0, 0, random(1, 2), 0);
	See:
		"####" "#" 0 { user_incombat = TRUE; } //mxd
	SeeLoop:
		"####" E 1 A_Chase(null,null,CHF_FASTCHASE);
		"####" EEE 1 A_Chase(null,null);
		"####" E 1 A_Chase;
		"####" EEE 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" # 0 A_PlayStepSound();
		"####" BBB 1 A_Chase(null,null);
		"####" B 1 A_Chase;
		"####" BBB 1 A_Chase(null,null);
		"####" C 1 A_Chase(null,null); //less erratic this way, fastchase called only once on state - ozy81
		"####" CCC 1 A_Chase(null,null);
		"####" C 1 A_Chase;
		"####" CCC 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" # 0 A_PlayStepSound();
		"####" DDD 1 A_Chase(null,null);
		"####" D 1 A_Chase;
		"####" DDD 1 A_Chase(null,null);
		Loop;
	Missile:
		"####" A 0 A_JumpIfInventory("PrisonerMedikitCounter", 3, 2);
		"####" A 0 A_JumpIfHealthLower(600, "Heal");
		"####" A 0 A_Jump(128, "Luger");
	Grenade:
		"####" F 0 A_Jump(128, "OccultFire");
		"####" F 0 A_Jump(128, "ZyklonFire");
		"####" F 16 A_FaceTarget;
		"####" F 10 A_ArcProjectile("HandGrenade",40,4,random(-8,8), CMF_OFFSETPITCH|CMF_BADPITCH, random(0,16));
		Goto See;
	Luger:
		"####" FG 5 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" H 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 2 A_FaceTarget;
		"####" H 0 A_StartSound("nazi/mp40", CHAN_WEAPON);
		"####" H 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemySMGTracer",50,4,random(-8,8));
		"####" G 2 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" G 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		Goto See;
	OccultFire:
		"####" OOPP 3 A_FaceTarget;
		"####" O 4 A_SpawnProjectile("OccultBlazeFlames",0,0,0,CMF_CHECKTARGETDEAD);
		"####" O 3;
		"####" P 4 A_SpawnProjectile("OccultBlazeFlames2",0,0,0,CMF_CHECKTARGETDEAD);
		"####" P 3;
		Goto See;
	ZyklonFire:
		"####" QQRR 3 A_FaceTarget;
		"####" Q 4 A_SpawnProjectile("OccultZyklonFlames",0,0,0,CMF_CHECKTARGETDEAD);
		"####" Q 3;
		"####" R 4 A_SpawnProjectile("OccultZyklonFlames2",0,0,0,CMF_CHECKTARGETDEAD);
		"####" R 3;
		Goto See;
	Reload:
		"####" F 0 {bNoPain = TRUE;}
		"####" F 30 A_StartSound("mp40/reload", CHAN_WEAPON);
		"####" F 0 A_SpawnItemEx("Casing9mm", 8,0,40, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		"####" "#" 0 A_Jump(256, "See");
	Death:
		"####" J 8;
		"####" K 8 A_Scream;
		"####" L 8 A_NoBlocking;
		"####" MN 8;
		"####" N -1;
		Stop;
	Pain:
		"####" I 6 A_NaziPain;
		"####" I 0 A_Jump(256,"See");
		Stop;
	}
}