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

// Match legacy settings without rewriting the user's language CVAR or adding
// duplicate entries to the language selector. New selections use BCP 47 codes.
class OptionMenuItemBoALanguage : OptionMenuItemOption
{
	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		int edge = Super.Draw(desc, y, indent, selected);
		int i = GetSelection();
		if (i < 0) return edge;
		String code = OptionValues.GetTextValue(mValues, i);
		if (code ~== "en-US") code = "enu";
		else if (code ~== "en-GB") code = "eng";
		else if (code ~== "pt-PT") code = "ptg";
		let flag = TexMan.CheckForTexture("MLANG" .. code);
		if (!flag.IsValid()) return edge;
		String value = StringTable.Localize(OptionValues.GetText(mValues, i));
		int x = indent + CursorSpace() + (Menu.OptionWidth(value) + 4) * CleanXfac_1;
		let size = TexMan.GetScaledSize(flag);
		int h = max(1, OptionMenuSettings.mLinespacing * CleanYfac_1 * 3 / 4);
		int w = int(h * size.x / max(1., size.y));
		if (x+w < Screen.GetWidth())
			Screen.DrawTexture(flag, true, x, y, DTA_DestWidth, w, DTA_DestHeight, h);
		return edge;
	}

	override int GetSelection()
	{
		int selection = Super.GetSelection();
		if (selection >= 0 || !mCVar) { return selection; }
		String value = mCVar.GetString();
		if (value ~== "default" || value ~== "enu" || value ~== "en") { value = "en-US"; }
		else if (value ~== "eng") { value = "en-GB"; }
		else if (value ~== "ptg" || value ~== "pt") { value = "pt-PT"; }
		for (int i = 0; i < OptionValues.GetCount(mValues); i++)
		{
			if (value ~== OptionValues.GetTextValue(mValues, i)) { return i; }
		}
		return selection;
	}
}

// Compatibility name for add-ons; stock rendering and navigation are inherited.
class BoAOptionMenu : OptionMenu {}

// Option menu slider that displays a float value as a percentage (e.g., 0.5 as 50% if min is 0 and max is 1.0)
// Also accepts optional text values that display in place of 0% and 100%
// Modified from OptionMenuItemScaleSlider class
class OptionMenuItemPercentSlider : OptionMenuItemSlider
{
	String Label0;
	String Label100;
	int mClickVal;
	
	OptionMenuItemPercentSlider Init(String label, Name command, double min, double max, double step, String zero = "", String full = "")
	{
		Super.Init(label, command, min, max, step, 0);
		mCVar = CVar.FindCVar(command);
		Label0 = zero;
		Label100 = full;
		mClickVal = -10;
		return self;
	}

	//=============================================================================
	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		drawLabel(indent, y, selected? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor);

		double val = GetSliderValue();
		String text = String.Format("%i", round(val * 100 / (mMax - mMin))) .. "%";

		if (((Label0.length() && val == mMin) || (Label100.length() && val == mMax)) && mClickVal <= 0)
		{
			text = val == mMin ? Label0 : val == mMax ? Label100  : "";
			drawValue(indent, y, OptionMenuSettings.mFontColorValue, text);
		}
		else
		{
			mDrawX = indent + CursorSpace();
			DrawSlider (mDrawX, y, mMin, mMax, GetSliderValue(), -1, indent);

			int right = mDrawX + (12*16 + 4) * CleanXfac_1;
			int maxlen = Menu.OptionWidth("100%") * CleanXfac_1;

			if (right + maxlen <= screen.GetWidth())
			{
				drawText(right, y, Font.CR_DARKGRAY, text, 0);
			}
		}
		return indent;
	}
}
