/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, Talon1024,
 *                         AFADoomer
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

class SSUniformStatic: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Bureau
		//$Title SS Uniform
		//$Color 3
		Radius 8;
		Height 20;
		Scale 0.67;
		ProjectilePassHeight 4;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		SSUN A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class UniformStatic : SSUniformStatic
{
	Default
	{
	//$Title Uniform
	}
	States
	{
	Spawn:
		SSUN B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ScientistUniformStatic : SSUniformStatic
{
	Default
	{
	//$Title Scientist Uniform
	Height 40;
	Scale 0.7;
	}
	States
	{
	Spawn:
		HNG1 B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class FoxUniformStatic : SSUniformStatic
{
	Default
	{
	//$Title Desert Fox Uniform
	}
	States
	{
	Spawn:
		SSUN C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class HitlerUniformStatic : SSUniformStatic
{
	Default
	{
	//$Title Hitler's Downfall Uniform
	}
	States
	{
	Spawn:
		DWNF A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger : SSUniformStatic
{
	Default
	{
	//$Title Coat Hanger (empty)
	Height 40;
	Scale 0.8;
	}
	States
	{
	Spawn:
		CTHN A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger2 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (full, random)
	//$Sprite CTHNB0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		CTHN B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger3 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (coat, random)
	//$Sprite CTHNE0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		CTHN E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger4 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (hat, random)
	//$Sprite CTHNH0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6);
		CTHN H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CTHN M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger5 : RandomSpawner
{
	Default
	{
	//$Category Props (BoA)/Bureau
	//$Title Coat Hanger (random type)
	//$Color 3
	//$Sprite CTHND0
	Radius 8;
	Height 40;
	Scale 0.8;
	DropItem "CoatHanger";
	DropItem "CoatHanger2";
	DropItem "CoatHanger3";
	DropItem "CoatHanger4";
	}
}

class CoatHangerA1 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (full, A1)
	}
	States
	{
	Spawn:
		CTHN B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerB1 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (full, B1)
	}
	States
	{
	Spawn:
		CTHN C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerC1 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (full, C1)
	}
	States
	{
	Spawn:
		CTHN D -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerA2 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (coat only, A2)
	}
	States
	{
	Spawn:
		CTHN E -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerB2 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (coat only, B2)
	}
	States
	{
	Spawn:
		CTHN F -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerC2 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (coat only, C2)
	}
	States
	{
	Spawn:
		CTHN G -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerA3 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (hat only, A3)
	}
	States
	{
	Spawn:
		CTHN H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerB3 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (hat only, B3)
	}
	States
	{
	Spawn:
		CTHN I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerC3 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (hat only, C3)
	}
	States
	{
	Spawn:
		CTHN J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerD3 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (hat only, D3)
	}
	States
	{
	Spawn:
		CTHN K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerE3 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (hat only, E3)
	}
	States
	{
	Spawn:
		CTHN L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHangerF3 : CoatHanger
{
	Default
	{
	//$Title Coat Hanger (hat only, F3)
	}
	States
	{
	Spawn:
		CTHN M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger6 : CoatHanger
{
	Default
	{
	//$Title Medical Coat Hanger
	}
	States
	{
	Spawn:
		CTHN Z -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger7A : CoatHanger
{
	Default
	{
	//$Title Tall Coat Hanger, 1st Variant
	Scale 0.35;
	}
	States
	{
	Spawn:
		CTHN N -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger7B : CoatHanger
{
	Default
	{
	//$Title Tall Coat Hanger, 2nd Variant
	Scale 0.35;
	}
	States
	{
	Spawn:
		CTHN O -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger7C : CoatHanger
{
	Default
	{
	//$Title Tall Coat Hanger, 3rd Variant
	Scale 0.35;
	}
	States
	{
	Spawn:
		CTHN P -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CoatHanger7S : RandomSpawner
{
	Default
	{
	//$Category Props (BoA)/Bureau
	//$Title Tall Coat Hanger (random type)
	//$Color 3
	//$Sprite CTHNN0
	Radius 8;
	Height 40;
	Scale 0.35;
	DropItem "CoatHanger7A";
	DropItem "CoatHanger7B";
	DropItem "CoatHanger7C";
	}
}

class PaperBox1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Bureau
		//$Title Box (single)
		//$Color 3
		Radius 8;
		Height 16;
		Scale 0.5;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		BOX1 A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class PaperBox2 : PaperBox1
{
	Default
	{
	//$Title Box (pack)
	Scale 0.45;
	}
	States
	{
	Spawn:
		BOX1 B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Mike : PaperBox1
{
	Default
	{
	//$Title Microphone for Tables
	Radius 2;
	Height 8;
	Scale 0.3;
	-SOLID
	}
	States
	{
	Spawn:
		MIKE A -1;
		Stop;
	}
}

class CasinoDice : PaperBox1
{
	Default
	{
	//$Title Casino Gambling Dice (random)
	Radius 2;
	Height 2;
	Scale 0.1;
	-SOLID
	}
	States
	{
	Spawn:
		DADO A 0 NODELAY A_Jump(256,1,2);
		"####" A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		"####" B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class BinWhite: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Bureau
		//$Title Recycle Bin (white)
		//$Color 3
		Radius 16;
		Height 32;
		Health 5;
		Mass 100;
		Scale 0.5;
		-DROPOFF
		+NOBLOOD
		+NOTAUTOAIMED
		+PUSHABLE
		+SHOOTABLE
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		BINS A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAA 0 A_SpawnItemEx("Debris_Bin", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("MetalFrags");
		BINS B -1;
		Stop;
	}
}

class Plant1 : Tiltable
{
	Default
	{
	//$Category Props (BoA)/Bureau
	//$Title Plant 1 (breakable, small)
	//$Color 3
	Radius 8;
	Height 32;
	Health 10;
	Scale 0.5;
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	}
	States
	{
	Spawn:
		PLNT A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT C -1;
		Stop;
	}
}

class Plant2 : Plant1
{
	Default
	{
	//$Title Plant 2 (breakable, small)
	}
	States
	{
	Spawn:
		PLNT B -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT D -1;
		Stop;
	}
}

class Plant3 : Plant1
{
	Default
	{
	//$Title Plant 3 (breakable, small)
	Height 24;
	Scale 1.0;
	}
	States
	{
	Spawn:
		DJPT A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 AAA 0 A_SpawnItemEx("Debris_Bin", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("MetalFrags");
		Stop;
	}
}

class Plant4 : Plant3
{
	Default
	{
	//$Title Plant 4 (breakable, small)
	}
	States
	{
	Spawn:
		DJPT B -1;
		Stop;
	}
}

class Plant5 : Plant1
{
	Default
	{
	//$Title Plant 5 (breakable, detailed, tall)
	Scale 1.0;
	}
	States
	{
	Spawn:
		DJPT C -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		DJPT G -1;
		Stop;
	}
}

class Plant6 : Plant1
{
	Default
	{
	//$Title Plant 6 (breakable, detailed, short)
	Height 24;
	Scale 1.0;
	}
	States
	{
	Spawn:
		DJPT D -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		DJPT H -1;
		Stop;
	}
}

class Cup1 : Tiltable
{
	Default
	{
	//$Category Props (BoA)/Bureau
	//$Title Cup (coffee)
	//$Color 3
	Radius 2;
	Height 4;
	Health 1;
	Scale 0.25;
	+CANPASS
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	}
	States
	{
	Spawn:
		CUP1 A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_StartSound("GLASS5");
		TNT1 AAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Cup2 : Cup1
{
	Default
	{
	//$Title Cups (empty)
	Scale 0.3;
	}
	States
	{
	Spawn:
		CUP3 A -1;
		Stop;
	}
}

class DecoVase : Cup1
{
	Default
	{
	//$Title Decorative Vase (breakable)
	Scale 1.0;
	DeathSound "Pot/Break";
	}
	States
	{
	Spawn:
		DJPT E -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		TNT1 AAAA 0 A_SpawnItemEx("Debris_LeafY", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class NaziPlant1 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 1 (breakable, small)
	}
	States
	{
	Spawn:
		PLNT K -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT M -1;
		Stop;
	}
}

class NaziPlant2 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 2 (breakable, tall)
	}
	States
	{
	Spawn:
		PLNT L -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT M -1;
		Stop;
	}
}

class NaziPlant3 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 3 (breakable, small)
	}
	States
	{
	Spawn:
		PLNT N -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT P -1;
		Stop;
	}
}

class NaziPlant4 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 4 (breakable, tall)
	}
	States
	{
	Spawn:
		PLNT O -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT P -1;
		Stop;
	}
}

class NaziPlant5 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 5 (breakable, small)
	}
	States
	{
	Spawn:
		PLNT Q -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT S -1;
		Stop;
	}
}

class NaziPlant6 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 6 (breakable, tall)
	}
	States
	{
	Spawn:
		PLNT R -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT S -1;
		Stop;
	}
}

class NaziPlant7 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 7 (breakable, small)
	}
	States
	{
	Spawn:
		PLNT T -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT V -1;
		Stop;
	}
}

class NaziPlant8 : Plant1
{
	Default
	{
	//$Title Nazi Table Plant 8 (breakable, tall)
	}
	States
	{
	Spawn:
		PLNT U -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("BarrelFrags");
		PLNT V -1;
		Stop;
	}
}

class SnookerBallSpawner : Tiltable
{
	Default
	{
	//$Category Props (BoA)/Bureau
	//$Title Casino Snooker Ball (random, mostly red)
	//$Color 3
	Scale 0.1;
	Radius 4;
	Height 4;
	Mass 10;
	+CANPASS
	+NOBLOOD
	+NOTAUTOAIMED
	+PUSHABLE
	+SHOOTABLE
	+SLIDESONWALLS
	+SOLID
	}
	States
	{
	Spawn:
		SNKR A -1 NODELAY A_Jump(128,1);
		"####" B -1 A_Jump(128,1);
		"####" C -1 A_Jump(128,1);
		"####" D -1 A_Jump(32,1); //white one very rare
		"####" E -1;
		Stop;
	}
}

class SnookerBall1 : SnookerBallSpawner
{
	Default
	{
	//$Title Casino Snooker Ball, red
	}
	States
	{
	Spawn:
		SNKR A -1;
		Stop;
	}
}

class SnookerBall2 : SnookerBallSpawner
{
	Default
	{
	//$Title Casino Snooker Ball, yellow
	}
	States
	{
	Spawn:
		SNKR B -1;
		Stop;
	}
}

class SnookerBall3 : SnookerBallSpawner
{
	Default
	{
	//$Title Casino Snooker Ball, black
	}
	States
	{
	Spawn:
		SNKR C -1;
		Stop;
	}
}

class SnookerBall4 : SnookerBallSpawner
{
	Default
	{
	//$Title Casino Snooker Ball, blue
	}
	States
	{
	Spawn:
		SNKR D -1;
		Stop;
	}
}

class SnookerBall5 : SnookerBallSpawner
{
	Default
	{
	//$Title Casino Snooker Ball, white
	}
	States
	{
	Spawn:
		SNKR E -1;
		Stop;
	}
}

class CasinoChips_Green: Actor //the only issue there is that we'll see some chips falling even with the single one... np anyway - ozy81
{
	Default
	{
	//$Category Props (BoA)/Bureau
	//$Title Casino Chips (green, random)
	//$Color 3
	Radius 4;
	Height 8;
	Health 1;
	Scale 0.15;
	+CANPASS
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+TOUCHY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		CHP1 A -1 A_Jump(128,1);
		"####" B -1 A_Jump(128,1);
		"####" C -1 A_Jump(128,1);
		"####" D -1 A_Jump(128,1);
		"####" E -1;
		Stop;
	Death:
		TNT1 A 0 A_StartSound("CHIP6");
		"####" AAAAAA 0 A_SpawnItemEx("Debris_ChipsGreen", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_UnsetSolid;
		Stop;
	}
}

class CasinoChips_Blue : CasinoChips_Green
{
	Default
	{
	//$Title Casino Chips (red, random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		CHP2 A -1 A_Jump(128,1);
		"####" B -1 A_Jump(128,1);
		"####" C -1 A_Jump(128,1);
		"####" D -1 A_Jump(128,1);
		"####" E -1;
		Stop;
	Death:
		TNT1 A 0 A_StartSound("CHIP6");
		"####" AAAAAA 0 A_SpawnItemEx("Debris_ChipsBlue", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_UnsetSolid;
		Stop;
	}
}

class CasinoChips_Red : CasinoChips_Green
{
	Default
	{
	//$Title Casino Chips (blue, random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		CHP3 A -1 A_Jump(128,1);
		"####" B -1 A_Jump(128,1);
		"####" C -1 A_Jump(128,1);
		"####" D -1 A_Jump(128,1);
		"####" E -1;
		Stop;
	Death:
		TNT1 A 0 A_StartSound("CHIP6");
		"####" AAAAAA 0 A_SpawnItemEx("Debris_ChipsRed", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_UnsetSolid;
		Stop;
	}
}

class Dollar: Actor
{
	Default
	{
	Radius 2;
	Height 2;
	Damage 0;
	Scale 0.1;
	Projectile;
	-NOGRAVITY
	+ROLLSPRITE
	}
	States
	{
	Spawn:
		MNEY A 0 NODELAY A_SetGravity(frandom(0.0525,0.0725));
	SetSpawn:
		"####" A 0 A_Jump(256,1,2,3);
		"####" ABC 0 A_Jump(256,"SpawnLoop");
	SpawnLoop:
		"####" "#" 0 {A_SetTics(random(1,3)); A_SetRoll(roll+10.5, SPF_INTERPOLATE,0);}
		"####" "#" 0 {A_SetTics(random(1,3)); A_SetRoll(roll-10.5, SPF_INTERPOLATE,0);}
		Loop;
	Death:
		"####" A 0 A_Jump(256,1,2,3);
		"####" ABC 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bRollSprite = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class MoneyBags : Plant1
{
	Default
	{
	//$Title Paper Money Bags (breakable)
	Height 16;
	}
	States
	{
	Spawn:
		MOBG A 0 NODELAY A_SetScale(Scale.X + frandom(-0.1, 0.02));
	SetSpawn:
		"####" A 0 A_Jump(256,1,2,3,4);
		"####" ABCD 0 A_Jump(256,"CompleteSpawn");
	CompleteSpawn:
		"####" "#" -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAA 0 A_SpawnItemEx("Dollar", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("Dollar", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 AAAAAA 0 A_SpawnItemEx("Dollar", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 1 A_SpawnItemEx("BarrelFrags");
		Stop;
	}
}

class Toys_Hans : Cup1
{
	Default
	{
	//$Title Exhibit Toy, Hans Grosse (breakable)
	DeathSound "WOODBRK";
	Scale 0.25;
	}
	States
	{
	Spawn:
		TOYZ A -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		"####" AAAA 0 A_SpawnItemEx("Debris_ToyHans", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_Wood", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Toys_Waffen : Toys_Hans
{
	Default
	{
	//$Title Exhibit Toy, Waffen SS (breakable)
	}
	States
	{
	Spawn:
		TOYZ B -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		"####" AAAA 0 A_SpawnItemEx("Debris_ToyWaff", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_Wood", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Toys_SS : Toys_Hans
{
	Default
	{
	//$Title Exhibit Toy, SS Officer (breakable)
	Scale 0.55;
	}
	States
	{
	Spawn:
		TOYZ C -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		"####" A 0 A_SpawnItemEx("Debris_ToyRPG1", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AA 0 A_SpawnItemEx("Debris_Wood", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Toys_Afrika : Toys_Hans
{
	Default
	{
	//$Title Exhibit Toy, Afrika Korps Guard (breakable)
	Scale 0.55;
	}
	States
	{
	Spawn:
		TOYZ D -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		"####" A 0 A_SpawnItemEx("Debris_ToyRPG2", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AA 0 A_SpawnItemEx("Debris_Wood", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Toys_Hitler : Toys_Hans
{
	Default
	{
	//$Title Exhibit Toy, Hitler (breakable)
	Scale 0.55;
	}
	States
	{
	Spawn:
		TOYZ E -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		"####" A 0 A_SpawnItemEx("Debris_ToyRPG3", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AA 0 A_SpawnItemEx("Debris_Wood", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class CoffeeMachine : SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Bureau
		//$Title Coffee Machine (interactive, destroyable)
		//$Color 3
		Radius 4;
		Height 16;
		Health 5;
		Scale 0.5;
		+DONTSPLASH
		+DONTTHRUST
		+LOOKALLAROUND //this is needed otherwise we can drink only while in front of it - ozy81
		+NOBLOOD
		+NOBLOODDECALS
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		+USESPECIAL
		Activation THINGSPEC_Switch | THINGSPEC_ThingTargets;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Active:
		CUP2 A 0 A_JumpIfHealthLower(25, 1, AAPTR_TARGET);
		Goto SpawnSet;
		"####" A 0 A_GiveInventory("CoffeeCounter", 1);
		"####" A 0 A_GiveToTarget("Health", 1);
		"####" A 0 A_StartSound("misc/drink", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 A_JumpIfInventory("CoffeeCounter", 5, "Empty");
		Goto SpawnSet;
	Spawn:
		CUP2 A 0 NODELAY A_SpawnItemEx("InteractionIcon25Health", Scale.X*4, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnSet:
		"####" A -1;
		Stop;
	SpawnSet2:
		"####" C -1;
		Stop;
	Inactive:
		"####" A 0 A_StopSound(CHAN_AUTO);
		Goto SpawnSet;
	Empty:
		"####" A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" A 0 {bUseSpecial = FALSE;}
		Goto SpawnSet2;
	Death:
		TNT1 A 0 A_StartSound("GLSBRK01", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" A 0 {bUseSpecial = FALSE;}
		"####" A 0 A_UnSetSolid;
		"####" AAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Medium", random(0,4), random(0,4), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		CUP2 B -1;
		Stop;
	}
}

//3D ACTORS//
class WaterMachine : CoffeeMachine
{
	Default
	{
	//$Title Water Machine (interactive, destroyable)
	DistanceCheck "boa_scenelod";
	Renderstyle "Translucent";
	Alpha 0.5;
	Scale 1.0;
	}
	States
	{
	Active:
		MDLA A 0 A_JumpIfHealthLower(25, 1, AAPTR_TARGET);
		Goto SpawnSet;
		"####" A 0 A_GiveInventory("WaterCounter", 1);
		"####" A 0 A_GiveToTarget("Health", 1);
		"####" A 0 A_StartSound("misc/drink", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 A_JumpIfInventory("WaterCounter", 5, "Empty");
		Goto SpawnSet;
	Spawn:
		MDLA A 0 NODELAY {A_SpawnItemEx("InteractionIcon25Health", Scale.X*4, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
							A_SpawnItemEx("WaterMachineWater", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);}
	SpawnSet:
		"####" A -1;
		Stop;
	Inactive:
		"####" A 0 A_StopSound(CHAN_AUTO);
		Goto SpawnSet;
	Empty:
		"####" A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" A 0 {bUseSpecial = FALSE;}
		Goto SpawnSet;
	Death:
		TNT1 A 0 A_StartSound("GLSBRK01", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		"####" A 0 {bUseSpecial = FALSE;}
		"####" A 0 A_UnSetSolid;
		"####" AAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Medium", random(0,4), random(0,4), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		MDLA B -1 A_SpawnItemEx("WaterMachineBrokenWater", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
		Stop;
	}
}

class WaterMachineWater: SceneryBase
{
	Default
	{
		DistanceCheck "boa_scenelod";
		Renderstyle "Translucent";
		Alpha 0.2;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class WaterMachineBrokenWater : WaterMachineWater {}
class CoffeeCounter : Inventory { Default { Inventory.MaxAmount 5; } }
class WaterCounter : Inventory { Default { Inventory.MaxAmount 5; } }