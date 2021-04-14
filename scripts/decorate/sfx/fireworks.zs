/*
 * Copyright (c) 2019-2021 Ozymandias81, Tormentor667, AFADoomer
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

class Fireworks_Base : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Fireworks Spawner (blue,red)
	//$Color 12
	//$Arg0 "Fail"
	//$Arg0Tooltip "Chance to Fail spawn fireworks, use values from 0 (never) to 255 (always)"
	+DONTSPLASH
	+DONTSQUASH
	+NOBLOCKMAP
	+NOGRAVITY
	+NOLIFTDROP
	+NONSHOOTABLE
	+NOTARGET
	+NOTELEOTHER
	}
	States
	{
	Active:
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A random(35,210) A_SpawnItemEx("Fireworks_Rocket", 0, 0, 16, frandom(0.0,0.1), frandom(0.0,0.1), frandom(4.0,8.0), random(0,359), 0, Args[0]);
		Loop;
	Inactive:
		TNT1 A 1;
		Wait;
	}
}

class Fireworks_LightDummy_Red : Fireworks_Base
{
	States
	{
	Spawn:
		TNT1 A 70;
		Stop;
	}
}

class Fireworks_LightDummy_Blue : Fireworks_Base
{
	States
	{
	Spawn:
		TNT1 A 70;
		Stop;
	}
}

class Fireworks_Rocket : Fireworks_Base //removed reactiontime 50 to improve performance - ozy81
{
	int user_die;
	Default
	{
	Scale 0.06;
	Gravity 0.02;
	Renderstyle "Add";
	-NOGRAVITY
	+BRIGHT
	+FORCEXYBILLBOARD
	+MISSILE
	}
	States
	{
	Spawn:
		FRWX Z 0 NODELAY;
		FRWX Z 0 {user_die++; if(user_die > 49) {user_die = 0; return ResolveState("Death");} return ResolveState(null);}
		FRWX Z 0 A_StartSound("fireworks/scream", CHAN_AUTO, 0, frandom(0.45,1.0), ATTN_IDLE);
		FRWX Z 1 { A_SpawnItemEx("Fireworks_Sparkle", random(-2,2), random(-2,2), 0, frandom(0.0,0.1), frandom(0.0,0.1), 0, random(0,359), 0, 0); A_SpawnItemEx("Fireworks_Sparkle", random(0,8), random(0,8), 0, frandom(0.0,0.1), frandom(0.0,0.1), 0, random(0,359), 0, 0); }
		FRWX Y 1 { A_SpawnItemEx("Fireworks_Sparkle", random(-2,2), random(-2,2), 0, frandom(0.0,0.1), frandom(0.0,0.1), 0, random(0,359), 0, 0); A_SpawnItemEx("Fireworks_Sparkle", random(0,8), random(0,8), 0, frandom(0.0,0.1), frandom(0.0,0.1), 0, random(0,359), 0, 0); }
		FRWX Z 0 A_Jump(127, "Spawn");
		Loop;
	Death:
		FRWX O 0 A_SetScale(1.0);
		FRWX O 0 A_StartSound("fireworks/boom", CHAN_AUTO, 0, frandom(0.75,3.0), ATTN_NONE);
		FRWX OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 0 A_SpawnItemEx("Fireworks_Ember", random(-4,4), random(-4,4), random(-4,4), frandom(-2.0,14.0), frandom(-2.0,14.0), frandom(-2.0,14.0), random(0,359), 0, 0);
		FRWX OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 0 A_SpawnItemEx("Fireworks_Bokeh", random(-8,8), random(-8,8), random(-8,8), frandom(-0.5,2.0), frandom(-0.5,2.0), frandom(-0.5,2.0), random(0,359), 0, 0);
		FRWX O 0 { A_SpawnItemEx("Fireworks_LightDummy_Blue"); A_SpawnItemEx("Fireworks_LightDummy_Red"); }
		FRWX OOOOOOOOOO 1 A_FadeOut(0.1);
		Stop;
	}
}

class Fireworks_Sparkle : Fireworks_Base
{
	Default
	{
	Radius 8;
	Height 8;
	Scale 0.025;
	Alpha 1.0;
	Renderstyle "Add";
	+BRIGHT
	+FORCEXYBILLBOARD
	+ROLLSPRITE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_Jump(127, "Rotate_Left");
	Rotate_Right:
		FRWX PPPPPPPPPP random(1,2) {A_SetRoll(roll+16.0, SPF_INTERPOLATE); A_SetScale(Scale.Y+0.005);}
		FRWX PPPPPPPPPP random(1,3) {A_SetRoll(roll+16.0, SPF_INTERPOLATE); A_SetScale(Scale.Y-0.005); A_FadeOut(0.01); }
		Stop;
	Rotate_Left:
		FRWX PPPPPPPPPP random(1,2) {A_SetRoll(roll-16.0, SPF_INTERPOLATE); A_SetScale(Scale.Y+0.005);}
		FRWX PPPPPPPPPP random(1,3) {A_SetRoll(roll-16.0, SPF_INTERPOLATE); A_SetScale(Scale.Y-0.005); A_FadeOut(0.01); }
		Stop;
	}
}

class Fireworks_Ember : Fireworks_Sparkle
{
	Default
	{
	Gravity 0.05;
	Scale 0.15;
	-NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_Jump(127, "Slower", "Slow", "Fast");
		TNT1 A 0 A_SetScale(frandom(0.2,0.5));
	Faster:
		FRWX JIHGFEDCBA random(3,4) {A_SetScale(Scale.Y+0.005); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		FRWX AAAAAAAAAA random(4,6) {A_FadeOut(0.1); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		Stop;
	Fast:
		FRWX ABCDEFGHIJ random(4,5) {A_SetScale(Scale.Y+0.005); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		FRWX JJJJJJJJJJ random(5,8) {A_FadeOut(0.1); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		Stop;
	Slow:
		FRWX JIHGFEDCBA random(2,3) {A_SetScale(Scale.Y+0.005); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		FRWX AAAAAAAAAA random(6,9) {A_FadeOut(0.1); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		Stop;
	Slower:
		FRWX ABCDEFGHIJ random(4,5) {A_SetScale(Scale.Y+0.005); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		FRWX JJJJJJJJJJ random(4,6) {A_FadeOut(0.1); A_ChangeVelocity(Vel.X/1.5, Vel.Y/1.5, Vel.Z/1.5, CVF_REPLACE); }
		Stop;
	}
}

class Fireworks_Bokeh : Fireworks_Ember
{
	Default
	{
	Scale 0.05;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_Jump(127, "Slower", "Medium");
		TNT1 A 0 A_SetScale(frandom(0.03,0.05));
	Faster:
		FRWX UUUUUUUUUUUUUUUUUUUU random(1,3) {A_SetScale(Scale.Y+0.01); A_FadeOut(0.05);}
		Stop;
	Medium:
		FRWX VVVVVVVVVVVVVVVVVVVV random(1,3) {A_SetScale(Scale.Y+0.01); A_FadeOut(0.05);}
		Stop;
	Slower:
		FRWX WWWWWWWWWWWWWWWWWWWW random(1,3) {A_SetScale(Scale.Y+0.01); A_FadeOut(0.05);}
		Stop;
	}
}