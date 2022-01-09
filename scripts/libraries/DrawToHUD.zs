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
			scale = Statusbar.GetHudScale();
			screensize.x = tosize.x * scale.x;
			screensize.y = tosize.y * scale.y;
		}
		else if (fromsize == (0, 0))
		{
			double uiscale = BoAStatusBar.GetUIScale(st_scale);
			fromsize = (Screen.GetWidth(), Screen.GetHeight());
			scale.x = fromsize.x / tosize.x;
			scale.y = fromsize.y / tosize.y;
			screensize = tosize * uiscale;
		}
		else
		{
			double uiscale = BoAStatusBar.GetUIScale(st_scale);
			scale.x = fromsize.x / tosize.x;
			scale.y = fromsize.y / tosize.y;
			screensize = tosize * uiscale;
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
		[screenpos, screensize, scale] = TranslatetoHUDCoordinates(pos, destsize * textscale, (fullscreen ? (-1, -1) : (0, 0)));

		double textw = fnt.StringWidth(text) * scale.x;
		double texth = fnt.GetHeight() * scale.y;

		if (flags & ZScriptTools.STR_RIGHT) { screenpos.x -= textw; }
		else if (flags & ZScriptTools.STR_CENTERED) { screenpos.x -= textw / 2; }

		if (flags & ZScriptTools.STR_BOTTOM) { screenpos.y -= texth; }
		else if (flags & ZScriptTools.STR_MIDDLE) { screenpos.y -= texth / 2; }

		// Draw the text
		screen.DrawText(fnt, shade, int(screenpos.x), int(screenpos.y), text, DTA_KeepRatio, true, DTA_Alpha, alpha, DTA_ScaleX, scale.x, DTA_ScaleY, scale.y);
	}

	enum DrawTex
	{
		TEX_DEFAULT = 0, // Draw with normal offset (from top left)
		TEX_USEOFFSETS = 0, // "
		TEX_CENTERED = 1, // Draw with centered offsets (default)
		TEX_COLOROVERLAY = 2, // Overlay color instead of using the texture as an alpha channel
		TEX_FIXED = 4, // Draw in status bar coordinates
	};

	static ui void DrawTexture(TextureID tex, Vector2 pos, double alpha = 1.0, double texscale = 1.0, color shade = -1, Vector2 desttexsize = (-1, -1), int flags = TEX_CENTERED, Vector2 destsize = (-1, -1))
	{
		bool fullscreen = !(flags & TEX_FIXED);

		// Scale the coordinates
		Vector2 screenpos, screensize, scale;
		[screenpos, screensize, scale] = TranslatetoHUDCoordinates(pos, destsize, (fullscreen ? (-1, -1) : (0, 0)));

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

	static ui void DrawTransformedTexture(TextureID tex, Vector2 pos, double alpha = 1.0, double ang = 0, double scale = 1.0, color shade = -1, int cliptop = 0, int clipleft = 0, int clipbottom = 0x7FFFFFFF, int clipright = 0x7FFFFFFF)
	{
		// Scale the coordinates
		Vector2 screenpos, screensize;
		Vector2 texsize = TexMan.GetScaledSize(tex);
		[screenpos, screensize] = TranslatetoHUDCoordinates(pos, texsize * scale);

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

	static ui void Dim(Color clr = 0x000000, double alpha = 0.5, double x = 0, double y = 0, double w = -1, double h = -1, Vector2 destsize = (-1, -1))
	{
		if (w == -1) { w = Screen.GetWidth(); }
		if (h == -1) { h = Screen.GetHeight(); }

		bool fullscreen = (destsize == (-1, -1));

		// Scale the coordinates
		Vector2 screenpos, screensize, scale;
		[screenpos, screensize, scale] = TranslatetoHUDCoordinates((x, y), destsize, (fullscreen ? (-1, -1) : (0, 0)));

		w *= scale.x;
		h *= scale.y;

		Screen.Dim(clr, alpha, int(round(screenpos.x)), int(round(screenpos.y)), int(round(w)), int(round(h)));
	}

	static ui void DrawThickLine(int x0, int y0, int x1, int y1, double thickness, Color clr, double alpha = 1.0)
	{
		// Scale the coordinates
		Vector2 screenpos, screensize;
		[screenpos, screensize] = TranslatetoHUDCoordinates((x0, y0), (x1, y1));

		Screen.DrawThickLine(int(screenpos.x), int(screenpos.y), int(screensize.x), int(screensize.y), thickness, clr, int(alpha * 255));
	}

	static ui void DrawLineFrame(Color clr, int x, int y, int w, int h, double thickness = 1, double alpha = 1.0)
	{
		// Scale the coordinates
		Vector2 screenpos, screensize;
		[screenpos, screensize] = TranslatetoHUDCoordinates((x, y), (w, h));

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

	static ui void DrawFrame(String prefix, int x, int y, double w, double h, color fillclr = 0x0, double alpha = 1.0, double fillalpha = -1, Vector2 destsize = (-1, -1))
	{
		TextureID top = TexMan.CheckForTexture(prefix .. "T");
		TextureID bottom = TexMan.CheckForTexture(prefix .. "B");
		TextureID left = TexMan.CheckForTexture(prefix .. "L");
		TextureID right = TexMan.CheckForTexture(prefix .. "R");
		TextureID topleft = TexMan.CheckForTexture(prefix .. "TL");
		TextureID topright = TexMan.CheckForTexture(prefix .. "TR");
		TextureID bottomleft = TexMan.CheckForTexture(prefix .. "BL");
		TextureID bottomright = TexMan.CheckForTexture(prefix .. "BR");

		if (!top || !bottom || !left || !right || !topleft || !topright || !bottomleft || !bottomright) { return; }

		bool fullscreen = (destsize == (-1, -1));

		Vector2 size = TexMan.GetScaledSize(top);
		int cellwidth = int(size.x);
		int cellheight = int(size.y);

		if (fillalpha == -1) { fillalpha = alpha; }

		DrawToHUD.Dim(fillclr, fillalpha, x + cellwidth / 2.0, y + cellheight / 2.0, w - cellwidth, h - cellheight, destsize);

		DrawToHUD.DrawTexture(top, (x + w / 2, y), alpha, 1.0, -1, (w - cellwidth, cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);
		DrawToHUD.DrawTexture(bottom, (x + w / 2, y + h), alpha, 1.0, -1, (w - cellwidth, cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);
		DrawToHUD.DrawTexture(left, (x, y + h / 2), alpha, 1.0, -1, (cellwidth, h - cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);
		DrawToHUD.DrawTexture(right, (x + w, y + h / 2), alpha, 1.0, -1, (cellwidth, h - cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);

		DrawToHUD.DrawTexture(topleft, (x, y), alpha, 1.0, -1, (cellwidth, cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);
		DrawToHUD.DrawTexture(topright, (x + w, y), alpha, 1.0, -1, (cellwidth, cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);
		DrawToHUD.DrawTexture(bottomleft, (x, y + h), alpha, 1.0, -1, (cellwidth, cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);
		DrawToHUD.DrawTexture(bottomright, (x + w, y + h), alpha, 1.0, -1, (cellwidth, cellheight), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), destsize);
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

	static ui void DrawButton(Vector2 pos, String label, double alpha, Vector2 destsize, TextureID icon, double buttonscale = 1.0, bool fullscreen = true)
	{
		double labelx = pos.x;
		double iconwidth;

		Font KeyLabelFont = Font.GetFont("THREEFIV");

		Vector2 scale = (1.0, 1.0) * buttonscale;

		scale = scale * buttonscale;

		int height = max(int(16 * scale.y), int(KeyLabelFont.GetHeight() * scale.y + 8 * scale.y));
		int width = max(height, int(KeyLabelFont.StringWidth(label) * scale.x + 12 * scale.x));

		labelx += width / 2;

		if (icon.IsValid())
		{
			Vector2 iconsize = TexMan.GetScaledSize(icon);
			iconwidth = iconsize.x * 0.5 * scale.x;
			width += int(iconwidth);
			labelx += iconwidth;
		}

		DrawToHUD.DrawFrame("BU_", int(pos.x), int(pos.y), width, height, 0x989898, alpha, alpha, (fullscreen ? (-1, -1) : destsize));

		if (icon.IsValid()) { DrawToHud.DrawTexture(icon, (pos.x + 12, pos.y + height / 2), alpha, 0.5 * scale.x, -1, (-1, -1), TEX_CENTERED | (fullscreen ? 0 : TEX_FIXED), (fullscreen ? (-1, -1) : destsize)); }

		DrawToHUD.DrawText(label, (labelx, pos.y + height / 2), KeyLabelFont, alpha, scale.x, destsize, Font.FindFontColor("TrueBlack"), ZScriptTools.STR_MIDDLE | ZScriptTools.STR_CENTERED | (fullscreen ? 0 : ZScriptTools.STR_FIXED));
	}
}