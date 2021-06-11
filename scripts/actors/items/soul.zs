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

class Soul : StackableInventory
{
	String msg;
	bool large;
	int loops, oldamount;
	int user_amount;
	double destscale;

	Default
	{
		//$Category Powerups (BoA)
		//$Title Souls (+1)
		//$Color 6
		//$Sprite AMM3A0
		+FLOATBOB
		+FORCEXYBILLBOARD
		+DONTSPLASH // Don't make footstep sounds
		Inventory.Amount 1;
		Inventory.MaxAmount 9999;
		Inventory.Icon "SOUL01";
		Inventory.PickupMessage "$SOUL_SM";
		Inventory.PickupSound "DSSLPU";
		Gravity 0.5;
		Speed 7;
		Renderstyle "Translucent";
		Alpha 0.8;
	}

	States
	{
		Placed:
			AMM3 ABCD 5 Bright;
			Loop;
		Spawn:
			AMM3 ABCD 5 Bright A_SoulSeek();
			AMM3 A 0 { if (loops++ < 20) { SetStateLabel("Spawn"); } } // Loop animation 20 times before starting fade; this logic also allows loops to be reset in code
		Fadeout:
			AMM3 ABCD 5 Bright
			{
				A_SoulSeek();
				A_FadeOut(0.05);
			}
			Loop;
		Merge:
			AMM3 ABCD 5 Bright
			{
				A_SoulSeek();
				A_FadeOut(0.1);
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		msg = PickupMsg;
		oldamount = Amount;

		if (user_amount) { Amount = user_amount; }

		if (GetClassName() == "Soul")
		{
			if (!bDropped) { SetStateLabel("Placed"); }
			else
			{
				// Give minor random initial velocity
				vel.x = FRandom(-2.0, 2.0);
				vel.y = FRandom(-2.0, 2.0);
				vel.z = FRandom(-2.0, 0.1);

				A_AttachLight("Glow", DynamicLight.PointLight, 0x78FF73, 24, 0, DynamicLight.LF_ATTENUATE, (0.0, 0.0, 32.0));
			}
		}
	}

	override void Tick()
	{
		if (globalfreeze || level.frozen) { return; }

		Super.Tick();

		if (!owner && !bNoSector)
		{
			A_AttachLight("Glow", DynamicLight.PointLight, 0x78FF73, int((24 + 8.0 * ((Amount - 3) / 22)) * alpha / Default.alpha), 0, DynamicLight.LF_ATTENUATE, (0.0, 0.0, 32.0));

			if (CurState && tics == CurState.tics) // Run this logic at the beginning of every new frame
			{
				if (large) { frame += 4; } // Offset the frames once you hit 3 souls in order to use the larger soul sprite and match the SoulBig pickup
			}

			if (Amount > oldamount)
			{
				DoScaling(); // Update scale, sprite frame, and pickup message
				oldamount = Amount;
			}

			if (destscale && destscale > scale.x) // Smooth scaling to increase size over time.
			{
				scale = min(destscale, scale.x * 1.01) * (1, 1);
				floorclip = -16 * (1.0 - (scale.x / Default.scale.x));
			}

			if (bDropped)
			{
				if (Level.time % 2 == 0 && vel.length() > 0.1)
				{
					Actor sf = Spawn("SoulTrail", pos - vel);
					if (sf) { sf.master = self; }
				}

				if (target is "Soul" && Distance3D(target) < 32.0)
				{
					if (floatbobphase > target.floatbobphase) { floatbobphase--; }
					else if (floatbobphase < target.floatbobphase) { floatbobphase++; }
				}
			}
		}
		else
		{
			A_RemoveLight("Glow");
		}
	}

	Actor FindClosestPlayer(Actor existing = null, int distance = 256)
	{
		Actor targetPlayer = null;
		for (int player = 0; player < MAXPLAYERS; player++)
		{
			if (!playeringame[player]){ continue; }

			double pdist = Distance2D(players[player].mo);
			if (pdist > distance || (existing && existing.player && pdist > Distance2D(existing))) { continue; }

			// Don't target players who already have full soul amount
			let i = players[player].mo.FindInventory(self.GetClass());
			if (i && i.Amount >= MaxAmount) { continue; }

			targetPlayer = players[player].mo;
		}
		return targetPlayer;
	}

	void A_SoulSeek(int distance = 256)
	{
		if (Amount && bSpecial) // If we're still a valid pickup (not absorbed by another soul and disappearing), look for a new seek target...
		{
			bSolid = true; // Needed for collision detection handling while flying

			target = FindClosestPlayer(target, distance); // Prefer to target a player

			BlockThingsIterator it = BlockThingsIterator.Create(self, 64); // But also move toward other souls

			while (it.Next())
			{
				if (it.thing == self) { continue; }
				if (it.thing.GetClassName() == "Soul")
				{
					let s = Soul(it.thing);
					if (!target || (s.target == target && s.Distance3D(target) < Distance3D(target))) { target = s; } // Merge with souls heading to the same target

					break;
				}
			}
		}

		if (target && self != target.target)
		{
			bNoGravity = true;

			double sp = Speed - Amount / 25.0; // Move more slowly toward the player as Amount increases

			let s = Soul(target); // Move much more slowly toward other souls
			if (s)
			{
				if (bSpecial)
				{
					if ( Amount + s.Amount > 25 ) { sp = -0.12; } // If at max amount, move away from other souls
					else { sp = 0.5 + Soul(target).Amount / 25.0; } // Otherwise move more quickly the more souls the target has
				}
				else
				{
					sp = 0.5;
				}
			}

			// Original targeting algorithm by Talon1024 / Kevin Caccamo
			Vector2 posDiff = Vec2To(target);
			double distance = posDiff.Length();
			Vel.XY = posDiff / max(1, distance) * sp;
			double middle = target.Pos.Z + max(0, target.Height / 2 - height); // Account for the soul actor height when aiming at target
			Vel.Z = sp / max(1, distance) * (middle - Pos.Z);
		}
		else
		{
			vel.z = min(vel.z, -0.1);
			bNoGravity = false;
		}
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (other)
		{
			if (Amount && other.player) { Touch(other); } // Try to pick up even if the player isn't moving
			else if (Amount && other.GetClassName() == "Soul" && Distance3D(other) <= 12.0) // Try to absorb another soul when hit
			{
				let s = Soul(other);

				if (s.Amount >= Amount && s.Amount + Amount <= 25)
				{
					s.loops = 0; // Reset fadeout animation time for the growing soul orb
					s.Amount += Amount; // Add the value of this orb to the other orb

					A_StartSound("DSSLPU", CHAN_VOICE, 0, 0.25, ATTN_STATIC, 0.125);

					Amount = 0;
					bSpecial = false;
					target = s;
					SetStateLabel("Merge");
				}
			}
		}

		return false; // Treat as non-solid in all other cases
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(msg);
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}

	// Update scale, sprite frame, and pickup message based on current Amount value
	void DoScaling()
	{
		if (Amount >= 25) { msg = StringTable.Localize("$SOUL_XBG"); }

		// Set actual scale amounts
		if (Amount < 3) // Scale small sprite up slightly when adding each soul
		{
			scale *= 1.1;
		}
		else if (Amount >= 25) // At maximum size, match appearance and message of the SoulSuperBig powerup
		{
			destscale = Default.scale.x;
			floorclip = Default.floorclip;
		}
		else // Scale up to full size in steps, based on how many souls have been added
		{
			if (!large) { scale = Default.scale / 2; } // If not yet tagged as large, reset the scale
			destscale = Default.scale.x / 2 * (1.0 + (Amount - 3) / 22.0);
		}

		if (Amount > 2) { large = true; } // Use the larger sprite and glow for amounts 3 or higher
	}
}

class SoulBig : Soul
{
	Default
	{
		//$Category Powerups (BoA)
		//$Title Souls (+3)
		//$Color 6
		//$Sprite AMM3E0

		Scale 0.5;
		Inventory.Amount 3;
		Inventory.PickupMessage "$SOUL_BG";
	}

	States
	{
		Spawn:
			AMM3 EFGH 4 Bright;
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		floorclip = -16.0; // Adjust apparent height of sprite off of ground after scaling down
	}
}

class SoulSuperBig : Soul
{
	Default
	{
		//$Category Powerups (BoA)
		//$Title Souls (+25)
		//$Color 6
		//$Sprite AMM3E0

		Inventory.Amount 25;
		Inventory.PickupMessage "$SOUL_XBG";
	}

	States
	{
		Spawn:
			AMM3 EFGH 4 Bright;
			Loop;
	}
}


class SoulTrail : ParticleBase
{
	int steps;

	Default
	{
		+FLOATBOB
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
		+NOGRAVITY
		Alpha 0.6;
		DistanceCheck "boa_sfxlod";
		RenderStyle "Add";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!master) { Destroy(); }
		else
		{
			sprite = master.sprite;
			frame = master.frame;
			scale = master.scale;
			vel = master.vel;
			bFloatBob = master.bFloatBob;
			floatbobphase = master.floatbobphase;
			floorclip = master.floorclip;

			steps = max(4, int(3 * master.vel.length()));
		}
	}

	override void Tick()
	{
		if (globalfreeze || level.frozen) { return; }

		alpha -= Default.alpha / steps;

		if (master) { alpha *= master.alpha / master.Default.alpha; }

		if (alpha <= 0) { Destroy(); }
	}
}