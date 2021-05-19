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

  An actor that will stand dormant until it sees a player, then will follow that player.
  The actor can be set to carry a specific weapon.

  Custom Properties:
	PlayerFollower.Weapon
	- Weapon that the PlayerFollower will spawn with, set based on FollowerWeapons Enum
	  below (e.g., PWEAP_None, PWEAP, Luger, etc.)

	PlayerFollower.CloseFollow
	- If true, actor will immediately forget its target if the player moves out of range.
	- This has the effect of making the actor follow the player more closely
	- Behavior and following is more predictable, but more realistic for an escaping
	  prisoner (vice a soldier in combat)

	PlayerFollower.ChaseAttackChance
	- Chance that the actor will stop while chasing to attack enemies - because of how
	  often this check is performed, values will need to be *very* low (e.g., 2-4) to see
	  any change in actor behavior.

	PlayerFollower.FOV
	- FOV used for look/search/sight calls

	PlayerFollower.GrenadeChance
	- Chance of using grenades.  By default, the actor has an infinite supply of grenades.
	- Alternatively, if you give the actor a specific number of grenades via a script,
	  then the PlayerFollower will throw up to that many grenades, then no more.

	PlayerFollower.CanBeCommanded
	- Determines if you can make the NPC follow/stop following you by pressing 'use' on them
	- Defaults to false.  Can be set to true to unconditionally keep the actor in place, or 
	  you can specify a distance in mapunits after which the actor will ignore your commands
	  and catch up anyway

	PlayerFollower.HealPlayer
	- Integer value that sets the health amount under which the player follower will heal
	  the player (so, set to 40 means that once the player is below 40 health, the follower
	  will heal the player in increments of 10 until the player is above 40 health).

  Useful Variables:
	These are intended to be set via ACS using 'SetUserVariable(tid, "variable", value);'

	nocatchup (default is 0)
	- Normally, if a PlayerFollower falls 100 pathmarkers behind the player, the actor
	  will be warped ahead to the halfway pathmarker (if the player can't see the marker)
	- Setting this boolean to 1 disables that behavior.  This is useful if you want to
	  force a PlayerFollower along a certain route in the map, and don't want him skipping
	  ahead.
	- Be cautious!  If the PlayerFollower gets stuck somwhere in the level geometry while
	  this is set, then the PlayerFollower will never be able to become un-stuck.

	nonmoving (default is 0)
	- Setting this boolean to 1 causes the PlayerFollower to stand in place and not
	  follow the player anymore.
	- This differs from being dormant/Deactivated in that the PlayerFollower will still
	  look for players, look for enemies, and open fire on enemies.

  Editing Tricks:
	Block the PlayerFollower
	- Normally the PlayerFollowers are not blocked by Monster-Blocking lines.  If you want
	  to limit where a PlayerFollower can go, just remove the NOBLOCKMONST flag in ACS:

		SetActorFlag(tid, "NOBLOCKMONST", 0);

	  Then place monster blocking lines in the map, and the PlayerFollower won't be able to
	  cross them.

	Change PlayerFollower Weapon
	- You can change the weapon that a PlayerFollower is carrying by giving them a new weapon
	  via ACS.  Note that the weapon must be one of those that is coded below...
	- Valid weapons are: Luger9mm, MP40, Sten, KnifeSilent (and GrenadePickup, as discussed in
	  the PlayerFollower.GrenadeChance property section above)

*/

// Parent class that holds functions and logic
class PlayerFollower : Actor // Default version - for actors like prisoner with A as standing frame and B-E walking, FGH firing, I pain, JKLMN Death
{
	enum FollowerWeapons
	{
		PWEAP_None, // 0
		PWEAP_Melee, // 1
		PWEAP_Luger, // 2
		PWEAP_MP40, // 3
		PWEAP_Rifle, // 4
		PWEAP_Grenade, // 5
		PWEAP_Shotgun // 6
	};

	Array<PathMarker> Markers;
	Actor playerToChase, currentGoal;
	Vector3 oldPlayerPos;

	int weapon;
	int shots, totalshots;
	double faceangle;
	double startSpeed;
	bool forgettarget;
	int chaseattackchance;
	LookExParams SearchParams;
	int fov;
	int grenadechance;
	bool countgrenades;
	bool nocatchup;
	bool nonmoving, user_nonmoving;
	int allowinteraction;
	int oldwaterlevel;
	int activationcount;
	String head;
	String charname;
	bool climbing;
	int enemycount;
	int reloadcount;
	BoAFindHitPointTracer trace;
	int frighttimeout;
	String healparticle;
	int healtime, playerhealtime;
	int healplayer;
	int scouttime;
	int offset;

	static const statelabel MissileStateNames[] = { null, "Melee", "Luger", "MP40", "Rifle", "Grenade", "Shotgun" };
	static const int MissileRanges[] = { 1, 32, 512, 768, 1024, 512, 512 };

	Property Weapon:weapon; // Weapon set based on FollowerWeapons Enum
	Property CloseFollow:forgettarget; // If true, actor will immediately forget its target if the player moves out of range.  Behavior and following is more predictable, but more realistic for an escaping prisoner (vice a soldier in combat)
	Property ChaseAttackChance:chaseattackchance; // Chance that the actor will stop while chasing to attack
	Property FOV:fov; // FOV used for look/search/sight calls
	Property GrenadeChance:grenadechance; // Chance of using grenades (and gives him grenades, so anything over 0 will throw grenades at some point)
	Property CanBeCommanded:allowinteraction;
	Property Head:head;
	Property HealParticle:healparticle;
	Property HealPlayer:healplayer;
	Property CharName:charname; // Name of follower

	Default
	{
		MONSTER;
		-COUNTKILL
		+AVOIDMELEE
		+DONTHARMSPECIES
		+FLOORCLIP
		+NOBLOCKMONST
		+NODAMAGE
		+NOTAUTOAIMED
		+PUSHABLE
		+SLIDESONWALLS
		+WINDTHRUST
		Health 100;
		Height 52;
		Radius 16;
		Mass 100;
		Speed 5;
		MaxStepHeight 56; //Matches max player jump height with standard JumpZ of 8 and MaxStepHeight of 24
		MaxDropOffHeight 512;
		MaxTargetRange 3072; // Because we have long corridors that are more than 2048 units long, and PlayerFollowers would stand there stupidly even though enemies are in sight
		DamageFactor "Trample", 0.0;
		PainChance 128;
		PlayerFollower.Weapon PWEAP_None;
		PlayerFollower.CloseFollow False;
		PlayerFollower.ChaseAttackChance 32;
		PlayerFollower.FOV 100;
		PlayerFollower.GrenadeChance 0;
		PlayerFollower.CanBeCommanded False;
		PlayerFollower.Head "MS_SOLD";
		PlayerFollower.HealParticle "HealingParticle";
		PlayerFollower.HealPlayer 0;
	}

	States
	{
		Spawn:
			ARH2 A 1;
			Goto Initialize;
		Initialize:
			"####" A 0 {
				startSpeed = Speed;
				A_SetTics(Random[Startup](0, 15));
				return ResolveState("Stand"); // Jump via ResolveState versus Goto for inheritance reasons
			}
		Stand: // Initial setup of actor and identification of what player we want to follow
			"####" A 1;
			"####" A 0 A_FindPlayer();
		Chase.Back: // Used to push actor back when touching player
			"####" EEEEE 1;
			"####" DDDDDCCCCC 1 {
				if (playerToChase)
				{
					double pushAngle = AngleTo(playerToChase) + 180;
					Thrust(Speed / 5, pushAngle);
				}
			}
			"####" BBBBB 1;
		Chase: // Standard goal chasing
			"####" BBBBBCCCCC 1 A_ChaseGoal();
			"####" DDDDDEEEEE 1 A_ChaseGoal();
			Loop;
		Chase.Near: // Near the player, take up defensive position (if armed), otherwise stand stupidly
			"####" AAAAA 1 A_Defend();
			Loop;
		Chase.Stand: // Wherever standing, take up defensive position (if armed), otherwise stand stupidly
			"####" AAAAA 1 A_Defend(false);
			"####" A 0 { if (!nonmoving) { SetStateLabel("Chase"); } }
			Loop;
		Pain:
			"####" I 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-8, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR);
			"####" I 3 {
				A_Pain();
				if (Random(0, 1023) < PainChance) { frighttimeout += min(SpawnHealth() - health, 10); }
			}
			Goto Chase;
		Luger: // Emulates the standard guard pistol - relatively standard
			"####" FG 10 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
			Luger.Refire:
				"####" H 8 LIGHT("NaziFire") A_FollowerFire("LugerTracer", "Casing9mm", "nazi/pistol", 54, 1);
				"####" G 8 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
 				"####" G 0 A_RefireReload("Luger.Refire", "Luger.Reload");
			Luger.Reload: // More emulation of the guard pistol - 8 shots, then reload
				"####" G 0 { bNoPain = True; }
				"####" G 30 {
					A_StartSound("luger/reload", CHAN_ITEM, 0, FRandom (0.3, 0.6), ATTN_NORM);
					shots = 0;
				}
				"####" G 0 {
					bNoPain = False;
					return ResolveState("Chase");
				}
		MP40: // Emulates the MP40.  Firing pattern similar to the original Wolf3D SS, just because...
			"####" FG 10 {
				A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				shots = 0;
			}
			MP40.Refire:
				"####" G 5 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				"####" H 5 LIGHT("NaziFire") A_FollowerFire("MP40Tracer", "Casing9mm", "nazi/mp40", 50, 4);
 				"####" G 0 A_RefireReload("MP40.Refire", "MP40.Reload", 128, 4, 32);
			MP40.Reload:
				"####" F 0 { bNoPain = True; }
				"####" F 30 {
					A_StartSound("MP40/reload", CHAN_WEAPON);
					totalshots = 0;
				}
				"####" F 0 {
					bNoPain = False;
					return ResolveState("Chase");
				}
		Rifle:
			"####" FG 6 {
				A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				shots = 0;
			}
			Rifle.Refire:
				"####" H 5 LIGHT("NaziFire") A_FollowerFire("ThompsonTracer", "MauserRifleCasing", "nazi/stg44", 40, 4, 2, 2);
				"####" G 5 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
 				"####" G 0 A_RefireReload("Rifle.Refire", "Rifle.Reload", 128, 10, 40);
			Rifle.Reload:
				"####" F 0 { bNoPain = True; }
				"####" F 30 {
					A_StartSound("sten/reload", CHAN_WEAPON);
					totalshots = 0;
				}
				"####" F 0 {
					bNoPain = False;
					return ResolveState("Chase");
				}
		Shotgun:
			"####" F 4 {
				A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				shots = 0;
			}
			Shotgun.Refire:
				"####" H 5 LIGHT("NaziFire") A_FollowerFire("ShotgunTracer", "ShotgunCasing", "shotgun/fire", 35, Random(5, 15), 2.0, 1.5, 10);
				"####" G 5;
 				"####" F 15 {
					A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
					A_StartSound("shotgun/pump", CHAN_WEAPON);
				}
				"####" F 0 {
					reloadcount++;
					return A_RefireReload("Shotgun.Refire", "Shotgun.Reload", 128, Random(1, 4), (target && target.bShootable || bFrightened) ? 1 : 8); // Quick reload if he's in trouble, otherwise wait to do all 8
				}
			Shotgun.Reload:
				"####" F 0 {
					bNoPain = True;
					frighttimeout += 10;
					A_StartSound("shotgun/load", CHAN_WEAPON);
					reloadcount--;
				}
				"####" BBBBBCCCCC 1 A_Chase(null, null); // Reload on the run!
				"####" DDDDDEEEEE 1 A_Chase(null, null);
				"####" F 0 {
					if (reloadcount <= 0)
					{
						A_StartSound("shotgun/pump", CHAN_WEAPON);
						bNoPain = False;
						return ResolveState("Chase");
					}
					return ResolveState("Shotgun.Reload");
				}
		Grenade:
			"####" F 16 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
			"####" F 10 A_ThrowGrenade();
		Melee:
			"####" FG 2;
			"####" H 8 A_CustomMeleeAttack(Random[Punch](1, 8) * 3, "knife/swing", "knife/swing");
			Goto Chase;
		Death: // Standard Death - unused, since he's invulnerable, but here just in case needed in future
			"####" J 8;
			"####" K 8 A_Scream;
			"####" L 8 A_NoBlocking;
			"####" M 8;
			"####" N -1;
			Stop;
		Heal:
			"####" F 2 {
				A_StartSound("misc/health_pkup");
				A_GiveInventory("Health", 25);
				healtime = 5;
			}
			"####" F 0 {
				if (nonmoving) { return ResolveState("Chase.Stand"); }
				else if (playerToChase && playerToChase.health && Distance3d(playerToChase) <= 64) { return ResolveState("Chase.Near"); }

				return ResolveState("Chase.Stand");
			}
			Goto Chase;
	}

	state A_FindPlayer() // Also sets up initial sight parameters
	{
		if (!target)
		{
			LookExParams SearchParams;

			SearchParams.fov = 360; // Always look all around for a player to follow
			SearchParams.minDist = 0;
			SearchParams.maxDist = 1024; // Far less than max distance so they don't just open fire from the other side of the map
			SearchParams.maxHearDist = 1024;

			for (int p = 0; p < MAXPLAYERS; p++) { // Iterate through all of the players and find the closest one
				Actor mo = players[p].mo;

				if (mo) {
					if (!mo.bShootable || mo.health <= 0) { continue; }
					if (players[p].cheats & CF_NOTARGET) { continue; }
					if (!IsVisible(mo, false, SearchParams)) { continue; }
					if (!isFriend(mo)) { continue; }
					if (target && Distance3d(mo) > Distance3d(target)) { continue; }

					target = mo;
				}
			}

			SearchParams.fov = fov; // Set default fov for future searches
		}

		if (target)
		{
			playerToChase = target; // Save the player that was targeted as who we want to follow
			target = null; // Clear target pointer
			bChaseGoal = True; // Always chase goal, even when firing
			return ResolveState("Chase");
		}
		return ResolveState("Stand");
	}

	state A_ChaseGoal()
	{
		if (!playerToChase || playerToChase.health <= 0) { return ResolveState("Stand"); } // Make sure a player was targeted as who to chase - if he's dead, target another player (multiplayer support)
		if (nonmoving && allowinteraction > 1) { return ResolveState("Chase.Stand"); } // Followers who will stop standing and catch up on their own are handled differently

		if (target && target is "GrenadeBase") // If you're running from a grenade
		{
			if (!bFrightened || Distance3D(target) > GrenadeBase(target).feardistance) { target = goal; }
			else
			{
				if (nonmoving && !currentGoal) // If you are standing and don't have an origin point set, spawn one
				{
					currentGoal = Spawn("PatrolPoint", pos);
					currentGoal.args[0] = -1;
					currentGoal.args[1] = 0x7FFFFFFF;
					currentGoal.angle = angle;
				}

				if (target) { target.bShootable = true; } // Because A_Chase will try to find a new target if the target isn't shootable...
				A_Chase(null, null); // Use default chase logic to run away
				if (target) { target.bShootable = target.Default.bShootable; }
			}
		}
		else if (nonmoving && !Markers.Size())  // If you're standing (and there were no marker goals already spawned).  If marker goals were spawned, follower will run up to that point, then become nonmoving
		{
			if (currentGoal) // If you have a goal assigned, it's an origin point and you were previously running from a grenade
			{
				if (Distance3D(currentGoal) < Radius) // If you're at the goal, go back to standing
				{
					currentGoal.destroy();
					return ResolveState("Chase.Stand");
				}
				else // Run back to the goal point
				{
					goal = currentGoal;
					A_Chase();
				} 
			}
			else
			{
				return ResolveState("Chase.Stand");
			}
		}
		else // Normal behavior
		{
			if (waterlevel > 1) // Make him able to "swim" - No proper animation, but he can at least move up and down in (and get out of) deep water now
			{
				bFloat = True;
				bNoGravity = True;
				Speed = startSpeed / 2;
			}
			else if (!climbing)
			{
				bFloat = False;
				bNoGravity = False;
				Speed = startSpeed;
			}

			if ( // If he's far, far behind, warp halfway along the trail *if* the destination spot and the actor aren't in sight of the player.
				playertochase &&
				!nocatchup &&
				Markers.Size() >= 150 &&
				Markers[75] &&
				!Markers[75].IsVisible(playerToChase, True) &&
				!IsVisible(playerToChase, True)
			) 
			{
				SetOrigin(Markers[75].pos, true); // Warp to the halfway point
				currentGoal = Markers[75];
				if (!weapon) // Pretend he picked up a pistol and some ammo somewhere, and he will act like a friendly Guard
				{
					weapon = PWEAP_Luger;
					chaseattackchance = max(128, chaseattackchance);
				}
			}
			else if (Markers.Size()) { currentGoal = Markers[Markers.Size() - 1]; }

			goal = currentGoal;

			A_Chase(null, null, CHF_STOPIFBLOCKED); // Use default chase logic to go after our goal without trying to fire

			// Not sure why I'm having to manually handle stepping up onto map objects
			if (
				BlockingMobj && 
				!BlockingMobj.bIsMonster && // Don't let them step up onto players, playerfollowers, enemies, etc.
				(bCanPass || BlockingMobj.bActLikeBridge) &&
				BlockingMobj.pos.z + BlockingMobj.height < pos.z + MaxStepHeight
			)
			{
				SetOrigin((pos.xy, BlockingMobj.pos.z + BlockingMobj.height), true);

				Vector2 newpos = Vec2Angle(speed, angle);
				if (!TryMove(newpos, 0)) { target = null; A_Chase(null, null); } // If you can step up, do so.  If not, forget that target and try a new direction.
			}

			if (playerToChase)
			{
				if (!scouttime && playerToChase.health && Distance3d(playerToChase) <= 64 && waterlevel < 2 && CheckSight(playerToChase)) // If within 64 units of the player, destroy the old waypoints and jump to "Close" state.  Has to be this close so that he can follow you into elevators
				{
					DestroyMarkers();
					return ResolveState("Chase.Near");
				}

				if (currentGoal)
				{
					if (!scouttime && Distance3d(playerToChase) < Distance3d(currentGoal) && CheckSight(playerToChase)) // If closer to player than to goal, destroy the old waypoints and start again fresh
					{
						DestroyMarkers();
					}
					else if (Distance2d(currentGoal) <= max(radius + playerToChase.Radius, 48)) // If within 48 units of goal, good enough - destroy that waypoint, get ready to iterate to the next
					{
						DestroyMarkers(Markers.Find(currentGoal));
					}
				}
			}

			if (health > 25 && weapon && pos.z == floorz && Random[Defend]() < 16) { return A_Defend(false); }
			if (health < (SpawnHealth() * 3 / 4) && Random[Heal]() < 8) { return ResolveState("Heal"); }
		}

		return ResolveState(null);
	}

	void A_LookForGrenades()
	{
		ThinkerIterator Finder = ThinkerIterator.Create("GrenadeBase", STAT_DEFAULT - 6);
		GrenadeBase mo;

		while ( (mo = GrenadeBase(Finder.Next())) )
		{
			if (mo is "Mine") { continue; }
			if (!CheckSight(mo)) { continue; }
			if (mo.bMissile && (mo.target == self || (mo.target is "PlayerPawn" && absangle(mo.angle + 180, AngleTo(mo.target)) > 30))) { continue; } // Ignore missiles fired from self and any from a player that aren't aimed at you
			if (Distance3d(mo) > min(512, (mo.bMissile ? mo.feardistance * max(mo.Speed, mo.vel.length()) : mo.feardistance))) { continue; } // feardistance default is 256 units (see GrenadeBase actor, GrenadeBase.FearDistance property)

			if (!GrenadeBase(target) || Distance3D(mo) < Distance3D(target))
			{
				target = mo;
			}
		}

		if (target && target is "GrenadeBase")
		{
			if (!frighttimeout && (target.bMissile || target is "Whizzer")) { movedir = (target.movedir + RandomPick(1, 2, 6, 7)) % 8; frighttimeout += 16; } // Pick a random direction away from the shooter and the missile's path
			else { frighttimeout += int(min(GrenadeBase(target).feardistance, 140)); } // Be frightened for a few seconds...  Less if there's a small fear distance/radius

			if (!InStateSequence(CurState, FindState("Chase"))) { SetStateLabel("Chase"); }
		}
	}

	state A_Defend(bool atPlayer = true)
	{
		bNoRadiusDmg = False;

		if (CheckInventory("KnifeSilent", 1)) { weapon = PWEAP_Melee; }
		if (CheckInventory("Luger9mm", 1)) { weapon = PWEAP_Luger; } // Or give him a weapon via script and he will act like a friendly Guard
		if (CheckInventory("MP40", 1)) { weapon = PWEAP_MP40; }
		if (CheckInventory("Sten", 1)) { weapon = PWEAP_Rifle; }
		if (CheckInventory("TrenchShotgun", 1)) { weapon = PWEAP_Shotgun; }

		if (CheckInventory("GrenadePickup", 1)) { countgrenades = True; grenadechance = grenadechance ? grenadechance : 16; } // If they have a grenade, use it - if they were given as inventory, count them!
		if (countgrenades && !CheckInventory("GrenadePickup", 1)) { grenadechance = 0; } // If they used all their grenades, don't throw any more

		vel = (0, 0, 0);

		if (target && target is "GrenadeBase" && Distance3D(target) < GrenadeBase(target).feardistance) { return ResolveState("Chase"); }

		if (target == goal) { target = null; }

		if (!target && playerToChase && CheckSight(playerToChase))
		{
			// If you don't have a target, and you see the player being attacked by an enemy, target that enemy.
			let mo = players[playerToChase.PlayerNumber()].attacker;

			if (mo && OkayToSwitchTarget(mo)) { target = mo; }
		}

		if (target && target.health <= 0) { target = null; }
		if (target is "TankBase" && TankBase(target).treads) { target = TankBase(target).treads; }

		enemycount = 0;

		ThinkerIterator Finder = ThinkerIterator.Create("Base", Thinker.STAT_DEFAULT);
		Actor mo;

		double targetrange = MaxTargetRange / 2; // He will still maintain fire or shoot at someone that hits him if they are inside MaxTargetRange, but won't find new enemies outside of this range...

		while ( (mo = Actor(Finder.Next())) )
		{
			if (mo is "TankBase" && TankBase(mo).treads) { mo = TankBase(mo).treads; }

			if (
				mo.health <= 0 ||
				mo.bDormant ||
				!mo.bShootable ||
				mo.bFriendly == bFriendly ||
				mo.GetSpecies() == Species ||
				Distance3d(mo) > targetrange ||
				!CheckSight(mo)
			) { continue; }

			if (Distance3d(mo) < 128.0 && mo is "Nazi") { enemycount += mo.bBoss ? 4 : 1; }

			if (target && target.bCountKill > mo.bCountKill) { continue; }

			target = mo;
			targetrange = Distance3d(mo);
		}

		// Also look for sneakable actors, and ignore their friendliness attribute
		Finder = ThinkerIterator.Create("Nazi", Thinker.STAT_DEFAULT - 5);

		while ( (mo = Actor(Finder.Next())) )
		{
			if (
				mo.health <= 0 ||
				mo.bDormant ||
				mo.GetSpecies() == Species ||
				Distance3d(mo) > targetrange ||
				!CheckSight(mo)
			) { continue; }

			if (Distance3d(mo) < 128.0) { enemycount += mo.bBoss ? 4 : 1; }

			if (target && target.bCountKill > mo.bCountKill) { continue; }

			target = mo;
			targetrange = Distance3d(mo);
		}

		if (!target)
		{
			LookForEnemies(true); // In no Nazis around, fall back to default algorithm to find an enemy to shoot at
		}

		double targetdist = target ? Distance3d(target) : 0;
		double playerdist = playerToChase ? Distance2d(playerToChase) : 0;
		
		if (enemycount > 6) { frighttimeout += enemycount - 5; }

		if (playerToChase)
		{
			if (atPlayer)
			{
				if (!target)
				{
					faceangle = playerToChase.angle + 135 + Random[FaceAngle](-15, 15); // Make him look like he might be able to cover your back
					if (abs(angle - faceangle) > 45) { angle = faceangle; }
/*
					if (!scouttime && Random() < 8)
					{
						scouttime = Random(45, 105);

						Vector3 targetpos = GetLineTargetPos(playerToChase);

						Actor mo = Spawn("PathMarker", targetpos);
						if (PathMarker(mo))
						{
							PathMarker(mo).playerToChase = PlayerPawn(playerToChase);
							PathMarker(mo).follower = self;
							Markers.Insert(0, PathMarker(mo));
						}

						return ResolveState("Chase");
					}
*/
				}

				if (playerdist > radius + 128 + playerToChase.radius) { // If player moves too far away, go back to following (and forget the target if forgettarget = True)
					if (forgettarget) { target = null; }
					return ResolveState("Chase");
				} else if (playerdist < radius + 16 + playerToChase.radius) { // If too close to player, push away
					return ResolveState("Chase.Back");
				}

				if (healplayer && playerToChase.player && playerToChase.player.health < healplayer && !playerhealtime)
				{
					A_StartSound("misc/health_pkup");
					playerhealtime = 2;
					playerToChase.player.health += 10;
					playerToChase.health += 10;
				}
			}
		}

		if (
			weapon &&
			target &&
			target.health > 0 &&
			target != goal &&
			target != self &&
			target.bShootable &&
			!target.bDormant &&
			!target.bInvulnerable &&
			CheckSight(target)
		)
		{ // If you have weapon, have a valid target, and it's in line of sight...
			if (!nonmoving && (!playerToChase || ((playerdist > radius + 128 + playerToChase.radius) && forgettarget))) // ...and if you weren't supposed to forget your target when the player is away...
			{
				target = null;
				goal = playerToChase;
			}
			else if (atPlayer || Random(0, 255) < (chaseattackchance + frighttimeout) || targetdist < radius + 32 + target.radius) // ...and you are at the player, or the target is close, or at random chance...
			{
				if (weapon != PWEAP_Melee || targetdist < radius + 32 + target.radius) // ...and you are in range...
				{
					// Do a line trace, and if the trace will hit a shootable actor, then fire
					DoTrace(self, AngleTo(target), MaxTargetRange, PitchTo(target), 0, Height * 3 / 4, trace);
					if (trace.Results.HitActor && (trace.Results.HitActor.bIsMonster || trace.Results.HitActor.Species == "NaziTank"))
					{
						return ResolveState(GetWeaponStateLabel()); // ...attack it
					}
				}
			}
		}

		if (!atPlayer && health < (SpawnHealth() * 3 / 4) && Random[Heal]() < 8) { return ResolveState("Heal"); }

		return ResolveState(null);
	}

	void DoTrace(Actor origin, double angle, double dist, double pitch, int flags, double zoffset, BoAFindHitPointTracer thistracer)
	{
		if (!origin) { origin = self; }

		thistracer.skipspecies = origin.species;
		thistracer.skipactor = origin;
		Vector3 tracedir = (cos(angle) * cos(pitch), sin(angle) * cos(pitch), -sin(pitch));
		thistracer.Trace(origin.pos + (0, 0, zoffset), origin.CurSector, tracedir, dist, 0);
	}

	void A_FollowerFire(class<Actor> weapontracer, class<Actor> casing, sound weaponsound = "nazi/pistol", int zoffset = 54, int xyoffset = 1, double angleoffset = 8, double pitchoffset = 0, int shots = 1)
	{
		vel = (0, 0, 0);

		A_StartSound(weaponsound, CHAN_WEAPON);
		A_AlertMonsters(0, AMF_TARGETEMITTER);
		for (int i = 0; i < shots; i++)
		{
			angleoffset = FRandom(-angleoffset, angleoffset);
			pitchoffset = FRandom(-pitchoffset, pitchoffset);

			Actor shot = A_SpawnProjectile(weapontracer, zoffset, xyoffset, angleoffset, CMF_OFFSETPITCH, pitchoffset);
			if (shot && target && target.bBoss)
			{
				shot.SetDamage(max(1, int(shot.damage * (5 - G_SkillPropertyInt(SKILLP_ACSReturn)) / 5.0))); // Decrease damage done based on skill level
			}
		}
		A_SpawnItemEx(casing, 1, 0, 56, Random(1, 2), Random(-1, 1), Random(1, 2), Random(-55, -80), SXF_NOCHECKPOSITION);
		shots++;
		totalshots++;
	}

	state A_RefireReload(statelabel Refire, statelabel Reload, int chance = 128, int refireshots = 0, int reloadshots = 8)
	{
		if (playerToChase)
		{
			// If player moves too far away, go back to following
			if (!nonmoving && Distance3D(playerToChase) > radius + 1024 + playerToChase.radius)
			{
				chance = 0;
			}
		}

		if (reloadshots && totalshots >= reloadshots) {
			shots = 0;
			totalshots = 0;
			return ResolveState(Reload);
		}

		if (target) { DoTrace(self, AngleTo(target), MaxTargetRange, PitchTo(target), 0, Height * 0.9, trace); }

		if (target && target.health > 0 && target.bShootable && Distance3D(target) > 0 && trace.Results.HitActor && trace.Results.HitActor.bIsMonster && (refireshots && shots < refireshots))
		{
			chance = int(chance / (Distance3D(target) / MissileRanges[weapon]));

			if (Random(0, 255) < chance) { return ResolveState(Refire); }
		}

		return ResolveState("Chase");
	}

	void A_ThrowGrenade(int variance = 5)
	{
		if (playerToChase.Distance3d(target) > 128)
		{
			bNoRadiusDmg = True;
			A_SpawnProjectile("HandGrenade", 60, 0, Random[Grenade](-variance, variance), CMF_OFFSETPITCH | CMF_SAVEPITCH | CMF_BADPITCH, FRandom[Grenade](variance, 15 * (GetZAt(0, 0, 0, GZF_CEILING) / 128.0)));
			TakeInventory("GrenadePickup", 1);
		}
	}

	statelabel GetWeaponStateLabel()
	{
		if (Random[GrenadeToss]() < grenadechance) { return MissileStateNames[PWEAP_Grenade]; } // Always randomly toss grenades if he has them

		return MissileStateNames[weapon];
	}

	// Destroys array-linked actors in the range of the specified indices.  Default is to destroy all of the markers and clear the array.
	void DestroyMarkers(int start = 0, int end = -1)
	{
		int max = Markers.Size() - 1;

		if (start < 0 || end > max) { return; } // Error catching, just in case...

		if (end < 0) { end = max; }

		for (int i = start; i <= end; i++)
		{
			if (Markers[i]) { Markers[i].Destroy(); }
		}

		Markers.Delete(start, end - start + 1);

		if (start == 0 && end == max) { Markers.Clear(); }
		if (end == max) { Markers.ShrinkToFit(); }
	}

	// Return the aim pitch offset from the source to the target
	double PitchTo(Actor mo, Actor source = null, double sourcepitch = 0)
	{
		if (source == null) { source = self; }
		if (!sourcepitch) { sourcepitch = source.pitch; }

		double distxy = max(source.Distance2D(mo), 1);
		double distz = source.pos.z - mo.pos.z;

		double targetheight = mo.player ? mo.height * mo.player.crouchfactor : mo.height; // Get target height, with crouching if applicable

		double pitchcalc = (atan(distz / distxy) + atan((distz - targetheight) / distxy)) / 2; // Return pitch to actor middle.

		return pitchcalc - sourcepitch % 360; // Normalize to 360 degree range
	}

	override void PostBeginPlay()
	{
		if (user_nonmoving) { nonmoving = user_nonmoving; } // For compatibility with old ACS scripts from before this variable was given the "user_" prefix

		Markers.Clear();

		trace = new("BoAFindHitPointTracer");

		offset = Random(0, 35);

		if (bFriendly) { BoACompass.Add(self, "GOAL1"); }

		GiveInventoryType("BoAFootsteps");

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (health <= 0) { Super.Tick(); return; }

		if (scouttime > 0) { scouttime--; }

		if ((level.time + offset) % 5 == 0) { A_LookForGrenades(); }

		if (waterlevel > 0)
		{
			// Only do this on entering the water
			if (waterlevel > oldwaterlevel && waterlevel == 1)
			{
				Spawn("SplashStep", (pos.x, pos.y, pos.z + 14));
			}
		}

		oldwaterlevel = waterlevel;

		if ((!nonmoving || allowinteraction > 1) && playerToChase && !playerToChase.bNoClip && Level.time % 5 == 0 && health > 0) // Spawn a waypoint at the player's position every 5 tics if the player has moved, and push it into an array
		{
			if (playerToChase.pos != oldPlayerPos)
			{
				Actor mo = Spawn("PathMarker", playerToChase.pos);
				if (PathMarker(mo))
				{
					PathMarker(mo).playerToChase = PlayerPawn(playerToChase);
					PathMarker(mo).follower = self;
					Markers.Insert(0, PathMarker(mo));
				}
				oldPlayerPos = playerToChase.pos;
			}
		}

		if (allowinteraction > 1 && nonmoving && playerToChase && !playerToChase.bNoClip && Distance3D(playerToChase) > allowinteraction)
		{
			nonmoving = false;
			if (!weapon) // Pretend he picked up a pistol and some ammo somewhere
			{
				weapon = PWEAP_Luger;
				chaseattackchance = max(128, chaseattackchance);
			}
			SetStateLabel("Chase");
		}

		// Don't stay standing near enemies; run away based on how much spawn health they have
		if (target && IsHostile(target) && Distance3D(target) < target.Default.health / 5) { frighttimeout = max(frighttimeout, target.Default.health / 100); }

		frighttimeout = clamp(frighttimeout - 1, 0, 210);

		bFrightened = frighttimeout > 0;

		if (healtime > 0 && gametic % 2 == 0)
		{
			healtime = max(healtime - 1, 0);
			A_SpawnItemEx(healparticle, random(10,-10), random(10,-10), random(16,64), 0, 0, random(1, 2), 0);
		}

		if (playerToChase && playerhealtime > 0 && gametic % 20 == 0)
		{
			playerhealtime = max(playerhealtime - 1, 0);
			playerToChase.A_SpawnItemEx(healparticle, random(10,-10), random(10,-10), random(16,64), 0, 0, random(1, 2), 0);
		}

		Super.Tick();
	}

	override bool Used(Actor user)
	{
		if (!IsFriend(user)) { return false; }

		String msg = "";

		if (!Default.user_nonmoving && allowinteraction) { nonmoving = !nonmoving; } // If not set nonmoving by default or disabled, allow toggling...

		if (nonmoving)
		{
			if (allowinteraction)
			{
				msg = "STAY" .. Random(0, 4);
				activationcount = 0;
			}
			else
			{
				msg = "STATIC" .. activationcount;
				activationcount = min(activationcount + 1, 4);
			}
		}
		else
		{
			playerToChase = user;

			if (allowinteraction)
			{
				msg = "COME" .. Random(0, 4);
				activationcount = 0;
			}
			else
			{
				msg = "ALWAYS" .. activationcount;
				activationcount = min(activationcount + 1, 4);
			}
		}

		if (msg != "")
		{
			String classmsg = GetClassName() .. msg; // Try to use a class-specific message
			if (StringTable.Localize(classmsg, false) ~== classmsg) { classmsg = "FOLLOWER" .. msg; } // Otherwise fall back to generic FOLLOWER* message

			Message.InitWithName(user, head, classmsg, charname);
		}

		return false;
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (
			source &&
			source.health > 0 &&
			source.bShootable &&
			source.bIsMonster &&
			!IsFriend(source) &&
			source.GetSpecies() != Species &&
			source.bFriendly != bFriendly &&
			(!target || Distance3D(source) < Distance3D(target))
		)
		{
			target = source; // If the follower is hit by an enemy that's closer than its current target, change targets to the one that shot it
		}

		// Manually handle falling damage calculation here, since P_MonsterFallingDamage is useless (It literally 
		// calculates the correct damage value, then ignores that and sets damage to Telefrag amount - blame Hexen's devs)
		// https://github.com/coelckers/gzdoom/blob/777798ede4b68cc71d1e1313d491e70c0eef9593/src/playsim/p_mobj.cpp#L2357
		// https://forum.zdoom.org/viewtopic.php?f=18&t=32702
		if (mod == "Falling") { damage = CalculateFallDamage(); }

		return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
	}

	// Derived from ZDoom-style damage calculations in player's P_FallingDamage function of p_mobj.cpp
	int CalculateFallDamage()
	{
		int damage;
		double vel = abs(vel.z);

		if (vel <= 19 || level.time < spawntime + 70) // Not fast enough to hurt - Or they were just spawned, so make sure they survive accidental in-air spawning
		{ 
			damage = 0;
		}
		if (vel >= 84) // Automatic death
		{ 
			damage = TELEFRAG_DAMAGE;
		}
		else
		{
			damage = int(max((vel ** 2 * (11.0 / 128) - 30) / 2, 1));
		}

		return damage;
	}

	Vector3 GetLineTargetPos(Actor source)
	{
		if (!source) { source = self; }

		CrosshairTracer actortrace;
		actortrace = new("CrosshairTracer");

		actortrace.skipactor = source;
		Vector3 tracedir = (cos(source.angle) * cos(source.pitch), sin(source.angle) * cos(source.pitch), -sin(source.pitch));
		actortrace.Trace(source.pos + (0, 0, height * 0.8), source.CurSector, tracedir, 2560, 0);

		return actortrace.Results.HitPos - 16.0 * actortrace.Results.HitVector;
	}

	static void SetGoal(int tid, int goaltid)
	{
		let gt = Level.CreateActorIterator(goaltid);
		Actor goal = gt.Next();

		let it = Level.CreateActorIterator(tid, "PlayerFollower");
		PlayerFollower pf;
		while (pf = PlayerFollower(it.Next()))
		{
			pf.Markers.Clear();
			pf.currentgoal = goal;
		}
	}
}

class PlayerFollower2 : PlayerFollower // Alternate frames versions - for almost all actors except prisoner, with N as standing frame and A-D walking, EFG firing, H pain, IJKLM Death
{
	States
	{
		Spawn:
			ARH2 N 1;
			Goto Initialize;
		Stand:
			"####" N 1;
			"####" N 0 A_FindPlayer();
		Chase.Back:
			"####" DDDDD 1;
			"####" CCCCCBBBBB 1 {
				if (playerToChase)
				{
					double pushAngle = AngleTo(playerToChase) + 180;
					Thrust(Speed / 5, pushAngle);
				}
			}
		Chase:
			"####" AAAAABBBBB 1 A_ChaseGoal();
			"####" CCCCCDDDDD 1 A_ChaseGoal();
			Loop;
		Chase.Near:
			"####" NNNNN 1 A_Defend();
			Loop;
		Chase.Stand: // Wherever standing, take up defensive position (if armed), otherwise stand stupidly
			"####" NNNNN 1 A_Defend(false);
			"####" N 0 { if (!nonmoving) { return ResolveState("Chase"); } return ResolveState(null); }
			Loop;
		Pain:
			"####" H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-8, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR);
			"####" H 3 {
				A_Pain();
				if (Random(0, 1023) < PainChance) { frighttimeout += min(SpawnHealth() - health, 10); }
			}
			Goto Chase;
		Luger:
			"####" EF 10 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
			Luger.Refire:
				"####" G 8 LIGHT("NaziFire") A_FollowerFire("LugerTracer", "Casing9mm", "nazi/pistol", 54, 1);
				"####" F 8;
 				"####" F 0 A_RefireReload("Luger.Refire", "Luger.Reload");
			Luger.Reload: // More emulation of the guard pistol - 8 shots, then reload
				"####" F 0 { bNoPain = True; }
				"####" F 30 {
					A_StartSound("luger/reload", CHAN_ITEM, 0, FRandom (0.3, 0.6), ATTN_NORM);
					A_SpawnItemEx("Casing9mm", 1, 0, 56, Random(3, 4), Random(-1, 1), Random(2, 4), Random(-55,-80), SXF_NOCHECKPOSITION);
					shots = 0;
				}
				"####" F 0 {
					bNoPain = False;
					return ResolveState("Chase.Near");
				}
		MP40:
			"####" EF 10 {
				A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				shots = 0;
			}
			MP40.Refire:
				"####" F 5 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				"####" G 5 LIGHT("NaziFire") A_FollowerFire("MP40Tracer", "Casing9mm", "nazi/mp40", 50, 4);
 				"####" F 0 A_RefireReload("MP40.Refire", "MP40.Reload", 128, 4, 32);
			MP40.Reload:
				"####" E 0 { bNoPain = True; }
				"####" E 30 {
					A_StartSound("MP40/reload", CHAN_WEAPON);
					A_SpawnItemEx("Casing9mm", 8, 0, 40, Random(3, 4), Random(-1, 1), Random(2, 4), Random(-55, -80),SXF_NOCHECKPOSITION);
					totalshots = 0;
				}
				"####" E 0 {
					bNoPain = False;
					return ResolveState("Chase.Near");
				}
		Rifle:
			"####" EF 6 {
				A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				shots = 0;
			}
			Rifle.Refire:
				"####" G 5 LIGHT("NaziFire") A_FollowerFire("ThompsonTracer", "MauserRifleCasing", "nazi/stg44", 38, 4, 2, 2);
				"####" F 5 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
 				"####" F 0 A_RefireReload("MP40.Refire", "MP40.Reload", 128, 10, 40);
			Rifle.Reload:
				"####" E 0 { bNoPain = True; }
				"####" E 30 {
					A_StartSound("sten/reload", CHAN_WEAPON);
					totalshots = 0;
				}
				"####" E 0 {
					bNoPain = False;
					return ResolveState("Chase.Near");
				}
		Shotgun:
			"####" E 4 {
				A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				shots = 0;
			}
			Shotgun.Refire:
				"####" G 5 LIGHT("NaziFire") A_FollowerFire("ShotgunTracer", "ShotgunCasing", "shotgun/fire", 35, Random(5, 15), 2.0, 1.5, 10);
				"####" F 5;
 				"####" E 15 {
					A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
					A_StartSound("shotgun/pump", CHAN_WEAPON);
				}
				"####" E 0 {
					reloadcount++;
					return A_RefireReload("Shotgun.Refire", "Shotgun.Reload", 128, Random(1, 4), (target && target.bShootable || bFrightened) ? 1 : 8); // Quick reload if he's in trouble, otherwise wait to do all 8
				}
			Shotgun.Reload:
				"####" E 0 {
					bNoPain = True;
					frighttimeout = 35;
					A_StartSound("shotgun/load", CHAN_WEAPON);
					reloadcount--;
				}
				"####" AAAAABBBBB 1 A_Chase(null, null); // Reload on the run!
				"####" CCCCCDDDDD 1 A_Chase(null, null);
				"####" E 0 {
					if (reloadcount <= 0)
					{
						A_StartSound("shotgun/pump", CHAN_WEAPON);
						bNoPain = False;
						return ResolveState("Chase");
					}
					return ResolveState("Shotgun.Reload");
				}
		Grenade:
			"####" E 16 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
			"####" E 10 A_ThrowGrenade();
		Melee:
			"####" EF 2;
			"####" G 8 A_CustomMeleeAttack(Random[Punch](1, 8) * 3, "knife/swing", "knife/swing");
			Goto Chase;
		Death:
			"####" I 8;
			"####" J 8 A_Scream;
			"####" K 8 A_NoBlocking;
			"####" L 8;
			"####" M -1;
			Stop;
		Heal:
			"####" E 2 {
				A_StartSound("misc/health_pkup");
				A_GiveInventory("Health", 25);
				healtime = 5;
			}
			"####" E 0 {
				if (nonmoving) { return ResolveState("Chase.Stand"); }
				else if (playerToChase && playerToChase.health && Distance3d(playerToChase) <= 64) { return ResolveState("Chase.Near"); }

				return ResolveState("Chase.Stand");
			}
			Goto Chase;
	}
}

// Minimal actor to use as waypoints
class PathMarker : Actor
{
	PlayerPawn playerToChase;
	PlayerFollower follower;

	Default
	{
		+NOINTERACTION
		+NOTONAUTOMAP
		+NODAMAGE
		Height 0;
		Radius 0;
	}

	States
	{
		Spawn:
			TNT1 A -1;
			Stop;
	}	

	override void Tick()
	{
		Super.Tick();

		if (!follower || !playerToChase)
		{
			Destroy();
			return;
		}

		int index = follower.Markers.Find(self);
		if (index == follower.Markers.Size()) { Destroy(); }

		// If the player crosses their own path, cut out the loop so the follower takes the most direct route after the player
		if (index > 10 && Distance3D(playerToChase) < 48)
		{
			follower.DestroyMarkers(0, index);
		}

		// If the follower crosses the path at a later point than their current goal, make this spot their new current goal
		if (Distance3D(follower) < 32)
		{
			if (!follower.currentGoal || index < follower.Markers.Find(follower.currentGoal)) { follower.currentGoal = self; }
		}
	}
}

///// Player Follower Actors /////

// Original Prisoner follower
class PrisonerAgent : PlayerFollower
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Cpt. James Ryan (Friendly Follower - Prisoner)
		//$Color 4

		Radius 6; // Smaller than player radius
		Speed 6; // He can't run as fast as you can, so will usually lag behind
		Scale 0.67;
		+FRIENDLY
		+NOINFIGHTING
		Obituary "$PRISONER";
		Species "PlayerFollower";
		PlayerFollower.CloseFollow True;
		PlayerFollower.ChaseAttackChance 0;
		PlayerFollower.CanBeCommanded 4096;
		PlayerFollower.Head "MS_PRIB";
		PlayerFollower.CharName "PRISONERAGENTNAME";
	}

	States
	{
		Spawn:
			TORT A 1;
			Goto Initialize;
		Saved:
			TORT OPQRS 4;
			TORT T 4 {vel.z += 8.0;}
			TORT U 4 A_StartSound("prisoner/yeeeah", CHAN_WEAPON);
			TORT VWVUTRP 4;
			Goto Spawn;
	}
}

//Ryan Armed followers
class AgentArmed : PlayerFollower
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Cpt. James Ryan (Friendly Follower - Luger)
		//$Color 4

		Speed 8; // A bit faster than the beat-up prisoner version
		PainChance 64;
		Scale 0.67;
		-NODAMAGE
		+BUDDHA
		+FRIENDLY
		+NOINFIGHTING
		Obituary "$FRIENDLY";
		Species "PlayerFollower";
		PlayerFollower.Weapon PWEAP_Luger;
		PlayerFollower.ChaseAttackChance 196;
		PlayerFollower.GrenadeChance 0;
		PlayerFollower.CanBeCommanded True;
		PlayerFollower.Head "MS_PRIS";
		PlayerFollower.CharName "PRISONERAGENTNAME";
	}

	States
	{
		Spawn:
			FREE A 1;
			Goto Initialize;
	}
}

class AgentArmedMP40 : AgentArmed
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Cpt. James Ryan (Friendly Follower - MP40)
		//$Color 4

		PlayerFollower.Weapon PWEAP_MP40;
		PlayerFollower.CharName "PRISONERAGENTNAME";
	}

	States
	{
		MP40: // Matches PrisonerEnemyBoss firing pattern (just slower firing for balance reasons).
			"####" FG 5 {
				A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				shots = 0;
			}
			MP40.Refire:
				"####" G 4 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
				"####" H 4 LIGHT("NaziFire") A_FollowerFire("MP40Tracer", "Casing9mm", "nazi/mp40", 50, 4);
 				"####" G 0 A_RefireReload("MP40.Refire", "MP40.Reload", 192, 4, 40);
			MP40.Reload:
				"####" F 0 { bNoPain = True; }
				"####" F 30 {
					A_StartSound("MP40/reload", CHAN_WEAPON);
					totalshots = 0;
				}
				"####" F 0 {
					bNoPain = False;
					return ResolveState("Chase");
				}
	}
}

class AscherArmed : PlayerFollower
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Sgt Ascher (Friendly Follower - Rifle)
		//$Color 4

		Speed 8;
		PainChance 32;
		Scale 0.67;
		-NODAMAGE
		+BUDDHA
		+FRIENDLY
		+NOINFIGHTING
		Obituary "$FRIENDLY";
		Species "PlayerFollower";
		PlayerFollower.Weapon PWEAP_Rifle;
		PlayerFollower.ChaseAttackChance 128;
		PlayerFollower.GrenadeChance 0;
		PlayerFollower.CanBeCommanded True;
		PlayerFollower.Head "MS_OFFC";
		PlayerFollower.HealPlayer 40;
		PlayerFollower.CharName "ASCHERNAME";
	}

	States
	{
		Spawn:
			PARS A 1;
			Goto Initialize;
		Pain:
			"####" J 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-8, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR);
			"####" J 3 {
				A_Pain();
				if (Random(0, 1023) < PainChance) { frighttimeout += min(SpawnHealth() - health, 10); }
			}
			Goto Chase;
		Death:
			"####" J 8 A_Scream;
			"####" K 8 A_NoBlocking;
			"####" LMN 8;
			"####" O -1;
			Stop;
	}
}

class SSAscherArmed : PlayerFollower2
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title SS Sgt Ascher (Friendly Follower - Luger)
		//$Color 4

		Speed 8;
		PainChance 64;
		Scale 0.67;
		-NODAMAGE
		+BUDDHA
		+FRIENDLY
		+NOINFIGHTING
		Obituary "$FRIENDLY";
		Species "PlayerFollower";
		PlayerFollower.Weapon PWEAP_Luger;
		PlayerFollower.ChaseAttackChance 196;
		PlayerFollower.GrenadeChance 0;
		PlayerFollower.CanBeCommanded True;
		PlayerFollower.Head "MS_OFFS";
		PlayerFollower.CharName "ASCHERNAME";
	}

	States
	{
		Spawn:
			ASC2 A 1;
			Goto Initialize;
	}
}

//Not-Darren follower
class DouglasArmed : PlayerFollower2
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Dirty Douglas (Friendly Follower - Pistol)
		//$Color 4

		Speed 7;
		Obituary "$FRIENDLY";
		Scale 0.67;
		+FRIENDLY
		+NOINFIGHTING
		Translation 1;
		Species "PlayerFollower";
		PlayerFollower.Weapon PWEAP_Luger;
		PlayerFollower.ChaseAttackChance 96;
		PlayerFollower.CanBeCommanded True;
		PlayerFollower.Head "MS_DARR";
		PlayerFollower.CharName "DARRENNAME";
	}

	States
	{
		Spawn:
			DARR A 1;
			Goto Initialize;
		Luger:
			"####" EF 10 A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
			Luger.Refire:
				"####" G 8 LIGHT("NaziFire") A_FollowerFire("LugerTracer", "Casing9mm", "nazi/pistol", 54, 1, 1);
				"####" F 8;
 				"####" F 0 A_RefireReload("Luger.Refire", "Luger.Reload", 128, Random(4, 8));
	}
}

// Armed soldier followers
class SoldierArmed : PlayerFollower
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Soldier (Friendly Follower - Pistol)
		//$Color 4

		Speed 7;
		PainChance 64;
		Scale 0.67;
		+FRIENDLY
		+NOINFIGHTING
		-NODAMAGE
		Health 300;
		DamageFactor "Bullet", 0.05;
		DamageFactor "Normal", 0.05;
		Obituary "$FRIENDLY";
		Species "PlayerFollower";
		PlayerFollower.Weapon PWEAP_Luger;
		PlayerFollower.CanBeCommanded True;
	}

	States
	{
		Spawn:
			ARH2 A 1;
			Goto Initialize;
	}
}

class SoldierArmedRifle : SoldierArmed
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Soldier (Friendly Follower - Machine Gun)
		//$Color 4

		PlayerFollower.Weapon PWEAP_Rifle;
	}

	States
	{
		Spawn:
			ARMH A 1;
			Goto Initialize;
	}
}


class SoldierArmedShotgun : SoldierArmed
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title Soldier (Friendly Follower - Shotgun)
		//$Color 4

		PlayerFollower.Weapon PWEAP_Shotgun;
	}

	States
	{
		Spawn:
			ARMH A 1;
			Goto Initialize;
	}
}

class DogFollower : PlayerFollower2
{
	Default
	{
		//$Category Monsters (BoA)/NPCs/Followers
		//$Title German Shepherd (Friendly Follower - Melee)
		//$Color 4

		Speed 4;
		Scale 0.67;
		+FRIENDLY
		+NOINFIGHTING
		PlayerFollower.ChaseAttackChance 256;
		PlayerFollower.Weapon PWEAP_Melee;
		PlayerFollower.Head "";
	}

	States
	{
		Spawn:
			DOG2 A 1;
			Goto Initialize;
		Stand:
			"####" A 1;
			"####" A 0 A_FindPlayer();
		Chase.Back:
			"####" DDDD 1;
			"####" CCCCBBBB 1 {
				double pushAngle = AngleTo(playerToChase) + 180;
				Thrust(1, pushAngle);
			}
		Heal: // Dogs can't heal themselves.
		Chase:
			"####" A 0 { Speed = 8; }
			"####" AAAABBBB 1 A_ChaseGoal();
			"####" CCCCDDDD 1 A_ChaseGoal();
			Loop;
		Chase.Near:
			"####" A 0 { Speed = 4; }
			"####" A 0 A_Defend();
			"####" AAA 1 A_Chase(null, null);
			"####" A 0 A_Defend();
			"####" BBB 1 A_ChaseGoal();
			"####" A 0 A_Defend();
			"####" CCC 1 A_Chase(null, null);
			"####" A 0 A_Defend();
			"####" DDD 1 A_ChaseGoal();
			Loop;
		Pain:
			"####" M 4 A_Pain();
			Goto Chase;
		Melee:
			"####" EF 2 Fast A_FaceTarget(0, 0, 0, 0, FAF_MIDDLE, height * 3 / 4);
			"####" G 8 Fast A_CustomMeleeAttack(Random[Bite](1, 8) * 3, "dog/attack", "dog/attack");
			"####" G 0 A_AlertMonsters(0, AMF_TARGETEMITTER);
			"####" FE 2 Fast;
			Goto Chase;
		Death:
			"####" H 8;
			"####" I 8 A_Scream;
			"####" J 8;
			"####" K -1 A_NoBlocking;
			Stop;
	}
}