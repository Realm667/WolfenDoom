/*
 * Copyright (c) 2021 AFADoomer, N00b
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

// BrokenLines-alike class with the same functions for accessing string info to 
// allow easier insertion into existing code with minimal changes
class BrokenString : Object
{
	Array<String> lines;
	private Font fnt;

	int Count()
	{
		return lines.Size();
	}

	int StringWidth(int line)
	{
		if (line < 0 || line >= lines.Size()) { return 0; }
		return fnt.StringWidth(ZScriptTools.Trim(ZScriptTools.StripColorCodes(lines[line])));
	}

	String StringAt(int line)
	{
		if (line < 0 || line >= lines.Size()) { return ""; }

		return lines[line];
	}

	// Used in the BreakString function to do initial setup; negligible direct use to end user
	static BrokenString Init(Font fnt)
	{
		BrokenString newobj = New("BrokenString");
		if (!newobj) { return null; }

		newobj.fnt = fnt;
		if (!newobj.fnt) { newobj.fnt = SmallFont; }

		newobj.lines.Clear();

		return newobj;
	}

	// ZScript implementation of similar funtionality to V_BreakLines.
	//  Some logic taken from https://github.com/coelckers/gzdoom/blob/master/src/common/fonts/v_text.cpp
	ui static String, BrokenString BreakString(String input, int maxwidth, bool flow = false, String defaultcolor = "L", Font fnt = null)
	{
		if (fnt == null) { fnt = SmallFont; }

		BrokenString brokenlines = BrokenString.Init(fnt);

		if (!input.length()) { return "", brokenlines; }
		input = StringTable.Localize(input, false);

		int c = -1, colorindex, wordindex;
		String output;
		String currentcolor = defaultcolor, lastcolor = defaultcolor;
		String colorstring = "\c" .. (defaultcolor.length() > 1 ? "[" .. defaultcolor .. "]" : defaultcolor);

		int i = 0;
		String line = "", word = "";
		int buttonwidth;

		if (flow) // Flow the text to fill most of the lines that it would take up at the the passed-in maxwidth value
		{
			double w = fnt.StringWidth(input);
			int linecount = int(ceil(w / maxwidth));

			maxwidth = int(min(fnt.StringWidth(input) * 1.25 / linecount, maxwidth));
		}

		while (c != 0)
		{
			[c, i] = input.GetNextCodePoint(i);

			if (c != 0x0A) { word.AppendCharacter(c); } // Don't save line breaks as part of a word

			if (c == 0x1C) // TEXTCOLOR_ESCAPE
			{
				colorindex = i; // Remember the index of the color so that we can revert to the old color if the last space precededes the color change

				[c, i] = input.GetNextCodePoint(i);
				word.AppendCharacter(c);

				String newcolor = "";

				if (c == 0x5B) // [
				{
					while (c && c != 0x5D) // ]
					{
						[c, i] = input.GetNextCodePoint(i);
						word.AppendCharacter(c);
						if (c != 0x5D) { newcolor.AppendCharacter(c); }
					}
				}
				else
				{
					newcolor = String.Format("%c", c);
				}

				// Remember the previous color in case the string gets cut before this point
				if (currentcolor != newcolor)
				{
					lastcolor = currentcolor;
					currentcolor = newcolor;
				}

				continue;
			}
			/* Preliminary implementation of button/key prompt-aware line splitting; has some issues, so commented out
			else if (c == 0x5B) // [
			{
				String label = "";
				[c, i] = input.GetNextCodePoint(i);
				word.AppendCharacter(c);
				label.AppendCharacter(c);

				if (c == 0x5B) // [ (double brackets surround inline key binds)
				{
					String binding = "";
					while (c && c != 0x5D) // ]
					{
						[c, i] = input.GetNextCodePoint(i);
						word.AppendCharacter(c);
						label.AppendCharacter(c);
						if (c != 0x5D) { binding.AppendCharacter(c); }
					}
					[c, i] = input.GetNextCodePoint(i);
					word.AppendCharacter(c);
					label.AppendCharacter(c);

					buttonwidth += DrawToHUD.DrawCommandButtons((0, 0), binding, flags:Button.BTN_CALC) - fnt.StringWidth(ZScriptTools.StripColorCodes(label));
				}
			}
			*/

			if (fnt.StringWidth(ZScriptTools.StripColorCodes(line)) + fnt.StringWidth(ZScriptTools.StripColorCodes(word)) + buttonwidth > maxwidth || c == 0x0A || c == 0)
			{ // Text is longer than maxwidth or there is a line break
				if ((c == 0x0A || c == 0) && fnt.StringWidth(ZScriptTools.StripColorCodes(line)) + fnt.StringWidth(ZScriptTools.StripColorCodes(word)) + buttonwidth < maxwidth)
				{
					line = line .. word;
					wordindex = i;
					word = "";

					lastcolor = currentcolor;
				}

				// Ported from this commit:
				// https://github.com/ZDoom/GZDoom/commit/ccf46281df46d9b350efefd893d4844cac71bfe0
				for (int pos = 0; pos < line.Length(); pos++)
				{
					if (line.ByteAt(pos) == 0x1C)
					{
						pos++;
						if (pos)
						{
							if (line.ByteAt(pos) == 0x5B) // [
							{ // Named colour
								int cstart = pos;
								while (line.ByteAt(pos) != 0x5D) // ]
								{
									pos++;
								}
								lastcolor = line.Mid(cstart, pos - cstart);
							}
							else
							{
								lastcolor = line.Mid(pos, 1);
							}
						}
					}
				}

				String printcolor = currentcolor;				
				if (colorindex > wordindex) { printcolor = lastcolor; } // Make sure the color change didn't happen after the last known space
				printcolor = printcolor.length() > 1 ? "[" .. printcolor .. "]" : printcolor; // Handle named colors

				if (brokenlines)
				{
					colorstring = "\c" .. printcolor;
					brokenlines.lines.Push(colorstring .. line);
				}

				output.AppendFormat("%s%c\c%s", line, 0x0A, printcolor);

				line = "";
				buttonwidth = 0;
			}
			else if (ZScriptTools.IsWhiteSpace(c))
			{
				line = line .. word;
				wordindex = i;
				word = "";
			}
		}

		if (word.length())
		{
			if (brokenlines) { brokenlines.lines.Push(colorstring .. word); }
			output.AppendFormat("%s", word);
		}

		return output, brokenlines;
	}
}