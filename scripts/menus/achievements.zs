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

	TextureID background, board;
	Font titlefont, textfont, captionfont;

	override void Init(Menu parent)
	{
		GenericMenu.Init(parent);

		DontDim = true;
		DontBlur = true;
		menuactive = OnNoPause;

		h = 600;
		w = int(h * 4 / 3);

		alpha = 1.0;
		rows = 9;
		cols = tracker.ACH_LASTACHIEVEMENT / rows;
		if (cols < tracker.ACH_LASTACHIEVEMENT / rows) { cols++; }

		titlefont = BigFont;
		textfont = Font.GetFont("ThreeFiv");
		captionfont = Font.GetFont("ThreeFiv");

		background = TexMan.CheckForTexture("graphics/hud/general/convback.png", TexMan.Type_Any);
		board = TexMan.CheckForTexture("graphics/hud/hud_achievements/ach_bkg.png", TexMan.Type_Any);

		tracker = AchievementTracker(EventHandler.Find("AchievementTracker"));
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
			DrawAchievement(a, tracker.records[a]);
		}
	}

	virtual void DrawAchievement(int index, Achievement ach)
	{
		int column = index / rows;
		int row = index % rows;
		int spacing = 10;

		int rowheight = 48;
		int colwidth = int((w - spacing * 2) / (cols + 1));
		int iconwidth = 40;

		double scale = (Screen.GetHeight() * iconwidth / h) / iconwidth;

		int yoffset = (h - rowheight * rows) / 2;

		Vector2 pos = (spacing + column * colwidth, yoffset + row * rowheight);

		Vector2 size;
		[pos, size] = Screen.VirtualToRealCoords(pos, (colwidth - spacing, rowheight - spacing), (w, h));

		Screen.Dim(0x0, 0.75, int(pos.x - 4 * scale), int(pos.y - 4 * scale), int(size.x + 8 * scale), int(size.y + 8 * scale));

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

		screen.DrawText(titlefont, ach.complete ? Font.CR_GOLD : Font.CR_DARKGRAY, pos.x, pos.y, ZScriptTools.StripColorCodes(title), DTA_Alpha, alpha, DTA_ScaleX, scale * titlescale, DTA_ScaleY, scale * titlescale);
		pos.y += int(titlefont.GetHeight() * scale * titlescale);

		TextureID icon = TexMan.CheckForTexture(ach.icon);
		if (icon.IsValid())
		{
			screen.DrawTexture(icon, true, pos.x + 2 * scale, pos.y + 3 * scale, DTA_Alpha, alpha, DTA_AlphaChannel, !ach.complete, DTA_FillColor, ach.complete ? -1 : 0xBBBBCC, DTA_ScaleX, scale, DTA_ScaleY, scale);
		}

		double textscale = 1.5;
		[text, lines] = BrokenString.BreakString(text, int((size.x - iconwidth * scale) / (scale * textscale)), false, "L", textfont);
		int lineheight = int(textfont.GetHeight() * scale * textscale);

		for (int l = 0; l <= lines.Count(); l++)
		{
			int clr = (ach.complete) ? Font.CR_GRAY : Font.CR_DARKGRAY;
			screen.DrawText(textfont, clr, pos.x + iconwidth * scale, pos.y + lineheight * l, ZScriptTools.StripColorCodes(lines.StringAt(l)), DTA_Alpha, alpha, DTA_ScaleX, scale * textscale, DTA_ScaleY, scale * textscale);
		}

		if (index == 33)
		{
			int sec = tracker.records[AchievementTracker.PLAY_TIME].time;
			String playtime = String.Format("%02d:%02d:%02d", sec / 3600, (sec % 3600) / 60, sec % 60);
			screen.DrawText(textfont, Font.CR_DARKGRAY, pos.x + size.x - textfont.StringWidth(playtime) * scale * textscale, pos.y + lineheight * 3, playtime, DTA_Alpha, alpha, DTA_ScaleX, scale * textscale, DTA_ScaleY, scale * textscale);
		}
	}
}