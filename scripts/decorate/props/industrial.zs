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

class RadioactiveBarrel : Obstacle3d //3d actor
{
	Default
	{
	//$Category Props (BoA)/Industrial
	//$Title Radioactive Barrel
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 16;
	Height 43;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class RadioactiveBarrel2 : RadioactiveBarrel //3d actor
{
	Default
	{
	//$Title Radioactive Barrel, stackable
	+NOGRAVITY
	}
}

class Crane: SceneryBase //3d actor
{
	Default
	{
		//$Category Props (BoA)/Industrial
		//$Title Crane
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 8;
		Height 80;
		+NOGRAVITY
		+SOLID
		+SPAWNCEILING
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class UBoat : Crane
{
	Default
	{
	//$Title U-Boat
	Height 40;
	}
	States
	{
	Spawn:
		UBOT A -1;
		Stop;
	}
}

class Zapper: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Industrial
		//$Title Zapper
		//$Color 3
		Radius 8;
		Height 56;
		Scale 0.5;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		EZAP ABCDEFGH 3;
		Loop;
	}
}

class Pipe1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Industrial/Pipes
		//$Title Pipe (thick)
		//$Color 3
		Radius 8;
		Height 128;
		+SOLID
		+FORCEYBILLBOARD
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		PIPE A -1;
		Stop;
	}
}

class Pipe2 : Pipe1
{
	Default
	{
	//$Title Pipe (middle)
	}
	States
	{
	Spawn:
		PIPE B -1;
		Stop;
	}
}

class Pipe3 : Pipe1
{
	Default
	{
	//$Title Pipe (small)
	}
	States
	{
	Spawn:
		PIPE C -1;
		Stop;
	}
}

class Pipe4 : Pipe1
{
	Default
	{
	//$Title Pipe (thin)
	}
	States
	{
	Spawn:
		PIPE D -1;
		Stop;
	}
}