// Zscript version of:
///////////////////////////////////
// SNOW SPAWNERS by Tormentor667 //
//   improved by  Ceeb & MaxED   //
///////////////////////////////////

class SnowSpawner : EffectSpawner
{
	// int particleLifetime;

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
			TNT1 A 6 SpawnEffect();
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!args[0]) { args[0] = 128; }
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (random(0, 255) < Args[1]) {
			return;
		}

		TextureID snowflake = TexMan.CheckForTexture("SNOWA0", TexMan.Type_Sprite);
		double psize = 3.0; // Max of sprite width and height * SnowParticle scale

		double xoffset = random(-Args[0], Args[0]);
		double yoffset = Args[2] ? 0 : random(-Args[0], Args[0]);
		double zoffset = 0;
		if (manager) { zoffset = min(manager.particlez - pos.z, 0); }

		// Calculate absolute spawn position
		double angle = Args[2] ? random(0, 359) : 0.0;
		Vector3 spawnPos = Args[2] ?
			Vec3Angle(xoffset, angle, zoffset) :
			Vec3Offset(xoffset, yoffset, zoffset);

		// Calculate lifetime based on distance to floor
		Sector mySector = Level.PointInSector(spawnPos.XY);
		if (mySector.GetTexture(Sector.ceiling) != skyflatnum) { return; }
		double floorHeight = mySector.NextLowestFloorAt(spawnPos.X, spawnPos.Y, spawnPos.Z);
		double heightDiff = spawnPos.Z - floorHeight;
		double speed = frandom(-1.0, -3.0);
		int lifetime = int(floor(heightDiff / -speed)) + 2; // fall into floor

		FSpawnParticleParams particleInfo;
		particleInfo.color1 = "FFFFFF";
		particleInfo.texture = snowflake;
		particleInfo.style = STYLE_Add;
		particleInfo.flags = 0;
		particleInfo.lifetime = lifetime;
		particleInfo.size = psize;
		particleInfo.pos = spawnPos;
		particleInfo.vel = (frandom(-1.0, 1.0), frandom(-1.0, 1.0), speed);
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
		scale.x = scale.y = FRandom(0.3, 0.6);
	}
}