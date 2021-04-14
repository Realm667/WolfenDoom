/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81
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

/////////////////////////////
// STONE & ROCK PROJECTILE //
/////////////////////////////
class FallingRock : RandomSpawner
{
	Default
	{
		DropItem "FallingRock1";
		DropItem "FallingRock2";
	}
}

class FallingRock1: Actor
{
	Default
	{
		Radius 8;
		Height 12;
		Damage 1;
		Projectile;
		-NOGRAVITY
		+ROLLSPRITE
		+TOUCHY
		Obituary "$OBFALLRK";
		DeathSound "misc/SRCRK2";
		SeeSound "misc/SRCRK1";
	}
	States
	{
	Spawn:
		SRR1 A 0 NODELAY A_Gravity;
		"####" A 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Goto Spawn+1;
	Death:
		"####" A 2;
		TNT1 A 0 A_SpawnProjectile("FallingRockFrac1",0,random(-2,2),0,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		"####" A 0 A_SpawnProjectile("FallingRockFrac2",0,random(-4,4),45,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		"####" A 0 A_SpawnProjectile("FallingRockFrac3",0,random(-8,8),90,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		"####" A 0 A_SpawnProjectile("FallingRockFrac1",0,random(-2,2),135,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		"####" A 0 A_SpawnProjectile("FallingRockFrac2",0,random(-4,4),180,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		"####" A 1 A_SpawnProjectile("FallingRockFrac3",0,random(-8,8),225,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		"####" A 0 A_SpawnProjectile("FallingRockFrac1",0,random(-2,2),270,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		"####" A 0 A_SpawnProjectile("FallingRockFrac2",0,random(-4,4),315,2,CMF_AIMDIRECTION|CMF_BADPITCH);
		Stop;
	}
}

class FallingRock2 : FallingRock1
{
	States
	{
	Spawn:
		SRR2 A 0 NODELAY A_Gravity;
		"####" A 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Goto Spawn+1;
	}
}

class FallingRockFrac1: Actor
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 12;
		DamageFunction (random(0,1));
		Projectile;
		+ROLLSPRITE
		BounceType "Doom";
		BounceFactor 0.4;
	}
	States
	{
	Spawn:
		SRR3 A 0 NODELAY A_Gravity;
		"####" A 1 A_SetRoll(roll+20, SPF_INTERPOLATE,0);
		Goto Spawn+1;
	Death:
		"####" A 300;
		"####" A 6 A_FadeOut;
		Wait;
	}
}

class FallingRockFrac2 : FallingRockFrac1
{
	States
	{
	Spawn:
		SRR4 A 0 NODELAY A_Gravity;
		"####" A 1 A_SetRoll(roll-20, SPF_INTERPOLATE,0);
		Goto Spawn+1;
	}
}

class FallingRockFrac3 : FallingRockFrac1
{
	States
	{
	Spawn:
		SRR5 A 0 NODELAY A_Gravity;
		"####" A 1 A_SetRoll(roll+20, SPF_INTERPOLATE,0);
		Goto Spawn+1;
	}
}

class FallingMetal : RandomSpawner
{
	Default
	{
		DropItem "FallingMetal1";
		DropItem "FallingMetal2";
		DropItem "FallingMetal3";
		DropItem "FallingMetal4";
	}
}

class FallingMetal1 : FallingRock1
{
	Default
	{
		Scale 1.25;
		+RANDOMIZE
		Obituary "$OBFALLMT";
		DeathSound "debris/metals";
		SeeSound "floor/met2";
	}
	States
	{
	Spawn:
		FMTL A 0 NODELAY A_Jump(255,"Set1","Set2","Set3","Set4","Set5","Set6","Set7");
		Set1:
		"####" A 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set2:
		"####" B 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set3:
		"####" C 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set4:
		"####" D 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set5:
		"####" E 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set6:
		"####" F 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set7:
		"####" G 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
	Death:
		"####" "#" 2;
		TNT1 A 0 A_SpawnItemEx("FallingMetlFrac1", random(2,-2), random(2,-2), random(0,4), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("FallingMetlFrac2", random(2,-2), random(2,-2), random(0,4), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("FallingMetlFrac1", random(2,-2), random(2,-2), random(0,4), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("FallingMetlFrac2", random(2,-2), random(2,-2), random(0,4), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("FallingMetlFrac1", random(2,-2), random(2,-2), random(0,4), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 1 A_SpawnItemEx("FallingMetlFrac2", random(2,-2), random(2,-2), random(0,4), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class FallingMetal2 : FallingMetal1
{
	States
	{
	Spawn:
		FMTL A 0 NODELAY A_Jump(255,"Set1","Set2","Set3","Set4","Set5","Set6","Set7");
		Set1:
		"####" A 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set2:
		"####" B 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set3:
		"####" C 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set4:
		"####" D 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set5:
		"####" E 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set6:
		"####" F 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set7:
		"####" G 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
	}
}

class FallingMetal3 : FallingMetal1
{
	Default
	{
		Scale 0.65;
	}
	States
	{
	Spawn:
		FMTL H 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7","Set8","Set9","Set10","Set11","Set12","Set13","Set14","Set15");
		Set1:
		"####" H 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set2:
		"####" I 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set3:
		"####" J 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set4:
		"####" K 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set5:
		"####" L 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set6:
		"####" M 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set7:
		"####" N 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set8:
		"####" O 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set9:
		"####" P 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set10:
		"####" Q 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set11:
		"####" R 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set12:
		"####" S 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set13:
		"####" T 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set14:
		"####" U 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set15:
		"####" V 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
	}
}

class FallingMetal4 : FallingMetal1
{
	Default
	{
		Scale 0.65;
	}
	States
	{
	Spawn:
		FMTL H 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7","Set8","Set9","Set10","Set11","Set12","Set13","Set14","Set15");
		Set1:
		"####" H 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set2:
		"####" I 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set3:
		"####" J 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set4:
		"####" K 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set5:
		"####" L 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set6:
		"####" M 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set7:
		"####" N 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set8:
		"####" O 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set9:
		"####" P 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set10:
		"####" Q 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set11:
		"####" R 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set12:
		"####" S 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set13:
		"####" T 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set14:
		"####" U 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set15:
		"####" V 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
	}
}

class FallingMetlFrac1 : FallingRockFrac1
{
	Default
	{
		Scale 0.75;
	}
	States
	{
	Spawn:
		FMTL A 0 NODELAY { A_Gravity(); A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7"); }
		Set1:
		"####" A 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set2:
		"####" B 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set3:
		"####" C 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set4:
		"####" D 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set5:
		"####" E 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set6:
		"####" F 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
		Set7:
		"####" G 1 A_SetRoll(roll+8, SPF_INTERPOLATE,0);
		Loop;
	Death:
		"####" "#" 1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y / 2);
		"####" "#" 300;
		"####" "#" 6 A_FadeOut;
		Wait;
	}
}

class FallingMetlFrac2 : FallingMetlFrac1
{
	States
	{
	Spawn:
		FMTL A 0 NODELAY { A_Gravity(); A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7"); }
		Set1:
		"####" A 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set2:
		"####" B 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set3:
		"####" C 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set4:
		"####" D 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set5:
		"####" E 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set6:
		"####" F 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
		Set7:
		"####" G 1 A_SetRoll(roll-8, SPF_INTERPOLATE,0);
		Loop;
	}
}