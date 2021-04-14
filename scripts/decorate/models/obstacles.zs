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

//Enjay models
class ModelBeachHedgeHog : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Obstacles
		//$Title Beach Hedgehog
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 32;
	}
}

class ModelSandBagCurve : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Obstacles
		//$Title Sandbag (curve)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 12;
		Height 16;
		-SOLID
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("Bridge16_3d",0,-16,0);
		MDLA A -1 A_SpawnItemEx("Bridge16_3d",0,16,0);
		Stop;
	}
}

class ModelSandBagStraight : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Obstacles
		//$Title Sandbag (straight)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 16;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("Bridge16_3d",0,-16,0);
		MDLA A -1 A_SpawnItemEx("Bridge16_3d",0,16,0);
		Stop;
	}
}

class Wire3D : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Obstacles
		//$Title Wire
		//$Color 3
		DistanceCheck "boa_scenelod";
		Height 32;
	}
}

class FuelDrum : Obstacle3d //MaxED
{
	Default
	{
		//$Category Models (BoA)/Obstacles
		//$Title Fuel Drum
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 43;
		-NOGRAVITY
		ModelBase.Buoyancy 0.2;
	}
}

//this actor is needed on rare occasions where we can stay below them when crouch then stand up, it doesn't move the drum, like on c2m1
class FuelDrumFix : FuelDrum
{
	Default
	{
		//$Title Fuel Drum, non-solid for players
		
		+THRUSPECIES
		Species "Player";
	}
}

class FuelDrumSide : FuelDrum
{
	Default
	{
		//$Title Fuel Drum on Side, non-solid for players
		Height 24;
		+THRUSPECIES
		Species "Player";
	}
}

class GasDrum : Obstacle3d //MaxED
{
	Default
	{
		//$Category Models (BoA)/Obstacles
		//$Title Gas Drum
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 42;
		-NOGRAVITY
		ModelBase.Buoyancy 0.15;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Destroyed:
		MDLA B -1;
		Stop;
	}
}

class FuelDrumAstro: Actor //Ozy81
{
	Default
	{
		//$Category Models (BoA)/Obstacles
		//$Title Fuel Drum (Astrostein, pushable)
		//$Color 3
		DistanceCheck "boa_scenelod";
		+CANPASS
		+MOVEWITHSECTOR	//I add this because we may need it for some "arcade" sequences -ozy
		+NOBLOOD
		+NODAMAGE
		+NOTAUTOAIMED
		+PUSHABLE
		+SHOOTABLE
		+SLIDESONWALLS	//let's prevent some weird behaviors, like being stuck in a map because the crate can't get out from an angle -ozy
		+SOLID
		Radius 24;
		Height 56;
		Mass 15000;
	}
	States
	{
	Spawn:
		MDLA A 1;
		Goto Look;
	Look:
		MDLA A 8 A_LookEx(LOF_NOSOUNDCHECK, 0, 64, 0, 360);
		Loop;
	See:
		MDLA A 0 A_JumpIf((Vel.X != 0 || Vel.Y != 0), "Moving");
		Goto Spawn;
	Moving:
		MDLA A 35 A_StartSound("astrodrum_moving", CHAN_AUTO, 0, 0.65);
		Goto Spawn;
	}
}

class MovableCrate1 : Obstacle3d //MaxED
{
	Default
	{
		//$Category Models (BoA)/Pushables
		//$Title Movable Crate (paper, 64)
		Radius 32;
		Height 64;
		Mass 9000;
		+MOVEWITHSECTOR
		-NOGRAVITY
		+PUSHABLE
		+SLIDESONWALLS
		ModelBase.Buoyancy 0.2;
	}
	States
	{
	Spawn:
		MDLA A 1;
		Goto Look;
	Look:
		MDLA A 8 A_LookEx(LOF_NOSOUNDCHECK, 0, 64, 0, 360);
		Loop;
	See:
		MDLA A 0 A_JumpIf((Vel.X != 0 || Vel.Y != 0), "Moving");
		Goto Spawn;
	Moving:
		MDLA A 35 A_StartSound("papercrate_moving", CHAN_AUTO, 0, 0.65);
		Goto Spawn;
	}
}

class MovableCrate2 : MovableCrate1
{
	Default
	{
		//$Title Movable Crate (paper, 32)
		Radius 16;
		Height 32;
		Mass 4500;
	}
}

class MovableCrate3 : MovableCrate1
{
	Default
	{
		//$Title Movable Crate (wood, 32)
		Radius 16;
		Height 32;
		Mass 4500;
	}
}

class MovableCrate4 : MovableCrate1
{
	Default
	{
		//$Title Movable SS Eagle Crate (wood, 32)
		Radius 16;
		Height 32;
		Mass 4500;
	}
}