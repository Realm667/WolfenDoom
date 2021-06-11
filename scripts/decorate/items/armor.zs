/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, Talon1024
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

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", saveamount));

		return msg;
	}
}