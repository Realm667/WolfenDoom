/*
 * Copyright (c) 2018-2020 AFADoomer
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

class BoAVisibility : CustomInventory
{
	double extravisibility;
	double visibility;
	double fogfactor;
	int lightlevel;
	int noiselevel;
	int alertedcount;
	double suspicion;
	int timeout;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
	}

	void DoVisibility()
	{
		[lightlevel, fogfactor] = ZScriptTools.GetLightLevel(owner.CurSector);

		if (lightlevel + extravisibility > 64)
		{
			double movespeed = Owner.vel.Length() * Owner.vel.Length();
			double viewheightmod = Owner.player.crouchfactor * Owner.height - (Owner.height / 2);

			if (movespeed > 0)
			{
				if (movespeed < viewheightmod) { movespeed = viewheightmod; }
				viewheightmod = 0;
			}

			visibility = Clamp(int(lightlevel * 0.35 + movespeed + noiselevel * 0.9 + extravisibility + viewheightmod - ((3 - skill) * 10)), 0, 100);
		} else { visibility = 0; }

		noiselevel = Max(0, noiselevel - 6);
		extravisibility = Max(0, extravisibility - 5);
	}

	void CountAlertedSneakables()
	{
		ThinkerIterator it = ThinkerIterator.Create("SneakableGuardEyesAlerted", Thinker.STAT_DEFAULT - 2);
		SneakableGuardEyesAlerted mo;

		int count = 0;
		while (mo = SneakableGuardEyesAlerted(it.Next())) { count++; }

		it = ThinkerIterator.Create("Nazi", Thinker.STAT_DEFAULT);
		Nazi nmo;

		while (nmo = Nazi(it.Next()))
		{
			if (
				!nmo.user_sneakable &&
				nmo.health > 0 &&
				nmo.bShootable &&
				nmo.user_incombat &&
				nmo.target &&
				nmo.target == Owner &&
				(nmo.CheckSight(Owner) || Owner.Distance3d(nmo) < 256) &&
				!(nmo is "Rottweiler") // Don't count dogs as alerted, so if just dogs are alerted, you're still stealthy
			) { count++; }
		}

		alertedcount = count;
	}

	bool CheckVisibility(Actor mo)
	{
		if (fogfactor && visibility + extravisibility < (mo.Distance3D(owner) / (fogfactor * 0.5)))
		{
			if (Nazi(mo)) { Nazi(mo).bChaseOnly = true; }
			else { mo.target = null; }

			return false;
		}

		if (Nazi(mo)) { Nazi(mo).bChaseOnly = false; }

		return true;
	}

	override void Tick(void)
	{
		if (Owner && Owner is "PlayerPawn")
		{
			if (timeout <= 0)
			{
				timeout = 35; // Only do this once a second
				CountAlertedSneakables();

			}
			timeout--;

			DoVisibility();
		}

		Super.Tick();
	}

	States
	{
		Use:
			TNT1 A 0;
			Fail;
		Pickup:
			TNT1 A 0
			{
				return true;
			}
			Stop;
	}
}