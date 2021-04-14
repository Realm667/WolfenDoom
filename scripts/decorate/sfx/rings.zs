/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, AFADoomer
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

/////////////////////////////////
// POWERUP POD CIRCLE SPAWNERS //
// for REALM667				   //
// by Tormentor667			   //
/////////////////////////////////

class BaseOrb : ParticleBase
{
	Default
	{
	Radius 0;
	Height 0;
	-SOLID
	+BRIGHT
	+MISSILE
	+NOBLOCKMAP
	+NOGRAVITY
	+NOINTERACTION
	RenderStyle "Add";
	Alpha 0.01;
	YScale 0.1;
	XScale 0.4;
	}
	States
	{
	Spawn:
		LRFX AAAAA 1 A_FadeIn(0.2);
		"####" AAAAAAAAAAAAAAAA 1 A_FadeOut(0.07);
		Stop;
	}
}

class GreenCirclePad: Actor
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title CirclePad (green)
	//$Color 12
	//$Arg0 "Nothing"
	//$Arg0Tooltip "Does nothing"
	//$Arg1 "Radius"
	//$Arg1Tooltip "Controls the size of the area. 32, for example, spawns in a 64x64 diameter circle."
	//$Arg2 "Speed"
	//$Arg2Tooltip "Controls the speed of the rings (can also be negative if you want them to move downwards instead of upwards)"
	-SOLID
	+CLIENTSIDEONLY
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	+NOSECTOR
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0;
		TNT1 A 0 A_CheckSightOrRange(512, "Inactive");
		TNT1 A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 0, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 10, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 20, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 30, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 40, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 50, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 60, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 70, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 80, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], 90, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],100, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],110, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],120, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],130, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],140, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],150, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],160, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],170, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],180, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],190, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],200, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],210, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],220, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],230, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],240, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],250, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],260, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],270, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],280, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],290, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],310, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],320, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],330, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],340, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],350, 129, 0);
		"####" A 4 A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2],360, 129, 0);
		Loop;
	Inactive:
		TNT1 A 1;
		TNT1 A 0 A_CheckSightOrRange(512, "Inactive");
		Goto Active;
	}
}

class BlueCirclePad : GreenCirclePad
{
	Default
	{
	//$Title CirclePad (blue)
	Translation "112:127=196:207";
	}
}

class WhiteCirclePad : GreenCirclePad
{
	Default
	{
	//$Title CirclePad (white)
	Translation "112:127=80:111";
	}
}

class RedCirclePad : GreenCirclePad
{
	Default
	{
	//$Title CirclePad (red)
	Translation "112:127=176:191";
	}
}

class OrangeCirclePad: GreenCirclePad
{
	Default
	{
	//$Title CirclePad (orange)
	Translation "112:127=214:223";
	}
}

class UFOCirclePad: Actor //fixed values for SecretUFO effect
{
	Default
	{
	-SOLID
	+CLIENTSIDEONLY
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	+NOSECTOR
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 0, 129, 0);
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnProjectile("SparkG", 0, random(-64,64), random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 10, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 20, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 30, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 40, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 50, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 60, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 70, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 80, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, 90, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,100, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,110, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,120, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,130, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,140, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,150, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,160, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,170, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,180, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,190, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,200, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,210, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,220, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,230, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,240, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,250, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,260, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,270, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,280, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,290, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,310, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,320, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,330, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,340, 129, 0);
		"####" A 0 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,350, 129, 0);
		"####" A 2 A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4,360, 129, 0);
		"####" "#" 2 A_FadeOut(0.04,FTF_REMOVE);
		Loop;
	}
}