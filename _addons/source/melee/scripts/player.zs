class MeleeBoAPlayer: BoAPlayer
{
	Default
	{
		//overload, but better than moving weapons to other slots
		Player.WeaponSlot 1, "MeleeKnifeSilent", "MeleeShovel", "Firebrand", "AstrosteinMelee";
		//clear other slots
		Player.WeaponSlot 2, ""; Player.WeaponSlot 3, "";
		Player.WeaponSlot 4, ""; Player.WeaponSlot 5, "";
		Player.WeaponSlot 6, ""; Player.WeaponSlot 7, "";
		Player.WeaponSlot 8, ""; Player.WeaponSlot 9, "";
		Player.WeaponSlot 0, "NullWeapon";
		Player.StartItem "Stamina", 100;
		Player.StartItem "NullWeapon", 1;
		Player.StartItem "MeleeKnifeSilent";
		Player.StartItem "MeleeKnifeAmmo", 2;
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		dodragging = true;
	}
	
	override void Tick()
	{
		for (int i = 0; i < 26; ++i)
		{
			let a = FindInventory(MeleeWeaponHandler.classes_to_remove[i], true);
			if (a)
			{
				TakeInventory(MeleeWeaponHandler.classes_to_remove[i], 5);
			}
		}
		if (player && !player.morphtics)
		{
			if (Level.time % (35 * 5) == 0) { ForcedHealthBar = GetClosestForcedHealthBar(); } // Only run this check occasionally

			CrosshairTarget = GetLineTarget();

			DoGravity();

			DoTokenChecks();

			DoInteractions();
			
			if (level.mapname != "TITLEMAP")
			{
				// Do screen drawing actions
				if (!FindInventory("TankMorph", 1)) // Only do these if you're not driving a tank
				{
					if (!CountInv("Billy"))
					{
						// Do visual effects
						ACS_NamedExecuteAlways("DoFlinchRecovery_Wrapper", 0);
						ACS_NamedExecuteAlways("DoTiltEffect_Wrapper", 0);
					}
				}
			}
		}

		Super.Tick();
	}
	
	static void DoKick(Actor mo)
	{
		if (mo.player && mo.player.ReadyWeapon && NaziWeapon(mo.player.ReadyWeapon) && mo.player.playerstate == PST_LIVE && !mo.player.FindPSprite(-10))
		{
			Inventory st = mo.FindInventory("Stamina");
			NaziWeapon wpn = NaziWeapon(mo.player.ReadyWeapon);

			if (!wpn) { return; }

			if (st && st.Amount > 29)
			{
				wpn.modifier = 5.0;

				mo.A_TakeInventory("Stamina", 30);
				mo.player.SetPsprite(-10, wpn.FindState("KickOverlay"), true);
			}
		}
	}
	
	void DoSprinting() //translation of the ACS function
	{
		if (CountInv("IsDragging")) { return; }
		bool checksprint = CVar.GetCVar("boa_sprintswitch", player).GetBool();
		int buttons = GetPlayerInput(INPUT_BUTTONS);
		int p = PlayerNumber();
		speed = Default.Speed;
		MeleeWeaponHandler mh = ((MeleeWeaponHandler) (EventHandler.Find("MeleeWeaponHandler")));
		if (!mh) return;
		if (ACSTools.IsNoClipping(self))
		{
			speed = 2.5;
			mh.cooldown[p] = 0;
			mh.staminarecoverytimeout[p] = 0;
			GiveInventory("Stamina", 100);
		}
		if (
			(buttons & BT_SPEED) && 
			(buttons & BT_FORWARD) && 
			!(buttons & BT_CROUCH) &&
			mh.cooldown[p] <= 0 &&
			CountInv("Stamina")
		)
		{
			speed *= 2.0;
			if (!checksprint && !CountInv("BerserkToken"))
			{
				TakeInventory("Stamina", Random(1, 3));
			}
		}
		else
		{
			if (mh.staminarecoverytimeout[p] < level.time)
			{
				mh.cooldown[p]--;
				GiveInventory("Stamina",1);
				mh.staminarecoverytimeout[p] = level.time + Random(1, 3);
			}
		}
		if (!CountInv("Stamina")) { mh.cooldown[p] = 100; }
	}
}