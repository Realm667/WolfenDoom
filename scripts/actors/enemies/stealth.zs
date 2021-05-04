/*
 * Copyright (c) 2017-2020 AFADoomer
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

/*

  Base class for the helper actors that are spawned when a Nazi class
  descendant is flagged as "sneakable". Also handles "perceptive" enemies who
  can see through disguises.

  Developer note: These actors have their statnum set to STAT_DEFAULT - 2
  (used to limit ThinkerIterator performance hit)

  New Functions
	A_LookForNoTargetPlayer()
	- Allows enemies to "see through" player disguises, essentially by having
	  those enemies ignore the NOTARGET flag when looking for their target, then
	  alerting the actor once the player has been in sight for more than the
	  specified modder-configured threshold  (See Nazi class declaration).
	- Threshold increments more quickly the closer the player is the the actor
	- Used in-game for Gestapo agents who can see through player disguises.
	- This should not be called directly; it is configured via Nazi class
	  Properties and called automatically by the sneakableeyes actors.

*/
class StealthBase : Actor
{
	Actor alert;
	Inventory vis;
	LookExParams SearchParams;
	double sighttime;
	int fov;
	int playernum;
	int threshold;

	Default
	{
		Height 46;
		Species "Eyes";
		+NEVERTARGET
		+NOCLIP
		+NOGRAVITY
		RenderStyle "None";
	}

	override void BeginPlay()
	{
		ChangeStatNum(Thinker.STAT_DEFAULT - 2); // Change the statnum of these actors so that ThinkerIterators can look at just this statnum and be more efficient
		if (master) { species = master.species; }
	}

	state A_LookForNoTargetPlayer(double Range = 256.0)
	{
		if (master && master is "Nazi") // Get the master actor's perceptionfov and perceptiontime properties
		{ // These become the fov parameter for visibility checks and the time threshold for how long the player must stay in view before detection
			fov = Nazi(master).perceptionfov;
			threshold = Nazi(master).user_perceptiontime;
		}

		if (threshold <= 0 || fov <= 0) { return ResolveState(null); } // If threshold is 0, the actor can't see through NOTARGET at all, so just return

		if (target != goal) { target = null; } // Clear target, just in case, but only if it's not a patrolpoint or other goal

		// Set up view parameters for this search
		SearchParams.fov = fov;
		SearchParams.minDist = 32;
		SearchParams.maxDist = Range;
		SearchParams.maxHearDist = Range;

		for (int p = 0; p < MAXPLAYERS; p++) // Iterate through all of the players and find one that's in range
		{
			Actor mo = players[p].mo;

			if (mo) {
				if (!mo.bShootable || mo.health <= 0) { continue; }
				if (isFriend(mo)) { continue; }

				double dist = Distance3D(mo);
				if (Range && dist > Range) { continue; }
				if (!IsVisible(mo, false, SearchParams)) { continue; }

				let disguise = mo.FindInventory("DisguiseToken", True);
				if (!disguise) { continue; }

				if (target && dist > Distance3d(target)) { continue; } // get the closest player

				target = mo;
				playernum = p;
			}
		}

		if (target) { vis = players[playernum].mo.FindInventory("BoAVisibility"); }

		if (target && vis && playernum >= 0 && CheckSight(target)) // If we have a player in view
		{
			double distWeight = 1.5;
			double speedWeight = .25;
			double velmod = max(1, target.vel.length() / 4) - 1;
			// Console.Printf("velmod %.3f", velmod);

			// Increment sight time counter, scaled to how far away player is and how fast he's moving. Once the sight time counter reaches full, become alerted.
			sighttime += (((Range - Distance3d(target)) / Range) * distWeight + velmod * speedWeight ) * min(1.0, 0.25 * (skill + 1));

			if (master && !alert)
			{  // Spawn the alert indicator
				alert = Spawn("AlertMarkerAlpha", (master.pos.x, master.pos.y, master.pos.z + 64));
				if (alert) { alert.master = master; }
			}

			if (sighttime >= threshold) // If 'threshold' amount of time has elapsed since player first seen
			{
				sighttime = 0; // Reset the count

				BoAVisibility(vis).visibility = 200;
				BoAVisibility(vis).suspicion = 0; // Clear the player's suspicion variable

				players[playernum].cheats &= ~CF_NOTARGET;  // Turn off the player's NOTARGET
				if (alert) { alert.Destroy(); } // Get rid of the alert indicator that was spawned here

				if (Nazi(master) && !master.bDormant) { Nazi(master).BecomeAlerted(target); }
			}
			else if (sighttime >= threshold / 4) // Otherwise, start looking at the currently targeted player
			{
				if (master) { master.A_Face(target, 0.25); } // (slowly...)
			}
		}
		else // If all players are out of sight...
		{
			sighttime > 0 ? sighttime -= 0.05 : 0;  // ...decrement the amount of time elapsed gradually to 0

			if (sighttime <= 0 && playernum > -1) // Once fully out of sight and 'forgotten', restore NOTARGET flag if the player has a disguise (added check since default for playernum is 0)
			{
				DisguiseToken disguise = DisguiseToken(players[playernum].mo.FindInventory("DisguiseToken", True));

				if (disguise && disguise.bNoTarget && !players[playernum].mo.FindInventory("DisguiseFailToken", True)) { players[playernum].cheats |= CF_NOTARGET; }
				playernum = -1;
			}
		}

		if (alert) {
			if (sighttime <= 0) { alert.SetStateLabel("Fade"); } // If we've completely lost sight of the player, fade out the alert indicator
			else // Otherwise, set the alpha and scale to correspond to sight time
			{
				alert.alpha = double(sighttime) / threshold;
				alert.scale.x = alert.scale.y = 1 + alert.alpha; // End scale is 2.0 to match the standard alert marker
			}
		}

		// Write the suspicion level to the player's suspicion variable so that it can be used on the hud
		if (vis) { BoAVisibility(vis).suspicion = int(sighttime * 100 / threshold); }

		return ResolveState(null);
	}

	bool TargetIsHidden()
	{
		Inventory vis = target.FindInventory("BoAVisibility");
		if (vis)
		{
			if (BoAVisibility(vis).alertedcount > 0) { return false; }
			if (BoAVisibility(vis).visibility  >= 100) { return false; }
		} else { return false; }

		return true;
	}

	override void Tick()
	{
		if (!master) { Destroy(); return; }

		SetXYZ(master.pos + (0, 0, height));
		angle = master.angle;

		Super.Tick();
	}
}

// Basic alert marker
class AlertMarker : Actor
{
	Default
	{
		Species "AlertMarker";
		Scale 2.0;
		+BRIGHT
		+NOGRAVITY
		+NOINTERACTION
	}

	States
	{
		Spawn:
			EXCL C 1 NODELAY A_StartSound("misc/alert", CHAN_BODY);
			Goto Fade;
		Fade:
			EXCL C 1 {
				A_Warp(AAPTR_MASTER, 0, 0, 28 + (master && master.bBoss) ? 84 : 64);
				A_FadeOut(0.01);
			}
			Loop;
	}
}

// Version of the alert marker that starts out fully translucent (alpha 0)
class AlertMarkerAlpha : AlertMarker
{
	Default
	{
		Scale 1.0;
		Renderstyle "Translucent";
		Alpha 0;
	}

	States
	{
		Spawn:
			EXCL C 1 A_Warp(AAPTR_MASTER, 0, 0, 28 + (master && master.bBoss) ? 84 : 64);
			Loop;
	}
}

// This actor follows SneakableGuard around looking for players
class SneakableGuardEyesIdle : StealthBase
{
	int idlesounddelay;

	States
	{
		Spawn:
			TNT1 A 1 A_SneakableLook();
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		idlesounddelay = Random(35, 700); // Set initial quote countdown time to 1 - 20 seconds so that they all don't start talking at once

		if (master && (!master.target || (master.target && master.target != master.goal)))
		{
			if (!Base(master) || Base(master).loiterdistance <= 0)
			{
				master.A_ClearTarget();
				if (!InStateSequence(master.CurState, master.SpawnState)) { master.SetState(master.SpawnState); }
			}
		}
	}

	void A_SneakableLook()
	{
		if (!master || master.bDormant) { return; }

		double closerange = 160.0;
		double closeFOV = 120.0;
		double farrange = 1024.0;
		double farFOV = 65.0;

		if (LastHeard && LastHeard is "PlayerPawn")
		{
			target = LastHeard;
			if (Nazi(master) && !master.bDormant) { Nazi(master).BecomeAlerted(target); }

			LastHeard = null;
		}
		else if (Nazi(master)) { Nazi(master).alerted = false; }

		A_LookEx(LOF_NOJUMP, 0.0, closerange, 256.0, closefov); // Wider FOV sight check for short-range

		if (!target || target == master) { A_LookEx(LOF_NOJUMP, 0.0, farrange, 256.0, master.bLookAllAround ? 360.0 : farFOV); }

		if (!target || target == master || playernum > -1)
		{
			if (Nazi(master)) { A_LookForNoTargetPlayer(Nazi(master).perceptiondistance); }
			else { A_LookForNoTargetPlayer(); }
		}

		if (!target || target == master)
		{
			// Check via CheckSight in order to "see through" double-sided walls (windows)
			for (int p = 0; p < MAXPLAYERS; p++) // Iterate through all of the players and see if any are in sight
			{
				if (players[p].cheats & CF_NOTARGET) { continue; }

				Actor mo = players[p].mo;
	
				if (mo) {
					if (Distance3d(mo) > (closerange + farrange) / 2) { continue; } // Meet in the middle of the short/close ranges above
					if (abs(deltaangle(angle, AngleTo(mo))) > farfov / 2) { continue; } // Use the far FOV
					if (!CheckSight(mo, SF_SEEPASTBLOCKEVERYTHING | SF_SEEPASTSHOOTABLELINES)) { continue; }

					target = mo;
				}
			}
		}

		if (target && target != master)
		{
			int dist = int(Distance3D(target) - master.radius - target.radius);
			int checkdist;

			if (Nazi(master)) { checkdist = Nazi(master).sneakableclosesightradius; }
			else { checkdist = 64; }

			Inventory vis = target.FindInventory("BoAVisibility");

			if (vis)
			{
				// If player gets within the "close visibility" range, extravisibility
				// value jumps in proportion with distance
				if (dist < checkdist)
				{
					BoAVisibility(vis).extravisibility = max((checkdist - dist) * 2, BoAVisibility(vis).extravisibility);
				}

				// If in direct enemy line of sight, increment the extravisibility amount 
				// over time (so that you can't just stand there in front of them)
				// This really only has an effect when a lot of enemies have you in sight
				// all at the same time, otherwise the increments are too small to matter.
				BoAVisibility(vis).extravisibility += 2.5 + 0.05 * skill;
			}

			if (TargetIsHidden())
			{
				A_ClearTarget();
			}
			else if (!threshold) // If there's a sight threshold, wait for that code to alert the actor
			{
				if (Nazi(master) && !master.bDormant) { Nazi(master).BecomeAlerted(target); }
			}
		}
		else if (!master.bBoss && !idlesounddelay)
		{
			if (Nazi(master))
			{
				if (Nazi(master).idlesound) { master.A_StartSound(Nazi(master).idlesound, CHAN_VOICE); }
			}
			else { master.A_StartSound("axis1/idle", CHAN_VOICE); }

			idlesounddelay = Random(490, 630); // Set quote countdown time to 14 - 18 seconds
		}
	}

	override void Tick()
	{
		Super.Tick();

		if (idlesounddelay > 0) { idlesounddelay--; }
	}
}

// This actor follows SneakableGuard around checking if players are no longer seen
class SneakableGuardEyesAlerted : StealthBase
{
	int timeout;
	int lostsounddelay;

	States
	{
		Spawn:
			TNT1 A 1 A_SneakableSearch();
			Loop;
	}

	override void PostBeginPlay()
	{
		ResetTimers();

		Super.PostBeginPlay();
	}

	void ResetTimers(bool chatteronly = false)
	{
		if (!chatteronly) { timeout = Random(280, 350); }
		lostsounddelay = Random(140, 210);
	}

	void A_SneakableSearch()
	{
		if (!master) { return; }

		A_LookEx(LOF_NOJUMP, 0.0, 1024.0, 256.0, 65.0);

		if (target)
		{
			A_ClearTarget();
			ResetTimers();
		}
		else if (timeout == 0)
		{
			if (master && Nazi(master)) { Nazi(master).BecomeIdle(); }

			Destroy();
 		}
		else if (lostsounddelay == 0)
		{
			if (master && !master.bBoss)
			{
				if (Nazi(master))
				{
					if (Nazi(master).lostsound) { master.A_StartSound(Nazi(master).lostsound, CHAN_VOICE); }
				}
				else { master.A_StartSound("axis1/target_not_seen", CHAN_VOICE); }
			}

			ResetTimers(true);
		}
	}

	override void Tick()
	{
		Super.Tick();

		if (timeout > 0) { timeout--; }
		if (lostsounddelay > 0) { lostsounddelay--; }
	}
}

// Give this to the player to make his disguise fail. Useful for making the player visible in certain locations while keeping the sprite. For example, inside the train station on C3M1.
class DisguiseFailToken : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
	}

	override void DoEffect()
	{
		DisguiseToken disguise = DisguiseToken(owner.FindInventory("DisguiseToken", true));

		if (disguise) { disguise.notargettimeout = level.time; } // Set disguise to immediately fail every tick
	}
}