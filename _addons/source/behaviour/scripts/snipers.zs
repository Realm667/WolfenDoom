
class LeadingSniper : Sniper replaces Sniper
{
	Actor InterceptTarget;
	Default {
		+MISSILEMORE
		+MISSILEEVENMORE
	}
	States
	{
	Melee:
	Missile:
		"####" F random(32,48) A_FaceTarget;
		"####" G 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" G 0 A_FaceTarget;
		"####" G 8 LIGHT("NAZIFIRE") A_SniperShot(44, 5);
		"####" G 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" F 32;
		"####" F 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Reload:
		"####" E 0 {bNoPain = TRUE;}
		"####" E 20 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" F 20 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	}
	
	override void PostBeginPlay()
	{
		//intercept = G_SkillPropertyInt(SKILLP_ACSReturn) > 2;
		InterceptTarget = Spawn("TankInterceptTarget", Pos, ALLOW_REPLACE);
		Super.PostBeginPlay();
	}
	
	virtual void A_SniperShot(float spawnheight, float spawnofs_xy) {
		if (target) // && intercept
		{
			double interceptTime;
			interceptTime = ZScriptTools.GetInterceptTime4(Pos, Target.Pos, Target.Vel, GetDefaultSpeed("EnemyRifleTracer"));
			Vector3 interceptPos = Target.Pos + Target.Vel * interceptTime;
			InterceptTarget.SetOrigin(interceptPos, true);
			let a = target;
			target = InterceptTarget;
			A_SpawnProjectile("EnemyRifleTracer", spawnheight, spawnofs_xy);
			target = a;
		}
	}
}

class LeadingWSniper : LeadingSniper replaces WSniper
{
	States
	{
	Spawn:
		SNW2 F 0;
		Goto Look;
	See:
		SNW2 F 0;
		Goto See.Sniper;
	Pain:
		SNIW I 9 A_NaziPain(256);
		Goto See;
	Death:
		SNIW I 5 A_RandomDeathAnim;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	Death.Front:
		SNWA I 0 A_CheckFadeDeath;
		SNWA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Death.Back:
		SNWB I 0 A_CheckFadeDeath;
		SNWB I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" KLM 5;
		"####" N -1;
		Stop;
	Raise:
		"####" MLKJI 5;
	Idle:
		Goto Look;
	}
}

class LeadingWSniper_Switchable : LeadingWSniper replaces WSniper_Switchable
{
	States
	{
	Spawn:
		SNW2 F -1;
		Stop;
	See:
		SNW2 F 0;
		Goto See.Sniper;
	Active:
		"####" "#" 0;
		Goto Look;
	}
}

class LeadingSniper_Crouch: LeadingSniper replaces Sniper_Crouch
{
	States
	{
	Spawn:
		SNIA C 0;
		Goto Look;
	See:
		SNIA C 0;
		Goto See.Sniper;
	Pain:
		"####" N 6 A_NaziPain(256);
		Goto See;
	Melee:
	Missile:
		"####" C random(28,42) A_FaceTarget; //a bit fast than normal one
		"####" D 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" G 0 A_FaceTarget;
		"####" D 8 LIGHT("NAZIFIRE") A_SniperShot(34, 5);
		"####" D 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 34, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" C 28;
		"####" C 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" C 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Reload: //ozy81
		"####" B 0 {bNoPain = TRUE;}
		"####" B 20 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" C 20 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		"####" # 0 { mass = 70; }
		"####" K 7 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" M -1;
		Stop;
	Raise:
		"####" MLKJI 5;
		Goto See;
	Idle:
		Goto Look;
	}
}
class LeadingWSniper_Crouch: LeadingSniper_Crouch replaces WSniper_Crouch
{
	States
	{
	Spawn:
		SNIW C 0;
		Goto Look;
	See:
		SNIW C 0;
		Goto See.Sniper;
	}
}

class LeadingWSniperCrouch_Switchable /*god damn it*/ : LeadingWSniper_Crouch replaces WSniper_CrouchSwitchable
{
	States
	{
	Spawn:
		SNIW C -1;
		Stop;
	See:
		SNIW C 0;
		Goto See.Sniper;
	Active:
		"####" "#" 0;
		Goto Look;
	}
}

class LeadingArcticSniper : LeadingSniper replaces ArcticSniper
{
	Default
	{
	Health 60;
	SeeSound "";
	DropItem "Kar98k", 72;
	DropItem "MauserAmmo", 192, 5;
	+LOOKALLAROUND
	}
	States
	{
	Spawn:
		SNSP A 0;
		Goto Look;
	See:
		SNSP A 0;
		Goto See.Sniper;
	Pain:
		SNRF I 6 A_NaziPain(256);
		Goto See;
	Melee:
	Missile: //attack & reload are slightly fast than other snipers - ozy81
		"####" B random(28,42) A_FaceTarget;
		"####" B 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" B 0 A_FaceTarget;
		"####" C 7 LIGHT("NAZIFIRE") A_SniperShot(44, 5);
		"####" C 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 56, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" A 28;
		"####" A 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" A 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Reload: //ozy81
		"####" A 0 {bNoPain = TRUE;}
		"####" A 16 A_StartSound("mauser/open", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" A 16 A_StartSound("mauser/insert", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" A 0 A_SpawnItemEx("EnfieldRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" A 0 {bNoPain = FALSE;}
		Goto See;
	Death:
		"####" # 0 { mass = 70; }
		SNRF I 5 A_RandomDeathAnim;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	Death.Back:
	Death.Headshot:
		Stop;
	Death.Front:
		SNDA I 0 A_CheckFadeDeath;
		SNDA I 5 A_Scream;
		"####" J 5 A_UnblockAndDrop;
		"####" K 20 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5;
		"####" M 5;
		"####" N 5;
		"####" O -1;
		Stop;
	Raise:
		"####" MLKJI 5;
	Idle:
		Goto Look;
	}
}

class LeadingArcticSniper_Crouch: LeadingArcticSniper replaces ArcticSniper_Crouch
{
	States
	{
	Spawn:
		SNSP D 0;
		Goto Look;
	See:
		SNSP D 0;
		Goto See.Sniper;
	Pain:
		SNSP N 6 A_NaziPain(256);
		Goto See;
	Melee:
	Missile: //attack & reload are slightly fast than other snipers - ozy81
		SNSP E random(24,36) A_FaceTarget; //a bit fast than normal one
		"####" E 0 { A_StartSound("browning/fire", CHAN_WEAPON); A_AlertMonsters(1536); }
		"####" E 0 A_FaceTarget;
		"####" F 7 LIGHT("NAZIFIRE") A_SniperShot(44, 5);
		"####" F 0 A_SpawnItemEx("EnfieldRifleCasing", 1, 0, 34, random(1,2), random(-1,1), random(1,2), random(-55,-80), SXF_NOCHECKPOSITION);
		"####" D 24;
		"####" D 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" D 0 A_StartSound("browning/cock", CHAN_AUTO, 0, 0.25);
		Goto See;
	Death:
		"####" # 0 { mass = 70; }
		SNRF K 7 A_Scream;
		"####" L 5 A_UnblockAndDrop;
		"####" M -1;
		Stop;
	}
}