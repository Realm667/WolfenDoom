/*
 * Copyright (c) 2018-2021 Ozymandias81, AFADoomer, Tormentor667, Talon1024
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

class Akten : CompassItem
{
	Default
	{
		//$Title Secret Files (Tunis)
		Tag "$TAGFILES";
		CompassItem.SpecialClue 3; // This folder gets re-used as a zombie clue in C3, so needs that special handling.  The number acts as a chapter filter for the special stats board drawing effects.
		Inventory.Icon "AKTTA0";
		Inventory.PickupMessage "$AKTEN";
	}
	States
	{
	Spawn:
		AKTT B -1;
		Stop;
	}
}

class AktenEisenmann : CompassItem
{
	Default
	{
		//$Title Secret Files (Eisenmann)
		Tag "$TAGEISEN";
		CompassItem.SpecialClue 1;
		Inventory.Icon "AKTEA0";
		Inventory.PickupMessage "$EISEN";
		Inventory.MaxAmount 5;
	}
	States
	{
	Spawn:
		AKTE B -1;
		Stop;
	}
}

class AktenV2 : CompassItem
{
	Default
	{
		//$Title Secret Files (V2 Base)
		Tag "$TAGTHORS";
		Inventory.Icon "AKT2A0";
		Inventory.PickupMessage "$THORS";
	}
	States
	{
	Spawn:
		AKT2 B -1;
		Stop;
	}
}

class AktenDream : CompassItem
{
	Default
	{
		//$Title Secret Files (Dream)
		Tag "$TAGZOMB";
		Inventory.Icon "AKT3A0";
		Inventory.PickupMessage "$DREAM";
		-INVENTORY.INVBAR
	}
	States
	{
	Spawn:
		AKT3 B -1;
		Stop;
	Remove:
		AKT3 B 1 A_FadeOut(0.05);
		Loop;
	}
}

class AktenDreamClue : CompassItem
{
	Default
	{
		//$Title Secret Files (Clue)
		Tag "$TAGZOMBC";
		CompassItem.SpecialClue 3;
		Inventory.Icon "AKT3A0";
		Inventory.PickupMessage "$ZOMBF";
		Inventory.MaxAmount 2;
	}
	States
	{
	Spawn:
		AKT3 B -1;
		Stop;
	}
}

class ArtifactAstrostrein : CompassItem
{
	Default
	{
		//$Title Mayan Artifact (Astrostein)
		Scale 0.25;
		Tag "$TAGMAYAN";
		CompassItem.SpecialClue 2;
		Inventory.Icon "ARTMA0";
		Inventory.PickupMessage "$MAYAN";
		Inventory.MaxAmount 5;
		Inventory.PickupSound "misc/mayan_pickup";
	}
	States
	{
	Spawn:
		ARTM B -1;
		Stop;
	}
}

class ArtifactAstrostreinIM: Actor
{
	Default
	{
		//$Category Pickups (BoA)
		//$Title Mayan Artifact (Astrostein, placed)
		//$Color 13
		Radius 4;
		Height 8;
		-SOLID
		Scale 0.25;
	}
	States
	{
	Spawn:
		ARTM B -1;
		Stop;
	}
}

class ArtifactEgyptian : CompassItem
{
	Default
	{
		//$Title Egyptian Artifact (C1M6)
		Scale 0.25;
		Tag "$TAGSUND1";
		Inventory.Icon "ARTEA0";
		Inventory.PickupMessage "$EGYPT";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/mayan_pickup";
		CompassItem.Alternates "ArtifactEgyptian_H1", "ArtifactEgyptian_H2";
	}
	States
	{
	Spawn:
		ARTE B -1;
		Stop;
	}
}

class ArtifactEgyptian_H1 : CompassItem
{
	Default
	{
		//$Title Egyptian Artifact, 1st half (C1M5)
		Scale 0.25;
		Tag "$TAGSUND2";
		+COUNTITEM
		Inventory.Icon "ARTEC0";
		Inventory.PickupMessage "$EGYPT";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/mayan_pickup";
	}
	States
	{
	Spawn:
		ARTE D -1;
		Stop;
	}
}

class ArtifactEgyptian_H2 : CompassItem
{
	Default
	{
		//$Title Egyptian Artifact, 2nd half (C1M5)
		Scale 0.25;
		Tag "$TAGSUND3";
		+COUNTITEM
		Inventory.Icon "ARTEE0";
		Inventory.PickupMessage "$EGYPT";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/mayan_pickup";
	}
	States
	{
	Spawn:
		ARTE F -1;
		Stop;
	}
}

class Cartridge : CompassItem
{
	int number;

	Property Number:number;

	Default
	{
		Scale 0.25;
		Inventory.PickupSound "ckeen/pickup";
	}

	override bool TryPickup (in out Actor toucher)
	{
		bool ret = Super.TryPickup(toucher);

		if (ret && toucher && toucher.player)
		{
			AchievementTracker tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
			if (tracker) { tracker.SetBit(tracker.records[tracker.STAT_CARTRIDGES].value, number); }
			
			AchievementTracker.CheckAchievement(toucher.PlayerNumber(), AchievementTracker.ACH_NEAT);
		}

		return ret;
	}
}

class Cartridge51 : Cartridge
{
	Default
	{
		//$Title Cartridge (for SM01)
		Tag "$TAGCART1";
		Inventory.Icon "SNSCA0";
		Inventory.PickupMessage "$KEENCART1";
		Cartridge.Number 0;
	}

	States
	{
		Spawn:
			SNSC B -1 NODELAY;
			Stop;
	}
}

class Cartridge52 : Cartridge
{
	Default
	{
		//$Title Cartridge (for SM02)
		Tag "$TAGCART2";
		Inventory.Icon "SNSCC0";
		Inventory.PickupMessage "$KEENCART2";
		Cartridge.Number 1;
	}

	States
	{
		Spawn:
			SNSC D -1 NODELAY;
			Stop;
	}
}

class Cartridge53 : Cartridge
{
	Default
	{
		//$Title Cartridge (for SM03)
		Tag "$TAGCART3";
		Inventory.Icon "SNSCE0";
		Inventory.PickupMessage "$KEENCART3";
		Cartridge.Number 2;
	}

	States
	{
		Spawn:
			SNSC F -1 NODELAY;
			Stop;
	}
}

class Crank : CompassItem
{
	Default
	{
		//$Title Crank (mech)
		Scale 0.25;
		Tag "$TAGCRANK";
		Inventory.Icon "KURBA0";
		Inventory.PickupMessage "$PUCRANK";
		Inventory.PickupSound "misc/gadget_pickup";
	}
	States
	{
	Spawn:
		KURB B -1;
		Stop;
	}
}

class RadioPickup : CompassItem
{
	Default
	{
		//$Title Field Radio
		Scale 0.4;
		Tag "$TAGRADIO";
		Inventory.PickupMessage "$RADIOF";
		Inventory.PickupSound "pickup/radiopk";
		-INVENTORY.INVBAR
	}
	States
	{
	Spawn:
		RADO A -1;
		Stop;
	}
}

class Kennkarte : CompassItem
{
	Default
	{
		//$Title Kennkarte (Scandinavia)
		Tag "$TAGKARTE";
		Inventory.Icon "KENKA0";
		Inventory.PickupMessage "$KENK";
	}
	States
	{
	Spawn:
		KENK B -1;
		Stop;
	}
}

class GrapplingHook : CompassItem
{
	Default
	{
		//$Title Grappling Hook
		Scale 0.4;
		Tag "$TAGHOOK";
		Inventory.PickupMessage "$HOOKM";
		Inventory.PickupSound "gadget_pickup";
		Inventory.Icon "ROPEB0";
	}
	States
	{
	Spawn:
		ROPE A -1;
		Stop;
	}
}

class ChutePickup : CompassItem
{
	Default
	{
		//$Title Parachute Bag
		Tag "$TAGCHUTE";
		Inventory.Icon "CHUTA0";
		Inventory.MaxAmount 2;
		Inventory.PickupMessage "$PCHUTE";
		Inventory.PickupSound "misc/p_pkup";
	}
	States
	{
	Spawn:
		CHUT B -1;
		Stop;
	}
}

class ChemicalsPickup : CompassItem
{
	Default
	{
		//$Title Chemical Ingredients
		Tag "$TAGCHEM";
		Inventory.Icon "CHEMA0";
		Inventory.PickupMessage "$PCHEM";
		Inventory.PickupSound "misc/p_pkup";
	}
	States
	{
	Spawn:
		CHEM B -1;
		Stop;
	}
}

class ScientistUniform : UniformStand
{
	Default
	{
		//$Category Pickups (BoA)
		//$Title Scientist Uniform (usable)
		//$Color 13
		UniformStand.UniformType "ScientistUniformToken";
	}
	States
	{
	Spawn:
		HNG1 B 0;
		Goto Inactive;
	}
}

class CCBJUniform : ScientistUniform
{
	Default
	{
		//$Title Concentration Camp Uniform (usable)
		UniformStand.UniformType "CCBJUniformToken";
	}
	States
	{
	Spawn:
		HNG2 C 0;
		Goto Inactive;
	}
}

class SSBJUniform : ScientistUniform
{
	Default
	{
		//$Title SS Uniform (usable)
		UniformStand.UniformType "SSBJUniformToken";
	}
	States
	{
	Spawn:
		HNG1 D 0;
		Goto Inactive;
	}
}

class ZombieArmClue : CompassItem
{
	Default
	{
		//$Title Zombie Arm (Clue)
		Tag "$TAGZARM";
		CompassItem.SpecialClue 3;
		Inventory.Icon "ZARMA0";
		Inventory.PickupMessage "$ZARM";
		Inventory.PickupSound "misc/armor_body";
	}
	States
	{
	Spawn:
		ZARM B -1;
		Stop;
	}
}

class ZombieHeadClue : ZombieArmClue
{
	Default
	{
		//$Title Zombie Head (Clue)
		Tag "$TAGZHED";
		Inventory.Icon "ZHEDA0";
		Inventory.PickupMessage "$ZHED";
	}
	States
	{
	Spawn:
		ZHED B -1;
		Stop;
	}
}

class MineralClue : ZombieArmClue
{
	Default
	{
		//$Title Mineral (Clue)
		Tag "$TAGMINR";
		Inventory.Icon "MINRA0";
		Inventory.MaxAmount 2;
		Inventory.PickupMessage "$ZMINR";
		Inventory.PickupSound "pickup/armorshard";
	}
	States
	{
	Spawn:
		MINR B -1;
		Stop;
	}
}

class RyanIDs : SwitchableDecoration
{
	Default
	{
		//$Category Props (BoA)/Mission
		//$Title Ryan IDs (ARGs from 0 to 3)
		//$Color 11
		//$Sprite RYIDE0
		//$Arg0 "Type"
		//$Arg0Type 11
		//$Arg0Enum { 0 = "British ID"; 1 = "German ID"; 2 = "Intel ID"; 3 = "Military ID"; }
		Radius 8;
		Height 0;
		Scale 0.10;
		+FLATSPRITE
		+NOBLOCKMAP
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Active:
		TNT1 A 0 {bDormant = FALSE;} //mxd. DORMANT flag must be updated manually
	Spawn:
		TNT1 A 0 NODELAY;
		TNT1 A 0 A_JumpIf(Args[0] == 1, "GerID");
		TNT1 A 0 A_JumpIf(Args[0] == 2, "IntID");
		TNT1 A 0 A_JumpIf(Args[0] == 3, "MilID");
	BriID:
		RYID A -1 A_SetPitch(180+Pitch);
		Stop;
	GerID:
		RYID B -1 A_SetPitch(180+Pitch);
		Stop;
	IntID:
		RYID C -1 A_SetPitch(180+Pitch);
		Stop;
	MilID:
		RYID D -1 A_SetPitch(180+Pitch);
		Stop;
	Inactive:
		TNT1 A 0 {bDormant = TRUE;} //mxd. DORMANT flag must be updated manually
	}
}
