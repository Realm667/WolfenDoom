/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, yqco, Talon1024,
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
// See ZScript for CoinItem class - Talon1024
class SingleCoin : CoinItem
{
	Default
	{
		//$Category Pickups (BoA)/Treasures
		//$Title Treasure (Coin, 1pts)
		//$Color 17
		Scale 0.5;
		Inventory.Amount 1;
		Inventory.PickupMessage "$COIN";
		Inventory.PickupSound "treasure/pickup";
	}
	States
	{
	Spawn:
		ONEC A -1 LIGHT("COINLITE");
		Stop;
	}
}

class BagOfCoins : SingleCoin
{
	Default
	{
		//$Title Treasure (Coin Bag, 10pts)
		Inventory.PickupMessage "$COINSBAG";
		Inventory.Amount 10;
	}
	States
	{
	Spawn:
		BAGC A -1 LIGHT("BAGCLITE");
		Stop;
	}
}

class CoinBagDrop : CoinDrop
{
	Default
	{
		//$Title Treasure (Coin Bag, 10pts)
		Inventory.PickupMessage "$COINSBAG";
		Inventory.Amount 10;
	}
	States
	{
	Spawn:
		BAGC A -1 LIGHT("BAGCLITE");
		Stop;
	}
}

class TreasureChest : SingleCoin
{
	Default
	{
		//$Title Treasure (Chest, 50pts)
		Inventory.PickupMessage "$CHEST";
		Inventory.Amount 50;
		Inventory.PickupSound "treasure/chest";
	}
	States
	{
	Spawn:
		TREA B -1 LIGHT("TRESLITE");
		Stop;
	}
}

class TreasureChest2 : SingleCoin
{
	Default
	{
		//$Title Treasure (Large Chest, 100pts)
		Scale 1.0;
		Inventory.PickupMessage "$CHESTBIG";
		Inventory.Amount 100;
		Inventory.PickupSound "treasure/chest";
	}
	States
	{
	Spawn:
		TREA C -1 LIGHT("BIGCLITE");
		Stop;
	}
}

class TreasureChest3 : SingleCoin
{
	Default
	{
		//$Title Treasure (Chest, 25pts)
		Inventory.PickupMessage "$CHESTSML";
		Inventory.Amount 25;
		Inventory.PickupSound "treasure/chest";
	}
	States
	{
	Spawn:
		TREA E -1 LIGHT("TRESLITE");
		Stop;
	}
}

class TreasureCross : SingleCoin
{
	Default
	{
		//$Title Treasure (Cross, 15pts)
		Inventory.PickupMessage "$CROSS";
		Inventory.Amount 15;
		Inventory.PickupSound "treasure/cross";
	}
	States
	{
	Spawn:
		TREA F -1 LIGHT("COINLITE");
		Stop;
	}
}

class CrossDrop : CoinDrop
{
	Default
	{
		//$Title Treasure (Cross, 15pts)
		Inventory.PickupMessage "$CROSS";
		Inventory.Amount 15;
		Inventory.PickupSound "treasure/cross";
	}
	States
	{
	Spawn:
		TREA F -1 LIGHT("COINLITE");
		Stop;
	}
}

class Goblet : SingleCoin
{
	Default
	{
		//$Title Treasure (Goblet, 15pts)
		Inventory.PickupMessage "$CHALICE";
		Inventory.Amount 15;
		Inventory.PickupSound "treasure/cup";
	}
	States
	{
	Spawn:
		TREA G -1 LIGHT("TRESLITE");
		Stop;
	}
}

class GobletDrop : CrossDrop
{
	Default
	{
		//$Title Treasure (Goblet, 15pts)
		Inventory.PickupMessage "$CHALICE";
		Inventory.PickupSound "treasure/cup";
	}
	States
	{
	Spawn:
		TREA G -1 LIGHT("TRESLITE");
		Stop;
	}
}

class TreasureCrown : SingleCoin
{
	Default
	{
		//$Title Treasure (Crown, 20pts)
		Inventory.PickupMessage "$CROWN";
		Inventory.Amount 20;
		Inventory.PickupSound "treasure/crown";
	}
	States
	{
	Spawn:
		TREA D -1 LIGHT("BAGCLITE");
		Stop;
	}
}

class CrownDrop : CoinDrop
{
	Default
	{
		//$Title Treasure (Crown, 20pts)
		Inventory.PickupMessage "$CROWN";
		Inventory.Amount 20;
		Inventory.PickupSound "treasure/crown";
	}
	States
	{
	Spawn:
		TREA D -1 LIGHT("BAGCLITE");
		Stop;
	}
}

class GoldBar : SingleCoin
{
	Default
	{
		//$Title Treasure (Gold Bar, 20pts)
		Scale 0.7;
		Inventory.PickupMessage "$GOLDBAR";
		Inventory.Amount 20;
		Inventory.PickupSound "treasure/crown";
	}
	States
	{
	Spawn:
		TREA A -1 LIGHT("TRESLITE");
		Stop;
	}
}

class Award : SingleCoin
{
	int number;

	Property Number:number;

	Default
	{
		Scale 0.12;
		Inventory.Amount 10;
		Inventory.PickupSound "treasure/chest";
	}

	override bool TryPickup (in out Actor toucher)
	{
		bool ret = Super.TryPickup(toucher);

		if (ret && toucher && toucher.player)
		{
			AchievementTracker tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
			if (tracker) { tracker.SetBit(tracker.records[tracker.STAT_AWARDS].value, number); }
			
			AchievementTracker.CheckAchievement(toucher.PlayerNumber(), AchievementTracker.ACH_TROPHYHUNTER);
		}

		return ret;
	}
}

class Naziward : Award
{
	Default
	{
		//$Title Treasure (Easteregg, Naziward, 10pts)
		Scale 0.2;
		Inventory.PickupMessage "$GOLDWRD";
		Inventory.PickupSound "treasure/cup";
		Award.Number 2;
	}

	States
	{
		Spawn:
			NZWR A -1 LIGHT("TRESLITE");
			Stop;
	}
}

class Cacoward : Award
{
	Default
	{
		//$Title Treasure (Easteregg, Cacoward, 10pts)
		Inventory.PickupMessage "$CACOWARD";
		Award.Number 1;
	}

	States
	{
		Spawn:
			CACW A -1 LIGHT("TRESLITE");
			Stop;
	}
}

class Keenaward : Award
{
	Default
	{
		//$Title Treasure (Easteregg, Keenaward, 10pts)
		Inventory.PickupMessage "$KEENAWARD";
		Award.Number 0;
	}

	States
	{
		Spawn:
			CKWR A -1 LIGHT("TRESLITE");
			Stop;
	}
}

class GraalHoly : FakeCoinItem
{
	Default
	{
		//$Category EasterEgg (BoA)
		//$Title Treasure (Easteregg, Holy Graal, 15pts)
		Inventory.PickupMessage "$GRAAL1";
		Inventory.Amount 15;
		Inventory.PickupSound "treasure/cup";
	}
	States
	{
	Spawn:
		GRAL A -1 LIGHT("TRESLITE");
		Stop;
	}
}

class GraalHelm : SingleCoin
{
	Default
	{
		//$Category EasterEgg (BoA)
		//$Title Treasure (Easteregg, Graal Helm, 1pts)
		Inventory.PickupMessage "$GRAAL2";
		Inventory.Amount 1;
		Inventory.PickupSound "treasure/crown";
		Scale 0.65;
	}
	States
	{
	Spawn:
		GRAL B -1 LIGHT("TRESLITE");
		Stop;
	}
}

class ChestKey : CompassItem
{
	Default
	{
		//$Category Pickups (BoA)/Treasures
		//$Title Treasure Chest Key
		//$Color 17
		Scale 0.5;
		Tag "$TAGCHEST";
		Inventory.Icon "I_SPBKEY";
		Inventory.PickupMessage "$CHESTKEY";
		Inventory.PickupSound "misc/k_pkup";
		Inventory.UseSound "supplychest/open";
		Inventory.MaxAmount 3;
	}
	States
	{
	Spawn:
		SBKY A -1 LIGHT("TRESLITE");
		Stop;
	}
}