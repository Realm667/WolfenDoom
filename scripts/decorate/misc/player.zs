/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED,
 *                         AFADoomer, Nash Muhandes, Talon1024
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

//Player
class IncomingMessage : Inventory {Default { Inventory.MaxAmount 20; } }

class ScientistUniformToken : DisguiseToken
{
	Default
	{
		Inventory.Icon "UNFSB0";
		Inventory.PickupMessage "$UNIFORM1";
		Inventory.PickupSound "pickup/uniform";
		Scale 0.7;
		Tag "$TAGCOATL";
	}
	States
	{
		Spawn:
			UNFL B -1;
			Stop;
		Pickup:
			TNT1 A 0 A_SelectWeapon("NullWeapon");
			Stop;
		WalkSprite:
			PLSC A 0;
		CrouchSprite:
			PLYS A 0;
	}
}

class CCBJUniformToken : DisguiseToken //used in concentration Camp
{
	Default
	{
		Inventory.Icon "UNFSC0";
		Inventory.PickupMessage "$UNIFORM3";
		Scale 0.7;
		Tag "$TAGCOATC";
		DropItem "NullWeapon"; // List here adds the Shovel, so breaks inheritance of parent item list, so
		DropItem "FakeID", 1;  // they all must be included here if we want them to work in this disguise.
		DropItem "Shovel";
	}
	States
	{
		Spawn:
			UNFL C -1;
			Stop;
		Pickup:
			TNT1 A 0 A_SelectWeapon("NullWeapon");
			Stop;
		WalkSprite:
			PLCP A 0;
		CrouchSprite:
			PLYP A 0;
	}
}

class SSBJUniformToken : DisguiseToken
{
	Default
	{
		Inventory.Icon "UNFSD0";
		Inventory.PickupMessage "$UNIFORM2";
		Inventory.PickupSound "pickup/uniform";
		Scale 0.7;
		Tag "$TAGCOATS";
	}
	States
	{
		Spawn:
			UNFL D -1;
			Stop;
		Pickup:
			TNT1 A 0 A_SelectWeapon("NullWeapon");
			Stop;
		WalkSprite:
			PLSS A 0;
		CrouchSprite:
			PLSD A 0;
	}
}

class PRBJUniformToken : DisguiseToken //used in C2M1
{
	Default
	{
		Inventory.Icon "UNFSA0";
		Inventory.PickupMessage "$UNIFORM4";
		Inventory.PickupSound "pickup/uniform";
		-DisguiseToken.NoTarget;
		Scale 0.7;
		Tag "$TAGCOATP";
	}
	States
	{
		Spawn:
			UNFL A -1;
			Stop;
		Pickup:
			TNT1 A 0 A_SelectWeapon("NullWeapon");
			Stop;
		WalkSprite:
			PLZP A 0;
		CrouchSprite:
			PLYZ A 0;
	}
}

class BaseLineSpawner: Actor
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SpawnItemEx("BaseLine", random(16, -16), random(16, -16), random(0, 8), 0, 0, random(1,3), 0, 129, 0);
		"####" A 0 A_FadeOut(0.02);
		Loop;
	}
}

//Dummy Item for hiding the HUD
class CutsceneEnabled : Inventory
{
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}

// Dialogue tokens - can be used in IfItem blocks in Strife conversations to
// boot the player back to the "main menu" in the conversation, or lock out
// certain options.
class DialogueToken1 : Inventory { Default { Inventory.MaxAmount 1; } }
class DialogueToken2 : DialogueToken1 {}
class DialogueToken3 : DialogueToken1 {}
