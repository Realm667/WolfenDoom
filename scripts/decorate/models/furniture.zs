/*
 * Copyright (c) 2019-2021 Ozymandias81
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

//Ozy models from scratch or revamped
class BoATable1 : MuseumBase
{
	Default
	{
		//$Category Furniture (BoA)
		//$Title BoA Table 1
		//$Color 3
	}
}

class BoATable2 : MuseumBase
{
	Default
	{
		//$Category Furniture (BoA)
		//$Title BoA Office Desk 1
		//$Color 3
	}
}

class Radiator_Short: SceneryBase
{
	Default
	{
		//$Category Furniture (BoA)
		//$Title Radiator (short)
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 4;
		Height 32;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class Radiator_Long : Radiator_Short
{
	Default
	{
		//$Title Radiator (long, USE SELF-REFERENCED SECTORS)
	}
}

class BlowTorch : Furniture3d
{
	Default
	{
		//$Title BlowTorch
		Radius 4;
		Height 16;
		+SOLID
	}
}

class ModelCampBed : Furniture3d
{
	Default
	{
		//$Title Camp Bed (double)
		Radius 24;
	}
}

class ModelCampBed2 : ModelCampBed
{
	Default
	{
		//$Title Camp Bed (single)
		Height 24;
	}
}

//DoomJuan Models, added & fixed a bit by Ozymandias81
class RTCWBench : Furniture3d
{
	Default
	{
		//$Title Bench, Wooden
		Radius 16;
		Height 8;
	}
}

class RTCWBench2 : RTCWBench
{
	Default
	{
		//$Title Bench, Metallic
	}
}

class RTCWChair1 : Furniture3d
{
	Default
	{
		//$Title Ornated Wooden Chair
		Radius 8;
		Height 32;
	}
}

class RTCWChair1D : RTCWChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wooden Chair (wartorn)
	}
}

class RTCWChair2 : RTCWChair1
{
	Default
	{
		//$Title Herr Direktor Chair
	}
}

class RTCWChair2D : RTCWChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Herr Direktor Chair (wartorn)
	}
}

class RTCWChair3 : RTCWChair1
{
	Default
	{
		//$Title Ornated Wooden Seat
	}
}

class RTCWChair3D : RTCWChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wooden Seat (wartorn)
	}
}

class RTCWChair3DF : Furniture_End3d
{
	Default
	{
		//$Title Ornated Wooden Seat (wartorn, no lod)
	}
}

class RTCWCouch1 : RTCWChair1
{
	Default
	{
		//$Title Ornated Wooden Chat Couch
	}
}

class RTCWCouch1D : RTCWChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wooden Chat Couch (wartorn)
	}
}

class RTCWCouch1DF : Furniture_End3d
{
	Default
	{
		//$Title Ornated Wooden Chat Couch (wartorn, no lod)
	}
}

class RTCWTable1 : RTCWChair1
{
	Default
	{
		//$Title Ornated Wooden Chat Table
		Height 24;
	}
}

class RTCWTable1D : RTCWChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wooden Chat Table (wartorn)
		Height 24;
	}
}

class RTCWTable1DF : Furniture_End3d
{
	Default
	{
		//$Title Ornated Wooden Chat Table (wartorn, no lod)
		Height 24;
	}
}

class RTCWTable2 : RTCWChair1
{
	Default
	{
		//$Title Ornated Wooden Side Table
	}
}

class RTCWTable2D : RTCWChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wooden Side Table (wartorn)
	}
}

class RTCWTable3 : RTCWChair1
{
	Default
	{
		//$Title Ornated Wooden Wall Table
	}
}

class RTCWTable3D : RTCWChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wooden Wall Table (wartorn)
	}
}

class TrestleTable : Furniture3d
{
	Default
	{
		//$Title Trestle Table
		Radius 40;
		Height 34;
	}
}

//TF3DM / 3dRegenerator Models
class ParkBench : RTCWBench
{
	Default
	{
		//$Title Park / City Street Bench A
	}
}

class ParkBench2 : RTCWBench
{
	Default
	{
		//$Title Park / City Street Bench B
	}
}

class ParkBench3 : RTCWBench
{
	Default
	{
		//$Title Park Stone Bench
		Height 12;
	}
}

class Bunk_Bed1 : Furniture3d
{
	Default
	{
		//$Title Bunk Bed (single)
		Radius 24;
		Height 24;
	}
}

class Bunk_Bed2 : Bunk_Bed1
{
	Default
	{
		//$Title Bunk Bed (double)
		Height 72;
	}
}

//COD stuff
class COD_Drafting : Furniture3d
{
	Default
	{
		//$Title Drafting Table
		Radius 32;
		Height 32;
		+NOGRAVITY
	}
}

class COD_Refrigerator : Furniture3d
{
	Default
	{
		//$Title Refrigerator
		Radius 16;
		Height 80;
	}
}

class COD_BunkerPhone : Furniture3d
{
	Default
	{
		//$Title Bunker, Phone
		Radius 8;
		Height 32;
		+NOGRAVITY
	}
}

class COD_BunkerSeat : Furniture3d
{
	Default
	{
		//$Title Bunker, Seat
		Radius 8;
		Height 16;
	}
}

class COD_BunkerTable : Furniture3d
{
	Default
	{
		//$Title Bunker, Table
		Radius 32;
		Height 32;
	}
}

class COD_Dresser1 : Furniture3d
{
	Default
	{
		//$Title Ornated Dresser
		Radius 8;
		Height 56;
	}
}

class COD_Dresser1D : COD_Dresser1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Dresser, burnt (USE SELF-REFERENCED SECTORS)
		Height 8;
	}
}

class COD_Dresser1DF : Furniture_End3d
{
	Default
	{
		//$Title Ornated Dresser, burnt (no lod)
	}
}

class COD_ArmChair : Furniture3d
{
	Default
	{
		//$Title Ornated French Chair
		Radius 8;
		Height 32;
	}
}

class COD_ArmChairD : COD_ArmChair
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated French Chair, burnt
		Height 24;
	}
}

class COD_ArmChairDF : Furniture_End3d
{
	Default
	{
		//$Title Ornated French Chair, burnt (no lod)
	}
}

class COD_WriTable1 : Furniture3d
{
	Default
	{
		//$Title Ornated Writing Table
		Radius 32;
		Height 40;
	}
}

class COD_WriTable1D : COD_WriTable1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Writing Table, torn
	}
}

class COD_WriTable1DF : Furniture_End3d
{
	Default
	{
		//$Title Ornated Writing Table, torn (no lod)
	}
}

class COD_Piano1 : Furniture3d
{
	Default
	{
		//$Title Ornated Piano
		RenderRadius 128;
		Radius 32;
		Height 72;
	}
}

class COD_Piano1D : COD_Piano1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Piano, burnt
	}
}

class COD_Piano1DF : Furniture_End3d
{
	Default
	{
		//$Title Ornated Piano, burnt (no lod)
		RenderRadius 128;
	}
}

class COD_SideTable1 : Furniture3d
{
	Default
	{
		//$Title Ornated Side Table
		Radius 8;
		Height 16;
	}
}

class COD_SideTable1D : COD_SideTable1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Side Table, torn
	}
}

class COD_LongTable1 : Furniture3d
{
	Default
	{
		//$Title Ornated Long Table (USE SELF-REFERENCED SECTORS)
		Radius 32;
		Height 48;
	}
}

class COD_LongTable1D : COD_LongTable1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Long Table, torn (USE SELF-REFERENCED SECTORS)
		Radius 16;
		Height 56;
	}
}

class COD_Rolltop1 : Furniture3d
{
	Default
	{
		//$Title Ornated Rolltop Desk
		Radius 32;
		Height 48;
	}
}

class COD_Rolltop1D : COD_Rolltop1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Rolltop Desk, torn (USE SELF-REFERENCED SECTORS)
	}
}

class COD_WallTable1 : Furniture3d
{
	Default
	{
		//$Title Ornated Wall Table 1
		Radius 16;
		Height 32;
	}
}

class COD_WallTable1D : COD_WallTable1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wall Table 1, torn (USE SELF-REFERENCED SECTORS)
	}
}

class COD_WallTable2 : COD_WallTable1
{
	Default
	{
		//$Title Ornated Wall Table 2
	}
}

class COD_WallTable2D : COD_WallTable1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wall Table 2, torn (USE SELF-REFERENCED SECTORS)
	}
}

class COD_OrnateClock1 : Furniture3d
{
	Default
	{
		//$Title Ornated Clock
		Radius 16;
		Height 24;
	}
}

class COD_OrnateClock2 : Furniture3d
{
	Default
	{
		//$Title Ornated Table Clock
		Radius 8;
		Height 8;
	}
}

class COD_Cabinet1 : Furniture3d
{
	Default
	{
		//$Title Ornated Wooden Cabinet
		Radius 16;
		Height 96;
	}
}

class COD_Cabinet1D : COD_Cabinet1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Wooden Cabinet, burnt
	}
}

class COD_Cabinet1DF : Furniture_End3d
{
	Default
	{
		//$Title Ornated Wooden Cabinet, burnt (no lod)
	}
}

class COD_OrnateChair1 : RTCWChair1
{
	Default
	{
		//$Title Ornated Chair
	}
}

class COD_OrnateChair1D : COD_OrnateChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Chair, ruined
	}
}

class COD_OrnateChair2 : RTCWChair1
{
	Default
	{
		//$Title Ornated Chair with Nazi Eagle
	}
}

class COD_OrnateChair2D : COD_OrnateChair1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Ornated Chair with Nazi Eagle, ruined
	}
}

class COD_Shelve1 : Furniture3d
{
	Default
	{
		//$Title Wooden Shelves (USE SELF-REFERENCED SECTORS)
		Radius 8;
		Height 8;
	}
}

class COD_Shelve1D : COD_Shelve1
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Wooden Shelves, burnt (USE SELF-REFERENCED SECTORS)
	}
}

class COD_Shelve1DF : Furniture_End3d
{
	Default
	{
		//$Title Wooden Shelves, burnt (no lod)
	}
}

//Talon1024 stuff
class HitlersDesk : MuseumBase
{
	Default
	{
		//$Category Furniture (BoA)
		//$Title Hitler's Desk
		//$Color 3
	}
}

class HitlersDesk2 : MuseumBase
{
	Default
	{
		//$Category Furniture (BoA)/Wartorn
		//$Title Hitler's Desk (wartorn)
		//$Color 3
	}
}