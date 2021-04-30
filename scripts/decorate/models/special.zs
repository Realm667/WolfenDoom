/*
 * Copyright (c) 2019-2021 Ozymandias81, Talon1024, AFADoomer
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

class SkyboxMoon: Actor
{
	Default
	{
		//$Category Skyboxes (BoA)
		//$Title Moon (skybox)
		//$Color 3
		Radius 16;
		Height 16;
		+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY {
		A_SpawnItemEx("SkyboxPlanetShade", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1);
		A_SpawnItemEx("SkyboxMoonLights", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1);}
		Stop;
	}
}

class SkyboxEarth : SkyboxMoon
{
	Default
	{
		//$Title Earth (skybox)
		Radius 1024;
		Height 1024;
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY {
		A_SpawnItemEx("SkyboxPlanetWeather", 0, 0, 0, 0, 0, 0, 180, MODELS_FLAGS1);
		A_SpawnItemEx("SkyboxPlanetShade", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1);
		A_SpawnItemEx("SkyboxPlanetLights", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1);}
		Stop;
	}
}

class SkyboxStars : SkyboxMoon
{
	Default
	{
		//$Title Stars (skybox)
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class SkyboxDayNight : SkyboxMoon
{
	Default
	{
		//$Title Sun & Moon (skybox)
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class SkyboxPlanetShade : Glass3d //shades of darkness - ozy81, adjusted by T667
{
	Default
	{
		RenderStyle "Shaded";
		StencilColor "00 00 00";
	}
	States
	{
	Spawn:
		MDLA A 1 A_Warp(AAPTR_MASTER,0,0,0,0,WARPF_NOCHECKPOSITION | WARPF_INTERPOLATE | WARPF_COPYVELOCITY);
		Loop;
	}
}

class SkyboxPlanetWeather : SkyboxPlanetShade //adjusted by T667
{
	Default
	{
		RenderStyle "Shaded";
		StencilColor "aaaaaa";
	}
}

class SkyboxPlanetLights : SkyboxPlanetShade //adjusted by T667
{
	Default
	{
		RenderStyle "Add";
		Alpha 0.5;
	}
}

class SkyboxMoonLights : SkyboxPlanetShade //adjusted by T667
{
	Default
	{
		RenderStyle "Add";
		Alpha 0.8;
	}
}

class TestCrate : Obstacle3d //Ozy81
{
	Default
	{
		//$Category Props (BoA)/Labs
		//$Title Test Lab Crate
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 24;
		Height 64;
		+SOLID
		+DONTRIP
		-NOGRAVITY
		-NOTELEPORT
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("CrateGlass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1, 0, tid);
		Stop;
	}
}

class TestCrate2 : TestCrate //Ozy81
{
	Default
	{
		//$Title Test Lab Crate (with random subject)
		+SOLID
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY {
		A_SpawnItemEx("DummyWarper", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1, 0, tid);
		A_SpawnItemEx("CrateGlass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1, 0, tid);
		A_SpawnItemEx("MutantSubjectWarped", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1, 0, tid);}
		Stop;
	}
}

class TestCrate3 : TestCrate //Ozy81
{
	Default
	{
		//$Title Test Lab Crate (stackable)
		+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("CrateGlass2", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1, 0, tid);
		Stop;
	}
}

class TestCrate4 : TestCrate //Ozy81
{
	Default
	{
		//$Title Test Lab Crate (narrow places, stackable)
		Radius 8;
		Height 8;
		+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("CrateGlass2", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1, 0, tid);
		Stop;
	}
}

class CrateGlass : Glass3d //Ozy81
{
	Default
	{
		DistanceCheck "boa_scenelod";
		Radius 24;
		Height 64;
		-SOLID
		-NOGRAVITY
		-NOTELEPORT
		+CULLACTORBASE.DONTCULL
		Alpha 0.5;
	}
	States
	{
	Spawn:
		MDLA A 1 A_Warp(AAPTR_MASTER,0,0,0,0);
		Loop;
	}
}

class CrateGlass2 : CrateGlass { Default { +NOGRAVITY } }

class DummyWarper: Actor //This is here to avoid "blink effects" - ozy81
{
	Default
	{
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 64;
		Scale 1.1;
		-NOGRAVITY
		-SOLID
		+NOBLOCKMAP
		+LOOKALLAROUND
	}
	States
	{
	Spawn:
		TNT1 A 1 A_Warp(AAPTR_MASTER,0,0,0,0,WARPF_MOVEPTR);
		Loop;
	}
}

class Door_A1_3d : MuseumBase //Ozy81
{
	Default
	{
		//$Category Doors (BoA)
		//$Title 3d Wooden Door (complete, no hitbox)
	}
}

class Door_B1_3d : Door_A1_3d
{
	Default
	{
		//$Title 3d Wooden Door (half, no hitbox)
	}
}

class Door_A2_3d : Door_A1_3d
{
	Default
	{
		//$Title 3d Wooden Door (greyed, complete, no hitbox)
	}
}

class Door_B2_3d : Door_A1_3d
{
	Default
	{
		//$Title 3d Wooden Door (greyed, half, no hitbox)
	}
}

class GoryDecal1 : DecalBase //Ozy81
{
	Default
	{
		//$Category Gore (BoA)/3D Walldecs
		//$Title Gory Decal 01
		//$Color 4
	}
}

class GoryDecal2 : GoryDecal1
{
	Default
	{
		//$Title Gory Decal 02
	}
}

class GoryDecal3 : GoryDecal1
{
	Default
	{
		//$Title Gory Decal 03
	}
}

class GoryDecal4 : GoryDecal1
{
	Default
	{
		//$Title Gory Decal 04 (Big)
		Scale 0.50;
	}
}

class GoryDecal5 : GoryDecal1
{
	Default
	{
		//$Title Gory Decal 05
	}
}

class GoryDecal6 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 06
	}
}

class GoryDecal7 : GoryDecal1
{
		Default
	{//$Title Gory Decal 07
	}
}

class GoryDecal8 : GoryDecal1
{
		Default
	{//$Title Gory Decal 08
	}
}

class GoryDecal9 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 09
	}
}

class GoryDecal10 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 10
	}
}

class GoryDecal11 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 11
	}
}

class GoryDecal12 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 12
	}
}

class GoryDecal13 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 13
	}
}

class GoryDecal14 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 14
	}
}

class GoryDecal15 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 15 (Small)
	}
}

class GoryDecal16 : GoryDecal1
{	Default
	{
	//$Title Gory Decal 16 (Small)
	}
}

class GoryDecalSpawner : RandomSpawner //15 & 16 are excluded for obvious reasons - ozy81
{
	Default
	{
		//$Category Gore (BoA)/3D Walldecs
		//$Title Gory Decal Spawner, Random
		//$Color 4
		//$Sprite DECLA0
		Radius 128;
		Height 0;
		+FLATSPRITE //needed only for gzdb
		DropItem "GoryDecal1";
		DropItem "GoryDecal2";
		DropItem "GoryDecal3";
		DropItem "GoryDecal4";
		DropItem "GoryDecal5";
		DropItem "GoryDecal6";
		DropItem "GoryDecal7";
		DropItem "GoryDecal8";
		DropItem "GoryDecal9";
		DropItem "GoryDecal10";
		DropItem "GoryDecal11";
		DropItem "GoryDecal12";
		DropItem "GoryDecal13";
		DropItem "GoryDecal14";
	}
}

class ZyklonDecal1 : GoryDecal1 //Ozy81
{	Default
	{
	//$Title Zyklon Decal 01
	}
}

class ZyklonDecal2 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 02
	}
}

class ZyklonDecal3 : GoryDecal1
{
	Default
	{
	//$Title Zyklon Decal 03
	}
}

class ZyklonDecal4 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 04 (Big)
	Scale 0.50;
	}
}

class ZyklonDecal5 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 05
	}
}

class ZyklonDecal6 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 06
	}
}

class ZyklonDecal7 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 07
	}
}

class ZyklonDecal8 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 08
	}
}

class ZyklonDecal9 : GoryDecal1
{
	Default
	{
	//$Title Zyklon Decal 09
	}
}

class ZyklonDecal10 : GoryDecal1
{
	Default
	{
	//$Title Zyklon Decal 10
	}
}

class ZyklonDecal11 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 11
	}
}

class ZyklonDecal12 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 12
	}
}

class ZyklonDecal13 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 13
	}
}

class ZyklonDecal14 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 14
	}
}

class ZyklonDecal15 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 15 (Small)
	}
}

class ZyklonDecal16 : GoryDecal1
{	Default
	{
	//$Title Zyklon Decal 16 (Small)
	}
}

class ZyklonDecalSpawner : GoryDecalSpawner //15 & 16 are excluded for obvious reasons - ozy81
{
	Default
	{
		//$Title Zyklon Decal Spawner, Random
		//$Sprite DECLB0
		DropItem "ZyklonDecal1";
		DropItem "ZyklonDecal2";
		DropItem "ZyklonDecal3";
		DropItem "ZyklonDecal4";
		DropItem "ZyklonDecal5";
		DropItem "ZyklonDecal6";
		DropItem "ZyklonDecal7";
		DropItem "ZyklonDecal8";
		DropItem "ZyklonDecal9";
		DropItem "ZyklonDecal10";
		DropItem "ZyklonDecal11";
		DropItem "ZyklonDecal12";
		DropItem "ZyklonDecal13";
		DropItem "ZyklonDecal14";
	}
}

class SootDecal1 : GoryDecal1 //Ozy81
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Grease Soot Decal 01
		RenderStyle "Translucent";
		Alpha 0.90;
	}
}

class SootDecal2 : GoryDecal1
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Grease Soot Decal 02
		RenderStyle "Translucent";
		Alpha 0.90;
	}
}

class SootDecal3 : GoryDecal1
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Grease Soot Decal 03
		RenderStyle "Translucent";
		Alpha 0.90;
	}
}

class SootDecal4 : GoryDecal1
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Grease Soot Decal 04 (wall)
		RenderStyle "Translucent";
		Alpha 0.90;
	}
}

class SootDecal5 : GoryDecal1
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Grease Soot Decal 05 (wall)
		RenderStyle "Translucent";
		Alpha 0.90;
	}
}

class SootDecal6 : GoryDecal1
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Grease Soot Decal 06 (wall)
		RenderStyle "Translucent";
		Alpha 0.90;
	}
}

class SootDecal7 : GoryDecal1
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Grease Soot Decal 07 (wall)
		RenderStyle "Translucent";
		Alpha 0.90;
	}
}

class EiffelTower : DecalBase //Ozy81
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Eiffel Tower for 3d Skyboxes
		Radius 4;
		Scale 1.0;
	}
}

class SlopeMe1 : Obstacle3d //Ozy81
{
	Default
	{
		//$Category Misc (BoA)
		//$Title Slopeable Glass (clear)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 4;
		+NOGRAVITY
		+CullActorBase.DONTCULL //remove in 3.1 
	}
}

class SlopeMe2 : SlopeMe1 //Ozy81
{
	Default
	{
		//$Title Slopeable Glass (checker)
		+CullActorBase.DONTCULL //remove in 3.1 
	}
}

class ZeppelinBridge : SlopeMe1 //Ozy81
{
	Default
	{
		//$Title Fake Zeppelin Bridge
		RenderRadius 256;
		Radius 1;
		Height 1;
		-SOLID
	}
}

class IntermapSkylight : Obstacle3d //MaxED
{
	Default
	{
		//$Category Models (BoA)/Intermap
		//$Title Headquarters Skylight
		//$Color 3
		Radius 64;
		Height 16;
		+NOGRAVITY
	}
}

class LighthouseBeam : IntermapSkylight //MaxED
{
	Default
	{
		//$Title Lighthouse Beam
		DistanceCheck "boa_scenelod";
		RenderStyle "Add";
		+BRIGHT
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

//Talon1024
class PlainsSun3D : ModelBase
{
	Default
	{
		//$Category Skyboxes (BoA)
		//$Title Sunny Morning SkyBox (PlainsSun, Special)
		//$Color 3
		+CullActorBase.DONTCULL;
	}
}

class MountainsSun3D : PlainsSun3D
{
	Default
	{
		//$Title Mountain Day SkyBox (MountainDay, Special)
	}
}