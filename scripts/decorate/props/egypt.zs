/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer
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

class EVase: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Egypt
		//$Title Vase (breakable)
		//$Color 3
		Radius 24; //in order to make the smokemonster never goin' stuck'd on map c1m6
		Height 64;
		Health 1;
		Scale 0.85;
		+NOBLOOD
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		DeathSound "Pot/Break";
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		VASE A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE); //make sure to always adjust XYZ position depending on the size of the object and the amount of AAA
		VASE B 2 A_SpawnItemEx("BarrelFrags");
		"####" B 6 A_Scream;
		"####" B -1;
		Stop;
	}
}

class EColumn: SceneryBase //3d Actor
{
	Default
	{
		//$Category Props (BoA)/Egypt
		//$Title Ornated Column
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 128;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class EStatue1 : EColumn //3d Actor
{
	Default
	{
	//$Title Pharaoh Statue
	DistanceCheck "boa_scenelod";
	Radius 16;
	}
}

class AZChalice1 : EColumn
{
	Default
	{
	//$Title Aztec Chalice, Stone
	Height 88;
	}
}

class AZChalice2 : EColumn
{
	Default
	{
	//$Title Aztec Chalice, Gold
	Height 88;
	}
}

class AZIdol1 : EColumn
{
	Default
	{
	//$Title Aztec Idol, Stone
	}
}

class AZIdol2 : EColumn
{
	Default
	{
	//$Title Aztec Idol, Gold
	}
}

class EStatue1NH : MuseumBase
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Pharaoh Statue, No Hitbox
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class AZChalice1NH : MuseumBase
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Aztec Chalice, Stone, No Hitbox
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class AZChalice2NH : MuseumBase
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Aztec Chalice, Gold, No Hitbox
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class AZIdol1NH : MuseumBase
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Aztec Idol, Stone, No Hitbox
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class AZIdol2NH : MuseumBase
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Aztec Idol, Gold, No Hitbox
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class AZMask : MuseumBase
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Aztec Ceremonial Mask
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class AZStatue : MuseumBase
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Aztec Scorpion Statue
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class EStatue2: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Egypt
		//$Title Large Statue (1st variant)
		//$Color 3
		Radius 16;
		Height 128;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		ESTA A -1;
		Stop;
	}
}

class EStatue3 : EStatue2
{
	Default
	{
	//$Title Large Statue (2nd variant)
	}
	States
	{
	Spawn:
		ESTA B -1;
		Stop;
	}
}

class LavaCauldron: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Egypt
		//$Title Lava Cauldron
		//$Color 3
		Radius 24;
		Height 32;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		LAVC A 0 NODELAY A_SpawnItemEx("LavaCauldronFire", 0, 0, Height, 0, 0, 0, 0, SXF_NOCHECKPOSITION, 0, tid);
		Goto Frame1;
	Frame1:
		LAVC A 0 A_CheckRange(512,"Frame4"); //tweak for sound channels - ozy81
		"####" A random(4, 6) A_StartSound("LavaCauldron/Loop", CHAN_5, CHANF_LOOPING, 1.0, ATTN_STATIC);
		"####" A 0 A_Jump(64, "Frame3");
		Goto Frame2;
	Frame2:
		LAVC B random(4, 6);
		"####" A 0 A_Jump(64, "Frame1");
		Goto Frame3;
	Frame3:
		LAVC C random(4, 6);
		"####" A 0 A_Jump(64, "Frame2");
		Goto Frame1;
	Frame4:
		LAVC A 0 A_StopSound(CHAN_5);
		LAVC A random(4, 6);
		"####" A 0 A_Jump(64, "Frame3");
		Goto Frame1;
	}
}

class LavaCauldronFire: SceneryBase
{
	Default
	{
		Radius 24;
		Height 30;
		DamageType "Fire";
		+NOGRAVITY
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 {
			if (!CheckRange(boa_sfxlod, true))
			{
				A_SpawnItemEx("FloatingCinder", 0, 0, random(0,2), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE);
			}
		}
		"####" A 16 A_Explode(8, (int) (Radius), 0, FALSE, (int) (Radius));
		Loop;
	}
}

class BreakableVase1 : DestructionSpawner
{
	Default
	{
	//$Category Props (BoA)/Egypt
	//$Title Vase 1 (breakable)
	//$Color 3
	Radius 10;
	Height 40;
	Health 5;
	Scale 0.5;
	+DONTGIB
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	DeathSound "Pot/Break";
	}
	States
	{
	Spawn:
		EGIP A -1;
		Stop;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGIK A 3 A_Scream;
		"####" B -1;
		Stop;
	}
}

class BreakableVase2 : BreakableVase1
{
	Default
	{
	//$Title Vase 2 (breakable)
	Height 32;
	}
	States
	{
	Spawn:
		EGIP B -1;
		Stop;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGIK C 3 A_Scream;
		"####" D -1;
		Stop;
	}
}

class BreakableVase3 : BreakableVase1
{
	Default
	{
	//$Title Vase 3 (breakable)
	Height 24;
	}
	States
	{
	Spawn:
		EGIP C -1;
		Stop;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGIK E 6 A_Scream;
		"####" F -1;
		Stop;
	}
}

class BreakableVase4 : BreakableVase1
{
	Default
	{
	//$Title Vase 4 (breakable)
	Radius 8;
	Height 16;
	}
	States
	{
	Spawn:
		EGIP D -1;
		Stop;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGIK G 3 A_Scream;
		"####" H -1;
		Stop;
	}
}

class BreakableVase5 : BreakableVase1
{
	Default
	{
	//$Title Vase 5 (breakable)
	Height 24;
	}
	States
	{
	Spawn:
		EGIP E -1;
		Stop;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGIK I 3 A_Scream;
		"####" J -1;
		Stop;
	}
}

class BreakableVase6 : BreakableVase1
{
	Default
	{
	//$Title Vase 6 (breakable)
	Height 32;
	}
	States
	{
	Spawn:
		EGIP F -1;
		Stop;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGIK K 3 A_Scream;
		"####" L -1;
		Stop;
	}
}

class EgyptPlant1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Egypt
		//$Title Vase with Plant (breakable)
		//$Color 3
		Radius 8;
		Height 32;
		Health 5;
		Scale 0.5;
		+DONTGIB
		+NOBLOOD
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		DeathSound "Pot/Break";
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		EGPL A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Leaf", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		TNT1 AAAAA 0 A_SpawnItemEx("Debris_Pottery", random(0,16), random(0,16), random(0,56), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGIK C 3 A_Scream;
		"####" D -1;
		Stop;
	}
}

class AztecVase1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Egypt
		//$Title Aztec Vase 1 (ceiling)
		//$Color 3
		Radius 8;
		Height 80;
		Scale 0.85;
		+NOGRAVITY
		+SOLID
		+SPAWNCEILING
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		DJAZ A -1;
		Stop;
	}
}

class AztecVase2 : AztecVase1
{
	Default
	{
	//$Title Aztec Vase 2 (ceiling)
	}
	States
	{
	Spawn:
		DJAZ B -1;
		Stop;
	}
}