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

class LevelData
{
	int totalkills, killcount;
	int totalitems, itemcount;
	int totalsecrets, secretcount;
	int leveltime;
	int levelnum;
	String mapname, levelname;
}

class PersistentMapStatsHandler : EventHandler
{
	Array<LevelData> Levels;
	Array<String> SpecialItemPickups;
}

class MapStatsHandler : StaticEventHandler
{
	Array<LevelData> Levels;
	Array<String> SpecialItemPickups;
	bool draw;
	bool active[MAXPLAYERS];
	const width = 640;
	const height = 480;
	Font TitleFont, HeadingFont, StatFont, PhaseFont;
	double titlescale, headingscale, fontscale, phasescale;
	int lineheight;
	int chapter;
	PersistentMapStatsHandler persistent;

	int FindLevel(String n) // Helper function to find a thing in a child class (Used in place of Levels.Find(mo) since the name is nested in a LevelData object
	{
		for (int i = 0; i < Levels.Size(); i++)
		{
			if (Levels[i] && Levels[i].mapname == n) { return i; }
		}
		return Levels.Size();
	}

	ui int FindLevelNumber(int n) // Helper function to find a thing in a child class (Used in place of Levels.Find(mo) since the level number is nested in a LevelData object
	{
		for (int i = 0; i < Levels.Size(); i++)
		{
			if (Levels[i] && Levels[i].levelnum == n) { return i; }
		}
		return Levels.Size();
	}

	static void SaveLevelData()
	{
		MapStatsHandler this = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));
		if (!this || !level) { return; }

		int i = this.FindLevel(level.mapname);

		LevelData l;

		if (i < this.Levels.Size()) // If it's already there, just update the completion data
		{
			l = this.Levels[i];
		}
		else
		{
			l = New("LevelData");

			if (!l) { if (developer) { console.printf("Failed to save level statistics data!"); } return; }

			l.mapname = level.mapname;
			l.levelname = level.levelname;
			l.levelnum = level.levelnum;

			this.Levels.Push(l);
		}

		l.totalkills = level.total_monsters;
		l.killcount = level.killed_monsters;
		l.totalitems = level.total_items;
		l.itemcount = level.found_items;
		l.totalsecrets = level.total_secrets;
		l.secretcount = level.found_secrets;
		l.leveltime = level.maptime;

		// Save the copy of the data that will persist across saves...
		if (!this.persistent) { this.persistent = PersistentMapStatsHandler(EventHandler.Find("PersistentMapStatsHandler")); }
		if (this.persistent)
		{
			this.persistent.Levels.Copy(this.Levels);
			this.persistent.SpecialItemPickups.Copy(this.SpecialItemPickups);
		}
	}

	override void OnRegister()
	{
		TitleFont = SmallFont;
		HeadingFont = SmallFont;
		StatFont = ZScriptTools.GetViableFont("Chalkboard|Typewriter", "0123456789%/ :");
		PhaseFont = ZScriptTools.GetViableFont("Chalkboard|Typewriter", Stringtable.Localize("$STATS_CHAPTER"));

		titlescale = GetScale(TitleFont) * 1.2;
		headingscale = GetScale(HeadingFont);
		fontscale = GetScale(StatFont);
		phasescale = GetScale(PhaseFont);

		lineheight = int(StatFont.GetHeight() * fontscale) + 1;
	}

	override void WorldTick()
	{
		if (active[consoleplayer])
		{
			PlayerInfo cp = players[consoleplayer];

			// Turn the stats off if you move...
			if (
				cp && 
				(
					cp.cmd.forwardmove || 
					cp.cmd.sidemove || 
					(
						cp.cmd.buttons & BT_CROUCH ||
						cp.cmd.buttons & BT_JUMP 
					)
				)
			)
			{
				active[consoleplayer] = false;
			}

			// Make sure the phase font can print the "Phase" header text; if it can't, that's a good indicator that 
			// the font is missing necessary characters... Checks each font in turn.  This check has to be done here
			// so that the font is checked whenever the player changes their selected language after initial startup
			PhaseFont = ZScriptTools.GetViableFont("Chalkboard|Typewriter", Stringtable.Localize("$STATS_CHAPTER"));
			phasescale = GetScale(PhaseFont);

			StatFont = ZScriptTools.GetViableFont("Chalkboard|Typewriter", "0123456789%/ :");
			fontscale = GetScale(StatFont);
			lineheight = int(StatFont.GetHeight() * fontscale) + 1;
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) // If loading a save, check for saved stats and copy them over if found
		{
			if (!persistent) { persistent = PersistentMapStatsHandler(EventHandler.Find("PersistentMapStatsHandler")); }

			if (persistent)
			{
				Levels.Copy(persistent.Levels);
				SpecialItemPickups.Copy(persistent.SpecialItemPickups);

				for (int i = 0; i < persistent.Levels.Size(); i++)
				{
					let m = persistent.Levels[i];

					// Filter to only show results from maps named in the CxMy format.
					String mapname = m.mapname;
					mapname.ToUpper();

					if (mapname.Mid(0, 1) != "C" || mapname.Mid(2, 1) != "M") { continue; }

					if (persistent.Levels[i])
					{
						chapter = Levels[i].mapname.CharCodeAt(1) - 48;
						break;
					}
				}
			}
		}

		active[consoleplayer] = false;

		SaveLevelData();
	}

	override void WorldUnloaded(WorldEvent e)
	{
		SaveLevelData();
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (active[consoleplayer])
		{
			Array<LevelData> summary;

			int screenwidth = Screen.GetWidth();
			int screenheight = Screen.GetHeight();

			// Draw background images
			TextureID bkg = TexMan.CheckForTexture("CONVBACK", TexMan.Type_Any);
			if (bkg) { Screen.DrawTexture(bkg, false, screenwidth / 2, screenheight / 2, DTA_DestWidth, screenwidth, DTA_DestHeight, screenheight, DTA_CenterOffset, true); }

			TextureID board = TexMan.CheckForTexture("board_hd", TexMan.Type_Any);
			if (board) { Screen.DrawTexture(board, false, screenwidth / 2, screenheight / 2, DTA_DestWidth, int(screenheight * 16 / 9), DTA_DestHeight, screenheight, DTA_CenterOffset, true); }

			for (int i = 0; i < persistent.Levels.Size(); i++)
			{
				let m = persistent.Levels[i];

				// Filter to only show results from maps named in the CxMy format.
				String mapname = m.mapname;
				mapname.ToUpper();

				if (mapname.Mid(0, 1) != "C" || mapname.Mid(2, 1) != "M") { continue; }

				int mapnum = mapname.CharCodeAt(3) - 48;
				int chapnum = mapname.CharCodeAt(1) - 48;

				if (chapnum != chapter) { continue; }

				int i = summary.Size();
				for (int j = 0; j < i; j++)
				{
					if (summary[j] && summary[j].levelnum == mapnum) { i = j; }
				}

				LevelData c;

				if (i < summary.Size())
				{
					c = summary[i];
				}
				else
				{
					c = New("LevelData");
					summary.Push(c);
				}

				// Add the values for the pieces of multi-part maps together
				c.mapname = mapname.Mid(0, 4); // Only use first 4 letters of map name
				c.levelname = m.levelname;
				c.levelnum = mapnum;
				c.totalkills += m.totalkills;
				c.killcount += m.killcount;
				c.totalitems += m.totalitems;
				c.itemcount += m.itemcount;
				c.totalsecrets += m.totalsecrets;
				c.secretcount += m.secretcount;
				c.leveltime += m.leveltime;
			}

			LevelData totals = New("LevelData"); // This has to be initialized, or bad things happen!
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
			
			// Draw 'Phase X' string or the 'No Missions Completed' string, as applicable
			if (summary.Size()) { DrawChapter(chapter, width / 2, height / 5, center); }
			else { DrawTextScaled(PhaseFont, Font.CR_WHITE, width / 2, height / 2 - height / 16, Stringtable.Localize("$STATS_NONE"), phasescale * 1.5, center); }
	
			for (int i = 0; i < summary.Size(); i++)
			{
				let l = summary[i];

				String imageprefix = String.Format("%s_", l.mapname.Mid(0, 4));

				totals.totalkills += l.totalkills;
				totals.killcount += l.killcount;
				totals.totalitems += l.totalitems;
				totals.itemcount += l.itemcount;
				totals.totalsecrets += l.totalsecrets;
				totals.secretcount += l.secretcount;
				totals.leveltime += l.leveltime;

				DrawSummary(imageprefix, l, 112, 116);
			}

			DrawTotals(totals, -112, -108);
			DrawItems(112, -68);
		}
	}

	double GetScale(font fnt)
	{
		if (fnt == SmallFont) { return 1.0; }

		double scale = double(SmallFont.GetHeight()) / fnt.GetHeight();

		// Use the total time clock width as a "standard" width for scaling
		double w = fnt.StringWidth("00:00:00");
		if (w > 52.0) { scale = 52.0 / w; }

		return scale;
	}

	enum align
	{
		left,
		right,
		center
	}

	ui void DrawItems(int xoffset, int yoffset)
	{
		if (xoffset < 0) { xoffset = width + xoffset; }
		if (yoffset < 0) { yoffset = height + yoffset; }

		TextureID img;

		// Handle drawing clue item icons
		for (int j = 0; j < min(SpecialItemPickups.Size(), chapter < 3 ? 5 : 6); j++) // Draw up to 5 (or 6 for C3) icons
		{
			img = TexMan.CheckForTexture(SpecialItemPickups[j], TexMan.Type_Any);

			if (img)
			{
				Vector2 size;
				size = TexMan.GetScaledSize(img);

				double ratio = 32.0 / size.x;
				size *= ratio;

				Screen.DrawTexture(img, false, xoffset + 40 * j, yoffset, DTA_DestWidthF, size.x, DTA_DestHeightF, size.y, DTA_VirtualWidth, width, DTA_VirtualHeight, height);
			}
		}
	}

	ui void DrawChapter(int chapter, int xoffset, int yoffset, int alignment = left)
	{
		if (xoffset < 0) { xoffset = width + xoffset; }
		if (yoffset < 0) { yoffset = height + yoffset; }

		String s = ZScriptTools.ToRomanNumerals(chapter);

		s = Stringtable.Localize("$STATS_CHAPTER") .. " " .. s;

		// Print chapter number
		DrawTextScaled(PhaseFont, Font.CR_WHITE, xoffset, yoffset, s, phasescale * 1.5, alignment);
	}

	ui void DrawTotals(LevelData totals, int xoffset, int yoffset)
	{
		if (xoffset < 0) { xoffset = width + xoffset; }
		if (yoffset < 0) { yoffset = height + yoffset; }

		yoffset = DrawData(totals, xoffset - 72, yoffset, true);

		String timetitle = Stringtable.Localize("$STATS_TIME");

		String s;

		// Print total time
		DrawTextScaled(HeadingFont, Font.CR_DARKGRAY, xoffset - 72, yoffset, timetitle, headingscale, right);
		let seconds = Thinker.Tics2Seconds(totals.leveltime);
		s = String.Format("%02i:%02i:%02i", seconds / 3600, (seconds % 3600) / 60, seconds % 60);
		DrawTextScaled(StatFont, Font.CR_WHITE, xoffset + 50, yoffset, s, fontscale, right);
	}

	static const int drawpositions[] =
	{
		15, 28, -12,
		65, 38, 5,
		17, 30, 10,
		60, 20, -7,
		35, 21, -10,
		40, 33, 8,
		15, 26, 30,
		37, 29, -7,
		22, 32, -9,
		56, 34, 4,
		35, 21, -10,
		60, 20, -7,
		17, 30, 10,
		65, 38, 5
	};

	ui int DrawDataLine(String title, int n, int d, int x, int y, bool isTotals)
	{
		if (d > 0)
		{
			String amt, total, percentage;

			DrawTextScaled(HeadingFont, Font.CR_DARKGRAY, x, y, title, headingscale, isTotals ? right : left);

			if (isTotals) { x -= 52; }

			amt = PadString(String.Format("%i", n), 3);
			total = String.Format("%i", d);
			percentage = String.Format("%i%%", n * 100 / d);

			DrawTextScaled(StatFont, Font.CR_WHITE, x + 90, y, amt, fontscale, right);
			DrawTextScaled(StatFont, Font.CR_WHITE, x + 97, y, "/", fontscale, center);
			DrawTextScaled(StatFont, Font.CR_WHITE, x + 104, y, total);
			DrawTextScaled(StatFont, Font.CR_WHITE, x + (isTotals ? 175 : 160), y, percentage, fontscale, right);

			return y += lineheight;
		}

		return y += lineheight / 2;
	}

	ui int DrawData(LevelData l, int x, int y, bool isTotals = false)
	{
		String prefix = (isTotals ? "STATS" : "AM");

		String treasuretitle = Stringtable.Localize("$" .. prefix .. "_ITEMS");
		String killstitle = Stringtable.Localize("$" .. prefix .. "_MONSTERS");
		String secretstitle = Stringtable.Localize("$" .. prefix .. "_SECRETS");

		y = DrawDataLine(treasuretitle, l.itemcount, l.totalitems, x, y, isTotals);
		y = DrawDataLine(killstitle, l.killcount, l.totalkills, x, y, isTotals);
		y = DrawDataLine(secretstitle, l.secretcount, l.totalsecrets, x, y, isTotals);

		return y;
	}

	ui void DrawSummary(String imageprefix, LevelData l, int xoffset, int yoffset)
	{
		int index = l.levelnum ? l.levelnum : 7;

		int x, y;

		xoffset = min(xoffset, width / 2 - 256 - 16);
		if (yoffset < 0) { yoffset = height + yoffset; }

		if (index <= 3) // 1-3
		{
			x = xoffset;
			y = yoffset + 64 * (index - 1);
		}
		else if (index <= 6) // 4-6
		{
			x = width - xoffset - 256;
			y = yoffset + 64 * (index - 4);
		}
		else // Secret map
		{
			x = width / 2 - 128;
			y = yoffset + 192;
		}

		// Dim a frame around the level's info draw area
		DimScaled(0x000000, 0.25, x - 2, y - 2, 262, 62);
		DimScaled(0x000000, 0.25, x - 1, y - 1, 261, lineheight);

		// Print level title
		DrawTextScaled(TitleFont, Font.CR_RED, x, y, l.levelname, titlescale);

		// Print level time in hh:mm:ss format
		let seconds = Thinker.Tics2Seconds(l.leveltime);
		String t = String.Format("%02i:%02i:%02i", seconds / 3600, (seconds % 3600) / 60, seconds % 60);
		DrawTextScaled(StatFont, Font.CR_WHITE, x + 256 - StatFont.StringWidth(t) * fontscale, y, t);

		y += 2;

		// Draw level images
		DimScaled(0xAA0000, 0.75, x, y + lineheight, 80, 40); // Red frame

		TextureID img = TexMan.CheckForTexture(imageprefix .. 2, TexMan.Type_Any);
		if (img) { Screen.DrawTexture(img, false, x + 2, y + lineheight + 2, DTA_DestWidth, 76, DTA_DestHeight, 36, DTA_VirtualWidth, width, DTA_VirtualHeight, height); }

		for (int i = 3; i < 5; i++)
		{
			int imagex = x + 2;
			int imagey = y + lineheight + 2;
			double angle = 0.0;

			int j = (i == 3) ? (index - 1) * 2 * 3 : (index - 1) * 2 * 3 + 3;

			imagex += drawpositions[j];
			imagey += drawpositions[j + 1];
			angle += drawpositions[j + 2];

			TextureID img = TexMan.CheckForTexture(imageprefix .. i, TexMan.Type_Any);
			if (img) { DrawTransformedTexture(img, 1.0, imagex, imagey, angle, 0.06 + (imagex % 10 < 5 ? 0.01 : 0)); }
		}

		y += lineheight;

		y = DrawData(l, x + 90, y);
	}

	ui void DimScaled(Color clr = 0x000000, double alpha = 0.5, int x = 0, int y = 0, int w = width, int h = height)
	{
		Vector2 pos, size;
		[pos, size] = Screen.VirtualToRealCoords((x, y), (w, h), (width, height));

		Screen.Dim(clr, alpha, int(pos.x), int(pos.y), int(size.x), int(size.y));
	}

	ui String PadString(String input, int digits)
	{
		While (input.Length() < digits)
		{	
			input = " " .. input;
		}

		return input;
	}

	ui void DrawTextScaled(Font fnt, int normalcolor, double x, double y, String text, double scale = 0, int alignment = left)
	{
		if (!scale) { scale = fontscale; }

		if (alignment == center) { x -= fnt.StringWidth(text) * scale / 2; }
		else if (alignment == right) { x -= fnt.StringWidth(text) * scale; }

		Screen.DrawText(fnt, normalcolor, int(x / scale), int(y / scale), text, DTA_VirtualWidth, int(width / scale), DTA_VirtualHeight, int(height / scale));
	}

	ui void DrawTransformedTexture(TextureID tex, double alpha = 1.0, int x = width / 2, int y = height / 2, double ang = 0, double scale = 1.0)
	{
		double shapescale = double(Screen.GetHeight()) / height;

		Vector2 pos, texsize, size;
		texsize = TexMan.GetScaledSize(tex);
		[pos, size] = Screen.VirtualToRealCoords((x, y), (texsize.x * scale, texsize.y * scale), (width, height));

		// Draw rotated texture
		Screen.DrawTexture(tex, false, pos.x, pos.y, DTA_CenterOffset, true, DTA_Rotate, -ang, DTA_Alpha, alpha, DTA_DestWidthF, size.x, DTA_DestHeightF, size.y);
	}

	static void Toggle(Actor activator, int status = -1)
	{
		SaveLevelData(); // Save data before toggling so that the current map gets included in the tallies

		if (!activator) { return; }

		MapStatsHandler this = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));
		let p = activator.player;
		if (!this || !p) { return; }

		if (status > -1) { this.active[activator.PlayerNumber()] = status; }
		else { this.active[activator.PlayerNumber()] = !this.active[activator.PlayerNumber()]; }
	}

	static bool IsActive()
	{
		MapStatsHandler this = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));

		if (!this) { return false; }

		return this.active[consoleplayer];
	}

	static void Clear()
	{
		MapStatsHandler this = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));
		if (!this) { return; }

		this.SpecialItemPickups.Clear();
		this.Levels.Clear();
	}

	static void SetChapter(int val) // Called from the MissionNumber OPEN ACS script in gameplay.acs
	{
		MapStatsHandler this = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));
		if (!this || !val) { return; }

		if (val != this.chapter || level.totaltime < 35) // If you're changing chapters or starting a new game, then initialize the stats list
		{
			this.Clear();
			this.chapter = val;
		}
	}

	static bool AddSpecialPickup(String texName, int chapter) // Called from the CompassItem base class when a CompassItem is picked up and chapter is 3.
	{
		MapStatsHandler this = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));
		// There's no event handler for a game being saved, so it is necessary  to do this to keep Eisenmann files and Mayan artifacts across saved games.
		PersistentMapStatsHandler pthis = PersistentMapStatsHandler(EventHandler.Find("PersistentMapStatsHandler"));
		if (!this) { return false; }

		if (chapter == this.chapter)
		{
			this.SpecialItemPickups.Push(texName);
			pthis.SpecialItemPickups.Push(texName);
			return true;
		}

		return false;
	}

	override void NewGame()
	{
		Levels.Clear();
		SpecialItemPickups.Clear();

		if (persistent)
		{
			persistent.Levels.Clear();
			persistent.SpecialItemPickups.Clear();
		}
	}
}