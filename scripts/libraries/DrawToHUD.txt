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
	static ui Vector2, Vector2 TranslatetoHUDCoordinates(Vector2 pos, Vector2 size = (0, 0))
	{
		// Get the scale being used by the HUD code
		Vector2 hudscale = Statusbar.GetHudScale();

		// Scale the texture and coordinates to match the HUD elements
		Vector2 screenpos, screensize;

		screenpos.x = pos.x * hudscale.x;
		screenpos.y = pos.y * hudscale.y;

		screensize.x = size.x * hudscale.x;
		screensize.y = size.y * hudscale.y;

		// Allow HUD coordinate-style positioning (not the decimal part, just that negatives mean offset from right/bottom)
		if (pos.x < 0) { screenpos.x += Screen.GetWidth(); }
		if (pos.y < 0) { screenpos.y += Screen.GetHeight(); }

		return screenpos, screensize;
	}

	enum offsets
	{
		left,
		right,
		center,
	};

	static ui void DrawText(String text, Vector2 pos, Font fnt = null, double alpha = 1.0, double scale = 1.0, color shade = -1, int offset = left)
	{
		if (!fnt) { fnt = SmallFont; }

		int width = int(Screen.GetWidth() / scale);
		int height = int((Screen.GetHeight() - fnt.GetHeight()) / scale);

		// Scale the coordinates
		Vector2 screenpos, screensize;
		[screenpos, screensize] = TranslatetoHUDCoordinates(pos, (640, 480) * scale);

		screenpos /= scale;

		//Do offset handling...
		switch (offset)
		{
			case 1:
				screenpos.x -= fnt.StringWidth(text);
				break;
			case 2:
				screenpos.x -= fnt.StringWidth(text) / 2;
				break;
			default:
				break;
		}

		// Draw the text
		screen.DrawText(fnt, shade, screenpos.x, screenpos.y, text, DTA_KeepRatio, true, DTA_Alpha, alpha, DTA_VirtualWidth, width, DTA_VirtualHeight, height);
	}

	static ui void DrawTexture(TextureID tex, Vector2 pos, double alpha = 1.0, double scale = 1.0, color shade = -1)
	{
		// Scale the coordinates
		Vector2 screenpos, screensize;
		[screenpos, screensize] = TranslatetoHUDCoordinates(pos, TexMan.GetScaledSize(tex) * scale);

		bool alphachannel;
		color fillcolor;

		if (shade > 0)
		{
			alphachannel = true;
			fillcolor = shade & 0xFFFFFF;
		}

		// Draw the texture
		screen.DrawTexture(tex, false, screenpos.x, screenpos.y, DTA_DestWidth, int(screensize.x), DTA_DestHeight, int(screensize.y), DTA_Alpha, alpha, DTA_CenterOffset, true, DTA_AlphaChannel, alphachannel, DTA_FillColor, shade);
	}

	static ui void DrawTransformedTexture(TextureID tex, Vector2 pos, double alpha = 1.0, double ang = 0, double scale = 1.0, color shade = -1)
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

		// Draw rotated texture
		Screen.DrawTexture(tex, false, screenpos.x, screenpos.y, DTA_CenterOffset, true, DTA_Rotate, -ang, DTA_DestWidth, int(screensize.x), DTA_DestHeight, int(screensize.y), DTA_Alpha, alpha, DTA_AlphaChannel, alphachannel, DTA_FillColor, shade);
	}


	static ui void Dim(Color clr = 0x000000, double alpha = 0.5, int x = 0, int y = 0, int w = -1, int h = -1)
	{
		if (w == -1) { w = Screen.GetWidth(); }
		if (h == -1) { h = Screen.GetHeight(); }

		// Scale the coordinates
		Vector2 screenpos, screensize;
		[screenpos, screensize] = TranslatetoHUDCoordinates((x, y), (w, h));

		Screen.Dim(clr, alpha, int(screenpos.x), int(screenpos.y), int(screensize.x), int(screensize.y));
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
}