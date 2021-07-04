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

class BathBase: SceneryBase
{
	Default
	{
		Radius 8;
		Height 32;
		+NOBLOOD
		+NODROPOFF
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		CullActorBase.CullLevel 1;
	}
}

class Shit : BathBase
{
	Default
	{
	//$Category Props (BoA)/Bath
	//$Title Shitpile (squeezable)
	//$Color 3
	Radius 2;
	Height 4;
	Health 1;
	Scale 0.35;
	+TOUCHY
	}
	States
	{
	Spawn:
		SHIT A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("SHITHPNS", CHAN_ITEM, 0, frandom(0.5,0.7), ATTN_NORM);
		"####" A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y / 2);
		Stop;
	}
}

class Shitler : Shit
{
	Default
	{
	//$Title Shitler Pile (squeezable)
	Scale 0.35;
	}
	States
	{
	Spawn:
		SHIT B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		"####" C 0 A_UnSetSolid;
		"####" C 0 A_StartSound("SHITHPNS", CHAN_ITEM, 0, frandom(0.5,0.7), ATTN_NORM);
		"####" CDE 4;
		"####" E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y / 2);
		Stop;
	}
}

class BucketMop : BathBase
{
	Default
	{
	//$Category Props (BoA)/Bath
	//$Title Mop with Bucket (destroyable)
	//$Color 3
	Health 5;
	Scale 0.45;
	+DONTTHRUST
	}
	States
	{
	Spawn:
		MOPP A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom(0.2,0.5), ATTN_NORM);
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom(0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("MetalFrags");
		MOPP B -1;
		Stop;
	}
}

//3D ACTORS//
class ToiletShootable : BathBase
{
	Default
	{
	//$Category Props (BoA)/Bath
	//$Title Toilet (shootable)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 10;
	Height 42;
	Health 5;
	Mass 999999;
	-NODROPOFF
	+DONTGIB
	DeathSound "toilet/death";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Death:
		MDLA A 2 A_Scream;
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Bin", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
	Broken:
		MDLA B 0 A_StartSound("toilet/broken", CHAN_AUTO, CHANF_LOOPING, 1.0, ATTN_STATIC);
	Broken.Loop:
		MDLA B 0 A_CheckRange(512,"BrokenSilent");
		"####" B 1 A_SpawnItemEx("WaterSmokePuffSmall", 0, 0, 1, (0.1)*random(0, 4), 0, (0.1)*random(8, 16), random(0, 360), 128);
		Loop;
	BrokenSilent:
		MDLA B 0 A_StopSound(CHAN_AUTO);
		"####" B 1 A_SpawnItemEx("WaterSmokePuffSmall", 0, 0, 1, (0.1)*random(0, 4), 0, (0.1)*random(8, 16), random(0, 360), 128);
		Goto Broken;
	}
}

class ToiletSoldier : ToiletShootable
{
	Default
	{
	//$Category Monsters (BoA)/Toilet Soldiers
	//$Title Toilet TO USE WITH SOLDIERS ONLY (shootable)
	DistanceCheck "boa_scenelod";
	Height 24;
	}
}

class ToiletTalking : ToiletShootable
{
	int user_angle;
	Default
	{
	//$Category Conversation Stuff (BoA)
	//$Title Talking Toilet (shootable)
	//$Color 5
	-NOTAUTOAIMED //or it will become impossible to interact with it
	}
	States
	{
	Spawn:
		MDLA A 1 {
			if (!user_angle) { user_angle = (int) (angle); }
			angle = user_angle;
		}
		Loop;
	}
}

class WashingDish: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Bath
		//$Title Washing Dish
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
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