class RockSpawner : SceneryBase
{
	Default
	{
		//$Category Models (BoA)/Rocks
		//$Color 3
		//$Arg0 "Shape"
		//$Arg0Tooltip "Pickup the desired shape\nRandom: 0\nLarge: 1\nMedium: 2\nSmall: 3"
		//$Arg1 "Gravity"
		//$Arg1Tooltip "Actor is affected by gravity and is solid \nNo: 0\nYes: 1"
		DistanceCheck "boa_scenelod"; //needed only for inheritances
		Radius 28;
		Height 24;
		Health -1;
		-CANPASS
		-FLOORCLIP
		-NOBLOCKMAP
		+DONTTHRUST
		+MOVEWITHSECTOR
		+NOBLOOD
		+NOBLOODDECALS
		+NODAMAGE
		+NOTAUTOAIMED
		+RELATIVETOFLOOR
		+SHOOTABLE
		+NOGRAVITY
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (args[0] == 0) { frame = Random(0, 2); } // If first arg was left as zero, pick a random frame (0, 1, 2 == A, B, C)
		else { frame = args[0] - 1; } // Otherwise set the chose frame

		bNoGravity = bSolid = !args[1];

		if (bSolid && !bDormant) // Adjust hitbox size and spawn blocking objects as needed
		{
			if (frame == 0)
			{
				A_SetSize(radius * scale.x, height * scale.y);
			}
			else if (!bWasCulled) // Blockers get added to the effect manager and handle their own culling, so only spawn blockers on initial spawn before culling
			{
				Actor block;

				if (frame == 1)
				{
					A_SetSize(12 * scale.x, 18 * scale.y);
					SpawnBlock(-6, 0, 0, 12, 16); // SpawnBlock handles offset and size scaling internally
					SpawnBlock(-2, 16, 0, 8, 16);
					SpawnBlock(-2, -16, 0, 8, 14);
				}
				else
				{
					A_SetSize(8 * scale.x, 14 * scale.y);
					SpawnBlock(-2, 0, 0, 6, 12);
					SpawnBlock(6, 0, 0, 6, 12);
					SpawnBlock(2, 14, 0, 6, 12);
					SpawnBlock(2, -14, 0, 6, 10);
				}
			}
		}
	}
}

