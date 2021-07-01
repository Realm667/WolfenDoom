class NoticeMenu : BoAMenu
{
	bool finished;

	override bool MouseEvent(int type, int x, int y)
	{
		if (type == MOUSE_Click)
		{
			return MenuEvent(MKEY_Enter, true);
		}
		return false;
	}

	override bool OnUIEvent(UIEvent ev)
	{
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

		if (current is "NoticeMenu") { return NoticeMenu(current).finished; }

		return true;
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		finished = true;
		return true;
	}
}

class IWADNotice : NoticeMenu
{
	override void Drawer()
	{
		screen.Dim(0x000000, 1.0, 0, 0, Screen.GetWidth(), screen.GetHeight());

		String title = StringTable.Localize("IWADNOTICE1", false);
		String text = StringTable.Localize("IWADNOTICE2", false);
		TextureID tex = TexMan.CheckForTexture("CONBACK", TexMan.Type_MiscPatch);
		if (tex) { screen.DrawTexture (tex, false, 0, 0, DTA_Fullscreen, true, DTA_Alpha, 1.0); }
		// Display IWADNOTICE1 on one line, center justified, in BigFont
		screen.DrawText(BigFont, Font.CR_GRAY,
			Screen.GetWidth() / 2 - BigFont.StringWidth(title) * CleanXfac / 2,
			Screen.GetHeight() / 2 - BigFont.GetHeight() * CleanYfac / 2,
			title, DTA_CleanNoMove, true);
		// Display IWADNOTICE2 on multiple lines, center justified, in SmallFont
		String widthString = "a";
		int widthChar = widthString.ByteAt(0);
		String temp; BrokenString textlines;
		[temp, textLines] = BrokenString.BreakString(text, SmallFont.GetCharWidth(widthChar) * 50, fnt:SmallFont);
		for (int line = 0; line < textLines.Count(); line++)
		{
			double yadd = SmallFont.GetHeight() * (line + 1);
			screen.DrawText (SmallFont, Font.CR_GRAY,
				Screen.GetWidth() / 2 - textLines.StringWidth(line) * CleanXfac / 2,
				Screen.GetHeight() / 2 + yadd * CleanYfac,
				textLines.StringAt(line), DTA_CleanNoMove, true);
		}
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		MenuSound("menu/choose");
		Close();
		Level.setFrozen(false);

		return true;
	}
}

class Disclaimer : NoticeMenu
{
	int tic, maxwidth, lineheight, w, h, delay;
	double x, y;
	double alpha, bgalpha;
	String text;
	BrokenString lines;

	override void Init(Menu parent)
	{
		w = 640;
		h = 400;

		text = StringTable.Localize("$DISCLAIMER");

		maxwidth = 500;
		lineheight = BigFont.GetHeight();
		[text, lines] = BrokenString.BreakString(text, maxwidth, false, "L", BigFont);

		alpha = 0.0;
		bgalpha = 1.0;
		x = w  / 2 - maxwidth / 2;
		y = h / 2 - lineheight * (lines.Count() - 1) / 2;

		delay = 35;

		GenericMenu.Init(parent);

		DontDim = true;
		DontBlur = true;
	}


	override void Ticker()
	{
		if (delay) { delay--; }

		if (delay == 0)
		{
			if (tic++ >= 350 ) { finished = true; }

			if (finished)
			{
				alpha = max(0.0, alpha - 1.0 / 70); // Fade out over two seconds
				if (alpha == 0.0) { bgalpha -= 1.0 / 35; }
				if (bgalpha <= 0)
				{
					Close();
				}
			}
			else if (alpha < 1.0)
			{
				alpha += 1.0 / 70; // Fade in over two seconds
			}
		}

		Super.Ticker();
	}

	override void Drawer()
	{
		screen.Dim(0x000000, bgalpha, 0, 0, Screen.GetWidth(), screen.GetHeight());

		PrintFullJustified(lines, maxwidth);
	}

	void PrintFullJustified(BrokenString lines, double width)
	{
		double spacing = 0;

		for (int t = 0; t < lines.Count(); t++)
		{
			String line = lines.StringAt(t);
			double textwidth = lines.StringWidth(t);

			if ( // Don't full justify if a line is the end of a paragraph and it's less than 80% of the desired width
				!(
					(
						t == lines.Count() - 1 ||
						lines.StringAt(t + 1) == ""
					) &&
					textwidth < width * 0.8
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

				spacing = spaces ? (width - textwidth) / spaces : 0;
			}

			if (spacing != 0)
			{
				String temp = "";
				int c = -1;
				int i = 0;
				double textx = 0;
				while (c != 0)
				{
					[c, i] = line.GetNextCodePoint(i);

					if ( // Whitespace
						ZScriptTools.IsWhiteSpace(c) ||
						c == 0x0
					)
					{
						screen.DrawText(BigFont, Font.FindFontColor("Light Gray"), x + textx, y + lineheight * t, temp, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, alpha);

						if (c == 0x9) // Tab alignment
						{
							double tabwidth = w / 10;
							int tabs = int(textx / tabwidth) + 1;
							textx = tabs * tabwidth;
						}
						else // Normal printing
						{
							textx += BigFont.StringWidth(String.Format("%s%c", temp, c)) + spacing;
						}

						temp = "";
					}
					else
					{
						temp.AppendCharacter(c);
					}
				}
			}
			else
			{	
				screen.DrawText (BigFont, Font.FindFontColor("Light Gray"), x, y + lineheight * t, line, DTA_VirtualWidth, w, DTA_VirtualHeight, h, DTA_Alpha, alpha);
			}
		}
	}
}

