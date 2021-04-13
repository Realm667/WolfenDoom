class Mine : GrenadeBase
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title Mine
		//$Color 3
		Radius 30;
		Height 12;
		Health 1000;
		Mass 9999999;
		+ACTIVATEMCROSS
		+DONTGIB
		+LOOKALLAROUND
		+NOBLOOD
		+NOICEDEATH
		+NOTAUTOAIMED
		+SHOOTABLE
		+TOUCHY
		DeathSound "panzer/explode";
		Obituary "$OBMINE";
		GrenadeBase.FearDistance 128;
		GrenadeBase.SplashType "Mine";
	}
	States
	{
	Spawn:
	See:
		MINE A 6 A_Chase;
		Loop;
	Death:
		"####" A 8 A_StartSound("MINEF");
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnGroundSplash;
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Medium");
		"####" A 0 A_SpawnItemEx("ZCrater");
		Stop;
	}
}

class MineInvisible : Mine
{
	Default
	{
		//$Title Mine (invisible)
		Radius 24;
		Height 12;
		RenderStyle "None";
	}
}

class PlacedMine : Mine
{
	Default
	{
		//$Title Friendly Mine (from Deployable item)
		Health 10;
		Mass 500;
		Obituary "$OBDMINE";
		-TOUCHY
	}
	States
	{
	Spawn:
		BOAM A 35 NODELAY A_CheckProximity("SpawnWait", "BoaPlayer", radius+64, 1, CPXF_SETTARGET); //wait 1 sec
	See:
		"####" A 0 A_CheckProximity("SpawnWait", "BoaPlayer", radius+64, 1, CPXF_SETTARGET);
		"####" A 35 {A_Chase(); bTouchy = TRUE; A_CheckProximity("SpawnWait", "BoaPlayer", radius+64, 1, CPXF_SETTARGET);}
		Loop;
	Death:
		"####" A 8 A_StartSound("MINEF");
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnGroundSplash;
		"####" A 0 A_SpawnItemEx("FriendlyExplosion_Medium");
		"####" A 0 A_SpawnItemEx("ZCrater");
		Stop;
	SpawnWait:
		"####" A 1 {bTouchy = FALSE;}
		"####" A 34;
		Goto Spawn;
	}
}

class BossEnemyPlacedMine : PlacedMine
{
	States
	{
	Spawn:
		BOAM A 35 NODELAY A_CheckProximity("SpawnWait", "HimmlerBoss", radius+64, 1, CPXF_SETTARGET); //wait 1 sec
	See:
		"####" A 0 A_CheckProximity("SpawnWait", "HimmlerBoss", radius+64, 1, CPXF_SETTARGET);
		"####" A 35 {A_Chase(); bTouchy = TRUE; A_CheckProximity("SpawnWait", "HimmlerBoss", radius+64, 1, CPXF_SETTARGET);}
		Loop;
	Death:
		"####" A 8 A_StartSound("MINEF");
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnGroundSplash;
		"####" A 0 A_SpawnItemEx("EnemyExplosion_Medium");
		"####" A 0 A_SpawnItemEx("ZCrater");
		Stop;
	}
}

class UnderwaterMine : Mine
{
	int user_theta;
	Default
	{
		//$Title Underwater Mine
		Radius 16;
		Height 128;
		Health 300;
		+NOGRAVITY
	}
	States
	{
	Spawn:
	See:
		UWMI HIJKL 6 A_Chase;
		Loop;
	Death:
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_Medium",0,0,64);
		UWMI H 12 A_Scream;
	Shock:
		UWMI H 0 A_SpawnProjectile("Bubble",random(64,76),0,user_theta,2);
		"####" H 0 { user_theta = user_theta+20; }
		"####" H 0 A_JumpIf(user_theta==360,1);
		Loop;
		"####" H 1 A_RemoveTarget(RMVF_EVERYTHING, "UnderwaterMineChain");
		UWMI A 0 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		"####" ABCDE 6;
		"####" F -1;
		Stop;
	}
}

class UnderwaterMineChain: Actor
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title Underwater Mine (longer Chain)
		//$Color 3
		Radius 16;
		Height 128;
		Mass 9999999;
		+NOGRAVITY
	}
	States
	{
	Spawn:
		UWMI G -1;
		Stop;
	}
}