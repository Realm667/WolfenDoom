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

// Vehicle base class - handles trample effect and slope aware terrain following
class VehicleBase : Base
{
	double trampleradius;

	Property TrampleRadius:trampleradius;

	Default
	{
		VehicleBase.TrampleRadius -1;
	}

	// Handling for terrain-based pitch/roll calculations...
	static double SetPitchRoll(Actor mo, double xoffset = 0, double yoffset = 0, int cap = 80, bool force = false, double centerxoffset = 0, double centeryoffset = 0)
	{
		if (!mo) { return 0; }

		double testwidth = mo.radius + yoffset;
		double testlength;

		if (mo is "TankTreadsBase") { testlength = TankTreadsBase(mo).length; }
		if (!testlength) { testlength = mo.radius + xoffset; }

		// Account for current pitch/roll when measuring corner heights
		testwidth *= abs(cos(mo.roll));
		testlength *= abs(cos(mo.pitch));

		double points[4], minz = 0x7FFFFFFF, maxz = -0x7FFFFFFF;

		// Get the relative z-height at the four corners of the tank
		points[0] = mo.GetZAt(centerxoffset + testlength, centeryoffset + testwidth);
		points[1] = mo.GetZAt(centerxoffset + testlength, centeryoffset - testwidth);
		points[2] = mo.GetZAt(centerxoffset - testlength, centeryoffset + testwidth);
		points[3] = mo.GetZAt(centerxoffset - testlength, centeryoffset - testwidth);

		for (int i = 0; i < 4; i++)
		{
			double maxstep = mo.master ? mo.master.MaxStepHeight : mo.MaxStepHeight;
			double maxdrop = mo.master ? mo.master.MaxDropoffHeight : mo.MaxDropoffHeight;

			if (points[i] > mo.pos.z + maxstep) { points[i] = 0; } // Ignore the point if you can't climb that high
			else if (points[i] < mo.pos.z - maxdrop) { points[i] = 0; } // Ignore the point if it's a dropoff
			else { points[i] -= mo.floorz; }
		}

		// Use those values to calculate the pitch.roll amounts
		double pitchinput = (points[0] + points[1]) / 2 - (points[2] + points[3]) / 2;
		double rollinput = (points[1] + points[3]) / 2 - (points[0] + points[2]) / 2;

		pitchinput = atan(pitchinput / (testlength * 2));
		rollinput = atan(rollinput / (testwidth * 2));

		// Interpolate to the new values
		if (force || level.time && level.time < 15)
		{
			mo.pitch = clamp(-pitchinput, -cap, cap);
			mo.roll = clamp(rollinput, -cap, cap);
		}
		else
		{
			if (mo.pitch > -pitchinput) { mo.pitch = max(mo.pitch - 1, -pitchinput); }
			if (mo.pitch < -pitchinput) { mo.pitch = min(mo.pitch + 1, -pitchinput); }

			if (mo.roll > rollinput) { mo.roll = max(mo.roll - 1, rollinput); }
			if (mo.roll < rollinput) { mo.roll = min(mo.roll + 1, rollinput); }

			mo.pitch = clamp(mo.pitch, -cap, cap);
			mo.roll = clamp(mo.roll, -cap, cap);
		}


		if (mo.master)
		{
			// Return the amount that you need to adjust the model z position by in order to keep it looking like it's actually on the ground
			double deltaz = testlength * sin(abs(mo.pitch)) + testwidth * sin(abs(mo.roll));

			return deltaz; 
		}

		return 0;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (other is "FlattenableProp") { return false; }
		if (other is "Trample") { return false; }
		return true;
	}

	override void Tick()
	{
		SetPitchRoll(self);
		if (health > 0) { DoTrample(); }

		Actor.Tick();
	}

	void DoTrample(bool always = false)
	{
		double movespeed = vel.length();

		if (trampleradius == -1)
		{
			if (self is "TankBase" && TankTreadsBase(TankBase(self).treads))
			{
				trampleradius = TankBase(self).treads.radius;
			}
			else { trampleradius = radius; }
		}

		if (movespeed >= 1 || always)
		{
			double dmg = always ? 1 : movespeed * 0.625;
			let treads = TankTreadsBase(TankBase(self).treads);

			bool sp;
			Actor t;

			// The explosion should only stick out 16 units in front of the tank
			double offset = trampleradius - radius + 16;
			if (self is "TankBase" && treads) { offset = max(treads.length, radius) - trampleradius + 16; }

			double angleoffset = treads ? treads.angle : 0;

			[sp, t] = A_SpawnItemEx("Trample", offset, 0, 0, 0, 0, 0, angleoffset, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_ABSOLUTEANGLE);

			if (t)
			{
				t.target = self; // Set the vehicle as the Trample actor's target, because Trample uses A_Explode, which defaults to treating the actor's target as the originator (and doesn't damage it)
				t.A_SetSize(trampleradius, Height / 3);
				Trample(t).dmg = int(dmg);
				if (treads) { t.angle = treads.angle; }
			}
		}
	}
}

// Trample actor - basically an explosion that simulates the spawning actor running over actors within its radius
// Used by tanks and by rail sequences
class Trample : GrenadeBase
{
	int dmg;
	int flags;

	Default
	{
		DamageType "Trample";
		Damage 5;
		Height 56;
		Radius 56;
		+NOBLOCKMAP
		+NOGRAVITY
		+NOCLIP
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Death:
			"####" # 20 {
				A_Explode(dmg == 0 ? damage : dmg, int(Radius), flags, FALSE, int(Radius));
			}
			Stop;
	}
}

// Target for tanks to aim at
class TankInterceptTarget : Actor
{
	Default
	{
		+BRIGHT
		+INVISIBLE
		+NOINTERACTION
		Alpha 0.5;
		RenderStyle "Translucent";
	}

	States
	{
	Spawn:
		EXCL A -1;
		Stop;
	}

	override void Tick()
	{
		Super.Tick();

		bInvisible = !boa_debugtankintercepts;
	}
}

// Same as NebNuke, but does not spawn NebBoom and cause explosion damage; moved from panzers.txt --N00b
class NebNukeHarmless: Actor
{
	Actor a, b;
	default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		Radius 0;
		Height 0;
	}
	States
	{
	Spawn:
		TNT1 A 0 Radius_Quake(3,8,0,24,0);
		"####" A 3
		{
			a = Spawn("NebFloor", Pos, ALLOW_REPLACE); b = Spawn("NebSmokeFloor", Pos, ALLOW_REPLACE);
			if (a) a.vel += self.vel; if (b) b.vel += self.vel;
		}
		"####" A 6 {
			a = Spawn("NebSmokePillar", Pos, ALLOW_REPLACE); b = Spawn("NebSmokeMushroom", Pos, ALLOW_REPLACE);
			if (a) a.vel += (self.vel + (0.0,0.0,2.0)); if (b) b.vel += self.vel;
		}
		Stop;
	}
}

// Base tank enemy actor.  Follows terrain, tramples.
//  Calls:
//   DoTurretTarget (when turret is aimed at the target)
//   DoTurret (when all conditions are right to fire a turret missile)
//   DoFrontWeapon (when conditions are right to fire straight ahead)
//
// See FriendlySherman below for use
class TankBase : VehicleBase
{
	Actor ally, treads, turret, gun, gunspot, gunspot2, frontgunspot;
	Class<Actor> body;
	Class<Actor> TurretProjectile;
	Class<Actor> FrontGunProjectile;
	double minpitch, maxpitch, minp, maxp;
	int missilecount, missiletimeout, bulletcount, bullettimeout, chasetimeout, turrettimeout, reversetimeout, targettimeout, turretdelay;
	sound movesound, idlesound;
	bool missiletargeted, wheeled;
	double zoffset, turretanglerange, turretspeed;
	bool user_static;
	bool intercept;
	Actor InterceptTarget; // Target for tank to aim at
	
	Property TankActor:body;
	Property MoveSound:movesound;
	Property IdleSound:idlesound;
	Property TurretAngleRange:turretanglerange;
	Property TurretSpeed:turretspeed;
	Property WheeledMovement:wheeled;
	Property MaxGunPitch:maxpitch;
	Property MinGunPitch:minpitch;
	Property TurretProjectile:TurretProjectile;
	Property FrontGunProjectile:FrontGunProjectile;
	Property TurretDelay:turretdelay;

	Default
	{
		Height 88;
		Mass 0x7ffffff;
		Radius 100;
		BloodType "TankSpark";
		DamageFactor "Melee", 0.0;	// Knife, boot, etc.
		DamageFactor "Bullet", 0.125;	// Most guns
		DamageFactor "Pellet", 0.125;	// Shotguns
		DamageFactor "Rifle", 0.5;	// Kar98, sniper rifle, chaingun
		DamageFactor "Fire", 0.5;	// Flamer
		DamageFactor "Trample", 0.1;	// Collision with another Tank/Vehicle
		DamageFactor "Frag", 0.25; // Cluster bombs
		Monster;
		MaxDropoffHeight 48;
		MaxStepHeight 32;
		Obituary "$TANKGUN";
		Species "NaziTank";
		MaxTargetRange 2048;
		RenderStyle "None";
		+AVOIDMELEE
		+BOSS
		+BOSSDEATH
		-CASTSPRITESHADOW
		+COUNTKILL
		+DONTMORPH
		+FLOORCLIP
		+ISMONSTER
		+LOOKALLAROUND
		+NOBLOOD
		+NOBLOODDECALS
		+NODROPOFF
		+NOINFIGHTING
		+PAINLESS
		+SLIDESONWALLS
		+SOLID
		TankBase.TankActor "US_Sherman";
		TankBase.MoveSound "TKMOVE";
		TankBase.IdleSound "TKIDLE";
		TankBase.MinGunPitch -10;
		TankBase.MaxGunPitch 25;
		TankBase.TurretSpeed 1.5;
		TankBase.TurretProjectile "TankMissile";
		TankBase.FrontGunProjectile "EnemyChaingunTracer";
		TankBase.TurretDelay 9;
	}

	States
	{
		Spawn:
			MDLA A 35 {
				target = FindEnemy();
				if (target) { SetStateLabel("See"); }
			}
			Loop;
		See:
			TNT1 A 1 A_TankChase();
			Goto See;
		Death:
			TNT1 A -1 DoDeath();
			Stop;
	}

	override void PostBeginPlay()
	{
		// Spawn everything in neutral orientation
		pitch = 0;
		roll = 0;

		if (bFriendly) { Species = "AllyTank"; }
		else { Species = "NaziTank"; }

		bool sp;
		while (!treads) { [sp, treads] = A_SpawnItemEx(body, 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); }
		treads.master = self;
		treads.bSolid = false;
		treads.Species = Species;
		treads.bFriendly = bFriendly;

		if (!user_static) { A_StartSound(idlesound, CHAN_6, CHANF_LOOPING, 0.25); }
		else { ClearCounters(); }

		targettimeout = Random(0, 35);
		// Disable intercepting missiles on lower skill levels
		intercept = G_SkillPropertyInt(SKILLP_ACSReturn) > 2;
		InterceptTarget = Spawn("TankInterceptTarget", Pos, ALLOW_REPLACE);

		Super.PostBeginPlay();
	}

	void DoDeath()
	{
		if (turret) { turret.Destroy(); }
		if (InterceptTarget) { InterceptTarget.Destroy(); }

		A_StopSound(CHAN_6); //the idle sound
		A_StopSound(CHAN_7);
		A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_IDLE);
		A_Scream();
		A_NoBlocking();

		if (treads)
		{
			Actor hulk = Spawn(TankTreadsBase(treads).deadclass, pos);

			hulk.angle = treads.angle;
			hulk.pitch = treads.pitch;
			hulk.roll = treads.roll;

			for (int i = 0; i < 30; i++)
			{
				A_SpawnItemEx(TankTreadsBase(treads).debris, random(88, 96), random(88, 96), random(88, 112), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
				A_SpawnItemEx("Debris_GlassShard_Large", random(88, 96), random(88, 96), random(96, 128), random(1, 3), random(1, 3), random(1, 3), random(0, 360), SXF_CLIENTSIDE);
			}

			TankTreadsBase(treads).DoDeath();
		}

		A_RemoveChildren(true, RMVF_EVERYTHING);
		
		A_SpawnItemEx("Nuke", 0, 0, 5, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		A_SpawnItemEx("KaBoomer", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		A_SpawnItemEx("GeneralExplosion_Large", 56, 0, 32);
	}

	override void Tick()
	{
		Actor.Tick();

		if (globalfreeze || level.Frozen || user_static) { return; }

		if (missiletimeout > 0) { missiletimeout--; }
		if (bullettimeout > 0) { bullettimeout--; }
		if (chasetimeout > 0) { chasetimeout--; }
		if (turrettimeout > 0) { turrettimeout--; }
		if (reversetimeout > 0) { reversetimeout--; }
		if (targettimeout > 0) { targettimeout--; }

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
		}

		if (!turret)
		{
			if (TankTreadsBase(treads))
			{
				turret = TankTreadsBase(treads).turret;

				if (turret)
				{
					turret.master = self;
					turret.angle = angle;
					turret.bSolid = false;
					turret.Species = Species;
				}
			}
		}

		if (treads && turret)
		{
			double zoffset = VehicleBase.SetPitchRoll(treads);
			double newz = pos.z - zoffset > GetZAt(0, 0) + MaxDropoffHeight ? pos.z - zoffset : GetZAt(0, 0);
			treads.SetOrigin((pos.xy, newz), true);

			double delta = deltaangle(treads.angle, turret.angle);

			minp = treads.pitch * cos(delta) - maxpitch;
			maxp = treads.pitch * cos(delta) - minpitch;

			turret.SetOrigin(treads.pos + (RotateVector((treads.radius * sin(treads.pitch), -treads.radius * sin(treads.roll)), treads.angle), treads.height * cos(treads.roll)), true);

			turret.pitch = treads.roll * sin(-delta) + treads.pitch * cos(delta);
			turret.roll = treads.roll * cos(-delta) + treads.pitch * sin(delta);

			if (!gun) { gun = TankTurretBase(turret).gun; }

			if (gun)
			{
				gun.A_Face(target, 0, turretspeed, flags:FAF_MIDDLE);

				// Force pitch clamping
				if (turret.pitch + gun.pitch >= maxp) { gun.pitch = maxp; }
				else if (turret.pitch + gun.pitch < minp)  { gun.pitch = minp; }

				gun.roll = turret.roll;
			}

			if (!gunspot) { gunspot = TankTurretBase(turret).gunspot; }
		}

		if (!frontgunspot && treads) { frontgunspot = TankTreadsBase(treads).gunspot; }

		if (bFriendly && (!ally || ally.health <= 0)) { ally = FindClosestPlayer(self, 360, 0, false); }

		if (target && bAvoidMelee) { bFrightened = Distance2D(target) < 256; } // Keep distance from the target
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (IsFriend(other) || (other is "TankBlocker" && other.Species == Species)) { return false; }

		if (!treads || (other.pos.z + height > treads.pos.z && other.pos.z < treads.pos.z + treads.height))
		{
			other.DamageMobj(self, self, int(vel.length() * 0.625), "Trample");
		}

		return Super.CanCollideWith(other, passive);
	}

	Actor FindEnemy()
	{
		Actor enemy = null;

		if (bFriendly)
		{
			if (ally && ally.player.attacker && ally.player.attacker != ally && ally.player.attacker.health > 0)
			{
				if (Distance3D(ally.player.attacker) < MaxTargetRange) { enemy = ally.player.attacker; }
			}
		}
		else
		{
			for (int p = 0; p < MAXPLAYERS; p++)
			{ // Iterate through all of the players and find the closest one
				Actor pl = players[p].mo;

				if (pl)
				{
					if (!pl.bShootable || pl.health <= 0) { continue; }
					if (players[p].cheats & CF_NOTARGET) { continue; }
					if (isFriend(pl)) { continue; }
					if (Distance3D(pl) > MaxTargetRange) { continue; }
					if (enemy && Distance3d(pl) > Distance3d(enemy)) { continue; }

					enemy = pl;
				}
			}
		}

		ThinkerIterator Finder;
		Base mo;

		// Only target sneakable actors if you are a friendly tank (so that enemy tanks won't target sneakable enemies)
		if (bFriendly)
		{
			Finder = ThinkerIterator.Create("Base", STAT_DEFAULT - 5);

			while ( (mo = Base(Finder.Next())) )
			{
				if (!IsValidTarget(mo)) { continue; }
				if (enemy && Distance3d(mo) > Distance3d(enemy)) { continue; }

				enemy = mo;
			}
		}

		// A Second iterator to account for the non-sneakables...
		Finder = ThinkerIterator.Create("Base", STAT_DEFAULT);

		while ( (mo = Base(Finder.Next())) )
		{
			if (!IsValidTarget(mo)) { continue; }
			if (enemy && Distance3d(mo) > Distance3d(enemy)) { continue; }

			enemy = mo;
		}

		// A third iterator to account for the player followers...
		Finder = ThinkerIterator.Create("PlayerFollower", STAT_DEFAULT);
		PlayerFollower pf;

		while ( (pf = PlayerFollower(Finder.Next())) )
		{
			if (!IsValidTarget(pf)) { continue; }
			if (enemy && Distance3d(pf) > Distance3d(enemy)) { continue; }

			enemy = pf;
		}

		return enemy;
	}

	bool IsValidTarget(Actor mo)
	{
		if (mo is "TankBase" && TankBase(mo).treads) { mo = TankBase(mo).treads; }

		if (
			!mo.bIsMonster ||
			mo.health <= 0 ||
			mo.bDormant ||
			!IsHostile(mo) ||
			mo == self ||
			!CheckSight(mo) ||
			Distance3D(mo) > MaxTargetRange || 
			mo is "StatistBarkeeper" || // Ignore NPCs...
			mo is "Camp_PrisonerBald" || // Ignore Camp Prisoners...
			(!bFriendly && Nazi(mo) && Nazi(mo).user_sneakable) // Ignore sneakables who are set via editor property
		) { return false; }

		return true;
	}

	virtual void A_TankChase(int flags = 0)
	{
		if (!treads || user_static) { return; }

		if (bStandStill) { flags |= CHF_DONTMOVE | CHF_DONTTURN; }

		if (!targettimeout && (!target || target.health <= 0 || !CheckLOF(CLOFF_JUMPENEMY | CLOFF_SKIPOBJECT, maxtargetrange) || !IsValidTarget(target))) { target = FindEnemy(); targettimeout = 70; }

		if ((!chasetimeout || !wheeled) && !(flags & CHF_DONTTURN))
		{
			double diff = deltaangle(treads.angle, angle);

			double turnamt = speed / (wheeled ? 3 : 5);

			if (reversetimeout) { turnamt *= -1; }

			if (abs(diff) > abs(turnamt) + 2)
			{
				if (diff < turnamt)
				{
					treads.angle -= turnamt;
					flags |= CHF_DONTMOVE;
					if (InStateSequence(treads.CurState, treads.SpawnState) && treads.FindState("Move")) { treads.SetStateLabel("Move"); }
				}
				else if (diff > -turnamt)
				{
					treads.angle += turnamt;
					flags |= CHF_DONTMOVE;
					if (InStateSequence(treads.CurState, treads.SpawnState) && treads.FindState("Move")) { treads.SetStateLabel("Move"); }
				}
				else
				{
					treads.angle = angle;
				}
			}

			if (wheeled) { DoMove(); }
		}

		if (!target || !CheckLOF(CLOFF_JUMPENEMY | CLOFF_SKIPOBJECT, maxtargetrange, offsetforward: treads.radius))
		{
			missiletimeout = 70;
			bullettimeout = 35;
		}

		Actor cannon = gunspot ? gunspot : (gun ? gun : turret);
		if (turret && !missiletimeout && !turrettimeout && missiletargeted && CheckLOF(CLOFF_JUMPENEMY | CLOFF_SKIPOBJECT, maxtargetrange, offsetforward: treads.radius))
		{
			flags |= CHF_DONTMOVE | CHF_DONTTURN;

			DoTurret(cannon);
			missiletargeted = false;
		}

		if (turret && !turrettimeout)
		{
			if (target)
			{
				Actor aimAt = target;
				if (intercept)
				{
					double interceptTime;
					interceptTime = ZScriptTools.GetInterceptTime4(Pos, Target.Pos, Target.Vel, GetDefaultSpeed(TurretProjectile));
					interceptTime += turretdelay; // Account for pre-fire delay
					Vector3 interceptPos = Target.Pos + Target.Vel * interceptTime;
					InterceptTarget.SetOrigin(interceptPos, true);
					aimAt = InterceptTarget;
				}
				if (turretanglerange > 0)
				{
					double delta = deltaangle(treads.angle, treads.AngleTo(aimAt));

					if (abs(delta) <= turretanglerange) { turret.A_Face(aimAt, turretspeed); A_StartSound("MACHINE_LOOP_3", 8, CHANF_NOSTOP, 1.0); }
					else { turret.angle = clamp(turret.angle, treads.angle - turretanglerange, treads.angle + turretanglerange); A_StartSound("MACHINE_LOOP_3", 8, CHANF_NOSTOP, 1.0); }
				}
				else { turret.A_Face(aimAt, turretspeed); }

				if (int(turret.angle) == int(turret.AngleTo(aimAt)))
				{
					A_StopSound(8);
					if (CheckLOF(CLOFF_JUMPENEMY | CLOFF_SKIPOBJECT, maxtargetrange, offsetforward: treads.radius) && (!gun || (gun.pitch - turret.pitch >= minp && gun.pitch - turret.pitch <= maxp)))
					{
						DoTurretTarget(cannon);
					}
				}
			}
			else
			{
				turret.angle = clamp(treads.angle, turret.angle - turretspeed, turret.angle + turretspeed);
			}
		}

		if (!bullettimeout && frontgunspot && abs(deltaangle(frontgunspot.angle, frontgunspot.AngleTo(target))) <= 5 && CheckLOF(CLOFF_JUMPENEMY | CLOFF_MUSTBESOLID, maxtargetrange * 2 / 3, offsetforward: Radius * 2))
		{
			DoFrontWeapon(frontgunspot ? frontgunspot : treads);
		}

		if (chasetimeout)
		{
			flags |= CHF_DONTMOVE | CHF_DONTTURN;
			A_StopSound(CHAN_7);
		}
		else if (!bStandStill)
		{
			DoMove();
		}

		A_Chase(null, null, flags);
	}

	void DoMove()
	{
		if (!treads) { return; }

		if (reversetimeout <= 0 && speed != default.speed) { speed = Default.speed; }

		if (!CheckPosition(pos.xy + RotateVector((reversetimeout ? -32 : 32, 0), treads.angle)))
		{
			if (wheeled || !BlockingMobj)
			{
				speed *= -0.5;
				if (speed < 0) { reversetimeout = int((15 + Random(0, 35)) * Default.Speed); }
				else { reversetimeout = 0; }
			}
		}

		A_ChangeVelocity(cos(treads.angle) * speed, sin(treads.angle) * speed, vel.z, CVF_REPLACE);

		if (InStateSequence(treads.CurState, treads.SpawnState) && treads.FindState("Move"))
		{
			 treads.SetStateLabel("Move");
		}

		DoTrample(true);

		A_StartSound(movesound, CHAN_7, CHANF_LOOPING, 1.0);
	}

	// Fire the main cannon at the target. The main cannon is assumed to be
	// already aiming at its target.
	// origin - The main cannon actor
	virtual void DoTurret(Actor origin)
	{
		// Needed since overrides call origin.A_ArcProjectile, which uses the caller's target pointer.
		origin.target = target;
		missiletargeted = false;
		bullettimeout = 20;
		turrettimeout = 87; // 2.5 seconds
		chasetimeout = 5;
	}

	// Fire the turret at the target. The turret is not assumed to be aiming at
	// its target, so you will need to make the turret aim at the target when
	// you override this method.
	// origin - The turret actor
	virtual void DoTurretTarget(Actor origin)
	{
		origin.target = target; // Just in case...
		missiletargeted = true;
		chasetimeout = 40;
		turrettimeout = turretdelay;
	}

	// Fire the front weapon at the target. The front weapon is assumed to be
	// aiming at the target.
	// origin - The front weapon
	virtual void DoFrontWeapon(Actor origin)
	{
		origin.target = target;
		chasetimeout = 20;
		missiletimeout = 70;
	}

	override String GetObituary(Actor victim, Actor inflictor, Name mod, bool playerattack)
	{
		if (mod == 'Trample')
		{
			return "$TRAMPLE";
		}
		else if (mod == 'Rocket')
		{
			return "$TANKSHELL";
		}

		return Super.GetObituary(victim, inflictor, mod, playerattack);
	}

	override void OnDestroy()
	{
		if (user_static) { level.total_monsters++; }

		Super.OnDestroy();
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		// For bullet projectiles, if the enemy's species (appended with "Tank") is the same as the tank's species, then don't do any damage to the tank.
		if (source && mod == "Bullet")
		{
			if (source.species == species || source.species == species .. "Tank")
			{
				return 0;
			}
		}

		return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
	}
}

// Blocker object for the front and back of the tank used to keep actors from walking inside the model
class TankBlocker : Actor
{
	Vector3 spawnoffset;
	Vector3 offset;
	double oldpitch;
	double oldroll;
	double oldangle;

	Default
	{
		+CANPASS
		+NOGRAVITY
		+SOLID
		+SHOOTABLE
		+NOBLOOD
		+NODAMAGE
		+NOTAUTOAIMED
		+DONTTHRUST
		Painchance 255;
		Radius 32;
		Height 64;
	}
	States
	{
		Spawn:
			TNT1 A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (scale.x == 1.0 && scale.y == 1.0)
		{
			scale.x = Radius * 2; 
			scale.y = Height;
		}

		if (master)
		{
			spawnoffset = pos - master.pos;

			Vector2 temp = RotateVector((spawnoffset.x, spawnoffset.y), -master.angle);
			spawnoffset = (temp.x, temp.y, spawnoffset.z);

			offset = spawnoffset;
		}
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (master && master.master) // Ugh...
		{
			if (source != master.master)
			{
				master.master.DamageMobj(inflictor, source, damage, mod, flags, angle);  // Inflict the damage on the owner of the tank
			}
		}

		return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
	}

	override bool Used(Actor user)
	{
		if (master) { return master.Used(user); }
		return false;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (master && master.master && other != master && other != master.master && !master.master.IsFriend(other))
		{
			other.DamageMobj(self, master.master, int(master.master.vel.length() * 0.625), "Trample");

			return master.CanCollideWith(other, passive);
		}

		return Super.CanCollideWith(other, passive);
	}


	override void Tick()
	{
		Super.Tick();

		if (master)
		{
			scale.x *= master.scale.x;
			scale.y *= master.scale.y;

			SetTag(master.GetTag());

			Species = master.Species;
		}

		Rotate();
	}

	void Rotate()
	{
		Vector2 temp;

		// Keep the blocks in the correct position, regardless of pitch/roll of the master actor
		// Obviously not perfect, because the blocks are square, but close enough when you can't see them.
		if (master && spawnoffset != (0, 0, 0)) {
			temp = RotateVector((spawnoffset.y, spawnoffset.z), master.roll);
			offset = (spawnoffset.x, temp.x, temp.y);

			temp = RotateVector((offset.x, offset.z), 360 - master.pitch);
			offset = (temp.x, offset.y, temp.y);

			temp = RotateVector((offset.x, offset.y), master.angle);
			offset = (temp.x, temp.y, offset.z);

			offset.x *= master.scale.x;
			offset.y *= master.scale.x;
			offset.z *= master.scale.y;

			SetOrigin(master.pos + offset, true);

			angle = master.angle;

			oldpitch = master.pitch;
			oldroll = master.roll;
			oldangle = master.angle;
		}
	}
}

// Base actor for tank treads
class TankTreadsBase : Base
{
	TankTurretBase turret;
	Actor gunspot;
	Class<Actor> turretclass, deadclass, debris;
	Class<PowerMorph> morphpowerup;
	int savedhealth;
	int usetimeout;
	double length;
	Vector3 gunspotoffset;
	double gunspotoffsetx, gunspotoffsety, gunspotoffsetz;

	Property TurretClass:turretclass;
	Property Length:length;
	Property MorphPowerup:morphpowerup;
	Property DeadActor:deadclass;
	Property DebrisActor:debris;
	Property GunSpotX:gunspotoffsetx;
	Property GunSpotY:gunspotoffsety;
	Property GunSpotZ:gunspotoffsetz;

	Default
	{
		Radius 64; // Also used as half-width of model for slope tilt calculations
		Height 64;
		Mass 0x7ffffff;
		Species "NaziTank";
		+CANPASS
		+SOLID
		TankTreadsBase.DeadActor "";
		TankTreadsBase.DebrisActor "Debris_Tank";
		TankTreadsBase.Length 96; // Half-length of model for slope calculation
		TankTreadsBase.MorphPowerup "";
		TankTreadsBase.GunSpotX 0;
		TankTreadsBase.GunSpotY 0;
		TankTreadsBase.GunSpotZ 0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
		Move:
			MDLA AB 5;
			Goto Spawn;
		Death:
			TNT1 A 1 DoDeath();
			Stop;
	}

	override void PostBeginPlay()
	{
		bool sp = false;
		Actor temp;
		
		while (!turret)
		{
			[sp, temp] = A_SpawnItemEx(turretclass, 0, 0, Height, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); 
			turret = TankTurretBase(temp);
		}

		double br = GetDefaultByType("TankBlocker").radius;
		double r = radius - br;
		double l = length - br;

		A_SpawnItemEx("TankBlocker", l, r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		A_SpawnItemEx("TankBlocker", l, -r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		A_SpawnItemEx("TankBlocker", -l, -r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		A_SpawnItemEx("TankBlocker", -l, r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);

		gunspotoffset = (gunspotoffsetx, gunspotoffsety, gunspotoffsetz);
		while (!gunspot) { [sp, gunspot] = A_SpawnItemEx("WeaponSpot", gunspotoffset.x, gunspotoffset.y, gunspotoffset.z, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); }
		gunspot.master = self;

		if (!master && morphpowerup) { BoACompass.Add(self, "TANKICO"); }

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (usetimeout) { usetimeout--; }

		if (master && master.player)
		{
			double moving = master.player.cmd.forwardmove;

			if (moving != 0)
			{
				double movespeed = master.vel.length();

				int dir = moving > 0 ? 1 : -1; // Trample both forward and backwards, depending on which direction you're moving
				double dmg = movespeed * 0.625; // Top speed gives ~100 damage

				bool sp;
				Actor t;

				[sp, t] = A_SpawnItemEx("Trample", scale.x * 128 * dir, 0, height / 2 - 16, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE);

				if (t)
				{
					t.target = master; // Set the player as the Trample actor's target, because it uses A_Explode, which defaults to treating the actor's target as the originator (and doesn't damage it)
					Trample(t).dmg = int(dmg);
				}
			}
		}

		if (turret)
		{
			turret.bSolid = bSolid;
			turret.bInvisible = bInvisible;
		}

		Super.Tick();
	}

	override bool Used(Actor user)
	{
		if (!morphpowerup) { return false; }

		if (usetimeout || bDormant || master && (master.player || master.bIsMonster)) { return false; }

		let p = user.player;

		if (p)
		{
			bSolid = False;

			p.mo.SetOrigin(pos, false);

			if (turret) { p.mo.angle = turret.angle; }
			else { p.mo.angle = angle; }

			p.mo.tracer = self;

			user.GiveInventory(morphpowerup, 1);
			return true;
		}
		return false;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (master && other != master && !master.IsFriend(other))
		{
			other.DamageMobj(self, master, int(0.5 * master.vel.xy.length()), "Trample");

			return master.CanCollideWith(other, passive);
		}

		return Super.CanCollideWith(other, passive);
	}

	void DoDeath()
	{
		// Spawn more block actors that can be jumped onto so that dead tanks can be climbed over
		bool s;
		Actor mo;

		double br = GetDefaultByType("TankBlocker").radius;
		double r = radius - br + 8;
		double l = length - br + 8;

		[s, mo] = A_SpawnItemEx("TankBlocker", l, 0, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		if (mo) { mo.A_SetSize(-1, 32); }

		[s, mo] = A_SpawnItemEx("TankBlocker", -l, 0, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		if (mo) { mo.A_SetSize(-1, 32); }

		[s, mo] = A_SpawnItemEx("TankBlocker", 0, r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		if (mo) { mo.A_SetSize(-1, 32); }

		[s, mo] = A_SpawnItemEx("TankBlocker", 0, -r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		if (mo) { mo.A_SetSize(-1, 32); }
	}		
}

class PairedTire : Actor
{
	Vector3 spawnoffset;
	bool turning;
	int rotated;

	Default
	{
		+NOGRAVITY
		+NOINTERACTION
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (!master) { Destroy(); return; }

		spawnoffset = pos - master.pos;

		spawnoffset = (RotateVector(spawnoffset.xy, -master.angle), spawnoffset.z);

		bSolid = false;
		Species = master.Species;
		bFriendly = master.bFriendly;
		angle = master.angle + rotated;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (master && other != master) { return master.CanCollideWith(other, passive); }

		return Super.CanCollideWith(other, passive);
	}

	override void Tick()
	{
		Super.Tick();

		if (globalfreeze || level.Frozen) { return; }

		scale.x = default.scale.x / level.pixelstretch; // Forceably correct skewed models introduced by pixel ratio settings

		if (master)
		{
			Vector3 offset;

			if (spawnoffset != (0, 0, 0))
			{
				Vector2 temp = RotateVector((spawnoffset.y, spawnoffset.z), master.roll);
				offset = (spawnoffset.x, temp.x, temp.y);

				temp = RotateVector((offset.x, offset.z), 360 - master.pitch);
				offset = (temp.x, offset.y, temp.y);

				temp = RotateVector((offset.x, offset.y), master.angle);
				offset = (temp.x, temp.y, offset.z);
			}

			SetOrigin(master.pos + offset, true);

			if (master.InStateSequence(master.CurState, master.FindState("Move")))
			{
				let base = master.master;
				double speed = base ? base.speed : 1;

				speed *= 2;

				if (rotated >= 180) { speed *= -1; }

				pitch += speed;
			}

			if (master.master && turning)
			{
				let base = master.master;
				double dir = base ? base.speed / abs(base.speed) : 1;

				double delta = deltaangle(master.angle, base.angle);

				double destangle = clamp(master.angle + rotated + delta * dir, master.angle - 30 + rotated, master.angle + 30 + rotated);

				angle = clamp(destangle, angle - 5, angle + 5);
			}
			else { angle = master.angle + rotated; }
		}
		else { Destroy(); }
	}
}

// Base actor for tank turret
class TankTurretBase : Base
{
	TankCannonBase gun;
	actor gunspot, gunspot2;
	Class<Actor> gunclass;
	Vector3 spawnoffset;
	Vector3 offset;
	double gunoffsetx, gunoffsetz, turretoffsetx;
	Vector3 gunspotoffset;
	double gunspotoffsetx, gunspotoffsety, gunspotoffsetz;

	Property TurretOffsetX:turretoffsetx;
	Property GunClass:gunclass;
	Property GunOffsetX:gunoffsetx;
	Property GunOffsetZ:gunoffsetz;
	Property GunSpotX:gunspotoffsetx;
	Property GunSpotY:gunspotoffsety;
	Property GunSpotZ:gunspotoffsetz;

	Default
	{
		Height 32;
		Species "NaziTank";
		+DONTSPLASH
		+NOGRAVITY
		+SOLID
		TankTurretBase.GunOffsetX 32;
		TankTurretBase.GunOffsetZ 18;
		TankTurretBase.GunSpotX 0;
		TankTurretBase.GunSpotY 0;
		TankTurretBase.GunSpotZ 0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		bool sp = false;
		Actor temp;
		
		if (gunclass)
		{
			while (!gun)
			{
				[sp, temp] = A_SpawnItemEx(gunclass, gunoffsetx, 0, gunoffsetz, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE);
				gun = TankCannonBase(temp);
			}
			
			gun.Species = Species;

			spawnoffset = gun.pos - pos;

			spawnoffset = (RotateVector(spawnoffset.xy, -angle), spawnoffset.z);
		}

		gunspotoffset = (gunspotoffsetx, gunspotoffsety, gunspotoffsetz);
		while (!gunspot) { [sp, gunspot] = A_SpawnItemEx("WeaponSpot", gunspotoffset.x, gunspotoffset.y, gunspotoffset.z, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); }
		if (gun) { gunspot.master = gun; }
		else { gunspot.master = self; }

		Super.PostBeginPlay();
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (master && other != master) { master.CanCollideWith(other, passive); }

		return true;
	}

	override void Tick()
	{
		if (gun)
		{
			gun.angle = angle;

			Vector2 temp = RotateVector((spawnoffset.y, spawnoffset.z), roll);
			offset = (spawnoffset.x, temp.x, temp.y);

			temp = RotateVector((offset.x, offset.z), 360 - pitch);
			offset = (temp.x, offset.y, temp.y);

			temp = RotateVector((offset.x, offset.y), angle);
			offset = (temp.x, temp.y, offset.z);

			gun.SetOrigin(self.pos + offset, true);

			gun.bSolid = bSolid;
			gun.bInvisible = bInvisible;
		}

		Actor.Tick();
	}

	override void OnDestroy()
	{
		if (gun) { gun.Destroy(); }
	}
}

class TankCannonBase : Base
{
	Default
	{
		+DONTSPLASH
		+NOGRAVITY
		Species "Tank";
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class TankDeadBase : Base
{
	Default
	{
		Radius 88;
		Height 96;
		Mass 0x7ffffff;
		+FLOORCLIP
		+NOBLOOD
		+NOBLOODDECALS
		+NODAMAGE
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		BloodType "TankSpark";
	}
	
	States
	{
	Spawn:
		MDLA A 12 A_SpawnProjectile("TankSmoke",58,0,random(0,360),2,random(70,130));
		Loop;
	}
}

// Sherman Tank components (used by both FriendlySherman and ShermanPlayer)
class US_Sherman : TankTreadsBase
{
	Default
	{
		//$Category Models (BoA)/Vehicles
		//$Title Driveable US M4 Sherman Tank
		//$Color 3
		TankTreadsBase.DeadActor "US_ShermanDead";
		TankTreadsBase.DebrisActor "Debris_Tank2";
		TankTreadsBase.MorphPowerup "Sherman";
		TankTreadsBase.TurretClass "US_ShermanTurret";
		TankTreadsBase.GunSpotX 100;
		TankTreadsBase.GunSpotY 25;
		TankTreadsBase.GunSpotZ 54;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		double br = GetDefaultByType("TankBlocker").radius;
		double r = radius - br;
		double l = length - br;

		A_SpawnItemEx("TankBlocker", l * 1.25, -r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		A_SpawnItemEx("TankBlocker", l * 1.25, r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		A_SpawnItemEx("TankBlocker", -l * 1.5, -r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
		A_SpawnItemEx("TankBlocker", -l * 1.5, r, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
	}
}

class US_ShermanTurret : TankTurretBase
{
	Default
	{
		TankTurretBase.GunClass "US_ShermanCannon";
		TankTurretBase.GunSpotX 120;
		TankTurretBase.GunSpotY 0;
		TankTurretBase.GunSpotZ 20;
	}

	override void PostBeginPlay()
	{
		bool sp = false;

		Vector3 gunspot2offset = (48, 16, 19);
		while (!gunspot2) { [sp, gunspot2] = A_SpawnItemEx("WeaponSpot", gunspot2offset.x, gunspot2offset.y, gunspot2offset.z, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); }
		gunspot2.master = self;

		Super.PostBeginPlay();

		if (gun) { gunspot2.master = gun; }
	}
}

class US_ShermanCannon : TankCannonBase {}
class US_ShermanDead : TankDeadBase {}

// Friendly Sherman Tank Actor
class FriendlySherman : TankBase
{
	Default
	{
		//$Category Monsters (BoA)/Tanks
		//$Title Sherman Tank, Manned (Friendly)
		//$Color 4
		Tag "$TAGSHERMAN";
		Health 3500;
		Radius 64;
		Speed 2.66666667;
		Species "AllyTank";
		MaxTargetRange 2048;
		+FRIENDLY
		TankBase.TankActor "US_Sherman";
		TankBase.MoveSound "TNK1LOOP";
		TankBase.IdleSound "TKIDLE";
		TankBase.FrontGunProjectile "Kar98kTracer";
	}

	override void DoTurret(Actor origin)
	{
		if (!origin || !Base(origin)) { return; }

		Super.DoTurret(origin);

		Actor muzzleflash = Spawn("NebNukeHarmless", origin.Pos, ALLOW_REPLACE);
		A_StartSound("tanks/75mmm3", CHAN_WEAPON);
		A_Quake(4, 11, 0, 384);
		//Actor mo = origin.A_SpawnProjectile(TurretProjectile, 0, 0, origin.angle, CMF_ABSOLUTEPITCH | CMF_ABSOLUTEANGLE, origin.pitch);
		Actor mo = Base(origin).A_ArcProjectile(TurretProjectile, 32, 0, origin.angle, CMF_ABSOLUTEANGLE, additionalHeight:-32);

		if (mo)
		{
			muzzleflash.vel += (mo.vel.x / 2.0, mo.vel.y / 2.0, mo.vel.z / 2.0);
			if (self) muzzleflash.vel += self.vel;
			mo.target = self;

			missilecount++;
			if (missilecount > 1)
			{
				missilecount = 0;
				missiletimeout = 35 * Random(3, 5);
			}
			else
			{
				missiletimeout = 40;
			}
		}
	}

	override void DoFrontWeapon(Actor origin)
	{
		if (!origin) { return; }

		Super.DoFrontWeapon(origin);

		A_StartSound("tank/50cal", CHAN_WEAPON);

		// Muzzle flash
		Actor muzzleflash = Spawn("KTFlare", origin.Pos, ALLOW_REPLACE);
		// Required for the muzzle flash to work properly.
		muzzleflash.master = origin;
		// Smoke
		origin.A_SpawnProjectile("TurrSmokeSpawner", 0, flags: CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE);
		// Projectile
		Actor mo = A_SpawnProjectile(FrontGunProjectile, 0, 0, origin.angle + Random(-2, 2), CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE, Random(-2, 2));

		if (mo)
		{
			mo.SetOrigin(origin.pos, false);
			mo.target = self;
		}

		bulletcount++;
		if (bulletcount > 50 + Random(0, 25))
		{
			bulletcount = 0;
			bullettimeout = 40 + Random(0, 35);
		}
		else
		{
			bullettimeout = 6;
		}
	}
}

// Panzer IV 
class PanzerIVTreads : TankTreadsBase
{
	Default
	{
		//$Category Monsters (BoA)/Tanks
		//$Title Tanks Base Item (for modders)
		TankTreadsBase.DebrisActor "Debris_Tank2";
		TankTreadsBase.DeadActor "DestroyedTank1";
		TankTreadsBase.MorphPowerup "PanzerIV";
		TankTreadsBase.TurretClass "PanzerIVTurret";
		TankTreadsBase.GunSpotX 80;
		TankTreadsBase.GunSpotY 26;
		TankTreadsBase.GunSpotZ 52;
	}
}

class PanzerIVTurret : TankTurretBase
{
	Default
	{
		TankTurretBase.GunClass "PanzerIVCannon";
		TankTurretBase.GunSpotX 155;
		TankTurretBase.GunSpotY 0;
		TankTurretBase.GunSpotZ 12;
	}
	override void PostBeginPlay()
	{
		bool sp = false;

		Vector3 gunspot2offset = (48, 16, 10);
		while (!gunspot2) { [sp, gunspot2] = A_SpawnItemEx("WeaponSpot", gunspot2offset.x, gunspot2offset.y, gunspot2offset.z, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); }
		gunspot2.master = self;

		Super.PostBeginPlay();

		if (gun) { gunspot2.master = gun; }
	}
}

class PanzerIVCannon : TankCannonBase {}

class SSTank1 : TankBase
{
	Default
	{
		//$Category Monsters (BoA)/Tanks
		//$Title Tank 1 (3500 HP, Panther Panzer IV, Turret + Missile)
		//$Color 4
		Tag "$TAGPZIV";
		Health 3500;
		Speed 2.66666667;
		TankBase.TankActor "PanzerIVTreads";
		TankBase.MinGunPitch -5;
	}

	override void DoTurret(Actor origin)
	{
		if (!origin || !Base(origin)) { return; }

		Super.DoTurret(origin);

		Actor muzzleflash = Spawn("NebNukeHarmless", origin.Pos, ALLOW_REPLACE);
		A_StartSound("tanks/75mmkwk40", CHAN_WEAPON);
		A_Quake(4, 11, 0, 384);
		//Actor mo = origin.A_SpawnProjectile(TurretProjectile, 0, 0, origin.angle, CMF_ABSOLUTEPITCH | CMF_ABSOLUTEANGLE, origin.pitch);
		Actor mo = Base(origin).A_ArcProjectile(TurretProjectile, 32, 0, origin.angle, CMF_ABSOLUTEANGLE, additionalHeight:-32);

		if (mo)
		{
			muzzleflash.vel += (mo.vel.x / 2.0, mo.vel.y / 2.0, mo.vel.z / 2.0);
			if (self) muzzleflash.vel += self.vel;
			mo.target = self;

			missilecount++;
			if (missilecount > 1)
			{
				missilecount = 0;
				missiletimeout = 35 * Random(3, 5);
			}
			else
			{
				missiletimeout = Random() < 96 ? 38 : 24; // 38 tics between shots about 40% of the time.  Otherwise, 24 tics between shots
			}
		}
	}

	override void DoFrontWeapon(Actor origin)
	{
		if (!origin) { return; }

		Super.DoFrontWeapon(origin);

		A_StartSound("weapons/chaingun", CHAN_WEAPON);

		double gunpitch = origin.pitch;
		if (origin.master && TankBase(origin.master) && TankBase(origin.master).gun) { gunpitch = TankBase(origin.master).gun.pitch; }

		// Muzzle flash
		Actor muzzleflash = Spawn("KTFlare", origin.Pos, ALLOW_REPLACE);
		muzzleflash.master = origin;
		// Smoke
		origin.A_SpawnProjectile("TurrSmokeSpawner", 0, flags: CMF_ABSOLUTEPITCH);
		// Projectile
		Actor mo = A_SpawnProjectile(FrontGunProjectile, 0, 0, random(-4, 4), CMF_ABSOLUTEPITCH, max(-gunpitch, 0));

		if (mo)
		{
			mo.SetOrigin(origin.pos, false);
			mo.target = self;
		}

		bulletcount++;
		if (bulletcount > 75)
		{
			bulletcount = 0;
			bullettimeout = 35 * Random(2, 5); // 2-5 seconds between long bursts
		}
		else
		{
			bullettimeout = 2; // 2 tics between shots
		}
	}
}

// Halftrack
class HalftrackTreads : TankTreadsBase
{
	Default
	{
		Radius 48;
		TankTreadsBase.DebrisActor "Debris_Tank2";
		TankTreadsBase.DeadActor "DestroyedTank2";
		TankTreadsBase.TurretClass "HalftrackTurret";
		TankTreadsBase.GunSpotX 35;
		TankTreadsBase.GunSpotY -16;
		TankTreadsBase.GunSpotZ 62;
		TankTreadsBase.Length 132;
	}

	override void PostBeginPlay()
	{
		Actor fl, fr;
		bool sp;

		if (master) { angle = master.angle; }

		while (!fl) { [sp, fl] = A_SpawnItemEx("HalftrackTire", 100.0, -36.0, 20.0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_SETMASTER); }
		PairedTire(fl).turning = true;
		PairedTire(fl).rotated = 180;

		while (!fr) { [sp, fr] = A_SpawnItemEx("HalftrackTire", 100.0, 36.0, 20.0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_SETMASTER); }
		PairedTire(fr).turning = true;

		Super.PostBeginPlay();
	}
}

class HalftrackTire : PairedTire {}

class HalftrackTurret : TankTurretBase
{
	Default
	{
		Height 16;
		TankTurretBase.TurretOffsetX -64;
		TankTurretBase.GunSpotX 70;
		TankTurretBase.GunSpotY 0;
		TankTurretBase.GunSpotZ 16;
	}
}

class SSTank2 : TankBase
{
	Default
	{
		//$Category Monsters (BoA)/Tanks
		//$Title Tank 2 (2500 HP, KFZ 251 HalfTrack, Turret + Missile)
		//$Color 4
		Tag "$TAGSDKFZ251";
		Health 2500;
		Speed 2.33333333;
		MaxStepHeight 16;
		TankBase.TurretProjectile "TankRocket"; //I presume the tube atop it is a variation of Panzerschreck
		TankBase.TankActor "HalftrackTreads";
		TankBase.TurretAngleRange 20;
		TankBase.WheeledMovement true;
	}

	override void DoTurret(Actor origin)
	{
		if (!origin) { return; }

		Super.DoTurret(origin);

		origin.A_Face(target, 0, 0, flags:FAF_MIDDLE);
		origin.angle = turret.angle;
		A_Quake(2, 7, 0, 256);
		Actor muzzleflash = Spawn("NebNukeHarmless", origin.Pos, ALLOW_REPLACE);
		//no sound; it is a rocket
		Actor mo = origin.A_SpawnProjectile(TurretProjectile, 0, 0, origin.angle, CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE, origin.pitch);

		if (mo)
		{
			mo.target = self;

			missilecount++;
			missiletimeout = 40;
		}
	}

	override void DoFrontWeapon(Actor origin)
	{
		if (!origin) { return; }

		Super.DoFrontWeapon(origin);

		A_StartSound("weapons/chaingun", CHAN_WEAPON);

		origin.A_Face(target, 0, 0, flags:FAF_MIDDLE);
		origin.angle = treads.angle;

		// Muzzle flash
		Actor muzzleflash = Spawn("KTFlare", origin.Pos, ALLOW_REPLACE);
		muzzleflash.master = origin;
		// Smoke
		origin.A_SpawnProjectile("TurrSmokeSpawner", 0, flags: CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE);
		// Projectile
		Actor mo = origin.A_SpawnProjectile(FrontGunProjectile, 0, 0, origin.angle + random(-4, 4), CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE, origin.pitch);

		if (mo)
		{
			mo.target = self;
		}

		bulletcount++;
		if (bulletcount > 45)
		{
			bulletcount = 0;
			bullettimeout = 35 * Random(2, 5); // 2-5 seconds between long bursts
		}
		else
		{
			bullettimeout = 2; // 2 tics between shots
		}
	}
}

// Tiger
class TigerTreads : TankTreadsBase
{
	Default
	{
		TankTreadsBase.DebrisActor "Debris_Tank2";
		TankTreadsBase.DeadActor "DestroyedTank3";
		TankTreadsBase.TurretClass "TigerTurret";
	}
}

class TigerTurret : TankTurretBase
{
	Default
	{
		Height 16;
		TankTurretBase.GunClass "TigerCannon";
		TankTurretBase.GunOffsetX 50;
		TankTurretBase.GunOffsetZ 13;
		TankTurretBase.GunSpotX 180;
		TankTurretBase.GunSpotY 4;
		TankTurretBase.GunSpotZ 5;
	}
}

class TigerCannon : TankCannonBase {}

class SSTank3 : TankBase
{
	Default
	{
		//$Category Monsters (BoA)/Tanks
		//$Title Tank 3 (3000 HP, Tiger I Panzer, Missile only)
		//$Color 4
		Tag "$TAGPZVI";
		Health 3000;
		Speed 2.55555556;
		TankBase.TankActor "TigerTreads";
		TankBase.MinGunPitch -2;
		TankBase.MaxGunPitch 25;
	}

	override void DoTurret(Actor origin)
	{
		if (!origin || !Base(origin)) { return; }

		Super.DoTurret(origin);

		Actor muzzleflash = Spawn("NebNukeHarmless", origin.Pos, ALLOW_REPLACE);
		A_StartSound("tanks/88mmkwk36", CHAN_WEAPON);
		A_Quake(7, 15, 0, 512);
		//Actor mo = origin.A_SpawnProjectile(TurretProjectile, 0, 0, origin.angle, CMF_ABSOLUTEPITCH | CMF_ABSOLUTEANGLE, origin.pitch);
		Actor mo = Base(origin).A_ArcProjectile(TurretProjectile, 32, 0, origin.angle, CMF_ABSOLUTEANGLE, additionalHeight:-32);

		if (mo)
		{
			muzzleflash.vel += (mo.vel.x / 2.0, mo.vel.y / 2.0, mo.vel.z / 2.0);
			if (self) muzzleflash.vel += self.vel;
			mo.target = self;

			missilecount++;
			missiletimeout = 40 + Random(0, 5) * 15;
		}
	}

	override void DoFrontWeapon(Actor origin) {}
}

// Light Panzer
class LightPanzerTreads : TankTreadsBase
{
	Default
	{
		Height 50;
		TankTreadsBase.DebrisActor "Debris_Tank2";
		TankTreadsBase.DeadActor "DestroyedTank4";
		TankTreadsBase.Length 80;
		TankTreadsBase.TurretClass "LightPanzerTurret";
	}

	override void PostBeginPlay()
	{
		Actor fl, fr, bl, br;
		bool sp;

		if (master) { angle = master.angle; }

		while (!fl) { [sp, fl] = A_SpawnItemEx("LightPanzerTire", 64.0, -35.0, 19.0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_SETMASTER); }
		PairedTire(fl).turning = true;
		PairedTire(fl).rotated = 180;

		while (!fr) { [sp, fr] = A_SpawnItemEx("LightPanzerTire", 64.0, 35.0, 19.0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_SETMASTER); }
		PairedTire(fr).turning = true;

		while (!bl) { [sp, bl] = A_SpawnItemEx("LightPanzerTire", -56.0, -35.0, 19.0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_SETMASTER); }
		PairedTire(bl).rotated = 180;

		while (!br) { [sp, br] = A_SpawnItemEx("LightPanzerTire", -56.0, 35.0, 19.0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE | SXF_SETMASTER); }

		Super.PostBeginPlay();
	}
}

class LightPanzerTire : PairedTire {}

class LightPanzerTurret : TankTurretBase
{
	Default
	{
		Height 16;
		TankTurretBase.GunSpotX 60;
		TankTurretBase.GunSpotY 0;
		TankTurretBase.GunSpotZ 16;
	}
}

class SSTank4 : TankBase
{
	Default
	{
		//$Category Monsters (BoA)/Tanks
		//$Title Tank 4 (1000 HP, Light Panzer KFZ 222, Turret only)
		//$Color 4
		Tag "$TAGSDKFZ222";
		Health 1000;
		Height 80;
		Radius 80;
		Speed 2.55555556;
		MaxStepHeight 16;
		TankBase.TankActor "LightPanzerTreads";
		TankBase.TurretSpeed 1.0;
		TankBase.WheeledMovement true;
		TankBase.TurretProjectile "EnemyChaingunTracer";
		TankBase.TurretDelay 2;
	}

	override void DoTurret(Actor origin) {}

	override void DoTurretTarget(Actor origin)
	{
		if (!origin || bullettimeout) { return; }
		origin.target = target; // Just in case

		turrettimeout = -1;

		A_StartSound("weapons/chaingun", CHAN_WEAPON);

		origin.A_Face(target, 0, 0, flags:FAF_MIDDLE);
		origin.angle = turret.angle;

		// Muzzle flash
		Actor muzzleflash = Spawn("KTFlare", origin.Pos, ALLOW_REPLACE);
		muzzleflash.master = origin;
		// Smoke
		origin.A_SpawnProjectile("TurrSmokeSpawner", 0, flags: CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE);
		// Projectile
		Actor mo = origin.A_SpawnProjectile(TurretProjectile, 0, 0, origin.angle + random(-4, 4), CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE, origin.pitch);

		if (mo) { mo.target = self; }

		missilecount++;
		if (missilecount > 45)
		{
			missilecount = 0;
			turrettimeout = 35 * Random(2, 5); // 2-5 seconds between long bursts
			chasetimeout = 35 + 5 * Random(0, 14); // 1-2 seconds between movements - so you can have back-to-back firing sometimes
		}
		else
		{
			turrettimeout = turretdelay; // 2 tics between shots
			chasetimeout = 40;
		}
	}

	override void DoFrontWeapon(Actor origin) {}
}

// T34
class T34Treads : TankTreadsBase
{
	Default
	{
		Height 68;
		Radius 96;
		TankTreadsBase.DeadActor "DestroyedT34Tank";
		TankTreadsBase.DebrisActor "Debris_Tank2";
		TankTreadsBase.Length 140;
		TankTreadsBase.TurretClass "T34Turret";
		TankTreadsBase.GunSpotX 85;
		TankTreadsBase.GunSpotY 24;
		TankTreadsBase.GunSpotZ 52;
	}
}

class T34Turret : TankTurretBase
{
	Default
	{
		TankTurretBase.GunClass "T34Cannon";
		TankTurretBase.GunOffsetX 42;
		TankTurretBase.GunOffsetZ 14;
		TankTurretBase.GunSpotX 230;
		TankTurretBase.GunSpotY 0;
		TankTurretBase.GunSpotZ 8;
	}
}

class T34Cannon : TankCannonBase {}

class T34Tank : TankBase
{
	Default
	{
		//$Category Monsters (BoA)/Tanks
		//$Title T-34 Soviet Standard Tank
		//$Color 4
		Tag "$TAGT34";
		Health 1250;
		Radius 96;
		Height 88;
		Speed 1.7;
		Species "AllyTank";
		MaxTargetRange 2048;
		+FRIENDLY
		TankBase.MinGunPitch -5;
		TankBase.MaxGunPitch 30;
		TankBase.TankActor "T34Treads";
		TankBase.FrontGunProjectile "Kar98kTracer";
	}

	override void DoTurret(Actor origin)
	{
		if (!origin || !Base(origin)) { return; }

		Super.DoTurret(origin);

		Actor muzzleflash = Spawn("NebNukeHarmless", origin.Pos, ALLOW_REPLACE);
		A_StartSound("tanks/85mmziss53", CHAN_WEAPON);
		A_Quake(6, 13, 0, 512);
		//Actor mo = origin.A_SpawnProjectile(TurretProjectile, 0, 0, origin.angle, CMF_ABSOLUTEPITCH | CMF_ABSOLUTEANGLE, origin.pitch);
		Actor mo = Base(origin).A_ArcProjectile(TurretProjectile, 32, 0, origin.angle, CMF_ABSOLUTEANGLE, additionalHeight:-32);
		if (mo)
		{
			muzzleflash.vel += (mo.vel.x / 2.0, mo.vel.y / 2.0, mo.vel.z / 2.0);
			if (self) muzzleflash.vel += self.vel;
			mo.target = self;

			missilecount++;
			if (missilecount > 1)
			{
				missilecount = 0;
				missiletimeout = 35 * Random(3, 5);
			}
			else
			{
				missiletimeout = 40;
			}
		}
	}

	override void DoFrontWeapon(Actor origin)
	{
		if (!origin) { return; }

		Super.DoFrontWeapon(origin);

		A_StartSound("weapons/chaingun", CHAN_WEAPON);

		origin.A_Face(target, 0, 0, flags:FAF_MIDDLE);
		origin.angle = treads.angle;

		// Muzzle flash
		Actor muzzleflash = Spawn("KTFlare", origin.Pos, ALLOW_REPLACE);
		muzzleflash.master = origin;
		// Smoke
		origin.A_SpawnProjectile("TurrSmokeSpawner", 0, flags: CMF_ABSOLUTEPITCH | CMF_ABSOLUTEANGLE);
		// Projectile
		Actor mo = origin.A_SpawnProjectile(FrontGunProjectile, 0, 0, origin.angle + random(-4, 4), CMF_ABSOLUTEPITCH | CMF_ABSOLUTEANGLE, clamp(origin.pitch, -5, 5));

		if (mo)
		{
			mo.SetOrigin(origin.pos + RotateVector((8.0, 0), angle), false);
			mo.target = self;
		}

		bulletcount++;
		if (bulletcount > 75)
		{
			bulletcount = 0;
			bullettimeout = 35 * Random(2, 5); // 2-5 seconds between long bursts
		}
		else
		{
			bullettimeout = 2; // 2 tics between shots
		}
	}
}

class WeaponSpot : ActorPositionable
{
	Default
	{
		Height 2;
		Radius 1;
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+INVISIBLE
	}

	States
	{
		Spawn:
			AMRK A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (master) { Species = master.Species; }

		Super.PostBeginPlay();
	}
}
