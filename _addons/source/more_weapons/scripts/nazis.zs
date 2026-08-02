class WOfficer_Replacer: RandomSpawner replaces WOfficer
{
	Default {
		DropItem "WOfficer_Pistol", 255, 7;
		DropItem "WOfficer_Kampfpistole", 255, 1;
	}
}

class WOfficer_Pistol: WOfficer {}

class WOfficer_Kampfpistole : WOfficer
{
	Default {
		-MISSILEEVENMORE
		-MISSILEMORE
		DropItem "Kampfpistole", 128;
		DropItem "NebAmmo", 128;
	}
	States
	{
	Missile:
		"####" E 4 A_FaceTarget;
	Missile.Aimed:
		"####" FFF 4 A_FaceTarget;
		"####" F 4 A_FaceTarget;
		"####" F 0 { A_StartSound("clusterbomb/fire", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" F 5 LIGHT("NAZIFIRE") A_ArcProjectile("Sprengpatrone_Enemy",32,0,frandom(-4,4));
		"####" G 0 { return ResolveState("Reload"); }
		"####" F 3;
		"####" F 0 A_Jump(256,"See");
		Stop;
	}
}

class SSOfficer_Replacer: RandomSpawner replaces SSOfficer
{
	Default {
		DropItem "SSOfficer_Pistol", 255, 7;
		DropItem "SSOfficer_Kampfpistole", 255, 1;
	}
}

class SSOfficer_Pistol: SSOfficer {}

class SSOfficer_Kampfpistole : SSOfficer
{
	Default {
		-MISSILEEVENMORE
		-MISSILEMORE
		DropItem "Kampfpistole", 128;
		DropItem "NebAmmo", 128;
	}
	States
	{
	Missile:
		"####" E 4 A_FaceTarget;
	Missile.Aimed:
		"####" FFF 4 A_FaceTarget;
		"####" F 4 A_FaceTarget;
		"####" F 0 { A_StartSound("clusterbomb/fire", CHAN_WEAPON); A_AlertMonsters(512); }
		"####" F 5 LIGHT("NAZIFIRE") A_ArcProjectile("Sprengpatrone_Enemy",32,0,frandom(-4,4));
		"####" G 0 { return ResolveState("Reload"); }
		"####" F 3;
		"####" F 0 A_Jump(256,"See");
		Stop;
	}
}

class WaffenSS_StG44: WaffenSS replaces WaffenSS
{
	Default {
		DropItem "KurzAmmo", 192;
		DropItem "GrenadePickup", 32;
		DropItem "StG44", 96;
	}
}

class ArcticWaffen_StG44: ArcticWaffen replaces ArcticWaffen
{
	Default {
		DropItem "KurzAmmo", 192;
		DropItem "GrenadePickup", 32;
		DropItem "StG44", 96;
	}
}

class Paratrooper_Replacer: RandomSpawner replaces Paratrooper
{
	Default {
		DropItem "Paratrooper_StG44", 255, 2;
		DropItem "Paratrooper_FG42", 255, 1;
	}
}

class Paratrooper_StG44: Paratrooper
{
	Default {
		DropItem "KurzAmmo", 192;
		DropItem "StG44", 96;
	}
}

class Paratrooper_FG42: Paratrooper
{
	Default {
		DropItem "MauserAmmo", 192;
		DropItem "FG42", 96;
	}
}

class SneakableWaffenSS_StG44: SneakableWaffenSS replaces SneakableWaffenSS
{
	Default {
		DropItem "KurzAmmo", 192;
		DropItem "GrenadePickup", 32;
		DropItem "StG44", 96; //drops only the weapon anyway
	}
}

class WereWaffenSS_StG44: WereWaffenSS replaces WereWaffenSS
{
	Default {
		DropItem "KurzAmmo", 192;
		DropItem "GrenadePickup", 32;
		DropItem "StG44", 96;
	}
}