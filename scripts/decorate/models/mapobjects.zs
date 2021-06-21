/*
 * Copyright (c) 2020-2021 Talon1024, Ozymandias81
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

class MapObject : Object3d
{
	Default
	{
		+NOINTERACTION
	}
}

class EisenhimmelHangarDoors : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Eisenhimmel hangar doors (Animated, Set state "Close")
		//$Color 3
		+CullActorBase.DONTCULL
	}
    States
    {
    Spawn:
        MDLA A -1;
    Hold:
        "####" "#" -1;
        Stop;
    Close:
        MDLA ABCDEFGH 114;
        Goto Hold;
    }
}

class ArnhemCathedral : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem Cathedral
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 512;
		Height 1024;
	}
}

class ArnhemHouseA : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House A
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 164;
		Height 384;
	}
}

class ArnhemHouseB : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House B
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 181;
		Height 384;
	}
}

class ArnhemHouseC : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House C
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 116;
		Height 416;
	}
}

class ArnhemHouseD : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House D
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 136;
		Height 464;
	}
}
