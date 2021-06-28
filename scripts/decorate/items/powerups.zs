/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, AFADoomer, Talon1024
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

class PowerScuba : PowerMaskProtection
{
	Default
	{
		DamageFactor "Drowning", 0;
		DamageFactor "MutantPoisonAmbience", 0;
		DamageFactor "UndeadPoisonAmbience", 0;
		DamageFactor "IceWater", 0;
	}

	override void DoEffect()
	{
		owner.player.mo.ResetAirSupply();
		Overlay.Init(owner.player, "STSCUBA", 2, 0, 0, 1.0, 0, Overlay.Force320x200 | Overlay.LightEffects);

		Super.DoEffect();
	}

	override double GetSpeedFactor() 
	{ 
		if (owner && owner.waterlevel < 2) { return 0.5; } // Slow speed due to limited mobility outside of water
		return 2.0; // But much faster when in the water with fins
	}
}

class ScubaGearGiver : PowerupToggler
{
	Default
	{
		//$Category Powerups (BoA)
		//$Title Scuba Gear ("Underwater" protection)
		//$Color 6
		Height 32;
		Scale 0.65;
		Inventory.Icon "SCUBA0";
		Inventory.MaxAmount 1;
		Inventory.PickupMessage "$SCUBA2";
		Inventory.PickupSound "pickup/uniform";
		Powerup.Duration -600;
		Powerup.Color "45 60 96", 0.125;
		Powerup.Type "PowerScuba";
		Tag "$TAGSCUBA";
		+INVENTORY.INVBAR
		+INVENTORY.UNDROPPABLE
	}

	States
	{
		Spawn:
			SCUB A -1;
			Stop;
	}

	override bool Use(bool pickup)
	{
		if (!powerinv)
		{
			// Override other masks - Only one can be active at a time!
			let mask = owner.FindInventory("PowerMaskProtection", true);
			if (mask) { mask.Destroy(); }
		}

		return Super.Use(pickup);
	}
}

class SpaceSuit : PowerupGiver
{
	Default
	{
		//$Category Powerups (BoA)
		//$Title Space Suit ("IceWater" protection)
		//$Color 6
		Scale 0.50;
		Inventory.MaxAmount 0;
		Inventory.PickupMessage "$SCUBA1";
		Inventory.RespawnTics 1050; //30 seconds
		Inventory.UseSound "pickups/suite";
		Powerup.Color "64 64 64", .20;
		Powerup.Duration -150;
		Powerup.Type "PowerSpaceSuit";
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.ALWAYSRESPAWN
		+INVENTORY.AUTOACTIVATE
	}

	States
	{
		Spawn:
			SSUT A -1;
			Stop;
	}

	override bool Use(bool pickup)
	{
		// Override other masks - Only one can be active at a time!
		let mask = owner.FindInventory("PowerMaskProtection", true);
		if (mask) { mask.Destroy(); }

		return Super.Use(pickup);
	}
}

class C4 : CompassItem
{
	Default
	{
		//$Category Powerups (BoA)
		//$Title C4 Explosives (pickups)
		//$Color 6
		Scale 0.50;
		Inventory.PickupMessage "$C4PACK";
		Inventory.Icon "I_C4";
		Inventory.MaxAmount 10;
		Tag "$TAGCOMPB";
	}
	States
	{
	Spawn:
		C4__ A -1;
		Stop;
	}
}

class Power : Inventory
{
	Default
	{
		+INVENTORY.UNDROPPABLE
		Inventory.Amount 1;
		Inventory.MaxAmount 2400; //Near 1 mins maximum - ozy81
	}
}

class AdrenalineSpeed : PowerupGiver
{
	Default
	{
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ADDITIVETIME
		-INVENTORY.INVBAR
		Inventory.MaxAmount 0;
		Powerup.Type "PowerDrugs";
	}
}

class PowerDrugs : PowerDoubleFiringSpeed
{
	Default
	{
		Inventory.Icon "ICO_FSPD";
		Powerup.Duration -10;
	}
}

class AdrenalineFactor : PowerupGiver
{
	Default
	{
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ADDITIVETIME
		-INVENTORY.INVBAR
		Inventory.MaxAmount 0;
		Powerup.Type "PowerFactor";
	}
}

class PowerFactor : PowerDamage
{
	Default
	{
		Inventory.Icon "ICO_DFAC";
		Powerup.Duration -10;
		DamageFactor "Normal", 2.0;
	}

	override void DoEffect()
	{
		Super.DoEffect();

		if (owner)
		{
			let drugs = PowerDrugs(owner.FindInventory("PowerDrugs"));
			if (drugs) { Overlay.Init(owner.player, "M_INJ", max(0, drugs.EffectTics - 36), 18, 18); 
			}
		}
	}
}

class AdrenalineKit : CustomInvBase
{
	Default
	{
		//$Title Adrenaline Kit (DamageFactor & FiringSpeed augmented)
		Tag "$TAGADREN";
		Inventory.Icon "ADRNB0";
		Inventory.MaxAmount 3;
		Inventory.PickupMessage "$ADREN";
		Inventory.UseSound "misc/p_pkup";
		+INVENTORY.INVBAR
	}
	States
	{
	Spawn:
		ADRN A -1;
		Stop;
	Use:
		"####" A 0 {A_GiveInventory("AdrenalineSpeed"); A_GiveInventory("AdrenalineFactor");}
		Stop;
	}
}

class DeployableMine : CustomInvBase
{
	Default
	{
		//$Title Deployable Mine
		Scale 1.0;
		Tag "$TAGMINES";
		Inventory.Icon "I_BOAM";
		Inventory.MaxAmount 5;
		Inventory.PickupMessage "$DEPMINE";
		Inventory.PickupSound "misc/ammo_pkup";
		+INVENTORY.INVBAR
	}

	States
	{
		Spawn:
			BOAM A -1;
			Stop;
		Use:
			"####" A 0 {
				bool sp;
				Actor mo;
				[sp, mo] = A_SpawnItemEx("PlacedMine", radius + 32);

				if (sp && mo) { mo.tracer = self; }
			}
			Stop;
		}
}

class LanternOil : Inventory
{
	Default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 12000; //Near 5 mins maximum - ozy81
	}
}

class OilPickup : CustomInvBase
{
	Default
	{
		//$Title Lantern Oil
		-INVENTORY.INVBAR
		Inventory.MaxAmount 12; //1000x12=12000
		Inventory.PickupMessage "$OILPICK";
		Inventory.PickupSound "misc/ammo_pkup";
	}
	States
	{
	Spawn:
		LANT C -1;
		Loop;
	Pickup:
		TNT1 A 0 A_GiveInventory("LanternOil", 1000);
		Stop;
	}
}

class Rune_Fa : Soul
{
	Default
	{
		//$Title Soul Rune, Fa (+100)
		Scale 1.0;
		Inventory.Amount 100;
		Inventory.MaxAmount 1;
		Inventory.PickupMessage "$RUNEFA";
		+COUNTITEM
		+FLOATBOB
		+NOGRAVITY
	}
	States
	{
	Spawn:
		RUNE A -1;
		Loop;
	}
}

class Rune_Gibor : Rune_Fa
{
	Default
	{
		//$Title Soul Rune, Gibor (+100)
		Inventory.PickupMessage "$RUNEGBR";
	}
	States
	{
	Spawn:
		RUNE B -1;
		Loop;
	}
}

class Rune_Tyr : Rune_Fa
{
	Default
	{
		//$Title Soul Rune, Tyr (+100)
		Inventory.PickupMessage "$RUNETYR";
	}
	States
	{
	Spawn:
		RUNE C -1;
		Loop;
	}
}

class Rune_Fa_Small : Rune_Fa
{
	Default
	{
		//$Title Soul Rune, Fa (Small, +20)
		Scale .5;
		Inventory.Amount 20;
	}
}

class Rune_Gibor_Small : Rune_Gibor
{
	Default
	{
		//$Title Soul Rune, Gibor (Small, +20)
		Scale .5;
		Inventory.Amount 20;
	}
}

class Rune_Tyr_Small : Rune_Tyr
{
	Default
	{
		//$Title Soul Rune, Tyr (Small, +20)
		Scale .5;
		Inventory.Amount 20;
	}
}