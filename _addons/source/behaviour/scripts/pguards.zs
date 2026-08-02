class WeaponGuard: Guard replaces Guard
{
	Default
	{
		+PICKUP
	}
	override void Tick()
	{
		if (FindInventory("G43")) { ReplaceWith("RifleGuard"); }
		Super.Tick();
	}
	override bool CanTouchItem(Inventory item)
	{
		Name n = item.GetClassName();
		return !FindInventory(n) && (n == 'G43');
	}
}

class WeaponWGuard: WGuard replaces WGuard
{
	Default
	{
		+PICKUP
	}
	override void Tick()
	{
		if (FindInventory("G43")) { ReplaceWith("WRifleGuard"); }
		else if (FindInventory("MP40")) { ReplaceWith("WMP40Guard"); }
		else if (FindInventory("TrenchShotgun")) { ReplaceWith("WShotgunGuard"); }
		Super.Tick();
	}
	override bool CanTouchItem(Inventory item)
	{
		Name n = item.GetClassName();
		return !FindInventory(n) && (n == 'G43') || (n == 'MP40') || (n == 'TrenchShotgun');
	}
}