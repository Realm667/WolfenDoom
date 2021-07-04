/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, AFADoomer,
 *                         DragonflyOS
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

//base actors
class LightBase : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Color 11
		DistanceCheck "boa_scenelod";
		+NOGRAVITY
		CullActorBase.CullLevel 2;
	}
}

class LightBase2 : LightBase
{
	Default
	{
	+NOBLOCKMAP
	+NOTAUTOAIMED
	+SOLID
	}
}

class LightBaseArgs : LightBase
{
	Default
	{
	//$Category Lights (BoA)/ARGs
	//$Arg0 Sound
	//$Arg0Type 11
	//$Arg0Enum { 0 = "Yes"; 1 = "No"; }
	+NOBLOCKMAP
	+SOLID
	}
}

class LightBaseArgs2 : LightBase
{
	Default
	{
	//$Category Lights (BoA)/No Hitbox
	//$Arg0 Sound
	//$Arg0Type 11
	//$Arg0Enum { 0 = "Yes"; 1 = "No"; }
	+NOBLOCKMAP
	-SOLID
	}
}

class LightBaseInt : LightBase
{
	Default
	{
	//$Category Lights (BoA)/ACS Switchable
	Health -1;
	-FLOORCLIP
	-NOBLOCKMAP
	+DONTSPLASH
	+DONTTHRUST
	+NOBLOOD
	+NOBLOODDECALS
	+NODAMAGE
	+NOTAUTOAIMED
	+SHOOTABLE
	}
}

class Glass3d : ModelBase
{
	Default
	{
	RenderStyle "Shaded";
	StencilColor "CC CC CC";
	}
}

//3d lights
class ChanGold : LightBase
{
	Default
	{
	//$Title 3d Gold Chandelier (SWITCHABLE)
	Radius 16;
	Height 52;
	+SPAWNCEILING
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //mxd. DORMANT flag must be updated manually
	Spawn:
		MDLA A -1 LIGHT("3DCHAN");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;} //mxd. DORMANT flag must be updated manually
		Stop;
	}
}

class WallLight1 : ModelBase
{
	Default
	{
	//$Category Lights (BoA)/Static
	//$Title 3d Wall Light (OFF, STATIC)
	//$Color 11
	DistanceCheck "boa_scenelod";
	Radius 4;
	Height 16;
	-SOLID
	+NOBLOCKMAP
	+NOGRAVITY
	}
}

class WallLight1Lit : WallLight1
{
	Default
	{
	//$Title 3d Wall Light (ON, STATIC)
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("VolumetricLight_ConeDown", Scale.X*16, 0, 24, 0, 0, 0, 0, SXF_ISTRACER, 0, tid);
		MDLA A -1 LIGHT("OZYWALLT");
		Stop;
	}
}

class WallLight1NC : WallLight1
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Wall Light, no cone (ON, STATIC)
	}
	States
	{
	Spawn:
		MDLA A -1 LIGHT("OZYWALT3");
		Stop;
	}
}

class WallLight2 : WallLight1
{
	Default
	{
	//$Title 3d Wall Lantern (OFF, STATIC)
	Height 24;
	}
}

class WallLight2Lit : WallLight2
{
	Default
	{
	//$Title 3d Wall Lantern (ON, STATIC)
	}
	States
	{
	Spawn:
		MDLA A -1 LIGHT("OZYWALLT");
		Stop;
	}
}

class SimpleLight1 : LightBaseInt
{
	Default
	{
	//$Title 3d Simple Light (OFF, SET DORMANT & ACTIVATE IT VIA ACS)
	Radius 8;
	Height 12;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A -1;
		Loop;
	Inactive:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X-Scale.Y-Height/24, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	InactiveLights:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1 LIGHT("OZYSIMLT");
		Stop;
	}
}

class SimpleLight1Lit : SimpleLight1
{
	Default
	{
	//$Title 3d Simple Light (ON, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	ActiveLights:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X-Scale.Y-Height/24, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	Activate:
		MDLA A 1 LIGHT("OZYSIMLT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1;
		Stop;
	}
}

class SimpleLight1NC : SimpleLight1
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Simple Light, no cone (ON, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1 LIGHT("OZYSIMLT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class WallLight2Switch : SimpleLight1
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Wall Lantern, no cone (ON, SWITCHABLE)
	Radius 4;
	Height 24;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1 LIGHT("OZYSIMLT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class HangLight1Switch : SimpleLight1
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Hanging Lantern, no cone (ON, SWITCHABLE)
	Height 1;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1 LIGHT("OZYSIMLT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class Chandelier1Switchable : LightBaseARGs
{
	Default
	{
	//$Title 3d Chandelier with Tall Candles (RUSTY, ARGS)
	Radius 10;
	Height 56;
	+SPAWNCEILING
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY A_StartSound("FIRE_SMALL", CHAN_BODY, CHANF_LOOPING, frandom(0.2,0.4) - args[0]);
	ActiveFlames: //ozy. let's apply these nice flames on candles first - coords be damned
		MDLA A 0 {
		A_SpawnItemEx("Flame_Normal3d", Scale.X*1, 	Scale.Y*33, 	Scale.X+Scale.Y*14, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*1, 	Scale.Y*-31, Scale.X+Scale.Y*5, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*24, 	Scale.Y*23, 	Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-22, Scale.Y*-22, Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*34, 	Scale.Y*1, 	Scale.X+Scale.Y*14, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-31, Scale.Y*1, 	Scale.X+Scale.Y*12, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-22, Scale.Y*23, 	Scale.X+Scale.Y*5, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*24, 	Scale.Y*-22, Scale.X+Scale.Y*8, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid); }
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC); //ozy81 - remove flames if deactivated
		"####" A -1 A_StopSound(CHAN_BODY);
		Stop;
	}
}

class Chandelier2Switchable : Chandelier1Switchable
{
	Default
	{
	//$Title 3d Chandelier with Short Candles (RUSTY, ARGS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY A_StartSound("FIRE_SMALL", CHAN_BODY, CHANF_LOOPING, frandom(0.2,0.4) - args[0]);
	ActiveFlames:
		MDLA A 0 {
		A_SpawnItemEx("Flame_Normal3d", Scale.X*0, Scale.Y*26, 	Scale.X+Scale.Y*10, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*0, Scale.Y*-26.5, Scale.X+Scale.Y*6, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*18.7, Scale.Y*18.2, Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-18.8, Scale.Y*-18.8, Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*26.5, Scale.Y*-0.2, Scale.X+Scale.Y*10, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-26.4, Scale.Y*0, Scale.X+Scale.Y*8.8,0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-18.8, Scale.Y*18.7, 	Scale.X+Scale.Y*5, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*19.2, Scale.Y*-18.9, Scale.X+Scale.Y*8, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid); }
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" A -1 A_StopSound(CHAN_BODY);
		Stop;
	}
}

class Chandelier3Switchable : Chandelier1Switchable
{
	Default
	{
	//$Title 3d Chandelier with Tall Candles (BLACK, ARGS)
	}
}

class Chandelier4Switchable : Chandelier2Switchable
{
	Default
	{
	//$Title 3d Chandelier with Short Candles (BLACK, ARGS)
	}
}

class Chandelier1SwitchableNH : LightBaseARGs2
{
	Default
	{
	//$Title 3d Chandelier with Tall Candles (NO HITBOX, RUSTY, ARGS)
	Radius 4;
	Height 4;
	+SPAWNCEILING
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY A_StartSound("FIRE_SMALL", CHAN_BODY, CHANF_LOOPING, frandom(0.2,0.4) - args[0]);
	ActiveFlames: //ozy. let's apply these nice flames on candles first - coords be damned
		MDLA A 0 {
		A_SpawnItemEx("Flame_Normal3d", Scale.X*1, 	Scale.Y*33, 	Scale.X+Scale.Y*14, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*1, 	Scale.Y*-31, Scale.X+Scale.Y*5, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*24, 	Scale.Y*23, 	Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-22, Scale.Y*-22, Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*34, 	Scale.Y*1, 	Scale.X+Scale.Y*14, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-31, Scale.Y*1, 	Scale.X+Scale.Y*12, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-22, Scale.Y*23, 	Scale.X+Scale.Y*5, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*24, 	Scale.Y*-22, Scale.X+Scale.Y*8, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid); }
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC); //ozy81 - remove flames if deactivated
		"####" A -1 A_StopSound(CHAN_BODY);
		Stop;
	}
}

class Chandelier2SwitchableNH : Chandelier1SwitchableNH
{
	Default
	{
	//$Title 3d Chandelier with Short Candles (NO HITBOX, RUSTY, ARGS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY A_StartSound("FIRE_SMALL", CHAN_BODY, CHANF_LOOPING, frandom(0.2,0.4) - args[0]);
	ActiveFlames:
		MDLA A 0 {
		A_SpawnItemEx("Flame_Normal3d", Scale.X*0, Scale.Y*26, 	Scale.X+Scale.Y*10, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*0, Scale.Y*-26.5, Scale.X+Scale.Y*6, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*18.7, Scale.Y*18.2, Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-18.8, Scale.Y*-18.8, Scale.X+Scale.Y*7, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*26.5, Scale.Y*-0.2, Scale.X+Scale.Y*10, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-26.4, Scale.Y*0, Scale.X+Scale.Y*8.8,0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*-18.8, Scale.Y*18.7, 	Scale.X+Scale.Y*5, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		A_SpawnItemEx("Flame_Normal3d", Scale.X*19.2, Scale.Y*-18.9, Scale.X+Scale.Y*8, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid); }
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" A -1 A_StopSound(CHAN_BODY);
		Stop;
	}
}

class Chandelier3SwitchableNH : Chandelier1SwitchableNH
{
	Default
	{
	//$Title 3d Chandelier with Tall Candles (NO HITBOX, BLACK, ARGS)
	}
}

class Chandelier4SwitchableNH : Chandelier2SwitchableNH
{
	Default
	{
	//$Title 3d Chandelier with Short Candles (NO HITBOX, BLACK, ARGS)
	}
}

class ArtDeco_WLight1 : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 3d Art-Deco Wall Light 1 (SET DORMANT & ACTIVATE IT VIA ACS)
		//$Color 11
		DistanceCheck "boa_scenelod";
		Radius 1;
		Height 1;
		-FLOORCLIP
		+NOBLOCKMAP
		+DONTTHRUST
		+NOGRAVITY
		CullActorBase.CullLevel 2;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //update manually on GZDB
	Spawn:
		MDLA A -1 LIGHT("OZYWALT2");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;} //update manually on GZDB
		Stop;
	}
}

class CODNeoLights1 : LightBaseInt
{
	Default
	{
	//$Category Lights (BoA)/ACS Switchable
	//$Title 3d Neoclassical Wall Light (SET DORMANT & ACTIVATE IT VIA ACS)
	Radius 8;
	Height 24;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //update manually on GZDB
	Spawn:
		MDLA A -1 LIGHT("OZYWALLT");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;} //update manually on GZDB
		Stop;
	}
}

class CODNeoLights2 : CODNeoLights1
{
	Default
	{
	//$Title 3d Neoclassical Wartorn Wall Light (SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //update manually on GZDB
	Spawn:
		MDLA A -1 LIGHT("OZYWALT4");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;} //update manually on GZDB
		Stop;
	}
}

class COD_ArtDecoLight1A : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 3d Art Deco Ceiling Light (OFF, SET DORMANT & ACTIVATE IT VIA ACS)
		//$Color 11
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 0;
		+NOBLOCKMAP
		+NOGRAVITY
		CullActorBase.CullLevel 2;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A -1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1 LIGHT("OZYSIMLT");
		Stop;
	}
}

class COD_ArtDecoLight1B : COD_ArtDecoLight1A
{
	Default
	{
	//$Title 3d Art Deco Ceiling Light (ON, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A -1 LIGHT("OZYSIMLT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class COD_StationLight1A : COD_ArtDecoLight1A
{
	Default
	{
	//$Title 3d Train Station Ceiling Light (OFF, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A -1;
		Loop;
	Inactive:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*1, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	InactiveLights:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1 LIGHT("OZYSIMLT");
		Stop;
	}
}

class COD_StationLight1B : COD_ArtDecoLight1A
{
	Default
	{
	//$Title 3d Train Station Ceiling Light (ON, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	ActiveLights:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*1, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	Activate:
		MDLA A 1 LIGHT("OZYSIMLT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1;
		Stop;
	}
}

class COD_StationLight1BNC : COD_ArtDecoLight1A
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Train Station Ceiling Light, no cone (ON, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1 LIGHT("OZYSIMLT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class COD_RustyChandelier1A : COD_ArtDecoLight1A
{
	Default
	{
	//$Title 3d Rusty Chandelier (OFF, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A -1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1 LIGHT("3DCHAN2");
		Stop;
	}
}

class COD_RustyChandelier1B : COD_ArtDecoLight1A
{
	Default
	{
	//$Title 3d Rusty Chandelier (ON, SET DORMANT & ACTIVATE IT VIA ACS)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A -1 LIGHT("3DCHAN2");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class COD_LampGlassOn : Glass3d { Default { DistanceCheck "boa_scenelod"; } }
class COD_LampGlassOff : Glass3d { Default { DistanceCheck "boa_scenelod"; } }

class COD_OilLamp : LightBaseARGs
{
	Default
	{
	//$Title 3d Oil Lamp (RUSTY, SWITCHABLE)
	Radius 4;
	Height 4;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY A_StartSound("FIRE_SMALL", CHAN_BODY, CHANF_LOOPING, 0.4 - args[0]);
	ActiveFlames:
		MDLA A 0 {A_SpawnItemEx("Flame_Lamp3d", 0, 0, Scale.X+Scale.Y*6, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
				A_SpawnItemEx("COD_LampGlassOn", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE, 0, tid);}
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC); //ozy. remove flames & lit glass if deactivated
		MDLA B 0 A_SpawnItemEx("COD_LampGlassOff", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); //add unlit glass
		"####" B -1 A_StopSound(CHAN_BODY);
		Stop;
	}
}

//needed for 3d chandeliers
class Flame_Normal3d : SceneryBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Scale 0.06;
		+FORCEYBILLBOARD
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+RANDOMIZE
		RenderStyle "Add";
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(235,2); //cindeeeeeeeeeeeeeerz! Yes, I love them - ozy
		TNT1 A 0 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("FloatingCinder", 0, 0, random(0,2), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE); } }
		TNT1 A 0 A_Jump(128,"Flames2","Flames3","Flames4");
		3DFR ABCDEFGHIJ 2 LIGHT ("3DFLAME_N");
		Loop;
	Flames2:
		3DFR JFHGEDCABI 2 LIGHT ("3DFLAME_N");
		Goto Spawn;
	Flames3:
		3DFR BDCEGIJHFA 2 LIGHT ("3DFLAME_N");
		Goto Spawn;
	Flames4:
		3DFR FADCEGIHJB 2 LIGHT ("3DFLAME_N");
		Goto Spawn;
	}
}

class Flame_Short3d : Flame_Normal3d
{
	Default
	{
	Scale 0.03;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(250,2);
		TNT1 A 0 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("FloatingCinder", 0, 0, random(0,2), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE); } }
		TNT1 A 0 A_Jump(128,"Flames2","Flames3","Flames4");
		3DFR ABCDEFGHIJ 2 LIGHT ("3DFLAME_S");
		Loop;
	Flames2:
		3DFR JFHGEDCABI 2 LIGHT ("3DFLAME_S");
		Goto Spawn;
	Flames3:
		3DFR BDCEGIJHFA 2 LIGHT ("3DFLAME_S");
		Goto Spawn;
	Flames4:
		3DFR FADCEGIHJB 2 LIGHT ("3DFLAME_S");
		Goto Spawn;
	}
}

class Flame_Tall3d : Flame_Normal3d
{
	Default
	{
	Scale 0.09;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(215,2);
		TNT1 A 0 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("FloatingCinder", 0, 0, random(0,2), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE); } }
		TNT1 A 0 A_Jump(128,"Flames2","Flames3","Flames4");
		3DFR ABCDEFGHIJ 2 LIGHT ("3DFLAME_T");
		Loop;
	Flames2:
		3DFR JFHGEDCABI 2 LIGHT ("3DFLAME_T");
		Goto Spawn;
	Flames3:
		3DFR BDCEGIJHFA 2 LIGHT ("3DFLAME_T");
		Goto Spawn;
	Flames4:
		3DFR FADCEGIHJB 2 LIGHT ("3DFLAME_T");
		Goto Spawn;
	}
}

class Flame_Lamp3d : Flame_Normal3d
{
	Default
	{
	Scale 0.02;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(250,2);
		TNT1 A 0 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("FloatingCinder", 0, 0, random(0,2), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE); } }
		TNT1 A 0 A_Jump(128,"Flames2","Flames3","Flames4");
		3DFR ABCDEFGHIJ 2 LIGHT ("3DFLAME_L");
		Loop;
	Flames2:
		3DFR JFHGEDCABI 2 LIGHT ("3DFLAME_L");
		Goto Spawn;
	Flames3:
		3DFR BDCEGIJHFA 2 LIGHT ("3DFLAME_L");
		Goto Spawn;
	Flames4:
		3DFR FADCEGIHJB 2 LIGHT ("3DFLAME_L");
		Goto Spawn;
	}
}

class Flame_Oven3d : Flame_Normal3d
{
	Default
	{
	Scale 0.08;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(144,2);
		TNT1 A 0 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("FloatingCinder2", Scale.X*48, 0, 4, 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE); } }
		TNT1 A 0 A_Jump(128,"Flames2","Flames3","Flames4");
		3DFR ABCDEFGHIJ 2 LIGHT ("WolfStove");
		Loop;
	Flames2:
		3DFR JFHGEDCABI 2 LIGHT ("WolfStove");
		Goto Spawn;
	Flames3:
		3DFR BDCEGIJHFA 2 LIGHT ("WolfStove");
		Goto Spawn;
	Flames4:
		3DFR FADCEGIHJB 2 LIGHT ("WolfStove");
		Goto Spawn;
	}
}

class CeilingLightM : LightBase2
{
	Default
	{
	//$Title 3d Ceiling Light (MIDDLE, SWITCHABLE)
	Radius 16;
	Height 23;
	+SPAWNCEILING
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	ActiveLights:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*12, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1;
		Stop;
	}
}

class CeilingLightM2 : CeilingLightM
{
	Default
	{
	//$Title 3d Ceiling Light (SMALL, SWITCHABLE)
	Radius 8;
	Height 10;
	-SOLID
	}
	States
	{
	ActiveLights:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*8, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	Activate:
		MDLA A 1;
		Loop;
	}
}

class CeilingLightMNC : CeilingLightM
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Ceiling Light, no cone (MIDDLE, SWITCHABLE)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1;
		Stop;
	}
}

class CeilingLightM2NC : CeilingLightM
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Ceiling Light, no cone (SMALL, SWITCHABLE)
	Radius 8;
	Height 10;
	-SOLID
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1;
		Stop;
	}
}

class StreetLight1 : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 3d Street Light (OFF, SWITCHABLE)
		//$Color 11
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 128;
		+SOLID
		CullActorBase.CullLevel 2;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
	Spawn:
		MDLA B -1;
		Stop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
	InactiveLights:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", Scale.X*50, 0, Scale.X+Scale.Y*128, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	InactiveStop:
		MDLA A 1 LIGHT("LIGHTPOSTLIGHT");
		Loop;
	}
}

class StreetLight1Lit : StreetLight1
{
	Default
	{
	//$Title 3d Street Light (ON, SWITCHABLE)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	ActiveLights:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", Scale.X*50, 0, Scale.X+Scale.Y*128, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	Activate:
		MDLA A 1 LIGHT("LIGHTPOSTLIGHT");
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1;
		Stop;
	}
}

class StreetLight2 : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 3d Street Light (TRIPLE, SWITCHABLE)
		//$Color 11
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 128;
		+SOLID
		CullActorBase.CullLevel 2;
	}
	States
	{
	Active:
		MDLA C 0 {bDormant = FALSE;}
	Spawn:
		MDLA C -1 LIGHT("BOASTLT2");
		Stop;
	Inactive:
		MDLA A -1 {bDormant = TRUE;}
		Stop;
	}
}

class StreetLight2NH : StreetLight2
{
	Default
	{
	//$Category Lights (BoA)/No Hitbox
	//$Title 3d Street Light with No Hitbox (TRIPLE, SWITCHABLE)
	Height 4;
	-SOLID
	+MOVEWITHSECTOR
	+NOBLOCKMAP
	+NOGRAVITY
	}
}

class StreetLight3 : StreetLight2
{
	Default
	{
	//$Title 3d Street Light (SINGLE, SWITCHABLE)
	}
	States
	{
	Active:
		MDLA D 0 {bDormant = FALSE;}
	Spawn:
		MDLA D -1 LIGHT("BOASTLT3");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;}
		Stop;
	}
}

class StreetLight3NH : StreetLight3
{
	Default
	{
	//$Category Lights (BoA)/No Hitbox
	//$Title 3d Street Light with No Hitbox (SINGLE, SWITCHABLE)
	Height 4;
	-SOLID
	+MOVEWITHSECTOR
	+NOBLOCKMAP
	+NOGRAVITY
	}
}

class CastleLight1 : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 3d Castle Light 1 (SWITCHABLE)
		//$Color 11
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 32;
		+NOBLOCKMAP
		+NOGRAVITY
		+SOLID
		+SPAWNCEILING
		CullActorBase.CullLevel 2;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*28, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		MDLA A -1 LIGHT("BOACEIL3");
		Stop;
	Inactive:
		MDLA A 1 {
			A_KillChildren();
			A_RemoveChildren(TRUE, RMVF_MISC);
		}
		MDLA B -1 {bDormant = TRUE;}
		Stop;
	}
}

class CastleLight2 : CastleLight1
{
	Default
	{
	//$Title 3d Castle Light 2 (SWITCHABLE)
	Height 56;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*28, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		MDLA A -1 LIGHT("BOACEIL3");
		Stop;
	}
}

class CastleLight1NC : CastleLight1
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Castle Light 1, no cone (SWITCHABLE)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A -1 LIGHT("BOACEIL3");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;}
		Stop;
	}
}

class CastleLight2NC : CastleLight2
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Castle Light 2, no cone (SWITCHABLE)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A -1 LIGHT("BOACEIL3");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;}
		Stop;
	}
}

class Cell_Light : CastleLight1
{
	Default
	{
	//$Title 3d Cell Light (SWITCHABLE)
	Radius 8;
	Height 1;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*-30, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		MDLA A -1 LIGHT("BOACEIL2");
		Stop;
	}
}

class Cell_LightNC : CastleLight1
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Cell Light, no cone (SWITCHABLE)
	Radius 8;
	Height 1;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A -1 LIGHT("BOACEIL2");
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;}
		Stop;
	}
}

class ColumnLight : LightBase
{
	Default
	{
	//$Title 3d Column Light (ON)
	//$Color 11
	DistanceCheck "boa_scenelod";
	Radius 8;
	Height 136;
	+SOLID
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;}
		Stop;
	}
}

class ColumnLight2 : ColumnLight
{
	Default
	{
	//$Title 3d Column Light (OFF)
	}
	States
	{
	Active:
		MDLA B 0 {bDormant = FALSE;}
	Spawn:
		MDLA B -1;
		Stop;
	Inactive:
		MDLA A -1 {bDormant = TRUE;}
		Stop;
	}
}

class StageLight: SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/Static
		//$Title 3d Theatre Stage Light
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 8;
		-SOLID
		+NOGRAVITY
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class FutureCeilingLight : LightBase
{
	Default
	{
	//$Title 3d Modern Ceiling Light (SWITCHABLE)
	Radius 16;
	Height 0;
	+SPAWNCEILING
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	ActiveLights:
		MDLA A 0 A_SpawnItemEx("VolumetricLight_ConeDown", 0, 0, Scale.X+Scale.Y*8, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		MDLA B -1;
		Stop;
	}
}

class FutureCeilingLightNC : FutureCeilingLight
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Modern Ceiling Light, no cone (SWITCHABLE)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class FutureCeilingLightNC2 : LightBase2
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title 3d Modern Ceiling Light, no cone & no hitbox (SWITCHABLE)
	-SOLID
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class MedicalLight : LightBase2
{
	Default
	{
	//$Category Lights (BoA)/No Cones
	//$Title Medical Operating Light, no hitbox (SWITCHABLE)
	Radius 32;
	Height 0;
	-SOLID
	+SPAWNCEILING
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A 0 NODELAY;
	Activate:
		MDLA A 1;
		Loop;
	Inactive:
		MDLA A 0 {bDormant = TRUE;}
		MDLA B -1;
		Stop;
	}
}

class LightBulb : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ARGs
		//$Title 3d Light Bulb (OFF, BREAKABLE)
		//$Color 11
		//$Arg0 "Type"
		//$Arg0Tooltip "Pickup the desired type\nBreakable: 0\nUnBreakable: 1"
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 1;
		Health 1;
		+DONTFALL
		+DONTTHRUST
		+NOBLOOD
		+NOGRAVITY
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		+SPAWNCEILING
		CullActorBase.CullLevel 2;
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A -1 NODELAY A_JumpIf(Args[0]==1, "UnBreakable");
		Stop;
	UnBreakable:
		"####" "#" 0 A_ChangeLinkFlags(1);
		"####" "#" -1;
		Stop;
	Inactive:
		MDLA B -1 BRIGHT LIGHT("BOACEIL5") {bDormant = TRUE;}
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" AAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_StartSound("GLASS5");
		MDLA CCCCCC 3 A_SpawnItemEx("SparkB", 0, 0, 0, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		MDLA C -1;
		Stop;
	}
}

class LightBulbOn : LightBulb
{
	Default
	{
	//$Title 3d Light Bulb (ON, BREAKABLE)
	}
	States
	{
	Active:
		MDLA B 0 {bDormant = FALSE;}
	Spawn:
		MDLA B -1 NODELAY BRIGHT LIGHT("BOACEIL5") A_JumpIf(Args[0]==1, "UnBreakable");
		Stop;
	UnBreakable:
		"####" "#" 0 A_ChangeLinkFlags(1);
		"####" "#" -1 BRIGHT LIGHT("BOACEIL5");
		Stop;
	Inactive:
		MDLA A -1 {bDormant = TRUE;}
		Stop;
	}
}

class LightBulb_Red : LightBulb
{
	Default
	{
	//$Title 3d Light Bulb, Red (OFF, BREAKABLE)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A -1 NODELAY A_JumpIf(Args[0]==1, "UnBreakable");
		Stop;
	UnBreakable:
		"####" "#" 0 A_ChangeLinkFlags(1);
		"####" "#" -1;
		Stop;
	Inactive:
		MDLA B -1 BRIGHT LIGHT("BOACEIL6") {bDormant = TRUE;}
		Stop;
	}
}

class LightBulbOn_Red : LightBulb
{
	Default
	{
	//$Title 3d Light Bulb, Red (ON, BREAKABLE)
	}
	States
	{
	Active:
		MDLA B 0 {bDormant = FALSE;}
	Spawn:
		MDLA B -1 NODELAY BRIGHT LIGHT("BOACEIL6") A_JumpIf(Args[0]==1, "UnBreakable");
		Stop;
	UnBreakable:
		"####" "#" 0 A_ChangeLinkFlags(1);
		"####" "#" -1 BRIGHT LIGHT("BOACEIL6");
		Stop;
	Inactive:
		MDLA A -1 {bDormant = TRUE;}
		Stop;
	}
}

class LightBulb_Grn : LightBulb
{
	Default
	{
	//$Title 3d Light Bulb, Green (OFF, BREAKABLE)
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;}
	Spawn:
		MDLA A -1 NODELAY A_JumpIf(Args[0]==1, "UnBreakable");
		Stop;
	UnBreakable:
		"####" "#" 0 A_ChangeLinkFlags(1);
		"####" "#" -1;
		Stop;
	Inactive:
		MDLA B -1 BRIGHT LIGHT("BOACEIL7") {bDormant = TRUE;}
		Stop;
	}
}

class LightBulbOn_Grn : LightBulb
{
	Default
	{
	//$Title 3d Light Bulb, Green (ON, BREAKABLE)
	}
	States
	{
	Active:
		MDLA B 0 {bDormant = FALSE;}
	Spawn:
		MDLA B -1 NODELAY BRIGHT LIGHT("BOACEIL7") A_JumpIf(Args[0]==1, "UnBreakable");
		Stop;
	UnBreakable:
		"####" "#" 0 A_ChangeLinkFlags(1);
		"####" "#" -1 BRIGHT LIGHT("BOACEIL7");
		Stop;
	Inactive:
		MDLA A -1 {bDormant = TRUE;}
		Stop;
	}
}

//Non-Interactive variants
class CeilingLightM_NoInt : CeilingLightM
{
	Default
	{
	//$Category Lights (BoA)/Non-Interactive
	//$Title 3d Non-Interactive Ceiling Light (MIDDLE, SWITCHABLE)
	+NOINTERACTION
	}
}

class CeilingLightM2_NoInt : CeilingLightM2
{
	Default
	{
	//$Category Lights (BoA)/Non-Interactive
	//$Title 3d Non-Interactive Ceiling Light (SMALL, SWITCHABLE)
	+NOINTERACTION
	}
}

class CastleLight1_NoInt : CastleLight1
{
	Default
	{
	//$Category Lights (BoA)/Non-Interactive
	//$Title 3d Non-Interactive Castle Light 1 (SWITCHABLE)
	+NOINTERACTION
	}
}

class CastleLight2_NoInt : CastleLight1
{
	Default
	{
	//$Category Lights (BoA)/Non-Interactive
	//$Title 3d Non-Interactive Castle Light 2 (SWITCHABLE)
	+NOINTERACTION
	}
}

class ChanGold_NoInt : ChanGold
{
	Default
	{
	//$Category Lights (BoA)/Non-Interactive
	//$Title 3d Non-Interactive Gold Chandelier (SWITCHABLE)
	+NOINTERACTION
	}
}

class Cell_Light_NoInt : Cell_Light
{
	Default
	{
	//$Category Lights (BoA)/Non-Interactive
	//$Title 3d Non-Interactive Cell Light (SWITCHABLE)
	+NOINTERACTION
	}
}

//2d Lights
class TableLightM : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 2d Bureau Light 1 (MIDDLE, SWITCHABLE)
		//$Color 11
		Radius 4;
		Height 32;
		Scale 0.50;
		ProjectilePassHeight 4;
		+NOTAUTOAIMED
		+SOLID
		+USESPECIAL
		Activation THINGSPEC_Switch;
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		TLIT A 0;
		Goto CheckDormant;
	CheckDormant:
		"####" "#" 0  {
			if (bDormant) {
				return ResolveState("Off");
			}
			return ResolveState("On");
		}
	On:
		"####" "#" -1 BRIGHT LIGHT("BOATABL1");
		Stop;
	Off:
		"####" "#" -1;
		Stop;
	Active: // These are just used to toggle the dormant state whenever 'used' by the player, regardless of starting value
	Inactive:
		"####" "#"0 {
			A_StartSound("SMSWITCH");
			bDormant = !bDormant;
			return ResolveState("CheckDormant");
		}
	}

	override void Activate (Actor activator)
	{
		SetStateLabel("Active");
	}

	override void Deactivate (Actor activator)
	{
		SetStateLabel("Inactive");
	}
}

class TableLightM2 : TableLightM
{
	Default
	{
	//$Title 2d Bureau Light 2 (MIDDLE, SWITCHABLE)
	Scale 0.7;
	}
	States
	{
	Spawn:
		TLIT C 0;
		Goto CheckDormant;
	}
}

class TableLightM3Y : TableLightM
{
	Default
	{
	//$Title 2d NeoClassic Yellow Lamp (MIDDLE, SWITCHABLE)
	Scale 0.53;
	}
	States
	{
	Spawn:
		TLIT G 0;
		Goto CheckDormant;
	}
}

class TableLightM3B : TableLightM
{
	Default
	{
	//$Title 2d NeoClassic Blue Lamp (MIDDLE, SWITCHABLE)
	Scale 0.53;
	}
	States
	{
	Spawn:
		TLIT H 0;
		Goto CheckDormant;
	}
}

class TableLightM3R : TableLightM
{
	Default
	{
	//$Title 2d NeoClassic Red Lamp (MIDDLE, SWITCHABLE)
	Scale 0.53;
	}
	States
	{
	Spawn:
		TLIT I 0;
		Goto CheckDormant;
	}
}

class TableLightM3G : TableLightM
{
	Default
	{
	//$Title 2d NeoClassic Grey Lamp (MIDDLE, SWITCHABLE)
	Scale 0.53;
	}
	States
	{
	Spawn:
		TLIT J 0;
		Goto CheckDormant;
	}
}

class TableLightS : TableLightM
{
	Default
	{
	//$Title 2d Table Light, Args (SMALL, SWITCHABLE)
	//$Arg0 "Type"
	//$Arg0Tooltip "Pickup the desired type\nRandom: 0\nClassic: 1\nBrown: 2\nFat: 3\nTall: 4"
	Height 16;
	-SOLID
	}
	States
	{
	Spawn:
		TLIT B 0 NODELAY {
		if (args[0] ==0 | args[0] >=6)
			{ frame = RandomPick(1, 3, 4, 5);} // For frame numbers, 0 = A, 1 = B, 2 = C, etc...  So this picks frame B, D, E, or F.
		if (args[0] ==1)
			{ frame = 1; }
		if (args[0] ==2)
			{ frame = 3; }
		if (args[0] ==3)
			{ frame = 4; }
		if (args[0] ==4)
			{ frame = 5; }
			A_Jump(256, "CheckDormant");}
	On:
		"####" "#" -1 BRIGHT LIGHT("BOATABL2");
		Stop;
	}
}

class TableLightS2 : TableLightM
{
	Default
	{
	//$Title 2d NeoClassic Table Light, Args (SMALL, SWITCHABLE)
	//$Arg0 "Type"
	//$Arg0Tooltip "Pickup the desired type\nRandom: 0\nGrey: 1\nYellow: 2\nBlue: 3\nRed: 4"
	Height 16;
	Scale 0.20;
	-SOLID
	}
	States
	{
	Spawn:
		TLIT K 0 NODELAY {
		if (args[0] ==0 | args[0] >=5)
			{ frame = RandomPick(10, 11, 12, 13);} // This picks frame K, L, M, or N.
		if (args[0] ==1)
			{ frame = 10; }
		if (args[0] ==2)
			{ frame = 11; }
		if (args[0] ==3)
			{ frame = 12; }
		if (args[0] ==4)
			{ frame = 13; }
			A_Jump(256, "CheckDormant");}
	On:
		"####" "#" -1 BRIGHT LIGHT("BOATABL2");
		Stop;
	}
}

class TableLightSA : TableLightM
{
	Default
	{
	//$Title 2d Small Table Light 1 (SWITCHABLE)
	Height 16;
	-SOLID
	}
	States
	{
	Spawn:
		TLIT B 0;
		Goto CheckDormant;
	On:
		"####" "#" -1 BRIGHT LIGHT("BOATABL2");
		Stop;
	}
}

class TableLightSB : TableLightM
{
	Default
	{
	//$Title 2d Small Table Light 2 (SWITCHABLE)
	Height 16;
	-SOLID
	}
	States
	{
	Spawn:
		TLIT D 0;
		Goto CheckDormant;
	On:
		"####" "#" -1 BRIGHT LIGHT("BOATABL2");
		Stop;
	}
}

class TableLightSC : TableLightM
{
	Default
	{
	//$Title 2d Small Table Light 3 (SWITCHABLE)
	Height 16;
	-SOLID
	}
	States
	{
	Spawn:
		TLIT E 0;
		Goto CheckDormant;
	On:
		"####" "#" -1 BRIGHT LIGHT("BOATABL2");
		Stop;
	}
}

class TableLightSD : TableLightM
{
	Default
	{
	//$Title 2d Small Table Light 4 (SWITCHABLE)
	Height 16;
	-SOLID
	}
	States
	{
	Spawn:
		TLIT F 0;
		Goto CheckDormant;
	On:
		"####" "#" -1 BRIGHT LIGHT("BOATABL2");
		Stop;
	}
}

class CreepyCandle : TableLightM
{
	Default
	{
	//$Category Lights (BoA)/ACS Switchable
	//$Title 2d Creepy Candle (ON)
	//$Color 11
	Radius 4;
	Height 8;
	Scale 0.8;
	-SOLID
	}
	States
	{
	Spawn:
		CDLE B 0;
		Goto CheckDormant;
	CheckDormant:
		"####" "#" 0  {
			if (bDormant) {
				return ResolveState("Off");
			}
			return ResolveState("On");
		}
	On:
		"####" BCDA 4 LIGHT("CREPLIT2");
		Loop;
	Off:
		"####" E -1;
		Stop;
	Active:
	Inactive:
		"####" E 0 {
			bDormant = !bDormant;
			return ResolveState("CheckDormant");}
	}
}

class CreepyCandleS : CreepyCandle
{
	Default
	{
	//$Title 2d Creepy Candle, Stackable (ON)
	+NOGRAVITY
	}
}

class CreepyCandlestick : CreepyCandle
{
	Default
	{
	//$Title 2d Creepy Candlestick (ON)
	Radius 16;
	Height 56;
	Scale 0.51;
	+SOLID
	}
	States
	{
	Spawn:
		CNHD B 0;
		Goto CheckDormant;
	On:
		"####" BCDA 4 LIGHT("CREPLIT1");
		Loop;
	}
}

class FBowl1 : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 2d Fire Bowl (ON)
		//$Color 11
		//$Sprite FBWLA0
		Radius 32;
		Height 26;
		Scale 0.78; //mxd
		+SOLID
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		FBWL A 0;
		Goto CheckDormant;
	CheckDormant:
		"####" "#" 0  {
			if (bDormant) {
				return ResolveState("Off");
			}
			return ResolveState("On");
		}
	On:
		"####" A 0 A_SpawnItemEx("FBowlFire", 0, 0, Height, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		"####" A 0 A_StartSound("SFX/FireLoop1", CHAN_BODY, CHANF_LOOPING, 0.7, ATTN_STATIC);
	FireLoop:
		FBWL ABCDEFGHIJKLM 2 LIGHT("BOAEBWL1");
		Loop;
	Off:
		"####" N -1;
		Stop;
	Active:
	Inactive:
		FBWL N 0 {
			A_StopSound(CHAN_BODY);
			A_RemoveChildren(TRUE, RMVF_MISC);
			bDormant = !bDormant;
			return ResolveState("CheckDormant");}
	}
}

class FBowlFire: SceneryBase
{
	Default
	{
		Radius 32;
		Height 30;
		DamageType "Fire";
		ProjectilePassHeight 0;
		+DONTSPLASH
		+NOGRAVITY
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		TNT1 A 0 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("FloatingCinder", 0, 0, random(0,2), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE); } }
		"####" A 16 A_Explode(8, (int) (Radius), 0, FALSE, (int) (Radius));
		Loop;
	}
}

class CBowl1 : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 2d Ceiling Fire Bowl (ON)
		//$Color 11
		Radius 8;
		Height 80;
		+NOGRAVITY
		+SOLID
		+SPAWNCEILING
		+FORCEYBILLBOARD
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		CFIR A 0;
		Goto CheckDormant;
	CheckDormant:
		"####" "#" 0  {
			if (bDormant) {
				return ResolveState("Off");
			}
			return ResolveState("On");
		}
	On:
		"####" ABC 5;
		Loop;
	Off:
		"####" D -1;
		Stop;
	Active:
	Inactive:
		"####" D 0 {
			bDormant = !bDormant;
			return ResolveState("CheckDormant");}
	}
}

class FBarrel1 : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Title 2d Fire Barrel (ON)
		//$Color 11
		Radius 16;
		Height 48;
		ProjectilePassHeight 0;
		+SOLID
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		FCNE A 0;
		Goto CheckDormant;
	CheckDormant:
		"####" "#" 0  {
			if (bDormant) {
				return ResolveState("Off");
			}
			return ResolveState("On");
		}
	On:
		"####" A 0 {
			if (!CheckRange(boa_sfxlod, true))
			{
				A_SpawnItemEx("FloatingCinder", 0, 0, random(48,54), 1, 0, random (1, 3), random (0, 360), SXF_SETMASTER | SXF_TRANSFERPITCH | SXF_CLIENTSIDE, 0, tid);
			}
		}
	FireLoop:
		"####" ABCD 3 LIGHT("BOAEBRL1");
		Loop;
	Off:
		"####" E -1;
		Stop;
	Active:
	Inactive:
		"####" E 0 {
			A_RemoveChildren(TRUE, RMVF_MISC);
			bDormant = !bDormant;
			return ResolveState("CheckDormant");}
	}
}

class Red_Light : SceneryBase
{
	Default
	{
		//$Category Lights (BoA)
		//$Title 2d Light, Red (ON, SWITCHABLE)
		//$Color 11
		Radius 16;
		Height 16;
		+DONTSPLASH
		+NOBLOCKMAP
		+NOGRAVITY
		+SPAWNCEILING
		CullActorBase.CullLevel 2;
	}
	States
	{
	Spawn:
		STRR A 0;
		Goto CheckDormant;
	CheckDormant:
		"####" "#" 0  {
			if (bDormant) {
				return ResolveState("Off");
			}
			return ResolveState("On");
		}
	On:
		"####" "#" -1 LIGHT("FIXEDRED");
		Stop;
	Off:
		"####" "#" -1;
		Stop;
	Active: // These are just used to toggle the dormant state whenever 'used' by the player, regardless of starting value
	Inactive:
		"####" "#"0 {
			bDormant = !bDormant;
			return ResolveState("CheckDormant");
		}
	}
}

class Blue_Light : Red_Light
{
	Default
	{
	//$Title 2d Light, Blue (ON, SWITCHABLE)
	}
	States
	{
	Spawn:
		STRB A -1;
		Goto CheckDormant;
	On:
		"####" "#" -1 LIGHT("FIXEDBLU");
		Stop;
	}
}

class Green_Light : Red_Light
{
	Default
	{
	//$Title 2d Light, Green (ON, SWITCHABLE)
	}
	States
	{
	Spawn:
		STRG A -1;
		Goto CheckDormant;
	On:
		"####" "#" -1 LIGHT("FIXEDGRN");
		Stop;
	}
}

class Yellow_Light : Red_Light
{
	Default
	{
	//$Title 2d Light, Yellow (ON, SWITCHABLE)
	}
	States
	{
	Spawn:
		STRY A -1;
		Goto CheckDormant;
	On:
		"####" "#" -1 LIGHT("FIXEDYEL");
		Stop;
	}
}

///////////
// FLARE //
///////////
class ActiveFlare: Actor
{
	Default
	{
	//$Category Lights (BoA)
	//$Title Active Signal Flare
	//$Color 11
	Radius 22;
	Height 11;
	}
	States
	{
	Spawn:
		FLRI A 0;
		"####" A 0 A_StartSound("Flare/Light");
		"####" A 0 A_StartSound("Flare/Loop", CHAN_BODY, CHANF_LOOPING, 1, ATTN_STATIC);
	Spawn.Loop:
		FLRI AB 1;
		Loop;
	}
}