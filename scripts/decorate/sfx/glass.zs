/*
 * Copyright (c) 2017-2021 Tormentor667, Ozymandias81, Ed the Bat
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

class BOD_GlassShardSpawner : GlassJunk replaces GlassJunk //just needed for the regular mirror breaker effect -T667
{
	Default
	{
	DeathSound "world/glassbreak";
	}
	States
	{
	Spawn:
		TNT1 A 1 A_Scream;
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("BOD_GlassShard", random(-32,32), random(-32,32), random(-32,32), frandom(0.5,1.0), frandom(0.5,1.0), frandom(0.5,1.0), random(0,360));
		Stop;
	}
}

class BOD_GlassShard : GlassShard
{
	Default
	{
	Radius 1;
	Height 1;
	Mass 5;
	Projectile;
	-ACTIVATEIMPACT
	-ACTIVATEPCROSS
	-NOGRAVITY
	+RANDOMIZE
	BounceType "Doom"; //otherwise they'll still "jump" over 3d objects - like chairs inside the barber shop on c1m5 - ozy81
	BounceFactor 0.3;
	WallBounceFactor 0.3;
	BounceCount 3;
	RenderStyle "Translucent";
	Alpha 0.5;
	Gravity 0.4;
	}
	States
	{
	Spawn:
		SHAR A 0 NODELAY A_SetScale(frandom(0.3,0.8), frandom(0.3,0.8));
	LetsShard:
		SHAR ABCDE 4;
		Loop;
	Death:
		TNT1 A 0 A_Jump(255, "Fade1", "Fade2", "Fade3", "Fade4");
	Fade1:
		SHAR E 25 A_Fadeout(0.1);
		Loop;
	Fade2:
		SHAR D 35 A_Fadeout(0.1);
		Loop;
	Fade3:
		SHAR C 32 A_Fadeout(0.1);
		Loop;
	Fade4:
		SHAR B 28 A_Fadeout(0.1);
		Loop;
	}
}

class BOD_GlassShardActivatable : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Glass Shard Spawner (25 pieces)
	//$Color 12
	//$Sprite SHARA0
	//$Arg0 "Height"
	//$Arg0Tooltip "Height in map units\nDefault: 0"
	//$Arg1 "Width"
	//$Arg1Tooltip "Width x2 in map units\nDefault: 0"
	Height 8;
	Radius 4;
	+CLIENTSIDEONLY
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	}
	States
	{
	Spawn:
	Inactive:
		TNT1 A -1;
		Loop;
	Active:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("BOD_GlassShard", 0, random(-Args[1], Args[1]), random(0, Args[0]), frandom(-0.8,0.8), frandom(1.0,3.0), frandom(0.1,0.5), 0, 0, 0);
		TNT1 A 0 A_StartSound("world/glassbreak");
		Stop;
	}
}