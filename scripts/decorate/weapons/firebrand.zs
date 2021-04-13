class FirebrandFireball: Actor
{
	Default
	{
	Projectile;
	Radius 12;
	Height 12;
	Speed 40;
	DamageFunction (40);
	+BRIGHT
	+FOILINVUL
	+WINDTHRUST
	RenderStyle "Add";
	DeathSound "world/barrelboom";
	DamageType "OccultFire";
	Obituary "$OBTYRF1";
	Decal "Scorch";
	ProjectileKickback 30;
	}
	States
	{
	Spawn:
		CFFX N 0 LIGHT("ITBURNSOC3");
		CFFX N 0 LIGHT("ITBURNSOC2");
		CFFX N 1 LIGHT("ITBURNSOC1") A_SpawnItemEx("FirebrandFireballTrail");
		Loop;
	Death:
		CFCF Q 2 A_Scream;
		"####" R 2 A_Explode(16,128,0);
		"####" STUVWXYZ 2;
		Stop;
	}
}

class FirebrandFireballTrail: Actor
{
	Default
	{
	RenderStyle "Add";
	+BRIGHT
	}
	States
	{
	Spawn:
		CFFX NOP 4 LIGHT("ITBURNSOC1");
		Stop;
	}
}

class SwordPuff: Actor
{
	Default
	{
	+NOBLOCKMAP
	+NOGRAVITY
	+PUFFONACTORS
	AttackSound "sword/wall";
	SeeSound "sword/hit";
	Obituary "$OBTYRF2";
	ProjectileKickback 10;
	DamageType "Melee";
	}
	States
	{
	Spawn:
	Melee:
		TNT1 A 1;
		Stop;
	Crash:
		"####" AAAA 0 A_SpawnItemEx("TracerSpark", 0, 0, 0, random(-2,1), random(-2,1), random(-2,1), random(0,359)); //T667 improvements
		"####" A 1 A_AlertMonsters;
		Stop;
	}
}

class FireSwordPuff : SwordPuff
{
	Default
	{
	+FOILINVUL
	DamageType "OccultFire";
	ProjectileKickback 30;
	SeeSound "flamesword/hit";
	}
}

class SwordPuffSpark: Actor
{
	Default
	{
	Health 4;
	Radius 3;
	Height 6;
	Speed .1;
	RenderStyle "Add";
	Scale .4;
	Mass 0;
	BounceType "Doom";
	+DONTSPLASH
	+FLOORCLIP
	+MISSILE
	}
	States
	{
	States:
		PUFF A 1;
		"####" A 5 BRIGHT A_SetTranslucent(.8,1);
		"####" A 6 BRIGHT A_SetTranslucent(.6,1);
		"####" A 8 BRIGHT A_SetTranslucent(.4,1);
		"####" A 10 BRIGHT A_SetTranslucent(.2,1);
		Stop;
	}
}

class SwordSeq : Inventory { Default { Inventory.MaxAmount 2; } }