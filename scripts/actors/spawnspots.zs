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

  ActorSpawner
    These are spawn point actors that spawn actors when active, and maintain a set
    number of those actors alive (1 by default).  Actors will not be spawned if a player
    can see the spawn point or if a player is within a defined minimum spawn distance
    from the spawner (default 512 units).

    By default, the spawner will spawn a single guard.  Once that guard is killed, the
    spawner will spawn another guard, and so on.

    Spawned actors can be given a TID and can be set to navigate to a specific
    PatrolPoint TID after spawn as well.

  Custom UDMF Properties
    arg0str
      Sets the class of actor to be spawned (default "Guard")

    user_tid
      Sets the TID that the spawned enemies are given.  By default they have no TID.

    user_goal
      Sets the goal/patrolpoint TID that the spawned enemies will walk to once they return to
      being idle.  By default, they go back to their spawn point and stand still.

    user_maxactors
      Sets how many enemies from this spawner to maintain alive at once (default 1) - use negative numbers to set total number spawned instead of number to keep alive

    user_minspawndistance
      Distance from player inside of which the spawner will stop spawning (default 512)

*/
class ActorSpawner : SwitchableDecoration
{
	Array<Actor> Spawns;
	Class<Actor> user_spawntype;
	Actor closestplayer;

	// TID to give the spawned enemy actor (default no TID)
	int user_tid;

	// TID of goal that the enemy should walk to after spawning (default no goal)
	int user_goal;

	// How many enemies from this spawner to maintain alive at once (default 1)
	int user_maxactors;

	// How many enemies from this spawner to spawn in total (defaults to infinite)
	int user_maxspawns;

	// Distance from player inside of which the spawner will stop spawning (default 512)
	int user_minspawndistance;

	// Should these actors show up on the compass?
	bool user_oncompass;

	Default
	{
		//$Category Misc (BoA)
		//$Title Spawner, Actor
		//$Arg0 "Thing ID to spawn"
		//$Arg0Str "Actor class to spawn"
		//$Arg0ToolTip "What actor to spawn.  Numeric values set Thing ID, and string values set spawn class."
		//$Arg1 "Maximum number alive"
		//$Arg1ToolTip "Determines the number of actors to keep alive at once (e.g., '5' will spawn a new actor every time you kill one, keeping 5 alive at all times)."
		//$Arg2 "TID to give actor"
		//$Arg2ToolTip "TID that will be given to the spawned actor(s).  Default is 0 (no TID)."
		//$Arg3 "Minimum player distance"
		//$Arg3ToolTip "Distance that the player must be away from this actor in order for spawns to take place.  A value of '0' defaults to 512."
		//$Arg3Default 512
		//$Arg4 "Maximum number to spawn, total"
		//$Arg4ToolTip "Determines the number of actors to spawn in total, regardless of how many are killed. Zero means unlimited."
		//$Sprite EXCLC0
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Loop;
		Active:
			"####" "#" 35 A_SetTics(Random[Spawn](1, 7 - skill) * 5);
			"####" "#" 0 { return ResolveState("Active.Spawn"); }
		Active.Spawn:
			"####" "#" 1 A_DoSpawns();
		Inactive:
			"####" "#" 35;
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Spawns.Clear();

		user_spawntype = GetSpawnableType(args[0]);
		user_maxactors = args[1];
		user_tid = args[2];
		user_minspawndistance = args[3];
		user_maxspawns = args[4];

		if (!user_spawntype) { user_spawntype = "Guard"; }
		if (user_maxactors == 0) { user_maxactors = 1; }
		if (user_minspawndistance == 0) { user_minspawndistance = 512; }

		if (bDormant) { SetStateLabel("Inactive"); }
	}

	static void SetArgument(int tid, int arg, int value)
	{
		if (arg < 0 || arg > 4) return;
		ActorIterator it = Level.CreateActorIterator(tid);
		ActorSpawner spawner = ActorSpawner(it.Next());
		while (spawner != null)
		{
			spawner.Args[arg] = value;
			switch (arg)
			{
			case 0:
				spawner.user_spawntype = GetSpawnableType(value);
				break;
			case 1:
				spawner.user_maxactors = value;
				break;
			case 2:
				spawner.user_tid = value;
				break;
			case 3:
				spawner.user_minspawndistance = value;
				break;
			case 4:
				spawner.user_maxspawns = value;
				break;
			}
			spawner = ActorSpawner(it.Next());
		}
	}

	// Iterate through all of the players and see if any can see the spawn point
	bool InPlayerSightOrRange(int range = 512)
	{
		double dist = !!closestplayer ? Distance3D(closestplayer) : 0x7FFFFFFF;

		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p]) { continue; }

			Actor mo = players[p].mo;
			double modist = Distance3d(mo);

			if (mo && modist < dist)
			{
				closestplayer = mo;
				dist = modist;
			}

			if (dist <= range) { return true; }
		}

		double lightlevel, fogfactor;
		[lightlevel, fogfactor] = ZScriptTools.GetLightLevel(CurSector);

		// Only care about the player seeing the spot if it's light enough to see
		if ((!fogfactor && lightlevel > 80) || (fogfactor && 25 > (dist / fogfactor)))
		{
			for (int q = 0; q < MAXPLAYERS; q++)
			{
				if (!playeringame[q]) { continue; }

				Actor mo2 = players[q].mo;

				LookExParams look;
				look.fov = mo2.player.fov * 1.4; // Plus a little extra to account for wider screen ratios...

				if (mo2 && mo2.IsVisible(self, false, look)) { return true; }
			}
		}

		return false;
	}

	int CountSpawns(Class<Actor> spawntype = null, bool countdead = false)
	{
		int spawncount = 0;

		for (int i = 0; i < Spawns.Size(); i++)
		{
			Actor mo = Spawns[i];

			if (mo)
			{
				if (mo is "RandomSpawner")
				{
					mo = mo.tracer;
					if (!mo)
					{
						Spawns.Delete(i);
						continue;
					}
				}

				if (!spawntype || mo.GetClass() == spawntype)
				{
					if (countdead || (mo.bShootable && mo.health > 0))
					{
						spawncount++;
					}
				}
			}
		}

		return spawncount;
	}

	virtual int TotalSpawns(Class<Actor> spawntype = null, bool countdead = false)
	{
		if (!tid) { return CountSpawns(spawntype, countdead); }

		int total = 0;

		ActorIterator it = ActorIterator.Create(tid, "ActorSpawner");
		Actor spot;

		while (spot = it.Next())
		{
			total += ActorSpawner(spot).CountSpawns(spawntype, countdead);
		}

		return total;
	}

	virtual state A_DoSpawns()
	{
		int spawncount = TotalSpawns();
		int totalspawncount = TotalSpawns(countdead:true);

		if (spawncount < user_maxactors && (totalspawncount < user_maxspawns || user_maxspawns == 0)) {
			//Spawn enemies if not visible to player
			if (!InPlayerSightorRange(user_minspawndistance)) {
				Actor spawned = Spawn(user_spawntype, pos);
				if (spawned)
				{
//console.printf("Spawned %s  %i of %i (%i / %i)", GetDefaultByType(user_spawntype).GetClassName(), spawncount, user_maxactors, totalspawncount, user_maxspawns);
					if (user_maxspawns == 0 && spawned.bCountKill && !spawned.bFriendly)
					{
						spawned.ClearCounters();
					}

					if (!spawned.TestMobjLocation())
					{ 
						if (spawned.bCountKill)
						{
							spawned.ClearCounters();
						}
						spawned.Destroy();
					}
					else
					{
						Spawns.Push(spawned);

						spawned.target = target;
						spawned.angle = angle;
						spawned.ChangeTID(user_tid);
						if (user_goal > 0)
						{
							let it = ActorIterator.Create(user_goal, "PatrolPoint");
							Actor goal;
							if (it) { goal = it.Next(); }
							if (goal) { spawned.goal = goal; }
	
							if (Nazi(spawned))
							{
								if (Nazi(spawned).user_sneakable) { Nazi(spawned).BecomeAlerted(); }
								Nazi(spawned).activationgoal = goal;
							}	

							spawned.SetStateLabel("See");
						}
						else if (Base(spawned) && !Base(spawned).loiterdistance)
						{
							Base(spawned).loiterdistance = 196;
						}

						if (user_oncompass)
						{
							BoACompass.Add(spawned);
						}
					}
				}
			}
		}

		if (bDormant) { return ResolveState("Inactive"); } // Cut out if the spawner is now dormant
		return ResolveState("Active");
	}
}

// More aggressive actor spawner, which ignores other actor spawners with the same TID
class AggressiveActorSpawner : ActorSpawner
{
	Default
	{
		//$Category Misc (BoA)
		//$Title Spawner, Actor
		//$Arg0 "Thing ID to spawn"
		//$Arg0Str "Actor class to spawn"
		//$Arg0ToolTip "What actor to spawn.  Numeric values set Thing ID, and string values set spawn class."
		//$Arg1 "Maximum number alive"
		//$Arg1ToolTip "Determines the number of actors to keep alive at once (e.g., '5' will spawn a new actor every time you kill one, keeping 5 alive at all times)."
		//$Arg2 "TID to give actor"
		//$Arg2ToolTip "TID that will be given to the spawned actor(s).  Default is 0 (no TID)."
		//$Arg3 "Minimum player distance"
		//$Arg3ToolTip "Distance that the player must be away from this actor in order for spawns to take place.  A value of '0' defaults to 512."
		//$Arg3Default 512
		//$Arg4 "Maximum number to spawn, total"
		//$Arg4ToolTip "Determines the number of actors to spawn in total, regardless of how many are killed. Zero means unlimited."
		//$Sprite EXCLC0
	}

	override int TotalSpawns(Class<Actor> spawntype, bool countdead)
	{
		return CountSpawns(spawntype, countdead);
	}
}

class Wave // Can't use dynamic arrays with structs
{
	Class<Actor> enemy;
	int count;
	int maxspawns;
	int round;
}

class WaveSpawner : ActorSpawner
{
	Array<Wave> Waves;
	int waveindex;
	int index;
	int maxindex;
	int round;
	bool user_lightburns;

	Property BrightLightKills:user_lightburns;

	Default
	{
		//$Category Misc (BoA)
		//$Title Spawner, Wave
		//$Arg0 "Unused"
		//$Arg1 "Unused"
		//$Arg4 "Unused"
	}

	States
	{
		Active:
			"####" "#" 0 {
				if (ValidRound(round + 1)) { round++; } 
			}
		Active.Spawn:
			"####" "#" 35 A_SetTics(Random[Spawn](1, 21) * 5);
			"####" "#" 0 A_DoSpawns();
		Inactive:
			"####" "#" 35;
			Loop;
	}

	static void AddWaveComponent(int tid, String actorclass, int count = 1, int maxspawns = 0, int round = 0)
	{
		if (tid)
		{
			ActorIterator it = ActorIterator.Create(tid, "WaveSpawner");
			WaveSpawner mo;

			while (mo = WaveSpawner(it.Next()))
			{
				mo.NewWaveComponent(actorclass, count, maxspawns, round);
			}
		}
	}

	void NewWaveComponent(String actorclass, int count = 1, int maxspawns = 0, int round = 0)
	{
		Wave this = new("Wave");

		this.enemy = actorclass;
		this.count = count;
		this.maxspawns = maxspawns;
		this.round = round;

		Waves.Push(this);
	}

	bool ValidRound(int round)
	{
		for (int w = 0; w < Waves.Size(); w++)
		{
			if (Waves[w] && Waves[w].round == round) { return true; }
		}

		return false;
	}

	bool ValidSpawn(int index)
	{
		if (index < 0 || index > Waves.Size() - 1 || !Waves[index] || !Waves[index].enemy) { return false; }
		if (Waves[index].round > round) { return false; }
		if (TotalSpawns(Waves[index].enemy) >= Waves[index].count) { return false; }
		if (
			Waves[index].maxspawns != 0 &&
			TotalSpawns(Waves[index].enemy, true) >= Waves[index].maxspawns
		) { return false; }

		return true;
	}

	override state A_DoSpawns()
	{
		if (user_lightburns) // Chapter 3 Secret Level
		{
			double lightlevel, fogfactor;
			[lightlevel, fogfactor] = ZScriptTools.GetLightLevel(CurSector);
			lightlevel -= fogfactor;

			if (ceilingpic == skyflatnum && lightlevel <= 128) { return ResolveState("Active.Spawn"); } // Don't spawn until it's actually dark
			else if (lightlevel > 160) { return ResolveState("Active.Spawn"); } // But be more forgiving in our definition of 'dark' if you're not under sky
		}

		index = -1;

		While (!ValidSpawn(index))
		{
			index++;

			if (index > Waves.Size() - 1)
			{
				return ResolveState("Active.Spawn");
			}
		}

		if (index == -1) { return ResolveState("Active.Spawn"); }

		user_spawntype = Waves[index].enemy;
		user_maxactors = Waves[index].count;
		user_maxspawns = Waves[index].maxspawns;

		//Spawn enemies if not visible to player
		if (!InPlayerSightorRange(user_minspawndistance)) {
			Actor spawned = Spawn(user_spawntype, pos);
			if (spawned)
			{
				if (user_maxspawns == 0 && spawned.bCountKill && !spawned.bFriendly)
				{
					spawned.ClearCounters();
				}

				if (!spawned.TestMobjLocation())
				{ 
					if (spawned.bCountKill)
					{
						spawned.ClearCounters();
					}
					spawned.Destroy();
				}
				else
				{
//console.printf("%i: Spawned %s  %i of %i  (Wave %i)", index, spawned.GetClassName(), TotalSpawns(user_spawntype) + 1, user_maxactors, round);
					Spawns.Push(spawned);

					spawned.target = target;
					spawned.angle = angle;
					spawned.ChangeTID(user_tid);

					if (Nazi(spawned)) { Nazi(spawned).dodgetimeout = 350; }
					if (Base(spawned))
					{
						Base(spawned).lightthreshold = 190;
						Base(spawned).user_lightburns = true;
					}

					if (user_goal > 0)
					{
						let it = ActorIterator.Create(user_goal, "PatrolPoint");
						Actor goal;
						if (it) { goal = it.Next(); }
						if (goal) { spawned.goal = goal; }

						if (Nazi(spawned) && !(spawned is "ZombieStandard"))
						{
							if (Nazi(spawned).user_sneakable) { Nazi(spawned).BecomeAlerted(); }
							Nazi(spawned).activationgoal = goal;
						}	

						spawned.SetStateLabel("See");
					}
					else if (Base(spawned) && !Base(spawned).loiterdistance)
					{
						Base(spawned).loiterdistance = 196;
					}
				}
			}
		}

		if (bDormant) { return ResolveState("Inactive"); } // Cut out if the spawner is now dormant
		return ResolveState("Active.Spawn");
	}

	override void Tick()
	{
		if (user_lightburns) // Chapter 3 Secret Level
		{
			for (int i = 0; i < Spawns.Size(); i++)
			{
				if (!Spawns[i])
				{
 					Spawns.Delete(i);
					Spawns.ShrinkToFit();
				}
			}
		}

		Super.Tick();
	}
}

// Base barrel actor that allows you to specify an item as args[0] in-editor that will always be dropped when the barrel/object is destroyed.
class BarrelSpawner : ExplosiveBarrel
{
	Class<Actor> user_spawntype; 
	Actor drop;

	Default
	{
		//$Category Misc (BoA)
		//$Title Spawner, Barrel
		//$Arg0 "Thing ID to spawn"
		//$Arg0Str "Actor class to spawn"
		//$Arg0ToolTip "What actor to spawn.  Numeric values set Thing ID, and string values set spawn class.  \nDefaults to nothing spawned, beyond any defined DropItems."
		Health 10; //one kick should be enough to destroy it - ozy81
	}

	override void PostBeginPlay()
	{
		// Setting a special on the actor overrides the use of args[0] to specify the drop item
		if (!special && !user_spawntype)
		{
			user_spawntype = GetSpawnableType(args[0]);
		}

		Super.PostBeginPlay();
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		int damageamt = Super.DamageMobj(inflictor, source, damage, mod, flags, angle);

		if (health <= 0)
		{
			if (user_spawntype && !drop)
			{
				drop = Spawn(user_spawntype, pos);

				if (drop)
				{
					drop.SetOrigin(pos + (0, 0, 10), false);
					drop.angle = angle;
					drop.VelFromAngle(5, inflictor.AngleTo(self));
					drop.vel.z = 1;
					drop.vel += vel;
					drop.bNoGravity = false;
					drop.ClearCounters();
				}
			}
			else
			{
				A_NoBlocking(); // Unset blocking and drop the actor's defined DropItems
			}
		}

		return damageamt;
	}
}

// Generic actor that can be inherited from to give an actor editor-configurable item drop
// Used by Egyptian vases
class DestructionSpawner : Actor
{
	Class<Actor> user_spawntype; 
	Actor drop;

	Default
	{
		//$Category Misc (BoA)
		//$Title Spawner, Destruction
		//$Arg0 "Thing ID to spawn"
		//$Arg0Str "Actor class to spawn"
		//$Arg0ToolTip "What actor to spawn.  Numeric values set Thing ID, and string values set spawn class.  \nDefaults to nothing spawned, beyond any defined DropItems."
	}

	override void PostBeginPlay()
	{
		// Setting a special on the actor overrides the use of args[0] to specify the drop item
		if (!special && !user_spawntype)
		{
			user_spawntype = GetSpawnableType(args[0]);
		}

		Super.PostBeginPlay();
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		int damageamt = Super.DamageMobj(inflictor, source, damage, mod, flags, angle);

		if (health <= 0)
		{
			if (user_spawntype && !drop)
			{
				drop = Spawn(user_spawntype, pos);

				if (drop)
				{
					drop.SetOrigin(pos + (0, 0, 10), false);
					drop.angle = angle;
					drop.VelFromAngle(5, inflictor.AngleTo(self));
					drop.vel.z = 1;
					drop.vel += vel;
					drop.bNoGravity = false;
					drop.ClearCounters();
				}
			}
			else
			{
				A_NoBlocking(); // Unset blocking and drop the actor's defined DropItems
			}
		}

		return damageamt;
	}
}

// This is only here for backwards compatibility.  
// See CivilianZombie in scripts/actors/enemies/zombies.txt
class CivilianZombieSpawner : CivilianZombie
{
	Default
	{
		//$Category Monsters (BoA)/Occult
		//$Title Civilian Zombie Spawner (random skin)
		//$Color 4
	}
}

class BatSwarmSpawner : Base
{
	int count;
	Class<Actor> spawnclass;

	Default
	{
		//$Category Misc (BoA)
		//$Title Spawner, Bat Swarm
		//$Arg0 "Use String Argument!"
		//$Arg0Str "Actor class to spawn"
		//$Arg0ToolTip "What actor to spawn.  Defaults to BatFamiliar."
		//$Arg1 "Number to spawn"
		//$Arg1ToolTip "Total number of bats to spawn.  Default is 10."
		//$Sprite BFAMK0

		+NOGRAVITY
	}

	States
	{
		Spawn:
			TNT1 A 5 A_LookThroughDisguise();
			Loop;
		See:
			TNT1 A 5 {
				Actor b = Spawn(spawnclass, pos);

				if (b)
				{
					b.target = target;
					b.vel.xy = RotateVector((FRandom(-1.0, 1.0), 0), Random(1, 360));
					b.vel.z = FRandom(-1.0, 1.0);
					count--;
				}

				if (count <= 0) { Destroy(); }
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (args[0] < 0) { spawnclass =  GetSpawnableType(args[0]); }
		else { spawnclass = "BatFamiliar"; }

		count = args[1] ? args[1] : 10;
	}
}