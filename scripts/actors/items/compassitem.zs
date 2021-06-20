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

class CompassItem : PuzzleItem
{
	String iconName;
	int specialclue;
	class<Inventory> alternate0, alternate1;

	Property SpecialClue:specialclue;
	Property Alternates: alternate0, alternate1; // Items that get removed if they are already in the inventory when this item is given (e.g., remove halves of an egyptian artifact when you are given the whole artifact)

	Default
	{
		//$Category Pickups (BoA)
		//$Color 13
		-NOGRAVITY
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.UNDROPPABLE
		-INVENTORY.INVBAR
		Inventory.MaxAmount 1;
		Inventory.PickupSound "pickup/papers"; // Default to sounding like paper pickup
		Scale 0.5;
	}

	override void PostBeginPlay()
	{
		iconName = "";

		// Try to use the inventory icon as the compass icon
		iconName = TexMan.GetName(icon);

		// Otherwise fall back to using the spawn sprite
		if (iconName == "")
		{
			TextureID iconTex = CurState.GetSpriteTexture(0);
			iconName = TexMan.GetName(iconTex);
		}

		BoACompass.Add(self, iconName);

		Super.PostBeginPlay();
	}

	override bool TryPickup(in out Actor toucher)
	{
		// Handling so that conversation-given items properly check the max amount before giving items to the player and taking money
		if (bDropped && maxamount > 0) // If given/dropped by another actor, and there is a max amount set...
		{
			let current = toucher.FindInventory(GetClass()); // and it's already in player inventory...
			if (current && current.Amount + Amount > maxamount) // don't pick it up if you already have max amount
			{
				bAlwaysPickup = false;	// Don't force pickup in excess of MaxAmount if the item was spawned by another actor after map load
							// This flag is checked in the internal Inventory pickup logic, regardless of the return value here.
				return false;
			}
		}

		bool pickup = Super.TryPickup(toucher);

		if (pickup && specialclue == 3)
		{
			TextureID tex = SpawnState.GetSpriteTexture(0);
			String texName = TexMan.GetName(tex);

			// If it belongs to this chapter and gets added, autosave on pickup so we don't have to deal with clearing the entries if we die.
			if (MapStatsHandler.AddSpecialPickup(texName, specialclue)) { level.MakeAutoSave(); }
		}

		return pickup;
	}

	override void Tick()
	{
		Super.Tick();

		if (owner) { RemoveAlternates(); }
	}

	void RemoveAlternates()
	{
		if (owner)
		{
			Inventory item;

			item = owner.FindInventory(alternate0);
			if (item) { item.Destroy(); }

			item = owner.FindInventory(alternate1);
			if (item) { item.Destroy(); }
		}
	}
}