
class ComplexBehaviourHandler: EventHandler
{
	int showscratch[MAXPLAYERS];
	
	override void WorldThingDamaged (WorldEvent e)
	{
		if (e.Thing is "PlayerPawn" && PlayerPawn(e.Thing).Player && e.Inflictor is "MutantMelee_Leap") {
			showscratch[PlayerPawn(e.Thing).PlayerNumber()] = 32 * (random(0, 1) * 2 - 1);
		}
	}
	
	override void WorldThingDied(WorldEvent e)
	{
		if (e.Thing.bCOUNTKILL)
		{
			DropItem di;
			di = e.Thing.GetDropItems();
			while (di)
			{
				if (di.Name == "GrenadePickup" && !random(0, 7)) { e.Thing.A_SpawnProjectile("VerySlowGrenade",24,16,frandom(-8,8),CMF_AIMDIRECTION); return; }
				di = di.Next;
			}
		}
	}
	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; ++i) {
			if (showscratch[i] > 0) --showscratch[i];
			else if (showscratch[i] < 0) ++showscratch[i];
		}
		if (level.time % 700 == 0)
		{ //every 20 seconds...
			ThinkerIterator t = ThinkerIterator.Create("BasicGuard");
			BasicGuard guard;
			while (guard = BasicGuard(t.Next()))
			{
				if (!guard.bINCOMBAT && !guard.user_incombat && Sleeper.isSleeper(guard))
				{
					if (guard.CurSector.lightlevel < 160 /*don't fall asleep when it is too bright*/ && !random(0, 7))
					{
						ThinkerIterator it = ThinkerIterator.Create("Nazi", Thinker.STAT_DEFAULT);
						Nazi mo;
						int count = 0;
						while (mo = Nazi(it.Next()))
						{
							if (guard.Distance3D(mo) > 1024.0) { continue; }
							if (mo == guard) { continue; }
							if (!mo.bShootable || mo.health <= 0) { continue; }
							if (!mo.IsVisible(guard, true)) { continue; }
							if (mo.GetClassName() == "Officer" || mo.GetClassName() == "WOfficer" || mo.GetClassName() == "SSOfficer" || mo.bBOSS) count++;
						}
						if (count == 0)
						{
							// The superiors are away, so I guess I can take a nap, I'm not on the front line anyway...
							Sleeper s = (Sleeper) (Actor.Spawn("Sleeper", guard.pos));
							s.master = guard;
						}
					}
				}
			}
		}
	}
	
	override void RenderUnderlay(RenderEvent e)
	{
		if (showscratch[consoleplayer] > 0)
		{
			Screen.DrawTexture(TexMan.CheckForTexture("lscratch"), false, 0, 0, DTA_Fullscreen, true, DTA_Alpha, showscratch[consoleplayer] / 32.0);
		}
		else if (showscratch[consoleplayer] < 0)
		{
			Screen.DrawTexture(TexMan.CheckForTexture("rscratch"), false, 0, 0, DTA_Fullscreen, true, DTA_Alpha, showscratch[consoleplayer] / -32.0);
		}
	}
}