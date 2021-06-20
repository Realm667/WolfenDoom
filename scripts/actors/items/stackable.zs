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

/*

  Base class that allows you to set up Inventory items of different classes that add their
  amounts up in a single inventory item, just like ammunition.  

  Used for Soul items.

  Lots of code derived from existing code in the Ammo class...  So much so that it's almost not
  worth it.  All you have to do to emulate this behavior is to inherit from Ammo instead of 
  Inventory and add "Ammo.BackpackAmount 0;" and "+INVENTORY.IGNORESKILL" to your base class 
  (i.e., "Soul") definitions.  That's how the CoinItem is done.

*/
class StackableInventory : PuzzleItem
{
	Default
	{
		-NOGRAVITY
		-INVENTORY.INVBAR
	}

	Class<Inventory> GetParentInventoryClass ()
	{
		class<Object> type = GetClass();

		while (type.GetParentClass() && type.GetParentClass() != "StackableInventory")
		{
			type = type.GetParentClass();
		}

		return (Class<Inventory>)(type);
	}

	override bool HandlePickup (Inventory item)
	{
		let stack = StackableInventory(item);

		if (stack && stack.GetParentInventoryClass() == GetClass())
		{
			if (Amount < MaxAmount || (sv_unlimited_pickup && !item.ShouldStay()))
			{
				if (Amount > 0 && Amount + item.Amount < 0)
				{
					Amount = 0x7fffffff;
				}
				else
				{
					Amount += item.Amount;
				}
			
				if (Amount > MaxAmount && !sv_unlimited_pickup)
				{
					Amount = MaxAmount;
				}
				item.bPickupGood = true;
			}
			return true;
		}
		return false;
	}

	override Inventory CreateCopy (Actor other)
	{
		Inventory copy;

		let type = GetParentInventoryClass();
		if (GetClass() != type && type != null)
		{
			if (!GoAway ())
			{
				Destroy ();
			}

			copy = Inventory(Spawn (type));
			copy.ClearCounters();
			copy.Amount = amount;
			copy.Deactivate(null);
			copy.BecomeItem ();
		}
		else
		{
			copy = Super.CreateCopy (other);
			copy.Amount = amount;
		}
		if (copy.Amount > copy.MaxAmount)
		{ // Don't pick up more than you're supposed to be able to carry.
			copy.Amount = copy.MaxAmount;
		}
		return copy;
	}

	override bool ShouldStay ()
	{
		return false;
	}
}