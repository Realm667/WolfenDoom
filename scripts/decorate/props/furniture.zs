/*
 * Copyright (c) 2019-2021 Ozymandias81, AFADoomer
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

//2d actors
class Table1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Castle
		//$Title Table, random (1)
		//$Color 3
		Radius 24;
		Height 24;
		Scale 0.5;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		TBL1 A -1;
		TBL1 B -1;
		Stop;
	}
}

class Table2 : Table1
{
	Default
	{
	//$Title Table (2)
	}
	States
	{
	Spawn:
		TBL2 A -1;
		Stop;
	}
}

class Table3 : Table1
{
	Default
	{
	//$Title Table (3)
	}
	States
	{
	Spawn:
		TBL3 A -1;
		Stop;
	}
}

class Table4 : Table1
{
	Default
	{
	//$Title Table (4)
	}
	States
	{
	Spawn:
		TBL5 A -1;
		Stop;
	}
}

class Table5 : Table1
{
	Default
	{
	//$Title Table (5)
	}
	States
	{
	Spawn:
		TBL6 A -1;
		Stop;
	}
}

class Table6 : Table1
{
	Default
	{
	//$Title Table (6)
	}
	States
	{
	Spawn:
		TBL7 A -1;
		Stop;
	}
}

//3d actors - these are all scale sensible, watch out!
class Table7: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Castle
		//$Title Table (1, no chairs, meals & liquors)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 20;
		Height 27;
		Scale 1.15;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("WineBottle", random(-8, -3), random(-8, 8), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineBottle", random(3, 8), random(-8, 8), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineGlass", random(8, 16), random(-16, -8), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("StackedMeal", random(-16, -18), random(-16, -18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineGlass", random(-16, -8), random(8, 16), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineGlass", random(8, 16), random(8, 16), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A -1;
		Stop;
	}
}

class Table8 : Table7
{
	Default
	{
	//$Title Table (2, no chairs, nothing)
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class Table9 : Table7
{
	Default
	{
	//$Title Table (3, no chairs, kettle & cups)
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("Kettle", random(-4, -2), random(-4, 4), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("Cup1", random(-18, -12), random(-18, -12), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("Cup1", random(12, 18), random(-18, -12), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("Cup1", random(-18, -12), random(12, 18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("Cup1", random(12, 18), random(12, 18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A -1;
		Stop;
	}
}

class Table10 : Table7
{
	Default
	{
	//$Title Table (4, no chairs, nazi kettle & cups)
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("TeaPot2", random(-4, -2), random(-4, 4), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup3", random(-18, -12), random(-18, -12), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup4", random(12, 18), random(-18, -12), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup4", random(-18, -12), random(12, 18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup4", random(12, 18), random(12, 18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A -1;
		Stop;
	}
}

class Table11 : Table7
{
	Default
	{
	//$Title Table (5, no chairs, china setup)
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("TeaPot1", random(-4, -2), random(-4, 4), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup1", random(-18, -12), random(-18, -12), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup1", random(12, 18), random(-18, -12), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup1", random(-18, -12), random(12, 18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("TeaCup1", random(12, 18), random(12, 18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A -1;
		Stop;
	}
}

class Table12 : Table7
{
	Default
	{
	//$Title Table (6, no chairs, party meal & liquors)
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("WineBottle", random(-8, -3), random(-8, 8), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineBottle", random(3, 8), random(-8, 8), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineGlass", random(8, 16), random(-16, -8), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("StackedPartyMeal", random(-16, -18), random(-16, -18), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineGlass", random(-16, -8), random(8, 16), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A 0 A_SpawnItemEx("WineGlass", random(8, 16), random(8, 16), 27, 0, 0, 0, 0, 0, 128, tid);
		"####" A -1;
		Stop;
	}
}

class CafeStuff : Table7
{
	Default
	{
	//$Category Props (BoA)/Street
	//$Title Table with Umbrella (no chairs, umbrella and cups)
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("TeaCup3", random(-24, -16), random(-24, -16), 32, 0, 0, 0, 0, 0, 128);
		"####" A 0 A_SpawnItemEx("Cup1", random(16, 24), random(-24, -16), 32, 0, 0, 0, 0, 0, 128);
		"####" A 0 A_SpawnItemEx("Cup1", random(-24, -16), random(16, 24), 32, 0, 0, 0, 0, 0, 128);
		"####" A 0 A_SpawnItemEx("TeaCup3", random(16, 24), random(16, 24), 32, 0, 0, 0, 0, 0, 128);
		"####" A -1;
		Stop;
	}
}

class BarSeat : BinWhite //linked to bureau.txt
{
	Default
	{
	//$Title Bar Chair (Destroyable)
	DistanceCheck "boa_scenelod";
	Radius 12;
	Height 24;
	Scale 1.0;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		"####" B -1;
		Stop;
	}
}

class ChairFuture : BarSeat
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Bar Chair (Modern, Destroyable)
	Radius 8;
	Height 16;
	}
	States
	{
	Death:
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("METLBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("MetalFrags");
		"####" B -1;
		Stop;
	}
}

class Chair1 : Plant1 //linked to bureau.txt
{
	Default
	{
	//$Title Chair (plain, wood)
	DistanceCheck "boa_scenelod";
	Height 20;
	Mass 999999;
	Scale 1.0;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Wood", random(10,30), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Wood", random(20,40), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		MDLA BCDEFG 1;
		MDLA H -1;
		Stop;
	}
}

class Chair2 : Chair1
{
	Default
	{
	//$Title Chair (office, wood & metal)
	}
	States
	{
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 {A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM); A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);}
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Wood", random(10,40), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Trash2", random(10,40), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		MDLA BCDEFGHIJKLMNO 1;
		MDLA P -1;
		Stop;
	}
}

class Chair3 : Chair1
{
	Default
	{
	//$Title Chair, Detailed (office, wood)
	}
	States
	{
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Wood", random(10,30), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Wood", random(20,40), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		MDLA BCDEFGHIJKLMNO 1;
		MDLA P -1;
		Stop;
	}
}

class Chair4 : Chair1
{
	Default
	{
	//$Title Chair (plain, metal)
	}
	States
	{
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Trash2", random(10,40), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		MDLA BCDEFG 1;
		MDLA H -1;
		Stop;
	}
}
