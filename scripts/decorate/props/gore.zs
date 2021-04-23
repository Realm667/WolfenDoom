/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer
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

class NukageBody: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Nukage Body (floating)
		//$Color 4
		Radius 16;
		Height 12;
		Scale 0.75;
		+FLOATBOB
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		NUKG A -1;
		Stop;
	}
}

class NukageBody2 : NukageBody
{
	Default
	{
	//$Title Nukage Body
	-FLOATBOB
	}
	States
	{
	Spawn:
		NUKG B -1;
		Stop;
	}
}

class NukageBody3 : NukageBody2
{
	Default
	{
	//$Title Sludge Body
	}
	States
	{
	Spawn:
		NUKG C -1;
		Stop;
	}
}

class HungBody: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Hung Body
		//$Color 4
		Radius 8;
		Height 98;
		+NOGRAVITY
		+SOLID
		+SPAWNCEILING
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		HUNG A -1;
		Stop;
	}
}

class HungBodyMov : HungBody
{
	Default
	{
	//$Title Hung Body, Shaking
	}
	States
	{
	Spawn:
		HUNG BCCCCDDEEFFEEDDDCCBBB 1 A_SetTics (random(2,5));
		HUNG A 1 A_SetTics (random(80,160));
		Loop;
	}
}

class HungBody2 : HungBody
{
	Default
	{
	//$Title Hung Body (Prisoner 1)
	Height 64;
	Scale 0.65;
	}
	States
	{
	Spawn:
		HUNC A -1;
		Stop;
	}
}

class HungBody3 : HungBody2
{
	Default
	{
	//$Title Hung Body (Prisoner 2)
	}
	States
	{
	Spawn:
		HUNC B -1;
		Stop;
	}
}

class HungBody4 : HungBody2
{
	Default
	{
	//$Title Hung Body (Prisoner 3)
	Height 60;
	}
	States
	{
	Spawn:
		HUNC C -1;
		Stop;
	}
}

class DeadBody: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Dead Body (random)
		//$Color 4
		Radius 16;
		Height 12;
		Scale 0.65;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,"Breathing");
		BODY A -1;
		BODY B -1;
		BODY C -1;
		BODY D -1;
		BODY E -1;
		Stop;
	Breathing:
		BODY E 1 A_SetTics(Random(40,80));
		"####" F 1 A_SetTics(Random(8,16));
		"####" G 1 A_SetTics(Random(8,16));
		"####" H 1 A_SetTics(Random(8,16));
		"####" G 1 A_SetTics(Random(8,16));
		"####" F 1 A_SetTics(Random(8,16));
		Loop;
	}
}

class Skeleton1: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Skeleton with ribs
		//$Color 4
		Radius 16;
		Height 12;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		BONE A -1;
		Stop;
	}
}

class Skeleton2 : Skeleton1
{
	Default
	{
	//$Title Skeleton (random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		SKLT A -1;
		SKLT B -1;
		Stop;
	}
}

class EmptyCage: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Cage (empty)
		//$Color 4
		Radius 16;
		Height 64;
		Scale 0.5;
		+NOGRAVITY
		+SPAWNCEILING
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		CCLL A -1;
		Stop;
	}
}

class PileOfSkulls: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Pile of Skulls
		//$Color 4
		Radius 4;
		Height 64;
		Scale 0.5;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		SKLL A -1;
		Stop;
	}
}

class MacSkulls : PileOfSkulls
{
	Default
	{
	//$Title Skulls
	Radius 16;
	Height 24;
	Scale 0.65;
	}
	States
	{
	Spawn:
		SKLL B -1;
		Stop;
	}
}

class RandomDeadSoldier: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Dead Soldier (random)
		//$Color 4
		Radius 16;
		Height 8;
		Scale 0.5;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4);
		GRD2 M -1;
		PARA M -1;
		SSMG M -1;
		WAFF M -1;
		Stop;
	}
}

class DeadSSGuardPistol : RandomDeadSoldier
{
	Default
	{
	//$Title Dead SS Guard with Pistol (for C2M1)
	}
	States
	{
	Spawn:
		SSMG M -1;
		Stop;
	}
}

class RandomDeadMutant : RandomDeadSoldier
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Dead Mutant (random)
	//$Color 4
	Scale 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		MLMT P -1;
		MTNT O -1;
		SUPM O -1;
		Stop;
	}
}

class MutantSubject1: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Subject (1st variant)
		//$Color 4
		Radius 8;
		Height 64;
		Scale 1.1;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		ALMU A -1;
		Stop;
	}
}

class MutantSubject2 : MutantSubject1
{
	Default
	{
	//$Title Subject (2nd variant)
	}
	States
	{
	Spawn:
		ALMU B -1;
		Stop;
	}
}

class MutantSubject3 : MutantSubject1
{
	Default
	{
	//$Title Subject (3rd variant)
	}
	States
	{
	Spawn:
		ALMU C -1;
		Stop;
	}
}

class MutantSubjectRandom : RandomSpawner
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Random Mutant Subject (Static)
	//$Color 4
	//$Sprite ALMUA0
	Radius 16;
	Height 64;
	Scale 1.1;
	DropItem "MutantSubject3";
	DropItem "MutantSubject2";
	DropItem "MutantSubject1";
	}
}

class MutantSubjectWarped: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Random Mutant Subject (Special)
		//$Color 4
		//$Sprite ALMUA0
		Radius 8;
		Height 64;
		Scale 1.1;
		-NOGRAVITY
		+LOOKALLAROUND
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,"TheLoop1","TheLoop2","TheLoop3");
	TheLoop1:
		ALMU A 1 A_Warp(AAPTR_MASTER,0,0,0,0);
		Loop;
	TheLoop2:
		ALMU B 1 A_Warp(AAPTR_MASTER,0,0,0,0);
		Loop;
	TheLoop3:
		ALMU C 1 A_Warp(AAPTR_MASTER,0,0,0,0);
		Loop;
	}
}

class CagedBody: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Cage with Body
		//$Color 4
		Radius 16;
		Height 80;
		+NOGRAVITY
		+SPAWNCEILING
		Scale 0.7;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		DJCG A -1;
		Stop;
	}
}

class CreepySkulls: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Creepy Skulls (args, straight or side)
		//$Color 4
		//$Sprite DJSKC0
		//$Arg0 "Type"
		//$Arg0Tooltip "Pickup the desired type\nRandom: 0\nStraight: 1\nSide: 2"
		Radius 8;
		Scale 0.7;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Straight");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Side");
	Random: //fall through if set at 0
		DJSK C -1 A_Jump(128,1);
		DJSK D -1;
		Stop;
	Straight:
		DJSK C -1;
		Stop;
	Side:
		DJSK D -1;
		Stop;
	}
}

class CreepySkullsImpaled: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Creepy Impaled Skulls (args, 1 or 2 skulls)
		//$Color 4
		//$Sprite DJSKA0
		//$Arg0 "Type"
		//$Arg0Tooltip "Pickup the desired type\nRandom: 0\nOne Skull: 1\nTwo Skulls: 2"
		Radius 12;
		Height 40;
		Scale 0.7;
		ProjectilePassHeight 4;
		+NOTAUTOAIMED
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "OneSkull");
		TNT1 A 0 A_JumpIf(Args[0]==2, "TwoSkulls");
	Random: //fall through if set at 0
		DJSK A -1 A_Jump(128,1);
		DJSK B -1;
		Stop;
	OneSkull:
		DJSK A -1;
		Stop;
	TwoSkulls:
		DJSK B -1;
		Stop;
	}
}

class RandomBodyParts: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Body Parts (random)
		//$Color 4
		//$Sprite GOREE0
		Radius 8;
		Height 4;
		Scale 0.7;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12);
		GORE B -1;
		GORE C -1;
		GORE D -1;
		GORE E -1;
		GORE F -1;
		GORE G -1;
		GORE H -1;
		GORE I -1;
		GORE J -1;
		GORE K -1;
		GORE L -1;
		GORE M -1;
		Stop;
	}
}

class PrisonerGuts: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Tortured Prisoner with severed Guts (random)
		//$Color 4
		Radius 8;
		Height 32;
		Scale 0.7;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		GTS1 A -1;
		GTS2 A -1;
		Stop;
	}
}

class PrisonerSit1 : PrisonerGuts
{
	Default
	{
	//$Title Tortured Prisoner (random, black hair)
	//$Sprite SIT1A0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		SIT1 A -1;
		SIT1 B -1;
		SIT1 C -1;
		SIT1 D -1;
		SIT1 E -1;
		SIT1 F -1;
		SIT1 G -1;
		SIT1 H -1;
		SIT1 I -1;
		SIT1 J -1;
		Stop;
	}
}

class PrisonerSit2 : PrisonerGuts
{
	Default
	{
	//$Title Tortured Prisoner (random, chestnut hair)
	//$Sprite SIT2A0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		SIT2 A -1;
		SIT2 B -1;
		SIT2 C -1;
		SIT2 D -1;
		SIT2 E -1;
		SIT2 F -1;
		SIT2 G -1;
		SIT2 H -1;
		SIT2 I -1;
		SIT2 J -1;
		Stop;
	}
}

class PrisonerSit3 : PrisonerGuts
{
	Default
	{
	//$Title Tortured Prisoner (random, blonde hair)
	//$Sprite SIT3A0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		SIT3 A -1;
		SIT3 B -1;
		SIT3 C -1;
		SIT3 D -1;
		SIT3 E -1;
		SIT3 F -1;
		SIT3 G -1;
		SIT3 H -1;
		SIT3 I -1;
		SIT3 J -1;
		Stop;
	}
}

class PrisonerSitRandom : RandomSpawner
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Tortured Male Prisoner Spawner (random)
	//$Color 4
	//$Sprite SIT1E0
	DropItem "PrisonerSit1";
	DropItem "PrisonerSit2";
	DropItem "PrisonerSit3";
	}
}

class PrisonerMaleHang1 : HungBody
{
	Default
	{
	//$Title Hanging Male Prisoner (random, black hair, detailed)
	//$Sprite HAN1A0
	Radius 8;
	Height 56;
	Scale 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,7);
		HAN1 A -1;
		HAN1 B -1;
		HAN1 C -1;
		HAN1 D -1;
		HAN1 E -1;
		Stop;
	Swinging:
		HAN1 A 1 A_SetTics(Random(80,160));
		HAN1 F 8;
		HAN1 G 8;
		HAN1 F 8;
		Loop;
	}
}

class PrisonerMaleHang2 : HungBody
{
	Default
	{
	//$Title Hanging Male Prisoner (random, blonde hair, detailed)
	//$Sprite HAN2A0
	Radius 8;
	Height 56;
	Scale 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,7);
		HAN2 A -1;
		HAN2 B -1;
		HAN2 C -1;
		HAN2 D -1;
		HAN2 E -1;
		Stop;
	Swinging:
		HAN2 A 1 A_SetTics(Random(80,160));
		HAN2 F 8;
		HAN2 G 8;
		HAN2 F 8;
		Loop;
	}
}

class PrisonerMaleHang3 : HungBody
{
	Default
	{
	//$Title Hanging Male Prisoner (random, chestnut hair, detailed)
	//$Sprite HAN3A0
	Radius 8;
	Height 56;
	Scale 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,7);
		HAN3 A -1;
		HAN3 B -1;
		HAN3 C -1;
		HAN3 D -1;
		HAN3 E -1;
		Stop;
	Swinging:
		HAN3 A 1 A_SetTics(Random(80,160));
		HAN3 F 8;
		HAN3 G 8;
		HAN3 F 8;
		Loop;
	}
}

class HangingPara1 : HungBody
{
	Default
	{
	//$Title Hanging Marine Paratrooper (long rope, random)
	//$Sprite PARLA0
	Radius 8;
	Height 128;
	Scale 0.67;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5);
		PARL A -1;
		PARL B -1;
		PARL C -1;
		PARL D -1;
		PARL E -1;
		Stop;
	}
}

class HangingPara2 : HangingPara1
{
	Default
	{
	//$Title Hanging Marine Paratrooper (short rope, random)
	//$Sprite PARTA0
	Height 56;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5);
		PART A -1;
		PART B -1;
		PART C -1;
		PART D -1;
		PART E -1;
		Stop;
	}
}

class CyanideProp1: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Brass Cyanide Container (side)
		//$Color 4
		Radius 2;
		Height 2;
		Scale 0.14;
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		CYAN A -1;
		Stop;
	}
}

class CyanideProp2 : CyanideProp1
{
	Default
	{
	//$Title Brass Cyanide Container (front)
	Scale 0.18;
	}
	States
	{
	Spawn:
		CYAN B -1;
		Stop;
	}
}

class CobwebBody : HungBody
{
	Default
	{
	//$Title Entangled Body in Cobweb, shootable
	Radius 16;
	Height 92;
	Health 25;
	Scale 0.75;
	+DONTFALL
	+DONTTHRUST
	+NOBLOOD
	+NOBLOODDECALS
	+NOTAUTOAIMED
	+SHOOTABLE
	}
	States
	{
	Spawn:
		COBW A -1;
		Stop;
	Death:
		COBW B -1;
		Stop;
	}
}

class CobwebNest : CobwebBody
{
	Default
	{
	//$Title Spiders Nest, shootable
	}
	States
	{
	Spawn:
		COBW C -1;
		Stop;
	Death:
		COBW D 1 A_UnSetSolid;
		COBW DDDD 0 A_SpawnItemEx("Debris_Web", frandom(-32.0,32.0), frandom(-16.0,16.0), frandom(-4.0,-8.0), frandom(-1.0,-2.0), -1, -1, random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		COBW DDD 0 A_SpawnItemEx("Debris_Web", frandom(-32.0,32.0), frandom(-16.0,16.0), frandom(-4.0,-8.0), frandom(-1.0,-2.0), -1, -1, random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		COBW DD 0 A_SpawnItemEx("Debris_Web", frandom(-32.0,32.0), frandom(-16.0,16.0), frandom(-4.0,-8.0), frandom(-1.0,-2.0), -1, -1, random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		COBW D 1 A_Jump(128,"Death1","Death2","Death3");
	Death1:
		COBW D 1 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D -1;
		Stop;
	Death2:
		COBW D 1 A_SpawnItemEx("BigSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("BigSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("BigSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D -1;
		Stop;
	Death3:
		COBW D 1 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("BigSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("BigSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D 0 A_SpawnItemEx("MiniSpiderNest",frandom(-24.0,24.0),frandom(-16.0,16.0),frandom(-4.0,-16.0),0 ,0 ,0 ,random(0,360), SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		COBW D -1;
		Stop;
	}
}

//3d Actors
class Skeleton3: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Skeleton Arms
		//$Color 4
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 51;
		+NOGRAVITY
		+SPAWNCEILING
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class SkeletonChains : Skeleton3
{
	Default
	{
	//$Title Skeleton Chains
	Height 41;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class Manacles: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Wall Manacles (with Type args)
		//$Color 4
		//$Arg0 "Type"
		//$Arg0Tooltip "Pickup the desired type\nRandom: 0\nNormal: 1\nWith Hands: 2\nRusty: 3"
		DistanceCheck "boa_scenelod";
		Radius 1;
		Height 32;
		+NOGRAVITY
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Type1");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Type2");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Type3");
	Random: //fall through if set at 0
		MDLA A -1 A_Jump(128,1);
		MDLA B -1 A_Jump(128,1);
		MDLA C -1;
		Stop;
	Type1:
		MDLA A -1;
		Stop;
	Type2:
		MDLA B -1;
		Stop;
	Type3:
		MDLA C -1;
		Stop;
	}
}

//Doom Replacements (these were) - Had to include new actors for these since they doesn't seem to work with .ipk3 file - ozy81
class WolfBloodPool: SceneryBase // Modified Jaguar Wolf3D water pool sprite
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Replacement for BloodPool actor
		//$Color 4
		Radius 20;
		Height 1;
		Scale 0.5;
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		POB2 A -1;
		Stop;
	}
}

class WolfColonGibs : WolfBloodPool // Re-use a gore gib that's close to the original Doom sprite
{
	Default
	{
	//$Title Replacement for ColonGibs actor
	Height 4;
	Scale 0.5;
	}
	States
	{
	Spawn:
		GORE K -1;
		Stop;
	}
}