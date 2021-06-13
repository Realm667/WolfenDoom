/*
 * Copyright (c) 2018-2020 AFADoomer
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

class BoASupplyChest : Actor
{
	bool open;
	Class<Actor> spawnclass;
	Class<Inventory> keyclass;
	sound failsound, opensound;

	Property Key:keyclass;
	Property FailSound:failsound;
	Property OpenSound:opensound;

	Default
	{
		//$Category Pickups (BoA)/Treasures
		//$Title Treasure Chest
		//$Color 17
		//$Arg0 "Prize"
		//$Arg0Tooltip "Predefined chest prize:\n  1 = 100 Coins\n  2 = 75 Coins\n  3 = 25 Coins\n  4 = Kar98k\n  5 = 2 Field Kits\n  6 = Grenades"
		//$Arg0Str "Actor class to spawn"
		//$Arg1 "Script"
		//$Arg1Tooltip "Optional script number to run when chest is unlocked. 0 means no script."
		//$Arg2 "Objective"
		//$Arg2Tooltip "Optional index of objective to clear when chest is unlocked. A value less than 0 means no objective."
		//$Arg2Default -1

		+CANPASS
		+ACTLIKEBRIDGE
		+DONTTHRUST
		+SOLID
		Height 25;
		Radius 14;
		BoASupplyChest.Key "ChestKey";
		BoASupplyChest.FailSound "treasure/locked";
		BoASupplyChest.OpenSound "misc/p_pkup";
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
		Open:
			"####" B 0 A_StartSound("CHESTOPN", CHAN_AUTO, 0, 0.5);
			"####" BC 5;
			"####" D -1; // E and F frames available, but maybe opens too far then?
			Stop;
	}

	override void PostBeginPlay()
	{
		BoACompass.Add(self, "CHESTICO");

		if (args[0] < 0) // If a string value was passed in, use that as the spawn class
		{
			spawnclass = GetSpawnableType(args[0]);

			if (GetDefaultByType(spawnclass).bCountItem) { level.total_items++; }
		} 
		else if (args[0] && args[0] < 4) // Pre-increment the level's item count so that the percentages are correct
		{
			switch(args[0])
			{
				case 1: // 100 coins (6 bags and 40 coins)
					level.total_items += 46;
					break;
				case 2: // 75 coins (4 bags and 35 coins)
					level.total_items += 39;
					break;
				case 3: // 25 coins (1 bag and 15 coins)
					level.total_items += 16;
					break;
			}
		}

		Super.PostBeginPlay();
	}

	override bool Used(Actor user)
	{
		if (open) { return false; } // Fail if it's already open
		if (keyclass && !user.FindInventory(keyclass, 1)) // If they don't have a key, don't open, and play a locked sound
		{
			A_StartSound(failsound, CHAN_AUTO, 0, 1.0); 
			return false;
		}

		// Take the key and play the opening sound
		A_StartSound(opensound, CHAN_AUTO, 0, 1.0); 
		if (keyclass) { user.TakeInventory(keyclass, 1); }

		// Tell the chest to open
		open = true;
		SetStateLabel("Open");

		// Lower height so that we can spawn items 'inside' the chest
		// Also effectively removes it from blocking the player
		A_SetSize(radius, 8);

		if (spawnclass) // If arg[0] resolved to a classname
		{
			// Spawn that actor
			let mo = Spawn(spawnclass, pos + (0, 0, height), ALLOW_REPLACE);
			mo.scale *= 0.75;
			mo.bDropped = False;

			if (mo.bCountItem) { level.total_items--; }
		}
		else // Otherwise fall back to the hard-coded presets
		{
			switch(args[0])
			{
				case 1: // 100 coins
					Inventory.PrintPickupMessage(user.CheckLocalView(consoleplayer), StringTable.Localize("$100COINS"));
					SpawnInBox("BagOfCoins", 6); // 60 coins
					SpawnInBox("SingleCoin", 40); // 40 coins
					level.total_items -= 46;
					break;
				case 2: // 75 coins
					Inventory.PrintPickupMessage(user.CheckLocalView(consoleplayer), StringTable.Localize("$75COINS"));
					SpawnInBox("BagOfCoins", 4); // 40 coins
					SpawnInBox("SingleCoin", 35); // 35 coins
					level.total_items -= 39;
					break;
				case 3: // 25 coins
					Inventory.PrintPickupMessage(user.CheckLocalView(consoleplayer), StringTable.Localize("$25COINS"));
					SpawnInBox("BagOfCoins", 1); // 10 coins
					SpawnInBox("SingleCoin", 15); // 15 coins
					level.total_items -= 16;
					break;
				case 4: // Karabiner
					Inventory.PrintPickupMessage(user.CheckLocalView(consoleplayer), StringTable.Localize("$KARCHEST"));
					A_SetSize(radius, 14); // Different height for this spawn to avoid clipping with the chest
					SpawnInBox("Kar98k", spread:true);
					break;
				case 5: // 2 Field Kits
					Inventory.PrintPickupMessage(user.CheckLocalView(consoleplayer), StringTable.Localize("$FKITCHEST"));
					SpawnInBox("FieldKit", 2, spread:true);
					break;
				case 6: // 3 Grenades
					Inventory.PrintPickupMessage(user.CheckLocalView(consoleplayer), StringTable.Localize("$GRECHEST"));
					SpawnInBox("GrenadePickup", 3, spread:true);
					break;
				default:
					break;
			}
		}

		// If you passed in a script number, then run the script
		if (args[1]) { ACS_ExecuteAlways(args[1], 0, tid); }

		// If this was tied to an objective, then mark that objective complete
		if (args[2] >= 0 && args[2] < 6)
		{
			ACS_NamedExecuteAlways("CompleteObjective", 0, args[2]);
			ACS_NamedExecuteAlways("boaobjectiveaccomplished");
		}

		BoACompass.Remove(self);

		AchievementTracker.CheckAchievement(user.PlayerNumber(), AchievementTracker.ACH_TREASUREHUNTER);

		return true;
	}

	// Spawns within a bounded area aligned with the chest actor's angle
	void SpawnInBox(Class<Actor> sp, int amt = 1, double w = 36, double d = 22, bool spread = false) // w and d are width and depth of the box
	{
		Vector2 offset;
		int count;
		double spawnscale = 0.75;

		double size = GetSpriteRadius(sp) * spawnscale;
		double space = size * 2;

		// Move in from the edges by the sprite's widest radius
		w = max(w / 2 - size, 0);
		d = max(d / 2 - size, 0);

		// Do this as many times as specified
		while (count < amt)
		{
			if (spread) // Space them evenly across the chest (Doesn't check against chest width!  Make sure this works in-game with the sprite widths!)
			{
				double start = -space * amt / 2 + space / 2;

				offset = (0, start + space * count);
			}
			else // Pick a random offset from center of the actor
			{
				offset = (FRandom(-d, d), FRandom(-w, w));
			}

			// Rotate the coordinates to align them with the chest's angle.
			offset = RotateVector(offset, angle);

			// Spawn the actor
			Actor mo = Spawn(sp, (pos.x + offset.x, pos.y + offset.y, pos.z + height));
			if (mo)
			{
				mo.scale *= spawnscale;
				mo.angle = angle;
				count++;
			}
		}
	}

	double GetSpriteRadius(Class<Actor> sp)
	{
		// Get the defaults for the spawning class
		let def = GetDefaultByType(sp);

		TextureID tex = def.SpawnState.GetSpriteTexture(0);

		if (tex) {
			Vector2 size = TexMan.GetScaledSize(tex);
			Vector2 offset = TexMan.GetScaledOffset(tex);

			return max(size.x - offset.x, offset.x) * def.scale.x; // Get the width of the widest part of the sprite (left or right of the offset center)
		}

		return 0;
	}
}

class BoASupplyChest_DSA1 : BoASupplyChest 
{
	//$Title Treasure Chest (DSA, easteregge)
}