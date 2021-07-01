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

class BoAMenu : GenericMenu
{
	static void SetMenu(Actor caller, Name mnu, int param = 0)
	{
		if (players[consoleplayer].mo != caller) { return; }

		Menu.SetMenu(mnu, param);
	}

	bool CheckControl(UIEvent ev, String control, int type)
	{
		int c1, c2;
		[c1, c2] = Bindings.GetKeysForCommand(control);

		String keynames = Bindings.NameKeys(c1, c2);
		keynames = ZScriptTools.StripColorCodes(keynames);

		Array<String> keys;
		keynames.Split(keys, ", ");

		String keychar = String.Format("%c", ev.KeyChar);
		keychar = keychar.MakeUpper();

		for (int i = 0; i < keys.Size(); i++)
		{
			if (keys[i].Length() > 1) { continue; } // Skip named keys (Alt, Shift, Ctrl, etc.)

			if (keys[i].ByteAt(0) == keychar.ByteAt(0))
			{
				MenuEvent(type, false);
				return true;
			}
		}

		return false;
	}
}

class CombinationSafe : BoAMenu
{
	TextureID spinner, spinnerfront, spinnerback, background, turn;
	Vector2 location, size, bgsize, screendimensions;
	double scale, bgscale;
	int dir, olddir, set, count;
	double angle, destangle;
	int keyactive, keytime;
	int combo[3], solution[3];
	double speed;
	int steps;
	Safe s;
	int initial;
	int ticcount;
	BrokenString hintlines;
	double hintx, hinty, hintlineheight;
	int freespin;

	override void Init(Menu parent)
	{
		Super.Init(parent);

		spinner = TexMan.CheckForTexture("DIAL", TexMan.Type_Any);
		spinnerfront = TexMan.CheckForTexture("DIAL_F", TexMan.Type_Any);
		spinnerback = TexMan.CheckForTexture("DIAL_B", TexMan.Type_Any);
		background = TexMan.CheckForTexture("SAFEBKG", TexMan.Type_Any);
		turn = TexMan.CheckForTexture("DIAL_DIR", TexMan.Type_Any);

		location = (427, 240);
		[location, screendimensions] = Screen.VirtualToRealCoords(location, (screen.GetWidth(), screen.GetHeight()), (640, 480));

		size = TexMan.GetScaledSize(spinner);
		bgsize = TexMan.GetScaledSize(background);
		scale = 0.4 * screen.GetHeight() / size.y;
		bgscale = scale * 1.75;

		s = Safe(players[consoleplayer].ConversationNPC);

		steps = 24;
		speed = 360.0 / steps;
		keytime = max(2, int(speed / 5));

		if (s && !s.special)
		{
			solution[0] = s.args[1];
			solution[1] = s.args[2];
			solution[2] = s.args[3];
		}

		// If no combination set, use the object's coordinates to derive a combination
		if (solution[0] == 0 && solution[1] == 0 && solution[2] == 0)
		{
			// Default to setting a pseudo-random combo...  If you flag the actor with STANDSTILL, it will stay unlocked
			if (s && !s.bStandStill)
			{
				solution[0] = int(abs(s.pos.x % steps));
				solution[1] = int(abs(s.pos.y % steps));
				solution[2] = int(abs(s.pos.z % steps));
			}
		}

		if (boa_debugsafes) { console.printf("%i %i %i", solution[0], solution[1], solution[2]); }

		DontDim = true;
		menuactive = OnNoPause;

		destangle = 360 * 3;
		freespin = 3;
		initial = 1;

		String hintmessage = StringTable.Localize("SAFEHINT", false);
		String temp;
		[temp, hintlines] = BrokenString.BreakString(hintmessage, 400, fnt:SmallFont);

		hintx = 320;
		hintlineheight = SmallFont.GetHeight();
		hinty = 470 - hintlineheight * (hintlines.Count() - 0.5);
	}

	override void Drawer()
	{
		if (solution[0] != 0 || solution[1] != 0 || solution[2] != 0)
		{
			screen.Dim(0x000000, 0.2, 0, 0, screen.GetWidth(), screen.GetHeight());

			if (background)
			{
				screen.DrawTexture(background, false, location.x - bgsize.x * bgscale / 9.2, location.y, DTA_DestWidth, int(bgsize.x * bgscale), DTA_DestHeight, int(bgsize.y * bgscale), DTA_CenterOffset, true);
			}

			if (spinnerback)
			{
				screen.DrawTexture(spinnerback, false, location.x, location.y, DTA_DestWidth, int(size.x * scale), DTA_DestHeight, int(size.y * scale), DTA_CenterOffset, true);
			}

			if (spinner)
			{
				Screen.DrawTexture(spinner, false, location.x, location.y, DTA_CenterOffset, true, DTA_Rotate, angle, DTA_ScaleX, scale, DTA_ScaleY, scale);
			}

			if (spinnerfront)
			{
				screen.DrawTexture(spinnerfront, false, location.x, location.y, DTA_DestWidth, int(size.x * scale), DTA_DestHeight, int(size.y * scale), DTA_CenterOffset, true);
			}

			if (ticcount > 0 && initial > 0)
			{
				double alpha;

				if (initial == 1 && ticcount <= 175)
				{
					// Print hint message (duplicates ACS "HintMessage" script, but with handling for multiple lines)
					if (ticcount == 10) { S_StartSound("menu/change", CHAN_7, CHANF_UI | CHANF_NOSTOP, 1.0); }

					if (ticcount >= 105)
					{
						alpha = 0.5 + sin(((ticcount - 70) * 360 / 70 - 90) / 2);
					}
					else if (ticcount >= 35)
					{
						alpha = 1.0;
					}
					else
					{
						alpha = 0.5 + sin((ticcount * 360 / 70 - 90) / 2);
					}

					for (int i = 0; i < hintlines.Count(); i++)
					{
						screen.DrawText(SmallFont, Font.CR_GRAY, hintx - hintlines.StringWidth(i) / 2, hinty + hintlineheight * i, hintlines.StringAt(i), DTA_VirtualWidth, 640, DTA_VirtualHeight, 480, DTA_Alpha, alpha);
					}
				}
				
				if (ticcount > 35)
				{
					alpha = 0.5 * (0.5 + sin(((ticcount - 35) * 720 / 70 - 90) / 2));
					if (ticcount < 105 || ticcount > 175)
					{
						screen.DrawTexture(turn, false, location.x, location.y, DTA_DestWidth, int(size.x * scale), DTA_DestHeight, int(size.y * scale), DTA_CenterOffset, true, DTA_Alpha, alpha);
					}
					else if (ticcount < 245)
					{
						screen.DrawTexture(turn, false, location.x, location.y, DTA_DestWidth, int(size.x * scale), DTA_DestHeight, int(size.y * scale), DTA_CenterOffset, true, DTA_FlipX, true, DTA_Alpha, alpha);
					}
				}
			}
		}
	}

	override void Ticker()
	{
		if (solution[0] == 0 && solution[1] == 0 && solution[2] == 0)
		{
			TryOpen();
			Close();

			return;
		}

		if (initial)
		{
			ticcount++;

			if (ticcount >= 245)
			{
				ticcount = 0;
				initial++;

				if (initial > 2) { initial = 0; }
			}
		}

		if (keyactive > 0)
		{
			keyactive--;
			ticcount = 0;
			initial = 0;
		}

		if (keyactive == keytime - 1 || freespin)
		{
			S_StartSound("safe/dial", CHAN_7, CHANF_UI | CHANF_NOSTOP, 1.0);

			if (destangle > angle)
			{
				angle += speed + speed * (!!freespin * 2);
				dir = 1;

				if (angle > 360)
				{
					angle -= 360;
					count = max(0, count - 1);
				}
			}
			else if (destangle < angle)
			{
				angle -= speed + speed * (!!freespin * 2);
				dir = -1;

				if (angle < 0)
				{
					angle += 360;
				}
			}

			if (freespin > 0 && angle <= speed * 3)
			{
				freespin--;
				if (freespin == 0) { angle = destangle = 0; }
			}
		}
		else if (!keyactive)
		{
			destangle = angle - (angle % speed);
			angle = destangle;
		}

		if (boa_debugsafes && set < 3)
		{
			int at = int((angle / (360 / steps)) % steps);
			String temp = String.Format("At: %i", at);

			int next = solution[at == solution[set] ? min(2, set + 1) : set];
			temp.AppendFormat("\nNext Number: %i", next);

			console.printf(temp);
		}

		if (olddir && olddir != dir && set < 3)
		{
			combo[set] = int((angle / (360 / steps)) % steps);

			set++;
			count++;
		}

		olddir = dir;

		if (set > 0 && count <= 0)
		{
			DoReset();
		}

		Super.Ticker();
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (keyactive || freespin > 0) { return false; }

		switch (mkey)
		{
			case MKEY_Up:
			case MKEY_Down:
			case MKEY_Back:
				Close();
				return true;
			case MKEY_Enter:
				// Attempt Open
				if (set == 2)
				{
					combo[2] = int((angle / (360 / steps)) % steps);
					TryOpen();
				}

				if (set > 2)
				{
					TryOpen();
				}

				return true;
			case MKEY_Right:
				// Turn Right
				if (angle == 0 && count == 0 && set == 0) { return false; } // Don't let the dial turn to the right in the beginning
				
				// Allow safe to open if you turn dial to right after setting combo correctly
				if (set == 2)
				{
					combo[2] = int((angle / (360 / steps)) % steps);
					TryOpen();
				}

				keyactive = keytime;
				destangle = angle - speed * 4;

				return true;
			case MKEY_Left:
				// Turn Left
				keyactive = keytime;
				destangle = angle + speed * 4;

				return true;
			default:
				return false;
		}
	}

	override bool MouseEvent(int type, int x, int y)
	{
		return false;
	}

	override bool OnUIEvent(UIEvent ev)
	{
		// Intercept key presses to see if we're pressing the strafe controls or use, 
		// and redirect those to call the correct left/right/open movement menu event code.

		if (ev.Type == UIEvent.Type_KeyDown || ev.Type == UIEVent.Type_Char)
		{
			CheckControl(ev, "+moveleft", MKEY_Left);
			CheckControl(ev, "+moveright", MKEY_Right);
			CheckControl(ev, "+use", MKEY_Enter);
			CheckControl(ev, "+forward", MKEY_Up);
			CheckControl(ev, "+back", MKEY_Down);
		}

		return false;
	}

	void TryOpen()
	{
		int match = true;

		for (int i = 0; i < 3; i++)
		{
			// Allow a step to either side of the correct number to be accepted
			if (combo[i] >= solution[i] - 1 && combo[i] <= solution[i] + 1) { continue; }
			if (solution[i] == 0 && combo[i] >= steps - 1) { continue; }

			match = false;
		}

		if (match)
		{
			S_StartSound("safe/open", CHAN_7, CHANF_UI | CHANF_NOSTOP, 0.5);
			EventHandler.SendNetworkEvent("opensafe", int(s.pos.x), int(s.pos.y), int(s.pos.z));

			Close();
		}
		else
		{
			S_StartSound("safe/locked", CHAN_7, CHANF_UI | CHANF_NOSTOP, 0.5);
		}
	}

	void DoReset()
	{
		for (int i = 0; i < 3; i++) { combo[i] = 0; }
		count = 0;
		set = 0;
	}
}

class ViewItem : BoAMenu
{
	TextureID background;
	Vector2 location, size, bgsize, screendimensions;
	double scale, fontscale, linespacing, alpha, msgalpha;

	bool initial;
	int ticcount, closetime, maxy, maxlines, pagewidth, page, maxpages;

	BrokenString hintlines;
	double hintx, hinty, hintlineheight;

	BrokenString textlines;
	double textx, texty, textlineheight;

	Font msgfont;

	InteractiveItem item;
	Sound PickupSound;

	override void Init(Menu parent)
	{
		Super.Init(parent);

		item = InteractiveItem(players[consoleplayer].ConversationNPC); // Only view actors that inherit from InteractiveItem

		texty = 55;
		maxy = 428;
		fontscale = 0.5;
		linespacing = 1.5;
		pagewidth = 250;

		String text, paper, fnt;

		if (item)
		{
			paper = "PAPER" .. item.args[1];

			switch (item.args[1])
			{
				case 3:
					texty = 108;
					break;
				case 4:
					texty = 168;
					break;
				case 6: 
					texty = 220;
					maxy = 308;
					break;
				case 7: 
					texty = 195;
					maxy = 300;
					break;
				case 8:
					maxy = 375;
				default:
					break;
			}

			int fontstyle = item.args[2];

			switch (fontstyle)
			{
				case 1:
					fnt = "AMH18";
					fontscale *= 0.875;
					linespacing = 1.25;
					break;
				case 3:
					fnt = "Classic";
					fontscale *= 2;
					break;
				case 4:
					fnt = "CHICKN24";
					fontscale *= 0.875;
					linespacing = 1.0;
					break;
				case 5:
					fnt = "handwriting_neat";
					break;
				case 6:
					fnt = "handwriting_institute";
					linespacing = 1.2;
					break;
				case 7:
					fnt = "NewConsoleFont";
					fontscale *= 1.5;
					break;
				case 8:
					fnt = "MavenProSmall";
					fontscale *= 1.2;
					linespacing = 1.2;
					break;
				case 9:
					// Larger handwriting_neat, for secret hint sheets
					fnt = "handwriting_neat";
					fontscale *= 1.25;
					linespacing = 1.0;
					break;
				case 10:
					fnt = "threefiv";
					fontscale *= 2;
					break;
				case 11:
					fnt = "chalkboard";
					break;
				case 2:
				default:
					fnt = "typewriter";
					linespacing = 1.4;
					break;
			}

			// Get text and image info from InteractiveItem functions.  Used for all text papers and variants.
			text = item.GetDisplayString();
			if (paper == "PAPER0") { paper = item.GetDisplayImage(); }
			scale = item.GetDisplayScale();

			PickupSound = item.PickupSound;
		}

		// Background graphic
		background = TexMan.CheckForTexture(paper, TexMan.Type_Any);
		bgsize = TexMan.GetScaledSize(background);

		location = (320, 240);

		if (!(text == "")) // Don't show any text if nothing was set up for display...
		{
			// Text content
			msgfont = Font.GetFont(fnt);
			if (!msgfont) { msgfont = SmallFont; }

			String textmessage = StringTable.Localize(text, false);

			ZScriptTools.DebugFontGlyphs(fnt, textmessage);

			String temp;
			[temp, textlines] = BrokenString.BreakString(textmessage, int(pagewidth / fontscale), fnt:msgfont);

			textx = 320 - pagewidth / 2;
			textlineheight = msgfont.GetHeight() * linespacing * fontscale;
			maxlines = int((maxy - texty) / textlineheight);

			int count = textlines.Count();
			for (int c = count - 1; c >= 0; c--)
			{
				if (textlines.StringWidth(c) <= 0) { count--; } // Don't count empty lines at the end
				else { break; }
			}		

			double pages = count / maxlines;

			maxpages = int(pages);  // maxpages is an integer, but make sure to always round up if there was even a small amount of overflow
			if (maxpages < pages) { maxpages++; }
		}

		// Hint message
		String hintmessage = StringTable.Localize("PAPERTEXTHOLD", false);

		if (maxpages > 0) { hintmessage = StringTable.Localize("PAPERTEXTTURN", false) .. "\n" .. hintmessage; }
		String temp;
		[temp, hintlines] = BrokenString.BreakString(hintmessage, min(pagewidth + 50, 320), fnt:SmallFont);

		hintx = 320;
		hintlineheight = SmallFont.GetHeight();

		double offset = hintlineheight * (hintlines.Count() - 0.5) - 10;

		hinty = 460 - offset;
		location.y -= offset;
		maxy = int(maxy - (hintlineheight * (hintlines.Count() - 1.0) - 10));

		texty -= offset;

		// Menu setup
		DontDim = true;
		menuactive = Menu.On; // Must set to 'On' first instead of straight to WaitKey in order to not end up with stuck controls

		initial = true;
		closetime = 0;
	}

	override void Drawer()
	{
		screen.Dim(0x000000, 0.2 * alpha, 0, 0, screen.GetWidth(), screen.GetHeight());

		if (alpha > 0)
		{
			if (background)
			{
				screen.DrawTexture(background, true, location.x, location.y, DTA_DestWidth, int(bgsize.x * scale), DTA_DestHeight, int(bgsize.y * scale), DTA_VirtualWidth, 640, DTA_VirtualHeight, 480, DTA_CenterOffset, true, DTA_Alpha, alpha);
			}

			if (textlines)
			{
				int start = page * maxlines;
				for (int i = start; i < min(start + maxlines, textlines.Count()); i++)
				{
					String text = textlines.StringAt(i);

					screen.DrawText(msgfont, Font.CR_UNTRANSLATED, textx / fontscale, texty / fontscale + textlineheight * (i - start) / fontscale, text, DTA_VirtualWidth, int(640 / fontscale), DTA_VirtualHeight, int(480 / fontscale), DTA_Alpha, alpha);
				}

				// Draw left/right indicators at the bottom of the page, as appropriate
				if (maxpages > 0)
				{
					if (page > 0) { screen.DrawText(msgfont, Font.CR_UNTRANSLATED, (textx + pagewidth - 32 - 4) / fontscale, maxy / fontscale, "<", DTA_VirtualWidth, int(640 / fontscale), DTA_VirtualHeight, int(480 / fontscale), DTA_Alpha, alpha); }
					if (page < maxpages) { screen.DrawText(msgfont, Font.CR_UNTRANSLATED, (textx + pagewidth - 32 + 4) / fontscale, maxy / fontscale, ">", DTA_VirtualWidth, int(640 / fontscale), DTA_VirtualHeight, int(480 / fontscale), DTA_Alpha, alpha); }
				}
			}
		}

		if (msgalpha > 0)
		{
			for (int i = 0; i < hintlines.Count(); i++)
			{
				screen.DrawText(SmallFont, Font.CR_GRAY, hintx - hintlines.StringWidth(i) / 2, hinty + hintlineheight * i, hintlines.StringAt(i), DTA_VirtualWidth, 640, DTA_VirtualHeight, 480, DTA_Alpha, msgalpha);
			}
		}
	}

	override void Ticker()
	{
		ticcount++;

		if (closetime > 0)
		{
			closetime--;
			alpha = closetime / 5.0;
		}

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
				if (ticcount == 10) { S_StartSound(PickupSound, CHAN_ITEM, CHANF_UI | CHANF_NOSTOP, 1.0); }

				if (ticcount >= 105)
				{
					msgalpha = 0.5 + sin(((ticcount - 70) * 360 / 70 - 90) / 2);
				}
				else if (ticcount >= 35 && ticcount < 105)
				{
					msgalpha = 1.0;
					alpha = msgalpha;
				}
				else
				{
					menuactive = Menu.WaitKey;
					msgalpha = 0.5 + sin((ticcount * 360 / 70 - 90) / 2);
					alpha = msgalpha;
				}
			}
		}

		if (ticcount > 5 && alpha <= 0)
		{
			closetime = 0;
			Close();

			if (item.bAllowPickup) { S_StartSound("pickup/item", CHAN_ITEM, CHANF_UI | CHANF_NOSTOP, 1.0); } // Generic "putting in inventory" sound
		}

		Super.Ticker();
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		switch (mkey)
		{
			case MKEY_Up:
			case MKEY_Left:
				if (page > 0) { page--; }
				return true;
			case MKEY_Down:
			case MKEY_Right:
				if (page < maxpages) { page++; }
				return true;
			case MKEY_Back:
			case MKEY_Enter:
				DoClose();
				return true;
			default:
				return false;
		}
	}

	override bool MouseEvent(int type, int x, int y)
	{
		return false;
	}

	override bool OnInputEvent(InputEvent ev)
	{
		if (ticcount < 5) { return false; }

		if (ev.type == InputEvent.Type_KeyDown)
		{
			switch (ev.keyscan)
			{
				case InputEvent.Key_Escape:
				case InputEvent.Key_Enter:
					MenuEvent(MKEY_Back, false);
					return true;
					break;
				case InputEvent.Key_LeftArrow:
				case InputEvent.Key_UpArrow:
					MenuEvent(MKEY_Left, false);
					return true;
					break;
				case InputEvent.Key_RightArrow:
				case InputEvent.Key_DownArrow:
					MenuEvent(MKEY_Right, false);
					return true;
					break;
				case InputEvent.Key_Mouse1:
					if (page < maxpages) { MenuEvent(MKEY_Right, false); }
					else { MenuEvent(MKEY_Back, false); }
					return true;
					break;
			}

			CheckInput(ev, "+moveleft", MKEY_Left);
			CheckInput(ev, "+moveright", MKEY_Right);
			CheckInput(ev, "+use", MKEY_Enter);
			CheckInput(ev, "+forward", MKEY_Up);
			CheckInput(ev, "+back", MKEY_Down);
		}

		return false;
	}

	bool CheckInput(InputEvent ev, String control, int type)
	{
		int c1, c2;
		[c1, c2] = Bindings.GetKeysForCommand(control);

		if (ev.keyscan == c1 || ev.keyscan == c2)
		{
			MenuEvent(type, false);
			return true;
		}

		return false;
	}

	void DoClose()
	{
		if (!closetime)
		{
			initial = false;
			closetime = 5;
		}
	}
}