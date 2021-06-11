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
	AchievementTracker achievements;

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

			if (achievements) { achievements.damaged[player.mo.PlayerNumber()] = true; }
		}
	}

	override void WorldTick()
	{
		if (!achievements) { achievements = AchievementTracker(EventHandler.Find("AchievementTracker")); }

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
		if (grenade)
		{
			grenades.Push(grenade);
			return;
		}
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

class InventoryTracker : EventHandler
{
	InventoryHolder[MAXPLAYERS] inventories;

	static void Save(Actor mo)
	{
		int pnum = mo.PlayerNumber();
		if (pnum < 0) { return; }

		InventoryTracker tracker = InventoryTracker(EventHandler.Find("InventoryTracker"));
		if (!tracker) { return; }

		tracker.inventories[pnum] = New("InventoryHolder");
		tracker.inventories[pnum].owner = mo;
		tracker.inventories[pnum].HoldInventory(mo.Inv);
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

class AchievementTracker : EventHandler
{
	transient CVar recordvar[4];
	int record;
	Array<bool> records;

	int pistolshots[MAXPLAYERS];
	int knifekills[MAXPLAYERS];
	int levelstats[MAXPLAYERS][3];
	int damaged[MAXPLAYERS];
	int reloads[MAXPLAYERS];
	int manualreloads[MAXPLAYERS];
	int surrenders[MAXPLAYERS];
	int grenades[MAXPLAYERS];
	int totalgrenades[MAXPLAYERS];
	int saves[MAXPLAYERS];
	int exhaustion[MAXPLAYERS];
	int lastminedeath[MAXPLAYERS];
	int minedeaths[MAXPLAYERS];
	int liquiddeath[MAXPLAYERS];
	int shots[MAXPLAYERS][2];
	int zombies[MAXPLAYERS];
	int playtime[MAXPLAYERS];
	bool weapons[MAXPLAYERS][16];

	static const Class<Weapon> weaponlist[] = { 
		"KnifeSilent",
		"Shovel",
		"Firebrand",
		"Luger9mm",
		"Walther9mm",
		"TrenchShotgun",
		"Browning5",
		"MP40",
		"Sten",
		"Kar98k",
		"G43",
		"Pyrolight",
		"Nebelwerfer",
		"Panzerschreck",
		"TeslaCannon",
		"UMG43"
	};

	enum LiquidDeaths
	{
		DTH_POISON = 0x1,
		DTH_LAVA = 0x10,
		DTH_DROWNING = 0x100,
	};

	enum Achievements
	{
		ACH_GUNSLINGER = 0,	// Fire 1000 pistol shots (total across all levels)
		ACH_PERFECTIONIST,	// Finish a map with 100% kills/treasure/secrets
		ACH_SPEEDRUNNER,
		ACH_TRICKSTER,
		ACH_IMPENETRABLE,	// Finish a map without taking damage
		ACH_DISGRACE = 5,	// Finish off a boss enemy with kicks
		ACH_PACIFIST,		// Finish a level without killing any enemies
		ACH_CLEARSHOT,		// Use the Kar98k to snipe an enemy over 6000 units away
		ACH_WATCHYOURSTEP,	// Kill 3 Nazis with a single placed mine
		ACH_CHEVALIER,		// Kill a loper with only the primary fire of the Firebrand
		ACH_1915 = 10,		// Complete C3M4 with no gas mask
		ACH_ASSASSIN,		// Stealth kill 10 enemies (total across all levels)
		ACH_NAUGHTY,		// Use the 'give' cheat
		ACH_MINRELOADS,		// Fewer than 25 weapon reloads in a map
		ACH_NORELOADS,		// Complete a map without manually reloading
		ACH_SURRENDERS = 15,// Cause 5 enemies to surrender (total across all levels)
		ACH_NOGRENADES,		// Complete a map without using grenades
		ACH_BOOM,			// Use 40 grenades (total across all levels)
		ACH_SPAM,			// Manually save 100 times (total across all levels)
		ACH_SPRINT,			// Exhaust stamina 50 times (total across all levels)
		ACH_LIQUIDDEATH = 20,
		ACH_PESTS,			// Die to spiders, bats, or rats
		ACH_ACCURACY,		// 75% accuracy or higher when over 100 player bullet tracers have been fired
		ACH_ZOMBIES,		// Kill 500 zombies
		ACH_IRONMAN,		// Collect all Eisenmann files
		ACH_BEAMMEUP = 25,	// Collect all Mayan artifacts
		ACH_FULLARSENAL,	// Collect all (non-Astrostein or Keen) weapons at least once
		ACH_COMBATMEDIC,
		ACH_TREASUREHUNTER,
		ACH_GOLDDIGGER,
		ACH_STAYDEAD = 30,
		ACH_GIBEMALL,
		ACH_NEAT,
		ACH_ADDICTED,		// Play BoA for more than 10 hours
	};

	override void OnRegister()
	{
		recordvar[0] = CVar.FindCVar("boa_achievementrecord0");
		recordvar[1] = CVar.FindCVar("boa_achievementrecord1");
		recordvar[2] = CVar.FindCVar("boa_achievementrecord2");
		recordvar[3] = CVar.FindCVar("boa_achievementrecord3");

		for (int i = 0; i < recordvar.Size(); i ++)
		{
			String value = recordvar[i].GetString();

			if (value.length()) 
			{
				Array<String> parse;
				value = Decode(value, 7);
				value.Split(parse, "|");

				for (int a = 0; a < parse.Size(); a++)
				{
					records.Push(!(parse[a] == String.Format("%c", 0x30 + a)));
				}
			}
		}
	}

	override void WorldTick()
	{
		CheckStats();
		
		if (players[consoleplayer].cmd.buttons & BT_RELOAD) { manualreloads[consoleplayer]++; }
		if (gameaction == ga_savegame) { CheckAchievement(consoleplayer, ACH_SPAM); }
		if (shots[consoleplayer][1] > 100 && shots[consoleplayer][0] * 100.0 / shots[consoleplayer][1] > 75) { CheckAchievement(consoleplayer, ACH_ACCURACY); }
		if (++playtime[consoleplayer] > 1260000) { CheckAchievement(consoleplayer, ACH_ADDICTED); }
	}

	override void WorldUnloaded(WorldEvent e)
	{

	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (e.Thing is "PlayerTracer" && PlayerTracer(e.Thing).target.player)
		{
			int pnum = PlayerTracer(e.Thing).target.PlayerNumber();
			if (e.Thing is "LugerTracer") { CheckAchievement(pnum, ACH_GUNSLINGER); }
		}
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (e.Thing is "ZombieStandard" && e.Thing.target && e.Thing.target.player) { CheckAchievement(e.Thing.target.PlayerNumber(), ACH_ZOMBIES); }
	}

	override void WorldLinePreActivated(WorldEvent e) 
	{
		let line = e.activatedline;

		CheckSpecials(line.special);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "achievement")
		{
			UpdateRecord(consoleplayer, e.args[0]);
		}
		else if (e.Name == "printachievements")
		{
			console.printf("%s", BitString(false));
		}
	}

	void CheckStats()
	{
		if (
			levelstats[consoleplayer][0] != players[consoleplayer].killcount ||
			levelstats[consoleplayer][1] != players[consoleplayer].itemcount ||
			levelstats[consoleplayer][2] != players[consoleplayer].secretcount
		)
		{
			levelstats[consoleplayer][0] = players[consoleplayer].killcount;
			levelstats[consoleplayer][1] = players[consoleplayer].itemcount;
			levelstats[consoleplayer][2] = players[consoleplayer].secretcount;

			CheckAchievement(consoleplayer, ACH_PERFECTIONIST);
		}
	}

	// Check for achievements on level exit
	static void CheckSpecials(int special)
	{
		if (
			special == 243 || // Exit_Normal
			special == 244 || // Exit_Secret
			special == 74 // Teleport_NewMap
		)
		{
			AchievementTracker.CheckAchievement(consoleplayer, AchievementTracker.ACH_IMPENETRABLE);
			AchievementTracker.CheckAchievement(consoleplayer, AchievementTracker.ACH_PACIFIST);
			AchievementTracker.CheckAchievement(consoleplayer, AchievementTracker.ACH_1915);
			AchievementTracker.CheckAchievement(consoleplayer, AchievementTracker.ACH_MINRELOADS);
			AchievementTracker.CheckAchievement(consoleplayer, AchievementTracker.ACH_NORELOADS);
			AchievementTracker.CheckAchievement(consoleplayer, AchievementTracker.ACH_NOGRENADES);
		}
	}

	static void CheckAchievement(int pnum, int a)
	{
		if (pnum < 0) { return; }

		AchievementTracker achievements = AchievementTracker(EventHandler.Find("AchievementTracker"));
		if (!achievements) { return; }

		achievements.DoChecks(pnum, a);
	}

	void DoChecks(int pnum, int a)
	{
		if (a < records.Size() && records[a]) { return; } // Ignore this achievement if it was already completed

		bool complete = false;

		switch (a)
		{
			case ACH_GUNSLINGER:  // Checked here in WorldThingSpawned function
				if (++pistolshots[pnum] >= 1000) { complete = true; }
				break;
			case ACH_PERFECTIONIST: // Checked here in CheckSpecials function
				if (
					players[pnum].killcount == level.total_monsters &&
					players[pnum].itemcount == level.total_items &&
					players[pnum].secretcount == level.total_secrets
				)
				{
					complete = true;
				}
				break;
			case ACH_SPEEDRUNNER:
				// TODO
				break;
			case ACH_TRICKSTER:
				// TODO
				break;
			case ACH_IMPENETRABLE:  // Checked here in CheckSpecials function
				if (!damaged[pnum]) { complete = true; }
				break;
			case ACH_PACIFIST:  // Checked here in CheckSpecials function. Currently includes all counted kills!
				if (players[pnum].killcount == 0) { complete = true; }
				break;
			case ACH_WATCHYOURSTEP: // Set up in the Nazi class's Die function
				if (lastminedeath[pnum] == 0 || lastminedeath[pnum] > level.time - 5)
				{
					if (++minedeaths[pnum] >= 3) { complete = true; }
				}
				else { minedeaths[pnum] = 1; }
				lastminedeath[pnum] = level.time;
				break;
			case ACH_1915: // Checked here in CheckSpecials function
				if (level.mapname == "C3M4" && !players[pnum].mo.FindInventory("ZyklonMask")) { complete = true; }
				break;
			case ACH_ASSASSIN: // Set up in the Nazi class's DamageMobj function
				if (++knifekills[pnum] >= 10) { complete = true; }
				break;
			case ACH_MINRELOADS: // Reloads incremented in NaziWeapon class A_Reloading function
				if (reloads[pnum] <= 25) { complete = true; }
				break;
			case ACH_NORELOADS: // Manual reloads incremented here in CheckButtons function
				if (!manualreloads[pnum]) { complete = true; }
				break;
			case ACH_SURRENDERS: // Checked in Nazi class DoSurrender function
				if (++surrenders[pnum] >= 5) { complete = true; }
				break;
			case ACH_NOGRENADES: // Checked in HandGrenade PostBeginPlay
				if (!grenades[pnum]) { complete = true; }
				break;
			case ACH_BOOM: // Checked in HandGrenade PostBeginPlay
				if (++totalgrenades[pnum] >= 40) { complete = true; }
				break;
			case ACH_SPAM: // Checked here in WorldTick function
				if (++saves[pnum] >= 100) { complete = true; }
				break;
			case ACH_SPRINT: // Checked from BoASprinting powerup
				if (++exhaustion[pnum] >= 50) { complete = true; }
				break;
			case ACH_ZOMBIES:
				if (++zombies[pnum] >= 500) { complete = true; }
				break;
			case ACH_FULLARSENAL:
				bool pass = true;

				for (int w = 0; w < 16; w++)
				{
					if (weapons[pnum][w] == false) { pass = false; break; }
				}

				complete = pass;
				break;
			case ACH_COMBATMEDIC:
				break;
			case ACH_TREASUREHUNTER:
				break;
			case ACH_GOLDDIGGER:
				break;
			case ACH_STAYDEAD:
				break;
			case ACH_GIBEMALL:
				break;
			case ACH_NEAT:
				break;
			case ACH_NAUGHTY: // Set up in the BoAPlayer class's 'give' cheat handling
				// Reset inventory-based achievements if you use 'give'
				for (int w = 0; w < 16; w++) { weapons[pnum][w] == false; }
				complete = true;
				break;
			case ACH_DISGRACE: // Set up in the Nazi class's Die function
			case ACH_CLEARSHOT: // Set up in the Nazi class's Die function
			case ACH_CHEVALIER: // Set up in the Nazi class's Die function, with handling in DamageMobj to flag the enemy to not allow the achievement if any other weapon was used
			case ACH_PESTS: // Set up in the BoAPlayer class's Die function
			case ACH_ACCURACY: // Set up in the BulletTracer class's PostBeginPlay function and actor states
			case ACH_ADDICTED: // Incremented here in WorldUnloaded function
			case ACH_IRONMAN: // Set in Gutenberg C1 conversation
			case ACH_BEAMMEUP: // Set in Gutenberg C2 conversation
			default:
				complete = true;
				break;
		}

		if (complete) { UpdateRecord(pnum, a); }
	}

	void UpdateRecord(int pnum, int a)
	{
		if (a >= records.Size()) { records.Resize(a + 1); } // Make the array bigger if it's not already big enough

		if (records[a]) { return; } // Only let the player get an achievement once
		else { records[a] = true; } // Set the achievement as complete

		// Encode the value string
		int index = a / 16;
		String bits = BitString(true, index * 16, index * 16 + 16);

		// Save the value to the CVar
		bits = Encode(bits, 7);
		recordvar[index].SetString(bits);

		// Look up the achievement description string
		String lookup = String.Format("ACHIEVEMENT%i", a);
		String text = StringTable.Localize(lookup, false);
		if (lookup ~== text) { text = String.Format("Completed achievement %i", a); }

		String image = String.Format("ACHVMT%02i", a);

		// Display the message
		AchievementMessage.Init(players[pnum].mo, text, image, "misc/achievement");
	}

	String BitString(int encode = true, int start = 0, int end = -1)
	{
		String bits = "";
		if (end == -1 || end > records.Size()) { end = records.Size(); }

		for (int b = start; b < end; b++)
		{
			if (b > 0) { bits = bits .. "|"; }
			int offset = 0x30;
			if (encode) { offset += b; }
			bits = String.Format("%s%c", bits, !!records[b] + offset);
		}

		return bits;
	}

	// Algorithms adapted from https://en.wikibooks.org/wiki/Algorithm_Implementation/Miscellaneous/Base64
	// Pass in v value as an offset to slightly obfuscate the encoded value (added ROT cipher, effectively)
	String Encode(String s, int v = 0)
	{
		String base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		String r = ""; 
		String p = ""; 
		int c = s.Length() % 3;

		if (c)
		{
			for (; c < 3; c++)
			{ 
				p = p .. '='; 
				s = s .. "\0"; 
			} 
		}

		for (c = 0; c < s.Length(); c += 3)
		{
			int m = (s.ByteAt(c) + v << 16) + (s.ByteAt(c + 1) + v << 8) + s.ByteAt(c + 2) + v;
			int n[] = { (m >>> 18) & 63, (m >>> 12) & 63, (m >>> 6) & 63, m & 63 };
			r = r .. base64chars.Mid(n[0], 1) .. base64chars.Mid(n[1], 1) .. base64chars.Mid(n[2], 1) .. base64chars.Mid(n[3], 1);
		}

		return r.Mid(0, r.Length() - p.Length()) .. p;
	}

	String Decode(String s, int v = 0)
	{
		String base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

		String p = (s.ByteAt(s.Length() - 1) == 0x3D ? (s.ByteAt(s.Length() - 2) == 0x3D ? "AA" : "A") : ""); 
		String r = ""; 
		s = s.Mid(0, s.Length() - p.Length()) .. p;

		for (int c = 0; c < s.Length(); c += 4)
		{
			int c1 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c))) << 18;
			int c2 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c + 1))) << 12;
			int c3 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c + 2))) << 6;
			int c4 = base64chars.IndexOf(String.Format("%c", s.ByteAt(c + 3)));

			int n = (c1 + c2 + c3 + c4);
			r = r .. String.Format("%c%c%c", ((n >>> 16) - v) & 127, ((n >>> 8) - v) & 127, (n - v) & 127); // Sorry extened ASCII and Unicode...  No support for you here.
		}

		return r.Mid(0, r.Length() - p.Length());
	}

	void GetStats()
	{
		PersistentAchievementTracker ptracker = PersistentAchievementTracker(StaticEventHandler.Find("PersistentAchievementTracker"));
		if (!ptracker) { return; }

		for (int i = 0; i < MAXPLAYERS; i++)
		{
			pistolshots[i] = ptracker.pistolshots[i];
			knifekills[i] = ptracker.knifekills[i];
			surrenders[i] = ptracker.surrenders[i];
			totalgrenades[i] = ptracker.totalgrenades[i];
			saves[i] = ptracker.saves[i];
			exhaustion[i] = ptracker.exhaustion[i];
			liquiddeath[i] = ptracker.liquiddeath[i];
			zombies[i] = ptracker.zombies[i];
			playtime[i] = ptracker.playtime[i];

			for (int w = 0; w < 16; w++)
			{
				weapons[i][w] = ptracker.weapons[i][w];
			}
		}
	}

	void SaveStats()
	{
		PersistentAchievementTracker ptracker = PersistentAchievementTracker(StaticEventHandler.Find("PersistentAchievementTracker"));
		if (!ptracker) { return; }

		for (int i = 0; i < MAXPLAYERS; i++)
		{
			ptracker.pistolshots[i] = pistolshots[i];
			ptracker.knifekills[i] = knifekills[i];
			ptracker.surrenders[i] = surrenders[i];
			ptracker.totalgrenades[i] = totalgrenades[i];
			ptracker.saves[i] = saves[i];
			ptracker.exhaustion[i] = exhaustion[i];
			ptracker.liquiddeath[i] = liquiddeath[i];
			ptracker.zombies[i] = zombies[i];
			ptracker.playtime[i] = playtime[i];

			for (int w = 0; w < 16; w++)
			{
				ptracker.weapons[i][w] = weapons[i][w];
			}
		}
	}
}

// Static tracker to allow tracking certain stats across level changes
class PersistentAchievementTracker : StaticEventHandler
{
	int pistolshots[MAXPLAYERS];
	int knifekills[MAXPLAYERS];
	int surrenders[MAXPLAYERS];
	int totalgrenades[MAXPLAYERS];
	int saves[MAXPLAYERS];
	int exhaustion[MAXPLAYERS];
	int liquiddeath[MAXPLAYERS];
	int zombies[MAXPLAYERS];
	int playtime[MAXPLAYERS];
	bool weapons[MAXPLAYERS][16];

	override void WorldLoaded(WorldEvent e)
	{
		AchievementTracker tracker = AchievementTracker(EventHandler.Find("AchievementTracker"));
		if (!tracker) { return; }

		tracker.GetStats();
	}

	override void WorldUnloaded(WorldEvent e)
	{
		if (!e.IsSaveGame)
		{
			AchievementTracker tracker = AchievementTracker(EventHandler.Find("AchievementTracker"));
			if (!tracker) { return; }

			tracker.SaveStats();
		}
	}
}