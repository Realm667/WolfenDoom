//Player
class Stamina : Inventory {Default { Inventory.MaxAmount 100; } }
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

class EnemyStep: Actor
{
	Default
	{
		Radius 32;
		Height 55;
		Gravity 10;
		-DONTSPLASH
		+CORPSE
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_CheckRange(1024,"Unsighted"); //feel free to change this value, 768 would be sufficient imho - ozy81
		TNT1 A 3;
		Stop;
	Crash:
		"####" A 1;
		Stop;
	Unsighted: //let's avoid flooding sound channels - ozy81
		TNT1 A 0 {bDontSplash = TRUE;}
		Goto Spawn+1;
	}
}

class PlayerStep: Actor
{
	Default
	{
		Speed 0;
		Gravity 10;
		+CORPSE
		+LOOKALLAROUND
	}
	States
	{
	Spawn:
		TNT1 A 1 NODELAY A_Look;
		Loop;
	See:
		"####" A 3;
		Goto See + 1;
	Crash:
		"####" A 1;
		Stop;
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
