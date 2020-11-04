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

class BoAUnderwater : CustomInventory
{
	int underwatertimer;
	int oldwaterlevel;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
	}

	void DoWaterEffects()
	{
		if (underwatertimer > 0) { underwatertimer--; }

		// Spawn bubbles
		if (level.time % 7 == 0)
		{
			if(owner.waterlevel >= 3 && boa_bubbleswitch) //check also stored cvar for custom tweaks
			{
				Actor bubble = Spawn("PlayerBubble", owner.pos + (Random(4, 8), 0, Random(48, 52)));
				if (bubble) { bubble.angle = Random(0, 359); }
			}
		}

		// Play water exit splash sound if you just got out of the water
		if (owner.waterlevel == 0 && oldwaterlevel >= 1) { owner.A_StartSound("water/exit", CHAN_AUTO, 0, 0.025 * owner.vel.z, ATTN_NORM); }

		if (owner is "PlayerPawn")
		{
			// Play underwater sound effect, and stop the sound when the player leaves the water
			if (owner.waterlevel >= 3 && underwatertimer == 0)
			{
				//  Note:  Should really just be a local sound, but local sounds apparently can't be stopped with A_StopSound,
				//  so the "underwtr" sound is set up with a 8-16 unit log attenuation in SNDINFO to get a similar effect...
				owner.A_StartSound("underwtr", 10, CHANF_LOOP, 0.25, ATTN_NORM);
				underwatertimer = Random(90, 127);
			}
			else if (owner.waterlevel < 3 && oldwaterlevel >= 3)
			{
				owner.A_StopSound(10);
				underwatertimer = 0;
			}
		}

		oldwaterlevel = owner.waterlevel;
	}

	override void Tick(void)
	{
		if (Owner && level.time % 5 == 0) // This doesn't need to run every tick...
		{
			DoWaterEffects();
		}

		Super.Tick();
	}

	States
	{
		Use:
			TNT1 A 0;
			Fail;
		Pickup:
			TNT1 A 0
			{
				return true;
			}
			Stop;
	}
}