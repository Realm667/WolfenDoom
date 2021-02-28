class SpearOfDestiny : CompassItem
{
	Default
	{
		//$Title Spear of Destiny
		Tag "$TAGSTAFF";
		Scale 0.67;
		+COUNTITEM
		Inventory.Icon "SPEAA0";
		Inventory.PickupMessage "$SPEAROD";
		Inventory.PickupSound "misc/spearofdestiny";
		CompassItem.Alternates "SpearofDestiny_End", "";
	}

	States
	{
		Spawn:
			SPEA B -1;
			Stop;
	}
}

class SpearOfDestiny_End : SpearOfDestiny
{
	Default
	{
		//$Title Spear of Destiny (Final Battle)
		+FLOATBOB
		Radius 48; // Make this easier to pick up
		Scale 2.0; // start scaled up, since it gets dropped from Longinus_Hitler
		CompassItem.Alternates "SpearofDestiny", "";
	}

	States
	{
		Spawn:
			SPEA C -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		floorclip = -24; // Raise the sprite above the floor, but not the hitbox

		SetOrigin((pos.xy, floorz), false);
	}

	override void Tick()
	{
		Super.Tick();
		
		if (scale.x != 0.67)
		{
			if (scale.x > 0.67) { scale = (scale.x - 0.025) * (1.0, 1.0); }
			else { scale = 0.67 * (1.0, 1.0); }
		}
	}
}

class UniformStand : SwitchableDecoration
{
	class<DisguiseToken> currentuniform;
	Inventory dropped;

	property UniformType: currentuniform;

	Default
	{
		Radius 8;
		Height 56;
		Scale 0.7;
		+NOTAUTOAIMED
		+SOLID
		+USESPECIAL
		Activation THINGSPEC_Switch;
		UniformStand.UniformType "";
	}

	States
	{
		Spawn:
			HNG1 A 0;
			Goto Inactive;
		Inactive:
			"####" "#" -1 {
				bDormant = TRUE; 
				ACS_NamedExecuteAlways("BoA_CompassQueue",0);
			}
			Stop;
		PreLoadSprites:
			HNG1 ABCD 0;
			HNG2 ABCD 0;
	}
	
	override void Activate (Actor activator)
	{
		// Can't be activated if the rack is empty, or if we've already spawned a disguise that hasn't been picked up
		if (activator is "PlayerPawn" && currentuniform && (!dropped || dropped.owner))
		{
			// Spawn the pickup for the disguise that was on the rack
			if (currentuniform) { dropped = Inventory(Spawn(currentuniform, pos + (0, 0, 16))); }

			// Find any current disguise that's in the player inventory
			let disguise = DisguiseToken(activator.FindInventory("DisguiseToken", True));

			if (disguise)
			{
				// If the player already had a disguise, set that as the rack's current disguise
				if (disguise is "ScientistUniformToken") { frame = 1; }
				else if (disguise is "CCBJUniformToken") { frame = 2; }
				else if (disguise is "SSBJUniformToken") { frame = 3; }
				else { frame = 0; }

				currentuniform = disguise.GetClass();

				// Remove the old disguise from the player inventory
				disguise.DepleteOrDestroy(); // Reset the player's attributes and remove from the player's inventory
			}
			else
			{
				// Otherwise, just set the rack to the empty sprite and don't let it be used again
				frame = 0;
				currentuniform = null;
			}

			SetStateLabel("Inactive");
		}
	}
	
	override void Deactivate (Actor deactivator)
	{
		Activate(deactivator);
	}
}
