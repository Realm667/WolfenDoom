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

class KeenMessage
{
	String text;
	String colorprefix;
	int align;
	String graphic;
	int graphicalign;
	int width;
	int height;
	int autoclose;
	int fadeintime, fadeouttime;
	double fadealpha, fadetargetalpha;
	int showtics;
	String options;
	bool active;

	ui static void Init(ClassicMessageBox parent, String mtext, int malign = 0, String mgraphic = "", int mgraphicalign = 0, int mautoclose = -1, int mwidth = 26, int mheight = 8, double fadealpha = 0.0, double fadetargetalpha = 1.0, int fadeintime = 0, int fadeouttime = 0, String options = "", bool active = false)
	{
		KeenMessage msg = New("KeenMessage");

		msg.text = mtext;
		msg.colorprefix = "\c[TrueBlack]";
		msg.align = malign;
		msg.graphic = mgraphic;
		msg.graphicalign = mgraphicalign;
		msg.autoclose = mautoclose;
		msg.width = mwidth;
		msg.height = mheight;
		msg.fadealpha = fadealpha;
		msg.fadetargetalpha = fadetargetalpha;
		msg.fadeintime = fadeintime;
		msg.fadeouttime = fadeouttime;
		msg.showtics = 70;
		msg.options = options;
		msg.active = active;

		parent.messages.Push(msg);
	}
}

class ClassicMessageBox : MessageBoxMenu
{
	String prefix;
	Color fillcolor;
	TextureID top, bottom, left, right;
	TextureID topleft, topright, bottomleft, bottomright;

	Font fnt;

	String message, colorprefix;
	int align;
	int graphicalign;
	String graphic, options;
	TextureID tex;
	int width, height;

	String cursor;
	int blinktime;

	bool silent, active;
	int autoclose;
	int cmds;

	int index;
	Array<KeenMessage> messages;

	int curstate;
	int fadetic, ticcount, ticks;
	int fadeintime, fadeouttime;
	double fadealpha, fadetargetalpha;

	int showtics, optioncount, retval;

	override void Init(Menu parent, String msg, int messagemode, bool StartSound, Name cmd, voidptr native_handler)
	{
		silent = !StartSound;

		// Initialize everything through the real message box code
		Super.Init(parent, msg, messagemode, StartSound, cmd, native_handler);

		message = CleanString(msg);
		tex = TexMan.CheckForTexture(graphic, TexMan.Type_Any);

		if (!prefix.Length())
		{
			if (parent is "OptionMenu") { prefix = "FRAME_"; fillcolor = 0xBB1b1b1b; }
			else { prefix = "BG_"; fillcolor = 0x0; }
		}

		if (!fnt)
		{
			if (parent is "OptionMenu") { fnt = SmallFont; }
			else { fnt = BigFont; }
		}

		top = TexMan.CheckForTexture(prefix .. "T", TexMan.Type_Any);
		bottom = TexMan.CheckForTexture(prefix .. "B", TexMan.Type_Any);
		left = TexMan.CheckForTexture(prefix .. "L", TexMan.Type_Any);
		right = TexMan.CheckForTexture(prefix .. "R", TexMan.Type_Any);
		topleft = TexMan.CheckForTexture(prefix .. "TL", TexMan.Type_Any);
		topright = TexMan.CheckForTexture(prefix .. "TR", TexMan.Type_Any);
		bottomleft = TexMan.CheckForTexture(prefix .. "BL", TexMan.Type_Any);
		bottomright = TexMan.CheckForTexture(prefix .. "BR", TexMan.Type_Any);

		if (messagemode > 0) { blinktime = -1; }
		retval = -1;

		autoclose = -1;
	}

	static String CleanString(String input)
	{
		input.Replace("\n\n" .. Stringtable.Localize("$DOSY"), "");
		input.Replace("\n\n" .. Stringtable.Localize("$PRESSKEY"), "");
		input.Replace("\n\n" .. Stringtable.Localize("$PRESSYN"), "");
		input.Replace(Stringtable.Localize("$PRESSYN"), ""); // For the save deletion prompt

		return input;
	}

	static ClassicMessageBox PrintMessage(String text, int align = 0, String graphic = "", int graphicalign = 0, int autoclose = -1, int width = 26, int height = 8, double fadealpha = 0.0, double fadetargetalpha = 1.0, int fadeintime = 0, int fadeouttime = 0, String options = "", bool active = false)
	{
		ClassicMessageBox msg = ClassicMessageBox(GetCurrentMenu());

		if (!msg) { msg = New("ClassicMessageBox"); }

		msg.cmds = players[consoleplayer].cmd.buttons;

		msg.prefix = "B_";
		msg.fillcolor = 0xFFFFFF;
		msg.fnt = Font.GetFont("Classic");
		msg.colorprefix = "\c[TrueBlack]";

		KeenMessage.Init(msg, text, align, graphic, graphicalign, autoclose, width * 8 + 16, height * 8 + 16, fadealpha, fadetargetalpha, fadeintime, fadeouttime, options, active);

		msg.Init(null, text, true, false);

		msg.index = 1;

		msg.message = msg.messages[msg.index - 1].text;
		msg.width = msg.messages[msg.index - 1].width;
		msg.height = msg.messages[msg.index - 1].height;
		msg.align = msg.messages[msg.index - 1].align;
		msg.graphic = msg.messages[msg.index - 1].graphic;
		msg.tex = TexMan.CheckForTexture(msg.graphic, TexMan.Type_Any);
		msg.graphicalign = msg.messages[msg.index - 1].graphicalign;
		msg.autoclose = msg.messages[msg.index - 1].autoclose;

		msg.curstate = 0;
		msg.fadeintime = msg.messages[msg.index - 1].fadeintime;
		msg.fadeouttime = msg.messages[msg.index - 1].fadeouttime;
		msg.fadealpha = msg.messages[msg.index - 1].fadealpha;
		msg.fadetargetalpha = msg.messages[msg.index - 1].fadetargetalpha;
		msg.fadetic = (msg.messages[msg.index - 1].fadeintime || msg.messages[msg.index - 1].fadeouttime) ? gametic : 0;
		msg.options = msg.messages[msg.index - 1].options;
		msg.active = msg.messages[msg.index - 1].active;

		msg.mMessageMode = !options.length();
		if (msg.active) { menuactive = OnNoPause; }
		else { menuactive = On; }

		msg.DontDim = true;
		msg.DontBlur = true;
		msg.silent = true;

		msg.showtics = 70;

		msg.ActivateMenu();

		return msg;
	}

	override void Drawer()
	{
		if (mParentMenu) { mParentMenu.Drawer(); }
		DrawMessage(message, 8, fillcolor, colorprefix);

		if (fadetic) { DrawFade(); }
	}

	override void Ticker()
	{
		ticks++;

		if (showtics > 0) { showtics--; }

		if (autoclose > 0)
		{
			autoclose--;
		}
		else if (autoclose == 0)
		{
			index++;

			if (retval > -1)
			{
				if (menuactive == Menu.OnNoPause) { retval = -1; } // Clear the value on second pass
				menuactive = Menu.OnNoPause; // Let scripts (e.g., Level exit) run in the background
			}
			else if (index > messages.Size())
			{
				if (!fadealpha)
				{
					Close();
				}
				else
				{
					menuactive = Menu.OnNoPause; // Let scripts (e.g., Level exit) run in the background
					if (index > messages.Size() + 1) { Close(); } // Then close the menu on the next tick
				}
			}
			else
			{
				message = messages[index - 1].text;
				colorprefix = messages[index - 1].colorprefix;
				width = messages[index - 1].width;
				height = messages[index - 1].height;
				align = messages[index - 1].align;
				graphic = messages[index - 1].graphic;
				tex = TexMan.CheckForTexture(graphic, TexMan.Type_Any);
				graphicalign = messages[index - 1].graphicalign;
				autoclose = messages[index - 1].autoclose;

				curstate = 0;
				fadeintime = messages[index - 1].fadeintime;
				fadeouttime = messages[index - 1].fadeouttime;
				fadealpha = messages[index - 1].fadealpha;
				fadetargetalpha = messages[index - 1].fadetargetalpha;
				fadetic = (messages[index - 1].fadeintime || messages[index - 1].fadeouttime) ? gametic : 0;
				showtics = messages[index - 1].showtics;
				options = messages[index - 1].options;
				active = messages[index - 1].active;

				mMessageMode = !options.length();
				if (active) { menuactive = OnNoPause; }
				else { menuactive = On; }

				cmds = players[consoleplayer].cmd.buttons;
			}

			if (!silent) { CloseSound(); }
		}

		if (fadetic) { TickFade(); }
	}

	virtual void DrawMessage(String text, int size = 8, color clr = 0x0, String colorprefix = "")
	{
		if (!top || !bottom || !left || !right || !topleft || !topright || !bottomleft || !bottomright) { return; }

		int w = 0, h = 0, gw = 0;
		text = colorprefix .. StringTable.Localize(text);

		Vector2 graphicsize;

		if (graphic)
		{
			graphicsize = TexMan.GetScaledSize(tex);
			gw = int(graphicsize.x * CleanXFac);
		}

		String temp; BrokenString message;
		[temp, message] = BrokenString.BreakString(text, (width > 0 ? width : 316) - int(graphicsize.x) - 20, fnt:fnt);

		int c = message.Count();

		int fontheight = fnt.GetHeight();
		if (options.length()) { fontheight = fontheight * 4 / 3; }

		for (int i = 0; i < c; i++)
		{
			w = max(w, message.StringWidth(i) + (i == (c - 1) ? blinktime > -1 ? fnt.StringWidth("_") : 0 : 0));
			h += fontheight;
		}

		if (options.length())
		{
			int index = 1;
			String lookup = options .. index;
			while (!(StringTable.Localize(lookup, false) ~== lookup))
			{
				lookup = options .. ++index;
			}

			optioncount = index - 1;

			h += fontheight * optioncount + fontheight / 3;
		}

		int textheight = h;

		w += 32;
		h += 24;

		w = max(w, width);
		h = max(h, height);

		int ws = w * CleanXfac;
		int hs = h * CleanYfac;

		int x = Screen.GetWidth() / 2 - ws / 2;
		int y = Screen.GetHeight() / 2 - hs / 2;

		x += int(size * CleanXfac);
		y += int(size * CleanYfac);
		ws -= int(2 * size * CleanXfac);
		hs -= int(2 * size * CleanYfac);

		DrawFrame(x, y, ws, hs, clr);

		int xoffset = 0;

		if (tex)
		{
			int drawx = x;

			if (graphicalign == 2) { drawx += ws / 2 - gw / 2; }
			else if (graphicalign == 1) { drawx += ws - gw; if (align) { xoffset -= int(graphicsize.x + 8) / align; } }
			else
			{
				if (align == 0) { xoffset += int(graphicsize.x) + 8; }
				else if (align == 2) { xoffset += int(graphicsize.x + 8) / 3; }
			}

			screen.DrawTexture(tex, true, drawx, y, DTA_CleanNoMove, true);
		}

		if (blinktime > -1 && gametic > blinktime)
		{
			if (cursor == "_") { cursor = ""; }
			else { cursor = "_"; }	

			blinktime = gametic + 5;
		}

		int drawx = 160 + xoffset;
		int drawy = 100 - textheight / 2;
		for (int i = 0; i < c; i++)
		{
			int size = fnt.StringWidth(message.StringAt(i) .. (i == (c - 1) ? cursor : ""));

			if (align == 2) { drawx -= size / 2; }
			else if (align == 1) { drawx += w / 2 - size - 8; }
			else { drawx -= w / 2 - 8; }

			screen.DrawText(fnt, 0, drawx, drawy, message.StringAt(i) .. (i == (c - 1) ? cursor : ""), DTA_Clean, true);

			drawx = 160 + xoffset;
			drawy += fontheight;
		}

		if (options.length())
		{
			drawy += fontheight / 2;
			int selectory = (fontheight * (1 + message.Count()) - 3) * CleanYFac;

			int weight = int(max(1, Round(Screen.GetHeight() / 200)));
			if (weight > 1 && weight % 2 == 1) { weight++; }
			int weightoffset = weight / 2;

			int index = 1;
			String lookup = options .. index;
			String value = StringTable.Localize(lookup, false);
			while (!(value ~== lookup))
			{
				screen.DrawText(fnt, 0, drawx - fnt.StringWidth(value) / 2, drawy, colorprefix .. value, DTA_Clean, true);

				if (index == messageSelection + 1)
				{
					Color clr = (ticks % 36 < 18) ? 0xFF5555 : 0x0000AA;

					int boxl = x + 8;
					int boxt = y + selectory;
					int boxr = boxl + ws - 16;
					int boxb = boxt + int(fontheight * CleanYFac - 2);
					
					screen.DrawThickLine(boxl, boxt, boxr, boxt, weight, clr);
					screen.DrawThickLine(boxl, boxb, boxr, boxb, weight, clr);
					screen.DrawThickLine(boxl + weightoffset, boxt, boxl + weightoffset, boxb + 1, weight, clr);
					screen.DrawThickLine(boxr - weightoffset, boxt, boxr - weightoffset, boxb + 1, weight, clr);
				}

				drawy += fontheight;
				selectory += fontheight * CleanYFac;

				lookup = options .. ++index;
				value = StringTable.Localize(lookup, false);
			}
		}
	}

	void DrawFrame(int x, int y, int ws, int hs, Color clr = 0xFFFFFF)
	{
		Vector2 texsize = TexMan.GetScaledSize(top);
		int size = int(texsize.x);

		double dimalpha = 1.0;
		if (clr.a) { dimalpha = clr.a / 255.0; }

		screen.Dim(clr, dimalpha, x, y, ws, hs);

		screen.DrawTexture(top, true, x, y - int(size * CleanYfac), DTA_CleanNoMove, true, DTA_DestWidth, ws, DTA_DestHeight, int(size * CleanYfac));
		screen.DrawTexture(bottom, true, x, y + hs, DTA_CleanNoMove, true, DTA_DestWidth, ws, DTA_DestHeight, int(size * CleanYfac));
		screen.DrawTexture(left, true, x - int(size * CleanXfac), y, DTA_CleanNoMove, true, DTA_DestWidth, int(size * CleanXfac), DTA_DestHeight, hs);
		screen.DrawTexture(right, true, x + ws, y, DTA_CleanNoMove, true, DTA_DestWidth, int(size * CleanXfac), DTA_DestHeight, hs);

		screen.DrawTexture(topleft, true, x - int(size * CleanXfac), y - int(size * CleanYfac), DTA_CleanNoMove, true, DTA_DestWidth, int(size * CleanXfac), DTA_DestHeight, int(size * CleanYfac));
		screen.DrawTexture(topright, true, x + ws, y - int(size * CleanYfac), DTA_CleanNoMove, true, DTA_DestWidth, int(size * CleanXfac), DTA_DestHeight, int(size * CleanYfac));
		screen.DrawTexture(bottomleft, true, x - int(size * CleanXfac), y + hs, DTA_CleanNoMove, true, DTA_DestWidth, int(size * CleanXfac), DTA_DestHeight, int(size * CleanYfac));
		screen.DrawTexture(bottomright, true, x + ws, y + hs, DTA_CleanNoMove, true, DTA_DestWidth, int(size * CleanXfac), DTA_DestHeight, int(size * CleanYfac));
	}

	override bool OnUIEvent(UIEvent ev)
	{
		// Intercept key presses to see if we're pressing the strafe controls or use, 
		// and redirect those to call the correct left/right/open movement menu event code.

		if (players[consoleplayer].cmd.buttons & cmds || showtics > 0) { return false; }

		if (ev.Type == UIEvent.Type_KeyDown)
		{
			if (
				CheckControl(ev, "+moveleft", MKEY_Left) ||
				CheckControl(ev, "+moveright", MKEY_Right) ||
				CheckControl(ev, "+use", MKEY_Enter) ||
				CheckControl(ev, "+forward", MKEY_Up) ||
				CheckControl(ev, "+back", MKEY_Down)
			) { return false; }
		}

		if (ev.type == UIEvent.Type_KeyDown)
		{
			if (mMessageMode == 0)
			{
				// tolower
				int ch = ev.KeyChar;
				ch = ch >= 65 && ch < 91? ch + 32 : ch;

				if (ch == 110 /*'n'*/ || ch == 32) 
				{
					HandleResult(false);		
					return true;
				}
				else if (ch == 121 /*'y'*/) 
				{
					HandleResult(true);
					return true;
				}
			}
			else
			{
				autoclose = 2;
				return true;
			}
			return false;
		}

		return Super.OnUIEvent(ev);
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mMessageMode == 0)
		{
			if (mkey == MKEY_Up)
			{
				if (!silent) { MenuSound("menu/cursor"); }
				if (--messageSelection < 0) { messageSelection = optioncount - 1; }
				return true;
			}
			else if (mkey == MKEY_Down)
			{
				if (!silent) { MenuSound("menu/cursor"); }
				if (++messageSelection > optioncount - 1) { messageSelection = 0; }
				return true;
			}
			else if (mkey == MKEY_Enter)
			{
				retval = messageSelection;
				HandleResult(!messageSelection);
				return true;
			}
			else if (mkey == MKEY_Back)
			{
				retval = 0;
				HandleResult(false);
				return true;
			}
			return false;
		}
		else
		{
			autoclose = 2;
			if (!silent) { CloseSound(); }
			return true;
		}

		return true;
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

	override void HandleResult(bool res)
	{
		if (Handler != null)
		{
			if (res) 
			{
				CallHandler(Handler);
			}
			else
			{
				autoclose = 2;
				if (!silent) { CloseSound(); }
			}
		}
		else if (mParentMenu != NULL)
		{
			if (mMessageMode == 0)
			{
				if (mAction == 'None') 
				{
					mParentMenu.MenuEvent(res? MKEY_MBYes : MKEY_MBNo, false);
					autoclose = 2;
				}
				else
				{
					autoclose = 2;
					if (res) SetMenu(mAction, -1);
				}
				if (!silent) { CloseSound(); }
			}
		}
		else
		{
			autoclose = 2;
			if (!silent) { CloseSound(); }
		}
	}

	void DrawFade()
	{
		screen.Dim(0x000000, fadealpha, 0, 0, screen.GetWidth(), screen.GetHeight());
	}

	void TickFade()
	{
		ticcount++;

		switch (curstate)
		{
			case 0:
				if (fadeintime)
				{
					fadealpha = fadealpha + abs(clamp(fadetargetalpha / fadeintime, -1.0, 1.0));
				}

				if (ticcount >= fadeintime || !fadeintime)
				{
					ticcount = 0; curstate++;
				}
				break;
			case 1:
				fadealpha = fadetargetalpha;

				if (ticcount >= 24)
				{
					ticcount = 0;
					curstate++;
				}
				break;
			default:
				if (fadeouttime)
				{
					fadealpha = fadealpha - abs(clamp(fadetargetalpha / fadeouttime, -1.0, 1.0));
				}

				if (ticcount >= fadeouttime || !fadeouttime)
				{
					if (fadealpha == 0)
					{
						fadetic = 0;
					}
				}
				break;
		}
	}

	static int GetSelection()
	{
		ClassicMessageBox msg = ClassicMessageBox(GetCurrentMenu());

		if (!msg) { return -1; }

		return msg.retval;
	}
}
