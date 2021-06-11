/*
 * Copyright (c) 2018-2020 Kevin Caccamo
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

class VitalitySerum : Inventory
{
	int Boost;
	Property Boost:Boost;

	Default
	{
		//$Category Health (BoA)
		//$Title Vitality Serum (max+5)
		//$Color 6
		Radius 20;
		Scale 0.45;
		Inventory.MaxAmount 10;
		Inventory.PickupMessage "$SERUM";
		VitalitySerum.Boost 5;
		+INVENTORY.IGNORESKILL
		+INVENTORY.UNDROPPABLE
		+INVENTORY.ISHEALTH
	}

	States
	{
	Spawn:
		VSRM ABC 6;
		Loop;
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (Super.TryPickup(toucher))
		{
			toucher.Stamina += Boost * Amount;
			toucher.GiveBody(Boost * Amount);
			return true;
		}
		return false;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", boost * amount));

		return msg;
	}
}

class VitalitySerum175: VitalitySerum { // Chapter 2
	default {
		Inventory.MaxAmount 15;
	}
}

class VitalitySerum200: VitalitySerum { // Chapter 3
	default {
		Inventory.MaxAmount 20;
	}
}