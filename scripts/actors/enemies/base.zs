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

  Base class that allows for handling of Boss Icons, Always-drawn health bars,
  and for "indiscriminate" enemies to be able to see through player disguises.

  Nazi class inherits from the Base class, so includes the same functionality,
  but also adds properties to configure "sneakability" and "perception".  It
  also includes handling for Stealth/one-hit knife attacks, and the code for
  alerting and setting idle sneakable enemies.

  Custom Properties
	Base.BossIcon
	- String property that is used to look up the icon image that is displayed
	  with the enemy's health bar
	- Must be used in combination with the +BOSS flag (which enables the boss
	  health bar to be drawn) or the Base.AlwaysDrawHealthBar property below.
	- Has no effect if the enemy is not flagged to have health bar drawn.

	Base.AlwaysDrawHealthBar
	- Boolean value that is used to tell the game if the enemy's health bar should
	  always be drawn.
	- Does not require the +BOSS flag to be set, and can alternatively be
	  controlled via ACS or in-editor by setting the user_DrawHealthBar variable
	- Developer note: This sets the statnum to STAT_DEFAULT - 3
	  (used to limit ThinkerIterator performance hit)

	Base.Swimmer
	- Boolean value that sets whether the actor should be restricted to staying
	  underwater or not.  Used by sharks.

	Base.LoiterDistance
	- Integer value that sets the range from the spawn point that this actor will
	  wander while it is idle (normally only on spawn).  Used by dogs and sharks.

	Base.LightThreshold
	- Integer value that determines the light level at which the actor becomes
	  afraid and runs away from the light

	Base.LightKills
	- Boolean value that, paired with LightThreshold, kills the actor with 'Fire'
	  death if they enter (or are caught in) an area that is brighter than their 
	  light threshold allows them to tolerate
	- The actor will also spawn small smoke puffs immediately before dying

	Nazi.Sneakable
	- Boolean that controls if the enemy is a sneakable enemy or not.
	- Can also be set in-editor on a per-actor basis by setting the user_sneakable
	  variable.
	- Can be set in-game (e.g., after a cutscene using normal actors) by setting
	  the actor's state to "MakeSneakable" via ACS.

	Nazi.PerceptionTime
	- Integer value that controls how many tics a disguised player must remain in
	  sight of this enemy before the player's disguise fails.
	- Default value is 0, meaning "can't see through disguises"
	- Used by SneakableEyesIdle actor (as seen on sneakable Gestapo)

	Nazi.PerceptionFOV
	- Integer value that controls the FOV of the enemy when trying to see through
	  player disguises.
	- Used by SneakableEyesIdle actor (as seen on sneakable Gestapo)

	Nazi.PerceptionRange
	- Double value that controls the distance at which a perceptive enemy will
	  first start to see the player
	- Used by SneakableEyesIdle actor (as seen on sneakable Gestapo)

	Nazi.Healer
	- Tags this enemy as a medic, and uses the medic's "smart" healing code to 
	  find allied bodies to heal.  The actor needs to have a Heal state defined
	  for full effect, otherwise they'll just stand there while healing.
	  See NaziMedic and TotenGraber_Wounded for examples
	- Setting this to 2 instead of 1 will only resurrect enemies that have a
	  suitable zombie counterpart

	Nazi.ActivateWhenShot
	- If an enemy is DORMANT and has this flag, they will become non-dormant
	  if fired on by a player.

	Nazi.IdleSound
	- Sound used for idle noises when the actor is set as sneakable

	Nazi.TargetLostSound
	- Sound used while the target is out of sight when the actor is set as sneakable

  UDMF Properties (Base Class)
	user_drawhealthbar
	- The underlying variable for the Base.AlwaysDrawHealthBar property above

	user_targetcrosshair
	- Boolean value that causes the player's cursor to show a larger yellow 
	  targeting reticle when the player's crosshair is over the actor.  Assists 
	  with sniping and firing from a distance.

	user_nocountkill
	- Boolean value that sets an actor to not add to or subtract from the enemy
	  kill counter on the automap and stats.

  UDMF Properties (Nazi Class)
	user_sneakable
	- The underlying variable for the Nazi.Sneakable property above

	user_static
	- Actor will remain at its spawn location until the player is within 256 units
	- The actor will still aim and fire at the player, but won't walk toward him
	  until the player is within the 256-unit range

	user_ForceWeaponDrop
	- Forces the enemy's weapon to be dropped when they are killed.
	- The enemy must call the A_UnblockAndDrop function in their Death state
	  for this property to have any effect.

	user_spymsgindex
	- Message displayed when player presses use to interact with a FRIENDLY Nazi
	  Message names in in LANGUAGE are formatted as:
		SPYMESSAGE[MAPNAME][user_spymsgindex value]

	  e.g., Spy message 1 in C3M1 would be the SPYMESSAGEC3M11 lookup

	user_spyitem
	- Item given to player when you press use to interact with a FRIENDLY Nazi

	user_activatewhenshot
	- If an enemy is DORMANT and has this variable set to non-zero, they will 
	  become non-dormant if fired on by a player.
	
	user_cansurrender
	- Whether this Nazi type can surrender to the player or not (uses "Death.Surrender"
	state).
	
  New Functions (Base class)
	A_LookThroughDisguise(int flags = 0, float minseedist = 0, float Range = 0, float maxheardist = 0, double fov = 0, statelabel label = "See")
	- Allows enemies to always and immediately "see through" player disguises,
	  essentially by having those enemies ignore the NOTARGET flag when looking
	  for their target.
	- Parameters are the same as for A_LookEx (https://zdoom.org/wiki/A_LookEx)
	- Should be used in place of A_Look or A_LookEx for "indiscriminate" enemies,
	  that wouldn't be fooled by a disguise, like rats, spiders, and possibly
	  paranormal creatures.

	A_JumpAttack(int attackspeed = 20, int flags = 0)
	- A generic version of A_SkullAttack that allows you to pass in an attack speed
	- Also handles skipping the attack if a swimmer is out of water
	- Flags:
	JAF_PRECISE - Velocity is calculated in true 3D rather than in 2D
	JAF_INTERCEPT - Fly at the target's predicted position rather than their current position

	A_WanderGoal()
	- If the enemy has a goal assigned, go to it.  If not, wander.

	static bool InPlayerSight(Actor caller)
	- Checks each player to see if they can see actor caller and returns true if any
	  player can see the actor

	actor FindClosestPlayer(int fov = 120, int dist = 0, bool IgnoreFriendlies = True)
	- Finds the closest player within the specified parameter range, and returns
	  the player's mapobject actor.

	bool SneakableActors()
	- Returns true if there are actors flagged as "sneakable" in the current
	  map (Actually just counts StealthBase actors to avoid iterating over all
	  Base or Nazi class descendants and causing huge slowdown).
	- Used internally to set up sneakable handling

  New Functions (Nazi class)
	A_NaziPain(int alertrange = 0, bool StartSound = True, int offset = -8)
	- Consolidated function intended for use in Nazi class Pain states to
	  eliminate code duplication across actors.
	- Spawns pain overlay (with height offset specified, alerts actors within the
	  passed range, and calls A_Pain if StartSound is true.

	BecomeAlerted(Actor newtarget = null)
	- Sets an idle sneakable actor to alerted, spawns alerted helper actor to
	  continue checking the player's visibility and to manage the return-to-idle
	  timout counters.
	- Takes one parameter - the new actor to target.
	- Used internally by SneakableEyesIdle actor

	BecomeIdle()
	- Sets an alerted sneakable actor to idle, spawns idle helper actor to look
	  for players and play idle sounds.
	- Also sets actor back to patrolling/goal chasing if a goal had been set
	  before the actor was alerted
	- Used internally by SneakableEyesAlerted actor

	A_UnblockAndDrop()
	- Similar to A_NoBlocking, but also implements forced weapon dropping, via
	  the user_ForceWeaponDrop property.
	- Also handles reduction of drop amounts for sneakable enemies; sneakables
	  will only ever drop weapons, no ammo, grenades, etc., and the included
	  dropped ammo amount is cut in half automatically.
	  
	A_GibsUnblockAndDrop() - Ozy81
	- Same of UnblockAndDrop, except that it has also hold blood effects related to
	  headshots, without the necessity then to nest multiple specials in a row.

	A_HealGoal()
	- Resurrects the actor's goal, with special handling to keep kill counts
	  accurate and sneakeable alerting functional.

  Useful objects (Nazi Class)
	activationgoal
	- Nazi class descendants have special internal handling in place for when
	  an actor is assigned as the activationgoal.
	- Similar to a normal 'goal' that is usually a PatrolPoint, a Nazi will walk
	  to their activationgoal when it is assigned to them.  The major difference
	  is that Nazis will walk immediately to the activationgoal without stopping
	  to fire at the player, and, once the activationgoal is reached, the goal
	  actor will activated.
	- Alarm Panels and their descendants have special handling, where the Nazi
	  is set to the 'Alarm' state upon activation.
	- After reaching the activationgoal, the Nazi automatically clears their
	  activationgoal and returns to normal behavior.

*/

const BASE_FLAGS = SXF_TRANSFERPITCH | SXF_CLIENTSIDE;

// Some flags to simplify things...
enum EHealerFlags
{
	HLR_ALLIES = 1,
	HLR_ZOMBIES = 2,
};

enum EJumpAttackFlags
{
	JAF_PRECISE = 1,
	JAF_INTERCEPT = 2,
	JAF_ARC = 4, // Force using ArcZVel to calculate Z velocity
}

// Base class to add ability to see through notarget to actors (e.g., mice, sharks)
class Base : Actor
{
	Actor marker;
	Actor patrolgoal;
	Actor frightener;
	LookExParams SearchParams;
	State DodgeState;
	String BossIcon;
	bool noheal;
	bool swimmer;
	bool user_DrawHealthBar;
	bool user_ForceWeaponDrop;
	bool user_conversation;
	bool user_lightburns;
	int dodgecounter;
	int dodgetimeout;
	int crouchtimeout;
	int crouchtimer;
	int frighttimeout;
	int lightthreshold;
	int loiterdistance;
	int maxdodge;
	int timeout;
	int interval;
	int user_count;			//attacks counters
	int user_count2;		//attacks counters
	int user_count3;		//attacks counters
	int user_count4;		//attacks counters
	int user_offset;		//elite counter
	int user_saw;			//smokemonster counter
	double user_rangefactor;	// Multiplier for MaxTargetRange
	int despawntime;
	bool user_oncompass;
	bool candodge;
	bool nofear;
	bool user_targetcrosshair;
	bool user_nocountkill;
	int flags;
	bool dodging;
	bool statnumchanged;
	EffectsManager manager;
	ParticleManager pmanager;
	LaserFindHitPointTracer HitPointTracer;
	LaserBeam beam;
	Actor flare;
	double dlvisibility;
	bool step;

	FlagDef CANSQUISH:flags, 0;

	Property AlwaysDrawHealthBar:user_DrawHealthBar;
	Property BossIcon:BossIcon;
	Property DodgeAmount:maxdodge; // Max number of times the enemy will dodge
	Property LightKills:user_lightburns;
	Property LightThreshold:lightthreshold;
	Property LoiterDistance:loiterdistance;
	Property NoMedicHeal:noheal;
	Property Swimmer:swimmer;
	Property OnCompass:user_oncompass;
	Property NoFear:nofear;
	Property DespawnTime:despawntime;

	Default
	{
		+CASTSPRITESHADOW
		Base.DespawnTime -1;
		Activation THINGSPEC_Default | THINGSPEC_ThingTargets;
	}

	state A_LookThroughDisguise(int flags = 0, float minseedist = 0, float Range = 0, float maxheardist = 0, double fov = 0, statelabel label = "See")
	{
		// Try a normal look first!
		A_LookEx(flags, minseedist, Range, maxheardist, fov, label);

		if (!target)
		{
			// Set up view parameters for this search
			SearchParams.fov = bLookAllAround ? 360 : fov;
			SearchParams.minDist = minseedist;
			SearchParams.maxDist = Range;
			SearchParams.maxHearDist = Range;

			for (int p = 0; p < MAXPLAYERS; p++) // Iterate through all of the players and find one that's in range, ignoring NOTARGET
			{
				Actor mo = players[p].mo;

				if (mo) {
					if (!mo.bShootable || mo.health <= 0) { continue; }
					if (isFriend(mo)) { continue; }
					if (Range && Distance3d(mo) > Range) { continue; }
					if (!IsVisible(mo, false, SearchParams)) { continue; }

					let disguise = mo.FindInventory("DisguiseToken", True);
					if (!disguise) { continue; }

					target = mo;
					return ResolveState(label);
				}
			}
		}

		return ResolveState(null);
	}

	// Charge towards the target. Similar to A_SkullAttack, but can optionally
	// charge in 3D rather than treating the Z velocity as an afterthought
	void A_JumpAttack(int attackspeed = 20, double heightFactor = .5, int flags = JAF_PRECISE)
	{
		if (!target || (swimmer && target.waterlevel == 0)) { return; }

		bSkullFly = true;
		A_StartSound(AttackSound, CHAN_VOICE);

		// Get "middle" of caller and their target

		// Calculate target position
		Vector3 targetPos = target.Pos;
		if (flags & JAF_INTERCEPT)
		{
			double interceptTime = ZScriptTools.GetInterceptTime4(Pos, target.Pos, target.Vel, double(attackspeed));
			targetPos = target.Pos + target.Vel * interceptTime;
		}
		Vector3 posDiff = Level.Vec3Diff(Pos, targetPos);

		// Modify velocity
		if (flags & JAF_PRECISE)
		{
			Angle = atan2(targetPos.Y, targetPos.X);
			Vector3 toEnemy = (posDiff.X, posDiff.Y, posDiff.Z);
			toEnemy.Z += target.Height * heightFactor;
			Vel = toEnemy.Unit() * attackspeed;
		}
		else
		{
			if (flags & JAF_INTERCEPT)
			{
				Angle = atan2(posDiff.Y, posDiff.X);
			}
			VelFromAngle(attackspeed);
			Vel.Z = (target.pos.Z + target.Height * heightFactor - pos.Z) / DistanceBySpeed(target, attackspeed);
		}

		// Calculate arc trajectory
		if (flags & JAF_ARC)
		{
			double time = posDiff.Length() / attackspeed;
			double grav = GetGravity();
			double height = posDiff.Z + target.Height * heightFactor;
			Vel.Z = ZScriptTools.ArcZVel(time, grav, height);
		}
	}

	// Fires a projectile in an arc towards the target.
	Actor A_ArcProjectile(class<Actor> missiletype, double spawnheight = 32, double spawnofs_xy = 0, double angle = 0, int flags = 0, double pitch = 0, int ptr = AAPTR_TARGET, double maxdistance = 0, double additionalHeight = 0)
	{
		// This function works by firing the projectile, and then modifying its
		// Z velocity to hit the target.
		Actor targ = GetPointer(ptr);
		// NOTE: spawnheight is also the height being aimed at! Use additionalHeight to work around this.
		Actor proj = A_SpawnProjectile(
			missiletype, spawnheight + additionalHeight, spawnofs_xy, angle, flags, pitch, ptr);
		if ((flags & CMF_ABSOLUTEPITCH) || (flags & CMF_AIMDIRECTION) || !proj)
		{
			// Do not modify the projectile's velocity, and just return it if
			// CMF_ABSOLUTEPITCH or CMF_AIMDIRECTION is set, which makes the
			// projectile use the given pitch value, in which case the Z
			// velocity shouldn't be modified.
			// Or the projectile was not even spawned, as could be the case if
			// CMF_CHECKTARGETDEAD was set.
			return proj;
		}
		double gravity = proj.GetGravity();
		double speed = Actor.GetDefaultSpeed(missiletype);
		if (!gravity || !speed)
		{
			// Gravity is 0, and thus the projectile will not fall, so
			// don't modify the projectile's velocity!
			// Also, if speed is 0, you'll end up dividing by 0, so prevent
			// that.
			return proj;
		}
		// The height difference may be changed by a portal
		Vector3 posDiff = Level.Vec3Diff(proj.Pos, targ.Pos);
		double distance = posDiff.Length();
		if (maxdistance)
		{
			distance = min(maxdistance, distance);
		}
		double time = distance / speed;
		// Account for spawnheight when calculating height difference
		double crouchfactor = 1;
		if (targ.player)
		{
			// Account for crouched players
			crouchfactor = targ.player.crouchfactor;
		}
		double height = posDiff.Z + spawnheight * crouchfactor;
		proj.Vel.Z = ZScriptTools.ArcZVel(time, gravity, height);
		if (pitch && (flags & CMF_OFFSETPITCH))
		{
			proj.Vel.Z += sin(-pitch) * speed;
		}
		if (flags & CMF_SAVEPITCH)
		{
			// Calculate projectile pitch. Speed is amount to move forward each
			// tic, and proj.Vel.Z is the amount to move up/down each tic.
			proj.Pitch = -atan2(proj.Vel.Z, speed);
		}
		return proj;
	}

	void A_XDie(Name damagetype = 'None')
	{
		// Force the caller to die with an extreme death
		int damage = health - GetGibHealth() + 1;
		DamageMobj(null, null, damage, damagetype, DMG_FORCED);
	}

	void A_WanderGoal(int flags = 0, int scarerange = 0)
	{
		if (scarerange > 0)
		{
			if (!target) { LookForEnemies(true); }
		
			if (target)
			{
				if (target is "GrenadeBase" || (target.bMissile && target.damage)) // If a GrenadeBase actor is closer than last heard, use that as the feared actor 
				{
					if (!lastheard || Distance3D(target) < Distance3D(lastheard))
					{
						lastheard = target;
						if (lastheard)
						{
							if (GrenadeBase(target)) { scarerange = max(scarerange, GrenadeBase(target).feardistance); }
							else { scarerange = int(target.radius + 256); }
						}
					}
				}
				else if (bFriendly && target is "Nazi") // If a Nazi actor is in sight, use that as the feared actor
				{
					if (!Nazi(target).user_incombat || !CheckSight(target)) { target = null; } // But only if the Nazi is awake and visible
					else if (!lastheard || Distance3D(target) < Distance3D(lastheard)) { lastheard = target; }
				}
			}

			if (lastheard)
			{
				// If it's close, or you last heard a BulletTracer or GrenadeBase, be afraid
				if (Distance3D(lastheard) <= scarerange || lastheard is "BulletTracer" || lastheard is "GrenadeBase" || (target && target is "Nazi") || (lastheard.bMissile && lastheard.damage))
				{
					frighttimeout = 35 + Random(0, 7) * 5; 
					frightener = lastheard;
				}
				else
				{
					lastheard = null;
				}
			}
		}

		if (goal != null)
		{
			if (!bFrightened) { bChaseGoal = true; }
			if (self is "Nazi") { Nazi(self).A_NaziChase(null, null, flags); }
			else { A_Chase(null, null, flags); }
		}
		else
		{
			bChaseGoal = Default.bChaseGoal;
			A_Wander(flags);
		}
	}

	static bool InPlayerSight(Actor caller)
	{
		for (int p = 0; p < MAXPLAYERS; p++) // Iterate through all of the players and see if any can see the spawn point
		{
			Actor mo = players[p].mo;

			if (mo) {
				if (mo.CheckSight(caller, SF_SEEPASTBLOCKEVERYTHING | SF_SEEPASTSHOOTABLELINES)) { return true; }
			}
		}

		return false;
	}

	static Actor FindClosestPlayer(Actor source, int fov = 120, int dist = 0, bool IgnoreFriendlies = True) // Also sets up initial sight parameters
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
				if (!source.IsVisible(mo, false, SearchParams)) { continue; }
				if (IgnoreFriendlies) { if (source.isFriend(mo)) { continue; } }
				if (ClosestPlayer && source.Distance3d(mo) > source.Distance3d(ClosestPlayer)) { continue; }

				ClosestPlayer = mo;
			}
		}
		return ClosestPlayer;
	}

	int CanBeSeen(int maxcount = 0, int range = 1024)
	{
		int count = 0;

		ThinkerIterator it = ThinkerIterator.Create("Nazi", Thinker.STAT_DEFAULT);
		Nazi mo;
		while (mo = Nazi(it.Next()))
		{
			if (mo == self) { continue; }
			if (!mo.bShootable || mo.health <= 0) { continue; }
			if (Distance3D(mo) > range) { continue; }
			if (!mo.IsVisible(self, true)) { continue; }

			count++;

			if (count > maxcount) { return count; }
		}

		it = ThinkerIterator.Create("Nazi", Thinker.STAT_DEFAULT - 5);
		while (mo = Nazi(it.Next()))
		{
			if (mo == self) { continue; }
			if (!mo.bShootable || mo.health <= 0) { continue; }
			if (Distance3D(mo) > range) { continue; }
			if (!mo.IsVisible(self, true)) { continue; }

			count++;

			if (count > maxcount) { return count; }
		}

		return count;
	}

	static bool SneakableActors() // Are there sneakable actors in the level?
	{
		ThinkerIterator it = ThinkerIterator.Create("StealthBase", Thinker.STAT_DEFAULT - 2); // Just iterate over the sneakable eyes - faster than all Nazi actors
		StealthBase mo;
		while (mo = StealthBase(it.Next()))
		{
			return true;
		}

		return false;
	}

	void ResetDodge(bool initial = false)
	{
		dodgetimeout = int(Random(350, 700) / max(speed, 1));

		if (initial) { dodgetimeout /= 3; } // Initial dodge delay is shorter 
	}

	bool A_DoSideRoll(int dodgespeed = 10, bool checkonly = false, bool force = false)
	{
		// If we're static, still waiting after the last dodge, or are on a path, don't try to dodge right now
		if
		(
			!speed ||
			dodging ||
			(!force && dodgetimeout > 0) ||
			(!force && (bFriendly || (target && target is "PatrolPoint"))) ||
			health <= 0
		) { return false; }

		double dodgeangle;
		double dodgedistance;

		[dodgedistance, dodgeangle] = GetBestSideMove(); // Get the direction (left or right) that is the best to dodge, and how far you can dodge there

		if (dodgedistance > 0) // If dodgedistance is less than zero, we shouldn't dodge...  That means there is no room.
		{
			if (checkonly) { return true; } // If this is just a logic check, stop here

			// Error message if you forgot to set up the Dodge state on the actor
			if (!DodgeState)
			{
				if (developer) { console.printf("\cgNo Dodge sprite defined in actor " .. GetClassName() .. "."); }
				return false;
			}

			dodging = true;

			// Take 50% damage instead, and prevent pain
			bNoPain = true;
			DamageFactor = Default.DamageFactor * 0.5;

			if (!force || (lastHeard && lastHeard is "Whizzer")) { dodgecounter++; }

			spriteID dodgesprite = DodgeState.sprite;
			if (dodgesprite) { sprite = dodgesprite; }

			// Set the actor's state based on dodging left or right
			if (deltaangle(dodgeangle, angle) > 0) { SetStateLabel("Dodge.Right"); }
			else { SetStateLabel("Dodge.Left"); }

			// Use the dodgeangle to move the actor in the correct direction
			VelFromAngle(dodgespeed, dodgeangle);

			// Set a random timeout until another dodge is allowed
			ResetDodge();

			return true;
		}

		return false;
	}

	double, double GetBestSideMove() //there should be some occasionally events where actors gets stucked over ledges or stairs, how to fix? - ozy81
	{
		double left = GetMoveDistance(90);
		double right = GetMoveDistance(-90);

		if (left < radius + 96 && right < radius + 96) { return -1, 0; } // Don't dodge if there's not space on either side - augmented values to avoid stuck cases
		if (left == right) return left, angle + 90 * RandomPick(-1, 1); // If the space on either side is the same, pick a random side
		if (left > right) return left, angle + 90; // If there's more space on the left, dodge left

		return right, angle - 90; // Otherwise, dodge right
	}

	double GetMoveDistance(double moveangle = 0, double range = 256)
	{
		bool blocked;
		double offsetangle = 0;

		if (target) { offsetangle = deltaangle(angle, AngleTo(target)); }

		for (double i = Radius; i <= range; i += Speed)
		{
			tracer = null;

			blocked = CheckBlock(CBF_DROPOFF | CBF_SETTRACER, AAPTR_DEFAULT, i, 0, 0, moveangle + offsetangle);

			if (blocked) { return i; }
		}

		return range;
	}

	Actor ReplaceWith(Class<Actor> cls, statelabel label = "Spawn")
	{
		Actor newmobj = Spawn(cls, pos);

		if (newmobj)
		{
			// Borrowed from RandomSpawner code
			newmobj.scale = scale;
			newmobj.Pitch = Pitch;
			newmobj.Roll = Roll;
			newmobj.SpawnPoint = SpawnPoint;
			newmobj.special = special;
			newmobj.args[0] = args[0];
			newmobj.args[1] = args[1];
			newmobj.args[2] = args[2];
			newmobj.args[3] = args[3];
			newmobj.args[4] = args[4];
			newmobj.special1 = special1;
			newmobj.special2 = special2;
			newmobj.SpawnFlags = SpawnFlags & ~MTF_SECRET;
			newmobj.HandleSpawnFlags();
			newmobj.SpawnFlags = SpawnFlags;
			newmobj.bCountSecret = SpawnFlags & MTF_SECRET;
			newmobj.ChangeTid(tid);
			newmobj.Vel = Vel;
			newmobj.master = master;
			newmobj.target = target;
			newmobj.tracer = tracer;
			newmobj.CopyFriendliness(self, false);

			newmobj.SetStateLabel(label);

			if (bCountKill && !bFriendly) { level.total_monsters--; }
			self.Destroy();

			return newmobj;
		}

		return self;
	}

	int GetVisibility()
	{
		int visibility = 0;

		ThinkerIterator it = ThinkerIterator.Create("Actor", STAT_DLIGHT);
		Actor mo;

		while (mo = Actor(it.Next()))
		{
			double checkRadius = mo.args[3];

			if (Distance3D(mo) > checkRadius * 2) { continue; }

			double brightness = (mo.args[0] + mo.args[1] + mo.args[2]) / (255. * 3) * 1.25; // Calculate the light's overall brightness

			double amount;

			if (mo is "Spotlight")
			{
				let light = SpotLight(mo);

				double amt = InBeamFrom(light);

				if (amt)
				{
					if (SpotLight(mo).spotinnerangle - amt < 0) // When in between inner and outer angles...
					{
						amount = SpotLight(mo).spotouterangle * 1.5 - amt;
						amount = amount / max((SpotLight(mo).spotouterangle * 1.5 - SpotLight(mo).spotinnerangle * 1.5), 1) * 100; // Ramp up intensity proportionate to distance from inner angle edge
					}
					else { amount = 100; } // Use full amount when located inside the center radius of the spotlight
				}
				else
				{ amount = 0; } //  Not in the spotlight's beam!
			}
			else { amount = checkRadius * 2 - Distance2d(mo) + 8; } // Calculate visibility based on how close the actor is to the light (in 2D space, so we can mostly disregard z-pos and height)

			amount *= brightness; // Adjust based on brightness level

			visibility = int(visibility + max(amount - visibility, 0)); // Set the new visibility - use delta in value instead of overriding so that multiple lights can be additive in visibility
		}

		return visibility;
	}

	double InBeamFrom(SpotLight mo)
	{
		double relpitch = PitchTo(self, mo);

		// Use custom function instead of AngleTo in order to account for target actor radius
		Vector2 posoffset = mo.pos.xy - pos.xy; // Get offsets
		posoffset = RotateVector(posoffset, -mo.angle); // Rotate to align with 0 degrees to remove rotation from calculations

		// Calculate the angle to the left and right sides of the actor, and return whichever is smaller
		double relangle = min(atan2(posoffset.y + radius * 0.7, posoffset.x), atan2(posoffset.y - radius * 0.7, posoffset.x));  // Radius is fudged by 0.7 since most actors's center of mass doesn't take up the whole radius //Changed to atan2 because posoffset.x can be zero, it happened to me multiple times --N00b

		double reldist = sqrt(relpitch ** 2 + relangle ** 2); // Get the distance from light cone center using the calculated pitch and angle

		if (reldist < mo.spotouterangle * 1.5) // Use 1.5 times the outer angle so that we have wiggle room to calculate the ramp up to full light level
		{
			return reldist; 
		}

		return 0;
	}

	// Return the aim pitch offset from the source to the target
	double PitchTo(Actor mo, Actor source = null, double sourcepitch = 0)
	{
		if (source == null) { source = self; }
		if (!sourcepitch) { sourcepitch = source.pitch; }

		double distxy = max(source.Distance2D(mo), 1);
		double distz = source.pos.z - mo.pos.z;

		double targetheight = mo.player ? mo.height * mo.player.crouchfactor : mo.height; // Get target height, with crouching if applicable

		double pitchcalc = min(atan(distz / distxy), atan((distz - targetheight) / distxy)); // Return whichever is lower: pitch to actor bottom or actor top.

		return pitchcalc - sourcepitch % 360; // Normalize to 360 degree range
	}

	void A_LightningAttack(Class<LightningBeam> beam = "LightningBeamZap", int xoffset = 0, int yoffset = 0, int zoffset = -1, double angleoffset = 0, double pitchoffset = 0, bool fromsky = false)
	{
		if (!target) { return; }
		if (fromsky && ceilingpic != skyflatnum) { return; }
		if (zoffset < 0) { zoffset = int(Height * 2 / 3); } // Default to spawning at z-height of 2/3 the actors height

		bool spawned;
		Actor b;

		[spawned, b] = A_SpawnItemEx(beam, xoffset, yoffset, zoffset);
		if (spawned && b)
		{
			b.master = self;
			b.pitch = pitch + pitchoffset;
			b.angle = angle + angleoffset;
			LightningBeam(b).AimPoint = target.pos;
		}
	}

	static void DestroyAll(String classname, String damagetype = "Fire", color clr = 0)
	{
		ThinkerIterator it = ThinkerIterator.Create(classname, Thinker.STAT_DEFAULT);
		Actor mo;

		while (mo = Actor(it.Next()))
		{
			mo.A_Die(damagetype);
			if (clr)
			{
				mo.A_SetRenderStyle(1.0, STYLE_SHADED);
				mo.SetShade(clr);
			}
		}
	}

	static void DeactivateAll(String classname)
	{
		ThinkerIterator it;
		Actor mo;

		for (int i = 0; i < 6; i++)
		{
			it = ThinkerIterator.Create(classname, Thinker.STAT_DEFAULT - i);

			while (mo = Actor(it.Next()))
			{
				mo.Deactivate(mo);
				mo.bDormant = true;

				if (mo.health > 0)
				{
					mo.SetState(mo.SpawnState);
					mo.A_Face(mo.target);
				}
			}
		}
	}

	void A_FireLaser(int damage, sound snd = "", double zoffset = 0, bool drawdecal = false, double alpha = 1.0, double volume = 1.0)
	{
		if (snd != "")
		{
			A_StartSound(snd, CHAN_6, CHANF_NOSTOP, 1.0);
			A_SoundVolume(CHAN_6, volume);
		}
		Laser.DoTrace(self, angle, 2048, pitch, 0, zoffset, hitpointtracer);
		[beam, flare] = Laser.DrawLaser(self, beam, flare, hitpointtracer.Results, "LaserBeam", "LaserPuff", damage, zoffset, drawdecal, alpha);
	}

	void A_StopLaser()
	{
		A_StopSound(CHAN_6);
		if (beam) { beam.Destroy(); }
		if (flare) { flare.Destroy(); }
	}

	enum steptype
	{
		Normal = 0,
		Heavy,
		Mech
	}

	void A_PlayStepSound(int type = Base.Normal, double stepvolume = 1.0, double typevolume = 1.0)
	{
		if (manager)
		{
			int interval;
			bool forceculled;

			[interval, forceculled] = manager.Culled(pos.xy);
			if (forceculled || interval > 3) { return; }
		}

		if (pos.z == max(curSector.NextLowestFloorAt(pos.x, pos.y, pos.z), floorz)) // If on the floor
		{
			stepvolume = clamp(stepvolume, 0.0, 1.0);
			typevolume = clamp(typevolume, 0.0, 1.0);

			step = !step;
			Sound stepsound = BoAFootsteps.GetStepSound(self, step);

			switch (type)
			{
				case 2:
					if (stepsound) { A_StartSound(stepsound, CHAN_AUTO, CHANF_DEFAULT, stepvolume, 8); }
					A_StartSound("mech/walk", CHAN_AUTO, CHANF_DEFAULT, FRandom(0.7, 1.0) * typevolume, ATTN_IDLE);
					break;
				case 1:
					if (stepsound) { A_StartSound(stepsound, CHAN_AUTO, CHANF_DEFAULT, stepvolume, 8); }
					A_StartSound("floor/heavy", CHAN_AUTO, CHANF_DEFAULT, typevolume);
					break;
				default:
					if (stepsound) { A_StartSound(stepsound, CHAN_AUTO, CHANF_DEFAULT, stepvolume); }
					break;
			}
		}
	}

	override void Tick()
	{
		if (manager)
		{
			int cullinterval = manager.Culled(pos.xy);
			if (cullinterval > 8 || cullinterval == -1) { Thinker.Tick(); return; }
			else if (cullinterval > 6) { Super.Tick(); return; }
		}
		else { manager = EffectsManager.GetManager(); }

		if (!pmanager) { pmanager = ParticleManager.GetManager(); }

		if (user_DrawHealthBar && !statnumchanged)
		{
			ChangeStatNum(Thinker.STAT_DEFAULT - 3); // Change the statnum of these actors so that ThinkerIterators can look at just this statnum and be more efficient
			statnumchanged = true; // Only do this once!
		}

		if (!globalfreeze && !level.Frozen)
		{
			if (dodgetimeout > 0) { dodgetimeout--; }
			if (crouchtimeout == 70) { crouchtimer++; }
			if (crouchtimeout > 0) { crouchtimeout--; }
			if (despawntime > 0) { despawntime--; }

			if (frighttimeout > -35) { frighttimeout--; }
			else if (Speed != Default.Speed) { Speed = Default.Speed; }

			if (bShootable && health > 0 && !bDormant)
			{
				if (Default.bCountKill && !bCountKill && !bFriendly)
				{
					if (SpawnFlags & MTF_DORMANT && !bDormant && !user_nocountkill)
					{
						bCountKill = true;
						level.total_monsters++; 
					}
				}

				if (swimmer) // Swimmers can't leave the water once they are below the surface (edge case: they can stack up on top of each other and sometimes make it out if the next sector height is close to the water height)
				{
					double waterheight = Buoyancy.GetWaterHeight(self);
					if (waterheight < pos.z + height + 8)
					{
						bFloat = false;
						vel.z = min(vel.z, -Speed);
					}
					else { bFloat = Default.bFloat; }
				}
				else if (Default.bFloat && !swimmer) // Non-swimming floaters can't enter water when they are above the surface
				{
					if (waterlevel > 0) 
					{
						bFloat = false;
						vel.z = max(vel.z, Speed);
					}
					else { bFloat = Default.bFloat; }
				}

				if ((!Nazi(self) || Nazi(self).user_incombat) && lightthreshold)  // If light threshold is zero or Nazi actor is not awake, ignore light levels (so, default to normal enemy behavior)
				{
					if ((level.time + interval) % 10 == 0) // Periodically poll dynamic lights to handle light avoidance
					{
						if (
							ReactionTime == 0 && // This is only checked when the enemy is active and not standing still or attacking
							!bFrightened && 
							frighttimeout == -35 && // Use a counter to keep the randomness evident!
							(!target || Distance2D(target) > 64 + target.radius + radius) // Only run away if not nearby to target
						)
						{
							dlvisibility = GetVisibility(); // This calls a ThinkerIterator, which is why this whole block only runs every 10 ticks

							FLineTraceData trace;
							if (LineTrace(angle, 256, 45, TRF_THRUHITSCAN | TRF_THRUACTORS, Height * 0.9, 0.0, 0.0, trace) && trace.HitType == TRACE_HitFloor)
							{
								double lightlevel, fogfactor;
								[lightlevel, fogfactor] = ZScriptTools.GetLightLevel(trace.HitSector);

								double visibility = lightlevel - fogfactor;

								if (visibility > lightthreshold || visibility + dlvisibility > lightthreshold + 64 + Random(0, 32)) // Add some randomness to the light reaction distance
								{
									if (target) { NewChaseDir(); }
									else { RandomChaseDir(); }
									FaceMovementDirection();
									frighttimeout = 35 + Random(0, 7) * 5; // Use a counter to keep the actor frightened for a little bit
									frightener = self;
								}
							}
						}
					}

					if (user_lightburns)
					{
						if (ceilingpic == skyflatnum)
						{
							double lightlevel, fogfactor;
							[lightlevel, fogfactor] = ZScriptTools.GetLightLevel(CurSector);
							lightlevel -= fogfactor;

							if (lightlevel > lightthreshold) { A_Die("Fire"); }
							else
							{
								// This min value really should be lower, since the light threshold for Zombies is 130...  
								// But it's too late now.  Just means the "smoking while it's not quite light enough to
								// burn up" effect isn't really ever seen in the mod.
								double minval = 128;
								
								double delta = lightlevel - max(minval, lightthreshold - 48); 
								if (health > 0 && delta > 0 && Random() < 64 * (delta / 16) && !CheckSightOrRange(64)) // Smoke more as you approach burning point
								{
									Spawn("BodySmoke", (pos.x + FRandom(-radius / 2, radius / 2), pos.y + FRandom(-radius / 2, radius / 2), pos.z + FRandom(0, height)));
								}
							}
						}
					}
				}

				bFrightened = !bBoss && !NoFear && (Default.bFrightened || frighttimeout > 0); // If frighttimeout was set, or we've been set to frightened by default, be afraid...
				if (!bFrightened) { frightener = null; }

				if (loiterdistance > 0 && patrolgoal && !bAmbush)
				{
					if (goal && goal != patrolgoal) { } // Already has a goal set, so don't mess with it
					else if (!target || (target == patrolgoal))
					{
						if (Distance3d(patrolgoal) > loiterdistance)
						{
							goal = patrolgoal;
							target = goal;

							if (timeout <= 0)
							{
								RandomChaseDir();
								FaceMovementDirection();

								timeout = 35;
							}
						}
		 				else
						{
							goal = null;
							target = null;
						}
					}
				}

				if (!bBoss && Default.Speed > 0 && target && target is "TankPlayer") // Be frightened of the tank (if you're not a boss, and if you aren't non-moving)
				{
					if (Distance2D(target) < 512) // Stay outside of 512 units and run away
					{
						frighttimeout = 70;
						frightener = target;
						dodgetimeout = 350; // No rolling while scared and running away
						Speed = Default.Speed + Random(1, 2); // Walk/run a little faster to get away
					}
					else // Back to normal speed and un-frighten (if light level allows)
					{
						if (frighttimeout == -35) { bFrightened = false; }  // Don't interfere with light sensitivity frightened flag use
						Speed = Default.Speed;
					}
				}

				// Randomly despawn if the player can't see you and is outside of range and you had a despawntime timeout set (AlarmSpawner uses this)
				if (despawntime == 0 && Random(0, 255) < 10 && InStateSequence(CurState, FindState("Look")) && CheckSightOrRange(512))
				{
					bShootable = false;
					if (bCountKill) { level.total_monsters--; }
					Destroy();
				}

				if (timeout > 0) { timeout--; }
			}
			else if (!bDormant && health <= 0 && Default.bShootable && bShootable) // If an actor somehow is shootable but should have died, kill it now
			{
				Die(self, self);
			}

			if (bInConversation && marker)
			{
				marker.SetStateLabel("Inactive");
				marker = null;
			}

			if (target && interval && level.time % interval == 0) // At intervals, make sure you haven't lost your target in the fog, even if you're not calling A_NaziLook or A_NaziChase
			{
				BoAVisibility vis = BoAVisibility(target.FindInventory("BoAVisibility"));
				if (vis) { vis.CheckVisibility(self); }
			}
		}

		Super.Tick();
	}

	override void PostBeginPlay()
	{
		EffectsManager manager = EffectsManager.GetManager();

		Super.PostBeginPlay();

		// Multiply MaxTargetRange
		if(user_rangefactor > 0){
			MaxTargetRange *= user_rangefactor;
		}

		user_nocountkill = user_nocountkill || (SpawnFlags & MTF_NOCOUNT);

		hitpointtracer = new("LaserFindHitPointTracer");

		if (!(self is "NaziBoss")) { A_SetSize(radius * scale.x / Default.scale.x, height * scale.y / Default.scale.y); } // If the actor is scaled from default, adjust the actual size of the actor

		if (SpawnFlags & MTF_DORMANT)
		{
			bDormant = true;

			if (bCountKill && !bFriendly)
			{
				ClearCounters();
			}
		}
		else if (Default.bCountKill && !bFriendly && user_nocountkill)
		{
			ClearCounters();
		}

		if (bDormant) { loiterdistance = 0; } // Don't loiter if dormant.

		// If it's a loiterer with no set goal, spawn a patrolpoint goal for it and make that the goal, then run around that point
		if (loiterdistance > 0 && !goal && !patrolgoal)
		{
			patrolgoal = Spawn("PatrolPoint", pos);
			patrolgoal.args[0] = -1;
			patrolgoal.args[1] = 0x7FFFFFFF;
			patrolgoal.angle = angle;

			if (!InStateSequence(CurState, SeeState)) { SetStateLabel("See"); }
		}

		// If it's tagged with a conversation ID, spawn the conversation marker
		if (user_conversation && !marker)
		{
			marker = Spawn("ConversationMarker", pos);
			if (marker) { marker.master = self; }
		}

		// Find dodge state
		DodgeState = FindState("Dodge");
		ResetDodge(true);

		if (user_oncompass) { BoACompass.Add(self, "GOAL1"); }
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (passive)
		{
			if (other.player && pos.z == floorz)
			{
				if (bCanSquish)
				{
					if (other.player.ReadyWeapon && other.player.ReadyWeapon is "NaziWeapon" && boa_peststomp)
					{
						let kick = other.player.FindPSprite(-10);
						if (!kick)
						{
							other.vel.xy *= 0;
							other.player.SetPsprite(-10, other.player.ReadyWeapon.FindState("KickOverlay"), true);
						}
					}

					DamageMobj(other, other, health, "Squish", 0, other.angle);
				}
			}
		}
		else
		{
			if (other is "FlattenableProp")
			{
				other.Touch(self);
				return false;
			}
		}

		return true;
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
		bCastSpriteShadow = false;
	}
}

enum EDisableDeathFlags
{
	RDEATH_FRONT = 1,
	RDEATH_BACK = 2,
}

// Base class for almost all enemy actors.
// Adds handling for 'sneakable' actors and stealth/critical hit kills
class Nazi : Base
{
	Actor activationgoal;
	Actor body;
	Actor eyes;
	String DeathDamageType;
	String zombievariant;
	bool alerted;
	bool healing;
	bool user_sneakable;
	int healflags;
	int healloopcount;
	int perceptionfov;
	int user_perceptiontime;
	double perceptiondistance;
	int sneakableclosesightradius;
	int user_incombat;
	int user_static;
	state AimState, HealState, IdleState;
	bool sp;
	double frightscale;
	int crouchchance;
	String healsound;
	int healdistance;
	bool user_fadedeath;
	int user_noaltdeath;
	Actor closestplayer;
	bool wasused;
	int usetime;
	int activationcount;
	int gierdroplevel;
	String head;
	String user_spyitem;
	int user_spymsgindex;
	bool user_activatewhenshot;
	bool user_cansurrender;
	Sound IdleSound, LostSound, SightedSound;
	int surrendered;
	int hiddentime;
	spriteID defaultsprite;
	int naziflags;

	FlagDef CHASEONLY:naziflags, 0;
	FlagDef IGNOREFOG:naziflags, 1;

	Property Healer:healflags;
	Property PerceptionFOV:perceptionfov; // FOV used for NOTARGET sight checks (i.e., Gestapo and others who can see through scientist/gestapo uniforms)
	Property PerceptionTime:user_perceptiontime; // How many tics the player has to be in sight before NOTARGET fails - 0 means never see through NoTarget
	Property PerceptionDistance:perceptiondistance; // Range at which a perceptive enemy will first be able to see the player
	Property Sneakable:user_sneakable;
	Property SneakableCloseSightRadius:sneakableclosesightradius;
	Property ZombieVariant:zombievariant;
	Property FrightMultiplier:frightscale;
	Property CrouchChance:crouchchance;
	Property HealSound:healsound;
	Property HealDistance:healdistance;
	Property FadeDeath:user_fadedeath;
	Property NoAltDeath:user_noaltdeath;
	Property Head:head;
	Property ActivateWhenShot:user_activatewhenshot;
	Property IdleSound:idlesound;
	Property TargetLostSound:lostsound;
	Property TargetSeenSound:sightedsound;
	Property CanSurrender:user_cansurrender;
	
	// Level of gold drop when player is using Totale Gier
	// Drop Level 0 (Animals) - Nothing
	// Drop Level 1 (Normal soldiers) - 4-7 coins
	// Drop Level 2 (Elites, Waffens, and Paratroops) - 15-20 coins (5-10 coins + 1 coin bag)
	// Drop Level 3 (Minibosses) - ~50 coins (1 cross, goblet, or crown + 2 coin bags + 10 coins)
	Property TotaleGierDrop:gierdroplevel;

	Default
	{
		Height 64;
		Mass 35;
		Scale 0.65;
		PainChance 200;
		Speed 2;
		FastSpeed 0; // FastMonsters will not increase monster movement speed
		Monster;
		+BOSSDEATH
		+DONTGIB
		+DONTHARMSPECIES
		+FLOORCLIP
		+NOINFIGHTSPECIES
		+WINDTHRUST
		MaxTargetRange 2048.0;
		Species "Nazi";
		DamageFactor "Electric", 1.2;
		DamageFactor "Frag", 1.2; //increased damage from grenades & clusterbombs for Nazi related enemies - this fix TurretSoldiers [ozy81]
		DamageFactor "Trample", 2; //for truck sequences
		DamageFactor "Truck", 1.2; //for truck sequences
		DamageFactor "EnemyFrag", 0; //for mines deploy by enemies

		Base.DodgeAmount 6;
		Nazi.CrouchChance 4; // Chance of crouching when behind an obstacle, from 0-255
		Nazi.FrightMultiplier 1.0;
		Nazi.Healer 0;
		Nazi.PerceptionFOV 120;
		Nazi.PerceptionTime 0;
		Nazi.PerceptionDistance 256.0;
		Nazi.Sneakable False;
		Nazi.SneakableCloseSightRadius 64;
		Nazi.HealDistance 8;
		Nazi.Head "MS_UNKN";
		Nazi.TotaleGierDrop 1;
	}

	States
	{
		Active:
			"####" "#" 0 { SetState(SpawnState); }
		Look:
			"####" "#" 10 A_NaziLook();
			Loop;
		See:
		See.Normal: // Guard Walk Pattern
			"####" "#" 0 {
				user_incombat = True;
				if (bStandStill) { SetStateLabel("See.Stand"); }
			}
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); } // Jump to the actor's defined See state so any special handling can still happen each loop
		See.Fast: // SS Walk Pattern
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" AA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AA 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" BB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CC 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" DD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.Faster: // Officer Walk Pattern
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" A 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" A 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" B 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound();
			"####" B 1 A_NaziChase;
			"####" B 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" C 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" C 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" D 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound();
			"####" D 1 A_NaziChase;
			"####" D 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.MutantFaster: // Mutant Walk Pattern (same as Faster, but with steps on opposite frames)
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" A 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound();
			"####" A 1 A_NaziChase;
			"####" A 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" B 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" B 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" C 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound();
			"####" C 1 A_NaziChase;
			"####" C 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" D 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" D 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.MutantFasterAlt: // Mutant Walk Pattern, offset frames (BCDE walk instead of ABCD)
			"####" "#" 0 { user_incombat = True; }
			"####" B 1 A_NaziChase;
			"####" B 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound();
			"####" B 1 A_NaziChase;
			"####" B 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" C 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" C 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" D 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound();
			"####" D 1 A_NaziChase;
			"####" D 1 A_NaziChase(null, null);
			"####" E 1 A_NaziChase;
			"####" E 1 A_NaziChase(null, null);
			"####" E 1 A_NaziChase;
			"####" E 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.Boss: // Almost all bosses
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.Boss2: // Wounded bosses
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See.Wounded"); }
		See.BossGiant: // Hitler mostly
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.15, 1.0);
			"####" B 1 { A_NaziChase(); Radius_Quake(5, 2, 0, 5, 0); }
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.15, 1.0);
			"####" D 1 { A_NaziChase(); Radius_Quake(5, 2, 0, 5, 0); }
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.Boss3: // NaziLoper
			"####" "#" 0 { user_incombat = True; }
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" B 0 A_SpawnItemEx("TPortLightningWaveSpawner",0,0,8,0,0,0,0,0,160);
			"####" A 0 { return ResolveState("See"); }
		See.BossFast: // Faster bosses, like UberMutant
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" AA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AA 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" B 1 A_NaziChase;
			"####" BB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CC 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" D 1 A_NaziChase;
			"####" DD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.BossMech: // Mechs - same as Boss, but with quake and mech sound
			"####" "#" 0 { user_incombat = True; }
			"####" A 2 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Mech, 0.15, 1.0);
			"####" B 2 { A_NaziChase(); Radius_Quake(5, 2, 0, 5, 0); }
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" C 2 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" D 2 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Mech, 0.15, 1.0);
			"####" C 2 { A_NaziChase(); Radius_Quake(5, 2, 0, 5, 0); }
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" B 2 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.BossBleeding: // Totengraber_Wounded special one
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" B 0 { A_SpawnItemEx("NashGore_BloodSplasher", 0, 0, 0, frandom(-2.0, 2.0), frandom(-2.0, 2.0), frandom(1.0, 2.0), random(0, 360), SXF_TRANSFERTRANSLATION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE | SXF_ABSOLUTEVELOCITY, 0);}
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null, null);
			"####" CCC 0 A_SpawnItemEx("SkullBloodDrip",8,random(-4,-8),56,0,0,0,0,0);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null, null);
			"####" # 0 A_PlayStepSound(Base.Heavy, 0.3, 1.0);
			"####" D 0 { A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 0, frandom(0.1, 1.0) * RandomPick(-1, 1), frandom(0.1, 1.0) * RandomPick(-1, 1), frandom(0.0, 2.0), 0, SXF_TRANSFERTRANSLATION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE | SXF_ABSOLUTEVELOCITY, 0);}
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.Frightened: // Prisoners Pattern
			"####" "#" 0 { user_incombat = True; A_SetSpeed(6);}
			"####" A 1 A_NaziChase;
			"####" AA 1 A_NaziChase(null, null);
			"####" A 1 A_NaziChase;
			"####" AA 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" BB 1 A_NaziChase(null, null);
			"####" B 1 A_NaziChase;
			"####" BB 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CC 1 A_NaziChase(null, null);
			"####" C 1 A_NaziChase;
			"####" CC 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" DD 1 A_NaziChase(null, null);
			"####" D 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" DD 1 A_NaziChase(null, null);
			"####" A 0 { return ResolveState("See"); }
		See.Statisch: // Static Walk Pattern (non-moving, limited frame actor)
			"####" "#" 0 { user_incombat = True; }
			"####" A 1 A_NaziChase("Melee", "Missile");
			"####" A 0 { return ResolveState("See"); }
		See.Stand: // Standing state for basic Nazis
			"####" "#" 0 {
				user_incombat = True;
				sprite = defaultsprite;
				frame = SpawnState.frame;
			}
			"####" "#" 1 A_NaziChase("Melee", "Missile", CHF_DONTMOVE | CHF_NODIRECTIONTURN);
			"####" "#" 0 { return ResolveState("See"); }
		See.Sniper: // Sniper Walk Pattern (non-moving)
			"####" "#" 0 { user_incombat = True; }
			"####" "#" 1 A_NaziChase("Melee", "Missile", CHF_NODIRECTIONTURN);
			"####" F 0 { return ResolveState("See"); }
		See.Dodge:
			"####" A 0 {
				bShootable = true;
				candodge = true; // Tells the code in A_NaziChase that this actor should be allowed to dodge
			}
			"####" A 0 { return ResolveState("Dodge.Resume"); }
		Dodge.Right:
			"####" A 0 A_SetSize(-1, Default.height / 2);
			"####" ABCDEA 5;
			"####" A 0 { return ResolveState("Dodge.End"); }
		Dodge.Left:
			"####" A 0 A_SetSize(-1, Default.height / 2);
			"####" AEDCBA 5;
			"####" A 0 { return ResolveState("Dodge.End"); }
		Dodge.Crouch:
			"####" A 0 A_SetSize(-1, Default.height * 0.75);
			"####" A 5 A_LookEx(LOF_NOSEESOUND);
			"####" A 0 {
				if (crouchtimer < 175 && Random[stand](0, 255) > 4 && (!user_incombat || !InPlayerCrosshair()))
				{
					if (!target && crouchtimer % 35 == 0 ) { A_NaziLook(); } // Look for enemies periodically...
					crouchtimeout = 70;
					return ResolveState("Dodge.Crouch");
				}
				crouchtimer = 0;
				return ResolveState("Dodge.End");
			}
		Dodge.End:
			"####" A 2;
			"####" A 0 {
				sprite = defaultsprite;
				A_Face(target);
				A_SetSize(-1, Default.height);
				bNoPain = Default.bNoPain;
				DamageFactor = Default.DamageFactor;
				reactiontime = 0;
				dodging = false;
			}
			"####" A 0 {
				if (!target) { return ResolveState("Spawn"); }
				return ResolveState("Dodge.Resume");
			}
		Dodge.Resume:
			"####" A 0 { return ResolveState("See.Normal"); }
		Idle:
			"####" AAAAAAAA 1 A_Wander;
			"####" BBBBBBBB 1 A_Wander;
			"####" CCCCCCCC 1 A_Wander;
			"####" DDDDDDDD 1 A_Wander;
			"####" A 0
			{
				A_LookEx(LOF_NOSEESOUND); // Look at the end of every walk cycle, in case we wandered into a non-background sector
				if (Random(0, 2) == 0) { PlayActiveSound(); } // Play the active sound one third of the time
			}
			Loop;
		Pain:
			"####" H 6 A_NaziPain(256);
			"####" H 0 A_Jump(256,"See");
		Death.Surrender: //not just +FRIENDLY because we don't want them attacking their comrades
			"####" E 6 {
				if (eyes)
				{
					eyes.Destroy();
				}
			}
			"####" F 6 A_UnblockAndDrop();
			Goto Death.Surrender.MainLoop;
		Death.Surrender.MainLoop:
			"####" G 9;
		Death.Surrender.SubLoop:
			"####" G 0;
			"####" G 32 A_Jump(64, "Death.Surrender.Blink");
			"####" A 0 { return ResolveState("Death.Surrender.MainLoop"); }
		Death.Surrender.Blink:
			"####" F 8;
			"####" G 16;
			"####" F 8;
			"####" A 0 { return ResolveState("Death.Surrender.MainLoop"); }
		Death.FireBlondi: //here since they doesn't inherit NaziStandard
			"####" # 0 A_SetScale(1.2);
			"####" # 0 { return ResolveState("Death.FireDogs.Random"); }
		Death.FireDogs: //here since they doesn't inherit NaziStandard
			"####" # 0 A_SetScale(0.65);
		Death.FireDogs.Random: // Jump to here if you have an actor that needs a different scale set
			"####" # 0 {
				DeathDamageType = "Fire"; // Because the flamethrower guards are set to this state via jump, not damage
				sprite = GetSpriteIndex(Random() < 128 ? "DBRN" : "NRBD");
				bIsMonster = False; // Burned enemies can't be resurrected
			}
			"####" AA 10 Bright Light("ITBURNS1") { A_Wander(); }
			"####" BBC 6 Bright Light("ITBURNS3") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" D 6 Bright Light("ITBURNS1") { A_Wander(); A_StartSound("dog/death", CHAN_VOICE); }
			"####" E 6 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); A_NoBlocking(); }
			"####" FF 6 Bright Light("ITBURNS2") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
		Death.FireDogs.Smoke:
			"####" G 0 A_Jump(32,"Death.FireDogs.End");
			"####" G 2 Light("ITBURNS4");
			"####" G 4 Light("ITBURNS5");
			"####" G 3 Light("ITBURNS6");
			"####" G 5 Light("ITBURNS5");
			Loop;
		Death.FireDogs.End:
			"####" G -1;
			Stop;
		Disintegrate:
			"####" H 0 A_Jump(256,"Disintegration");
		Disintegrate.Alt1: //added in case we plan to have allied soldiers on Astrostein maps - ozy81
			"####" I 0 A_Jump(256,"Disintegration");
		Disintegrate.Alt2:
			"####" J 0 A_Jump(256,"Disintegration");
		Disintegration:
			"####" "#" 5
			{
				if (DeathSound != "astrostein/guard_death") { A_StartSound("astrostein/guard_death", CHAN_AUTO); }
				A_Scream();
				A_UnblockAndDrop();
			}
			"####" "#" 0 A_Jump(256,"Disintegration.FadeLoop");
		Disintegration.FadeLoop:
			"####" "#" 1 {
				int chunkx, chunky;
				[chunkx, chunky] = EffectBlock.GetBlock(pos.x, pos.y);
				if (!pmanager || level.time % max(1, pmanager.GetDelay(chunkx, chunky)) == 0) { A_SpawnItemEx("BaseLine", FRandom(0.8 * radius, -0.8 * radius), FRandom(0.8 * radius, -0.8 * radius), FRandom(0, 8), 0, 0, FRandom(1, 3), 0, 129, 0); }
				A_FadeOut(0.02);
			}
			Loop;
		MakeSneakable:
			"####" # 0 {
				if (health <= 0 || !bShootable) { return ResolveState("StaticFrame"); } // If it's dead, don't make a zombie, just freeze on the current frame and hope no one notices...

				user_sneakable = true;
				BeginPlay();

				return ResolveState("Spawn");
			}
		See.MakeAlertedForever:
			"####" # 0 {
				user_sneakable = false; // Enemies alerted by setting to this state won't go back to idle
				user_perceptiontime = 1; // And they will see through your disguise if you have one
			}
		See.MakeAlerted: // Naming the state like this allows you to use ACS to set actors to 'See.MakeAlerted' state, and non-Nazi class actors will cleanly fall back to the See state
		MakeAlerted:
			"####" # 0 {
				if (health <= 0 || !bShootable) { return ResolveState("StaticFrame"); } // If it's dead, don't make a zombie, just freeze on the current frame and hope no one notices...

				BecomeAlerted(target);
				return ResolveState("See");
			}
		Heal: // Placeholder state to avoid weird behavior if a healing actor isn't properly set up
			"####" H 5 {
				A_HealGoal();
				return ResolveState("See");
			}
		Alarm:
			"####" H 50 A_SetTics(interval);
			"####" H 0 A_Jump(256, "See");
		StaticFrame:
			"####" # -1;
			Stop;
		SpriteLookups: // Because the GetSpriteIndex function won't find sprites that aren't already used by a state in the current actor.
			BURN A 0;
			NRUB A 0;
			DBRN A 0;
			NRBD A 0;
			FIZZ A 0;
			ZZIF A 0;
	}

	// Function to consolidate default pain state actions.  See use above - can be used to eliminate a lot of existing copy/paste.
	void A_NaziPain(int alertrange = 0, bool StartSound = True, int offset = -8, Class<Actor> bloodspurt = "")
	{
		if (bloodspurt == "") { bloodspurt = "Pain_Overlay"; } // Handled here instead of in default above because spurts are in DECORATE, not ZScript, so aren't loaded until after this code, so can't be validated at load time

		A_SpawnItemEx(bloodspurt, scale.x + 3, 0, height + offset, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR); // Spawn pain overlay blood spurt

		if (bDormant) { return; } // Dormant actors should not do anything but bleed

		if (target && target.species == species) { target = null; return; }

		if (alertrange) { A_AlertMonsters(alertrange); } // Alert monsters in given range
		if (StartSound) { A_Pain(); } // Play pain sound unless passed 'false'

		if (target && user_sneakable && bFriendly) // If we attacked a sneakable actor who wasn't alerted...
		{
			// If we are the same species as what shot us, then just become alert and look for a target - otherwise, return fire!
			BecomeAlerted(target.species == species ? null : target); // Alert that actor
		}

		if (!bBoss && (!target || Distance3D(target) > 96))
		{
			frighttimeout += min(SpawnHealth() - health, 10);
			frightener = target;
		}
		reactiontime = 0;

		A_LookForGrenades();
	}

	void A_NaziLook()
	{
		if (bDormant || dodging || health <= 0) { return; }

		if (level.time > 35)
		{
			bool didnothavetarget = !target; // Do not call SoundAlert every 10 tics
			A_LookEx((user_sneakable || bFrightened || (bFriendly && !user_sneakable && Default.Species == "Nazi")) ? LOF_NOSEESOUND : 0); // Don't play see sound if you are a sneakable enemy - Their sound alert is handled elsewhere.

			if (bStandStill) { LookForPlayers(bLookAllAround); }

			if (target)
			{
				BoAVisibility vis = BoAVisibility(target.FindInventory("BoAVisibility"));
				if (vis) { vis.CheckVisibility(self); }
			}

			if (target && target.species == species || HitFriend()) { target = null; } // Ignore the target if it's the same species (normally "Nazi")
			if (target && didnothavetarget && user_incombat && SeeSound && !user_sneakable) { SoundAlert(target, false, 256); } // If the Nazi yells after seeing a target, actually alert enemies around him

			if (bStandStill) { SetStateLabel("See"); }
		}

		if (CheckSightOrRange(512)) { return; }

		if (!bFriendly)
		{
			// Check specifically for players via CheckSight in order to "see through" block-everything lines (which are usually windows)
			for (int p = 0; p < MAXPLAYERS; p++) // Iterate through all of the players and see if any are in sight
			{
				if (players[p].cheats & CF_NOTARGET) { continue; }

				Actor mo = players[p].mo;

				if (mo)
				{
					if (absangle(angle, AngleTo(mo)) <= 30)
					{
						if (DodgeState) { A_TryHide(); }

						if (AimState && (user_static || bAmbush) && !InStateSequence(CurState, FindState("Dodge.Crouch")))
						{
							frame = AimState.frame;
						}
					}

					if (IsFriend(mo)) { continue; }
					if (Distance3d(mo) > 160.0) { continue; }
					if (abs(deltaangle(angle, AngleTo(mo))) > 32.5) { continue; }
					if (!CheckSight(mo, SF_SEEPASTBLOCKEVERYTHING | SF_SEEPASTSHOOTABLELINES)) { continue; }

					if (mo is "TankPlayer") { target = TankPlayer(mo).turret; }
					else { target = mo; }

					if (!InStateSequence(CurState, SeeState)) { SetStateLabel("See"); }
				}
			}
		}

		if (bFriendly && !user_sneakable && Default.Species == "Nazi")
		{
			if (!closestplayer) { closestplayer = FindClosestPlayer(self, IgnoreFriendlies:!bFriendly); }

			if (lastheard && CheckSight(lastheard, true)) { SetState(SeeState); } // If an alerting actor is in sight, become active
			else if (activationcount == 0 && !CanBeSeen() && closestplayer && closestplayer.IsVisible(self, true)) // if you haven't been used yet and there are no other enemies around
			{
				A_Face(closestplayer);
				if (Random() < 6) { A_StartSound("spy/attention", CHAN_VOICE, 0, 0.5); } // play an attention-getting sound
			}
		}

		if (!Default.bLookAllAround && level.time % interval == 0)
		{
			FLineTraceData trace;
			if (LineTrace(angle, 256.0, pitch, TRF_THRUHITSCAN | TRF_ALLACTORS, Height * 0.9, 0.0, 0.0, trace) && trace.HitType == TRACE_HitWall)
			{
				// If it's a mirror, look all around...  
				//  This isn't perfect, but will work in situations where we have a guard with his back to the
				//  door who is facing a mirror - better than him being unresponsive to the player until hit 
				bLookAllAround = (trace.HitLine.special == 182 || (trace.HitLine.special == 80 && trace.HitLine.args[0] == 406));
			}
		}
	}

	void A_NaziChase(statelabel melee = "None", statelabel missile = "None", int flags = 0)
	{
		if (dodging || health <= 0) { return; }
		if (bDormant) { SetState(SpawnState); return; } // Dormant actors should not wake up even if they're somehow placed in their See state

		sprite = defaultsprite; // Make sure our sprite isn't crouched or rolling

		if (melee == "None") { melee = "Melee.Aimed"; }
		if (missile == "None") { missile = "Missile.Aimed"; }

		if (target && Distance3D(target) < 256) { user_static = 0; }

		if (AimState && (user_static || bAmbush))
		{
			flags |= CHF_DONTMOVE | CHF_NODIRECTIONTURN;

			if (!InStateSequence(CurState, SeeState)) { frame = AimState.frame; }
			A_SetTics(Random[StandDelay](1, 5));

			A_FaceTarget();
			reactiontime = 0;
		}

		if ( // Chance to roll if the player is aiming at this actor
			candodge &&
			!bStandStill &&
			(user_sneakable || !bFriendly) &&
			(!maxdodge || dodgecounter < maxdodge) &&
			!InStateSequence(CurState, FindState("Dodge.Crouch"))
		)
		{
			if (InPlayerCrosshair() && Random[dodgeskip](0, 255) < 64)
			{
				user_static = 0; // Un-set frozen state

				// Try to do a side roll
				if (A_DoSideRoll()) { return; } // Sprite and state changes and thrusting handled internally by the A_DoSideRoll() function
			}
		}

		if (user_sneakable && bFriendly && level.time % interval == 0) { A_LookForBodies(); }

		if (target && (target is "GrenadeBase") && Speed > 0)
		{
			if (user_static && (flags & CHF_DONTMOVE)) { flags &= ~(flags & CHF_DONTMOVE); } // Make static enemies flee from grenades and other dangerous things
			if (candodge && Distance3D(target) < radius + 64 + target.radius) { A_DoSideRoll(force:true); } // Roll away if it's close
			else { A_Chase(null, null, flags); } // If running from a grenade, just run away and don't fire
		}
		else
		{
			if (!bFriendly && closestplayer && target && closestplayer != target && Random[switchtarget](0, 100) < 20 && CheckSight(closestplayer) && Distance3D(closestplayer) < Distance3D(target)) { target = closestplayer; }
			if (target is "TankPlayer") { target = Random(0, 1) ? Actor(TankPlayer(target).turret) : Actor(TankPlayer(target).treads); }

			if (!closestplayer) { closestplayer = FindClosestPlayer(self, IgnoreFriendlies:!bFriendly); }

			if (!bFriendly && user_cansurrender && closestplayer && CheckSight(closestplayer) && Distance3D(closestplayer) < 384.0) // last enemy in the room can surrender
			{
				int nazicount = CanBeSeen(1);
				if (!nazicount && Random[surrender](0, 255) < 2)
				{
					DoSurrender(closestplayer);
				}
			}
			
			// If a Nazi is flagged as friendly, he will turn on his fellow Nazis if there's only 1 other Nazi around
			if (bFriendly && !user_sneakable && Default.Species == "Nazi")
			{
				int nazicount = CanBeseen(1);

				if (nazicount < 2)
				{
					if (!nazicount) // nazicount == 0
					{
						Species = Default.Species;
						bFrightened = false;
						SetState(SpawnState); // return to Spawn state
					}
					else
					{
						Species = "Ally";
						bFrightened = false;
						if (closestplayer && closestplayer.player && closestplayer.player.attacker && CheckSight(closestplayer.player.attacker))
						{
							target = closestplayer.player.attacker;
						}

						A_Chase(melee, missile, flags);
					}
				}
				else
				{
					Species = Default.Species;
					// Make him run away from you
					if (!closestplayer) { closestplayer = FindClosestPlayer(self, IgnoreFriendlies:!bFriendly); }
					target = closestplayer; // +FRIGHTENED will make this guy run away from his target.
					bFrightened = true;
					A_Chase(null, null, flags);
				}
			}
			else if (target == patrolgoal)
			{
				A_Chase(null, null, flags); // Ensure that you don't attack if you are going after a navigation goal
			}
			else
			{
				if (target)
				{
					BoAVisibility vis = BoAVisibility(target.FindInventory("BoAVisibility"));
					if (vis) { vis.CheckVisibility(self); }
				}

				if (bChaseOnly && !bIgnoreFog)
				{
					A_Chase(null, null, flags);
				}
				else
				{
					A_Chase(melee, missile, flags);
				}
			}
		}

		if (candodge && !crouchtimeout && !goal) { A_TryHide(); }
	}

	virtual void DoSurrender(Actor source)
	{
		if (bCountKill) { ClearCounters(); }
		user_ForceWeaponDrop = true;
		surrendered = true;

		health = 1;
		vel *= 0;

		// 1 in 8 chance that surrendering enemies will urinate
		if (Random(0, 7) == 0)
		{
			Actor pee = Spawn("PeePool", pos);
			if (pee) { pee.master = self; }
		}

		State SurrenderSpriteState = FindState("SurrenderSprite");
		if (SurrenderSpriteState) { sprite = SurrenderSpriteState.sprite; }

		if (source) { AchievementTracker.CheckAchievement(source.PlayerNumber(), AchievementTracker.ACH_SURRENDERS); }

		SetStateLabel("Death.Surrender");
	}

	// A_NaziChase with CheckLOF
	void A_MeleeMutantChase(statelabel melee = "None", statelabel missile = "None", double maxrange = 1024, double minrange = 512, int chaseFlags = 0, int CLOFFlags = CLOFF_SKIPOBSTACLES | CLOFF_IGNOREGHOST)
	{
		if (CheckLOF(CLOFFlags, maxrange, minrange))
		{
			A_NaziChase(melee, missile, chaseFlags);
		}
		else
		{
			A_NaziChase(melee, null, chaseFlags);
		}
	}

	state A_CheckFadeDeath()
	{
		if (user_fadedeath == TRUE) { return ResolveState("Death.Fade"); }

		return ResolveState(null);
	}

	state A_CheckAltDeath(int chance = 64)
	{
		if (!user_noaltdeath && Random[altdeath](0, 255) < chance) { return ResolveState("Death.Alt1"); }

		return ResolveState(null);
	}

	state A_RandomDeathAnim(int chance = 64)
	{
		if (Random[altdeath](0, 255) < chance)
		{
			state FrontDeath = FindState("Death.Front", true);
			state BackDeath = FindState("Death.Back", true);
			state HeadDeath = FindState("Death.Headshot", true);
			int sum = !!FrontDeath + !!BackDeath + !!HeadDeath;
			if (sum == 0) { return null; } //actor has no altdeaths
			int diceroll = Random[altdeath](0, 255);
			int cumulative = 0;
			if (FrontDeath)
			{
				++cumulative;
				if (diceroll <= (cumulative * 256 / sum)) { Vel.XY = (0, 0); return FrontDeath; }
			}
			
			if (BackDeath)
			{
				++cumulative;
				if (diceroll <= (cumulative * 256 / sum)) { return BackDeath; }
			}
			
			if (HeadDeath)
			{
				++cumulative;
				if (diceroll <= (cumulative * 256 / sum)) { return HeadDeath; }
			}
		}

		return null;
	}

	bool InPlayerCrosshair()
	{
		BoAPlayer p;

		p = BoAPlayer(target);
		if (!p) { p = BoAPlayer(lastenemy); }
		if (!p) { p = BoAPlayer(lastheard); }

		// If the actor is in a player (that they know about!)'s crosshair, and the player is holding a non-melee-flagged weapon...
		if (p && p.CrosshairTarget == self && p.player.ReadyWeapon && !Weapon(p.player.ReadyWeapon).bMeleeWeapon && !(Weapon(p.player.ReadyWeapon) is "NullWeapon")) { return true; }

		return false;
	}

	void A_TryHide(int chance = -1)
	{
		if (chance < 0) { chance = clamp(crouchchance + crouchchance * bFrightened, 0, 255); }

		if (Random[duck](0, 255) > chance) { return; }

		for (int r = 0; r <= 64; r += 16)
		{
			if (CheckForBarrier(height / 4, radius + r)) { DoCrouch(); return; }
		}
	}

	bool CheckForBarrier(double height = 16.0, double range = 64.0)
	{
		FLineTraceData trace;

		double destangle = angle;
		double destpitch = pitch;

		if (target) // If you have a target, check between you and your target
		{
			angle = AngleTo(target);
			pitch = PitchTo(target);
		}

		LineTrace(angle, range, pitch, TRF_THRUACTORS | TRF_THRUHITSCAN, height, 0.0, 0.0, trace);
		// If it's a wall, it must be solid...  But don't crouch in front of 1-sided walls...
		if (trace.HitType == TRACE_HitWall && trace.HitLine && !(trace.HitLine.flags & line.ML_BLOCKING))
		{
			// And only duck if the other side of the blocking wall (or a good enough approximation) is inside the map...
			if (level.IsPointInMap(pos + (RotateVector((range + 32.0, 0), angle), height))) { return true; }
		}

		LineTrace(angle, range, pitch, TRF_SOLIDACTORS | TRF_THRUHITSCAN, height, 0.0, 0.0, trace);
		// Check if there's a solid actor (that's not an enemy) in front of you...
		if (trace.HitType == TRACE_HitActor && trace.HitActor && !IsHostile(trace.HitActor) && !trace.HitActor.bIsMonster) { return true; }

		return false;
	}

	void DoCrouch()
	{
		if (!DodgeState || InStateSequence(CurState, FindState("Dodge.Crouch"))) { return; }

		spriteID dodgesprite = DodgeState.sprite;
		if (dodgesprite) { sprite = dodgesprite; }

		SetStateLabel("Dodge.Crouch");
		A_SetTics(Random(0, 35));
	}

	state A_LookForBodies()
	{
		if (goal && goal is "PatrolPoint")
		{
			patrolgoal = goal; // Save the navigation goal if one was set
		}

		if (!patrolgoal) // Otherwise, make a new navgoal at the actor's origin so that it can come back.
		{
			patrolgoal = Spawn("PatrolPoint", pos);
			patrolgoal.args[0] = -1;
			patrolgoal.args[1] = 0x7FFFFFFF;
			patrolgoal.angle = angle;
		}

		ThinkerIterator Finder = ThinkerIterator.Create("Nazi", STAT_DEFAULT - 5);
		Nazi mo;

		while ( (mo = Nazi(Finder.Next())) )
		{
			if (!IsCorpse(mo)) { continue; }

			if (goal && Distance3d(mo) > Distance3d(goal)) { continue; }

			goal = mo;
		}

		// A Second iterator to account for the non-sneakables...
		Finder = ThinkerIterator.Create("Nazi", STAT_DEFAULT);

		while ( (mo = Nazi(Finder.Next())) )
		{
			if (!IsCorpse(mo)) { continue; }

			if (goal && Distance3d(mo) > Distance3d(goal)) { continue; }

			goal = mo;
		}

		if (goal)
		{
			if (healflags) { body = goal; return ResolveState("See"); }
			else if (goal is "Nazi")
			{
				Speed = Default.Speed + Random(1, 2); // Walk a little faster
				if (Distance3D(goal) < 96)
				{
					BecomeAlerted(goal.target);
				}
			}
		}

		return ResolveState(null);
	}

	void A_LookForGrenades()
	{
		if (dodging || (!CheckIfSeen() && CheckRange(512.0, true))) { return; }

		Actor grenade = ThingTracker.LookForGrenades(self);

		if (!grenade) { return; }

		if (target != grenade && !bFrightened)
		{
			target = grenade;
			if (user_sneakable && !alerted) { BecomeAlerted(target); } // If sneakable, alert them
			else if (user_incombat && !bFriendly && !((grenade is "Whizzer"))) { A_StartSound(SeeSound, CHAN_VOICE); } // Play SeeSound if the enemy isn't a friendly
		}

		if (timeout <= 0)
		{
			if (grenade.bMissile) { movedir = (grenade.movedir + RandomPick(1, 2, 6, 7)) % 8; } // Pick a random direction away from the shooter and the missile's path
			else
			{
				if (target) { NewChaseDir(); }
				else { RandomChaseDir(); }
			}

			FaceMovementDirection();

			timeout = 70;
		}

		int feardistance = int(grenade.radius + (GrenadeBase(grenade) ? GrenadeBase(grenade).feardistance : 256));
		frighttimeout = int(min(feardistance / 2, 140) * frightscale); // Be frightened for a few seconds...  Less if there's a small fear distance/radius
		frightener = grenade;

		dodgetimeout = 350; // No rolling while scared and running away

		Speed = Default.Speed + Random(1, 2); // Walk/run a little faster to get away

		if (!InStateSequence(CurState, SeeState) && health > 0) { SetStateLabel("See"); } 
	}

	bool IsCorpse(Actor mo)
	{
		if (
			!mo.bIsMonster ||
			mo.health > 0 ||
			mo.bDormant
		) { return false; }

		if (healflags)
		{
			if (
				(
					Nazi(mo) &&
					(				
						Nazi(mo).healing ||
						Nazi(mo).DeathDamageType ~== "Fire"
					)
				) ||
				!IsVisible(mo, True) ||
				!mo.FindState("Raise") ||
				Distance3d(mo) > 1024
			) { return false; }

			if (healflags & HLR_ALLIES)
			{
				if (
					(!bDontGib && mo.health < mo.GetGibHealth()) ||
					mo.bFriendly != bFriendly ||
					mo.bBoss ||
					(Base(mo) && Base(mo).noheal)
				) { return false; }
			}

			if (healflags & HLR_ZOMBIES)
			{
				if (!Nazi(mo) || Nazi(mo).zombievariant == "") { return false; }
			}
		}
		else if (
			Distance3d(mo) > 512 ||
			(mo.species != species)
		) { return false; }

		return true;
	}

	// Initialize actor
	override void BeginPlay()
	{
		if (user_sneakable)
		{
			ChangeStatNum(Thinker.STAT_DEFAULT - 5); // Make these tic before the alert lights for checking logic purposes
		}

		// Set the actor's aim state (first frame of attack animation) for static and AMBUSH actors
		AimState = FindState("Missile.Aimed");
		if (!AimState) { AimState = FindState("Melee.Aimed"); }

		HealState = FindState("Heal");
		IdleState = FindState("Idle");

		interval = Random[pollinterval](35, 140);
	}

	override void PostBeginPlay()
	{
		// If it's sneakable, spawn a set of the sneakeable eyes and mark it as friendly (and make the actor never infight)
		if (user_sneakable)
		{
			bFriendly = True;
			bNeverTarget = True; // A bit of a hack, but it works...  Will cause issues if FRIENDLY actors ever need to interact with sneakable actors
			[sp, eyes] = A_SpawnItemEx("SneakableGuardEyesIdle", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_NOCHECKPOSITION, 0, tid);
		}
		else if (bFriendly && !user_sneakable && Default.Species == "Nazi") { bNeverTarget = true; } // Spies will never be targeted
		else if ((bFriendly && Species == "Nazi") || SneakableActors()) // If there are sneakable actors or spies in the level, no Nazi actors will be targetable - fixes targeting of non-sneakables by idle (friendly) sneakables
		{ // This will break normal expected friendly monster behavior!
			bNeverTarget = True;
		}

		if (frightscale && !speed) { frightscale = 0.0; }

		if (!defaultsprite) { defaultsprite = SpawnState.sprite; }
/*
		if (!bBoss)
		{
			let footsteps = BoAFootsteps(GiveInventoryType("BoAFootsteps"));
			if (footsteps) { footsteps.stepdistance = 36; }
		}
*/
		Super.PostBeginPlay();
	}

	void DoGierDrops()
	{
		if (gierdroplevel > 0 && target && target.player && target.FindInventory("GierToken"))
		{
			// Do Totale Gier coin drop
			// Drop coins
			int mincoins = 4;
			int maxcoins = 7;
			if (gierdroplevel == 2)
			{
				mincoins = 5;
				maxcoins = 10;
			}
			else if (gierdroplevel == 3)
			{
				mincoins = 10;
				maxcoins = 10;
			}
			for (int c = 1; c < Random(mincoins, maxcoins); c++)
			{
				Actor coin = Spawn("CoinDrop", pos + (Random(-4, 4), Random(-4, 4), 0));

				if (coin)
				{
					coin.Vel3DFromAngle(Random(4, 8), Random(0, 359), Random(-75, -90));
					coin.ClearCounters();
				}
			}
			// Drop additional treasures
			if (gierdroplevel == 2)
			{
				Actor coin = Spawn("CoinBagDrop", pos + (Random(-4, 4), Random(-4, 4), 0));
				if (coin)
				{
					coin.Vel3DFromAngle(Random(4, 8), Random(0, 359), Random(-75, -90));
					coin.ClearCounters();
				}
			}
			else if (gierdroplevel == 3)
			{
				static const class<CoinDrop> randomdrops[] = {"CrossDrop", "GobletDrop", "CrownDrop"};
				// Random treasure drop
				for (int c = 0; c < 1; c++)
				{
					class<CoinDrop> dropClass = randomdrops[Random(0, randomdrops.Size() - 1)];
					Actor coin = Spawn(dropClass, pos + (Random(-4, 4), Random(-4, 4), 0));
					if (coin)
					{
						coin.Vel3DFromAngle(Random(4, 8), Random(0, 359), Random(-75, -90));
						coin.ClearCounters();
					}
				}
				// Drop 2 coin bags
				for (int c = 0; c < 2; c++)
				{
					Actor coin = Spawn("CoinBagDrop", pos + (Random(-4, 4), Random(-4, 4), 0));
					if (coin)
					{
						coin.Vel3DFromAngle(Random(4, 8), Random(0, 359), Random(-75, -90));
						coin.ClearCounters();
					}
				}
			}
		}
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
		DoGierDrops(); // AActor::Die sets target to killer

		String mod = (inflictor && inflictor.paintype) ? inflictor.paintype : MeansOfDeath; // Get the damage type

		if (source.player)
		{
			// Achievement for killing a boss with kicks
			if (bBoss && inflictor is "KickPuff") { AchievementTracker.CheckAchievement(source.PlayerNumber(), AchievementTracker.ACH_DISGRACE); }

			// Achievement for killing enemies with the shovel
			if (inflictor is "ShovelPuff" && Default.species == "Nazi" && !(self is "MutantStandard")) { AchievementTracker.CheckAchievement(source.PlayerNumber(), AchievementTracker.ACH_SHOVEL); }

			// Achievement for sniping over long range
			if (inflictor && inflictor is "Kar98KTracer2" && Distance3D(source) >= 6000) { AchievementTracker.CheckAchievement(source.PlayerNumber(), AchievementTracker.ACH_CLEARSHOT); }

			// Achievement for killing a loper only using the sword
			if (NaziLoper(self) && inflictor is "SwordPuff" && !NaziLoper(self).noachievement[source.PlayerNumber()]) { AchievementTracker.CheckAchievement(source.PlayerNumber(), AchievementTracker.ACH_CHEVALIER); }

			if ((health < GetGibHealth() || bExtremeDeath) && !bNoExtremeDeath) {  AchievementTracker.CheckAchievement(source.PlayerNumber(), AchievementTracker.ACH_GIBEMALL); }
		}

		// Achievement for killing three enemies with the same placeable mine
		if (mod == "FriendlyFrag" && inflictor.master) { AchievementTracker.CheckAchievement(inflictor.master.PlayerNumber(), AchievementTracker.ACH_WATCHYOURSTEP); }

		// Make sure the sneakable enemies that were killed without being alerted to the
		// player still count as kills, since there is special handling to add them to
		// the level's max kill count, and FRIENDLY monsters don't get counted as kills.
		if (user_sneakable && bFriendly && bCountKill)
		{
			level.killed_monsters++;
		}
	}

	// Hijack the damage calls in order to implement stealth kills and critical hits
	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		// Make sure the sprite is correct if we were dodging
		if (!bNoPain && (DodgeState && sprite == DodgeState.sprite) || surrendered) { sprite = defaultsprite; }

		Inventory vis;

		if (user_sneakable && bDormant) { bDormant = False; } // Pain wakes up a dormant sneakable actors

		String currentDamage = (inflictor && inflictor.paintype) ? inflictor.paintype : mod; // Get the damage type

		if (currentDamage ~== "SilentKnifeAttack" && !bBoss) // If the attack was with the knife (and this is not a boss actor - they can't be one-hit killed!)
		{
			if (bFriendly)
			{
				if (!activationcount && (user_sneakable || !(Default.Species == "Ally" || Default.Species == "PlayerFollower"))) // If this is a non-Ally sneakable actor who isn't active yet
				{ // Stealth kill, remove the sneakable eyes, alert a medium radius, and kill the actor
					A_Log(StringTable.Localize("$STEALTH"));
					A_RemoveChildren(TRUE, RMVF_EVERYTHING, "None", "Eyes");
					A_RemoveChildren(TRUE, RMVF_EVERYTHING, "None", "AlertMarker");
					bFriendly = False; // Force to not friendly so that they will count as a kill and be healable.
					if (self is "NaziStandard") { DeathSound = "Nazi/Gurgle"; } // Reset death sound to gurgle
					SoundAlert(source, false, 192);
					damage = health;
					flags |= DMG_FORCED;
					user_noaltdeath = True;

					// Achievement for knife sneak attacks
					AchievementTracker.CheckAchievement(inflictor.PlayerNumber(), AchievementTracker.ACH_ASSASSIN);
				}
				else {} // Don't change behavior for Allied FRIENDLY actors
			}
			else if (user_incombat) // If the actor has already been in its See state
			{
				if (self is "NaziStandard") { A_StartSound("Nazi1/Pain", CHAN_VOICE, 0, FRandom(0.2, 0.4), ATTN_NORM); } // Play quiet pain sound
				SoundAlert(source, false, 64); //ozy - only if near // Alert small radius
			}
			else // Otherwise, this attack was the equivalent of Stealth Kill for non-sneakable enemies
			{
				user_incombat = True;
				A_Log(StringTable.Localize("$CRITICAL"));
				if (self is "NaziStandard") { DeathSound = "Nazi/Gurgle"; } // Reset death sound to gurgle
				SoundAlert(source, false, 192);
				damage = health;
				flags |= DMG_FORCED;
				user_noaltdeath = True;

				// Achievement for knife sneak attacks
				AchievementTracker.CheckAchievement(inflictor.PlayerNumber(), AchievementTracker.ACH_ASSASSIN);
			}
		}

		if (source)
		{
			if (source is "MovingTrailBeam") { source = source.master; }

			vis = source.FindInventory("BoAVisibility");
		}
		else { source = self; }

		if (vis) { BoAVisibility(vis).visibility = 200; }

		if (user_sneakable && bFriendly) // If we attacked a sneakable actor who wasn't alerted...
		{
			BecomeAlerted(source); // Alert that actor
		}

		if (user_activatewhenshot && bDormant && !bFriendly && source && source.player) { bDormant = false; } // Wake up dormant enemies that are shot by a player

		int damageamt = Super.DamageMobj(inflictor, source, damage, mod, flags, angle); // Get the damage amount from the real DamageMobj function

		if (health <= 0) // If we killed the actor...
		{
			if (user_sneakable) // and it was a sneakable actor...
			{
				A_RemoveChildren(TRUE, RMVF_EVERYTHING, "None", "Eyes"); // Remove the sneakable eyes
				A_RemoveChildren(TRUE, RMVF_EVERYTHING, "None", "AlertMarker"); // Remove the alert marker
			}
		
			if (user_perceptiontime > 0) // or if it was a perceptive actor...
			{
				if (vis) { BoAVisibility(vis).suspicion = 0; } // Reset suspicion level to zero
			}

			// Fix dead enemies being invisible if you kill them while dodging
			if (DodgeState && sprite == DodgeState.sprite)
			{
				sprite = defaultsprite;
			}

			DeathDamageType = currentDamage;

			if (master && master is "WaveSpawner") { A_QueueCorpse(); } // Queue wave spawned corpses for removal
		}

		if (Species == "Nazi" && bFriendly && source.player) // Friendly Nazis might become unfriendly if you shoot them
		{
//			if (developer) { console.printf("You shot a friendly spy!"); }

			if (Random() < 64)
			{
				bFriendly = false;
				bNeverTarget = false;
			}
		}

		if (damageamt && !bDormant && OkayToSwitchTarget(source))
		{
			lastenemy = target;
			target = source; // Target the source if it wasn't friendly or of the same species
			SoundAlert(source, false, 192);
		}

		if (source.player && NaziLoper(self) && !(inflictor is "SwordPuff")) { NaziLoper(self).noachievement[source.PlayerNumber()] = true; }

		return damageamt; // Function returns amount of damage received by the actor
	}

	override bool OkayToSwitchTarget(Actor other)
	{
		if (bFriendly == other.bFriendly && species == other.species .. "Tank") { return false; }
		
		return Super.OkayToSwitchTarget(other);
	}

	// Handling for alerting sneakable actors
	void BecomeAlerted(Actor newtarget = null)
	{
		if (health <= 0 || !bShootable) { return; } // If it's dead, don't do anything

		if (newtarget && newtarget.species == species) { return; } // Ignore actors of the same species as targets

		if (!alerted)
		{
			A_SpawnItemEx("AlertMarker", 0, 0, 64, 0, 0, 0, 0, SXF_SETMASTER);
			if (!bBoss)
			{
				if (sightedsound) { A_StartSound(sightedsound, CHAN_VOICE); }
				else { A_StartSound(SeeSound, CHAN_VOICE); }
			}
			else { A_StartSound(SeeSound, CHAN_VOICE); }

			ResetDodge(true);
			dodgecounter = 0;

			alerted = true;
			user_incombat = true;
		}

		A_RemoveChildren(TRUE, RMVF_EVERYTHING, "None", "Eyes"); // Get rid of the passive guard eyes
		bFriendly = False; // Set unfriendly

		if (goal)
		{
			if (goal is "PatrolPoint")
			{
				patrolgoal = goal; // Save the navigation goal if one was set
			}
			else { goal = null; }
		}

		if (!patrolgoal) // Otherwise, make a new navgoal at the actor's origin so that it can come back.
		{
			patrolgoal = Spawn("PatrolPoint", pos);
			patrolgoal.args[0] = -1;
			patrolgoal.args[1] = 0x7FFFFFFF;
			patrolgoal.angle = angle;
		}

		target = newtarget; // Set target to the player the eyes saw

		if (activationgoal)
		{
			goal = activationgoal;
			target = activationgoal;
			LastEnemy = newtarget;
			bChaseGoal = True;
			Speed = Default.Speed + Random(1, 2);
		}
		else
		{
			Speed = Default.Speed;
		}

		reactiontime = 0; // Make the enemy respond to seeing the player right away
		A_AlertMonsters(512); // Alert an extra-large radius
		[sp, eyes] = A_SpawnItemEx("SneakableGuardEyesAlerted", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_NOCHECKPOSITION, 0, tid); // Spawn active guard eyes
		if (target && target.GetSpecies() == GetSpecies()) { target = null; SetStateLabel("Spawn"); } // Don't go after same-species targets

		if (!InStateSequence(CurState, SeeState)) { SetStateLabel("See"); } // Go to See state and start chasing the player (or wandering if target wasn't set for some reason)
	}

	void BecomeIdle()
	{
		if (health <= 0 || !bShootable) { return; }

		if (user_sneakable)
		{
			alerted = false;
			bFriendly = True;

			goal = patrolgoal; // Restore any navigation goal if there was one set
			target = patrolgoal;

			[sp, eyes] = A_SpawnItemEx("SneakableGuardEyesIdle", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_NOCHECKPOSITION, 0, tid);

			sprite = defaultsprite;

			if (goal && target) { if (!InStateSequence(CurState, SeeState)) { SetStateLabel("See"); } }
			else { SetStateLabel("Spawn"); }
		}
	}

	void A_UnblockAndDrop()
	{
		bool dodrops = false;

		if (user_ForceWeaponDrop && surrendered < 2)
		{
			DropItem drops = GetDropItems();
			DropItem item;

			if (drops != null)
			{
				for (item = drops; item != null; item = item.Next)
				{
					String itemName = String.Format("%s", item.Name); // Don't know why I have to do this and the Length check, but 'DropItem ""' crashes without it, even if I check for != "", != null, etc...
					if (itemName.Length() > 0 && item.Name != 'None')
					{
						Actor drop = Spawn(item.Name); // See if it spawns in order to validate the name...  Since there's no FindClass function exposed?

						if (drop is "Weapon") // If it is a weapon, drop the item
						{
							int amt = item.Amount;

							A_DropItem(item.Name, amt);
						}

						drop.Destroy(); // Destroy the placeholder spawned item
					}
				}
			}
		}
		else if (user_sneakable && surrendered < 2)
		{
			DropItem drops = GetDropItems();
			DropItem item;

			double dropfactor = G_SkillPropertyFloat(SKILLP_DropAmmoFactor);
			if (dropfactor < 0) { dropfactor = 0.5; }

			if (drops != null)
			{
				for (item = drops; item != null; item = item.Next)
				{
					String itemName = String.Format("%s", item.Name); // Don't know why I have to do this and the Length check, but 'DropItem ""' crashes without it, even if I check for != "", != null, etc...
					if (itemName.Length() > 0 && item.Name != 'None')
					{
						Actor drop = Spawn(item.Name); // See if it spawns in order to validate the name...  Since there's no FindClass function exposed?

						if (Weapon(drop)) // Only drop weapons, no extra ammo, grenades, etc.
						{
							int amt = item.Amount;

							if (amt <= 0)
							{
								amt = Weapon(drop).AmmoGive1 > 0 ? Weapon(drop).AmmoGive1 : Weapon(drop).AmmoGive2; // Default to affecting AmmoType1, with fallback to AmmoType2
								amt = max(int(amt * (dropfactor / 2)), 0); // Worst case, drop a weapon with zero ammo
							}

							A_DropItem(item.Name, amt);
						}

						drop.Destroy(); // Destroy the placeholder spawned item
					}
				}
			}
		}
		else
		{
			if (surrendered < 2) { dodrops = true; }
		}

		if (surrendered) { surrendered++; }

		A_NoBlocking(dodrops);
	}

	void A_GibsUnblockAndDrop(int head = 2, Class<Actor> bloodspurt = "")
	{
		if (bloodspurt == "") { bloodspurt = "Pain_Overlay"; } // directly from A_NaziPain - ozy81
		A_SpawnItemEx(bloodspurt, scale.x + 3, 0, height + 48, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR); // Spawn head spurt
		A_SpawnItemEx("HeadGibsRing", scale.x + 3, 0, height + head, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR); // Spawn head gibs

		A_UnblockAndDrop();
	}

	void A_HealGoal()
	{
		if (healsound.length()) { A_StartSound(healsound, CHAN_AUTO); }

		if (Nazi(goal) && healflags & HLR_ZOMBIES)
		{
			if (Nazi(goal).zombievariant != "")
			{
				goal = Base(goal).ReplaceWith(Nazi(goal).zombievariant, "Raise");
			}
		}

		if (goal) { RaiseActor(goal, RF_NOCHECKPOSITION | RF_TRANSFERFRIENDLINESS); }

		if (Nazi(goal))
		{
			if (Nazi(goal).user_sneakable) { Nazi(goal).BecomeAlerted(target); } // If it's a sneakable actor, make it alert
			Nazi(goal).healing = false;
			Nazi(goal).ResetDodge(true); // Reset the dodge timeout
		}

		if (goal) // Just to be sure, make the resurrected actor allied to the healing actor...
		{
			// Unlink blood pools from the revived actor
			ThinkerIterator it = ThinkerIterator.Create("BloodPool2", Thinker.STAT_DEFAULT);
			Actor mo;

			while (mo = Actor(it.Next())) { mo.master = null; }

			goal.BeginPlay();
			goal.bInvulnerable = false;
			goal.species = species;
			goal.master = self;
			goal.target = null;
			goal.CopyFriendliness(self, false);
		}

		body = null;
		goal = null;

		ResetDodge(true); // Reset the dodge timeout
	}

	// Wrapper for A_SpawnItemEx so that items can be spawned at the actor's goal in Decorate
	void A_SpawnAtGoal(class<Actor> itemtype, double xofs = 0, double yofs = 0, double zofs = 0, double xvel = 0, double yvel = 0, double zvel = 0, double angle = 0, int flags = 0, int failchance = 0, int tid=0)
	{
		Actor spawntarget = goal;
		if (!spawntarget) { spawntarget = self; }
		spawntarget.A_SpawnItemEx(itemtype, xofs, yofs, zofs, xvel, yvel, zvel, angle, flags, failchance, tid);
	}

	override void Tick()
	{
		if (manager)
		{
			int cullinterval = manager.Culled(pos.xy);
			if (cullinterval > 8 || cullinterval == -1) { Thinker.Tick(); return; }
			else if (cullinterval > 6) { Actor.Tick(); return; }
			else if (cullinterval > 4) { Super.Tick(); return; }
		}
		else { manager = EffectsManager.GetManager(); }

		if (globalfreeze || level.Frozen || !interval) { return; }

		if (wasused)
		{
			if (usetime > 0)
			{
				bDormant = true;
				usetime--;
			}
			if (usetime == 0)
			{
				bDormant = false;
				wasused = false;
			}
		}
		
		if (health > 0 && bShootable && !bDormant && !dodging && !surrendered)
		{
			if (curSector.GetUDMFInt("user_background") == True) // If this is a background actor, skip most of the logic here
			{
				if (!InStateSequence(curState, IdleState)) { SetState(IdleState); }

				Super.Tick();

				return;
			}

			// If the enemy is sneakable and idle (and not patrolling), and isn't in its original location, keep it moving toward that location.
			//  NOTE: This doesn't work properly when the player has NOTARGET enabled (or is wearing a disguise and has no weapon raised).
			if (user_sneakable && bFriendly && user_incombat && patrolgoal && patrolgoal.args[0] == -1)
			{
				MeleeRange = 0; // To bypass the internal A_Chase "goal reached" logic

				if (!loiterdistance && Distance3D(patrolgoal) <= Radius) // If at goal, clear target and goal and go to Spawn state
				{
					angle = patrolgoal.angle;
					goal = null;
					LastHeard = null;
					LastEnemy = null;
					A_ClearTarget();
					MeleeRange = Default.MeleeRange;
					user_incombat = false;
					SetStateLabel("Spawn");
				}
				else // Otherwise, keep trying to get there (necessary because A_Chase clears goal and target when within MeleeRange of goal)
				{
					goal = patrolgoal;
					target = patrolgoal;
				}
			}
			else if (user_incombat && !bFriendly && activationgoal && (LastEnemy || LastHeard))
			{
				MeleeRange = 0; // To bypass the internal A_Chase "goal reached" logic

				if (Distance3D(activationgoal) <= Radius + activationgoal.radius)
				{
					A_Face(activationgoal);

					if (LastEnemy is "PlayerPawn") { target = LastEnemy; }
					LastEnemy = null;

					bJustAttacked = False;
					bChaseGoal = False;
					Speed = Default.Speed;

					MeleeRange = Default.MeleeRange;

					if (activationgoal is "AlarmPanel")
					{
						// Only activate the alarm if it's actually in reach.
						if (pos.z < activationgoal.pos.z + height && pos.z + height > activationgoal.pos.z)
						{
							SetStateLabel("Alarm");

							activationgoal.Activate(target);
						}
					}
					else
					{
						activationgoal.Activate(target);
					}

					activationgoal = null;
				}
				else if (goal != activationgoal) // Otherwise, keep trying to get there
				{
					goal = activationgoal; // Set the activation goal as the current navigation goal
					bJustAttacked = True; // Keep the actor from attacking while chasing to the goal
					bChaseGoal = True; // Chase to the goal only, not toward a target
					Speed = Default.Speed + Random(1, 2); // Walk a little faster
 					if (!InStateSequence(CurState, SeeState)) { SetStateLabel("See"); } // Go to the See state if not already there
				}
			}
			else if (healflags)
			{
				// If it doesn't have a goal (and isn't running away), look for dead bodies
				if (!goal || (goal && Distance3d(goal) > 1024))
				{
					if (level.time % interval == 0) { A_LookForBodies(); }

					if (Nazi(body) && !body.bShootable && !Nazi(body).healing) { bChaseGoal = true; goal = body; } // Keep trying to get to the body if it's still dead and isn't being healed
					else { body = null; }
				}

				if (!bFrightened || (frightener && !frightener.player))
				{
					// If it wasn't frightened by a player and close to a dead body that it isn't already healing, start healing the body
					if (goal && goal.bIsMonster && Distance3d(goal) <= goal.radius + radius + healdistance && !InStateSequence(CurState, HealState)) {
						if (Nazi(goal)) { Nazi(goal).healing = true; }
						bChaseGoal = Default.bChaseGoal;
						SetStateLabel("Heal");
					}
				}
				else
				{ // If you are frightened, forget the dead body and run away
					if (Nazi(goal)) { Nazi(goal).healing = false; }
					body = null;
					bChaseGoal = Default.bChaseGoal;
					goal = null;
				}
			}

			// If you're sneakable and there aren't any eyes spawned for some reason, spawn them...
			if (user_sneakable && !eyes)
			{
				if (alerted) { alerted = true; BecomeAlerted(); }
				else { BecomeIdle(); }
			}

			if (
				(!user_sneakable || alerted) && // Sneakable enemies only care about grenades if they're alerted
				!bBoss &&
				!(self is "Rottweiler") && // Dogs aren't smart enought to avoid grenades
				!(self is "MutantStandard") && // Nor are mutants
				!(self is "ZombieStandard") && // And zombies are especially not smart...
				Default.Speed > 0 && 
				level.time % (interval / 3) == 0 // Check for grenades more often than the random interval, but still only every 10-11 tics at most...
			) 
			{
				A_LookForGrenades();
			}

			if (level.time % interval == 0) { closestplayer = FindClosestPlayer(self, IgnoreFriendlies:!bFriendly); }
		}

		if (user_cansurrender && surrendered)
		{
			if (!InPlayerSight(self)) { hiddentime++; }
			else { hiddentime = 0; } // Reset the timer if seen

			if (hiddentime > 35 * 10) { Destroy(); } // Remove the surrendered actor after 10 seconds of being out of sight.
		}

		Super.Tick();
	}

	static void SpyGive(Actor recipient, String itemname, int rawAmount)
	{
		Class<Inventory> item = itemname;
		Inventory haveItem = recipient.FindInventory(item);

		// Amount of items to put in player's inventory
		int amountToGive = rawAmount;

		// Amount of items to drop at player's feet
		int amountToDrop = 0;

		// Space available in player's inventory
		int spaceAvailable = GetDefaultByType(item).MaxAmount;

		// Check whether player has the item
		if (haveItem)
		{
			spaceAvailable = haveItem.MaxAmount - haveItem.Amount;
		}

		if (spaceAvailable > 0)
		{
			amountToGive = min(spaceAvailable, amountToGive);
			recipient.GiveInventory(item, amountToGive);
			recipient.A_StartSound(GetDefaultByType(item).PickupSound, CHAN_ITEM);
		}

		amountToDrop = amountToGive - spaceAvailable;

		if (amountToDrop <= 0) { return; }

		int delta;

		if (item is "CoinItem")
		{ // CoinItem is invisible, so drop something that's visible instead
			delta = DropDelta(recipient, "TreasureChest2", amountToDrop);
			delta = DropDelta(recipient, "TreasureChest", amountToDrop);
			delta = DropDelta(recipient, "GoldBar", amountToDrop);
			delta = DropDelta(recipient, "BagOfCoins", delta);
			DropDelta(recipient, "SingleCoin", delta);
		}
		else if (item is "Ammo9mm")
		{
			delta = DropDelta(recipient, "AmmoBox9mm", amountToDrop);
			DropDelta(recipient, "Ammo9mm", delta);
		}
		else if (item is "Ammo12Gauge")
		{
			delta = DropDelta(recipient, "AmmoBox12Gauge", amountToDrop);
			DropDelta(recipient, "Ammo12Gauge", delta);
		}
		else if (item is "NebAmmo")
		{
			delta = DropDelta(recipient, "NebAmmoBox", amountToDrop);
			DropDelta(recipient, "NebAmmo", delta);
		}
		else
		{
			amountToDrop /= GetDefaultByType(item).Amount;
			DropItems(recipient, item, amountToDrop);
		}
	}

	// Drops the maximum number of the specified item to meet a target amount, and returns
	// the amount of the base inventory class that still needs to be dropped
	static int DropDelta(Actor target, Class<Inventory> item, int delta)
	{
		int amt = GetDefaultByType(item).Amount; // How many does this item give?
		int dropamt = delta / amt; // How many of this item should be spawned?
		delta %= amt; // What's left of the original requested amount after spawning these?

		DropItems(target, item, dropamt);

		return delta;
	}

	static void DropItems(Actor target, Class<Inventory> item, int amt)
	{
		if (!amt) { return; }

		for (int i = 0; i < amt; i++)
		{
			double r = GetDefaultByType(item).radius + target.radius;
			Vector3 spawnpos = target.pos + (FRandom(-r, r), FRandom(-r, r), 0);
			Actor drop = Spawn(item, spawnpos, ALLOW_REPLACE);
			if (drop)
			{
				drop.Vel3DFromAngle(Random(1, 4), Random(0, 359), Random(-75, -90)); // Don't stack items on top of each other
				drop.ClearCounters();
			}
		}
	}

	override bool Used(Actor user)
	{
		if (user.player && !wasused && !special && bFriendly && !user_sneakable && Default.Species == "Nazi" && (!target || !target.bShootable) && activationcount < 2 && health > 0)
		{
			wasused = true;
			usetime = 70;

			SetState(SpawnState);
			A_Face(user);
			bPushable = True;

			int index = activationcount;
			if (index == 0 && user_spyitem == "") { index = Random(1, 3); }
			else if (index > 0) { index = 99; }

			String msg = "";
			String messagestr = "";

			if (!activationcount && user_spymsgindex)
			{
				msg = "SPYMESSAGE" .. level.mapname .. user_spymsgindex;
				messagestr = StringTable.Localize(msg, false);
			}

			if (messagestr ~== msg)
			{
				switch (index)
				{
					case 0:
						msg = "GENERIC" .. Random(0, 4);
						break;
					case 1:
						msg = "AMMO";
						break;
					case 2:
						msg = "BANDAGES";
						break;
					case 3:
						msg = "GOLD";
						break;
					default:
						msg = "MOVE" .. Random(0, 1);
						break;
				}

				msg = "SPYMESSAGE" .. msg;
				messagestr = StringTable.Localize(msg, false);

				if (!(messagestr ~== msg))
				{
					if (index == 0 && user_spyitem) { messagestr = messagestr .. "\n\cC" .. StringTable.Localize("SPYMESSAGETAKETHIS", false); }
					else if (index > 0 && index < 4) { messagestr = StringTable.Localize("SPYMESSAGEGENERIC" .. Random(0, 4), false) .. "\n\cC" .. messagestr; }
				}
			}

			if (messagestr.length())
			{
				Message.Init(user, head, messagestr);
			}

			switch (index)
			{
				case 0:
					if (!(user_spyitem == ""))
					{
						let item = (Class<Inventory>)(user_spyitem);

						if (item)
						{
							SpyGive(user, user_spyitem, 1);

							let itemdef = GetDefaultByType(item);
							if (itemdef.bInvBar) { PlayerPawn(user).InvSel = user.FindInventory(item); }
						}
					}

				default:
					break;
				case 1:
					SpyGive(user, "Ammo9mm", Random(1, 4) * 4);
					break;
				case 2:
					SpyGive(user, "Bandages", Random(1, 2));
					break;
				case 3:
					SpyGive(user, "CoinItem", Random(2, 4) * 5);
					break;
			}

			activationcount++;
		}

		return Super.Used(user);
	}
	
	override void Activate (Actor activator)
	{
		Super.Activate(activator);
		if (health > 0) SetStateLabel("Active");
	}

	override void OnDestroy()
	{
		if (user_sneakable && bFriendly && health > 0)
		{
			bFriendly = false;
			ClearCounters();
		}
	}
}

//Standard Nazi enemy defaults.
//  Intended for use with 'normal' non-boss Nazi enemies.
//  Currently handles burning, gibbing, and disintegration states
class NaziStandard : Nazi
{
	Default
	{
		GibHealth 30;
		SeeSound "Nazi1/Sighted";
		PainSound "Nazi1/Pain";
		DeathSound "Nazi1/Death";
		Nazi.IdleSound "axis1/idle";
		Nazi.TargetLostSound "axis1/target_not_seen";
		Nazi.TargetSeenSound "axis1/sighted";
	}

	States
	{
		Salute: //special state for cinematic sequences - ozy81
			"####" N 35;
		SaluteLoop:
			"####" Z 35;
			Loop;
		Death.Fire:
			"####" # 0 A_SetScale(0.55);
		Death.Fire.Random: // Jump to here if you have an actor that needs a different scale set (See WereWaffenSS)
			"####" # 0 {
				DeathDamageType = "Fire"; // Because the flamethrower guards are set to this state via jump, not damage
				sprite = GetSpriteIndex(Random() < 128 ? "BURN" : "NRUB");
				bIsMonster = False; // Burned enemies can't be resurrected
			}
			"####" A 5 Bright Light("ITBURNS1") { A_Wander(); }
			"####" BC 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" D 5 Bright Light("ITBURNS1") { A_Wander(); A_StartSound("death/burning", CHAN_VOICE); }
			"####" E 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" FABCD 5 Bright Light("ITBURNS2") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" EFAG 5 Bright Light("ITBURNS3") A_Wander();
			"####" H 5 Bright Light("ITBURNS3") A_UnblockAndDrop();
			"####" IJK 5 Bright Light("ITBURNS2") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,16), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" LMN 5 Bright Light("ITBURNS1") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,8), 1, 0, random (1, 3), frandom (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
		Death.Fire.Smoke:
			"####" O 0 A_Jump(32,"Death.Fire.End");
			"####" O 2 Light("ITBURNS4");
			"####" O 4 Light("ITBURNS5");
			"####" O 3 Light("ITBURNS6");
			"####" O 5 Light("ITBURNS5");
			Loop;
		Death.Fire.End:
			"####" O -1;
			Stop;
		Death.Electric:
			"####" # 0 A_SetScale(0.55);
		Death.Electric.Random: // Jump to here if you have an actor that needs a different scale set (See WereWaffenSS)
			"####" # 0 {
				DeathDamageType = "Electric";
				sprite = GetSpriteIndex(Random() < 128 ? "FIZZ" : "ZZIF");
				bIsMonster = False; // Zapped enemies can't be resurrected
			}
			"####" A 5 Bright Light("TPortNormal");
			"####" BA 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" B 5 Bright Light("TPortNormal") { A_StartSound("death/burning", CHAN_VOICE); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" AABAB 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" C 7 Light("TPortNormal") A_UnblockAndDrop();
			"####" DE 6 Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" FG 5 A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
		Death.Electric.Smoke:
			"####" H 0 A_Jump(32,"Death.Electric.End");
			"####" H 2;
			"####" H 4;
			"####" H 3;
			"####" H 5;
			Loop;
		Death.Electric.End:
			"####" H -1;
			Stop;
		Raise:
			"####" M 35;
			"####" LKJ 5;
			"####" I 5 A_Jump(256,"See");
			Stop;
		XDeath:
			SLOP A 5 {
				A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
				A_SetScale(0.65);
				bIsMonster = False; // So that an exploded enemy can't be resurrected
				A_StopSound(CHAN_VOICE); // Stop enemy shouting
			}
			"####" BCDE 5;
			"####" F 5 A_UnblockAndDrop();
			"####" G -1;
			Stop;
		XDeath.Giant:
			SLOP A 5 {
				A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
				A_SetScale(2.90);
				bIsMonster = False; // So that an exploded enemy can't be resurrected
				A_StopSound(CHAN_VOICE); // Stop enemy shouting
			}
			"####" BCDE 5;
			"####" F 5 A_UnblockAndDrop();
			"####" G -1;
			Stop;
		XDeath.Boom:
			SLOP A 5 {
				A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
				A_SetScale(0.65);
				bIsMonster = False; // So that an exploded enemy can't be resurrected
				A_StopSound(CHAN_VOICE); // Stop enemy shouting
			}
			"####" A 0 A_SpawnItemEx("PanzerBoom", 0, 0, 8);
			"####" BCDE 5 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
			"####" F 5 A_UnblockAndDrop();
			"####" G -1;
			Stop;
	}
}

class MutantStandard : Nazi
{
	Default
	{
		Nazi.FrightMultiplier 0.0;
		Height 56;
		Scale 0.7;
		GibHealth 30;
		DamageFactor "Electric", 0.3; //Purple = less sensible - ozy81
		DamageFactor "MutantPoison", 0;
		DamageFactor "MutantPoisonAmbience", 0;
		DamageFactor "UndeadPoison", 0;
		DamageFactor "UndeadPoisonAmbience", 0;
		DamageFactor "Poison", 0;
		SeeSound "mutant/see";
		PainSound "mutant/pain";
		DeathSound "mutant/Death";
		BloodColor "9F 00 9B";
		BloodType "MutantBlood";
		Translation "16:47=[205,0,215]:[40,0,96]","168:191=[205,0,215]:[40,0,96]";
		Nazi.TotaleGierDrop 0;
	}

	States
	{
		Death.Fire:
			"####" # 0 A_SetScale(0.55);
		Death.Fire.Random: // Jump to here if you have an actor that needs a different scale set (See WereWaffenSS)
			"####" # 0 {
				DeathDamageType = "Fire"; // Because the flamethrower guards are set to this state via jump, not damage
				sprite = GetSpriteIndex(Random() < 128 ? "BURN" : "NRUB");
				bIsMonster = False; // Burned enemies can't be resurrected
			}
			"####" A 5 Bright Light("ITBURNS1") { A_Wander(); }
			"####" BC 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" D 5 Bright Light("ITBURNS1") { A_Wander(); A_StartSound(DeathSound, CHAN_VOICE); }
			"####" E 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" FABCD 5 Bright Light("ITBURNS2") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" EFAG 5 Bright Light("ITBURNS3") A_Wander();
			"####" H 5 Bright Light("ITBURNS3") A_UnblockAndDrop();
			"####" IJK 5 Bright Light("ITBURNS2") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,16), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" LMN 5 Bright Light("ITBURNS1") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,8), 1, 0, random (1, 3), frandom (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
		Death.Fire.Smoke:
			"####" O 0 A_Jump(32,"Death.Fire.End");
			"####" O 2 Light("ITBURNS4");
			"####" O 4 Light("ITBURNS5");
			"####" O 3 Light("ITBURNS6");
			"####" O 5 Light("ITBURNS5");
			Loop;
		Death.Fire.End:
			"####" O -1;
			Stop;
		Death.Electric:
			"####" # 0 A_SetScale(0.55);
		Death.Electric.Random: // Jump to here if you have an actor that needs a different scale set (See WereWaffenSS)
			"####" # 0 {
				DeathDamageType = "Electric";
				sprite = GetSpriteIndex(Random() < 128 ? "FIZZ" : "ZZIF");
				bIsMonster = False; // Zapped enemies can't be resurrected
			}
			"####" A 5 Bright Light("TPortNormal");
			"####" BA 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" B 5 Bright Light("TPortNormal") { A_StartSound(DeathSound, CHAN_VOICE); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" AABAB 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" C 7 Light("TPortNormal") A_UnblockAndDrop();
			"####" DE 6 Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" FG 5 A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
		Death.Electric.Smoke:
			"####" H 0 A_Jump(32,"Death.Electric.End");
			"####" H 2;
			"####" H 4;
			"####" H 3;
			"####" H 5;
			Loop;
		Death.Electric.End:
			"####" H -1;
			Stop;
		Raise:
			"####" M 35;
			"####" LKJ 5;
			"####" I 5 A_Jump(256,"See");
			Stop;
		XDeath:
			SLOM A 5 {
				A_SpawnItemEx("MutantFlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
				A_SetScale(0.62);
				bIsMonster = False; // So that an exploded enemy can't be resurrected
			}
			"####" BCDE 5;
			"####" F 5 A_UnblockAndDrop();
			"####" G -1;
			Stop;
		XDeath.Big:
			SLOM A 5 {
				A_SpawnItemEx("MutantFlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
				A_SetScale(0.95);
				bIsMonster = False; // So that an exploded enemy can't be resurrected
			}
			Goto XDeath+1;
		Disintegrate:
			"####" I 0 A_Jump(256, "Disintegration");
			Stop;
	}
}

//Standard Zombie enemy defaults.
class ZombieStandard : Nazi
{
	Default
	{
		Base.LightThreshold 190;
		Base.LightKills True;
		Nazi.FrightMultiplier 0.0;
		Nazi.TotaleGierDrop 0;
		GibHealth 30;
		PainChance 64;
		DamageFactor "Electric", 0.8;
		DamageFactor "Fire", 1.2;
		DamageFactor "MutantPoison", 0;
		DamageFactor "MutantPoisonAmbience", 0;
		DamageFactor "Normal", 0.5;
		DamageFactor "Poison", 0;
		DamageFactor "UndeadPoison", 0;
		DamageFactor "UndeadPoisonAmbience", 0;
		ActiveSound "nazombie/act";
		DeathSound "nazombie/die";
		PainSound "nazombie/pain";
		SeeSound "nazombie/sighted";
		BloodColor "00 A0 7D";
		BloodType "ZombieBlood";
		MaxStepHeight 28;
		MaxDropoffHeight 28;
		Species "Zombie";
	}

	States
	{
		RunLoop:
			"####" O 1 A_NaziChase;
			"####" OOO 1 A_NaziChase(null,null);
			"####" O 1 A_NaziChase;
			"####" OOO 1 A_NaziChase(null,null);
			"####" P 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" PPP 1 A_NaziChase(null,null);
			"####" P 1 A_NaziChase;
			"####" PPP 1 A_NaziChase(null,null);
			"####" Q 1 A_NaziChase;
			"####" QQQ 1 A_NaziChase(null,null);
			"####" Q 1 A_NaziChase;
			"####" QQQ 1 A_NaziChase(null,null);
			"####" R 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" RRR 1 A_NaziChase(null,null);
			"####" R 1 A_NaziChase;
			"####" RRR 1 A_NaziChase(null,null);
			"####" "#" 0 A_Jump(256,"See");
		RunLoop2:
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null,null);
			"####" A 1 A_NaziChase;
			"####" AAA 1 A_NaziChase(null,null);
			"####" B 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" BBB 1 A_NaziChase(null,null);
			"####" B 1 A_NaziChase;
			"####" BBB 1 A_NaziChase(null,null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null,null);
			"####" C 1 A_NaziChase;
			"####" CCC 1 A_NaziChase(null,null);
			"####" D 1 A_NaziChase;
			"####" # 0 A_PlayStepSound();
			"####" DDD 1 A_NaziChase(null,null);
			"####" D 1 A_NaziChase;
			"####" DDD 1 A_NaziChase(null,null);
			"####" "#" 0 A_Jump(256,"See");
		Death.Fire:
			"####" # 0 A_SetScale(0.55);
		Death.Fire.Random: // Jump to here if you have an actor that needs a different scale set (See WereWaffenSS)
			"####" # 0 {
				DeathDamageType = "Fire"; // Because the flamethrower guards are set to this state via jump, not damage
				sprite = GetSpriteIndex(Random() < 128 ? "BURN" : "NRUB");
				bIsMonster = False; // Burned enemies can't be resurrected
			}
			"####" A 5 Bright Light("ITBURNS1") { A_Wander(); }
			"####" BC 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" D 5 Bright Light("ITBURNS1") { A_Wander(); A_StartSound(DeathSound, CHAN_VOICE); }
			"####" E 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" FABCD 5 Bright Light("ITBURNS2") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" EFAG 5 Bright Light("ITBURNS3") A_Wander();
			"####" H 5 Bright Light("ITBURNS3") A_UnblockAndDrop();
			"####" IJK 5 Bright Light("ITBURNS2") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,16), 1, 0, random (1, 3), random (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" LMN 5 Bright Light("ITBURNS1") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,8), 1, 0, random (1, 3), frandom (0, 360), BASE_FLAGS, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
		Death.Fire.Smoke:
			"####" O 0 A_Jump(32,"Death.Fire.End");
			"####" O 2 Light("ITBURNS4");
			"####" O 4 Light("ITBURNS5");
			"####" O 3 Light("ITBURNS6");
			"####" O 5 Light("ITBURNS5");
			Loop;
		Death.Fire.End:
			"####" O 4 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
			"####" O -1;
			Stop;
		Death.Electric:
			"####" # 0 A_SetScale(0.55);
		Death.Electric.Random: // Jump to here if you have an actor that needs a different scale set (See WereWaffenSS)
			"####" # 0 {
				DeathDamageType = "Electric";
				sprite = GetSpriteIndex(Random() < 128 ? "FIZZ" : "ZZIF");
				bIsMonster = False; // Zapped enemies can't be resurrected
			}
			"####" A 5 Bright Light("TPortNormal");
			"####" BA 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" B 5 Bright Light("TPortNormal") { A_StartSound(DeathSound, CHAN_VOICE); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
			"####" AABAB 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" C 7 Light("TPortNormal") A_UnblockAndDrop();
			"####" DE 6 Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" FG 5 A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
			"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
		Death.Electric.Smoke:
			"####" H 0 A_Jump(32,"Death.Electric.End");
			"####" H 2;
			"####" H 4;
			"####" H 3;
			"####" H 5;
			Loop;
		Death.Electric.End:
			"####" H -1;
			Stop;
		XDeath:
			SLOZ A 5 {
				A_SpawnItemEx("Zombie_FlyingBlood", 0, 0, 8, random(-4, 4), random(-4, 4), random(2, 5), 0, 143, 176);
				A_SetScale(0.65);
				bIsMonster = False; // So that an exploded enemy can't be resurrected
			}
			"####" BCDE 5;
			"####" F 5 {A_UnblockAndDrop(); A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));}
			"####" G -1;
			Stop;
		Disintegrate:
			"####" F 0 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, FRandom(1, 3));
			"####" F 0 A_Jump(256, "Disintegration");
			Stop;
	}
}

// Conversation marker that follows the actor, positioning itself above their head.
// For Invisible/NoBlockMap actors, the marker is placed at the base of the actor.
class ConversationMarker : Actor
{
	Default
	{
		Height 0;
		Radius 0;
		Scale 1.35;
		+BRIGHT
		+NOBLOCKMAP
		+NOGRAVITY
		RenderStyle "Translucent";
		Alpha 1.0;
	}

	States
	{
		Spawn:
		Active:
			EXCL D 1;
			Loop;
		Inactive:
			EXCL D 10;
			EXCL E -1;
			Stop;
	}

	override void Tick()
	{
		if (master)
		{
			if (master.health <= 0 || !Base(master).user_conversation) { Destroy(); }
			else
			{
				double offset;

				if (master.bInvisible || master.bNoBlockMap) { offset = 12; }
				else { offset = master.height + 12; }

				SetOrigin((master.pos.x, master.pos.y, master.pos.z + offset), true);
			}
		}

		Super.Tick();
	}
}

class ModelBase : SceneryBase
{
	mixin GiveBuoyancy;

	Default
	{
		Height 56;
		+FLOORCLIP
		+DONTSPLASH
		+NOGRAVITY
		ModelBase.Buoyancy 0.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (!bWasCulled) { A_SetSize(radius * scale.x / Default.scale.x, height * scale.y / Default.scale.y); } // If the actor is scaled from default, adjust the actual size of the actor

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		DoBuoyancy();
	}
}

// Base class for Nazi bosses.  
// If the boss has a WoundHealth set and a "Wounded" state label defined, then  the enemy 
// will be forced to use the sprite that is set at that state label as long as the 'wounded' 
// boolean is set to true.  See Longinus_Hitler for example.
class NaziBoss : Nazi
{
	bool wounded;
	SpriteID WoundedSprite;

	Default
	{
		Mass 1000;
		Scale 0.67;
		Height 80;
		MaxTargetRange 0;
		Base.BossIcon "BOSSICON";
		DamageFactor "Rocket", 0.07;
		+AVOIDMELEE
		+BOSS
		+DONTTHRUST
		+NEVERTARGET //so allied soldiers won't attack any NaziBoss based actors, preventing players to cover themselves indefinitely --Ozy81
		Nazi.TotaleGierDrop 3;
	}

	States
	{
		See:
			Goto See.Boss;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		State WoundedState = FindState("Wounded");
		if (WoundedState) { WoundedSprite = WoundedState.sprite; }

		wounded = false;
	}

	override void Tick()
	{
		Super.Tick();

		if (wounded && WoundedSprite) { sprite = WoundedSprite; }
	}
}

class BatBase : Base
{
	int countdown;
	Actor roostgoal;
	int maxchase;

	Property MaxChaseTime:maxchase;

	Default
	{
		BatBase.MaxChaseTime 7;
		Species "Player"; ///this to avoid players getting blocked by bats in narrow places, we need to see what happens with targets though --Ozy81
		+THRUSPECIES
	}

	States //these states shouldn't have shadows --Ozy81
	{
		Roost:
			"####" K Random(35, 350); // 'Sleep' on roost for 1-10 seconds
		RoostLoop:
			"####" K 5 A_LookThroughDisguise(LOF_NOSIGHTCHECK); // Then only go after the player again if they make a noise
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		ResetCountDown();

		SpawnRoost();
	}

	override void Tick()
	{
		if (IsFrozen()) { return; }

		if (bShootable && health > 0)
		{
			if (target)
			{
				if (target != goal && height < Default.Height) { A_SetSize(-1, Default.Height, true); }
				countdown--;

				if (CheckMeleeRange() && countdown > 0) { countdown = 0; }
			}

			if (!roostgoal) { SpawnRoost(); } // Keep trying to spawn a roost if the actors spawned under open sky

			// Positive values on countdown timer are how long remaining in active attack mode
			// Negative values on countdown timer are how long bat has been trying to run away or get back to roost
			if (countdown == 0 || reactiontime > 0) // When countdown hits zero, run away from the player
			{
				bFrightened = true;
			}
			else if (countdown < -35 && roostgoal) // After one second of running away, stop running and go back to roost
			{
				bFrightened = false;
				goal = roostgoal;
				target = goal;
				bJustAttacked = True;
				bChaseGoal = True;

				if (roostgoal)
				{
					double dist = Distance2D(roostgoal);
					if (dist < radius && roostgoal.pos.z <= pos.z + 16) // At roost, roost.
					{
						SetOrigin(roostgoal.pos, true);
						vel *= 0; // Make sure to remove any externally-applied velocity, or you can (rarely) end up with sliding roosted bats
						SetStateLabel("Roost");

						ResetCountDown();
						A_ClearTarget();
					}
					else if (dist < radius * 3)
					{
						A_SetSize(-1, 16); // Make the bat shorter so that the sprite can move closer to the ceiling to roost more smoothly
					}
				}
			}

			if (countdown < 0 && abs(countdown) % 35 == 0)
			{
				if (target)
				{
					NewChaseDir();
				}
				else
				{
					RandomChaseDir();
				}
				FaceMovementDirection();
			}

			if (roostgoal && countdown == 35 * -10) // If you've been trying to get back to your roost for 10 seconds, give up and try to spawn a new roost here
			{
				countdown = -35;

				SpawnRoost();
			}
		}

		Super.Tick();
	}

	void ResetCountdown()
	{
		countdown = int(35 * Random(5, maxchase) * max(1.0, (pos.z - floorz) / 256.0)); // Actively chase player for 5-10 seconds - or more, if the ceiling is high
	}

	void SpawnRoost()
	{
		if (ceilingpic != skyflatnum) // No roosting on sky ceiling
		{
			if (roostgoal) { roostgoal.Destroy(); } // If this gets called twice, destroy the old roost

			roostgoal = Spawn("MapSpot", (pos.xy, ceilingz - 16)); // Convenient actor re-use
			roostgoal.bShootable = true; // Must be set so that A_Chase will keep the map spot as a target
		}
	}
}