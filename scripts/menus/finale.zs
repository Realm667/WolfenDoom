/*
 * Copyright (c) 2018-2021 AFADoomer
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

// Base class for text scroller menu screens.  Inherit from this and configure via the Init function (see IntroScroll class below)
// Call from ACS with: 'ScriptCall("Menu", "SetMenu", "IntroScroll");'
// Wait for completion from within ACS with: 'While (!ScriptCall("TextScroll", "Ready")) { Delay(35); }' (checks if the currently open scroller is done)
class TextScroll : BoAMenu
{
	TextureID background, overlay, scrollback;
	Font fnt;
	int clr, mapnum;
	String text;

	double scrolly, scrollx, scrollstep;
	double textwidth, backwidth, backheight;
	double alpha;
	int w, h, margin, topmargin, delay;
	double lineheight;

	bool noskip, finished;

	BrokenString lines;

	override void Init(Menu parent)
	{
		GenericMenu.Init(parent);

		if (!fnt) { fnt = SmallFont; }

		DontDim = true;
		DontBlur = true;
		menuactive = OnNoPause;

		alpha = 1.0;

		w = 900;
		h = int(w * 0.75);
		margin = 160;
		topmargin = 180;
		lineheight = 23.25;

		scrolly = h;
		scrollx = w / 2;

		textwidth = w - 160;

		if (!scrollstep) { scrollstep = 1.0; }

		scrolly += delay / scrollstep;

		if (scrollback)
		{
			[backwidth, backheight] = TexMan.GetSize(scrollback);
			textwidth = backwidth - margin * 2;
		}
		
		String temp;
		[temp, lines] = BrokenString.BreakString(StringTable.Localize(text), int(textwidth), fnt:fnt);

		mapnum = level.levelnum; // Remember what map we're on so that we can close this scroller if the map changes
	}

	override void Drawer()
	{
		if (background) { screen.DrawTexture(background, false, 0, 0, DTA_FullScreenEx, 2); }
		if (scrollback) { screen.DrawTexture(scrollback, false, scrollx - backwidth / 2, scrolly, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, alpha); }

		for (int l = 0; l < lines.Count(); l++)
		{
			screen.DrawText(fnt, clr, scrollx - textwidth / 2, scrolly + topmargin + l * lineheight, lines.StringAt(l), DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, 0.9 * alpha);
		}

		if (overlay) { screen.DrawTexture(overlay, false, 0, 0, DTA_FullScreenEx, 2); }
	}

	override void Ticker()
	{
		scrolly -= scrollstep;

		if (finished || scrolly < -(backheight - lineheight * 12)) // Wait until the scroller is most of the way done before starting the fade-out
		{
			finished = true;
			alpha -= 1.0 / 70; // Fade out over two seconds
		}

		if (alpha <= 0 || (mapnum && mapnum != level.levelnum)) { Close(); } // Close if it faded out or if the map somehow changed

		Super.Ticker();
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mkey == MKEY_Back)
		{
			Menu.SetMenu("MainMenu", -1);
			return true;
		}

		if (noskip) { return false; }

		finished = true;
		return true;
	}

	override bool MouseEvent(int type, int x, int y)
	{
		if (noskip || type == MOUSE_Move) { return false; }

		finished = true;
		return true;
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

	static bool Ready()
	{
		Menu current = Menu.GetCurrentMenu();

		if (current is "TextScroll" && TextScroll(current).finished) { return true; }
		else { return false; }
	}
}

class IntroScroll : TextScroll
{
	TextureID signature;
	int sig_size_y;
	String sig_name;

	override void Init(Menu parent)
	{
		text = "$INTRO_LETTER";			// String of text to display; can be omitted (defaults to no text)
		fnt = Font.GetFont("typewriter");	// Font to use; can be omitted (defaults to SmallFont)
		clr = Font.CR_UNTRANSLATED;		// Font color; can be omitted (defaults to CR_BRICK)

		sig_name = StringTable.Localize(text .. "2");

		// Background image that scrolls with the text; can be omitted (defaults to no image)
		// You can also specify:
		//  'background' for a static full-screen background image behind the scroller
		//  'overlay' for a static full-screen image overlaid on top of the scroller
		scrollback = TexMan.CheckForTexture("graphics/intromap/DDB_LTTB.png", TexMan.Type_Any);

		// Special handling for the signature block
		signature = TexMan.CheckForTexture("graphics/intromap/DDB_LTTS.png", TexMan.Type_Any);
		if (signature)
		{
			int sig_size_x;
			[sig_size_x, sig_size_y] = TexMan.GetSize(signature);
		}

		noskip = false; // Allow the player to exit early (can be omitted; default is false)
		scrollstep = 0.35; // Speed of scroller (can be omitted; default is 0.5)

		Super.Init(parent);
	}

	override void Drawer()
	{
		if (background) { screen.DrawTexture(background, false, 0, 0, DTA_FullScreenEx, 2); }
		if (scrollback) { screen.DrawTexture(scrollback, false, scrollx - backwidth / 2, scrolly, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, alpha); }

		for (int l = 0; l < lines.Count(); l++)
		{
			screen.DrawText(fnt, clr, scrollx - textwidth / 2, scrolly + topmargin + l * lineheight, lines.StringAt(l), DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, 0.9 * alpha);
		}

		// Special handling to add the signature block at the end of the letter
		double sigy = scrolly + topmargin + (lines.Count() + 2) * lineheight; // Skip two blank lines and place the closing title line
		screen.DrawText(fnt, clr, scrollx - textwidth / 2, sigy, sig_name, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, 0.9 * alpha);

		if (signature)
		{
			sigy -= sig_size_y * 0.95; // Then go back up most of the height of the signature to draw the ink signature
			screen.DrawTexture(signature, false, scrollx - 306, sigy, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, alpha);
		}

		if (overlay) { screen.DrawTexture(overlay, false, 0, 0, DTA_FullScreenEx, 2); }
	}
}

// Base class for finale menu screens.  
//
// Call from ACS with: 'ScriptCall("Finale", "Setup", "<String to display>", <true/false - Show stats>, <true/false - Swap draw sides for stats and text>);'
//	Example: ScriptCall("Finale", "Setup", "$EPILOGUEC1", true, false);
//
// Wait for completion from within ACS with: 'While (!ScriptCall("Finale", "Ready")) { Delay(35); }' (checks if the currently open finale is closing)
class Finale : BoAMenu
{
	TextureID background, strips, label_l, label_r, frame;
	Font fnt, titlefnt;
	String text;

	double alpha, textscale;
	int w, h, textwidth, textheight;
	int drawtic;
	double texttic, lineheight;

	BrokenString lines;
	int page, oldpage, maxlines, maxpages, curchar, maxdrawn;

	LevelData totals;

	bool finished, nostats, swapsides;

	double textXOffsetScale;

	override void Init(Menu parent)
	{
		if (automapactive) { ZScriptTools.CloseAutomap(); }

		GenericMenu.Init(parent);

		if (!fnt) { fnt = SmallFont; }
		if (!titlefnt) { titlefnt = BigFont; }

		DontDim = true;
		DontBlur = true;
		menuactive = OnNoPause;

		h = 400;
		w = 640;
		alpha = 1.0;

		textwidth = 270;
		textheight = 260;
		textscale = 1.25;

		lineheight = 12 * textscale;

		background = TexMan.CheckForTexture("graphics/finale/finale_background.png", TexMan.Type_Any);
		strips = TexMan.CheckForTexture("graphics/finale/finale_strips.png", TexMan.Type_Any);
		label_l = TexMan.CheckForTexture("graphics/finale/finale_label_l.png", TexMan.Type_Any);
		label_r = TexMan.CheckForTexture("graphics/finale/finale_label_r.png", TexMan.Type_Any);
		frame = TexMan.CheckForTexture("graphics/finale/finale_frame.png", TexMan.Type_Any);

		/*
		double frameToScreen = Screen.GetWidth() / 960;
		double textToScreen = Screen.GetWidth() / double(w);
		textXOffsetScale = frameToScreen / textToScreen;
		*/
		textXOffsetScale = double(w) / Screen.GetWidth() * textscale;

		InitText(text);

		totals = GetTotals();
	}

	void InitText(String text)
	{
		[text, lines] = BrokenString.BreakString(StringTable.Localize(text), int(textwidth / textscale), false, "U");
		if (!lines) { return; }

		maxlines = int(textheight / lineheight);

		int count = lines.Count();
		for (int c = count - 1; c >= 0; c--)
		{
			if (lines.StringWidth(c) <= 0) { count--; } // Don't count empty lines at the end
			else { break; }
		}		

		double pages = count / maxlines;

		// Subtract any blank lines that will be skipped if they fall at the top of a page.
		int lostlines = 0;
		for (int p = 0; p < pages; p++)
		{
			if (lines.StringWidth(p * maxlines + lostlines) == 0) { lostlines++; }
		}

		// ... and re-calculate the page count.
		pages = (count - lostlines) / maxlines;

		maxpages = int(pages);  // maxpages is an integer, but make sure to always round up if there was even a small amount of overflow
		if (maxpages < pages) { maxpages++; }
	}

	override void Drawer()
	{
		if (!lines) { return; }

		int height = int(Screen.GetHeight());
		int width = int(Screen.GetWidth());

		double backalpha = min(0.5, drawtic / 140.0) * alpha;
		if (background) { screen.DrawTexture(background, true, 0, 0, DTA_DestWidth, width, DTA_DestHeight, height, DTA_Alpha, backalpha, DTA_FlipX, swapsides); }

		if (drawtic > 140)
		{
			double stripalpha = min(1.0, (drawtic - 140) / 140.0) * alpha;
			if (strips) { screen.DrawTexture(strips, false, 0, 0, DTA_DestWidth, width, DTA_DestHeight, height, DTA_Alpha, stripalpha); }

			int lw, lh;
			int sw = 800;
			int sh = 600;
			double labelscale = 1.5;

			if (label_r)
			{
				[lw, lh] = TexMan.GetSize(label_r);
				double offset = (sw / 10) / labelscale + lw;
				screen.DrawTexture(label_r, false, sw / labelscale - offset, sh / labelscale - 4 * labelscale - lh, DTA_VirtualWidthF, sw / labelscale, DTA_VirtualHeightF, sh / labelscale, DTA_Alpha, stripalpha);
				screen.DrawText(SmallFont, Font.CR_GRAY, sw / labelscale - offset + 12, sh / labelscale - 4 * labelscale  + 3 / labelscale - lh, StringTable.Localize("$PAGE") .. " " .. page + 1 .. " " .. StringTable.Localize("$OF") .. " " .. maxpages + 1, DTA_VirtualWidthF, sw / labelscale, DTA_VirtualHeightF, sh / labelscale, DTA_Alpha, stripalpha);
			}

			if (label_l)
			{
				[lw, lh] = TexMan.GetSize(label_l);
				screen.DrawTexture(label_l, false, (sw / 10) / labelscale, sh / labelscale - 4 * labelscale - lh, DTA_VirtualWidthF, sw / labelscale, DTA_VirtualHeightF, sh / labelscale, DTA_Alpha, stripalpha);
			}
		}

		if (drawtic > 70)
		{
			double framealpha = min(1.0, (drawtic - 70) / 140.0) * alpha * 0.5;
			if (frame) { screen.DrawTexture(frame, false, width / 2 - (swapsides ? 370 : 0), height / 2, DTA_CenterOffset, true, DTA_DestWidth, height * 960 / 400, DTA_DestHeight, height, DTA_Alpha, framealpha); }
		}

		if (drawtic > 175 && !nostats)
		{
			double statsalpha = min(1.0, (drawtic - 175) / 140.0) * alpha;

			int lineheight = 12;
			int line = 0;

			int starty = 320;
			int titlex = swapsides ? w - 196 - 64 : 64;
			int valuex = titlex + 196;

			String t = StringTable.Localize("$STATS_TIME");
			screen.DrawText(SmallFont, Font.CR_WHITE, titlex, starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);

			int sec = Thinker.Tics2Seconds(totals.leveltime); 
			t = String.Format("%02d:%02d:%02d", sec / 3600, (sec % 3600) / 60, sec % 60);
			screen.DrawText(SmallFont, Font.CR_GRAY, valuex - SmallFont.StringWidth(t), starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);
			line++;

			t = StringTable.Localize("$STATS_MONSTERS");
			screen.DrawText(SmallFont, Font.CR_WHITE, titlex, starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);
			t = totals.totalkills ? totals.killcount * 100 / totals.totalkills .. "%" : " - ";
			screen.DrawText(SmallFont, Font.CR_RED, valuex - SmallFont.StringWidth(t), starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);
			line++;

			t = StringTable.Localize("$STATS_SECRETS");
			screen.DrawText(SmallFont, Font.CR_WHITE, titlex, starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);
			t = totals.totalsecrets ? totals.secretcount * 100 / totals.totalsecrets .. "%" : " - ";
			screen.DrawText(SmallFont, Font.CR_YELLOW, valuex - SmallFont.StringWidth(t), starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);
			line++;

			t = StringTable.Localize("$STATS_ITEMS");
			screen.DrawText(SmallFont, Font.CR_WHITE, titlex, starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);
			t = totals.totalitems ? totals.itemcount * 100 / totals.totalitems .. "%" : " - ";
			screen.DrawText(SmallFont, Font.CR_GOLD, valuex - SmallFont.StringWidth(t), starty + line * lineheight, t, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, statsalpha);
			line++;
		}

		double textalpha = min(1.0, drawtic / 140.0) * alpha;

		int start = page * maxlines;

		int chars;

		int textx = int((w / 2) - (swapsides ? (370 * textXOffsetScale) : 0) - 20);
		int texty = 100;
		int lineoffset = 0;

		for (int l = start; l < min(start + lineoffset + maxlines, lines.Count()) || chars > texttic; l++)
		{
			int len = min(int(texttic) - chars, lines.StringAt(l).CodePointCount());

			if (l == start && lines.StringWidth(l) == 0) { lineoffset++; } // Skip printing blank lines at the beginning of a page

			// int xoffset = 0;

			String line = "";
			int nextchar = 0, i = 0;
			while (i < len)
			{
				int c;
				[c, nextchar] = lines.StringAt(l).GetNextCodePoint(nextchar);
				line = String.Format("%s%c", line, c);

				i++;
			}

			screen.DrawText(fnt, Font.CR_DARKGRAY, textx / textscale, (texty + (l - start - lineoffset) * lineheight) / textscale, line, DTA_VirtualWidthF, w / textscale, DTA_VirtualHeightF, h / textscale, DTA_Alpha, textalpha);
			chars += len;
		}
	}

	override void Ticker()
	{
		if (page != oldpage)
		{
			if (page > maxdrawn) { texttic = 0; }
			else { texttic = 4096; }
			oldpage = page;
			maxdrawn = max(maxdrawn, page);
		}
		else
		{
			drawtic++;
			texttic += 0.5;
		}

		if (finished)
		{
			alpha -= 1.0 / 70; // Fade out over two seconds
			if (alpha <= 0) { Close(); }
		}

		Super.Ticker();
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mkey == MKEY_Back)
		{
			finished = true;
			return true;
		}
		else if (mkey == MKEY_Right || mkey == MKEY_Down || mkey == MKEY_Enter)
		{
			page = min(maxpages, page + 1);
			return true;
		}
		else if (mkey == MKEY_Left || mkey == MKEY_Up)
		{
			page = max(0, page - 1);
			return true;
		}

		return false;
	}

	override bool MouseEvent(int type, int x, int y)
	{
		if (type == MOUSE_Click)
		{
			page = min(maxpages, page + 1);
			return true;
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

	LevelData GetTotals() // Pull the total stats from the map stats event handler
	{
		LevelData totals = New("LevelData");
		totals.mapname = "Stat Totals";
		totals.levelname = "Stat Totals";
		totals.levelnum = 0;
		totals.totalkills = 0;
		totals.killcount  = 0;
		totals.totalitems  = 0;
		totals.itemcount = 0;
		totals.totalsecrets = 0;
		totals.secretcount = 0;
		totals.leveltime = 0;

		MapStatsHandler stats = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));

		if (stats)
		{
			Array<LevelData> summary;

			for (int i = 0; i < stats.Levels.Size(); i++)
			{
				let m = stats.Levels[i];

				// Filter to only show results from maps named in this episode (e.g., matching "C1L").
				if (m.mapname.Mid(0, 3) ~== level.mapname.Mid(0, 3)) { summary.Push(m); }
				else { continue; }
			}

			for (int i = 0; i < summary.Size(); i++)
			{
				let l = summary[i];

				totals.totalkills += l.totalkills;
				totals.killcount += l.killcount;
				totals.totalitems += l.totalitems;
				totals.itemcount += l.itemcount;
				totals.totalsecrets += l.totalsecrets;
				totals.secretcount += l.secretcount;
				totals.leveltime += l.leveltime;
			}
		}

		return totals;
	}

	static bool Ready()
	{
		Menu current = Menu.GetCurrentMenu();

		if (current is "Finale" && Finale(current).finished) { return true; }
		else { return false; }
	}

	static ui void Setup(String str = "", bool stats = -1, bool swap = -1)
	{
		Finale current = Finale(Menu.GetCurrentMenu());
		if (!current)
		{
			Menu.SetMenu("Finale");

			current = Finale(Menu.GetCurrentMenu());
		}

		if (str.length()) { current.InitText(str); }
		if (stats > -1) { current.nostats = !stats; }
		if (swap > -1) { current.swapsides = swap; }
	}
}