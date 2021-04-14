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
 *
 * Portions copied from GZDoom licensed under GPLv3
**/

// Custom option menu class that adds customizeable info descriptors and graphical
// icons to standard option menu option selector items.  
// 
// This implementation has the benefit of working with the default engine menus,
// though there's a possibility that something might break if the internal engine
// menus ever get re-written in the future.
// 
// See 'data/OptionMenus.txt' for configuration information.

class BoAOptionMenu : OptionMenu
{
	ParsedValue menudata;

	override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		menudata = FileReader.Parse("data/OptionMenus.txt");
		menudata = menudata.Find("MenuItems");

		Super.Init(parent, desc);
	}

	// Modified from https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/engine/ui/menu/optionmenu.zs
	override void Drawer ()
	{
		int y = mDesc.mPosition;

		if (y <= 0)
		{
			y = DrawCaption(mDesc.mTitle, -y, true);
		}
		mDesc.mDrawTop = y / CleanYfac_1; // mouse checks are done in clean space.
		int fontheight = OptionMenuSettings.mLinespacing * CleanYfac_1;

		int indent = GetIndent();

		int ytop = y + mDesc.mScrollTop * 8 * CleanYfac_1;
		int lastrow = screen.GetHeight() - OptionHeight() * CleanYfac_1;

		int i;
		for (i = 0; i < mDesc.mItems.Size() && y <= lastrow; i++)
		{
			// Don't scroll the uppermost items
			if (i == mDesc.mScrollTop)
			{
				i += mDesc.mScrollPos;
				if (i >= mDesc.mItems.Size()) break;	// skipped beyond end of menu 
			}

			bool isSelected = mDesc.mSelectedItem == i;
			int cur_indent = indent;

			if (!menudata || DrawDescriptor(mDesc.mItems[i], indent, y, isSelected)) // Only run the old draw code if DrawDescriptor didn't already handle everything
			{
				cur_indent = mDesc.mItems[i].Draw(mDesc, y, indent, isSelected);
			}

			if (cur_indent >= 0 && isSelected && mDesc.mItems[i].Selectable())
			{
				if (((MenuTime() % 8) < 6) || GetCurrentMenu() != self)
				{
					DrawOptionText(cur_indent + 3 * CleanXfac_1, y, OptionMenuSettings.mFontColorSelection, "◄");
				}
			}

			y += fontheight;
		}

		CanScrollUp = (mDesc.mScrollPos > 0);
		CanScrollDown = (i < mDesc.mItems.Size());
		VisBottom = i - 1;

		if (CanScrollUp)
		{
			DrawOptionText(screen.GetWidth() - 11 * CleanXfac_1, ytop, OptionMenuSettings.mFontColorSelection, "▲");
		}
		if (CanScrollDown)
		{
			DrawOptionText(screen.GetWidth() - 11 * CleanXfac_1 , y - 8*CleanYfac_1, OptionMenuSettings.mFontColorSelection, "▼");
		}

		Menu.Drawer();
	}

	// Draw info/warnings and icons on menu items
	// Returns true if item's native code still should run, false if it was duplicated internally here
	bool DrawDescriptor(OptionMenuItem item, int x, int y, bool selected = false)
	{
		bool ret = true;

		if (!menudata) { return ret; }

		ParsedValue descriptor = menudata.Find(item.mLabel);
		if (!descriptor) { return ret; }

		String label = StringTable.Localize(item.mLabel);
		String infolookup = FileReader.GetString(descriptor, "info.string");
		String info;
		String exception = FileReader.GetString(descriptor, "info.default");
		
		String replace = FileReader.GetString(descriptor, "info.replace");
		String with = "";

		if (replace.length())
		{
			Array<string> replacement;
			replace.Split(replacement, ":");

			replace = replacement[0];
			if (replacement.Size() > 1) { with = replacement[1]; }
		}

		String colorname = FileReader.GetString(descriptor, "info.color");
		int clr = OptionMenuSettings.mFontColorHighlight;
		if (colorname.length()) { clr = Font.FindFontColor(colorname); }

		String icon = FileReader.GetString(descriptor, "icon.graphic");

		if (icon.length())
		{
			int labelwidth = NewSmallFont.StringWidth(label);

			if (icon.left(1) == "&") // Ampersand flags this as a cvar lookup
			{
				icon = icon.mid(1);

				CVar lookup = CVar.FindCVar(icon);
				if (!lookup) { return ret; }

				String value = lookup.GetString();

				if (icon ~== "language") // Only really handles language lookup right now
				{
					String shortvalue = value.Left(3);

					if (value ~== "auto") { return ret; }
					if (value ~== "default") { shortvalue = "enu"; }

					icon = "mlang" .. shortvalue; // Flag icons are named MLANG[language code] - so MLANGENU, MLANGDE, etc.

					if (int(TexMan.CheckForTexture(icon)) == -1) { icon = icon.left(7); } // If full 3-letter language not found, fall back to two-letter graphic
				}
				else { icon = value; } // Try to use the value of the CVar directly as a texture name.  Don't know why you'd use this, but...
			}
			else if (icon.left(1) == "$") // Look up the string if there's a dollar sign.  Also don't know why you'd use this.
			{
				icon = StringTable.Localize(icon, true);
			}

			TextureID tex = TexMan.CheckForTexture(icon);
			if (!tex) { return ret; }

			Vector2 texsize = TexMan.GetScaledSize(tex);
			double ratio = texsize.x / texsize.y;

			int lineheight = OptionMenuSettings.mLinespacing * CleanYfac_1;
			int h = int(lineheight * 0.75);

			int w = int(h * ratio);

			String iconpos = FileReader.GetString(descriptor, "icon.position");

			if (item is "OptionMenuItemOption" && iconpos ~== "options")
			{
				// Take over drawing the option values so that they can be offset properly if the icon is in front of the options list

				let it = OptionMenuItemOption(item);

				int labelx = x;
				if (it.mCenter) { labelx = screen.GetWidth() / 2; }
		
				int labelw = Menu.OptionWidth(label) * CleanXfac_1;
				labelx = (!it.mCentered) ? labelx - labelw : (screen.GetWidth() - labelw) / 2;
				Menu.DrawOptionText(labelx, y, selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor, label, it.isGrayed());

				int Selection = it.GetSelection();

				String text = StringTable.Localize(OptionValues.GetText(it.mValues, Selection));
				if (text.Length() == 0)
				{
					text = "Unknown";
					x += it.CursorSpace();
				}
				else
				{
					x += it.CursorSpace() + w / 2;

					screen.DrawTexture(tex, true, x, y + lineheight / 2, DTA_CleanNoMove_1, true, DTA_DestWidth, w, DTA_DestHeight, h, DTA_CenterOffset, true);

					x += w / 2 + 4;
				}

				Menu.DrawOptionText(x, y, OptionMenuSettings.mFontColorValue, text, it.isGrayed());

				ret = false;
			}
			else
			{
				if (iconpos ~== "options")
				{
					x += 14 * CleanXfac_1 + w / 2;

					screen.DrawTexture(tex, true, x, y + lineheight / 2, DTA_CleanNoMove_1, true, DTA_DestWidth, w, DTA_DestHeight, h, DTA_CenterOffset, true);

					x += w / 2 + 4;
				}
				else
				{
					screen.DrawTexture(tex, true, x - (labelwidth + w / 2 + 4) * CleanXFac_1, y + lineheight / 2, DTA_CleanNoMove_1, true, DTA_DestWidth, w, DTA_DestHeight, h, DTA_CenterOffset, true);
				}
			}
		}

		if (infolookup.length()) { info = StringTable.Localize(infolookup); }

		if (!(info ~== exception || info ~== infolookup.mid(1)))
		{
			if (replace.length()) { info.Replace(replace, with); }

			let desc = OptionMenuItemOption(item);

			if (item is "OptionMenuItemOption")
			{
				int optionwidth = NewSmallFont.StringWidth(StringTable.Localize(OptionValues.GetText(desc.mValues, desc.GetSelection())));
				DrawOptionText(x + item.CursorSpace() + optionwidth * CleanXFac_1, y, clr, info);
			}
		}

		return ret;
	}
}