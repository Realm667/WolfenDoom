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

class GreenCirclePad: EffectSpawner
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
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 10 SpawnEffect();
			Loop;
		Inactive:
			TNT1 A 1;
			Goto Active;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		for (int a = 0; a < 360; a += (5 + 5 * (curchunk ? curchunk.range : 1)))
		{
			A_SpawnItemEx("BaseOrb", Args[1], 0, 0, 0, 0, Args[2], a, SXF_TRANSFERTRANSLATION, 0);
		}
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

class UFOCirclePad: EffectSpawner //fixed values for SecretUFO effect
{
	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 10 SpawnEffect();
			TNT1 A 0 A_FadeOut(0.5, FTF_REMOVE);
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		for (int a = 0; a < 360; a += (5 + 5 * (curchunk ? curchunk.range : 1)))
		{
			A_SpawnItemEx("BaseOrb", 128, 0, 0, 0, 0, -4, a, SXF_TRANSFERTRANSLATION, 0);
		}

		for (int s = 0; s < 16; s += (curchunk ? curchunk.range : 1))
		{
			angle = Random[Spark](0, 360);
			A_SpawnProjectile("SparkG", 0, Random[Spark](-64, 64), 0, CMF_AIMDIRECTION | CMF_BADPITCH | CMF_ABSOLUTEANGLE, Random[Spark](-67,-113));
		}
	}
}