/*
 * Copyright (c) 2019-2020 AFADoomer, Talon1024
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

class GrenadeBase : Actor // Base actor for anything we want Nazis to run away from as soon as they see it (e.g., grenades...)
{
	mixin SpawnsGroundSplash;

	int feardistance;
	bool hasHitEnemy;
	String iconname;
	int grenadeflags;

	Property FearDistance: feardistance;
	Property Icon:iconname;

	FlagDef DRAWINDICATOR:grenadeflags, 0;

	Default
	{
		GrenadeBase.FearDistance 256;
	}

	override void BeginPlay()
	{
		ChangeStatNum(Thinker.STAT_DEFAULT - 6); // Give these their own statnum for performance reasons with enemy grenade avoidance
		Super.BeginPlay();
	}

	override void PostBeginPlay()
	{
		hasHitEnemy = false;
		Super.PostBeginPlay();
	}

	override int SpecialMissileHit(Actor victim)
	{
		if (victim != target && victim.bSolid && victim.bShootable)
		{
			hasHitEnemy = true;
		}
		return Super.SpecialMissileHit(victim);
	}

	void A_SkipIfHit()
	{
		// Different than A_Countdown because it modifies the current state's duration
		if (hasHitEnemy)
		{
			SetState(CurState.NextState);
		}
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (bTouchy && (other is "PlayerFollower" || other.bInvulnerable || other.bNoDamage)) { return false; } // Player followers and invulnerable actors can't set off touchy variants of these (Mines)

		return true;
	}
}

// Fixes for Astrostein grenades:
// Allow cheat "give AstroGrenadePickup" to give more than one grenade and token
class AstroGrenadePickup : Inventory
{
	Default
	{
		//$Category Astrostein (BoA)/Weapons
		//$Title Grenade (Astrostein)
		//$Color 14
		Inventory.PickupMessage "$GRENADE";
		Inventory.PickupSound "grenade/pickup";
		Inventory.MaxAmount 2147483647; // This item is just a proxy for GrenadePickup and AstroGrenadeToken
		Scale 0.25;
	}

	States
	{
	Spawn:
		ASGN A -1 Light("ASTRAMM1");
		Stop;
	}

	override bool TryPickup(in out Actor toucher)
	{
		Inventory grenade = toucher.FindInventory("GrenadePickup");
		if (!grenade || grenade.Amount < grenade.MaxAmount)
		{
			toucher.GiveInventory("GrenadePickup", Amount);
			toucher.GiveInventory("AstroGrenadeToken", Amount);
			GoAwayAndDie();
			return true;
		}
		return false;
	}
}

// Fix for grenades: only allow player to throw one per second
class IntervalUseItem : CustomInventory
{
	override bool Use(bool pickup)
	{
		if (ReactionTime == 0)
		{
			ReactionTime = Default.ReactionTime;
			return Super.Use(pickup);
		}
		return false;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if (ReactionTime > 0)
		{
			ReactionTime--;
		}
	}
}