class KnifeSilent : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (1) Knife
	//$Color 14
	Scale 0.35;
	DamageType "Knife";
	+FORCEPAIN
	+WEAPON.MELEEWEAPON
	+WEAPON.NOALERT
	+WEAPON.NOAUTOFIRE
	+WEAPON.WIMPY_WEAPON
	Tag "$TAGKNIFE";
	Weapon.BobStyle "Smooth";
	Weapon.BobSpeed 1.5;
	Weapon.BobRangeX 1.5;
	Inventory.PickupMessage "$KNIFE";
	Weapon.SelectionOrder 10000;
	}
	States
	{
	Spawn:
		KNFE A -1;
		Stop;
	Ready:
		KNFG A 1 A_WeaponReady;
		Loop;
	Deselect:
		KNFG A 1 A_Lower;
		Loop;
	Select:
		KNFG A 1 A_Raise;
		Loop;
	Fire:
		KNFG A 0 A_JumpIfInventory("PowerStrength", 1, "Fire.Berserked");
	Fire.Normal:
		KNFG A 1 A_StartSound("knife/swing", CHAN_WEAPON);
		KNFG B 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		Goto Fire.End;
	Fire.Berserked:
		KNFG A 1 A_StartSound("knife/swing", CHAN_WEAPON);
		KNFG B 1 A_CustomPunch(10*5, 1, 0, "KnifePuff", 64); //Quintuple Damage with NaziBerserk, suggested by N00b - ozy81
	Fire.End:
		KNFG CDEFGHJKLMN 1;
		KNFG A 10;
		Goto Ready;
	}
}

class KnifePuff : ShovelPuff
{
	Default
	{
	AttackSound "";
	SeeSound "";
	Scale 0.4;
	Obituary "$OBKNIFE";
	PainType "SilentKnifeAttack"; //mxd. Used to invoke Pain.SilentKnifeAttack exclusively on stealth monsters
	DamageType "Melee";
	}
	States
	{
	Spawn:
	Melee:
	Crash:
		POOF A 3 A_StartSound("knife/stone");
		POOF BCDE 3;
		Stop;
	XDeath:
		POOF A 3 A_StartSound("knife/hit");
		Goto Crash+1;
	}
}