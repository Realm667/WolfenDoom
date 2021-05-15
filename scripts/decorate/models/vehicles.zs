/*
 * Copyright (c) 2019-2021 Ozymandias81, AFADoomer
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

//Enjay models
class ModelIncaTrain : ModelBase
{
	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Train
	//$Color 3
	DistanceCheck "boa_scenelod";
	RenderRadius 256;
	Radius 4;
	Height 4;
	}
}

class ModelRailBoxcar : ModelIncaTrain
{
	Default
	{
	//$Title Train (boxcar)
	}
}

class TrainWheels : ModelIncaTrain
{
	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Train Wheels
	//$Color 3
	Radius 4;
	Height 4;
	}
}

class ModelRailBoxcar2 : ModelIncaTrain
{
	Default
	{
	//$Title Train (boxcar,kz)
	}
}

class ModelRailBoxcar3 : ModelIncaTrain
{
	Default
	{
	//$Title Train (future)
	}
}

class ModelRailBoxcar3_Projectile : ModelRailBoxcar3
{
	Default
	{
	Radius 48;
	Height 48;
	Speed 1;
	Damage 1000;
	Projectile;
	SeeSound "subway/active";
	+RIPPER
	}
}

class ModelRailTanker : ModelIncaTrain
{
	Default
	{
	//$Title Train (tanker)
	}
}

class BomberVTOL3 : ModelBase
{	Default
	{
	//$Category Models (BoA)/Planes
	//$Title Bomber VTOL-3
	//$Color 3
	DistanceCheck "boa_scenelod";
	}
}

class Submarine : ModelBase //Ozy81
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Submarine
	//$Color 3
	//$Arg0 "Engine Sound"
	//$Arg0Type 11
	//$Arg0Enum { 0 = "No"; 1 = "Yes"; }
	DistanceCheck "boa_scenelod";
	Radius 64;
	Height 64;
	-SOLID
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_JumpIf(args[0] == 1, "PlayEngineSound");
		Goto Super::Spawn;
	PlayEngineSound:
		MDLA A 0 A_StartSound("uboat/engine", CHAN_AUTO, CHANF_LOOPING, 1.0, 0.5);
		Goto Super::Spawn;
	}
}

class SubmarineF : Furniture_End3d
{	Default
	{
	//$Title Submarine (no lod)
	}
}

class SubmarineIcy : Submarine
{	Default
	{
	//$Title Submarine (congealed)
	}
}

class TankPanzer3 : ModelBase //MaxED
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Tank (Panzer III)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 4;
	Height 64;
	}
}

class Cruiser : ModelBase //Ozy81
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Battleship
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 4;
	Height 4;
	}
}

class FlakVierling3D_Ship : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Flak Vierling (ship variant)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 72;
	Height 88;
	+NOGRAVITY
	}
}

class Luftschiff : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Luftschiff LZ127
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 32;
	-SOLID
	+NOGRAVITY
	}

	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	Animate:
		MDLA ABCDEFGH 1;
		Loop;
	}
}

class Luftschiff_End : SwitchableDecoration
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Luftschiff LZ127 (Castle Wolfenstein)
	//$Color 3
	Radius 32;
	Height 32;
	-SOLID
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A -1;
		Wait;
	Active:
		"####" A 35;
		Loop;
	Inactive:
		MDLA A 0 A_StartSound("UFOEXPL", CHAN_AUTO, 0, 12.0, ATTN_NONE);
		"####" A 0 A_NoBlocking;
		"####" A 0 A_SpawnItemEx("LZ127Nuke", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 0 A_SpawnItemEx("LZ127SmokePillar", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 1 A_SpawnItemEx("LZ127SmokePillar", 0, 0, -512, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" B -1;
		Stop;
	}
}

class Luftschiff_Deco : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Luftschiff LZ127 (Decorative)
	DistanceCheck "boa_scenelod";
	}
}

class Junker52 : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Planes
	//$Title Junkers JU-52
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 128;
	Height 64;
	}
}

class Forklift : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Forklift
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 80;
	Height 64;
	}
}

class MedTruck : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Medical Truck
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 68;
	Height 72;
	}
}

class MedTruckD : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Medical Truck, Destroyed
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 68;
	Height 72;
	}
}

class Tires: Actor
{	Default
	{
	//$Category Props (BoA)/Street
	//$Title Tires (Kubelwagon)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 16;
	Height 8;
	+SOLID
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class Tires2 : Tires
{	Default
	{
	//$Title Tires (Nazi Staff Car)
	DistanceCheck "boa_scenelod";
	+NOGRAVITY
	}
}

class Tires3 : Tires
{	Default
	{
	//$Title Tires (Junker-52)
	DistanceCheck "boa_scenelod";
	+NOGRAVITY
	}
}

class Single_Tire : Tires
{	Default
	{
	//$Title Single Tire (Kubelwagon)
	DistanceCheck "boa_scenelod";
	+NOGRAVITY
	}
}

class Single_Tire2 : Tires
{	Default
	{
	//$Title Single Tire (Junker-52)
	DistanceCheck "boa_scenelod";
	+NOGRAVITY
	}
}

//Return to Castle Wolfenstein models
class RTCWCar : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Staff Car
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 32;
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("RTCWCarGlass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		Stop;
	}
}

class RTCWCarGlass : Glass3d { Default { DistanceCheck "boa_scenelod"; } }

//Wolfenstein 2009 models
class Opel_Fuel : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Opel Blitz T-Stoff Tankwagen
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 32;
	}
	States
	{
	Spawn:
		MDLA A -1; //no glass
		Stop;
	}
}

//MaxED stuff
class ModelGMCTruck : SwitchableDecoration //ozy81
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Truck (US, MoH)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Health -1;
	-FLOORCLIP
	-NOBLOCKMAP
	+CANPASS
	+DONTSPLASH
	+DONTTHRUST
	+NOBLOOD
	+NOBLOODDECALS
	+NODAMAGE
	+NOTAUTOAIMED
	+SHOOTABLE
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //mxd. DORMANT flag must be updated manually
	TrampleIsOn:
		MDLA A 1 A_SpawnItemEx("Trample", Scale.X*128, 0, Height-16, 0, 0, 0, 0, MODELS_FLAGS2);
		Loop;
	Spawn:
		MDLA A -1;
		Stop;
	Inactive:
		MDLA A -1 {bDormant = TRUE;} //mxd. DORMANT flag must be updated manually
		Stop;
	}
}

class ModelOpelTruck : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Opel Blitz Truck (Afrika Korps or Wehrmacht)
	//$Color 3
	//$Arg0 "Type"
	//$Arg0Tooltip "Pickup the desired type\nAfrika: 0\nWehrmacht: 1\nAfrika (Truck Seqs): 2\nWehrmacht (Truck Seqs): 3"
	DistanceCheck "boa_scenelod";
	RenderRadius 256;
	Radius 24;
	Height 24;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY { args[0] == args[0] % 2; } // Remove check once the trucks are all fixed to not use args 2/3 (used to be windowless versions)
		TNT1 A 0 A_JumpIf(Args[0]==1, "Wehrmacht");
	Random: //fall through if set at 0
		MDLA A -1 A_SpawnItemEx("ModelOpelTruckWindows", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1);
		Stop;
	Wehrmacht:
		MDLA B -1 A_SpawnItemEx("ModelOpelTruckWindows", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS1);
		Stop;
	}
}

// Rideable "Opel truck" for C2M5_A
class ModelOpelTruckRide : ModelOpelTruck
{
	Default
	{
		+CULLACTORBASE.DONTCULL
	}
}

class MercedesLimo : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Mercedes Nazi Limo
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 32;
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("LimoGlass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		Stop;
	}
}

class LimoGlass : Glass3d { Default { DistanceCheck "boa_scenelod"; } }

class Kubelwagen : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Kubelwagen
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 32;
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY A_SpawnItemEx("KubelGlass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		Stop;
	}
}

class KubelGlass : Glass3d { Default { DistanceCheck "boa_scenelod"; } }

class OldCar_Spawner : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Old Citroen C6 Sedan Spawner
	//$Color 3
	//$Arg0 "Color"
	//$Arg0Tooltip "Pickup the desired color\nRandom: 0\nOlive: 1\nRed: 2\nCyan: 3\nNoir: 4"
	DistanceCheck "boa_scenelod";
	Height 64;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Olive");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Red");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Cyan");
		TNT1 A 0 A_JumpIf(Args[0]==4, "Noir");
	Random: //fall through if set at 0
		MDLA A -1 A_Jump(128,1);
		MDLA B -1 A_Jump(128,1);
		MDLA C -1 A_Jump(128,1);
		MDLA D -1;
		Stop;
	Olive:
		MDLA A -1;
		Stop;
	Red:
		MDLA B -1;
		Stop;
	Cyan:
		MDLA C -1;
		Stop;
	Noir:
		MDLA D -1;
		Stop;
	}
}

class Tractor : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Trclass
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 32;
	}
}

//CODs Stuff - Ozy81
class US_ShermanTurretProp : ModelBase { Default { DistanceCheck "boa_scenelod"; +CANPASS } }
class US_ShermanCannonProp : ModelBase { Default { DistanceCheck "boa_scenelod"; +CANPASS } }

class US_ShermanProp : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title US M4 Sherman Tank (scenery)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Height 88;
	+SOLID
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY {
		A_SpawnItemEx("US_ShermanTurretProp", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		A_SpawnItemEx("US_ShermanCannonProp", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid); }
		Stop;
	}
}

class US_ShermanTurretDeco : MuseumBase { Default { DistanceCheck "boa_scenelod"; +CANPASS } }
class US_ShermanCannonDeco : MuseumBase { Default { DistanceCheck "boa_scenelod"; +CANPASS } }

class US_ShermanDeco : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title US M4 Sherman Tank, Decorative
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY {
		A_SpawnItemEx("US_ShermanTurretDeco", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		A_SpawnItemEx("US_ShermanCannonDeco", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid); }
		Stop;
	}
}

class T34TreadsProp : MuseumBase { Default { DistanceCheck "boa_scenelod"; +CANPASS } }
class T34CannonProp : MuseumBase { Default { DistanceCheck "boa_scenelod"; +CANPASS } }
class T34TurretProp : MuseumBase { Default { DistanceCheck "boa_scenelod"; +CANPASS } }

class T34TankProp : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title T-34 Soviet Standard Tank (scenery)
	//$Color 3
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1 NODELAY {
		A_SpawnItemEx("T34TurretProp", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		A_SpawnItemEx("T34CannonProp", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		A_SpawnItemEx("T34TreadsProp", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid); }
		Stop;
	}
}

class COD_DestroyedTrainPlain : ModelIncaTrain
{	Default
	{
	//$Title Destroyed City Train (Plain)
	}
}

class COD_DestroyedTrainSnow : ModelIncaTrain
{	Default
	{
	//$Title Destroyed City Train (Snow Covered)
	}
}

class COD_Tiger1 : ModelBase
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Tank (Tiger I)
	//$Color 3
	Radius 4;
	Height 64;
	RenderRadius 256;
	DistanceCheck "boa_scenelod";
	}
}
class COD_SSHorch : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Truck, Horch-1A (Nazi)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 12;
	Height 52;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY A_SpawnItemEx("COD_SSHorch_Glass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		MDLA A 0 A_SpawnItemEx("InvisibleBridge32",-48,0,20,0,0,0,0,0,0,tid);
		MDLA A 0 A_SpawnItemEx("InvisibleBridge32",80,0,36,0,0,0,0,0,0,tid);
		MDLA A -1 A_SpawnItemEx("InvisibleBridge32",88,0,16,0,0,0,0,0,0,tid);
		Stop;
	}
}

class COD_SSHorch_Glass : Glass3d { Default { DistanceCheck "boa_scenelod"; } }

class COD_USJeep : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Jeep (US)
	//$Color 3
	//$Arg0 "Shape"
	//$Arg0Tooltip "Change the variant\nDamaged: 1"
	DistanceCheck "boa_scenelod";
	Radius 12;
	Height 52;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Damaged");
	Normal:
		MDLA A 0 A_SpawnItemEx("COD_USJeep_Glass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		MDLA A 0 A_SpawnItemEx("InvisibleBridge32",-48,0,20,0,0,0,0,0,0,tid);
		MDLA A 0 A_SpawnItemEx("InvisibleBridge32",80,0,36,0,0,0,0,0,0,tid);
		MDLA A -1 A_SpawnItemEx("InvisibleBridge32",88,0,16,0,0,0,0,0,0,tid);
		Stop;
	Damaged:
		MDLA B 0 A_UnsetSolid;
	DmgLoop:
		MDLA B 8 A_SpawnProjectile("DarkSmoke2",32,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	}
}

class COD_USJeep_Glass : Glass3d { Default { DistanceCheck "boa_scenelod"; } }

class COD_OpBlitzDestroyed : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Destroyed Opel Blitz (Set ARGs, 2 variants)
	//$Color 3
	//$Arg0 "Type"
	//$Arg0Tooltip "Change the variant\nAfrika: 1"
	DistanceCheck "boa_scenelod";
	Radius 32;
	Height 64;
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Afrika");
	Normal:
		MDLA A -1 A_SpawnItemEx("COD_OpBlitzD_Glass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		Stop;
	Afrika:
		MDLA B -1 A_SpawnItemEx("COD_OpBlitzD_Glass", 0, 0, 0, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		Stop;
	}
}

class COD_OpBlitzD_Glass : Glass3d { Default { DistanceCheck "boa_scenelod"; } }

class CODBike : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Old Bike
	//$Color 3
	//$Arg0 "Shape"
	//$Arg0Tooltip "Pickup the desired shape\nRandom: 0\nClean: 1\nBroken: 2"
	DistanceCheck "boa_scenelod";
	Radius 16;
	Height 32;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Clean");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Broken");
	Random: //fall through if set at 0
		MDLA A -1 A_Jump(128,1);
		MDLA B -1 A_UnsetSolid;
		Stop;
	Clean:
		MDLA A -1;
		Stop;
	Broken:
		MDLA B -1 A_UnsetSolid;
		Stop;
	}
}

class CODOmahaBoat : FlakVierling3D
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Landing Boat
	//$Color 3
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //update manually on GZDB
	Spawn:
		MDLA A -1;
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
	}
}

class CODPTBoat : COD_USJeep
{	Default
	{
	//$Category Models (BoA)/Ships
	//$Title Higgins PT Boat 109
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Damaged");
	Normal:
		MDLA A -1;
		Stop;
	Damaged:
		MDLA B 0 A_UnsetSolid;
	DmgLoop:
		MDLA B 8 A_SpawnProjectile("DarkSmoke2",32,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	}
}

class CODStuka : ModelBase //no distancecheck for this one due it is used on C2M4 as sensible objective target --ozy81
{
	Default
	{
	//$Category Models (BoA)/Planes
	//$Title Stuka Airplane (Uses Args, Normal, Destroyed, Crashed or Boom)
	//$Color 3
	//$Arg0 "Type"
	//$Arg0Tooltip "Pickup the desired shape\nNormal: 0\nDestroyed: 1\nCrashed: 2\nBoom: 3"
	+CANPASS
	+DONTTHRUST
	+NOBLOODDECALS
	+SHOOTABLE
	+SOLID
	BloodType "TankSpark";
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Destroyed");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Crashed");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Boom");
		Normal: //fall through if set at 0
		MDLA A -1;
		Stop;
	Destroyed:
		MDLA B -1;
		Stop;
	Crashed:
		MDLA B 8 A_SpawnProjectile("DarkSmoke2",Scale.X*8,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	Boom: //this is used mainly for c2m4 - ozy81
		TNT1 A 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" A 0 A_UnSetSolid;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Tank", random(64,112), random(64,112), random(128,144), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("Nuke",0,0,5,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 1 A_SpawnItemEx("KaBoomer",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS);
		Dead:
		MDLA B 8 A_SpawnProjectile("DarkSmoke3",Scale.X*8,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	}
}

class CODStuka_Flight : CODStuka
{	Default
	{
	Projectile;
	Speed 1;
	Height 1;
	Radius 1;
	}
}

class CODStuka_Flight_Fog : CODStuka_Flight { Default { DistanceCheck "boa_scenelod"; } }

class CODStukaF : Furniture_End3d
{	Default
	{
	//$Title Stuka Airplane (no lod)
	}
	States
	{
	Spawn:
		MDLA A 8 A_SpawnProjectile("DarkSmoke2",Scale.X*8,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(70,130));
		Loop;
	}
}

class COD_StukaBomb1 : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Scenery
	//$Title Stuka Bomb
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 16;
	Height 16;
	+NOGRAVITY
	}
}

class COD_StukaBomb2 : COD_StukaBomb1
{	Default
	{
	//$Title Stuka Bombs, Pile
	Radius 32;
	Height 64;
	}
}

class COD_StukaBomb2HH : COD_StukaBomb1
{	Default
	{
	//$Title Stuka Bombs, Pile (Half Height for C3M5_B)
	Radius 32;
	Height 32;
	}
}

class CODStuka_Deco : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Planes
	//$Title Stuka Airplane, Decorative
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class TMPlane : ModelBase
{	Default
	{
	//$Category Cutscenes (BoA)
	//$Title Titlemap Stuka
	//$Color 0
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class CODCondor : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Planes
	//$Title German Condor Focke-Wulf FW200 Bomber
	//$Color 3
	DistanceCheck "boa_scenelod";
	RenderRadius 512;
	Radius 8;
	Height 8;
	}
}

class CODCondor_Deco : MuseumBase
{	Default
	{
	//$Category Models (BoA)/Planes
	//$Title German Condor Focke-Wulf FW200 Bomber, Decorative
	DistanceCheck "boa_scenelod";
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class CODSideCar : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title SideCar
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 56;
	Height 48;
	}
}

class CODSideCarD : CODSideCar
{	Default
	{
	//$Title SideCar (Destroyed)
	}
}

class CODCivCarD_Spawner : Obstacle3d
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Civilian Car Spawner (Destroyed)
	//$Color 3
	//$Arg0 "Color"
	//$Arg0Tooltip "Pickup the desired color\nRandom: 0\nTan: 1\nRed: 2\nBlue: 3"
	DistanceCheck "boa_scenelod";
	Height 64;
	+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0]==1, "Tan");
		TNT1 A 0 A_JumpIf(Args[0]==2, "Red");
		TNT1 A 0 A_JumpIf(Args[0]==3, "Blue");
	Random: //fall through if set at 0
		MDLA A -1 A_Jump(128,1);
		MDLA B -1 A_Jump(128,1);
		MDLA C -1;
		Stop;
	Tan:
		MDLA A -1;
		Stop;
	Red:
		MDLA B -1;
		Stop;
	Blue:
		MDLA C -1;
		Stop;
	}
}

class CODScheinwerfer : SwitchableDecoration
{	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Scheinwerfer (Set DORMANT & activate it via ACS)
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 64;
	Height 80;
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
	BloodType "TankSpark";
	}
	States
	{
	Active:
		MDLA A 0 {bDormant = FALSE;} //update manually on GZDB
	Spawn:
		MDLA A -1 LIGHT("SPOTLITE") A_SpawnItemEx("Flare3d", Scale.X*28, 0, Scale.Y*92, 0, 0, 0, 0, MODELS_FLAGS2, 0, tid);
		Stop;
	Inactive:
		MDLA B -1 {bDormant = TRUE;} //update manually on GZDB
		Stop;
	}
}