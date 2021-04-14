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

//Shards
class FlaskShard1: Actor
{
	Default
	{
	Radius 2;
	Height 4;
	Speed 2;
	Mass 1;
	RenderStyle "Translucent";
	Alpha 0.6;
	+DONTSPLASH
	+MISSILE
	+NOBLOCKMAP
	+NOTELEPORT
	}
	States
	{
	Spawn:
		TSR1 ABCD 4;
		TSR1 ABC 4;
		TSR1 D 4 A_Jump (24, "DeathA");
		TSR1 ABCD 4;
		TSR1 ABC 4;
		TSR1 D 4 A_Jump (24, "DeathB");
		Loop;
	DeathA:
		"####" C 5 A_Jump (80, "DeathA2");
		Stop;
	DeathB:
		"####" D 5 A_Jump (80, "DeathB2");
		Stop;
	DeathA2:
		"####" C 3 A_Jump (24, "DeathA2");
		Stop;
	DeathB2:
		"####" D 3 A_Jump (24, "DeathB2");
		Stop;
	}
}

class FlaskShard2 : FlaskShard1
{
	States
	{
	Spawn:
		TSR2 ADBC 4;
		TSR2 ADB 4;
		TSR2 C 4 A_Jump (24, "DeathA");
		TSR2 ADBC 4;
		TSR2 ADB 4;
		TSR2 C 4 A_Jump (24, "DeathB");
		Loop;
	}
}

//Lab Glasses
class FlaskBlueA: Actor
{
	Default
	{
	//$Category Props (BoA)/Labs
	//$Title Lab Flask (blue 1)
	//$Color 3
	Mass 1500;
	Health 1;
	Radius 8;
	Height 16;
	Scale 0.3;
	+ACTIVATEMCROSS
	+DONTGIB
	+NOBLOOD
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	DeathSound "tubes/break";
	}
	States
	{
	Spawn:
		FLKS A -1;
		Stop;
	Death:
		TNT1 AAAAAA 0 A_SpawnItemEx("FlaskShard1", 0, 0, random (3, 5), random (-5, 5), random (-5, 5), random (1, 2), 0, 0, 30);
		TNT1 AAAAAA 0 A_SpawnItemEx("FlaskShard2", 0, 0, random (3, 5), random (-5, 5), random (-5, 5), random (1, 2), 0, 0, 30);
		TNT1 A 0 A_Scream;
		Stop;
	}
}

class FlaskBlueB : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (blue 2)
	}
	States
	{
	Spawn:
		FLKS G -1;
		Stop;
	}
}

class FlaskPurpleA : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (purple 1)
	}
	States
	{
	Spawn:
		FLKS B -1;
		Stop;
	}
}

class FlaskPurpleB : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (purple 2)
	}
	States
	{
	Spawn:
		FLKS H -1;
		Stop;
	}
}

class FlaskRedA : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (red 1)
	//$Color 3
	}
	States
	{
	Spawn:
		FLKS C -1;
		Stop;
	}
}

class FlaskRedB : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (red 2)
	//$Color 3
	}
	States
	{
	Spawn:
		FLKS I -1;
		Stop;
	}
}

class FlaskGreenA : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (green 1)
	}
	States
	{
	Spawn:
		FLKS D -1;
		Stop;
	}
}

class FlaskGreenB : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (green 2)
	}
	States
	{
	Spawn:
		FLKS J -1;
		Stop;
	}
}

class FlaskYellowA : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (yellow 1)
	}
	States
	{
	Spawn:
		FLKS E -1;
		Stop;
	}
}

class FlaskYellowB : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (yellow 2)
	}
	States
	{
	Spawn:
		FLKS K -1;
		Stop;
	}
}

class FlaskGreyA : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (grey 1)
	}
	States
	{
	Spawn:
		FLKS F -1;
		Stop;
	}
}

class FlaskGreyB : FlaskBlueA
{
	Default
	{
	//$Title Lab Flask (grey 2)
	}
	States
	{
	Spawn:
		FLKS L -1;
		Stop;
	}
}

class GlassBlue : FlaskBlueA
{
	Default
	{
	//$Title Lab Glass (Blue)
	Radius 4;
	Height 4;
	}
	States
	{
	Spawn:
		BEAK A -1;
		Stop;
	}
}

class GlassPurple : GlassBlue
{
	Default
	{
	//$Title Lab Glass (Purple)
	}
	States
	{
	Spawn:
		BEAK B -1;
		Stop;
	}
}

class GlassRed : GlassBlue
{
	Default
	{
	//$Title Lab Glass (Red)
	}
	States
	{
	Spawn:
		BEAK C -1;
		Stop;
	}
}

class GlassGreen : GlassBlue
{
	Default
	{
	//$Title Lab Glass (Zyklon Green)
	}
	States
	{
	Spawn:
		BEAK D -1;
		Stop;
	}
}

class GlassYellow : GlassBlue
{
	Default
	{
	//$Title Lab Glass (Yellow)
	}
	States
	{
	Spawn:
		BEAK E -1;
		Stop;
	}
}

class GlassGrey : GlassBlue
{
	Default
	{
	//$Title Lab Glass (Grey)
	}
	States
	{
	Spawn:
		BEAK F -1;
		Stop;
	}
}

class BigFlaskSpawner : SwitchableDecoration
{
	Default
	{
	//$Category Props (BoA)/Labs
	//$Title Big Flask Spawner (static, 0-6 args)
	//$Color 3
	//$Sprite DJB1A0
	//$Arg0 "Color"
	//$Arg0Tooltip "Pickup the desired color\nRandom: 0\nBlack: 1\nBlue: 2\nPurple: 3\nZyklon: 4\nRed: 5\nYellow: 6"
	Radius 8;
	Height 16;
	Health 1;
	Mass 1500;
	Scale 0.3;
	+ACTIVATEMCROSS
	+DONTGIB
	+NOBLOOD
	+NODROPOFF
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	DeathSound "tubes/break";
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Black");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Blue");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Purple");
		TNT1 A 0 A_JumpIf(Args[0]==4, "Zyklon");
		TNT1 A 0 A_JumpIf(Args[0]==5, "Red");
		TNT1 A 0 A_JumpIf(Args[0]==6, "Yellow");
	Random: //fall through if set at 0
		DJB1 A -1 A_Jump(128,1);
		DJB2 A -1 A_Jump(128,1);
		DJB3 A -1 A_Jump(128,1);
		DJB4 A -1 A_Jump(128,1);
		DJB5 A -1 A_Jump(128,1);
		DJB6 A -1;
		Stop;
	Black:
		DJB1 A -1;
		Stop;
	Blue:
		DJB2 A -1;
		Stop;
	Purple:
		DJB3 A -1;
		Stop;
	Zyklon:
		DJB4 A -1;
		Stop;
	Red:
		DJB5 A -1;
		Stop;
	Yellow:
		DJB6 A -1;
		Stop;
	Death:
		TNT1 A 0 A_StartSound("GLASS5");
		"####" AAA 0 A_SpawnItemEx("Debris_GlassShard_Medium", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_UnsetSolid;
		Stop;
	}
}

class BigFlaskSpawner2 : BigFlaskSpawner
{
	Default
	{
	//$Title Big Flask Spawner with pedestal (static, 0-6 args)
	//$Sprite DJB1B0
	Height 33;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Black");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Blue");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Purple");
		TNT1 A 0 A_JumpIf(Args[0]==4, "Zyklon");
		TNT1 A 0 A_JumpIf(Args[0]==5, "Red");
		TNT1 A 0 A_JumpIf(Args[0]==6, "Yellow");
	Random: //fall through if set at 0
		DJB1 B -1 A_Jump(128,1);
		DJB2 B -1 A_Jump(128,1);
		DJB3 B -1 A_Jump(128,1);
		DJB4 B -1 A_Jump(128,1);
		DJB5 B -1 A_Jump(128,1);
		DJB6 B -1;
		Stop;
	Black:
		DJB1 B -1;
		Stop;
	Blue:
		DJB2 B -1;
		Stop;
	Purple:
		DJB3 B -1;
		Stop;
	Zyklon:
		DJB4 B -1;
		Stop;
	Red:
		DJB5 B -1;
		Stop;
	Yellow:
		DJB6 B -1;
		Stop;
	}
}

class BigFlaskSpawner3 : BigFlaskSpawner
{
	Default
	{
	//$Title Big Flask Spawner with pedestal (animated, 0-6 args)
	//$Sprite DJB1C0
	Height 33;
	+RANDOMIZE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Black");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Blue");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Purple");
		TNT1 A 0 A_JumpIf(Args[0]==4, "Zyklon");
		TNT1 A 0 A_JumpIf(Args[0]==5, "Red");
		TNT1 A 0 A_JumpIf(Args[0]==6, "Yellow");
	Random: //fall through if set at 0
		TNT1 A 0 A_Jump(128,"Blue");
		TNT1 A 0 A_Jump(128,"Purple");
		TNT1 A 0 A_Jump(128,"Zyklon");
		TNT1 A 0 A_Jump(128,"Red");
		TNT1 A 0 A_Jump(128,"Yellow");
		//Fall through to set Black
	Black:
		DJB1 DEFC 4;
		Loop;
	Blue:
		DJB2 DEFC 4;
		Loop;
	Purple:
		DJB3 DEFC 4;
		Loop;
	Zyklon:
		DJB4 DEFC 4;
		Loop;
	Red:
		DJB5 DEFC 4;
		Loop;
	Yellow:
		DJB6 DEFC 4;
		Loop;
	}
}

class TubeFlaskSpawner : BigFlaskSpawner
{
	Default
	{
	//$Title Tube Flask Spawner (static, 0-6 args)
	//$Sprite DJB1G0
	Height 25;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Black");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Blue");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Purple");
		TNT1 A 0 A_JumpIf(Args[0]==4, "Zyklon");
		TNT1 A 0 A_JumpIf(Args[0]==5, "Red");
		TNT1 A 0 A_JumpIf(Args[0]==6, "Yellow");
	Random: //fall through if set at 0
		DJB1 G -1 A_Jump(128,1);
		DJB2 G -1 A_Jump(128,1);
		DJB3 G -1 A_Jump(128,1);
		DJB4 G -1 A_Jump(128,1);
		DJB5 G -1 A_Jump(128,1);
		DJB6 G -1;
		Stop;
	Black:
		DJB1 G -1;
		Stop;
	Blue:
		DJB2 G -1;
		Stop;
	Purple:
		DJB3 G -1;
		Stop;
	Zyklon:
		DJB4 G -1;
		Stop;
	Red:
		DJB5 G -1;
		Stop;
	Yellow:
		DJB6 G -1;
		Stop;
	}
}

class PetriSpawner : BigFlaskSpawner
{
	Default
	{
	//$Title Petri Dish Spawner (static, 0-4 args)
	//$Sprite DJPDC0
	//$Arg0 "Type"
	//$Arg0Tooltip "Pickup the desired color\nRandom: 0\nNone: 1\nEmpty: 2\nPurple: 3\nZyklon: 4"
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "None");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Empty");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Purple");
		TNT1 A 0 A_JumpIf(Args[0]==4, "Zyklon");
	Random: //fall through if set at 0
		DJPD C -1 A_Jump(128,1);
		DJPD D -1 A_Jump(128,1);
		DJPD E -1 A_Jump(128,1);
		DJPD F -1;
		Stop;
	None:
		DJPD C -1;
		Stop;
	Empty:
		DJPD D -1;
		Stop;
	Purple:
		DJPD E -1;
		Stop;
	Zyklon:
		DJPD F -1;
		Stop;
	Death:
		TNT1 A 0 { A_Scream(); A_StartSound("GLASS5", CHAN_AUTO, 0, frandom(0.3,0.6), ATTN_NORM); }
		"####" AAA 0 A_SpawnItemEx("Debris_GlassShard_Medium", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_UnsetSolid;
		Stop;
	}
}

class PetriDish_Green: Actor
{
	Default
	{
	//$Category Props (BoA)/Labs
	//$Title Petri Dish (Zyklon, destroyable)
	//$Color 3
	Health 1;
	Radius 8;
	Height 16;
	Mass 1500;
	Scale 0.3;
	+ACTIVATEMCROSS
	+DONTGIB
	+NOBLOOD
	+NODROPOFF
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	DeathSound "tubes/break";
	}
	States
	{
	Spawn:
		DJPD A -1;
		Stop;
	Death:
		TNT1 A 0 { A_Scream(); A_StartSound("GLASS5", CHAN_AUTO, 0, frandom(0.2,0.4), ATTN_NORM); }
		"####" AAA 0 A_SpawnItemEx("Debris_GlassShard_Medium", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.2,0.4), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("MetalFrags");
		DJPD I -1 A_UnsetSolid;
		Stop;
	}
}

class PetriDish_Purple : PetriDish_Green
{
	Default
	{
	//$Category Props (BoA)/Labs
	//$Title Petri Dish (Mutant, destroyable)
	//$Color 3
	}
	States
	{
	Spawn:
		DJPD B -1;
		Stop;
	}
}

class MagnifySpawner : BigFlaskSpawner
{
	Default
	{
	//$Title Magnify Glass with pedestal Spawner (static, 0-2 args)
	//$Sprite DJPDH0
	//$Arg0 "Type"
	//$Arg0Tooltip "Pickup the desired type\nRandom: 0\nNone: 1\nGlass: 2"
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Random");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Empty");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Glass");
	Random: //fall through if set at 0
		DJPD G -1 A_Jump(128,1);
		DJPD H -1;
		Stop;
	Empty:
		DJPD G -1;
		Stop;
	Glass:
		DJPD H -1;
		Stop;
	Death:
		TNT1 A 0 { A_Scream(); A_StartSound("GLASS5", CHAN_AUTO, 0, frandom(0.2,0.4), ATTN_NORM); }
		"####" AA 0 A_SpawnItemEx("Debris_GlassShard_Medium", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_StartSound("METALBRK", CHAN_AUTO, 0, frandom (0.3,0.5), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("MetalFrags");
		DJPD I -1 A_UnsetSolid;
		Stop;
	}
}

class MagnifyGlass: Actor
{
	Default
	{
	//$Category Props (BoA)/Labs
	//$Title Magnify Glass
	//$Color 3
	Scale 0.3;
	}
	States
	{
	Spawn:
		DJLN A -1;
		Stop;
	}
}

class LabSkeleton: Actor
{
	Default
	{
	//$Category Props (BoA)/Labs
	//$Title Medical Lab Skeleton Display
	//$Color 3
	Height 64;
	Radius 16;
	ProjectilePassHeight 16;
	+NOTAUTOAIMED
	+SOLID
	Scale 0.6;
	}
	States
	{
	Spawn:
		DJDS A -1;
		Stop;
	}
}

class Surgery_Crab: Actor
{
	Default
	{
	//$Category Props (BoA)/Labs
	//$Title Surgery Crab
	//$Color 3
	+NOGRAVITY
	+SOLID
	+SPAWNCEILING
	Radius 20;
	Height 40;
	}
	States
	{
	Spawn:
		SURG A -1;
		Stop;
	}
}

class BrainLab1: Actor
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Brain (1)
	//$Color 4
	Radius 16;
	Height 16;
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
		BRNS A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		TNT1 A 0 A_StartSound("GLASS5", CHAN_AUTO, 0, frandom(0.5,1.0), ATTN_NORM);
		"####" AA 0 A_SpawnItemEx("Debris_GlassShard_Large", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_GlassShard_Medium", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAAAAAA 0 A_SpawnItemEx("Debris_GlassShard_Small", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class BrainLab2 : BrainLab1
{
	Default
	{
	//$Title Brain (2)
	}
	States
	{
	Spawn:
		BRNS B -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Goto Super::Spawn;
	}
}

class BrainLab3 : BrainLab1
{
	Default
	{
	//$Title Brain (3)
	}
	States
	{
	Spawn:
		BRNS C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Goto Super::Spawn;
	}
}

class DripLab1: Actor
{
	Default
	{
	//$Category Gore (BoA)
	//$Title Medical Drip (1)
	//$Color 4
	Radius 12;
	Height 56;
	Scale 0.6;
	ProjectilePassHeight 16;
	+NOGRAVITY
	+SOLID
	}
	States
	{
	Spawn:
		RIPD A -1;
		Stop;
	}
}

class DripLab2 : DripLab1
{
	Default
	{
	//$Title Medical Drip (2)
	}
	States
	{
	Spawn:
		RIPD B -1;
		Stop;
	}
}

class DripLab3 : DripLab1
{
	Default
	{
	//$Title Medical Drip (3)
	}
	States
	{
	Spawn:
		RIPD C -1;
		Stop;
	}
}

class DripLab4 : DripLab1
{
	Default
	{
	//$Title Zyklon Contaminated Medical Drip
	}
	States
	{
	Spawn:
		RIPD D -1;
		Stop;
	}
}