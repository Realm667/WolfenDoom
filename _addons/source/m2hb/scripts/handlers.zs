class WeaponOverrideHandler : EventHandler
{
	override void WorldTick() {
		for (int pn = 0; pn < MAXPLAYERS; pn++) {
			if (!playerInGame[pn]) continue;
			PlayerInfo player = players[pn];
			PlayerPawn mo = player.mo;
			let oldweap = player.pendingWeapon.GetClassName();
			//let oldweapr = player.readyweapon.GetClassName(); --commented out to avoid https://github.com/Realm667/WolfenDoom/issues/938
			if (oldweap == 'NebelwerferTruck')
			{
				player.pendingWeapon = GetWeapon(mo, "M2HBTruck");
			}
		}
	}
	private Weapon GetWeapon(PlayerPawn mo, Class<Weapon> type)
	{
		let weap = Weapon(mo.FindInventory(type));
		return weap ? weap : Weapon(mo.GiveInventoryType(type));
	}
}
