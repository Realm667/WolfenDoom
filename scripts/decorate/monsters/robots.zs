class TeslaTurret : NaziStandard
{
	Default
	{
	//$Category Monsters (BoA)/Defensive Devices
	//$Title Tesla Turret (Invulnerable)
	//$Color 4
	Radius 16;
	Height 96;
	Speed 0;
	MaxTargetRange 640;
	-COUNTKILL
	+DONTTHRUST
	+INVULNERABLE
	+LOOKALLAROUND
	+NOBLOOD
	+NOTAUTOAIMED //because it's invulnerable, some ammo saved
	Obituary "$TESLAT";
	SeeSound "";
	PainSound "";
	DeathSound "";
	Base.Shadow 0; //needed for shadows
	}
	States
	{
	Spawn:
		TSLT A 1 A_NaziLook;
		"####" A 0 A_StartSound("Tesla/Loop", CHAN_ITEM, CHANF_LOOPING, 1.0, ATTN_STATIC);
		Loop;
	See:
		"####" A 1 A_NaziChase;
		"####" A 0 A_StartSound("Tesla/Loop", CHAN_ITEM, CHANF_LOOPING, 1.0, ATTN_STATIC);
		Loop;
	Missile:
		"####" A 4 A_FaceTarget;
		"####" A 0 BRIGHT A_StartSound("Tesla/Attack");
		"####" AAAAAA 4 {
			A_StartSound("tesla/kill");
			A_SpawnProjectile("TPortLightningWaveSpawner", 54, 0, 0, CMF_AIMDIRECTION, 0);
			A_SpawnProjectile("TPortLightningWaveSpawner", 54, 0, 180, CMF_AIMDIRECTION, 0);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,54,0,0,0,0,0,160);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,54,0,0,0,0,0,160);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 54, 0, -90, true);
			A_LightningAttack("LightningBeamZap2", 0, 0, 54, 0, 0, false);
		}
		"####" AA 0 A_SpawnItemEx("SparkB",0,0,54,0,random(-1,1),random(-1,1),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,54,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" A 5;
		"####" A 0 A_JumpIfInTargetLOS("See", 0, JLOSF_CLOSENOJUMP, 0, 640);
		Loop;
	//no Death states because it's invulnerable
	}
}