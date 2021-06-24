/*
 * Copyright (c) 2019-2020 AFADoomer
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

// Base enemy class
class CKBaseEnemy : Actor
{
	bool stunned, stunframes;
	int stuntime, stuncounter, wakeontouch;
	Actor confusion;
	State StunState, ReviveState, AttackState;

	// Some generic variables for CK_ internal functions.  I'd rather put these functions all in the actual classes, but DECORATE...
	int counter, counter2;
	Vector3 offset, oldpos;

	Sound touchsound;

	Property StunTime:stuntime;
	Property StunFrames:stunframes;
	Property WakeOnTouch:wakeontouch;
	Property TouchSound:touchsound;

	Default
	{
		Monster;
		Damage 15;
		Gravity 1.2;
		MaxDropoffHeight 64;
		MaxStepHeight 48;
		Scale 2.0;
		+CASTSPRITESHADOW
		+DONTTHRUST
		+FLOORCLIP
		+LOOKALLAROUND
		+NODAMAGE
		+NOBLOOD
		-COUNTKILL

		CKBaseEnemy.StunTime -1; // Default to staying stunned forever
		CKBaseEnemy.StunFrames 1; // Default to one possible frames for stun state (some actors have 2)
	}

	States
	{
		// Generic placeholder states, just in case something doesn't get defined properly
		Stunned:
			TNT1 A -1;
			Stop;
		Revive:
			TNT1 A 0 { SetState(SpawnState); }
	}

	override void PostBeginPlay()
	{
		StunState = FindState("Stunned");
		ReviveState = FindState("Revive");
		AttackState = FindState("Attack");
		if (!AttackState) { AttackState = FindState("Missile"); }
		if (!AttackState) { AttackState = FindState("Melee"); }

		SpawnPoint = pos;

		Super.PostBeginPlay();
	}

	// Don't take damage, only stun if stunnable (and the player is the one that shot you)
	// Be nice and let the 'kill monsters' cheat still work (won't stop stunned enemies from reviving, though)
	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (wakeontouch > 1)
		{
			wakeontouch = false;
			SetStateLabel("See");
		}

		if (bSolid && ((source && source.player || source is "PlayerFollower") || mod == "Massacre") && stuntime != 0 && !stunned) { DoStun(true); }
		else if (mod == "Massacre" && FindState("Death")) { SetStateLabel("Death"); }

		return 0;
	}

	// Handles other actor touching this actor
	// If wake on touch is set, set this actor to See state
	// Otherwise, damage any player that is touched
	// Unless damage is set 0, then fall back to executing the actor's special
 	override void Touch(Actor toucher)
	{
		if (toucher && toucher.player)
		{
			if (wakeontouch > 0)
			{
				wakeontouch = false;
				SetStateLabel("See");
			}

			if (damage > 0)
			{
				if (!stunned) { toucher.DamageMobj(self, self, damage, "Melee"); }
			}

			if (special)
			{
				A_StartSound(TouchSound, CHAN_UI);
				Level.ExecuteSpecial(special, toucher, null, false, args[0], args[1], args[2], args[3], args[4]);
				A_SetSpecial(0);
			}
		}
	}

	override void Tick()
	{
		if (pos != oldpos || vel.length() || !CheckRange(256) || (!bNoGravity && pos.z == ceilingz - height)) // Tick normally if player nearby or moving (or if hit the ceiling)
		{
			Super.Tick();
			oldpos = pos;
		}
		else // Otherwise just tick through actor states
		{
			if (tics == -1) { return; }
			else if (--tics <= 0)
			{
				SetState(CurState.NextState);
			}
		}

		// If an actor falls onto an instant-death floor, remove it
		F3DFloor curfloor;
		Sector floorsec;
		[floorz, floorsec, curfloor] = curSector.NextLowestFloorAt(pos.x, pos.y, pos.z);

		Sector cursec = curSector;
		if (curfloor) { cursec = curfloor.model; }
		
		if (pos.z == floorz && cursec.damagetype == "InstantDeath") { Die(self, self, 0, "Falling"); }

		if (stunned) { DoStun(); }
	}

	// Force calling of the Touch function for players without resorting to using
	// the SPECIAL flag, which changes other things with collision and interaction
	override bool CanCollideWith(Actor other, bool passive)
	{
		if (!stuncounter && health > 0 && other.player)
		{
			Touch(other);
			return true;
		}
		else if (!bShootable && !CKBounder(other))
		{
			return false;
		}

		return true;
	}

	// Generic function for handling stunning of enemies
	void DoStun(bool initial = false)
	{
		if (!InStateSequence(CurState, StunState)) { SetState(StunState); }

		if (initial)
		{
			if (stunframes > 1) { frame += Random(0, stunframes - 1); } // Pick a random frame within set range
			stuncounter = stuntime;
			A_SetSize(Default.Radius, 0);
			bNotAutoAimed = true;

			stunned = true;
		}
		else
		{
			// Spawn confusion ring once the actor has hit the floor
			if (!confusion && (pos.z == floorz || bOnMobj))
			{
				vel *= 0;
				confusion = Spawn("CKConfusion", pos);
			}

			if (stuncounter > 0)
			{
				stuncounter--;
			}
			else if (stuncounter == 0 && waterlevel < 2)
			{
				stunned = false;
				if (confusion) { confusion.Destroy(); }

				A_SetSize(Default.Radius, Default.Height);
				bNotAutoAimed = Default.bNotAutoAimed;

				SetState(ReviveState);
			}
		}
	}

	// Function to handle Mad Mushroom bouncing pattern
	void CK_MushroomBounce()
	{
		if (pos.z == floorz || bOnMobj)
		{
			counter = (counter + 1) % 3;

			if (counter == 0)
			{
				vel.z = 20.0;
			}
			else
			{
				vel.z = 10.0;
			}

			A_StartSound("ckeen/madmushroombounce");
		}
	}

	// Function to move an actor in a straight line until it hits something (or travels maxstep units), then change directions randomly, with preference for moving toward player.
	void CK_Glide(int maxstep = 1024)
	{
		PlayerSearch();

		if (BlockingMobj || BlockingLine || SpawnTime == level.time || (maxstep && counter >= maxstep / Speed))
		{
			if (target && IsVisible(target, true))
			{
				if (angle != AngleTo(target)) { angle = AngleTo(target); }
				else { angle += 180; }
			}
			else { angle = Random(0, 359); }

			counter = 0;
		}

		vel.xy = RotateVector((Speed, 0), angle);

		if (AttackState && Distance2D(target) <= Radius + MaxTargetRange)
		{
			SetState(AttackState);
		}

		counter++;
	}

	void CK_Float(int dist = 16, double speed = 1.5)
	{
		SetOrigin(pos + (0, 0, speed), true);

		if (abs(pos.z - SpawnPoint.z) > dist) { FloatSpeed *= -1; }
	}

	static Actor FindOnMObj(Actor origin = null)
	{
		if (!origin) { return null; }

		BlockThingsIterator it = BlockThingsIterator.Create(origin, 1);

		while (it.Next())
		{
			let mo = it.thing;

			if (mo == origin) { continue; } // Ignore itself

			if (mo.bSolid && origin.pos.z == mo.pos.z + mo.height)
			{
				return mo;
			}
		}

		return null;
	}

	// Looks for a player, then waits for the player to be within dist units to activate
	void CK_WaitForPlayer(int dist = 256)
	{
		PlayerSearch();

		if (target && Distance2D(target) < dist)
		{
			SetState(SeeState);
		}
	}

	void PlayerSearch()
	{
		if (target) { return; }

		LookExParams params;
		params.maxDist = 1024;
		params.maxHearDist = 1024;

		LookForPlayers(true, params);
	}
}

// Pickup items: Mixin used for points, health, gems, and weapon
mixin class CKPickup
{
	Actor touched;
	double vspeed;
	State PickupState;
	int ticker;
	bool ticked;

	Property VSpeed:vspeed;

	States(Actor)
	{
		HideDoomish:
			"####" "#" 0 { bInvisible = false; }
			"####" "#" 12 Bright;
			Goto Inventory::HideDoomish;
		HoldAndDestroy:
			"####" "#" 0 { bInvisible = false; }
			"####" "#" 12 Bright;
			Stop;
		Held:
			"####" "#" 0 { bInvisible = false; }
			"####" "#" 12 Bright;
			Goto Inventory::Held;
	}

	override void PostBeginPlay()
	{
		SpawnPoint = pos;
		PickupState = FindState("Pickup");

		bDropped = false;

		Super.PostBeginPlay();
	}

	override void Touch(Actor toucher)
	{
		if ((toucher.player || toucher is "CKSmirky") && !touched)
		{
			touched = toucher;
			ticker = 12;

			Super.Touch(toucher);
		}
	}

	override void Tick()
	{
		if (touched)
		{
			if (!InStateSequence(CurState, PickupState))
			{
				SetState(PickupState);

				vel.z = vspeed;
			}

			if (ticker > 0) { ticker--; }
			else
			{
				bInvisible = true;
				touched = null;

				if (Inventory.ShouldStay())
				{
					SetOrigin(SpawnPoint, false);
				}
				else
				{
					GoAwayAndDie();
				}
			}
		}

		if (!ticked || !CheckRange(256)) // Tick normally if player nearby
		{
			Super.Tick();
			ticked = true;
		}
		else // Otherwise just tick through actor states
		{
			if (tics == -1) { return; }
			else if (--tics <= 0)
			{
				SetState(CurState.NextState);
			}
		}
	}
}

class CKTreasure : StackableInventory
{
	mixin CKPickup;

	Default
	{
		+COUNTITEM
		+NOGRAVITY

		Inventory.MaxAmount 10000000;
		Inventory.PickupFlash "";
		Inventory.PickupSound "ckeen/pickup";
		+INVENTORY.UNDROPPABLE

		CKTreasure.VSpeed 4;
		Scale 2.0;
	}

	override bool ShouldStay ()
	{
		if (touched && ticker) { return true; }

		return false;
	}
}

class CKHealth : Health
{
	mixin CKPickup;

	Default
	{
		//$Category Commander Keen (BoA)/Pickups
		//$Color 13
		+NOGRAVITY

		Inventory.PickupFlash "";
		Inventory.PickupSound "ckeen/pickup";

		CKHealth.VSpeed 4;
		Scale 2.0;
	}

	override bool ShouldStay ()
	{
		if (touched && ticker) { return true; }

		return false;
	}
}

class CKPuzzleItem : PuzzleItem
{
	mixin CKPickup;

	Default
	{
		//$Category Commander Keen (BoA)/Items
		//$Color 13
		+NOGRAVITY

		Inventory.MaxAmount 1;
		Inventory.PickupFlash "";
		Inventory.PickupSound "ckeen/gem";
		-INVENTORY.INVBAR

		CKPuzzleItem.VSpeed 4;
		Scale 2.0;
	}

	override bool ShouldStay ()
	{
		if (touched && ticker) { return true; }

		return false;
	}
}

class CKWeapon : Weapon
{
	mixin CKPickup;

	Default
	{
		//$Category Commander Keen (BoA)/Weapons
		//$Color 14
		+NOGRAVITY

		Inventory.PickupFlash "";

		CKWeapon.VSpeed 4;
		Scale 2.0;
	}
}

// Player class
class KeenPlayer : PlayerPawn
{
	double aircontrol;

	Actor povcamera;
	Vector3 cameralocation;
	transient FLineTraceData cameratrace;
	double CameraDist;

	BoAFindHitPointTracer hittracer;
	Vector3 CrosshairPos;
	Actor CrosshairActor;
	double CrosshairDist;

	Inventory pogo;

	Property AirControl:aircontrol;

	Default
	{
		Speed 1;
		Health 100;
		Radius 16;
		Height 56;
		Mass 100;
		PainChance 255;
		Scale 2.0;
		DamageFactor "Falling", 0.0; // No falling damage
		+NOSKIN
		+NOBLOOD
		+NOBLOODDECALS
		+DONTGIB
		+INTERPOLATEANGLES

		Player.SideMove 1.0, 1.0;
		Player.ForwardMove 1.0, 1.0;
		Player.ViewBob 0.1;
		Player.DisplayName "Billy Blaze";

		Player.MorphWeapon "CKStunner";
		Player.StartItem "CKStunner";
		Player.WeaponSlot 1, "CKStunner";
		Player.AirCapacity -1; // Breathe underwater
		Player.JumpZ 12.0;
		Player.DamageScreenColor "FF 00 00", 0.0; // No red screen flash

		Player.SoundClass "Keen"; // Most sounds are defined here, except for...
		PainSound "ckeen/keen_pain"; // Pain sound has to be defined here because A_Pain plays actor's defined pain sound when morphed, not class's SNDINFO-defined pain sound...

		KeenPlayer.AirControl 0.8;
	}

	States
	{
		Spawn:
			KEEN L 1;
			Loop;
		See:
			KEEN ABCD 6;
			Loop;
		See.Jump:
			KEEN AB 6;
		See.Fall:
			KEEN E 6;
			KEEN E 0 { if (player.jumptics < 0) { SetStateLabel("See.Fall"); } }
			Goto See;
		See.Pogo:
			KEEN K 7;
		See.PogoBounce:
			KEEN J 1;
			Loop;
		Missile:
		Melee:
			KEEN E 2;
			KEEN F 4;
			KEEN E 1;
			Goto Spawn;
		Pain:
			KEEN G 8 {
				// A_Pain doesn't find the SNDINFO-defined pain sound for morphed actors anyway,
				// plus it restarts playing the sound every time it's called; if we call the pain
				// sound manually here with CHAN_NOSTOP, we get a better effect.
				A_StartSound(PainSound, CHAN_VOICE, CHAN_NOSTOP);
			}
			Goto Spawn;
		Death:
		XDeath:
			KEEN H 10
			{
				A_PlayerScream();
				vel = (FRandom(-5.0, 5.0), FRandom(-5.0, 5.0), FRandom(1.0, 5.0));
			}
			KEEN I 70;
			KEEN I -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		TakeInventory("BoATilt", 1);
		TakeInventory("BoASprinting", 1);
		TakeInventory("BoAHeartBeat", 1);

		let pain = FindInventory("PainShaderControl");
		if (pain) { pain.Destroy(); }

		player.air_finished = int.max; // Set initial air capacity to max directly in case we start underwater (only gets set on water entry by default)

		while (!povcamera) { povcamera = Spawn("SecurityCamera"); }
		povcamera.master = self;

		hittracer = new("BoAFindHitPointTracer");

		GiveInventory("CKLedgeGrab", 1);

		Level.MakeAutoSave(); // Force a save when you morph so that the death menu works properly and doesn't reset hub progress/state

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		bool chasecam = player && player.cheats & CF_CHASECAM;

		if (player && povcamera && chasecam)
		{
			Player.MinPitch = -60;
			Player.MaxPitch = 60;

			// Force pitch clamping
			if (pitch >= player.MaxPitch || pitch <= player.MinPitch)
			{
				player.cmd.pitch = 0;
			}

			double modifier;

			if (pitch < 0) { modifier = -96 * sin(-pitch); } // Aiming up moves the camera up so you can keep the aimpoint on screen
			else { modifier = 96 * sin(pitch); } // Aiming down actually moves the camera *up*, so that you can see the aimpoint over the top of the actor

			LineTrace(angle + 180, (CameraDist ? Min(CameraDist + 1.0, 128.0 - waterlevel * 16.0) : 128.0 - waterlevel * 16.0), 0, TRF_THRUHITSCAN | TRF_THRUACTORS, height + 32 - waterlevel * 8.0 + modifier, 0.0, 0.0, cameratrace);

			povcamera.SetOrigin(cameratrace.HitLocation + AngleToVector(angle, 2), true);
			povcamera.angle = angle;
			povcamera.pitch = pitch;

			povcamera.CameraFOV = player.fov;

			player.camera = povcamera;
			CameraDist = cameratrace.Distance;

			DoTrace(self, angle, 2048, pitch, 0, height / 2, hittracer);

			CrosshairPos = hittracer.Results.HitPos;
			CrosshairActor = hittracer.Results.HitActor;
			CrosshairDist = hittracer.Results.Distance;
		}
		else if (player)
		{
			Player.MinPitch = -90;
			Player.MaxPitch = 90;

			player.camera = player.mo;
		}

		if (!pogo) { pogo = FindInventory("CKPogoStick"); }

		if (
			player &&
			player.jumptics < 0 &&
			(!pogo || !CKPogoStick(pogo).active) &&
			!InStateSequence(CurState, FindState("See.Jump"))
		)
		{
			A_StartSound("ckeen/keen_jump");
			SetStateLabel("See.Jump");
		}

		Super.Tick();
	}

	// Stripped down give cheat so that we can keep the +invuse key for activating the pogostick
	override void CheatGive(String name, int amount)
	{
		int i;
		Class<Inventory> type;
		let player = self.player;

		if (player.mo == NULL || player.health <= 0)
		{
			return;
		}

		int giveall = ALL_NO;
		if (name ~== "all") { giveall = ALL_YES; }
		else if (name ~== "everything") { giveall = ALL_YES; }

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

			if (!giveall) { return; }
		}


		if (giveall || name ~== "ammo")
		{
			let ammoitem = FindInventory("CKStunnerAmmo");

			if (!ammoitem)
			{
				let ammoitem = Inventory(Spawn("CKStunnerAmmo"));
				ammoitem.AttachToOwner (self);
				ammoitem.Amount = ammoitem.MaxAmount;
			}
			else if (ammoitem.Amount < ammoitem.MaxAmount)
			{
					ammoitem.Amount = ammoitem.MaxAmount;
			}

			if (!giveall) { return; }
		}

		if (giveall || name ~== "keys")
		{
			for (i = 0; i < AllActorClasses.Size(); ++i)
			{
				let type = (class<CKPuzzleItem>)(AllActorClasses[i]);
				if (type != null)
				{
					let def = GetDefaultByType (type);
					if (def.Icon.isValid())
					{
						GiveInventory(type, amount <= 0 ? def.MaxAmount : amount, true);
					}
				}
			}

			if (!giveall) { return; }
		}


		if (giveall || name ~== "weapons")
		{
			GiveInventory("CKStunner", 1);

			if (!giveall) { return; }
		}

		if (giveall) { return; }

		type = name;
		if (!type)
		{
			if (PlayerNumber() == consoleplayer)
				A_Log(String.Format("Unknown item \"%s\"\n", name));
		}
		else
		{
			// Limit what you can give, since there is no inventory bar available - Player should be able to press '+use' to enable/disable pogostick, and that's it!
			if (name.left(2) ~== "CK" || name.left(5) ~== "Power" || name.left(3) ~== "BoA") { GiveInventory(type, amount, true); }
			else if (PlayerNumber() == consoleplayer)
				A_Log(String.Format("Can't give item \"%s\" while you are Commander Keen!\n", name));
		}
	}

	// No running...
	override double, double TweakSpeeds (double forward, double side)
	{
		if (!(player.cheats & CF_NOCLIP2 || player.cheats & CF_NOCLIP)) // Clamp speeds unless you are cheating
		{
			forward = clamp(forward, -6400, 6400);
			side = clamp(side, -6144, 6144);
		}

		forward *= ForwardMove1;
		side *= SideMove1;

		return forward, side;
	}

	// Morph-friendly CheckWeaponChange function to allow changing weapons while morphed
	override void CheckWeaponChange()
	{
		let player = self.player;
		if (player.WeaponState & WF_DISABLESWITCH) // Weapon changing has been disabled.
		{ // ...so throw away any pending weapon requests.
			player.PendingWeapon = WP_NOCHANGE;
		}

		// Put the weapon away if the player has a pending weapon or has died, and
		// we're at a place in the state sequence where dropping the weapon is okay.
		if ((player.PendingWeapon != WP_NOCHANGE || player.health <= 0) &&
			player.WeaponState & WF_WEAPONSWITCHOK)
		{
			DropWeapon();
		}
	}

	// Modified FireWeapon that doesn't automatically switch to another weapon when no ammo remains
	override void FireWeapon (State stat)
	{
		let player = self.player;

		let weapn = player.ReadyWeapon;
		if (weapn == null || !weapn.CheckAmmo (Weapon.PrimaryFire, false))
		{
			return;
		}

		player.WeaponState &= ~WF_WEAPONBOBBING;
		PlayAttacking ();
		weapn.bAltFire = false;
		if (stat == null)
		{
			stat = weapn.GetAtkState(!!player.refire);
		}
		player.SetPsprite(PSP_WEAPON, stat);
		if (!weapn.bNoAlert)
		{
			SoundAlert (self, false);
		}
	}

	void DoTrace(Actor origin, double angle, double dist, double pitch, int flags, double zoffset, BoAFindHitPointTracer thistracer)
	{
		if (!origin) { origin = self; }

		thistracer.skipspecies = origin.species;
		thistracer.skipactor = origin;
		Vector3 tracedir = (cos(angle) * cos(pitch), sin(angle) * cos(pitch), -sin(pitch));
		thistracer.Trace(origin.pos + (0, 0, zoffset), origin.CurSector, tracedir, dist, 0);
	}

	override bool UndoPlayerMorph(playerinfo activator, int unmorphflag, bool force)
	{
		if (!activator || !activator.mo) { return false; }

		int premorphhealth;

		for (Inventory i = activator.mo.inv; i != null; i = i.Inv)
		{
			if (i is "Billy")
			{
				if (Billy(i).premorphhealth) { premorphhealth = Billy(i).premorphhealth; }
				break;
			}
		}

		bool ret = Super.UndoPlayerMorph(activator, unmorphflag, force); // This call forces the player health to full Spawn Health

		activator.health = activator.mo.health = premorphhealth;

		return ret;
	}

	override bool UseInventory (Inventory item)
	{
		if (String.Format(item.GetClassName()).Left(2) ~== "CK") { return Super.UseInventory(item); }
		else { return false; }
	}

	override bool OnGiveSecret(bool printmsg, bool playsound)
	{
		console.MidPrint(Font.GetFont("Classic"), StringTable.Localize("$SECRETMESSAGE"));
		A_StartSound("ckeen/secret", CHAN_AUTO, CHANF_UI);

		return false;
	}

	// Allow forcing the player to respawn in a map via ACS (equivalent to pressing 'use' when dead)
	static void ForceRespawn(Actor mo)
	{
		let player = mo.player;

		if (!player) { return; }

		player.cls = null;
		player.playerstate = (multiplayer || level.AllowRespawn || sv_singleplayerrespawn || G_SkillPropertyInt(SKILLP_PlayerRespawn)) ? PST_REBORN : PST_ENTER;
		if (mo.special1 > 2) { mo.special1 = 0; }
	}

	static void ExitLevel(Actor mo, int position)
	{
		if (mo.player) { mo.player.Resurrect(); }
		Level.ExitLevel(position, false);
	}
}

class Billy : PowerMorph
{
	int armor;
	double hexenarmorslots[5];
	int premorphhealth;
	double savepercent;
	class<Inventory> PreInvSel;

	Default
	{
		PowerMorph.MorphStyle MRF_LOSEACTUALWEAPON | MRF_NEWTIDBEHAVIOUR | MRF_UNDOBYDEATHSAVES;
		PowerMorph.MorphFlash "Nothing";
		PowerMorph.UnMorphFlash "Nothing";
		PowerMorph.PlayerClass "KeenPlayer";
		Powerup.Duration 0x7FFFFFFF;
	}

	override void InitEffect()
	{
		if (owner && owner.player)
		{
// Should we default Keen to third-person view??
//			owner.player.cheats |= CF_CHASECAM;

			// Save the armor values.
			for (Inventory i = owner.Inv; i != null; i = i.Inv)
			{
				if (i.GetClass() == "BasicArmor")
				{
					armor = i.Amount;
					savepercent = BasicArmor(i).SavePercent;
				}
				else if (i.GetClass() == "HexenArmor")
				{
					let h = HexenArmor(i);
					for (int s = 0; s < 5; s++) { hexenarmorslots[s] = h.slots[s]; }
				}
			}

			premorphhealth = owner.health;

			PlayerPawn p = PlayerPawn(owner);
			if (p && p.InvSel)
			{
				PreInvSel = PlayerPawn(owner).InvSel.GetClass();
			}
		}

		Super.InitEffect();
	}

	override void EndEffect()
	{
		if (MorphedPlayer && MorphedPlayer.mo)
		{
			MorphedPlayer.cheats &= ~CF_CHASECAM;
			MorphedPlayer.camera = MorphedPlayer.mo;

			// Restore pitch clamping, since this doesn't get reset otherwise
			MorphedPlayer.MinPitch = -90;
			MorphedPlayer.MaxPitch = 90;

			// Reset the default inventory items (effects, shaders, etc.)
			InventoryClearHandler.GiveDefaultInventory(MorphedPlayer.mo, true);

			// Restore armor values
			BasicArmor a = BasicArmor(MorphedPlayer.mo.FindInventory("BasicArmor"));
			if (!a)
			{
				MorphedPlayer.mo.GiveInventory("BasicArmor", 0);
				a = BasicArmor(MorphedPlayer.mo.FindInventory("BasicArmor"));
			}

			if (a)
			{ 
				a.amount = armor;
				a.SavePercent = savepercent;
			}

			HexenArmor h = HexenArmor(MorphedPlayer.mo.FindInventory("HexenArmor"));
			if (!h)
			{
				MorphedPlayer.mo.GiveInventory("HexenArmor", 0);
				h = HexenArmor(MorphedPlayer.mo.FindInventory("HexenArmor"));
			}

			if (h)
			{
				for (int s = 0; s < 5; s++) { h.slots[s] = hexenarmorslots[s]; }
			}

			MorphedPlayer.mo.InvSel = MorphedPlayer.mo.FindInventory(PreInvSel);
			if (!MorphedPlayer.mo.InvSel)
			{
				MorphedPlayer.mo.InvSel = MorphedPlayer.mo.FirstInv();
			}
		}

		Super.EndEffect();
	}

	// Don't delete this item when player dies!
	override void OwnerDied() {}
}

// Moving Platforms
class CKPlatform : Actor
{
	Array<Actor> touchers;
	Vector3[64] offsets;

	Actor thrust;
	Class<Actor> ExhaustActor;

	double moveangle, moved, user_movedist;

	Property Exhaust:ExhaustActor;

	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Platform (Moving)
		//$Color 8

		Radius 46;
		Height 12;
		MaxStepHeight 0;
		Speed 4;
		+CANPASS
		+DONTTHRUST
		+NOGRAVITY
		+SOLID
		CKPlatform.Exhaust "CKPlatformThrust";
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
		Active:
			MDLA A -1;
			Stop;
		Inactive:
			MDLA A -1;
			Stop;
	}

	override void Touch(Actor toucher)
	{
		if (toucher == self || toucher.bNoGravity || toucher is "CKPlatform" || toucher.pos.z == toucher.floorz) { return; }
		if (toucher.pos.z > pos.z + 32.0 || toucher.pos.z < pos.z - 16) { return; }
		if (touchers.Find(toucher) == touchers.Size()) { touchers.Push(toucher); }
	}

	override void PostBeginPlay()
	{
		moveangle = angle;

		bDormant = SpawnFlags & MTF_DORMANT;

		if (bDormant) { Deactivate(self); }
		else { Activate(self); }

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (IsFrozen() || bDormant)
		{
			Actor.Tick();

			return;
		}

		CheckTouchers();

		Vector2 newpos = pos.xy + RotateVector((Speed, 0), moveangle);
		moved += Speed;

		if (CheckMove(newpos, 0) && (user_movedist <= 0 || moved <= user_movedist))
		{
			SetOrigin((newpos, pos.z), true);

			MatchMovement();
			Actor.Tick();
		}
		else
		{
			moveangle = (moveangle + 180) % 360;
			moved = 0;
			Actor.Tick();
		}
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (other.player || other.bIsMonster)
		{
			Touch(other);
			return true;
		}

		return true;
	}

	void CheckTouchers()
	{
		for (int i = 0; i < min(touchers.Size(), 64); i++)
		{
			if (touchers[i])
			{
				if (
					Distance3D(touchers[i]) > (Radius + touchers[i].radius) * 1.4 ||
					touchers[i].pos.z < pos.z + height ||
					!touchers[i].bOnMobj
				)
				{
					touchers.Delete(i);
					offsets[i] = (0, 0, 0);
				}
				else { offsets[i] = touchers[i].pos - pos; }
			}
			else { touchers.Delete(i); touchers.ShrinkToFit(); }
		}
	}

	void MatchMovement()
	{
		for (int i = 0; i < min(touchers.Size(), 64); i++)
		{
			if (
				touchers[i] &&
				(
					(Distance2D(touchers[i]) < (Radius + touchers[i].radius) * 1.4 && touchers[i].pos.z == pos.z + height) ||
					absangle(angle, AngleTo(touchers[i])) < 45 ||
					((touchers[i].bOnMobj || (touchers[i].player && touchers[i].player.jumptics == 0)) && Distance3D(touchers[i]) < radius * 2)
				) &&
				offsets[i] != (0, 0, 0)
			)
			{
				if (touchers[i].TryMove(pos.xy + offsets[i].xy, true))
				{
					touchers[i].SetOrigin(pos + offsets[i], true);
				}
			}
		}
	}

	override void Activate(Actor activator)
	{
		bDormant = false;
		if (ExhaustActor) { thrust = Spawn(ExhaustActor); }
		if (thrust) { thrust.master = self; }
		Super.Activate(activator);
	}

	override void Deactivate(Actor activator)
	{
		bDormant = true;
		if (thrust) { thrust.Destroy(); }
		Super.Deactivate(activator);
	}
}

class CKPlatformFalling : CKPlatform
{
	int movetimer, synchoffset;
	double movez;
	bool hitbottom;

	Default
	{
		//$Title Platform (Falling)
		+INTERPOLATEANGLES
		CKPlatform.Exhaust "";
	}

	override void PostBeginPlay()
	{
		SpawnPoint = pos;
		synchoffset = Random(0, 19);

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (IsFrozen() || bDormant)
		{
			Actor.Tick();

			return;
		}

		CheckTouchers();

		if (movetimer == 16)
		{
			if (pos.z == floorz)
			{
				if (touchers.Size()) { movez = 0;}
				else { movez = Speed; hitbottom = true; }
			}
			else
			{
				if (touchers.Size() || !hitbottom) { movez = -Speed; hitbottom = false; }
				else if (pos.z < SpawnPoint.z && hitbottom) { movez = Speed; }
				else { movez = 0; movetimer = 0; }
			}
		}
		else if (touchers.Size()) { movetimer++; }
		else if (movetimer && (level.time + synchoffset) % 20 == 0) { movetimer = max(movetimer - 1, 0); }

		if (movez)
		{
			Vector3 newpos = pos + (0, 0, movez);
			if (CheckMove(newpos.xy, PCM_NOACTORS)) { SetOrigin(newpos, true); }

			MatchMovement();
		}

		Actor.Tick();
	}
}

class CKPlatformVertical : CKPlatform
{
	double movedist, movez;
	bool hitbottom;

	Default
	{
		//$Title Platform (Vertical)
		Speed 2;
		+INTERPOLATEANGLES
		CKPlatform.Exhaust "CKPlatformEnergy";
	}

	override void PostBeginPlay()
	{
		SpawnPoint = pos;

		movedist = user_movedist ? user_movedist : pos.z - floorz + 2;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (IsFrozen() || bDormant)
		{
			Actor.Tick();

			return;
		}

		CheckTouchers();

		if (pos.z == SpawnPoint.z - movedist || pos.z == floorz || pos.z + 64.0 == ceilingz)
		{
			movez = Speed;
			hitbottom = true;
		}
		else
		{
			if (!hitbottom)
			{
				movez = -Speed;
			}
			else if (pos.z < SpawnPoint.z && hitbottom)
			{
				movez = Speed;
			}
			else
			{
				movez = 0; hitbottom = false;
			}
		}

		if (movez)
		{
			Vector3 newpos = pos + (0, 0, movez);
			if (CheckMove(newpos.xy, PCM_NOACTORS)) { SetOrigin(newpos, true); }

			MatchMovement();
		}

		Actor.Tick();
	}
}

class CKPlatformThrust : Actor
{
	Default
	{
		+BRIGHT
		+FORCEXYBILLBOARD
		+NOGRAVITY
		+NOINTERACTION
		Scale 2.0;
	}

	States
	{
		Spawn:
			CKPT AB 2;
			Loop;
	}

	override void Tick()
	{
		if (CKPlatform(master) && !master.bDormant) { SetXYZ((master.pos.xy - RotateVector((master.Radius, 0), CKPlatform(master).moveangle), master.pos.z + master.height / 2)); }
		else { Destroy(); }

		Super.Tick();
	}
}

class CKPlatformEnergy : CKPlatformThrust
{
	Default
	{
		Scale 1.0;
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
	}

	override void Tick()
	{
		if (CKPlatform(master) && !master.bDormant)
		{
			SetXYZ(master.pos);
			angle = master.angle;
		}
		else { Destroy(); }

		Actor.Tick();
	}
}

class CKPlatformGlass : Actor
{
	int phasecounter, user_phaseoffset; // user_phaseoffset controls which phase of transparency the actor stars in.  Default is 0 (solid).

	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Platform (Glass, Disappearing)
		//$Color 8

		Radius 46;
		Height 12;
		MaxStepHeight 0;
		+CANPASS
		+DONTTHRUST
		+NOGRAVITY
		+SOLID
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		frame = min(user_phaseoffset, 3);

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (IsFrozen() || bDormant) { return; }

		if (phasecounter < 85) { phasecounter++; }
		else
		{
			phasecounter = 0;

			frame++;

			if (frame > 3) { frame = 0; } // Rotate through A, B, C only

			bSolid = (frame != 2); // Solid on frame A, B, and D
		}

		Super.Tick();
	}
}

// Climbable Pipes
class CKPipe : LadderBase
{
	Class<Actor> top;

	Property Top:top;

	Default
	{
		//$Category Commander Keen (BoA)/Props
		Radius 1;
		Height 0;
		-NOINTERACTION
		+SOLID
		LadderBase.ClimbRadius 24;
		LadderBase.Friction 0.75;
		LadderBase.LadderHeight -1;
	}

	override void PostBeginPlay()
	{
		if (user_groundoffset == -1) { user_groundoffset = 32.0; }

		Super.PostBeginPlay();

		SetOrigin((pos.xy, pos.z - ladderheight), false);

		A_SetSize(-1, ladderheight);
		scale.y = -ladderheight / (64.0 / 1.2);

		if (top)
		{
			Actor t = Spawn(top, pos + (0, 0, ladderheight));
			t.angle = angle;
		}

		if (!user_soundtype) { user_soundtype = 5; } // Soundtype 5 means Keen climbing sounds
	}
}

class CKPipeTopBlue : Actor
{
	Default
	{
		+NOINTERACTION
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class CKPipeTopPink : CKPipeTopBlue {}
class CKPipeTopGold : CKPipeTopBlue {}

class CKPipeBlue : CKPipe
{
	Default
	{
		//$Title Climbable Pipe (Blue)
		CKPipe.Top "CKPipeTopBlue";
	}
}

class CKPipePink : CKPipe
{
	Default
	{
		//$Title Climbable Pipe (Pink)
		CKPipe.Top "CKPipeTopPink";
	}
}

class CKPipeGold : CKPipe
{
	Default
	{
		//$Title Climbable Pipe (Gold)
		CKPipe.Top "CKPipeTopGold";
	}
}

// Enemies and NPCs
class CKLick : CKBaseEnemy
{
	int turncounter;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Lick
		//$Color 4

		Speed 8;
		Radius 16;
		Height 32;
		Damage 0; // Damages on touch only during attack state
		Obituary "$CK_LICK";
	}

	States
	{
		Spawn:
			CKLC AAAAABBBBB 1 CK_LickBounce();
		See:
			CKLC CCCCCDDDDD 1 CK_LickBounce();
			Goto Spawn;
		Stunned:
			CKLC H 1 A_ChangeVelocity(0, 0, 4, CVF_RELATIVE);
			CKLC H -1;
			Stop;
		Attack:
			CKLC E 2
			{
				A_StartSound("ckeen/lick/attack");
				vel.xy = RotateVector((2, 0), angle);
				SetDamage(15);
			}
			CKLC FGFEFGF 2;
			CKLC F 0 { SetDamage(0); }
			Goto See; // Original code sent actor back to third state (C frame), which is why Spawn and See are split the way they are above.
	}

	void CK_LickBounce()
	{
		PlayerSearch();

		if (!target) { return; }

		double dist = target ? Distance2D(target) - target.radius * 1.4 : 0;

		bool blocked = BlockingLine || BlockingMobj || !CheckMove(pos.xy + vel.xy, PCM_DROPOFF | PCM_NOLINES);

		if (pos.z == floorz || blocked || bOnMobj)
		{
			if (!blocked && target && IsVisible(target, true))
			{
				if (IsVisible(target, true))
				{
					if (!turncounter) { angle = AngleTo(target); }

					if (dist < 32 && abs(pos.z - target.pos.z) < 32)
					{
						angle = AngleTo(target);
						SetState(AttackState);
						return;
					}
				}
			}

			if (blocked)
			{
				angle += Random(-115, -245);
				turncounter = 35;
			}

			if (pos.z == floorz || bOnMobj)
			{
				if (dist > 48) { vel.z = Speed; }
				else { vel.z = Speed / 2; }
			}

			vel.xy = RotateVector((dist > 48 ? Speed : Speed / 2, 0), angle);
		}
	}

	override void Tick()
	{
		// They would jump into tar originally and fall off of the map...  I think this is the best way to handle that.
		if (waterlevel && !stunned) { DoStun(true); }

		if (turncounter > 0) { turncounter--; }

		Super.Tick();
	}
}

class CKWormouth : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Wormouth
		//$Color 4

		Speed 4;
		Radius 18;
		Height 36;
		Damage 0; // Damages on touch only during attack state
		Obituary "$CK_WORMOUTH";
		-SOLID
	}

	States
	{
		Spawn:
			CKSN A 1;
		See:
			CKSN AA 1 CK_WormMove();
			Loop;
		LookAround:
			CKSN I 10 { angle += 90; } // Look right
			CKSN H 4;
			CKSN I 10 CK_Look(90);
			CKSN A 4;
			CKSN I 10 { angle += 180; } // Look left
			CKSN H 4;
			CKSN I 10 CK_Look(-90);
			CKSN A 4 A_Face(target);
			Goto See;
		Stunned:
			CKSN G -1;
			Stop;
		Attack:
			CKSN D 4
			{
				A_Face(target);
				bSolid = true;
				A_StartSound("ckeen/wormouth/attack");
			}
			CKSN E 4;
			CKSN F 8
			{
				vel.xy = RotateVector((1, 0), angle);
				SetDamage(15); // Damage on the 'biting' frame only
			}
			CKSN ED 4
			{
				SetDamage(0);
			}
			CKLC F 0
			{
				if (target && Distance2D(target) < 16) { SetState(AttackState); return; }
				bSolid = false;
			}
			Goto See;
	}

	void CK_WormMove()
	{
		PlayerSearch();

		if (!target) { return; }

		double dist = target ? Distance2D(target) - target.radius * 1.4 : 0;

		if (target && dist < 128 && Random() < 6) // Range is ~48 in original code
		{
			vel.xy *= 0;
			SetStateLabel("LookAround");
			return;
		}

		if (target && dist < 16)
		{
			SetState(AttackState);
			return;
		}

		bool blocked = BlockingLine || BlockingMobj || !CheckMove(pos.xy + RotateVector((Speed, 0), angle), PCM_DROPOFF | PCM_NOLINES);

		if (blocked) { angle += Random(-115, -245); }

		vel.xy = RotateVector((Speed, 0), angle);
	}

	void CK_Look(int angleoffset = 0, int anglerange = 30)
	{
		if (!target) { return; }

		if (absangle(angle + angleoffset, AngleTo(target)) < anglerange)
		{
			A_Face(target);
			SetState(SeeState);
		}
	}
}

class CKMine : CKBaseEnemy
{
	double moveangle, moved, user_movedist;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Mine
		//$Color 4

		Radius 24;
		Height 50;
		Speed 4;
		MaxStepHeight 0;
		+NOGRAVITY
		+FORCEXYBILLBOARD
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKMN A -1;
			Stop;
		Explode:
			CKMN B 0 A_StartSound("ckeen/mine/explode");
			CKMN BD 15 Bright A_Explode();
			Stop;
	}

	override void PostBeginPlay()
	{
		moveangle = angle;

		bDormant = SpawnFlags & MTF_DORMANT;

		if (bDormant) { Deactivate(self); }
		else { Activate(self); }

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (IsFrozen() || bDormant)
		{
			Actor.Tick();

			return;
		}

		Vector2 newpos = pos.xy + RotateVector((Speed * cos(abs(pitch)), 0), moveangle);
		moved += Speed;

		if (CheckMove(newpos, 0) && (user_movedist <= 0 || moved <= user_movedist) && waterlevel == 3 && pos.z > floorz && !bOnMobj && pos.z + height < ceilingz) // Keep them underwater if they move up and down
		{
			SetOrigin((newpos, pos.z + Speed * sin(pitch)), true);
		}
		else // Swap directions
		{

			Speed = -Speed;
			moved = 0;

			SetOrigin((newpos, pos.z + Speed * sin(pitch)), true);
		}

		Super.Tick();
	}

	override void Touch(Actor toucher)
	{
		if (toucher && toucher.player && !InStateSequence(CurState, FindState("Explode")))
		{
			vel *= 0;
			bDormant = true;
			SetStateLabel("Explode");
		}
	}

	override void Activate(Actor activator)
	{
		bDormant = false;
		Super.Activate(activator);
	}

	override void Deactivate(Actor activator)
	{
		bDormant = true;
		Super.Deactivate(activator);
	}
}

class CKSmirky : CKBaseEnemy
{
	double teleportcounter;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Treasure Eater
		//$Color 4

		Speed 5;
		Radius 40;
		Height 64;
		Damage 0;
		Obituary "$CK_SMIRKY";
	}

	States
	{
		Spawn:
			CKGN AAAAAAAAAABBBBBBBBBB 1;
			CKGN B 0 CK_SmirkyLook();
		See:
			CKGN CCCDDDEEEDDD 1 CK_SmirkyBounce();
			CKGN D 0; //A_Stop();
			Goto Spawn;
		Stunned:
			CKGN C 3;
			CKGN F -1;
			Stop;
		Teleport:
			CKGN J 10 A_StartSound("ckeen/smirky/teleport");
			CKGN IHG 10;
			CKGN G 10 CK_WarpToItem();
			CKGN HIJ 10 CK_CheckPickup();
			Goto See;
	}

	void CK_SmirkyLook()
	{
		if (CheckIfSeen()) { SetState(SpawnState); } // Don't do any thieving unless a player is in sight (otherwise he'll clean the level out)
	}

	void CK_SmirkyBounce()
	{
		LookForItem();

		CK_CheckPickup();

		double dist = goal ? Distance2D(goal) : 0;

		bool blocked = BlockingLine || BlockingMobj || !CheckMove(pos.xy + vel.xy);

		if (pos.z == floorz || blocked || bOnMobj)
		{
			if (pos.z == floorz || bOnMobj)
			{
				if ((!dist || dist > radius) && teleportcounter >= 12)
				{
					vel *= 0;
					SetStateLabel("Teleport");
					return;
				}

				vel.z = 12.0;
			}

			if (!blocked && goal && IsVisible(goal, true)) { angle = AngleTo(goal); }
			else
			{
				angle = Random(0, 359);
				teleportcounter++;
			}

			if (dist && dist < radius) { vel.xy *= 0; } // Stop if you're at the item so that you can jump to grab it next loop
			else { vel.xy = RotateVector((Speed, 0), angle); }

			if (CheckMove(pos.xy + vel.xy)) { return; }

			if (pos.z == floorz || bOnMobj)
			{
				if (teleportcounter++ == 12)
				{
					vel *= 0;
					SetStateLabel("Teleport");
					return;
				}
			}
		}
	}

	void CK_CheckPickup()
	{
		if (!goal) { return; }

		if (goal && Distance2D(goal) < radius && Distance3D(goal) < height)
		{
			Vector3 goalpos = goal.pos;

			if (
				Inventory(goal).CallTryPickup(self) &&
				!(goal is "CKTreasure" && CKTreasure(goal).touched) &&
				!(goal is "CKPuzzleItem" && CKPuzzleItem(goal).touched)
			)
			{
				Spawn("CKStolenItem", goalpos);
				A_StartSound("ckeen/smirky/steal");
			}
		}
	}

	void CK_WarpToItem()
	{
		teleportcounter = 0;

		if (!goal) { LookForItem(); } // Last chance to check for remaining items
		if (!goal) { Destroy(); return; } // Teleport away forever if no more items are in the level to steal

		Vector2 targetpos = goal.pos.xy;

		if (!CheckMove(targetpos))
		{
			// If stuck in a line, try one time to move him out.  Otherwise he'll get out on his own next time he teleports
			if (BlockingLine)
			{
				int s = PointOnLineSide(targetpos.x, targetpos.y, BlockingLine);

				double lineangle = 0;

				if (!BlockingLine.delta.x) { lineangle = 0; }
				else if (!BlockingLine.delta.y) { lineangle = 90; }
				else { lineangle = (atan(BlockingLine.delta.y / BlockingLine.delta.x) + 270) % 360; }

				if (s) { lineangle += 180; }

				targetpos += RotateVector((Radius, 0), lineangle);
			}
		}

		SetOrigin((targetpos, (goal.pos.z - goal.floorz < 128 ? goal.floorz : goal.pos.z)), false);
	}

	int PointOnLineSide(double x, double y, line l)
	{
		return (y - l.v1.p.y) * l.delta.x + (l.v1.p.x - x) * l.delta.y > (1.0 / 65536);
	}

	void LookForItem()
	{
		ThinkerIterator it = ThinkerIterator.Create("Actor", Thinker.STAT_DEFAULT);
		Actor mo;
		int count;

		while (mo = Actor(it.Next()))
		{
			if (mo is "CKHealth" || mo is "CKTreasure") // Look for health and coin items first
			{
				count++;

				if (mo.pos.z - mo.floorz >= 128) { continue; } // Only go after items within jumping reach!

				if (!goal || Distance2D(mo) < Distance2D(goal))
				{
					goal = mo;
				}
			}
		}

		if (count) { return; } // If you found treasure left in the level, stop looking here

		it.Reinit();

		while (mo = Actor(it.Next())) // Otherwise, look for key gems and steal those instead so that we can't complete the map!
		{
			if (mo is "CKPuzzleItem")
			{
				if (!goal || Distance2D(mo) < Distance2D(goal))
				{
					goal = mo;
				}
			}
		}
	}
}

class CKStolenItem : Actor
{
	Default
	{
		Scale 2.0;
		+NOINTERACTION
		+NOGRAVITY
	}

	States
	{
		Spawn:
			CKST ABCD 5;
			Stop;
	}
}

class CKLindsey : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/NPCs
		//$Title Princess Lindsey
		//$Color 11
		Speed 0;
		FloatSpeed 1.5;
		Radius 16;
		Height 64;
		Damage 0;
		Obituary "$CK_LINDSEY";
		+FRIENDLY
		+NOGRAVITY
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
		CKBaseEnemy.TouchSound "ckeen/lindsey/touch";
	}

	States
	{
		Spawn:
			CKPL A 1;
		See:
			CKPL AAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDD 1 CK_Float(12, FloatSpeed); // Allow interpolated bobbing motion across 10-tic frames
			Loop;
	}

	override void PostBeginPlay()
	{
		if (pos.z - floorz < 25) { SetOrigin((pos.xy, floorz + 25), false); }

		Super.PostBeginPlay();
	}
}

class CKDopefish : CKBaseEnemy
{
	int turncounter, zdir;
	double oldangle;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Dopefish
		//$Color 4

		Height 128;
		Radius 64;
		Scale 3.0;
		Speed 3.75;
		FloatSpeed 1.875;
		Damage 0; // Damages on touch only during attack state
		+NOGRAVITY
		+NOTAUTOAIMED
		Obituary "$CK_DOPEFISH";
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKDF A 1;
		See:
			CKDF AAAAAAAAAABBBBBBBBBB 1 CK_DopefishSwim();
			Loop;
		Attack:
			CKDF C 10 // Open mouth
			{
				vel.xy = RotateVector((Speed, 0), angle);
				vel.z = 0;

				// Use alternate frame...  C is original-style sprite, E has schoolfish between teeth
				if (Random() < 128) { frame = 4; }
			}
			CKDF A 1 // Bite!
			{
				vel.xy = RotateVector((Speed, 0), angle);
				A_StartSound("ckeen/dopefish/attack");
				SetDamage(100);
				if (target is "CKSchoolFish") { target.Destroy(); }
			}
			CKDF A 29; // Closed mouth
			CKDF A 0 // Reset
			{
				SetDamage(0);
				if (target && target.health > 0)  // Keep attacking the player without burping
				{
					if (Distance3D(target) < 64)
					{
						A_Face(target);
						SetState(AttackState);
					}
					else
					{
						SetState(SeeState);
					}
				}
			}
		Burp:
			CKDF A 30;
			CKDF D 30
			{
				A_StartSound("ckeen/dopefish/burp");
				Spawn("CKBubble", pos + (RotateVector((56, -4), angle + 90), 32));
			}
			CKDF A 30;
			Goto See;
	}

	void CK_DopeFishSwim()
	{
		PlayerSearch();

		if (!target) { return; }

		bool blocked = BlockingLine || BlockingMobj || !CheckMove(pos.xy + vel.xy);

		if (BlockingMobj && BlockingMobj is "CKSchoolfish")
		{
			target = BlockingMobj;
			A_Face(target);

			SetState(AttackState);
			return;
		}

		if (turncounter > 0) { turncounter--; }

		if (blocked)
		{
			if (BlockingMobj && BlockingMobj == target)
			{
				SetState(AttackState);
				return;
			}

			if (!turncounter)
			{
				angle += Random(-115, -245);
				turncounter = 70;
			}

			zdir = Random(-1, 1);
		}
		else if (target && IsVisible(target, true))
		{
			if (!turncounter)
			{
				angle = AngleTo(target);
				turncounter = 70;
			}

			if (pos.z > target.pos.z) { zdir = -1; }
			else if (pos.z < target.pos.z) { zdir = 1; }
			else { zdir = 0; }
		}

		if (waterlevel < 3) { zdir = min(zdir, 0); } // Keep them underwater!

		vel.xy = RotateVector((Speed, 0), angle);
		vel.z = FloatSpeed * zdir;
	}
}

class CKBubble : Actor
{
	Default
	{
		Scale 2.0;
		+NOCLIP
	}

	States
	{
		Spawn:
			CKBU ABCD 10;
			Loop;
	}

	override void Tick()
	{
		if (waterlevel < 2 || pos.z + height == ceilingz) { Destroy(); }

		vel.z = 5;

		Super.Tick();
	}
}

class CKSchoolfish : CKBaseEnemy
{
	int turncounter, zdir, swimoffset;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Schoolfish
		//$Color 4

		Speed 2.5;
		FloatSpeed 1.25;
		Radius 14;
		Height 20;
		Damage 0;
		MaxStepHeight 0;
		+NOGRAVITY
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKSF A 1;
		See:
			CKSF AAAAAAAAAABBBBBBBBBB 1 CK_SchoolfishSwim();
			Loop;
	}

	override void PostBeginPlay()
	{
		swimoffset = Random(-32, 32);
		turncounter = Random(0, 35);

		Super.PostBeginPlay();
	}

	void CK_SchoolFishSwim()
	{
		PlayerSearch();

		if (!target) { return; }

		bool blocked = BlockingLine || BlockingMobj || !CheckMove(pos.xy + vel.xy);

		if (turncounter > 0) { turncounter--; }

		if (blocked)
		{
			if (!turncounter)
			{
				angle += Random(-115, -245);
				turncounter = 70;
			}

			zdir = Random(-1, 1);
			swimoffset = Random(-32, 32);
		}
		else if (target && IsVisible(target, true))
		{
			if (!turncounter)
			{
				angle = AngleTo(target) + Random(-45, 45);
				turncounter = 70;
			}

			double swimheight = (target.player ? target.player.viewheight : target.height / 2) + swimoffset;

			if (pos.z > target.pos.z + swimheight + height) { zdir = -1; }
			else if (pos.z < target.pos.z + swimheight - height) { zdir = 1; }
			else { zdir = 0; }
		}

		if (waterlevel < 3) { zdir = min(zdir, 0); } // Keep them underwater!

		vel.xy = RotateVector((Speed, 0), angle);
		vel.z = FloatSpeed * zdir;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (other is "CKSchoolfish" || other is "CKMine" || other.player) { return false; } // Swim through other fish and the player

		return Super.CanCollideWith(other, passive);
	}
}

class CKInchworm : CKBaseEnemy
{
	Array<Actor> touchers;
	int turncounter;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Inchworm
		//$Color 4

		Speed 6;
		Radius 18;
		Height 20;
		Damage 0;
		MaxStepHeight 16;
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKWM A Random(0, 15);
		See:
			CKWM AAABBB 5 CK_InchwormMove();
			Loop;
	}

	void CK_InchwormMove()
	{
		PlayerSearch();

		if (!target) { return; }

		if (turncounter) { turncounter--; }

		NewChaseDir();

		if (absangle(angle, AngleTo(target)) > 135 && !turncounter) { movedir = (movedir + 4) % 8; } // Turn around after a short while if you're facing away from the player

		MonsterMove();

		angle = movedir * 45;
		if (!turncounter) { turncounter = 6; } // Set the timeout for how long until you turn around if you are facing away from the player

		for (int i = 0; i < touchers.Size(); i++)
		{
			if (touchers[i] && Distance3D(touchers[i]) > 32.0) { touchers.Delete(i); }
		}

	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		// Don't collide with anything, but keep count of how many inchworms are overlapping right now
		if (other.bSolid && other is "CKInchWorm" && target && Distance3D(target) <= 32)
		{
			if (touchers.Find(other) == touchers.Size()) { touchers.Push(other); }

			if (touchers.Size() == 11)
			{
				DoEasterEgg();
			}
		}

		return false;
	}

	void DoEasterEgg()
	{
		// Only run this if there's no foot in the level already
		ThinkerIterator it = ThinkerIterator.Create("CKFoot", Thinker.STAT_DEFAULT);
		if (it.Next()) { return; }

		// Execute the inchworms' special...
		Level.ExecuteSpecial(special, self, null, false, args[0], args[1], args[2], args[3], args[4]);

		// Remove the inchworms.
		it = ThinkerIterator.Create("CKInchworm", Thinker.STAT_DEFAULT);
		Actor mo;

		while (mo = Actor(it.Next()))
		{
			mo.Destroy();
		}
	}
}

class CKMimRock : CKBaseEnemy
{
	bool bounced;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Mimrock
		//$Color 4

		Speed 6;
		Radius 24;
		Height 44;
		Damage 0;
		CKBaseEnemy.StunTime 0; // Only stunnable during moving and attack frames
	}

	States
	{
		Spawn:
			CKMM A 10;
			CKMM A 0 CK_MimRockWait();
		See:
			CKMM BCDEBC 3 CK_MimRockMove();
			Goto Spawn;
		Attack:
			CKMM F 12 { SetDamage(15); }
			CKMM G 5;
		Fall:
			CKMM H 1;
			CKMM H 5 CK_MimRockJump();
			Goto Spawn;
		Stunned:
			CKMM H 6;
			CKMM I -1;
			Stop;
	}

	void CK_MimRockWait()
	{
		stuntime = 0;
		bounced = false;
		SetDamage(0);

		PlayerSearch();

		if (target && !InSightOf(target) && Distance2D(target) > 48)
		{
			SetState(SeeState);
		}
		else
		{
			SetState(SpawnState);
		}
	}

	void CK_MimRockMove()
	{
		stuntime = -1; // Can be stunned while walking

		if (target && IsVisible(target, true) && !InsightOf(target) && abs(target.pos.z - pos.z) <= 80)
		{
			A_Face(target);

			if (Distance2D(target) < 128) // Double original range
			{
				vel.xy = RotateVector((5, 0), angle);
				vel.z = 10;

				SetState(AttackState);
			}
			else
			{
				A_Chase(null, null);
			}
		}
		else { SetState(SpawnState); }
	}

	void CK_MimRockJump()
	{
		stuntime = -1; // Can be stunned while jumping

		if (pos.z == floorz || bOnMobj)
		{
			A_StartSound("ckeen/mimrock/bounce");

			if (!bounced)
			{
				vel.z = 5;

				bounced = true;

				SetStateLabel("Fall");
			}
			else
			{
				vel.z = 0;
			}
		}
		else
		{
			SetStateLabel("Fall");
		}
	}

	bool InSightOf(Actor other)
	{
		return !(other && absangle(other.angle, other.AngleTo(self)) > 90);
	}
}

class CKSprite : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Sprite
		//$Color 4
		Speed 0;
		FloatSpeed 2.0;
		Radius 24;
		Height 50;
		Damage 0;
		+NOGRAVITY
		Obituary "$CK_SPRITE";
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKSP A 1;
		See:
			CKSP AAAAA 1 CK_SpriteFloat();
			Loop;
		Attack:
			CKSP B 20 A_Face(target, 0, 0);
			CKSP C 20 {
				A_StartSound("ckeen/shoot");
				A_SpawnProjectile("CKSpriteProjectile", 18.0, 0, 0, CMF_AIMDIRECTION);
			}
			CKSP C 15;
			Goto See;
	}

	override void PostBeginPlay()
	{
		if (pos.z - floorz < 25) { SetOrigin((pos.xy, floorz + 25), false); }

		Super.PostBeginPlay();
	}

	void CK_SpriteFloat()
	{
		PlayerSearch();

		CK_Float(16, FloatSpeed);

		if (target && IsVisible(target, true) && target.pos.z < pos.z + height && target.pos.z + target.height > pos.z) { SetState(AttackState); }

		if (pos.z > SpawnPoint.z + 16 && FloatSpeed < 0) { tics = 10; }
	}
}

class CKSpriteProjectile : Actor
{
	Default
	{
		Projectile;
		Scale 2.0;
		Speed 10;
		+BRIGHT
		+NOGRAVITY
	}

	States
	{
		Spawn:
			CKSP DEFG 5;
			Loop;
		Death:
			TNT1 A 15 A_Explode(15, 64);
			Stop;
	}
}

class CKBirdEgg : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Blue Bird Egg
		//$Color 4
		//$Sprite CKEGA0

		Speed 0;
		Radius 21;
		Height 48;
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
		CKBaseEnemy.WakeOnTouch 2;
	}

	States
	{
		Spawn:
			CKEG A 4;
			Loop;
		See:
			CKEG BCD 8;
			CKEG E -1
			{
				A_SetSize(-1, 20);

				Spawn("CKBird", pos);

				Actor shell;

				shell = Spawn("CKBirdEggShellBit", pos);
				if (shell)
				{
					shell.frame = 4;
					shell.vel.xy = RotateVector((-7, 0), Random(0, 359));
					shell.vel.z = 10;
					shell = null;
				}

				shell = Spawn("CKBirdEggShellBit", pos);
				if (shell)
				{
					shell.frame = 5;
					shell.vel.xy = RotateVector((7, 0), Random(0, 359));
					shell.vel.z = 10;
					shell = null;
				}

				shell = Spawn("CKBirdEggShellBit", pos);
				if (shell)
				{
					shell.frame = random(6,7);
					shell.vel.z = 14;
					shell = null;
				}
			}
			Stop;
	}
}

class CKBirdEggShellBit : Actor
{
	Default
	{
		Scale 2.0;
		Gravity 1.2;
	}

	States
	{
		Spawn:
			CKEG F -1;
			Stop;
	}

}

class CKBird : CKBaseEnemy
{
	int turncounter, zdir;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Blue Bird
		//$Color 4

		Speed 6;
		FloatSpeed 4;
		Radius 28;
		Height 66;
		CKBaseEnemy.StunTime 120;
		CKBaseEnemy.WakeOnTouch true;
	}

	States
	{
		Spawn:
			CKEA F 60;
		See:
			CKEA FFF 1 CK_BirdWalk();
			CKEA GGGG 1 CK_BirdWalk();
			CKEA HHH 1 CK_BirdWalk();
			CKEA IIII 1 CK_BirdWalk();
			Loop;
		Fly:
			CKEA AAAABBBBCCCCDDDD 1 CK_BirdFly();
			Loop;
		Land:
			CKEA D 4;
			CKEA D 0 CK_BirdLand(false);
			Loop;
		Stunned:
			CKEA E 4;
			CKEA E 0 CK_BirdLand();
			Loop;
		Revive:
			CKEA EFEFE 10;
			Goto See;
	}

	void CK_BirdWalk()
	{
		PlayerSearch();

		if (!target || stunned) { return; }

		double newfloorz = GetZAt(Speed, 0, AngleTo(target), GZF_ABSOLUTEANG);

		if (target && (target.pos.z - pos.z > 48 || newfloorz < pos.z))
		{
			vel.z = 2.0;

			bNoGravity = true;
			bFloat = true;
			Speed = FloatSpeed;

			A_SetSize(56, -1, true);

			SetStateLabel("Fly");
		}
		else
		{
			A_Chase(null, null);
		}
	}

	void CK_BirdFly()
	{

		double heightoffset = 0;

		PlayerSearch();

		if (!target || stunned) { return; }

		bool blocked = BlockingLine || (BlockingMobj && (!target || BlockingMobj != target)) || !CheckMove(pos.xy + vel.xy);

		if (turncounter > 0) { turncounter--; }

		if (blocked)
		{
			if (!turncounter)
			{
				angle += Random(90, 270);
				turncounter = 35;

				zdir = Random(-1, 1);
			}
		}
		else if (target && IsVisible(target, true))
		{
			heightoffset = target.height / 2;

			if (!turncounter)
			{
				angle = AngleTo(target);
				turncounter = 70;
			}

			if (pos.z > target.pos.z + heightoffset) { zdir = -1; }
			else if (pos.z < target.pos.z) { zdir = 1; }
			else { zdir = 0; }
		}

		if (waterlevel > 0) { zdir = 1; }

		vel.xy = RotateVector((Speed, 0), angle);
		vel.z = FloatSpeed * zdir;

		if (!waterlevel && pos.z <= floorz + heightoffset && vel.z <= 0)
		{
			SetStateLabel("Land");
		}
	}

	void CK_BirdLand(bool stopmovement = true)
	{
		if (waterlevel && !stunned) { SetStateLabel("Fly"); return; }

		bNoGravity = false;
		bFloat = false;
		Speed = Default.Speed;

		A_SetSize(Default.Radius, -1, true);

		if (pos.z <= floorz)
		{
			if (stopmovement) { vel.xy *= 0; }
			SetState(SeeState);
		}
	}
}

// Inventory Items
class CKPogoStick : CustomInventory
{
	bool active, wasactive;
	double moveangle, sidespeed;
	State PogoState;

	Default
	{
		//$Category Commander Keen (BoA)/Items
		//$Title Pogostick
		//$Color 11

		Tag "$TAGPOGO";
		+BRIGHT
		+NOGRAVITY
		Inventory.Icon "CKPOG0";
		Inventory.PickupMessage "$CK_POGO";
		Inventory.MaxAmount 1;
		Inventory.PickupSound "";
		Inventory.RestrictedTo "KeenPlayer";
		+INVENTORY.INVBAR
		+INVENTORY.UNDROPPABLE
	}

	States
	{
		Spawn:
			CKPO G -1;
			Stop;
		Use:
			CKPO G 0
			{
				invoker.active = !invoker.active;
				invoker.speed = 0;
				invoker.sidespeed = 0;
			}
			Fail;
	}

	override bool TryPickup (in out Actor toucher)
	{
		bool ret = Super.TryPickup(toucher);

		if (ret) { ACS_NamedExecute("KeenPogoMessage", 0); }

		return ret;
	}

	override void Tick()
	{
		if (IsFrozen()) { return; }

		if (owner)
		{
			if (owner.health)
			{
				if (active)
				{
					if (
						!owner.player ||
						owner.waterlevel > 1 ||
						owner.health <= 0 ||
						owner.player.cmd.buttons & BT_ATTACK ||
						owner.player.cmd.buttons & BT_ALTATTACK ||
						owner.player.cheats & CF_NOCLIP ||
						InStateSequence(owner.CurState, owner.FindState("Pain"))
					)
					{
						active = false;
						owner.SetState(owner.SpawnState);

						return;
					}

					// Stomp on all other player sounds (land, grunt), since there doesn't seem to be a way to disable them temporarily
					for (int s = 0; s <= 6; s++) { owner.A_StopSound(s); }

					if (owner.player.onground)
					{
						if (!PogoState) { PogoState = owner.FindState("See.Pogo", true); }
						if (PogoState) { owner.SetState(PogoState); }

						owner.A_StartSound("ckeen/pogo", CHAN_7);
						owner.vel.z = 12.0;
						if (owner.player.cmd.buttons & BT_JUMP) { owner.vel.z *= 1.5; }

						sidespeed = 0;

						moveangle = owner.angle;
					}
					else
					{
						moveangle = owner.angle;
					}

					if (owner.player.cmd.buttons & BT_FORWARD) { speed = min(6, speed + 0.25); }
					if (owner.player.cmd.buttons & BT_BACK) { speed = max(-1.5, speed - 0.5); }
					if (owner.player.cmd.buttons & BT_MOVELEFT) { sidespeed = min(3, sidespeed + 0.5); }
					if (owner.player.cmd.buttons & BT_MOVERIGHT) { sidespeed = max(-3, sidespeed - 0.5); }

					owner.vel.xy = RotateVector((speed, sidespeed), moveangle);

					if (!owner.vel.xy.length()) { owner.TryMove(owner.pos.xy, false); } // Make sure we still run collision logic even if there's no x/y axis velocity.
				}
				else if (wasactive)
				{
					owner.SetState(owner.SpawnState);
				}
			}
			else if (active)
			{
				active = false;

				owner.vel *= 0;
			}
		}

		wasactive = active;
	}
}

class CKLedgeGrab : Inventory
{
	bool LedgeGrabbed;
	double LedgeAngle;
	double LedgeHeight;
	int LedgeTime;
	Weapon ReselectWeapon;
	Inventory pogo;

	Default
	{
		Inventory.MaxAmount 1;
		Inventory.PickupSound "";
		+INVENTORY.UNDROPPABLE
	}

	override void Tick()
	{
		if (IsFrozen()) { return; }

		if (owner)
		{
			if (owner.health)
			{
				if (!pogo) { pogo = FindInventory("CKPogoStick"); }

				if (!pogo || !CKPogoStick(pogo).active)
				{
					if (
						(!owner.bOnMobj && owner.pos.z > owner.floorz) ||
						owner.player.jumptics
					)
					{ LedgeGrabInitiator(); }

					if (LedgeGrabbed)
					{
						owner.angle = clamp(owner.angle, LedgeAngle - 20, LedgeAngle + 20);
						LedgeGrab();
					}
				}
			}
		}
	}

	// Ledge grabbing, modified from ZMovement by Ivory Duke (https://forum.zdoom.org/viewtopic.php?f=43&t=65095)
	void LedgeGrabInitiator()
	{
		if (!owner || !owner.player || !PlayerPawn(owner)) { return; }

		//Already ledge grabbing, no clipping, moving away from where you are looking, ceiling already too low for sure
		if(LedgeGrabbed || (owner.player.Cheats & CF_NOCLIP2) || owner.Vel.XY dot AngleToVector(owner.Angle) <= 0 || owner.CeilingZ <= owner.Pos.Z + owner.Height * 1.6f) { return; }

		//Find ledge (if any)
		FLineTraceData LedgeTrace;
		double TraceDistance = sqrt(2) * owner.Radius + 1; //account for the fact that Doom's hitboxes are square
		owner.LineTrace(owner.Angle, TraceDistance, 0, TRF_BLOCKSELF | TRF_THRUACTORS | TRF_BLOCKUSE, owner.Height * 1.2, data: LedgeTrace);
		Vector3 HitPos = LedgeTrace.HitLocation;

		if (LedgeTrace.HitLine) // Hit a blocking line
		{
			// If it's a "BLOCK USE" line, halt here - allows for selective blocking of ledge grabbing ability
			if (LedgeTrace.HitLine.flags & Line.ML_BLOCKUSE) { return; }
		}

		double LedgeCandidate;
		if(LedgeTrace.HitType == TRACE_HitWall) //hit wall scenario
		{
			if(LedgeTrace.Hit3DFloor != NULL) //3D floor
			{
				LedgeCandidate = LedgeTrace.Hit3DFloor.Top.ZAtPoint(HitPos.XY);
			}
			else //regular wall
			{
				Line HitLine = LedgeTrace.HitLine;
				if(HitLine.FrontSector != NULL && HitLine.FrontSector != CurSector)
					LedgeCandidate = HitLine.FrontSector.FloorPlane.ZatPoint(HitPos.XY);
				else if(HitLine.BackSector != NULL && HitLine.BackSector != CurSector)
					LedgeCandidate = HitLine.BackSector.FloorPlane.ZatPoint(HitPos.XY);
			}
		}
		else if(LedgeTrace.HitSector != CurSector)//tracer stopper mid air in a sector that is not the one where player currently is
		{
			LedgeCandidate = LedgeTrace.HitSector.NextLowestFloorAt(HitPos.X, HitPos.Y, HitPos.Z, FFCF_3DRESTRICT, 0);
/*
// Handling for climbing over solid things.  Mostly works, but can be buggy...
			BlockThingsIterator it = BlockThingsIterator.CreateFromPos(HitPos.x, HitPos.y, HitPos.z, -owner.height * 0.8, 1, false);

			while (it.Next())
			{
				if (
					it.thing == owner ||
					it.thing.bIsMonster ||
					PlayerFollower(it.thing) ||
					owner.Vel.XY dot AngleToVector(owner.AngleTo(it.thing)) <= 0
				)
				{ continue; }

				if (it.thing.bSolid)
				{
					double testheight = it.thing.pos.z + it.thing.height;

					if (testheight > LedgeCandidate && testheight > owner.pos.z)
					{
						LedgeCandidate = testheight;
					}
				}
			}
*/
		}
		else
		{
			return;
		}

		//Check if the candidate ledge can suffice
		if (LedgeCandidate > owner.Pos.Z + owner.Height * (PlayerPawn(owner).jumpz / 13.0) && LedgeCandidate <= owner.Pos.Z + owner.Height * (1.0 + PlayerPawn(owner).jumpz / 40))
		{
			Vector3 OrigPos = owner.Pos;
			owner.SetXYZ((owner.Pos.XY, LedgeCandidate));
			if(!owner.CheckMove(owner.Pos.XY + 5.0 * AngleToVector(owner.Angle))) //not enough space, cancel everything :(
			{
				owner.SetXYZ(OrigPos);
				return;
			}
			owner.SetXYZ(OrigPos);
			LedgeHeight = LedgeCandidate;
		}
		else
		{
			return; //too high/low
		}

		//Switch to a weapon that forbids firing during the ledge grab
		ReselectWeapon = owner.player.ReadyWeapon;
		Weapon empty = Weapon(owner.FindInventory("NullWeapon"));
		if (!empty)
		{
			owner.GiveInventory("NullWeapon", 1);
			empty = Weapon(owner.FindInventory("NullWeapon"));
		}
		owner.player.PendingWeapon = empty;

		if (owner.player.ReadyWeapon)
		{
			owner.player.SetPsprite(PSP_WEAPON, owner.player.ReadyWeapon.GetDownState());
		}

		//Allow ledge grab
		owner.A_StopSound(CHAN_WEAPON); 	//stop looping weapon sounds
		LedgeAngle = owner.Angle;
		owner.A_StartSound("Climb", CHAN_BODY);
		LedgeGrabbed = True;
	}

	void LedgeGrab()
	{
		if (!owner ||!owner.player || !PlayerPawn(owner)) { return; }

		LedgeTime++;
		if(owner.Pos.Z >= LedgeHeight || !owner.Vel.Length() || LedgeTime >= 35)
		{
			//End Ledge Grab
			owner.player.PendingWeapon = ReselectWeapon;
			LedgeGrabbed = LedgeHeight = 0;
			LedgeTime = 0;
			//Only if ledge grab was successful
			if(LedgeTime >= 35) { return; }
			owner.Vel = owner.Vel.Length() ? (5.0 * AngleToVector(LedgeAngle), -3.0) : (0, 0, 0); //push player forward and downward
			owner.A_StartSound("*land", CHAN_BODY);
		}
		else
		{
			owner.Vel = owner.Vel.Length() ? (0, 0, 4) : (0, 0, 0);
		}

		//Sprite animation
		PlayerPawn(owner).PlayIdle();
	}
}

class CKThundercloud : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Thundercloud
		//$Color 4

		Speed 2;
		Radius 64;
		Height 32;
		Damage 0;
		MaxTargetRange 32;
		-FLOORCLIP
		+NOGRAVITY
		-SOLID
		+NOTAUTOAIMED
		Obituary "$CK_TCLOUD";

		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKCL A 10 CK_WaitForPlayer(512);
			Loop;
		See:
			CKCL B 50;
		Chase:
			CKCL BBBBB 2 CK_Glide(512);
			Loop;
		Missile:
			CKCL B 40;
			CKCL CBC 10;
			CKCL B 10 A_SpawnItemEx("CKThunderbolt", -1, 0, -120, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
			CKCL CBCB 10;
			CKCL C 24;
			Goto Chase;
	}
}

class CKBounder : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Bounder
		//$Color 4

		Speed 6;
		Radius 18;
		Height 36;
		Damage 0;
		Obituary "$CK_BOUND";
	}

	States
	{
		Spawn:
			CKBB A 1;
		See:
			CKBB AAAAAAAAAABBBBBBBBBB 1 CK_BounderBounce();
			Loop;
		Stunned:
			CKBB C -1;
			Stop;
	}

	// Function to handle Bounder bounce pattern, re-imagined in 3D space
	void CK_BounderBounce()
	{
		PlayerSearch();

		if (!target) { return; }

		bool blocked = BlockingLine;

		if (target)
		{
			if (
				Distance2D(target) > (Radius + target.radius) * 1.4 ||
				target.pos.z < pos.z
			)
			{
				target = null;
				offset = (0, 0, 0);
			}
			else
			{
				offset = target.pos - pos;
				offset.z = max(offset.z, height);
			}
		}

		if (!blocked && BlockingMobj)
		{
			if (BlockingMobj != target) { blocked = true; }
		}

		if (bOnMobj)
		{
			Actor onmo = FindOnMobj(self);
			if (!onmo || onmo == target) { bOnMobj = false; }
		}

		if (pos.z == floorz || blocked || waterlevel || bOnMobj)
		{
			if (pos.z == floorz || waterlevel || bOnMobj)
			{
				counter++;
				A_StartSound("ckeen/madmushroombounce");
				vel.z = 12.0;
			}

			if (target)
			{
				counter = 0;

				angle = target.angle;

				double scale = 1.0 - (abs(target.pitch) / 90);
				scale *= 0.75;
				scale -= 0.25;

				vel.xy = RotateVector((Speed * 1.5 * scale, 0), angle);

				if (!CheckMove(pos.xy + vel.xy))
				{
					vel.xy *= 0;
				}
			}
			else if (counter > 2 && counter2)
			{
				counter2 = 0;

				if (Random() < 200)
				{
					angle = Random(0, 359);
					vel.xy = RotateVector((Speed, 0), angle);
				}
			}
			else
			{
				counter2 = 1;
				vel.xy *= 0;
			}
		}

		if (
			target &&
			(target.player && target.player.jumptics == 0) &&
			offset != (0, 0, 0)
		)
		{
			if (target.TryMove(pos.xy + offset.xy, false))
			{
				target.SetOrigin(pos + (vel.xy, vel.z * gravity) + offset, true);
			}
		}

		bNoBlockMonst = !!(target && target is "PlayerPawn"); // Allow them to pass through monster blocking lines if a player is riding...
	}

	// Let the player 'use' the bounder in order to get on top instead of just jumping on top.
	override bool Used(Actor user)
	{
		if (user.player && (!target || target != user))
		{
			user.SetOrigin(pos + (0, 0, height), true);
			target = user;

			return true;
		}

		return false;
	}
}

class CKFoot : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Foot (secret access)
		//$Color 3

		Radius 32;
		Height 64;
		Damage 0;
		+FRIENDLY
		+NOGRAVITY
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKFT A -1;
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		Spawn("CKFootSmoke", pos + (Random(0, 32), 0, Random(0, 32)));
		Spawn("CKFootSmoke", pos + (-Random(0, 32), 0, Random(0, 32)));
		Spawn("CKFootSmoke", pos + (0, Random(0, 32), Random(0, 32)));
		Spawn("CKFootSmoke", pos + (0, -Random(0, 32), Random(0, 32)));
	}
}

class CKFootSmoke : Actor
{
	Default
	{
		Scale 2.0;
		+NOINTERACTION
	}

	States
	{
		Spawn:
			CKGN GHIJ 6;
			Stop;
	}
}

class CKBerkeloid : CKBaseEnemy
{
	double vspeed;
	int floatdir, zdir, turncounter;

	Property VSpeed:vspeed;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Berkeloid
		//$Color 4

		Speed 4;
		Radius 15;
		Height 43;
		Renderstyle "Add";
		Alpha 0.95;
		+BRIGHT
		+NODROPOFF
		+VISIBILITYPULSE
		-CASTSPRITESHADOW
		Obituary "$CK_BERKELOID";
		CKBaseEnemy.StunTime 0;
		CKBerkeloid.VSpeed 1.0;
	}

	States
	{
		Spawn:
			CKFF A 1;
		See:
			CKFF AAABBBCCCDDD 1 CK_BerkeloidMove();
			Loop;
		Attack:
			CKFF E 15;
			CKFF E 3 CK_BerkeloidAttack();
			CKFF F 15;
			CKFF A 2;
			Goto See;
	}

	override void PostBeginPlay()
	{
		floatdir = 1;
		if (pos.z - floorz < 26.0) { SetOrigin((pos.xy, floorz + 26.0), true); }

		Super.PostBeginPlay();
	}

	void CK_BerkeloidMove()
	{
		PlayerSearch();

		if (!target) { return; }

		if (Random() < 10)
		{
			A_Face(target);
			turncounter = 35;
		}

		if (Random() < 2) { SetState(AttackState); }
		else if (Random() < 20 && Distance3D(target) < 256) { SetState(AttackState); }

		bool blocked = BlockingLine || BlockingMobj || !CheckMove(pos.xy + RotateVector((Speed, 0), angle), PCM_DROPOFF | PCM_NOLINES);

		if (blocked)
		{
			angle += Random(-115, -245);
			turncounter = 35;
		}

		vel.xy = RotateVector((Speed, 0), angle);
	}

	void CK_BerkeloidAttack()
	{
		vel.xy *= 0;

		A_SpawnProjectile("CKBerkeloidBall", flags:CMF_AIMDIRECTION);

		A_StartSound("ckeen/berkeloid/attack");
	}

	void DoFloat()
	{
		if (counter++ > 24)
		{
			counter = 0;
			floatdir *= -1;
		}

		if (waterlevel) { floatdir = 1; }
		if (pos.z - floorz > 50) { floatdir = -1; }

		vel.z = vspeed * floatdir;
	}

	override void Tick()
	{
		if (turncounter > 0) { turncounter--; }

		DoFloat();

		Super.Tick();
	}
}

class CKBerkeloidBall : Actor
{
	Default
	{
		Projectile;
		Radius 6;
		Height 12;
		Speed 24;
		-NOGRAVITY
	}

	States
	{
		Spawn:
			CKFF HI 3;
			Loop;
		Death:
			CKFF HJKJKHIHI 6 A_Explode(15, 32);
			Stop;
	}
}

class CKSkyPest : CKBaseEnemy
{
	int turncounter, zdir, zheightcounter;

	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title SkyPest
		//$Color 4

		Speed 10;
		FloatSpeed 5;
		Radius 12;
		Height 9;
		+NOGRAVITY
		+NODROPOFF
		+NOTAUTOAIMED
		Obituary "$CK_SKYPEST";
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKFL H 1;
		See:
			CKFL HH 1 CK_SkyPestFly();
			CKFL III 1 CK_SkyPestFly();
			Loop;
		Preen:
			CKFL A 50 { SetDamage(0); }
			CKFL BCDKDCB 5;
			CKFL A 30;
			CKFL GFEJEFG 5;
			CKFL A 50;
			CKFL A 1
			{
				zdir = 1;
				zheightcounter = 35;
				angle = Random(0, 359);
				vel.z = 8.0;
			}
			Goto See;
		Death:
			CKFL L -1 { SetDamage(0); }
			Stop;
	}

	override void PostBeginPlay()
	{
		zdir = RandomPick(-1, 1);

		Super.PostBeginPlay();
	}

	void CK_SkyPestFly()
	{
		SetDamage(Default.Damage);

		bool blocked = BlockingLine || !CheckMove(pos.xy + vel.xy, PCM_NOACTORS);

		if (waterlevel) // Keep them above water!
		{
			zdir = 1;
			zheightcounter = 75;
		}
		else if (!zheightcounter || pos.z == floorz || pos.z + height == ceilingz)
		{
			zdir *= -1;
			zheightcounter = 70 - zdir;
		}

		if (blocked || !turncounter)
		{
			angle += RandomPick(-90, 90, 180);
			turncounter = 20;
		}

		if (pos.z > floorz)
		{
			vel.xy = RotateVector((Speed, 0), angle);
			vel.z = FloatSpeed * zdir;
		}
		else
		{
			vel *= 0;

			SetOrigin((pos.xy, floorz), true);

			SetStateLabel("Preen");
		}
	}

	override void Tick()
	{
		if (turncounter > 0) { turncounter--; }
		if (zheightcounter > 0) { zheightcounter--; }

		Super.Tick();
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (pos.z == floorz && other.player && other.FindInventory("CKPogoStick"))
		{
			let p = CKPogoStick(other.FindInventory("CKPogoStick"));

			if (p.active)
			{
				SetStateLabel("Death");
				return false;
			}
		}

		return Super.CanCollideWith(other, passive);
	}

}

class CKSpearDown : CKBaseEnemy
{
	int dir;
	int user_delay;

	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Spears (Down)
		//$Color 3

		Damage 0;
		Radius 8;
		Height 0;
		-CASTSPRITESHADOW
		+NOGRAVITY
		+NOTAUTOAIMED
		-COUNTKILL
		-SHOOTABLE
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKSH A 10 CK_WaitForPlayer(128);
			Loop;
		See:
			CKSH A 60;
			CKSH A 1
			{
				tics = user_delay;
				user_delay = 0;
			}
		Thrust:
			CKSH C 1 CK_SpearThrust();
			Loop;
	}

	override void PostBeginPlay()
	{
		dir = -1;

		Super.PostBeginPlay();
	}

	virtual void CK_SpearThrust()
	{
		SetDamage(15);

		if (dir > 0 && counter - 8 > 0)
		{
			counter -= 8;
		}
		else if (dir < 0 && counter + 8 < 80)
		{
			counter += 8;
		}
		else
		{
			dir *= -1;
		}

		if (counter <= 0) { frame = 0; }
		else if (counter < 24) { frame = 1; }
		else { frame = 2; }


		if (counter <= 8 && dir == 1)
		{
			counter = 0;

			SetState(SeeState);
			SetDamage(0);
		}

		A_SetSize(Radius, counter);
		SetOrigin((pos.xy, SpawnPoint.z - height), true);
	}

	override void Activate(Actor activator)
	{
		SetState(SeeState);

		Super.Activate(activator);
	}

}

class CKSpearUp : CKSpearDown
{
	Default
	{
		//$Title Spears (Up)
	}

	States
	{
		Spawn:
			CKSH D 10 CK_WaitForPlayer(128);
			Loop;
		See:
			CKSH D 60;
			CKSH D 1
			{
				tics = user_delay;
				user_delay = 0;
			}
		Thrust:
			CKSH F 1 CK_SpearThrust();
			Loop;
	}

	override void PostBeginPlay()
	{
		dir = -1;

		Super.PostBeginPlay();
	}

	override void CK_SpearThrust()
	{
		SetDamage(15);

		if (dir > 0 && counter - 8 > 0)
		{
			counter -= 8;
		}
		else if (dir < 0 && counter + 8 < 56)
		{
			counter += 8;
		}
		else
		{
			dir *= -1;
		}

		if (counter <= 0) { frame = 3; }
		else if (counter < 16) { frame = 4; }
		else { frame = 5; }

		if (counter <= 8 && dir == 1)
		{
			counter = 0;

			SetState(SeeState);
			SetDamage(0);
		}

		SetOrigin((pos.xy, SpawnPoint.z + counter), true);
	}
}

class CKSpear : CKSpearUp
{
	Default
	{
		//$Title Spears (Pitched)
		+NOCLIP
		-SOLID
		+WALLSPRITE
		+ROLLSPRITE
	}

	override void CK_SpearThrust()
	{
		SetDamage(15);
		bSolid = true;

		if (dir > 0 && counter - 8 > 0)
		{
			counter -= 8;
		}
		else if (dir < 0 && counter + 8 < 72)
		{
			counter += 8;
		}
		else
		{
			dir *= -1;
		}

		if (counter <= 0) { frame = 3; }
		else if (counter < 40) { frame = 4; }
		else { frame = 5; }

		if (counter <= 8 && dir == 1)
		{
			counter = 0;
			bSolid = false;

			SetState(SeeState);
			SetDamage(0);
		}

		SetOrigin((SpawnPoint.xy + RotateVector((counter * sin(roll), 0), angle + 90), SpawnPoint.z + counter * cos(roll)), true);
	}

	override void PostBeginPlay()
	{
		if (pitch == 90 || pitch == 270) { bWallSprite = false; }

		if (pos.z == ceilingz) { SetOrigin((pos.xy, pos.z - 7), true); }

		angle -= 90;
		roll = pitch + 90;
		pitch = 0;

		Super.PostBeginPlay();
	}
}

class CKConfusion : Actor
{
	int ticker;

	Default
	{
		Radius 1;
		Height 1;
		RenderStyle "Translucent";
		Scale 2.0;
		+NOGRAVITY
		-SOLID
	}

	States
	{
		Spawn:
			CKCF ABC 10;
			Loop;
	}

	override void Tick()
	{
		if (master)
		{
			if (pos != master.pos) { SetXYZ(master.pos); }

			ticker++;

			if (ticker > 175) { alpha -= 0.01; }
		}

		Super.Tick();
	}
}

class CKStunnerBall : Actor
{
	Actor confusion;

	Default
	{
		Radius 11;
		Height 8;
		Speed 20;
		Damage 20;
		DamageType "KeenStunner";
		Projectile;
		+BRIGHT
		+NOEXTREMEDEATH
		+HITMASTER
		SeeSound "ckeen/shoot";
		DeathSound "ckeen/hit";
		Obituary "$OB_CKBLAST";
	}

	States
	{
		Spawn:
			CKBA ABCD 3 { if (waterlevel > 2) { SetStateLabel("Death"); } }
			Loop;
		Death:
			CKBA EF 4;
			TNT1 A 35 { vel *= 0; }
			Stop;
	}

	override void Tick()
	{
		if (!confusion && master && master.bIsMonster && master.health <= 0)
		{
			confusion = Spawn("CKConfusion", master.pos);
			confusion.master = master;
		}

		Super.Tick();
	}
}

class CKWallShooter : SwitchableDecoration
{
	int user_fireoffset; // Number of tics to offset firing pattern from other Wall Shooters

	Default
	{
		//$Category Commander Keen (BoA)/Special
		//$Title Wall Shooter (3D)
		//$Color 4

		+NOGRAVITY
		+WALLSPRITE
		+NODAMAGE
		+DONTTHRUST
		-SOLID
		Radius 1;
		Height 0;
		Obituary "$CK_WALSH";
	}

	States
	{
		Spawn:
		Active:
			MDLA A 10 CK_WaitForPlayer(1024); // Don't fire until a player is around...
			Loop;
		See:
			MDLA A 1
			{
				// Synchronize all wall shooters
				if (level.time % (70 + user_fireoffset) == 0) { A_SpawnProjectile("CKWallShooterArrow", 0, 0, 0, CMF_AIMDIRECTION | CMF_SAVEPITCH, pitch); }

				if (target && !IsVisible(target, true) && Distance2D(target) > 1024)
				{
					target = null;
					SetState(SpawnState);
				}
			}
			Loop;
		Inactive:
			MDLA A 1;
			Loop;
	}

	void CK_WaitForPlayer(int dist = 256)
	{
		if (!target) { LookForPlayers(true); }

		if (target && Distance2D(target) < dist)
		{
			SetState(SeeState);
		}
	}
}

class CKWallShooterArrow : Actor
{
	Default
	{
		PROJECTILE;
		+WALLSPRITE
		+ROLLSPRITE
		+NOCLIP
		Radius 8;
		Height 8;
		Damage 16;
		Speed 16;
		Seesound "ckeen/blowgun";
		Deathsound "ckeen/klick";
	}

	States
	{
		Spawn:
			CKAR F 2 NODELAY A_StartSound(SeeSound);
			CKAR F 0 { bNoClip = false; } // Only NoClip for first few ticks to make sure these can fire when placed against walls
			CKAR EF 8;
			Loop;
		Death:
			TNT1 A 0;
			Stop;
	}

	override void PostBeginPlay()
	{
		// If fired straight up or down, always face the player for visibility purposes
		if (pitch == 90 || pitch == 270)
		{
			bWallSprite = false;
			pitch -= 180;
		}

		// Adjust for WallSprite offset and to change firing pitch to sprite roll amount
		angle -= 90;
		roll = pitch;
		pitch = 0;

		Super.PostBeginPlay();
	}
}

class CKStunner : CKWeapon
{
	Default
	{
		//$Title (2) Neural Stunner
		Radius 16;
		Height 26;
		Weapon.SelectionOrder 9998;
		Weapon.AmmoType "CKStunnerAmmo";
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 5;
		Weapon.UpSound "ckeen/flag";
		Tag "$TAGNEURS";
		Inventory.PickupMessage "$CKNEUS";
		Inventory.Pickupsound "ckeen/gun";
		+WEAPON.NOAUTOFIRE
	}

	States
	{
		Ready:
			CKBF A 1 A_WeaponReady(WRF_NOSWITCH);
			Loop;
		Select:
			CKBF A 1 A_Raise();
			Loop;
		Deselect:
			CKBF A 1 A_LowerEx();
			Loop;
		Fire:
			CKBF B 2;
			CKBF C 2 A_FireProjectile ("CKStunnerBall");
			CKBF D 1;
			Goto Ready;
		Spawn:
			CKBL AB 5;
			Loop;
		Pickup:
			CKBL C -1 BRIGHT;
			Stop;
	}

	// Morph-friendly variant of A_Lower
	action void A_LowerEx(int lowerspeed = 6)
	{
		let player = player;

		if (null == player)
		{
			return;
		}
		if (null == player.ReadyWeapon)
		{
			player.mo.BringUpWeapon();
			return;
		}
		let psp = player.GetPSprite(PSP_WEAPON);
		if (!psp) return;
		if (player.cheats & CF_INSTANTWEAPSWITCH)
		{
			psp.y = WEAPONBOTTOM;
		}
		else
		{
			psp.y += lowerspeed;
		}
		if (psp.y < WEAPONBOTTOM)
		{ // Not lowered all the way yet
			return;
		}
		if (player.playerstate == PST_DEAD)
		{ // Player is dead, so don't bring up a pending weapon
			// Player is dead, so keep the weapon off screen
			player.SetPsprite(PSP_FLASH, null);
			psp.SetState(player.ReadyWeapon.FindState('DeadLowered'));
			return;
		}
		// [RH] Clear the flash state. Only needed for Strife.
		player.SetPsprite(PSP_FLASH, null);
		player.mo.BringUpWeapon ();
		return;
	}
}