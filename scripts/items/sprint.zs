/*
 * Copyright (c) 2013-2021 Ral22, Ozymandias81, edthebat, MaxEd, AFADoomer
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

// Converted to ZScript by AFADoomer from ACS code derived from Lasting Light by ral22,
// originally ported in by Ozymandias81, modified by edthebat, MaxEd, and AFADoomer

class BoASprinting : Inventory
{
	int cooldown;
	int staminarecoverytimeout, staminasoundtimeout;
	int exhaustionthreshold;
	String gaspsound;
	int flags;

	Property ExhaustionStamina:exhaustionthreshold;
	Property GaspSound:gaspsound;

	FlagDef AnyDirection:flags, 0; // Allow sprinting while moving sideways
	FlagDef RequireForward:flags, 1; // Only sprint when there is some forward movement
	FlagDef AllowCrouch:flags, 2; // Allow sprinting while crouched

	Default
	{
		+Inventory.Undroppable
		BoASprinting.ExhaustionStamina 25;
		BoASprinting.GaspSound "player/breathing";
		+BoASprinting.RequireForward
	}

	override void Tick()
	{
		Super.Tick();

		if (!PlayerPawn(owner)) { Destroy(); return; }
		if (owner && owner.health <= 0) { return; }

		DoSprintCheck();
		DoExhaustionCheck();
	}

	virtual void DoSprintCheck()
	{
		if (BoAPlayer(owner) && BoAPlayer(owner).DragTarget) { return; }

		UserCmd cmd = owner.player.cmd;
		double speed = 1.0;

		let stamina = owner.FindInventory("Stamina");
		if (!stamina) { stamina = owner.GiveInventoryType("Stamina"); }

		// Reset both walking and running speed to default walking speed
		PlayerPawn(owner).forwardmove1 = PlayerPawn(owner).Default.forwardmove1;
		PlayerPawn(owner).forwardmove2 = PlayerPawn(owner).Default.forwardmove1 / 2; // Internal running code multiplies by 2

		PlayerPawn(owner).sidemove1 = PlayerPawn(owner).Default.sidemove1;
		PlayerPawn(owner).sidemove2 = PlayerPawn(owner).Default.sidemove1 / 2;

		// Reset to full stamina if noclipping, and increase base speed
		if (owner.player.cheats & (CF_NOCLIP | CF_NOCLIP2))
		{
			PlayerPawn(owner).forwardmove1 = PlayerPawn(owner).forwardmove2 = 2.5;
			PlayerPawn(owner).sidemove1 = PlayerPawn(owner).sidemove2 = 2.5;
			cooldown = 0;
			staminarecoverytimeout = 0;

			stamina.amount = stamina.maxamount;
		}

		bool run = cmd.buttons & BT_SPEED & ~cl_run;

		if (
			run &&
			(
				(bAnyDirection && cmd.sidemove) || // Check if player is strafing, if that flag is set
				(
					cmd.forwardmove && // Or if player is moving forward or backward
					(!bRequireForward || cmd.forwardmove > 0) // And only forward, if that flag is set
				)
			) &&
			(bAllowCrouch || owner.player.crouchfactor == 1.0) &&
			cooldown <= 0 &&
			stamina.amount > 0
		)
		{
			// Counteract cl_run swapping run and walk speeds
			if (cl_run)
			{ // Change walking speed if cl_run set
				PlayerPawn(owner).forwardmove1 = PlayerPawn(owner).Default.forwardmove1 * 2;
				PlayerPawn(owner).sidemove1 = PlayerPawn(owner).Default.sidemove1 * 2;
			}
			else
			{ // Otherwise update run speed
				PlayerPawn(owner).forwardmove2 = PlayerPawn(owner).Default.forwardmove1;
				PlayerPawn(owner).sidemove2 = PlayerPawn(owner).Default.sidemove1;
			}

			// Don't use stamina if stamina check is disabled or if Totale Macht/Berserk is active
			if (!boa_sprintswitch && !owner.FindInventory("BerserkToken"))
			{
				stamina.amount -= Random(1, 3); //more stamina to use
			}
		}
		else
		{
			if (staminarecoverytimeout < level.time)
			{
				cooldown--;
				stamina.amount = min(stamina.maxamount, stamina.amount + 1);
				staminarecoverytimeout = level.time + Random(1, 3); //recovery is more fast
			}
		}

		if (!stamina.amount)
		{
			cooldown = stamina.maxamount;
			AchievementTracker.CheckAchievement(owner.PlayerNumber(), AchievementTracker.ACH_SPRINT);
		}
	}

	virtual void DoExhaustionCheck(void)
	{
		if (owner.waterlevel > 2 || gamestate != GS_LEVEL) { return; }

		let stamina = owner.FindInventory("Stamina");

		if (stamina && stamina.amount < exhaustionthreshold && staminasoundtimeout < level.time)
		{
			owner.A_StartSound(gaspsound, CHAN_VOICE, CHANF_DEFAULT, 1.0);
			staminasoundtimeout = level.time + 50;
		}
	}
}

class Stamina : Inventory
{
	Default
	{
		Inventory.MaxAmount 100;
		+Inventory.KEEPDEPLETED;
	}
}