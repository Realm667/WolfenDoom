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
	int h, w, cols, rows;
	Achievement selected;

	TextureID background, board;
	Font titlefont, textfont, captionfont;
	
	double msgalpha;
	bool initial;
	int ticcount;
	BrokenLines hintlines;
	double hintx, hinty, hintlineheight;

	override void Init(Menu parent)
	{
		GenericMenu.Init(parent);

		DontDim = true;
		DontBlur = true;
		menuactive = OnNoPause;
		mMouseCapture = true;

		h = 600;
		w = int(h * 4 / 3);

		alpha = 1.0;
		rows = 9;
		cols = tracker.ACH_LASTACHIEVEMENT / rows;
		if (cols < tracker.ACH_LASTACHIEVEMENT / rows) { cols++; }

		titlefont = BigFont;
		textfont = SmallFont;
		captionfont = Font.GetFont("ThreeFiv");

		background = TexMan.CheckForTexture("graphics/hud/general/convback.png", TexMan.Type_Any);
		board = TexMan.CheckForTexture("graphics/hud/hud_achievements/ach_bkg.png", TexMan.Type_Any);

		// Hint message
		String hintmessage = StringTable.Localize("ACHIEVEMENTINFO", false);
		hintlines = SmallFont.BreakLines(hintmessage, 320);
		hintx = 320;
		hintlineheight = SmallFont.GetHeight();
		double offset = hintlineheight * (hintlines.Count() - 0.5) - 10;
		hinty = 460 - offset;
		
		initial = true;

		tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
	}

	override void Drawer()
	{
		if (!tracker) { return; }

		int height = int(Screen.GetHeight());
		int width = int(Screen.GetWidth());

		if (background) { screen.DrawTexture(background, true, 0, 0, DTA_DestWidth, width, DTA_DestHeight, height, DTA_Alpha, alpha); }
		if (board) { Screen.DrawTexture(board, true, width / 2, height / 2, DTA_DestWidth, int(height * 16 / 9), DTA_DestHeight, height, DTA_CenterOffset, true); }

		for (int a = 0; a < tracker.ACH_LASTACHIEVEMENT; a++)
		{
			DrawAchievement(a, tracker.records[a], tracker.records[a] == selected);
		}
		
		if (msgalpha > 0)
		{
			for (int i = 0; i < hintlines.Count(); i++)
			{
				screen.DrawText(SmallFont, Font.CR_GRAY, hintx - hintlines.StringWidth(i) / 2, hinty + hintlineheight * i, hintlines.StringAt(i), DTA_VirtualWidth, 640, DTA_VirtualHeight, 480, DTA_Alpha, msgalpha);
			}
		}
	}

	virtual void DrawAchievement(int index, Achievement ach, bool selected = false)
	{
		int column = index / rows;
		int row = index % rows;
		int spacing = 10;

		int rowheight = 48;
		int colwidth = int((w - spacing * 2) / (cols + 1));
		int iconwidth = 40;

		double scale = max(0.01, (Screen.GetHeight() * iconwidth / h) / iconwidth);

		int yoffset = (h - rowheight * rows) / 2;

		Vector2 pos = (spacing + column * colwidth, yoffset + row * rowheight);

		Vector2 size;
		[pos, size] = Screen.VirtualToRealCoords(pos, (colwidth - spacing, rowheight - spacing), (w, h));

		ach.pos = pos - (4, 4) * scale;
		ach.size = size + (8, 8) * scale;;

		double bottom = pos.y + size.y;

		if (selected) { Screen.DrawLineFrame(0xFFDD0000, int(ach.pos.x), int(ach.pos.y), int(ach.size.x), int(ach.size.y), 2); }
		Screen.Dim(0x0, 0.75, int(ach.pos.x), int(ach.pos.y), int(ach.size.x), int(ach.size.y));

		String text = ach.title;
		BrokenString lines;
		
		int endline = text.IndexOf("\n");
		String title = text.Left(endline);
		text = text.Mid(endline + 1);

		double titlescale = 0.8;
		[title, lines] = BrokenString.BreakString(title, int(size.x / (scale * titlescale)), false, "L", titlefont);

		title = lines.StringAt(0);
		if (lines.Count() > 0)
		{
			title = title .. "...";

			if (titlefont.StringWidth(title) > size.x / (scale * titlescale))
			{
				title = title.Left(title.RightIndexOf(" ") - 1) .. "...";
			}
		}

		screen.DrawText(titlefont, ach.complete ? Font.CR_GOLD : Font.CR_DARKGRAY, int(pos.x), int(pos.y), ZScriptTools.StripColorCodes(title), DTA_Alpha, alpha, DTA_ScaleX, scale * titlescale, DTA_ScaleY, scale * titlescale);
		pos.y += int(titlefont.GetHeight() * scale * titlescale);

		TextureID icon = TexMan.CheckForTexture(ach.icon);
		if (icon.IsValid())
		{
			screen.DrawTexture(icon, true, pos.x + 2 * scale, pos.y + 3 * scale, DTA_Alpha, alpha, DTA_AlphaChannel, !ach.complete, DTA_FillColor, ach.complete ? -1 : 0xBBBBCC, DTA_ScaleX, scale, DTA_ScaleY, scale);
		}

		double textscale = 1.0;

		String temp;
		while (textscale == 1.0 || (lines.Count() + 1) * textfont.GetHeight() * scale * textscale > size.y * 0.65)
		{
			textscale *= 0.9;
			[temp, lines] = BrokenString.BreakString(text, int((size.x - iconwidth * scale) / (scale * textscale)), false, "L", textfont);
		}

		int lineheight = int(textfont.GetHeight() * scale * textscale);

		for (int l = 0; l <= lines.Count(); l++)
		{
			int clr = (ach.complete) ? Font.CR_GRAY : Font.CR_DARKGRAY;
			screen.DrawText(textfont, clr, int(pos.x + iconwidth * scale), int(pos.y + lineheight * l), ZScriptTools.StripColorCodes(lines.StringAt(l)), DTA_Alpha, alpha, DTA_ScaleX, scale * textscale, DTA_ScaleY, scale * textscale);
		}

		double captionscale = 1.0;
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
				value = String.Format("%i/%i", tracker.saves[consoleplayer], 100);
				break;
			case AchievementTracker.ACH_SPRINT:
				value = String.Format("%i/%i", tracker.exhaustion[consoleplayer], 50);
				break;
			case AchievementTracker.ACH_LIQUIDDEATH:
				if (tracker.liquiddeath[consoleplayer][0]) { value = "\cH"; }
				value = value .. "⬛\cU";
				if (tracker.liquiddeath[consoleplayer][1]) { value = value .. "\cI"; }
				value = value .. "⬛\cU";
				if (tracker.liquiddeath[consoleplayer][2]) { value = value .. "\cT"; }
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
				if (tracker.cartridges[consoleplayer][0]) { value = "\cG"; }
				value = value .. "⬛\cU";
				if (tracker.cartridges[consoleplayer][1]) { value = value .. "\cD"; }
				value = value .. "⬛\cU";
				if (tracker.cartridges[consoleplayer][2]) { value = value .. "\cY"; }
				value = value .. "⬛";
				break;
			case AchievementTracker.ACH_TROPHYHUNTER:
				if (tracker.records[AchievementTracker.ACH_KEENAWARD]) { value = "\cF"; }
				value = value .. "🅺\cU";
				if (tracker.records[AchievementTracker.ACH_CACOWARD]) { value = value .. "\cF"; }
				value = value .. "🅲\cU";
				if (tracker.records[AchievementTracker.ACH_NAZIWARD]) { value = value .. "\cF"; }
				value = value .. "🅽";
				break;
			case AchievementTracker.ACH_ADDICTED:
				int sec = tracker.playtime[consoleplayer];
				value = String.Format("%02d:%02d:%02d", sec / 3600, (sec % 3600) / 60, sec % 60);
				break;
		}

		pos.y = bottom - captionfont.GetHeight() * scale * captionscale;

		if (ach.time && ach.time > 100)
		{
			screen.DrawText(captionfont, Font.CR_GOLD, int(pos.x + iconwidth * scale), int(pos.y), SystemTime.Format("%d %b %Y, %T", ach.time), DTA_Alpha, alpha, DTA_ScaleX, scale * captionscale, DTA_ScaleY, scale * captionscale);
		}

		if (value.length()) { screen.DrawText(captionfont, Font.CR_DARKGRAY, int(pos.x + size.x - captionfont.StringWidth(value) * scale * captionscale), int(pos.y), value, DTA_Alpha, alpha, DTA_ScaleX, scale * captionscale, DTA_ScaleY, scale * captionscale); }
	}

	override bool MouseEvent(int type, int mx, int my)
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
				selected = ach;
				return true;
			}
		}

		selected = null;
		return true;
	}
	
	override void Ticker()
	{
		ticcount++;

		if (initial)
		{
			if (ticcount >= 245)
			{
				msgalpha = 0;
				ticcount = 0;
				initial = false;
			}
			else if (ticcount <= 175)
			{
				if (ticcount >= 105)
				{
					msgalpha = 0.5 + sin(((ticcount - 70) * 360 / 70 - 90) / 2);
				}
				else if (ticcount >= 35 && ticcount < 105)
				{
					msgalpha = 1.0;
				}
				else
				{
					msgalpha = 0.5 + sin((ticcount * 360 / 70 - 90) / 2);
				}
			}
		}
		
		Super.Ticker();
	}
}