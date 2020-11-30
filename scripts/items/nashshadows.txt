//===========================================================================
//
// SpriteShadow
//
// Duke3D-style Actor Shadows
//
// Written by Nash Muhandes
//
// Feel free to use this in your mods. No need to ask for my permission!
//
// * This version contains additional BoA-specific changes by other authors!
//    - Shadows grow in size and fade away as the z-height of their parent
//	actor above the floor z-height increases.
//    - Shadows fade as the player moves away from them, and completely
//	disappear when the player is the set render distance away.
//    - BoA 'Base' class actor descendants have a 'shadow' boolean that
//	can be used to directly set whether they are shadowed or not.
//    - The 'Z_DontShadeMe' actor can be given to any actor that would
//	normally be shadowed in order to keep a shadow from being drawn.
//
// * Original source: https://forum.zdoom.org/viewtopic.php?f=105&t=54992
//
//===========================================================================

class Z_SpriteShadow : Actor
{
	Default
	{
		Alpha 0.0;
		RenderStyle "Stencil";
		StencilColor "Black";
		+NOBLOCKMAP
		+NOINTERACTION
		+NOTONAUTOMAP
	}

	Actor caster;
	Inventory casterHasShadow;
	bool bStopTicking;
	double heightdelta;

	transient CVar cvShadowDistance;
	double shadowDist;

	void UpdateShadowDistance(void)
	{
		if (!cvShadowDistance) return;
		shadowDist = cvShadowDistance.GetFloat();
	}

	override void PostBeginPlay()
	{
		cvShadowDistance = CVar.FindCVar("boa_spriteshadowdistance");
		UpdateShadowDistance();
		Super.PostBeginPlay();
	}

	override void Tick(void)
	{
		if (!cvShadowDistance || (!bNoTimeFreeze && (isFrozen() || Level.isFrozen()))) return;

		if (!bStopTicking)
		{
			Super.Tick();
			bStopTicking = true;
			return;
		}
		else if (!shadowDist || (caster && caster.CheckSightOrRange(shadowDist)))
		{
			return;
		}
		else
		{
			if (caster && players[consoleplayer].camera)
			{
				casterHasShadow = caster.FindInventory("Z_ShadeMe");

				// filter your own shadow and hide it from your first person view
				if (caster is "PlayerPawn" && players[consoleplayer].mo == caster)
				{
					if (players[consoleplayer].camera == players[consoleplayer].mo && !(caster.player.cheats & CF_CHASECAM))
					{
						bInvisible = true;
					}
					else
					{
						bInvisible = false;
					}
				}
				else
				{
					let c = players[consoleplayer].camera;

					if (c && c.CheckLocalView(consoleplayer))
					{
						// hide shadow if you are under the monster
						if (c && c.Pos.Z + (c.player ? c.player.viewheight : c.GetCameraHeight()) < Pos.Z)
							bInvisible = true;

						// always visible for monsters
						else bInvisible = false;
					}
					else
					{
						return;
					}
				}

				double zheight = caster.floorz;
				double shadowzdist = 128.0;


				// Only check if you're on top of a thing if you're not on the ground already
				// and are a player or can float.  Reduces processing overhead from FindOnMobj
				// function, which calls a BlockThingsIterator
				if ((caster.player || caster.bFloat) && caster.pos.z > floorz) 
				{
					Actor onmo = FindOnMobj(caster, shadowzdist);
					if (onmo && onmo.pos.z + onmo.height > floorz) { zheight = onmo.pos.z + onmo.height; }
				}

				heightdelta = max(1.0 - ((caster.pos.z - zheight) / shadowzdist), 0.001); // Difference between z position of parent actor and the floor height, as a percentage of an arbitrary number of units (with a min value to avoid division by 0)

				// sync size of bounding box
				if (Radius != caster.Radius || Height != caster.Height)
				{
					A_SetSize(caster.Radius, caster.Height);
				}

				// sync sprites and angle
				Sprite = caster.Sprite;
				Frame = caster.Frame;
				Angle = caster.Angle;

				// sync alpha
				alpha = caster.alpha * 0.5 * heightdelta; // heightdelta makes shadows that are farther from the parent actor more transparent

				// fade the shadow out along a smooth curve as you get closer to the defined max draw distance
				alpha *= cos(clamp(Distance2D(players[consoleplayer].camera) / shadowDist, 0.0, 1.0) * 180) / 2 + 0.5;

				// sync scale
				Scale.X = caster.Scale.X / clamp(heightdelta, 0.666, 1.0); // heightdelta makes shadows that are farther from the parent actor bigger (clamped to 1.5x size)

				Scale.Y = caster.Scale.Y * 0.1 / clamp(heightdelta, 0.666, 1.0); // heightdelta makes shadows that are farther from the parent actor bigger (clamped to 1.5x size)


				// sync position (offset shadow away from local camera)
				if (!players[consoleplayer].camera) return;
				Vector3 sPos = (
					caster.Pos.X + cos(players[consoleplayer].camera.Angle) * 0.01,
					caster.Pos.Y + sin(players[consoleplayer].camera.Angle) * 0.01,
					zheight
					);
				SetOrigin(sPos, true);

				return;
			}
			else if (!caster || (caster && !casterHasShadow))
			{
				// clean-up
				Destroy();
				return;
			}
		}
	}

	// Finds a walkable actor underneath 'origin' actor, within 'range' height distance...
	Actor FindOnMObj(Actor origin, double range = 0)
	{
		BlockThingsIterator it = BlockThingsIterator.Create(origin, 1);

		while (it.Next())
		{
			let mo = it.thing;

			if (
				mo == self || // Ignore self
				!mo.bSolid || // Ignore non-solids
				mo.bIsMonster || // Ignore monsters
				mo.player || // Ignore players
				abs(mo.pos.x - origin.pos.x) > origin.radius + mo.radius || // Ignore if outside of hitbox footprint
				abs(mo.pos.y - origin.pos.y) > origin.radius + mo.radius    //  (using square hitboxes)
			) { continue; } 

			if (origin.pos.z >= mo.pos.z + mo.height && origin.pos.z <= mo.pos.z + mo.height + range)
			{
				return mo;
			}
		}

		return null;
	}
}

// REFRESH_PERIOD / SHADOW_MAX_AGE balances CPU perfomance against shadow
// appear/disappearance liveness.

// shadows are "refreshed" every 0.5s.
const REFRESH_PERIOD = 17;

// "un-refreshed" shadows die after 1s.
const SHADOW_MAX_AGE = 2 * REFRESH_PERIOD;

class Z_ShadeMe : CustomInventory
{
	Default
	{
		FloatBobPhase 0;
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
	}

	Z_SpriteShadow myShadow;
	int countFromLastUpdate;
	int maxShadowAgeInTicks;
	bool shadowCloseEnoughToPlayer;


	void SetEnableShadow(bool bEnable)
	{
		if (bEnable)
		{
			// reset mark date at enable only.
			countFromLastUpdate = 0;
		}
		if (bEnable != self.shadowCloseEnoughToPlayer)
		{
			if (bEnable)
			{
				if (!self.myShadow)
				{
					let sh = Z_SpriteShadow(Spawn("Z_SpriteShadow", Owner.Pos, NO_REPLACE));

					if (sh)
					{
						self.myShadow = sh;
						self.myShadow.caster = Owner;
					}
					//Console.PrintF("+++ Add shadow to %s ",self.GetClassName());
				}
			}
			else
			{
				// destroy the shadow because disabled, or too far from the player.
				if (self.myShadow)
				{
					self.myShadow.Destroy();
					self.myShadow = null;
					//Console.PrintF("--- DESTROY shadow to %s ",self.GetClassName());
				}
			}

			// update
			self.shadowCloseEnoughToPlayer = bEnable;
		}
	}


	override void PostBeginPlay()
	{
		self.shadowCloseEnoughToPlayer = false;

		// If the Shadow owner if a Player, its shadow age is "infinite", i.e set to 0.
		let pmo = PlayerPawn(Owner);
		if (pmo)
		{
			self.maxShadowAgeInTicks = 0;
		}
		else
		{
			self.maxShadowAgeInTicks = SHADOW_MAX_AGE;
		}

		self.SetEnableShadow(true);
		Super.PostBeginPlay();
	}


	override void Tick()
	{
		countFromLastUpdate++;

		// Cleanup : Shadow is too old, it means it has not been tested
		// for player proximity for a long time, which means it is indeed too far !
		if (maxShadowAgeInTicks > 0 && countFromLastUpdate > maxShadowAgeInTicks)
		{
			self.SetEnableShadow(false);
			Destroy();
			return;
		}

		Super.Tick();
	}

	States
	{
		Use:
			TNT1 A 0;
			Fail;
		Pickup:
			TNT1 A 0 { return true; }
			Stop;
	}
}

class Z_DontShadeMe : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
	}
}

class SpriteShadowHandler : EventHandler
{
	transient CVar cvShadowDistance;

	int countTicks;

	override void OnRegister()
	{
		cvShadowDistance = CVar.FindCVar("boa_spriteshadowdistance");
	}

	// Player-specific stuff
	void DoSpawnPlayerShadow(PlayerPawn p)
	{
		if (p) p.A_GiveInventory("Z_ShadeMe", 1);
	}

	void DoRemovePlayerShadow(PlayerPawn p)
	{
		if (p)
		{
			let shadeMe = Z_ShadeMe(p.FindInventory("Z_ShadeMe"));
			if (shadeMe)
			{
				shadeMe.SetEnableShadow(false);
				shadeMe.Destroy();
			}
		}
	}

	override void PlayerEntered(PlayerEvent e)
	{
		let p = players[e.PlayerNumber].mo;
		if (p) DoSpawnPlayerShadow(p);


		// make it shadows appear next WorldTick:
		countTicks = -1;
	}

	override void PlayerRespawned(PlayerEvent e)
	{
		let p = players[e.PlayerNumber].mo;
		if (p) DoSpawnPlayerShadow(p);
	}

	override void PlayerDied(PlayerEvent e)
	{
		let p = players[e.PlayerNumber].mo;
		if (p) DoRemovePlayerShadow(p);
	}

	override void WorldUnloaded(WorldEvent e)
	{
		// player is leaving this level, so mark their shadows for destruction
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			let p = players[i].mo;

			if (p && playeringame[i])
			{
				DoRemovePlayerShadow(p);
			}
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		// make it shadows appear next WorldTick:
		countTicks = -1;
	}

	override void WorldTick(void)
	{
		// 0) Save game : do not serialize shadows.
		if (gameaction == ga_savegame || gameaction == ga_autosave)
		{
			ThinkerIterator it = ThinkerIterator.Create("Z_ShadeMe");
			Z_ShadeMe shadeMe;
			while (shadeMe = Z_ShadeMe(it.Next()))
			{
				// Destroy all shadows, and Z_ShadeMe (including Player's)
				// Shadows will be re-created at next WorldTicks().
				if (shadeMe)
				{
					shadeMe.SetEnableShadow(false);
					shadeMe.Destroy();
				}
			}

			// Trick so that the next Shadow monsters re-creation will only occur in REFRESH_PERIOD ticks.
			countTicks = 0;
		}

		countTicks++;

		// no need to update this too often
		if (countTicks % REFRESH_PERIOD != 0) return;

		PlayerInfo p = players[consoleplayer];
		if (!p) return;

		double shadowDist = GetShadowDistance();
		bool shadows_enabled = !!(shadowDist > 0);

		// 1) Update Player shadows according to current setting.
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			let pmo = players[i].mo;
			if (pmo && PlayerInGame[i])
			{
				let shadeMe = Z_ShadeMe(pmo.FindInventory("Z_ShadeMe"));

				if (shadeMe && !shadows_enabled)
				{
					shadeMe.SetEnableShadow(false);
					shadeMe.Destroy();
				}
				else if (shadeMe == null && shadows_enabled)
				{
					// lazy creation of Z_ShadeMe. The shadow itself is created in Z_ShadeMe.PostBeginPlay().
					pmo.A_GiveInventory("Z_ShadeMe", 1);
				}
			}
		}

		// 2) Update Monster shadows enabling flag to Z_ShadeMe according to distance to player:
		// look for shadow casters around you
		BlockThingsIterator it = BlockThingsIterator.Create(p.mo, shadowDist);
		while (it.Next())
		{
			Actor mo = it.thing;

			// only consider monster-tagged things:
			if (!mo.bIsMonster || mo is "PlayerPawn" || (mo is "Base" && !Base(mo).shadow) || mo.CountInv("Z_DontShadeMe") || (mo is "CKBaseEnemy" && CKBaseEnemy(mo).noshadow)) continue;

			let shadeMe = Z_ShadeMe(mo.FindInventory("Z_ShadeMe"));

			bool display_shadows = shadows_enabled && (mo.Distance2DSquared(p.mo) < shadowDist ** 2);

			if (shadeMe)
			{
				shadeMe.SetEnableShadow(display_shadows);
			}
			else if (display_shadows)
			{
				// lazy creation of Z_ShadeMe. The shadow itself is created in Z_ShadeMe.PostBeginPlay().
				mo.A_GiveInventory("Z_ShadeMe", 1);
			}
		}
	}

	double GetShadowDistance(void)
	{
		if (!cvShadowDistance) return 0;
		return cvShadowDistance.GetFloat();
	}
}