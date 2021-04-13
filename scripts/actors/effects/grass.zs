class Grass1 : GrassBase
{
	Default
	{
		//$Category Flora (BoA)
		//$Title Grass 1
		//$Color 3
		//$Sprite GRS1A0
		Radius 16;
		Height 16;
		Scale 0.5;
		Health 1;
		+DONTTHRUST
		+NOBLOOD
		+NOTAUTOAIMED
		+SHOOTABLE
		DistanceCheck "boa_grasslod";
		GrassBase.Fragments "GrassFrags";
	}

	States
	{
		Spawn:
			GRS1 A -1;
			Stop;
		Death:
			"####" B -1 A_Death();
			Stop;
	}

	virtual void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		scale *= FRandom(0.9, 1.1);
		scale.x *= RandomPick(-1, 1);
	}
}

class Grass2 : Grass1
{
	Default
	{
		//$Title Grass 2
		//$Sprite GRS2A0
	}

	States
	{
		Spawn:
			GRS2 A -1;
			Stop;
	}
}

class Grass3 : Grass1
{
	Default
	{
		//$Title Grass 3
		//$Sprite GRS3A0
	}

	States
	{
		Spawn:
			GRS3 A -1;
			Stop;
	}
}

class Grass4 : Grass1
{
	Default
	{
		//$Title Grass 1 (desert)
		//$Sprite GRS4A0
		GrassBase.Fragments "GrassFrags_Dry";
	}

	States
	{
		Spawn:
			GRS4 A -1;
			Stop;
	}
}

class Grass5 : Grass4
{
	Default
	{
		//$Title Grass 2 (desert)
		//$Sprite GRS5A0
	}

	States
	{
		Spawn:
			GRS5 A -1;
			Stop;
	}
}

class Grass6 : Grass4
{
	Default
	{
		//$Title Grass 3 (desert)
		//$Sprite GRS6A0
	}

	States
	{
		Spawn:
			GRS6 A -1;
			Stop;
	}
}

class Grass7 : Grass1
{
	Default
	{
		//$Title Grass 1 (winter)
		//$Sprite GRS7A0
		GrassBase.Fragments "GrassFrags_Snowy";
	}

	States
	{
		Spawn:
			GRS7 A -1;
			Stop;
	}
}

class Grass8 : Grass7
{
	Default
	{
		//$Title Grass 2 (winter)
		//$Sprite GRS8A0
	}

	States
	{
		Spawn:
			GRS8 A -1;
			Stop;
	}
}

class Grass9 : Grass7
{
	Default
	{
		//$Title Grass 3 (winter)
		//$Sprite GRS9A0
	}

	States
	{
		Spawn:
			GRS9 A -1;
			Stop;
	}
}

class NiceBush1 : Grass1
{
	Default
	{
		//$Category Flora (BoA)
		//$Title Flourishing Bush (1st variant, RBY flowers)
		//$Sprite BUS1A0
		GrassBase.Fragments "GrassFrags";
	}

	States
	{
		Spawn:
			"####" "#" -1;
			Stop;
		Death:
			BUSZ C -1 A_Death();
			Stop;
		Frames:
			BUS1 A 0;
			BUS2 A 0;
			BUS3 A 0;
			BUS4 A 0;
			BUS5 A 0;
			BUS6 A 0;
			BUS7 A 0;
			BUS8 A 0;
			BUS9 A 0;
			BUSA A 0;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		A_SpawnItemEx("Debris_LeafY", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		A_SpawnItemEx("Debris_LeafW", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		A_SpawnItemEx("Debris_LeafR", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	virtual void PickVariant()
	{
		int spr = GetSpriteIndex("BUS" .. Random(1, 2));
		if (spr != -1) { sprite = spr; }

		frame = Random(0, 3);
	}

	override void PostBeginPlay()
	{
		GrassBase.PostBeginPlay();

		PickVariant();

		scale *= FRandom(0.9, 1.1);
		scale.x *= RandomPick(-1, 1);
	}
}

class NiceBush2 : NiceBush1
{
	Default
	{
		//$Title Flourishing Bush (2nd variant, BY flowers)
		//$Sprite BUS3A0
	}

	States
	{
		Spawn:
			BUS3 "#" -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		A_SpawnItemEx("Debris_LeafY", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		A_SpawnItemEx("Debris_LeafB", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PickVariant()
	{
		frame = Random(0, 3);
	}
}

class NiceBush3 : NiceBush1
{
	Default
	{
		//$Title Flourishing Bush (3rd variant, red flowers)
		//$Sprite BUS4A0
	}


	States
	{
		Spawn:
			BUS4 "#" -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		A_SpawnItemEx("Debris_LeafR", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PickVariant()
	{
		frame = Random(0, 3);
	}
}

class NiceBush4 : NiceBush1
{
	Default
	{
		//$Title Flourishing Bush (4th variant, yellow flowers)
		//$Sprite BUS5A0
	}

	States
	{
		Spawn:
			BUS5 "#" -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		A_SpawnItemEx("Debris_LeafY", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PickVariant()
	{
		frame = Random(0, 3);
	}
}

class NiceBush5 : NiceBush1
{
	Default
	{
		//$Title Flourishing Bush (5th variant, blue flowers)
		//$Sprite BUS6A0
	}


	States
	{
		Spawn:
			BUS6 "#" -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		A_SpawnItemEx("Debris_LeafB", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PickVariant()
	{
		frame = Random(0, 3);
	}
}

class NiceBush6 : NiceBush1
{
	Default
	{
		//$Title Flourishing Bush (6th variant, random berries)
		//$Sprite BUS7A0
	}

	States
	{
		Spawn:
			BUS7 "#" -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		A_SpawnItemEx("Debris_Leaf", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PickVariant()
	{
		frame = Random(0, 3);
	}
}

class NiceBush7 : NiceBush1
{
	Default
	{
		//$Title Bed of Flowers (1st variant, random)
		//$Sprite BUS8A0
		Radius 12;
		Height 12;
	}

	States
	{
		Spawn:
			BUS8 "#" -1;
			Stop;
		Death:
			BUSZ D -1 A_Death();
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		A_SpawnItemEx("Debris_LeafY", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		A_SpawnItemEx("Debris_LeafW", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PickVariant()
	{
		frame = Random(0, 3);
	}
}

class NiceBush8 : NiceBush7
{
	Default
	{
		//$Title Bed of Flowers (2nd variant, random)
		//$Sprite BUS9A0
		Radius 8;
		Height 8;
	}

	States
	{
		Spawn:
			BUS9 A -1;
			Stop;
	}
}

class NiceBush9 : NiceBush7
{
	Default
	{
		//$Title Bed of Flowers (3rd variant, random)
		//$Sprite BUSAA0
		Radius 8;
		Height 8;
	}

	States
	{
		Spawn:
			BUSA A -1;
			Stop;
	}
}

class Flower1 : Grass1
{
	Default
	{
		//$Title Flower (yellow)
		//$Color 3
		//$Sprite FLW1A0
		Height 32;
		Scale 1.0;
	}

	States
	{
		Spawn:
			FLW1 A -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		for (int i = 0; i < 4; i++) { A_SpawnItemEx("Debris_LeafY", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE); }
		if (fragments) { A_SpawnItemEx(fragments); }
	}

	override void PostBeginPlay()
	{
		GrassBase.PostBeginPlay();

		scale *= FRandom(0.8, 1.1);
		scale.x *= RandomPick(-1, 1);
	}
}

class Flower2 : Flower1
{
	Default
	{
		//$Title Flower (white)
		//$Sprite FLW2A0
	}

	States
	{
		Spawn:
			FLW2 A -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		for (int i = 0; i < 4; i++) { A_SpawnItemEx("Debris_LeafW", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE); }
		if (fragments) { A_SpawnItemEx(fragments); }
	}
}

class Flower3 : Flower1
{
	Default
	{
		//$Title Flower (winter)
		//$Sprite FLW3A0
		GrassBase.Fragments "GrassFrags_Snowy";
	}

	States
	{
		Spawn:
			FLW3 A -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		if (fragments) { A_SpawnItemEx(fragments); }
	}
}

class Rose1 : Flower1
{
	Default
	{
		//$Title Rose (red)
		//$Sprite FLW4A0
	}

	States
	{
		Spawn:
			FLW4 A -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		for (int i = 0; i < 4; i++) { A_SpawnItemEx("Debris_LeafR", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE); }
		if (fragments) { A_SpawnItemEx(fragments); }
	}
}

class Rose2 : Flower1
{
	Default
	{
		//$Title Rose (yellow)
		//$Sprite FLW5A0
	}

	States
	{
		Spawn:
			FLW5 A -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		for (int i = 0; i < 4; i++) { A_SpawnItemEx("Debris_LeafY", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE); }
		if (fragments) { A_SpawnItemEx(fragments); }
	}
}

class Rose3 : Flower1
{
	Default
	{
		//$Title Rose (blue-white)
		//$Sprite FLW6A0
	}

	States
	{
		Spawn:
			FLW6 A -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		for (int i = 0; i < 4; i++) { A_SpawnItemEx("Debris_LeafB", random(0,4), random(0,8), random(0,24), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE); }
		if (fragments) { A_SpawnItemEx(fragments); }
	}
}

class Rose4 : Flower1
{
	Default
	{
		//$Title Rose (winter)
		//$Sprite FLW7A0
		GrassBase.Fragments "GrassFrags_Snowy";
	}

	States
	{
		Spawn:
			FLW7 A -1;
			Stop;
	}

	override void A_Death()
	{
		A_UnSetSolid();
		A_StartSound("GRASBRKS", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		if (fragments) { A_SpawnItemEx(fragments); }
	}
}

//Jungle grass
class JungleGrass1 : Grass1
{
	Default
	{
		//$Title Jungle Grass 1
		//$Sprite JUNGA0
		Scale 0.9;
	}

	States
	{
		Spawn:
			JUNG A -1;
			Stop;
		Death:
			JUNG E -1 A_Death();
			Stop;
	}
}

class JungleGrass2 : Grass1
{
	Default
	{
		//$Title Jungle Grass 2
		//$Sprite JUNGB0
	}

	States
	{
		Spawn:
			JUNG B -1;
			Stop;
		Death:
			JUNG F -1 A_Death();
			Stop;
	}
}

class JungleGrass3 : Grass1
{
	Default
	{
		//$Title Jungle Grass 3
		//$Sprite JUNGC0
	}

	States
	{
		Spawn:
			JUNG C -1;
			Stop;
		Death:
			JUNG G -1 A_Death();
			Stop;
	}
}

class JungleGrass4 : Grass1
{
	Default
	{
		//$Title Jungle Grass 4
		//$Sprite JUNGD0
	}

	States
	{
		Spawn:
			JUNG D -1;
			Stop;
		Death:
			JUNG H -1 A_Death();
			Stop;
	}
}

//Randomizers
class FlowersSpawner : RandomSpawner
{
	Default
	{
		//$Category Flora (BoA)
		//$Title Random Flowers Spawner
		//$Color 3
		//$Sprite FLW1A0
		DropItem "Flower1";
		DropItem "Flower2";
		DropItem "Rose1";
		DropItem "Rose2";
		DropItem "Rose3";
	}
}

class GrassSpawner : RandomSpawner
{
	Default
	{
		//$Category Flora (BoA)
		//$Title Random Grass Spawner
		//$Color 3
		//$Sprite GRS1A0
		DropItem "Grass1";
		DropItem "Grass2";
		DropItem "Grass3";
		Radius 16;
		Height 16;
		Scale 0.5;
	}
}

class GrassSpawnerDesert : RandomSpawner
{
	Default
	{
		//$Category Flora (BoA)
		//$Title Random Grass Spawner (desert)
		//$Color 3
		//$Sprite GRS4A0
		DropItem "Grass4";
		DropItem "Grass5";
		DropItem "Grass6";
		Radius 16;
		Height 16;
		Scale 0.5;
	}
}

class GrassSpawnerWinter : RandomSpawner
{
	Default
	{
		//$Category Flora (BoA)
		//$Title Random Grass Spawner (winter, also flowers)
		//$Color 3
		//$Sprite GRS7A0
		DropItem "Grass7";
		DropItem "Grass8";
		DropItem "Grass9";
		DropItem "Grass7";
		DropItem "Grass8";
		DropItem "Grass9";
		DropItem "Flower3";
		DropItem "Rose4";
		Radius 16;
		Height 16;
		Scale 0.5;
	}
}

class GrassSpawnerJungle : RandomSpawner
{
	Default
	{
		//$Category Flora (BoA)
		//$Title Random Grass Spawner (jungle)
		//$Color 3
		//$Sprite JUNGA0
		DropItem "JungleGrass1";
		DropItem "JungleGrass2";
		DropItem "JungleGrass3";
		DropItem "JungleGrass4";
		Radius 16;
		Height 16;
		Scale 0.9;
	}
}