/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, Talon1024,
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

class StreetBase: SceneryBase
{
	Default
	{
		Radius 16;
		Height 56;
		Mass 100;
		+NOBLOOD
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		CullActorBase.CullLevel 1;
	}
}

class Dome: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Street
		//$Title Dome
		//$Color 3
		Radius 2;
		Height 2;
		+NOGRAVITY
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		DOME A -1;
		Stop;
	}
}

class StreetBin : StreetBase
{
	Default
	{
	//$Category Props (BoA)/Street
	//$Title Recycle Bin (Street)
	//$Color 3
	Scale 0.85;
	Health 5;
	+PUSHABLE
	}
	States
	{
	Spawn:
		SRCB A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("METALBRK");
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Trash", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		SRCB E -1;
		Stop;
	}
}

class StreetBin2 : StreetBin
{
	Default
	{
	//$Title Recycle Bin (Whermacht)
	Height 24;
	}
	States
	{
	Spawn:
		SSBN A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("METALBRK");
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Trash", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		SSBN B -1;
		Stop;
	}
}

class BurningBarrelBoA : StreetBase
{
	Default
	{
	//$Category Props (BoA)/Street
	//$Title Burning Barrel (Destroyable)
	//$Color 3
	Height 64;
	Health 5;
	+DONTTHRUST
	}
	States
	{
	Spawn:
		BBAR A 0 NODELAY A_StartSound("SFX/FireLoop1", CHAN_BODY, CHANF_LOOPING, frandom(0.4,0.8), ATTN_STATIC);
		SpawnLoop:
		TNT1 A 0 A_CheckRange(768,"NoSound");
		TNT1 A 0 {
			if (!CheckRange(boa_sfxlod, true))
			{
				A_SpawnItemEx("FloatingCinder", 0, 0, random(48,54), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE);
			}
		}
		BBAR ABCD 3;
		Loop;
	NoSound:
		TNT1 A 0 A_StopSound(CHAN_BODY);
		TNT1 A 0 {
			if (!CheckRange(boa_sfxlod, true))
			{
				A_SpawnItemEx("FloatingCinder", 0, 0, random(48,54), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE);
			}
		}
		BBAR ABCD 3;
		Goto Spawn;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StopSound(CHAN_BODY);
		"####" A 0 A_StartSound("METALBRK");
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Metal3Dark", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAA 0 A_SpawnItemEx("BarrelFireSpawner", random(8,12), random(8,12), random(0,56), 0, 0, 0, random(0,360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE);
		BBAR E -1;
		Stop;
	}
}

class ScareCrow : StreetBase
{
	Default
	{
	//$Category Props (BoA)/Street
	//$Title Scarecrow (Destroyable)
	//$Color 3
	Height 48;
	Health 5;
	Mass 100000;
	Scale 0.85;
	+ROLLSPRITE
	}
	States
	{
	Spawn:
		SCRW A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 {A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
								A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
								A_SpawnItemEx("GrassFrags_Dry");}
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Wood", random(20,40), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Wood", random(40,60), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		SCRW B -1;
		Stop;
	}
}

//3D ACTORS//
class HydrantShootable : StreetBase
{
	Default
	{
	//$Category Props (BoA)/Street
	//$Title Hydrant (shootable)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Health 10;
	Radius 10;
	Height 42;
	Mass 999999;
	+DONTGIB
	+NOICEDEATH
	DeathSound "hydrant/death";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Death:
		MDLA B 4 A_Scream;
		"####" AAAAAAAA 0 A_SpawnItemEx("Debris_Hydrant", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
	Water:
		MDLA B 0 A_StartSound("hydrant/broken", CHAN_7, CHANF_LOOPING, frandom(0.8, 1.0), ATTN_NORM);
	Broken:
		MDLA B 0 A_CheckRange(768,"BrokenSilent");
		"####" B 1 A_SpawnItemEx("WaterSmokePuffSmall", 0, 0, 1, (0.1)*random(0, 4), 0, (0.1)*random(8, 16), random(0, 360), 128);
		Loop;
	BrokenSilent:
		MDLA B 0 A_StopSound(CHAN_7);
		"####" B 1 A_SpawnItemEx("WaterSmokePuffSmall", 0, 0, 1, (0.1)*random(0, 4), 0, (0.1)*random(8, 16), random(0, 360), 128);
		Goto Water;
	}
}

class RoadBarrier: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Street
		//$Title Road Barrier (Small)
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 64;
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

class NTomb1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Street
		//$Title Tombstone 1
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 15;
		Height 68;
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

class NTomb2 : NTomb1
{
	Default
	{
	//$Title Tombstone 2
	DistanceCheck "boa_scenelod";
	Height 62;
	}
}

class NTomb3 : NTomb1
{
	Default
	{
	//$Title Tombstone 3
	DistanceCheck "boa_scenelod";
	Height 48;
	}
}

class NTomb4 : NTomb1
{
	Default
	{
	//$Title Tombstone 4
	DistanceCheck "boa_scenelod";
	Height 43;
	}
}

class NTomb5 : NTomb1
{
	Default
	{
	//$Title Tombstone 5
	DistanceCheck "boa_scenelod";
	Radius 12;
	Height 35;
	}
}

class Haycart: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Street
		//$Title Haycart
		//$Color 3
		//$Arg0 "Type"
		//$Arg0Tooltip "Pickup the desired type\nNormal: 0\nDestroyed: 1"
		DistanceCheck "boa_scenelod";
		Radius 24; //reduced for map-wise placement - ozy
		Height 32;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_JumpIf(Args[0]==1, "Destroyed");
		MDLA A -1;
		Stop;
	Destroyed:
		MDLA B -1;
		Stop;
	}
}