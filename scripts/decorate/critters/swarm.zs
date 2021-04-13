class Bodiless_Swarm : SwitchableDecoration
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Swarm Of Flies
		//$Color 0
		//$Sprite SFLYA0
		Radius 1;
		Height 64;
		+CLIENTSIDEONLY
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
		+NOSECTOR
	}
	States
	{
	Active:
		TNT1 A 0 {bDormant = FALSE;}
	Spawn:
		TNT1 A 0 NODELAY A_StartSound("SFX/Buzz", CHAN_BODY, CHANF_LOOPING, frandom(0.6, 0.8));
		"####" AAAAA 1 A_SpawnItemEx("SwarmFly",frandom(-16,16),frandom(-16,16),frandom(-16,16),0 ,0 ,0 ,0 ,SXF_SETMASTER | SXF_CLIENTSIDE, 0, tid);
		"####" A -1;
		Stop;
	Inactive:
		TNT1 A 0 {bDormant = TRUE;}
		TNT1 A 0 A_StopSound(CHAN_BODY);
		TNT1 A 1 A_RemoveChildren(TRUE, RMVF_MISC);
		Stop;
	}
}

class Bodiless_Swarm2 : Bodiless_Swarm
{
	Default
	{
		//$Title Swarm Of FireFlies
		//$Sprite SFLYC0
	}
	States
	{
	Spawn:
		TNT1 AAAAA 1 A_SpawnItemEx("FireFly",frandom(-16,16),frandom(-16,16),frandom(-16,16),0 ,0 ,0 ,0 ,0 ,0 ,tid);
		"####" A -1;
		Stop;
	}
}

class SwarmFly: Actor
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Radius 1;
		Height 1;
		Speed 5;
		Projectile;
		ReactionTime 4;
		Scale 0.25;
		+NOCLIP
	}
	States
	{
	Spawn:
		SFLY A 1 ThrustThingZ(0,random(-1,1),random(1,0),1);
		TNT1 A 0 A_ChangeVelocity(frandom(-2,2),frandom(-1,1),frandom(-2,2),1);
		SFLY B 1 ThrustThingZ(0,random(-1,1),random(1,0),1);
		TNT1 A 0 A_ChangeVelocity(frandom(-1,1),frandom(-2,2),frandom(-1,1),1);
		SFLY A 0 A_CountDown;
		SFLY C 1 ThrustThingZ(0,random(-1,1),random(1,0),1);
		TNT1 A 0 A_ChangeVelocity(frandom(-2,2),frandom(-1,1),frandom(-2,2),1);
		SFLY B 1 ThrustThingZ(0,random(-1,1),random(1,0),1);
		TNT1 A 0 A_ChangeVelocity(frandom(-1,1),frandom(-2,2),frandom(-1,1),1);
		SFLY A 0 A_CountDown;
		Loop;
	Death:
		SFLY A 1 A_SpawnProjectile("SwarmFly",0,0,frandom(-20,20));
		Stop;
	}
}

class FireFly : SwitchableDecoration
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		Radius 2;
		Height 2;
		Speed 0;
		Mass 5;
		Scale 0.05;
		+BLOCKEDBYSOLIDACTORS
		+CANNOTPUSH
		+CLIENTSIDEONLY
		+NOGRAVITY
		+NOLIFTDROP
		+NOTARGET
		+NOTELEPORT
		+NOTELESTOMP
		+RANDOMIZE
		RenderStyle "Shaded";
		StencilColor "FFB100";
	}
	States
	{
	Spawn:
		CRIT A 0 NODELAY A_SetScale(frandom(0.05, 0.15));
	SpawnLoop:
		TNT1 A 0 A_CheckSightOrRange(1200.0, "LoopWait", TRUE);
		CRIT A 1 LIGHT("FIREFLY") A_CheckProximity("Inactive", "BoAPlayer", 128);
	Active:
		TNT1 A 0 A_ChangeVelocity(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),1);
		CRIT A 1 LIGHT("FIREFLY") ThrustThingZ(0,random(-1,1),random(1,0),1);
		TNT1 A 0 A_ChangeVelocity(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),1);
		CRIT A 1 LIGHT("FIREFLY") A_Wander;
		CRIT A 1 LIGHT("FIREFLY") ThrustThingZ(0,random(-1,1),random(1,0),1);
		TNT1 A 0 A_ChangeVelocity(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),1);
		CRIT A 1 LIGHT("FIREFLY") ThrustThingZ(0,random(-1,1),random(1,0),1);
		TNT1 A 0 A_ChangeVelocity(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),1);
		CRIT A 1 LIGHT("FIREFLY") A_Wander;
		Goto SpawnLoop;
	Inactive:
		CRIT A 1 LIGHT("FIREFLY") A_Fadeout(0.04);
	Death:
		TNT1 A 1 A_SetTics(random(525,1050));
		TNT1 A 5 A_Respawn(FALSE);
		TNT1 A -1;
		Stop;
	LoopWait:
		TNT1 A 10;
		Goto SpawnLoop;
	}
}