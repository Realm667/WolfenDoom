/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer,
 *						 Talon1024
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


/*
Quick Reference:
CrowWander1L 8881 - Wanders, proximity flee. Reacts to weapon fire. Left.
CrowWander1R 8882 - Wanders, proximity flee. Reacts to weapon fire. Right.
CrowWander2L 8883 - Wanders, proximity flee. No reaction to weapon fire. Left.
CrowWander2R 8884 - Wanders, proximity flee. No reaction to weapon fire. Right.
CrowWander3L 8885 - Wanders, no proximity flee. Reacts to weapon fire. Left.
CrowWander3R 8886 - Wanders, no proximity flee. Reacts to weapon fire. Right.
CrowWander4L 8887 - Wanders, no proximity flee. No reaction to weapon fire. Left.
CrowWander4R 8888 - Wanders, no proximity flee. No reaction to weapon fire. Right.
CrowStill1L  8889 - Stationary, proximity flee. Reacts to weapon fire. Left.
CrowStill1R  8890 - Stationary, proximity flee. Reacts to weapon fire. Right.
CrowStill2L  8891 - Stationary, proximity flee. No reaction to weapon fire. Left.
CrowStill2R  8892 - Stationary, proximity flee. No reaction to weapon fire. Right.
CrowStill3L  8893 - Stationary, no proximity flee. Reacts to weapon fire. Left.
CrowStill3R  8894 - Stationary, no proximity flee. Reacts to weapon fire. Right.
CrowStill4L  8895 - Stationary, no proximity flee. No reaction to weapon fire. Left.
CrowStill4R  8896 - Stationary, no proximity flee. No reaction to weapon fire. Right.

Proximity Flee - Flees when player is close to the actor
Reacts to weapon fire - An actor will fly away if a weapon is shot within 800 map units of it.

Note: All actors flee when shot directly. Some flee upon reacting to weapon sound, or when the player approaches. In any case
they will fly towards the sky and permanently disappear.

A fleeing crow will cause any other crows in a nearby group to flee as well when the above conditions are met.
*/

class CrowWander1L : Base //Wandering version. Flees when player gets close and reacts to weapon fire. Faces left.
{
	int user_type;
	Default {
		//$Category Fauna (BoA)
		//$Title Crow (left,wander,proxflee,reactsweapon)
		//$Color 0
		//$Sprite CRW1A0B0
		Mass 99999;
		Health 999;
		Radius 3;
		Height 3;
		Scale 0.7;
		//Monster
		-CASTSPRITESHADOW
		-CANUSEWALLS
		-CANPUSHWALLS
		-COUNTKILL
		-ISMONSTER
		+BOUNCEONWALLS
		+FLOORCLIP
		+FLOORHUGGER
		+LOOKALLAROUND
		+NOBLOOD
		+NODAMAGE
		+NODAMAGETHRUST
		+NOTARGET
		+NOTAUTOAIMED
		+THRUACTORS
		MeleeRange 310;
		PainChance 255;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Stop;
		"####" A 0 A_JumpIfInventory("CrowGroupFlee",1,"Pain");
		"####" A 0 A_LookThroughDisguise(user_type, 0, 310, 800, 0, "Pain");
		"####" A 0 A_StopSound(CHAN_5);
		"####" A 0 A_JumpIfCloser(310,"Pain");
		"####" A 0 {bFloorHugger = TRUE;}
		CRW1 A 25 A_Gravity;
		"####" A 0 A_Jump(60,"LookDown","Peck","ForwardLook");
		"####" A 0 A_Jump(15,"Caw");
		"####" A 0 A_Jump(10,"WanderFly");
		Loop;
	See:
		TNT1 A 0 A_StopSound(CHAN_5);
		"####" A 0 A_FaceTarget;
		"####" A 0 A_JumpIfCloser(310,"Pain");
		"####" A 0 A_JumpIfInventory("CrowGroupFlee",1,"Pain");
		"####" A 0 {bFloorHugger = TRUE;}
		CRW1 A 25 A_Gravity;
		"####" A 0 A_Jump(60,"LookDown","Peck","ForwardLook");
		"####" A 0 A_Jump(15,"Caw");
		"####" A 0 A_Jump(10,"WanderFly");
		Goto Spawn;
	LookDown:
		TNT1 A 0 A_JumpIfCloser(310,"Pain");
		"####" A 0 A_JumpIfInventory("CrowGroupFlee",1,"Pain");
		CRW1 C 5 A_LookThroughDisguise(user_type,0,310,800,0,"Pain");
		"####" A 0 A_Jump(60,"Spawn","Peck");
		Loop;
	Peck:
		TNT1 A 0 A_JumpIfCloser(310,"Pain");
		"####" A 0 A_JumpIfInventory("CrowGroupFlee",1,"Pain");
		CRW1 C 5 A_LookThroughDisguise(user_type,0,310,800,0,"Pain");
		"####" EC 2;
		"####" A 0 A_Jump(60,"Spawn","LookDown");
		Loop;
	Caw:
		TNT1 A 0 A_JumpIfCloser(310,"Pain");
		"####" A 0 A_JumpIfInventory("CrowGroupFlee",1,"Pain");
		"####" A 0 A_LookThroughDisguise(user_type,0,310,800,0,"Pain");
		"####" A 0 A_Jump(60,4); //To play one caw on occasion.
		"####" A 0 A_CheckRange(1280,"NoCaw1");
		CRW1 A 12 A_StartSound("CRWCAW1", CHAN_6, 0, 0.3);
		"####" M 6;
		Goto Spawn;
		CRW1 A 0 A_CheckRange(1280,"NoCaw2");
		CRW1 A 12 A_StartSound("CRWCAW3", CHAN_6, 0, 0.3);
		Goto Spawn;
	NoCaw1:
		CRW1 A 0 A_StopSound(CHAN_6);
		CRW1 A 12;
		"####" M 6;
		Goto Spawn;
	NoCaw2:
		CRW1 A 0 A_StopSound(CHAN_6);
		CRW1 A 12;
		Goto Spawn;
	ForwardLook:
		TNT1 A 0 A_JumpIfCloser(310,"Pain");
		"####" A 0 A_JumpIfInventory("CrowGroupFlee",1,"Pain");
		CRW1 G 16 A_LookThroughDisguise(user_type,0,310,800,0,"Pain");
		"####" A 0 A_Jump(120,"Spawn");
		Loop;
	WanderFly:
		TNT1 A 0 A_CheckRange(1280,2);
		TNT1 A 0 A_StartSound("CRWFLP", CHAN_5, CHANF_LOOPING, 0.3);
		"####" A 0 A_NoGravity;
		"####" A 0 {bFloorHugger = FALSE;}
		"####" A 0 ThrustThing(random[Crow](0,360), random[Crow](4,8), 0, 0);
		CRW1 IK 2;
		TNT1 A 0 ThrustThingZ(0,random[Crow](4,8),0,1);
		"####" A 0 A_Jump(20,"Flight");
		Goto WanderFly+3;
	Flight:
		TNT1 A 0 A_CheckRange(1280,2);
		TNT1 A 0 A_StartSound("CRWFLP", CHAN_5, CHANF_LOOPING, 0.3);
		"####" A 0 ThrustThing(random[Crow](0,360), random[Crow](3,6), 0, 0);
		CRW1 IK 2;
		"####" A 0 A_Jump(35,"FlyDown");
		Goto Flight+1;
	FlyDown:
		TNT1 A 0 A_Stop;
		CRW1 IK 2;
		TNT1 A 0 A_CheckRange(1280,2);
		TNT1 A 0 A_StartSound("CRWFLP", CHAN_5, CHANF_LOOPING, 0.3);
		"####" A 0 ThrustThing(random[Crow](0,360), random[Crow](3,6), 0, 0);
		"####" A 0 ThrustThingZ(0,-2,0,1);
		"####" A 0 A_CheckFloor("Spawn");
		Goto FlyDown+1;
	Melee:
	Pain:
		TNT1 A 0 A_RadiusGive("CrowGroupFlee",160,RGF_OBJECTS,1);
		"####" A 0 A_CheckRange(1280,4);
		"####" A 0 A_Jump(25,2);
		"####" A 0 A_StartSound("CRWCAW2", CHAN_6, 0, 0.4);
		"####" A 0 A_StartSound("CRWFLP", CHAN_5, CHANF_LOOPING, 0.3);
		"####" A 0 A_NoGravity;
		"####" A 0 {bFloorHugger = FALSE;}
		"####" A 0 ThrustThing(random[Crow](0,360), random[Crow](6,12), 0, 0);
		CRW1 IK 2;
		TNT1 A 0 ThrustThingZ(0,random[Crow](12,20),0,1);
		"####" A 0 A_FadeOut(0.1);
		Goto Pain+5;
	}
}

class CrowWander1R : CrowWander1L //Wandering version. Flees when player gets close and reacts to weapon fire. Faces right.
{
	Default
	{
		//$Title Crow (right,wander,proxflee,reactsweapon)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(-Scale.X,Scale.Y);
		Goto Super::Spawn;
	}
}

class CrowWander2L : CrowWander1L //Wandering version. Flees when player gets close. No reaction to weapon fire. Faces left.
{
	Default
	{
		//$Title Crow (left,wander,proxflee)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY { user_type = LOF_NOSOUNDCHECK; }
		Goto Super::Spawn;
	}
}

class CrowWander2R : CrowWander1R //Wandering version. Flees when player gets close. No reaction to weapon fire. Faces right.
{
	Default
	{
		//$Title Crow (right,wander,proxflee)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY { user_type = LOF_NOSOUNDCHECK; }
		Goto Super::Spawn;
	}
}

class CrowWander3L : CrowWander1L //Wandering version. Does not flee when player approches but reacts to weapon fire. Faces left.
{
	Default
	{
		//$Title Crow (left,wander,reactsweapon)
		-LOOKALLAROUND
		MeleeRange 44;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY { user_type = LOF_NOSIGHTCHECK; }
		Goto Super::Spawn;
	}
}

class CrowWander3R : CrowWander1R //Wandering version. Does not flee when player approches but reacts to weapon fire. Faces right.
{
	Default
	{
		//$Title Crow (right,wander,reactsweapon)
		-LOOKALLAROUND
		MeleeRange 44;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY { user_type = LOF_NOSIGHTCHECK; }
		Goto Super::Spawn;
	}
}

class CrowWander4L : CrowWander1L //Wandering version. Does not flee when player approches. No sounds reaction. Faces left.
{
	Default
	{
		//$Title Crow (left,wander)
		-LOOKALLAROUND
		MeleeRange 44;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY { user_type = LOF_NOSIGHTCHECK+LOF_NOSOUNDCHECK; }
		Goto Super::Spawn;
	}
}

class CrowWander4R : CrowWander1R //Wandering version. Does not flee when player approches. No sound reaction. Faces right.
{
	Default
	{
		//$Title Crow (right,wander)
		-LOOKALLAROUND
		MeleeRange 44;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY { user_type = LOF_NOSIGHTCHECK+LOF_NOSOUNDCHECK; }
		Goto Super::Spawn;
	}
}

//===================//
//STATIONARY VERSIONS//
//===================//

class CrowStill1L : CrowWander1L //Stationary version. Flees when player is close. Reacts to sound. Faces left.
{
	Default
	{
		//$Title Crow (left,stationary,proxflee,reactsweapon)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowStill1R : CrowWander1R //Stationary version. Flees when player is close. Reacts to sound. Faces right.
{
	Default
	{
		//$Title Crow (right,stationary,proxflee,reactsweapon)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowStill2L : CrowWander2L //Stationary version. Flees when player is close. No sound reaction. Faces left.
{
	Default
	{
		//$Title Crow (left,stationary,proxflee)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowStill2R : CrowWander2R //Stationary version. Flees when player is close. No sound reaction. Faces right.
{
	Default
	{
		//$Title Crow (right,stationary,proxflee)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowStill3L : CrowWander3L //Stationary version. Does not flee when player is close. Reacts to sound. Faces left.
{
	Default
	{
		//$Title Crow (left,stationary,reactsweapon)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowStill3R : CrowWander3R //Stationary version. Flees when player is close. No sound reaction. Faces right.
{
	Default
	{
		//$Title Crow (right,stationary,reactsweapon)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowStill4L : CrowWander4L //Stationary version. Does not flee when player is close. No sound reaction. Faces left.
{
	Default
	{
		//$Title Crow (left,stationary)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowStill4R : CrowWander4R //Stationary version. Does not flee when player is close. No sound reaction. Faces right.
{
	Default
	{
		//$Title Crow (right,stationary)
	}
	States
	{
	WanderFly:
		Goto Spawn;
	}
}

class CrowGroupFlee : Inventory {}
