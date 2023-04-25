// Zscript version of:
///////////////////////////////////
// SNOW SPAWNERS by Tormentor667 //
//   improved by  Ceeb & MaxED   //
///////////////////////////////////

class SnowSpawner : EffectSpawner
{
	int particleLifetime;

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
		+SPAWNCEILING;
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

		Sector mySector = Level.PointInSector(Pos.XY);
		// The +SPAWNCEILING flag makes the snow spawner spawn in the ceiling
		double floorHeight = mySector.NextLowestFloorAt(Pos.X, Pos.Y, Pos.Z);
		double snowSpeed = 1.5; // Average with a bit more leeway
		double heightDiff = Pos.Z - floorHeight;
		particleLifetime = int(floor(heightDiff / snowSpeed)) + 10; // a few extra tics in case heightDiff / snowSpeed is not enough
		// Let's see if this code is really necessary first
		/* 
		// Check around the snow particle spawn area for the lowest sector height
		switch (args[2]) {
			case 0: // Square
			default:
				for (int i = 0; i < 5; i++) {
					for (int j = 0; j < 5; j++) {
						//
					}
				}
				break;
			case 1: // Circle
				//
				break;
		} */
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (random(0, 255) < Args[1]) {
			return;
		}

		TextureID snowflake = TexMan.CheckForTexture("SNOWA0", TexMan.Type_Sprite);
		double psize = 3.0; // Sprite width(?) * SnowParticle scale

		double xoffset = random(-Args[0], Args[0]);
		double yoffset = Args[2] ? 0 : random(-Args[0], Args[0]);
		double zoffset = 0;
		if (manager) { zoffset = min(manager.particlez - pos.z, 0); }
		double angle = Args[2] ? random(0, 359) : 0.0;

		A_SpawnParticleEx(
			"FFFFFF", // color1
			snowflake, // texture
			STYLE_Normal, // style
			SPF_RELATIVE, // flags
			particleLifetime, // lifetime
			psize, // size
			angle, // angle
			xoffset, yoffset, zoffset, // off xyz
			frandom(-1.0, 1.0), frandom(-1.0, 1.0), frandom(-1.0, -3.0), // vel xyz
			fadestepf: 0.0
		);
	}
}

// Kept for savegame compatibility - Talon1024 and Username-N00b-is-not-available
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