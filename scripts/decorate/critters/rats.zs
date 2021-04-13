class RatSpawner: Actor
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Rats (arg0 Amount, arg1 Radius)
		//$Color 0
		//$Sprite MOUSA1
		//$Arg0 "Amount"
		//$Arg0Tooltip "Amount of Rats, from 1-5"
		//$Arg1 "Radius"
		//$Arg1Tooltip "Radius in map units"
		Radius 2;
		Height 2;
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(Args[0]==5,5);
		"####" A 0 A_JumpIf(Args[0]==4,5);
		"####" A 0 A_JumpIf(Args[0]==3,5);
		"####" A 0 A_JumpIf(Args[0]==2,5);
		"####" A 0 A_JumpIf(Args[0]==1,5);
		"####" AAAAA 0 A_SpawnItemEx("ScurryRat", random (-Args[1], Args[1]), 0, 0, 0, 0, 0, random (0, 360),0 ,0 ,tid);
		"####" A 1;
		Stop;
	}
}

class ScurryRat : Base
{
	Default
	{
		Radius 8;
		Height 8;
		Health 1;
		Mass 50;
		Speed 8;
		Scale 0.20;
		-CANUSEWALLS
		-CANPUSHWALLS
		+AMBUSH
		+FLOORCLIP
		+FRIGHTENED
		+LOOKALLAROUND
		+NEVERRESPAWN
		+STANDSTILL
		+TOUCHY
		+VULNERABLE
		ActiveSound "rat/active";
		DeathSound "rat/death";
		SeeSound "rat/squeek";
	}
	States
	{
	Spawn:
		MOUS A 10 A_LookThroughDisguise;
		Loop;
	See:
		MOUS A 1 A_Chase;
		"####" A 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" A 1 A_Chase;
		"####" A 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		Loop;
	Vanish:
		TNT1 A 1;
		Stop;
	Death:
		MOUS H 3 A_ScreamAndUnblock;
		"####" IJKL 3;
		"####" M -1;
		Stop;
	}
}