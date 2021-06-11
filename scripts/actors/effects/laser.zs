// AFADoomer ZScript laser implementation, with some modifications to match DECORATE of Kodi's Lazerbeam, as reworked by Ozymandias81
// This code was originally based on a direct conversion of Kodi's original code to ZScript, but has evolved significantly.
// The major difference is that this code only spawns the beam actor and the flare once, then moves/scales them as necessary

// Emitter actors (Placed in map)
class LaserShooter : EffectSpawner
{
	static const string beamclasses[] = { "LaserBeamRed", "LaserBeamPurple", "LaserBeamGreen" };

	LaserFindHitPointTracer HitPointTracer;
	LaserBeam beam;
	Actor flare;
	Class<Actor> beamclass, puffclass, flareclass;
	int beamdistance;

	Property BeamClass:beamclass;
	Property PuffClass:puffclass;
	Property FlareClass:flareclass;
	Property BeamDistance:beamdistance;

	Default
	{
		//$Category Hazards (BoA)
		//$Title Laserbeam Shooter (switchable, 3 colors, 4 args)
		//$Color 3
		//$Sprite UNKNA0
		//$Arg0 "Color"
		//$Arg0Type 11
		//$Arg0Enum { 0 = "Red"; 1 = "Purple"; 2 = "Green"; }
		//$Arg1 "Rotation Speed"
		//$Arg2 "Distance (x256)"
		//$Arg3 "Sound"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Yes"; 1 = "No"; }
		Radius 0;
		Height 0;
		Damage 30;
		DamageType "Laser";
		+NOGRAVITY
		+EffectSpawner.DONTCULL
		LaserShooter.FlareClass "BigLaserFlare";
	}

	States
	{
		Spawn:
			TNT1 A 1;
		Active:
			TNT1 A 1 A_FireLaser(damage);
			Loop;
		Inactive:
			TNT1 A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		hitpointtracer = new("LaserFindHitPointTracer");

		if (!beamclass) { beamclass = beamclasses[min(2, args[0])]; }

		if (!beamdistance)
		{
			if (!args[2]) { beamdistance = 2048; } // Default to 2048 units long
			else { beamdistance = 256 * args[2]; }
		}

		range = max(range, beamdistance + 512);

		if (bDormant || SpawnFlags & MTF_DORMANT) { Deactivate(null); }
		else { Activate(null); }
	}

	virtual void A_FireLaser(int damage, sound snd = "", double zoffset = 0, bool drawdecal = false, double alpha = 1.0, double volume = 1.0)
	{
		if (args[1]) { angle += args[1] * 0.25; }

		if (CheckRange(boa_sfxlod, true)) { return; }

		if (snd != "")
		{
			A_StartSound(snd, CHAN_6, CHANF_NOSTOP, 1.0);
			A_SoundVolume(CHAN_6, volume);
		}

		Laser.DoTrace(self, angle, beamdistance, pitch, 0, zoffset, hitpointtracer);
		[beam, flare] = Laser.DrawLaser(self, beam, flare, hitpointtracer.Results, beamclass, puffclass, damage, zoffset, drawdecal, alpha, flareclass);

		// Spawn line attacks above/below the main beam to keep the player from crouching underneath or jumping over
		// Match the actual beam's distance, pitch, angle, and damage
		int radius = 8;
		if (hitpointtracer)
		{
			LineAttack(angle, hitpointtracer.Results.distance, pitch, damage, damagetype, "Nothing", offsetz:zoffset - 8 + radius);
			LineAttack(angle, hitpointtracer.Results.distance, pitch, damage, damagetype, "Nothing", offsetz:zoffset - 8 - radius);
		}
	}

	override void Activate(Actor activator)
	{
		if (!args[3]) { A_StartSound("tesla/loop", CHAN_6, CHANF_LOOPING, 0.2); }

		bDormant = false;
		SetStateLabel("Active");
	}

	override void Deactivate(Actor activator)
	{
		A_StopSound(CHAN_6);
		if (beam) { beam.Destroy(); }
		if (flare) { flare.Destroy(); }

		bDormant = true;
		SetStateLabel("Inactive");
	}
}

class LaserShooterNF : LaserShooter
{
	static const string flareclasses[] = { "BigLaserFlareNR", "BigLaserFlareNP", "BigLaserFlareNG" };

	Actor flare2;

	Default
	{
		//$Title Laserbeam Shooter, No Flares (switchable, 3 colors, 4 args)
	}

	States
	{
		Active:
			TNT1 A 1 A_FireLaser(damage, drawdecal:false);
			Loop;
	}

	override void PostBeginPlay()
	{
		flareclass = flareclasses[min(2, args[0])];

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		if (flare2)
		{
			flare2.frame = Random(0, 5);
			flare2.alpha = flare2.Default.alpha * alpha;
		}
	}

	override void Activate(Actor activator)
	{
		if (!args[3]) { A_StartSound("tesla/loop", CHAN_6, CHANF_LOOPING, 0.2); }

		// Second flare actor at origin
		flare2 = Spawn(flareclass, pos, ALLOW_REPLACE);
		if (flare2) { flare2.master = beam; }

		bDormant = false;
		SetStateLabel("Active");
	}

	override void Deactivate(Actor activator)
	{
		A_StopSound(CHAN_6);
		if (beam) { beam.Destroy(); }
		if (flare) { flare.Destroy(); }
		if (flare2) { flare2.Destroy(); }

		bDormant = true;
		SetStateLabel("Inactive");
	}
}

class ZapShooter : LaserShooter
{
	double hitRadius;

	Property hitRadius: HitRadius;

	Default
	{
		//$Title Electrical Zap Shooter (switchable, 3 args)
		//$Arg0 "Rotation Speed"
		//$Arg1 "Distance (x256)"
		//$Arg2 "Sound"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "Yes"; 1 = "No"; }
		//$Arg3 ""
		ZapShooter.HitRadius 32;
		DamageType "Electric";
		LaserShooter.BeamClass "ElectricBeam";
		LaserShooter.FlareClass "ZapFlare";
	}

	override void PostBeginPlay()
	{
		// Offset the args so they match the parent actor's expected args
		args[3] = args[2];
		args[2] = args[1];
		args[1] = args[0];
		args[0] = 0;

		Super.PostBeginPlay();
	}

	override void A_FireLaser(int damage, sound snd, double zoffset, bool drawdecal, double alpha, double volume)
	{
		if (args[1]) { angle += args[1] * 0.25; }

		if (CheckRange(boa_sfxlod, true)) { return; }

		A_LookEx(LOF_NOSEESOUND | LOF_NOJUMP, 0, max(boa_sfxlod, 1024), max(boa_sfxlod, 1024));

		if (snd != "")
		{
			A_StartSound(snd, CHAN_6, CHANF_NOSTOP, 1.0);
			A_SoundVolume(CHAN_6, volume);
		}

		double shootAngle = angle;
		double shootPitch = pitch;
		double shootDist = beamdistance;
		if (target)
		{
			// Ensure target is within HitRadius
			Vector3 targPos = target.Pos; targPos.Z += target.Height * .75;
			Vector3 toTarget = Level.Vec3Diff(Pos, targPos);
			Vector2 xy = Actor.RotateVector(toTarget.XY, angle);
			Vector2 radiusCheck = (xy.y, toTarget.Z);
			if (radiusCheck.Length() < hitRadius)
			{
				Vector3 shoot = Level.SphericalCoords(Pos, targPos);
				shootAngle = -shoot.x;
				shootPitch = -shoot.y;
			}
		}

		Laser.DoTrace(self, shootAngle, shootDist, shootPitch, 0, zoffset, hitpointtracer);
		[beam, flare] = Laser.DrawLaser(self, beam, flare, hitpointtracer.Results, beamclass, puffclass, damage, zoffset, drawdecal, alpha, flareclass);
	}
}

// Utility class containing Laser tracer and beam drawing code.  See A_FireLaser function above.
class Laser : Actor
{
	static void DoTrace(Actor origin, double angle, double dist, double pitch, int flags, double zoffset, LaserFindHitPointTracer thistracer)
	{
		if (!thistracer || !origin) { return; }

		thistracer.skipspecies = origin.species;
		thistracer.skipactor = origin;

		Vector3 tracedir = ZScriptTools.GetTraceDirection(angle, pitch);
		if (!thistracer.Trace(origin.pos + (0, 0, zoffset), origin.CurSector, tracedir, dist, 0))
		{
			 // If tracer failed, assume full range.
			thistracer.Results.Distance = dist;
			thistracer.Results.HitPos = origin.pos + (0, 0, zoffset) + thistracer.Results.HitVector * dist;
		}
	}

	static LaserBeam, Actor DrawLaser(Actor origin, LaserBeam beam, Actor flare, TraceResults traceresults, Class<Actor> spawnclass = "LaserBeam", Class<Actor> puffclass = "LaserPuff", int damage = 0, double zoffset = 0, bool drawdecal = true, double alpha = 1.0, Class<Actor> flareclass = "LaserFlare")
	{
		ParticleManager manager;
		manager = ParticleManager.GetManager();

		if (!traceresults) { return beam, flare; }
		if (!origin) { return beam, flare; }

		Vector3 beamoffset = origin.pos + (0, 0, zoffset);
		double dist = traceresults.Distance;

		//Laser beam
		Vector3 beampos = beamoffset + traceresults.HitVector * (dist / 2);
		if (!beam && spawnclass != "")
		{
			beam = LaserBeam(Spawn(spawnclass, beampos, ALLOW_REPLACE));
			if (beam)
			{
				beam.master = origin;
				beam.target = origin;
			}
		}

		if (beam)
		{
			if (beam.pos != beampos) { beam.SetXYZ(beampos); }

			beam.pitch = origin.pitch - 90;
			beam.angle = origin.angle;
			beam.scale.x = FRandom(0.5, 0.75);
			beam.scale.y = dist * 2.225;
			beam.alpha = beam.Default.alpha * alpha;
		}

		if (!flare)
		{
			flare = Spawn(flareclass, traceresults.HitPos, ALLOW_REPLACE);
			if (flare)
			{
				flare.master = beam;
			}
		}

		if (flare)
		{
			flare.SetXYZ(traceresults.HitPos);

			flare.frame = Random(0, 5);
			flare.alpha = flare.Default.alpha * alpha;
			flare.angle = flare.AngleTo(origin);
		}

		Actor puff;
		int delay = 0;
		if (manager) { delay = 2 * manager.GetDelay(0, 0, traceresults.HitActor); }

		if (
			traceresults.HitType == TRACE_HitFloor || 
			traceresults.HitType == TRACE_HitCeiling || 
			traceresults.HitType == TRACE_HitWall || 
			(traceresults.HitActor && traceresults.HitActor.bNoBlood)
		)
		{
			if (!delay || level.time % delay == 0)
			{
				// Spawn bullet puff
				if (puffclass != "" && (!delay || level.time % delay == 0))
				{
					puff = Spawn(puffclass, traceresults.HitPos - traceresults.HitVector * 3.0, ALLOW_REPLACE);

					if (puff)
					{
						puff.master = origin;
						puff.angle = origin.AngleTo(puff);
						if (drawdecal && !Random(0, 16)) { puff.A_SprayDecal("LaserBeamScorch", 24.0); }
						puff.angle = puff.AngleTo(origin);
					}
				}
			}
		}
		else if (traceresults.HitActor)
 		{
			if (!delay || level.time % delay == 0)
			{
				puff = Spawn("LaserSmoke", traceresults.HitPos, ALLOW_REPLACE);
				if (puff)
				{
					puff.master = origin;
					puff.angle = puff.AngleTo(origin);
					puff.vel.z = 1.0;
				}
			}
		}

		if (traceresults.HitActor)
		{
			Name dmgtype;
			if (origin.damagetype != 'None') { dmgtype = origin.damagetype; }
			else {dmgtype = "Laser"; }

			traceresults.HitActor.DamageMobj(beam, origin, damage, dmgtype);
		}

		return beam, flare;
	}
}

// Tracer for sight lines of laser
class LaserFindHitPointTracer : LineTracer
{
	Name skipspecies;
	Actor skipactor;

	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitActor)
		{
			if (
				Results.HitActor != skipactor && // Skip the origin
				(skipactor != Results.HitActor.master) && // And the master
				(!Results.HitActor.master || Results.HitActor.master != skipactor) && // And any children
				(!skipspecies || Results.HitActor.species != skipspecies) && // And any of the skipped species
				(Results.HitActor.bSolid || Results.HitActor.bShootable || Results.HitActor is "PlayerPawn") && // And only return shootable actors
				!(Results.HitActor is "EffectSpawner")
			) { return TRACE_Stop; } 

			Results.HitActor = null;

			return TRACE_Skip;
		}
		else if (Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling)
		{
			return TRACE_Stop;
		}
		else if (Results.HitType == TRACE_HitWall)
		{
			if (Results.HitLine.flags & Line.ML_BLOCKEVERYTHING) { return TRACE_Stop; } // Only stops at one-sided or blocking lines (NOT impassible!)
			else if (!(Results.HitLine.flags & Line.ML_TWOSIDED)) { return TRACE_Stop; }

			if (Results.HitTexture)
			{
				if (Results.Tier != TIER_Middle) // Ignores all mid-textures, so will pass through 3D-midtex lines unless they were marked as blocking
				{
					return TRACE_Stop;
				}
			}

			Results.HitLine = null;

			return TRACE_Skip;
		}

		return TRACE_Stop;
	}
}

// Various beam types
class LaserBeam : Actor
{
	Default
	{
		+NOGRAVITY
		+NOINTERACTION
		+NOBLOCKMAP
		+BRIGHT
		+INTERPOLATEANGLES
		Radius 0;
		Height 0;
		RenderStyle "Add";
		RenderRadius 2048.0;
		Alpha 0.35;
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
	}

	override void Tick()
	{
		if (!master) { Destroy(); }

		Super.Tick();
	}
}

class LaserBeamRed : LaserBeam {}
class LaserBeamGreen : LaserBeam {}
class LaserBeamPurple : LaserBeam {}

class ElectricBeam : LaserBeam
{
	Default
	{
		+RANDOMIZE
	}

	States
	{
		Spawn:
			TNT1 A 1 NoDelay A_Jump(256,1,5,9,13,17,21,25,29,33);
		ActiveLoop:
			MDLA FGHIJKLMNOJNFGIHMKOL 2;
			Loop;
		ActiveLoop2:
			MDLA FGOHNIMJLKONMLKJIHGF 2;
			Loop;
	}
}

// Puff/Flare classes (spawned at impact point)
class BigLaserFlare : EffectSpawner
{
	Default
	{
		+NOGRAVITY
		Height 0;
		Radius 0;
		Mass 0;
		+BRIGHT
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+INTERPOLATEANGLES
		RenderStyle "Add";
		Scale 0.25;
		Alpha 2.5; // Overbright so they show up better
		+EffectSpawner.DONTCULL
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			SPKW A 0;
		Active:
			SPKW # 2 BRIGHT Light("LAZERZ") SpawnEffect();
			Loop;
	}

	override void Tick()
	{
		Super.Tick();

		if (!master) { Destroy(); }

		frame = Random(0, 5);
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		A_StartSound("tesla/loopdeath", CHAN_AUTO, CHANF_LOOPING, 0.2);
	}

	override void SpawnEffect()
	{
		if (CheckRange(1200, true)) { return; }

		Super.SpawnEffect();

		A_SpawnitemEx("SparkFlareW",FRandom(0, 2), FRandom(-2, 2), FRandom(-2, 2), FRandom(-2, 2), FRandom(-2, 2), FRandom(-2, 2), 0, SXF_ISTRACER | SXF_SETMASTER | SXF_NOCHECKPOSITION);
		A_SpawnItemEx("LaserSpark", FRandom(0, 4), FRandom(-4, 4), FRandom(-4, 4), FRandom(-2, 2), FRandom(-2, 2), FRandom(-2, 2));
		A_SpawnItemEx("LaserSmoke", FRandom(0, 4), FRandom(-4, 4), FRandom(-4, 4), 0, 0, FRandom(2.5, 3.5));
	}
}

class BigLaserFlareNR : BigLaserFlare
{
	States
	{
		Spawn:
			SPKW A 0;
		Active:
			SPKW # 10 BRIGHT Light("LAZERRED");
			Loop;
	}
}

class BigLaserFlareNP : BigLaserFlare
{
	States
	{
		Spawn:
			SPKW A 0;
		Active:
			SPKW # 10 BRIGHT Light("LAZERPUR");
			Loop;
	}
}

class BigLaserFlareNG : BigLaserFlare
{
	States
	{
		Spawn:
			SPKW A 0;
		Active:
			SPKW # 10 BRIGHT Light("LAZERGRN");
			Loop;
	}
}

class ZapFlare : BigLaserFlare
{
	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 # 10 BRIGHT Light("LAZERZAP");
			Loop;
	}
}

// Smoke class (spawned as part of flare and on impact with bleeding actor)
class LaserSmoke : PuffSmoke
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+NOINTERACTION
		+WINDTHRUST
		RenderStyle "Translucent";
		Alpha 0.0;
		Scale 0.05;
		SmokeBase.FadeInTics 1;
		SmokeBase.FadeOutTics 1;
		SmokeBase.MaxAlpha 0.5;
	}

	States
	{
		Spawn:
			"####" A 1 DoFade(0.05, 0.025, 1.1);
			Loop;
		Frames:
			GRM1 A 0;
			GRM2 A 0;
			GRM3 A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		scale.x *= FRandom(0.7, 1.0);
		scale.y *= FRandom(0.7, 1.0);

		int spr = GetSpriteIndex("GRM" .. Random(1, 3));
		if (spr != -1) { sprite = spr; }
	}
}

// Default puff actor.  Currently only seen with ProtoDrone laser
class LaserPuff : Actor
{
	Default
	{
		+NOGRAVITY
		+NOINTERACTION
		+NOBLOCKMAP
		+INVISIBLE
		Radius 0;
		Height 0;
	}

	States
	{
		Spawn:
			AMRK A 5 {
				A_SpawnItemEx("SparkFlareY", 0, 0, 40);
			}
			AMRK A 2 {
				// Spawn random spark
		 		A_SpawnProjectile(String.Format("Spark%c", RandomPick("W", "Y")), 0, 0, 0, CMF_AIMDIRECTION, Random(-157, -203));
			}
			Stop;
	}
}

// Spark spawned by puff actor.
class LaserSpark : SparkW
{
	Default
	{
		Scale 0.025;
	}
}

// Default flare actor.  Currently only seen with ProtoDrone laser
class LaserFlare : Actor
{
	Default
	{
		Height 0;
		Radius 0;
		Mass 0;
		+BRIGHT
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+INTERPOLATEANGLES
		RenderStyle "Add";
		Scale 0.0375;
		Alpha 2.5; // Overbright so they show up better
	}

	States
	{
		Spawn:
			SPKW # 1 BRIGHT;
			Loop;
	}

	override void Tick()
	{
		if (!master) { Destroy(); }

		Super.Tick();
	}
}