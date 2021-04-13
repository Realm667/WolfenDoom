class MauserAmmo : Ammo
{
	Default
	{
	//$Category Ammo (BoA)
	//$Title Clip (x5 clips)
	//$Color 6
	Scale 0.3;
	Tag "7.92x57mm";
	Inventory.Amount 5;
	Inventory.MaxAmount 40;
	Ammo.BackpackAmount 5;
	Ammo.BackpackMaxAmount 100;
	Inventory.PickupMessage "$MAUSAMMO";
	Inventory.Icon "MAUS02";
	}
	States
	{
	Spawn:
		792A A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class MauserAmmoBox : MauserAmmo
{
	Default
	{
	//$Category Ammo (BoA)
	//$Title Clipbox (x20 clips)
	//$Color 6
	Scale 0.5;
	Inventory.Amount 20;
	Inventory.PickupMessage "$MAUSBOX";
	}
	States
	{
	Spawn:
		792A B -1;
		Stop;
	}
}

class FlameAmmo : Ammo
{
	Default
	{
	//$Category Ammo (BoA)
	//$Title Gas (x25 cans)
	//$Color 6
	Tag "$TAGPETRO";
	Inventory.PickupMessage "$FLAMAMMO";
	Inventory.Amount 25;
	Inventory.MaxAmount 175;
	Ammo.BackpackAmount 25;
	Ammo.BackpackMaxAmount 350;
	Scale .5;
	Inventory.Icon "FLAM01";
	}
	States
	{
	Spawn:
		FAMO A -1;
		Stop;
	}
}

class NebAmmo : Ammo
{
	Default
	{
	//$Category Ammo (BoA)
	//$Title Nebelrounds (x5 rounds)
	//$Color 6
	Scale 0.47;
	Tag "$TAGMINIR";
	Inventory.Amount 5;
	Inventory.MaxAmount 100;
	Ammo.BackpackAmount 10;
	Ammo.BackpackMaxAmount 150;
	Inventory.PickupMessage "$NEBWAMMO";
	Inventory.Icon "NEBE01";
	}
	States
	{
	Spawn:
		MNRB A -1;
		Stop;
	}
}

class NebAmmoBox : NebAmmo
{
	Default
	{
	//$Category Ammo (BoA)
	//$Title Nebelbox (x10 rounds)
	//$Color 6
	Scale 0.63;
	Inventory.Amount 10;
	Inventory.PickupMessage "$NEBWBOX";
	}
	States
	{
	Spawn:
		MNRB B -1;
		Stop;
	}
}

class PanzerAmmo : Ammo
{
	Default
	{
	//$Category Ammo (BoA)
	//$Title Panzerschreck Rocket (x5 rockets)
	//$Color 6
	Tag "$TAGROCKT";
	Inventory.MaxAmount 5;
	Inventory.PickupMessage "$PANZAMMO";
	Ammo.BackpackAmount 1;
	Ammo.BackpackMaxAmount 10;
	Inventory.Icon "PANZ01";
	Scale .25;
	}
	States
	{
	Spawn:
		PANA A -1;
		Stop;
	}
}

class TeslaCell : Ammo
{
	Default
	{
	//$Category Ammo (BoA)
	//$Title Tesla Cell (x10 cell charges)
	//$Color 6
	Tag "$TAGTCELL";
	Inventory.PickupMessage "$TESLAMMO";
	Inventory.Amount 10;
	Inventory.MaxAmount 200;
	Ammo.BackpackAmount 20;
	Ammo.BackpackMaxAmount 200;
	Inventory.Icon "TESL01";
	}
	States
	{
	Spawn:
		TCEL B -1;
		Stop;
	}
}

class TeslaCellBox : TeslaCell
{
	Default
	{
	//$Title Tesla Cell (x50 cell charges)
	Inventory.Amount 50;
	Inventory.PickupMessage "$TESLABOX";
	}
	States
	{
	Spawn:
		TCEL A -1;
		Stop;
	}
}

class TurretBulletAmmo : Ammo
{
	Default
	{
	Inventory.Amount 1;
	Inventory.MaxAmount 1;
	Inventory.Icon "WALT01";
	}
}

class TurretHeatAmmo : Ammo
{
	Default
	{
	Inventory.Amount 1;
	Inventory.MaxAmount 100;
	Inventory.Icon "HEAT01";
	}
}