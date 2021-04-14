/*
 * Copyright (c) 2018-2020 MajorCooke, AFADoomer
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

// Lots of bits and pieces from D4D's Lightning Gun used originally... Significantly modified by AFADoomer.
// D4D license: https://github.com/MajorCooke/Doom4Doom/blob/master/LICENSE

Class LightningPuff : Actor
{
	Default 
	{
		Radius 0;
		Height 0;
		Projectile;
		+BLOODLESSIMPACT
		+DONTSPLASH
		+NOINTERACTION
		+NOTONAUTOMAP
		RenderStyle "None";
		Decal "RailScorchLower";
		DamageType "Electric";
	}

	States
	{
		Spawn:
			TNT1 A 10;
			Stop;
		Death:
		Crash:
			TNT1 A 1 A_SpawnItemEx("ZScorchLower");
			TNT1 A 10 A_SpawnSparks();
			Stop;
	}

	void A_SpawnSparks()
	{
		if (Random(0, 6)) { return; }

		for (int s = 1; s < Random(2, 5); s++)
		{
			// Spawn random white or yellow sparks
	 		Actor mo = A_SpawnProjectile(String.Format("Spark%c", RandomPick("W", "Y")), -1, 0, Random(-45, 45), CMF_AIMDIRECTION, 270 - pitch + FRandom(-45, 45));
			if (mo) { mo.scale *= FRandom(0.5, 1.0); }
		}
	}
}

Class LightningPuff2 : Actor
{
	Default 
	{
		Radius 0;
		Height 0;
		Projectile;
		+BLOODLESSIMPACT
		+DONTSPLASH
		+NOINTERACTION
		+NOTONAUTOMAP
		+PUFFGETSOWNER
		+PUFFONACTORS
		RenderStyle "None";
	}

	States
	{
		Spawn:
			TNT1 A 20;
			Stop;
		Death:
		Crash:
			TNT1 A 1 A_SpawnItemEx("ZScorchLower");
			Stop;
	}
}

// Base class that spawns the actual beam segments
Class LightningBeam : Actor 
{
	Vector3 AimPoint;

	Actor closest;
	Actor origin;
	Array<Actor> near;
	String trail;
	bool targets;
	double AngleRandom;
	double CurDistance;
	double MaxDistance;
	double MaxScale;
	double MinScale;
	double PitchRandom;
	double StepDistance;
	double faceamt;
	double splitamt;
	double stepfactor;
	int Choke;
	int ChokeMax;
	int ChokeMin;
	int child;

	Property AllowSplit:splitamt;
	Property AngleRandom:AngleRandom;
	Property ChokeMax:ChokeMax;
	Property ChokeMin:ChokeMin;
	Property FaceAmount:faceamt;
	Property MaxDistance:MaxDistance;
	Property MaxScale:MaxScale;
	Property MinScale:MinScale;
	Property PitchRandom:PitchRandom;
	Property StepFactor:stepfactor;
	Property TrailActor:trail;
	Property targets:targets;

	Default 
	{
		+NOBLOCKMAP
		+NOINTERACTION
		+INTERPOLATEANGLES
		RenderStyle "None";
		ActiveSound "electrical/shock";

		LightningBeam.AngleRandom 5;
		LightningBeam.ChokeMax 3;
		LightningBeam.ChokeMin 1;
		LightningBeam.FaceAmount 5;
		LightningBeam.MaxDistance 256;
		LightningBeam.MaxScale 0.03;
		LightningBeam.MinScale 0.0125;
		LightningBeam.PitchRandom 5;
		LightningBeam.StepFactor 1;
		LightningBeam.TrailActor "LightningTrailBeamZap";

		Obituary "$ELECTROCUTION";
	}

	States
	{
		Spawn:
			TNT1 A 1 NODELAY A_SpawnBeam();
			Stop;
	}

	override void PostBeginPlay()
	{
		if (master) { origin = master; }
		else { origin = self; }

		Choke = random(ChokeMin, ChokeMax);

		StepDistance = Random[steps](5, 7) * stepfactor;

		if (Scale.X == 1.0) { Scale.X = MaxScale; }

		Scale.Y = StepDistance;

		FLineTraceData trace;

		if (AimPoint == (0, 0, 0))
		{
			origin.LineTrace(origin.angle, MaxDistance, origin.pitch, TRF_THRUHITSCAN | TRF_THRUACTORS, origin.height, 0.0, 0.0, trace);
			AimPoint = trace.HitLocation;
		}

		tracer = GetLineTarget(origin, int(MaxDistance));

		if (!tracer) { tracer = Spawn("TargetActor", AimPoint); }

		Super.PostBeginPlay();
	}

	Actor GetLineTarget(Actor origin, int range = 2560)
	{
		CrosshairTracer actortrace;
		actortrace = new("CrosshairTracer");

		actortrace.skipactor = origin;
		Vector3 tracedir = ZScriptTools.GetTraceDirection(origin.Angle, origin.Pitch);
		actortrace.Trace(origin.pos + (0, 0, origin.height / 2), origin.CurSector, tracedir, range, 0);

		return actortrace.Results.HitActor;
	}

	void A_SpawnBeam()
	{
		// Due to how lightning damage is handled, even though the beam is drawn right next to the spawning 
		//  actor, it doesn't do damage within 4 * Radius distance from the spawning actor.  This call below 
		//  makes sure that damage of the correct amount and type still occurs inside of that radius...
		Class<MovingTrailBeam> trailclass = trail;
		let def = GetDefaultByType(trailclass);
		if (!def) { return; }

		if (master && master.radius && def.damage) { master.A_CustomBulletAttack(angle - master.angle, 0, 1, def ? int(def.Damage) : Random(0, 1), MovingTrailBeam(def) ? MovingTrailBeam(def).puff : "LightningPuff", master.radius * 4, CBAF_AIMFACING | CBAF_EXPLICITANGLE); }

		Actor prev;

		A_StartSound(ActiveSound, CHAN_AUTO, CHANF_NOSTOP, 0.5, ATTN_STATIC);

		While (CurDistance < MaxDistance - StepDistance)
		{
			if (CurDistance > 0 && !level.IsPointInLevel(pos)) { return; }

			bool spawned;
			Actor t;

			if (!closest || level.time % 15 == 0) // Only run this every fifteen tics, or on first iteration
			{
				closest = ClosestMonster(self, int(MaxDistance - CurDistance), null, near);
				if (closest && targets) { tracer = closest; }
			}

			A_FaceTracer(faceamt, 0, 0, 0, FAF_MIDDLE);

			Scale.X = MinScale + (MaxDistance - CurDistance) * (MaxScale - MinScale) / MaxDistance;

			if (
				(
					!master || !(master is "PlayerPawn") ||
					CurDistance > Min(32, MaxDistance / 4)
				) &&
				CurDistance < (MaxDistance - StepDistance)
			)
			{
				// D4D Code
				// If we're not about to reach the end, or not hitting the 
				// Choker, randomize it. Otherwise, stay on target and go 
				// for the puff.
				if (Choke > 0)
				{
					pitch = pitch + FRandom[pitch](0, PitchRandom) * RandomPick[pitchdir](-1, 1);
					angle = angle + FRandom[angle](0, AngleRandom) * RandomPick[angledir](-1, 1);

					Choke = max(0, Choke -1);
				}
				else if (CurDistance < (MaxDistance - StepDistance * 3))
				{
					Choke = Random(ChokeMin, ChokeMax);
				}

				// Spawn a split from the main beam
				if (splitamt > 0 && scale.x > 0.001 && Random[split]() < 10 * splitamt * (child + 1) && child < ChokeMax + 2)
				{
					t = Spawn(GetClass(), pos + (RotateVector((cos(pitch), 0), angle), -sin(pitch)));
					if (t) {
						t.master = master;
						t.pitch = FRandom(pitch - PitchRandom, pitch + PitchRandom);
						t.angle = FRandom(angle - AngleRandom, angle + AngleRandom);
						t.tracer = tracer;
						LightningBeam(t).AimPoint = AimPoint;
						LightningBeam(t).MaxDistance = 32;
						LightningBeam(t).child = child + 1;
						LightningBeam(t).StepFactor = stepfactor;
						LightningBeam(t).StepDistance = stepdistance;
						LightningBeam(t).MaxScale = scale.x;
						LightningBeam(t).closest = closest;
						t.scale.x = scale.x / (child + 1);
						t.target = target;
					}
				}
			}

			// Spawn call here was originally D4D Code using A_SpawnItemEx
			// Spawn the beam with the same angle and pitch. Note that the
			// beam is being centered so we have to take that into account
			// and spawn it FORWARD based on half the beam's length.
			// Then move forward by a beam's length and repeat until done.
			t = Spawn(trail, pos + (RotateVector((cos(-pitch) * StepDistance / 2.0, 0), angle), sin(-pitch) * StepDistance / 2.0));
			if (t)
			{
				if (t.waterlevel > 0)
				{
					if (pitch != 0)
					{
						t.Destroy(); // Destroy this one and spawn a new one with flat pitch, so it goes along the surface of the water

						pitch = 0;
						PitchRandom = 0;
						AngleRandom = 45;

						t = Spawn(trail, pos + (RotateVector((StepDistance / 2.0, 0), angle), 0));
					}

					if (t) { ElectrifySector(t.CurSector, t.Damage); }
				}

				t.master = master;
				t.angle = angle;
				t.pitch = pitch + 90;
				t.scale = scale;
				t.target = target;
				t.tracer = tracer;
			}

			SetXYZ(pos + (RotateVector((cos(-pitch) * StepDistance, 0), angle), sin(-pitch) * StepDistance));

			if (master && master is "PlayerPawn" && tracer)
			{
				if (Distance2D(tracer) <= tracer.radius && pos.z < tracer.pos.z + tracer.height && pos.z > tracer.pos.z)
				{
					SetXYZ((tracer.pos.xy, pos.z) + (RotateVector((cos(-pitch) * StepDistance / 2, 0), angle), sin(-pitch) * StepDistance / 2));

					if (near.Size())
					{
						int i = near.Size();
						Actor current = tracer;
						tracer = null;

						while (!tracer && i > 0)
						{
							tracer = near[--i];
							closest = tracer;

							if (tracer == current || tracer.player) { tracer = null; }

							near.Delete(i);
							near.ShrinkToFit();
						}

						if (i == 0) { MaxDistance = CurDistance; }
					}

					if (tracer) { angle = AngleTo(tracer); }
				}
			}

			prev = t;

			CurDistance += StepDistance;
		}
	}

	void ElectrifySector(Sector cur, int damage = -1)
	{
		for (Actor mo = cur.thinglist; mo != null; mo = mo.snext)
		{
			if (mo.waterlevel > 0 && mo.bShootable) { mo.DamageMobj(self, self, damage > 0 ? damage : Random(0, 2), "Electric"); }
		}
	}

	static Actor ClosestMonster(Actor spawner, int range = 256, Actor origin = null, out Array<Actor> near = null)
	{
		Actor mo, closest;

		if (!origin) { origin = spawner; }

		if (spawner is "MovingTrailBeam" || (spawner.master && (spawner.master is "PlayerPawn" || spawner.master.bFriendly == true)))
		{
			BlockThingsIterator it = BlockThingsIterator.Create(origin, range);

			while (it.Next())
			{
				mo = it.thing;

				if (mo == spawner || !mo.bShootable || !mo.bIsMonster || mo.bDormant || mo.health <= 0 || mo == origin || spawner.IsFriend(mo)) { continue; } // Magical lightning that doesn't seek out your allies
				if (spawner is "LightningBeam")
				{
					if (mo == LightningBeam(spawner).origin) { continue; }
					if (!LightningBeam(spawner).origin.IsVisible(mo, true)) { continue; }
				}
				if (origin.Distance3d(mo) > range) { continue; }

				if (near) { near.Push(mo); }

				if (closest && origin.Distance3d(mo) > origin.Distance3d(closest)) { continue; }

				closest = mo;
			}
		}
		else
		{
			for (int p = 0; p < MAXPLAYERS; p++)	
			{ // Iterate through all of the players and find the closest one
				mo = players[p].mo;

				if (mo)
				{
					if (!mo.bShootable || mo.health <= 0) { continue; }
					if (players[p].cheats & CF_NOTARGET) { continue; }
					if (closest && origin.Distance3d(mo) > origin.Distance3d(closest)) { continue; }

					closest = mo;
				}
			}
		}

		return closest;
	}

	override void Tick()
	{
		if (master) { vel = master.vel; }

		Super.Tick();
	}
}

Class LightningBeam2 : LightningBeam
{
	override void PostBeginPlay()
	{
		if (master)
		{
			origin = master;
		}

		Choke = random(ChokeMin, ChokeMax);

		StepDistance = Random[steps](1, 2) * stepfactor;

		if (Scale.X == 1.0) { Scale.X = MaxScale; }

		Scale.Y = StepDistance;

		if (AimPoint == (0, 0, 0))
		{
			FLineTraceData trace;
			LineTrace(angle, MaxDistance, pitch, TRF_THRUHITSCAN | TRF_THRUACTORS, 0.0, 0.0, 0.0, trace);

			AimPoint = trace.HitLocation;
		}

		tracer = Spawn("TargetActor2", AimPoint);

		Super.PostBeginPlay();
	}
}

Class LightningBeamZap : LightningBeam
{
	Default
	{
		LightningBeam.AllowSplit 1.5;
		LightningBeam.AngleRandom 10;
		LightningBeam.MaxScale 0.15;
		LightningBeam.MinScale 0.025;
		LightningBeam.PitchRandom 8;
		LightningBeam.StepFactor 4.5;
		LightningBeam.Targets True;
		LightningBeam.TrailActor "LightningTrailBeamZap";
	}
}

Class LightningBeamZap2 : LightningBeamZap
{
	Default
	{
		LightningBeam.MaxDistance 640;
	}
}

Class LightningBeamZapH : LightningBeamZap
{
	Default
	{
		LightningBeam.MaxScale 2.10;
		LightningBeam.MinScale 1.10;
		LightningBeam.MaxDistance 384;
	}
}

Class LightningBeamZapP : LightningBeam
{
	Default
	{
		LightningBeam.AllowSplit 1.5;
		LightningBeam.AngleRandom 10;
		LightningBeam.MaxScale 0.15;
		LightningBeam.MinScale 0.025;
		LightningBeam.PitchRandom 8;
		LightningBeam.StepFactor 4.5;
		LightningBeam.Targets True;
		LightningBeam.TrailActor "LightningTrailBeamZapP";
	}
}

Class LightningBeamZapPH : LightningBeamZapP
{
	Default
	{
		LightningBeam.MaxScale 2.10;
		LightningBeam.MinScale 1.10;
		LightningBeam.MaxDistance 384;
	}
}

Class LightningBeamPillarZap : LightningBeam
{
	Default 
	{
		LightningBeam.AllowSplit 0.5;
		LightningBeam.AngleRandom 15;
		LightningBeam.ChokeMax 5;
		LightningBeam.ChokeMin 5;
		LightningBeam.FaceAmount 0;
		LightningBeam.MaxScale 0.10;
		LightningBeam.MinScale 0.025;
		LightningBeam.PitchRandom 15;
		LightningBeam.StepFactor 1.5;
		LightningBeam.TrailActor "LightningTrailBeamZap";
	}
}

Class LightningBeamPillarZap2 : LightningBeamPillarZap
{
	Default 
	{
		LightningBeam.MaxDistance 640;
		LightningBeam.TrailActor "LightningTrailBeamZapP";
	}
}

Class LightningBeamPillarZapH : LightningBeamPillarZap
{
	Default 
	{
		LightningBeam.MaxScale 2.10;
		LightningBeam.MinScale 1.10;
		LightningBeam.MaxDistance 384;
		LightningBeam.TrailActor "LightningTrailBeamZap";
	}
}

Class LightningBeamPillarZapPH : LightningBeamPillarZap2
{
	Default 
	{
		LightningBeam.MaxScale 2.10;
		LightningBeam.MinScale 1.10;
		LightningBeam.MaxDistance 384;
	}
}

Class LightningBeamPri : LightningBeam
{
	Default 
	{
		LightningBeam.AngleRandom 4;
		LightningBeam.ChokeMax 3;
		LightningBeam.ChokeMin 2;
		LightningBeam.MaxDistance 512;
		LightningBeam.MaxScale 0.15;
		LightningBeam.MinScale 0.025;
		LightningBeam.PitchRandom 4;
		LightningBeam.StepFactor 2.5;
		LightningBeam.TrailActor "LightningTrailBeam";
	}
}

Class LightningBeamPri2 : LightningBeam2
{
	Default 
	{
		LightningBeam.AngleRandom 4;
		LightningBeam.ChokeMax 3;
		LightningBeam.ChokeMin 2;
		LightningBeam.MaxDistance 1280;
		LightningBeam.MaxScale 0.15;
		LightningBeam.MinScale 0.025;
		LightningBeam.PitchRandom 4;
		LightningBeam.StepFactor 2.5;
		LightningBeam.TrailActor "LightningTrailBeam2";
	}
}

Class LightningBeamAlt : LightningBeam
{
	Default 
	{
		LightningBeam.AllowSplit 1.5;
		LightningBeam.AngleRandom 20;
		LightningBeam.ChokeMax 4;
		LightningBeam.ChokeMin 2;
		LightningBeam.FaceAmount 10;
		LightningBeam.MaxScale 0.15;
		LightningBeam.MinScale 0.025;
		LightningBeam.PitchRandom 15;
		LightningBeam.StepFactor 4.5;
		LightningBeam.Targets True;
		LightningBeam.TrailActor "LightningTrailBeamAlt";
	}
}

Class LightningBeamAlt2 : LightningBeamAlt
{
	States
	{
		Spawn:
			TNT1 A 1 NODELAY { A_SpawnBeam(); A_RadiusThrust(1500, 128); }
			Stop;
	}
}

Class LightningBeamArc : LightningBeamPri
{
	Default 
	{
		LightningBeam.FaceAmount 15;
		LightningBeam.TrailActor "LightningTrailBeamArc";
	}
}

Class LightningBeamArc2 : LightningBeamPri2
{
	Default 
	{
		LightningBeam.FaceAmount 15;
		LightningBeam.TrailActor "LightningTrailBeamArc2";
		LightningBeam.Targets False;
		LightningBeam.StepFactor 10;
	}
}

Class LightningBeamPillar : LightningBeam
{
	Default 
	{
		LightningBeam.AllowSplit 0.5;
		LightningBeam.AngleRandom 15;
		LightningBeam.ChokeMax 5;
		LightningBeam.ChokeMin 5;
		LightningBeam.FaceAmount 0;
		LightningBeam.MaxScale 0.10;
		LightningBeam.MinScale 0.025;
		LightningBeam.PitchRandom 15;
		LightningBeam.StepFactor 1.5;
		LightningBeam.TrailActor "LightningTrailBeamArc";
	}
}

Class LightningBeamPillar2 : LightningBeamPillar
{
	Default 
	{
		LightningBeam.TrailActor "LightningTrailBeamArc2";
	}
}

// Base class for the beam segments
Class MovingTrailBeam : Actor 
{
	String puff;
	Vector3 beamoffset;
	double damage;

	Property Damage:damage;
	Property PuffActor:puff;

	Default
	{
		Height 1;
		Radius 0;
		+NOINTERACTION
		RenderStyle "Add";
		MovingTrailBeam.Damage 0;
		MovingTrailBeam.PuffActor "LightningPuff";
	}

	States
	{
		Spawn:
			MDLA A 0 A_Jump(8,"Fade.Light");
		Fade:
			MDLA A 1 A_FadeOut(0.2);
			Goto Spawn;
		Fade.Light:
			MDLA A 1 Light("Lightning") A_FadeOut(0.2);
			Goto Spawn;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (master)
		{ 
			if (damage > 0 && Distance3D(master) > master.radius * 4)
			{
				int dmg = int(damage);

				if (damage != dmg)
				{
					// If we passed a double in for damage amount, fudge the actual damage to get closer to that number on average
					int part = int((damage - dmg) * 100);
					dmg = dmg + !!(Random(0, 100) < part);
				}

				// Used to make all individual bolt segments leave decals and cause damage
				LineAttack(angle, scale.y, pitch - 90, dmg, "Electric", puff, 0, null, -8.5);
			}

			beamoffset = pos - master.pos;
		}

		if (pos.z < floorz) { Destroy(); }
	}

	override void Tick()
	{
		Super.Tick();

		if (globalfreeze || level.Frozen) { return; }

		if (master && master is "PlayerPawn")
		{ 
			SetXYZ(master.pos + beamoffset);
		}
	}

}

Class FakeMovingTrailBeam : MovingTrailBeam
{
	Default
	{
		MovingTrailBeam.PuffActor "LightningPuff2";
	}

	States
	{
		Spawn:
			TNT1 A 0 A_Jump(16,"Fade.Light");
		Fade:
			MDLA A 1 A_FadeOut(0.2);
			Goto Spawn;
		Fade.Light:
			MDLA A 1 Light("GLightning") A_FadeOut(0.2);
			Goto Spawn;
	}
}

Class LightningTrailBeamZap : MovingTrailBeam
{
	Default
	{
		MovingTrailBeam.Damage 1;
	}
}

Class LightningTrailBeamZapP : MovingTrailBeam
{
	Default
	{
		MovingTrailBeam.Damage 1;
	}
}

Class LightningTrailBeam : MovingTrailBeam
{
	Default
	{
		MovingTrailBeam.Damage 4;
	}
}

Class LightningTrailBeamAlt : MovingTrailBeam
{
	Default
	{
		MovingTrailBeam.Damage 4;
	}
}

Class LightningTrailBeamArc : MovingTrailBeam
{
	Default
	{
		MovingTrailBeam.Damage 50;
	}
}

Class LightningTrailBeam2 : FakeMovingTrailBeam
{
	Default
	{
		MovingTrailBeam.Damage 0;
	}
}

Class LightningTrailBeamArc2 : FakeMovingTrailBeam
{
	Default
	{
		MovingTrailBeam.Damage 0;
	}
}

Class TargetActor : Actor
{
	Vector3 offset;

	Default
	{
		Height 0;
		Radius 0;
		+NOINTERACTION;
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (master) { offset = pos - master.pos; }

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (master)
		{
			SetXYZ(master.pos + offset);
		}

		Super.Tick();
	}
}

Class TargetActor2 : Actor
{
	Default
	{
		Height 0;
		Radius 0;
		+NOINTERACTION;
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Stop;
	}
}