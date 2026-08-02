
class EfficientReplaceHandler: EventHandler
{
	static const Name classes_to_replace[] = {'Ammo9mm', 'AmmoBox9mm', 'Ammo12Gauge', 'AmmoBox12Gauge', 'MauserAmmo',
		'MauserAmmoBox', 'FlameAmmo', 'NebAmmo', 'NebAmmoBox', 'PanzerAmmo', 'TeslaCell', 'TeslaCellBox', 'AstroShotgunShell',
		'AstroRocketAmmo', 'AstroClipAmmo', 'Medikit_Small', 'Medikit_Medium', 'Medikit_Large', 'AstroMedikit'};
	override void CheckReplacement(ReplaceEvent e)
	{
		for (int i = 0; i < 19; ++i)
		{
			if (e.Replacee == classes_to_replace[i])
			{
				e.Replacement = "Efficient"..classes_to_replace[i];
				return;
			}
		}
	}
}