class MeleeKnifeSilent: KnifeSilent
{
	Default {
		+INVENTORY.UNCLEARABLE
		+INVENTORY.UNDROPPABLE
		Weapon.AmmoType1 "MeleeKnifeAmmo";
		Weapon.AmmoUse1 1;
		Weapon.AmmoType2 "MeleeKnifeAmmo";
		Weapon.AmmoUse2 1;
	}
	States
	{
	Deselect:
		KNFG A 1 A_Lower;
		KNFG A 0 A_Lower;
		Loop;
	Select:
		KNFG A 1 A_Raise;
		KNFG A 0 A_Raise;
		Loop;
	Fire:
		KNFG A 1 A_StartSound("knife/swing", CHAN_WEAPON);
		KNFG B 1 A_CustomPunch(10*5, 1, 0, "KnifePuff", 64);
	Fire.End:
		KNFG CDEFGHJKLMN 1;
		KNFG A 10;
		Goto Ready;
	Altfire:
		KNTH A 1 Offset(0, 63);
		KNTH A 1 Offset(0, 51);
		KNTH A 1 Offset(0, 41);
		KNTH A 1;
	AltHold:
		KNTH A 2;
		KNTH A 0 A_Refire;
		KNTH B 2;
		KNTH C 2 A_FireProjectile("MeleeThrownKnife",frandom(-1.5,1.5),1,0,0,FPF_NOAUTOAIM,frandom(-0.5,0.5));
		KNTH C 1 Offset(0, 36);
		KNTH C 1 Offset(0, 47);
		KNTH C 1 Offset(0, 60);
		KNTH D 1 Offset(0, 57);
		KNTH D 1 Offset(0, 69);
		KNTH D 1 Offset(0, 82);
		KNTH D 1 Offset(0, 97);
		KNTH D 1 Offset(0, 110);
		TNT1 A 0 { if (CountInv("MeleeKnifeAmmo") == 0) { ScriptUtil.SetWeapon(self, "NullWeapon"); return ResolveState("NoAmmo");} return ResolveState(null); }
		KNFG A 1 Offset(0, 110);
		KNFG A 1 Offset(0, 97);
		KNFG A 1 Offset(0, 82);
		KNFG A 1 Offset(0, 69);
		KNFG A 1 Offset(0, 57);
		KNFG A 1 Offset(0, 42);
		KNFG A 1;
		Goto Ready;
	NoAmmo:
		TNT1 A -1 A_WeaponReady(WRF_NOFIRE);
		Stop;
	}
}

class MeleeShovel : Shovel
{
	States
	{
	Fire:
		SHUV B 1 Offset(5,32);
		SHUV B 1 Offset(10,33) A_StartSound("shovel/miss", CHAN_WEAPON);
		SHUV B 1 Offset(16,35);
		SHUV B 1 Offset(24,38);
		SHUV B 1 Offset(26,39);
		SHUV B 1 Offset(27,40);
		SHUV C 1 Offset(20,38) A_CustomPunch(60*3,1,0,"ShovelPuff",120);
		SHUV C 1 Offset(10,39);
		SHUV C 1 Offset(-3,40);
		SHUV D 1 Offset(-19,32);
		SHUV D 1 Offset(-40,36);
		SHUV E 1 Offset(-64,40);
		SHUV E 1 Offset(-90,42);
	Reappear:
		TNT1 A 10;
		SHUV A 1 Offset(60,60);
		SHUV A 1 Offset(50,55);
		SHUV A 1 Offset(40,50) A_WeaponReady(WRF_NOBOB);
		SHUV A 1 Offset(30,45) A_WeaponReady(WRF_NOBOB);
		SHUV A 1 Offset(20,40) A_WeaponReady(WRF_NOBOB);
		SHUV A 1 Offset(10,35) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	Altfire:
		SHUV A 1;
		SHUV B 1 Offset(5,32);
		SHUV B 1 Offset(10,33);
	AltHold:
		SHUV B 1 Offset(10,33);
		SHUV B 0 A_Refire;
		SHUV B 1 Offset(16,35);
		SHUV B 1 Offset(26,39); //around 2x faster
		SHUV C 1 Offset(20,38) A_CustomPunch(60*3,1,0,"ShovelPuff",120);
		SHUV C 1 Offset(-3,40);
		SHUV D 1 Offset(-40,36);
		SHUV E 1 Offset(-90,42);
		Goto Reappear;
	}
}

class MeleeKnifeAmmo : Ammo
{
	Default
	{
		Scale 0.35;
		Tag "Throwing Knives";
		Inventory.Amount 1;
		Inventory.MaxAmount 4;
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 8;
		Inventory.PickupMessage "$KNIFE";
		DamageType "Knife";
		Inventory.Icon "KNTH01";
	}
	States
	{
	Spawn:
		KNFE A -1;
		Stop;
	}
}

class MeleeThrownKnife: Actor
{
	Default
	{
		Projectile;
		Radius 4;
		Height 8;
		+BLOODSPLATTER
		+NOEXTREMEDEATH
		+SKYEXPLODE
		-NOGRAVITY
		SeeSound "NailFlight";
		Speed 40;
		DamageFunction (random(37, 61));
		Scale 1.0;
	}
	States
	{
	Spawn:
		KNTH E 1 A_AlertMonsters(128);
		Loop;
	Crash:
		KNTH E 1 A_StartSound("knife/stone",CHAN_VOICE);
		Goto Death;
	XDeath:
		KNTH E 0 A_StartSound("knife/hit",CHAN_VOICE);
	Death:
		KNTH E 0 A_SpawnItemEx("HackPuff");
		KNTH E 0 A_SpawnItemEx("MeleeKnifeAmmo", 1);
		KNTH E 1 A_FadeOut(0.4);
		Stop;
	}
}
