/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, AFADoomer
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

class JazzJackrabbit : CommanderKeen
{
	Default
	{
		//$Category EasterEgg (BoA)
		//$Title Jazz Jackrabbit (Easteregg)
		//$Color 3
		Height 128;
		PainSound "jazz/pain";
		DeathSound "jazz/death";
	}
	States
	{
	Spawn:
		JAZZ A -1;
		Loop;
	Death:
		"####" AB 6;
		"####" C 6 A_Scream;
		"####" DEFGH 6 { A_SpawnItemEx("SingleCoin", 0, 0, random(4,8), frandom(0.5,1.5), frandom(0.5,1.5), frandom(1.0,4.0), random(0,360)); A_StartSound("treasure/pickup", 0, 0, 64, ATTN_IDLE, 0, frandom(-6.0, 6.0)); }
		"####" I 0 A_NoBlocking;
		"####" III 2 { A_SpawnItemEx("SingleCoin", 0, 0, random(4,8), frandom(0.5,1.5), frandom(0.5,1.5), frandom(1.0,4.0), random(0,360)); A_StartSound("treasure/pickup", 0, 0, 64, ATTN_IDLE, 0, frandom(-6.0, 6.0)); }
		"####" JJJ 2 { A_SpawnItemEx("SingleCoin", 0, 0, random(4,8), frandom(0.5,1.5), frandom(0.5,1.5), frandom(1.0,4.0), random(0,360)); A_StartSound("treasure/pickup", 0, 0, 64, ATTN_IDLE, 0, frandom(-6.0, 6.0)); }
		"####" K 6 A_KeenDie;
		"####" LLLLL 4 { A_SpawnItemEx("SingleCoin", 0, 0, random(4,8), frandom(0.5,1.5), frandom(0.5,1.5), frandom(1.0,4.0), random(0,360)); A_StartSound("treasure/pickup", 0, 0, 64, ATTN_IDLE, 0, frandom(-6.0, 6.0)); }
		"####" L -1;
		Stop;
	Pain:
		"####" M 4;
		"####" M 8 A_Pain;
		Goto Spawn;
	}
}

class Dogse: SceneryBase
{
	Default
	{
		//$Category EasterEgg (BoA)
		//$Title Dogse (Easteregg)
		//$Color 3
		Radius 16;
		Height 24;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		DOGS AB 5;
		Loop;
	}
}

class DogseResult : Dogse
{
	Default
	{
		//$Title Dogpuppy (Easteregg)
	}
	States
	{
	Spawn:
		PUPP AB 5;
		Loop;
	}
}

class BoAHead1 : Dogse
{
	Default
	{
		//$Title AFADoomer head (Easteregg)
		Height 64;
		Scale 0.67;
	}
	States
	{
	Spawn:
		RAFA A -1;
		Stop;
	}
}

class BoAHead2 : Dogse
{
	Default
	{
		//$Title DoomJuan head (Easteregg)
		Height 64;
		Scale 0.67;
	}
	States
	{
	Spawn:
		RDEA A -1;
		Stop;
	}
}

class BoAHead3 : Dogse
{
	Default
	{
		//$Title DoomJedi head (Easteregg)
		Height 64;
		Scale 0.67;
	}
	States
	{
	Spawn:
		RDJE A -1;
		Stop;
	}
}

class BoAHead4 : Dogse
{
	Default
	{
		//$Title T667 head (Easteregg)
		Height 64;
		Scale 0.67;
	}
	States
	{
	Spawn:
		RTOR A -1;
		Stop;
	}
}

class BoAHead5 : Dogse
{
	Default
	{
		//$Title Ozy81 head (Easteregg)
		Height 64;
		Scale 0.67;
	}
	States
	{
	Spawn:
		RVIR A -1;
		Stop;
	}
}

class BoABrain : BossBrain
{
	Default
	{
		//$Category EasterEgg (BoA)
		//$Title Romero Aged Head (Easteregg)
		Height 88;
	}
	States
	{
	Spawn:
		BOAR A -1;
		Stop;
	Pain:
		BOAR B 36 A_BrainPain;
		Goto Spawn;
	Death: //A_BrainDie removed otherwise it will end the map --Ozy81
		BOAR B 5 A_UnSetSolid;
		BOAR B 100 A_BrainScream;
		"####" BBBBBBBBBBBBBBBB 0 A_SpawnItemEx("BloodSkullCloud",random(-16,16),random(-16,16),random(24,48),random(1,2), random(1,2), random(1,2), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 0 A_SpawnItemEx("Debris_FatFlesh", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" BBBBBBBBBBBBBBBBBBBBBBBB 0 A_SpawnItemEx("Debris_Flesh", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" BBBBBBBBB 0 A_SpawnItemEx("NashGore_FlyingBlood", random(-16,16), random(-16,16), random(24,48), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" C -1;
		Stop;
	}
}

class BladeRunner : Dogse
{
	Default
	{
		//$Title Blade Runner Origami (Easteregg)
		Radius 2;
		Height 2;
		-SOLID
	}
	States
	{
	Spawn:
		BLAD A -1;
		Stop;
	}
}

class DSA1Pillar : Dogse
{
	Default
	{
		//$Title Arkania's Dungeon Pillar (Easteregg)
		Scale 0.33;
	}
	States
	{
	Spawn:
		ROAR A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
		Stop;
	}
}

class DSA1Female : Dogse
{
	Default
	{
		//$Title Arkania's Female Characters (Easteregg)
		Height 75;
		Scale 0.13;
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		ARKA A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
	Randomize:
		ARKA A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12");
		Stop;
	Pose1:
		"####" A -1;
		Stop;
	Pose2:
		"####" D -1;
		Stop;
	Pose3:
		"####" E -1;
		Stop;
	Pose4:
		"####" H -1;
		Stop;
	Pose5:
		"####" J -1;
		Stop;
	Pose6:
		"####" L -1;
		Stop;
	Pose7:
		"####" N -1;
		Stop;
	Pose8:
		"####" O -1;
		Stop;
	Pose9:
		"####" Q -1;
		Stop;
	Pose10:
		"####" T -1;
		Stop;
	Pose11:
		"####" V -1;
		Stop;
	Pose12:
		"####" X -1;
		Stop;
	}
}

class DSA1Male : Dogse
{
	Default
	{
		//$Title Arkania's Male Characters (Easteregg)
		Height 75;
		Scale 0.13;
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		ARKA B 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
	Randomize:
		ARKA B 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12");
		Stop;
	Pose1:
		"####" B -1;
		Stop;
	Pose2:
		"####" C -1;
		Stop;
	Pose3:
		"####" F -1;
		Stop;
	Pose4:
		"####" G -1;
		Stop;
	Pose5:
		"####" I -1;
		Stop;
	Pose6:
		"####" K -1;
		Stop;
	Pose7:
		"####" M -1;
		Stop;
	Pose8:
		"####" P -1;
		Stop;
	Pose9:
		"####" R -1;
		Stop;
	Pose10:
		"####" S -1;
		Stop;
	Pose11:
		"####" U -1;
		Stop;
	Pose12:
		"####" W -1;
		Stop;
	}
}

class NaziDopefish : Dogse
{
	Default
	{
		//$Title Nazi Dopefish (Easteregg)
		Radius 8;
		Height 16;
		Scale 1;
	}
	States
	{
	Spawn:
		DOPE A -1;
		Stop;
	}
}

class T100Lava : Dogse
{
	Default
	{
		//$Title Terminator 100 (Easteregg)
		Radius 2;
		Height 8;
		Scale 0.7;
	}
	States
	{
	Spawn:
		T100 A -1;
		Stop;
	}
}

class Roswell : Dogse
{
	Default
	{
		//$Title Roswell Gray Alien (Easteregg)
		Radius 8;
		Height 8;
		Scale 0.7;
	}
	States
	{
	Spawn:
		ROSW A -1;
		Stop;
	}
}

class MrSpock : Dogse
{
	Default
	{
		//$Title Mr. Spock (Easteregg)
		Radius 12;
		Height 56;
		Scale 0.5;
	}
	States
	{
	Spawn:
		MRSP A -1;
		Stop;
	}
}

class BillyBlaze : MrSpock
{
	Default
	{
		//$Title BillyBlaze (Easteregg)
		Scale 2.0;
	}
	States
	{
	Spawn:
		KIIN A -1;
		Stop;
	}
}

class Predator : MrSpock
{
	Default
	{
		//$Title Predator (Easteregg)
		Scale 1.0;
	}
	States
	{
	Spawn:
		PRED A -1;
		Stop;
	}
}

class Alien : MrSpock
{
	Default
	{
		//$Title Alien (Easteregg)
		Scale 1.0;
	}
	States
	{
	Spawn:
		ALIN A -1;
		Stop;
	}
}

class SoloChewbie : MrSpock
{
	Default
	{
		//$Title Solo & Chewbie (Easteregg)
		Scale 1.3;
	}
	States
	{
	Spawn:
		HSCB A -1;
		Stop;
	}
}

class Cedric : MrSpock
{
	Default
	{
		//$Title King's Quest 5 Cedric (Easteregg)
		Scale 1.3;
	}
	States
	{
	Spawn:
		KQ5C A -1;
		Stop;
	}
}

class KingsQuest5 : MrSpock
{
	Default
	{
		//$Title King's Quest 5 (Easteregg)
		Scale 1.3;
	}
	States
	{
	Spawn:
		KQ5C B -1;
		Stop;
	}
}

class RogerWilco : MrSpock
{
	Default
	{
		//$Title Roger Wilco (Easteregg)
		Scale 0.5;
	}
	States
	{
	Spawn:
		ROWI A -1;
		Stop;
	}
}

class BDDoll : Dogse
{
	Default
	{
		//$Title Brutal Doomguy Doll (Easteregg)
		Height 8;
		Radius 8;
		Scale 1.1;
	}
	States
	{
	Spawn:
		DDOL A -1;
		Stop;
	}
}

class IndianaJones : Dogse
{
	Default
	{
		//$Title Indiana Jones (Easteregg)
		Height 64;
	}
	States
	{
	Spawn:
		INDY A 70;
		"####" B 20;
		"####" C 70;
		"####" DEFEDBC 10;
		"####" D 20;
		Loop;
	}
}

class IndianaJonesGirl : IndianaJones
{
	Default
	{
		//$Title Sophia Hapgood (Easteregg)
	}
	States
	{
	Spawn:
		INDY M 140;
		"####" GHIJKL 10;
		Loop;
	}
}

class LaraCroft : Dogse
{
	Default
	{
		//$Title Lara Croft (Easteregg)
		Scale 0.2;
	}
	States
	{
	Spawn:
		LARC A -1;
		Stop;
	}
}

class AsterixObelix : Dogse
{
	Default
	{
		//$Title Asterix & Obelix (Easteregg)
		Height 64;
		Scale 1.4;
		+WALLSPRITE
	}
	States
	{
	Spawn:
		ASXT A 70;
		"####" B 20;
		"####" C 20;
		"####" DE 70;
		"####" DCB 140;
		Loop;
	}
}

class NaziCakeBabe : Dogse
{
	Default
	{
		//$Title Nazi Birthday Cake Babe
		Radius 4;
		Height 32;
		Health 20;
		PainChance 255;
		Mass 0x7ffffff;
		-DROPOFF
		+CANPASS
		+DONTFALL
		+NOTAUTOAIMED
		+SHOOTABLE
		PainSound "BossGirl/pain";
		DeathSound "BossGirl/Death";
	}
	States
	{
	Spawn:
		BAB3 A 1 A_SetTics(Random(80,160));
		"####" B 8;
		"####" C 8;
		"####" BD 8;
		"####" BD 8;
		"####" EFEF 8;
		"####" EF 8;
		"####" B 8;
		Loop;
	Death:
		"####" G 6;
		"####" H 6 A_Scream;
		"####" IJ 6 A_SpawnItemEx("CupCake1", random(16,-16), random(16,-16), random(4,8), frandom(2.5,4.5), frandom(2.5,4.5), frandom(1.0,4.0), random(0,360));
		"####" J 0 A_NoBlocking;
		"####" J 0 A_SpawnItemEx("CupCake2", random(16,-16), random(16,-16), random(4,8), frandom(2.5,4.5), frandom(2.5,4.5), frandom(1.0,4.0), random(0,360));
		"####" J 0 A_SpawnItemEx("CupCake3", random(16,-16), random(16,-16), random(4,8), frandom(2.5,4.5), frandom(2.5,4.5), frandom(1.0,4.0), random(0,360));
		"####" J 0 A_SpawnItemEx("CupCake4", random(16,-16), random(16,-16), random(4,8), frandom(2.5,4.5), frandom(2.5,4.5), frandom(1.0,4.0), random(0,360));
		"####" K -1;
		Stop;
	Pain:
		"####" G 2;
		"####" G 4 A_Pain;
		Goto Spawn;
	}
}

//3d actors
class Tie_Fighter : Dogse //ozy81
{
	Default
	{
		//$Title Tie Fighter (Easteregg)
		DistanceCheck "boa_scenelod";
		Radius 48;
		Height 192;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}