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

class CirclePad: EffectSpawner
{
	int padradius;
	int padvelz;
	int padlife;

	Property PadRadius:padradius;
	Property PadVelZ:padvelz;
	Property PadLifetime:padlife;

	Default
	{
		//$Category Special Effects (BoA)
		//$Color 12
		//$Arg0 "Nothing"
		//$Arg0Tooltip "Does nothing"
		//$Arg1 "Radius"
		//$Arg1Tooltip "Controls the size of the area. 32, for example, spawns in a 64x64 diameter circle."
		//$Arg2 "Speed"
		//$Arg2Tooltip "Controls the speed of the rings (can also be negative if you want them to move downwards instead of upwards)"
		StencilColor "FFFFFF";
		CirclePad.PadRadius 128;
		CirclePad.PadVelZ 1;
		CirclePad.PadLifetime 20;
	}

	States
	{
		Spawn:
			TNT1 A 1;
		Active:
			TNT1 A 5 SpawnEffect();
			Loop;
		Inactive:
			TNT1 A 5;
			Loop;
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		if (bDormant || flags & MTF_DORMANT) { SetStateLabel("Inactive"); }

		padradius = Args[1] ? Args[1] : Default.padradius;
		padvelz = Args[2] ? Args[2] : Default.padvelz;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		FSpawnParticleParams particleInfo;
		particleInfo.color1 = fillcolor & 0xFFFFFF;
		particleInfo.texture = TexMan.CheckForTexture("LRFXB0");
		particleInfo.style = STYLE_Add;
		particleInfo.flags = SPF_FULLBRIGHT | SPF_REPLACE;
		particleInfo.lifetime = padlife;
		particleInfo.size = 32;
		particleInfo.vel = (0, 0, padvelz);
		particleInfo.startalpha = 0.8;
		particleInfo.fadestep = -1;

		for (double a = 0; a < 360; a += min(30, 640.0 / (padradius / (curchunk ? max(1, curchunk.range) : 1))))
		{
			particleInfo.pos = pos + (RotateVector((padradius, 0), a), 0);
			Level.SpawnParticle(particleInfo);
		}
	}
}

class GreenCirclePad : CirclePad
{
	Default
	{
		//$Title CirclePad (green)
		StencilColor "67df5f";
	}
}

class BlueCirclePad : CirclePad
{
	Default
	{
		//$Title CirclePad (blue)
		StencilColor "20FCFC";
	}
}

class WhiteCirclePad : CirclePad
{
	Default
	{
		//$Title CirclePad (custom color - set on Action/Tag/Misc. tab)
	}
}

class RedCirclePad : CirclePad
{
	Default
	{
		//$Title CirclePad (red)
		StencilColor "FF0000";
	}
}

class OrangeCirclePad: CirclePad
{
	Default
	{
		//$Title CirclePad (orange)
		StencilColor "FC7800";
	}
}

class UFOCirclePad: CirclePad //fixed values for SecretUFO effect
{
	Default
	{
		+NOGRAVITY
		StencilColor "67df5f";
		CirclePad.PadVelZ -4;
	}

	States
	{
		Spawn:
			TNT1 A 1;
		Active:
			TNT1 A 15 SpawnEffect();
			Loop;
		Inactive:
			TNT1 A 5;
			Loop;
	}

	override void Tick()
	{
		Super.Tick();

		if (master) { SetXYZ(master.pos); }
	}

	override void SpawnEffect()
	{
		padlife = int(min(70, (pos.z - floorz) / abs(padvelz)));

		Super.SpawnEffect();

		for (int s = 0; s < 16; s += (curchunk ? curchunk.range : 1))
		{
			Actor spark = Spawn("SparkG", pos + (Random[Spark](-64, 64), Random[Spark](-64, 64), Random[Spark](-32, 0)));
			if (spark)
			{
				spark.Vel3DFromAngle(spark.speed, FRandom[Spark](0, 360), Random[Spark](67, 113));
			}
		}
	}
}