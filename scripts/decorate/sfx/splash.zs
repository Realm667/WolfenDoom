/*
 * Copyright (c) 2016-2021 Tormentor667, Ozymandias81, AFADoomer
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

const SPLASHES_FLAGS = SXF_CLIENTSIDE | SXF_TRANSFERRENDERSTYLE | SXF_TRANSFERSTENCILCOL;

class WaterSplashGeneratorNormal : EffectSpawner
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Water Splash Generator (normal; Renderstyle, Stencilcolor are taken into account)
	//$Color 12
	//$Sprite WTSAA0
	//$Arg3 "Sound"
	//$Arg3Type 11
	//$Arg3Enum { 0 = "Yes"; 1 = "No"; }
	+CLIENTSIDEONLY
	+DONTSPLASH
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 NODELAY A_JumpIf(boa_splashswitch==0,"EndSpawn");
		TNT1 A 0 A_JumpIf(Args[3] > 0, 2);
		TNT1 A 0 A_StartSound("water/lap", CHAN_7, 0, 1.0);
		TNT1 AAAAAAA 2 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("WaterSplashSpawner", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS); } }
	Inactive:
		TNT1 A -1;
		Loop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class WaterSplashSpawner: Actor
{
	Default
	{
	+DONTSPLASH
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_Jump(256, "Splash1", "Splash2", "Splash3", "Splash4");
	Splash1:
		TNT1 A 0 A_SpawnItemEx("WaterSplashObject1", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS);
		Stop;
	Splash2:
		TNT1 A 0 A_SpawnItemEx("WaterSplashObject2", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS);
		Stop;
	Splash3:
		TNT1 A 0 A_SpawnItemEx("WaterSplashObject3", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS);
		Stop;
	Splash4:
		TNT1 A 0 A_SpawnItemEx("WaterSplashObject4", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS);
		Stop;
	}
}

class WaterSplashObject1: Actor
{
	Default
	{
	Mass 100;
	Gravity 6.0;
	Alpha 0.8;
	Scale 0.3;
	-NOGRAVITY
	+CLIENTSIDEONLY
	+DONTSPLASH
	+NOINTERACTION
	}
	States
	{
	Spawn:
		WTSA A 0 NODELAY;
		"####" A 0 ThrustThingZ(0,random(4,8),0,0);
		"####" A 0 ThrustThing(random(0,255),random(0,1),0,0);
		"####" A 1 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		"####" A 0 A_FadeOut(.025,FTF_REMOVE);
		Goto Spawn+3;
	}
}

class WaterSplashObject2 : WaterSplashObject1
{
	States
	{
		Spawn:
			WTSB A 0 NODELAY;
			Goto Super::Spawn+1;
	}
}

class WaterSplashObject3 : WaterSplashObject1
{
	States
	{
		Spawn:
			WTSB A 0 NODELAY;
			Goto Super::Spawn+1;
	}
}
class WaterSplashObject4 : WaterSplashObject1
{
	States
	{
		Spawn:
			WTSC A 0 NODELAY;
			Goto Super::Spawn+1;
	}
}

class WaterSplashCloud : ParticleBase
{
	Default
	{
	Mass 100;
	Gravity 6.0;
	Alpha 0.0;
	Scale 0.7;
	-NOGRAVITY
	+CLIENTSIDEONLY
	+DONTSPLASH
	+NOINTERACTION
	}
	States
	{
	Spawn:
		WTFG A 0 NODELAY;
		"####" A 0 ThrustThingZ(0,random(1,4),0,0);
		"####" A 0 ThrustThing(random(0,255),random(0,1),0,0);
		"####" AAAAAAAAA 2 A_FadeIn(.03);
		"####" A 2 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		"####" A 0 A_FadeOut(.03,FTF_REMOVE);
		Goto Spawn+12;
	}
}

class WaterSplashGeneratorNormalLooping : WaterSplashGeneratorNormal
{
	Default
	{
	//$Title Water Splash Generator (normal, looping; Renderstyle, Stencilcolor are taken into account)
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 NODELAY A_JumpIf(boa_splashswitch==0,"EndSpawn");
		TNT1 A 4 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("WaterSplashSpawner", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS); } }
		TNT1 A 4 { if (!CheckRange(boa_sfxlod, true)) { A_SpawnItemEx("WaterSplashCloud", random(-8,8), random(-8,8), random(0,16), 0, 0, 0, 0, SPLASHES_FLAGS); } }
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}