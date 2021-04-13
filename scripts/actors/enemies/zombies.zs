class CivilianZombie : ZombieStandard
{
	int variant;

	Property Variant:variant;

	Default
	{
		//$Category Monsters (BoA)/Occult
		//$Color 4
		//$Sprite CIRZA1

		Nazi.ZombieVariant "CivilianZombie";
		Health 20;
		Speed 2;
		Obituary "$CIVBITE";
		DropItem "Soul";
		CivilianZombie.Variant -1;
	}

	States
	{
		Spawn:
			CIRZ A 0;
			Goto Look;
		See:
			"####" "#" 0 A_JumpIfCloser(radius + 160, "Run");
			"####" "#" 0 A_SetSpeed(3);
			Goto See.Normal;
		Run:
			"####" "#" 0 A_SetSpeed(6);
			"####" "#" 0 A_Jump(256,"RunLoop2");
			Stop;
		Melee:
			"####" EF 4 A_FaceTarget();
			"####" G 5 A_CustomMeleeAttack(4*random(1,3), "nazombie/pain", "", "UndeadPoison", TRUE);
			"####" F 4 A_FaceTarget();
			"####" G 5 A_CustomMeleeAttack(4*random(1,3), "nazombie/pain", "", "UndeadPoison", TRUE);
			Goto See;
		Pain:
			"####" H 6 A_NaziPain(256, True, -8, "ZPain_Overlay");
			"####" H 0 A_Jump(256,"See");
			Goto Spawn;
		Death:
			"####" I 5 A_Scream();
			"####" J 6;
			"####" K 5 A_NoBlocking();
			"####" LM 4;
			"####" O 5 A_SpawnItemEx("ZombieSoul", 0, 0, 10, 0, 0, frandom(1,3));
			"####" P -1;
			Stop;
		Raise:
			"####" POMLKJI 7;
			"####" I 0 A_Jump(256,"See");
			Stop;
		Variants:
			CZOM N 0; // Variant 0
			CIRZ A 0; // Variant 1
			CIBZ A 0; // Variant 2
			CIGZ A 0; // Variant 3
	}

	override void PostBeginPlay()
	{
		if (variant < 0 || variant > 3) { variant = Random(1, 3); }

		State VariantState = FindState("Variants") + variant;

		defaultsprite = VariantState.sprite;
		sprite = defaultsprite;

		Super.PostBeginPlay();
	}
}

class Camp_PrisonerZombie : CivilianZombie
{
	Default
	{
		//$Title Zombie Prisoner
		//$Sprite CZOMA1

		Health 30;
		Speed 3;
		Obituary "$PRISBITE";
		Nazi.ZombieVariant "Camp_PrisonerZombie";
		CivilianZombie.Variant 0;
	}
}

class CivilianZombie1 : CivilianZombie
{
	Default
	{
		//$Title Civilian Zombie (brown trousers)
		//$Sprite CIBZA1

		Nazi.ZombieVariant "CivilianZombie1";
		CivilianZombie.Variant 1;
	}
}

class CivilianZombie2 : CivilianZombie
{
	Default
	{
		//$Title Civilian Zombie (green trousers)
		//$Sprite CIGZA1

		Nazi.ZombieVariant "CivilianZombie2";
		CivilianZombie.Variant 2;
	}
}

class CivilianZombie3 : CivilianZombie
{
	Default
	{
		//$Title Civilian Zombie (red trousers)
		//$Sprite CIRZA1

		Nazi.ZombieVariant "CivilianZombie3";
		CivilianZombie.Variant 3;
	}
}