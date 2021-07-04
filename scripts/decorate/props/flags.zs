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

class NazibannerM : SwitchableDecoration //3d actor
{
	Default
	{
	//$Category Props (BoA)/Flags
	//$Title Nazibanner (middle, set Dormant for non-solid/invulnerable)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 16;
	Height 96;
	Health 30;
	Mass 100000;
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsW", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsW", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsD", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		MDLA B -1;
		Stop;
	Inactive:
		MDLA A 0 A_UnsetSolid;
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class NazibannerM2 : NaziBannerM //3d actor
{
	Default
	{
	//$Title Nazibanner 2 (middle, set Dormant for non-solid/invulnerable)
	}
}

class Reichbanner : NaziBannerM //3d actor
{
	Default
	{
	//$Title Third Reich Banner (set Dormant for non-solid/invulnerable)
	}
	States
	{
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsW", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsW", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsD", random(0,32), random(0,16), random(24,80), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		MDLA BCDEFGHIJKLM 2;
		MDLA P -1;
		Stop;
	}
}

//2d actors
class NaziFlagS : SwitchableDecoration
{
	Default
	{
	//$Category Props (BoA)/Flags
	//$Title Naziflag (short, set Dormant for non-solid/invulnerable)
	//$Color 3
	Radius 8;
	Height 64;
	Health 20;
	Mass 100000;
	Scale 0.5;
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	}
	States
	{
	Spawn:
		FLAG A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		FLAG D -1;
		Stop;
	Inactive:
		FLAG A 0 A_UnsetSolid;
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class NaziFlagT : NaziFlagS
{
	Default
	{
	//$Title Naziflag (tall, set Dormant for non-solid/invulnerable)
	Height 80;
	Scale 0.70;
	}
	States
	{
	Spawn:
		FLAG B -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		FLAG C -1;
		Stop;
	Inactive:
		FLAG B 0 A_UnsetSolid;
		"####" B -1 A_SetInvulnerable;
		Stop;
	}
}

class UKFlagT : NaziFlagT
{
	Default
	{
	//$Title UK Flag (tall, set Dormant for non-solid/invulnerable)
	}
	States
	{
	Spawn:
		FLAG F -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAA 0 A_SpawnItemEx("Debris_FlagsB2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		FLAG C -1;
		Stop;
	Inactive:
		FLAG F 0 A_UnsetSolid;
		"####" F -1 A_SetInvulnerable;
		Stop;
	}
}

class USFlagT : NaziFlagT
{
	Default
	{
	//$Title US Flag (tall, set Dormant for non-solid/invulnerable)
	}
	States
	{
	Spawn:
		FLAG G -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsR2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsB2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,48), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		FLAG C -1;
		Stop;
	Inactive:
		FLAG G 0 A_UnsetSolid;
		"####" G -1 A_SetInvulnerable;
		Stop;
	}
}

class SSBanner : NaziFlagS
{
	Default
	{
	//$Category Props (BoA)/Flags
	//$Title SS Banner (middle, set Dormant for non-solid/invulnerable)
	//$Color 3
	Radius 16;
	}
	States
	{
	Spawn:
		SSFG A -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsD2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsD2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsW", random(0,32), random(0,16), random(16,48), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		FLAG D -1;
		Stop;
	Inactive:
		SSFG A 0 A_UnsetSolid;
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class SSBanner2 : SSBanner
{
	Default
	{
	//$Title SS Banner, swastika (middle, set Dormant for non-solid/invulnerable)
	Radius 16;
	}
	States
	{
	Spawn:
		SSFG B -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsD2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsD2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsW", random(0,32), random(0,16), random(16,48), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" A 2 A_SpawnItemEx("BarrelFrags");
		FLAG D -1;
		Stop;
	Inactive:
		SSFG B 0 A_UnsetSolid;
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class FlagWithFaces1 : NaziFlagS
{
	Default
	{
	//$Category Props (BoA)/Flags
	//$Title Flag with Faces (small, set Dormant for non-solid/invulnerable)
	//$Color 3
	Radius 16;
	Height 48;
	Health 10;
	Scale 1.0;
	}
	States
	{
	Spawn:
		DJFG B -1;
		Stop;
	Death:
		TNT1 A 0 A_UnSetSolid;
		"####" A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_FlagsW2", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		"####" AAAAA 0 A_SpawnItemEx("Debris_FlagsW", random(0,32), random(0,16), random(2,8), random(1,2), 1, 1, random(0,360), SXF_CLIENTSIDE);
		DJFG D -1;
		Stop;
	Inactive:
		DJFG B 0 A_UnsetSolid;
		"####" B -1 A_SetInvulnerable;
		Stop;
	}
}

class FlagWithFaces2 : FlagWithFaces1
{
	Default
	{
	//$Title Flag with Faces (large, set Dormant for non-solid/invulnerable)
	}
	States
	{
	Spawn:
		DJFG A -1;
		Stop;
	Inactive:
		DJFG A 0 A_UnsetSolid;
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class FlagWithFaces3 : FlagWithFaces1
{
	Default
	{
	//$Title Flag with Faces (medium, set Dormant for non-solid/invulnerable)
	}
	States
	{
	Spawn:
		DJFG C -1;
		Stop;
	Inactive:
		DJFG C 0 A_UnsetSolid;
		"####" C -1 A_SetInvulnerable;
		Stop;
	}
}

class Toys_UKFlag : Toys_Hans
{
	Default
	{
	//$Category Props (BoA)/Flags
	//$Title Exhibit Toy, UK Flag (breakable)
	}
	States
	{
	Spawn:
		FLAG F -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		"####" AAAA 0 A_SpawnItemEx("Debris_Wood", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		FLAG C -1;
		Stop;
	}
}

class Toys_USFlag : Toys_UKFlag
{
	Default
	{
	//$Title Exhibit Toy, US Flag (breakable)
	}
	States
	{
	Spawn:
		FLAG G -1;
		Stop;
	}
}

class Toys_NaziFlagT : Toys_UKFlag
{
	Default
	{
	//$Title Exhibit Toy, Nazi Flag (tall, breakable)
	}
	States
	{
	Spawn:
		FLAG B -1;
		Stop;
	}
}

class Toys_NaziFlagS : Toys_UKFlag
{
	Default
	{
	//$Title Exhibit Toy, Nazi Flag (short, breakable)
	Scale 0.65;
	}
	States
	{
	Spawn:
		FLAG A -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		"####" AAAA 0 A_SpawnItemEx("Debris_Wood", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		FLAG D -1;
		Stop;
	}
}

class Maps_Pins1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Flags
		//$Title Maps Pins - SS Flag
		//$Color 3
		Radius 2;
		Height 2;
		Scale 0.25;
		+NOGRAVITY
		+WALLSPRITE
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MAPP A -1;
		Stop;
	}
}

class Maps_Pins2 : Maps_Pins1
{
	Default
	{
	//$Title Maps Pins - UK Flag
	}
	States
	{
	Spawn:
		MAPP B -1;
		Stop;
	}
}

class Maps_Pins3 : Maps_Pins1
{
	Default
	{
	//$Title Maps Pins - USA Flag
	}
	States
	{
	Spawn:
		MAPP C -1;
		Stop;
	}
}

class Maps_Pins4 : Maps_Pins1
{
	Default
	{
	//$Title Maps Pins - USSR Flag
	}
	States
	{
	Spawn:
		MAPP D -1;
		Stop;
	}
}