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

//Ozy81 models
class REWheelchair : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Resident Evil Wheelchair
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 48;
	}
}

class Cello : MuseumBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Cello
		//$Color 3
		Height 16;
		Radius 16;
	}
}

class Handrail : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Handrail
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 1;
		Height 1;
		-FLOORCLIP
		+MOVEWITHSECTOR
	}
}

class CeilingFan : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Ceiling Fan
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 0;
		+NOBLOCKMAP
		+NOGRAVITY
		+SPAWNCEILING
		Scale 0.85;
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("WoodenBlades", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2);
		Stop;
	}
}

class WoodenBlades : ModelBase
{
	Default
	{
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 0;
		+NOBLOCKMAP
		+SPAWNCEILING
		Scale 0.85;
	}
}

class CeilingFanD : CeilingFan
{
	Default
	{
		//$Title Ceiling Fan, Destroyed
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class Wheelbarrow : Obstacle3d //Hunter01
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Wheelbarrow
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 16;
	}
}

class Lids1 : MuseumBase
{
	Default
	{
	//$Title Wooden Lid 1 (without hitbox)
	}
}

class Lids2 : Lids1
{
	Default
	{
		//$Title Wooden Lid 2 (without hitbox)
	}
}

class Lids3 : Lids1
{
	Default
	{
		//$Title Wooden Lid 3 (without hitbox)
	}
}

class Lids4 : Lids1
{
	Default
	{
		//$Title Wooden fake Trap-Door (without hitbox)
	}
}

class Planks1 : Lids1
{
	Default
	{
		//$Title Wooden Plank, 256x2x16 (without hitbox)
	}
}

class Planks2 : Lids1
{
	Default
	{
		//$Title Wooden Plank, 128x2x16 (without hitbox)
	}
}

class Planks3 : Lids1
{
	Default
	{
		//$Title Wooden Plank, 64x2x16 (without hitbox)
	}
}

class Planks4 : Lids1
{
	Default
	{
		//$Title Wooden Plank, 256x16x16 (without hitbox)
	}
}

class Planks5 : Lids1
{
	Default
	{
		//$Title Wooden Plank, 128x16x16 (without hitbox)
	}
}

class Planks6 : Lids1
{
	Default
	{
		//$Title Wooden Plank, 64x16x16 (without hitbox)
	}
}

class OilCan : Obstacle3d //Sutinoer
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Oil Can
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 4;
	}
}

class Hammer1 : MuseumBase //Sutinoer
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Hammer, simple
		//$Color 3
		Radius 2;
		Height 2;
	}
}

class Hammer2 : Hammer1
{
	Default
	{
		//$Title Hammer, sledge
	}
}

class Hammer3 : Hammer1
{
	Default
	{
		//$Title Hammer, detailed
	}
}

class Saw1 : Hammer1 //Sutinoer
{
	Default
	{
		//$Title Saw 1
	}
}

class Saw2 : Hammer1
{
	Default
	{
		//$Title Saw 2
	}
}

class Tongs : Hammer1 //Sutinoer
{
	Default
	{
		//$Title Tongs
	}
}

class Wrench : Hammer1 //Sutinoer
{
	Default
	{
		//$Title Wrench, complex
	}
}

class WaterTower : ModelBase //MaxED
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Watertower
		//$Color 3
		DistanceCheck "boa_scenelod";
	}
}

class Windmill : Obstacle3d //MaxED
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Windmill (don't scale it more than 1.2!)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 64;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_StartSound("misc/windmill", CHAN_AUTO, CHANF_LOOPING, 0.7);
		MDLA A -1 A_SpawnItemEx("WindmillWheel", 24, 0, Scale.Y*476);
		Stop;
	}
}

class WindmillWheel : ModelBase //MaxED
{
	Default
	{
		DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A 1 A_SetRoll(roll + 0.3);
		Loop;
	}
}

class Tent : ModelBase //Enjay
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Tent
		//$Color 3
		DistanceCheck "boa_scenelod";
	}
}

class Bunker3D_A : ModelBase //Enjay
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Decorative Bunker Turret A
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 4;
	}
}

class Bunker3D_B : Bunker3D_A //Enjay
{
	Default
	{
		//$Title Decorative Bunker Turret B
	}
}

class FlakGun3D : Obstacle3d //MaxED
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Flakgun
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 40;
		Height 64;
	}
}

class FlakGun3DNC : MuseumBase
{
	Default
	{
		//$Title Flakgun (no hitbox)
	}
}

//RTCW stuff
class Book1_3d : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Book (front)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 8;
	}
}

class Book2_3d : Book1_3d
{
	Default
	{
		//$Title Book (back)
	}
}

class RTCWGenerator : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Generator
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 32;
	}
}

class RTCWChalice : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Holy Graal
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 32;
	}
}

class RTCWClock : Obstacle3d //fixed by mxd
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Clock
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 12;
		Height 96;
		+SYNCHRONIZED
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("RTCWClockPendulum", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2);
		Goto TickLoop;
	TickLoop: // Tried adding those sound effects to RTCWClockPendulum, found out that it horribly messes model interpolation... - mxd
		MDLA A 0 A_CheckRange(512,"NoTickLoop"); //tweak for sound channels - ozy81
		MDLA A 44 A_StartSound("oldclock/tick");
		MDLA A 0 A_Jump(1, "Chime");
		Loop;
	Chime:
		MDLA A 278 A_StartSound("oldclock/chime", CHAN_ITEM);
		Goto TickLoop;
	NoTickLoop:
		MDLA A 44;
		MDLA A 0 A_Jump(1, "NoChime");
		Goto TickLoop;
	NoChime:
		MDLA A 278;
		Goto TickLoop;
	}
}

class RTCWClockPendulum : Obstacle3d //mxd
{
	Default
	{
		DistanceCheck "boa_scenelod";
		+SYNCHRONIZED
	}
	States
	{
	Spawn:
		MDLA ABCDEFGHIJKLKJIHGFEDCB 4;
		Loop;
	}
}

class Typewriter : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Typewriter
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 16;
	}
}

class TypewriterSmall : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Typewriter (small)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 7;
	}
}

class RadioModern: SceneryBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Radio (modern, destroyable, not interactive)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 20;
		Health 25;
		-FLOORCLIP
		-NOBLOCKMAP
		+CANPASS
		+DONTSPLASH
		+DONTTHRUST
		+NOBLOOD
		+NOBLOODDECALS
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Death:
		MDLA B 0 A_StartSound("METALBRK", CHAN_ITEM, 0, frandom (0.5,0.8), ATTN_STATIC);
		"####" B 0 A_StartSound("tesla/loop", CHAN_AUTO, CHANF_LOOPING, 1.0);
		"####" B 0 A_UnSetSolid;
		"####" B 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" BBBBBB 3 A_SpawnItemEx("SparkB", Scale.X*24, frandom(-12.0,12.0), Scale.Y*12, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" B 0 A_StopSound(CHAN_AUTO);
		"####" BBBBBB 3 A_SpawnItemEx("SparkW", Scale.X*24, frandom(-12.0,12.0), Scale.Y*12, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" B -1;
		Stop;
	}
}

class RTCWParlor : InteractionBase
{
	Default
	{
		//$Title Parlor Radio (destroyable, interactive)
	}
	States
	{
	Active:
		MDLA A 0 A_StartSound("radios/loops", CHAN_ITEM);
		Goto SpawnSet;
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("InteractionIcon", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnSet:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA A 0 A_StopSound(CHAN_ITEM);
		Goto SpawnSet;
	Death:
		MDLA B 0 A_StopSound(CHAN_ITEM);
		"####" B 0 A_StartSound("METALBRK", CHAN_ITEM, 0, frandom (0.5,0.8), ATTN_STATIC);
		"####" B 0 A_StartSound("tesla/loop", CHAN_6, CHANF_LOOPING, 1.0);
		"####" B 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" B 0 {bUseSpecial = FALSE;}
		"####" B 0 A_UnSetSolid;
		"####" B 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" BBBBBB 3 A_SpawnItemEx("SparkR", Scale.X*24, frandom(-8.0,8.0), Scale.Y*8, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" B 0 A_StopSound(CHAN_6);
		"####" BBBBBB 3 A_SpawnItemEx("SparkR", Scale.X*24, frandom(-8.0,8.0), Scale.Y*8, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" B -1;
		Stop;
	}
}

class SovietRadio : RTCWParlor
{
	Default
	{
		//$Title Russian Radio (interactive)
		Health -1;
		-SHOOTABLE
		+NODAMAGE
	}
	States
	{
	Active:
		MDLA A 0 A_StartSound("radios2/loops", CHAN_ITEM);
		Goto SpawnSet;
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("InteractionIcon", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnSet:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA A 0 A_StopSound(CHAN_ITEM);
		Goto SpawnSet;
	}
}

class RTCWGramo : InteractionBase
{
	Default
	{
		//$Title Gramophone (destroyable, interactive)
		Radius 16;
		Height 32;
	}
	States
	{
	Active:
		MDLA A 0 A_StartSound("WALKURE", CHAN_ITEM);
		Play:
		MDLA ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
		MDLB ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
		MDLC ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
		Loop;
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("InteractionIcon", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnSet:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA A 0 A_StopSound(CHAN_ITEM);
		Goto SpawnSet;
	Death:
		MDLD A 0 A_StopSound(CHAN_ITEM);
		"####" A 0 A_StartSound("METALBRK", CHAN_ITEM, 0, frandom (0.5,0.8), ATTN_STATIC);
		"####" A 0 A_StartSound("tesla/loop", CHAN_6, CHANF_LOOPING, 1.0);
		"####" A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" A 0 {bUseSpecial = FALSE;}
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" AAAAAA 3 A_SpawnItemEx("SparkY", Scale.X*24, frandom(-16.0,16.0), Scale.Y*16, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_StopSound(CHAN_6);
		"####" AAAAAA 3 A_SpawnItemEx("SparkB", Scale.X*24, frandom(-16.0,16.0), Scale.Y*16, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" A -1;
		Stop;
	}
}

class RTCWGramoHitler : RTCWGramo
{
	Default
	{
		//$Title Hitler's Gramophone (destroyable, interactive)
	}
	States
	{
	Active:
		MDLA A 0 A_StartSound("WALKUR2", CHAN_ITEM);
		Play:
		MDLA ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
		MDLB ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
		MDLC ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
		Loop;
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("InteractionIcon", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnSet:
		MDLA A -1;
		Stop;
	}
}

class RTCWPhone : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Phone
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 8;
	}
}

class RTCWPhoneWall : MuseumBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Phone, Wall Mounted
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 2;
		Height 16;
	}
}

class EnigmaMachine : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Enigma Machine
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 8;
	}
}

class RTCWShield : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Shield with Swords
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 32;
		-SOLID
		-CANPASS
		+NOBLOCKMAP
		+NOGRAVITY
	}
}

class RTCWParachute1 : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Parachute (Ragged One)
		//$Color 3
		DistanceCheck "boa_scenelod";
	}
}

class RTCWParachute2 : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Parachute (Open One)
		//$Color 3
		DistanceCheck "boa_scenelod";
	}
}

class RTCW_V2_Complete : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title V2 (Complete)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 46;
		Height 192;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class RTCW_V2_NoRamp : RTCW_V2_Complete
{
	Default
	{
		//$Title V2 (Without Ramp)
	}
}

class RTCW_V2_Rocket : RTCW_V2_Complete
{
	Default
	{
		//$Title V2 (Rocket Only)
	}
}

class RTCW_V2_CompleteNH : MuseumBase
{
	Default
	{
		//$Title Decorative V2 (Complete)
	}
}

class Eagle3d : Obstacle3d //DoomJuan & Ozy81
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title SS Eagle
		//$Color 3
		DistanceCheck "boa_scenelod";
		Height 1;
		Radius 1;
		-SOLID
		-CANPASS
		+NOBLOCKMAP
	}
}

class Eagle2_3d : Eagle3d //Ozy81
{
	Default
	{
		//$Title Berlin SS Eagle
	}
}

//Flags
class FlagWave : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Flags
		//$Title Waving Flag (Swastika)
		//$Color 3
		//$Arg0 "Flap Sound"
		//$Arg0Type 11
		//$Arg0Enum { 0 = "Yes"; 1 = "No"; }
		DistanceCheck "boa_scenelod";
		Radius 1;
		Height 1;
		Mass 5;
		+NOINTERACTION
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_JumpIf(args[0] == 0, "SetFlap");
		Goto SetFlag;
	SetFlap:
		MDLA A 0 A_StartSound("flag/flap", 0, CHANF_LOOPING, 1.0, ATTN_IDLE); //let's play this sound only 1 time - ozy81
	SetFlag:
		TNT1 A 0 A_Jump(64,12);
		TNT1 A 0 A_Jump(84,24);
		TNT1 A 0 A_Jump(104,36);
		TNT1 A 0 A_Jump(124,48);
	SpawnLoop:
		MDLA ABCDEFGHIJKLMNOPQRSTU 1;
		MDLA VWXYZ 1;
		MDLB ABCDEFGHIJKLMNOPQRSTUV 1;
		MDLB WXYZ 1;
		MDLC ABCDEFGHIJKLMNOPQRSTU 1;
		MDLC VWXYZ 1;
		MDLD ABCDEFGHIJKLMNOPQR 1;
		Goto SpawnLoop;
	}
}

class FlagWave_SS : FlagWave
{
	Default
	{
		//$Title Waving Flag (SS)
	}
}

class FlagWave_War : FlagWave
{
	Default
	{
		//$Title Waving Flag (War Times)
	}
}

class FlagWave_Gear : FlagWave
{
	Default
	{
		//$Title Waving Flag (Gear)
	}
}

class FlagWave_State : FlagWave
{
	Default
	{
		//$Title Waving Flag (State)
	}
}

class FlagWave_US : FlagWave
{
	Default
	{
		//$Title Waving Flag (US)
	}
}

class FlagWave_France : FlagWave
{
	Default
	{
		//$Title Waving Flag (France)
	}
}

class FlagWide_Flutter : FlagWave
{
	Default
	{
		//$Title Waving Flag, Wide (Swastika)
	}
	States
	{
	Spawn:
		MDLA ABCDEFGHIJKLMNOP 8;
		Loop;
	}
}

class FlagShort_Flutter : FlagWide_Flutter
{
	Default
	{
		//$Title Waving Flag, Short (Swastika)
	}
}

class NaziBannerTallFlutter512 : FlagWave
{
	Default
	{
		//$Title Nazi Banner Tall, Flutter (512)
	}
	States
	{
	Spawn:
		MDLA ABCDEFGHIJKLMNOP 8;
		Loop;
	}
}

class NaziBannerGearTallFlutter512 : FlagWave
{
	Default
	{
		//$Title Nazi Banner Tall, Gear, Flutter (512)
	}
	States
	{
	Spawn:
		MDLA ABCDEFGHIJKLMNOP 8;
		Loop;
	}
}

class NaziBannerTallFlutter256 : NaziBannerTallFlutter512
{
	Default
	{
		//$Title Nazi Banner Tall, Flutter (256)
	}
}

class NaziBannerTallHang512 : ModelBase //we don't need flapping sounds for a not moving flag, right? -ozy81
{
	Default
	{
		//$Category Models (BoA)/Flags
		//$Title Nazi Banner Tall, Not Moving (512)
		DistanceCheck "boa_scenelod";
		Radius 1;
		Height 1;
		Mass 5;
		+NOINTERACTION
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class NaziBannerTallHang256 : NaziBannerTallHang512
{
	Default
	{
		//$Title Nazi Banner Tall, Not Moving (256)
	}
}

class FlagWide_Hang : NaziBannerTallHang512
{
	Default
	{
		//$Title Hanging Flag, Wide (Swastika)
	}
}

class FlagShort_Hang : NaziBannerTallHang512
{
	Default
	{
		//$Title Hanging Flag, Short (Swastika)
	}
}

//Fallout 3 Models - ripped & fixed by Ozymandias81
class Gurney1 : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Old Gurney
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 32;
		+NOGRAVITY
	}
}

class Gurney2 : Gurney1
{
	Default
	{
		//$Title Old Gurney, destroyed
		-SOLID
		-CANPASS
		+NOBLOCKMAP
	}
}

//HERETIC II, HEXEN II and JEDI KNIGHT 3 MODELS - From Gore - Ozymandias81
class MineCartF : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Mine Cart, Full
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 34;
		Height 24;
		+NOGRAVITY
	}
}

class MineCartE : MineCartF
{
	Default
	{
		//$Title Mine Cart, Empty
	}
}

class MineCartW : MineCartF
{
	Default
	{
		//$Title Mine Cart, Wrecked
	}
}

class Minerals3d : Obstacle3d //Jk2
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Minerals
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 1;
		Height 1;
		+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1 LIGHT("MINERALLITE");
		Stop;
	}
}

//Sitters stuff
class Cable1 : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Cable A
		//$Color 3
		DistanceCheck "boa_scenelod";
		Height 0;
		+SPAWNCEILING
	}
}

class Cable2: Cable1
{
	Default
	{
		//$Title Cable B
	}
}

class Cable3: Cable1
{
	Default
	{
		//$Title Cable C
	}
}

class Cable4: Cable1
{
	Default
	{
		//$Title Cable D
	}
}

class Cable5: Cable1
{
	Default
	{
		//$Title Cable E
	}
}

class Trolley3d : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Trolley
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 48;
		+NOGRAVITY
	}
}

class Cannon3d : Trolley3d
{
	Default
	{
		//$Title Cannon
	}
}

class Cannonballs3d: Cannon3d
{
	Default
	{
		//$Title Cannonballs
	}
}

class Guillotine3d : Trolley3d
{
	Default
	{
		//$Category Models (BoA)/Occult
		//$Title Guillotine
	}
}

class HeadCrusher3d : Guillotine3d
{
	Default
	{
		//$Title Head Crusher
	}
}

class JudasCrusher3d: Guillotine3d
{
	Default
	{
		//$Title Judas Crusher
	}
}

class Pillory3d : Guillotine3d
{
	Default
	{
		//$Title Pillory
	}
}

class Rack3d: Guillotine3d
{
	Default
	{
		//$Title Rack
		Height 32;
	}
}

class Splitter3d: Guillotine3d
{
	Default
	{
		//$Title Splitter
		Height 32;
	}
}

class Skeleton_Sit3d : Trolley3d
{
	Default
	{
		//$Category Models (BoA)/Occult
		//$Title Skeleton (Sit)
		Height 24;
	}
}

//Talon1024 stuff
class Feldfernschreiber : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Feld Hell machine
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 32;
	}
}

class Toolbox3D: SceneryBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Toolbox (3D)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 8;
		+NOBLOCKMAP
		+NOGRAVITY
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class Spanner3D : Toolbox3D
{
	Default
	{
		//$Title Spanner (3D)
		Radius 2;
		Height 2;
	}
}

class TrainLever3D : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Train Lever
		//$Color 3
	}
}

class TrainLever3DSwitch : InteractionBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Train Lever, Nazi Eagle (Switchable)
		//$Color 3
		Height 64;
		Radius 16;
		+NODAMAGE
	}
	States
	{
	Active:
		MDLA A 0 A_StartSound("SWMECH");
		MDLA ABCDE 3;
		MDLA E -1;
		Stop;
	Spawn:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA E 0 A_StartSound("SWMECH");
		MDLA EDCBA 3;
		MDLA A -1;
		Stop;
	Death:
		MDLA A 1;
		Stop;
	}
}

class TrainLever3DSwitch1 : TrainLever3DSwitch
{
	Default
	{
		//$Title Train Lever, Red 1 (Switchable)
	}
}

class TrainLever3DSwitch2 : TrainLever3DSwitch
{
	Default
	{
	//$Title Train Lever, Red 2 (Switchable)
	}
}

class TrainLever3DSwitch3 : TrainLever3DSwitch
{
	Default
	{
	//$Title Train Lever, Blue 3 (Switchable)
	}
}

class TrainLever3DSwitch4 : TrainLever3DSwitch
{
	Default
	{
	//$Title Train Lever, Blue 4 (Switchable)
	}
}

class TrainLever3DSwitch5 : TrainLever3DSwitch
{
	Default
	{
	//$Title Train Lever, White 5 (Switchable)
	}
}

class TrainLever3DSwitch6 : TrainLever3DSwitch
{
	Default
	{
	//$Title Train Lever, White 6 (Switchable)
	}
}

class TrainLever3DSwitch7 : TrainLever3DSwitch
{
	Default
	{
	//$Title Train Lever, Brown 7 (Switchable)
	}
}

class TrainLever3DSwitch8 : TrainLever3DSwitch
{
	Default
	{
	//$Title Train Lever, Brown 8 (Switchable)
	}
}

//COD stuff
class CODPipe1 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 1
	}
}

class CODPipe2 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 2
	}
}

class CODPipe3 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 3
	}
}

class CODPipe4 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 4
	}
}

class CODPipe5 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 5
	}
}

class CODPipe6 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 6
	}
}

class CODPipe7 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 7
	}
}

class CODPipe8 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 8
	}
}

class CODPipe9 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 9
	}
}

class CODPipe10 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 10
	}
}
class CODPipe11 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 11
	}
}

class CODPipe12 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 12
	}
}

class CODPipe13 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 13
	}
}

class CODPipe14 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 14
	}
}

class CODPipe15 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 15
	}
}

class CODPipe16 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 16
	}
}

class CODPipe17 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 17
	}
}

class CODPipe18 : MuseumBase
{
	Default
	{
	//$Title Decorative Pipe 18
	}
}

class COD_WallBars1 : MuseumBase
{
Default
	{
	//$Title Rusty Wall Bars 1
	}
}

class COD_WallBars2 : COD_WallBars1
{
	Default
	{
	//$Title Rusty Wall Bars 2
	}
}

class COD_Boiler : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Bunker Boiler
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 24;
		Height 48;
		+NOGRAVITY
	}
}

class COD_Stove : COD_Boiler
{
	Default
	{
		//$Title Bunker Stove
	}
}
class COD_Crowbar : MuseumBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Crowbar
		//$Color 3
	}
}

class COD_Hammer : COD_Crowbar
{
	Default
	{
		//$Title Hammer, gross
	}
}

class COD_Screwdriver : MuseumBase
{
	Default
	{
		//$Title Screwdriver
	}
}

class COD_Toolbox : MuseumBase
{
	Default
	{
		//$Title "Toolbox, full
	}
}

class COD_Wrench : MuseumBase
{
	Default
	{
		//$Title Wrench, simple
	}
}

class COD_Popcorn : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Popcorn Stand
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 48;
		Height 48;
		+NOGRAVITY
	}
}

class COD_WBarrel1 : FuelDrumAstro
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Wooden Barrel (1st variant, movable)
		//$Color 3
		Radius 13;
		Height 32;
	}
	States
	{
	Moving:
		MDLA A 35 A_StartSound("papercrate_moving", CHAN_AUTO, 0, 0.65);
		Goto Spawn;
	}
}

class COD_WBarrel2 : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Wooden Barrel (1st variant, standing)
		//$Color 3
		Radius 24;
		Height 24;
	}
}

class COD_WBarrel3 : COD_WBarrel1
{
	Default
	{
		//$Title Wooden Barrel (2nd variant, movable)
	}
}

class COD_WBarrel4 : COD_WBarrel2
{
	Default
	{
		//$Title Wooden Barrel (2nd variant, standing)
	}
}

class COD_Gascan : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Gascan
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 32;
	}
}

class COD_RadioSimple : InteractionBase
{
	Default
	{
		//$Title Radio (interactive, destroyable, simple)
		Radius 16;
		Height 16;
	}
	States
	{
	Active:
		MDLA A 0 A_StartSound("SPEECH1", CHAN_ITEM);
		Goto SpawnSet;
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("InteractionIcon", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnSet:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA A 0 A_StopSound(CHAN_ITEM);
		Goto SpawnSet;
	Death:
		MDLA B 0 A_StopSound(CHAN_ITEM);
		"####" B 0 A_StartSound("METALBRK", CHAN_ITEM, 0, frandom (0.5,0.8), ATTN_STATIC);
		"####" B 0 A_StartSound("tesla/loop", CHAN_6, CHANF_LOOPING, 1.0);
		"####" B 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" B 0 {bUseSpecial = FALSE;}
		"####" B 0 A_UnSetSolid;
		"####" B 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" BBBBBB 3 A_SpawnItemEx("SparkB", Scale.X*24, frandom(-8.0,8.0), Scale.Y*8, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" B 0 A_StopSound(CHAN_6);
		"####" BBBBBB 3 A_SpawnItemEx("SparkB", Scale.X*24, frandom(-8.0,8.0), Scale.Y*8, 0, frandom(-1.0,1.0), frandom(-1.0,1.0), random(0,360), SXF_CLIENTSIDE);
		"####" B -1;
		Stop;
	}
}

class COD_Radio_Tall : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Radio, Tall
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 32;
		+FIXMAPTHINGPOS
		+NOGRAVITY
	}
}

class COD_Radio_Tall_D : COD_Radio_Tall
{
	Default
	{
		//$Title Radio, Tall (Blown)
	}
}

class CODSignal_Light : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Train Signal Light (off/red/yel/green)
		//$Color 3
		//$Arg0 "Light"
		//$Arg0Tooltip "Pickup the desired light\nOff: 0\nGreen: 1\nYellow: 2\nRed: 3"
		//$Arg1 "Gravity"
		//$Arg1Tooltip "Actor is affected by gravity \nNo: 0\nYes: 1"
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 128;
		+MOVEWITHSECTOR
		+NOGRAVITY
		+RELATIVETOFLOOR
		+SOLID
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Green");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Yellow");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Red");
	Off: //fall through if set at 0
		MDLA A 0 {bNoGravity = !Args[1];}
		MDLA A -1;
		Stop;
	Green:
		MDLA B 0 {bNoGravity = !Args[1];}
		MDLA B -1 LIGHT("SIGNLGRN");
		Stop;
	Yellow:
		MDLA C 0 {bNoGravity = !Args[1];}
		MDLA C -1 LIGHT("SIGNLYEL");
		Stop;
	Red:
		MDLA D 0 {bNoGravity = !Args[1];}
		MDLA D -1 LIGHT("SIGNLRED");
		Stop;
	}
}

class CODRailway_Switch : SwitchableDecoration
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Train Railway Switch (Set DORMANT & activate it via ACS)
		//$Color 3
		//$Arg0 "Gravity"
		//$Arg0Tooltip "Actor is affected by gravity \nNo: 0\nYes: 1"
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 144;
		Health -1;
		-NOBLOCKMAP
		+CANPASS
		+DONTSPLASH
		+DONTTHRUST
		+MOVEWITHSECTOR
		+NOBLOOD
		+NOBLOODDECALS
		+NODAMAGE
		+NOGRAVITY
		+NOTAUTOAIMED
		+RELATIVETOFLOOR
		+SHOOTABLE
		+SOLID
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //update manually on GZDB
	Spawn:
		MDLA A 0 NODELAY {bNoGravity = !Args[0];}
		MDLA A -1;
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;} //update manually on GZDB
		Stop;
	}
}

//TF3DM / 3dRegenerator Models
class Piano3d : InteractionBase
{
	Default
	{
		//$Title Piano
		Radius 48;
		Height 48;
		+NODAMAGE
		-SHOOTABLE
	}
	States
	{
	Active:
		MDLA A 0 A_StartSound("CLAIREDL", CHAN_ITEM);
		Goto SpawnSet;
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("InteractionIcon", 0, 0, 64, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnSet:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA A 0 A_StopSound(CHAN_ITEM);
		Goto SpawnSet;
	}
}

//Archibase.net Stuff
class CanyonRockSpawner : RockSpawner //ozymandias81
{
	Default
	{
		//$Title Canyon Rock Spawner
	}
}

class DryRockSpawner : CanyonRockSpawner
{	Default
	{
	//$Title Dry Rock Spawner
	}
}

class SnowyRockSpawner : CanyonRockSpawner
{	Default
	{
	//$Title Snowy Rock Spawner
	}
}

class MuddyRockSpawner : CanyonRockSpawner
{	Default
	{
	//$Title Muddy Rock Spawner
	}
}

class LunarRockSpawner : CanyonRockSpawner
{	Default
	{
	//$Title Lunar Rock Spawner (Astrostein)
	}
}

class SandRockSpawner : CanyonRockSpawner
{	Default
	{
	//$Title Sand Rock Spawner (Tunis)
	}
}

//NOLF1 Stuff
class RooftopAntennae : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Rooftop Antennae
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 64;
	}
}

//Mohofoz Stuff
class Speakers_1_3d : Obstacle3d
{	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Tannoy Speakers (Single)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 8;
		-CANPASS
	}
}

//Hypnagogia Stuff
class Suitcase1 : MuseumBase
{
	Default
	{
	//$Title Suitcase, normal (without hitbox)
	}
}

class OldCash : Obstacle3d
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Antique Cash
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 4;
	Height 8;
	+NOGRAVITY
	}
}

class NaziGlobe : OldCash
{
	Default
	{
	//$Title Hitler's Globe
	Radius 24;
	Height 48;
	-NOGRAVITY
	}
}

class Speakers_2_3d : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Tannoy Speakers (Double)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 96;
	}
}

class Speakers_4_3d : Speakers_2_3d
{
	Default
	{
		//$Title Tannoy Speakers (Four)
	}
}

class SecretUFO : SwitchableDecoration //3dRealms - no distancecheck for this
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Secret UFO
		//$Color 3
		+MOVEWITHSECTOR
	}
	States
	{
	Spawn:
		MDLA A -1;
		Wait;
	Active:
		"####" A 35; //just wait 1 sec before spawning effects
		"####" A 0 A_StartSound("UFOLNCH", CHAN_AUTO, 0, 1.0, ATTN_NONE);
	ActiveLoop:
		MDLA A 0 A_SpawnItemEx("UFOCirclePad",0,0,-8,0,0,random(1,8), SXF_SETMASTER | SXF_NOCHECKPOSITION);
		"####" A 15;
		Loop;
	Inactive:
		MDLA A 0 A_StartSound("UFOEXPL", CHAN_AUTO, 0, 1.0, ATTN_NONE);
		"####" A 0 A_NoBlocking;
		"####" A 0 A_RemoveChildren(TRUE, RMVF_EVERYTHING);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Tank", random(-256, 256), random(-256, 256), random(16, -16), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_MetalJunk", random(-256, 256), random(-256, 256), random(16, -16), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Metal1", random(-256, 256), random(-256, 256), random(16, -16), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Metal2", random(-256, 256), random(-256, 256), random(16, -16), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Metal3", random(-256, 256), random(-256, 256), random(16, -16), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
		"####" AAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Large", random(64, 256), random(64, 256), random(16, -16), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("UFONuke", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 0 A_SpawnItemEx("UFOSmokePillar", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 1 A_SpawnItemEx("UFOSmokePillar", 0, 0, -512, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 10;
		"####" A 1 A_FadeOut(0.0001);
		Stop;
	}
}

class MusicStand : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Music Stand
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 40;
	}
}

class CastleShield1 : MuseumBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Decorative Shield 1, No Hitbox
	}
}

class CastleShield2 : MuseumBase
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Shield 2, No Hitbox
	}
}

class CastleShield3 : MuseumBase
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Shield 3, No Hitbox
	}
}

class CastleShield4 : MuseumBase
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Shield 4, No Hitbox
	}
}

class CastleShield5 : MuseumBase
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Shield 5, No Hitbox
	}
}

class CastleShield6 : MuseumBase
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Shield 6, No Hitbox
	}
}

class CastleShield7 : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Hanging Shield, No Hitbox
	}
}

class CastleWeapon1 : MuseumBase
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Mace, No Hitbox
	}
}

class CastleWeapon2 : MuseumBase
{
	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Halberd, No Hitbox
	}
}

class CastleWeapon3 : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Sword 1, No Hitbox
	}
}

class CastleWeapon4 : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Sword 2, No Hitbox
	}
}

class CastleWeapon5 : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Sword 3, No Hitbox
	}
}

class CastleWeapon6 : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Decorative Sword 4, No Hitbox
	}
}