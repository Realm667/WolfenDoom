/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, Talon1024,
 *                         AFADoomer
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

//2d Actors//
class BarrelFuture: Actor
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Barrel (modern, destroyable)
	//$Color 3
	Radius 8;
	Height 56;
	Health 5;
	Mass 100;
	-DROPOFF
	+NOBLOOD
	+NOTAUTOAIMED
	+PUSHABLE
	+SHOOTABLE
	+SOLID
	}
	States
	{
	Spawn:
		CANF A -1;
		Stop;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" B 0 A_SpawnItemEx("MetalFrags");
		"####" BBBBBB 0 A_SpawnItemEx("Debris_Astro", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" BBBBBB 3 A_SpawnItemEx("SparkB", random(0,16), random(0,16), random(0,56), 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" B -1;
		Stop;
	}
}

class BarrelFutureExploding : ExplosiveBarrel
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Barrel (modern, explode)
	//$Color 3
	Radius 16;
	Height 64;
	DeathSound "astrostein/explosion";
	}
	States
	{
	Spawn:
		BARF ABCDCB 8;
		Loop;
	Death:
		"####" A 0 A_SpawnItemEx("AstrosteinExplosion_Medium",0,0,32);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Trash", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 6 A_Scream;
		BARF E -1;
		Stop;
	}
}

class StreetLightAstro: Actor
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Street Light (modern)
	//$Color 3
	Radius 8;
	Height 128;
	+SOLID
	}
	States
	{
	Spawn:
		STRL X -1;
		Stop;
	}
}

class StripperGirl1: Actor
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Stripper Girl, Purple
	//$Color 3
	Radius 16;
	Height 56;
	Scale 0.6;
	+RANDOMIZE
	+SOLID
	}
	States
	{
	Spawn:
		STRP A 0 A_Jump(64, 9);
		STRP A 0 A_Jump(64, 5);
		STRP A 0 A_Jump(64, 2);
		STRP ABCDEDCBA 3;
		STRP FGHGHF 6;
		Loop;
	}
}

class StripperGirl1NH : StripperGirl1
{
	Default
	{
	//$Title Stripper Girl, Purple (decorative)
	//$Color 3
	Radius 2;
	Height 2;
	Scale 0.6;
	-SOLID
	+NOBLOCKMAP
	}
}

class StripperGirl2 : StripperGirl1
{
	Default
	{
	//$Title Stripper Girl, Black
	}
	States
	{
	Spawn:
		STR2 A 0 A_Jump(64, 9);
		STR2 A 0 A_Jump(64, 5);
		STR2 A 0 A_Jump(64, 2);
		STR2 ABCDEDCBA 3;
		STR2 FGHGHF 6;
		Loop;
	}
}

class StripperGirl3 : StripperGirl1
{
	Default
	{
	//$Title Stripper Girl, Red
	}
	States
	{
	Spawn:
		STR3 A 0 A_Jump(64, 9);
		STR3 A 0 A_Jump(64, 5);
		STR3 A 0 A_Jump(64, 2);
		STR3 ABCDEDCBA 3;
		STR3 FGHGHF 6;
		Loop;
	}
}

class StripperGirls : RandomSpawner
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Stripper Girl, Random
	//$Color 3
	//$Sprite STRPH0
	Radius 16;
	Height 56;
	Scale 0.6;
	DropItem "StripperGirl1";
	DropItem "StripperGirl2";
	DropItem "StripperGirl3";
	}
}

//3d Actors//
class AstroShuttle : ModelBase //AFADoomer
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Galileo's Shuttle
	//$Color 3
	DistanceCheck "boa_scenelod";
	Height 32;
	Radius 64;
	}
}

class EnergyTankLit: Actor //Talon1024 model
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Energy Tank (lit)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 128;
	+SOLID
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class EnergyTankUnLit : EnergyTankLit //Talon1024 model
{
	Default
	{
	//$Title Energy Tank (unlit)
	}
}

class RadioSatelite: Actor
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Radio Satelite
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 64;
	Height 256;
	Scale 4.0;
	+SOLID
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class RadioTower : RadioSatelite
{
	Default
	{
	//$Title Radio Tower
	Radius 32;
	Scale 3.0;
	}
	States
	{
	Spawn:
		MDLA AB 20;
		Loop;
	}
}

class SolarPanel : RadioSatelite
{
	Default
	{
	//$Title Solar Panel
	Height 96;
	Scale 2.0;
	}
}

class RotatingStation: Actor
{
	Default
	{
	//$Category Astrostein (BoA)/Props
	//$Title Space Station (rotating)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Height 64;
	+FLOORCLIP
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}