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

class VolumetricLight_ConeDown : VolumetricBase
{
	Default
	{
	//$Title Volumetric Light, Downward (PLACE IT 256MP MINIMUM)
	}
	States
	{
	Spawn:
	Active:
		VOLT A 1 NODELAY A_SpawnItemEx("AlertLight", 0, 0, -112, 0, 0, 0, 0, SXF_SETMASTER | SXF_SETTRACER);
	ActiveLoop:
		VOLT A 1;
		Loop;
	Inactive:
		TNT1 A 1 A_RemoveTracer(RMVF_MISC);
		Loop;
	}
}

class VolumetricLight_ConeUp : VolumetricBase //spawn correct AlertLight & sprite
{
	Default
	{
	//$Title Volumetric Light, Upward
	//$Sprite VOLTB0
	}
	States
	{
	Spawn:
	Active:
		VOLT B 1 NODELAY A_SpawnItemEx("AlertLight", 0, 0, 112, 0, 0, 0, 0, SXF_SETMASTER | SXF_SETTRACER);
	ActiveLoop:
		VOLT B 1;
		Loop;
	Inactive:
		TNT1 A 1 A_RemoveTracer(RMVF_MISC);
		Loop;
	}
}

class VolumetricLight_ConePitch : VolumetricBase
{
	Default
	{
	//$Title Volumetric Light, Pitchable (NO ALERTLIGHT)
	+FLATSPRITE
	}
	States
	{
	Spawn:
	Active:
		VOLT A 1;
		Loop;
	Inactive:
		TNT1 A 1;
		Loop;
	}
}