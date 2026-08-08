class MeleeWeaponHandler: EventHandler
{
	int cooldown[MAXPLAYERS];
	int staminarecoverytimeout[MAXPLAYERS];
	static const Name classes_to_remove[] = {'Luger9mm', 'Walther9mm', 'AstroLuger', 'TrenchShotgun', 'Browning5', 'AstroShotgun', 'MP40', 'Sten', 'AstroChaingun', 'Kar98k', 'G43', 'Pyrolight', 'Nebelwerfer', 'AstroRocketlauncher', 'Panzerschreck', 'TeslaCannon', 'UMG43', 'GrenadePickup', 'DeployableMine', 'Ammo9mm', 'Ammo12Gauge', 'MauserAmmo', 'FlameAmmo', 'NebAmmo', 'PanzerAmmo', 'TeslaCell'};
	static const Name classes_to_replace[] = {'AmmoBox9mm', 'AmmoBox12Gauge', 'MauserAmmoBox', 'NebAmmoBox', 'TeslaCellBox', 'AstroGrenadePickup'};
	override void CheckReplacement(ReplaceEvent e)
	{
		if (e.Replacee is 'KnifeSilent') { e.Replacement = 'MeleeKnifeAmmo'; return; }
		if (e.Replacee is 'Shovel') { e.Replacement = 'MeleeShovel'; return; }
		for (int i = 0; i < 5; ++i)
		{
			if (e.Replacee is classes_to_replace[i])
			{
				if (random(0, 255) < 64) { e.Replacement = 'MeleeKnifeAmmo'; }
				else { e.Replacement = 'Nothing'; }
				return;
			}
		}
		for (int i = 0; i < 26; ++i)
		{
			if (e.Replacee is classes_to_remove[i])
			{
				e.Replacement = 'Nothing';
				return;
			}
		}
	}
}