/*
 * Copyright (c) 2018-2021 Ozymandias81, AFADoomer
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

class ShopStand1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Shops
		//$Title SS Shop Stand (Guard variant, random, non-solid)
		//$Color 3
		Radius 8;
		Height 8;
		Scale 0.67;
		-SOLID
		+CANPASS
		+NOGRAVITY
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		STND A 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND A -1;
		Stop;
	Set2:
		STND B -1;
		Stop;
	}
}

class ShopStand2 : ShopStand1
{
	Default
	{
	//$Title SS Shop Stand (Officer variant, random, non-solid)
	}
	States
	{
	Spawn:
		STND C 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND C -1;
		Stop;
	Set2:
		STND D -1;
		Stop;
	}
}

class ShopStand3 : ShopStand1
{
	Default
	{
	//$Title SS Shop Stand (Small Cap variant, non-solid)
	}
	States
	{
	Spawn:
		STND E -1;
		Stop;
	}
}

class ShopStand4 : ShopStand1
{
	Default
	{
	//$Title SS Hat Mannequin (No hat, non-solid)
	}
	States
	{
	Spawn:
		STND F -1;
		Stop;
	}
}

class ShopStand5 : ShopStand1
{
	Default
	{
	//$Title SS Hat Mannequin (Guard helm, non-solid)
	}
	States
	{
	Spawn:
		STND G 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND G -1;
		Stop;
	Set2:
		STND H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ShopStand6 : ShopStand1
{
	Default
	{
	//$Title SS Hat Mannequin (Officer hat, non-solid)
	}
	States
	{
	Spawn:
		STND I -1;
		Stop;
	}
}

class ShopStand7 : ShopStand1
{
	Default
	{
	//$Title SS Guard Hat (random sides)
	}
	States
	{
	Spawn:
		STND J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ShopStand8 : ShopStand1
{
	Default
	{
	//$Title SS Officer Hat (non-solid)
	}
	States
	{
	Spawn:
		STND K -1;
		Stop;
	}
}

class ShopStand9 : ShopStand1
{
	Default
	{
	//$Title SS Random Hat (random, non-solid)
	}
	States
	{
	Spawn:
		STND J 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set2:
		STND K -1;
		Stop;
	}
}

class ShopStand10 : ShopStand1
{
	Default
	{
	//$Title SS Boots (random, non-solid)
	}
	States
	{
	Spawn:
		STND L 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND L -1;
		Stop;
	Set2:
		STND M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class ShopCleaver : ShopStand1
{
	Default
	{
	//$Title Cleaver (non-solid)
	Scale 0.5;
	}
	States
	{
	Spawn:
		BUTC Z -1;
		Stop;
	}
}

class ShopStand1D: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Shops/Destroyable
		//$Title SS Shop Stand (Guard variant, random, destroyable)
		//$Color 3
		Radius 8;
		Height 64;
		Health 5;
		Mass 100;
		Scale 0.67;
		-DROPOFF
		-NOGRAVITY
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
		STND A 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND A -1;
		Stop;
	Set2:
		STND B -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.2,0.5), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Wood", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#####" 0 A_SpawnItemEx("Debris_FlagsR", random(0,16), random(0,16), random(24,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#####" 0 A_SpawnItemEx("Debris_FlagsD", random(0,16), random(0,16), random(24,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_Jump(256,"Death.Helm");
	Death.Helm:
		"####" "#" 0 A_SpawnItemEx("Debris_SSHelm", random(0,16), random(0,16), random(56,64), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_SpawnItemEx("BarrelFrags");
		STND N -1;
		Stop;
	}
}

class ShopStand2D : ShopStand1D
{
	Default
	{
	//$Title SS Shop Stand (Officer variant, random, destroyable)
	}
	States
	{
	Spawn:
		STND C 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND C -1;
		Stop;
	Set2:
		STND D -1;
		Stop;
	Death.Helm:
		"####" "#" 0 A_SpawnItemEx("Debris_SSHelm2", random(0,16), random(0,16), random(56,64), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_SpawnItemEx("BarrelFrags");
		STND N -1;
		Stop;
	}
}

class ShopStand3D : ShopStand1D
{
	Default
	{
	//$Title SS Shop Stand (Small Cap variant, destroyable)
	}
	States
	{
	Spawn:
		STND E -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.2,0.5), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Wood", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#####" 0 A_SpawnItemEx("Debris_FlagsR", random(0,16), random(0,16), random(24,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#####" 0 A_SpawnItemEx("Debris_FlagsD", random(0,16), random(0,16), random(24,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_SpawnItemEx("BarrelFrags");
		STND N -1;
		Stop;
	}
}

class ShopStand4D : ShopStand1D
{
	Default
	{
	//$Title SS Hat Mannequin (Guard helm, destroyable)
	}
	States
	{
	Spawn:
		STND G 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		STND G -1;
		Stop;
	Set2:
		STND H -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.1,0.3), ATTN_NORM);
		"####" "#" 0 A_SpawnItemEx("Debris_SSHelm", random(0,16), random(0,16), random(4,16), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_SpawnItemEx("BarrelFrags");
		STND O -1;
		Stop;
	}
}

class ShopStand5D : ShopStand1D
{
	Default
	{
	//$Title SS Hat Mannequin (Officer helm, destroyable)
	}
	States
	{
	Spawn:
		STND I -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.1,0.3), ATTN_NORM);
		"####" "####" 0 A_SpawnItemEx("Debris_Wood", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_SpawnItemEx("Debris_SSHelm2", random(0,16), random(0,16), random(4,16), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_SpawnItemEx("BarrelFrags");
		STND O -1;
		Stop;
	}
}

class ShopStand6D : ShopStand1D
{
	Default
	{
	//$Title SS Hat Mannequin (no hat, destroyable)
	}
	States
	{
	Spawn:
		STND F -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.1,0.3), ATTN_NORM);
		"####" "####" 0 A_SpawnItemEx("Debris_Wood", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" "#" 0 A_SpawnItemEx("BarrelFrags");
		STND O -1;
		Stop;
	}
}

class Butchery1 : ShopStand1
{
	Default
	{
	//$Category Props (BoA)/Shops
	//$Title Pork Butt (random, non-solid)
	Scale 0.25;
	}
	States
	{
	Spawn:
		BUTC A 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		BUTC A -1;
		Stop;
	Set2:
		BUTC B -1;
		Stop;
	}
}

class Butchery1_R : Butchery1
{
	Default
	{
	//$Title Russian Pork Butt (easteregg, non-solid)
	}
	States
	{
	Spawn:
		BUTC Y -1;
		Stop;
	}
}

class ButcheryNazi : Butchery1
{
	Default
	{
	//$Title Nazi Pork Butt (easteregg, non-solid)
	}
	States
	{
	Spawn:
		NAZB A -1;
		Stop;
	}
}

class Butchery2 : Butchery1
{
	Default
	{
	//$Title Sausage (hanging, random sides, non-solid)
	Scale 0.11;
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC D -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Butchery3 : Butchery1
{
	Default
	{
	//$Title Sausage (laying, random sides, non-solid)
	Scale 0.11;
	}
	States
	{
	Spawn:
		BUTC F -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Butchery4 : Butchery1
{
	Default
	{
	//$Title Pack of Sausages (hanging, random sides, non-solid)
	Scale 0.11;
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC H -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Butchery5 : Butchery1
{
	Default
	{
	//$Title Pig (hanging, random, non-solid)
	Scale 0.13;
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC I 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		BUTC I -1;
		Stop;
	Set2:
		BUTC J -1;
		Stop;
	}
}

class Butchery6 : Butchery1
{
	Default
	{
	//$Title Hanging Piece of Meat (non-solid)
	Scale 0.67;
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC M -1;
		Stop;
	}
}

class Butchery7 : Butchery1
{
	Default
	{
	//$Title Hanging Chicken (random, non-solid)
	Scale 0.08;
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC N 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		BUTC N -1;
		Stop;
	Set2:
		BUTC O -1;
		Stop;
	}
}

class Butchery8 : Butchery1
{
	Default
	{
	//$Title Hanging Rat (random sides, non-solid)
	Scale 0.08;
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC P -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Butchery9 : Butchery1
{
	Default
	{
	//$Title Pig Lamb (random sides, non-solid)
	Scale 0.13;
	}
	States
	{
	Spawn:
		BUTC L -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Butchery1D: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Shops/Destroyable
		//$Title Pork Butt (random)
		//$Color 3
		Radius 4;
		Height 8;
		Health 5;
		Mass 100;
		Scale 0.25;
		-DROPOFF
		+CANPASS
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
		BUTC A 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		BUTC A -1;
		Stop;
	Set2:
		BUTC B -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Flesh", random(0,16), random(0,16), random(4,16), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
		BUTC C -1;
		Stop;
	}
}

class Butchery1D_R : Butchery1D
{
	Default
	{
	//$Title Russian Pork Butt (easteregg, destroyable)
	}
	States
	{
	Spawn:
		BUTC Y -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Flesh", random(0,16), random(0,16), random(4,16), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
		BUTC C -1;
		Stop;
	}
}

class ButcheryNaziD : Butchery1D
{
	Default
	{
	//$Title Nazi Pork Butt (easteregg, destroyable)
	}
	States
	{
	Spawn:
		NAZB A -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Flesh", random(0,16), random(0,16), random(4,16), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
		BUTC C -1;
		Stop;
	}
}

class Butchery2D : Butchery1D
{
	Default
	{
	//$Title Sausage (hanging, destroyable)
	Radius 2;
	Height 16;
	Health 5;
	Mass 100;
	Scale 0.11;
	-PUSHABLE
	+DONTFALL
	+DONTTHRUST
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC D -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "####" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(4,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		BUTC E -1;
		Stop;
	}
}

class Butchery3D : Butchery1D
{
	Default
	{
	//$Title Sausage (laying, destroyable)
	Radius 2;
	Height 8;
	Scale 0.11;
	}
	States
	{
	Spawn:
		BUTC F -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "####" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(4,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		BUTC G -1;
		Stop;
	}
}

class Butchery4D : Butchery1D
{
	Default
	{
	//$Title Pack of Sausages (hanging, destroyable)
	Radius 2;
	Height 64;
	Scale 0.11;
	-PUSHABLE
	+DONTFALL
	+DONTTHRUST
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC H -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "##########" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(16,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		BUTC X -1;
		Stop;
	}
}

class Butchery5D : Butchery1D
{
	Default
	{
	//$Title Pig (hanging, destroyable)
	Radius 16;
	Height 24;
	Scale 0.13;
	-PUSHABLE
	+DONTFALL
	+DONTTHRUST
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC I 0 NODELAY A_Jump(256,"Set1","Set2");
	Set1:
		BUTC I -1;
		Stop;
	Set2:
		BUTC J -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Flesh", random(0,16), random(0,16), random(8,32), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 A 2 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
		BUTC K -1;
		Stop;
	}
}

class Butchery6D : Butchery1D
{
	Default
	{
	//$Title Hanging Piece of Meat (destroyable)
	Radius 2;
	Height 72;
	Scale 0.67;
	-PUSHABLE
	+DONTFALL
	+DONTTHRUST
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC M -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "##########" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(16,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		BUTC Q -1;
		Stop;
	}
}

class Butchery7D_A : Butchery1D
{
	Default
	{
	//$Title Hanging Chicken (1st type, destroyable)
	Radius 4;
	Height 16;
	Scale 0.08;
	-PUSHABLE
	+DONTFALL
	+DONTTHRUST
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC N -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "##########" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(4,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		BUTC R -1 A_Feathers(); //inheritance with Heretic sprites here - Ozy81
		Stop;
	}
}

class Butchery7D_B : Butchery1D
{
	Default
	{
	//$Title Hanging Chicken (2nd type, destroyable)
	Radius 4;
	Height 16;
	Scale 0.08;
	-PUSHABLE
	+DONTFALL
	+DONTTHRUST
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC O -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "##########" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(4,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		BUTC S -1 A_Feathers(); //inheritance with Heretic sprites here - Ozy81
		Stop;
	}
}

class Butchery8D : Butchery1D
{
	Default
	{
	//$Title Hanging Rat (destroyable)
	Radius 4;
	Height 12;
	Scale 0.08;
	-PUSHABLE
	+DONTFALL
	+DONTTHRUST
	+NOGRAVITY
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		BUTC P -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "##########" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(4,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		BUTC T -1;
		Stop;
	}
}

class Butchery9D : Butchery1D
{
	Default
	{
	//$Title Pork Lamb (laying, destroyable)
	Radius 2;
	Height 8;
	Scale 0.13;
	}
	States
	{
	Spawn:
		BUTC L -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("flesh/ribs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "######" 0 A_SpawnItemEx("Debris_Flesh2", random(0,16), random(0,16), random(4,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Bakery1 : Butchery1
{
	Default
	{
	//$Title Bread (laying, random, non-solid)
	Scale 0.35;
	}
	States
	{
	Spawn:
		BAGU A 0 NODELAY A_Jump(256,"Set1","Set2","Set3");
	Set1:
		BAGU A -1;
		Stop;
	Set2:
		BAGU B -1;
		Stop;
	Set3:
		BAGU C -1;
		Stop;
	}
}

class Bakery1D: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Shops/Destroyable
		//$Title Bread (laying, random, destroyable)
		//$Color 3
		Radius 4;
		Height 8;
		Health 5;
		Mass 100;
		Scale 0.35;
		-DROPOFF
		+CANPASS
		+NOBLOOD
		+NOTAUTOAIMED
		+PUSHABLE
		+SHOOTABLE
		+SOLID
		+TOUCHY
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		BAGU A 0 NODELAY A_Jump(256,"Set1","Set2","Set3");
	Set1:
		BAGU A -1;
		Stop;
	Set2:
		BAGU B -1;
		Stop;
	Set3:
		BAGU C -1;
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("bread/crumbs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Bread", random(0,16), random(0,16), random(4,16), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}