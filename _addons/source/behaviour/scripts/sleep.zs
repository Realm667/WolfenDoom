
class Sleeper: Actor
{
	static const Name sleepclasses[] = {'Guard', 'RifleGuard', 'WGuard', 'WRifleGuard', 'WMP40Guard', 'WShotgunGuard'};
	//these could be retrieved from dropitems list (see sneakable enemies implementation), but I'm a bit lazy
	static const Name weapons[] = {'None', 'G43', 'None', 'G43', 'MP40', 'TrenchShotgun'};
	Name cl;
	States {
	Spawn:
		TNT1 A 0 NoDelay
		{
			if (master)
			{
				cl = master.GetClassName();
				Actor sg;
				sg = master.Spawn("SleepingGuard", master.pos);
				for (int i = 0; i < 6; ++i)
				{
					if (cl == sleepclasses[i]) {
						if (weapons[i]) SleepingGuard(sg).droppedweapon = (Inventory)(sg.A_DropItem(weapons[i], 1, 256));
						SleepingGuard(sg).cl = cl;
					}
				}
				sg.master = master;
			}
		}
		Stop;
	}
	static bool IsSleeper(Actor a)
	{
		for (int i = 0; i < 6; ++i)
		{
			if (a.GetClassName() == Sleeper.sleepclasses[i]) return true;
		}
		return false;
	}
}

class SleepingGuard: NaziStandard
{
	Name cl;
	int itype;
	Inventory droppedweapon;
	Default
	{
		Base.NoMedicHeal;
		Radius 20;
		Height 48;
		Health 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay
		{
			if (cl == 'Guard' || cl == 'RifleGuard')
			{
				itype = 1;
				return ResolveState("Spawn.AfrikaKorps");
			}
			else //Wehrmacht, also fallback
			{
				itype = 0;
				return ResolveState("Spawn.Wehrmacht");
			}
		}
		Stop;
	Spawn.Wehrmacht:
		GRDS A 0;
		Goto DestroyMaster;
	Spawn.AfrikaKorps:
		AGRS A 0;
		Goto DestroyMaster;
	DestroyMaster:
		"####" A 1 {
			if (master) master.Destroy();
		}
		Goto Sleep;
	Sleep:
		"####" A random(16, 64)
		{
			A_SpawnItemEx("SleepEffect", random(-2,2), random(-2,2), random(24,32), 0, 0, 1, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
			A_LookEx(LOF_NOSIGHTCHECK, 1.0, 0.0, 1024.0);
		}
		"####" B random(16, 64)
		{
			A_SpawnItemEx("SleepEffect", random(-2,2), random(-2,2), random(24,32), 0, 0, 1, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
			A_LookEx(LOF_NOSIGHTCHECK, 1.0, 0.0, 1024.0);
		}
		"####" A 0 { if (!random(0, 7)) A_StartSound("nazi/snore", CHAN_VOICE, 0, 1.0, ATTN_STATIC); }
		Loop;
	See:
		"####" C 17; //What..?
		"####" D 9; //ALERT!!!
		"####" D 0
		{ //Where's my weapon?
			if (!droppedweapon || droppedweapon.owner)
			{ //Oh damn it!
				if (itype == 0) ReplaceWith("WGuard");
				else if (itype == 1) ReplaceWith("Guard");
			}
			else { droppedweapon.Destroy(); ReplaceWith(cl); }
		}
		Stop;
	Death:
		"####" "#" 0
		{
			if (itype == 1) return ResolveState("DeathAfrikaKorps");
			return ResolveState(null);
		}
	DeathWehrmacht:
		GRD2 A 0;
		Goto DeathSequence;
	DeathAfrikaKorps:
		GARD A 0;
		Goto DeathSequence;
	DeathSequence:
		"####" K 5 A_SpawnItemEx("ThroatSpill", 0, 0, 0);
		"####" L 5 A_NoBlocking();
		"####" M -1;
		Stop;
	}
}