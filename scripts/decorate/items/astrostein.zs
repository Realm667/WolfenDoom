class AstroMedikit : Medikit
{
	Default
	{
		//$Category Astrostein (BoA)/Health
		//$Title Medikit (modern, +25)
		//$Color 6
		Scale 0.50;
	}
	States
	{
	Spawn:
		MEDI Z -1;
		Stop;
	}
}

class AstroBlueKey : BoABlueKey
{
	Default
	{
		//$Category Astrostein (BoA)/Keys
		//$Title Blue Keycard (Number 2)
		Scale 0.50;
		Inventory.PickupMessage "$GOTBLUEKEY";
		Inventory.Icon "ATKEYS0";
		Species "BoABlueKey";
	}
	States
	{
	Spawn:
		KCBL A 10;
		"####" B 10 LIGHT("BOABKEY");
		Loop;
	}
}

class AstroYellowKey : BoAYellowKey
{
	Default
	{
		//$Category Astrostein (BoA)/Keys
		//$Title Yellow Keycard (Number 3)
		Scale 0.50;
		Inventory.PickupMessage "$GOTYELLOWKEY";
		Inventory.Icon "ATKEYS1";
		Species "BoAYellowKey";
	}
	States
	{
	Spawn:
		KCYE A 10;
		"####" B 10 LIGHT("BOAYKEY");
		Loop;
	}
}

class AstroRedKey : BoARedKey
{
	Default
	{
		//$Category Astrostein (BoA)/Keys
		//$Title Red Keycard (Number 1)
		Scale 0.50;
		Inventory.PickupMessage "$GOTREDKEY";
		Inventory.Icon "ATKEYS2";
		Species "BoARedKey";
	}
	States
	{
	Spawn:
		KCRE A 10;
		"####" B 10 LIGHT("BOARKEY");
		Loop;
	}
}

class ArmorShard : ArmorBonus
{
	Default
	{
		//$Category Astrostein (BoA)/Health
		//$Title Armor Shard (modern, +5)
		//$Color 6
		Inventory.Pickupmessage "$ASHARD";
		Inventory.Icon "armh06";
		Inventory.PickupSound "pickup/armorshard";
		Armor.Saveamount 5;
		-COUNTITEM
	}
	States
	{
	Spawn:
		ARSD ABCDCB 6;
		Loop;
	}
}