class ZyklonBSteamSpawner : SteamSpawner
{
	Default
	{
	//$Title Zyklon B Steam Spawner
	//$Sprite ZTEMA0
	SteamSpawner.Particle "ZyklonBSteamParticle";
	}
}

class ZyklonBSteamParticle : SteamParticle
{
	Default
	{
	Height 16;
	Radius 8;
	DamageFunction (random(1,8));
	PoisonDamage 4;
	DamageType "UndeadPoisonAmbience";
	Projectile;
	}
	States
	{
	Spawn:
		ZTEM A 0;
		"####" A 2 A_SetScale(Scale.X+0.013, Scale.Y+0.013);
		"####" A 0 A_FadeOut(.04,FTF_REMOVE);
		Loop;
	}
}

class ZyklonBSteamSpawner_C3M6A : SteamSpawner
{
	Default
	{
	//$Title Zyklon B Steam Spawner (long range)
	//$Sprite ZTEMA0
	SteamSpawner.Particle "ZyklonBSteamParticle_C3M6A";
	}
}

class ZyklonBSteamParticle_C3M6A : ZyklonBSteamParticle
{
	Default
	{
    DamageFunction (2*random(1,8));
    PoisonDamage 8;
	}
    States
	{
	Spawn:
		ZTEM A 0;
		"####" A 2 A_SetScale(Scale.X+0.002, Scale.Y+0.002);
		"####" A 0 A_FadeOut(.001,FTF_REMOVE);
		Loop;
	}
}