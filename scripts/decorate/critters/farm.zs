/*
 * Copyright (c) 2016-2021 Ozymandias81, Tormentor667, AFADoomer
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

class Cows: SceneryBase
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Cows (random)
		//$Color 0
		Height 32;
		Radius 32;
		Scale 0.8;
		+CASTSPRITESHADOW
		+RANDOMIZE
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		COWS A 0 NODELAY A_SetScale(Scale.X + frandom(0.1,0.2),Scale.Y + frandom(0.1,0.2));
	Randomize:
		COWS A 0 A_Jump(128,"Cow2");
	Cow1:
		"####" BCDA 1 A_SetTics(random(4,10));
		"####" AA 1 A_SetTics(random(10,40));
		Loop;
	Cow2:
		"####" FGHE 1 A_SetTics(random(4,10));
		"####" EE 1 A_SetTics(random(10,40));
		Loop;
	}
}

class Camel : Cows
{
	Default
	{
		//$Title Desert Camel (Randomly Chewing)
		Scale 0.9;
	}
	States
	{
	Spawn:
		CAML A 0 NODELAY A_SetScale(Scale.X + frandom(0.1,0.2),Scale.Y + frandom(0.1,0.2));
	SpawnSet:
		"####" BA 1 A_SetTics(random(40,80));
		"####" CDEFDEF 1 A_SetTics(random(8,16));
		Loop;
	}
}

class BarkDog : SwitchableDecoration
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Barking Dog (Interactive)
		//$Color 0
		Radius 8;
		Height 24;
		Scale 0.9;
		+CASTSPRITESHADOW
		+DONTTHRUST
		+NONSHOOTABLE
		+NOTAUTOAIMED
		+RANDOMIZE
		+SOLID
		+USESPECIAL
		Activation THINGSPEC_Switch;
	}
	States
	{
	Active:
		BRDG E 0 A_StartSound("dog/attack", CHAN_ITEM, 0, frandom(0.7,1.0), ATTN_NORM);
	ActiveSet:
		"####" F 1 A_SetTics(random(4,8));
		"####" GE 1 A_SetTics(random(20,40));
		Goto SpawnSet;
	Spawn:
		BRDG A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
	SpawnSet:
		BRDG DCBA 1 A_SetTics(random(4,10));
		"####" AA 1 A_SetTics(random(10,40));
		Loop;
	Inactive:
		"####" A 0 A_StopSound(CHAN_ITEM);
		Goto SpawnSet;
	}
}

class BlackCat : BarkDog
{
	Default
	{
		//$Title Black Cat (Interactive)
		Height 16;
		Scale 0.87;
		+CANPASS
		+NOGRAVITY
	}
	States
	{
	Active:
		BCAT D 0 A_StopSound(CHAN_ITEM);
		"####" D 0 A_JumpIfInventory("HissCounter", 2, "Hiss");
		"####" D 0 A_StartSound("cat/meows", CHAN_AUTO, 0, frandom(0.7,1.0), ATTN_NORM);
	ActiveSet:
		"####" D 0 A_GiveInventory("HissCounter", 1);
		"####" D 1 A_SetTics(random(10,40));
		"####" D 0 A_StartSound("cat/meows", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" EF 1 A_SetTics(random(20,40));
		Goto Purr;
	Hiss:
		"####" D 1 A_SetTics(random(10,40));
		"####" EF 1 A_SetTics(random(4,8));
		"####" G 0 A_StartSound("cat/hiss", CHAN_AUTO, 0, frandom(0.7,1.0), ATTN_NORM);
		"####" G 1 A_SetTics(random(20,30));
		Goto Purr;
	Spawn:
		BCAT A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
	Purr:
		BCAT A 0 A_StartSound("cat/purr", CHAN_ITEM, CHANF_LOOPING, frandom(0.1,0.2), ATTN_STATIC);
	SpawnSet:
		BCAT A 0 A_CheckRange(512,"SpawnSilent");
		BCAT BCA 1 A_SetTics(random(4,10));
		"####" AA 1 A_SetTics(random(10,40));
		Loop;
	SpawnSilent:
		BCAT A 0 A_StopSound(CHAN_ITEM);
		"####" BCA 1 A_SetTics(random(4,10));
		"####" AA 1 A_SetTics(random(10,40));
		Goto Purr;
	Inactive:
		"####" A 0 A_StopSound(CHAN_ITEM);
		Goto Purr;
	}
}

class HissCounter : Inventory { Default {Inventory.MaxAmount 2; } }

class OcherCat: SceneryBase
{
	Default
	{
		Radius 4;
		Height 8;
		Scale 0.9;
		+CASTSPRITESHADOW
		+CANPASS
		+DONTTHRUST
		+NOGRAVITY
		+NONSHOOTABLE
		+NOTAUTOAIMED
		+RANDOMIZE
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		OCAT A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
	Randomize:
		OCAT A 0 A_Jump(128,"Cat2");
	Cat1:
		OCAT BCAD 1 A_SetTics(random(4,10));
		"####" AA 1 A_SetTics(random(10,40));
		Loop;
	Cat2:
		OCAT FGEH 1 A_SetTics(random(4,10));
		"####" EE 1 A_SetTics(random(10,40));
		Loop;
	}
}

class GrayCat : OcherCat
{
	States
	{
	Spawn:
		GCAT A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
	Randomize:
		GCAT A 0 A_Jump(128,"Cat2");
	Cat1:
		GCAT BCAD 1 A_SetTics(random(4,10));
		"####" AA 1 A_SetTics(random(10,40));
		Loop;
	Cat2:
		GCAT FGEH 1 A_SetTics(random(4,10));
		"####" EE 1 A_SetTics(random(10,40));
		Loop;
	}
}

class WhiteCat : OcherCat
{
	States
	{
	Spawn:
		WCAT A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
	Randomize:
		WCAT A 0 A_Jump(128,"Cat2");
	Cat1:
		WCAT BCAD 1 A_SetTics(random(4,10));
		"####" AA 1 A_SetTics(random(10,40));
		Loop;
	Cat2:
		WCAT FGEH 1 A_SetTics(random(4,10));
		"####" EE 1 A_SetTics(random(10,40));
		Loop;
	}
}

class CatSpawner : RandomSpawner
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Cat Spawner (Random Ocher, White & Gray Non-Interactive Cats)
		//$Color 0
		//$Sprite OCATA0
		Radius 4;
		Height 8;
		DropItem "OcherCat";
		DropItem "GrayCat";
		DropItem "WhiteCat";
	}
}

class DogsBodies: SceneryBase
{
	Default
	{
		//$Category Gore (BoA)
		//$Title Dead Dogs (random)
		//$Sprite ZARKA0
		Scale 0.65;
		+NOBLOCKMAP
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		ZARK A -1 A_SetScale(0.9);
		ZARK B -1 A_SetScale(0.9);
		ZARK C -1 A_SetScale(0.9);
		ZYDO A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		DOGY K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		DOG2 K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		DOG3 K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZYDO J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CatsBodies : DogsBodies //recolors not included yet - ozy81
{
	Default
	{
		//$Title Dead Cats (random)
		//$Sprite ZCATA0
		Scale 0.9;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		ZCAT A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCAT B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCAT C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CowsBodies : DogsBodies
{
	Default
	{
		//$Title Dead Cows (random)
		//$Sprite ZCOWA0
		Scale 0.9;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		ZCOW A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZCOW G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class PigsBodies : DogsBodies
{
	Default
	{
		//$Title Dead Pigs (random)
		//$Sprite ZPIGA0
		Scale 0.8;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9);
		ZPIG A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		ZPIG I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class DeadBear : DogsBodies
{
	Default {
		//$Title Dead Bear (random sides)
		Scale 0.75;
	}
	States
	{
	Spawn:
		ZBER A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}