/*
 * Copyright (c) 2015-2020 @wildweasel486
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

class BulletTracer : FastProjectile
{
	Class<TracerTrail> trail;
	Actor trailactor;
	int offset;
	int zoffset;
	int flags;
	EffectsManager manager;

	flagdef NoRicochet: flags, 0;
	flagdef NoInertia: flags, 1;
	flagdef PortalAware: flags, 2;

	Property Trail:trail;

	Default
	{
		+BLOODSPLATTER
		+NOEXTREMEDEATH
		+WINDTHRUST
		+THRUGHOST
		+HITTRACER
		-NOGRAVITY
		Gravity 15.0;
		Radius 2;
		Height 2;
		Speed 75;
		FastSpeed 85;
		Decal "BulletChip";
		BulletTracer.Trail "TracerTrail";
		DamageType "Bullet";
	}

	States
	{
		Spawn:
			TNT1 A 1 BRIGHT;
			Loop;
		Death:
		Crash:
			TNT1 AAA 0 {
				if (trailactor) { trailactor.Destroy(); }
				A_SpawnItemEx("TracerSpark", 0, 0, 0, random(-2,2), random(-2,2), random(-2,2), random(0,359)); //T667 improvements
				bWindThrust = false;
			}
			PUFF B 3 BRIGHT LIGHT("BPUFF1") {
				// If a non-bleeding actor was hit, count the shot as successful
				if (BoAPlayer(target) && BoAPlayer(target).tracker && tracer && tracer.bIsMonster && tracer.bNoBlood) { BoAPlayer(target).tracker.shots[target.PlayerNumber()][0]++; }
				if (!bNoRicochet)
				{
					A_StartSound("ricochet");
				}
				A_SpawnItemEx("ZBulletChip");
			}
			PUFF CD 3 BRIGHT LIGHT("BPUFF1");
			Stop;
		XDeath:
			TNT1 A 1 {
				// If a bleeding actor was hit, count the shot as successful
				if (BoAPlayer(target) && BoAPlayer(target).tracker) { BoAPlayer(target).tracker.shots[target.PlayerNumber()][0]++; }
				bWindThrust = false;
				A_StartSound("hitflesh");
			}
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!bNoInertia && target)
		{
			vel += target.vel;
		}

		// Spawn the visible tracer *once* at spawn
		trailactor = Spawn(trail, pos);
		if (trailactor)
		{
			trailactor.vel = vel;
			trailactor.A_FaceMovementDirection(0, 0.0, 0.0, FMDF_INTERPOLATE);
			trailactor.master = self;
		}

		offset = Random(0, 70);
		Actor shooter = target;

		while (shooter is "KTFlare" || shooter is "TurretGun") {
			shooter = shooter.master;
		}
		if (shooter is "TurretStand") {
			shooter = TurretStand(shooter).shooter;
		}

		if (!bNoGravity && shooter && !shooter.player && shooter.target)
		{
			Vector3 posDiff = Level.Vec3Diff(Pos, shooter.target.Pos);
			double time = posDiff.Length() / Speed;
			double grav = GetGravity() / Speed;
			double crouchfactor = 1;
			double heightfac = .75;
			if (shooter.target.player)
			{
				crouchfactor = shooter.target.player.crouchfactor;
			}
			else
			{
				heightfac = .5; // My attempt to fix PlayerFollower inaccuracy
			}
			double height = posDiff.Z + shooter.target.height * heightfac * crouchfactor;
			Vel.Z = ZScriptTools.ArcZVel(time, grav, height);
		}

		FLineTraceData trace;
		if (shooter && shooter.LineTrace(shooter.angle, 2048, shooter.pitch, 0, int(pos.z - shooter.pos.z), 0, 0, trace))
		{
			bPortalAware = !!trace.NumPortals;
		}

		// Count the shot for stats if it was fired by a player
		if (BoAPlayer(target) && BoAPlayer(target).tracker) { BoAPlayer(target).tracker.shots[target.PlayerNumber()][1]++; }
	}

	// Handling so that tracers won't hit actors that have the tracer's origin actor set as their master (or inherit from one that does)
	override bool CanCollideWith(Actor other, bool passive)
	{
		if (target && other)
		{
			Actor roottarget = target;
			Actor rootmaster = other;
			while (roottarget.master) { roottarget = roottarget.master; }
			while (rootmaster.master) { rootmaster = rootmaster.master; }

			if (roottarget && roottarget == rootmaster) { return false; }
		}

		return true;
	}

	override void Tick()
	{
		if ((level.time + offset) % 30 == 0)
		{
			if ((target && target.player) || (manager && manager.InRange(pos, 0))) { DoWhizChecks(); }
		}

		ClearInterpolation();
		double oldz = pos.Z;

		if (isFrozen())
			return;

		// [RH] Ripping is a little different than it was in Hexen
		FCheckPosition tm;
		tm.DoRipping = bRipper;

		int count = 8;
		if (radius > 0)
		{
			while (abs(Vel.X) >= radius * count || abs(Vel.Y) >= radius * count)
			{
				// we need to take smaller steps.
				count += count;
			}
		}

		if (height > 0)
		{
			while (abs(Vel.Z) >= height * count)
			{
				count += count;
			}
		}

		// Handle movement
		bool ismoved = Vel != (0, 0, 0)
			// Check Z position set during previous tick.
			// It should be strictly equal to the argument of SetZ() function.
			|| (   (pos.Z != floorz		   ) /* Did it hit the floor?   */
				&& (pos.Z != ceilingz - Height) /* Did it hit the ceiling? */ );

		if (ismoved)
		{
			// force some lateral movement so that collision detection works as intended.
			if (bMissile && Vel.X == 0 && Vel.Y == 0 && !IsZeroDamage())
			{
				VelFromAngle(MinVel);
			}

			Vector3 frac = Vel / count;
			int changexy = frac.X != 0 || frac.Y != 0;
			int ripcount = count / 8;
			for (int i = 0; i < count; i++)
			{
				if (changexy)
				{
					if (--ripcount <= 0)
					{
						tm.ClearLastRipped();	// [RH] Do rip damage each step, like Hexen
					}
					
					if (!TryMove (Pos.XY + frac.XY, true, NULL, tm))
					{ // Blocked move
						if (!bSkyExplode)
						{
							let l = tm.ceilingline;
							if (l &&
								l.backsector &&
								l.backsector.GetTexture(sector.ceiling) == skyflatnum)
							{
								let posr = PosRelative(l.backsector);
								if (pos.Z >= l.backsector.ceilingplane.ZatPoint(posr.XY))
								{
									// Hack to prevent missiles exploding against the sky.
									// Does not handle sky floors.
									Destroy ();
									return;
								}
							}
							// [RH] Don't explode on horizon lines.
							if (BlockingLine != NULL && BlockingLine.special == Line_Horizon)
							{
								Destroy ();
								return;
							}
						}

						ExplodeMissile (BlockingLine, BlockingMobj);
						return;
					}
				}
				AddZ(frac.Z);
				UpdateWaterLevel ();
				oldz = pos.Z;
				if (oldz <= floorz)
				{ // Hit the floor

					if (floorpic == skyflatnum && !bSkyExplode)
					{
						// [RH] Just remove the missile without exploding it
						//		if this is a sky floor.
						Destroy ();
						return;
					}

					SetZ(floorz);
					HitFloor ();
					Destructible.ProjectileHitPlane(self, SECPART_Floor);
					ExplodeMissile (NULL, NULL);
					return;
				}
				if (pos.Z + height > ceilingz)
				{ // Hit the ceiling

					if (ceilingpic == skyflatnum && !bSkyExplode)
					{
						Destroy ();
						return;
					}

					SetZ(ceilingz - Height);
					Destructible.ProjectileHitPlane(self, SECPART_Ceiling);
					ExplodeMissile (NULL, NULL);
					return;
				}
				if (bPortalAware) { CheckPortalTransition(); }
				if (changexy && ripcount <= 0) 
				{
					ripcount = count >> 3;

					// call the 'Effect' method.
					Effect();
				}
			}
		}
		if (!CheckNoDelay())
			return;		// freed itself
		// Advance the state
		if (tics != -1)
		{
			if (tics > 0) tics--;
			while (!tics)
			{
				if (!SetState (CurState.NextState))
				{ // mobj was removed
					return;
				}
			}
		}

		if (!bNoGravity && pos.z > floorz)
		{
			vel.z -= GetGravity() / Speed;
			if (trailactor)
			{
				trailactor.vel = vel;
				trailactor.pitch = -VectorAngle(Speed, Vel.Z);
			}
		}
	}

	void DoWhizChecks(int radius = 96)
	{
		BlockThingsIterator it = BlockThingsIterator.Create(self, radius);

		while (it.Next())
		{
			if (it.thing == target) { continue; } // Ignore the originator

			if (it.thing.health > 0 && it.thing.bShootable && (Nazi(it.thing) || PlayerPawn(it.thing) || PlayerFollower(it.thing)) && it.thing.IsVisible(self, true)) // Only affect living Nazis, players, and player followers
			{
				if (it.thing.lastHeard != self)
				{
					it.thing.lastHeard = self;

					if (target && (target.IsHostile(it.thing) || (Nazi(it.thing) && Nazi(it.thing).user_sneakable)) && target.species != it.thing.species) // Only 'whizz' at hostiles
					{
						Actor mo = Spawn("Whizzer", pos);
						if (mo) { mo.master = it.thing; }

						it.thing.SoundAlert(target, false, 64); // Emit alert sound

						return; // Only whiz once per check to cut down on performance impact
					}
				}
			}
		}
	}
}

class ZFlatDecal : ParticleBase
{
	const epsilon = 4;

	bool onCeiling;
	bool randomFlipX,
		 randomFlipY;

	Property RandomFlip : randomFlipX, randomFlipY;

	Default
	{
		Height 0;
		Radius 0;

		RenderStyle "Shaded";

		+FLATSPRITE
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		// Random flip
		scale.x *= randomFlipX ? RandomPick(1, -1) : 1;
		scale.y *= randomFlipY ? RandomPick(1, -1) : 1;

		// Stick to floor/ceiling
		SecPlane plane;
		if (Abs(pos.z - GetZAt()) <= epsilon)
		{
			SetZ(GetZAt());
			plane = curSector.floorPlane;
			onCeiling = false;
		}
		else if (Abs(pos.z - GetZAt(flags:GZF_Ceiling)) <= epsilon)
		{
			SetZ(GetZAt(flags:GZF_Ceiling));
			plane = curSector.ceilingPlane;
			onCeiling = true;
		}
		else
		{
			Destroy();
			return;
		}

		// Tilt to match slopes
		let normal = plane.normal;
		angle = VectorAngle(normal.x, normal.y);

		normal.xy = RotateVector(normal.xy, -angle);
		pitch = -VectorAngle(normal.x, normal.z) + 90;
	}

	override void Tick()
	{
		Super.Tick();

		// MoveWithSector isn't good enough to stick to a rising ceiling
		if (onCeiling)
			SetZ(GetZAt(flags:GZF_Ceiling));
	}
}

class ZBulletChip : ZFlatDecal
{
	Default
	{
		Scale 0.5;
		Alpha 0.85;
		StencilColor "Black";
		ZFlatDecal.RandomFlip true, true;
	}

	States
	{
	Spawn:
		TNT1 A 0 NODELAY
		{
			return curState + Random(1, 5);
		}
		CHIP ABCDE -1;
		Stop;
	}
}

class ZScorch : ZBulletChip
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY
		{
			return curState + 1;
		}
		ZSCO A -1;
		Stop;
	}
}

class ZScorchLower : ZBulletChip
{
	Default
	{
		Scale 0.5;
	}
	
	States
	{
	Spawn:
		TNT1 A 0 NODELAY
		{
			return curState + Random (1,2);
		}
		ZSCO BC -1;
		Stop;
	}
}

class ZCrater : ZBulletChip
{
	Default
	{
		Scale 0.25;
	}

	States
	{
		Spawn:
			ZSCO # -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (!TestPoints(self)) { Destroy(); }

		frame = Random(5, 9);

		Super.PostBeginPlay();
	}

	bool TestPoints(Actor mo)
	{
		Vector3 normals[4];
		double offset = 8.0;

		PointTracer pointtracer;
		pointtracer = new("PointTracer");

		Vector3 tracedir = (0, 0, -1);
		double zoffset = mo.pos.z;
		double dist = 128.0;
		Vector3 tracepos;
		
		tracepos = (mo.pos.xy + RotateVector((offset, -offset), mo.angle), zoffset);
		pointtracer.Trace(tracepos, level.PointInSector(tracepos.xy), tracedir, dist, 0);
		normals[0] = pointtracer.Results.HitSector.floorplane.normal;

		tracepos = (mo.pos.xy + RotateVector((offset, offset), mo.angle), zoffset); 
		pointtracer.Trace(tracepos, level.PointInSector(tracepos.xy), tracedir, dist, 0);
		normals[1] = pointtracer.Results.HitSector.floorplane.normal;

		if (normals[1] != normals[0]) { return false; }

		tracepos = (mo.pos.xy + RotateVector((-offset, -offset), mo.angle), zoffset);
		pointtracer.Trace(tracepos, level.PointInSector(tracepos.xy), tracedir, dist, 0);
		normals[2] = pointtracer.Results.HitSector.floorplane.normal;

		if (normals[2] != normals[1]) { return false; }

		tracepos = (mo.pos.xy + RotateVector((-offset, offset), mo.angle), zoffset);
		pointtracer.Trace(tracepos, level.PointInSector(tracepos.xy), tracedir, dist, 0);
		normals[3] = pointtracer.Results.HitSector.floorplane.normal;

		if (normals[3] != normals[2]) { return false; }

		return true;
	}
}

class PointTracer : LineTracer
{
	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitActor)
		{
			return TRACE_Skip;
		}

		return TRACE_Stop;
	}
}

class ZPlasma : ZBulletChip
{
	Default
	{
		Scale 1.5;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY
		{
			return curState + Random (1,2);
		}
		ZSCO DE -1;
		Stop;
	}
}

class Whizzer : GrenadeBase
{
	Default
	{
		+NOGRAVITY
		+NOINTERACTION
		GrenadeBase.FearDistance 32;
	}

	States
	{
		Spawn:
			TNT1 A 15;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (master && PlayerPawn(master)) { A_StartSound("whiz"); } // Only play whiz sound if near a player that's not the originator
	}
}

class TracerTrail : SimpleActor
{
	double faderate, stepalpha, startalpha;

	Property FadeRate:faderate;
	Property StartAlpha:startalpha;

	Default
	{
		+BRIGHT
		+CANNOTPUSH
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+MISSILE //mxd
		+NOBLOCKMAP
		+NOINTERACTION
		+NODAMAGETHRUST
		+NOGRAVITY
		+NOTELEPORT
		+WINDTHRUST
		Alpha 0.0;
		Scale 0.4;
		RenderStyle "Add";
		TracerTrail.FadeRate 0.01;
		TracerTrail.StartAlpha 0.75;
	}
	States
	{
		Spawn:
			PUFF A 1 DoFade();
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		if (bNoInteraction && TestMobjLocation()) { bNoInteraction = false; }

		if (!master || !vel.xy.length()) { Destroy(); }
	}

	void DoFade()
	{
		if (stepalpha < startalpha)
		{ // Quickly fade in from nothing at the very beginning...  This hides situations where the tracer would spawn and flash right in front of the player for a tick.
			alpha += 0.25;
			if (alpha > startalpha) { alpha = startalpha; }

			stepalpha = alpha;
		}
		else if (faderate) { A_FadeOut(faderate); } // Fade out to nothing at the specified rate
	}
}

class TracerSpark : Actor
{
	Default
	{
		+DONTSPLASH
		+FLOORCLIP
		+FORCEXYBILLBOARD
		+MISSILE
		+NOTELEPORT
		+WINDTHRUST
		Health 4;
		Radius 3;
		Height 6;
		Gravity .1;
		Speed .1;
		RenderStyle "Add";
		Scale .3;
		Mass 0;
		BounceType "Doom";
	}

	States
	{
		Spawn:
			PUFF A 1;
			"####" AEFGHI 2 BRIGHT A_SetTranslucent(.8,1);
			"####" J 1 BRIGHT A_SetTranslucent(.8,1);
			"####" K 1 BRIGHT A_SetTranslucent(.7,1);
			"####" K 1 BRIGHT A_SetTranslucent(.6,1);
			"####" K 1 BRIGHT A_SetTranslucent(.5,1);
			"####" K 1 BRIGHT A_SetTranslucent(.4,1);
			"####" K 1 BRIGHT A_SetTranslucent(.3,1);
			"####" K 1 BRIGHT A_SetTranslucent(.2,1);
			"####" K 0 { bWindThrust = False; }
			Stop;
	}
}

class TracerSpark_Longlive : TracerSpark
{

	Default
	{
		+BRIGHT
		Gravity .2;
	}

	States
	{
		Spawn:
			PUFF A 0 NODELAY A_Jump(256, "Fade1", "Fade2", "Fade3", "Fade4");
			Loop;
		Fade1:
			"####" AEFGHI 5 A_SetTranslucent(.8,1);
			"####" J 2 A_SetTranslucent(.8,1);
			"####" K 2 A_SetTranslucent(.7,1);
			"####" K 2 A_SetTranslucent(.6,1);
			"####" K 2 A_SetTranslucent(.5,1);
			"####" K 2 A_SetTranslucent(.4,1);
			"####" K 2 A_SetTranslucent(.3,1);
			"####" K 2 A_SetTranslucent(.2,1);
			"####" K 0 { bWindThrust = False; }
			Stop;
		Fade2:
			"####" AEFGHI 6 A_SetTranslucent(.8,1);
			"####" J 3 A_SetTranslucent(.8,1);
			"####" K 3 A_SetTranslucent(.7,1);
			"####" K 3 A_SetTranslucent(.6,1);
			"####" K 3 A_SetTranslucent(.5,1);
			"####" K 3 A_SetTranslucent(.4,1);
			"####" K 3 A_SetTranslucent(.3,1);
			"####" K 3 A_SetTranslucent(.2,1);
			"####" K 0 { bWindThrust = False; }
			Stop;
		Fade3:
			"####" AEFGHI 4 A_SetTranslucent(.8,1);
			"####" J 4 A_SetTranslucent(.8,1);
			"####" K 4 A_SetTranslucent(.7,1);
			"####" K 4 A_SetTranslucent(.6,1);
			"####" K 4 A_SetTranslucent(.5,1);
			"####" K 4 A_SetTranslucent(.4,1);
			"####" K 4 A_SetTranslucent(.3,1);
			"####" K 4 A_SetTranslucent(.2,1);
			"####" K 0 { bWindThrust = False; }
			Stop;
		Fade4:
			"####" AEFGHI 7 A_SetTranslucent(.8,1);
			"####" J 2 A_SetTranslucent(.8,1);
			"####" K 2 A_SetTranslucent(.7,1);
			"####" K 2 A_SetTranslucent(.6,1);
			"####" K 2 A_SetTranslucent(.5,1);
			"####" K 2 A_SetTranslucent(.4,1);
			"####" K 2 A_SetTranslucent(.3,1);
			"####" K 2 A_SetTranslucent(.2,1);
			"####" K 0 { bWindThrust = False; }
			Stop;
	}
}

class PlayerTracer : BulletTracer
{
	Default
	{
		MaxTargetRange 2048.0; // Used in P_SpawnPlayerMissile's P_LineAttack call to set range for auto-aiming
		Species "PlayerFollower"; // By default, player bullets have PlayerFollower species
	}

	override void PostBeginPlay()
	{
		if (target && target is "PlayerFollower" && target.bFriendly) { // If the shooter is a friendly PlayerFollower...
			A_SetSpecies("Player");  // ...they can always shoot through players
			bThruSpecies = True;
		} else if (!multiplayer && skill < 2) { // Otherwise, if it's a regular player, not in coop (or dm, hypothetically), and at lowest two skills...
			bThruSpecies = True; // ...player shots go through PlayerFollower species, as defined in Default block
		}

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		if (isFrozen()) { return; }

		if (zoffset < 8) // Rise up 8 units to match the crosshair height
		{
			zoffset = 8;
			SetOrigin(pos + (0, 0, zoffset), true);
			if (trailactor) { trailactor.SetOrigin(trailactor.pos + (0, 0, zoffset), true); }
		}
	}
}

class KTurretTracer : PlayerTracer
{
	Default
	{
		Speed 200.0;
		BulletTracer.Trail "KTurretTrail";
	}

	override void PostBeginPlay()
	{
		SetDamage(Random(10, 30));

		Super.PostBeginPlay();
	}
}

class KTurretTrail : TracerTrail
{
	Default
	{
		Alpha 1.0; // Start out at full alpha
	}
}

class KTFlare : ActorPositionable
{
	Default
	{
		+NOGRAVITY
		+ROLLSPRITE
		+FORCEXYBILLBOARD
		Scale 0.25;
		Alpha 0.5;
		RenderStyle "Add";
	}

	States
	{
		Spawn:
			FLAR B 1 Bright Light("3dFlare") A_FadeOut(0.075);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		roll += Random(0, 360);
	}

	override void Tick()
	{
		Actor.Tick();

		RotateWithMaster(ROT_MatchAngle);
	}
}