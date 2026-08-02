
class MutantMelee_Leap : MutantMelee replaces MutantMelee
{
	Default
	{
		MeleeRange 64; //a bit more OP
		+MISSILEMORE
		+MISSILEEVENMORE
	}
	States
	{
	Spawn:
		MLMT A 0 NODELAY ACS_NamedExecuteAlways("DisableMutants",0);
		Goto Look;
	See:
		"####" A 0 A_SetSpeed(6);
		Goto See.MutantFasterAlt;
	See.MutantFasterAlt:
		// Mutant Walk Pattern, offset frames (BCDE walk instead of ABCD)
		"####" "#" 0 { user_incombat = True; if (user_count4 > 0) --user_count4; }
		"####" B 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" B 1 A_MeleeMutantChase(null, null);
		//"####" B 0 A_SpawnItemEx("EnemyStep", 0, 0, 14, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		"####" B 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" B 1 A_MeleeMutantChase(null, null);
		"####" C 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" C 1 A_MeleeMutantChase(null, null);
		"####" C 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" C 1 A_MeleeMutantChase(null, null);
		"####" D 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" D 1 A_MeleeMutantChase(null, null);
		//"####" D 0 A_SpawnItemEx("EnemyStep", 0, 0, 14, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		"####" D 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" D 1 A_MeleeMutantChase(null, null);
		"####" E 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" E 1 A_MeleeMutantChase(null, null);
		"####" E 1 A_MeleeMutantChase("Melee", "Missile", 1024, 64);
		"####" E 1 A_MeleeMutantChase(null, null);
		"####" A 0 { return ResolveState("See"); }
	Missile:
		MLMT A 0 A_JumpIfCloser(320, "Leap");
		MLMT Q 8 A_FaceTarget;
		MLMT RS 4 A_FaceTarget;
		MLMT T 4 A_SpawnProjectile("FlyingCleaver",43,8,random(-2,2));
		MLMT UV 4 A_FaceTarget;
		MLMT W 4 A_SpawnProjectile("FlyingCleaver",43,-8,random(-2,2));
		MLMT XY 8 A_FaceTarget;
		MLMT Q 4 A_FaceTarget;
		Goto See;
	Leap:
		MLMT A 0 A_JumpIfCloser(128, "See");
		MLMT A 0
		{
			if (user_count4 > 24) return ResolveState("See");
			return ResolveState(null);
		}
		MTNL A 5 A_StartSound("mutant/see", CHAN_VOICE);
		MTNL A 7 A_FaceTarget;
		MTNL B 10 {
			user_count4 += 16;
			A_FaceTarget();
			A_Recoil(-20.0);
			Vel.Z = ZScriptTools.ArcZVel(Level.Vec2Diff(pos.XY, target.pos.XY).Length() / 20.0, GetGravity(), target.pos.Z - pos.Z);
			bSKULLFLY = true;
		}
		MTNL C 12 A_FaceTarget;
		MTNL D 6 {
			bSKULLFLY = false;
		}
	Mutuz:
		MTNL E 2;
		MTNL F 3 A_FaceTarget;
		MTNL G 4 A_CustomMeleeAttack(5*random(1,5));
		MTNL H 2;
		MTNL I 3 A_FaceTarget;
		MTNL J 4 A_CustomMeleeAttack(5*random(1,5));
		MLMT A 0 A_JumpIf(!target, "See");
		MLMT A 0 A_JumpIfCloser(meleerange + target.radius, "Mutuz");
		Goto See;
	}
	override bool Slam (Actor victim) {
		if (victim.bSOLID || victim is "PlayerPawn")
		{
			victim.DamageMobj(self, self, 10*random(1,5), 'Melee');
			victim.A_StartSound("sword/hit", CHAN_BODY);
			bSKULLFLY = false;
		}
		return true;
	}
}