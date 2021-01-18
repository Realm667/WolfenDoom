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
}
