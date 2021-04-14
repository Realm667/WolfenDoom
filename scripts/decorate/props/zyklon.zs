/*
 * Copyright (c) 2019-2021 Ozymandias81
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

class ZSkeletons: Actor
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Zyklon Contaminated Skeletons (random)
	//$Color 4
	//$Sprite ZPRPI0
	Radius 8;
	Height 8;
	Scale 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		ZPRP D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZRandomBodyParts1 : RandomBodyParts
{
	Default
	{
	//$Title Zyklon Body Parts (male, random)
	//$Color 4
	//$Sprite ZCORA0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22);
		ZCOR A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR N -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR O -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR P -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR Q -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR R -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR S -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR T -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR U -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOR V -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZLyingBodies1 : RandomBodyParts
{
	Default
	{
	//$Title Zyklon Contaminated Corpse, Lying (male, random)
	//$Color 4
	//$Sprite ZBEDA0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9);
		ZBED A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZBED I -1 A_SetScale(0.53);
		Stop;
	}
}

class ZLyingBodies2 : ZLyingBodies1
{
	Default
	{
	//$Title Zyklon Contaminated Corpse, Lying (child, random)
	//$Color 4
	//$Sprite ZCHLA0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		ZCHL A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCHL B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCHL C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCHL D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCHL E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCHL F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCHL G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZBodySamples : Camp_PrisonerSamples
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Zyklon Contaminated Body Sample (random, shootable)
	//$Color 4
	//$Sprite ZJARA0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13);
		CJAR A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CJAR B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CJAR C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CJAR D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZJAR I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZImpaledHeads : Camp_RandomPileDead
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Zyklon Contaminated Impaled Heads (random)
	//$Color 4
	//$Sprite ZPRPA0
	Height 88;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		ZPRP A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPRP C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZDeadBody : DeadBody
{
	Default
	{
	//$Title Zyklon Contaminated Dead Body (male, random)
	//$Sprite ZODYA0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,"Breathing");
		ZODY A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZODY B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZODY C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZODY D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZODY E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Breathing:
		ZODY E 0 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
	BreathLoop:
		"####" E 1 A_SetTics(Random(40,80));
		"####" F 1 A_SetTics(Random(8,16));
		"####" G 1 A_SetTics(Random(8,16));
		"####" H 1 A_SetTics(Random(8,16));
		"####" G 1 A_SetTics(Random(8,16));
		"####" F 1 A_SetTics(Random(8,16));
		Loop;
	}
}

class ZDogsBodies : DogsBodies
{
	Default
	{
	//$Title Zyklon Contaminated Dead Dogs (random)
	//$Sprite ZARKD0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		ZARK D -1 A_SetScale(0.9);
		ZARK E -1 A_SetScale(0.9);
		ZYDO D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZDOG K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZCatsBodies : CatsBodies //recolors not included yet - ozy81
{
	Default
	{
	//$Title Zyklon Contaminated Dead Cats (random)
	//$Sprite ZCATD0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		ZCAT D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCAT E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZCowsBodies : CowsBodies
{
	Default
	{
	//$Title Zyklon Contaminated Dead Cows (random)
	//$Sprite ZCOWG0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		ZCOW H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW N -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZPigsBodies : PigsBodies
{
	Default
	{
	//$Title Zyklon Contaminated Dead Pigs (random)
	//$Sprite ZPIGJ0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8);
		ZPIG J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG N -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG O -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG P -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG Q -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ZDeadBear : DeadBear
{
	Default
	{
	//$Title Zyklon Contaminated Dead Bear (random sides)
	}
	States
	{
	Spawn:
		ZBER B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}