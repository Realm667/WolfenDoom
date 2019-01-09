/*

  Base class that allows you to set up Inventory items of different classes that add their
  amounts up in a single inventory item, just like ammunition.  

  Used for Soul items.

  Lots of code derived from existing code in the Ammo class...  So much so that it's almost not
  worth it.  All you have to do to emulate this behavior is to inherit from Ammo instead of 
  Inventory and add "Ammo.BackpackAmount 0;" and "+INVENTORY.IGNORESKILL" to your base class 
  (i.e., "Soul") definitions.  That's how the CoinItem is done.

*/
class StackableInventory : Inventory
{
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
}