/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, AFADoomer
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

class Ink1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Castle
		//$Title Ink, Yellow
		//$Color 3
		Radius 2;
		Height 2;
		Scale 0.2;
		+CANPASS
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		INKY A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Ink2 : Ink1
{
	Default
	{
	//$Title Ink, Blue
	}
	States
	{
	Spawn:
		INKY B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Ink3 : Ink1
{
	Default
	{
	//$Title Ink, Red
	}
	States
	{
	Spawn:
		INKY C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Ink4 : Ink1
{
	Default
	{
	//$Title Ink, Green
	}
	States
	{
	Spawn:
		INKY D -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Ink5 : Ink1
{
	Default
	{
	//$Title Ink, Black
	}
	States
	{
	Spawn:
		INKY E -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Ink6 : Ink1
{
	Default
	{
	//$Title Stilo Pen with Holder
	}
	States
	{
	Spawn:
		PENS A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class MonsterStatue: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Castle
		//$Title Monster Statue (Red Eyes)
		//$Color 3
		Radius 24;
		Height 64;
		Health 25;
		Mass 100000;
		Scale 0.5;
		+NOBLOOD
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		WSTA A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.3,0.5), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue4", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue4", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue4", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue4", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		WSTA C -1;
		Stop;
	}
}

class MonsterStatue2 : MonsterStatue
{
	Default
	{
	//$Title Monster Statue (Zyklon Eyes)
	}
	States
	{
	Spawn:
		WSTA B -1;
		Stop;
	}
}

class BronzeStatueA : SwitchableDecoration
{
	Default
	{
	//$Category Props (BoA)/Castle
	//$Title Arno Breker's Speer Statue, Bronze (Torch)
	//$Color 3
	Radius 24;
	Height 128;
	Health 25;
	Mass 100000;
	Scale 0.5;
	+FORCEYBILLBOARD
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	}
	States
	{
	Spawn:
		BRNZ A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.3,0.5), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		BRNZ G -1;
		Stop;
	Inactive:
		BRNZ A 0 A_UnsetSolid;
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class BronzeStatueB : BronzeStatueA
{
	Default
	{
	//$Title Arno Breker's Speer Statue, Bronze (Sword)
	}
	States
	{
	Spawn:
		BRNZ B -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		BRNZ H -1;
		Stop;
	Inactive:
		BRNZ B 0 A_UnsetSolid;
		"####" B -1 A_SetInvulnerable;
		Stop;
	}
}

class BronzeStatueC : BronzeStatueA
{
	Default
	{
	//$Title Arno Breker's Speer Statue, Gold (Torch)
	}
	States
	{
	Spawn:
		BRNZ C -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		BRNZ I -1;
		Stop;
	Inactive:
		BRNZ C 0 A_UnsetSolid;
		"####" C -1 A_SetInvulnerable;
		Stop;
	}
}

class BronzeStatueD : BronzeStatueA
{
	Default
	{
	//$Title Arno Breker's Speer Statue, Gold (Sword)
	}
	States
	{
	Spawn:
		BRNZ D -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		BRNZ J -1;
		Stop;
	Inactive:
		BRNZ D 0 A_UnsetSolid;
		"####" D -1 A_SetInvulnerable;
		Stop;
	}
}

class BronzeStatueE : BronzeStatueA
{
	Default
	{
	//$Title Arno Breker's Speer Statue, Stone (Torch)
	}
	States
	{
	Spawn:
		BRNZ E -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		BRNZ K -1;
		Stop;
	Inactive:
		BRNZ E 0 A_UnsetSolid;
		"####" E -1 A_SetInvulnerable;
		Stop;
	}
}

class BronzeStatueF : BronzeStatueA
{
	Default
	{
	//$Title Arno Breker's Speer Statue, Stone (Sword)
	}
	States
	{
	Spawn:
		BRNZ F -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		BRNZ L -1;
		Stop;
	Inactive:
		BRNZ F 0 A_UnsetSolid;
		"####" F -1 A_SetInvulnerable;
		Stop;
	}
}

class BronzeStatueFMini: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Castle
		//$Title Mini Arno Breker's Speer Statue
		//$Color 3
		Radius 1;
		Height 1;
		Scale 0.05;
		-SOLID
		+NOBLOCKMAP
		+NOINTERACTION
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		BRNZ F -1;
		Stop;
	}
}

class Denkmal : BronzeStatueA
{
	Default
	{
	//$Category Props (BoA)/Street
	//$Title Statue Horse (Silver, destroyable)
	Scale 0.85;
	Radius 64;
	}
	States
	{
	Spawn:
		DNML A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		DNML C -1;
		Stop;
	Inactive:
		DNML A 0 A_UnsetSolid;
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class Denkmal2 : Denkmal
{
	Default
	{
	//$Category Props (BoA)/Street
	//$Title Statue Horse (Gold, destroyable)
	}
	States
	{
	Spawn:
		DNML B -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Statue2", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		DNML D -1;
		Stop;
	Inactive:
		DNML B 0 A_UnsetSolid;
		"####" B -1 A_SetInvulnerable;
		Stop;
	}
}

class HarnessSet: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Castle
		//$Title Medieval Harness Set (silver, red)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 72;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class HarnessSet2 : HarnessSet
{
	Default
	{
	//$Title Medieval Harness Set (silver, blue)
	DistanceCheck "boa_scenelod";
	}
}

class WellEmpty: SceneryBase //mxd
{
	Default
	{
		//$Category Props (BoA)/Castle
		//$Title Well (empty)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 24;
		Height 32;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class WellWater : WellEmpty //mxd
{
	Default
	{
	//$Title Well (water)
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("WellWaterWater", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE, 0, tid);
		Stop;
	}
}

class WellWaterWater: SceneryBase //mxd
{
	Default
	{
		DistanceCheck "boa_scenelod";
		RenderStyle "Translucent";
		Alpha 0.9;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class WellBlood : WellEmpty //mxd
{
	Default
	{
	//$Title Well (blood)
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("WellBloodBlood", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE, 0, tid);
		Stop;
	}
}

class WellBloodBlood : WellWaterWater //mxd
{
	Default
	{
	DistanceCheck "boa_scenelod";
	Alpha 0.7;
	}
}

class BarrelWine : WellEmpty //mxd
{
	Default
	{
	//$Title Barrel (wine)
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class CathedralBell : ZBell //ozy81
{
	Default
	{
	//$Category Props (BoA)/Castle
	//$Title Bell (shootable)
	//$Color 3
	Health 5;
	Radius 56;
	Height 120;
	+DONTTHRUST
	+NOBLOOD
	+NOGRAVITY
	+NOICEDEATH
	+SHOOTABLE
	+SOLID
	+SPAWNCEILING
	+SYNCHRONIZED
	DeathSound "BellRing";
	}
	States
	{
	Spawn:
		MDLB C -1;
		Stop;
	Death:
		MDLA A 4 A_BellReset1;
		MDLA B 4;
		MDLA C 4 A_Scream;
		MDLA DEFG 4;
		MDLA H 4 A_Scream;
		MDLA IJK 4;
		MDLA L 4 A_Scream;
		MDLA MNOPQ 4;
		MDLA R 4 A_Scream;
		MDLA STUVWXYZ 4;
		MDLB ABC 4;
		MDLB C 4 A_BellReset2;
		Goto Spawn;
	}
}