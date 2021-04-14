/*
 * Copyright (c) 2016-2021 Ozymandias81, AFADoomer
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

class KickPuff : BlastEffect
{
	Default
	{
	+NOBLOCKMAP
	+NOEXTREMEDEATH
	+NOGRAVITY
	+PUFFONACTORS
	RenderStyle "Add";
	Obituary "$OBKICKS";
	ProjectileKickback 100;
	Scale 0.4;
	DamageType "Melee";
	}
	States
	{
	Spawn:
	Melee:
	Crash:
		POOF A 3 A_StartSound("kick/hit");
		POOF A 0 A_Blast(BF_DONTWARN|BF_NOIMPACTDAMAGE, 200, random(8,16), frandom(20.0,30.0));
		POOF A 0 Radius_Quake(1,random(15,20),0,8,0);
		POOF BCDE 3;
		Stop;
	XDeath:
		POOF A 3 A_StartSound("kick/hit");
		Goto Crash+1;
	}
}