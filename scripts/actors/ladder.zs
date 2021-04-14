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

/*
  Base ladder class that allows any actor touching it to climb up and down
  until the climbing actor leaves the ladder actor's radius or z-height.

  The actor is placed at the *top* of the climbable area.

  The base actor here is "stackable" in that you can place one above the 
  other and make a longer ladder.  This allows for 3D model ladders that
  you can place in the map that will "just work" with no extra settings
  (This is what the actor was originally designed for).


  Alternatively, the ClimbableZone actor defined below is intended for use
  with texture-based ladders (walls or 3D midtex).  With this ladder variant,
  you can set the Y scale of the actor as appropriate to define the height
  of the climbable zone that you want to set up.  

  The ClimbableZone actor is invisible in game, but shows up in-editor as 
  a transparent orange box, which represents the boundaries of the zone; 
  this allows you to easily see the zone boundary in 3D view,


  PlayerFollowers can use ladders by default; other +ISMONSTER actors cannot.

  The ladder plays sounds while an actor is climbing it.  Which sound set is
  used is controlled by the user_soundtype variable.

	0 - (Default) Ladder climbing sounds
	1 - Rope climbing sounds
	2 - Rock step sounds
	3 - Quiet metal step sounds
	4 - Wood step sounds
	5 - Keen sounds

  RopeSpawner spawns a climbable/walkable rope from the actor along whatever
  pitch you give the actor (so, 90 for a rope that hangs straight down). 
  These actors can use the same user_soundtype property as above, and the
  user_maxlength property to specify a maximum length of the rope (default 
  maximum is 1024 units).

  CableSpawner is the same, but uses a smaller diameter grey model, so it
  looks like a cable instead.
*/

class LadderBase : Actor
{
	Array<Actor> Climbers;
	double ladderheight;
	double climbradius;
	double friction;
	bool passive;
	bool nomonsters;
	int soundtimeout, soundtimeout2;
	int user_soundtype;
	int activetimeout;
	int user_groundoffset;

	Property LadderHeight:ladderheight; // Height of climbable area
	Property DisallowMonsters:nomonsters; // Can monsters climb the ladder?
	Property ClimbRadius:climbradius; // Detection radius for the ladder.  Defaults to same as actor radius
	Property Friction:friction;
	Property GroundHeightOffset:user_groundoffset;

	Default
	{
		+DONTTHRUST
		+NODAMAGE
		+NOGRAVITY
		-SOLID
		Height 8;
		Radius 24;
		LadderBase.LadderHeight 132; // Uses custom property vice actual actor height so that the ladder model can be submerged in the ground to make shorter ladders 
		LadderBase.DisallowMonsters True; // Sets variable determining if monsters should be disallowed from using the ladder
		LadderBase.Friction 0.95; // Only slow down a little when climbing ladders, by default
		LadderBase.GroundHeightOffset -1; // Default to -1 to allow setting to zero via UDMF property
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		if (!climbradius) { climbradius = Radius; }
		if (user_groundoffset < 0) { user_groundoffset = 0; }
		if (ladderheight <= 0) { ladderheight = pos.z - floorz - user_groundoffset; }

		Climbers.Clear();

		DoStackCheck();

		Super.PostBeginPlay();
	}

	void DoStackCheck()
	{
		BlockThingsIterator it = BlockThingsIterator.Create(self, 1);

		while (it.Next())
		{
			if (it.thing == self) { continue; } // Ignore itself

			if (it.thing is "LadderBase")
			{ // If there are other ladders immediately above or below, handle setting up transfer logic so that players don't get dropped mid-ladder if there are multiple stacked ladders
				if (it.thing is "RopeSegment")
				{
					if (Distance2d(it.thing) > 8) { continue; }

					if (it.thing.pos.z >= pos.z && it.thing.curSector == curSector) { passive = true; }
 					else if (it.thing.pos.z < pos.z) // This ladder is the top, so make its height check logic handle the entire stack
					{
						double heightcheck = pos.z - it.thing.pos.z + LadderBase(it.thing).ladderheight;
						ladderheight = heightcheck > ladderheight ? heightcheck : ladderheight;
					}
				}
				else
				{
					if (Distance2d(it.thing) > 0) { continue; } // Only check ladders that are directly above/below this one

					if (it.thing.pos.z >= pos.z && pos.z - ladderheight <= it.thing.pos.z && it.thing.curSector == curSector) { passive = true; } // This ladder is not the top, so make it decorative only
					else if (it.thing.pos.z < pos.z && pos.z - ladderheight > it.thing.pos.z) // This ladder is the top, so make its height check logic handle the entire stack
					{
						double heightcheck = pos.z - it.thing.pos.z + LadderBase(it.thing).ladderheight;
						ladderheight = heightcheck > ladderheight ? heightcheck : ladderheight;
					}
				}
			}
		}
	}

	override void Tick()
	{
		Super.Tick();

		if (passive) { return; }

		if (self is "RopeSegment" && abs(pitch) != 90 && !activetimeout && CheckRange(48.0, true)) { return; } // Short circuit the function if there are no players within reasonable range (cuts down on processing time, especially for horizontal ropes)

		BlockThingsIterator it = BlockThingsIterator.Create(self, climbradius + 16);

		while (it.Next())
		{
			if ((nomonsters || !it.thing.bIsMonster || it.thing.health <= 0 || it.thing.Default.bNoGravity) && !(it.thing is "PlayerPawn") && !(it.thing is "PlayerFollower")) { continue; } // Ignore everything except players and monsters

			activetimeout = 350; // Set a timer so that the actor will stay active for 10 seconds after a player uses it to give playerfollowers a chance to use it...

			if (
				(Distance2D(it.thing) > (climbradius + it.thing.radius) * 1.34 || !CheckSight(it.thing)) || // Check if the actor can reach the ladder (horizontal radius check), with some fudging to account for square collision boxes
				(it.thing.pos.z + it.thing.height < pos.z - ladderheight) || // Z-height check (player below ladder)
				(it.thing.pos.z > pos.z + (bSolid ? height : -height)) // Z-height check (player above ladder) - if non-solid, the player will "step down" onto the ladder, so it's easier to get onto ladders that are in a hole in the ground
			)
			{
				ResetActor(it.thing);
				continue;
			}

			if (target && target is "RopeSpawner")
			{
				soundtimeout = RopeSpawner(target).soundtimeout;
				soundtimeout2 = RopeSpawner(target).soundtimeout2;
			}

			if (self is "RopeSegment" && (pitch < 70 || pitch > 290)) // Handle horizontal rope segments separately so they don't get the nogravity effect
			{
				if (soundtimeout <= 0 && abs(it.thing.vel.length()) >= 1.0)
				{
					if (user_soundtype == 1)
					{
						it.thing.A_StartSound("world/ropecreak", CHAN_BODY, 0, 0.05); // Play quiet walking-on-rope creaking sounds

						soundtimeout = 15;
					} 
				}
			}
			else if (!it.thing.bFly && !it.thing.bFloat) // Only affect things that aren't already flying
			{
				if (Climbers.Find(it.thing) == Climbers.Size()) { Climbers.Push(it.thing); } // Add the actor to the list of climbers if it's not already there

				if (it.thing.bIsMonster && !(it.thing is "PlayerFollower")) { it.thing.bFloat = True; } // If it's a monster set +FLOAT
				else
				{
					if (it.thing is "BoAPlayer") { BoAPlayer(it.thing).climbing = self; } // Store pointer to the ladder object in player variable
					else if (it.thing is "PlayerFollower")  // Just a boolean flag for PlayerFollowers, but also toggle FLOAT
					{
						PlayerFollower(it.thing).climbing = true;
						it.thing.bFloat = true;
					}
					else { it.thing.bFly = True; } // If it's some other class of player, use the fly cheat/powerup
				}
				it.thing.bNoGravity = True;
			}

			if (Climbers.Find(it.thing) < Climbers.Size()) // If the actor is in the climbers list, apply speed/velocity changes
			{
				it.thing.vel *= friction;
			}

			double vel = abs(it.thing.vel.length());

			if (soundtimeout <= 0 && vel >= 1.0 && it.thing.pos.z != floorz)
			{
				double vol = min(vel - 1.0, 1.0);

				if (user_soundtype == 1) { it.thing.A_StartSound("world/rope", CHAN_BODY, 0, 0.05); } // Very quiet climbing sounds that combine with the rope creaking
				else if (user_soundtype == 2) { it.thing.A_StartSound("floor/rock", CHAN_BODY, 0, vol * 0.3); }
				else if (user_soundtype == 3) { it.thing.A_StartSound("floor/metal", CHAN_BODY, 0, vol * 0.1); }
				else if (user_soundtype == 4) { it.thing.A_StartSound("floor/wood", CHAN_BODY, 0, vol * 0.5); }
				else if (user_soundtype == 5) { it.thing.A_StartSound("ckeen/climb", CHAN_BODY, 0, vol * 0.5, pitch:FRandom(0.9, 1.1)); }
				else { it.thing.A_StartSound("world/ladder", CHAN_BODY, 0, vol * 0.4); }

				soundtimeout = 15;
			}

			if (soundtimeout2 <= 0 && abs(it.thing.vel.length()) >= 1.0)
			{
				if (user_soundtype == 1) // Rope creaking
				{
					let spawner = RopeSpawner(target);

					if (spawner && spawner.first && spawner.last)
					{
						if (spawner.pitch == -90 || abs(spawner.pitch != 90)) { spawner.last.A_StartSound("world/ropecreak", CHAN_BODY, 0, 0.15); } // Play creaking sound from the mount point
						else if (spawner.pitch == 90 || abs(spawner.pitch != 90)) { spawner.first.A_StartSound("world/ropecreak", CHAN_BODY, 0, 0.15); } // Or both ends, depending how the rope is spawned
					}
				} 

				soundtimeout2 = Random(35, 70);
			}
		}

		// Explicitly check current climbers to make sure they are still in range of the ladder in case they moved away too quickly for the above check to catch
		for (int c = 0; c < Climbers.Size(); c++)
		{
			let mo = Climbers[c];

			if (mo)
			{
				if (Distance2D(mo) > (climbradius + mo.radius) * 1.34) { ResetActor(mo); }
			}
		}

		soundtimeout--;
		soundtimeout2--;
		activetimeout = max(activetimeout - 1, 0);
	}

	// Restores the default values of the various flags if the actor was on this ladder
	void ResetActor(Actor mo)
	{
		if (Climbers.Find(mo) != Climbers.Size()) //If the actor was on the list of climbers for this ladder...
		{
			mo.Speed = mo.Default.Speed; // Reset the default values...
			mo.bNoGravity = mo.Default.bNoGravity;
			mo.bFly = mo.Default.bFly;
			mo.bFloat = mo.Default.bFloat;

			if (mo is "BoAPlayer") { BoAPlayer(mo).climbing = null; }
			else if (mo is "PlayerFollower") { PlayerFollower(mo).climbing = false; }

			Climbers.Delete(Climbers.Find(mo)); // ...and delete if from the climbers list.  
			Climbers.ShrinkToFit(); // Re-shrink the array
		}
	}

	override bool Used(Actor user)
	{
		if (user.player && user.pos.z <= pos.z + 16 && user.pos.z >= pos.z - ladderheight - user.height)
		{
			user.vel.z += user.speed / 2 * friction;
			user.player.usedown = false;

			return true;
		}
		else { return false; }
	}
}

class ClimbableZone : LadderBase
{
	Default
	{
		//$Category Misc (BoA)
		//$Title Climbable Zone
		Alpha 0.5;
		RenderStyle "Stencil";
		StencilColor "Orange";
	}

	override void PostBeginPlay()
	{
		bInvisible = True;

		ladderheight *= scale.y;

		Super.PostBeginPlay();
	}
}

class ClimbableZone2 : ClimbableZone //half radius for narrow zones to let BJ open doors near ladders
{
	Default
	{
		//$Category Misc (BoA)
		//$Title Climbable Zone (Narrow)
		Radius 12;
	}
}

class RopeSegment : LadderBase
{
	Vector3 SpawnPos;
	RopeSegment next, prev;
	double position, shotpitch, shotdist, offset, sag, period;
	int time;

	Property Sag:sag;

	Default
	{
		+NOGRAVITY
		+SOLID
		Radius 2;
		Height 2;
		LadderBase.LadderHeight 2;
		LadderBase.DisallowMonsters False;
		LadderBase.ClimbRadius 12;
		LadderBase.Friction 0.85; // Slower than a ladder
		RopeSegment.Sag 1.0;
	}

	States
	{
		Spawn:
			ROPE A 1;
			Loop;
		Knot:
			ROPE B 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		SpawnPos = pos;

		if (target && target is "RopeSpawner")
		{
			user_soundtype = RopeSpawner(target).user_soundtype;
			if (RopeSpawner(target).user_sag > 0) { sag = RopeSpawner(target).user_sag; }

			shotdist = RopeSpawner(target).HitDistance;

			if (!shotdist) // Shouldn't ever happen, but just in case...
			{
				if (developer) { console.printf("\cgERROR: \cjRope failed to draw at \cf%i, %i, %i\cj.", pos.x, pos.y, pos.z); }
				Destroy();

				return;
			} 

			shotpitch = pitch;
			position = Distance3D(target) / shotdist;

			RopeSpawner(target).Segments.Push(self);

			scale.x *= target.scale.x;
			scale.y *= target.scale.y;

			A_SetSize(Radius * scale.x, Height * scale.y);

			Reposition();
		}

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		if (shotdist) { Super.Tick(); }
	}

	void Reposition()
	{
		// This breaks down at steeper angles because gaps start to appear between segments...  Max sag is probably about 4 for every 128 units of rope length

		offset = (shotdist * 0.018 * sag) * -sin(position * 180) * cos(-shotpitch);
		SetOrigin((SpawnPos.x, SpawnPos.y, SpawnPos.z + offset), false);

		// Some guesstimating here...  I need to check my math.  But it's close enough.
		pitch = shotpitch + (shotdist * tan(sag / (shotdist / 192))) * cos(position * 180) * cos(-shotpitch); 
	}
}

class RopeSpawner : Actor
{
	double HitDistance;
	int soundtimeout, soundtimeout2;
	int user_soundtype;
	double user_maxlength;
	double user_sag;
	bool user_hideknots;
	Class<RopeSegment> seg;
	Array<RopeSegment> Segments;
	bool initialized, knots;
	int timeout, interval;
	double zoffset;
	double spacing;
	RopeSegment first, last;

	Property SegmentActor:seg;
	Property SoundSet:user_soundtype;
	Property ZOffset:zoffset;
	Property Spacing:spacing;
	Property SoundInterval:interval;
	Property EndKnots:knots;

	Default
	{
		//$Category Misc (BoA)
		Height 0;
		Radius 4;
		Scale 1.5;
		RopeSpawner.SegmentActor "RopeSegment";
		RopeSpawner.SoundSet 1;
		RopeSpawner.Spacing 3.0;
		RopeSpawner.SoundInterval 15;
		RopeSpawner.EndKnots True;
	}

	States
	{
		Spawn:
			UNKN A 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		if (!user_maxlength)
		{
			if (pitch == 90) { user_maxlength = pos.z - (floorz + 40); } // If it's straight down, go down to just short of the floor
			else if (pitch == -90 || pitch == 270) { user_maxlength = ceilingz - pos.z; if (pos.z == floorz) { SetOrigin((pos.xy, floorz + Radius), false); } } // If it's straight up, fill up to the ceiling
			else { user_maxlength = 1024; } // Otherwise, max out at 1024 units
		}
		if (!user_sag) { user_sag = -1.0; } // Defaults to whatever is set in the segment, but can be overriden by anything over 0;

		bInvisible = true;

		if (tid)
		{
			target = FindTarget();
			if (target) { A_Face(target, 0, 0, flags:FAF_TOP); }
		}

		FLineTraceData trace;
		LineTrace(angle, user_maxlength, pitch, TRF_THRUACTORS, 0.0, 0.0, 0.0, trace);
		HitDistance = trace.Distance;

		for (double s = 0; s < HitDistance; s += spacing * scale.x)
		{
			Vector3 stepmove = (cos(angle) * cos(-pitch), sin(angle) * cos(-pitch), sin(-pitch)).Unit(); // Calculate facing direction as a unit vector

			Actor segment = Spawn(seg, pos + stepmove * s + (0, 0, zoffset * scale.y - 4), ALLOW_REPLACE);
			if (segment)
			{
				segment.pitch = pitch;
				segment.angle = angle;
				segment.target = self;
			}
		}

		timeout = level.time + 35;

		Segments.Clear();

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		if (!initialized && level.time > timeout)
		{
			if (Segments.Size())
			{
				first = Segments[0];
				last = Segments[Segments.Size() - 1];

				if (knots && !user_hideknots)
				{
					if (pitch == 90 || abs(pitch != 90))
					{ 
						first.SetStateLabel("Knot");
					}

					if (pitch == -90 || abs(pitch != 90))
					{
						last.SetStateLabel("Knot");
						last.angle += 180;
						last.pitch = -last.pitch;
					}
				}

				first.roll = 0;
				last.roll = 0;

				initialized = true;	
			}
		}

		soundtimeout = soundtimeout <= 0 ? interval : soundtimeout - 1;
		soundtimeout2 = soundtimeout2 <= 0 ? interval + Random(15, 50) : soundtimeout2 - 1; // Randomize creaking interval some
	}

	Actor FindTarget()
	{
		ThinkerIterator it = ThinkerIterator.Create("RopeSpawnerTarget", Thinker.STAT_DEFAULT - 7);
		Actor mo;

		while (mo = Actor(it.Next()))
		{
			if (mo.tid == tid)
			{
				return mo;
			}
		}

		return null;
	}
}

class VerticalRopeSpawner : RopeSpawner
{
	override void PostBeginPlay()
	{
		pitch = 90;

		Super.PostBeginPlay();
	}
}

class RopeSpawnerTarget : MapSpot
{
	Default
	{
		//$Category Misc (BoA)
		Height 0;
		Radius 4;
		Scale 1.5;
	}

	override void BeginPlay()
	{
		ChangeStatNum(Thinker.STAT_DEFAULT - 7);
	}

	override void PostBeginPlay()
	{
		bInvisible = true;

		Super.PostBeginPlay();
	}

	States
	{
		Spawn:
			UNKN A 1;
			Loop;
	}	
}

class CableSegment : RopeSegment
{
	Default
	{
		RopeSegment.Sag 0.0;
	}
}

class CableSpawner : RopeSpawner
{
	Default
	{
		RopeSpawner.SegmentActor "CableSegment";
		RopeSpawner.SoundSet 3;
	}
}

class BridgeSegment : RopeSegment
{
	Default
	{
		+ROLLSPRITE
		+FLATSPRITE
		Radius 32;
		Scale 0.75;
		LadderBase.Friction 1.0;
		LadderBase.ClimbRadius 32;
	}

	States
	{
		Spawn:
			BBRD A 1;
		Knot:
			BBRD # 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		Roll = Random(-5, 5);

		frame = Random(0, 7);
		Scale.X *= RandomPick(-1, 1);

		Super.PostBeginPlay();
	}
}

class BridgeSpawner : RopeSpawner
{
	Default
	{
		RopeSpawner.SegmentActor "BridgeSegment";
		RopeSpawner.SoundSet 4;
		RopeSpawner.Spacing 32.0;
		RopeSpawner.ZOffset 2;
		RopeSpawner.EndKnots False;
	}
}