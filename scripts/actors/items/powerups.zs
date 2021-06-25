/*
 * Copyright (c) 2018-2020 AFADoomer
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
**/

class CustomInvBase : CustomInventory
{
	String FailMessage;

	Property FailMessage:FailMessage;

	Default
	{
		//$Category Powerups (BoA)
		//$Color 6
		Scale 0.50;
		CustomInvBase.FailMessage "";
	}

	override bool Use(bool pickup)
	{
		if (level.levelnum == 99)
		{
			if (FailMessage) { Console.MidPrint (null, FailMessage, true); }
			return false;
		}

		return Super.Use(pickup);
	}
}

class PowerupToggler : PowerupGiver
{
	Powerup powerinv;

	override void DoEffect()
	{
		if (globalfreeze || level.Frozen) { return; }
		if (powerinv)
		{
			EffectTics = powerinv.EffectTics;
		}
		if (EffectTics == 1)
		{
			if (amount > 1)
			{
				amount -= 1;
				EffectTics = Default.EffectTics + 1;
			}
			else
			{
				Destroy();
			}
			if (powerinv)
			{
				powerinv.Destroy();
			}
		}
	}

	override void PostBeginPlay()
	{
		// In case powerup duration was not set in the defaults
		if (EffectTics == 0)
		{
			EffectTics = Powerup(GetDefaultByType(PowerupType)).EffectTics;
		}
		// Add 1 tic to the powerup time so that this "toggler" has control
		// over the powerup, and the powerup doesn't get removed without the
		// toggler knowing
		EffectTics += 1;
	}

	override bool Use(bool pickup)
	{
		PlayPickupSound(owner);

		if (powerinv)
		{
			powerinv.Destroy();
		}
		else
		{
			Super.Use(pickup);
			// Required to work around a type issue
			class<Inventory> PowerType = PowerupType.GetClassName();
			if (PowerType)
			{
				powerinv = Powerup(Owner.FindInventory(PowerType));
			}
		}
		return false; // Don't remove the toggler from owner's inventory.
	}

	override bool TryPickup(in out Actor toucher)
	{
		// Picking up another of the same item
		PowerupGiver toggler = PowerupGiver(toucher.FindInventory(GetClass()));
		if (toggler)
		{
			if (toggler.MaxAmount > 1 && toggler.Amount < toggler.MaxAmount)
			{
				toggler.Amount += 1;
				GoAwayAndDie();
				return true;
			}
			// Type issue workaround
			Class<Inventory> PowerType = PowerupType.GetClassName();
			if (PowerType)
			{
				Powerup curPower = Powerup(toucher.FindInventory(PowerType, true));
				// Powerup is active, modify powerup EffectTics. The toggler
				// will query the EffectTics of the powerup every tic.
				if (curPower)
				{
					if (bAdditiveTime)
					{
						curPower.EffectTics += Default.EffectTics;
						GoAwayAndDie();
						return true;
					}
					else if (curPower.EffectTics < (Default.EffectTics + 1))
					{
						curPower.EffectTics = Default.EffectTics + 1;
						GoAwayAndDie();
						return true;
					}
				}
				else
				{
					// Powerup is not active, modify toggler EffectTics
					if (bAdditiveTime)
					{
						toggler.EffectTics += Default.EffectTics;
						GoAwayAndDie();
						return true;
					}
					else if (toggler.EffectTics < (Default.EffectTics + 1))
					{
						toggler.EffectTics = Default.EffectTics + 1;
						GoAwayAndDie();
						return true;
					}
				}
			}
		}
		return Super.TryPickup(toucher);
	}
}

class ZyklonMask : PowerupToggler
{
	Default
	{
		//$Category Powerups (BoA)
		//$Title Zyklon Mask (any poison protection)
		//$Color 6
		Scale 0.35;
		Tag "$TAGZMASK";
		Inventory.Icon "ZASKB0";
		Inventory.PickupMessage "$ZMASK";
		Inventory.PickupSound "misc/gadget_pickup";
		Inventory.MaxAmount 1;
		Powerup.Duration 0x7FFFFFFF; // Never expire; status bar will not draw duration percentage (PowerZyklonMask also has code to never decrement tics)
		Powerup.Type "PowerZyklonMask";
		+INVENTORY.INVBAR
		+INVENTORY.UNDROPPABLE
	}

	States
	{
		Spawn:
			ZASK A -1;
			Stop;
	}

	override bool Use(bool pickup)
	{
		if (!powerinv)
		{
			// Override other masks - Only one can be active at a time!
			let mask = owner.FindInventory("PowerMaskProtection", true);
			if (mask) { mask.Destroy(); }
		}

		return Super.Use(pickup);
	}

	override void DoEffect()
	{
		if (globalfreeze || level.Frozen) { return; }

		// Zyklon mask cannot be used underwater
		if (powerinv && owner.waterlevel >= 3)
		{
			A_StartSound("flamer/steam", CHAN_AUTO, 0, Random(15, 45));
			powerinv.Destroy();
		}
		Super.DoEffect();
	}
}

const CHAN_MASK = 194;

// PowerProtection that plays a looping sound while active
class PowerMaskProtection : PowerProtection
{
	sound maskSound;
	int maskChannel;

	Property Sound: maskSound;
	Property Channel: maskChannel;

	Default
	{
		PowerMaskProtection.Sound "player/gasmask";
		PowerMaskProtection.Channel CHAN_MASK;
	}

	// Any mask with duration of 0x7FFFFFFF should never expire
	override void Tick()
	{
		if (owner && EffectTics == 0x7FFFFFFF) { return; }

		Super.Tick();
	}

	override void InitEffect()
	{
		if (Owner)
		{
			Owner.A_StartSound(maskSound, maskChannel, CHANF_LOOPING);
		}
		Super.InitEffect();
	}

	override void EndEffect()
	{
		if (Owner)
		{
			Owner.A_StopSound(maskChannel);
		}
		Super.EndEffect();
	}
}

class PowerZyklonMask : PowerMaskProtection
{
	Default
	{
		DamageFactor "MutantPoisonAmbience", 0;
		DamageFactor "UndeadPoisonAmbience", 0;
	}

	override void DoEffect()
	{
		Super.DoEffect();

		if (owner)
		{
			Overlay.Init(owner.player, "STGZASK", 2, 0, 0, 1.0, 0, Overlay.Force320x200 | Overlay.LightEffects);
		}
	}
}

class PowerSpaceSuit : PowerMaskProtection
{
	Default
	{
		DamageFactor "IceWater", 0;
	}

	override void DoEffect()
	{
		Super.DoEffect();

		if (owner)
		{
			Overlay.Init(owner.player, "STGMASK", 2, 0, 0, 1.0, 0, Overlay.Force320x200 | Overlay.LightEffects, -(sin(level.time * 10) * owner.vel.xy.length()) / 10);
		}
	}
}

class PoweredInventory : Inventory
{
	bool active;
	Class<Inventory> fuelclass;
	int fuelgiveamt;

	Property Fuel:fuelclass;
	Property FuelGiveAmt:fuelgiveamt;

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		if (owner && active)
		{
			if (owner.FindInventory(fuelclass)) { owner.TakeInventory(fuelclass, 1); }
			else { active = false; }
		}
	}

	override bool Use (bool pickup)
	{
		if (!owner) { return false; }

		active = !active;

		if (active && !owner.FindInventory(fuelclass)) { active = false; }

		return false;
	}

	// This only gets called after you've picked up the item once...  
	// On first pickup, the Inventory class HandlePickup returns true and this is never called.
	override bool HandlePickup(Inventory item)
	{
		if (item.GetClass() == GetClass())
		{
			// If the player already has the item, but isn't at max fuel, add fuel here (and pick up the item)
			let fuel = owner.FindInventory(fuelclass);
			if (!fuel) { fuel = owner.GiveInventoryType(fuelclass); fuel.Amount = 0; }

			if (fuel && fuel.Amount < fuel.MaxAmount)
			{
				fuel.Amount += fuelgiveamt;

				if (fuel.Amount > fuel.MaxAmount && !sv_unlimited_pickup)
				{
					fuel.Amount = fuel.MaxAmount;
				}

				item.bPickupGood = true;
			}

			return true;
		}
		return false;
	}

	override bool TryPickup(in out Actor toucher)
	{
		// If this is the first pickup of the item, also add fuel to the player's inventory
		if (!toucher.FindInventory(GetClass())) { toucher.A_GiveInventory(fuelclass, fuelgiveamt); }

		return Super.TryPickup(toucher);
	}
}

class LanternPickup : PoweredInventory
{
	int ticcount;

	Default
	{
		//$Category Powerups (BoA)
		//$Title Useable Lantern (requires Oil)
		//$Color 6
		Scale 0.5;
		Tag "$TAGLANTR";
		Inventory.Icon "LANTB0";
		Inventory.PickupMessage "$LANTERN";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/gadget_pickup";
		+INVENTORY.INVBAR
		+INVENTORY.UNDROPPABLE
		PoweredInventory.Fuel "LanternOil";
		PoweredInventory.FuelGiveAmt 1000;
	}

	States
	{
		Spawn:
			LANT A -1;
			Stop;
	}

	override void Tick()
	{
		if (owner)
		{
			if (active)
			{
				if (owner.waterlevel >= 3) // Extinguish if the player goes underwater
				{
					A_StartSound("flamer/steam", CHAN_AUTO, 0, Random(15, 45));
					active = false;
				}
				else
				{
					if (ticcount > 4) { owner.A_AttachLightDef("LanternFlicker", "LANT01"); }
					else if (ticcount > 0) { owner.A_AttachLightDef("LanternFlicker", "LANT02"); }
					else { owner.A_AttachLightDef("LanternFlicker", "LANT03"); }

					if (ticcount) { ticcount = max(0, ticcount - 1); }
				}
			}
			else
			{
				owner.A_RemoveLight("LanternFlicker");
			}
		}

		if (globalfreeze || level.Frozen) { return; }

		Super.Tick();
	}

	override bool Use(bool pickup)
	{
		bool ret = Super.Use(pickup);

		if (active) { ticcount = 8; }

		return ret;
	}
}

class MineSweeper : PoweredInventory
{
	Default
	{
		//$Category Powerups (BoA)
		//$Title Human Mine Scanning (pickups)
		//$Color 6
		Scale 0.5;
		Tag "$TAGSWEEP";
		Inventory.Icon "MSPUB0";
		Inventory.PickupMessage "$SWEEPER";
		Inventory.MaxAmount 1;
		+INVENTORY.INVBAR
		+INVENTORY.UNDROPPABLE
		PoweredInventory.Fuel "Power";
		PoweredInventory.FuelGiveAmt 2400;
	}

	States
	{
		Spawn:
			MSPU A -1;
			Stop;
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		Super.Tick();

		// Remove Minesweeper from inventory when depleted
		if (owner && !owner.FindInventory(fuelclass)) { Destroy(); }
	}
}

class BoACompass : CustomInventory
{
	bool active;

	Default
	{
		//$Category Pickups (BoA)
		//$Title Compass
		//$Color 13
		Scale 0.2;
		Tag "$TAGCOMPS";
		Inventory.Icon "CMPSB0";
		Inventory.PickupMessage "$COMPASS";
		Inventory.PickupSound "misc/armor_head";
		Inventory.MaxAmount 1;
		+INVENTORY.INVBAR
		+INVENTORY.UNCLEARABLE // So that it doesn't get removed on C2M2 - Talon1024
	}

	States
	{
		Spawn:
			CMPS A -1;
			Stop;
		Use:
			TNT1 A 0 {
				invoker.active = !invoker.active;
			}
			Fail;
	}

	override Inventory CreateTossable(int amt)
	{
		active = false;
		return Super.CreateTossable(amt);
	}

	static void Add(Actor thing, String iconName = "", bool usesprite = false, int actorTID = 0)
	{
		if (!thing || actorTID)
		{
			if (actorTID)
			{
				let it = ActorIterator.Create(actorTID, "Actor");
				Actor mo;

				while (mo = Actor(it.Next()))
				{
					Add(mo, iconName, usesprite); // Add each thing that has a matching TID
				}
			}

			return; // If no thing was passed, silently fail here
		} 

		CompassHandler compassEvent = CompassHandler(EventHandler.Find("CompassHandler"));
		if (!compassEvent) { return; } // If no CompassHandler was found (somehow), silently fail

		if (iconName == "") { iconName = CompassHandler.GetDefaultIcon(thing, usesprite); }

		compassEvent.Add(thing, iconName);
	}

	static void Remove(Actor thing)
	{
		if (!thing) { return; } // If no thing was passed, silently fail

		CompassHandler compassEvent = CompassHandler(EventHandler.Find("CompassHandler"));
		if (!compassEvent) { return; }

		int i = compassEvent.FindCompassItem(thing);

		if (i < compassEvent.CompassItems.Size())
		{
			compassEvent.CompassItems[i].Destroy();
			compassEvent.CompassItems.Delete(i, 1);
			compassEvent.CompassItems.ShrinkToFit();
		}
	}

	static void Flash()
	{
		CompassHandler compassEvent = CompassHandler(EventHandler.Find("CompassHandler"));
		if (!compassEvent) { return; }

		compassEvent.drawflash = level.time;
	}

	static void ForceActivate(Actor owner, bool activate)
	{
		if (owner && owner.player)
		{
			Inventory cmpsitem = owner.FindInventory("BoACompass");
			if (cmpsitem)
			{
				BoACompass compass = BoACompass(cmpsitem);
				compass.active = activate;
			}
		}
	}
}

// Disguise token to change player sprites and properties
//  Formerly handled in CheckSpriteToken function in BoAPlayer class
//  Properties are named similarly to their corresponding PlayerPawn property
//  If you don't specify a crouch sprite, the standing sprite is used and default squishing applies
//  DropItem list is used as the list of weapons that are allowed to be carried without breaking the disguise
//
// See RyanToken below for simple example.
class DisguiseToken : CustomInventory
{
	int viewheight;
	double playerscale;
	double viewbob;
	double forwardmove1, forwardmove2;
	double sidemove1, sidemove2;
	String HUDsprite;
	SpriteID basesprite, crouchsprite;
	int notargettimeout;
	Name playersoundclass;
	int flags;

	Property ViewHeight:viewheight;
	Property PlayerScale:playerscale;
	Property ViewBob:viewbob;
	Property ForwardMove:forwardmove1, forwardmove2;
	Property SideMove:sidemove1, sidemove2;
	Property HUDSprite:HUDsprite;
	Property PlayerSoundClass:playersoundclass;

	FlagDef NOTARGET:flags, 0;
	FlagDef ALLOWSPRINT:flags, 1;

	Default
	{
		DisguiseToken.PlayerScale 0.65; // Overrides scale of original player class
		DisguiseToken.ViewHeight -1; // -1 means 'use player class default' for everything below...
		DisguiseToken.ViewBob -1;
		DisguiseToken.ForwardMove -1, -1;
		DisguiseToken.SideMove -1, -1;
		DisguiseToken.HUDSprite "STF"; // Default to using the default mugshot
		DropItem "NullWeapon"; // Misappropriate DropItem to list weapons that can be equipped without breaking disguise
		DropItem "FakeID", 1; // Drop probability is used as a flag field; set to 1 to allow this weapon to be fired in disguise and to not alert enemies
		+Inventory.NeverRespawn
		+DisguiseToken.NoTarget; // If set, disguise hides player from Nazis.  If False, player just uses alternate skin but is fired at normally.
		+DisguiseToken.AllowSprint; // If set, allows the player to sprint while disguised
	}

	States
	{
		Use:
			TNT1 A -1;
			Stop;
		// Define WalkSprite (and CrouchSprite, if used) in token actor's states
		WalkSprite:
			PLAY A 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		State WalkState = FindState("WalkSprite");
		State CrouchState = FindState("CrouchSprite");

		basesprite = WalkState.sprite;

		if (CrouchState) { crouchsprite = CrouchState.sprite; }
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if (!Amount) { return; }
		let p = PlayerPawn(owner);
		if (!p || !p.player) { return; }
		// Apply token-specific settings and sprites to the player
		if (playerscale > 0) { p.scale = (1.0, 1.0) * playerscale; }

		if (crouchsprite && p.player.crouchfactor < 0.75)
		{
			p.sprite = crouchsprite;
			p.scale.y *= 1.0 / p.player.crouchfactor; // Negate crouch sprite scaling
		}
		else
		{
			p.sprite = basesprite;
		}

		if (viewheight > -1)
		{
			p.viewheight = viewheight;
			p.attackzoffset = p.Default.attackzoffset * viewheight / p.Default.viewheight;
		}

		if (p.scale.x != playerscale) { p.A_SetSize(p.Default.radius * p.scale.x / p.Default.scale.x, p.Default.height * p.scale.y / p.Default.scale.y); }

		if (viewbob > -1) { p.viewbob = viewbob; }
		if (forwardmove1 > -1 && forwardmove2 > -1) { p.forwardmove1 = forwardmove1; p.forwardmove2 = forwardmove2; }
		if (sidemove1 > -1 && sidemove2 > -1) { p.sidemove1 = sidemove1; p.sidemove2 = sidemove2; }

		if (bNoTarget) { SetNoTarget(); }
		
		if (playersoundclass) { p.SoundClass = playersoundclass; }
	}

	override bool TryPickup (in out Actor toucher)
	{
		if (toucher && !bAllowSprint)
		{
			toucher.TakeInventory("BoASprinting", 1);
		}

		return Super.TryPickup(toucher);
	}

	override void DepleteOrDestroy()
	{
		// Restore player defaults
		let p = PlayerPawn(owner);
		if (!p || !p.player) { return; }
		p.sprite = p.SpawnState.sprite;
		p.viewheight = p.Default.viewheight;
		p.attackzoffset = p.Default.attackzoffset;
		if (p.scale != p.Default.scale)
		{
			p.scale = p.Default.scale;
			p.A_SetSize(p.Default.radius, p.Default.height);
		}
		p.viewbob = p.Default.viewbob;
		p.forwardmove1 = p.Default.forwardmove1;
		p.forwardmove2 = p.Default.forwardmove2;
		p.sidemove1 = p.Default.sidemove1;
		p.sidemove2 = p.Default.sidemove2;
		p.soundclass = p.Default.soundclass;

		if (bNoTarget)
		{
			p.player.cheats &= ~CF_NOTARGET;
			p.speed = owner.Default.speed;
		}

		// Reset the default inventory items (effects, shaders, etc.)
		InventoryClearHandler.GiveDefaultInventory(p);

		Super.DepleteOrDestroy();
	}

	void SetNoTarget()
	{
		let weap = owner.player.ReadyWeapon;

		if (weap && !owner.FindInventory("DisguiseFailToken", true))
		{
			DropItem allowedweapons = GetDropItems();

			if (allowedweapons)
			{
				for (DropItem weaponitem = allowedweapons; weaponitem != null; weaponitem = weaponitem.Next)
				{
					Class<Weapon> testweapon = weaponitem.Name;

					if (testweapon && testweapon == weap.GetClass())
					{
						let psp = owner.player.GetPSprite(PSP_WEAPON);

						if ( // If in ready state, up state, or down state, turn notarget on unless enemies are already alerted
							!owner.player.FindPSprite(-10) && // Kicks make you lose your disguise
							(
								weaponitem.Probability != 255 ||
								psp.CurState == weap.GetReadyState() ||
								psp.CurState == weap.GetUpState() ||
								psp.CurState == weap.GetDownState()
							)
						) 
						{
							Inventory vis = owner.FindInventory("BoAVisibility");

							if (!vis || !BoAVisibility(vis).alertedcount) // If no enemies are already alerted, turn on notarget
							{
								notargettimeout = level.time + 2;
							}
						}
						else
						{
							notargettimeout = level.time;
						}

						break;
					}
				}
			}
		}

		if (notargettimeout)
		{
			if (notargettimeout <= level.time) // Turn off notarget and reset speed
			{
				owner.player.cheats &= ~CF_NOTARGET;
				owner.speed = owner.Default.speed;

				notargettimeout = 0;
			}
			else // Turn on notarget and slow down your movement
			{
				owner.player.cheats |= CF_NOTARGET;
				owner.speed = owner.Default.speed * 0.85;
			}
		}
	}
}

// "Holds" an inventory temporarily
class InventoryHolder play
{
	// Indicates whether an item should be held, not held, or held later.
	enum EHold {
		HOLD = 0,
		DO_NOT_HOLD,
		HOLD_DEFERRED
	}

	Array<Inventory> heldItems;
	Array<String> itemTypeNames; // For debugging only - Some items are apparently being lost in C3M0_B
	Actor owner;
	Inventory holder;
	
	int armor;
	double savepercent;
	TextureID armorIcon;
	double hexenarmorslots[5];
	int health;

	protected virtual EHold ShouldHoldItem(Inventory item)
	{
		// Don't "hold" the token which caused this to "hold" the player's
		// inventory.
		if (item == holder ||
			// Don't "hold" the player's stamina (used for sprinting and
			// kicking).
			item is "Stamina" ||
			// Don't "hold" footsteps, heartbeat, or sprinting - these items
			// destroy themselves if not in an actor's inventory.
			item is "BoASprinting" ||
			item is "BoAHeartBeat" ||
			item is "BoAFootsteps" ||
			// "Holding" an "IncomingMessage" or "CutsceneToken" may cause
			// the compass to break.
			item is "IncomingMessage" ||
			item is "CutsceneEnabled" ||
			// Don't "hold" items that are not expected to be removed.
			item is "ShaderControl" ||
			item is "ColorGradeShaderControl") {
			return DO_NOT_HOLD;
		}
		else if (item is "BackpackItem")
		{
			// Backpacks need special handling, since they reset the ammo
			// counts for all ammo types when taken away.
			return HOLD_DEFERRED;
		}

		return HOLD;
	}

	void HoldInventory(Inventory head)
	{
		Inventory ii = head;
		// Make sure all items, except those which should not be, are restored.
		Array<Inventory> deferredItemsToHold;
		while (ii != null)
		{
			EHold hold = ShouldHoldItem(ii);
			if (hold == HOLD_DEFERRED)
			{
				deferredItemsToHold.Push(ii);
			}
			if (hold)
			{
				ii = ii.Inv;
				continue;
			}
			// ii will be detached from the owner, and thus removed from their
			// inventory (a linked list), so we need to advance "ii" to the 
			// next item, and store a pointer to the current item.
			Inventory curItem = ii;
			ii = ii.Inv;
			HoldItem(curItem);
		}
		for (int i = 0; i < deferredItemsToHold.Size(); i++)
		{
			HoldItem(deferredItemsToHold[i]);
		}

		// Save health amount
		if (owner) { health = owner.health; }
		else if (holder && holder.owner) { health = holder.owner.health; }

		if (boa_debugholdinventory) { Console.Printf("Health: %d, Armor: %d %.3f", health, armor, savepercent); }
	}

	protected void HoldItem(Inventory curItem)
	{
		itemTypeNames.Push(curItem.GetClassName());
		int prevMaxAmount = curItem.MaxAmount;
		int prevAmount = curItem.Amount;
		curItem.BecomePickup();
		curItem.MaxAmount = prevMaxAmount;
		curItem.Amount = prevAmount;
		curItem.A_ChangeLinkFlags(1, 1); // Prevent players from picking it up.
		curItem.SetStateLabel("Held");
		heldItems.Push(curItem);

		// Save armor values
		if (curItem.GetClass() == "BasicArmor")
		{
			armor = curItem.Amount;
			armorIcon = curItem.Icon;
			savepercent = BasicArmor(curItem).SavePercent;
		}
		else if (curItem.GetClass() == "HexenArmor")
		{
			let h = HexenArmor(curItem);
			armorIcon = curItem.Icon;
			for (int s = 0; s < 5; s++) { hexenarmorslots[s] = h.slots[s]; }
		}

		if (boa_debugholdinventory) {
			Console.Printf("%s (%d/%d) (%d/%d)", curItem.GetClassName(), curItem.Amount, curItem.MaxAmount, prevAmount, prevMaxAmount);
		}
	}

	void RestoreInventory(Actor receiver)
	{
		// Clear out receiver's previous inventory
		Inventory ii = receiver.Inv;
		while (ii != null)
		{
			EHold hold = ShouldHoldItem(ii);
			if (hold == DO_NOT_HOLD)
			{
				ii = ii.Inv;
				continue;
			}
			Inventory curItem = ii;
			ii = ii.Inv;
			curItem.DepleteOrDestroy();
		}
		// Iterate in reverse to put items in the same order they were before
		for (int i = heldItems.Size() - 1; i >= 0; i--)
		{
			Inventory ii = heldItems[i];
			if (boa_debugholdinventory) { Console.Printf("Attempting to restore %s...", itemTypeNames[i]); }
			if (ii)
			{
				RestoreItem(ii, receiver);
			}
			else if (boa_debugholdinventory) { Console.Printf("Unable to restore %s because it is null!", itemTypeNames[i]); }
		}

		// Restore health amount
		receiver.health = health;
		if (receiver.player) { receiver.player.health = health; }
	}

	protected void RestoreItem(Inventory item, Actor receiver)
	{
		if (boa_debugholdinventory) { Console.Printf("%s (%d/%d)", item.GetClassName(), item.Amount, item.MaxAmount); }
		// Fix ammo amounts if player had a backpack
		Inventory existing = receiver.FindInventory(item.GetClass());
		if (existing)
		{
			if (existing is "BasicArmor")
			{
				let a = BasicArmor(existing);
				a.amount = armor;
				a.SavePercent = savepercent;
				a.Icon = armorIcon;
			}
			else if (existing is "HexenArmor")
			{
				let h = HexenArmor(existing);
				for (int s = 0; s < 5; s++) { h.slots[s] = hexenarmorslots[s]; }
				h.Icon = armorIcon;
			}
			else
			{
				existing.MaxAmount = item.MaxAmount;
				existing.Amount = item.Amount;
			}
		}
		else
		{
			// Inventory.AttachToOwner changes bNoBlockmap and bNoSector, so
			// there is no need to change those flags here.
			item.AttachToOwner(receiver);
		}
	}
}

class RyanToken : DisguiseToken
{
	InventoryHolder BJInv;
	int BJStamina; // Attempt to fix health
	int BJHealth;
	class<Inventory> PreInvSel;
	class<Weapon> PreWeapon;

	Default
	{
		DisguiseToken.ViewBob 0.22; // Less bob then BJ
		DisguiseToken.ForwardMove 0.9, 0.45; // Just a little slower than BJ
		DisguiseToken.SideMove 0.9, 0.45;
		DisguiseToken.HUDSprite "RTF"; // Ryan Mugshot
		DisguiseToken.PlayerSoundClass "ryan"; // soundclass
		-DisguiseToken.NOTARGET; // Don't hide player from enemies
	}

	States
	{
		WalkSprite:
			PLRR A 0;
		CrouchSprite:
			PLYR A 0;
	}

	override bool TryPickup (in out Actor toucher)
	{
		if (toucher)
		{
			AttachToOwner(toucher); // So that health restoration works properly
			let p = PlayerPawn(toucher);
			if (p.InvSel)
			{
				PreInvSel = p.InvSel.GetClass();
			}
			if (p.player && p.player.ReadyWeapon)
			{
				PreWeapon = p.player.ReadyWeapon.GetClass();
			}
			BJInv = new("InventoryHolder");
			BJInv.holder = self;
			BJInv.HoldInventory(toucher.Inv);

			// Console.Printf("Health: %d %d", p.Health, p.player.Health);
			if (p && p.player)
			{
				// Reset the default inventory items (effects, shaders, etc.)
				InventoryClearHandler.GiveDefaultInventory(toucher);

				toucher.A_GiveInventory("KnifeSilent", 1);
				
				p.InvSel = p.InvFirst = p.FirstInv();
				// Needed so that players can switch weapons when they turn
				// into James Ryan.
				p.player.ReadyWeapon = null;
				p.player.PendingWeapon = Weapon(p.FindInventory("NullWeapon"));

				BJStamina = p.Stamina;
				p.Stamina = p.Default.Stamina;
				BJHealth = p.Health;
				// Player's health is stored in two different places: the
				// PlayerPawn actor, and the PlayerInfo which is attached to it.
				p.Health = p.Default.Health;
				p.player.Health = p.Default.Health;
				// Add start items
				DropItem si = GetDefaultByType(p.GetClass()).GetDropItems();
				while (si != null)
				{
					class<Inventory> siClass = si.Name;
					if (!(siClass is "Weapon"))
					{
						p.GiveInventory(siClass, si.Amount);
					}
					si = si.Next;
				}
			}
			return true;
		}
		return false;
	}

	override void DepleteOrDestroy()
	{
		if (owner)
		{
			BJInv.RestoreInventory(owner);
			BJInv.Destroy();

			let p = PlayerPawn(owner);

			if (p)
			{
				p.InvSel = p.FindInventory(PreInvSel);
				if (!p.InvSel)
				{
					p.InvSel = p.FirstInv();
				}
				// Just in case...
				p.player.ReadyWeapon = null;
				p.player.PendingWeapon = Weapon(p.FindInventory(PreWeapon));

				p.Stamina = BJStamina;
				p.Health = BJHealth;
				p.player.Health = BJHealth;
			}
		}

		Super.DepleteOrDestroy();
	}
}

// Hold player inventory until training course is complete
class HQTrainingCourse : Inventory
{
	InventoryHolder holder;
	class<Inventory> PreInvSel;
	class<Weapon> PreWeapon;

	Default
	{
		Inventory.MaxAmount 1;
		+Inventory.NeverRespawn
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (toucher)
		{
			AttachToOwner(toucher); // So that health restoration works properly
			let p = PlayerPawn(toucher);
			if (p.player && p.player.ReadyWeapon)
			{
				PreWeapon = p.player.ReadyWeapon.GetClassName();
			}
			if (p.InvSel)
			{
				PreInvSel = p.InvSel.GetClassName();
			}
			holder = new("InventoryHolder");
			holder.holder = self;
			holder.HoldInventory(toucher.Inv);

			if (p && p.player)
			{
				// Reset the default inventory items (effects, shaders, etc.)
				InventoryClearHandler.GiveDefaultInventory(p);

				p.InvSel = p.InvFirst = p.FirstInv();
				// Needed so that players can switch weapons.
				p.player.ReadyWeapon = null;
				p.player.PendingWeapon = Weapon(p.FindInventory("NullWeapon"));
				// Add start items
				DropItem si = GetDefaultByType(p.GetClass()).GetDropItems();
				while (si != null)
				{
					class<Inventory> siClass = si.Name;
					if (!(siClass is "Weapon"))
					{
						p.GiveInventory(siClass, si.Amount);
					}
					si = si.Next;
				}
			}
			return true;
		}
		return false;
	}

	override void DepleteOrDestroy()
	{
		if (owner)
		{
			holder.RestoreInventory(owner);
			holder.Destroy();

			let p = PlayerPawn(owner);

			if (p)
			{
				p.InvSel = p.FindInventory(PreInvSel);
				if (!p.InvSel)
				{
					p.InvSel = p.FirstInv();
				}
				// Just in case...
				p.player.ReadyWeapon = null;
				p.player.PendingWeapon = Weapon(p.FindInventory(PreWeapon));
			}
		}

		Super.DepleteOrDestroy();
	}
}

class PowerRepairing : Powerup
{
	bool initialized;
	int resumetics;
	Inventory giver; 

	Default
	{
		Powerup.Duration 500; // Duration of effect in tics
		Powerup.Strength 3; // Per tic HP increase
	}
	
	override void DoEffect()
	{
		Super.DoEffect();

		if (!Owner || owner.health >= GetDefaultByType(owner.GetClass()).Health)
		{
			if (giver)
			{
				giver.alpha = 1.0; // Set the icon back to solid if it was flashing
				if (RepairKit(giver)) { RepairKit(giver).repairtime = resumetics; }

				Destroy();
			}

			return;
		}
		else if (Owner is "TankPlayer")
		{
			// Heal the tank, up to maximum default health for the tank player class
			Owner.GiveBody(int(Strength), GetDefaultByType("TankPlayer").Health);

			if (giver) // If a giving inventory item was set, manipulate its icon and handle inventory removal
			{
				giver.alpha = 0.67 + sin(level.time * 15) / 3; // Flash the icon while actively repairing

				if (RepairKit(giver))
				{
					if (!initialized)
					{
						EffectTics = RepairKit(giver).repairtime;
						initialized = true;
					}
					else { RepairKit(giver).repairtime = EffectTics; }
				}

				if (EffectTics == 1) // Handle removing (or decrementing the amount of) the inventory item 
				{
					if (--giver.Amount == 0) { giver.GoAwayAndDie(); } // If none remaining in inventory, remove the inventory item and this powerup
					else
					{
						giver.alpha = 1.0; // Restore to full alpha if there are more repair kits in inventory
						if (RepairKit(giver)) { RepairKit(giver).repairtime = RepairKit(giver).Default.repairtime; } // Restore repair time amount for next repair kit use
					}
				}
			}

			resumetics = EffectTics; // Save last effect tick count so we have a point to start from if the player exits the tank next tick
		}
		else if (owner is "BoAPlayer")
		{
			// Don't heal a non-tank player, but also don't decrement the effect time
			// This way, tank repair can be re-started when you get back into a tank
			EffectTics = resumetics;

			if (giver)
			{
				giver.alpha = 1.0; // Set the icon back to solid if it was flashing
				if (RepairKit(giver)) { RepairKit(giver).repairtime = resumetics; }

				Destroy();
			}
		}
		else
		{
			Destroy();
		}
	}
}

class RepairKit : CompassItem
{
	int repairtime;

	Property RepairTime:repairtime;

	Default
	{
		//$Title Repair Kit (electric)
		-INVENTORY.ALWAYSPICKUP
		Tag "$TAGREKIT";
		Inventory.Icon "EKPKA0";
		Inventory.PickupMessage "$ELECPAK";
		Inventory.PickupSound "misc/gadget_pickup";
		Inventory.MaxAmount 3;
		RepairKit.RepairTime 500;
	}

	States
	{
		Spawn:
			EKPK B -1;
			Stop;
	}

	override bool Use(bool pickup)
	{
		// Only activate for tank players that aren't at full health and who aren't already using a repair kit
		if (Owner is "TankPlayer" && owner.health < GetDefaultByType("TankPlayer").Health && !Owner.FindInventory("PowerRepairing"))
		{
			Inventory repairing = Owner.GiveInventoryType("PowerRepairing"); // Give the actual powerup

			// Tell the powerup what inventory item gave it, just in case someone decides to create a new type of repair kit
			if (PowerRepairing(repairing))
			{
				PowerRepairing(repairing).giver = self;
				PowerRepairing(repairing).EffectTics = repairtime;
			}

			// Don't 'return true' here; removal of the inventory item is handled in the PowerRepairing powerup as long as the 'giver' is set above.
		}

		return false;
	}

	// Called from status bar code when selected by a tank player
	ui void DrawStatus(int x, int y, int size, double alpha = 1.0)
	{
		int drawx;
		int drawy = y;
		int width = int(size / 16);
		int height, fullheight;

		for (int i = Amount; i > 0; i--)
		{
			drawx = x - i * (width + 2);
			fullheight = height = int(size * 0.75);

			if (i == Amount) { height = int(height * repairtime * 1.0 / Default.repairtime); }

			DrawToHUD.Dim("DDDD00", alpha * 0.25, drawx, drawy - fullheight, width, fullheight - height);
			DrawToHUD.Dim("DDDD00", alpha * 0.65, drawx, drawy - height, width, height);
		}
	}
}

class Bandages : PowerupGiver
{
	Default
	{
		//$Category Health (BoA)
		//$Title Bandages (+10)
		//$Color 6
		Scale 0.5;
		Tag "$TAGBAIDS";
		Inventory.Icon "BAIDB0";
		Inventory.MaxAmount 5;
		Inventory.PickupMessage "$BAID";
		Inventory.UseSound "pickup/bandage";
		Inventory.PickupSound "misc/health_pkup";
		Powerup.Type "RegenPowerup";
	}

	States
	{
		Spawn:
			BAID A -1;
			Stop;
	}

	// Don't let the player use bandages when they are at full health!
	override bool Use(bool pickup)
	{
		if (owner.FindInventory("HQ_Checker", true)) { return false; }
		if (owner && (owner.health >= owner.GetMaxHealth(true) || owner.FindInventory("RegenPowerup"))) { return false; }

		return Super.Use(pickup);
	}
}

class RegenPowerup : PowerUp
{
	Sound regensound;
	int regeninterval;

	Property RegenSound : regensound;
	Property RegenInterval : regeninterval;

	Default
	{
		Inventory.Icon "ICO_HEAL";

		Powerup.Duration -10;
		Powerup.Strength 1;

		RegenPowerup.RegenSound "*regenerate";
		RegenPowerup.RegenInterval TICRATE;
	}

	// Derived from base PowerRegeneration class, but using actual ticrate-based seconds instead of running every 32 tics
	override void DoEffect()
	{
		Super.DoEffect();

		if (owner && owner.health > 0 && (Level.maptime % regeninterval) == 0)
		{
			if (Owner.GiveBody(int(Strength)))
			{
				Owner.A_StartSound(regensound, CHAN_ITEM);
			}
		}
	}
}

class ZyklonResistance : PowerupGiver
{
	Default
	{
		+INVENTORY.INVBAR
		Radius 8;
		Height 16;
		Scale 0.3;
		Inventory.Icon "BEAKD0";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/k_pkup";
		Inventory.PickupMessage "$ZRESIST";
		Powerup.Duration 0x7FFFFFFF;
		Powerup.Type "PowerZyklonResistance";
		Tag "$TAGVIAL";
	}

	States
	{
		Spawn:
			BEAK D -1 BRIGHT;
			Stop;
	}
}

class PowerZyklonResistance : PowerProtection
{
	Default
	{
		Inventory.Icon "ICO_ZYKR";
		DamageFactor "UndeadPoison", 0.25;
		DamageFactor "UndeadPoisonAmbience", 0.25;
	}

	override void Tick()
	{
		if (owner && EffectTics == 0x7FFFFFFF) { return; }

		Super.Tick();
	}
}

class SavingHealth : CustomInvBase
{
	String savemessage;

	Property SaveMessage : savemessage;
}

class NaziBerserk : SavingHealth
{
	Default
	{
		//$Title Totale Macht (Berserk)
		//$Sprite PSTRA0
		+INVENTORY.INVBAR
		Inventory.Icon "I_BSRK";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/p_pkup";
		Inventory.PickupMessage "$SSBERSK";
		Tag "$TAGMACHT";
		SavingHealth.SaveMessage "$TMSAVE";
	}

	States
	{
		Spawn:
			PSTR A -1;
			Loop;
		Pickup:
			Stop;
		Use:
			TNT1 A 0
			{
				A_GiveInventory("BerserkRegen", 1);
				A_GiveInventory("BerserkReflect", 1);
				A_GiveInventory("BerserkToken", 1);
			}
			Stop;
	}
}

class BerserkToken : PowerUp // Token is checked for in ACS-based sprint handling - no stamina use for the duration of this powerup!
{
	Default
	{
		Inventory.Icon "ICO_SPRN";
		Powerup.Duration -30;
	}
}


class BerserkRegen : RegenPowerUp
{
	double blendstep;
	bool initial;

	Default
	{
		Inventory.Icon "ICO_HEAZ";

		Powerup.Duration -60;
		Powerup.Color "00 7D 5C", 0.5; // Zyklon green
		RegenPowerUp.RegenSound "";
		RegenPowerUp.RegenInterval 1; // Start healing quickly...
	}

	override void InitEffect()
	{
		Super.InitEffect();

		owner.A_StartSound("activate/macht", CHAN_AUTO, CHANF_LOCAL, 15.0, 0.5);
		owner.A_StartSound("EXPDSND5", CHAN_AUTO, CHANF_LOCAL, 15.0, 0.25);
		initial = true;
	}

	override void DoEffect()
	{
		Super.DoEffect();

		if (owner && owner.health > 0 && (Level.maptime % TICRATE) == 0)
		{
			regeninterval++; // ...and decrease healing rate over time.
		}
	}

	override color GetBlend()
	{
		double amt;

		if (effecttics < 175) // Pulse when there are 5 seconds left
		{
			if (effecttics == 174 || effecttics % TICRATE == 0) { blendstep = 0; }

			amt = sin(blendstep) / 4;
			blendstep += 90.0 / TICRATE;
		}
		else if (initial || (Level.maptime % TICRATE) != 0)
		{
			if (initial) // Always flash over two seconds on initial activation
			{
				amt = sin(blendstep);
				blendstep += 45.0 / TICRATE;

				if (blendstep >= 180.0)
				{
					blendstep = 0;
					initial = false;
				}
			}
			else // Flash every second after that, with more transparency the healthier you are and the weaker the effect gets
			{
				amt = (1.0 - double(owner.health) / owner.GetMaxHealth(true)) * sin(blendstep) * double(effecttics) / Default.effecttics;
				blendstep += 90.0 / TICRATE;
			}
		}
		else
		{
			blendstep = 0;
		}

		if (amt) { return Color(int(BlendColor.a * amt), BlendColor.r, BlendColor.g, BlendColor.b); }

		return 0;
	}
}

class BerserkReflect : PowerUp
{
	Default
	{
		Inventory.Icon "ICO_REFL";
		Powerup.Duration -10;
	}

	override void DoEffect()
	{
		Super.DoEffect();

		if (owner)
		{
			owner.DamageFactor = 0.0; // Basically set the player invulnerable without setting the flag, so the mugshot won't change
			owner.bReflective = true;
		}
	}

	override void EndEffect ()
	{
		Super.EndEffect();

		if (owner)
		{
			owner.DamageFactor = owner.Default.DamageFactor;
			owner.bReflective = false;
		}
	}
}

class TotaleGier : CustomInvBase // Checked within Nazi class to drop coins on death for duration of this item
{
	Default
	{
		//$Title Totale Gier (Make enemies drop gold when killed)
		//$Sprite TTGRA0
		+INVENTORY.INVBAR
		Inventory.Icon "I_TTGR";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/p_pkup";
		Inventory.PickupMessage "$SSGIER";
		Tag "$TAGGIER";
	}

	States
	{
		Spawn:
			TTGR A -1;
			Loop;
		Pickup:
			Stop;
		Use:
			TNT1 A -1
			{
				A_GiveInventory("GierToken", 1);
			}
			Stop;
	}
}


class GierToken : PowerUp // Token is checked for in Nazi class to cause enemies that are killed by the owner to drop coins on death
{
	double blendstep;

	Default
	{
		Inventory.Icon "ICO_GREE";
		Powerup.Color "88 66 00", 0.65; // Gold flash
		Powerup.Duration -60;
	}

	override void InitEffect()
	{
		Super.InitEffect();

		owner.A_StartSound("activate/gier", CHAN_AUTO, CHANF_LOCAL, 1.0, 2.0);

		if (owner.player.mo == players[consoleplayer].camera)
		{
			StatusBar.SetMugshotState("Grin");
		}
	}

	override color GetBlend()
	{
		double amt;
		if (effecttics < 175) // Pulse when there are 5 seconds left
		{
			if (effecttics == 174 || effecttics % TICRATE == 0) { blendstep = 0; }

			amt = sin(blendstep) / 4;
			blendstep += 90.0 / TICRATE;
		}
		else if (blendstep < 180.0)  // Fast flash of gold on activation
		{
			amt = sin(blendstep);
			blendstep += 135.0 / TICRATE;
		}

		if (amt) { return Color(int(BlendColor.a * amt), BlendColor.r, BlendColor.g, BlendColor.b); }
		
		return 0;
	}
}

class NazisBackpack : BackpackItem
{
	Default
	{
		//$Category Items (BoA)
		//$Title Backpack (Backpack)
		//$Color 1
		Height 26;
		Scale 0.50;
		Inventory.PickupMessage "$SSPACK";
	}

	States
	{
		Spawn:
			BPK2 A -1;
			Stop;
	}

	override bool HandlePickup (Inventory item) //modified from gzdoom.pk3
	{
		// Since you already have a backpack, that means you already have every
		// kind of ammo in your inventory, so we don't need to look at the
		// entire PClass list to discover what kinds of ammo exist, and we don't
		// have to alter the MaxAmount either.
		if (item is 'BackpackItem')
		{
			if (item is 'ShopBackpack') //trying to buy a second backpack from the shop
			{
				item.bPickupGood = false;
				return true;
			}
			for (let probe = Owner.Inv; probe != NULL; probe = probe.Inv)
			{
				let ammoitem = Ammo(probe);

				if (ammoitem && ammoitem.GetParentAmmo() == ammoitem.GetClass())
				{
					if (ammoitem.Amount < ammoitem.MaxAmount || sv_unlimited_pickup)
					{
						int amount = ammoitem.Default.BackpackAmount;
						// extra ammo in baby mode and nightmare mode
						if (!bIgnoreSkill)
						{
							amount = int(amount * G_SkillPropertyFloat(SKILLP_AmmoFactor));
						}
						ammoitem.Amount += amount;
						if (ammoitem.Amount > ammoitem.MaxAmount && !sv_unlimited_pickup)
						{
							ammoitem.Amount = ammoitem.MaxAmount;
						}
					}
				}
			}
			// The pickup always succeeds, even if you didn't get anything
			item.bPickupGood = true;
			return true;
		}
		return false;
	}
}

class ShopBackpack: NazisBackpack {}

class SuperShield : BasicArmorPickup
{
	Default
	{
		//$Category Astrostein (BoA)/Health
		//$Title Super Shield (modern, +100)
		//$Color 6
		Armor.SavePercent 100.0;
		Armor.SaveAmount 100;
		Inventory.MaxAmount 200;
		Inventory.Icon "armh05";
		Inventory.PickupMessage "$SUPASHLD";
		+BRIGHT
	}

	States
	{
		Spawn:
			ARMX AB 3;
			Loop;
	}

	// Modified from https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/actors/inventory/armor.zs
	override bool Use (bool pickup)
	{
		int SaveAmount = GetSaveAmount();
		let armor = BasicArmor(Owner.FindInventory("BasicArmor"));

		// This should really never happen but let's be prepared for a broken inventory.
		if (armor == null)
		{
			armor = BasicArmor(Spawn("BasicArmor"));
			armor.BecomeItem ();
			Owner.AddInventory (armor);
		}
		else
		{
			// If you already have more armor than this item gives you, you can't use it.
			if (pickup && armor.ArmorType == GetClassName() && (MaxAmount && armor.Amount >= MaxAmount))
			{
				return false;
			}
		}

		// If you already had a Tesla armor, then add to it
		if (armor.ArmorType == GetClassName())
		{
			armor.Amount = min(armor.Amount + SaveAmount + armor.BonusCount, MaxAmount);
		}
		else // Otherwise, override whatever old armor was there - note that this
		{    // disregards BonusAmount when giving, and can *decrease* armor percentage to 100
			armor.SavePercent = clamp(SavePercent, 0, 100) / 100.0;
			armor.Amount = SaveAmount;
			armor.MaxAmount = max(armor.Amount, armor.MaxAmount);
			armor.Icon = Icon;
			armor.MaxAbsorb = max(armor.MaxAbsorb, MaxAbsorb);
			armor.MaxFullAbsorb = max(armor.MaxFullAbsorb, MaxFullAbsorb);
			armor.ArmorType = GetClassName();
			armor.ActualSaveAmount = max(armor.ActualSaveAmount, SaveAmount);
		}

		return true;
	}

	override bool CanPickup(Actor toucher)
	{
		// Force pickup unless you already have maxed it out
		if (toucher && toucher.player)
		{
			let armor = BasicArmor(toucher.FindInventory("BasicArmor"));

			if (armor && armor.ArmorType == GetClassName() && (MaxAmount && armor.Amount >= MaxAmount)) { return false; }

			return true;
		}

		return BasicArmorPickup.CanPickup(toucher);
	}
}