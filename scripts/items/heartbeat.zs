
/*
 * Copyright (c) 2017-2021 Ozymandias81, AFADoomer
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

// Converted to ZScript by AFADoomer from ACS code originally written by Ozymandias81
// Modified to smoothly transition speed and translucency of effects based on health
// instead of changing in 10-unit steps, and allows customization of properties

class BoAHeartBeat : Inventory
{
	int heartbeatdelay1, heartbeatdelay2;
	double heartbeatvolume;
	int threshhold;
	String beatsound;

	Property Threshold:threshold;
	Property HeartbeatSound:beatsound;

	Default
	{
		+Inventory.Undroppable
		BoAHeartBeat.Threshold 30;
		BoaHeartBeat.HeartbeatSound "hbeat";
	}

	override void Tick()
	{
		Super.Tick();

		if (!owner) { Destroy(); return; }

 		// Don't let the heartbeat effect be visible/heard before it can be deactivated in maps where the ACS variable is set.
		// Use the DORMANT flag to toggle the heartbeat effect on and off.  See InventoryClearHandler NetworkProcess and UITIck.
		if (level.time < 35 || bDormant || owner.health <= 0) { return; }

		DoHeartbeat();
	}

	virtual void DoHeartbeat()
	{
		// Less than or equal to threshold health
		if (owner.health <= threshold)
		{
			if (
				PlayHeartBeat(heartbeatdelay1, heartbeatvolume) &&
				PlayHeartBeat(heartbeatdelay2, heartbeatvolume)
			)
			{
				// Effect now transitions smoothly instead of moving in 10-health-point increments
				double health = owner.health;
				double scalefactor = clamp(health / (threshold * 1.25), 0, 1.0);
				double beatfactor = clamp(health - 10, 0, 20) / 20.0; // Only allow so much variation in heartbeat speed

				heartbeatvolume = 0.65 - scalefactor / 2;
				heartbeatdelay1 = 10 + int(11 * beatfactor);
				heartbeatdelay2 = 14 + int(20 * beatfactor);

				DrawHeartBeat(heartbeatdelay1, 1.0 - scalefactor);

				heartbeatdelay1 += level.time;
				heartbeatdelay2 += level.time;
			}
		}
	}

	virtual void DrawHeartBeat(int timing, double alpha)
	{
		Overlay.Init(owner.player, "M_INJ", 0, timing / 2, timing / 2, alpha); // Draws more transparent the more health you have
	}

	virtual bool PlayHeartBeat(in out int heartbeatdelay, double volume)
	{
		if (heartbeatdelay < level.time) { return true; }

		if (heartbeatdelay == level.time)
		{
			owner.A_StartSound(beatsound, CHAN_AUTO, CHANF_LOCAL, volume);
			heartbeatdelay = 0;

			return true;
		}

		return false;
	}
}