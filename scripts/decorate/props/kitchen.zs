/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, AFADoomer
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

class PotKitchen1 : Tiltable
{
	Default
	{
	//$Category Props (BoA)/Kitchen
	//$Title Sauce Pan (rusty, open)
	//$Color 3
	Radius 16;
	Height 32;
	Health 1;
	Scale 0.5;
	+CANPASS
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	}
	States
	{
	Spawn:
		TOPF A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_UnsetSolid();
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("MetalFrags");
		TOPF B -1;
		Stop;
	}
}

class PotKitchen2 : PotKitchen1
{
	Default
	{
	//$Title Frying Pan (cooking)
	Height 16;
	}
	States
	{
	Spawn:
		FCAN A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
	Cook:
		FCAN ABC 5;
		Loop;
	Death:
		TNT1 A 0 A_UnsetSolid();
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("MetalFrags");
		FCAN D -1;
		Stop;
	}
}

class PotKitchen3 : PotKitchen1
{
	Default
	{
	//$Title Frying Pan (empty)
	Height 8;
	}
	States
	{
	Spawn:
		ECAN A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_UnsetSolid();
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("MetalFrags");
		ECAN B -1;
		Stop;
	}
}

class PotKitchen4 : PotKitchen1
{
	Default
	{
	//$Title Sauce Pan (rusty, closed)
	}
	States
	{
	Spawn:
		TOPF C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_UnsetSolid();
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("MetalFrags");
		TOPF D -1;
		Stop;
	}
}

class Kettle : PotKitchen1
{
	Default
	{
	//$Title Kettle
	Radius 8;
	Height 16;
	}
	States
	{
	Spawn:
		KETL A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_UnsetSolid();
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" A 2 A_SpawnItemEx("MetalFrags");
		KETL B -1;
		Stop;
	}
}

class Teapot1 : PotKitchen1
{
	Default
	{
	//$Title Teapot, China
	Radius 4;
	Height 8;
	Scale 0.15;
	DeathSound "Pot/Break";
	}
	States
	{
	Spawn:
		TEAZ A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 { A_UnSetSolid(); A_Scream(); }
		"####" AAAAA 0 A_SpawnItemEx("Debris_Porcelain", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Teapot2 : Teapot1
{
	Default
	{
	//$Title Teapot, Nazi
	Scale 0.20;
	}
	States
	{
	Spawn:
		TEAZ B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 { A_UnsetSolid(); A_Scream(); }
		"####" AAAAA 0 A_SpawnItemEx("Debris_Porcelain", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class TeaCup1 : Teapot1
{
	Default
	{
	//$Title Tea Cup, China
	Radius 2;
	Height 2;
	Scale 0.10;
	}
	States
	{
	Spawn:
		TEAZ C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 { A_UnsetSolid(); A_Scream(); }
		"####" AAA 0 A_SpawnItemEx("Debris_Porcelain", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class TeaCup2 : Teapot1
{
	Default
	{
	//$Title Tea Cup, British
	Radius 2;
	Height 2;
	Scale 0.10;
	}
	States
	{
	Spawn:
		TEAZ D -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 { A_UnsetSolid(); A_Scream(); }
		"####" AAA 0 A_SpawnItemEx("Debris_Porcelain", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class TeaCup3 : Teapot1
{
	Default
	{
	//$Title Tea Cup, Classic
	Radius 2;
	Height 2;
	Scale 0.10;
	}
	States
	{
	Spawn:
		TEAZ E -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 { A_UnsetSolid(); A_Scream(); }
		"####" AAA 0 A_SpawnItemEx("Debris_Porcelain", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class TeaCup4 : Teapot1
{
	Default
	{
	//$Title Tea Cup, Nazi
	Radius 2;
	Height 2;
	Scale 0.10;
	}
	States
	{
	Spawn:
		TEAZ F -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 { A_UnsetSolid(); A_Scream(); }
		"####" AAA 0 A_SpawnItemEx("Debris_Porcelain", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Plates1 : Teapot1
{
	Default
	{
	//$Title Pile of Plates 1 (breakable)
	Scale 0.5;
	}
	States
	{
	Spawn:
		PLAT A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 1 { A_UnsetSolid(); A_Scream(); }
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_Porcelain", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Plates2 : Plates1
{
	Default
	{
	//$Title Pile of Plates 2 (breakable)
	}
	States
	{
	Spawn:
		PLAT B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Plates3 : Teapot1
{
	Default
	{
	//$Title Pile of Plates 3 (breakable)
	Scale 0.5;
	}
	States
	{
	Spawn:
		PLAT C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class WineBottle : PotKitchen1
{
	Default
	{
	//$Title Bottle (liquor, random)
	Radius 4;
	Height 8;
	Scale 0.12;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		FLAS A -1;
		FLAS B -1;
		FLAS C -1;
		FLAS D -1;
		FLAS E -1;
		FLAS F -1;
		FLAS G -1;
		Stop;
	Death:
		TNT1 A 0 A_StartSound("GLASS5");
		"####" AAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_UnsetSolid;
		Stop;
	}
}

class WineGlass : WineBottle
{
	Default
	{
	//$Title Glass (glass, random)
	Radius 2;
	Scale 0.05;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		FLAS Y -1;
		FLAS Z -1;
		Stop;
	}
}

class Pickles1 : Tiltable
{
	Default
	{
	//$Category Props (BoA)/Kitchen
	//$Title Pickles, Peppers (random, shootable)
	//$Color 3
	Radius 8;
	Height 8;
	Scale 0.6;
	Health 1;
	+CANPASS
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		PKLS A -1;
		PKLS B -1;
		Stop;
	Death:
		TNT1 A 0 A_StartSound("GLASS5");
		"####" AA 0 A_SpawnItemEx("Debris_GlassShard_Large", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_GlassShard_Medium", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_UnsetSolid;
		Stop;
	}
}

class Pickles2 : Pickles1
{
	Default
	{
	//$Title Pickles, Tomatoes (random, shootable)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		PKLS C -1;
		PKLS D -1;
		Stop;
	}
}

class Pickles3 : Pickles1
{
	Default
	{
	//$Title Pickles, Gherkins (random sides, shootable)
	}
	States
	{
	Spawn:
		PKLS E -1;
		Stop;
	}
}

class Pickles4 : Pickles1
{
	Default
	{
	//$Title Pickles, Watermelon (random sides, shootable)
	}
	States
	{
	Spawn:
		PKLS F -1;
		Stop;
	}
}

class PicklesSpawner : RandomSpawner
{
	Default
	{
	//$Category Props (BoA)/Kitchen
	//$Title Pickles Spawner (random, shootable)
	//$Color 3
	//$Sprite PKLSA0
	Radius 8;
	Height 8;
	Scale 0.6;
	DropItem "Pickles1";
	DropItem "Pickles2";
	DropItem "Pickles3";
	DropItem "Pickles4";
	}
}

class OvenHot : SwitchableDecoration
{
	Default
	{
	//$Category Props (BoA)/Kitchen
	//$Title Oven (Interactive)
	//$Color 3
	Radius 16;
	Height 64;
	+DONTTHRUST
	+NOBLOOD
	+NOBLOODDECALS
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	+USESPECIAL
	Activation THINGSPEC_Switch;
	}
	States
	{
	Spawn:
		MDLA A 0;
		Goto CheckDormant;
	CheckDormant:
		"####" "#" 0  {
			if (bDormant) {
				return ResolveState("Off");
			}
			return ResolveState("On");
		}
	On:
		"####" A 0 A_SpawnItemEx("Flame_Oven3d", Scale.X*12, 0, 12, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		"####" A -1 A_StartSound("SFX/FireLoop1", CHAN_BODY, CHANF_LOOPING, 0.7, ATTN_STATIC);
		Stop;
	Off:
		"####" B -1;
		Stop;
	Active:
	Inactive:
		MDLA B 0 {
			A_StopSound(CHAN_BODY);
			A_RemoveChildren(TRUE, RMVF_MISC);
			bDormant = !bDormant;
			return ResolveState("CheckDormant");}
	}
}