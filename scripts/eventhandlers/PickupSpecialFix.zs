/*
 * Copyright (c) 2020 Talon1024
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

class InventoryAction : FakeInventory
{ // Unlike FakeInventory, this follows the "master" inventory item around
	Default
	{
		+INVENTORY.QUIET
	}

	void CopyActionFrom(Inventory item)
	{
		Special = item.special;
		Args[0] = item.Args[0];
		Args[1] = item.Args[1];
		Args[2] = item.Args[2];
		Args[3] = item.Args[3];
		Args[4] = item.Args[4];
		bNoGravity = item.bNoGravity;
		A_SetSize(item.Radius, item.Height);
	}

	override void Tick()
	{
		if (master)
		{
			SetOrigin(master.Pos, false);
		}
		else
		{
			Destroy();
		}
	}

	override bool CanPickup(Actor toucher)
	{
		Inventory masterItem = Inventory(master);
		if (masterItem && !masterItem.CanPickup(toucher))
		{
			return false;
		}
		return Super.CanPickup(toucher);
	}
}

class PickupSpecialFix : StaticEventHandler
{
	override void WorldThingSpawned(WorldEvent e)
	{
		Inventory item = Inventory(e.Thing);
		InventoryAction fake = InventoryAction(e.Thing);
		if (item && !fake && item.bSpecial && item.Special)
		{
			// Copy item special and args
			int special = item.Special;
			int args[5];
			args[0] = item.Args[0];
			args[1] = item.Args[1];
			args[2] = item.Args[2];
			args[3] = item.Args[3];
			args[4] = item.Args[4];
			// Make a new InventoryAction
			fake = InventoryAction(Actor.Spawn("InventoryAction", item.Pos, NO_REPLACE));
			fake.master = item;
			fake.CopyActionFrom(item);
			// Unset the original item's special and args
			item.Special = 0;
			item.Args[0] = 0; item.Args[1] = 0;
			item.Args[2] = 0; item.Args[3] = 0;
			item.Args[4] = 0;
		}
	}
}
