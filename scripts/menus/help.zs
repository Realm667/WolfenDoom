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

class BoAInfo : BoAMenu
{
	int mScreen;
	int mInfoTic, prevtic;
	int dir, w, h;
	ParsedValue data;
	int maxpages;
	double labelscale;
	bool continousscroll;
	bool once;

	override void Init(Menu parent)
	{
		Super.Init(parent);
		mScreen = 1;
		dir = 0;
		mInfoTic = gametic;

		data = FileReader.Parse("data/InfoScreen.txt");

		if (!data) { return; }

		data.Init();
		while (data.Next("page")) { maxpages++; }

		w = FileReader.GetInt(data, "global.defaults.screenwidth");
		if (!w) { w = 320; }

		h = FileReader.GetInt(data, "global.defaults.screenheight");
		if (!h) { h = 200; }

		labelscale = FileReader.GetDouble(data, "global.defaults.labelscale");
		if (!labelscale) { labelscale = 1.0; }
	}

	override void Drawer()
	{
		double alpha, scale, prevscale;
		TextureID tex, prevpic, label_l, label_r;
		
		if (!data) { return; }
		
		if (!tex.IsValid())
		{
			ParsedValue page = data.Find("page", mScreen);
			tex = TexMan.CheckForTexture(GetString(page, "attributes.background"), TexMan.Type_Any);
			scale = GetDouble(page, "attributes.scale");
		}

		if (mScreen > 0 && mScreen <= maxpages)
		{
			ParsedValue prevpage = data.Find("page", mScreen - dir);
			prevpic = TexMan.CheckForTexture(GetString(prevpage, "attributes.background"), TexMan.Type_Any);
			prevscale = GetDouble(prevpage, "attributes.scale");
		}

		screen.Dim(0, 1.0, 0,0, screen.GetWidth(), screen.GetHeight());
		alpha = MIN((gametic - mInfoTic) * (3. / Thinker.TICRATE), 1.);
		if (alpha < 1. && prevpic.IsValid())
		{
			screen.DrawTexture (prevpic, false, 0, 0, DTA_FullscreenEx, 3);
			DrawBlocks(data, mScreen - dir, 1.0, prevtic, prevscale);
		}
		else alpha = 1;
		screen.DrawTexture (tex, false, 0, 0, DTA_FullscreenEx, 3, DTA_Alpha, alpha);
		DrawBlocks(data, mScreen, alpha, mInfoTic, scale);

		label_l = TexMan.CheckForTexture("graphics/finale/finale_label_l.png", TexMan.Type_Any);
		label_r = TexMan.CheckForTexture("graphics/finale/finale_label_r.png", TexMan.Type_Any);

		int lw, lh;

		if (label_r)
		{
			[lw, lh] = TexMan.GetSize(label_r);
			double offset = (w / 10) / labelscale + lw;
			screen.DrawTexture(label_r, false, w / labelscale - offset, h / labelscale - 4 * labelscale - lh, DTA_VirtualWidthF, w / labelscale, DTA_VirtualHeightF, h / labelscale);
			screen.DrawText(SmallFont, Font.CR_GRAY, w / labelscale - offset + 12, h / labelscale - 4 * labelscale  + 3 / labelscale - lh, StringTable.Localize("$PAGE") .. " " .. mScreen .. " " .. StringTable.Localize("$OF") .. " " .. maxpages, DTA_VirtualWidthF, w / labelscale, DTA_VirtualHeightF, h / labelscale);
		}

		if (label_l) { screen.DrawTexture(label_l, false, (w / 10) / labelscale, h / labelscale - 4 * labelscale - lh, DTA_VirtualWidthF, w / labelscale, DTA_VirtualHeightF, h / labelscale); }

		once = true;
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mkey == MKEY_Back)
		{
			Close();	
			return true;
		}
		else if (mkey == MKEY_Right || mkey == MKEY_Down || mkey == MKEY_Enter)
		{
			if (mScreen + 1 <= maxpages)
			{
				mScreen++;
				dir = 1;
				prevtic = mInfoTic;
				mInfoTic = gametic;
				once = false;
				return true;
			}
		}
		else if (mkey == MKEY_Left || mkey == MKEY_Up)
		{
			if (mScreen - 1 > 0)
			{
				mScreen--;
				dir = -1;
				prevtic = mInfoTic;
				mInfoTic = gametic;
				once = false;
				return true;
			}
		}

		return false;
	}

	override bool MouseEvent(int type, int x, int y)
	{
		if (type == MOUSE_Click)
		{
			if (x > Screen.GetWidth() / 2) { MenuEvent(MKEY_Right, false); }
			else { MenuEvent(MKEY_Left, false); }
		}

		return false;
	}

	override bool OnUIEvent(UIEvent ev)
	{
		// Intercept key presses to see if we're pressing the strafe controls or use, 
		// and redirect those to call the correct left/right/open movement menu event code.

		if (ev.Type == UIEvent.Type_KeyDown)
		{
			CheckControl(ev, "+moveleft", MKEY_Left);
			CheckControl(ev, "+moveright", MKEY_Right);
			CheckControl(ev, "+use", MKEY_Enter);
			CheckControl(ev, "+forward", MKEY_Up);
			CheckControl(ev, "+back", MKEY_Down);
		}

		return Super.OnUIEvent(ev);
	}

	void DrawBlocks(ParsedValue data, int pagenum, double alpha, int tic, double scale)
	{
		if (!scale) { scale = 1.0; }

		if (data)
		{
			data.Init(); // Reset to the top of the file

			ParsedValue page = data.Find("page", pagenum);

			if (page)
			{
				page.Init();

				ParsedValue block = page.Find("block");

				while (block)
				{
					DrawBlock(block, alpha, tic, scale);

					block = page.Next("block");
				}
			}
		}
	}

	int GetInt(ParsedValue block, String property)
	{
		int t;
		String s;

		t = FileReader.GetInt(block, property);

		if (!t)
		{
			s = FileReader.GetString(block, property);
			if (s.length()) { t = FileReader.GetInt(data, "global." .. s); }
		}

		if (!t && block.parent) { t = FileReader.GetInt(data, "block.parent." .. property); }
		if (!t) { t = FileReader.GetInt(data, "global.defaults." .. property); }

		return t;
	}

	bool GetBool(ParsedValue block, String property)
	{
		bool t;
		String s;

		t = FileReader.GetBool(block, property);

		if (!t)
		{
			s = FileReader.GetString(block, property);
			if (s.length()) { t = FileReader.GetBool(data, "global." .. s); }
		}

		if (!t && block.parent) { t = FileReader.GetBool(data, "block.parent." .. property); }
		if (!t)	{ t = FileReader.GetBool(data, "global.defaults." .. property); }

		return t;
	}

	double GetDouble(ParsedValue block, String property)
	{
		double t;
		String s;

		t = FileReader.GetDouble(block, property);

		if (!t) // If nothing was returned, check to see is a global variable is being used
		{
			s = FileReader.GetString(block, property);
			if (s.length()) { t = FileReader.GetDouble(data, "global." .. s); }
		}

		// If nothing was returned, fall back to the parent's value, then to the default value, if set
		if (!t && block.parent) { t = FileReader.GetDouble(data, "block.parent." .. property); }
		if (!t) { t = FileReader.GetDouble(data, "global.defaults." .. property); }
		return t;
	}

	void SetValue(ParsedValue block, String property, String value)
	{
		ParsedValue key = block.Find(property);
		if (!key)
		{
			key = New("ParsedValue");
			key.KeyName = property;
			block.Children.Push(key);
		}

		key.Value = value;
	}

	String GetString(ParsedValue block, String property)
	{
		String s = FileReader.GetString(block, property);

		if (s.Left(6) ~== "global.")
		{
			s = FileReader.GetString(data, "global." .. s);
		}

		if (!s.length() && block.parent) { s = FileReader.GetString(data, "block.parent." .. property); }
		if (!s.length()) { s = FileReader.GetString(data, "global.defaults." .. property); }

		return s;
	}

	void DrawBlock(ParsedValue block, double alpha, int tic, double scale)
	{
		// Scale to the center of the draw area (fudge y coords slightly to account for header and labels
		double x = GetInt(block, "attributes.x") * scale;
		x += w * (1.0 - scale) * 0.5;

		double y = GetInt(block, "attributes.y") * scale;
		y += h * (0.93 - scale) * 0.5;

		double bw = GetInt(block, "attributes.width") * scale;
		double bh = GetInt(block, "attributes.height") * scale;
		double margin = GetInt(block, "attributes.margin") * scale;

		string dimcolor = GetString(block, "attributes.dimcolor");
		double dimalpha = GetDouble(block, "attributes.dimalpha");

		Vector2 pos, size, marginsize;
		[pos, marginsize] = Screen.VirtualToRealCoords((x, y), (margin, margin), (w, h)); // Get "real" screen coords and size for Dim call and clipping in the draw calls
		[pos, size] = Screen.VirtualToRealCoords((x, y), (bw, bh), (w, h));
		Screen.Dim(dimcolor, dimalpha * alpha, int(pos.x), int(pos.y), int(size.x), int(size.y));

		double yoffset = margin;

		double scrollspeed = GetDouble(block, "attributes.scrollspeed");
		int scrolldelay = GetInt(block, "attributes.scrolldelay");
		double scrolloffset = (gametic - tic - scrolldelay) * scrollspeed;
		if (scrolloffset > 0) { yoffset -= scrolloffset; }

		ParsedValue content = block.Find("content");

		while (content)
		{
			Font fnt = Font.GetFont(GetString(content, "font"));
			Font initialfnt = fnt;

			String text = StringTable.Localize(GetString(content, "text"));
			double textscale = GetDouble(content, "fontscale");
			if (!textscale) { textscale = 1.0; }

			textscale *= scale;

			if (!once && alpha < 1.0) { ZScriptTools.DebugFontGlyphs(GetString(content, "font"), text); }

			if (!fnt || !fnt.CanPrint(text)) { fnt = SmallFont; } // If the font can't print the string, try falling back to SmallFont
			if (!fnt.CanPrint(text)) { fnt = NewSmallFont; } // If SmallFont still can't print it, use the engine's built-in NewSmallFont

			if (initialfnt && fnt != initialfnt) // If the font was changed, adjust the scale so the sizes match
			{
				int initialheight = initialfnt.GetHeight();
				int fntheight = fnt.GetHeight();

				double fntscale = scale * double(fntheight) / initialheight;

				textscale /= fntscale;
			}

			double screenscale = screen.GetHeight() / double(h);
			double minscale = 10 / (fnt.GetHeight() * screenscale);
//			textscale = max(textscale, minscale);

			int clr = Font.CR_GRAY;
			String fontcolor = GetString(content, "fontcolor");
			if (fontcolor.length()) { clr = Font.FindFontColor(fontcolor); }

			String align = GetString(content, "align");

			TextureID pic = TexMan.CheckForTexture(GetString(content, "pic"), TexMan.Type_Any);

			String temp; BrokenString lines;
			[temp, lines] = BrokenString.BreakString(text, int((bw - margin * 2) / textscale), false, "C", fnt);

			int cliptop = int(pos.y + marginsize.y);
			int clipbottom = int(pos.y + size.y - marginsize.y);

			if (pic.IsValid())
			{
				double picscale = GetDouble(content, "picscale");
				if (picscale == 0) { picscale = 1.0; }
				picscale *= scale;

				Vector2 picsize = TexMan.GetScaledSize(pic);

				if (yoffset + int(picsize.y * picscale) + margin / 2 > 0)
				{
					double xoffset = (bw / picscale) / 2 - picsize.x / 2;
					if (align ~== "right") { xoffset = (bw - margin) / picscale - picsize.x; }
					else if (align ~== "left") { xoffset = margin / picscale; }

					screen.DrawTexture (pic, true, x / picscale + xoffset, y / picscale + yoffset / picscale, DTA_VirtualWidthF, w / picscale, DTA_VirtualHeightF, h / picscale, DTA_TopOffset, 0, DTA_LeftOffset, 0, DTA_Alpha, alpha, DTA_ClipTop, cliptop, DTA_ClipBottom, clipbottom);
				}

				yoffset += picsize.y * picscale + margin / 2;

				if (yoffset > bh - margin) { return; }
			}

			double contentscrollspeed = GetDouble(content, "scrollspeed");

			if (!scrollspeed)
			{
				double contenttop = y + yoffset;
				double contentbottom = contenttop + lines.Count() * fnt.GetHeight() * textscale;
				double contentsize = min(contentbottom, y + bh) - contenttop;

				Vector2 top, bottom;
				top = Screen.VirtualToRealCoords((x + margin, contenttop), (0, 0), (w, h));
				bottom = Screen.VirtualToRealCoords((x + margin, contentbottom), (0, 0), (w, h));

				cliptop = int(max(cliptop, top.y));
				clipbottom = int(min(clipbottom, bottom.y));

				double contentscrolldelay = GetDouble(content, "scrolldelay");
				double contentscrolloffset = (gametic - tic - contentscrolldelay) * contentscrollspeed;

				// Scroll once and stop
//				contentscrolloffset = min(contentscrolloffset, contentsize / textscale);

				if (!scrollspeed && contentscrolloffset > 0) { yoffset -= contentscrolloffset; }
			}

			for (int t = 0; t < lines.Count(); t++)
			{
				String line = lines.StringAt(t);

				if (yoffset + int(fnt.GetHeight() * textscale) > 0)
				{
					double xoffset = margin;
					double spacing = 0;

					if (align ~== "right") { xoffset = (bw - margin) / textscale - fnt.StringWidth(line); }
					else if (align ~== "center") { xoffset = (bw / textscale) / 2 - fnt.StringWidth(line) / 2; }
					else if (align ~== "full")
					{
						double textwidth = lines.StringWidth(t) * textscale;

						if ( // Don't full justify if a line is the end of a paragraph and it's less than 80% of the block width
							!(
								screenscale < 1.0 ||
								(
									t == lines.Count() - 1 ||
									lines.StringAt(t + 1) == ""
								) &&
								textwidth < (bw - margin * 2) * 0.8
							)
						)
						{
							int spaces = 0;
							int start = 0;
							while (start > -1)
							{
								start = line.IndexOf(" ", start + 1);
								if (start > 0) { spaces++; }
							}

							spacing = spaces ? (bw - margin * 2 - textwidth - 2) / spaces : 0;
							spacing /= textscale;
						}
					}

					if (spacing != 0)
					{
						String temp = "";
						int cur = 0;
						double textx = 0;
						while (cur <= line.length())
						{
							String curchar = line.Mid(cur, 1);
							int charbyte = curchar.ByteAt(0);

							if ( 	// Whitespace
								charbyte == 0x9 || // Tab
								charbyte == 0x20 || // Space
								(charbyte >= 0x2000 && charbyte <= 0x200A) || // Various widths of spaces
								charbyte == 0x2028 || // Line separator
								charbyte == 0x205F || // Math space
								charbyte == 0x3000 || // Ideographic space
								 // End of line
								charbyte == 0x0
							)
							{
								screen.DrawText(fnt, clr, x / textscale + xoffset + textx, y / textscale + yoffset / textscale, temp, DTA_VirtualWidthF, w / textscale, DTA_VirtualHeightF, h / textscale, DTA_Alpha, alpha);

								if (charbyte == 0x9) // Tab alignment
								{
									double tabwidth = w / 10;
									int tabs = int(textx / tabwidth) + 1;
									textx = tabs * tabwidth;
								}
								else // Normal printing
								{
									textx += fnt.StringWidth(temp .. curchar) + spacing * textscale;
								}

								temp = "";
							}
							else
							{
								temp = temp .. curchar;
							}

							cur++;
						}
					}
					else
					{			
						screen.DrawText(fnt, clr, x / textscale + xoffset, y / textscale + yoffset / textscale, line, DTA_VirtualWidthF, w / textscale, DTA_VirtualHeightF, h / textscale, DTA_Alpha, alpha);
					}
				}
				yoffset += fnt.GetHeight() * textscale;

				if (yoffset > bh - margin)
				{
					if (!scrollspeed && minscale == textscale) // Only scroll if you adjusted the scaling and aren't scrolling already
					{
						SetValue(content, "scrollspeed", "0.25");
						SetValue(content, "scrolldelay", "40");
					}

					return;
				}

				// Loop if scrolling content text only
				if (contentscrollspeed && t == lines.Count() - 1)
				{
					yoffset += margin * 2;
					t = -1;
				}
			}

			content = block.Next("content");
			if (content) { once = false; }

			if (!content && scrollspeed) // Incomplete handling for looped scrolling blocks (they only loop for upward scrolling), but enough for our purposes
			{
				content = block.Find("content");
				yoffset += margin / 2;
			}

			yoffset += margin / 2;
		}
	}
}