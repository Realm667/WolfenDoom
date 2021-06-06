/*
 * Copyright (c) 2016-2021 Ozymandias81
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

//Concentration Camp actors made from DoomJedi resources
// GORE //
class Camp_HungSkeleton: SceneryBase
{
	Default
	{
		//$Category Concentration Camp (BoA)/Gore
		//$Title Camp Prisoner Hanging Skeleton
		//$Color 3
		Radius 16;
		Height 60;
		Scale 0.65;
		+NOGRAVITY
		+SPAWNCEILING
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		CMPG H -1;
		Stop;
	}
}

class Camp_PrisonerHang : Camp_HungSkeleton
{
	Default
	{
	//$Title Camp Prisoner Hanging (random, bald, detailed)
	//$Sprite HAN4A0
	Radius 8;
	Height 56;
	Scale 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6);
		HAN4 A -1;
		HAN4 B -1;
		HAN4 C -1;
		HAN4 D -1;
		Stop;
	Swinging:
		HAN4 A 1 A_SetTics(Random(80,160));
		"####" E 8;
		"####" G 8;
		"####" E 8;
		Loop;
	}
}

class Camp_RandomPileDead: SceneryBase
{
	Default
	{
		//$Category Concentration Camp (BoA)/Gore
		//$Title Dead Prisoners (pile, random)
		//$Color 3
		Radius 16;
		Height 12;
		ProjectilePassHeight 4;
		Scale 0.65;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5);
		CMPG A -1;
		CMPG B -1;
		CMPG C -1;
		CMPG D -1;
		CMPG E -1;
		Stop;
	}
}

class Camp_RandomPileBones : Camp_RandomPileDead
{
	Default
	{
	//$Title Mound Of Prisoners Bones (random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		CMPG N -1;
		CMPG O -1;
		Stop;
	}
}

class Camp_MoundOfBodies : Camp_RandomPileDead
{
	Default
	{
	//$Title Mound Of Prisoners Bodies
	Height 24;
	}
	States
	{
	Spawn:
		CMPG P -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_ImpaledHead : Camp_RandomPileDead
{
	Default
	{
	//$Title Impaled Prisoner's Head (random)
	Radius 8;
	Height 44;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5);
		CMPG I -1;
		CMPG J -1;
		CMPG K -1;
		CMPG L -1;
		CMPG M -1;
		Stop;
	}
}

class Camp_LogsDead : Camp_RandomPileDead
{
	Default
	{
	//$Title Dead Prisoner, Logs
	Height 32;
	}
	States
	{
	Spawn:
		CMPG G -1;
		Stop;
	}
}

class Camp_SnowyLogsDead : Camp_LogsDead
{
	Default
	{
	//$Title Dead Prisoner, Snowy Logs
	}
	States
	{
	Spawn:
		CMPG F -1;
		Stop;
	}
}

class Camp_RandomBodyParts: SceneryBase
{
	Default
	{
		//$Category Concentration Camp (BoA)/Gore
		//$Title Prisoners Body Parts (random)
		//$Color 3
		Radius 8;
		Height 4;
		Scale 0.7;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);
		GORC A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC N -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC O -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC P -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC Q -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		GORC R -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_LyingBodies : Camp_RandomBodyParts
{
	Default
	{
	//$Title Camp Prisoner Corpse, Lying (random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9);
		CBED A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED I -1 A_SetScale(0.53);
		Stop;
	}
}

class Camp_LyingBodies2 : Camp_RandomBodyParts
{
	Default
	{
	//$Title Camp Prisoner Exhausted, Lying (random)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		CBED J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CBED L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_LyingBodies3 : Camp_RandomBodyParts
{
	Default
	{
	//$Title Camp Prisoner Headshotted, Lying
	}
	States
	{
	Spawn:
		CBED M -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_PrisonerGuts: SceneryBase
{
	Default
	{
		//$Category Concentration Camp (BoA)/Gore
		//$Title Camp Prisoner Corpse, Severed Guts
		//$Color 3
		Radius 8;
		Height 32;
		Scale 0.7;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		GORC S -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_PrisonerSit : Camp_PrisonerGuts
{
	Default
	{
	//$Title Tortured Camp Prisoner (random, sitting)
	//$Sprite SIT4A0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		SIT4 A -1;
		SIT4 B -1;
		SIT4 C -1;
		SIT4 D -1;
		SIT4 E -1;
		SIT4 F -1;
		SIT4 G -1;
		SIT4 H -1;
		SIT4 I -1;
		SIT4 J -1;
		Stop;
	}
}

class Camp_PrisonerSamples: SceneryBase
{
	Default
	{
		//$Category Concentration Camp (BoA)/Gore
		//$Title Camp Prisoner Body Sample (random, shootable)
		//$Color 3
		Radius 16;
		Height 16;
		Scale 0.6;
		Health 1;
		+CANPASS
		+NOBLOOD
		+NOTAUTOAIMED
		+SHOOTABLE
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13);
		CJAR A -1;
		CJAR B -1;
		CJAR C -1;
		CJAR D -1;
		CJAR E -1;
		CJAR F -1;
		CJAR G -1;
		CJAR H -1;
		CJAR I -1;
		CJAR J -1;
		CJAR K -1;
		CJAR L -1;
		CJAR M -1;
		CJAR N -1;
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

class Camp_PrisonerSample1 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Empty Sample 1
	}
	States
	{
	Spawn:
		CJAR A -1;
		Stop;
	}
}

class Camp_PrisonerSample2 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Empty Sample 2
	}
	States
	{
	Spawn:
		CJAR B -1;
		Stop;
	}
}

class Camp_PrisonerSample3 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Empty Sample 3
	}
	States
	{
	Spawn:
		CJAR C -1;
		Stop;
	}
}

class Camp_PrisonerSample4 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Empty Sample 4
	}
	States
	{
	Spawn:
		CJAR D -1;
		Stop;
	}
}

class Camp_PrisonerSample5 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 1
	}
	States
	{
	Spawn:
		CJAR E -1;
		Stop;
	}
}

class Camp_PrisonerSample6 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 2
	}
	States
	{
	Spawn:
		CJAR F -1;
		Stop;
	}
}

class Camp_PrisonerSample7 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 3
	}
	States
	{
	Spawn:
		CJAR G -1;
		Stop;
	}
}

class Camp_PrisonerSample8 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 4
	}
	States
	{
	Spawn:
		CJAR H -1;
		Stop;
	}
}

class Camp_PrisonerSample9 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 5
	}
	States
	{
	Spawn:
		CJAR I -1;
		Stop;
	}
}

class Camp_PrisonerSample10 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 6
	}
	States
	{
	Spawn:
		CJAR J -1;
		Stop;
	}
}

class Camp_PrisonerSample11 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 7
	}
	States
	{
	Spawn:
		CJAR K -1;
		Stop;
	}
}

class Camp_PrisonerSample12 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 8
	}
	States
	{
	Spawn:
		CJAR L -1;
		Stop;
	}
}

class Camp_PrisonerSample13 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 9
	}
	States
	{
	Spawn:
		CJAR M -1;
		Stop;
	}
}

class Camp_PrisonerSample14 : Camp_PrisonerSamples
{
	Default
	{
	//$Title Camp Prisoner Body Sample 10
	}
	States
	{
	Spawn:
		CJAR N -1;
		Stop;
	}
}

// SCENERY //
class Camp_RandomUniform: SceneryBase
{
	Default
	{
		//$Category Concentration Camp (BoA)/Scenery
		//$Title Prisoner Uniform (random)
		//$Color 3
		Scale 0.65;
		Radius 8;
		Height 40;
		ProjectilePassHeight 8;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		CMPP A -1;
		CMPP B -1;
		CMPP C -1;
		Stop;
	}
}

class Camp_RandomBags : Camp_RandomUniform
{
	Default
	{
	//$Title Bags (random)
	Height 16;
	Scale 0.45;
	ProjectilePassHeight 4;
	+CANPASS
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		CMPL A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		CMPL J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_Eyeglass : Cup1
{
	Default
	{
	//$Category Concentration Camp (BoA)/Scenery
	//$Title Eyeglasses (breakable, random X axis)
	//$Color 3
	Height 2;
	Scale 0.25;
	}
	States
	{
	Spawn:
		EGLS A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_StartSound("GLASS5");
		TNT1 AAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		EGLS B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_RandomEyeglass: SceneryBase
{
	Default
	{
		//$Category Concentration Camp (BoA)/Scenery
		//$Title Eyeglasses (broken, random)
		//$Color 3
		Radius 2;
		Height 2;
		Scale 0.25;
		+CANPASS
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5);
		EGLS B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		EGLS C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		EGLS D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		EGLS E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		EGLS F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Camp_RandomBoots : Camp_RandomEyeglass
{
	Default
	{
	//$Title Boots (random)
	Scale 0.45;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		SHOS B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		SHOS C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		SHOS D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		SHOS E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		SHOS F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		SHOS G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		SHOS H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}