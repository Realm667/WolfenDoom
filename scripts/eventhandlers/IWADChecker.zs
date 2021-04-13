/*
 * Copyright (c) 2020 N00b, Talon1024
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

class IWADChecker : EventHandler
{
	// Check if BoA is being loaded as a PWAD, and display the IWADNotice if it
	// is.
	void CheckIWAD()
	{
		if (Wads.FindLump("MAP01", 0) > 0 || Wads.FindLump("E1M1", 0) > 0) //filters Doom IWADS
		{
			Menu.SetMenu("IWADNotice");
			Level.setFrozen(true);
		}
	}

	void CheckRenderer()
	{
		// Ensure player is using a renderer which supports shaders
		/*
		if (!(r_renderercaps & RFF_MATSHADER) && !(r_renderercaps & RFF_POSTSHADER))
		{
			Menu.SetMenu("IWADNotice");
			Level.setFrozen(true);
		}
		*/
	}

	override void WorldTick()
	{
		if (level.time == 5)
		{
			CheckIWAD();
			CheckRenderer();
			Destroy();
		}
	}
}

class IWADNotice : BoAMenu
{
	override void Drawer()
	{
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
		BrokenLines textLines = SmallFont.BreakLines(text, SmallFont.GetCharWidth(widthChar) * 50);
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
		// Intercept key presses to see if we're pressing the strafe controls or use, 
		// and redirect those to call the correct left/right/open movement menu event code.

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
}

