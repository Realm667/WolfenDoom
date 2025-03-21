// Zscript version of:
///////////////////////////////////
// SNOW SPAWNERS by Tormentor667 //
//   improved by  Ceeb & MaxED   //
///////////////////////////////////

// See effects.zs for ParticleSpawnPoint struct and SPAWN_POINTS_PER_SPAWNER

class SnowSpawner : EffectSpawner
{
	protected int checkDelay;
	ParticleSpawnPoint spawnPoints[SPAWN_POINTS_PER_SPAWNER]; // 48 * 32 = 1536 bytes

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Snow Spawner
		//$Color 12
		//$Sprite SNOWA0
		//$Arg0 "Radius"
		//$Arg0Tooltip "Radius in map units\nDefault: 0"
		//$Arg1 "Frequency"
		//$Arg1Tooltip "The lower the number, the heavier the snowfall\nRange: 0 - 255"
		//$Arg2 "Area"
		//$Arg2Type 11
		//$Arg2Enum { 0 = "Square"; 1 = "Circle"; }
		Radius 1;
		Height 3;
		+CLIENTSIDEONLY
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+NOSECTOR
		+SPAWNCEILING
		EffectSpawner.Range 1024;
		EffectSpawner.SwitchVar "boa_snowswitch";
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 6 SpawnEffect;
			TNT1 A 0 {
				if (--checkDelay == 0) {
					checkDelay = 12; // check happens every 72 (6 * 12) tics
					return A_CheckSightOrRange(range, "NotInSight", true);
				} else {
					return ResolveState(null);
				}
			}
			Loop;
		NotInSight:
			TNT1 A 70;
			TNT1 A 0 A_CheckSightOrRange(range, "NotInSight", true);
			Goto Active;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!args[0]) { args[0] = 128; }
		checkDelay = Random[CheckDelay](1, 12);
		SetupSpawnPoints();
	}

	static bool SpawnPointValid(Sector sec, TextureID ceilingpic) {
		return (
			sec &&
			sec.GetTexture(Sector.ceiling) == ceilingpic);
	}

	void SetupSpawnPoints() {
		bool circular = !!Args[2];

		for (int i = 0; i < SPAWN_POINTS_PER_SPAWNER; i++) {
			do { // So that "continue" can be used to try again
				double xoffset = Random[Snow](-Args[0], Args[0]);
				double yoffset = circular ?
					Random[Snow](0, 359) :
					Random[Snow](-Args[0], Args[0]);

				// Calculate absolute spawn position
				Vector3 spawnPos = circular ?
					// yoffset is used here as an angle
					Vec3Angle(xoffset, yoffset, 0) :
					Vec3Offset(xoffset, yoffset, 0);

				Sector spawnSector = Level.PointInSector(spawnPos.XY);
				if (!SnowSpawner.SpawnPointValid(spawnSector, ceilingpic)) {
					continue;
				}
				spawnPos.Z = min(spawnPos.Z, spawnSector.HighestCeilingAt(spawnPos.XY) - 2.0);

				// Use a hitscan to find the distance to the nearest obstacle
				BoASolidSurfaceFinderTracer finder = new("BoASolidSurfaceFinderTracer");
				Vector3 vel = (FRandom[Snow](-1.0, 1.0), FRandom[Snow](-1.0, 1.0), FRandom[Snow](-1.0, -3.0));
				vel = vel.Unit();
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
				spawnPoints[i].distance = min(dist, waterDist);
				break;
			} while(true); // See lines 68 and 83
		}
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (Random[Snow](0, 255) < Args[1]) {
			return;
		}

		int index = Random[SnowSpawner](0, SPAWN_POINTS_PER_SPAWNER - 1);

		TextureID snowflake = TexMan.CheckForTexture("SNOWA0", TexMan.Type_Sprite);
		double psize = 3.0; // Max of sprite width and height * SnowParticle scale

		Vector3 vel = ZScriptTools.GetTraceDirection(spawnPoints[index].angle, spawnPoints[index].pitch) * FRandom[Snow](1, 3);
		int lifetime = int(floor(spawnPoints[index].Distance / vel.Length())) + 2; // fall into floor

		FSpawnParticleParams particleInfo;
		particleInfo.color1 = "FFFFFF";
		particleInfo.texture = snowflake;
		particleInfo.style = STYLE_Add;
		particleInfo.flags = 0;
		particleInfo.lifetime = lifetime;
		particleInfo.size = psize;
		particleInfo.pos = spawnPoints[index].worldPos;
		particleInfo.vel = vel;
		particleInfo.startalpha = 1.0;
		Level.SpawnParticle(particleInfo);
	}
}

// Kept for savegame compatibility - Talon1024 and N00b
class SnowParticle : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Radius 1;
		Height 3;
		Projectile;
		RenderStyle "Add";
		Alpha 0.6;
		Scale 0.6;
		+CLIENTSIDEONLY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
	}

	States
	{
		Spawn:
			SNOW AAAAAAAA 1 NoDelay A_FadeIn(0.05);
			SNOW A -1;
			Stop;
		Death:
			SNOW A 1 A_FadeOut(0.02, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		scale.x = scale.y = FRandom[Snow](0.3, 0.6);
	}
}