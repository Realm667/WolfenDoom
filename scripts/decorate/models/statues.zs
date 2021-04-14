/*
 * Copyright (c) 2019-2021 Ozymandias81
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

//Enjay
class Hitler_Bust : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Statues
		//$Title Hitler's Bronze Bust
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 24;
		+NOGRAVITY
	}
}

//RTCW stuff
class Lion_Left : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Statues
		//$Title Lion Statue (Left)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 48;
		Height 192;
	}
}

class Lion_Right : Lion_Left
{
	Default
	{
		//$Title Lion Statue (Right)
	}
}

class Caesar : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Statues
		//$Title Caesar's Statue
		//$Color 3
		//$Arg0 "Type"
		//$Arg0Tooltip "Pickup the desired type\nSolid: 0\nNon-Solid: 1"
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 192;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		MDLA A 0 A_JumpIf(Args[0]==1, "NonSolid");
	Solid:
		MDLA A -1;
		Stop;
	NonSolid:
		MDLA A 1 A_UnSetSolid;
		Wait;
	}
}

class King : Caesar
{
	Default
	{
		//$Category Models (BoA)/Statues
		//$Title King's Statue
		//$Color 3
		Radius 48;
	}
}

class Female_StatueA : Caesar //CoD1
{
	Default
	{
		//$Title Female Statue (right side)
		Radius 24;
		Height 72;
	}
}

class Female_StatueB : Female_StatueA //CoD1
{
	Default
	{
		//$Title Female Statue (left side)
	}
}

class Caesar_Museum : MuseumBase
{
	Default
	{
		//$Title Caesar's Statue (without hitbox)
	}
}

class King_Museum : Caesar_Museum
{
	Default
	{
		//$Title King's Statue (without hitbox)
	}
}

class PromL_Museum : Caesar_Museum //ozy81
{
	Default
	{
		//$Title Prometheus Statue (left, without hitbox)
	}
}

class PromR_Museum : Caesar_Museum //ozy81
{
	Default
	{
		//$Title Prometheus Statue (right, without hitbox)
	}
}

class LionL_Museum : Caesar_Museum
{
	Default
	{
		//$Title Lion's Statue (left, without hitbox)
	}
}

class LionR_Museum : Caesar_Museum
{
	Default
	{
		//$Title Lion's Statue (right, without hitbox)
	}
}

//Sketchfab Stuff
class GardenUrn : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Statues
		//$Title Garden Urn
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 72;
	}
}

class GardenUrn_Museum : Caesar_Museum
{
	Default
	{
		//$Category Models (BoA)/No Hitbox
		//$Title Garden Urn (without hitbox)
	}
}

//Ozy81 stuff
class BerlinAngel1L : Lion_Left //ozy81
{
	Default
	{
		//$Title Berlin Angel Statue (left)
	}
}

class BerlinAngel1R : Lion_Left //ozy81
{
	Default
	{
		//$Title Berlin Angel Statue (right)
	}
}

class CreepyStatue1R : Lion_Left //ozy81
{
	Default
	{
		//$Title Creepy Statue, Goro (right)
	}
}

class CreepyStatue1L : CreepyStatue1R
{
	Default
	{
	//$Title Creepy Statue, Goro (left)
	}
}

class CreepyStatue1RF : Furniture_End3d
{	Default
	{
	//$Title Creepy Statue, Goro (right, no lod)
	Radius 48;
	Height 192;
	}
}

class CreepyStatue1LF : CreepyStatue1RF
{	Default
	{
	//$Title Creepy Statue, Goro (left, no lod)
	}
}

class CreepyStatue1R_Museum : MuseumBase
{	Default
	{
	//$Title Creepy Statue, Goro (right, no hitbox)
	}
}

class CreepyStatue1L_Museum : CreepyStatue1R_Museum
{	Default
	{
	//$Title Creepy Statue, Goro (left, no hitbox)
	}
}

class BerlinAngel1L_Museum : CreepyStatue1R_Museum
{	Default
	{
	//$Title Berlin Angel Statue (left, no hitbox)
	}
}

class BerlinAngel1R_Museum : CreepyStatue1R_Museum
{	Default
	{
	//$Title Berlin Angel Statue (right, no hitbox)
	}
}

//S.T.A.L.K.E.R. models
class Prometheus_L3d : Caesar
{	Default
	{
	//$Category Models (BoA)/Statues
	//$Title Prometheus Statue (Left Side)
	//$Color 3
	Height 96;
	}
}

class Prometheus_R3d: Prometheus_L3d
{	Default
	{
	//$Title Prometheus Statue (Right Side)
	}
}

class Prometheus_LF3d : Furniture_End3d
{	Default
	{
	//$Title Prometheus Statue, Floating Flame (Left Side, no lod)
	Radius 32;
	Height 96;
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("PrometheusFireA", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE);
		Stop;
	Destroyed:
		MDLA B 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" BBBBBBBBBBBBBBBB 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" BBBBBBBBBBBBB 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" BBBBBBBBBB 0 A_SpawnItemEx("Debris_Statue3", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		"####" BBBBBBB 0 A_SpawnItemEx("Debris_Statue1", random(32,96), random(16,64), random(24,32), random(2,4), random(2,4), random(2,4), random(0,360), SXF_CLIENTSIDE);
		MDLA B -1;
		Stop;
	}
}

class Prometheus_RF3d: Prometheus_LF3d
{	Default
	{
	//$Title Prometheus Statue, Floating Flame (Right Side, no lod)
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("PrometheusFireB", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE);
		Stop;
	}
}

class PrometheusFireA : ModelBase
{	Default
	{
	+FLOAT
	+FLOATBOB
	-SOLID
	}
}

class PrometheusFireB : PrometheusFireA {}

//Skyrim models
class CreepyStatue2LF : Furniture_End3d
{	Default
	{
	//$Title Creepy Statue, Malacath (Left Side, no lod)
	Radius 32;
	Height 96;
	}
}

class CreepyStatue2RF : CreepyStatue2LF
{	Default
	{
	//$Title Creepy Statue, Malacath (Right side, no lod)
	}
}

//COD stuff
class COD_FemaleBust : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Statues
	//$Title Female Bust (silver or bronze)
	//$Color 3
	//$Arg0 "Material"
	//$Arg0Tooltip "Choose the desired material\nSilver: 0\nBronze: 1"
	DistanceCheck "boa_scenelod";
	Radius 8;
	Height 24;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Bronze");
	Silver: //fall through if set at 0
		MDLA A -1;
		Stop;
	Bronze:
		MDLA B -1;
		Stop;
	}
}

class COD_EagleBust : COD_FemaleBust
{	Default
	{
	//$Title Eagle Bust (silver or bronze)
	}
}

class COD_FemaleBust_Museum : MuseumBase
{	Default
	{
	//$Title Female Bust (silver or bronze, no hitbox)
	//$Arg0 "Material"
	//$Arg0Tooltip "Choose the desired material\nSilver: 0\nBronze: 1"
	DistanceCheck "boa_scenelod";
	Radius 8;
	Height 24;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Bronze");
	Silver: //fall through if set at 0
		MDLA A -1;
		Stop;
	Bronze:
		MDLA B -1;
		Stop;
	}
}

class COD_EagleBust_Museum : COD_FemaleBust_Museum
{	Default
	{
	//$Title Eagle Bust (silver or bronze, no hitbox)
	}
}