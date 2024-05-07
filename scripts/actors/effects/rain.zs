// Zscript version of the DECORATE Rain Spawner by Tormentor667
class RainSpawner : EffectSpawner
{
	Class<Actor> rainDropClass;
	protected int spawnIndex;
	protected Vector3 rainDropVel;
	protected double spawnZoffset;
	protected transient int updateCounter;
	ParticleSpawnPoint spawnPoints[SPAWN_POINTS_PER_SPAWNER]; // 48 * 32 = 1536 bytes

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Rain Spawner
		//$Color 12
		//$Arg0 "Radius"
		//$Arg0Tooltip "Radius in map units\nDefault: 0"
		//$Arg1 "Frequency"
		//$Arg1Tooltip "Frequency, the lower the number, the heavier the rainfall\nRange: 0 - 255"
		//$Arg2 "Sound"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "Yes"; 1 = "No"; }
		//$Arg3 "Drop Length"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Long"; 1 = "Short"; }
		//$Arg3Tooltip "Drop length, use long (0) for heavy rainfall and short (1) for a mizzle"
		//$Arg4 "Pitch"
		//$Arg4Tooltip "The rainfall's pitch, for maps with wind and storm, use angle for direction.\nThe higher the number, the heavier the wind.\nRange: 0 - 75, where 75 is almost horizontal rain"
		Radius 1;
		Height 1;
		YScale 0.1;
		+NOCLIP
		+NOGRAVITY
		+SPAWNCEILING;
		EffectSpawner.Range 1200;
		EffectSpawner.SwitchVar "boa_rainswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 1 SpawnEffect();
			Loop;
	}

	void SetupSpawnPoints() {
		bool circular = true;

		for (int i = 0; i < SPAWN_POINTS_PER_SPAWNER; i++) {
			do { // So that "continue" can be used to try again
				double xoffset = Random[Rain](-Args[0], Args[0]);
				double yoffset = circular ?
					Random[Rain](0, 359) :
					Random[Rain](-Args[0], Args[0]);

				// Calculate absolute spawn position
				Vector3 spawnPos = circular ?
					// yoffset is used here as an angle
					Vec3Angle(xoffset, yoffset, 0) :
					Vec3Offset(xoffset, yoffset, 0);

				Sector spawnSector = Level.PointInSector(spawnPos.XY);
				spawnPos.Z = min(spawnPos.Z, spawnSector.HighestCeilingAt(spawnPos.XY) - 2.0);
				spawnPos.Z += spawnZoffset;

				// Use a hitscan to find the distance to the nearest obstacle
				Vector3 vel = rainDropVel.Unit();

				BoASolidSurfaceFinderTracer finder = new("BoASolidSurfaceFinderTracer");
				finder.Trace(spawnPos, spawnSector, vel, 10000.0, TRACE_HitSky);

				// Set up spawn point
				spawnPoints[i].worldPos = spawnPos;
				[spawnPoints[i].angle, spawnPoints[i].pitch] = ZScriptTools.AnglesFromDirection(vel);
				/* // ========== Test start
				Vector3 dirbo = ZScriptTools.GetTraceDirection(spawnPoints[i].angle, spawnPoints[i].pitch);
				Console.Printf("dirbo: %.3f %.3f %.3f, vel: %.3f %.3f %.3f", dirbo, vel);
				if (dirbo dot vel < 0.9375) {
					Console.Printf("ZScriptTools.AnglesFromDirection is broken!");
				}
				// ========== Test end */
				double dist = finder.Results.Distance;
				double waterDist = finder.Results.Distance;
				if (finder.Results.CrossedWater) {
					Vector3 waterPos = finder.Results.CrossedWaterPos;
					waterDist = (waterPos - spawnPos).Length();
				} else if (finder.Results.Crossed3DWater) {
					Vector3 waterPos = finder.Results.Crossed3DWaterPos;
					waterDist = (waterPos - spawnPos).Length();
				}
				spawnPoints[i].distance = ceil(min(waterDist, dist) / rainDropVel.Length());
				break;
			} while(true); // See lines 68 and 83
		}
	}

	override void PostBeginPlay()
	{
		rainDropClass = "RainDropShort";
		if (!args[3]) { rainDropClass = "RainDropLong"; }

		if (args[0] == 0) { args[0] = 128; }

		rainDropVel = (
			Args[4],
			0,
			-(args[3] ? 20 : 40) + (Args[4] / 2)
		);
		rainDropVel.xy = RotateVector(rainDropVel.xy, Angle);

		SetupSpawnPoints();

		Super.PostBeginPlay();
	}

	override void Activate(Actor activator)
	{
		if (!args[2] && switchcvar && switchcvar.GetBool()) { A_StartSound("Ambient/Rain", 7, CHANF_LOOPING, 1.0); }

		Super.Activate(activator);
	}

	override void Deactivate(Actor activator)
	{
		A_StopSound(7);

		Super.Deactivate(activator);
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (Random[Rain](0, 255) < Args[1] || !rainDropClass) {
			return;
		}

		// Adjust the z-height
		if (++updateCounter == 3 && curchunk) {
			updateCounter = 0;
			double chunkZoffset = 0;
			chunkZoffset = min(curchunk.GetPlayerZOffset() - Pos.Z, 0);
			if (spawnZoffset != chunkZoffset) {
				spawnZoffset = chunkZoffset;
				// Console.Printf("spawnZoffset is now %.3f", spawnZoffset);
				SetupSpawnPoints();
			}
		}

		Actor raindropMobj = Spawn(rainDropClass, spawnPoints[spawnIndex].worldPos);
		raindropMobj.Vel = rainDropVel;
		raindropMobj.Angle = Angle;
		raindropMobj.Pitch = Pitch;
		raindropMobj.ReactionTime = int(spawnPoints[spawnIndex].distance);
		
		spawnIndex = (spawnIndex + 1) % SPAWN_POINTS_PER_SPAWNER;
	}
}

class RainDropShort : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Height 1;
		Radius 4;
		ReactionTime 10; // Lifetime, calculated by RainSpawner
		RenderStyle "Translucent";
		Alpha 0.7;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
	}

	States
	{
		Spawn:
			MDLA A 0;
		Rainfall:
			"####" A 1 A_Countdown;
			Loop;
		Death:
			RNDR A 0 {
				Scale = (0.10, 0.10);
				alpha = FRandom[Rain](0.8, 0.2);
			}
		RainDeath:
			"####" A 1 {
				Scale.x += 0.05;
				Scale.y += 0.05;
				A_FadeOut(0.1, FTF_REMOVE);
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Scale.x += FRandom[Rain](-0.05, 0.05);
		Scale.y += FRandom[Rain](-0.05, 0.05);
		alpha = FRandom[Rain](0.7, 0.4);
	}
}

class RainDropLong : RainDropShort {}