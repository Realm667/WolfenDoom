/*
 * Copyright (c) 2019-2020 Talon1024
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
// Miscellaneous ACS tools

class ACSTools
{
	// Find the number of the last message in a series of messages in the string table.
	// Examples/expected results for various inputs:
	// prefix: DARRENMESSAGE
	// start: 1
	// return value: 101
	//
	// prefix: PRISONERMESSAGE
	// start: 1
	// return value: 21
	//
	// prefix: MARINEAFTERDOUGLESCONV
	// start: 1
	// return value: 55
	//
	static int LastMessageFor(String prefix, int start)
	{
		// Concatenating an empty string with a number is an easy way of converting it to a string
		String suffix = start < 10 ? "0" .. start : "" .. start;
		String lookup = prefix .. suffix;
		String entry = StringTable.Localize(lookup, false);
		int current = start;
		while (entry != lookup)
		{
			current++;
			suffix = current < 10 ? "0" .. current : "" .. current;
			lookup = prefix .. suffix;
			entry = StringTable.Localize(lookup, false);
		}
		return current - 1;
	}

	// For the first thing with a matching TID, get the integer value for the given argument
	static int GetArgument(int tid, int arg)
	{
		if(arg >= 0 && arg <= 4)
		{
			ActorIterator it = Level.CreateActorIterator(tid);
			Actor thething = it.Next();
			if (thething != null)
			{
				return thething.Args[arg];
			}
		}
		return -1;
	}

	// For every thing with a matching TID, set the integer value for the given argument
	static play void SetArgument(int tid, int arg, int value)
	{
		if (arg < 0 || arg > 4) return;
		ActorIterator it = Level.CreateActorIterator(tid);
		Actor thething = it.Next();
		while (thething != null)
		{
			thething.Args[arg] = value;
			thething = it.Next();
		}
	}

	static clearscope int GetTextureWidth(string TextureName)
	{
		TextureID tex = TexMan.CheckForTexture(TextureName, TexMan.Type_Any);
		if (!tex)
		{
			return 0;
		}
		int width, height;
		[width, height] = TexMan.GetSize(tex);
		return width;
	}

	static clearscope int GetTextureHeight(string TextureName)
	{
		TextureID tex = TexMan.CheckForTexture(TextureName, TexMan.Type_Any);
		if (!tex)
		{
			return 0;
		}
		int width, height;
		[width, height] = TexMan.GetSize(tex);
		return height;
	}

	static play void HasAltDeaths(Actor activator)
	{
		ActorFinderTracer aft = new("ActorFinderTracer");
		aft.Source = activator;
		Vector3 Origin = activator.Pos;
		Origin.Z += activator.Height / 2;
		if (activator is "PlayerPawn")
		{
			Origin.Z = activator.Pos.Z + PlayerPawn(activator).ViewHeight;
		}
		Console.Printf("Origin: %.3f %.3f %.3f", Origin);
		// Actor.Spawn("TraceVisual", Origin, NO_REPLACE);
		float Pitch = activator.Pitch;
		float Angle = activator.Angle;
		Vector3 Direction = ZScriptTools.GetTraceDirection(Angle, Pitch);
		Console.Printf("Direction: %.3f %.3f %.3f", direction);
		aft.Trace(Origin, Level.PointInSector(Origin.XY), Direction, 1024, TRACE_HitSky);
		if (aft.found())
		{
			Console.Printf("========== %s ==========", aft.Results.HitActor.GetClassName());
			State frontDeath = aft.Results.HitActor.FindState("Death.Front");
			State backDeath = aft.Results.HitActor.FindState("Death.Back");
			Console.Printf("Without exact: frontDeath %s, backDeath %s", frontDeath ? "true" : "false", backDeath ? "true" : "false");
			frontDeath = aft.Results.HitActor.FindState("Death.Front", true);
			backDeath = aft.Results.HitActor.FindState("Death.Back", true);
			Console.Printf("With exact: frontDeath %s, backDeath %s", frontDeath ? "true" : "false", backDeath ? "true" : "false");
		}
		/*
		// Visualize trace
		for (vector3 i = Origin; (aft.Results.HitPos - i) dot Direction >= 0; i += Direction * 4)
		{
			Actor.Spawn("TraceVisual", i, NO_REPLACE);
		}
		Actor.Spawn("TraceVisual", aft.Results.HitPos, NO_REPLACE);
		*/
		Console.Printf("Hit position: %.3f %.3f %.3f", aft.Results.HitPos);
	}

	static bool FindInventoryClass(Actor mo, String classname, bool descendants = true)
	{
		if (mo && mo.FindInventory(classname, descendants)) { return true; }

		return false;
	}

	// Gets the entry ID for the properly declined word form, given a number
	// and a "base" entry ID. If no declined entry exists in the language 
	// table, the "base" entry ID is returned.
	//
	// For example:
	// In languages with only singular/plural forms, the plural form of KRAUTSKILLER02 would be KRAUTSKILLER02P
	// In Czech, it would be KRAUTSKILLER02A or KRAUTSKILLER02B
	// But if there is no declined form of KRAUTSKILLER02, it returns KRAUTSKILLER02.
	// s:ScriptCall("ACSTools", "GetDeclinedForm", "entry", xxx)
	static String GetDeclinedForm(String entry, int count) {
		String form = ""; // Singular (default)
		if (language.Left(2) ~== "cs") // Czech
		{
			if (count > 4)
			{
				form = "B";
			}
			else if (count > 1)
			{
				form = "A";
			}
		}
		else if (language.Left(2) ~== "pl") // Polish
		{
			if (count > 4)
			{
				form = "B";
			}
			else if (count > 1)
			{
				form = "A";
			}
		}
		else if (language ~== "ru") // Russian
		{
			int numend = count % 100;
			// See https://en.wikipedia.org/wiki/Russian_declension#Declension_of_cardinal_numerals
			if (numend >= 5 && numend <= 20) // only last two digits matter in all of this
			{
				// Genitive plural
				form = "P";
			}
			else
			{
				numend = count % 10;
				if (numend == 1)
				{
					// Nominative singular
					form = "A";
				}
				else if (numend == 2 || numend == 3 || numend == 4)
				{
					// Genitive singular
					form = "B";
				}
				else
				{
					// Genitive plural
					form = "P";
				}
			}
		}
		else if (count != 1)
		{
			// Languages that only have singular/plural forms
			form = "P"; // Plural
		}
		String key = entry .. form;
		// Check if the declined form exists
		String text = StringTable.Localize(key, false);
		if (text != key && text != " ")
		{
			// Declined form exists because the entry was found
			return text;
		}
		// Declined form was not found, so return the entry in singular form
		text = StringTable.Localize(entry, false);
		if (text != entry)
		{
			return text;
		}
		// Entry was not found, return a blank string.
		return "";
	}

	static bool ShouldUseWideObjectivesBox()
	{
		WideObjectivesDataHandler dataHandler = WideObjectivesDataHandler(StaticEventHandler.Find("WideObjectivesDataHandler"));
		return dataHandler.shouldUseWideObjectivesBox();
	}

	static play void DamageSectorWrapper(int tag, int damage) // for destructible 3d floors --N00b
	{
		SectorTagIterator sectors = level.CreateSectorTagIterator(tag);
		int sector_id = sectors.next(); //damage only the first sector
		Destructible.DamageSector(level.sectors[sector_id], null, damage, "None", SECPART_3D, (0, 0, 0), false);
	}

	static bool IsAtMaxHealth(Actor activator)
	{
		return activator.Health == activator.GetMaxHealth(true);
	}

	static bool IsNoClipping(Actor activator)
	{
		if (activator)
		{
			if (activator.player) { return (activator.player.cheats & (CF_NOCLIP | CF_NOCLIP2)); }
			else { return activator.bNoClip; }
		}

		return false;
	}

	// Check if the player is wearing a disguise and is currently hidden
	// If a player is wearing a disguise and is undetected, returns true
	// If a player has been seen or is carrying a weapon not allowed by the current disguise, returns false
	ui static bool IsHidden(Actor mo)
	{
		if (mo && mo.player)
		{
			let disguise = DisguiseToken(mo.FindInventory("DisguiseToken", true));

			if (
				disguise &&
				disguise.bNoTarget &&
				mo.player.cheats & CF_NOTARGET
			) { return true; }
		}

		return false;
	}

	static String, String GetKeyPressString(String bind, bool required = false, String keycolor = "Gold", String textcolor = "Untranslated", String errorcolor = "Dark Red")
	{
		keycolor = "\c[" .. keycolor .. "]";
		textcolor = "\c[" .. textcolor .. "]";
		errorcolor = "\c[" .. errorcolor .. "]";

		int c1, c2;
		[c1, c2] = Bindings.GetKeysForCommand(bind);

		String keynames = Bindings.NameKeys(c1, c2);
		keynames = ZScriptTools.StripColorCodes(keynames);
		keynames.Replace(", ", ">" .. textcolor .. " " .. StringTable.Localize("$WORD_OR") .. " " .. keycolor .. "<");

		// If the bind is an inventory use command, append '<activate item>' to the string
		String suffix = "";
		if (bind.Left(3) ~== "use")
		{
			suffix = " " .. StringTable.Localize("$WORD_OR") .. keycolor .. " <" .. StringTable.Localize("$CNTRLMNU_USEITEM") .. ">" .. textcolor;
			suffix.MakeLower();
		}

		if (required && !keynames.length())
		{
			String actionname = ACSTools.GetActionName(bind);

			return errorcolor .. "<" .. StringTable.Localize("$BINDKEY") .. " " .. actionname .. ">" .. textcolor .. suffix, actionname;
		}
		else
		{
			if (keynames.length()) { keynames = keycolor .. "<" .. keynames .. ">" .. textcolor .. suffix; }
		}

		return keynames, keynames;
	}

	static String GetActionName(String actionname, String prefix = "$CNTRLMNU_")
	{
		String output = "";
		String rawactionname = actionname;

		if (actionname.Left(1) == "+") { actionname = actionname.Mid(1); }
		if (actionname.Left(3) == "am_") { actionname = actionname.Mid(3); }

		// Special handling for BoA-specific items, and native items that don't follow the naming pattern
		if (actionname ~== "use grenadepickup") { output = "$CO_GREN"; }
		else if (actionname ~== "pukename quickkick") { output = "$CO_KICK"; }
		else if (actionname ~== "pukename boaobjectives") { output = "$CO_OBJS"; }
		else if (actionname ~== "openmenu MessageLogMenu") { output = "$CO_MSGL"; }
		else if (actionname ~== "left") { output = "$CNTRLMNU_TURNLEFT"; }
		else if (actionname ~== "right") { output = "$CNTRLMNU_TURNRIGHT"; }
		else if (actionname ~== "mlook") { output = "$CNTRLMNU_MOUSELOOK"; }
		else if (actionname ~== "klook") { output = "$CNTRLMNU_KEYBOARDLOOK"; }
		else if (actionname ~== "speed") { output = "$CNTRLMNU_RUN"; }
		else if (actionname ~== "toggle cl_run") { output = "$CNTRLMNU_TOGGLERUN"; }
		else if (actionname ~== "showscores") { output = "$CNTRLMNU_SCOREBOARD"; }
		else if (actionname ~== "messagemode") { output = "$CNTRLMNU_SAY"; }
		else if (actionname ~== "messagemode2") { output = "$CNTRLMNU_TEAMSAY"; }
		else if (actionname ~== "weapnext") { output = "$CNTRLMNU_NEXTWEAPON"; }
		else if (actionname ~== "weapprev") { output = "$CNTRLMNU_PREVIOUSWEAPON"; }
		else if (actionname.Left(5) ~== "slot ") { output = "$CNTRLMNU_SLOT" .. actionname.Mid(5); }
		else if (actionname.Left(4) ~== "user") { output = "$CNTRLMNU_USER" .. actionname.Mid(4); }
		else if (actionname ~== "invuse") { output = "$CNTRLMNU_USEITEM"; }
		else if (actionname ~== "invuseall") { output = "$CNTRLMNU_USEALLITEMS"; }
		else if (actionname ~== "invnext") { output = "$CNTRLMNU_NEXTITEM"; }
		else if (actionname ~== "invprev") { output = "$CNTRLMNU_PREVIOUSITEM"; }
		else if (actionname ~== "invdrop") { output = "$CNTRLMNU_DROPITEM"; }
		else if (actionname ~== "invquery") { output = "$CNTRLMNU_QUERYITEM"; }
		else if (actionname ~== "weapdrop") { output = "$CNTRLMNU_DROPWEAPON"; }
		else if (actionname ~== "togglemap") { output = "$CNTRLMNU_AUTOMAP"; }
		else if (actionname ~== "chase") { output = "$CNTRLMNU_CHASECAM"; }
		else if (actionname ~== "spynext") { output = "$CNTRLMNU_COOPSPY"; }
		else if (actionname ~== "toggleconsole") { output = "$CNTRLMNU_CONSOLE"; }
		else if (actionname ~== "sizeup") { output = "$CNTRLMNU_DISPLAY_INC"; }
		else if (actionname ~== "sizedown") { output = "$CNTRLMNU_DISPLAY_DEC"; }
		else if (actionname ~== "togglemessages") { output = "$CNTRLMNU_TOGGLE_MESSAGES"; }
		else if (actionname ~== "bumpgamma") { output = "$CNTRLMNU_ADJUST_GAMMA"; }
		else if (actionname ~== "menu_help") { output = "$CNTRLMNU_OPEN_HELP"; }
		else if (actionname ~== "menu_save") { output = "$CNTRLMNU_OPEN_SAVE"; }
		else if (actionname ~== "menu_load") { output = "$CNTRLMNU_OPEN_LOAD"; }
		else if (actionname ~== "menu_options") { output = "$CNTRLMNU_OPEN_OPTIONS"; }
		else if (actionname ~== "menu_display") { output = "$CNTRLMNU_OPEN_DISPLAY"; }
		else if (actionname ~== "menu_endgame") { output = "$CNTRLMNU_EXIT_TO_MAIN"; }
		else if (actionname ~== "menu_quit") { output = "$CNTRLMNU_MENU_QUIT"; }
		else if (actionname ~== "showpopup 1") { output = "$CNTRLMNU_MISSION"; }
		else if (actionname ~== "showpopup 2") { output = "$CNTRLMNU_KEYS"; }
		else if (actionname ~== "showpopup 3") { output = "$CNTRLMNU_STATS"; }
		else if (actionname ~== "gobig") { output = "$MAPCNTRLMNU_TOGGLEZOOM"; }
		else if (actionname ~== "toggle am_rotate") { output = "$MAPCNTRLMNU_ROTATE"; }
		else if (actionname ~== "clearmarks") { output = "$MAPCNTRLMNU_CLEARMARK"; }
		else if (rawactionname ~== "crouch") { output = "$CNTRLMNU_TOGGLECROUCH"; }
		else { output = prefix .. actionname; }

		output = StringTable.Localize(output);

		// Fall back to displaying the bind information if no string was found.
		if (output.left(9) ~== prefix) { output = rawactionname; }

		return output;
	}
}

class ActorFinderTracer : LineTracer
{
	Actor Source;
	class<Actor> typeRestriction;
	bool exactType;
	private bool find;

	bool isSuitableActor(Actor toExamine)
	{
		bool typeGood = true;
		if (typeRestriction)
		{
			if (exactType)
			{
				typeGood = toExamine.GetClass() == typeRestriction;
			}
			else
			{
				typeGood = toExamine is typeRestriction;
			}
		}
		return typeGood && toExamine != Source && toExamine is "Base" && toExamine.bSolid && toExamine.bShootable;
	}

	bool found()
	{
		return find;
	}

	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling || Results.HitType == TRACE_HasHitSky)
		{
			return TRACE_Stop;
		}
		else if (Results.HitType == TRACE_HitWall)
		{
			if (Results.HitLine.sidedef[1] && Results.Tier == TIER_Middle)
			{
				return TRACE_Skip;
			}
			else
			{
				return TRACE_Stop;
			}
		}
		else if (Results.HitType == TRACE_HitActor)
		{
			if (isSuitableActor(Results.HitActor))
			{
				find = true;
				return TRACE_Stop;
			}
			else
			{
				return TRACE_Skip;
			}
		}
		return TRACE_Skip;
	}
}