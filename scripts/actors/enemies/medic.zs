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

  An actor that looks for dead 'Nazi' class actors to be healed.

  Automatically searches for the closest visible dead 'Nazi' actor that it is allied with (that
  has the same FRIENDLY flag settings) that is not gibbed or burned to ash.  Once the actor is
  identified, the Medic sets the actor as its goal and runs to it.

  Once within range of the goal actor (24 units centerpoint to centerpoint), the Medic enters its
  "Heal" state and begins to resurrect the dead actor.

  While the dead actor is being healed, "HealingParticle" actors are spawned from the dead actor.
  The number of particles spawned, and the number of repetitions of the "Heal" state animation that
  are played, is based on the spawn health of the dead actor; one iteration of the heal animation
  (5 particle spawns) for every 25 hitpoints, with a maximum of 3 iterations.

  The now ressurected actor's target is cleared, and, if they are sneakable, they are set idle.

  The Medic also tries to avoid the player, by running away if a player is visible within 192
  units.  When this happens, the medic also forgets what dead body it was going toward.

  Also can work as FRIENDLY, healing only the FRIENDLY dead actors.

*/
class NaziMedic : NaziStandard
{
	bool crouched;

	Default
	{
		//$Category Monsters (BoA)/Others
		//$Title Nazi Medic
		//$Color 4
		Health 20;
		PainChance 64;
		Speed 4;
		+ALLOWPAIN
		+AVOIDMELEE
		+NODAMAGE
		+NEVERTARGET
		Base.NoMedicHeal;
		Nazi.CanSurrender True;
		Nazi.Healer HLR_ALLIES;
		Nazi.HealSound "misc/health_pkup";
		DropItem "NaziMedicBox", 255;
	}

	States
	{
		Spawn:
			NMDC N 1; // Just sets the base sprite
			Goto Look;
		Look:
			"####" "#" 35 A_LookForBodies();
			"####" "#" 0 A_CheckForPlayer(True);
			Loop;
		See:
			Goto See.Dodge;
		Dodge:
			NMDD A 0;
		Dodge.Resume:
			Goto See.Heal;
		See.Heal:
			"####" "#" 0 {
				user_incombat = true;
				crouched = false;
				bChaseGoal = true;
				bSolid = true;

				A_CheckForPlayer();

				Speed = bFrightened ? FRandom(4,6) : Default.Speed;
			}
			"####" AAAAAA 1 A_WanderGoal(0, 512);
			"####" # 0 A_PlayStepSound();
			"####" BBBBBB 1 A_WanderGoal(0, 512);
			"####" B 0 A_CheckForPlayer();
			"####" CCCCCC 1 A_WanderGoal(0, 512);
			"####" # 0 A_PlayStepSound();
			"####" DDDDDD 1 A_WanderGoal(0, 512);
			"####" A 0 {
				if (bFrightened && frightener)
				{
					if (!CheckSight(frightener)) { frightener = null; } // Forget the frightener if they are out of sight
					else if (
						(
							frightener.player || // Player actor
							frightener is "PlayerTracer" || // Player shot
							( // Other missile/projectile that came from a player
								frightener.bMissile &&
								frightener.target &&
								frightener.target.player
							)
						) && 
						Random(0, 32) == 0
					)
					{
						// Randomly surrender if the player was the frightener
						surrendered = true;
						SetStateLabel("Death");
					}
				}
			}
			Loop;
		Heal:
			"####" E 0 {
				crouched = true;
				if (goal) {
					healloopcount = goal.Default.Health > 25 ? min(goal.Default.Health / 25, 3) : 0; // Set the number of Heal iterations to scale with the actor's spawnhealth (max of 3 loops)
				}
			}
		Heal.Loop:
			"####" E 15;
			"####" F 5;
			"####" EEEEE 3 { if (goal) { goal.A_SpawnItemEx("HealingParticle", random(10,-10), random(10,-10), random(16,64), 0, 0, random(1, 2), 0); } } // Spawn healing particles as the actor is ressurected
			"####" E 0 {
				if (healloopcount > 0) {
					healloopcount--;
					return ResolveState("Heal.Loop");
				}

				A_HealGoal();

				return ResolveState("See");
			}
			Goto See;
		Death:
			"####" A 0 A_NoBlocking(true); // No weapon to drop, just the medical kit
			"####" XYZ 6;
			"####" A 0 {
				DoSurrender(target);
				bShootable = false;
				bIsMonster = false; // Keep these from being re-killed by the massacre/kill monsters cheat
			}
		Death.Surrender:
			"####" F 1 A_SetTics(Random(35, 70));
			"####" BA 6;
		Death.SurrenderLoop:
			"####" A 1 A_SetTics(Random(35, 70));
			"####" BC 6;
			"####" DEDED 1 A_SetTics(Random(48, 96));
			"####" CB 6;
			Loop;
		Death.StandingSurrender:
			"####" X 6;
			"####" Y 6 A_NoBlocking(true); // No weapon to drop, just the medical kit
			Goto Death.StandingSurrender.MainLoop;
		Death.StandingSurrender.MainLoop:
			"####" Z 9;
		Death.StandingSurrender.SubLoop:
			"####" Z 0;
			"####" Z 32 A_Jump(64, "Death.StandingSurrender.Blink");
			"####" A 0 { return ResolveState("Death.StandingSurrender.MainLoop"); }
		Death.StandingSurrender.Blink:
			"####" Y 8;
			"####" Z 16;
			"####" Y 8;
			"####" A 0 { return ResolveState("Death.StandingSurrender.MainLoop"); }
		SurrenderSprite:
			NMDS A 0;
		Alarm:
			"####" N 50 A_SetTics(interval);
			"####" N 0 A_Jump(256, "See");
	}

	state A_CheckForPlayer(bool jump = False)
	{
		Actor p = FindClosestPlayer(self, dist:int(512 + radius));

		if (!p) { p = lastheard; } // Also respond to any alert sounds

		// Run away from any player that's close by
		if (p)
		{
			if ((!bFrightened && Random(0, 255) < 16) || jump) { A_StartSound("Nazi1/Sighted", CHAN_ITEM); }
			Speed = Default.Speed * 2;

			if (p.player && Distance3D(p) < 512 + radius)
			{
				target = p;
				body = null;
				goal = null;
				frighttimeout = 35 + Random(0, 14) * 5;
				frightener = target;
			}

			if (jump && !InStateSequence(CurState, FindState("See.Heal"))) { return ResolveState("See.Heal"); }
		} else if (goal) { target = goal; }

		return ResolveState(null);
	}

	override void Tick()
	{
		candodge = !crouched; // Only let him dodge if he's not crouched

		Super.Tick();
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (source && source is "MovingTrailBeam") { source = source.master; } // Attribute damage to the owner of any lightning beam

		if (bNoDamage && source && source.player || source is "PlayerFollower")
		{
			if (!surrendered)
			{
				target = source;
				surrendered = true;
				SetStateLabel("Death");
			}

			return 0;
		}
		else
		{
			return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
		}
	}
}