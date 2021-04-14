/*
 * Copyright (c) 2017-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer
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

class Flare1 : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Flare (white)
	//$Color 12
	Height 16;
	Radius 16;
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	Scale 0.5;
	RenderStyle "Add";
	}
	States
	{
	Spawn:
	Active:
		FLAR A -1;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}

class Flare2 : Flare1
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Flare (fire)
	//$Color 12
	}
	States
	{
	Spawn:
	Active:
		FLAR B -1 BRIGHT;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}

class Flare3d : Flare1
{
	Default
	{
	+FORCEXYBILLBOARD
	Scale 1.2;
	}
}

class Flare_Sun : Flare1
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Flare (Sun)
	//$Color 12
	+FORCEXYBILLBOARD
	Scale 1.0;
	}
	States
	{
	Spawn:
	Active:
		SUNL A -1 BRIGHT;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}