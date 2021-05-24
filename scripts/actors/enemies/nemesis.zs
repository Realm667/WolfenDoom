/*
 * Copyright (c) 2020 Talon1024
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

class SpotFinderTracer : LineTracer
{
	// Set by the callback
	bool hitWall;

	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling)
		{
			hitWall = true;
			return TRACE_Stop;
		}
		else if (Results.HitType == TRACE_HitWall)
		{
			// Walls need further examination
			if (Results.Tier != TIER_Middle)
			{
				hitWall = true;
				return TRACE_Stop;
			}
			else
			{
				if (!(Results.HitLine.flags & Line.ML_TWOSIDED))
				{
					// Not a two-sided wall
					hitWall = true;
					return TRACE_Stop;
				}
				else
				{
					// Two-sided wall
					if (Results.HitLine.flags & Line.ML_BLOCKING ||
						Results.HitLine.flags & Line.ML_BLOCKMONSTERS ||
						Results.HitLine.flags & Line.ML_BLOCK_PLAYERS ||
						Results.HitLine.flags & Line.ML_BLOCKEVERYTHING)
					{
						hitWall = true;
						return TRACE_Stop;
					}
				}
			}
		}
		return TRACE_Skip;
	}
}

// Base class for missiles that travel on the floor
class GroundedMissile : GrenadeBase
{
	Default
	{
		Health 1;
		Projectile;
		-NOGRAVITY
		+NOEXPLODEFLOOR
		+STEPMISSILE
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (!MaxStepHeight)
		{
			MaxStepHeight = Speed;
		}
	}

	override void Tick()
	{
		Super.Tick();
		if (health <= 0) return;
		double floorz = CurSector.NextLowestFloorAt(Pos.X, Pos.Y, Pos.Z, steph: MaxStepHeight);
		double minz = floorz + MaxStepHeight;
		if (Pos.Z <= minz)
		{
			Vel.Z = 0;
			AddZ(minz - Pos.Z);
			Vel.XY = AngleToVector(Angle, Speed);
		}
	}
}

class NemesisControl : Thinker
{
	bool canDie;
	bool sleeping;
	bool canTeleport;
	private bool revive;

	static NemesisControl Get()
	{
		ThinkerIterator it = ThinkerIterator.Create("NemesisControl");
		NemesisControl control = NemesisControl(it.Next());
		if (control)
		{
			return control;
		}
		return new("NemesisControl");
	}

	// int killable = ScriptCall("NemesisControl", "IsKillable");
	static bool IsKillable()
	{
		NemesisControl control = NemesisControl.Get();
		return control.canDie;
	}

	// int asleep = ScriptCall("NemesisControl", "IsAsleep");
	static bool IsAsleep()
	{
		NemesisControl control = NemesisControl.Get();
		return control.sleeping;
	}

	// ScriptCall("NemesisControl", "SetKillable", 1);
	// or
	// ScriptCall("NemesisControl", "SetKillable", 0);
	static void SetKillable(bool canDie)
	{
		NemesisControl control = NemesisControl.Get();
		control.canDie = canDie;
	}

	// ScriptCall("NemesisControl", "SetAsleep", 1);
	// or
	// ScriptCall("NemesisControl", "SetAsleep", 0);
	static void SetAsleep(bool sleeping)
	{
		NemesisControl control = NemesisControl.Get();
		control.sleeping = sleeping;
	}

	// ScriptCall("NemesisControl", "ForceResurrect");
	// NOTE: Do this to make him "killable for good":
	// ScriptCall("NemesisControl", "SetKillable", 1);
	static void ForceResurrect()
	{
		NemesisControl control = NemesisControl.Get();
		control.sleeping = false;
		control.revive = true;
	}

	override void Tick()
	{
		Super.Tick();
		if (revive)
		{
			ThinkerIterator iter = ThinkerIterator.Create("RENemesis");
			RENemesis nemesis = RENemesis(iter.Next());
			if (nemesis)
			{
				State DeathState = nemesis.FindState("Death");
				if (nemesis.InStateSequence(nemesis.CurState, DeathState))
				{
					if (nemesis.A_ReviveStart())
					{
						revive = false;
					}
				}
			}
			else
			{
				revive = false;
			}
		}
	}
}

class NemesisZyklonBall : GroundedMissile
{
	Default
	{
		DamageType "UndeadPoison";
		DamageFunction (40);
		Radius 24;
		Height 16;
		Speed 10;
		Gravity .25;
		MaxStepHeight 16;
		Scale .25;
		+BRIGHT
		+ROLLSPRITE
	}

	States
	{
	Spawn:
		ZBAL AAAAAA 1 LIGHT("ZYKFLMW2") A_SetRoll(Roll + 5, SPF_INTERPOLATE);
		ZBAL A 0 A_SpawnZClouds;
		Loop;
	Death:
		ZBLX A 2 LIGHT("ZYKFLMW2") A_Explode(random(16,24), 128, 0, fulldamagedistance: 64);
		ZBLX BCDEFGHIJK 2 LIGHT("ZYKFLMW2");
		Stop;
	}

	void A_SpawnZClouds(int cloudsPerSide = 1, float cloudSeparation = 24)
	{
		A_SpawnProjectile("ZyklonZCloud", 0, flags: CMF_TRACKOWNER);
		for (int i = 1; i <= cloudsPerSide; i++)
		{
			A_SpawnProjectile("ZyklonZCloud", 0, cloudSeparation * i, 90, CMF_TRACKOWNER);
			A_SpawnProjectile("ZyklonZCloud", 0, cloudSeparation * i, -90, CMF_TRACKOWNER);
		}
	}
}

class RENemesis : NaziBoss
{
	NemesisControl control;

	Default
	{
		Activation THINGSPEC_NoDeathSpecial; // Will be disabled when "killed for good"
		DamageFactor "UndeadPoison", 0;
		DamageFactor "UndeadPoisonAmbience", 0;
		DeathSound "nemesis/death";
		Health 1600;
		PainChance 16;
		Radius 48;
		MeleeRange 56;
		SeeSound "nemesis/sight";
		Speed 5;
		Tag "$TAGNEMESIS";
		DefThreshold 64;
		Base.BossIcon "BOSSICO2";
		Nazi.TotaleGierDrop 0;
		BloodColor "00 A0 7D";
		BloodType "ZombieBlood";
		+JUMPDOWN
	}

	States
	{
	Spawn:
		NEMS A 0 NoDelay {user_incombat = 1;}
		Goto Look;
	See:
		"####" "#" 0 {
			if (target && Distance2D(target) > 768)
			{
				return ResolveState("TeleportStart");
			}
			return ResolveState(null);
		}
		Goto See.Boss;
	Missile:
		NEMS A 0 A_Jump(100, "Missile2");
		NEMS FG 10;
		NEMS G 10 A_ArcProjectile("ZombieVomit", additionalHeight: 32);
		Goto See;
	Missile2:
		NEMS FG 10;
		NEMS G 10 A_SpawnProjectile("NemesisZyklonBall");
		Goto See;
	Melee:
		NEMS A 3;
		NEMS H 4 A_StartSound("nemesis/swing", CHAN_WEAPON);
		NEMS I 12 A_CustomMeleeAttack(random(20,30), "nemesis/melee");
		NEMS A 3 A_JumpIfTargetOutsideMeleeRange("See");
		NEMS J 4 A_StartSound("nemesis/swing", CHAN_WEAPON);
		NEMS K 12 A_CustomMeleeAttack(random(20,30), "nemesis/melee");
		Goto See;
	Pain:
		NEMS L 10;
		Goto See;
	Death: // Kneel after taking some damage
		NEMS O 0 {
			ACS_NamedExecute("City_Light_On", 0);
			if (control.canDie)
			{
				return ResolveState("DeathForReal");
			}
			return ResolveState(null);
		}
		NEMS M 8 A_NoBlocking(false);
		// Kneel for 4 minutes = 60 seconds * 35 tics per second = 8400 tics
		// 8400 tics - 3 seconds = 8400 - 105 = 8295 tics
		// 3 seconds (105 tics) is easier to test with
		NEMS N 8295 CanRaise;
	Sleep:
		"####" "#" 35 CanRaise A_JumpIf(!control.sleeping, 1);
		Wait;
		"####" "#" 104; // Wait for 3 seconds before reviving
		"####" "#" 1 A_JumpIf(control.sleeping, "Sleep");
		"####" "#" -1 A_ReviveStart;
		Stop;
	DeathForReal: // Die permanently, and do not reappear.
		NEMS O 8 A_Scream;
		NEMS P 8;
		NEMS Q 8 A_NoBlocking;
		NEMS R 8;
		NEMS S -1;
		Stop;
	Raise:
		NEMS N 8 {
			A_StartSound(SeeSound, CHAN_VOICE, attenuation: 0);
			ACS_NamedExecute("City_Light_Off", 0);
			A_RearrangePointers(AAPTR_TRACER); // Fetch target from "tracer" pointer.
		}
		NEMS M 8;
		Goto See;
	TeleportStart:
		NEMS A 0 { // Set frame you see while disappearing
			bNoPain = true;
			bSolid = false;
			bShootable = false;
		}
		"####" "#" 1 A_FadeOutJump(0.125, 1);
		Wait;
		"####" "#" 70 A_TeleportCloseTo(180, 384, "Reappear");
		Wait;
	Reappear:
		"####" "#" 0 A_StartSound("JUMPSCARE", attenuation: 0);
		"####" "#" 1 A_FadeInJump(0.125, 1);
		Wait;
		"####" "#" 0 {
			bSolid = true;
			bShootable = true;
			bNoPain = false;
		}
		Goto See;
	}

	override void BeginPlay()
	{
		// Get pointer to Nemesis controller thinker
		control = NemesisControl.Get();
		Super.BeginPlay();
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		if (control.canDie)
		{
			// If Nemesis can die permanently, allow death special activation
			activationtype &= ~THINGSPEC_NoDeathSpecial;
		}
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
		if (target == self)
		{
			target = null;
		}
	}

	override bool OkayToSwitchTarget(Actor other)
	{
		if (other.Species == "Zombie")
		{
			return false;
		}
		return Super.OkayToSwitchTarget(other);
	}

	bool A_ReviveStart()
	{
		// Keep previous target in "tracer" pointer to prevent it from
		// being lost, since actors lose their targets (and the lastEnemy)
		// when they are resurrected.
		A_RearrangePointers(AAPTR_NULL, newtracer: AAPTR_TARGET);
		return A_RaiseSelf(RF_NOCHECKPOSITION);
	}

	void A_FadeOutJump(double fadeAmount, statelabel label, int flags = FTF_CLAMP)
	{
		A_FadeOut(fadeAmount, flags);
		if (Alpha <= 0.0)
		{
			SetStateLabel(label);
		}
	}

	void A_FadeInJump(double fadeAmount, statelabel label, int flags = FTF_CLAMP)
	{
		A_FadeIn(fadeAmount, flags);
		if (Alpha >= 1.0)
		{
			SetStateLabel(label);
		}
	}

	// Checks whether the given angle is suitable for teleporting to. Returns
	// the distance at the given angle which is suitable, or -1 if it is not
	// suitable.
	double isAngleSuitable(double angle, double maxdistance, double checkIncrement = 16, double heightThreshold = 128, double mindistance = 128)
	{
		double suitableDistance = -1;
		// Find closest wall
		SpotFinderTracer finder = new("SpotFinderTracer");
		Vector3 traceDirection = (AngleToVector(angle), 0);
		Vector3 traceOrigin = target.Pos;
		traceOrigin.Z += target.MaxStepHeight;
		finder.Trace(traceOrigin, target.CurSector, traceDirection, maxdistance, 0);
		// There is a wall blocking this angle!
		if (finder.hitWall)
		{
			maxdistance = finder.Results.Distance;
		}
		// Some setup
		Vector3 oldPosition = Pos;
		Sector targSec = Level.PointInSector(target.Pos.XY);
		double targFloorHeight = targSec.NextLowestFloorAt(target.Pos.X, target.Pos.Y, target.Pos.Z, 0, MaxStepHeight);
		// Check for a suitable spot to reappear at. Start at the furthest
		// point, and close in to the target's position.
		for (
			double checkDistance = maxdistance;
			checkDistance > mindistance;
			checkDistance -= checkIncrement
		){
			Vector3 checkSpot = target.Vec3Angle(checkDistance, angle);
			Sector sec = Level.PointInSector(checkSpot.XY);
			if (sec.GetUDMFInt("user_blocknemesis"))
			{ // Don't teleport into sectors marked with "user_blocknemesis"
				continue;
			}
			// Ensure Nemesis doesn't teleport into midair
			double closestFloorHeight = sec.NextLowestFloorAt(checkSpot.X, checkSpot.Y, checkSpot.Z, 0, MaxStepHeight);
			if ((targFloorHeight - closestFloorHeight) > MaxDropoffHeight)
			{
				continue;
			}
			// Ensure Nemesis doesn't get stuck on a wall or ledge
			BlockLinesIterator iter = BlockLinesIterator.CreateFromPos(checkSpot, MaxDropoffHeight, Radius + Speed, sec);
			bool stuck = false;
			double lowestFloor = 99999999;
			double highestFloor = -99999999;
			while (iter.Next())
			{
				if (!(iter.CurLine.flags & Line.ML_TWOSIDED))
				{
					stuck = true;
					break;
				}
				Sector frontsec = iter.CurLine.sidedef[0].sector;
				Sector backsec = iter.CurLine.sidedef[1].sector;
				double frontFloorHeight = frontsec.NextLowestFloorAt(checkSpot.X, checkSpot.Y, checkSpot.Z + MaxStepHeight, steph: MaxStepHeight);
				double frontCeilHeight = frontsec.NextHighestCeilingAt(checkSpot.X, checkSpot.Y, checkSpot.Z, checkSpot.Z + Height);
				double backFloorHeight = backsec.NextLowestFloorAt(checkSpot.X, checkSpot.Y, checkSpot.Z, steph: MaxStepHeight);
				double backCeilHeight = backsec.NextHighestCeilingAt(checkSpot.X, checkSpot.Y, checkSpot.Z, checkSpot.Z + Height);
				if (frontCeilHeight - frontFloorHeight < Height || backCeilHeight - backFloorHeight < Height)
				{ // Ensure a 3D floor isn't blocking Nemesis
					stuck = true;
					break;
				}
				lowestFloor = min(lowestFloor, frontFloorHeight, backFloorHeight);
				highestFloor = max(highestFloor, frontFloorHeight, backFloorHeight);
			}
			if (stuck || (highestFloor - lowestFloor) > MaxStepHeight)
			{
				continue;
			}
			SetOrigin(checkSpot, false);
			// (Hopefully) Ensure Nemesis can move
			if (!CheckMove(Vec2Angle(Speed, AngleTo(target))))
			{
				continue;
			}
			// Ensure Nemesis doesn't get stuck on another actor or prop
			// (I think that's what TestMobjLocation does... It doesn't seem
			// to have prevented Nemesis from getting stuck on a ledge.)
			if (TestMobjLocation())
			{
				suitableDistance = checkDistance;
				break;
			}
		}
		SetOrigin(oldPosition, false);
		return suitableDistance;
	}

	State A_TeleportCloseTo(double preferredAngle = 180, double maxdistance = 384, StateLabel toJumpTo = null)
	{
		State appearState = ResolveState(toJumpTo);
		if (!target) {return appearState;}
		preferredAngle = target.Angle + preferredAngle;
		double suitableDistance = -1;
		double traceAngle = 0;
		// Check every angle around target for a good position
		for (double angleOffset = 0; angleOffset < 180; angleOffset += 22.5)
		{
			traceAngle = preferredAngle + angleOffset;
			suitableDistance = isAngleSuitable(traceAngle, maxdistance);
			if (suitableDistance > -1)
			{
				break;
			}
			// Check in the other direction
			traceAngle = preferredAngle - angleOffset;
			suitableDistance = isAngleSuitable(traceAngle, maxdistance);
			if (suitableDistance > -1)
			{
				break;
			}
		}
		// Console.Printf("suitableDistance: %.3f", suitableDistance);
		if (suitableDistance == -1)
		{
			return null;
		}
		SetOrigin(target.Vec3Angle(suitableDistance, traceAngle), false);
		return appearState;
	}
}
