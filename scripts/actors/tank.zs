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

// Player Tank Class
class TankPlayer : PlayerPawn
{
	TankTreadsBase treads;
	TankTurretBase turret;
	TankCannonBase gun;
	Actor turretcamera, povcamera;
	Actor ForcedHealthBar;
	transient FLineTraceData cameratrace;
	BoAFindHitPointTracer hittracer;
	double sndvol;
	Vector3 cameralocation;
	int useholdtime;
	Vector3 CrosshairPos;
	Actor CrosshairActor;
	double CrosshairDist;
	int altrefire;
	class<TankTreadsBase> treadsclass;
	class<TankMorph> powerupclass;
	class<TankPlayer> actorclass;
	property TreadsClass: treadsclass;
	property PowerupClass: powerupclass;
	property ActorClass: actorclass;

	Default
	{
		Health 10000;
		Height 96;
		Mass 0x7ffffff;
		Radius 64;
		Speed 1;
		BloodType "TankSpark";
		DamageFactor "Electric", 0.8;
		DamageFactor "Fire", 0.5;
		DamageFactor "MutantPoison", 0.1;
		DamageFactor "MutantPoisonAmbience", 0.1;
		DamageFactor "Normal", 0.5;
		DamageFactor "Rocket", 0.5;
		DamageFactor "Rocket2", 10.0; //enemypanzerrocket only, for panzerguards  - ozy81 //1.5->10.0 --N00b
		DamageFactor "UndeadPoison", 0.1;
		DamageFactor "UndeadPoisonAmbience", 0.1;
		DamageFactor "Frag", 0.75;
		MaxStepHeight 48;
		MaxDropoffHeight 48;
		Species "Tank";
		Player.UseRange 0;
		Renderstyle 'None'; // Ensure that the actual player actor stays invisible, just in case it reverts to PLAYA0 sprites
		+NOBLOOD
		-PICKUP // Don't pick up powerups while in the tank
	}

	States
	{
		Spawn:
			TNT1 A -1;
			Stop;
		Pain:
			TNT1 A 1 A_Pain;
			Goto Spawn;
		Death:
			TNT1 A 1 {
				A_Scream();
				A_StopSound(30);
				A_StopSound(31);
				A_StopSound(32);
			}
			TNT1 A -1;
			Stop;
	}

	override void MovePlayer ()
	{
		let player = self.player;
		UserCmd cmd = player.cmd;

		double moveangle = angle;

		if (cmd.yaw) { angle += cmd.yaw * (360./65536.); } 
		if (treads) { moveangle = treads.angle; }

		player.onground = (pos.z <= floorz) || bOnMobj || bMBFBouncer || (player.cheats & CF_NOCLIP2);

		double newsndvol = 0;

		if (cmd.forwardmove | cmd.sidemove)
		{
			double forwardmove, sidemove;
			double friction, movefactor;
			double fm, sm;

			[friction, movefactor] = GetFriction();

			if (!player.onground && !bNoGravity && !waterlevel)
			{
				// [RH] allow very limited movement if not on ground.
				movefactor *= level.aircontrol;
			}

			fm = cmd.forwardmove;
			sm = cmd.sidemove;
			[fm, sm] = TweakSpeeds (fm, sm);
			fm *= Speed / 256;
			sm *= Speed / 256;

			// The tank always moves at normal speed, regardless of cl_run setting or shift being held
			// This basically cancels out the run speed additions handled in g_game.cpp.
			if (cl_run && player.cmd.buttons & BT_SPEED)
			{
				sm /= 1.25;
				fm /= 1.25;
			}
			else if (cl_run ^ player.cmd.buttons & BT_SPEED)
			{
				sm /= 2;
				fm /= 2;
			}

			forwardmove = fm * movefactor * (35 / TICRATE);
			sidemove = sm * movefactor * (35 / TICRATE);

			CVar boa_autosteer = CVar.FindCVar('boa_autosteer');
			bool shift = !(player.cmd.buttons & BT_SPEED) != !boa_autosteer.GetInt(); // If shift is being held or boa_autosteer cvar is true

			// Handle "auto-steering" the tank to wherever you are aiming
			if (forwardmove && shift && treads && turret && treads.angle != turret.angle) // If holding SHIFT, auto-steer the tracks to align with the turret
			{
				double diff = deltaangle(treads.angle, angle);

				if (diff < -1)
				{
					treads.angle -= 2;
					forwardmove /= 5;
					A_StartSound("MACHINE_LOOP_3", 30, CHANF_NOSTOP, 0.5);
				}
				else if (diff > 1)
				{
					treads.angle += 2;
					forwardmove /= 5;
					A_StartSound("MACHINE_LOOP_3", 30, CHANF_NOSTOP, 0.5);
				}
				else
				{
					treads.angle = angle;
					A_StopSound(30);
				}

				newsndvol += 0.5;
			}
			else if (sidemove) // Only do separate sidemove handling if not auto-steering or not moving forward
			{
				if (forwardmove >= 0) { sidemove *= -1; }

				if (!forwardmove) { sidemove *= 2.5; } // Turn faster if you're not moving forward

				angle += sidemove;

				if (treads)
				{
					treads.angle += sidemove;
					if (turret) { turret.angle += sidemove; }
				}

				A_SetInventory("ShakeShaderControl", 1 + int(sidemove));

				newsndvol += abs(sidemove);
			}

			if (forwardmove)
			{
				ForwardThrust(forwardmove, moveangle);
			}

			if (!(player.cheats & CF_PREDICTING) && (forwardmove != 0 || sidemove != 0))
			{
				PlayRunning ();
				if (treads)
				{
					if (InStateSequence(treads.CurState, treads.SpawnState) && treads.FindState("Move"))
					{
						 treads.SetStateLabel("Move");
					}
				}
			}

			if (player.cheats & CF_REVERTPLEASE)
			{
				player.cheats &= ~CF_REVERTPLEASE;
				player.camera = player.mo;
			}
		}

		double movespeed = vel.xy.length();
		if (movespeed)
		{
			A_SetInventory("ShakeShaderControl", 1 + int(movespeed) * 65536);
			newsndvol += movespeed;
		}

		if (sndvol > newsndvol) { sndvol = max(sndvol - 0.25, newsndvol); }
		if (sndvol < newsndvol) { sndvol = min(sndvol + 0.25, newsndvol); }

		A_SoundVolume(CHAN_7, sndvol);
	}

	override void CheckJump() {} // Tanks can't jump
		
	override void CheckAirSupply() //nor can they swim --N00b
	{
		// Handle air supply
		//if (level.airsupply > 0)
		{
			let player = self.player;
			
			bool ok; Actor below; //see A_CheckSolidFooting on wiki
			[ok, below] = TestMobjZ(true);
			if (waterlevel >= 1 && abs(pos.z - GetZAt()) > 1 && !below)
			{
				vel.z -= gravity / 2.0;
			}
			if (waterlevel < 3 || (bInvulnerable) || (player.cheats & (CF_GODMODE | CF_NOCLIP2)) ||	(player.cheats & CF_GODMODE2))
			{
				ResetAirSupply();
			}
			else if (!(Level.maptime & 7)) //only does the damage while the tank is inhabited
			{	//waterlevel is 3, the water is flooding the tank
				DamageMobj(NULL, NULL, 100, 'Drowning');
			}
		}
	}

	override void CheckPitch()
	{
		let player = self.player;
		// [RH] Look up/down stuff
		if (!level.IsFreelookAllowed())
		{
			Pitch = 0.;
		}
		else
		{
			// The player's view pitch is clamped between -32 and +56 degrees,
			// which translates to about half a screen height up and (more than)
			// one full screen height down from straight ahead when view panning
			// is used.
			int clook = player.cmd.pitch;
			if (clook != 0)
			{
				if (clook == -32768)
				{ // center view
					player.centering = true;
				}
				else if (!player.centering)
				{
					// no more overflows with floating point. Yay! :)
					Pitch = clamp(Pitch - clook * (360. / 65536.), (turret ? -turret.pitch : 0) + player.MinPitch, (turret ? -turret.pitch : 0) + player.MaxPitch);
				}
			}
		}
		if (player.centering)
		{
			if (abs(Pitch) > 2.)
			{
				Pitch *= (2. / 3.);
			}
			else
			{
				Pitch = 0.;
				player.centering = false;
				if (PlayerNumber() == consoleplayer)
				{
					LocalViewPitch = 0;
				}
			}
		}
	}

	override bool UseInventory(Inventory item)
	{
		if (
			item is "RepairKit" ||
			item is "BoACompass"
		)
		{
			return Super.UseInventory(item);
		}

		return false;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (other is "TankBlocker" && other.Species == Species) { return false; }

		if (other.bSpecial) { other.Touch(self); }

		return true;
	}

	override void FireWeaponAlt (State stat)
	{
		let weapn = player.ReadyWeapon;
		if (weapn == null || weapn.FindState('AltFire') == null || !weapn.CheckAmmo (Weapon.AltFire, true))
		{
			return;
		}

		player.WeaponState &= ~WF_WEAPONBOBBING;
		PlayAttacking ();
		weapn.bAltFire = true;

		if (stat == null)
		{
			int refire = player.refire;

			if (player.mo is "TankPlayer") { refire = TankPlayer(player.mo).altrefire; }

			stat = weapn.GetAltAtkState(!!refire);
		}

		player.SetPsprite(PSP_WEAPON, stat);
		if (!weapn.bNoAlert)
		{
			SoundAlert (self, false);
		}
	}

	override void PostBeginPlay()
	{
		TakeInventory("BoATilt", 1);

		hittracer = new("BoAFindHitPointTracer");

		// Spawn everything in neutral orientation
		pitch = 0;
		roll = 0;

		bool sp = false;
		Actor temp;
		
		if (tracer && TankTreadsBase(tracer))
		{
			treads = TankTreadsBase(tracer);
			tracer = null;
		}

		while (!treads)
		{
			[sp, temp] = A_SpawnItemEx(treadsclass, 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE);
			treads = TankTreadsBase(temp);
		}
		treads.master = self;
		treads.bSolid = false;
		treads.Species = Species;

		while (!turretcamera) { [sp, turretcamera] = A_SpawnItemEx("SecurityCamera", -2.5 * radius, 0, treads.height + 128, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); }
		turretcamera.master = self;

		sndvol = 0.7;

		A_StartSound("TKIDLE", 31, CHANF_LOOPING, 0.25);
		A_StartSound("TNK1LOOP", 32, CHANF_LOOPING, 0.7);

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		bool chasecam = !(player.cheats & CF_CHASECAM);

		if (health == Default.Health && treads.savedhealth)
		{
			A_SetHealth(treads.savedhealth);
			treads.savedhealth = 0;
		}

		if (!turret) // Since turret is spawned by treads actor, check for it here since it'll be spawned after PostBeginPlay is called
		{
			if (treads)
			{
				turret = treads.turret;

				if (turret)
				{
					turret.master = self;
					turret.angle = angle;
					turret.bSolid = false;

					bool sp;
					while (!povcamera) { [sp, povcamera] = turret.A_SpawnItemEx("SecurityCamera", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPITCH | SXF_TRANSFERROLL | SXF_TRANSFERSCALE); }
					povcamera.master = turret;
				}
			}
		}

		if (Level.time % (35 * 5) == 0) { ForcedHealthBar = GetClosestForcedHealthBar(); } // Only run this check occasionally

		if (player && turretcamera && treads && turret && povcamera)
		{
			double zoffset = VehicleBase.SetPitchRoll(treads);
			double newz = pos.z - zoffset > GetZAt(0, 0) + MaxDropoffHeight ? pos.z - zoffset : GetZAt(0, 0);
			treads.SetOrigin((pos.xy, newz), true);

			double delta = deltaangle(treads.angle, turret.angle);

			Player.MinPitch = treads.pitch * cos(delta) - 25;
			Player.MaxPitch = treads.pitch * cos(delta) + 10;

			turret.SetOrigin(treads.pos + (RotateVector((treads.radius * sin(treads.pitch), -treads.radius * sin(treads.roll)), treads.angle), treads.height * cos(treads.roll)), true);

			turret.pitch = treads.roll * sin(-delta) + treads.pitch * cos(delta);
			turret.roll = treads.roll * cos(-delta) + treads.pitch * sin(delta);

			if (turret.angle != angle)
			{
				angle = Normalize180(angle);
				turret.angle = Normalize180(turret.angle);

				if (angle > turret.angle + 180) { angle -= 360; }
				else if (angle < turret.angle - 180) { angle += 360; }

			 	turret.angle = !chasecam ? angle : clamp(angle, turret.angle - 1.5, turret.angle + 1.5);
				A_StartSound("MACHINE_LOOP_3", 30, CHANF_NOSTOP, 0.5);
			}
			else
			{
				A_StopSound(30);
			}

			// Force pitch clamping
			if (turret.pitch + pitch >= player.MaxPitch || turret.pitch + pitch <= player.MinPitch)
			{
				player.cmd.pitch = 0;
			}

			if (!gun) { gun = treads.turret.gun; }

			if (gun)
			{
				DoTrace(gun, turret.angle, 2048, turret.pitch + pitch, 0, 0, hittracer);

				CrosshairPos = hittracer.Results.HitPos;
				CrosshairActor = hittracer.Results.HitActor;
				CrosshairDist = hittracer.Results.Distance;

				gun.pitch = turret.pitch + pitch;
				gun.roll = turret.roll;
			}

			if (!chasecam)
			{
				if (povcamera)
				{
					Vector3 povoffset = (48, -24, 48);

					povcamera.angle = turret.angle;
					if (gun) { povcamera.pitch = gun.pitch; }
					else { povcamera.pitch = turret.pitch; }

					Vector2 temp = RotateVector((povoffset.y, povoffset.z), turret.roll);
					Vector3 offset = (povoffset.x, temp.x, temp.y);

					temp = RotateVector((offset.x, offset.z), 360 - turret.pitch);
					offset = (temp.x, offset.y, temp.y);

					temp = RotateVector((offset.x, offset.y), turret.angle);
					offset = (temp.x, temp.y, offset.z);

					povcamera.SetOrigin(turret.pos + offset, true);

					povcamera.roll = turret.roll;

					povcamera.CameraFOV = player.fov * 1.2;

					player.camera = povcamera;
				}
			}
			else
			{
				double modifier, pitchmodifier;

				if (pitch < 0) { modifier = 48 * sin(-pitch); } // Aiming up moves the camera up so you can keep the aimpoint on screen
				else { modifier = 96 * sin(pitch * 3); } // Aiming down actually moves the camera *up*, so that you can see the aimpoint over the top of the turret

				modifier += (turret.pitch > 0 ? 96 : 128) * sin(turret.pitch); // Move the camera up/down when going up/downhill
				pitchmodifier = (turret.pitch > 0 ? -15 : 10) * sin(turret.pitch); // Pitch the camera up/down when going up/downhill

				turret.LineTrace(angle + 180, 2.5 * radius, pitchmodifier, TRF_THRUHITSCAN | TRF_THRUACTORS, turret.height + 32 + modifier, 0.0, 0.0, cameratrace);

				turretcamera.SetOrigin(cameratrace.HitLocation + AngleToVector(angle, 2), true);
				turretcamera.angle = angle;
				turretcamera.pitch = turret.pitch;

				turretcamera.CameraFOV = player.fov;

				player.camera = turretcamera;
			}
		}
		else
		{
			player.camera = player.mo;
		}

		if (player.usedown)
		{
			useholdtime++;
			if (useholdtime == 1) { HintMessage.Init(player.mo, "TANKEXITHOLD", "+use"); }
		}
		else { useholdtime = 0; }


		if (useholdtime >= 35)
		{
			A_SetInventory("ShakeShaderControl", 1);
			if (treads) {treads.usetimeout = 35; }
			TakeInventory(powerupclass, 1);
		}
	}

	Actor GetClosestForcedHealthBar()
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

	void DoTrace(Actor origin, double angle, double dist, double pitch, int flags, double zoffset, BoAFindHitPointTracer thistracer)
	{
		if (!origin) { origin = self; }

		thistracer.skipspecies = origin.species;
		thistracer.skipactor = origin;
		Vector3 tracedir = ZScriptTools.GetTraceDirection(angle, pitch);
		thistracer.Trace(origin.pos + (0, 0, zoffset), origin.CurSector, tracedir, dist, 0);
	}

	override bool UndoPlayerMorph(playerinfo activator, int unmorphflag, bool force)
	{
		if (!activator || !activator.mo) { return false; }

		int premorphhealth;

		for (Inventory i = activator.mo.inv; i != null; i = i.Inv)
		{
			if (i is "TankMorph")
			{
				if (TankMorph(i).premorphhealth) { premorphhealth = TankMorph(i).premorphhealth; }
				break;
			}
		}

		// This call forces the player health to full Spawn Health, so we have to re-asjudt health after this point
		// Setting the third argument (force) to true ensures that all of the morph cleanup code runs even if the
		// player spawn fails so that we can gracefully handle player location in the TankMorph powerup code.
		bool ret = Super.UndoPlayerMorph(activator, unmorphflag, true); 

		activator.health = activator.mo.health = premorphhealth;

		return ret;
	}
}

Class BoAFindHitPointTracer : LineTracer
{
	Name skipspecies;
	Actor skipactor;

	override ETraceStatus TraceCallback() // Doesn't handle 3d Floors :-/
	{
		if (Results.HitType == TRACE_HitActor)
		{
			if (
				Results.HitActor != skipactor && // Skip the player
				!(Results.HitActor is "TankPlayer") &&
				(!Results.HitActor.master || Results.HitActor.master != skipactor) && // And any children
				Results.HitActor.species != skipspecies && // And any of the skipped species
				(Results.HitActor.bSolid || Results.HitActor.bShootable) // And only return shootable actors
			) { return TRACE_Continue; } // Fall through, but remember the actor that you hit

			return TRACE_Skip;
		}
		else if (Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling)
		{
			return TRACE_Stop;
		}
		else if (Results.HitType == TRACE_HitWall)
		{
			if (Results.HitLine.flags & Line.ML_BLOCKING || Results.HitLine.flags & Line.ML_BLOCKEVERYTHING) { return TRACE_Stop; }
			if (Results.HitTexture)
			{
				if (Results.Tier != TIER_Middle || Results.HitLine.flags & Line.ML_3DMIDTEX) // 3D Midtex check still isn't perfect...
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

class Nothing : Actor
{
	Default
	{
		+NOBLOCKMAP
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Stop;
	}
}

class TankMorph : PowerMorph
{
	int armor;
	double hexenarmorslots[5];
	int premorphhealth;
	double savepercent;
	class<TankPlayer> actorclass;
	property ActorClass: actorclass;

	Default
	{
		PowerMorph.MorphStyle MRF_LOSEACTUALWEAPON | MRF_NEWTIDBEHAVIOUR | MRF_UNDOBYDEATHSAVES;
		PowerMorph.MorphFlash "Nothing"; // Why isn't there an option to NOT spawn fog at all?
		PowerMorph.UnMorphFlash "Nothing";
		Powerup.Duration 0x7FFFFFFF;
	}

	override void InitEffect() 
	{
		if (owner && owner.player)
		{
			owner.TakeInventory("BoASprinting", 1);
			owner.TakeInventory("BoAHeartbeat", 1);

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

			FilterInventoryBar(true);
		}

		Super.InitEffect();
	}

	override void EndEffect()
	{
		if (MorphedPlayer && MorphedPlayer.mo)
		{
			let tank = TankPlayer(MorphedPlayer.mo);

			if (tank)
			{
				if (tank.treads)
				{
					tank.treads.bSolid = true;
					tank.treads.master = null;
					if (TankTreadsBase(tank.treads))
					{
						TankTreadsBase(tank.treads).savedhealth = tank.health;
						TankTreadsBase(tank.treads).usetimeout = 35;
					}
				}
				if (tank.turretcamera) { tank.turretcamera.Destroy(); }
				if (tank.povcamera) { tank.povcamera.Destroy(); }

				// Restore pitch clamping, since this doesn't get reset otherwise
				MorphedPlayer.MinPitch = -90;
				MorphedPlayer.MaxPitch = 90;

				if (tank.health <= 0) { tank.treads.SetStateLabel("Death"); }

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

				// Reposition the player so that it's not inside of the tank
				Vector3 newpos = tank.pos + (0, 0, tank.height); // Dump the player on top of the body of the tank
				if (tank.turret) { newpos = tank.turret.pos + (0, 0, tank.turret.height); } // Dump the player on top of the turret if there is one

				MorphedPlayer.mo.SetOrigin(newpos, false);

				for (
					int i = 0;
					i <= 4 && !MorphedPlayer.mo.TestMobjLocation();
					i++
				)
				{
					// Try different spots around the tank if spawning on top didn't work
					switch(i)
					{
						case 1:
							newpos = tank.pos + (RotateVector((0, -128), tank.angle), 0);
							break;
						case 2:
							newpos = tank.pos + (RotateVector((0, 128), tank.angle), 0);
							break;
						case 3:
							newpos = tank.pos + (RotateVector((192, 0), tank.angle), 0);
							break;
						case 4:
							newpos = tank.pos + (RotateVector((-192, 0), tank.angle), 0);
							break;
						default:
							// Worst case, leave you crammed into the space between the tank and the ceiling.
							// Possibly stuck, but still able to get back in the tank.
						case 0:
							break;
					}

					MorphedPlayer.mo.SetOrigin(newpos, false);
				}
			}

			ResetInventoryBar();
		}
 
		Super.EndEffect();
	}

	override void Tick()
	{
		Super.Tick();

		if (owner && owner is "TankPlayer") { FilterInventoryBar(); }
	}

	void FilterInventoryBar(bool set = false)
	{
		Inventory cur = owner.Inv;

		while (cur)
		{
			if ( // Unfortunately hard-coded list of inventory items that can be used while driving a tank
				cur is "RepairKit" || 
				cur is "BoACompass"
			)
			{
				cur.bInvBar = true;
				if (set && !cur.Default.bInvbar) { PlayerPawn(owner).InvSel = cur; } // Automatically select an item that wasn't previously on the inventory bar to highlight that it's there now
			}
			else { cur.bInvBar = false; }
			if (cur is "PoweredInventory")
			{ // Ensure PoweredInventory (Lantern and Mine sweeper) items are turned off when player enters a tank
				PoweredInventory(cur).active = false;
			}
			cur = cur.Inv;
		}

		SelectValidInventory();
	}

	void ResetInventoryBar()
	{
		Inventory cur = MorphedPlayer.mo.Inv;

		while (cur)
		{
			cur.bInvBar = cur.Default.bInvBar;
			cur = cur.Inv;
		}

		SelectValidInventory();
	}

	void SelectValidInventory()
	{
		if (!PlayerPawn(owner).InvSel) { PlayerPawn(owner).InvSel = PlayerPawn(owner).Inv; }
		if (!PlayerPawn(owner).InvSel.bInvBar) { PlayerPawn(owner).InvSel = PlayerPawn(owner).InvSel.NextInv(); } // Make sure a valid inventory item is selected
	}
}

///////////////////////////
// ACTUAL DRIVABLE TANKS //
///////////////////////////

class Sherman: TankMorph
{
	default
	{ //both are necessary, since we have to inherit from PowerMorph
		PowerMorph.PlayerClass "ShermanPlayer";
		TankMorph.ActorClass "ShermanPlayer";
	}
}

class ShermanPlayer: TankPlayer
{
	default
	{
		Player.MorphWeapon "Cannon75mm";
		Player.StartItem "Cannon75mm";
		Player.WeaponSlot 1, "Cannon75mm";
		TankPlayer.TreadsClass "US_Sherman";
		TankPlayer.PowerupClass "Sherman";
	}
}

class PanzerIVPlayer: ShermanPlayer
{ //modders should inherit from TankPlayer directly
	default
	{
		Player.MorphWeapon "Cannon75mmKwK";
		Player.StartItem "Cannon75mmKwK";
		Player.WeaponSlot 1, "Cannon75mmKwK";
		TankPlayer.TreadsClass "PanzerIVTreads";
		TankPlayer.PowerupClass "PanzerIV";
	}
}

class PanzerIV : Sherman //can also inherit directly from TankMorph
{
	Default
	{
		PowerMorph.PlayerClass "PanzerIVPlayer";
		TankMorph.ActorClass "PanzerIVPlayer";
	}
}