class Vidcam : Obstacle3d //Ozy81
{
	Default
	{
		//$Category Models (BoA)/Intermap
		//$Title Video Cam
		//$Color 3
		DistanceCheck "boa_scenelod";
		Height 64;
	}
}

class COD_DogHouse : Obstacle3d
{
	Default
	{
		//$Category Models (BoA)/Intermap
		//$Title Dog House
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 24;
		Height 48;
	}
}

class Flak88mm : ModelBase //MaxED
{
	Default
	{
		//$Category Models (BoA)/Mission
		//$Title 88mm Flak
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 64;
		Height 80;
	}
}

class Flak88mmDestroyed : ModelBase //Ozy81
{
	Default
	{
		//$Category Models (BoA)/Mission
		//$Title 88mm Flak (destroyed)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 64;
		Height 80;
	}
}

class Nebelwerfer3D : Base //MaxED
{
	Default
	{
		//$Category Models (BoA)/Mission
		//$Title Nebelwerfer 41 Mortar Launcher (mission only)
		//$Color 3
		Tag "Nebelwerfer";
		Radius 32;
		Height 56;
		Health 1000;
		+CANPASS
		+DONTSPLASH
		+DONTTHRUST
		+FLOORCLIP
		+NOBLOODDECALS
		+SHOOTABLE
		+SOLID
		+SYNCHRONIZED
		BloodType "TankSpark";
		DamageFactor "Frag", 0;
		DamageFactor "Poison", 0;
		DamageFactor "MutantPoison", 0;
		DamageFactor "UndeadPoison", 0;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Fire:
		MDLA BCDEFGH 1;
		Goto Spawn;
	Death:
		TNT1 A 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Tank", random(64,112), random(64,112), random(128,144), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("Nuke",0,0,5,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 1 A_SpawnItemEx("KaBoomer",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS);
		TNT1 A 5 A_SpawnItemEx("Nebelwerfer3D_Destroyed");
		Stop;
	}
}

class Nebelwerfer3D_Destroyed: Actor //Ozy81
{
	Default
	{
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 56;
		Health -1;
		+CANPASS
		+DONTSPLASH
		+DONTTHRUST
		+FLOORCLIP
		+NOBLOODDECALS
		+SHOOTABLE
		+SOLID
		BloodType "TankSpark";
	}
	States
	{
	Spawn:
		MDLA B 8 A_SpawnProjectile("DarkSmoke2",32,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	}
}

class COD_Mortars1 : MuseumBase //Ozy81
{
	Default
	{
		//$Category Models (BoA)/Mission
		//$Title Nebelwerfer Mortars Box
		//$Color 7
		DistanceCheck "boa_scenelod";
		Radius 16;
		Height 8;
	}
}

class COD_Mortars2 : MuseumBase //Ozy81
{
	Default
	{
		//$Category Models (BoA)/Mission
		//$Title Nebelwerfer Mortars Crate
		//$Color 7
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 32;
	}
}

class FlakVierling3D : SwitchableDecoration
{
	Default
	{
		//$Category Models (BoA)/Mission
		//$Title Flak Vierling (mission only)
		//$Color 3
		//$Arg0 "Type"
		//$Arg0Tooltip "Pickup the desired type\nSolid: 0\nNon-Solid: 1"
		Radius 80;
		Height 88;
		Health -1;
		-FLOORCLIP
		-NOBLOCKMAP
		+CANPASS
		+DONTSPLASH
		+DONTTHRUST
		+NOBLOOD
		+NOBLOODDECALS
		+NODAMAGE
		+NOGRAVITY
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //update manually on GZDB
	Spawn:
		MDLA A -1 NODELAY A_JumpIf(Args[0]==1, "NonSolid");
		Stop;
	Inactive:
		MDLA B 0 {bDormant = TRUE;} //update manually on GZDB
		MDLA B 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		MDLA B 0 A_Scream;
		MDLA B 0 A_NoBlocking;
		MDLA BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 0 A_SpawnItemEx("Debris_Tank", random(64,112), random(64,112), random(128,144), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		MDLA B 1 A_SpawnItemEx("Nuke",0,0,5,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
	Destroyed:
		MDLA B 8 A_SpawnProjectile("DarkSmoke2",32,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	NonSolid: //Needed for Intromap - ozy81
		MDLA A 0 A_UnsetSolid;
		MDLA A 0 {bNoGravity = FALSE; bCanPass = FALSE; bFloorClip = TRUE; bActLikeBridge = FALSE;} //oh god.. - ozy81
		"####" A -1 A_SetInvulnerable;
		Stop;
	}
}

class FlakVierling3D_War: Actor
{
	Default
	{
		//$Category Battlefield (BoA)
		//$Title Flak Vierling (destroyable)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 80;
		Height 88;
		Health 350;
		+CANPASS
		+DONTSPLASH
		+DONTTHRUST
		+FLOORCLIP
		+NOBLOODDECALS
		+SHOOTABLE
		+SOLID
		BloodType "TankSpark";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Death:
		MDLA B 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		MDLA B 0 A_Scream;
		MDLA B 0 A_NoBlocking;
		MDLA BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 0 A_SpawnItemEx("Debris_Tank", random(64,112), random(64,112), random(128,144), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		MDLA B 1 A_SpawnItemEx("Nuke",0,0,5,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
	Destroyed:
		MDLA B 8 A_SpawnProjectile("DarkSmoke2",32,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	}
}