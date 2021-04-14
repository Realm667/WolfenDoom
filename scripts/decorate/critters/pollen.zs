/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, AFADoomer, Talon1024
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

class PollenAir : EffectBase
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Pollen
		//$Color 0
		DistanceCheck "boa_sfxlod";
		Radius 1;
		Height 1;
		Speed 1;
		Mass 5;
		Scale 0.1;
		-PUSHABLE
		+CANNOTPUSH
		+CANPASS
		+DONTOVERLAP
		+FLOATBOB
		+FRIENDLY
		+NOBLOCKMAP
		+NOGRAVITY
		+NOLIFTDROP
		+NOTARGET
		+RANDOMIZE
		+SPAWNFLOAT
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		CRIT A 2 A_Wander;
		Loop;
	}
}