/*
 * Copyright (c) 2020 Talon1024, Username-N00b-is-not-available, AFADoomer
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

class ZScriptTools
{
	// Calculate the time it will take for a projectile to hit a moving target,
	// assuming constant velocities for both the projectile and target.
	//
	// Why calculate impact time rather than the position? It is more flexible,
	// because then you can calculate impact position like this:
	// ImpactPos = TargetPos + TargetVel * ImpactTime;
	//
	// Based on math and code from https://indyandyjones.wordpress.com/2010/04/08/intercepting-a-target-with-projectile/
	// Very important excerpt from that particular blog post:
	// Squaring and multiplication of vectors against vectors amounts to taking
	// the dot product
	static double GetInterceptTime(Vector3 ToTarget, Vector3 TargetVel, double MissileSpeed)
	{
		// Get the terms of the quadratic equation.
		// Taking the dot product of a vector with itself is the same as
		// getting its squared length.
		double a = (TargetVel dot TargetVel) - MissileSpeed * MissileSpeed;
		double b = 2 * TargetVel dot ToTarget;
		double c = ToTarget dot ToTarget;
		double radicand = (b * b) - (4 * a * c);
		if (radicand < 0)
		{
			// Cannot calculate intercept time
			if (developer >= 1)
			{
				Console.Printf("Cannot calculate intercept time!");
			}
			return 0.0;
		}
		// This aims ahead of the target. If the other root was used,
		// the calculated impact point would be behind the target.
		double time = (-b - sqrt(radicand)) / (2 * a);
		return time;
	}

	// Takes projectile origin and target position rather than the vector
	// between the two positions.
	static double GetInterceptTime4(Vector3 ProjPos, Vector3 TargetPos, Vector3 TargetVel, double MissileSpeed)
	{
		// LevelLocals.Vec3Diff accounts for portals
		Vector3 ToTarget = LevelLocals.Vec3Diff(ProjPos, TargetPos); // TargetPos - ProjPos
		return ZScriptTools.GetInterceptTime(ToTarget, TargetVel, MissileSpeed);
	}

	// Is a particular bit set in this integer?
	static bool BitIsSet(int number, int bitIndex)
	{
		return !!(number & (1 << bitIndex));
	}

	// Set a bit in this integer
	static int BitSet(int number, int bitIndex)
	{
		return number | (1 << bitIndex);
	}

	// Unset a bit in this integer
	static int BitUnset(int number, int bitIndex)
	{
		return number & (~(1 << bitIndex));
	}

	// Get Z velocity for a falling projectile such that it hits a target at
	// the given distance and height.
	//
	// time is the 2D distance between the shooter and target, divided by the
	// speed. In other words, the amount of time (in tics) the projectile would
	// take to reach the target if it didn't fall.
	//
	// gravity is the amount the Z velocity decreases each tic.
	//
	// height is the height difference between the shooter and target.
	static double ArcZVel(double time, double gravity, double height = 0)
	{
		gravity *= .5; // I have no idea why I needed to do this, but I did...
		double badd = height / time;
		double b = time * gravity + badd;
		return -gravity + b;
	}

	// Like "clamp", but for angles rather than plain numbers
	static double ClampAngle(double angle, double min, double max)
	{
		min = Actor.Normalize180(min);
		max = Actor.Normalize180(max);
		double maxdiff = Actor.deltaangle(angle, max);
		double mindiff = Actor.deltaangle(min, angle);
		// Invert clamp
		if (maxdiff < 0 && mindiff < 0)
		{
			if (mindiff < maxdiff)
			{
				return max;
			}
			else
			{
				return min;
			}
		}
		if (maxdiff < 0)
		{
			return max;
		}
		else if (mindiff < 0)
		{
			return min;
		}
		return Actor.Normalize180(angle);
	}

	static Vector3 GetTraceDirection(double Angle, double Pitch)
	{
		return (
			cos(Angle) * cos(Pitch),
			sin(Angle) * cos(Pitch),
			-sin(Pitch)
		);
	}

	// Convert int to Roman numerals...  Just because.
	// Reference https://www.hanshq.net/roman-numerals.html for algorithm used
	static clearscope String ToRomanNumerals(int input)
	{
		static const string numerals[] = { "I", "V", "X", "L", "C", "D", "M" };
		int d = 0;
		String roman = "";

		while (input > 0)
		{
			int num = input % 10;

			if (num % 5 < 4)
			{
				for (int i = num % 5; i > 0; i--)
				{
					roman = numerals[d] .. roman;
				}
			}
			if (num >= 4 && num <= 8) { roman = numerals[d + 1] .. roman; }
			if (num == 9) { roman = numerals[d + 2] .. roman; }
			if (num % 5 == 4) { roman = numerals[d] .. roman; }

			input /= 10;
			d += 2;
		}

		return roman;
	}

	// Takes a string of font names, separated by '|'.  Checks to see if the 'check' string can be
	// printed by each listed font; if one is able to print the string, that font is returned.
	//
	//  This will check to see if Chalkboard can print all of the characters listed, and if not, it
	//  will move on to Typewriter and test it the same way, and so on:
	//
	//  	ZScriptTools.GetViableFont("Chalkboard|Typewriter|handwriting_neat|handwriting_institute|chickn24", "0123456789%/ :");
	//
	//  Fallback if none of the passed fonts can print the string is to return SmallFont.
	static clearscope Font GetViableFont(String fntname, String check = "")
	{
		// Split the string to create an array of font names
		Array<String> fonts;
		fntname.Split(fonts, "|");

		// Iterate through the array of fonts until you find one that can print all of the characters
		for (int f = 0; f < fonts.Size(); f++)
		{
			Font fnt = Font.GetFont(fonts[f]);
			if (fnt && ZScriptTools.DebugFontGlyphs(fonts[f], check)) { return fnt; }
		}

		return SmallFont; // If all else fails, fall back to SmallFont
	}

	static void TestFonts()
	{
		String data = FileReader.ReadLump("LANGUAGE.csv");

		Array<String> lines;
		data.Split(lines, "\n");

		String fntname = "amh18|bigfont|bigupper|chalkboard|chickn24|Classic|handwriting_institute|handwriting_neat|MavenProSmall|run14|smallfont|threefiv|typewriter";

		Array<String> fonts;
		fntname.Split(fonts, "|");

		for (int f = 0; f < fonts.Size(); f++)
		{
			String output = "";

			console.printf("\cKTesting font \cC%s\cK...", fonts[f]);

			for (int r = 1; r < lines.Size(); r++)
			{
				output = ZScriptTools.TestFont(fonts[f], lines[r], output);
			}

			if (output.length()) { console.printf("\cG  Missing: \cJ%s\n", output); }
			else { console.printf("\cD  All characters found.\n", fonts[f], output); }
		}
	}

	static void TestFontFallback()
	{
		String fntname = "amh18|bigfont|bigupper|chalkboard|chickn24|Classic|handwriting_institute|handwriting_neat|MavenProSmall|run14|smallfont|threefiv|typewriter";

		Array<String> fonts;
		fntname.Split(fonts, "|");

		for (int f = 0; f < fonts.Size(); f++)
		{
			String output = "";

			console.printf("\cKTesting font \cC%s\cK for language '\cC%s\cK'...", fonts[f], language);

			String teststring = StringTable.Localize("REQUIRED_CHARACTERS", false);
			teststring = teststring .. teststring.MakeLower();

			output = ZScriptTools.TestFont(fonts[f], teststring, output);

			if (output.length()) { console.printf("\cG  Missing: \cJ%s\n", output); }
			else { console.printf("\cD  All characters found.\n", fonts[f], output); }
		}
	}

	static clearscope String TestFont(String fnt, String check, String output = "")
	{
		bool valid;
		String result;
		[valid, result] = ZScriptTools.DebugFontGlyphs(fnt, check, true);

		if (!valid)
		{
			Array<String> results;
			result.split(results, ", ");
			for (int r = 0; r < results.Size(); r++)
			{
				if (output.IndexOf(results[r]) == -1)
				{
					if (output.length()) { output = output .. ", "; }
					output = output .. results[r];
				}
			}
		}

		return output;
	}

	// Strip color codes out of a string
	static String StripColorCodes(String input)
	{
		int place = 0;
		int len = input.length();
		String output;

		while (place < len)
		{
			if (!(input.Mid(place, 1) == String.Format("%c", 0x1C)))
			{
				output = output .. input.Mid(place, 1);
				place++;
			}
			else if (input.Mid(place + 1, 1) == "[")
			{
				place += 2;
				while (place < len - 1 && !(input.Mid(place, 1) == "]")) { place++; }
				if (input.Mid(place, 1) == "]") { place++; }
			}
			else
			{
				if (place + 1 < len - 1) { place += 2; }
				else break;
			}
		}

		return output;
	}

	// UTF aware character-by-character printing check
	static bool, string DebugFontGlyphs(String fnt, String input, bool silent = false)
	{
		if (fnt == "") { return false, ""; }
		if (input == "") { return true, ""; }

		Font testfont = Font.GetFont(fnt);
		if (!testfont)
		{
			if (developer && !silent) { console.printf("\cKFont \cC%s \cKcould not be found.", fnt); }
			return false, "";
		}

		if (testfont.CanPrint(input)) { return true, ""; } // Skip the additional logic if the string is printable

		input = ZScriptTools.StripColorCodes(input);

		String fail;
		int c = 0;

		for (int i = 0; i < input.CodePointCount(); ++i)
		{
			int t;
			[t, c] = input.GetNextCodePoint(c);

			String test = String.Format("%c", t);
			if (test.length() && !testfont.CanPrint(test))
			{
				if (fail.IndexOf(test) == -1)
				{
					if (fail.length()) { fail = fail .. ", "; }
					fail = String.Format("%s%s (%04X)", fail, test, t);
				}
			}
		}

		if (fail.length())
		{
			if (developer && !silent) { console.printf("\cKFont \cC%s \cKcannot print \cJ%s\cK.", fnt, fail); }
			return false, fail;
		}

		return true, "";
	}

	static bool IsWhitespace(int c)
	{
		switch (c)
		{
			// Reference https://en.wikipedia.org/wiki/Whitespace_character
			case 0x0009:
			case 0x000A:
			case 0x000B:
			case 0x000C:
			case 0x000D:
			case 0x0020:
			case 0x0085: 
			case 0x00A0:
			case 0x1680:
			case 0x2000:
			case 0x2001:
			case 0x2002:
			case 0x2003:
			case 0x2004:
			case 0x2005:
			case 0x2006:
			case 0x2007:
			case 0x2008:
			case 0x2009:
			case 0x200A:
			case 0x2028:
			case 0x2029:
			case 0x202F:
			case 0x205F:
			case 0x3000:
				return true;
			default:
				return false;
		}
	}

	static String Trim(String input)
	{
		if (input.Length() < 1) { return ""; }

		String output = input;

		while (ZScriptTools.IsWhiteSpace(output.GetNextCodePoint(0))) { output.Remove(0, 1); }
		while (ZScriptTools.IsWhiteSpace(output.GetNextCodePoint(output.CodePointCount() - 1))) { output.DeleteLastCharacter(); }

		return output;
	}

	static int, double GetLightLevel(Sector cursec)
	{
		if (!cursec) { return 0, 0; }

		int lightlevel = cursec.lightlevel;

		Color light = cursec.ColorMap.LightColor;
		Color fade = cursec.ColorMap.FadeColor;

		int density = cursec.ColorMap.FogDensity;
		if (!density) { density = lightlevel; }

		double fogamount = (255 - (light.r + light.g + light.b) / 3.0) + ((fade.r + fade.g + fade.b) / 3.0) * density / 255.0;
		double fogfactor = clamp(fogamount, 0, 100);

		// Average (inverted) RGB light level minus fog depth
		return lightlevel, fogfactor;
	}

	enum StringPosition
	{
		STR_LEFT = 0,
		STR_RIGHT = 1,
		STR_CENTERED = 2,
		STR_TOP = 4,
		STR_BOTTOM = 8,
		STR_MIDDLE = 16,
		STR_FIXED = 32 // Print directly on screen, not in hud coordinate space
	}

	static ui void TypeString(Font fnt, BrokenString lines, int msgwidth, Vector2 textpos, int texttic, double textscale = 1.0, double alpha = 1.0, Vector2 screensize = (640, 400), int flags = STR_CENTERED | STR_MIDDLE)
	{
		int lineheight = int(SmallFont.GetHeight());

		int chars;

		double h = int(screensize.y);
		double w = int(screensize.y * 5 / 3);

		double textw = 0;
		double texth = 0;

		for (int lw = 0; lw < lines.Count(); lw++)
		{
			int width = lines.StringWidth(lw);
			if (width > textw) { textw = width; }

			texth += lineheight;
		}

		if (flags & STR_RIGHT) { textpos.x -= textw; }
		else if (flags & STR_CENTERED) { textpos.x -= textw / 2; }

		if (flags & STR_BOTTOM) { textpos.y -= texth; }
		else if (flags & STR_MIDDLE) { textpos.y -= texth / 2; }

		for (int l = 0; l < lines.Count() || chars > texttic; l++)
		{
			int len = min(texttic - chars, lines.StringAt(l).CodePointCount());

			String line = "";
			int nextchar = 0, i = 0;
			while (i < len)
			{
				int c;
				[c, nextchar] = lines.StringAt(l).GetNextCodePoint(nextchar);
				line = String.Format("%s%c", line, c);

				i++;
			}

			if (flags & STR_FIXED) { screen.DrawText(fnt, Font.CR_UNTRANSLATED, textpos.x / textscale, textpos.y / textscale + l * lineheight / textscale, line, DTA_VirtualWidth, int(w * textscale), DTA_VirtualHeight, int(h * textscale), DTA_Alpha, alpha); }
			else { DrawToHud.DrawText(line, (textpos.x, textpos.y + l * lineheight), fnt, alpha, textscale, screensize, Font.CR_UNTRANSLATED); }
			chars += len;
		}
	}

	// Converted and made Unicode-aware by AFADoomer from GetMessageTime ACS code written by Talon1024
	//
	//   Calculate time (in tics, 1/35 of a second) to display the message on-screen,
	//   hopefully giving players enough time to read it, whilst not displaying it
	//   for too long. "message" is the identifier of a LANGUAGE entry.
	//
	static int GetMessageTime(String message)
	{
		message = StringTable.Localize(message, false);

		int extraTime = 70; // 2 extra seconds
		int perWordTime = 6; // Tics per word
		int longWordPerCharTics = 2; // Tics to add per char in a long word
		int spaces = 0; // Number of spaces. Add 1 to get word count, multiply by perWordTime and add longWordTime and extraTime to get estimated reading time.
		int longWordTime = 0; // Extra time to add for long words (7 or more letters)
		int consecutiveChars = 0; // Consecutive letters

		int nextchar = 0;
		for (int i = 0; i < message.CodePointCount(); i++)
		{
			int strchar;
			[strchar, nextchar] = message.GetNextCodePoint(nextchar);

			if (ZScriptTools.IsWhiteSpace(strchar))
			{
				spaces++;

				if (consecutiveChars >= 7) { longWordTime += longWordPerCharTics * consecutiveChars; }
				consecutiveChars = 0;
			}
			else { consecutiveChars++; }
		}

		return (spaces + 1) * perWordTime + longWordTime + extraTime;
	}

	// Converted from ACS; Function to check for a voiceover, play it, and print an error if it isn't found
	static int PlaySound(Actor mo, String text)
	{
		// Get localized SNDINFO entry for voice acting
		String messageKey = "SND_" .. text;
		String messageEntry = StringTable.Localize(messageKey, false);

		bool hassound = !(messageKey ~== messageEntry);
		
		double soundLength = 0;
		if (hasSound) { soundLength = S_GetLength(messageEntry); }

		if (!hasSound || soundLength == 0)
		{
			if (boa_debugvoiceovers) { console.printf("\cgMissing voiceover: \cjCheck SNDINFO entry and audio file for \cf%s\cj!", text); }

			return 0;
		}

		mo.A_StartSound(messageEntry, CHAN_BODY, CHANF_LOCAL);

		return int(soundLength * 35);
	}

	// Returns the scale necessary to cleanly resize an image to fit into a box of a sepcific size
	static Vector2, Vector2 ScaleTextureTo(TextureID tex, int size = 16)
	{
		Vector2 texsize = TexMan.GetScaledSize(tex);
		Vector2 imagesize = texsize;
		if (texsize.x > size || texsize.y > size)
		{
			if (texsize.y > texsize.x)
			{
				texsize.y = size * 1.0 / texsize.y;
				texsize.x = texsize.y;
			}
			else
			{
				texsize.x = size * 1.0 / texsize.x;
				texsize.y = texsize.x;
			}
		}
		else { texsize = (1.0, 1.0); }

		imagesize.x *= texsize.x;
		imagesize.y *= texsize.y;

		return texsize, imagesize;
	}
	
	// Makes the game close the automap (use it for a scripted sequence that is not in the
	// beginning of the level, such as in C3M0_B). Pauses the game for one tic as a side effect.
	static void CloseAutomap()
	{
		level.StartIntermission('Automap_Hack', FSTATE_InLevel);
	}
}

// Functions to identify the current IWAD and read info from the matching IWADINFO block
// Uses the FileReader class and ParsedValue functions to parse IWADINFO data
class WADInfo
{
	// Look up and parse the IWADINFO block associated with the current IWAD
	static ParsedValue GetIWADInfo()
	{
		int w = WADIndex("PLAYPAL"); // Get the first loaded WAD with a PLAYPAL entry; this is the IWAD
		int i = Wads.CheckNumForName("IWADINFO", 0, w); // Try to load IWADINFO from that IWAD (only works for custom mods)

 		// If no IWADINFO was found in the WAD, load the engine IWADINFO lump from game_support.pk3
		if (i < 0)
		{
			w = WADIndex("IWADINFO"); // Get the first wad with an IWADINFO lump that you can find; this will be game_support.pk3
			i = Wads.CheckNumForName("IWADINFO", 0, w); // Try to load the IWADINFO from game_support.pk3

			if (i == -1) { return null; } // If none found somehow, abort.
		}

		String infodata = Wads.ReadLump(i); // Read the lump into a string

		// Manually do a naive parsing of IWADINFO to add end-of-line semicolons so FileReader can parse it
		Array<String> info;
		infodata.Split(info, "\n");
		infodata = "";

		for (int i = 0; i < info.Size(); i++)
		{
			String line = ZScriptTools.Trim(info[i]);
			if (line.IndexOf("=") > -1 || line.IndexOf("\x22") > -1) { line = line .. ";"; } // Stick a semicolon on the end if it contains quotes or an equal sign

			infodata = infodata .. "\n" .. line; // Then re-concatenate everything back together
		}

		// Parse the string with FileReader to make the data logically accessible
		ParsedValue IWADs = new("ParsedValue");
		FileReader.ParseString(infodata, IWADs);

		// Iterate through all defined IWADs to find a definition whose required lumps are all currently loaded
		ParsedValue IWAD = IWADs.Find("IWAD");
		while (IWAD)
		{
			String mustcontain = FileReader.GetString(IWAD, "mustcontain");

			if (mustcontain.length())
			{
				Array<String> lumps;
				mustcontain.Split(lumps, ",");

				for (int l = 0; l < lumps.Size(); l++)
				{
					lumps[l] = FileReader.StripQuotes(lumps[l]);
				}

				if (CheckIWADLumps(lumps)) { return IWAD; } // If the lumps were all there, this is our matching IWADINFO
			}
			else
			{
				return IWAD; // If it doesn't have any 'mustcontain' lumps defined, it's a custom IWAD/IPK3 anyway
			}

			IWAD = IWADs.Next("IWad");
		}

		return null;
	}

	// Iterate through wads in load order (defaulting to up to 15 files) and return the
	// index of the first one containing a lump matching the lump name that was passed in. 
	// This can be used to get the index of gzdoom.pk3, game_support.pk3, the current IWAD, 
	// etc. by searching for lumps that first appear in those files.
	//
	// Examples:
	//  DEHSUPP -> gzdoom.pk3
	//  IWADINFO -> game_support.pk3
	//  PLAYPAL -> Current IWAD
	//
	static int WADIndex(String lump, int max = 15)
	{
		for (int i = 0; i < max; i++)
		{
			int l = Wads.CheckNumForName(lump, 0, i);
			if (l > -1) { return i; }
		}

		return -1;
	}

	// Search the current IWAD for all lumps listed in an array of strings
	static bool CheckIWADLumps(Array<String> lumps)
	{
		int w = WADIndex("PLAYPAL"); // First PLAYPAL lump parsed by the engine will be in the IWAD

		for (int i = 0; i < lumps.Size(); i++)
		{
			int l = -1;
			
			for (int n = Wads.ns_global; n < Wads.ns_firstskin; n++) // Iterate through all namespaces for this check
			{
				int m = Wads.CheckNumForName(lumps[i], n, w); // Try to find the lump

				if (m > -1)
				{
					l = m; // If it was found, move on to search for the next lump
					break;
				}
			}

			if (l < 0) { return false; } // If the lump wasn't found in any namespace, this is not the file we are looking for
		}

		return true;
	}

	// Wrapper function to handle looking up a value with a single call
	//  e.g.: String IWADName = WadInfo.GetIWADInfoEntry("name");
	static String GetIWADInfoEntry(String entry = "name")
	{
		ParsedValue IWAD = GetIWADInfo();
		if (IWAD) { return FileReader.GetString(IWAD, entry, true); }

		return "";
	}
}
