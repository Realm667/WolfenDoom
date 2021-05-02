/*
 * Copyright (c) 2017-2021 Tormentor667, AFADoomer, Ozymandias81
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

class SkyboxTracerTrail: Actor //3d actor
{
	Default
	{
	Alpha 1.0;
	Scale 1.0;
	RenderStyle "Add";
	+BRIGHT
	+CLIENTSIDEONLY
	+NOINTERACTION
	}
	States
	{
	Spawn:
		MDLA A 70;
		Goto Death;
	Death:
		MDLA A 4 A_FadeOut(0.1);
		Loop;
	}
}

class SkyboxTracerSpawner : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Skyfire Tracers
	//$Color 12
	//$Sprite UNKNA0
	+INVULNERABLE
	+NOGRAVITY
	+NOINTERACTION
	+SHOOTABLE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
	Active:
		TNT1 A 12 A_SpawnItemEx("SkyboxTracerTrail", 0, 0, 0, 1, 0, 8, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE);
		Loop;
	Inactive:
		TNT1 A -1;
		Stop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}