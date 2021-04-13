class KeyBase : Key
{
	Default
	{
		//$Category Keys (BoA)
		//$Color 13
		Scale 0.07;
	}
}

class BoABlueKey : KeyBase
{
	Default
	{
		//$Title Blue Key (Number 2)
		Inventory.PickupMessage "$GOTBLUEKEY";
		Inventory.Icon "STKEYS0";
	}
	States
	{
	Spawn:
		BKEY A 10;
		"####" A 10 LIGHT("BOABKEY2");
		Loop;
	}
}

class BoAYellowKey : KeyBase
{
	Default
	{
		//$Title Yellow Key (Number 3)
		Inventory.PickupMessage "$GOTYELLOWKEY";
		Inventory.Icon "STKEYS1";
	}
	States
	{
	Spawn:
		YKEY A 10;
		"####" A 10 LIGHT("BOAYKEY");
		Loop;
	}
}

class BoARedKey : KeyBase
{
	Default
	{
		//$Title Red Key (Number 1)
		Inventory.PickupMessage "$GOTREDKEY";
		Inventory.Icon "STKEYS2";
	}
	States
	{
	Spawn:
		RKEY A 10;
		"####" A 10 LIGHT("BOARKEY");
		Loop;
	}
}

class BoAGreenKey : KeyBase
{
	Default
	{
		//$Title Green Key (Number 5)
		Inventory.PickupMessage "$GOTGREENKEY";
		Inventory.Icon "STKEYS3";
	}
	States
	{
	Spawn:
		GSKU A 10;
		"####" A 10 LIGHT("BOAGKEY");
		Loop;
	}
}

class BoAPurpleKey : KeyBase
{
	Default
	{
		//$Title Purple Key (Number 6)
		Inventory.PickupMessage "$GOTPURPLEKEY";
		Inventory.Icon "STKEYS4";
	}
	States
	{
	Spawn:
		PSKU A 10;
		"####" A 10 LIGHT("BOAPKEY");
		Loop;
	}
}

class BoACyanKey : KeyBase
{
	Default
	{
		//$Title Cyan Key (Number 4)
		Inventory.PickupMessage "$GOTCYANKEY";
		Inventory.Icon "STKEYS5";
	}
	States
	{
	Spawn:
		CSKU A 10;
		"####" A 10 LIGHT("BOACKEY");
		Loop;
	}
}

class SkullKey : CompassItem
{
	Default
	{
		//$Category Keys (BoA)
		//$Title Occult Skull Key (Puzzle 4)
		//$Color 13
		Scale 0.17;
		PuzzleItem.Number 4;
		Inventory.MaxAmount 2;
		Inventory.Icon "SKLKB0";
		Inventory.PickupSound "key/skullkey";
		PuzzleItem.FailMessage "$SKULLF";
		Inventory.PickupMessage "$SKULLP";
		-FLOATBOB
		-NOGRAVITY
	}
	States
	{
	Spawn:
		SKLK A -1;
		Stop;
	}
}

//Special items - no DeNums
class SurrenderingSoldierKey: SkullKey //was SpyToken, pickup msg not needed
{
	Default
	{
		//$Title Surrendering Soldier Cache Key (puzzle 5, given by him)
		Inventory.Icon "SKLKF0";
		Inventory.MaxAmount 1;
		PuzzleItem.Number 5;
	}
    States
	{
	Spawn:
		SKLK E -1;
		Stop;
	}
}

class SkullKeyForSale : SkullKey //C3M6_A
{
	Default
	{
		//$Category Keys (BoA)
		//$Title Occult Skull Key from C3M6_A (puzzle 6, for sale)
		//$Color 13
		Inventory.MaxAmount 1;
		Inventory.Icon "SKLKD0";
		PuzzleItem.Number 6;
	}
	States
	{
	Spawn:
		SKLK C -1;
		Stop;
	}
}