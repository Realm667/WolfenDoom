/*
 * Copyright (c) 2017-2020 AFADoomer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Portions copied from GZDoom licensed under GPLv3
**/

/*

  New Functions:
	GetLineTarget()
	- Saves reference to whatever actor is under the player's crosshair to the CrossHairTarget variable
	- Used by Status Bar code to draw boss health bars

	GetClosestForcedHealthBar()
	- Finds the closest Nazi class descendant with the user_DrawHealthBar variable set to true and saves
	  a reference to that actor to the ForcedHealthBar variable
	- Used by Status Bar code to draw always-present health bar (e.g., Nebelwerfer in Paris)

	DoTokenChecks()
	- Parent function where various inventory checks should be performed

	SpawnEffect(class<PlayerEffect>)
	RemoveEffect(class<PlayerEffect>)
	- Used to spawn/remove an effect actor that follows the player around (e.g., glow for FireBrand)
	- See PlayerEffect class information below
	- Checks should be performed in DoTokenChecks:

		// If current weapon is BFG9000, spawn swirlysparkles that follow the player
		if (player && player.ReadyWeapon is "BFG9000") { SpawnEffect("SwirlySparkles"); }
		else { RemoveEffect("SwirlySparkles"); }

  New Base Classes:
	PlayerEffect
	- Base class for player effects, to be spawned/removed with SpawnEffect/RemoveEffect as shown above
	- Literally just a simple actor that constantly warps to the position of its master (the player)
	- Developer note: These actors have their statnum set to STAT_DEFAULT - 4
	  (used to limit ThinkerIterator performance hit)

  Useful variables:
	flinchfactor
	- Acts as multiplier for flinch amount; range from 0 to 255
	- Set via ACS like this: 
		SetUserVariable(playerTID, "flinchfactor", 128);

*/

const PLAYER_TAG_OFFSET = 1000;

class BoAPlayer : PlayerPawn
{
	double leveltilt, oldtilt, leveltiltangle;
	Actor CrosshairTarget;
	Actor ForcedHealthBar;
	Actor DragTarget;
	SpriteID baseSprite;
	Weapon LastWeapon;
	Line UseTarget;
	int crosshair;
	String crosshairstring;
	Actor climbing;
	int interactiontimeout;
	int flinchfactor;
	bool dodragging; // Set true to enable dragging of corpses and pushable actors (crouch and use)
	AchievementTracker tracker;

	Default
	{
		+CASTSPRITESHADOW
		+DONTTRANSLATE //Needed to fix Camp uniform palette - ozy81
		+THRUSPECIES // Needed for swimming through ActorBlockers
		Species "Player";
		Player.MaxHealth 100; // Needed for improved vitality serum
		Player.InvulnerabilityMode "reflective";
		Player.StartItem "AstroChaingunLoaded",30;
		Player.StartItem "AstroRocketLauncherLoaded",5;
		Player.StartItem "AstroShotgunLoaded",8;
		Player.StartItem "Browning5Loaded",5;
		Player.StartItem "G43Loaded",10;
		Player.StartItem "Kar98kLoaded",5;
		Player.StartItem "Luger9mmLoaded",8;
		Player.StartItem "MP40Loaded",32;
		Player.StartItem "PanzerschreckLoaded";
		Player.StartItem "PyrolightLoaded",50;
		Player.StartItem "StenLoaded",32;
		Player.StartItem "TeslaLoaded",30;
		Player.StartItem "TrenchShotgunLoaded",8;
		Player.StartItem "Walther9mmLoaded",8;
		Player.StartItem "Stamina", 100;
		Player.StartItem "NullWeapon", 1;
		Player.StartItem "KnifeSilent";
		Player.SoundClass "player";
		Player.ViewHeight 56;
		Player.AttackZOffset 24;
		Player.DisplayName "William Blazkowicz";
		Player.CrouchSprite "PLYC";
		Player.SideMove 1.0, 1.0;
		Player.ForwardMove 1.0, 1.0;
		Player.ViewBob 0.44;
		Player.WeaponSlot 1, "KnifeSilent", "Shovel", "Firebrand", "AstrosteinMelee"; //, "FakeID";
		Player.WeaponSlot 2, "Luger9mm", "Walther9mm", "AstroLuger";
		Player.WeaponSlot 3, "TrenchShotgun", "Browning5", "AstroShotgun";
		Player.WeaponSlot 4, "MP40", "Sten", "AstroChaingun";
		Player.WeaponSlot 5, "Kar98k", "G43";
		Player.WeaponSlot 6, "Pyrolight", "Nebelwerfer", "AstroRocketlauncher";
		Player.WeaponSlot 7, "Panzerschreck";
		Player.WeaponSlot 8, "TeslaCannon", "UMG43";
		Player.WeaponSlot 0, "NullWeapon";
		Player.DamageScreenColor "ff 00 00", 0.0;
		Player.DamageScreenColor "ff ff ff", 1.0, "IceWater";
		Player.DamageScreenColor "64 00 C8", 0.0, "MutantPoison";
		Player.DamageScreenColor "64 00 C8", 1.0, "MutantPoisonAmbience"; // Used for poison damage
		Player.DamageScreenColor "00 5A 40", 0.0, "UndeadPoison";
		Player.DamageScreenColor "00 5A 40", 1.0, "UndeadPoisonAmbience"; // Used for poison damage
		DamageFactor "Creepy", 0.0;
		DamageFactor "FriendlyFrag", 0.5;
		Scale 0.65;
	}

	States
	{
	Spawn:
		PLAY A 0 DoTokenChecks(); // Must run the check once here because it can miss a frame somehow otherwise.  All other states are taken care of in the Tick function.
	SpawnLoop:
		"####" A 1;
		Loop;
	See:
		PLAY ABCD 8 {   // Urgh.  So that player menu preview will show up properly...
			// The menu code looks for the See state frames and duration, but doesn't process code - It also doesn't handle "####" frames.
			// Since this return is processed before the frame is rendered, the actor will jump to the proper See state in-game without
			// screwing up the handling for disguises or ever showing the wrong sprites.
			return ResolveState("See.InGame");
		}
		Loop;
	See.InGame:
		"####" AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDD 1;
		"####" # 0 A_Jump(256, "SpawnLoop");
	Pain.Numbness:
		"####" G 0 {
			A_GiveInventory("CurseNumbness", Random(25, 50));
			A_GiveInventory("BlurShaderControl", Random(25, 50));
		}
		"####" # 0 A_Jump(256, "Pain");
	Pain.Electric:
		"####" G 0 {
			A_SetBlend("White", FRandom(3.25, 7.25), Random(1, 4));
			A_GiveInventory("BlurShaderControl", Random(5, 10));
		}
	Pain:
		"####" G 0 ACS_NamedExecuteWithResult("PlayerFlinch", flinchfactor);
		"####" G 4 A_PlayerPain();
		"####" # 0 A_Jump(256, "SpawnLoop");
	Missile:
		"####" E 12;
		"####" # 0 A_Jump(256, "SpawnLoop");
	Melee:
		"####" F 6;
		"####" # 0 A_Jump(256, "Missile");
	Disintegrate: //here in order to transfer properly frames if needed - ozy81
		"####" G 0 A_StartSound("astrostein/guard_death");
		"####" G 5 A_PlayerScream();
		"####" G 0 A_NoBlocking;
		"####" G 0 A_SpawnItemEx("BaseLineSpawner", random(16, -16), random(16, -16), random(0, 8), 0, 0, random(1,3), 0, 129, 0);
		"####" GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 1 A_FadeOut(0.02,0);
		TNT1 A -1 A_SetTranslucent(1);
		Stop;
	Death:
		"####" H 5 A_PlayerScream();
		"####" I 8;
		"####" I 1 A_StartSound("death/bjfall");
		"####" J 5 A_NoBlocking;
		"####" K 5;
		"####" LM 2;
		"####" N -1;
		Stop;
	Death.Fire:
		"####" # 0 {sprite = GetSpriteIndex(Random() < 128 ? "BURN" : "NRUB");}
		"####" A 5 Bright Light("ITBURNS1") { A_Wander(); }
		"####" BC 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
		"####" D 5 Bright Light("ITBURNS1") { A_Wander(); A_StartSound("death/burning"); }
		"####" E 5 Bright Light("ITBURNS1") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
		"####" FABCD 5 Bright Light("ITBURNS2") { A_Wander(); A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,32), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
		"####" EFAG 5 Bright Light("ITBURNS3") A_Wander();
		"####" H 5 Bright Light("ITBURNS3") A_Wander();
		"####" IJK 5 Bright Light("ITBURNS2") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,16), 1, 0, random (1, 3), random (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
		"####" LMN 5 Bright Light("ITBURNS1") { A_SpawnItemEx("FloatingCinder", random(-8,8), random(-8,8), random(0,8), 1, 0, random (1, 3), frandom (0, 360), SXF_TRANSFERPITCH | SXF_CLIENTSIDE, 160); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
		"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
	Death.Fire.Smoke:
		"####" O 0 A_Jump(32,"Death.Fire.End");
		"####" O 2 Light("ITBURNS4");
		"####" O 4 Light("ITBURNS5");
		"####" O 3 Light("ITBURNS6");
		"####" O 5 Light("ITBURNS5");
		Loop;
	Death.Fire.End:
		"####" O -1;
		Stop;
	Death.Electric:
		"####" # 0 {sprite = GetSpriteIndex(Random() < 128 ? "FIZZ" : "ZZIF");}
		"####" # 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		"####" A 5 Bright Light("TPortNormal");
		"####" BA 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
		"####" B 5 Bright Light("TPortNormal") { A_StartSound("death/burning"); A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0)); }
		"####" AABAB 5 Bright Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
		"####" C 7 Light("TPortNormal");
		"####" DE 6 Light("TPortNormal") A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
		"####" FG 5 A_SpawnItemEx("BodySmoke", random(-3,3), random(-3,3), random(0,56), 0, 0, frandom(0.2,1.0));
		"####" A 0 A_SpawnItemEx("BodySmokeSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER);
	Death.Electric.Smoke:
		"####" H 0 A_Jump(32,"Death.Electric.End");
		"####" H 2;
		"####" H 4;
		"####" H 3;
		"####" H 5;
		Loop;
	Death.Electric.End:
		"####" H -1;
		Stop;
	SpriteLookups:
		BURN A 0;
		NRUB A 0;
		FIZZ A 0;
		ZZIF A 0;
	}

	override void PostBeginPlay()
	{
		flinchfactor = 255; // Start out with full flinch amount.
		dodragging = false;
		int playerID = PLAYER_TAG_OFFSET + PlayerNumber();
		Thing_ChangeTID(0, playerID);

		tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));

		Super.PostBeginPlay();
	}

	override void Tick()
	{
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

	override void TickPSprites()
	{
		let player = self.player;
		let pspr = player.psprites;
		while (pspr)
		{
			// Destroy the psprite if it's from a weapon that isn't currently selected by the player
			// or if it's from an inventory item that the player no longer owns. 
			if ((pspr.Caller == null ||
				(pspr.Caller is "Inventory" && Inventory(pspr.Caller).Owner != pspr.Owner.mo) ||
				(pspr.Caller is "Weapon" && pspr.Caller != pspr.Owner.ReadyWeapon)))
			{
				pspr.Destroy();
			}
			else
			{
				pspr.Tick();
			}

			pspr = pspr.Next;
		}

		if ((health > 0) || (player.ReadyWeapon != null && !player.ReadyWeapon.bNoDeathInput))
		{
			if (player.ReadyWeapon == null)
			{
				if (player.PendingWeapon != WP_NOCHANGE)
					player.mo.BringUpWeapon();
			}
			else
			{
				CheckWeaponChange();
				if (player.WeaponState & (WF_WEAPONREADY | WF_WEAPONREADYALT) && !FindInventory("HQ_Checker", true))
				{
					CheckWeaponFire();
				}
				// Check custom buttons
				CheckWeaponButtons();
			}
		}
	}

	override void MovePlayer ()
	{
		let player = self.player;
		UserCmd cmd = player.cmd;

		// [RH] 180-degree turn overrides all other yaws
		if (player.turnticks)
		{
			player.turnticks--;
			Angle += (180. / TURN180_TICKS);
		}
		else
		{
			if (DragTarget) { cmd.yaw = int(cmd.yaw * 0.15); }
			Angle += cmd.yaw * (360./65536.);
		}

		player.onground = (pos.z <= floorz) || bOnMobj || bMBFBouncer || (player.cheats & CF_NOCLIP2);

		// killough 10/98:
		//
		// We must apply thrust to the player and bobbing separately, to avoid
		// anomalies. The thrust applied to bobbing is always the same strength on
		// ice, because the player still "works just as hard" to move, while the
		// thrust applied to the movement varies with 'movefactor'.

		if (cmd.forwardmove | cmd.sidemove)
		{
			double forwardmove, sidemove;
			double bobfactor;
			double friction, movefactor;
			double fm, sm;

			[friction, movefactor] = GetFriction();
			bobfactor = friction < ORIG_FRICTION ? movefactor : ORIG_FRICTION_FACTOR;

			if (!player.onground && !bNoGravity && !waterlevel && !leveltilt && !climbing)
			{
				// [RH] allow very limited movement if not on ground.
				movefactor *= level.aircontrol;
				bobfactor *= level.aircontrol;
			}

			fm = cmd.forwardmove;
			sm = cmd.sidemove;
			[fm, sm] = TweakSpeeds (fm, sm);
			fm *= Speed / 256;
			sm *= Speed / 256;

			// When crouching, speed and bobbing have to be reduced
			if (CanCrouch() && player.crouchfactor != 1)
			{
				fm *= player.crouchfactor;
				sm *= player.crouchfactor;
				bobfactor *= player.crouchfactor;
			}

			forwardmove = fm * movefactor * (35 / TICRATE);
			sidemove = sm * movefactor * (35 / TICRATE);

			if (forwardmove)
			{
				if (leveltilt <= 30) { Bob(Angle, cmd.forwardmove * bobfactor / 256., true); }
				if (leveltilt && !climbing)
				{
					vel.x += forwardmove * cos(angle) * cos(leveltilt) * speed * 1.5;
					vel.y += forwardmove * sin(angle) * speed;
					vel.z -= forwardmove * cos(angle - leveltiltangle) * sin(leveltilt) * speed * 1.5;
				}
				else
				{
					ForwardThrust(forwardmove, Angle);
				}
			}
			if (sidemove)
			{
				let a = Angle - 90;
				if (leveltilt <= 30) { Bob(a, cmd.sidemove * bobfactor / 256., false); }

				if (leveltilt && !climbing)
				{
					vel.x += sidemove * sin(angle) * cos(leveltilt) * speed * 1.75;
					vel.y += -sidemove * cos(angle) * speed * 1.75;
					vel.z -= sidemove * sin(angle - leveltiltangle) * sin(leveltilt) * speed * 1.75;
				}
				else
				{
					Thrust(sidemove, a);
				}
			}

			if (!(player.cheats & CF_PREDICTING) && (forwardmove != 0 || sidemove != 0))
			{
				PlayRunning ();
			}

			if (player.cheats & CF_REVERTPLEASE)
			{
				player.cheats &= ~CF_REVERTPLEASE;
				player.camera = player.mo;
			}
		}
	}

	override void CheckCheats()
	{
		let player = self.player;
		// No-clip cheat
		if ((player.cheats & (CF_NOCLIP | CF_NOCLIP2)) == CF_NOCLIP2)
		{ // No noclip2 without noclip
			player.cheats &= ~CF_NOCLIP2;
		}
		bNoClip = (player.cheats & (CF_NOCLIP | CF_NOCLIP2) || Default.bNoClip);
		if (player.cheats & CF_NOCLIP2)
		{
			bNoGravity = true;
		}
		else if (!climbing && !bFly && !Default.bNoGravity) // Added 'climbing' check
		{
			bNoGravity = false;
		}
	}

	override void CheatGive (String name, int amount)
	{
		int i;
		Class<Inventory> type;
		let player = self.player;

		if (player.mo == NULL || player.health <= 0)
		{
			return;
		}

		AchievementTracker.CheckAchievement(PlayerNumber(), AchievementTracker.ACH_NAUGHTY);

		int giveall = ALL_NO;
		if (name ~== "all")
		{
			giveall = ALL_YES;
		}
		else if (name ~== "everything")
		{
			giveall = ALL_YESYES;
		}

		if (giveall || name ~== "health")
		{
			if (amount > 0)
			{
				health += amount;
				player.health = health;
			}
			else
			{
				player.health = health = GetMaxHealth(true);
			}

			let def = GetDefaultByType("Stamina");
			GiveInventory("Stamina", def.MaxAmount);
		}

		if (giveall || name ~== "backpack")
		{
			// Select the correct type of backpack based on the game
			type = (class<Inventory>)(gameinfo.backpacktype);
			if (type != NULL)
			{
				GiveInventory(type, 1, true);
			}

			if (!giveall)
				return;
		}

		if (giveall || name ~== "ammo")
		{
			// Find every unique type of ammo. Give it to the player if
			// he doesn't have it already, and set each to its maximum.
			for (i = 0; i < AllActorClasses.Size(); ++i)
			{
				let ammotype = (class<Ammo>)(AllActorClasses[i]);

				if (ammotype && GetDefaultByType(ammotype).GetParentAmmo() == ammotype)
				{
					let ammoitem = FindInventory(ammotype);
					if (ammoitem == NULL)
					{
						ammoitem = Inventory(Spawn (ammotype));
						ammoitem.AttachToOwner (self);
						ammoitem.Amount = ammoitem.MaxAmount;
					}
					else if (ammoitem.Amount < ammoitem.MaxAmount)
					{
						ammoitem.Amount = ammoitem.MaxAmount;
					}
				}
			}

			if (!giveall)
				return;
		}

		if (giveall || name ~== "armor")
		{
			if (gameinfo.gametype != GAME_Hexen)
			{
				let armoritem = BasicArmorPickup(Spawn("BasicArmorPickup"));
				armoritem.SaveAmount = 100*deh.BlueAC;
				armoritem.SavePercent = gameinfo.Armor2Percent > 0 ? gameinfo.Armor2Percent * 100 : 50;
				if (!armoritem.CallTryPickup (self))
				{
					armoritem.Destroy ();
				}
			}
			else
			{
				for (i = 0; i < 4; ++i)
				{
					let armoritem = Inventory(Spawn("HexenArmor"));
					armoritem.health = i;
					armoritem.Amount = 0;
					if (!armoritem.CallTryPickup (self))
					{
						armoritem.Destroy ();
					}
				}
			}

			if (!giveall)
				return;
		}

		if (giveall || name ~== "keys")
		{
			for (int i = 0; i < AllActorClasses.Size(); ++i)
			{
				if (AllActorClasses[i] is "Key")
				{
					let keyitem = GetDefaultByType (AllActorClasses[i]);
					if (keyitem.special1 != 0)
					{
						let item = Inventory(Spawn(AllActorClasses[i]));
						if (!item.CallTryPickup (self))
						{
							item.Destroy ();
						}
					}
				}
			}
			if (!giveall)
				return;
		}

		if (giveall || name ~== "weapons")
		{
			let savedpending = player.PendingWeapon;
			for (i = 0; i < AllActorClasses.Size(); ++i)
			{
				let type = (class<Weapon>)(AllActorClasses[i]);
				if (type != null && type != "Weapon")
				{
					// Don't give replaced weapons unless the replacement was done by Dehacked.
					let rep = GetReplacement(type);
					if (rep == type || rep is "DehackedPickup")
					{
						// Give the weapon only if it is set in a weapon slot.
						if (player.weapons.LocateWeapon(type))
						{
							readonly<Weapon> def = GetDefaultByType (type);
							if (giveall == ALL_YESYES || !def.bCheatNotWeapon)
							{
								GiveInventory(type, 1, true);
							}
						}
					}
				}
			}
			player.PendingWeapon = savedpending;

			if (!giveall)
				return;
		}

		if (giveall || name ~== "artifacts")
		{
			for (i = 0; i < AllActorClasses.Size(); ++i)
			{
				let type = (class<Inventory>)(AllActorClasses[i]);
				if (type!= null)
				{
					let def = GetDefaultByType (type);
					if (def.Icon.isValid() && (def.MaxAmount > 1 || def.bInvBar) && // Add check so that any actor that is set to show up on the inventory bar will be added
						!(type is "PuzzleItem") && !(type is "Powerup") && !(type is "Ammo") &&	!(type is "Armor"))
					{
						// Do not give replaced items unless using "give everything"
						if (giveall == ALL_YESYES || GetReplacement(type) == type)
						{
							GiveInventory(type, amount <= 0 ? def.MaxAmount : amount, true);

							if (type is "PoweredInventory") // Give full fuel for any powered inventory item
							{
								Class<Inventory> fuel = PoweredInventory(def).fuelclass;
								def = GetDefaultByType(fuel);
								GiveInventory(fuel, def.MaxAmount, true);
							}
						}
					}
				}
			}
			if (!giveall)
				return;
		}

		if (giveall || name ~== "gold" || name ~== "treasure" || name ~== "money" || name ~== "coins")
		{
			let type = (class<CoinItem>)("CoinItem");

			if (type)
			{
				let def = GetDefaultByType(type);
				GiveInventory(type, amount <= 0 ? def.MaxAmount : amount, true);
			}

			if (!giveall) { return; }
		}

		if (giveall || name ~== "puzzlepieces")
		{
			for (i = 0; i < AllActorClasses.Size(); ++i)
			{
				let type = (class<PuzzleItem>)(AllActorClasses[i]);
				if (type != null)
				{
					let def = GetDefaultByType (type);
					if (def.Icon.isValid())
					{
						// Do not give replaced items unless using "give everything"
						if (giveall == ALL_YESYES || GetReplacement(type) == type)
						{
							GiveInventory(type, amount <= 0 ? def.MaxAmount : amount, true);
						}
					}
				}
			}
			if (!giveall)
				return;
		}

		if (giveall)
			return;
		
		if (name ~== "astrostein")
		{
			GiveInventory("AstrosteinMelee", 1);
			GiveInventory("AstroLuger", 1);
			GiveInventory("AstroClipAmmo", GetDefaultByType("AstroClipAmmo").MaxAmount);
			GiveInventory("AstroShotgun", 1);
			GiveInventory("AstroShotgunShell", GetDefaultByType("AstroShotgunShell").MaxAmount);
			GiveInventory("AstroChaingun", 1);
			GiveInventory("AstroRocketLauncher", 1);
			GiveInventory("AstroRocketAmmo", GetDefaultByType("AstroRocketAmmo").MaxAmount);
			GiveInventory("AstroGrenadePickup", GetDefaultByType("GrenadePickup").MaxAmount);

			return;
		}

		type = name;
		if (type == NULL)
		{
			if (PlayerNumber() == consoleplayer)
				A_Log(String.Format("Unknown item \"%s\"\n", name));
		}
		else
		{
			GiveInventory(type, amount, true);
		}
		return;
	}

	override void PlayerThink()
	{
		let player = self.player;
		UserCmd cmd = player.cmd;
		prevBob = player.bob; // Fix for weapon stutter

		CheckFOV();

		if (player.inventorytics)
		{
			player.inventorytics--;
		}
		CheckCheats();

		if (bJustAttacked)
		{ // Chainsaw/Gauntlets attack auto forward motion
			cmd.yaw = 0;
			cmd.forwardmove = 0xc800/2;
			cmd.sidemove = 0;
			bJustAttacked = false;
		}

		bool totallyfrozen = CheckFrozen();

		// Handle crouching
		CheckCrouch(totallyfrozen);
		CheckMusicChange();

		if (player.playerstate == PST_DEAD)
		{
			DeathThink ();
			return;
		}

		if (player.jumpTics != 0)
		{
			player.jumpTics--;
			if (player.onground && player.jumpTics < -18)
			{
				player.jumpTics = 0;
			}
		}

		if (player.morphTics && !(player.cheats & CF_PREDICTING)) { MorphPlayerThink (); }

		// Crouching moves down while climbing
		if (climbing && cmd.buttons & BT_CROUCH) { vel.z -= 0.95; }

		CheckPitch();
		HandleMovement();

		// Only recalculate the view position if you're not climbing or if you are climbing at speed
		// Keeps the float bob effect from being visible to the player
		if (!climbing || abs(vel.length()) > 1.0) { CalcHeight (); }

		// Bobbing while on the ladder is caused by P_ZMovement in p_mobj.cpp and can't be altered (currently lines 3028-3035).  
		// This flag tricks the player actor into only bobbing a tiny bit, but is an awful hack that depends on a quirk in the checks in the internal code.
		// NOCLIP2 gets unset almost immediately after the check is made here, so never actually takes effect.
		// Since this is just cosmetic (you only see it in chasecam or multiplayer), it may be best to comment it out, just in case internal code changes in the future.
//		if (climbing) { player.cheats |= CF_NOCLIP2; }

		if (!(player.cheats & CF_PREDICTING))
		{
			CheckEnvironment();
			CheckUse();
			CheckUndoMorph();
			// Cycle psprites.
			// Note that after this point the PlayerPawn may have changed due to getting unmorphed so 'self' is no longer safe to use.
			player.mo.TickPSprites();
			// Other Counters
			if (player.damagecount)	player.damagecount--;
			if (player.bonuscount) player.bonuscount--;

			if (player.hazardcount)
			{
				player.hazardcount--;
				if (!(level.time % player.hazardinterval) && player.hazardcount > 16*TICRATE)
					player.mo.DamageMobj (NULL, NULL, 5, player.hazardtype);
			}
			player.mo.CheckPoison();
			player.mo.CheckDegeneration();
			player.mo.CheckAirSupply();
		}
	}

	override void CheckJump()
	{
		let player = self.player;
		// [RH] check for jump
		if (player.cmd.buttons & BT_JUMP)
		{
			if (player.crouchoffset != 0)
			{
				// Jumping while crouching will force an un-crouch but not jump
				player.crouching = 1;
			}
			else if (waterlevel >= 2)
			{
				Vel.Z = 4 * Speed;
			}
			else if (bNoGravity && !leveltilt && !climbing)
			{
				Vel.Z = 3.;
			}
			else if (climbing && !player.onground && level.IsJumpingAllowed())
			{
				if (abs(deltaangle(angle, AngleTo(climbing))) > 60)
				{
					if (player.cmd.forwardmove > 0)
					{
						Thrust(Speed / 2, angle);
						Vel.Z = 1.0;
					}
				}
				else
				{
					Vel.Z = 3.;
				}
			}
			else if (level.IsJumpingAllowed() && (player.onground || leveltilt != 0) && player.jumpTics == 0)
			{
				double jumpvelz = JumpZ * 35 / TICRATE;
				double jumpfac = 0;

				// [BC] If the player has the high jump power, double his jump velocity.
				// (actually, pick the best factors from all active items.)
				for (let p = Inv; p != null; p = p.Inv)
				{
					let pp = PowerHighJump(p);
					if (pp)
					{
						double f = pp.Strength;
						if (f > jumpfac) jumpfac = f;
					}
				}
				if (jumpfac > 0) jumpvelz *= jumpfac;

				Vel.X += jumpvelz * sin(leveltilt) * cos(leveltiltangle) * level.aircontrol;
				Vel.Y += jumpvelz * sin(leveltilt) * sin(leveltiltangle) * level.aircontrol;
				Vel.Z += jumpvelz * cos(leveltilt);
				bOnMobj = false;
				player.jumpTics = -1;
				if (!(player.cheats & CF_PREDICTING)) A_StartSound("*jump", CHAN_BODY);
			}
		}
	}

	override void CheckUndoMorph()
	{
		if (player) { Super.CheckUndoMorph(); }
	}

	virtual Actor GetLineTarget()
	{
		CrosshairTracer actortrace;
		actortrace = new("CrosshairTracer");

		actortrace.skipactor = self;
		Vector3 tracedir = ZScriptTools.GetTraceDirection(Angle, Pitch);
		actortrace.Trace(self.pos + (0, 0, player.viewheight), self.CurSector, tracedir, 2560, 0);

		return actortrace.Results.HitActor;
	}

	virtual Actor GetClosestForcedHealthBar()
	{
		ThinkerIterator Finder = ThinkerIterator.Create("Base", Thinker.STAT_DEFAULT - 3);
		Base it;
		Actor mo;

		while ( it = Base(Finder.Next()) )
		{
			if (!it.user_DrawHealthBar == True) { continue; } // Only process actors with the AlwaysDrawHealthBar flag set
			if (
				it.health <= 0 ||
				!it.bShootable ||
				it.bDormant
			) { continue; }
			if (mo && Distance3D(it) > Distance3D(mo)) { continue; } // Only draw health bar for the closest one

			mo = it;
		}

		return mo;
	}

	// Allow derived classes to run a check every tick
	virtual void DoTokenChecks() {}

	// Function to spawn no more than a single copy of an effect actor as a child of the player
	// No longer used in the mod, but left for compatibility and possible extension in the future
	// Would be useful for swirling particle effects that follow the player, etc.
	void SpawnEffect(class<PlayerEffect> effect)
	{
		ThinkerIterator it = ThinkerIterator.Create("PlayerEffect", Thinker.STAT_DEFAULT - 4);
		PlayerEffect mo;

		while (mo = PlayerEffect(it.Next()))
		{
			if (mo.master && mo.master != self) { continue; } // Only look at effects that belong to this player actor
			if (mo is effect) { return; } // The effect already exists, so abort so we don't spawn it again
		}

		// If it wasn't already there, spawn this effect
		Actor newEffect = Spawn(effect);
		if (newEffect) { newEffect.master = self; }
	}

	// Function to remove any spawned copy of an effect that is a child of the player
	void RemoveEffect(class<PlayerEffect> effect)
	{
		ThinkerIterator it = ThinkerIterator.Create("PlayerEffect", Thinker.STAT_DEFAULT - 4);
		PlayerEffect mo;

		while (mo = PlayerEffect(it.Next()))
		{
			if (mo.master && mo.master != self) { continue; } // Only look at effects that belong to this player actor
			if (mo is effect) { mo.SetStateLabel('null'); } // Remove the effect, if found
		}
	}

	// Function to handle leveltilt-induced "gravity" effects.
	void DoGravity()
	{
		// If the player isn't using NOCLIP and they are at the "tipping point" for their mass, make them slide to the new "down"
		if (abs(leveltilt) >= min(mass, 1000) / 1000.0 * 45 && !(player.cheats & (CF_NOCLIP | CF_NOCLIP2)) && !climbing)
		{
			bNoGravity = leveltilt != 0;

			double grav = level.gravity * CurSector.gravity * Gravity * 0.00125;

			vel.z -= grav * cos(leveltilt);
			vel.x -= grav * sin(leveltilt) * cos(leveltiltangle);
			vel.y -= grav * sin(leveltilt) * sin(leveltiltangle);

			if (leveltilt != oldtilt)
			{
				// if (leveltilt == 0) will never be true because of the
				// previous "if" statement
				double abstilt = abs(leveltilt);
				double newradius = Default.radius * cos(abstilt) + Default.height / 2 * sin(abstilt);
				double newheight = Default.radius * sin(abstilt) + Default.height / 2 * cos(abstilt);

				if (height != newheight || radius != newradius) { A_SetSize(newradius, newheight, true); }

				oldtilt = leveltilt;
			}
		}
		else if (oldtilt != 0 && leveltilt == 0)
		{
			A_SetSize(Default.Radius, Default.Height);
			oldtilt = 0;
		}
	}

	virtual void DoInteractions()
	{
		FLineTraceData trace;
		LineTrace(angle, UseRange, pitch, TRF_THRUACTORS, player.viewheight, 0.0, 0.0, trace);
		Line AimLine = trace.HitLine;
		TextureID AimTexture = trace.HitTexture;

		FLineTraceData actortrace;
		LineTrace(angle, UseRange, pitch, TRF_ALLACTORS, player.viewheight, 0.0, 0.0, actortrace); // Corpse dragging needs to trace without TRF_THRUACTORS flag
		Actor AimActor = actortrace.HitActor;

		interactiontimeout = max(interactiontimeout - 1, 0);

		if (AimTexture)
		{
			// Handle texture-specific "generic" activations - really need to figure out a 
			// good way to make this an event handler or something, so it's not tied only
			// to the BoAPlayer player class.
			if (player.buttons & BT_USE && !(player.oldbuttons & BT_USE)) // If the player just pressed use
			{
				// See what texture we are aiming at
				String texname = TexMan.GetName(AimTexture);

				if (texname.IndexOf(".") >= 0) // If it's a long filename
				{
					// Strip the texture name down to only the filename (basically the old-style texture name, but allowing more than 8 characters)
					int start = texname.RightIndexOf("/") + 1;
					texname = texname.Mid(start, texname.RightIndexOf(".") - start);
				}

				// Convert to all upper-case for comparison
				texname.ToUpper();

				if (texname == "CABN_T02" && !interactiontimeout) // If it's the storage shelf with medkits...
				{
					if (Health < MaxHealth) // ...and we're not at full health...
					{
						GiveInventory("RegenPowerup", 1); // Heal by 10 and play the bandage tearing sound
						A_StartSound("pickup/bandage", CHAN_VOICE);
						interactiontimeout = 350; // Set use delay of 10 seconds before re-use
					}
				}
				else if (texname == "VENT_M01") // If it's a breakable vent...
				{
					if (trace.HitType == FLineTraceData.TRACE_HitWall)
					{
						AimLine.Activate(self, trace.LineSide, SPAC_Impact); // Pretend it was shot
					}
				}
				else if (AimActor)
				{
					A_StopSound(CHAN_VOICE);
				}
				else if (!AimLine || !(AimLine.activation & SPAC_Use) || (Aimline.locknumber && !CheckKeys(Aimline.locknumber, false, true)))
				{
					String snd = InteractionHandler.GetSound(texname);
					if (snd.length())
					{
						A_StartSound(snd, CHAN_VOICE, 0, 0.25);
					}
				}
			}
		}

		if (AimLine && !crosshair)
		{
			// Only show custom crosshair if the line is running a script, is a locked door or puzzle item use line, or has a UDMF lock number
			//  Otherwise - Why?  It's not an activation line, so what's the point of showing a hint?
			if ( 	
				AimLine.special == 13 || // Door_LockedRaise
				AimLine.special == 80 || // ACS_Execute 
				(AimLine.special >= 83 && AimLine.special <= 85) || // ACS_LockedExecute, ACS_ExecuteWithResult, ACS_LockedExecuteDoor
				Aimline.special == 129 || // UsePuzzleItem
				AimLine.special == 226 || // ACS_ExecuteAlways
				Aimline.locknumber
			)
			{
				crosshair = AimLine.GetUDMFInt("user_crosshair"); // Use the line's user_crosshair property if it has a value
				crosshairstring = AimLine.GetUDMFString("user_crosshair"); // Or try looking for a class name as a string value
			}
			else
			{
				crosshair = 0;
				crosshairstring = "";
			}
		}

		if (AimLine && !AimLine.special) { AimLine = null; }

		// If line is set to block hitscans only, do some special handling
		if (AimLine && AimLine.flags & Line.ML_BLOCKHITSCAN && !(AimLine.flags & Line.ML_BLOCKEVERYTHING) && !(AimLine.flags & Line.ML_WRAP_MIDTEX))
		{
			if (AimLine.flags & Line.ML_3DMIDTEX) // If it's a 3D midtex, figure out if we hit the texture or not...
			{
				let side = AimLine.sidedef[trace.LineSide];

				if (side)
				{
					TextureID tex = side.GetTexture(trace.LinePart);

					if (tex)
					{
						Vector2 texsize = TexMan.GetScaledSize(tex);
						double scaley = side.GetTextureYScale(trace.LinePart);
						double sizey = texsize.y / scaley;
						double offsety = side.GetTextureYOffset(trace.LinePart) / scaley;

						double topz, bottomz;

						// Adjust things if lower unpegged is set...
						if (AimLine.flags & Line.ML_DONTPEGBOTTOM) { topz = sizey; }
						else { topz = trace.HitSector.ceilingplane.D - trace.HitSector.floorplane.D; }

						topz += offsety;
						bottomz = topz - sizey;

						double hitz = trace.HitLocation.z + trace.HitSector.floorplane.D;

						if (topz < hitz || bottomz > hitz) // You're not actually looking at the midtex!
						{
							AimLine = null; // Clear the line pointer
						}
					}
					else // No texture
					{
						AimLine = null; // Clear the line pointer
					}
				}
			}
		}

		// Handle player holding down use button while looking at a repeatable, script-executing line that's within use range
		if (AimLine && (crosshair || !(crosshairstring == ""))) // If we are actually looking at a line within range, and it sets an interaction crosshair
		{
			if (
				( // And the line is running a script
					AimLine.special == 80 || 
					(AimLine.special >= 83 && AimLine.special <= 85) || 
					AimLine.special == 226
				) &&
				( // And is flagged as repeatable and you're pressing use
					AimLine.flags & Line.ML_REPEAT_SPECIAL && 
					player.cmd.buttons & BT_USE
				) &&
				( // And we have the right UDMF-defined key if one was set on the line!
					!Aimline.locknumber || 
					CheckKeys(Aimline.locknumber, false, true)
				)
			)
			{
				player.usedown = false; // Pretend that the use button wasn't actually being held so that the use action will repeat as long as use is held

				if (!LastWeapon && crosshair >= 80 && crosshair <= 90) // Only lower weapon when there's a status display
				{
					Weapon lowered = Weapon(FindInventory("NullWeapon"));

					if (player.ReadyWeapon != lowered) { LastWeapon = player.ReadyWeapon; }
					player.PendingWeapon = lowered;
				}
			}
		}
		// Draggable corpse handling (also lets you pull pushable actors)
		// Player must _hold_ crouch within use range of a draggable actor and _hold_ use, then move to drag the actor along
		// There is also little sense to drag something with a weapon in your hands, so it gets lowered
		else if (dodragging && (AimActor || DragTarget) && player.usedown && player.cmd.buttons & BT_CROUCH)
		{
			if (DragTarget)
			{
				DragTarget.Warp(self, Clamp(Distance2D(DragTarget), radius + DragTarget.radius + speed, UseRange), flags:WARPF_INTERPOLATE | WARPF_NOCHECKPOSITION);
				// Closed hand grab icon
				crosshair = 97;
			}
			else
			{
				if (
					AimActor && 
					Distance2D(AimActor) < UseRange && 
					(
						(IsCorpse(AimActor) && !AimActor.bBOSS) ||
						(AimActor.bPushable && !AimActor.bISMONSTER)
					)
				)
				{
					if (!LastWeapon)
					{
						Weapon lowered = Weapon(FindInventory("NullWeapon"));

						if (player.ReadyWeapon != lowered) { LastWeapon = player.ReadyWeapon; }
						player.PendingWeapon = lowered;
					}
					DragTarget = AimActor;
					GiveInventory("IsDragging", 1);
					Speed = Default.Speed / (1.0 + AimActor.mass / (player.mo.mass + 1.0));
				}
			}
		}
		else
		{
			if (LastWeapon)
			{
				player.PendingWeapon = LastWeapon;
				LastWeapon = null;
			}

			crosshair = 0;
			crosshairstring = "";

			if (dodragging)
			{
				DragTarget = null;
				Speed = Default.Speed;
				TakeInventory("IsDragging", 1);
				if (
					player.cmd.buttons & BT_CROUCH &&
					AimActor && 
					Distance2D(AimActor) < UseRange + AimActor.Radius && 
					(
						(IsCorpse(AimActor) && !AimActor.bBOSS) ||
						(AimActor.bPushable && !AimActor.bISMONSTER)
					)
				)
				{
					// Open hand grab icon
					crosshair = 98;
				}
			}
		}

		// Blank out the actual crosshair if a custom one is being used - 0 reverts to the player or weapon's default
		if (player.ReadyWeapon) { player.ReadyWeapon.Crosshair = (crosshair > 0 || crosshairstring || player.mo.FindInventory("CutsceneEnabled")) ? 99 : 0; }
	}

	bool IsCorpse(Actor mo)
	{
		if (
			!mo.bIsMonster ||
			mo.health > 0 ||
			mo.bDormant
		) { return false; }

		return true;
	}

	static void FireWeapon(Actor mo, bool alt = 0, bool onuse = 1)
	{
		if (mo.player && mo.player.ReadyWeapon && mo.player.playerstate == PST_LIVE)
		{
			let psp = mo.player.GetPSprite(PSP_WEAPON);

			State newState = alt ? mo.player.ReadyWeapon.FindState('AltFire') : mo.player.ReadyWeapon.FindState('Fire');

			if (newState) { psp.SetState(newState); }
		}
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
				if (mo.FindInventory("PowerStrength")) { wpn.modifier = 3.0; } // Strength increases damage by 3 and range by 10
				else { wpn.modifier = 1.0; }

				mo.A_TakeInventory("Stamina", 30);
				mo.player.SetPsprite(-10, wpn.FindState("KickOverlay"), true);
			}
		}
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		String mod = (inflictor && inflictor.paintype) ? inflictor.paintype : MeansOfDeath; // Get the damage type

		if (mod == "Pest") { AchievementTracker.CheckAchievement(PlayerNumber(), AchievementTracker.ACH_PESTS); }

		double waterlevel;
		bool underwater;
		Sector watersector;
		[waterlevel, underwater, watersector] = Buoyancy.GetWaterHeight(self);
		if (underwater && (mod == "None" || mod == "Drowning"))
		{
			String texture = TexMan.GetName(watersector.GetTexture(Sector.ceiling)); 
			mod = GetTextureMod(texture, mod);
		}
		else if (mod == "None") { mod = GetTextureMod(TexMan.GetName(floorpic), mod); }

		AchievementTracker tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
		if (tracker)
		{
			if (mod == "Drowning") { tracker.SetBit(tracker.records[tracker.STAT_LIQUIDDEATH].value, 0); }
			else if (mod == "Lava") { tracker.SetBit(tracker.records[tracker.STAT_LIQUIDDEATH].value, 1); }
			else if (mod == "MutantPoisonAmbience") { tracker.SetBit(tracker.records[tracker.STAT_LIQUIDDEATH].value, 2); }

			AchievementTracker.CheckAchievement(PlayerNumber(), AchievementTracker.ACH_LIQUIDDEATH);
		}

		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
	}

	Name GetTextureMod(String texture, Name default = "None")
	{
		if (texture ~== "WATR_X98") { return "MutantPoisonAmbience"; }
		else if (
			texture.Left(5) ~== "WATR_" || 
			texture.Left(5) ~== "SLDG_" || 
			texture.Left(6) ~== "HIACID" || 
			texture.Left(6) ~== "HIWATR" || 
			texture ~== "AZTC_WTR"
		) { return "Drowning"; }
		else if (texture.Left(5) ~== "LAVA_") { return "Lava"; }

		return default;
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
/*
		String i = "null";
		String s = "null";
		if (inflictor) { i = inflictor.getclassname(); }
		if (source) { i = source.getclassname(); }

		console.printf("Inflictor: %s\nSource: %s\nMod: %s", i, s, mod);
*/
		Inventory saveme;

		if (player && player.mo && G_SkillPropertyInt(SKILLP_ACSReturn) < 3) { saveme = player.mo.FindInventory("SavingHealth", true); }

		if (saveme) { player.cheats |= CF_BUDDHA2; }

		int dmg = Super.DamageMobj(inflictor, source, damage, mod, flags, angle);

		if (saveme)
		{
			player.cheats &= ~CF_BUDDHA2;

			// If the player would have died, use the saving inventory item
			if (player.health <= 1)
			{
				saveme.Use(false);

				String msg = SavingHealth(saveme).savemessage;
				if (msg.length()) { console.printf(StringTable.Localize(msg)); }
				player.mo.RemoveInventory(saveme);
			}

			dmg = 1;
		}

		return dmg;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		// You can't walk on top of PlayerFollowers or other actors with PlayerFollower species, 
		// but will still collide with them if you walk into them, or they into you.
		if (!passive && other && other.Species == "PlayerFollower" && other.bFriendly && pos.z > other.pos.z)
		{
			return false;
		}

		return Super.CanCollideWith(other, passive);
	}

	virtual void A_PlayerPain()
	{
		// [RH] Vary player pain sounds depending on health (ala Quake2)
		if (player && player.morphTics == 0)
		{
			String pain_amount;
		
			if (health < 25)
				pain_amount = "*pain25";
			else if (health < 50)
				pain_amount = "*pain50";
			else if (health < 75)
				pain_amount = "*pain75";
			else
				pain_amount = "*pain100";

			String pain_sound;

			// Try for damage-specific sounds
			if (player.LastDamageType != "None")
			{
				pain_sound = pain_amount .. "-" .. player.LastDamageType;

				if (!S_GetLength(pain_sound))
				{
					// Try again without a specific pain amount.
					pain_sound = "*pain-" .. player.LastDamageType;
				}
			}
			if (!S_GetLength(pain_sound)) { pain_sound = pain_amount; }

			A_StartSound(pain_sound, CHAN_VOICE, CHANF_NOSTOP, 1, ATTN_NORM);
		}
		else if (PainSound)
		{
			A_StartSound(PainSound, CHAN_VOICE, CHANF_NOSTOP, 1, ATTN_NORM);
		}
	}
	
	override void OnRespawn()
	{
		if (deathmatch || alwaysapplydmflags) //only do this in deathmatch (but could be useful in single player...)
		{
			//reset inventory for deathmatch
			InventoryClearHandler invclearhandler = InventoryClearHandler(EventHandler.Find("InventoryClearHandler"));
			invclearhandler.ResetPlayerInventory(self);
		}
		Super.OnRespawn();
	}
}

// for bypassing DoSprinting from sprint.acs when dragging an object
class IsDragging: Inventory { Default { Inventory.MaxAmount 1; } }

// Base class for simple visual effects that will always follow the player until removed
class PlayerEffect : Actor
{
	Default
	{
		+NOINTERACTION
	}

	States
	{
		Spawn:
			// This state should be replaced in child classes
			UNKN A 1;
			Loop;
	}

	override void BeginPlay()
	{
		ChangeStatNum(Thinker.STAT_DEFAULT - 4);
	}

	override void Tick()
	{
		// If a master is assigned, always move to its location
		if (master) { SetOrigin(master.pos, true); }
		Super.Tick();
	}
}

// No longer used for player, but used as a debugging marker
class FireBrandEffect : PlayerEffect 
{
	States
	{
		Spawn:
			TNT1 A 4 NODELAY Light("ITBURNSOC1");
			TNT1 A 4 Light("ITBURNSOC2");
		SpawnLoop:
			TNT1 A 4 Light("ITBURNSOC3") A_SetTics(Random(1, 8));
			Loop;
	}
}

Class CrosshairTracer : LineTracer
{
	Actor skipactor;

	override ETraceStatus TraceCallback() 
	{
		if (Results.HitType == TRACE_HitActor)
		{
			Actor actual = Results.HitActor;
			while (actual.master) { actual = actual.master; } // If the actor has a master, pretend the tracer hit the master

			if (actual == skipactor || actual is "EffectSpawner") { Results.HitActor = null; return TRACE_Skip; } // Skip the player and any children, and any effect spawners 
			if (
				!actual.bNoInteraction && // If it's actually interactive...
				(actual.bSolid || actual.bShootable) && // And shootable
				actual.health > 0 // And has health
			)
			{
				Results.HitActor = actual;
				return TRACE_Stop;
			}
			
			return TRACE_Skip;
		}
		else if (Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling)
		{
			Results.HitActor = null;

			return TRACE_Stop;
		}
		else if (Results.HitType == TRACE_HitWall)
		{
			if (Results.HitLine.flags & Line.ML_BLOCKING || Results.HitLine.flags & Line.ML_BLOCKEVERYTHING) { return TRACE_Stop; }
			if (Results.HitTexture)
			{
				if (Results.Tier != TIER_Middle) // 3D Midtex check still isn't perfect...
				{
					return TRACE_Stop;
				}
				return TRACE_Skip;
			}
			return TRACE_Skip;
		}

		return TRACE_Stop;
	}
}