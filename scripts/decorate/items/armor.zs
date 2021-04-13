class FlakJacket : BasicArmorPickup
{
	Default
	{
		//$Category Items (BoA)
		//$Title Flak Jacket (Green Armor, +100)
		//$Color 1
		Scale 0.5;
		Inventory.Pickupmessage "$JACKET";
		Inventory.Icon "armh03";
		Inventory.PickupSound "misc/armor_body";
		Armor.SavePercent 33;
		Armor.SaveAmount 100;
	}
	States
	{
	Spawn:
		ARM3 A -1;
		Stop;
	}
}

class HeavyArmor : BasicArmorPickup
{
	Default
	{
		//$Category Items (BoA)
		//$Title Heavy Armor (Blue Armor, +200)
		//$Color 1
		Scale 0.45;
		Inventory.Pickupmessage "$HEAVY";
		Inventory.Icon "armh04";
		Inventory.PickupSound "misc/armor_body";
		Armor.SavePercent 50;
		Armor.SaveAmount 200;
	}
	States
	{
	Spawn:
		ARM4 A -1;
		Stop;
	}
}

class LeatherJacket : BasicArmorPickup
{
	Default
	{
		//$Category Items (BoA)
		//$Title Leather Jacket (Half Green Armor, +50)
		//$Color 1
		Scale 0.45;
		Inventory.Pickupmessage "$LEATHER";
		Inventory.Icon "armh02";
		Inventory.PickupSound "misc/armor_body";
		Armor.SavePercent 25;
		Armor.SaveAmount 50;
	}
	States
	{
	Spawn:
		ARM2 A -1;
		Stop;
	}
}

class Stahlhelm : BasicArmorBonus
{
	Default
	{
		//$Category Items (BoA)
		//$Title Steel Helmet (Armor Bonus, +5)
		//$Color 1
		Radius 8;
		Height 16;
		Scale 0.5;
		Inventory.PickupMessage "$HELMSS";
		Inventory.Icon "armh01";
		Inventory.PickupSound "misc/armor_head";
		Armor.SavePercent 33;
		Armor.SaveAmount 5;
		Armor.MaxSaveAmount 100;
		-INVENTORY.ALWAYSPICKUP
	}
	States
	{
	Spawn:
		STAL A -1;
		Stop;
	}
}