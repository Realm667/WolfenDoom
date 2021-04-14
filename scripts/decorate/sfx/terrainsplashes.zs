/*
 * Copyright (c) 2016-2021 Tormentor667, Ozymandias81
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Water Splash ///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
class BoA_WaterSplash: Actor
{
	Default
	{
	RenderStyle "Translucent";
	Alpha 0.0;
	XScale 0.1;
	YScale 0.2;
	+DONTSPLASH
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	}
	States
	{
	Spawn:
		WSPL A 0 A_SetScale(Scale.X+(frandom(-0.1,0.1)), Scale.Y+(frandom(-0.1,0.1)));
		"####" "#" 0 A_SetTranslucent(frandom(0.6,0.3));
	Death:
		"####" "#" 0 A_FadeOut(0.1,FTF_REMOVE);
		"####" "#" 1 A_SetScale(Scale.X+0.05, Scale.Y+0.05);
		Loop;
	}
}

class BoA_WaterSplash_Chunk : BoA_WaterSplash
{
	Default
	{
	Alpha 0.5;
	Scale 0.1;
	Gravity 0.1;
	-NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(127,2);
		WSPL B 0;
		Goto Active;
		WSPL C 0;
	Active:
		"####" "#" 0 A_SetScale(Scale.X+(frandom(-0.05,0.05)), Scale.Y+(frandom(-0.05,0.05)));
		"####" "#" 0 A_SetTranslucent(frandom(0.8,0.5));
	Death:
		"####" "#" 0 A_FadeOut(0.1,FTF_REMOVE);
		"####" "#" 3 A_SetScale(Scale.X+0.05, Scale.Y+0.05);
		Loop;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Lava Splash ////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
class BoA_LavaSplash : BoA_WaterSplash
{
	Default
	{
	RenderStyle "Add";
	Alpha 1.0;
	XScale 0.15;
	YScale 0.1;
	}
	States
	{
	Spawn:
		LSPL A 0 A_SetScale(Scale.X+(frandom(-0.1,0.1)), Scale.Y+(frandom(-0.1,0.1)));
		"####" "#" 0 A_SetTranslucent(frandom(1.0,0.7),1);
		"####" "#" 0 A_SpawnItemEx("DarkSmoke1");
	Death:
		"####" "#" 0 A_FadeOut(0.15,FTF_REMOVE);
		"####" "#" 2 A_SetScale(Scale.X+0.03, Scale.Y+0.03);
	Loop;
	}
}

class BoA_LavaSplash_Chunk : BoA_LavaSplash
{
	Default
	{
	Scale 0.1;
	Gravity 0.1;
	-NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(127,2);
		LSPL B 0;
		Goto Active;
		LSPL C 0;
	Active:
		"####" "#" 0 A_SetScale(Scale.X+(frandom(-0.05,0.05)), Scale.Y+(frandom(-0.05,0.05)));
		"####" "#" 0 A_SetTranslucent(frandom(1.0,0.7),1);
	Death:
		"####" "#" 0 A_FadeOut(0.1,FTF_REMOVE);
		"####" "#" 3 A_SetScale(Scale.X+0.05, Scale.Y+0.05);
		Loop;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Sizzle Smoke ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
class BoA_LavaSmoke: Actor
{
	States
	{
	Spawn:
		"####" "#" 0 A_SpawnItemEx("DarkSmoke1");
		Stop;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Nukage Splash //////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
class BoA_NukageSplash: Actor
{
	Default
	{
	RenderStyle "Add";
	Alpha 0.0;
	XScale 0.1;
	YScale 0.2;
	+DONTSPLASH
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	}
	States
	{
	Spawn:
		NSPL A 0 A_SetScale(Scale.X+(frandom(-0.1,0.1)), Scale.Y+(frandom(-0.1,0.1)));
		"####" "#" 0 A_SetTranslucent(frandom(1.0,0.7),1);
	Death:
		"####" "#" 0 A_FadeOut(0.1,FTF_REMOVE);
		"####" "#" 1 A_SetScale(Scale.X+0.05, Scale.Y+0.05);
		Loop;
	}
}

class BoA_NukageSplash_Chunk : BoA_NukageSplash
{
	Default
	{
	Alpha 0.5;
	Scale 0.1;
	Gravity 0.1;
	-NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(127,2);
		NSPL B 0;
		Goto Active;
		NSPL C 0;
	Active:
		"####" "#" 0 A_SetScale(Scale.X+(frandom(-0.05,0.05)), Scale.Y+(frandom(-0.05,0.05)));
		"####" "#" 0 A_SetTranslucent(frandom(1.0,0.6),1);
	Death:
		"####" "#" 0 A_FadeOut(0.1,FTF_REMOVE);
		"####" "#" 3 A_SetScale(Scale.X+0.05, Scale.Y+0.05);
		Loop;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Slime Splash ///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
class BoA_SlimeSplash: Actor
{
	Default
	{
	RenderStyle "Translucent";
	Alpha 0.0;
	XScale 0.2;
	YScale 0.1;
	+DONTSPLASH
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	}
	States
	{
	Spawn:
		SSPL A 0 A_SetScale(Scale.X+(frandom(-0.1,0.1)), Scale.Y+(frandom(-0.1,0.1)));
		"####" "#" 0 A_SetTranslucent(frandom(1.0,0.7));
	Death:
		"####" "#" 0 A_FadeOut(0.03,FTF_REMOVE);
		"####" "#" 1 A_SetScale(Scale.X+0.015, Scale.Y+0.015);
		Loop;
	}
}

class BoA_SlimeSplash_Chunk : BoA_SlimeSplash
{
	Default
	{
	Alpha 0.5;
	Scale 0.1;
	Gravity 0.1;
	-NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(127,2);
		SSPL B 0;
		Goto Active;
		SSPL C 0;
	Active:
		"####" "#" 0 A_SetScale(Scale.X+(frandom(-0.05,0.05)), Scale.Y+(frandom(-0.05,0.05)));
		"####" "#" 0 A_SetTranslucent(frandom(1.0,0.7));
	Death:
		"####" "#" 0 A_FadeOut(0.1,FTF_REMOVE);
		"####" "#" 6 A_SetScale(Scale.X+0.05, Scale.Y+0.05);
		Loop;
	}
}