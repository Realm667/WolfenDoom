/*
 * Copyright (c) 2015-2021 MaxEd, AFADoomer
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
*/

// Converted to ZScript by AFADoomer from ACS code written by MaxEd
// Now used by all actors that need to have standard footsteps in-game - Players, Nazis, PlayerFollowers, etc.

class BoAFootsteps : Inventory
{
	int curStepDistance;
	Vector3 oldpos;
	bool step;
	int stepdistance, noise;
	EffectsManager manager;

	Property StepDistance:stepdistance;
	Property Noise:noise;

	Default
	{
		+Inventory.Undroppable
		BoAFootsteps.StepDistance 76;
		BoAFootsteps.Noise 0; // This was 10 in the original MaxEd/2015 ACS implementation
	}

	override void Tick()
	{
		Super.Tick();

		if (!owner) { Destroy(); return; }
		if (owner && owner.health <= 0) { return; }
		if (!manager) { manager = EffectsManager.GetManager(); }

		DoFootstepSounds();
	}

	void DoFootstepSounds()
	{
		if (oldpos == (0, 0, 0)) { oldpos = owner.pos; }
		else if (owner.pos == oldpos) { return; }

		if (manager)
		{
			int interval;
			bool forceculled;

			[interval, forceculled] = manager.Culled(owner.pos.xy);
			if (forceculled || interval > 1) { return; }
		}

		if (!owner.player && !owner.CheckRange(768, true)) { return; } // Don't play non-player footsteps if no players are around

		if (owner.waterlevel > 2) { return; }

		if (owner.pos.z == max(owner.curSector.NextLowestFloorAt(owner.pos.x, owner.pos.y, owner.pos.z), owner.floorz)) // If on the floor
		{
			if (curStepDistance > stepdistance)
			{
				step = !step; // Alternate between the left and right step sounds; unused (left and right sounds are the same), but works if configured
				Sound stepsound = GetStepSound(owner, step);

				if (owner.player && owner.player.crouchfactor == 0.5) //different step sounds while crouching
				{
					owner.A_StartSound(stepsound, CHAN_AUTO, CHANF_DEFAULT, 0.1);
					owner.A_StartSound("floor/dirt", CHAN_AUTO, CHANF_DEFAULT, 0.2);
				}
				else
				{
					owner.A_StartSound(stepsound, CHAN_AUTO, CHANF_DEFAULT, 1.0);
					/*
						This was intended to add directly to visibility originally, but was broken pre-C2 release; the ACS call tried
						to set the visibility value of the player, not their visibility inventory item. This is kind of unnecessary
						now, since movement speed increases visibility, and this would change gameplay some, but I'll leave it here in
						case a modder wants to do something with it...  Just need to modify the Noise property in the Default block of
						an inherited/replaced version of this class.
					*/
					if (noise > 0)
					{
						BoAVisibility vis = BoAVisibility(owner.FindInventory("BoAVisibility"));
						if (vis) { vis.noiselevel = noise; }
					}
				}

				curStepDistance = 0;
			}
			else
			{
				curStepDistance += int((oldpos.xy - owner.pos.xy).length());
			}

			oldpos = owner.pos;
		}
		else
		{
			curStepDistance = 0;
		}
	}

	static Sound GetStepSound(Actor origin, bool which)
	{
		// Read the sound directly from the terrain definition instead of spawning an actor to cause a splash
		TerrainDef ground = origin.GetFloorTerrain();
		Sound stepsound;

		if (ground)
		{
			if (which) { stepsound = ground.leftstepsound; }
			else { stepsound = ground.rightstepsound; }
		}

		if (!stepsound) { stepsound = "floor/dirt"; } // Fall back to the dirt sound if nothing was found.

		return stepsound;
	}
}

// Used by PlayerFollower to spawn a splash when entering water
class SplashStep: Actor
{
	Default
	{
		Speed 0;
		Gravity 10;
		+CORPSE
	}
	States
	{
		Spawn:
			TNT1 A 1;
			Wait;
		Crash:
			"####" A 1;
			Stop;
	}
}