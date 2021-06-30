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
**/

/*

  Base class for BoA Weapons

*/
class NaziWeapon : Weapon
{
	int lowertimeout;
	float lowerstart, lowerspeed;
	double modifier;
	uint oldbuttons;
	bool reloading; // Weapon is reloading
	int flags;
	Class<Inventory> ammoitem;

	Property AmmoInventoryType:ammoitem;
	FlagDef NORAMPAGE:flags, 0;

	Default
	{
		+WEAPON.AMMO_CHECKBOTH
		+WEAPON.NOALERT
		+WEAPON.NOAUTOAIM
		Weapon.BobStyle "InverseSmooth";
		Weapon.BobSpeed 2.2;
		Weapon.BobRangeY 1.0;
		Weapon.BobRangeX 1.25;
	}

	States
	{
		Dryfire:
			"####" "#" 1 A_JumpIf(CVar.FindCVar("boa_autoreload").GetInt() == 1,"Reload");
			"####" "#" 1 Offset(0,35) A_StartSound("weapon/dryfire", CHAN_WEAPON);
			"####" "#" 9 Offset(0,34);
			"####" "#" 0 A_Jump(256,"Ready");
			Stop;
		KickOverlay:
			TNT1 A 1 FindPest(); // Note:  Overlay offset y values are 32 less than their Weapon state counterparts
			BJKK A 1 Offset(84, 68);
			BJKK A 1 Offset(72, 56);
			BJKK A 1 Offset(56, 40);
			BJKK A 1 Offset(40, 24);
			BJKK A 1 Offset(24, 7);
			BJKK A 1 Offset(6, 2) A_StartSound("knife/swing",CHAN_WEAPON);
			BJKK B 2 Offset(4, 0) A_CustomPunch(int(8 * invoker.modifier), TRUE, CPF_NOTURN, "KickPuff", invoker.modifier ? 80 : 70); //CPF_NOTURN is added in order to avoid 3d actors to turn towards us like if they are autoaimed - I want to destroy a tank with kicks!
			BJKK A 1 Offset(6, 2) { bDontBlast = true; }
			BJKK A 1 Offset(24, 7) { bDontBlast = false; } //KickPuff blast happens 3 tics after spawning
			BJKK A 1 Offset(36, 20);
			BJKK A 1 Offset(44, 28);
			BJKK A 1 Offset(52, 36);
			BJKK A 1 Offset(60, 44);
			BJKK A 1 Offset(68, 52);
			BJKK A 1 Offset(76, 60);
			BJKK A 1 Offset(82, 66);
			Stop;
	}

	override void PostBeginPlay()
	{
		// Allow the drop amount of the weapon to set the amount of primary ammunition that is in a pickup
		// Default drop amount value is 1, and is interpreted as normal drop amount handling...
		if (Amount > 1)
		{
			// Take skill ammo drop amounts into account when calculating amount of ammo to give
			float dropammofactor = G_SkillPropertyFloat(SKILLP_DropAmmoFactor);
			if (dropammofactor == -1) { dropammofactor = 0.5; }

			// Default to affecting AmmoType1, with fallback to AmmoType2 if the
			//  weapon does not give any of AmmoType1 (Nazis weapons use AmmoType1
			//  as the current clip's amount, and give only to AmmoType2 normally.
			if (AmmoGive1 > 0) { AmmoGive1 = int(Amount * dropammofactor); }
			else if (AmmoGive2 > 0) { AmmoGive2 = int(Amount * dropammofactor); }

			Amount = 1;
		}

		modifier = 1.0;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (owner && owner.player)
		{
			if (owner.player.ReadyWeapon == self)
			{
				let psp = owner.player.GetPSprite(PSP_WEAPON);
				let kick = owner.player.FindPSprite(-10);

				if (owner.FindInventory("HQ_Checker", true))
				{
					lowertimeout++;

					let downstate = GetDownState();

					if (psp && psp.CurState)
					{
						if (psp.CurState.InStateSequence(GetUpState()) || lowertimeout < 35) { return; }
						else if (!psp.CurState.InStateSequence(downstate))
						{
							owner.player.SetPsprite(PSP_WEAPON, downstate);
							lowerstart = psp.y;
						}
						else
						{
							if (!lowerspeed) { lowerspeed = psp.y - lowerstart; }	

							if (psp.y >= WEAPONBOTTOM - lowerspeed)
							{
								owner.player.ReadyWeapon = null;
								owner.player.PendingWeapon = WP_NOCHANGE;
								lowertimeout = 0;
							}
						}
					}
				}
/* Handled via ACS and player class static function for integration with the old kick code rather than using a built-in keybind
				else if (owner.player.cmd.buttons & BT_USER1 && !(oldbuttons & BT_USER1)) // Only kick on fresh button presses
				{
					Inventory st = owner.FindInventory("Stamina");

					if (st && st.Amount > 29)
					{
						if (!kick)
						{
							if (owner.FindInventory("PowerStrength")) { modifier = 3.0; } // Strength increases damage by 3 and range by 10

							owner.A_TakeInventory("Stamina",30);
							owner.player.SetPsprite(-10, FindState("KickOverlay"), true);
						}
					}
				}
*/

				if (kick)
				{
					if (owner.FindInventory("CCBJUniformToken")) { kick.frame += 2; }
					else if (owner.FindInventory("SSBJUniformToken")) { kick.frame += 4; }
				}

				oldbuttons = owner.player.cmd.buttons;

				// If you're using the knife and there's a chance of a stealth kill, hide 
				// the crosshair so that the status bar code can draw the overlay knife icon.
				if (self is "KnifeSilent")
				{
					BoAPlayer p = BoAPlayer(owner);

					if (
						p && 
						Nazi(p.crosshairtarget) && 
						!Nazi(p.crosshairtarget).user_incombat &&
						!(p.crosshairtarget is "WGuard_Wounded") && //this gave away wounded guards
						p.Distance2D(p.crosshairtarget) < p.crosshairtarget.radius + 64.0
					)
					{
						crosshair = 99;
					}
				}
			}
		}

		Super.Tick();
	}

	override bool TryPickup (in out Actor toucher)
	{
		bool ret = Super.TryPickup(toucher);

		if (ret && toucher && toucher.player)
		{
			AchievementTracker achievements = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
			if (achievements)
			{
				for (int w = 0; w < achievements.weaponlist.Size(); w++)
				{
					if (achievements.weaponlist[w] == GetClass())
					{
						achievements.weapons[toucher.PlayerNumber()][w] = true;
						AchievementTracker.CheckAchievement(toucher.PlayerNumber(), AchievementTracker.ACH_FULLARSENAL);

						break;
					}
				}
			}
		}

		return ret;
	}

	action void A_SpawnLightning(Class<LightningBeam> beam = "LightningBeam")
	{
		let p = player.mo;

		double posdist = max(4, cos(p.pitch) * p.radius);
		if (p.pitch > 0) { posdist = -p.radius + posdist; } // Adjust beam origin for downward view pitch (otherwise beam spawns "in front of" the player weapon)

		double posheight = player.viewheight * 0.8;

		Actor b = Spawn(beam, pos + (RotateVector((posdist, 0), angle), posheight));
		if (b)
		{
			b.master = p;
			b.pitch = p.pitch;
			b.angle = p.angle;
		}
	}

	action void FindPest()
	{
		let p = player.mo;

		BlockThingsIterator it = BlockThingsIterator.Create(self, p.radius * 1.4);

		Actor closest;

		while (it.Next())
		{
			if (Base(it.thing) && Base(it.thing).bCanSquish)
			{
				if (!it.thing.bShootable || it.thing.health <= 0) { continue; }
				if (it.thing.pos.z != floorz) { continue; }
				if (absangle(p.angle, AngleTo(it.thing)) > 60) { continue; }
				if (closest && Distance3D(closest) < Distance3D(it.thing)) { continue; }

				closest = it.thing;
			}
		}

		if (closest)
		{
			p.A_SetAngle(AngleTo(closest), SPF_INTERPOLATE);
			p.A_Face(closest, -1, 90, 0, 0, FAF_BOTTOM);
		}
	}

	action void A_Reloading(bool r = true)
	{
		invoker.reloading = r;
		// Clear firing state, so the player can cancel the reload if the reload
		// was started automatically via the DryFire state
		if (r && invoker.Owner.player) {
			invoker.Owner.player.WeaponState &= ~(WF_WEAPONREADY | WF_WEAPONREADYALT);

			AchievementTracker tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
			if (tracker) { tracker.reloads[invoker.owner.PlayerNumber()]++; }
		}
	}

	action state A_JumpIfReloading(StateLabel st)
	{
		if (invoker.reloading)
		{
			return A_Jump(256, st);
		}
		return null;
	}
}

class NullWeapon : NaziWeapon
{
	Default
	{
		+INVENTORY.UNCLEARABLE
		+INVENTORY.UNDROPPABLE
		+WEAPON.NOALERT
		Weapon.SelectionOrder 99999; // Make this absolutely last in weapon priority
		Tag "$TAGCLOAK";
		+NaziWeapon.NORAMPAGE
	}

	States
	{
		Select:
			TNT1 A 1 A_Raise;
			Loop;
		Deselect:
			TNT1 A 1 A_Lower;
			Loop;
		Fire:
		Ready:
			TNT1 A 1 A_WeaponReady(WRF_NOFIRE);
			Loop;
	}
}

// The astrostein weapons have altfires that should use primary (loaded) ammo
class NaziAstroWeapon : NaziWeapon {
	Default
	{
		//$Category Astrostein (BoA)/Weapons
		//$Color 14
		Scale 0.50;
		+WEAPON.CHEATNOTWEAPON
	}

	// DryFire state definition removed because it was the same as the DryFire state for NaziWeapon

	// Astrostein weapons use primary ammo for both fire modes.
	override bool CheckAmmo (int firemode, bool autoSwitch, bool requireAmmo, int ammocount) {
		// True if player has loaded ammo, or ammo in the stockpile.
		// For the shocker, or if player has infinite ammo powerup.
		if (bAmmo_Optional || Owner.FindInventory("PowerInfiniteAmmo", true)) return true;
		// Make sure player has either loaded ammo, or ammo in the stockpile.
		if (AmmoType1 && AmmoType2 && !Owner.FindInventory(AmmoType1) && !Owner.FindInventory(AmmoType2)) return false;
		return Super.CheckAmmo(firemode, autoSwitch, requireAmmo, ammocount);
	}

	override bool DepleteAmmo (bool altfire, bool checkEnough, int ammouse) {
		if (AmmoUse1 == 0 || Owner.FindInventory("PowerInfiniteAmmo", true)) return true;

		bool requireAmmo = AmmoUse1 > 0 || AmmoUse2 > 0 || !bAmmo_Optional;

		if (checkEnough) {
			if (CheckAmmo(PrimaryFire, true, requireAmmo, ammouse)) {
				if (AmmoType1) {
					Ammo magAmmo = Ammo(Owner.FindInventory(AmmoType1));
					if (magAmmo) {
						magAmmo.amount -= AmmoUse1;
						return true;
					}
				}
			}
		}
		return false;
	}
}

class TankCannonWeapon : NaziWeapon // Weapon used when morphed into a tank. 
{
	int cannontimeout;
	int prevtimeout; // Cannon fire time is random now, so keep track of the previous cannon timeout.

	Default
	{
		Weapon.SelectionOrder 1;
	}

	States
	{
		Ready:
			TNT1 A 1 A_TankRefire();
			Loop;
		Select:
			TNT1 A 1 A_Raise;
			Loop;
		Deselect:
			TNT1 A 1 A_Lower;
			Loop;
		//real Fire and Altfire moved to subclasses, these two states are necessary for weapon syntax
		Fire:
			TNT1 A 2 { Console.Printf("Base TankCannonWeapon fire state call, please report this error"); }
			TNT1 A 0 A_TankRefire();
			Goto Ready;
		
		Spawn:
			UNKN A -1;
			Loop;
	}

	action void A_TankReFire(statelabel flash = null)
	{
		let player = self.player;

		if (!player) { return; }

		if ((player.cmd.buttons & BT_ATTACK) && player.health > 0 && !player.refire) 
		{
			player.refire++;
			player.mo.FireWeapon(ResolveState(flash));
		}
		else if ((player.cmd.buttons & BT_ALTATTACK) && player.health > 0)
		{
			if (player.mo is "TankPlayer") { TankPlayer(player.mo).altrefire++; }
			else { player.refire++; }
			player.mo.FireWeaponAlt(ResolveState(flash));
		}
		else
		{
			if (player.mo is "TankPlayer") { TankPlayer(player.mo).altrefire = 0; }
			else { player.refire = 0; }
		}
	}

	override void Tick()
	{
		Super.Tick();

		if (cannontimeout > 0)
		{
			if (owner)
			{
				if (cannontimeout == prevtimeout)
				{
					owner.A_StartSound("tank/breech/open", CHAN_6, 0, 12.0);
				}
				else if (cannontimeout == 105)
				{
					owner.A_StartSound("tank/shellcasing", CHAN_6, 0, 12.0, ATTN_NORM, FRandom(0.7, 1.0));
				}
				else if (cannontimeout == 35)
				{
					owner.A_StartSound("tank/breech/close", CHAN_6, 0, 12.0);
				}
			}

			cannontimeout--;
		}
		else if (owner && owner.player && !(owner.player.cmd.buttons & BT_ATTACK)) { owner.player.refire = 0; }
	}

	//to modders: you can use this or add your own custom action functions for attacks
	action void DoCannon(string sound = "tanks/75mmm3", class<Actor> missiletype = "TankMissile", int reloadtime = 130, class<Actor> flashtype = "NebNukeHarmless")
	{
		if (invoker.cannontimeout)  { return; }

		Actor origin = self;
		if (origin && TankPlayer(origin) && TankPlayer(origin).turret && TankPlayer(origin).turret.gunspot) { origin = TankPlayer(origin).turret.gunspot; }

		double angledelta = deltaangle(angle, origin.angle);
		double pitchdelta = deltaangle(pitch, origin.pitch);

		A_GunFlash();
		Actor muzzleflash = Spawn(flashtype, origin.Pos, ALLOW_REPLACE);
		A_StartSound(sound, CHAN_WEAPON);
		Actor mo = A_FireProjectile(missiletype, angledelta, False, 0, 0, FPF_NOAUTOAIM, pitchdelta);
		if (mo && origin != self)
		{
			muzzleflash.vel += (mo.vel.x / 2.0, mo.vel.y / 2.0, mo.vel.z / 2.0);
			if (self)
			{
				muzzleflash.vel += self.vel;
				mo.vel += self.vel;
			}
			mo.SetOrigin(origin.pos, false); // Move the missile so that it flies from the model's gun
		}

		invoker.prevtimeout = random(int(reloadtime * 0.9), int(reloadtime * 1.1));
		invoker.cannontimeout = invoker.prevtimeout;
	}

	action void DoMachineGun(string sound, class<Actor> missiletype)
	{
		Actor origin = self;
		Actor maingun = self;

		if (origin && TankPlayer(origin) && TankPlayer(origin).turret)
		{
			if (TankPlayer(self).turret.gunspot2) { origin = TankPlayer(self).turret.gunspot2; }
			if (TankPlayer(self).turret.gunspot) { maingun = TankPlayer(self).turret.gunspot; }
		}

		double angledelta = deltaangle(angle, maingun.angle);
		double pitchdelta = deltaangle(pitch, maingun.pitch);

		A_StartSound(sound, CHAN_WEAPON, 0, FRandom(0.6, 0.8));
		Actor muzzleflash = Spawn("KTFlare", origin.Pos, ALLOW_REPLACE);
		if (muzzleflash)
		{
			muzzleflash.master = origin;
		}
		A_FireProjectile("TurrSmokeSpawner", origin.Pos.Z - Pos.Z);
		Actor mo = A_FireProjectile(missiletype, angledelta + Random(-2, 2), False, origin.pos.x - pos.x, origin.pos.z - pos.z, 0, pitchdelta + Random(-2, 2));
		if (mo && origin != self)
		{
			mo.SetOrigin(origin.pos, false); // Move the tracer so that it flies from the model's gun
			if (self) { mo.vel += self.vel; }
			mo.bMThruSpecies = true;
		}
	}
}

class Cannon75mm: TankCannonWeapon
{
	States
	{
		Fire:
			TNT1 A 2 { DoCannon("tanks/75mmm3"); A_Quake(4, 11, 0, 384); }
			TNT1 A 0 A_TankRefire();
			Goto Ready;
		AltFire:
			TNT1 A 6 DoMachineGun("tank/50cal", "Kar98kTracer");
			TNT1 A 20 A_TankRefire();
			Goto Ready;
	}
}

class Cannon75mmKwK: TankCannonWeapon // Pz. Kpfw. IV
{
	States
	{
		Fire:
			TNT1 A 2 { DoCannon("tanks/75mmkwk40"); A_Quake(4, 11, 0, 256); }
			TNT1 A 0 A_TankRefire();
			Goto Ready;
		AltFire:
			TNT1 A 3 DoMachineGun("chaingun/fire", "ChaingunTracer");
			TNT1 A 20 A_TankRefire();
			Goto Ready;
	}
}

class TankRocket : GrenadeBase
{
	Default
	{
		Radius 5;
		Height 6;
		Speed 70;
		Projectile;
		-NOTELEPORT
		+WINDTHRUST
		+THRUGHOST
		Damage (500);
		DamageType "Rocket";
		Decal "Scorch";
		Obituary "$TANKSHELL";
		ProjectileKickback 25000;
		GrenadeBase.SplashType "Missile";
	}

	States
	{
		Spawn:
			TNT1 A 2;
		SpawnLoop:
			MNSS A 1 Bright Light("BOAFLMW2") A_StartSound("panzer/fly", CHAN_VOICE, CHANF_LOOPING, 1.0);
			MNSS A 1 Bright Light("BOAFLMW2") A_SpawnItemEx("RocketFlame", random(-1,1), 0, random(-1,1));
			Wait;
		Death:
			EXP1 A 0 A_SpawnGroundSplash;
			EXP1 A 0 A_SetScale(0.75, 0.75);
			EXP1 A 0 A_StopSound(CHAN_VOICE);
			EXP1 A 0 A_StartSound("panzer/explode", CHAN_VOICE, 0, 1.0, ATTN_NORM);
			EXP1 A 0 { A_Explode(0, 192, 0, TRUE, 320); A_SpawnItemEx("ZScorch"); }
			TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("TracerSpark_Longlive", 0, 0, 0, random(-5,5), random(-5,5), random(-5,5), random(0,359)); //T667 improvements
			TNT1 A 0 A_SpawnItemEx("PanzerNuke", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
			TNT1 A 8 {
				Actor ex = Spawn("GeneralExplosion_Large", pos + (RotateVector((56, 0), angle), 32));
				if (ex)
				{
					ex.target = target;
					ex.damagetype = damagetype;
				}
			}
			EXP1 A 2 Bright Light("BOAFLMW2") A_Quake(9, 15, 0, 1024, "");
			EXP1 BCDEFGHIJKLMN 2 Bright Light("BOAFLMW2");
			Stop;
	}

	// Handling so that rockets won't hit actors that have the rocket's origin actor set as their master (or inherit from one that does)
	override bool CanCollideWith(Actor other, bool passive)
	{
		if (target)
		{
			Actor roottarget = target;
			Actor rootmaster = other;
			while (roottarget.master) { roottarget = roottarget.master; }
			while (rootmaster.master) { rootmaster = rootmaster.master; }

			if (roottarget && roottarget == rootmaster) { return false; }
		}
		return true;
	}
}

class TankMissile : TankRocket
{
	Default
	{
		-NOGRAVITY
		Gravity 0.33;
	}

	States
	{
		Spawn:
			TNT1 A 2;
		SpawnLoop:
			MNSS A 1 Bright Light("BOAFLMW2") A_StartSound("panzer/fly", CHAN_VOICE, CHANF_LOOPING, 1.0);
			MNSS A 1 Bright Light("BOAFLMW2"); //no flames, it is a regular projectile
			Wait;
	}
}

class TurretSwivel : ActorPositionable
{
	Default
	{
		Height 2;
		Radius 2;
		+NOBLOCKMAP;
		+NOGRAVITY;
		+NOINTERACTION
		+THRUSPECIES
		Species "Turret";
	}

	States
	{
		Spawn:
			 MDLA A -1;
		Stop;
	}
}

class TurretGun : ActorPositionable
{
	Actor swivel, light, light2, light3;
	TurretOverheatSmokeSpawner smokefx;
	int shotcount;
	int maxshotcount;
	int cooldowntime, cooldowntimeout, heatlevel, heatthreshold;
	string ammoGraphic;

	Property MaxShotCount:maxshotcount;
	Property TemperatureThreshold:heatthreshold;
	Property CoolDownTime:cooldowntime;
	Property AmmoGraphic:ammoGraphic;

	Default
	{
		Radius 2;
		Height 2;
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+THRUSPECIES
		Species "Turret";
		TurretGun.MaxShotCount 100; // How many rounds to fire before reloading
		TurretGun.TemperatureThreshold 200; // How many tics of continuous fire before cooldown (roughly 50 degrees per 100 rounds)
		TurretGun.CoolDownTime 140; // How many tics you must wait before firing again after hitting max temperature (does NOT guarantee full cooldown!)
		TurretGun.AmmoGraphic "WALT01";
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
		Reload:
			MDLA A 5 A_StartSound("weapon/dryfire", CHAN_WEAPON);
			MDLA A 35 DoReload();
			MDLA A 5 A_StartSound("mp40/reload", CHAN_WEAPON);
			MDLA A 5;
			MDLA A 0 { if (cooldowntimeout > 0) { SetStateLabel("Cooldown"); } }
			Goto Spawn;
		Cooldown:
			MDLA A 0 DoCoolDown();
			Goto Spawn;
		Fire:
			MDLA ABCD 2 DoFire();
			Goto Spawn;
	}

	override void PostBeginPlay()
	{
		while (!swivel) { swivel = Spawn("TurretSwivel", pos); }
		swivel.scale = scale;
		swivel.master = master;

		while (!light) { light = Spawn("AlphaLight", pos + (RotateVector((28 * scale.x, 0), angle), 8 * scale.y)); }
		light.scale = scale;
		light.master = self;
		DynamicLight(light).bAdditive = true;
		AlphaLight(light).clr = 0xFF2000;

		while (!light2) { light2 = Spawn("AlphaLight", pos + (RotateVector((28 * scale.x, 0), angle), 8 * scale.y)); }
		light2.scale = scale;
		light2.master = self;
		AlphaLight(light2).clr = 0xFF6600;

		while (!light3) { light3 = Spawn("AlphaLight", pos + (RotateVector((28 * scale.x, 0), angle), 8 * scale.y)); }
		light3.scale = scale;
		light3.master = self;
		AlphaLight(light3).clr = 0xFFAA77;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (heatlevel && level.time && level.time % 4 == 0) { heatlevel--; }

		if (swivel) { swivel.angle = angle; }

		double heatamt = double(heatlevel) / heatthreshold;
		
		if (cooldowntimeout > 0) cooldowntimeout -= 1;

		if (light) { light.alpha = clamp(heatamt * 1.25, 0, 1.0); }
		if (light2) { light2.alpha = clamp((heatamt - 0.75) * 3, 0, 1.0); }
		if (light3) { light3.alpha = clamp((heatamt - 0.85) * 5.7, 0, 1.0); }

		RotateWithMaster(ROT_MATCHROLL);

		Actor.Tick();
	}

	void DoFire()
	{
		A_StartSound("mp40/fire", CHAN_WEAPON);

		A_SpawnItemEx("Casing9mm", 4 * scale.x, 4 * scale.x, 8 * scale.y, 8, Random(-2,2), Random(0,4), Random(50,80), SXF_NOCHECKPOSITION);
		A_SpawnItemEx("TurrSmokeSpawner", 10 * scale.x, 0, 8 * scale.x, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_TRANSFERROLL | SXF_TRANSFERPITCH);

		bool temp;
		Actor origin;
		[temp, origin] = A_SpawnItemEx("KTFlare", 34 * scale.x, 0, 8 * scale.x, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_SETMASTER);

		if (!origin) { origin = self; }
		// Spawn the tracer from the flare so that the tracer model isn't visible sticking through the turret gun body
		origin.A_SpawnProjectile("KTurretTracer", 8 * scale.y, 0, angle + FRandom(-1.0, 1.0), CMF_AIMDIRECTION | CMF_ABSOLUTEANGLE, pitch + FRandom(-1.0, 1.0));

		shotcount++;
		heatlevel++;

		if (maxshotcount && shotcount >= maxshotcount)
		{
			SetStateLabel("Reload");
		}

		if (heatthreshold && heatlevel > heatthreshold)
		{
			cooldowntimeout = cooldowntime;
			SetStateLabel("Cooldown");
		}
	}

	void DoReload()
	{
		shotcount = 0;
		A_StartSound("mauser/insert", CHAN_WEAPON);
	}

	void DoCoolDown()
	{
		A_SetTics(cooldowntimeout);

		if (cooldowntimeout > 24)
		{
			A_StartSound("STEAM_BURST", CHAN_WEAPON);
		}

		if (!smokefx)
		{
			smokefx = TurretOverheatSmokeSpawner(Spawn("TurretOverheatSmokeSpawner", Pos, NO_REPLACE));
		}

		smokefx.master = self;
		smokefx.cooldowntime = cooldowntimeout;
	}

	static void Overheat(Actor activator, int goToCooldownState = 0)
	{
		TurretGun gun;

		// Find the gun
		FTranslatedLineTarget gtarg;
		activator.AimLineAttack(activator.Angle, 512.0, gtarg, flags: ALF_CHECK3D | ALF_CHECKNONSHOOTABLE);

		if (gtarg.linetarget)
		{
			if (gtarg.linetarget is "TurretStand")
			{
				TurretStand stand = TurretStand(gtarg.linetarget);
				gun = stand.gun;
			}
			else if (gtarg.linetarget is "TurretGun")
			{
				gun = TurretGun(gtarg.linetarget);
			}
			else
			{
				if (gtarg.linetarget)
				{
					Console.Printf("Found a %s", gtarg.linetarget.GetClassName());
				}
				return;
			}

			gun.heatlevel = gun.heatthreshold;
		}

		if (gun && goToCooldownState)
		{
			gun.cooldowntimeout = gun.cooldowntime;
			gun.SetStateLabel("Cooldown");
		}
	}
}

class TurretOverheatSmokeSpawner : GunSmokeSpawner
{
	int cooldowntime;

	Default
	{
		GunSmokeSpawner.SmokeClass "TurrCoolSmoke";
	}

	States
	{
		Spawn:
			TNT1 A 2
			{
				A_SpawnSmoke(zVelFactor: 2.0);
				if (cooldowntime <= 0)
				{
					Destroy();
				}
			}
			Loop;
	}

	override void Tick()
	{
		if (master)
		{
			Angle = master.Angle;
			Pitch = master.Pitch;
			SetOrigin(GetMuzzlePos(), false);
		}
		if (cooldowntime)
		{
			cooldowntime -= 1;
		}
		Super.Tick();
	}
	
	vector3 GetMuzzlePos()
	{
		vector3 mPos = master.Pos;

		vector3 offsetVector = (34.2, .57, 9.12);
		double offsetLen = offsetVector.Length();

		// A_SpawnSmoke offsets X by 24
		offsetVector.X -= 24;

		offsetVector.XY = RotateVector(offsetVector.XY, master.Angle);
		offsetVector.Z -= sin(master.Pitch) * offsetLen;


		return mPos + offsetVector;
	}
}

// "Proxy" weapon that copies the ammo counts from the turret gun so that they can be displayed in the status bar.
class TurretWeapon : NullWeapon
{
	TurretGun gun;

	Default
	{
		Tag "$TAGTURET";
		Weapon.AmmoType1 "TurretBulletAmmo";
		Weapon.AmmoType2 "TurretHeatAmmo";
	}

	override void DoEffect()
	{
		static const string heatlevelicons[] = {"HEAT01", "HEAT02", "HEAT03", "HEAT04", "HEAT05", "HEAT06"};
		static const int heatlevels[] = {0, 20, 40, 60, 80, 100};

		if (gun)
		{
			Ammo1.MaxAmount = gun.maxshotcount;
			Ammo1.Amount = gun.maxshotcount - gun.shotcount;
			Ammo1.Icon = TexMan.CheckForTexture(gun.ammoGraphic, TexMan.Type_MiscPatch);

			Ammo2.Amount = int((double(gun.heatlevel) / gun.heatthreshold) * 100);
			int i = 0;
			for (;i < 6; i++)
			{
				if (Ammo2.Amount <= heatlevels[i]) break;
			}
			Ammo2.Icon = TexMan.CheckForTexture(heatlevelicons[i], TexMan.Type_MiscPatch);
		}
	}
}

class TurretStand : Actor
{
	Actor shooter;
	TurretGun gun;
	Weapon playerlastweapon;
	transient FLineTraceData crosshairtrace;
	double pangle, ppitch;
	bool freezeonreload;
	TurretWeapon twep;

	Property FreezeOnReload:freezeonreload;

	Default
	{
		//$Category Weapons (BoA)
		//$Title Usable Turret (ZScript)
		//$Color 14
		Radius 8;
		Height 32;
		+MOVEWITHSECTOR
		+MTHRUSPECIES
		+SOLID
		+THRUSPECIES
		Species "Turret";
		TurretStand.FreezeOnReload False;
	}

	States
	{
		Spawn:
			MDLA A -1;
	}

	override bool Used(Actor user)
	{
		if (shooter)
		{
			if (shooter == user)
			{
				return LeaveTurret();
			}

			return false;
		}

		double delta = deltaangle(angle, AngleTo(user));

		if (user.player && abs(delta) > 135) // Player must be within +/-45 degrees of directly behind the gun
		{
			if (gun)
			{
				gun.target = user;
				user.Angle = Normalize180(user.Angle);
				gun.Angle = user.Angle;
			}
			shooter = user;
			shooter.DamageFactor = 0.25; // Player takes quarter damage while using the turret gun
			ReactionTime = 10; // Lock player to gun for 10 tics
			return true;
		}

		return false;
	}

	override void PostBeginPlay()
	{
		Angle = Normalize180(Angle);
		vector3 gunPos = Pos;
		gunPos.Z += 26;
		while (!gun) { gun = TurretGun(Spawn("TurretGun", gunPos)); }

		gun.master = self;
		gun.target = self;
		gun.scale = scale;
		gun.Angle = Angle;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		VehicleBase.SetPitchRoll(self, 0);

		if (shooter && shooter.player && gun && shooter.health > 0)
		{
			if (
				shooter.player.cmd.buttons & BT_CROUCH ||
				shooter.player.cmd.buttons & BT_JUMP ||
				shooter.player.cmd.forwardmove ||
				shooter.player.cmd.sidemove
			)
			{
				if (!LeaveTurret())
				{
					DoInteractions();
				}
			}
			else
			{
				DoInteractions();
			}
		}

		Super.Tick();
	}

	void DoInteractions()
	{
		shooter.SetOrigin(pos + RotateVector((-(shooter.radius + radius) * 1.5, 0), gun.angle), true); // Keep the shooter at the firing position

		if (ReactionTime)
		{
			ReactionTime--;
		}

		if (!twep)
		{
			twep = TurretWeapon(shooter.GiveInventoryType("TurretWeapon"));

			if (!twep.gun || twep.gun != gun)
				twep.gun = gun;
		}

		if (shooter.player.ReadyWeapon != twep)
		{
			playerlastweapon = shooter.player.ReadyWeapon;
			shooter.player.PendingWeapon = twep;
		}

		shooter.player.viewheight = PlayerPawn(shooter).viewheight * 3 / 4; 

		gun.pitch = clamp(shooter.pitch, -55, 55);
		gun.angle = ZScriptTools.clampAngle(shooter.angle, angle - 70, angle + 70);
		/*
		if (abs(deltaangle(shooter.angle, angle)) <= 70)
		{
			gun.angle = shooter.angle;
		}
		*/

		shooter.angle = gun.angle;

		shooter.player.cheats |= CF_FROZEN;

		if (CanLeaveTurret())
		{
			shooter.player.cheats ^= CF_FROZEN;
		}

		if (shooter.player.cmd.buttons & BT_ATTACK)
		{
			if (GunIsIdle())
			{
				gun.SetStateLabel("Fire");
			}
		}
		else if (shooter.player.cmd.buttons & BT_RELOAD)
		{
			if (!GunIsReloading() && gun.shotcount > 0)
			{
				gun.SetStateLabel("Reload");
			}
		}
	}

	virtual bool GunIsIdle()
	{
		return gun.InStateSequence(gun.CurState, gun.SpawnState);
	}

	virtual bool GunIsCooling()
	{
		State CooldownState = gun.ResolveState("Cooldown");
		return gun.InStateSequence(gun.CurState, CooldownState);
	}

	virtual bool GunIsReloading()
	{
		State ReloadState = gun.ResolveState("Reload");
		return gun.InStateSequence(gun.CurState, ReloadState);
	}

	virtual bool CanLeaveTurret()
	{
		return ReactionTime == 0 && !GunIsReloading() || GunIsCooling();
	}

	virtual bool LeaveTurret()
	{
		if (!CanLeaveTurret())
		{
			// Lock player while reloading
			return false;
		}

		shooter.player.PendingWeapon = playerlastweapon;

		shooter.player.viewheight = PlayerPawn(shooter).viewheight;
		shooter.DamageFactor = shooter.Default.DamageFactor;

		Inventory twepInv = shooter.FindInventory("TurretWeapon");

		if (twepInv)
		{
			shooter.TakeInventory("TurretWeapon", twepInv.Amount);
		}

		shooter = null;
		return true;
	}
}

class AlphaLight : DynamicLight
{
	Color clr;
	double maxradius;
	Vector3 spawnoffset;

	Property LightColor:clr;
	Property LightRadius:maxradius;

	Default
	{
		DynamicLight.Type "Point";
		AlphaLight.LightColor 0xFFFFFF;
		AlphaLight.LightRadius 16;
	}

	override void BeginPlay ()
	{
		alpha = 0;

		args[LIGHT_RED] = clr.r;
		args[LIGHT_GREEN] = clr.g;
		args[LIGHT_BLUE] = clr.b;
		args[LIGHT_INTENSITY] = int(maxradius); //int(maxradius * scale.y * alpha);

		Super.BeginPlay();
	}

	override void PostBeginPlay()
	{
		if (master)
		{
			spawnoffset = pos - master.pos;

			Vector2 temp = RotateVector((spawnoffset.x, spawnoffset.y), -master.angle);
			spawnoffset = (temp.x, temp.y, spawnoffset.z);
		}

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		args[LIGHT_RED] = int(clr.r * alpha);
		args[LIGHT_GREEN] = int(clr.g * alpha);
		args[LIGHT_BLUE] = int(clr.b * alpha);
		args[LIGHT_INTENSITY] = int(maxradius); //int(maxradius * scale.y * alpha);

		if (master && spawnoffset != (0, 0, 0)) { Rotate(); }

		Super.Tick();
	}

	void Rotate()
	{
		Vector2 temp = RotateVector((spawnoffset.y, spawnoffset.z), master.roll);
		Vector3 offset = (spawnoffset.x, temp.x, temp.y);

		temp = RotateVector((offset.x, offset.z), 360 - master.pitch);
		offset = (temp.x, offset.y, temp.y);

		temp = RotateVector((offset.x, offset.y), master.angle);
		offset = (temp.x, temp.y, offset.z);

		offset.x *= master.scale.x;
		offset.y *= master.scale.x;
		offset.z *= master.scale.y;

		SetOrigin(master.pos + offset, true);
	}
}

class GunSmoke : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		RenderStyle "Translucent";
		Alpha 0.2;
		Scale 0.01;
		+NOCLIP
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+ROLLSPRITE
	}

	States
	{
		Spawn:
			SMSP A 1 A_FadeIn();
			SMSP A 1 A_FadeIn();
		Next:
			SMSP A 1 A_SetRoll(roll+1, SPF_INTERPOLATE);
			SMSP A 0 A_FadeOut(0.04);
			SMSP A 0 A_SetScale(Scale.X+0.001, Scale.Y+0.001);
			Loop;
	}

	override void PostBeginPlay()
	{
		if (GetClass() == "GunSmoke") { Super.PostBeginPlay(); }

		double newScaleX = Scale.X; // set scale relatively
		double newScaleY = Scale.Y;

		class<Actor> type = GetClass();
		do
		{
			type = (class<Actor>)(type.GetParentClass());
			newScaleX *= (GetDefaultByType(type)).Scale.X;
			newScaleY *= (GetDefaultByType(type)).Scale.Y;
		} while (type != "GunSmoke");

		Scale.X = newScaleX;
		Scale.Y = newScaleY;
		
		Super.PostBeginPlay();
	}
}

class GunSmokeSpawner : Actor
{
	class<Actor> smokeClass;

	Property SmokeClass:smokeClass;

	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		+NOINTERACTION

		GunSmokeSpawner.SmokeClass "PistolSmoke";
	}

	States
	{
		Spawn:
			TNT1 A 0 NODELAY A_SpawnSmoke();
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		CVar boa_smokeswitch = CVar.FindCVar("boa_smokeswitch");
		int smoke = boa_smokeswitch.GetInt();
		if (smoke == 0)
		{
			Destroy();
			return;
		}
	}

	Actor A_SpawnSmoke(double xPosFactor = 1.0, double xVelFactor = 1.0, double zVelFactor = 1.0)
	{
		bool sp;
		Actor ac;
		[sp, ac] = A_SpawnItemEx(smokeClass,24 * xPosFactor,0,0,frandom(0.1,0.2) * xVelFactor,0,frandom(0.2,0.6) * zVelFactor);
		ac.Roll = frandom(0.0, 360.0);
		return ac;
	}
}

/*
 * Firebrand code taken, and modified from ww-nazis-v2 by Kevin Caccamo and
 * the Realm667 team
 * Copyright (c) 2015-2020 @wildweasel486
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

class Firebrand : NaziWeapon
{
	int ticcount;

	Default
	{
		//$Category Weapons (BoA)
		//$Title (1) Tyrfing
		//$Color 14
		Scale 0.5;
		NaziWeapon.AmmoInventoryType "Soul"; // For inventory bar
		Weapon.SelectionOrder 9999;
		Inventory.PickupMessage "$TYRF";
		Inventory.PickupSound "sword/draw";
		Weapon.UpSound "sword/draw";
		-WEAPON.AMMO_CHECKBOTH
		+WEAPON.NOALERT
		+WEAPON.NOAUTOFIRE
		+NaziWeapon.NORAMPAGE
		Tag "$TAGBLAOA";
	}
	States
	{
	Select:
		SRDG A 0 A_Raise;
		"####" A 1 A_Raise;
		Loop;
	Deselect:
		SRDG A 0 A_StopSound(CHAN_WEAPON);
		SRDG A 0 A_Lower;
		"####" A 1 A_Lower;
		Loop;
	Ready:
		SRDG A 0 A_StopSound(CHAN_WEAPON);
		TNT1 A 0 A_JumpIfInventory("FirebrandCharged",1,"SoundLoop");
		SRDG A 1 A_WeaponReady;
		Loop;
	SoundLoop:
		SRDF A 0 A_StartSound("SFX/FireLoop2", CHAN_WEAPON, CHANF_LOOPING, 0.7, ATTN_STATIC);
		Goto PowerLoop;
	PowerLoop:
		SRDF A 3 A_WeaponReady;
		SRDI BC 3 A_WeaponReady;
		TNT1 A 0 A_JumpIfInventory("FirebrandCharged",1,"PowerLoop");
		Goto Ready;
	Fire:
		TNT1 A 0 A_JumpIfInventory("FirebrandCharged",1,"SuperFire");
		SRDG B 0 A_JumpIfInventory("SwordSeq",2,"Fire3");
		"####" B 1 A_JumpIfInventory("SwordSeq",1,"Fire2");
		"####" C 1 A_GiveInventory("SwordSeq");
		TNT1 A 4;
		SRDG DE 1;
		"####" F 1 A_StartSound("sword/swing");
		"####" GHI 1;
		"####" J 1 A_CustomPunch(35,1,0,"SwordPuff",96);
		"####" KLM 1;
		TNT1 A 8 A_WeaponReady;
		SRDG C 1;
		"####" B 1 A_TakeInventory("SwordSeq");
		Goto ready;
	Fire2:
		TNT1 A 5;
		SRDG N 1 A_GiveInventory("SwordSeq");
		"####" O 1 A_StartSound("sword/swing");
		"####" PQR 1;
		"####" S 1 A_CustomPunch(45,1,0,"SwordPuff",96);
		"####" TUV 1;
		TNT1 A 8 A_WeaponReady;
		"####" A 0 A_TakeInventory("SwordSeq");
		Goto Ready;
	Fire3:
		TNT1 A 4;
		SRDG DE 1;
		"####" F 1 A_StartSound("sword/swing");
		"####" GHI 1;
		"####" J 1 A_CustomPunch(35,1,0,"SwordPuff",96);
		"####" KL 1;
		"####" M 1 A_TakeInventory("SwordSeq",1);
		TNT1 A 8 A_WeaponReady;
		SRDG C 1;
		"####" B 1 A_TakeInventory("SwordSeq");
		Goto Ready;
	SuperFire: //we can heal ourselves of 25 max from 1 to 25 hp when we do melee attack with powered sword - ozy81
		SRDF B 0 A_JumpIfInventory("SwordSeq",2,"SuperFire3");
		"####" B 1 A_JumpIfInventory("SwordSeq",1,"SuperFire2");
		"####" C 1 A_GiveInventory("SwordSeq");
		TNT1 A 4;
		SRDG DE 1;
		SRDF F 1 A_StartSound("flamesword/swing");
		"####" GHI 1;
		"####" J 1 A_CustomPunch(80,1,0,"FireSwordPuff",96,1,25);
		"####" KLM 1;
		TNT1 A 8 A_WeaponReady;
		SRDF C 1;
		"####" B 1 A_TakeInventory("SwordSeq");
		Goto ready;
	SuperFire2: //we can heal ourselves of 25 max from 1 to 25 hp when we do melee attack with powered sword - ozy81
		TNT1 A 5;
		SRDF N 1 A_GiveInventory("SwordSeq");
		"####" O 1 A_StartSound("flamesword/swing");
		"####" PQR 1;
		"####" S 1 A_CustomPunch(100,1,0,"FireSwordPuff",96,1,25);
		"####" TUV 1;
		TNT1 A 8 A_WeaponReady;
		"####" A 0 A_TakeInventory("SwordSeq");
		Goto Ready;
	SuperFire3: //we can heal ourselves of 25 max from 1 to 25 hp when we do melee attack with powered sword - ozy81
		TNT1 A 4;
		SRDG DE 1;
		SRDF F 1 A_StartSound("flamesword/swing");
		"####" GHI 1;
		"####" J 1 A_CustomPunch(80,1,0,"FireSwordPuff",96,1,25);
		"####" KL 1;
		"####" M 1 A_TakeInventory("SwordSeq",1);
		TNT1 A 8 A_WeaponReady;
		SRDF C 1;
		"####" B 1 A_TakeInventory("SwordSeq");
		Goto Ready;
	AltFire:
		SRDG A 1 A_JumpIfInventory("FirebrandCharged",1,"Altfire2");
		"####" BC 1;
		TNT1 A 7 {
			Inventory soulAmmo = FindInventory("Soul");
			if (soulAmmo) // 1 or more souls
			{
				A_TakeInventory("Soul", 1, TIF_NOTAKEINFINITE);
				A_SetBlend("64 ff 96", .5, 15);
			}
			else
			{
				Thing_Damage(0,25);
				A_SetBlend("ff 00 00", .5, 15);
			}
		}
		SRDG C 1
		{
			invoker.ticcount = 8;
			A_GiveInventory("FirebrandCharged");
		}
		"####" BA 1;
		Goto Ready;
	Altfire2:
		SRDF BC 1;
		TNT1 A 4;
		SRDG DE 1;
		SRDF F 1 A_StartSound("flamesword/swing");
		"####" GH 1;
		"####" I 1;
		"####" J 1 {
			A_FireProjectile("FirebrandFireball");
			Inventory soulAmmo = FindInventory("Soul");
			if (soulAmmo)
			{
				if (soulAmmo.Amount > 1)
				{
					int soulTakeCount = min(5, CountInv("Soul"));
					int i;
					A_TakeInventory("Soul", soulTakeCount, TIF_NOTAKEINFINITE);
					for (i = 1; i < soulTakeCount; i++)
					{ // Already fired 1 projectile
						A_FireProjectile("FirebrandFireball", frandom(-2.0, 2.0), false, 0, 0, 0, frandom(-2.0, 2.0));
					}
				}
				else
				{
					A_TakeInventory("Soul", 1, TIF_NOTAKEINFINITE);
				}
			}
			/*
			else // No souls
			{
				Thing_Damage(0,2);
			}
			*/
		}
		"####" KLM 1;
		TNT1 A 20 A_WeaponReady;
		SRDF C 1;
		"####" B 1 A_TakeInventory("SwordSeq");
		Goto Ready;
	Spawn:
		SRDP ABCD 4 LIGHT("ITBURNSOC1");
		Loop;
	}

	override void Tick()
	{
		if (owner)
		{
			if (owner.CountInv("FirebrandCharged") && owner.player && owner.player.ReadyWeapon == self)
			{
				if (ticcount > 4) { owner.A_AttachLight("FlameEffect", DynamicLight.FlickerLight , color(2, 212, 117), 24, 32, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 32), 0.2); }
				else if (ticcount > 0) { owner.A_AttachLight("FlameEffect", DynamicLight.FlickerLight , color(26, 168, 105), 32, 36, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 32), 0.3); }
				else { owner.A_AttachLight("FlameEffect", DynamicLight.FlickerLight , color(18, 94, 48), 36, 44, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 32), 0.4); }
			}
			else { owner.A_RemoveLight("FlameEffect"); }
		}

		Super.Tick();
	}
}

class FirebrandCharged : PowerWeaponLevel2
{
	Default
	{
		Inventory.Icon "ICO_FBRD";
		Powerup.Color "02 D4 75", 0.5;
	}

	override color GetBlend () { return 0; } // Don't actually flash, just use the blend color for the hud timer
}

///////////////////////
// Truck Nebelwerfer //
///////////////////////

class NebelwerferTruck : NaziWeapon
{
	Default
	{
		Weapon.SelectionOrder 2500;
		Weapon.UpSound "nebelwerfer/select";
		Tag "Fliegerfaust";
		-WEAPON.NOALERT
		-WEAPON.AMMO_CHECKBOTH
		+INVENTORY.UNDROPPABLE
	}

	States
	{
		Ready:
			HSML A 1 {
				A_WeaponReady(WRF_NOSWITCH);
				invoker.AdjustPitch();
			}
			Loop;
		Deselect:
			HSML A 0 A_Lower();
			HSML A 1 A_Lower();
			Loop;
		Select:
			HSML A 0 A_Raise();
			HSML A 1 A_Raise();
			Loop;
		Fire:
			HSML A 0 A_JumpIf(height<=30,"Fire.LowRecoil");
			HSML A 0 A_GunFlash();
			HSML A 0 A_StartSound("nebelwerfer/fire", CHAN_WEAPON);
			HSML BBC 1;
			HSML C 0 A_FireProjectile("NebRocket2");
			HSML CDD 1 A_SetPitch(pitch-(0.7* boa_recoilamount));
			HSML A 40;
			HSML A 2 A_ReFire();
			Goto Ready;
		Fire.LowRecoil:
			HSML A 0 A_GunFlash();
			HSML A 0 A_StartSound("nebelwerfer/fire", CHAN_WEAPON);
			HSML BBC 1;
			HSML C 0 A_FireProjectile("NebRocket2");
			HSML CDD 1 A_SetPitch(pitch-(0.35*boa_recoilamount));
			HSML A 40;
			HSML A 2 A_ReFire();
			Goto Ready;
		Flash:
			HSML A 2 A_Light2;
			TNT1 A 2 A_Light1;
			Goto LightDone;
		Spawn:
			HSML A -1;
			Stop;
	}

	void AdjustPitch()
	{
		owner.player.maxpitch = 10; // Start with a max pitch down of 10 degrees

		if (!owner.goal) // Stores the current vehicle as the player actor's goal pointer (which is otherwise unused)
		{
			ThinkerIterator it = ThinkerIterator.Create("ModelGMCTruck"); // This is what's used in C2M4; modify this code or inherit from that class if ever used elsewhere
			Actor mo;

			while ((mo = Actor(it.Next())) && !owner.goal)
			{
				if (mo == self) { continue; } // Ignore itself

				if (owner.Distance2D(mo) <= mo.Radius) { owner.goal = mo; } // Find the closest truck to the player
			}
		}

		if (owner.goal) // If a vehicle was found...
		{
			double diff = absangle(owner.angle, owner.goal.angle); // Get the angle offset of the player from the truck

			if (diff > 35) // And adjust the pitch accordingly
			{
				owner.player.maxpitch += (clamp(diff - 35, 0, 20) / 20.0) * 20; // Scale from 10 to 30 degrees down, over the course of a 20 degree diff
			}

			owner.player.maxpitch += owner.goal.pitch * cos(diff); // Set max pitch in a smooth curve between 35 degrees and 55 degrees diff
		}
	}

	override void OnDestroy()
	{
		if (owner && owner.player)
		{			
			owner.player.maxpitch = 90; // Restore full pitch range when this item is destroyed (removed from inventory)
		}

		Super.OnDestroy();
	}
}