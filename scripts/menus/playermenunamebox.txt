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

class ListMenuItemPlayerNameBoxColored : ListMenuItemPlayerNameBox
{
	override void Drawer(bool selected)
	{
		String text = StringTable.Localize(mText);
		if (text.Length() > 0)
		{
			screen.DrawText(mFont, selected? OptionMenuSettings.mFontColorSelection : mFontColor, mXpos, mYpos, text, DTA_Clean, true);
		}

		// Draw player name box
		double x = mXpos + mFont.StringWidth(text) + 16 + mFrameSize;
		DrawBorder (x, mYpos - mFrameSize, 16);
		if (!mEnter)
		{
			screen.DrawText (SmallFont, Font.CR_GRAY, x + mFrameSize, mYpos, mPlayerName, DTA_Clean, true);
		}
		else
		{
			let printit = mEnter.GetText() .. SmallFont.GetCursor();
			screen.DrawText (SmallFont, Font.CR_GRAY, x + mFrameSize, mYpos, printit, DTA_Clean, true);
		}
	}
}