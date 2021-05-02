/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, AFADoomer
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

//DEBRIS FOR OBJECTS//
class Debris_Base: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Mass 5;
	Projectile;
	-ACTIVATEIMPACT
	-ACTIVATEPCROSS
	-NOGRAVITY
	+FLATSPRITE
	+RANDOMIZE
	+ROLLCENTER
	+ROLLSPRITE
	+THRUSPECIES
	Species "Player";
	BounceType "Doom";
	BounceFactor 0.3;
	WallBounceFactor 0.3;
	BounceCount 3;
	Gravity 0.3;
	}
}

class Debris_Trash : Debris_Base
{
	Default
	{
	Gravity 0.5;
	Scale 1.2;
	}
	States
	{
	Spawn:
		SRCB B 0 NODELAY A_Jump(256,1,2,3,4);
		"####" BCDF 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Trash2 : Debris_Trash { Default { Scale 0.8; } }

class Debris_Hydrant : Debris_Trash
{
	States
	{
	Spawn:
		HDBR A 0 NODELAY A_Jump(256,1,2,3,4);
		"####" ABCD 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_MetalJunk : Debris_Base
{
	Default
	{
	BounceSound "TANKDBRS";
	Scale 0.6;
	}
	States
	{
	Spawn:
		MTLJ B 0 NODELAY A_Jump(256,1,2,3,4);
		"####" BCEL 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bFlatSprite = FALSE; bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Statue1 : Debris_Base
{
	Default
	{
	BounceSound "misc/SRCRK2";
	BounceFactor 0.5;
	WallBounceFactor 0.5;
	Gravity 0.425;
	Scale 0.3;
	}
	States
	{
	Spawn:
		SRB1 A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5");
	Set1:
		SRB1 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set2:
		SRB2 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set3:
		SRB3 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set4:
		SRB4 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set5:
		SRB5 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bFlatSprite = FALSE; bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Statue2 : Debris_Statue1
{
	States
	{
	Spawn:
		SRG1 A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5");
	Set1:
		SRG1 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set2:
		SRG2 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set3:
		SRG3 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set4:
		SRG4 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set5:
		SRG5 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bFlatSprite = FALSE; bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Statue3 : Debris_Statue1
{
	States
	{
	Spawn:
		SRS1 A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5");
	Set1:
		SRS1 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set2:
		SRS2 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set3:
		SRS3 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set4:
		SRS4 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set5:
		SRS5 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bFlatSprite = FALSE; bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Statue4 : Debris_Statue1
{
	States
	{
	Spawn:
		SRW1 A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5");
	Set1:
		SRW1 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set2:
		SRW2 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set3:
		SRW3 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set4:
		SRW4 A 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	Set5:
		SRW5 A 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-30.25, 30.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bFlatSprite = FALSE; bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Wood : Debris_Base
{
	Default
	{
	Scale 0.65;
	Gravity 0.125;
	}
	States
	{
	Spawn:
		SCDB A 0 NODELAY A_Jump(256,1,2,3,4);
		"####" ABCD 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_ToyHans : Debris_Base
{
	Default
	{
	Scale 0.25;
	Gravity 0.325;
	}
	States
	{
	Spawn:
		TOYD A 0 NODELAY A_Jump(256,1,2,3,4);
		"####" ABCD 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_ToyWaff : Debris_ToyHans
{
	States
	{
	Spawn:
		TOYD E 0 NODELAY A_Jump(256,1,2,3,4);
		"####" EFGH 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_ToyRPG1 : Debris_ToyHans
{
	Default
	{
	Scale 0.55;
	}
	States
	{
	Spawn:
		TOYD I 0 NODELAY;
		"####" I 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(200);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_ToyRPG2 : Debris_ToyHans
{
	Default
	{
	Scale 0.55;
	}
	States
	{
	Spawn:
		TOYD J 0 NODELAY;
		"####" J 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(200);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_ToyRPG3 : Debris_ToyHans
{
	Default
	{
	Scale 0.55;
	}
	States
	{
	Spawn:
		TOYD K 0 NODELAY;
		"####" K 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(200);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Astro : Debris_Base
{
	Default
	{
	Gravity 0.5;
	}
	States
	{
	Spawn:
		ASTD A 0 NODELAY A_Jump(256,1,2);
		"####" AB 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll - frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle - random(-15, 15)); A_SetPitch(pitch - frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_GlassShard_Small : Debris_Base
{
	Default
	{
	RenderStyle "Translucent";
	Alpha 0.4;
	Scale 0.25;
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		GLAS ABCD 4 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" B 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" C 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0 A_Jump(256,1,2,3);
		"####" ABCD 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_GlassShard_Medium : Debris_GlassShard_Small { Default { Scale 0.5; } }
class Debris_GlassShard_Large : Debris_GlassShard_Small { Default { Scale 1.0; } }

class Debris_Bin : Debris_Base
{
	Default
	{
	Gravity 0.5;
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		BINS CDE 4 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" C 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" E 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" C 0 A_Jump(256,1,2,3);
		"####" CDE 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Metal1 : Debris_Base
{
	Default
	{
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		MDB1 BCDA 4 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" B 2 A_ScaleVelocity(0.7);
		"####" C 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" D 2 A_ScaleVelocity(0.7);
		"####" A 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" B 0 A_Jump(256,1,2,3);
		"####" BCDA 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Metal2 : Debris_Base
{
	Default
	{
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		MDB2 BCDA 4 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" B 2 A_ScaleVelocity(0.7);
		"####" C 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" D 2 A_ScaleVelocity(0.7);
		"####" A 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" B 0 A_Jump(256,1,2,3);
		"####" BCDA 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Metal3 : Debris_Base
{
	Default
	{
	Scale 0.7;
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		MDB3 BCDFGHIA 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(450);
		Goto Swim;
	Swim: //mxd
		"####" B 2 A_ScaleVelocity(0.7);
		"####" C 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" D 2 A_ScaleVelocity(0.7);
		"####" A 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" B 0 A_Jump(256,1,2,3);
		"####" BCDA 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Pottery : Debris_Base
{
	Default
	{
	Scale 0.9;
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		POTR ABCDEF 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(350);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" B 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" C 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" E 2 A_ScaleVelocity(0.7);
		"####" F 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" B 0 A_Jump(256,1,2,3);
		"####" BDF 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Porcelain : Debris_Pottery
{
	States
	{
	Spawn:
		POTR GHIJKL 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(350);
		Goto Swim;
	Swim: //mxd
		"####" G 2 A_ScaleVelocity(0.7);
		"####" H 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" I 2 A_ScaleVelocity(0.7);
		"####" J 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" K 2 A_ScaleVelocity(0.7);
		"####" L 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" H 0 A_Jump(256,1,2,3);
		"####" HJL 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Flesh : Debris_Base
{
	Default
	{
	Scale 0.5;
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		BUTC UVW 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(350);
		Goto Swim;
	Swim: //mxd
		"####" U 2 A_ScaleVelocity(0.7);
		"####" V 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" W 2 A_ScaleVelocity(0.7);
		"####" U 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" U 0 A_Jump(256,1,2,3);
		"####" UVW 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 0 A_StopSound(CHAN_ITEM);
		"####" "#" 0 A_StartSound("flesh/stop", CHAN_AUTO, 0, frandom (0.2,0.5), ATTN_NORM);
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y / 2); //let's flat it
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Flesh2 : Debris_Flesh
{
	Default
	{
	Scale 0.15;
	}
	States
	{
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 0 A_StopSound(CHAN_ITEM);
		"####" "#" 0 A_StartSound("flesh/stop", CHAN_AUTO, 0, frandom (0.1,0.3), ATTN_NORM);
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y / 2); //let's flat it
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_FatFlesh : Debris_Flesh
{
	Default
	{
	Scale 0.8;
	Gravity 0.125;
	}
	States
	{
	Spawn:
		BUTC UVW 2 NODELAY { A_JumpIf(waterlevel == 3, "AdjustMass"); A_SpawnItemEx("NashGore_FlyingBlood", random(-2,2), random(-2,2), random(-2,2), random(1,3), random(1,3), random(1,3), angle, SXF_TRANSFERTRANSLATION|SXF_USEBLOODCOLOR|SXF_TRANSFERROLL); }
		Loop;
	}
}

class Debris_Bread : Debris_Base
{
	Default
	{
	Scale 0.5;
	-FLATSPRITE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		BAGU DEF 2 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(350);
		Goto Swim;
	Swim: //mxd
		"####" D 2 A_ScaleVelocity(0.7);
		"####" E 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" F 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" D 0 A_Jump(256,1,2,3);
		"####" DEF 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 0 A_StopSound(CHAN_ITEM);
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y / 2); //let's flat it
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Leaf : Feather //inheritances with Ravens actor
{
	Default
	{
	-DONTSPLASH //original one has +
	+FLATSPRITE
	+ROLLCENTER
	+ROLLSPRITE
	Scale 0.5;
	}
	States
	{
	Spawn:
		PLNT EFGHIJ 3 NODELAY {A_SetRoll(roll + frandom(-5.0, 5.0), SPF_INTERPOLATE); A_SetAngle(angle + random(-15, 15)); A_SetPitch(pitch + frandom(-5.25, 5.25)); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(350);
		Goto Swim;
	Swim: //mxd
		"####" E 2 A_ScaleVelocity(0.7);
		"####" F 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" G 2 A_ScaleVelocity(0.7);
		"####" H 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" I 2 A_ScaleVelocity(0.7);
		"####" J 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" E 0 { A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; }
		"####" E 0 A_Jump(256,1,2,3);
		"####" EGJ 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Translated : Debris_Leaf //needed to fix translations
{
	Default
	{
	-FLATSPRITE
	}
	States
	{
	Spawn:
		TDBR ABCDEF 3 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(350);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" B 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" C 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" E 2 A_ScaleVelocity(0.7);
		"####" F 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0 A_Jump(256,1,2,3);
		"####" ACF 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Cloth : Debris_Leaf
{
	Default
	{
	Scale 0.8;
	Gravity 0.125;
	-FLATSPRITE
	}
	States
	{
	Spawn:
		TDBR ADE 3 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(250);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" E 2 A_ScaleVelocity(0.7);
		"####" A 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0 A_Jump(256,1,2,3);
		"####" ADE 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_ChipsGreen: Actor
{
	Default
	{
	Radius 2;
	Height 4;
	Mass 1;
	+ACTIVATEIMPACT
	+ACTIVATEPCROSS
	+BOUNCEONACTORS
	+BOUNCEONCEILINGS
	+BOUNCEONWALLS
	+CLIENTSIDEONLY
	+MISSILE
	Scale 0.15;
	BounceType "Doom";
	BounceFactor 0.5;
	BounceSound "casino/chips";
	}
	States
	{
	Spawn:
		CHP1 FGHIG 5 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" F 2 A_ScaleVelocity(0.7);
		"####" G 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" H 2 A_ScaleVelocity(0.7);
		"####" I 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" G 2 A_ScaleVelocity(0.7);
		Loop;
	Death:
		"####" C 0 A_Jump(256,1,2,3);
		"####" CI 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE; bBounceOnCeilings = FALSE; bBounceOnWalls = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Stop;
	}
}

class Debris_ChipsBlue : Debris_ChipsGreen
{
	States
	{
	Spawn:
		CHP2 FGHIG 5 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	}
}

class Debris_ChipsRed : Debris_ChipsGreen
{
	States
	{
	Spawn:
		CHP3 FGHIG 5 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	}
}

//Translated ones
class Debris_LeafY : Debris_Translated { Default { Translation "10:10=165:165", "112:125=160:166"; } }
class Debris_LeafR : Debris_Translated { Default { Translation "10:10=184:184", "112:125=168:181"; } }
class Debris_LeafB : Debris_Translated { Default { Translation "10:10=198:198", "112:125=192:198"; } }
class Debris_LeafW : Debris_Translated { Default { Translation "10:10=95:95", "112:125=82:95"; } }
class Debris_FlagsB : Debris_Cloth { Default { Scale 1.0; Translation "10:10=240:240", "112:125=195:207"; } }
class Debris_FlagsR : Debris_Cloth { Default { Scale 1.0; Translation "10:10=184:184", "112:125=168:181"; } }
class Debris_FlagsD : Debris_Cloth { Default { Scale 0.7; Translation "10:10=245:247", "112:125=5:8", "107:107=5:5"; } }
class Debris_FlagsW : Debris_Cloth { Default { Translation "10:10=95:95", "112:125=82:95"; } }
class Debris_FlagsB2 : Debris_Cloth { Default { Scale 0.5; Translation "10:10=240:240", "112:125=195:207"; } }
class Debris_FlagsR2 : Debris_Cloth { Default { Scale 0.5; Translation "10:10=184:184", "112:125=168:181"; } }
class Debris_FlagsD2 : Debris_Cloth { Default { Scale 0.5; Translation "10:10=245:247", "112:125=5:8", "107:107=5:5"; } }
class Debris_FlagsW2 : Debris_Cloth { Default { Scale 0.5; Translation "10:10=95:95", "112:125=82:95"; } }
class Debris_Metal3Dark : Debris_Metal3 { Default { Translation "80:111=109:111"; } }

class Debris_Web : Debris_Cloth
{
	Default
	{
	Scale 0.7;
	Gravity 0.075;
	Translation "10:10=95:95", "112:125=82:95";
	Renderstyle "Translucent";
	Alpha 0.65;
	}
}

//DEBRIS FOR ENEMIES//
class Bones_Base: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Mass 1;
	Scale 0.65;
	Projectile;
	-ACTIVATEIMPACT
	-ACTIVATEPCROSS
	-NOGRAVITY
	+FORCEXYBILLBOARD
	+RANDOMIZE
	+ROLLCENTER
	+ROLLSPRITE
	BounceCount 3;
	BounceFactor 0.7;
	BounceType "Doom";
	WallBounceFactor 0.7;
	Gravity 0.3;
	}
}

class HeadGibs : Bones_Base
{
	Default
	{
	-FLATSPRITE
	-RANDOMIZE
	-ROLLCENTER
	-ROLLSPRITE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13);
		GIBL A -1;
		GIBL B -1;
		GIBL C -1;
		GIBL D -1;
		GIBL E -1;
		GIBL F -1;
		GIBL G -1;
		GIBL H -1;
		GIBL I -1;
		GIBL J -1;
		GIBL K -1;
		GIBL L -1;
		GIBL M -1;
		Stop;
	}
}

class HeadGibsRing: Actor
{
	int user_gibs;
	Default
	{
	Radius 0;
	Height 0;
	+NOBLOCKMAP
	+NOGRAVITY
	+NOINTERACTION
	+THRUSPECIES
	Species "Player";
	}
	States
	{
	Spawn:
		GIBL A 0 A_SpawnItemEx("HeadGibs",0,0,54,frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.0, 6.0),user_gibs, NASHGORE_BLOODFLAGS1, 64);
		GIBL A 0 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 54, frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.0, 6.0), user_gibs, NASHGORE_BLOODFLAGS1, 64);
		GIBL A 0 { user_gibs = user_gibs+45; }
		GIBL A 0 A_JumpIf(user_gibs==360,1);
		Loop;
		TNT1 A 0;
		Stop;
	}
}

class ThroatSpill : HeadGibsRing
{
	States
	{
	Spawn:
		GIBL A 0 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 24, frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.0, 6.0), user_gibs, NASHGORE_BLOODFLAGS1, 64);
		GIBL A 0 { user_gibs = user_gibs+20; }
		GIBL A 0 A_JumpIf(user_gibs==1080,1);
		Loop;
		TNT1 A 0;
		Stop;
	}
}

class Debris_Bone : Bones_Base //no skull
{
	States
	{
	Spawn:
		ZBON A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		"####" ABCDEFG 0 A_Jump(256,"SpawnLoop","SpawnLoop2");
	SpawnLoop:
		"####" "#" 1 {A_SetRoll(roll+random(15,30), SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	SpawnLoop2:
		"####" "#" 1 {A_SetRoll(roll-random(15,30), SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(750);
		Goto Swim;
	Swim: //mxd
		"####" "#" 2 A_ScaleVelocity(0.7);
		"####" "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" "#" 0 {bBounceOnActors = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Skull : Bones_Base
{
	States
	{
	Spawn:
		ZBON H 1 {A_SetRoll(roll-random(15,30), SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass:
		"####" H 0 A_SetMass(750);
		Goto Swim;
	Swim:
		"####" H 2 A_ScaleVelocity(0.7);
		"####" H 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" H 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" H 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" H 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_FatAxe : Debris_Bone
{
	Default
	{
	Scale 0.47;
	-FLATSPRITE
	BounceSound "TANKDBRS";
	}
	States
	{
	Spawn:
		BRUN X 1 A_SetRoll(roll-random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		BRUN X 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE; bFlatSprite = TRUE;}
		"####" X 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_FatShield : Debris_Bone
{
	Default
	{
	Scale 0.47;
	-FLATSPRITE
	BounceSound "TANKDBRS";
	}
	States
	{
	Spawn:
		BRUN Z 1 A_SetRoll(roll+random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		BRUN Z 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE; bFlatSprite = TRUE;}
		"####" Z 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_FatHelm : Debris_Bone
{
	Default
	{
	Scale 0.47;
	}
	States
	{
	Spawn:
		BRUN Y 1 A_SetRoll(roll-random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		BRUN Y 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" Y 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_SSHelm : Debris_Bone
{
	Default
	{
	Scale 0.67;
	}
	States
	{
	Spawn:
		STND J 1 A_SetRoll(roll-random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		STND J 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" J 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_SSHelm2 : Debris_SSHelm
{
	States
	{
	Spawn:
		STND K 1 A_SetRoll(roll-random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		STND K 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" K 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Batton : Debris_Bone
{
	Default
	{
	Scale 0.67;
	}
	States
	{
	Spawn:
		BNAV K 1 A_SetRoll(roll+random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		BNAV K 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" K 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Batton2 : Debris_Batton
{
	States
	{
	Spawn:
		BNAV K 1 A_SetRoll(roll+random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		BNAV K 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" K 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class HitlerChaingun : Debris_FatAxe
{
	Default
	{
	Scale 1.30;
	+WALLSPRITE
	}
	States
	{
	Spawn:
		SHI1 X 1 A_SetRoll(roll-random(15,30), SPF_INTERPOLATE);
		Loop;
	Death:
		SHI1 X 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" X 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Loper : Debris_Skull
{
	Default
	{
	Mass 500;
	}
	States
	{
	Spawn:
		LOPR O 1 {A_SetRoll(roll-random(7,15), SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass:
		"####" O 0 A_SetMass(750);
		Goto Swim;
	Swim:
		"####" O 2 A_ScaleVelocity(0.7);
		"####" O 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" O 0 {A_SetRoll(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		"####" O 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" O 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Mecha : Debris_MetalJunk
{
	Default
	{
	-FLATSPRITE
	BounceFactor 0.5;
	BounceType "Doom";
	Scale 1.0;
	}
	States
	{
	Spawn:
		DMCH A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7","Set8");
		DMCH A 0 A_Jump(256,"Set1");
		Set1:
		"####" A 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" A 1 {A_SetRoll(roll + 25, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set2:
		"####" B 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" B 1 {A_SetRoll(roll - 25, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set3:
		"####" C 0 A_SpawnItemEx("SparkR",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" C 1 {A_SetRoll(roll + 30, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set4:
		"####" D 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" D 1 {A_SetRoll(roll - 30, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set5:
		"####" E 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" E 1 {A_SetRoll(roll + 35, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set6:
		"####" F 0 A_SpawnItemEx("SparkR",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" F 1 {A_SetRoll(roll - 35, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set7:
		"####" G 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" G 1 {A_SetRoll(roll + 40, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set8:
		"####" H 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" H 1 {A_SetRoll(roll - 40, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass:
		DMCH "#" 0 A_SetMass(750);
		DMCH "#" 0 A_Jump(256,"Swim");
	Swim:
		DMCH "#" 2 A_ScaleVelocity(0.7);
		DMCH "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		DMCH "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		DMCH "#" 1 A_SetTics(35*boa_debrislifetime);
		DMCH "#" 0 A_Jump(256,"DeathWait");
	DeathWait:
		"####" "#" 1 A_FadeOut(0.09); //lasts more time to have better feeling of debris spammed around - ozy81
		Wait;
	}
}

class Debris_Mecha2 : Debris_Mecha
{
	States
	{
	Spawn:
		DMCI A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7","Set8");
		DMCI A 0 A_Jump(256,"Set1");
	AdjustMass:
		DMCI "#" 0 A_SetMass(750);
		DMCI "#" 0 A_Jump(256,"Swim");
	Swim:
		DMCI "#" 2 A_ScaleVelocity(0.7);
		DMCI "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		DMCI "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		DMCI "#" 1 A_SetTics(35*boa_debrislifetime);
		DMCI "#" 0 A_Jump(256,"DeathWait");
	}
}

class Debris_Mecha3 : Debris_Mecha
{
	States
	{
	Spawn:
		DMCJ A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7","Set8");
		DMCJ A 0 A_Jump(256,"Set1");
	AdjustMass:
		DMCJ "#" 0 A_SetMass(750);
		DMCJ "#" 0 A_Jump(256,"Swim");
	Swim:
		DMCJ "#" 2 A_ScaleVelocity(0.7);
		DMCJ "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		DMCJ "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		DMCJ "#" 1 A_SetTics(35*boa_debrislifetime);
		DMCJ "#" 0 A_Jump(256,"DeathWait");
	}
}

class Debris_Mecha4 : Debris_Mecha
{
	States
	{
	Spawn:
		DMCK A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7","Set8");
		DMCK A 0 A_Jump(256,"Set1");
	AdjustMass:
		DMCK "#" 0 A_SetMass(750);
		DMCK "#" 0 A_Jump(256,"Swim");
	Swim:
		DMCK "#" 2 A_ScaleVelocity(0.7);
		DMCK "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		DMCK "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		DMCK "#" 1 A_SetTics(35*boa_debrislifetime);
		DMCK "#" 0 A_Jump(256,"DeathWait");
	}
}

class Debris_Mecha5 : Debris_Mecha
{
	States
	{
	Spawn:
		DMCN A 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6","Set7","Set8");
		DMCN A 0 A_Jump(256,"Set1");
	AdjustMass:
		DMCN "#" 0 A_SetMass(750);
		DMCN "#" 0 A_Jump(256,"Swim");
	Swim:
		DMCN "#" 2 A_ScaleVelocity(0.7);
		DMCN "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		DMCN "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		DMCN "#" 1 A_SetTics(35*boa_debrislifetime);
		DMCN "#" 0 A_Jump(256,"DeathWait");
	}
}

class Debris_AstroSuite : Debris_MetalJunk
{
	Default
	{
	BounceFactor 0.5;
	BounceType "Doom";
	Scale 0.70;
	-FLATSPRITE
	}
	States
	{
	Spawn:
		ROB1 P 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6");
		Set1:
		"####" P 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" P 1 {A_SetRoll(roll + 25, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set2:
		"####" Q 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" Q 1 {A_SetRoll(roll - 25, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set3:
		"####" R 0 A_SpawnItemEx("SparkR",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" R 1 {A_SetRoll(roll + 30, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set4:
		"####" S 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" S 1 {A_SetRoll(roll - 30, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set5:
		"####" T 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" T 1 {A_SetRoll(roll + 35, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set6:
		"####" U 0 A_SpawnItemEx("SparkR",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" U 1 {A_SetRoll(roll - 35, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass:
		ROB1 "#" 0 A_SetMass(750);
		Goto Swim;
	Swim:
		ROB1 "#" 2 A_ScaleVelocity(0.7);
		ROB1 "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		ROB1 "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		ROB1 "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_AstroRobot : Debris_AstroSuite
{
	States
	{
	Spawn:
		ROB2 P 0 NODELAY A_Jump(256,"Set1","Set2","Set3","Set4","Set5","Set6");
		Set1:
		"####" P 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" P 1 {A_SetRoll(roll + 25, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set2:
		"####" Q 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" Q 1 {A_SetRoll(roll - 25, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set3:
		"####" R 0 A_SpawnItemEx("SparkR",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" R 1 {A_SetRoll(roll + 30, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set4:
		"####" S 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" S 1 {A_SetRoll(roll - 30, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set5:
		"####" T 0 A_SpawnItemEx("SparkY",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" T 1 {A_SetRoll(roll + 35, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
		Set6:
		"####" U 0 A_SpawnItemEx("SparkR",0,0,random(32,128),0,random(-1,1),random(-1,1),random(0,360),SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE,random(157,203));
		"####" U 1 {A_SetRoll(roll - 35, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass");}
		Loop;
	AdjustMass:
		ROB2 "#" 0 A_SetMass(750);
		Goto Swim;
	Swim:
		ROB2 "#" 2 A_ScaleVelocity(0.7);
		ROB2 "#" 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		ROB2 "#" 0 {A_SetRoll(0); A_SetAngle(0); A_SetPitch(0); bRollCenter = FALSE; bRollSprite = FALSE; bBounceOnActors = FALSE;}
		ROB2 "#" 1 A_SetTics(35*boa_debrislifetime);
	DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

//DEBRIS FOR TANKS//
class Debris_Tank: Actor
{
	Default
	{
	Radius 5;
	Height 5;
	Speed 8;
	Mass 1;
	Scale 0.8;
	BounceFactor 0.5;
	BounceType "Doom";
	BounceSound "TANKDBRS";
	+BOUNCEONACTORS
	+BOUNCEONCEILINGS
	+BOUNCEONWALLS
	+CLIENTSIDEONLY
	+MISSILE
	+NOBLOCKMAP
	+NOTELEPORT
	}
	States
	{
	Spawn:
		BRKP AB 0 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		BRKP AB 2 A_SetScale(Scale.X+frandom(-0.1,0.1),Scale.Y+frandom(-0.1,0.1));
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(500);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" B 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0 A_Jump(256,1,2,3);
		"####" AB 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE; bBounceOnCeilings = FALSE; bBounceOnWalls = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_Tank2 : Debris_Tank
{
	Default
	{
	Scale 0.7;
	Speed 6;
	Mass 1;
	BounceFactor 0.7;
	}
	States
	{
	Spawn:
		MDB1 ABCD 0 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		MDB1 ABCD 2 A_SetScale(Scale.X+frandom(-0.1,0.1),Scale.Y+frandom(-0.1,0.1));
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(500);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" B 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" C 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0 A_Jump(256,1,2,3);
		"####" BD 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE; bBounceOnCeilings = FALSE; bBounceOnWalls = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class Debris_TankShards : Debris_Tank
{
	Default
	{
	Speed 7;
	BounceFactor 0.75;
	RenderStyle "Add";
	Alpha 0.6;
	BounceSound "none";
	}
	States
	{
	Spawn:
		PBIT ABCDEFGHIJ 1 NODELAY A_JumpIf(waterlevel == 3, "AdjustMass"); //mxd
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" B 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" C 2 A_ScaleVelocity(0.7);
		"####" D 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" E 2 A_ScaleVelocity(0.7);
		"####" F 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" G 2 A_ScaleVelocity(0.7);
		"####" H 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		"####" I 2 A_ScaleVelocity(0.7);
		"####" J 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0 A_Jump(256,1,2,3);
		"####" GHJ 0 A_Jump(256,"Death1");
		Stop;
	Death1:
		"####" "#" 0 {bBounceOnActors = FALSE; bBounceOnCeilings = FALSE; bBounceOnWalls = FALSE;}
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
	Death1Wait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

//ACTIVATEABLES//
class Debris_Vent : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Vent Debris (activatable)
	//$Color 12
	+NOINTERACTION
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_SpawnItemEx("PowerPlantSmokePuffSmall", 0, 0, 32, 0, 0, 0, 0, 0);
		TNT1 A 0 A_StartSound("DSMETDST", CHAN_AUTO, 0, 0.5, ATTN_NORM);
		TNT1 AAAA 0 A_SpawnItemEx("Debris_Trash", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
		TNT1 AAAA 0 A_SpawnItemEx("Debris_Trash2", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}

class Debris_Wood2 : Debris_Vent
{
	Default
	{
	//$Title Wood Debris (activatable)
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_SpawnItemEx("PowerPlantSmokePuffSmall", 0, 0, 32, 0, 0, 0, 0, 0); //needed? - Ozy81
		TNT1 A 0 A_StartSound("WOODBRK", CHAN_AUTO, 0, 0.5, ATTN_NORM);
		TNT1 AAAA 0 A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
		TNT1 AAAA 0 A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}