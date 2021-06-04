/*
 * Copyright (c) 2021 AFADoomer
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

class DamageInfo
{
	PlayerInfo player;
	Actor attacker;
	String infoname;
	Vector3 attackerpos;
	int distance;
	int angle;
	int timeout;
	double alpha;
	Color clr;
}

class DamageTracker : EventHandler
{
	Array<DamageInfo> events;
	Color blend[players.Size()];
	Color oldblend[players.Size()];
	int lasttick;

	override void WorldThingDamaged(WorldEvent e)
	{
		let player = e.thing.player;

		if (!player) { return; }

		if (player.mo)
		{
			Actor attacker = null;
			String infoname = "";
			Color flashclr = player.mo.GetPainFlash();

			if (flashclr.a != 0) { return; }

			// If the attacker is still alive (and not the player), use their data
			if (player.attacker)
			{
				if (player.attacker == player.mo)
				{
					infoname = "Player " .. player.mo.PlayerNumber();
				}
				else { attacker = player.attacker; }
			}
			else // Otherwise, treat it as world-induced damage
			{
				infoname = "World";
			}

			DamageInfo info;

			// Save information about a new attacker if it isn't already being tracked
			int attackerindex = FindAttacker(player, attacker, infoname);
			if (attackerindex == events.Size())
			{
				info = New("DamageInfo");
				info.attacker = attacker;
				info.infoname = infoname;
				info.player = player;
				info.alpha = 0.0;

				events.Push(info);
			}
			else { info = events[attackerindex]; }

			// And save additional information
			if (info)
			{
				info.clr = flashclr;

				if (attacker)
				{
					info.attackerpos = attacker.pos;
					info.angle = int(360 - player.mo.deltaangle(player.mo.angle, player.mo.AngleTo(attacker)));
				}
				else  // If no attacker actor, assume it was something behind the player's current movement direction that caused the damage (e.g., explosion)
				{
					info.attackerpos = player.mo.pos - player.mo.vel;
					info.angle = int(360 - player.mo.deltaangle(player.mo.angle, atan2(-player.mo.vel.y, -player.mo.vel.x)));
				}
				info.distance = clamp(int(56 - level.Vec3Diff(player.mo.pos, info.attackerpos).length() / 64), 0, 64);
				info.timeout = level.time + min(e.damage * 4, 100);
			}
		}
	}

	override void WorldTick()
	{
		for (int i = 0; i < events.Size(); i++)
		{
			if (events[i].timeout < level.time) { events.Delete(i); }
			else if (events[i].timeout < level.time + 35) { events[i].alpha = (events[i].timeout - level.time) / 35.0; }
			else if (events[i].alpha < 1.0) { events[i].alpha = min(1.0, events[i].alpha + 0.1); }
			else { events[i].alpha = 1.0; }
		}

		lasttick = level.time;
	}

	int FindAttacker(PlayerInfo player, Actor attacker, String infoname = "")
	{
		for (int i = 0; i < events.Size(); i++)
		{
			if (events[i].player != player) { continue; }

			if (attacker && events[i].attacker == attacker) { return i; }
			else if (infoname.length() && events[i].infoname ~== infoname) { return i; }
		}

		return events.Size();
	}

	// Lifted from https://github.com/coelckers/gzdoom/blob/4bcea0ab783c667940008a5cab6910b7a826f08c/src/rendering/2d/v_blend.cpp#L59
	static const uint DamageToAlpha[] =
	{
		0,   8,  16,  23,  30,  36,  42,  47,  53,  58,  62,  67,  71,  75,  79,
		83,  87,  90,  94,  97, 100, 103, 107, 109, 112, 115, 118, 120, 123, 125,
		128, 130, 133, 135, 137, 139, 141, 143, 145, 147, 149, 151, 153, 155, 157,
		159, 160, 162, 164, 165, 167, 169, 170, 172, 173, 175, 176, 178, 179, 181,
		182, 183, 185, 186, 187, 189, 190, 191, 192, 194, 195, 196, 197, 198, 200,
		201, 202, 203, 204, 205, 206, 207, 209, 210, 211, 212, 213, 214, 215, 216,
		217, 218, 219, 220, 221, 221, 222, 223, 224, 225, 226, 227, 228, 229, 229,
		230, 231, 232, 233, 234, 235, 235, 236, 237
	};

	static Color, double, int GetDamageBlend(PlayerInfo player)
	{
		DamageTracker damagehandler = DamageTracker(EventHandler.Find("DamageTracker"));

		if (!damagehandler) { return 0x0, 0.0, 1; }

		String temp;
		int pnum = player.mo.PlayerNumber();
		Color clr = damagehandler.blend[pnum];

		int damageamount = 0;
		for (int i = 0; i < damagehandler.events.Size(); i++)
		{
			if (damagehandler.events[i].player == player)
			{
				damageamount += damagehandler.GetAmount(i);
			}
		}

		if (!damageamount)
		{
			damagehandler.blend[pnum] = 0x0;
			damagehandler.oldblend[pnum] = 0x0;
			return 0x0, 0.0, 1; // If no damage found, return early
		}

		damagehandler.oldblend[pnum] = damagehandler.blend[pnum];

		double blendalpha = clamp((DamageTracker.DamageToAlpha[clamp(damageamount, 0, 113)] / 255.0) * blood_fade_scalar * 1.25, 0.0, 1.0);
		
		for (int i = 0; i < damagehandler.events.Size(); i++)
		{
			if (damagehandler.events[i].player == player)
			{
				let d = damagehandler.events[i];

				double percentage = damagehandler.GetAmount(i) * 1.0 / damageamount;
				clr = damagehandler.AddBlend(clr, d.clr, percentage);

				if (boa_debugscreenblends)
				{
					String attackername = "World/Player";
					if (d.attacker) { attackername = d.attacker.getclassname(); }
					if (temp.length()) { temp = temp .. ",\n"; }
					temp = temp .. string.format("> Damage from %s: %x (%.2f) => %x", attackername, d.clr, percentage, clr);
				}
			}
		}

		damagehandler.blend[pnum] = clr;
		if (!clr) { blendalpha = 0.0; }

		if (boa_debugscreenblends) { console.printF("%s\nFinal blend: %x at %.2f", temp, damagehandler.blend[pnum], blendalpha); }

		return damagehandler.blend[pnum], blendalpha, max(1, damageamount);
	}

	// See V_AddBlend in v_blend.cpp
	static Color AddBlend (Color base, Color add, double alpha)
	{
		if (alpha <= 0) { return base; }

		double a2 = base.a + (1 - base.a) * alpha;
		double a3 = base.a / a2;

		int r = int(base.r * a3 + add.r * (1 - a3));
		int g = int(base.g * a3 + add.g * (1 - a3));
		int b = int(base.b * a3 + add.b * (1 - a3));

		return r * 0x10000 + g * 0x100 + b;
	}

	int GetAmount(int i)
	{
		if (events[i] && events[i].timeout) { return max(0, events[i].timeout - level.time); }
		
		return 0;
	}
}

class ThingTracker : EventHandler
{
	Array<Actor> grenades;

	override void WorldThingSpawned(WorldEvent e)
	{
		let grenade = GrenadeBase(e.thing);

		if (!grenade) { return; }

		grenades.Push(grenade);
	}

	override void WorldThingDestroyed(WorldEvent e)
	{
		let grenade = GrenadeBase(e.thing);

		if (!grenade) { return; }

		int g = grenades.Find(grenade);
		grenades.Delete(g);
	}

	static Actor LookForGrenades(Actor mo)
	{
		if (mo.bBoss) { return null; }

		ThingTracker tracker = ThingTracker(EventHandler.Find("ThingTracker"));
		if (!tracker) { return null; }

		Actor closest = null;

		for (int g = 0; g < tracker.grenades.Size(); g++)
		{
			let grenade = tracker.grenades[g];

			int feardistance = int(grenade.radius + (GrenadeBase(grenade) ? GrenadeBase(grenade).feardistance : mo.radius * 2));

			if (!mo.CheckSight(grenade)) { continue; }
			if (grenade.bMissile && (grenade.target == mo || (grenade.target is "PlayerPawn" && Actor.absangle(grenade.angle + 180, mo.AngleTo(grenade.target)) > 30))) { continue; } // Ignore missiles fired from self and any from a player that aren't aimed at you
			if (mo.Distance3d(grenade) > (grenade.bMissile ? feardistance * max(grenade.Speed, grenade.vel.length()) : feardistance)) { continue; }
			if (grenade.pos.z > mo.pos.z + mo.height || grenade.pos.z + grenade.height < mo.pos.z) { continue; }
			if (closest && mo.Distance3d(grenade) > mo.Distance3d(closest)) { continue; }

			closest = grenade;
		}

		return closest;
	}
}

class InventoryTracker : StaticEventHandler
{
	InventoryHolder[MAXPLAYERS] inventories;

	static void Save(Actor mo)
	{
		int pnum = mo.PlayerNumber();
		if (pnum < 0) { return; }

		InventoryTracker tracker = InventoryTracker(EventHandler.Find("InventoryTracker"));
		if (!tracker) { return; }

		let inv = new("InventoryHolder");
		inv.HoldInventory(mo.Inv);

		tracker.inventories[pnum] = inv;
	}

	static void Restore(Actor mo)
	{
		int pnum = mo.PlayerNumber();
		if (pnum < 0) { return; }

		InventoryTracker tracker = InventoryTracker(EventHandler.Find("InventoryTracker"));
		if (!tracker) { return; }

		tracker.inventories[pnum].RestoreInventory(mo);
		tracker.inventories[pnum].Destroy();
	}

	static void Clear(Actor mo)
	{
		int pnum = mo.PlayerNumber();
		if (pnum < 0) { return; }

		InventoryTracker tracker = InventoryTracker(EventHandler.Find("InventoryTracker"));
		if (!tracker) { return; }

		tracker.inventories[pnum].Destroy();
	}
}