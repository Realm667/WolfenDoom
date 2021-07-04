/*
 * Copyright (c) 2015-2021 Ed the Bat, Ozymandias81, MaxED, Nash Muhandes,
 *                         AFADoomer, Talon1024
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

class Ammo9mm : Ammo
{
	Default {
	//$Category Ammo (BoA)
	//$Title Ammoclip (x8 clips)
	//$Color 6
	Scale 0.20;
	Tag "9x19mm";
	Inventory.Amount 8;
	Inventory.MaxAmount 256;
	Ammo.BackpackAmount 64;
	Ammo.BackpackMaxAmount 480;
	Inventory.PickupMessage "$9MMAMMO";
	Inventory.Icon "WALT01";
	}
	States
	{
	Spawn:
		MCLP A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class AmmoBox9mm : Ammo9mm
{
	Default {
	//$Category Ammo (BoA)
	//$Title Ammobox (x64 clips)
	//$Color 6
	Inventory.Amount 64;
	Inventory.PickupMessage "$9MMBOX";
	Inventory.Icon "WALT02";
	}
	States
	{
	Spawn:
		MCLP B -1;
		Stop;
	}
}

class Ammo12Gauge : Ammo
{
	Default {
	//$Category Ammo (BoA)
	//$Title Shells (x4 shells)
	//$Color 6
	Scale 0.30;
	Tag "$TAGGAUGE";
	Inventory.PickupMessage "$GAUGAMMO";
	Inventory.Amount 4;
	Inventory.MaxAmount 32;
	Ammo.BackpackAmount 4;
	Ammo.BackpackMaxAmount 64;
	Inventory.Icon "BROW02";
	}
	States
	{
	Spawn:
		SHEL A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class AmmoBox12Gauge : Ammo12Gauge
{
	Default {
	//$Category Ammo (BoA)
	//$Title Shellbox (x16 shells)
	//$Color 6
	Scale 0.25;
	Inventory.Amount 16;
	Inventory.PickupMessage "$GAUGBOX";
	}
	States
	{
	Spawn:
		SBOX A -1;
		Stop;
	}
}


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

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
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

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
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

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
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

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
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