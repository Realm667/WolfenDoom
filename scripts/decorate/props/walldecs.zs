/*
 * Copyright (c) 2017-2021 Ozymandias81, Tormentor667
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

// WALL DECS //
class Wall_CampMalePrisoner: Actor
{
	Default
	{
	//$Category Wall Decorations (BoA) /Concentration Camp
	//$Title Camp Prisoner Hanging (male, random)
	//$Color 3
	Radius 1;
	Height 64;
	Scale 0.65;
	+FORCEYBILLBOARD
	+FIXMAPTHINGPOS
	+NOGRAVITY
	+WALLSPRITE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,10);
		CHGM A -1;
		CHGM E -1;
		CHGM F -1;
		CHGM G -1;
		CHGM H -1;
		CHGM I -1;
		CHGM J -1;
		CHGM K -1;
		Stop;
	Moving:
		CHGM B 1 A_SetTics(Random(80,160));
		"####" C 8;
		"####" D 8;
		"####" C 8;
		Loop;
	}
}

class Wall_CampMaleSkeleton : Wall_CampMalePrisoner
{
	Default
	{
	//$Title Camp Skeleton Hanging (random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6);
		CHGM L -1;
		CHGM M -1;
		CHGM N -1;
		CHGM O -1;
		CHGM P -1;
		CHGM Q -1;
		Stop;
	}
}

class Wall_CampFemalePrisoner : Wall_CampMalePrisoner
{
	Default
	{
	//$Title Camp Prisoner Hanging (female, random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,9);
		CHGF A -1;
		CHGF B -1;
		CHGF C -1;
		CHGF D -1;
		CHGF E -1;
		CHGF F -1;
		CHGF G -1;
		Stop;
	Moving:
		CHGF H 1 A_SetTics(Random(80,160));
		"####" I 8;
		"####" J 8;
		"####" I 8;
		Loop;
	}
}

class Wall_CivilianMale1 : Wall_CampMalePrisoner
{
	Default
	{
	//$Category Wall Decorations (BoA)
	//$Title Civilian Prisoner Hanging (1st variant, random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,12);
		CIV1 D -1;
		CIV1 E -1;
		CIV1 F -1;
		CIV1 G -1;
		CIV1 H -1;
		CIV1 I -1;
		CIV1 J -1;
		CIV1 K -1;
		CIV1 L -1;
		CIV1 M -1;
		Stop;
	Moving:
		CIV1 A 1 A_SetTics(Random(80,160));
		"####" B 8;
		"####" C 8;
		"####" B 8;
		Loop;
	}
}

class Wall_CivilianMale2 : Wall_CampMalePrisoner
{
	Default
	{
	//$Category Wall Decorations (BoA)
	//$Title Civilian Prisoner Hanging (2nd variant, random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,12);
		CIV2 D -1;
		CIV2 E -1;
		CIV2 F -1;
		CIV2 G -1;
		CIV2 H -1;
		CIV2 I -1;
		CIV2 J -1;
		CIV2 K -1;
		CIV2 L -1;
		CIV2 M -1;
		Stop;
	Moving:
		CIV2 A 1 A_SetTics(Random(80,160));
		"####" B 8;
		"####" C 8;
		"####" B 8;
		Loop;
	}
}

class Wall_CivilianMale3 : Wall_CampMalePrisoner
{
	Default
	{
	//$Category Wall Decorations (BoA)
	//$Title Civilian Prisoner Hanging (3rd variant, random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,12);
		CIV3 D -1;
		CIV3 E -1;
		CIV3 F -1;
		CIV3 G -1;
		CIV3 H -1;
		CIV3 I -1;
		CIV3 J -1;
		CIV3 K -1;
		CIV3 L -1;
		CIV3 M -1;
		Stop;
	Moving:
		CIV3 A 1 A_SetTics(Random(80,160));
		"####" B 8;
		"####" C 8;
		"####" B 8;
		Loop;
	}
}

class Wall_CivilianMale4 : Wall_CampMalePrisoner
{
	Default
	{
	//$Category Wall Decorations (BoA)
	//$Title Civilian Prisoner Hanging (smoking, shootable)
	Health 25;
	Mass 0x7ffffff;
	+DONTFALL
	+SHOOTABLE
	}
	States
	{
	Spawn:
		CIV4 A 1 A_JumpIfHealthLower(40,"Bleeding");
		Loop;
	Bleeding:
		CIV4 B 1 A_SetTics(Random(80,160));
		"####" C 8;
		"####" D 8;
		"####" B 8;
		Loop;
	Death:
		TNT1 A 0 A_Jump(256,1,2);
		CIV4 E -1 A_UnSetShootable;
		CIV4 F -1 A_UnSetShootable;
		Stop;
	}
}

//FLAT DECS//
class FlatBase: SceneryBase
{
	Default
	{
		Radius 128;
		Height 0;
		Scale 0.25;
		+FLATSPRITE
		CullActorBase.CullLevel 1;
	}
}

class CraterGrass : FlatBase
{
	Default
	{
	//$Category Battlefield (BoA)
	//$Title Crater (Grass)
	//$Color 4
	}
	States
	{
	Spawn:
		KRAT A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CraterSnow : CraterGrass
{
	Default
	{
	//$Title Crater (Snow)
	}
	States
	{
	Spawn:
		KRAT B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CraterDirt : CraterGrass
{
	Default
	{
	//$Title Crater (Dirt)
	}
	States
	{
	Spawn:
		KRAT C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CraterConcrete : CraterGrass
{
	Default
	{
	//$Title Crater (Concrete)
	}
	States
	{
	Spawn:
		KRAT E -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class SnowPile1 : CraterGrass
{
	Default
	{
	//$Title Snowpile Large
	}
	States
	{
	Spawn:
		KRAT D -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class StainedGlassLight : CraterGrass
{
	Default
	{
	//$Title Stained Glass Light
	RenderStyle "Add";
	Alpha 1.0;
	}
	States
	{
	Spawn:
		STGL Z -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}