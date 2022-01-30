/*
 * Copyright (c) 2018-2022 AFADoomer
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

/*

	Helper function to translate HUD-style coordinates to screen-space coordinates so 
	that you can use Screen drawing functions to draw elements that align with the HUD.

	TranslatetoHUDCoordinates takes two parameters:
	- Vector2 of the HUD x/y coordinates that you want to position something at
	- Vector2 of the desired width/height of the image in HUD-scaled pixels

	The function returns two Vector2 values:
	- Vector2 of the x/y screen coordinates equivalent to the HUD coordinates passed in
	- Vector2 of the screen-scaled width/height of the image


	Also includes wrapper functions to draw textures and shape textures using the
	coordinate translation function (both draw the texture centered at the coords).
*/
class DrawToHUD
{
	// Scale coordinates and size to screen space, using rules simliar to the hud sizing/scaling rules
	static ui Vector2, Vector2, Vector2 TranslatetoHUDCoordinates(Vector2 pos, Vector2 tosize = (0, 0), Vector2 fromsize = (-1, -1))
	{
		// Scale the texture and coordinates to match the HUD elements
		Vector2 screenpos, screensize;
		Vector2 scale = Statusbar.GetHudScale();

		if (fromsize == (-1, -1))
		{
			fromsize = (Screen.GetWidth(), Screen.GetHeight());

			// Get the scale being used by the HUD code
			screensize.x = tosize.x * scale.x;
			screensize.y = tosize.y * scale.y;
		}
		else if (fromsize == (0, 0))
		{
			fromsize = (Screen.GetWidth(), Screen.GetHeight());

			// Get the scale being used by the Status Bar code
			double uiscale = BoAStatusBar.GetUIScale(st_scale);
			scale.x = fromsize.x / tosize.x;
			scale.y = fromsize.y / tosize.y;
			screensize = tosize * uiscale;
		}
		else
		{
			// Use the passed-in size
			scale.x = fromsize.x / tosize.x;
			scale.y = fromsize.y / tosize.y;
			screensize = tosize;
		}

		screenpos.x = pos.x * scale.x;
		screenpos.y = pos.y * scale.y;

		// Allow HUD coordinate-style positioning (not the decimal part, just that negatives mean offset from right/bottom)
		if (pos.x < 0) { screenpos.x += fromsize.x; }
		if (pos.y < 0) { screenpos.y += fromsize.y; }

		return screenpos, screensize, scale;
	}

	static ui void DrawText(String text, Vector2 pos, Font fnt = null, double alpha = 1.0, double textscale = 1.0, Vector2 destsize = (640, 480), color shade = -1, int flags = ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT)
	{
		if (!fnt) { fnt = SmallFont; }

		bool fullscreen = !(flags & ZScriptTools.STR_FIXED);

		// Scale the coordinates
		Vector2 screenpos, screensize, scale;
		Vector2 fromsize = fullscreen ? (-1, -1) : (0, 0);
		if (flags & ZScriptTools.STR_MENU) { fromsize = (CleanWidth_1, CleanHeight_1); }
		[screenpos, screensize, scale] = TranslatetoHUDCoordinates(pos, destsize, fromsize);

		scale *= textscale;

		double textw = fnt.StringWidth(text);
		double texth = fnt.GetHeight();

		if (text.IndexOf("[[") > -1 && text.IndexOf("]]") > -1)
		{
			String line = text;
			int totalwidth = 0;

			while (line.length())
			{
				int buttonstart = line.IndexOf("[[");
				int buttonend = line.IndexOf("]]", buttonstart);

				if (buttonend > -1 && buttonstart > -1)
				{
					String cmd = line.Mid(buttonstart + 2, buttonend - buttonstart - 2);
					bool valid = true;
					int buttonwidth = 0;
					[buttonwidth, valid] = DrawCommandButtons((0, 0), cmd, 0.0, destsize, 1.0, Button.BTN_CALC | (fullscreen ? 0 : Button.BTN_FIXED));

					String keystring = "";
					if (!valid)
					{
						keystring = ACSTools.GetKeyPressString(cmd, true, "Dark Gray", "Gray", "Red");
						text.Replace("[[" .. cmd .. "]]", "[[" .. cmd .. "]] " .. keystring);
					}

					totalwidth += int(SmallFont.StringWidth(line.left(buttonstart) .. keystring) + buttonwidth);

					line = line.mid(buttonend + 2);
				}
				else
				{
					totalwidth += SmallFont.StringWidth(line);
					line = "";
				}
			}

			textw = totalwidth;
			texth = max(20, fnt.GetHeight());
		}

		if (flags & ZScriptTools.STR_RIGHT)
		{
			pos.x -= textw;
			screenpos.x -= textw * scale.x;
		}
		else if (flags & ZScriptTools.STR_CENTERED)
		{
			pos.x -= textw / 2;
			screenpos.x -= textw * scale.x / 2;
		}

		if (flags & ZScriptTools.STR_BOTTOM)
		{
			pos.y -= texth;
			screenpos.y -= texth * scale.y;
		}
		else if (flags & ZScriptTools.STR_MIDDLE)
		{
			pos.y -= texth / 2;
			screenpos.y -= texth * scale.y / 2;
		}

		if (text.IndexOf("[[") > -1 && text.IndexOf("]]") > -1)
		{
			int lineoffset = 0;

			String line = text;
			while (line.length())
			{
				int buttonstart = line.IndexOf("[[");
				int buttonend = line.IndexOf("]]", buttonstart);

				if (buttonend > -1 && buttonstart > -1)
				{
					String segment = line.left(buttonstart);
					screen.DrawText(fnt, shade, int(screenpos.x + lineoffset * scale.x), int(screenpos.y), segment, DTA_KeepRatio, true, DTA_Alpha, alpha, DTA_ScaleX, scale.x, DTA_ScaleY, scale.y);
					lineoffset += SmallFont.StringWidth(segment);

					String cmd = line.Mid(buttonstart + 2, buttonend - buttonstart - 2);
					lineoffset += DrawCommandButtons((pos.x + lineoffset, pos.y + SmallFont.GetHeight() / 2), cmd, alpha, destsize, textscale, Button.BTN_MIDDLE | (fullscreen ? 0 : Button.BTN_FIXED));

					line = line.mid(buttonend + 2);
				}
				else
				{
					screen.DrawText(fnt, shade, int(screenpos.x + lineoffset * scale.x), int(screenpos.y), line, DTA_KeepRatio, true, DTA_Alpha, alpha, DTA_ScaleX, scale.x, DTA_ScaleY, scale.y);
					line = "";
				}
			}
		}
		else
		{
			screen.DrawText(fnt, shade, int(screenpos.x), int(screenpos.y), text, DTA_KeepRatio, true, DTA_Alpha, alpha, DTA_ScaleX, scale.x, DTA_ScaleY, scale.y);
		}
	}

	enum DrawTex
	{
		TEX_DEFAULT = 0, // Draw with normal offset (from top left)
		TEX_USEOFFSETS = 0, // "
		TEX_CENTERED = 1, // Draw with centered offsets (default)
		TEX_COLOROVERLAY = 2, // Overlay color instead of using the texture as an alpha channel
		TEX_FIXED = 4, // Draw in status bar coordinates
		TEX_MENU = 8, // Draw in menu coordinates
	};

	static ui void DrawTexture(TextureID tex, Vector2 pos, double alpha = 1.0, double texscale = 1.0, color shade = -1, Vector2 desttexsize = (-1, -1), int flags = TEX_CENTERED, Vector2 destsize = (-1, -1))
	{
		bool fullscreen = !(flags & TEX_FIXED);

		// Scale the coordinates
		Vector2 screenpos, screensize, scale;
		Vector2 fromsize = fullscreen ? (-1, -1) : (0, 0);
		if (flags & TEX_MENU) { fromsize = (CleanWidth_1, CleanHeight_1); }
		[screenpos, screensize, scale] = TranslatetoHUDCoordinates(pos, destsize, fromsize);

		if (desttexsize == (-1, -1)) { desttexsize = TexMan.GetScaledSize(tex); }
		desttexsize *= texscale;

		bool alphachannel;
		color fillcolor;

		if (shade > 0)
		{
			if (!(flags & TEX_COLOROVERLAY)) { alphachannel = true; }
			fillcolor = shade & 0xFFFFFF;
		}

		// Draw the texture
		if (flags & TEX_CENTERED) { screen.DrawTexture(tex, true, screenpos.x, screenpos.y, DTA_DestWidth, int(desttexsize.x), DTA_DestHeight, int(desttexsize.y), DTA_Alpha, alpha, DTA_CenterOffset, true, DTA_AlphaChannel, alphachannel, DTA_FillColor, shade, DTA_ScaleX, scale.x, DTA_ScaleY, scale.y); }
		else { screen.DrawTexture(tex, true, screenpos.x, screenpos.y, DTA_DestWidth, int(desttexsize.x), DTA_DestHeight, int(desttexsize.y), DTA_Alpha, alpha, DTA_TopOffset, 0, DTA_LeftOffset, 0, DTA_AlphaChannel, alphachannel, DTA_FillColor, shade, DTA_ScaleX, scale.x, DTA_ScaleY, scale.y); }
	}

	static ui void DrawTransformedTexture(TextureID tex, Vector2 pos, double alpha = 1.0, double ang = 0, double scale = 1.0, color shade = -1, int cliptop = 0, int clipleft = 0, int clipbottom = 0x7FFFFFFF, int clipright = 0x7FFFFFFF, int flags = TEX_DEFAULT)
	{
		bool fullscreen = !(flags & TEX_FIXED);

		// Scale the coordinates
		Vector2 screenpos, screensize;
		Vector2 texsize = TexMan.GetScaledSize(tex);
		Vector2 fromsize = fullscreen ? (-1, -1) : (0, 0);
		if (flags & TEX_MENU) { fromsize = (CleanWidth_1, CleanHeight_1); }
		[screenpos, screensize] = TranslatetoHUDCoordinates(pos, texsize * scale, fromsize);

		bool alphachannel;
		color fillcolor;

		if (shade > 0)
		{
			alphachannel = true;
			fillcolor = shade & 0xFFFFFF;
		}

		// Scale the clipping coordinates
		Vector2 hudscale = StatusBar.GetHudScale();
		if (cliptop) { cliptop = int(cliptop * hudscale.y); }
		if (cliptop < 0) { cliptop += Screen.GetHeight(); }
		if (clipbottom < 0x7FFFFFFF) { clipbottom = int(clipbottom * hudscale.y); }
		if (clipbottom < 0) { clipbottom += Screen.GetHeight(); }
		if (clipleft) { clipleft = int(clipleft * hudscale.x); }
		if (clipleft < 0) { clipleft += Screen.GetWidth(); }
		if (clipright < 0x7FFFFFFF) { clipright = int(clipright * hudscale.x); }
		if (clipright < 0) { clipright += Screen.GetWidth(); }

		// Draw rotated texture
		Screen.DrawTexture(tex, true, screenpos.x, screenpos.y, DTA_CenterOffset, true, DTA_Rotate, -ang, DTA_DestWidth, int(screensize.x), DTA_DestHeight, int(screensize.y), DTA_Alpha, alpha, DTA_AlphaChannel, alphachannel, DTA_FillColor, shade, DTA_ClipTop, cliptop, DTA_ClipLeft, clipleft, DTA_ClipBottom, clipbottom, DTA_ClipRight, clipright);
	}

	static ui void Dim(Color clr = 0x000000, double alpha = 0.5, double x = 0, double y = 0, double w = -1, double h = -1, Vector2 destsize = (-1, -1), int flags = TEX_DEFAULT)
	{
		bool fullscreen = !(flags & TEX_FIXED);

		if (w == -1) { w = Screen.GetWidth(); }
		if (h == -1) { h = Screen.GetHeight(); }

		// Scale the coordinates
		Vector2 screenpos, screensize, scale;
		Vector2 fromsize = fullscreen ? (-1, -1) : (0, 0);
		if (flags & TEX_MENU) { fromsize = (CleanWidth_1, CleanHeight_1); }
		[screenpos, screensize, scale] = TranslatetoHUDCoordinates((x, y), destsize, fromsize);

		w *= scale.x;
		h *= scale.y;

		// If positioned via a negative coordinate, but full width of dim would extend off of the
		// screen, assume that the dimmed area was supposed to be located on the opposite site
		// of the screen and recalculate values to crop the dim to the left or top side of the screen
		if (x < 0 && screenpos.x + w > Screen.GetWidth())
		{
			w = screenpos.x + w - Screen.GetWidth();
			screenpos.x = 0;
		}

		if (y < 0 && screenpos.y + h > Screen.GetHeight())
		{
			h = screenpos.y + h - Screen.GetHeight();
			screenpos.y = 0;
		}

		// Crop to the screen size
		if (screenpos.x + w > Screen.GetWidth()) { w = screenpos.x + w - Screen.GetWidth(); }
		if (screenpos.y + h > Screen.GetHeight()) { h = screenpos.y + h - Screen.GetHeight(); }

		Screen.Dim(clr, alpha, int(round(screenpos.x)), int(round(screenpos.y)), int(round(w)), int(round(h)));
	}

	static ui void DrawThickLine(int x0, int y0, int x1, int y1, double thickness, Color clr, double alpha = 1.0, int flags = TEX_DEFAULT)
	{
		bool fullscreen = !(flags & TEX_FIXED);

		// Scale the coordinates
		Vector2 screenpos, screensize;
		Vector2 fromsize = fullscreen ? (-1, -1) : (0, 0);
		if (flags & TEX_MENU) { fromsize = (CleanWidth_1, CleanHeight_1); }
		[screenpos, screensize] = TranslatetoHUDCoordinates((x0, y0), (x1, y1), fromsize);

		Screen.DrawThickLine(int(screenpos.x), int(screenpos.y), int(screensize.x), int(screensize.y), thickness, clr, int(alpha * 255));
	}

	static ui void DrawLineFrame(Color clr, int x, int y, int w, int h, double thickness = 1, double alpha = 1.0, int flags = TEX_DEFAULT)
	{
		bool fullscreen = !(flags & TEX_FIXED);

		// Scale the coordinates
		Vector2 screenpos, screensize;
		Vector2 fromsize = fullscreen ? (-1, -1) : (0, 0);
		if (flags & TEX_MENU) { fromsize = (CleanWidth_1, CleanHeight_1); }
		[screenpos, screensize] = TranslatetoHUDCoordinates((x, y), (w, h), fromsize);

		// Native function doesn't work from status bar code?
		//Screen.DrawLineFrame(clr, int(screenpos.x), int(screenpos.y), int(screensize.x), int(screensize.y), thickness);

		// So do it ourselves...
		int left = int(screenpos.x);
		int right = left + int(screensize.x);
		int top = int(screenpos.y);
		int bottom = top + int(screensize.y);

		Vector2 hudscale = Statusbar.GetHudScale();
		thickness *= hudscale.x;

		int offset = int(thickness / 2);

		// Draw top and bottom sides.
		Screen.DrawThickLine(left - offset, top, right + offset, top, thickness, clr, int(alpha * 255));
		Screen.DrawThickLine(right, top - offset, right, bottom + offset, thickness, clr, int(alpha * 255));
		Screen.DrawThickLine(left - offset, bottom, right + offset, bottom, thickness, clr, int(alpha * 255));
		Screen.DrawThickLine(left, top - offset, left, bottom + offset, thickness, clr, int(alpha * 255));
	}

	static ui void DrawFrame(String prefix, int x, int y, double w, double h, color fillclr = 0x0, double alpha = 1.0, double fillalpha = -1, Vector2 destsize = (-1, -1), int flags = TEX_DEFAULT)
	{
		bool fullscreen = !(flags & TEX_FIXED);
		
		TextureID top = TexMan.CheckForTexture(prefix .. "T");
		TextureID bottom = TexMan.CheckForTexture(prefix .. "B");
		TextureID left = TexMan.CheckForTexture(prefix .. "L");
		TextureID right = TexMan.CheckForTexture(prefix .. "R");
		TextureID topleft = TexMan.CheckForTexture(prefix .. "TL");
		TextureID topright = TexMan.CheckForTexture(prefix .. "TR");
		TextureID bottomleft = TexMan.CheckForTexture(prefix .. "BL");
		TextureID bottomright = TexMan.CheckForTexture(prefix .. "BR");

		if (!top || !bottom || !left || !right || !topleft || !topright || !bottomleft || !bottomright) { return; }

		Vector2 size = TexMan.GetScaledSize(top);
		int cellwidth = int(size.x);
		int cellheight = int(size.y);

		if (flags & TEX_MENU)
		{
			cellwidth = int(cellwidth * CleanXfac_1);
			cellheight = int(cellheight * CleanYfac_1);
		}

		if (fillalpha == -1) { fillalpha = alpha; }

		DrawToHUD.Dim(fillclr, fillalpha, x + cellwidth / 2.0, y + cellheight / 2.0, w - cellwidth, h - cellheight, destsize, flags);

		int texflags =  TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED) | (flags & TEX_MENU ? TEX_MENU : 0);

		DrawToHUD.DrawTexture(top, (x + w / 2, y), alpha, 1.0, -1, (w - cellwidth, cellheight), texflags, destsize);
		DrawToHUD.DrawTexture(bottom, (x + w / 2, y + h), alpha, 1.0, -1, (w - cellwidth, cellheight), texflags, destsize);
		DrawToHUD.DrawTexture(left, (x, y + h / 2), alpha, 1.0, -1, (cellwidth, h - cellheight), texflags, destsize);
		DrawToHUD.DrawTexture(right, (x + w, y + h / 2), alpha, 1.0, -1, (cellwidth, h - cellheight), texflags, destsize);

		DrawToHUD.DrawTexture(topleft, (x, y), alpha, 1.0, -1, (cellwidth, cellheight), texflags, destsize);
		DrawToHUD.DrawTexture(topright, (x + w, y), alpha, 1.0, -1, (cellwidth, cellheight), texflags, destsize);
		DrawToHUD.DrawTexture(bottomleft, (x, y + h), alpha, 1.0, -1, (cellwidth, cellheight), texflags, destsize);
		DrawToHUD.DrawTexture(bottomright, (x + w, y + h), alpha, 1.0, -1, (cellwidth, cellheight), texflags, destsize);
	}

	static ui void DrawTimer(int time, int maxtime, Color clr, Vector2 pos = (0, 0), double scale = 1.0, double alpha = 1.0, String bkg = "STATUSB", String border = "STATUSO")
	{
		TextureID fill = TexMan.CheckForTexture("STATUSF");
		TextureID back = TexMan.CheckForTexture(bkg);
		TextureID border = TexMan.CheckForTexture(border);

		// Snap draw coordinates to integers for clean scaling;
		pos.x = int(pos.x);
		pos.y = int(pos.y);

		if (back.IsValid()) { DrawToHud.DrawTexture(back, pos, alpha, scale); }

		if (fill.IsValid() && time < 0x7FFFFFFF)  // Don't draw amount indicators for infinite powerups
		{
			double angle = 360.0 * time / maxtime;

			int quads = int(angle / 90);

			for (int q = quads; q > 0; q--)
			{
				DrawToHud.DrawTransformedTexture(fill, pos, alpha, (90 * q - 1) - 90, scale, clr);
			}

			int top = 0, left = 0, bottom = 0x7FFFFFFF, right = 0x7FFFFFFF;

			switch (quads % 4)
			{
				case 3:
					bottom = int(pos.y);
					break;
				case 2:
					right = int(pos.x);
					break;
				case 1:
					top = int(pos.y);
					break;
				default:
					left = int(pos.x);
					break;
			}

			DrawToHud.DrawTransformedTexture(fill, pos, alpha, angle - 90, scale, clr, top, left, bottom, right);
		}

		if (border.IsValid()) { DrawToHud.DrawTexture(border, pos, alpha, scale); }
	}

	static ui int, bool DrawCommandButtons(Vector2 pos, String command, double alpha = 1.0, Vector2 destsize = (-1, -1), double buttonscale = 1.0, int flags = Button.BTN_MIDDLE, KeyBindings binds = null)
	{
		if (!command.length()) { return 0, false; }
		if (!binds) { binds = Bindings; }

		Font KeyLabelFont = Font.GetFont("Minifont");
		Font KeyPromptFont = Font.GetFont("KeyPrompts");

		// Define separator strings
		String comma = ",";
		String or = StringTable.Localize("$WORD_OR");
		int commasize =  SmallFont.StringWidth(comma);
		int orsize = SmallFont.StringWidth(or);

		int width, totalwidth;

		Array<int> keycodes;
		Array<String> keys;
		Array<Button> buttons;

		bool ret = true;

		// Look up key binds for the passed-in command
		binds.GetAllKeysForCommand(keycodes, command);

		if (!keycodes.Size())
		{
			if (command.left(4) ~== "key:")
			{
				command = command.mid(4);
				
				// Special name to print left and right arrow keys
				if (command ~== "LeftRightArrows")
				{
					keycodes.Push(0);
					keys.Push("LeftArrow");
					keycodes.Push(0);
					keys.Push("RightArrow");
				}
				else
				{
					keycodes.Push(0);
					keys.Push(command);
				}
			}
			else
			{
				keycodes.Push(-1);
				keys.Push("?");
				ret = false;
			}
		}
		else
		{
			// Get the key names for each bound key, and parse them into a lookup array
			String keynames = binds.NameAllKeys(keycodes);
			keynames = ZScriptTools.StripColorCodes(keynames);
			keynames.Split(keys, ", ");
		}

		// Iterate through the keys in the array to generate button data and handle key-specific
		// visual tweaks (label lookups, size changes, icon selection, etc.)
		for (int k = 0; k < keys.Size(); k++)
		{
			// Set the default frame/button background to look like a pixel-art physical key
			String bkg = "BU_";
			double bkgalpha = 1.0;
			double bkgfillalpha = 1.0;
			int fntcolor = Font.FindFontColor("TrueBlack");
			color fillcolor = 0x989898;
			int margin = int(4 * buttonscale);
			String label = keys[k];
			String icon = "";

			// Dynamically build "pretty" label strings for non-keyboard binds and assign device-
			// specific icons as appropriate for each input type
			if ( // Mouse
				(keycodes[k] >= 0x100 && keycodes[k] < 0x108) ||
				(keycodes[k] >= 0x198 && keycodes[k] < 0x19B)
			)
			{
				icon = "BU_MOUSE";

				if (keycodes[k] >= 0x100 && keycodes[k] < 0x108) // Standard buttons
				{
					if (keycodes[k] < 0x102)
					{
						CVar swapbuttons = CVar.FindCvar("m_swapbuttons");
						if (swapbuttons && swapbuttons.GetBool())
						{
							// Handle button swapping via cvar
							if (keycodes[k] == 0x100) { keycodes[k] = 0x101; }
							else if (keycodes[k] == 0x101) { keycodes[k] = 0x100; }
						}
					}

					// Generate the label from the "Mouse Button" string and the number of the button
					label = StringTable.Localize("$KEY_Mouse") .. " " .. keycodes[k] - 0x0FF;
				}
				else if (keycodes[k] >= 0x198 && keycodes[k] < 0x19B) // Wheel
				{
					// Generate the label from the "Mouse Wheel" string and the number of the button
					int index = keycodes[k] - 0x198;

					String direction = "";
					switch(index)
					{
						case 0:
							direction = StringTable.Localize("$WORD_UP");
						break;
						case 1:
							direction = StringTable.Localize("$WORD_DOWN");
						break;
						case 2:
							direction = StringTable.Localize("$WORD_RIGHT");
						break;
						case 3:
							direction = StringTable.Localize("$WORD_LEFT");
						break;
					}

					label = StringTable.Localize("$KEY_MouseWheel") .. " " .. direction;
				}
			}
			else if ( // Joystick
				(keycodes[k] >= 0x108 && keycodes[k] <= 0x197) ||
				(keycodes[k] >= 0x19C && keycodes[k] <= 0x1AB)
			)
			{
				icon = "BU_JOY";
				fntcolor = Font.CR_WHITE;

				if (keycodes[k] >= 0x108 && keycodes[k] <= 0x187)
				{
					// Generate the label from the "Joystick Button" string and the number of the button
					label = StringTable.Localize("$KEY_Joystick") .. " " .. keycodes[k] - 0x107;
				}
				else if (keycodes[k] >= 0x188 && keycodes[k] <= 0x197) // Joystick POV Hat
				{
					// Generate the label from the "Joystick POV Hat" string and the number and direction of the button
					int index = keycodes[k] - 0x188;
					int hat = 1 + index / 4;
					int dir = index % 4;

					String direction = "";
					switch(dir)
					{
						case 0:
							direction = StringTable.Localize("$WORD_UP");
						break;
						case 1:
							direction = StringTable.Localize("$WORD_RIGHT");
						break;
						case 2:
							direction = StringTable.Localize("$WORD_DOWN");
						break;
						case 3:
							direction = StringTable.Localize("$WORD_LEFT");
						break;
					}

					label = StringTable.Localize("$KEY_JoystickHat") .. " " .. hat .. " " .. direction;
				}
				else if (keycodes[k] >= 0x19C && keycodes[k] <= 0x1AB) // Joystick Axis
				{
					// Generate the label from the "Joystick Axis" string and the number and direction of the button
					int index = keycodes[k] - 0x19C;
					int axis = 1 + index / 2;
					int dir = index % 2;

					String direction = "";
					switch(dir)
					{
						case 0:
							direction = "+";
						break;
						case 1:
							direction = "-";
						break;
					}

					label = StringTable.Localize("$KEY_JoystickAxis") .. " " .. axis .. " " .. direction;
				}
			}
			else if (keycodes[k] >= 0x108) // Game pad
			{
				icon = "BU_PAD";
			}

			// Allow key names to be translated by prefixing them with KEY_ (e.g., "KEY_Mouse2", "KEY_Ctrl")
			// and defining the appropriate entry in the LANGUAGE lump.  This also allows defining more
			// aesthetic names for keys (e.g., in BoA KEY_PAD_START will show "Start" instead of "Pad_Start")
			// These override generated names 
			String prettylabel = StringTable.Localize("$KEY_" .. keys[k]);
			if (!(prettylabel == "KEY_" .. keys[k])) { label = prettylabel; }

			// Use alternate background style for non-keyboard key binds (mouse, joystick, gamepad)
			if (keycodes[k] >= 0x100)
			{
				bkg = "BU_D_";
				fntcolor = Font.CR_GRAY;
				fillcolor = 0x78809A;
				margin = int(2 * buttonscale);
			}
			else if (keycodes[k] == -1) // and for errors
			{
				bkg = "BU_R_";
				fntcolor = Font.CR_WHITE;
				fillcolor = 0x722626;
			}

			// Create the button object for the key bind
			Button b;
			if (KeyPromptFont.GetGlyphHeight(keycodes[k])) // If there's a dedicated key prompt graphic, use it
			{
				b = Button.Create(String.Format("%c", keycodes[k]), KeyPromptFont, "", buttonscale, "");
				if (b)
				{
					b.width = int(16 * buttonscale);
					b.height = int(16 * buttonscale);
					b.labeloffset = b.width / 2;
				}
			}
			else
			{
				// Add characters to the label names for some key binds so that they better reflect
				// the physical key that they are meant to represent
				if (keys[k] == "Enter") { label = label .. " ⏎"; }
				else if (keys[k] == "Tab") { label = label .. " ⭾"; }
				else if (keys[k] == "Shift" || keys[k] == "RShift") { label = "⇧ " .. label; }
				else if (keys[k] == "Backspace") { label = "← " .. label; }
				else if (keys[k] == "LWin" || keys[k] == "RWin") { label = "⊞"; }
				else if (keys[k] == "Command") { label = "⌘"; }
				else if (keys[k] == "LeftArrow") { label = "◂"; }
				else if (keys[k] == "RightArrow") { label = "▸"; }
				else if (keys[k] == "UpArrow") { label = "▴"; }
				else if (keys[k] == "DownArrow") { label = "▾"; }
				
				b = Button.Create(label, KeyLabelFont, icon, buttonscale, bkg, fntcolor, fillcolor, margin, bkgalpha, bkgfillalpha);

				// Make the space bar wide so that it closer matches actual space bar width
				if (b && keys[k] == "Space")
				{
					b.width = max(int(96 * buttonscale), b.width);
					b.labeloffset = b.width / 2;
				}
			}

			if (b)
			{
				// Add the generated button to the array of buttons for this key bind
				buttons.Push(b);

				// Calculate total width of the drawn buttons, including separators ("," and "or")
				totalwidth += b.width;
				if (k < keys.Size() - 2) { totalwidth += int((commasize + 6) * b.scale.x); }
				else if (k == keys.Size() - 2) { totalwidth += int((orsize + 12) * b.scale.x); }
			}
		}

		// Return early if we're just getting the width
		if (flags & Button.BTN_CALC) { return totalwidth, ret; }

 		// Allow the BTN_CENTERED flag to be passed to center the whole set of buttons, but strip
		// it so it doesn't pass on to the individual buttons and try to center them as well.
		if (flags & Button.BTN_CENTERED) { pos.x -= totalwidth / 2; }
		flags &= ~Button.BTN_CENTERED;

		// Iterate through buttons and draw each one, as well as separators as appropriate
		for (int i = 0; i < buttons.Size(); i++)
		{
			Button b = buttons[i];

			b.Draw(pos, alpha, destsize, flags);

			pos.x += b.width + int(6 * b.scale.x);

			int textflags = ZScriptTools.STR_MIDDLE | ZScriptTools.STR_CENTERED | (flags & Button.BTN_FIXED ? ZScriptTools.STR_FIXED : 0) | (flags & Button.BTN_MENU ? ZScriptTools.STR_MENU : 0);

			// Use "," to separate all but the final button, then use "or" for the last one
			if (i < buttons.Size() - 2) // ","
			{
				pos.x += int((commasize / 2 - 6) * b.scale.x);
				DrawToHUD.DrawText(comma, pos, SmallFont, alpha, b.scale.x, destsize, Font.CR_GRAY, textflags);
				pos.x += int((commasize / 2 + 6) * b.scale.x);
			}
			else if (i == buttons.Size() - 2) // "or"
			{
				pos.x += int((orsize / 2) * b.scale.x);
				DrawToHUD.DrawText(or, pos, SmallFont, alpha, b.scale.x, destsize, Font.CR_GRAY, textflags);
				pos.x += int((orsize / 2 + 6) * b.scale.x);
			}
		}

		return totalwidth, ret;
	}
}

class Button
{
	String label;
	Font fnt;
	TextureID icon;
	int width;
	int height;
	int iconoffset;
	int labeloffset;
	Vector2 scale;
	String bkg;
	double bkgalpha;
	double bkgfillalpha;
	int fntcolor;
	color fillcolor;

	static ui Button Create(String label, Font fnt, String icon = "", double buttonscale = 1.0, String bkg = "BU_", int fntcolor = Font.CR_UNTRANSLATED, color fillcolor = 0x989898, int margin = 4, double bkgalpha = 1.0, double bkgfillalpha = 1.0)
	{
		if (!label.length() && !icon.length()) { return null; }

		Vector2 scale = (1.0, 1.0) * buttonscale;

		int height = Button.GetHeight(fnt, buttonscale, margin, 16);

		int width = height;
		if (label.length() > 1) { width = max(height, int(fnt.StringWidth(label) * scale.x + (margin * 2 + 4) * scale.x) + 1); }

		int labeloffset = width / 2;
		int iconoffset = 0;

		TextureID icontex = TexMan.CheckForTexture(icon);
		if (icontex && icontex.IsValid())
		{
			Vector2 iconsize = TexMan.GetScaledSize(icontex);
			int iconwidth = int((iconsize.x * 0.5 + margin) * scale.x);
			width += iconwidth;
			labeloffset += iconwidth;
			iconoffset = iconwidth / 2;
		}

		Button b = New("Button");

		if (b)
		{
			b.label = label;
			b.fnt = fnt;
			b.icon = icontex;
			b.width = width;
			b.height = height;
			b.labeloffset = labeloffset;
			b.iconoffset = iconoffset;
			b.scale = scale;
			b.bkg = bkg;
			b.bkgalpha = bkgalpha;
			b.bkgfillalpha = bkgfillalpha;
			b.fntcolor = fntcolor;
			b.fillcolor = fillcolor;
		}

		return b;
	}

	static ui int GetHeight(Font fnt = null, double scale = 1.0, int margin = 4, int minheight = 16)
	{
		if (!fnt) { fnt = Font.GetFont("MiniFont"); }
		if (!fnt) { fnt = SmallFont; }
		
		return max(int(minheight * scale), int(fnt.GetHeight() * scale + margin * 2 * scale));
	}

	enum DrawButtons
	{
		BTN_DEFAULT = 0,
		BTN_CENTERED = 1, // Draw centered at coords
		BTN_MIDDLE = 2, // Draw centered vertically at coords
		BTN_FIXED = 4, // Draw in status bar coordinates
		BTN_MENU = 8, // Draw in menu coordinates
		BTN_CALC = 16, // For command button lists; calculate size, but don't draw
	};

	ui void Draw(Vector2 pos, double alpha = 1.0, Vector2 destsize = (-1, -1), int flags = BTN_DEFAULT)
	{
		if (destsize != (-1, -1) && (flags & BTN_MENU))
		{
			Vector2 screenscale = (CleanXfac_1, CleanYfac_1);

			if (flags & BTN_CENTERED) { pos.x -= width * screenscale.x / 2; }
			if (flags & BTN_MIDDLE) { pos.y -= height * screenscale.y / 2; }

			width = int(width * screenscale.x);
			height = int(height * screenscale.y);
			scale.x *= screenscale.x;
			scale.y *= screenscale.y;
			labeloffset = int(labeloffset * screenscale.x);
			iconoffset = int(iconoffset * screenscale.x);
		}
		else
		{
			if (flags & BTN_CENTERED) { pos.x -= width / 2; }
			if (flags & BTN_MIDDLE) { pos.y -= height / 2; }
		}

		bkgalpha *= alpha;
		bkgfillalpha *= bkgalpha;

		if (bkg.length()) { DrawToHUD.DrawFrame(bkg, int(pos.x), int(pos.y), width, height, fillcolor, bkgalpha, bkgfillalpha, destsize, (flags & BTN_FIXED ? DrawToHUD.TEX_FIXED : 0) | (flags & BTN_MENU ? DrawToHUD.TEX_MENU : 0)); }
		if (icon && icon.IsValid()) { DrawToHud.DrawTexture(icon, (pos.x + iconoffset, pos.y + height / 2), alpha, 0.5 * scale.x, -1, (-1, -1), DrawToHUD.TEX_CENTERED | (flags & BTN_FIXED ? DrawToHUD.TEX_FIXED : 0) | (flags & BTN_MENU ? DrawToHUD.TEX_MENU : 0), destsize); }
		DrawToHUD.DrawText(label, (pos.x + labeloffset, pos.y + height / 2), fnt, alpha, scale.x, destsize, fntcolor, ZScriptTools.STR_MIDDLE | ZScriptTools.STR_CENTERED | (flags & BTN_FIXED ? ZScriptTools.STR_FIXED : 0) | (flags & BTN_MENU ? ZScriptTools.STR_MENU : 0));
	}
}