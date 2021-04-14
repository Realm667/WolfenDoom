/*
 * Copyright (c) 2018-2021 Tormentor667, AFADoomer, Ozymandias81
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

///////////////////////////
// SWIRL by TORMENTOR667 //
///////////////////////////

class Swirl_Normal : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Swirl (Projectile)
	//$Color 12
	//$Sprite SWRLA0
	Radius 1;
	Height 1;
	+NOGRAVITY
	-SOLID
	Alpha 1.0;
	Scale 0.3;
	RenderStyle "Add";
	}
	States
	{
	Active:
	Spawn:
		SWRL YXWVUTSRQPONMLKJIHGFEDCBA 2 BRIGHT;
		Loop;
	Inactive:
		TNT1 A 1;
		Wait;
	}
}

class Swirl_Wall : Swirl_Normal
{
	Default
	{
	//$Title Swirl (Wallsprite)
	+ROLLSPRITE
	+WALLSPRITE
	}
}

class Swirl_XL1 : Swirl_Wall
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Swirl Large 1 (Flatsprite)
	//$Color 12
	//$Sprite SWRXA0
	-WALLSPRITE
	+FLATSPRITE
	Health 1;
	Alpha 1.0;
	Scale 1.0;
	}
	States
	{
	Active:
	Spawn:
		SWRX A 3 BRIGHT;
		Loop;
	Inactive:
		TNT1 A 1;
		Wait;
	Death:
		SWRX AAAAAAAAAAAAAAAAAAAA 5 A_Fadeout(0.05);
		Stop;
	}
}

class Swirl_XL2 : Swirl_XL1
{
	Default
	{
	//$Title Swirl Large 2 (Flatsprite)
	//$Sprite SWRXB0
	}
	States
	{
	Active:
	Spawn:
		SWRX B 3 BRIGHT;
		Loop;
	Inactive:
		TNT1 A 1;
		Wait;
	Death:
		SWRX BBBBBBBBBBBBBBBBBBBB 5 A_Fadeout(0.05);
		Stop;
	}
}

class Swirl_XL3 : Swirl_XL1
{
	Default
	{
	//$Title Swirl Large 3 (Flatsprite)
	//$Sprite SWRXC0
	}
	States
	{
	Active:
	Spawn:
		SWRX C 3 BRIGHT;
		Loop;
	Inactive:
		TNT1 A 1;
		Wait;
	Death:
		SWRX CCCCCCCCCCCCCCCCCCCC 5 A_Fadeout(0.05);
		Stop;
	}
}

class Swirl_XL4 : Swirl_XL1
{
	Default
	{
	//$Title Swirl Large 4 (Flatsprite)
	//$Sprite SWRXD0
	}
	States
	{
	Active:
	Spawn:
		SWRX D 3 BRIGHT;
		Loop;
	Inactive:
		TNT1 A 1;
		Wait;
	Death:
		SWRX DDDDDDDDDDDDDDDDDDDD 5 A_Fadeout(0.05);
		Stop;
	}
}