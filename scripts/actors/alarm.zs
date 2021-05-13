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

  These actors allow for activatable alarms that alert actors within a 512-unit radius.
  Optionally, alarm activation can trigger spawn of additional enemies.

  Three actors are involved:
    AlarmPanel
	These are usable flatsprite actors that control Alarms and Alarm Spawners that have the
	same TID as the panel.  The Nazi-class descendant actor who is closest to the alarm panel
	(within 1024 units) will be automatically selected as the activator, and, once alerted,
	will automatically walk to the alarm panel and activate it.

	Any actors with the same TID as the Alarm Panel will be set to their 'Active' or 'Inactive'
	state, so any Alarm of Alarm Spawner actors (as well as any other switchable decorations)
	that have the same TID as the panel can be controlled by the panel.

	To silence alarms, the player must manually deactivate the alarm, or the Alarm Panel can
	be deactivated via ACS to set inactive all controlled actors.

	Players can also turn deactivated alarms on...  This would normally be dumb, but might be
	useful for flushing guards into a courtyard away from a key, or something similar.

	Active AlarmPanel actors have a red glow on them.

    Alarm
	These are simple actors that, upon activation, alert all actors within a 512-
	unit radius and set the actors' target to the alarm panel activator's target.

    AlarmSpawner
	These are spawn point actors that spawn up to three SneakableSSMP40Guard actors
	when they are activated.  A maximum of three guards will be present at any time;
	if three guards were spawned and one guard was killed before the alarm was shut
	off, the next time the alarm goes off, only one additional guard will spawn.

	Spawning only occurs when no player can see the spawn point.

	Useful custom properties (set on Custom tab of thing properties in GZDB):
	  user_tid
	    Sets the TID that the spawned enemies are given.  By default they have no TID.

	  user_goal
	    Sets the goal/patrolpoint TID that the spawned enemies will walk to once they return to
	    being idle.  By default, they go back to their spawn point and stand still.

  Alarms and Alarm Spawners must be given the same TID as an Alarm Panel that will control
  them, otherwise they will not function.  You can have multiple Alarm Panels with the same
  TID (e.g., so that the player can turn of alarms from a side office after the alarms are
  turned on by a guard in a main area).

*/
class Alarm : Base
{
	bool active;
	bool activated;
	int looptime;

	Default
	{
		//$Category Misc (BoA)
		-CASTSPRITESHADOW
		+WALLSPRITE
		+ROLLSPRITE
		+NOGRAVITY
		-SOLID
		Height 16;
		Radius 8;
	}

	States
	{
		Spawn:
			ALRM A 35;
		Inactive:
			"####" A 35 { active = false; }
		InactiveLoop:
			"####" A 35;
			Loop;
		Active:
			"####" B 1 { active = true; }
		ActiveLoop:
			"####" AB 1;
			Loop;
	}

	override void Tick()
	{
		Super.Tick();

		if (active)
		{
			if (!activated)
			{
				activated = true;
				A_StartSound("alarm_ring", CHAN_VOICE, CHANF_LOOPING, 1.0);
			}
			if (level.time % 35 == 0) { SoundAlert(target, false, 512); } // Only do the sound alert once a second for performance reasons
		}
		else if (!active && activated)
		{
			activated = false;
			A_StopSound(CHAN_VOICE);
			SoundAlert(null, false, 512);
		}
	}

	override void Activate (Actor activator)
	{
		SetStateLabel("Active");
	}

	override void Deactivate (Actor activator)
	{
		SetStateLabel("Inactive");
	}
}

class AlarmPanel : SwitchableDecoration
{
	bool active;
	Actor activator;
	int counter;
	Actor marker;

	Default
	{
		//$Category Misc (BoA)
		//$Arg0 Script number
		//$Arg0Tooltip Script to call when alarm is activated or deactivated.  Alarm status passed as Arg 1.
		//$Arg0Str Script name
		//$Arg1 IGNORED
		//$Arg1Tooltip DO NOT SET IN EDITOR.  Used to pass the current status of the alarm to the script in Arg 0.  1 = on, 0 = off.
		//$Arg2 Script Argument 1
		//$Arg3 Script Argument 2
		//$Arg4 Script Argument 3
		+DONTTHRUST //...in order to not move from where it is if hit but not enough - ozy81
		+WALLSPRITE
		+ROLLSPRITE
		+NOGRAVITY
		+SHOOTABLE
		+NOBLOOD
		+DONTFALL
		-SOLID
		Height 48;
		Radius 24;
		Health 1; //make sure that a minimum of damage destroys it...
	}

	States
	{
		Spawn:
			ALRM Q 35;
		Inactive:
			"####" Q 1;
			"####" Q 0 {
				counter++;
				if (counter >= 525) { // Check after 15 seconds to give alerted guards time to return to idle when the alarm is turned off, and to avoid spamming thinkeriterator calls
					if (
						!activator ||
						!NaziStandard(activator) ||
						!activator.bShootable ||
						activator.health <= 0 ||
						(NaziStandard(activator).activationgoal && NaziStandard(activator).activationgoal != self)
					) { activator = FindActivator(); }

					counter = 490; // Check every second after the first delay
				}

				if (boa_debugalarms > 0 && activator && !marker)
				{
					marker = activator.Spawn("FireBrandEffect", activator.pos);
					marker.master = activator;
				}

				if (args[0] && active) { level.ExecuteSpecial(226, activator, null, 0, args[0], 0, false, args[2], args[3]); }
				active = false;
			}
			Loop;
		Active:
			"####" P 1 Light("LAZERRED");
			"####" P 0 {
				counter = 0;
				if (NaziStandard(activator)) { NaziStandard(activator).activationgoal = null; }
				activator = null;

				if (marker) { marker.Destroy(); }

				if (args[0] && !active) { level.ExecuteSpecial(226, activator, null, 0, args[0], 0, true, args[2], args[3]); }
				active = true;
			}
			Loop;
		Death:
			ALRM R 0;
			ALRM # 5 {
				if (!active) { frame++; } // If it wasn't active, show frame S, which is broken with switch in off position

				if (NaziStandard(activator)) { NaziStandard(activator).activationgoal = null; }
				activator = null;

				A_StartSound("World/Spark", CHAN_AUTO, 0, 0.15);
				A_SpawnItemEx("SparkFlareY", 0, 0, 40);
				A_StartSound("METALBRK", CHAN_AUTO, 0, 0.25);
			}
			ALRM # 2 {
				for (int s = 1; s < 17; s++)
				{
					// Spawn 16 random orange, white, or yellow sparks
			 		A_SpawnProjectile(String.Format("Spark%c", RandomPick("O", "W", "Y")), 40 + Random(-12, 12), Random(-16, 16), 0, CMF_AIMDIRECTION | CMF_BADPITCH, Random(157,203));
				}
			}
			ALRM # -1;
			Stop;
	}

	override bool Used(Actor user)
	{ // Handle the player activating/deactivating the alarm
		if (health <= 0) { return false; }

		if (user.pos.z < pos.z - user.height || user.pos.z > pos.z + height) { return false; } // Rudimentary z-checking

		target = user;
		if (active) { Deactivate(user); }
		else { Activate(user); }
		return false;
	}

	override void Activate (Actor activator)
	{
		if (health <= 0) { return; } // Just in case an actor somehow still calls the Activate function

		target = activator;
		A_SetPeerState();
		Super.Activate(activator);
	}

	override void Deactivate (Actor activator)
	{
		A_SetPeerState(false);
		Super.Deactivate(activator);
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (inflictor is "BulletTracer" && !source.bFriendly) { return 0; } // Don't let enemy bullets destroy alarms

		int dmg = Super.DamageMobj(inflictor, source, damage, mod, flags, angle);

		if (health <= 0)
		{
			// Clear the activator
			if (NaziStandard(activator)) { NaziStandard(activator).activationgoal = null; }
			activator = null;

			A_SetPeerState(false);

			SetStateLabel("Death");
		}

		return dmg;
	}

	Actor FindActivator(int range = 256)
	{
		NaziStandard closest;

		ThinkerIterator it = ThinkerIterator.Create("NaziStandard");
		NaziStandard mo;
		double dist;

		while (mo = NaziStandard(it.Next()))
		{
			dist = Distance3d(mo);

			if (
				!mo.bShootable ||
				mo.health <= 0  ||
				mo.bDormant ||
				mo.bAmbush ||
				mo.Speed == 0 ||
				!mo.bCanUseWalls ||
				dist > range ||
				!CheckSight(mo) ||
				(closest && dist > Distance3d(closest))
			)
			{
				if (mo.activationgoal && mo.activationgoal == self) { mo.activationgoal = null; }
				continue;
			}

			closest = mo;
		}

		if (closest) { closest.activationgoal = self; }

		return closest;
	}

	void A_SetPeerState(bool makeactive = true)
	{
		A_StartSound("switches/normbutn", CHAN_AUTO);
		if (tid)
		{ // If there's a TID, affect all actors with that TID
			let it = ActorIterator.Create(tid, "Actor");
			Actor mo;

			while (mo = Actor(it.Next()))
			{
				if (mo.health > 0) { DoActivation(mo, makeactive); }
			}

			DoActivation(self, makeactive);
		}
	}

	void DoActivation(Actor mo, bool makeactive)
	{
		if (!makeactive)
		{
			mo.target = null;
			mo.SoundAlert(NULL, false);
			if (mo is "AlarmPanel") { mo.SetStateLabel("Inactive"); }
			else { mo.Deactivate(null); }
		}
		else
		{
			if (LastHeard && LastHeard is "PlayerPawn") { target = LastHeard; }
			if (!target) { target = FindClosestPlayer(360); }
			mo.target = target;
			if (mo is "AlarmPanel") { mo.SetStateLabel("Active"); }
			else { mo.Activate(target); }
		}
	}

	Actor FindClosestPlayer(int fov = 120, int dist = 0, bool IgnoreFriendlies = True) // Also sets up initial sight parameters
	{
		Actor ClosestPlayer = null;

		LookExParams SearchParams;

		SearchParams.fov = fov;
		SearchParams.minDist = 0;
		SearchParams.maxDist = dist;
		SearchParams.maxHearDist = dist;

		for (int p = 0; p < MAXPLAYERS; p++) { // Iterate through all of the players and find the closest one
			Actor mo = players[p].mo;

			if (mo) {
				if (!mo.bShootable || mo.health <= 0) { continue; }
				if (players[p].cheats & CF_NOTARGET) { continue; }
				if (!IsVisible(mo, false, SearchParams)) { continue; }
				if (IgnoreFriendlies) { if (isFriend(mo)) { continue; } }
				if (ClosestPlayer && Distance3d(mo) > Distance3d(ClosestPlayer)) { continue; }

				ClosestPlayer = mo;
			}
		}
		return ClosestPlayer;
	}
}

// Actor spawner with some parameters hard-coded, sneakable guards as default,
//  and customized spawn locations, so that sneakables have a place to return
//  to when they go back to idle.  
// 
// All Nazi enemies spawned by AlarmSpawners will be set as "sneakable" on spawn!
class AlarmSpawner : ActorSpawner
{
	Default
	{
		//$Title Alarm Spawner
	}

	States
	{
		Spawn:
			TNT1 A 35;
			Goto Inactive;
	}

	override void PostBeginPlay()
	{
		user_spawntype = GetSpawnableType(args[0]);
		if (!user_spawntype) { user_spawntype = "SneakableSSMP40Guard"; }
		if (!user_maxactors) { user_maxactors = 3; }
		if (!user_minspawndistance) { user_minspawndistance = 0; }
	}

	override state A_DoSpawns()
	{
		int guardcount = CountSpawns();

		if (guardcount < user_maxactors || user_maxactors < 0)
		{
			vector3 location = pos;

			if (guardcount == 1) { location += (-32, 32, 0); }
			else if (guardcount == 2) { location += (-32, -32, 0); }

			//Spawn enemies if not visible to player
			if (!InPlayerSightorRange(user_minspawndistance))
			{
				Actor guard = Spawn(user_spawntype, location);
				guard.target = target;
				guard.angle = angle;
				guard.ChangeTID(user_tid);
				if (user_goal > 0)
				{
					let it = ActorIterator.Create(user_goal, "PatrolPoint");
					Actor goal;
					if (it) { goal = it.Next(); }
					if (goal) { guard.goal = goal; }

					if (Nazi(guard))
					{
						Nazi(guard).activationgoal = goal;

						if (!Nazi(guard).user_sneakable)
						{
							Nazi(guard).user_sneakable = true; // Always make enemies spawned by alarm points sneakable
							guard.BeginPlay(); // Initialize sneakable handling
						}
						Nazi(guard).BecomeAlerted();
					}
					else
					{
						guard.SetStateLabel("See");
					}
				}

				if (Base(guard)) { Base(guard).despawntime = Random(35 * 30, 35 * 120); } //  Wait 30 seconds to 2 minutes before there's a chance to disappear

				Spawns.Push(guard);
			}

			if (user_maxactors < 0) { user_maxactors++; }

			return ResolveState("Active");
		}
		return ResolveState("Inactive");
	}
}