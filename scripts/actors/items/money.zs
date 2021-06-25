/*
 * Copyright (c) 2017-2020 Kevin Caccamo, AFADoomer
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

// Can be activated/deactivated and/or set dormant to prevent player from picking it up.
// Inheriting from StackableInventory prevents player from picking it up if player is maxed out on it.
class CoinItem : StackableInventory
{
	Default
	{
		Inventory.MaxAmount 9999;
		Tag "Money";
		+COUNTITEM
		+INVENTORY.UNDROPPABLE
		+INVENTORY.IGNORESKILL
	}

	override void Activate(Actor activator)
	{
		bDormant = false;

		if (Default.bCountItem && !bCountItem)
		{
			level.total_items++;
			bCountItem = true;
		}

		if (Default.bCountSecret && !bCountSecret)
		{
			level.total_secrets++;
			bCountSecret = true;
		}

		Super.Activate(activator);
	}

	override void Deactivate(Actor activator)
	{
		bDormant = true;
		ClearCounters();
		Super.Deactivate(activator);
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		bDormant = SpawnFlags & MTF_DORMANT;
		if (bDormant) { ClearCounters(); }
	}

	override bool CanPickup(Actor toucher)
	{
		if (!bDormant) return Super.CanPickup(toucher);
		return false;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
	
	override bool TryPickup (in out Actor toucher)
	{
		bool ret = Super.TryPickup(toucher);

		if (ret && toucher && toucher.player)
		{
			AchievementTracker achievements = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
			if (achievements)
			{
				achievements.coins[toucher.PlayerNumber()] += Amount;
				AchievementTracker.CheckAchievement(toucher.PlayerNumber(), AchievementTracker.ACH_GOLDDIGGER);
			}
		}

		return ret;
	}
}

class CoinDrop : CoinItem
{
	int time;
	int duration;

	Property Duration:duration;

	Default
	{
		-COUNTITEM
		Scale 0.5;
		Inventory.Amount 1;
		Inventory.PickupMessage "$COIN";
		Inventory.PickupSound "treasure/pickup";
		CoinDrop.Duration -60;
	}

	States
	{
		Spawn:
			ONEC A -1 LIGHT("COINLITE");
			Stop;
	}

	override void Tick()
	{
		if (time++ > ((duration >= 0) ? duration : -duration * 35) && CheckIfSeen()) { Destroy(); } // Disappears if out of sight and duration has elapsed

		Actor.Tick();
	}
}

class FakeCoinItem : CoinItem
{
	Default
	{
		-COUNTITEM
		Scale 0.5;
	}
	override void Tick() //no countitem adjustment --N00b
	{
		Actor.Tick();
	}
}