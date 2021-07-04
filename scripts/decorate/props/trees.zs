/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, AFADoomer,
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

class TreeBase : TreesBase
{
	Default
	{
		Radius 16;
		Height 128;
	}
	
	States
	{
		Spawn:
			MDLA A -1;
			Stop;
		BidiSpawn:
			UNKN A -1; // spawn the UNKN sprite if not set, thanks to inheritances
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (boa_bidiswitch == 1)
		{
			SetStateLabel("BidiSpawn");
			A_2DPitchFix();
		}
		else
		{
			A_3DPitchFix();
		}
	}
}

class Tree1 : TreeBase
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Tree (snow)
	//$Color 3
	Radius 32;
	Height 192;
	+MOVEWITHSECTOR
	+RELATIVETOFLOOR
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE E -1;
		Stop;
	}
}

class Tree1_Plaza : Tree1
{
	Default
	{
	//$Title Tree (for Opera)
	Radius 16;
	Height 56;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE E -1;
		Stop;
	}
}

class Tree2 : Tree1
{
	Default
	{
	//$Title Tree (large)
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE D -1;
		Stop;
	}
}

class Tree3 : Tree1
{
	Default
	{
	//$Title Tree 1 (middle)
	Height 96;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE C -1;
		Stop;
	}
}

class Tree4 : Tree1
{
	Default
	{
	//$Title Tree 2 (middle)
	Height 96;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE B -1;
		Stop;
	}
}

class Palm1 : TreeBase
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Palm (center)
	//$Color 3
	DistanceCheck "boa_treeslod";
	+NOGRAVITY
	+SOLID
	}
	States
	{
	BidiSpawn:
		DTRE I -1;
		Stop;
	}
}

class Palm2 : Palm1
{
	Default
	{
	//$Title Palm (left)
	}
	States
	{
	BidiSpawn:
		DTRE J -1;
		Stop;
	}
}

class Palm3 : Palm1
{
	Default
	{
	//$Title Palm (right)
	}
	States
	{
	BidiSpawn:
		DTRE K -1;
		Stop;
	}
}

class Palm1NH : TreeBase //needed for INTERMAP - ozy81
{
	Default
	{
	//$Category Flora (BoA)/No Hitbox
	//$Title Palm (center, no hitbox)
	//$Color 3
	Radius 4;
	Height 4;
	-SOLID
	+NOBLOCKMAP
	+NOGRAVITY
	}
	States
	{
	BidiSpawn:
		DTRE I -1;
		Stop;
	}
}

class Palm2NH : Palm1NH
{
	Default
	{
	//$Title Palm (left, no hitbox)
	}
	States
	{
	BidiSpawn:
		DTRE J -1;
		Stop;
	}
}

class Palm3NH : Palm1NH
{
	Default
	{
	//$Title Palm (right, no hitbox)
	}
	States
	{
	BidiSpawn:
		DTRE K -1;
		Stop;
	}
}

class JungleTree1 : TreeBase
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Jungle Tree 1
	//$Color 3
	DistanceCheck "boa_treeslod";
	+SOLID
	}
	States
	{
	BidiSpawn:
		DTRE F -1;
		Stop;
	}
}

class JungleTree2 : JungleTree1
{
	Default
	{
	//$Title Jungle Tree 2 (wall)
	Height 32;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE G -1; //no pitch for this one
		Stop;
	}
}

class JungleTree3 : JungleTree1
{
	Default
	{
	//$Title Jungle Tree 3 (bamboo)
	DistanceCheck "boa_treeslod";
	}
}

class WinterA : TreeBase
{
	Default
	{
	Height 115;
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE L -1;
		Stop;
	}
}

class WinterB : WinterA
{
	Default
	{
	Radius 15;
	Height 90;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE M -1;
		Stop;
	}
}

class WinterC : WinterA
{
	Default
	{
	Height 140;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE O -1;
		Stop;
	}
}

class WinterD : TreeBase
{
	Default
	{
	Height 60;
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE P -1;
		Stop;
	}
}

class WinterE : WinterA
{
	Default
	{
	Radius 10;
	Height 45;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE Q -1;
		Stop;
	}
}

class WinterF : WinterA
{
	Default
	{
	Radius 10;
	Height 110;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE R -1;
		Stop;
	}
}

class WinterG : WinterA
{
	Default
	{
	Radius 25;
	Height 130;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE S -1;
		Stop;
	}
}

class WinterH : WinterA
{
	Default
	{
	Radius 25;
	Height 130;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE T -1;
		Stop;
	}
}

class WinterI : WinterA
{
	Default
	{
	Radius 25;
	Height 130;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE U -1;
		Stop;
	}
}

class SmallTree1 : TreeBase
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Tree 4 (middle)
	//$Color 3
	Height 96;
	+MOVEWITHSECTOR
	+RELATIVETOFLOOR
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE A -1;
		Stop;
	}
}

class SmallTree2 : SmallTree1
{
	Default
	{
	//$Title Tree 5 (small)
	Height 64;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE H -1;
		Stop;
	}
}

//Burnt variants - Ozymandias81
class Tree1_Burnt : TreeBase // changes visible only with 3d trees, this actor is special and used only on c3m5_b cyan key sequence - ozy81
{
	Default
	{
	Radius 32;
	Height 192;
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DTRE E -1;
		Stop;
	}
}

class Tree2_Burnt : TreeBase
{
	Default
	{
	//$Category Flora (BoA)/Burnt
	//$Title Tree (burnt, large)
	//$Color 3
	Radius 32;
	Height 192;
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DBUR D -1;
		Stop;
	}
}

class Tree3_Burnt : Tree2_Burnt
{
	Default
	{
	//$Title Tree 1 (burnt, middle)
	Height 96;
	+NOGRAVITY
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DBUR E -1;
		Stop;
	}
}

class Tree4_Burnt : Tree2_Burnt
{
	Default
	{
	//$Title Tree 2 (burnt, middle)
	Height 96;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DBUR F -1;
		Stop;
	}
}

class JungleTree1_Burnt : TreeBase
{
	Default
	{
	//$Category Flora (BoA)/Burnt
	//$Title Jungle Tree 1 (Burnt)
	//$Color 3
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DBUR A -1;
		Stop;
	}
}

class JungleTree2_Burnt : JungleTree1_Burnt
{
	Default
	{
	//$Title Jungle Tree 2 (burnt, wall)
	Height 32;
	+NOGRAVITY
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DBUR B -1; //no pitch for this one
		Stop;
	}
}

class SmallTree1_Burnt : TreeBase
{
	Default
	{
	//$Category Flora (BoA)/Burnt
	//$Title Tree 4 (burnt, middle)
	//$Color 3
	Height 96;
	+SOLID
	DistanceCheck "boa_treeslod";
	}
	States
	{
	BidiSpawn:
		DBUR C -1;
		Stop;
	}
}

//2d actors
class CeilingGrass : GrassBase
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Ceiling Grass
	//$Color 3
	Radius 16;
	Height 24;
	+FORCEYBILLBOARD
	+NOGRAVITY
	+SPAWNCEILING
	+WALLSPRITE
	DistanceCheck "boa_grasslod";
	}
	States
	{
	Spawn:
		CLGR A -1;
		Stop;
	}
}

class SmallBush1 : TreesBase
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Bush 1
	//$Color 3
	-SOLID
	Radius 16;
	Height 24;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	Spawn:
		BUSN A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
		Stop;
	}
}

class SmallBush2 : SmallBush1
{
	Default
	{
	//$Title Bush 2
	Height 40;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	Spawn:
		BUSN B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
		Stop;
	}
}

class Bush : SmallBush1
{
	Default
	{
	//$Title Bush (small)
	Height 32;
	DistanceCheck "boa_treeslod";
	}
	States
	{
	Spawn:
		BUSH A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
		Stop;
	}
}

class BigBush : SmallBush1
{
	Default
	{
	//$Title Bush (big, rippable)
	Height 32;
	Health 1;
	+SOLID
	+DONTTHRUST
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	DistanceCheck "boa_treeslod";
	}
	States
	{
	Spawn:
		BUSZ A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "####" 0 A_SpawnItemEx("Debris_Leaf", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 2 A_SpawnItemEx("GrassFrags");
		BUSZ B -1;
		Stop;
	}
}

class RandomRye : FlattenableProp
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Random Rye
	//$Color 3
	//$Sprite RYE_A0
	Radius 8;
	Height 32;
	Scale 0.8;
	DistanceCheck "boa_grasslod";
	}
	States
	{
	Spawn:
		RYE_ A 0 NODELAY A_Jump(256, "RyeA", "RyeB", "RyeC", "RyeD", "RyeE", "RyeF");
		Stop;
	RyeA:
		RYE_ A 0;
		Goto Setup;
	RyeB:
		RYE_ B 0;
		Goto Setup;
	RyeC:
		RYE_ C 0;
		Goto Setup;
	RyeD:
		RYE_ D 0;
		Goto Setup;
	RyeE:
		RYE_ E 0;
		Goto Setup;
	RyeF:
		RYE_ F 0;
		Goto Setup;
	Setup:
		"####" "#" 0 A_SetScale(Scale.X * frandom(0.85, 1.1), Scale.Y * frandom(0.85, 1.1));
		"####" "#" -1 A_SetScale(Scale.X * RandomPick(-1.0, 1.0), Scale.Y);
		Stop;
	}
}

//Randomizers
class BurnTreeSpawner : RandomSpawner
{
	Default
	{
	//$Category Flora (BoA)/Burnt
	//$Title Trees (burnt, random spawner)
	//$Color 3
	//$Sprite DBURA0
	DropItem "Tree2_Burnt";
	DropItem "Tree3_Burnt";
	DropItem "Tree4_Burnt";
	DropItem "JungleTree1_Burnt";
	DropItem "SmallTree1_Burnt";
	}
}

class SummerTreeSpawner : RandomSpawner
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Tree (Summer, random spawner)
	//$Color 3
	//$Sprite DTRED0
	DropItem "Bush";
	DropItem "Tree2";
	DropItem "Tree3";
	DropItem "Tree4";
	DropItem "SmallTree1";
	DropItem "SmallTree2";
	}
}

class WinterTreeSpawner : RandomSpawner
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Tree (winter, random spawner)
	//$Color 3
	//$Sprite DTREE0
	DropItem "WinterA";
	DropItem "WinterB";
	DropItem "WinterC";
	DropItem "WinterD";
	DropItem "WinterE";
	DropItem "WinterF";
	DropItem "WinterG";
	DropItem "WinterH";
	DropItem "WinterI";
	}
}

class WoodyLogs : TreesBase
{
	Default
	{
	//$Category Flora (BoA)
	//$Title Small Pack of Logs (Woods)
	//$Color 3
	DistanceCheck "boa_treeslod";
	Radius 24;
	Height 24;
	Scale 0.65;
	+SOLID
	}
	States
	{
	Spawn:
		DJLG B -1;
		Stop;
	}
}

class SnowyLogs : WoodyLogs
{
	Default
	{
	//$Title Small Pack of Logs (Snow)
	DistanceCheck "boa_treeslod";
	}
	States
	{
	Spawn:
		DJLG A -1;
		Stop;
	}
}