
class FG42 : NaziWeapon
{
	Default
	{
		Scale 0.45;
		Weapon.AmmoType "FG42Loaded";
		Weapon.AmmoUse 1;
		Weapon.AmmoType2 "MauserAmmo";
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive2 20;
		Weapon.UpSound "mauser/select";
		Inventory.PickupMessage "$FG42";
		Weapon.SelectionOrder 50;
		+WEAPON.NOAUTOFIRE
		Tag "FG 42";
	}
	States
	{
	Ready:
		42FG A 0 A_JumpIfInventory("SniperZoom",1,"ScopedReady");
		42FG A 0 A_JumpIfInventory("FG42Loaded",0,2);
		42FG A 0 A_JumpIfInventory("MauserAmmo",1,2);
		42FG A 1 A_WeaponReady;
		Loop;
		42FG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	ScopedReady:
		SCO1 A 0 A_JumpIfInventory("FG42Loaded",0,2);
		SCO1 A 0 A_JumpIfInventory("MauserAmmo",1,2);
		SCO1 A 1 A_WeaponReady(WRF_NOBOB);
		Goto Ready;
		SCO1 A 1 A_WeaponReady(WRF_NOBOB|WRF_ALLOWRELOAD);
		Goto Ready;
	Select:
		42FG A 0 A_Raise;
		42FG A 1 A_Raise;
		Loop;
	Deselect:
		42FG A 0 A_JumpIfReloading(4);
		42FG A 0 A_JumpIfInventory("SniperZoom",1,"ScopedDeselect");
		42FG A 0 A_Lower;
		42FG A 1 A_Lower;
		Loop;
		42FG T 3 Offset(0,60) A_StartSound("mauser/shut", CHAN_5);
		42FG S 3 Offset(0,51);
		42FG R 3 Offset(0,42);
		42FG A 2 Offset(0,36);
		42FG A 2 Offset(0,33) A_Reloading(0);
		Loop;
	ScopedDeselect:
		SCO1 A 0 A_TakeInventory("SniperZoom");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 1 A_ZoomFactor(1.0);
		Goto Deselect;
	Fire:
		42FG A 0 A_JumpIfReloading("ReloadEnd");
		42FG A 0 A_JumpIfInventory("FG42Loaded",1,1);
		Goto Dryfire;
		42FG A 0 A_AlertMonsters;
		42FG A 0 A_StartSound("fg42/fire", CHAN_WEAPON); // fg42/fire
		42FG A 0 A_SpawnItemEx("MauserRifleCasing",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		42FG A 0 A_JumpIfInventory("SniperZoom", 1, "ScopedFire");
		42FG A 0 A_GunFlash;
		42FG A 2 A_FireProjectile("Kar98kTracer",frandom(-0.1,0.1));
		42FG A 0 A_JumpIf(waterlevel > 0,2);
		42FG A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		42FG A 2 Offset(0,40) A_SetPitch(pitch-(2.0*boa_recoilamount));
		42FG A 2 Offset(0,36) A_SetPitch(pitch-(1.0*boa_recoilamount));
		42FG A 1 A_SetPitch(pitch+(1.5*boa_recoilamount));
		42FG A 1 A_CheckReload;
		42FG A 0 A_Refire;
		Goto Ready;
	ScopedFire:
		SCO1 A 2 A_FireProjectile("Kar98kTracer",frandom(-0.1,0.1));
		SCO1 A 0 A_JumpIf(height<=30,"ScopedFireLowRecoil");
		SCO1 A 0 A_JumpIf(waterlevel > 0,2);
		SCO1 A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		SCO1 A 2 A_SetPitch(pitch-(2.0*boa_recoilamount));
		SCO1 A 2 A_SetPitch(pitch-(1.0*boa_recoilamount));
		SCO1 A 1 A_SetPitch(pitch+(1.5*boa_recoilamount));
		SCO1 A 1 A_CheckReload;
		SCO1 A 0 A_Refire;
		Goto Ready;
	ScopedFireLowRecoil:
		SCO1 A 0 A_JumpIf(waterlevel > 0,2);
		SCO1 A 0 A_FireProjectile("ShotSmokeSpawner",0,0,0,random(-4,4),0,0);
		SCO1 A 2 A_SetPitch(pitch-(1.5*boa_recoilamount));
		SCO1 A 2 A_SetPitch(pitch-(0.5*boa_recoilamount));
		SCO1 A 1 A_SetPitch(pitch+(0.75*boa_recoilamount));
		SCO1 A 1 A_CheckReload;
		SCO1 A 0 A_Refire;
		Goto Ready;
	Flash:
		42FF A 1 A_Light2;
		42FF B 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	AltFire:
		42FG A 0 A_JumpIfReloading("ReloadEnd");
		SCO1 A 0 A_JumpIfInventory("SniperZoom",1,"ZoomOut");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 0 A_GiveInventory("SniperZoom");
		SCO1 A 2 A_ZoomFactor(6.0);
		Goto Ready;
	ZoomOut:
		SCO1 A 0 A_TakeInventory("SniperZoom");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 2 A_ZoomFactor(1.0);
		Goto Ready;
	Reload:
		SCO1 A 0 A_Reloading;
		SCO1 A 0 A_JumpIfInventory("SniperZoom",1,2);
		SCO1 A 0 A_Jump(256,4);
		SCO1 A 0 A_TakeInventory("SniperZoom");
		SCO1 A 0 A_StartSound("mauser/scope");
		SCO1 A 2 A_ZoomFactor(1.0);
		42FG ARS 3;
		42FG T 3 A_StartSound("mauser/open", CHAN_5);
		42FG UVW 3;
		42FG X 21;
		42FG WVU 3;
		42FG T 3 A_StartSound("mauser/shut", CHAN_5);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("MauserAmmo",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("FG42Loaded");
		TNT1 A 0 A_JumpIfInventory("FG42Loaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("MauserAmmo",1,"ReloadLoop");
	ReloadFinish:
		42FG S 3;
		42FG Y 3 A_StartSound("fg42/load", CHAN_5);
		42FG ZY 3;
		42FG R 3;
		42FG A 5 A_Reloading(0);
		Goto Ready;
	Spawn:
		42FG P -1;
		Stop;
	}
}

class StG44 : NaziWeapon
{
	Default {
		Scale .5;
		Weapon.SelectionOrder 600;
		Weapon.AmmoType "StG44Loaded";
		Weapon.AmmoUse 1;
		Weapon.AmmoType2 "KurzAmmo";
		Weapon.AmmoUse2 1;
		Weapon.UpSound "mp40/select"; /////////////////////
		Tag "StG 44";
		Inventory.PickupMessage "$STG44";
		Weapon.AmmoGive2 30;
	}
	States
	{
	Ready:
		MP43 A 0 A_JumpIfInventory("StG44Loaded",0,2);
		MP43 A 0 A_JumpIfInventory("KurzAmmo",1,2);
		MP43 A 1 A_WeaponReady;
		Loop;
		MP43 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		MP43 A 0 A_Lower;
		MP43 A 1 A_Lower;
		Loop;
	Select:
		MP43 A 0 A_Raise;
		MP43 A 1 A_Raise;
		Loop;
	Fire:
		MP43 A 0 A_JumpIfInventory("StG44Loaded",1,1);
		Goto Dryfire;
		MP43 A 0 A_GunFlash;
		MP43 A 0 A_SetPitch(pitch-(0.5*boa_recoilamount));
		MP43 A 0 A_JumpIf(waterlevel > 0,2);
		MP43 A 0 A_FireProjectile("ChainSmokeSpawner",0,0,0,random(-4,4),0,0);
		MP43 A 0 A_StartSound("stg44/fire", CHAN_WEAPON, 0, frandom(0.6, 0.8));
		MP43 A 0 A_SpawnItemEx("MauserRifleCasing",12,-20,32,8,random(-2,2),random(0,4),random(-55,-80),SXF_NOCHECKPOSITION);
		MP43 A 0 A_AlertMonsters;
		MP43 A 1 A_FireProjectile("StG44Tracer",frandom(-1.4,1.4));
		MP43 A 1 Offset(0,38);
		MP43 A 1 Offset(0,44);
		MP43 A 1 Offset(0,40);
		TNT1 A 0 A_CheckReload;
		Goto Ready;
	Reload:
		MP43 A 1 Offset(0,35) A_StartSound("mauser/open", CHAN_5, 0, frandom(0.6, 0.8));
		MP43 A 1 Offset(0,38);
		MP43 A 1 Offset(0,44);
		MP43 A 1 Offset(0,52);
		MP43 A 1 Offset(-1,54);
		MP43 A 1 Offset(-2,56);
		MP43 A 1 Offset(-3,58);
		MP43 B 1 Offset(-4,58);
		MP43 B 1 Offset(-4,57);
		MP43 B 1 Offset(-3,54);
		MP43 B 1 Offset(-3,51);
		MP43 C 1 Offset(-3,53);
		MP43 C 1 Offset(-3,55);
		MP43 C 2 Offset(-3,56);
		MP43 D 6 Offset(-3,56) A_StartSound("stg44/load", CHAN_5, 0, frandom(0.6, 0.8));
		MP43 E 12 Offset(-3,56);
	ReloadLoop:
		TNT1 A 0 A_TakeInventory("KurzAmmo",1,TIF_NOTAKEINFINITE);
		TNT1 A 0 A_GiveInventory("StG44Loaded");
		TNT1 A 0 A_JumpIfInventory("StG44Loaded",0,"ReloadFinish");
		TNT1 A 0 A_JumpIfInventory("KurzAmmo",1,"ReloadLoop");
	ReloadFinish:
		MP43 D 5 Offset(-3,57);
		MP43 C 1 Offset(-3,59);
		MP43 C 1 Offset(-3,63);
		MP43 C 1 Offset(-3,67);
		MP43 B 1 Offset(-3,65);
		MP43 B 1 Offset(-3,62);
		MP43 B 1 Offset(-3,58);
		MP43 A 1 Offset(-3,55);
		MP43 A 1 Offset(-2,53);
		MP43 A 1 Offset(-2,49);
		MP43 A 1 Offset(-2,46);
		MP43 A 1 Offset(-2,45);
		MP43 A 1 Offset(-1,44);
		MP43 A 1 Offset(-1,46);
		MP43 A 1 Offset(-1,47);
		MP43 A 1 Offset(0,49) A_WeaponReady(WRF_NOBOB);
		MP43 A 1 Offset(0,44) A_WeaponReady(WRF_NOBOB);
		MP43 A 1 Offset(0,38) A_WeaponReady(WRF_NOBOB);
		MP43 A 1 Offset(0,35) A_WeaponReady(WRF_NOBOB);
		MP43 A 1 Offset(0,32) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Flash:
		MP43 F 1 A_Light2;
		MP43 G 1;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		MP43 P -1;
		Stop;
	}
}

class Kampfpistole : NaziWeapon
{
	Default {
		Weapon.SelectionOrder 2500;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 2;
		Weapon.AmmoType "NebAmmo";
		Weapon.UpSound "luger/select";
		Tag "Kampfpistole";
		Inventory.PickupMessage "$KAMPFPIST";
		-WEAPON.AMMO_CHECKBOTH
		-WEAPON.NOALERT
	}
	States
	{
	Ready:
		KPPL A 1 A_WeaponReady;
		Loop;
	Deselect:
		KPPL A 1 A_Lower;
		Loop;
	Select:
		KPPL A 1 A_Raise;
		Loop;
	Fire:
		//KPPL A 0 A_GunFlash;
		KPPL A 0 A_StartSound("clusterbomb/fire", CHAN_WEAPON);
		KPPL A 3 A_FireProjectile("Sprengpatrone");
		KPPL BCD 2 A_SetPitch(pitch-(0.5*boa_recoilamount));
		KPPL E 12;
		KPPL A 0 { if (CountInv("NebAmmo") == 0) { ScriptUtil.SetWeapon(self, "NullWeapon"); return ResolveState("NoAmmo"); } return ResolveState(null); }
		KPPL F 6 A_StartSound("mauser/open", CHAN_5, 0, frandom(0.6, 0.8));
		KPPL G 5;
		KPPL H 8;
		KPPL E 9 A_StartSound("browning/load", CHAN_5);
		KPPL A 5 A_ReFire;
		Goto Ready;
	Flash:
		KPPL A 2 A_Light2;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		KPPL P -1;
		Stop;
	NoAmmo:
		KPPL A -1 A_WeaponReady(WRF_NOFIRE);
		Stop;
	}
}


class FG42Loaded : Ammo
{
	Default
	{
		Tag "7.92x57mm";
		+Inventory.IGNORESKILL
		Inventory.MaxAmount 20;
		Inventory.Icon "MAUS01";
	}
}

class StG44Loaded : Ammo
{
	Default
	{
		Tag "7.92x33mm";
		+Inventory.IGNORESKILL
		Inventory.MaxAmount 30;
		Inventory.Icon "WALT01"; ///////////
	}
}

class KurzAmmo : Ammo
{
	Default {
		Scale 0.20;
		Tag "7.92x33mm";
		Inventory.Amount 30;
		Inventory.MaxAmount 120;
		Ammo.BackpackAmount 30;
		Ammo.BackpackMaxAmount 240;
		Inventory.PickupMessage "$KURZAMMO";
		Inventory.Icon "WALT01"; /////////////////
	}
	States
	{
	Spawn:
		MCLP A -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class StG44Tracer: PlayerTracer { Default { Speed 140; DamageFunction (random(16, 28)); } }

class Sprengpatrone: NebRocket
{
	Default {
		Speed 50;
		Damage 4;
		-NOGRAVITY
	}
	States
	{
	Spawn:
		TRGN A 1 BRIGHT;
		Loop;
	Death:
	Crash:
		EXP1 A 0 A_SetScale(0.85,0.95);
		EXP1 A 0 A_SpawnGroundSplash;
		EXP1 A 0 A_AlertMonsters;
		EXP1 A 0 A_StopSound(CHAN_AUTO);
		EXP1 A 0 { bNOGRAVITY = true; }
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("TracerSpark_Longlive", 0, 0, 0, frandom(-5.0,5.0), frandom(-5.0,5.0), frandom(-5.0,5.0), random(0,359));
		TNT1 A 0 A_SpawnItemEx("NebNuke",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		FRME A 1 BRIGHT LIGHT("NEBEXPLO") { A_Explode(25*damage,48*damage); A_SpawnItemEx("ZScorch");}
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("NEBEXPLO");
		Stop;
	}
}

class Sprengpatrone_Enemy: Sprengpatrone { Default { Damage 2; } }