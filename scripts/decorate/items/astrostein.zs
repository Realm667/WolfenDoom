/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, Talon1024,
 *                         AFADoomer
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

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", saveamount));

		return msg;
	}
}
