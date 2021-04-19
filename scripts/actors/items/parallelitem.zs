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

// An inventory item that prevents itself from exceeding the held amount of a
// "parallel" inventory item class.
class ParallelInventory : Inventory
{
	class<Inventory> parallel;

	Property type: parallel;

	Default
	{
		Inventory.MaxAmount 2147483647;
	}

	// NOTE: This is called when the item has an owner. The "item" argument
	// is not yet owned.
	override bool HandlePickup(Inventory item)
	{
		if (!Super.HandlePickup(item))
		{
			return false;
		}
		Inventory existing = Owner.FindInventory(parallel);
		if (Amount > existing.Amount)
		{
			Amount = existing.Amount;
		}
		return true;
	}

	override bool CanPickup(Actor toucher)
	{
		Inventory existing = toucher.FindInventory(parallel);
		if (!existing)
		{
			return false;
		}
		MaxAmount = existing.MaxAmount;
		return Super.CanPickup(toucher);
	}
}