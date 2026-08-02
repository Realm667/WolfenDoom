class EfficientAmmo : Ammo abstract
{
	Class<Ammo> AmmoType;
	property AmmoType: AmmoType;
	Actor activator;
	
	Default
	{
		EfficientAmmo.AmmoType "Ammo9mm";
		+USESPECIAL
		Radius 16;
		Height 16;
		Activation THINGSPEC_Switch; // no time to understand GZDoom code
	}
	
	States
	{
		Spawn:
		TNT1 A -1 NoDelay {
			sprite = GetDefaultByType(AmmoType).SpawnState.sprite;
			frame = GetDefaultByType(AmmoType).SpawnState.frame;
			scale = GetDefaultByType(AmmoType).scale;
		}
		Stop;
	}
	
	Override Class<Ammo> GetParentAmmo ()
	{
		class<Object> type = self.AmmoType;
		while (type.GetParentClass() != "Ammo" && type.GetParentClass() != NULL)
		{
			type = type.GetParentClass();
		}
		return (class<Ammo>)(type);
	}
	
	Override bool TryPickup(in out Actor Toucher)
	{
		let ToucherAmmo = Toucher.FindInventory(GetDefaultByType(self.AmmoType).GetParentAmmo());
		int ToucherAmount = ToucherAmmo ? ToucherAmmo.Amount : 0;
		int ToucherMax = ToucherAmmo ? ToucherAmmo.MaxAmount : GetDefaultByType(self.AmmoType).MaxAmount;
		int ToucherNeed = Abs(ToucherAmount - ToucherMax);
		Amount = bIgnoreSkill ? GetDefaultByType(AmmoType).Amount : (int) (GetDefaultByType(AmmoType).Amount * G_SkillPropertyFloat(SKILLP_AmmoFactor));
		if (activator && activator == Toucher) { return Super.TryPickup(Toucher); }
		if (Amount + ToucherAmount <= ToucherMax) { return Super.TryPickup(Toucher); }
		return bPickupGood;
	}
	
	override String PickupMessage () { return GetDefaultByType(AmmoType).PickupMessage(); }
	
	override void Activate (Actor a)
	{
		activator = a;
		if (a) { Touch(a); }
		activator = null;
	}
	
	override void Deactivate (Actor a)
	{
		activator = a;
		if (a) { Touch(a); }
		activator = null;
	}
}

class EfficientHealth : Health
{
	Class<Inventory> HealthType; //Health does not represent a class type. ???
	property HealthType: HealthType;
	Actor activator;
	
	Default
	{
		EfficientHealth.HealthType "Medikit_Small";
		+USESPECIAL
		Radius 16;
		Height 16;
		Activation THINGSPEC_Switch;
	}

	States
	{
		Spawn:
		TNT1 A -1 NoDelay {
			sprite = GetDefaultByType(HealthType).SpawnState.sprite;
			frame = GetDefaultByType(HealthType).SpawnState.frame;
			scale = GetDefaultByType(HealthType).scale;
		}
		Stop;
	}
	
	override bool TryPickup(in out Actor Toucher)
	{
		int ToucherAmount = Toucher.Health;
		int ToucherMax = Toucher.GetMaxHealth(true);
		Amount = GetDefaultByType(HealthType).Amount;
		if (activator && activator == Toucher) { return Super.TryPickup(Toucher); }
		if (self.Amount + ToucherAmount <= ToucherMax) { return Super.TryPickup(Toucher); }
		return bPickupGood;
	}
	
	override String PickupMessage () { return GetDefaultByType(HealthType).PickupMessage(); }
	
	override void Activate (Actor a)
	{
		activator = a;
		if (a) { Touch(a); }
		activator = null;
	}
	
	override void Deactivate (Actor a)
	{
		activator = a;
		if (a) { Touch(a); }
		activator = null;
	}
}


class EfficientAmmo9mm: EfficientAmmo { Default { EfficientAmmo.AmmoType "Ammo9mm"; } }
class EfficientAmmoBox9mm: EfficientAmmo { Default { EfficientAmmo.AmmoType "AmmoBox9mm"; } }
class EfficientAmmo12Gauge: EfficientAmmo { Default { EfficientAmmo.AmmoType "Ammo12Gauge"; } }
class EfficientAmmoBox12Gauge: EfficientAmmo { Default { EfficientAmmo.AmmoType "AmmoBox12Gauge"; } }
class EfficientMauserAmmo: EfficientAmmo { Default { EfficientAmmo.AmmoType "MauserAmmo"; } }
class EfficientMauserAmmoBox: EfficientAmmo { Default { EfficientAmmo.AmmoType "MauserAmmoBox"; } }
class EfficientFlameAmmo: EfficientAmmo { Default { EfficientAmmo.AmmoType "FlameAmmo"; } }
class EfficientNebAmmo: EfficientAmmo { Default { EfficientAmmo.AmmoType "NebAmmo"; } }
class EfficientNebAmmoBox: EfficientAmmo { Default { EfficientAmmo.AmmoType "NebAmmoBox"; } }
class EfficientPanzerAmmo: EfficientAmmo { Default { EfficientAmmo.AmmoType "PanzerAmmo"; } }
class EfficientTeslaCell: EfficientAmmo { Default { EfficientAmmo.AmmoType "TeslaCell"; } }
class EfficientTeslaCellBox: EfficientAmmo { Default { EfficientAmmo.AmmoType "TeslaCellBox"; } }
class EfficientAstroShotgunShell: EfficientAmmo { Default { EfficientAmmo.AmmoType "AstroShotgunShell"; } }
class EfficientAstroRocketAmmo: EfficientAmmo { Default { EfficientAmmo.AmmoType "AstroRocketAmmo"; } }
class EfficientAstroClipAmmo: EfficientAmmo { Default { EfficientAmmo.AmmoType "AstroClipAmmo"; } }

class EfficientMedikit_Small: EfficientHealth { Default { EfficientHealth.HealthType "Medikit_Small"; } }
class EfficientMedikit_Medium: EfficientHealth { Default { EfficientHealth.HealthType "Medikit_Medium"; } }
class EfficientMedikit_Large: EfficientHealth { Default { EfficientHealth.HealthType "Medikit_Large"; } }
class EfficientAstroMedikit: EfficientHealth { Default { EfficientHealth.HealthType "AstroMedikit"; } }
//add addon stg44 ammo