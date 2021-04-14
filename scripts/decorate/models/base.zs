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

const MODELS_FLAGS1 = SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_SETMASTER;
const MODELS_FLAGS2 = SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE;

//Base stuff - ModelBase moved on zscript codes
class DecalBase : SceneryBase
{
	Default
	{
		DistanceCheck "boa_scenelod";
		Radius 128;
		Height 0;
		Scale 1.25;
		-SOLID
		+NOBLOCKMAP
		+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class MuseumBase : SceneryBase
{
	Default
	{
		//$Category Models (BoA)/No Hitbox
		//$Color 7
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 4;
		-SOLID
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class InteractionBase : SwitchableDecoration
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 8;
		Health 10;
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
		+SYNCHRONIZED
		+USESPECIAL
		Activation THINGSPEC_Switch;
	}
}

class Object3d : ModelBase
{
	Default
	{
		+NOBLOCKMAP
		+SOLID
	}
}

class Obstacle3d : Object3d
{
	Default
	{
		Health -1;
		-FLOORCLIP
		-NOBLOCKMAP
		+CANPASS
		+DONTTHRUST
		+NOBLOOD
		+NOBLOODDECALS
		+NODAMAGE
		+NOTAUTOAIMED
		+SHOOTABLE
	}
}

class Furniture3d : Obstacle3d
{
	Default
	{
		//$Category Furniture (BoA)
		//$Color 3
		DistanceCheck "boa_scenelod";
	}
}

class Furniture_End3d: Actor  //this doesn't have boa_scenelod to force needed effect on c3m6_b battle - ozy81
{
	Default
	{
		//$Category Final Battle (BoA)
		//$Color 3
		Height 2;
		Radius 2;
		+CANPASS
		+MOVEWITHSECTOR
		+NOGRAVITY
		+SOLID
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

//some smart bridges
class Bridge256_3d : InvisibleBridge { Default {Radius 256; Height 256;} }
class Bridge192_3d : InvisibleBridge { Default {Radius 192; Height 192;} }
class Bridge176_3d : InvisibleBridge { Default {Radius 176; Height 176;} }
class Bridge144_3d : InvisibleBridge { Default {Radius 144; Height 144;} }
class Bridge128_3d : InvisibleBridge { Default {Radius 128; Height 128;} }
class Bridge96_3d : InvisibleBridge { Default {Radius 96; Height 96;} }
class Bridge64_3d : InvisibleBridge { Default {Radius 64; Height 64;} }
class Bridge56_3d : InvisibleBridge { Default {Radius 56; Height 56;} }
class Bridge48_3d : InvisibleBridge { Default {Radius 48; Height 48;} }
class Bridge32_3d : InvisibleBridge { Default {Radius 32; Height 32;} }
class Bridge24_3d : InvisibleBridge { Default {Radius 24; Height 24;} }
class Bridge16_3d : InvisibleBridge { Default {Radius 16; Height 16;} }
class Bridge8_3d : InvisibleBridge { Default {Radius 8; Height 24;} }