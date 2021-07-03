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

class AchievementSummary : BoAMenu
{
	AchievementTracker tracker;

	double alpha;
	int h, w;
	int selected;

	TextureID background, board;
	Font titlefont, textfont, captionfont;
	
	int drawtop, drawbottom, drawright, drawheightscaled;
	int scrollpos, maxscroll, scrollamt;
	int spacing, cellheight, cellwidth, iconwidth;

	double scale;

	ScrollBar scroll;

	override void Init(Menu parent)
	{
		GenericMenu.Init(parent);

		DontDim = true;
		DontBlur = true;
		menuactive = OnNoPause;
		mMouseCapture = true;

		h = 480;
		w = 640;

		drawtop = int(Screen.GetHeight() * 0.125);
		drawbottom = int(Screen.GetHeight() * 0.875);
		drawright = int(Screen.GetWidth() / 2 + (Screen.GetHeight() * 4.0 / 3) / 2);
		drawheightscaled = int(h * double(drawbottom - drawtop) / Screen.GetHeight());

		alpha = 1.0;
		scale = max(0.01, Screen.GetHeight() * 1.0 / h);
		spacing = 10;
		cellheight = 48;
		cellwidth = w / 2 - 16;
		iconwidth = 32;
		maxscroll = cellheight * tracker.ACH_LASTACHIEVEMENT - drawheightscaled;
		scrollamt = 10;

		selected = 0;
		scrollpos = 0;

		titlefont = BigFont;
		textfont = SmallFont;
		captionfont = Font.GetFont("ThreeFiv");

		background = TexMan.CheckForTexture("graphics/hud/general/convback.png", TexMan.Type_Any);
		board = TexMan.CheckForTexture("graphics/hud/hud_achievements/ach_bkg.png", TexMan.Type_Any);

		tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));

		scroll = Scroll.Init(int(drawright - 12 * scale), drawtop, int(12 * scale), drawbottom - drawtop, maxscroll);
	}

	override void Drawer()
	{
		if (!tracker) { return; }

		int height = int(Screen.GetHeight());
		int width = int(Screen.GetWidth());

		if (background) { screen.DrawTexture(background, true, 0, 0, DTA_DestWidth, width, DTA_DestHeight, height, DTA_Alpha, alpha); }
		if (board) { Screen.DrawTexture(board, true, width / 2, height / 2, DTA_DestWidth, int(height * 16 / 9), DTA_DestHeight, height, DTA_CenterOffset, true); }

		if (selected == -1) { selected = int(ceil(double(scrollpos) / cellheight)); }

		int dimx = Screen.GetWidth() / 2;
		Screen.Dim(0x0, 0.75, dimx, drawtop, drawright - dimx - int(12 * scale), drawbottom - drawtop);

		for (int a = 0; a < tracker.ACH_LASTACHIEVEMENT; a++)
		{
			DrawAchievement(a, tracker.records[a], a == selected);
		}

		scroll.scrollpos = scrollpos;
		scroll.alpha = alpha;
		scroll.Draw();
	}

	virtual void DrawAchievement(int index, Achievement ach, bool isselected = false)
	{
		double titlescale = 1.0 * scale;
		double textscale = 1.0 * scale;
		double captionscale = 1.0 * scale;

		String text = StringTable.Localize(ach.title, false);
		BrokenString lines;

		Vector2 size, pos = (spacing, spacing - scrollpos + index * cellheight);
		[pos, size] = Screen.VirtualToRealCoords(pos, (cellwidth - spacing, cellheight - spacing), (w, h));

 		pos.y += drawtop - spacing / 2;

		pos.x = int(pos.x);
		pos.y = int(pos.y);

		ach.pos = pos - (4, 4) * scale;
		ach.fullsize = size;
		ach.size = size + (8, 8) * scale;

		ach.size.y = min(ach.size.y, ach.pos.y + ach.size.y - drawtop);
		ach.size.y = min(ach.size.y, drawbottom - ach.pos.y);
		ach.pos.y = max(ach.pos.y, drawtop);
		ach.pos.y = min(ach.pos.y, drawbottom);

		if (ach.size.y < cellheight && isselected)
		{
			if (pos.y < Screen.GetHeight() / 2) { selected++; }
			else { selected--; }
		}
		if (ach.pos.y + ach.size.y <= drawtop || ach.pos.y >= drawbottom) { return; }

		double bottom = pos.y + size.y;

		Screen.Dim(0x0, isselected ? 0.75 : 0.6, int(ach.pos.x), int(ach.pos.y), isselected ? int(ceil(Screen.GetWidth() / 2 - ach.pos.x)): int(ach.size.x), int(ach.size.y));

		// Split the title and content text
		// Assumes that the first line up to a line break is the title.
		int endline = text.IndexOf("\n");
		String title = text.Left(endline);
		text = text.Mid(endline + 1);

		// Draw the title string, with handling for adding ellipses on overflow
		int titlewidth = int((size.x - (iconwidth + spacing * 2) * scale) / titlescale);
		[title, lines] = BrokenString.BreakString(title, titlewidth, false, "L", titlefont);

		String shorttitle = lines.StringAt(0);
		if (lines.Count() > 1)
		{
			int last = 0x20;
			while (titlefont.StringWidth(shorttitle) > titlewidth - titlefont.StringWidth("...") || last != 0x20)
			{
				shorttitle.DeleteLastCharacter();
				last = shorttitle.GetNextCodePoint(shorttitle.CodePointCount() - 1);
			}

			shorttitle = shorttitle .. "...";
		}
		screen.DrawText(titlefont, ach.complete ? Font.CR_GOLD : Font.CR_DARKGRAY, int(pos.x + (spacing * 2 + iconwidth) * scale), int(pos.y + (size.y - titlefont.GetHeight() * titlescale) / 2), ZScriptTools.StripColorCodes(shorttitle), DTA_Alpha, alpha, DTA_ScaleX, titlescale, DTA_ScaleY, titlescale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom);

		// Get and draw icon
		TextureID icon = TexMan.CheckForTexture(ach.icon);
		if (icon.IsValid())
		{
			screen.DrawTexture(icon, true, pos.x + (spacing / 2 + iconwidth / 2) * scale, pos.y + size.y / 2, DTA_Alpha, alpha, DTA_AlphaChannel, !ach.complete, DTA_FillColor, ach.complete ? -1 : 0xBBBBCC, DTA_DestWidth, int(iconwidth * scale), DTA_DestHeight, int(iconwidth * scale), DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom, DTA_CenterOffset, true);
		}

		// Print the current status or completion timestamp
		pos.y = bottom - captionfont.GetHeight() * captionscale;

		String value = "";
		switch (index)
		{
			case AchievementTracker.ACH_GUNSLINGER:
				value = String.Format("%i/%i", tracker.pistolshots[consoleplayer], 1000);
				break;
			case AchievementTracker.ACH_SPEEDRUNNER:
				if (!level.partime) { break; }

				int cur = level.maptime / 35;
				int par = level.partime / 2;
				String curstr = String.Format("%02d:%02d", cur / 60, cur % 60);
				String parstr = String.Format("%02d:%02d", par / 60, par % 60);
				value = String.Format("%s/%s", curstr, parstr);
				break;
			case AchievementTracker.ACH_ASSASSIN:
				value = String.Format("%i/%i", tracker.knifekills[consoleplayer], 10);
				break;
			case AchievementTracker.ACH_SURRENDERS:
				value = String.Format("%i/%i", tracker.surrenders[consoleplayer], 5);
				break;
			case AchievementTracker.ACH_BOOM:
				value = String.Format("%i/%i", tracker.totalgrenades[consoleplayer], 40);
				break;
			case AchievementTracker.ACH_SPAM:
				value = String.Format("%i/%i", tracker.records[AchievementTracker.STAT_SAVES].value, 100);
				break;
			case AchievementTracker.ACH_SPRINT:
				value = String.Format("%i/%i", tracker.exhaustion[consoleplayer], 50);
				break;
			case AchievementTracker.ACH_LIQUIDDEATH:
				int deathbits = tracker.records[AchievementTracker.STAT_LIQUIDDEATH].value;
				if (deathbits & 1) { value = "\cH"; }
				value = value .. "⬛\cU";
				if (deathbits & 2) { value = value .. "\cI"; }
				value = value .. "⬛\cU";
				if (deathbits & 4) { value = value .. "\cT"; }
				value = value .. "⬛";
				break;
			case AchievementTracker.ACH_ZOMBIES:
				value = String.Format("%i/%i", tracker.zombies[consoleplayer], 500);
				break;
			case AchievementTracker.ACH_FULLARSENAL:
				int val = 0;
				for (int w = 0; w < 16; w++)
				{
					if (tracker.weapons[consoleplayer][w]) { val++; }
				}
				value = String.Format("%i/%i", val, 16);
				break;
			case AchievementTracker.ACH_COMBATMEDIC:
				value = String.Format("%i/%i", tracker.fieldkits[consoleplayer], 20);
				break;
			case AchievementTracker.ACH_TREASUREHUNTER:
				value = String.Format("%i/%i", tracker.chests[consoleplayer], 20);
				break;
			case AchievementTracker.ACH_STAYDEAD:
				value = String.Format("%i/%i", tracker.deadwounded[consoleplayer], 50);
				break;
			case AchievementTracker.ACH_GIBEMALL:
				value = String.Format("%i/%i", tracker.gibs[consoleplayer], 100);
				break;
			case AchievementTracker.ACH_GOLDDIGGER:
				value = String.Format("%i/%i", tracker.coins[consoleplayer], 1000);
				break;
			case AchievementTracker.ACH_NEAT:
				int neatbits = tracker.records[AchievementTracker.STAT_CARTRIDGES].value;

				if (neatbits & 1) { value = "\cG"; }
				value = value .. "⬛\cU";
				if (neatbits & 2) { value = value .. "\cD"; }
				value = value .. "⬛\cU";
				if (neatbits & 4) { value = value .. "\cY"; }
				value = value .. "⬛";
				break;
			case AchievementTracker.ACH_TROPHYHUNTER:
				int trophybits = tracker.records[AchievementTracker.STAT_AWARDS].value;

				if (trophybits & 2) { value = "\cF"; }
				value = value .. "🅲\cU";
				if (trophybits & 4) { value = value .. "\cF"; }
				value = value .. "🅽\cU";
				if (trophybits & 1) { value = value .. "\cF"; }
				value = value .. "🅺";
				break;
			case AchievementTracker.ACH_ADDICTED:
				int sec = tracker.records[AchievementTracker.STAT_PLAYTIME].value;
				value = String.Format("%02d:%02d:%02d", sec / 3600, (sec % 3600) / 60, sec % 60);
				break;
			case AchievementTracker.ACH_SHOVEL:
				value = String.Format("%i/%i", tracker.shovelkills[consoleplayer], 100);
				break;
		}

		String timevalue;
		int charsize = captionfont.StringWidth(" ");
		int valuewidth, timewidth;

		if (ach.value && ach.value > 1 << 16)
		{
			timevalue = SystemTime.Format("%d %b %Y, %T", ach.value);
			timewidth = timevalue.length() * charsize;
			screen.DrawText(captionfont, Font.CR_GOLD, int(pos.x + size.x - timewidth * captionscale), int(pos.y), timevalue, DTA_Alpha, alpha, DTA_ScaleX, captionscale, DTA_ScaleY, captionscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom, DTA_Monospace, 2, DTA_Spacing, charsize);
		}
		else
		{
			if (value.length())
			{
				if (
					index == AchievementTracker.ACH_LIQUIDDEATH ||
					index == AchievementTracker.ACH_NEAT ||
					index == AchievementTracker.ACH_TROPHYHUNTER
				)
				{
					valuewidth = captionfont.StringWidth(value);
					screen.DrawText(captionfont, Font.CR_DARKGRAY, int(pos.x + size.x - valuewidth * captionscale), int(pos.y), value, DTA_Alpha, alpha, DTA_ScaleX, captionscale, DTA_ScaleY, captionscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom);	
				}
				else
				{
					valuewidth = value.length() * charsize;
					screen.DrawText(captionfont, Font.CR_DARKGRAY, int(pos.x + size.x - valuewidth * captionscale), int(pos.y), value, DTA_Alpha, alpha, DTA_ScaleX, captionscale, DTA_ScaleY, captionscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom, DTA_Monospace, 2, DTA_Spacing, charsize);
				}
			}
		}

		// If this isn't the active selection, stop here
		if (!isselected) { return; }

		pos.x = Screen.GetWidth() / 2 + spacing * scale;
		pos.y = drawtop + spacing * scale;

		int lineheight;

		[title, lines] = BrokenString.BreakString(title, int((drawright - Screen.GetWidth() / 2 - spacing * 2 * scale) / textscale), false, "L", textfont);
		lineheight = int(titlefont.GetHeight() * textscale);

		for (int l = 0; l < lines.Count(); l++)
		{
			screen.DrawText(titlefont, Font.CR_GOLD, int(pos.x), int(pos.y), ZScriptTools.StripColorCodes(lines.StringAt(l)), DTA_Alpha, alpha, DTA_ScaleX, titlescale, DTA_ScaleY, titlescale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom);
			pos.y += lineheight;
		}

		pos.y += spacing * scale;

		int textwidth = int((drawright - Screen.GetWidth() / 2 - spacing * 3 * scale) / textscale);
		[text, lines] = BrokenString.BreakString(text, textwidth, false, "L", textfont);
		lineheight = int(textfont.GetHeight() * textscale);

		for (int l = 0; l < lines.Count(); l++)
		{
			screen.DrawText(textfont, Font.CR_GRAY, int(pos.x), int(pos.y), ZScriptTools.StripColorCodes(lines.StringAt(l)), DTA_Alpha, alpha, DTA_ScaleX, textscale, DTA_ScaleY, textscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom);
			pos.y += lineheight;
		}

		pos.y += spacing * scale;

		if (value.length())
		{
			bool complete;
			Vector2 drawpos = (drawright - spacing * scale, pos.y);
			Vector2 size;

			switch(index)
			{
				case AchievementTracker.ACH_TROPHYHUNTER:
					TextureID caco = TexMan.CheckForTexture("CACWA0");
					TextureID nazi = TexMan.CheckForTexture("NZWRA0");
					TextureID keen = TexMan.CheckForTexture("CKWRA0");

					drawpos.y += 64;

					complete = tracker.records[AchievementTracker.STAT_AWARDS].value & 2;
					size = TexMan.GetScaledSize(caco).Unit();
					size *= (24 / size.x);
					screen.DrawTexture(caco, true, drawpos.x - 36 * 3, drawpos.y, DTA_Alpha, alpha, DTA_AlphaChannel, !complete, DTA_FillColor, complete ? -1 : 0xBBBBCC, DTA_DestWidth, int(size.x), DTA_DestHeight, int(size.y), DTA_CenterBottomOffset, true);

					complete = tracker.records[AchievementTracker.STAT_AWARDS].value & 4;
					size = TexMan.GetScaledSize(nazi).Unit();
					size *= (24 / size.x);
					screen.DrawTexture(nazi, true, drawpos.x - 36 * 2, drawpos.y, DTA_Alpha, alpha, DTA_AlphaChannel, !complete, DTA_FillColor, complete ? -1 : 0xBBBBCC, DTA_DestWidth, int(size.x), DTA_DestHeight, int(size.y), DTA_CenterBottomOffset, true);

					complete = tracker.records[AchievementTracker.STAT_AWARDS].value & 1;
					size = TexMan.GetScaledSize(keen).Unit();
					size *= (24 / size.x);
					screen.DrawTexture(keen, true, drawpos.x - 36, drawpos.y, DTA_Alpha, alpha, DTA_AlphaChannel, !complete, DTA_FillColor, complete ? -1 : 0xBBBBCC, DTA_DestWidth, int(size.x), DTA_DestHeight, int(size.y), DTA_CenterBottomOffset, true);
					break;
				case AchievementTracker.ACH_NEAT:
					TextureID cart51 = TexMan.CheckForTexture("SNSCA0");
					TextureID cart52 = TexMan.CheckForTexture("SNSCC0");
					TextureID cart53 = TexMan.CheckForTexture("SNSCE0");

					size = TexMan.GetScaledSize(cart51);
					drawpos.y += size.y;
					
					complete = tracker.records[AchievementTracker.STAT_CARTRIDGES].value & 1;
					screen.DrawTexture(cart51, true,drawpos.x - 36 * 3, drawpos.y, DTA_Alpha, alpha, DTA_AlphaChannel, !complete, DTA_FillColor, complete ? -1 : 0xBBBBCC, DTA_DestWidth, int(size.x), DTA_DestHeight, int(size.y), DTA_CenterBottomOffset, true);

					complete = tracker.records[AchievementTracker.STAT_CARTRIDGES].value & 2;
					screen.DrawTexture(cart52, true, drawpos.x - 36 * 2, drawpos.y, DTA_Alpha, alpha, DTA_AlphaChannel, !complete, DTA_FillColor, complete ? -1 : 0xBBBBCC, DTA_DestWidth, int(size.x), DTA_DestHeight, int(size.y), DTA_CenterBottomOffset, true);

					complete = tracker.records[AchievementTracker.STAT_CARTRIDGES].value & 4;
					screen.DrawTexture(cart53, true, drawpos.x - 36, drawpos.y, DTA_Alpha, alpha, DTA_AlphaChannel, !complete, DTA_FillColor, complete ? -1 : 0xBBBBCC, DTA_DestWidth, int(size.x), DTA_DestHeight, int(size.y), DTA_CenterBottomOffset, true);
					break;
				case AchievementTracker.ACH_LIQUIDDEATH:
					valuewidth = captionfont.StringWidth(value);
					screen.DrawText(captionfont, Font.CR_DARKGRAY, int(drawright - valuewidth * captionscale - spacing * 2 * scale), int(pos.y), value, DTA_Alpha, alpha, DTA_ScaleX, captionscale, DTA_ScaleY, captionscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom);
					break;
				default:
					valuewidth = value.length() * charsize;
					screen.DrawText(captionfont, Font.CR_DARKGRAY, int(drawright - valuewidth * captionscale - spacing * 2 * scale), int(pos.y), value, DTA_Alpha, alpha, DTA_ScaleX, captionscale, DTA_ScaleY, captionscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom, DTA_Monospace, 2, DTA_Spacing, charsize);
					break;
			}
		}
		screen.DrawText(captionfont, Font.CR_GOLD, int(pos.x), int(pos.y), timevalue, DTA_Alpha, alpha, DTA_ScaleX, captionscale, DTA_ScaleY, captionscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom, DTA_Monospace, 2, DTA_Spacing, charsize);

		// Cheat warning message
		[text, lines] = BrokenString.BreakString(StringTable.Localize("ACHIEVEMENTINFO", false), textwidth, false, "L", textfont);

		pos.y = drawbottom - (lines.Count() + 1) * lineheight;

		for (int l = 0; l < lines.Count(); l++)
		{
			screen.DrawText(textfont, Font.CR_GRAY, int(pos.x + textwidth * scale / 2 - lines.StringWidth(l) * scale / 2), int(pos.y), lines.StringAt(l), DTA_Alpha, alpha, DTA_ScaleX, textscale, DTA_ScaleY, textscale, DTA_ClipTop, drawtop, DTA_ClipBottom, drawbottom);
			pos.y += lineheight;
		}
	}

	override bool MouseEvent(int type, int mx, int my)
	{
		if (type == MOUSE_CLICK)
		{
			for (int a = 0; a < tracker.ACH_LASTACHIEVEMENT; a++)
			{
				let ach = tracker.records[a];
				if (!ach) { continue; }

				if (
					mx >= ach.pos.x &&
					mx <= ach.pos.x + ach.size.x &&
					my >= ach.pos.y &&
					my <= ach.pos.y + ach.size.y
				)
				{
					selected = a;

					if (ach.size.y < ach.fullsize.y)
					{
						if (ach.pos.y < Screen.GetHeight() / 2) { scrollpos -= int(ach.fullsize.y - ach.size.y); }
						else { scrollpos += int(ach.fullsize.y - ach.size.y); }
					}
					return true;
				}
			}

			int scrollclick = scroll.CheckClick(mx, my);

			switch (scrollclick)
			{
				case ScrollBar.SCROLL_SLIDER:
					scroll.capture = true;
					break;
				case ScrollBar.SCROLL_UP:
					scrollpos = max(0, scrollpos - cellheight);
					break;
				case ScrollBar.SCROLL_DOWN:
					scrollpos = min(maxscroll, scrollpos + cellheight);
					break;
				case ScrollBar.SCROLL_PGUP:
					scrollpos = max(0, scrollpos - cellheight * 5);
					break;
				case ScrollBar.SCROLL_PGDOWN:
					scrollpos = min(maxscroll, scrollpos + cellheight * 5);
					break;
				default:
					break;
			}
		}
		else if (type == MOUSE_MOVE && scroll.capture)
		{
			int ypos = clamp(my - (scroll.y + scroll.elementsize), 0, scroll.h - (scroll.elementsize * 2));
			scrollpos = maxscroll * ypos / (scroll.h - (scroll.elementsize * 2));
		}
		else
		{
			if (scroll.capture) { scroll.capture = false; }
		}

		return true;
	}

	override bool OnUIEvent(UIEvent ev)
	{
		if (ev.type == UIEvent.Type_WheelUp)
		{
			scrollpos = max(0, scrollpos - scrollamt);
			return true;
		}
		else if (ev.type == UIEvent.Type_WheelDown)
		{
			scrollpos = min(maxscroll, scrollpos + scrollamt);
			return true;
		}
		return Super.OnUIEvent(ev);
	}

	override bool MenuEvent (int mkey, bool fromcontroller)
	{
		int startedAt = selected;
		int lastselection = AchievementTracker.ACH_LASTACHIEVEMENT - 1;
		int pageamt = drawheightscaled / cellheight;

		switch (mkey)
		{
			case MKEY_Up:
				--selected;
				if (selected < 0)
				{
					selected = lastselection;
					scrollpos = maxscroll;
				}
				else if (selected == 0)
				{
					scrollpos = 0;
				}
				else if (selected * cellheight < scrollpos)
				{
					scrollpos -= cellheight;
				}
				break;
			case MKEY_Down:
				++selected;
				if (selected > lastselection)
				{
					selected = 0;
					scrollpos = 0;
				}
				else if (selected == lastselection)
				{
					scrollpos = maxscroll;
				}
				else if ((selected + 1) * cellheight > scrollpos + drawheightscaled)
				{
					scrollpos += cellheight;
				}
				break;
			case MKEY_PageUp:
				selected = max(0, selected - pageamt);
				scrollpos = max(0, selected * cellheight);
				break;
			case MKEY_PageDown:
				selected = min(lastselection, selected + pageamt);
				scrollpos = min(maxscroll, selected * cellheight);
				break;
			default:
				return Super.MenuEvent(mkey, fromcontroller);
		}

		if (selected != startedAt)
		{
			MenuSound ("menu/cursor");
		}

		return true;
	}
}

class ScrollBar ui
{
	int x, y, w, h;
	int scrollpos, maxscroll;
	int elementsize;
	int blocktop, blockbottom;
	bool capture;

	double alpha;

	TextureID up, down, scroll_t, scroll_m, scroll_b, scroll_s;

	ScrollBar Init(int x, int y, int w, int h, int maxscroll)
	{
		ScrollBar s = New("ScrollBar");

		if (s)
		{
			s.up = TexMan.CheckForTexture("graphics/conversation/arrow_up.png", TexMan.Type_Any);
			s.down = TexMan.CheckForTexture("graphics/conversation/arrow_dn.png", TexMan.Type_Any);
			s.scroll_t = TexMan.CheckForTexture("graphics/conversation/scroll_t.png", TexMan.Type_Any);
			s.scroll_m = TexMan.CheckForTexture("graphics/conversation/scroll_m.png", TexMan.Type_Any);
			s.scroll_b = TexMan.CheckForTexture("graphics/conversation/scroll_b.png", TexMan.Type_Any);
			s.scroll_s = TexMan.CheckForTexture("graphics/conversation/scroll_s.png", TexMan.Type_Any);
	
			s.x = x;
			s.y = y;
			s.w = w;
			s.h = h;
			s.maxscroll = maxscroll;
			s.elementsize = s.w;
		}

		return s;
	}

	void Draw()
	{
		double scrollblocksize = double(h - elementsize * 2.75) / maxscroll;
		int scrollbarsize = int(scrollblocksize / 16);

		Screen.Dim(0x0, 0.5, x, y, w, h);

		Color clr = g_activecolor;
		Color disabled = g_inactivecolor;

		if (scrollBarSize < 1)
		{
				blocktop = y + elementsize + int(scrollblocksize * scrollpos);
				blockbottom = blocktop + elementsize;
				screen.DrawTexture(scroll_s, true, x, blocktop, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, clr, DTA_DestHeight, elementsize, DTA_DestWidth, elementsize);
		}
		else
		{
			blocktop = y + elementsize + min(int(scrollblocksize * scrollpos), h - elementsize * (2 + scrollbarsize));
			blockbottom = blocktop + elementsize * scrollbarsize;
			for (int b = 0; b < scrollbarsize; b++)
			{
				if (b == 0)
				{
					screen.DrawTexture(scroll_t, true, x, blocktop, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, clr, DTA_DestHeight, elementsize, DTA_DestWidth, elementsize);
				}
				else if (b == scrollbarsize - 1)
				{
					screen.DrawTexture(scroll_b, true, x, blocktop + b * elementsize, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, clr, DTA_DestHeight, elementsize, DTA_DestWidth, elementsize);
				}
				else if (scrollbarsize > 2)
				{
					screen.DrawTexture(scroll_m, true, x, blocktop + b * elementsize, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, clr, DTA_DestHeight, elementsize, DTA_DestWidth, elementsize);
				}
			}
		}

		screen.DrawTexture(up, true, x, y, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, scrollpos == 0 ? disabled : clr, DTA_DestHeight, elementsize, DTA_DestWidth, elementsize);
		screen.DrawTexture(down, true, x, y + h - elementsize, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, scrollpos == maxscroll ? disabled : clr, DTA_DestHeight, elementsize, DTA_DestWidth, elementsize);
	}

	enum Clicks
	{
		NONE,
		SCROLL_UP,
		SCROLL_DOWN,
		SCROLL_SLIDER,
		SCROLL_PGUP,
		SCROLL_PGDOWN,
	};

	int CheckClick(int mousex, int mousey)
	{
		if (mousex < x || mousex > x + elementsize) { return NONE; }
		if (mousey < y && mousey > y + h) { return NONE; }

		if (mousey <= y + elementsize) { return SCROLL_UP; }
		if (mousey >= y + h - elementsize) { return SCROLL_DOWN; }
		if (mousey >= blocktop && mousey <= blockbottom) { return SCROLL_SLIDER; }
		if (mousey < blocktop) { return SCROLL_PGUP; }
		if (mousey > blockbottom) { return SCROLL_PGDOWN; }

		return NONE;
	}
}