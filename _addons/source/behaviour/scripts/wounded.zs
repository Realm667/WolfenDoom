
class Grenade_WGuard_Wounded: WGuard_Wounded replaces WGuard_Wounded
{
	//Default { Obituary "$WNDWGUARD"; }
	States
	{
	Missile:
		"####" "#" 0 A_Jump(128, "Grenade");
		Goto WGuard_Wounded::Missile;
	Grenade:
		"####" "#" 15 A_FaceTarget;
		"####" "#" 12 A_SpawnProjectile("VerySlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION);
		//too exhausted to arcprojectile
		Goto SeeLoop;
	}
}

class Grenade_WGuard_Wounded_NoCount : Grenade_WGuard_Wounded replaces WGuard_Wounded_NoCount { Default {-COUNTKILL} States { Death: Goto Death_NoCount; } }

class Grenade_Guard_Wounded : Grenade_WGuard_Wounded replaces Guard_Wounded { Default { Obituary "$WNDGUARD"; } States { Spawn: GARD O 0; Goto Spawn.Loop; } }

class Grenade_Guard_Wounded_NoCount : Grenade_Guard_Wounded replaces Guard_Wounded_NoCount { Default {-COUNTKILL} States { Death: Goto Death_NoCount; } }

class Grenade_SSGuard_Wounded : Grenade_WGuard_Wounded replaces SSGuard_Wounded { Default { Obituary "$WNDSSGUARD"; } States { Spawn: SSPG O 0; Goto Spawn.Loop; } }

class Grenade_SSGuard_Wounded_NoCount : Grenade_SSGuard_Wounded replaces SSGuard_Wounded_NoCount { Default {-COUNTKILL} States { Death: Goto Death_NoCount; } }

class Grenade_Officer_Wounded : Grenade_WGuard_Wounded replaces Officer_Wounded { Default { Obituary "$WNDOFFICER"; } States { Spawn: OFFI O 0; Goto Spawn.Loop; } }

class Grenade_Officer_Wounded_NoCount : Grenade_Officer_Wounded replaces Officer_Wounded_NoCount { Default {-COUNTKILL} States { Death: Goto Death_NoCount; } }

class Grenade_SSOfficer_Wounded : Grenade_WGuard_Wounded replaces SSOfficer_Wounded { Default { Obituary "$WNDSSOFFICER"; } States { Spawn: SSOF O 0; Goto Spawn.Loop; } }

class Grenade_SSOfficer_Wounded_NoCount : Grenade_SSOfficer_Wounded replaces SSOfficer_Wounded_NoCount { Default {-COUNTKILL} States { Death: Goto Death_NoCount; } }

class Grenade_WOfficer_Wounded : Grenade_WGuard_Wounded replaces WOfficer_Wounded { Default { Obituary "$WNDWOFFICER"; } States { Spawn: OFR2 O 0; Goto Spawn.Loop; } }

class Grenade_WOfficer_Wounded_NoCount : Grenade_WOfficer_Wounded replaces WOfficer_Wounded_NoCount { Default {-COUNTKILL} States { Death: Goto Death_NoCount; } }