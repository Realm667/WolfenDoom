/*
 * Copyright (c) 2021 Talon1024
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

class MessageLogHandler : EventHandler
{
	Array<String> messages;
	Dictionary images; // In case a message should have an image appear beside it

	override void OnRegister()
	{
		if (!images)
		{
			images = Dictionary.Create();
		}
	}

	static void Add(String message, String image = "")
	{
		MessageLogHandler handler = MessageLogHandler(EventHandler.Find("MessageLogHandler"));
		if (!handler) { return; }
		handler.messages.Push(message);
		if (image.Length())
		{
			handler.images.Insert(message, image);
		}
	}
}

const MessageLogVHeight = 540; // Divides evenly with most common aspect ratios

class MessageLogMenu : GenericMenu
{
	Array<String> lines; // Text line strings
	Array<int> xoffsets; // X offsets of text lines
	Dictionary images; // Line number (Array index) to image
	int msgWidth; // Width available for drawing text
	int maxLines; // Maximum number of lines which can be drawn
	int minLine; // Minimum or "current" line
	// Scroll bar graphics
	TextureID scrollTop;
	TextureID scrollMid;
	TextureID scrollBot;
	TextureID arrowUp;
	TextureID arrowDown;
	bool dragging; // User is dragging the scroll bar?
	double scaleX;
	double scaleY;

	override void Init(Menu parent)
	{
		Super.Init(parent);
		images = Dictionary.Create();
		// Virtual width of message log - used to calculate scaling
		int vWidth = int(MessageLogVHeight * Screen.GetAspectRatio());
		// Multiply by 1.0 to convert to double
		scaleX = double(Screen.GetWidth()) / vWidth;
		scaleY = double(Screen.GetHeight()) / MessageLogVHeight;
		// Display messages in a 4:3 "space", with side padding.
		// 20 px = 10px padding on both sides
		// 32 px = width of the scroll bar graphics
		// Scale scrollbar by Clean{X,Y}Fac_1
		msgWidth = int(min(Screen.GetWidth(), Screen.GetHeight() * 4. / 3) - 20 - 32 * CleanXFac_1);
		// How many lines, at most, should be displayed?
		maxLines = int(ceil(MessageLogVHeight / smallfont.GetHeight() * .875));
		scrollTop = TexMan.CheckForTexture("graphics/conversation/Scroll_T.png");
		scrollMid = TexMan.CheckForTexture("graphics/conversation/Scroll_M.png");
		scrollBot = TexMan.CheckForTexture("graphics/conversation/Scroll_B.png");
		arrowUp = TexMan.CheckForTexture("graphics/conversation/Arrow_Up.png");
		arrowDown = TexMan.CheckForTexture("graphics/conversation/Arrow_Dn.png");
		MessageLogHandler log = MessageLogHandler(EventHandler.Find("MessageLogHandler"));
		if (!log) { return; }
		// Add all of the messages from the log handler to the "menu"
		for(int i = 0; i < log.messages.Size(); i++)
		{
			String image = log.images.At(log.messages[i]);
			addMessage(log.messages[i], image);
		}
		minLine = max(0, lines.Size() - maxLines);
	}

	// Push to both arrays so that they are the same size
	protected ui void addLine(String text, int offset = 0)
	{
		lines.Push(text);
		xoffsets.Push(offset);
	}

	protected ui void addMessage(String message, String image = "")
	{
		// Prepare image
		int imageWidth = 0;
		int imageLines = 0;
		if (image.Length())
		{
			TextureID imageTexture = TexMan.CheckForTexture(image);
			if (imageTexture)
			{
				int imageHeight;
				[imageWidth, imageHeight] = TexMan.GetSize(imageTexture);
				imageLines = int(ceil(double(imageHeight) / smallfont.GetHeight()));
			}
		}
		String fulltext = "";
		if (message.ByteAt(0) == 124) // '|'
		{
			fulltext = StringTable.Localize(message.Mid(1), false);
		}
		else
		{
			Array<String> pieces;
			message.Split(pieces, "|", TOK_SKIPEMPTY);
			for (int i = 0; i < pieces.Size(); i++)
			{
				fulltext = fulltext .. StringTable.Localize(pieces[i], false);
			}
		}
		// Break text into lines
		BrokenString breakInfo;
		String textLines;
		[textLines, breakInfo] = BrokenString.BreakString(fulltext, int((msgWidth - (imageWidth ? 6 : 0) - imageWidth * scaleX) / scaleX), fnt: smallfont);
		// Add lines
		int firstLineNumber = lines.Size();
		if (firstLineNumber)
		{
			addLine(""); // Should make it less cluttered and easier to read
			addLine(""); // Private use character - separator graphic in smallfont
			addLine("");
			firstLineNumber += 3; // So that images are drawn - the drawer
			// checks the text line, not the separator line.
		}
		for (int i = 0; i < breakInfo.Count(); i++)
		{
			addLine(breakInfo.StringAt(i), imageWidth ? imageWidth + 6 : 0);
		}
		if (breakInfo.Count() < imageLines)
		{
			for (int i = breakInfo.Count(); i <= imageLines; i++)
			{
				addLine(""); // Blank lines don't need to have offsets
			}
		}
		if (imageWidth)
		{
			String lineNumString = String.Format("%d", firstLineNumber);
			images.Insert(lineNumString, image);
		}
	}

	override void Drawer()
	{
		if (lines.Size())
		{
			// Left-hand edge of the 4:3 box, plus 10px for left-hand padding
			double xpos = max(0, Screen.GetWidth() / 2 * (1 - (4./3) / Screen.GetAspectRatio())) + 10 * scaleX;
			int maxLine = min(lines.Size(), minLine + maxLines);
			double ystart = Screen.GetHeight() * .0625;
			double ypos = ystart;
			// Draw the messages
			for (int line = minLine; line < maxLine; line++)
			{
				double textXpos = xpos + xoffsets[line] * scaleX;
				if (lines[line] == "")
				{ // Draw a separator
					Screen.DrawText(smallfont, Font.CR_GRAY, textXpos, ypos, "", DTA_ScaleX, scaleX, DTA_ScaleY, scaleY);
					textXpos += smallfont.GetCharWidth(0xE000) * scaleX;
					int endSepWidth = int(smallfont.GetCharWidth(0xE002) * scaleX);
					while (textXpos < (msgWidth + xpos - endSepWidth))
					{
						Screen.DrawText(smallfont, Font.CR_GRAY, textXpos, ypos, "", DTA_ScaleX, scaleX, DTA_ScaleY, scaleY);
						textXpos += smallfont.GetCharWidth(0xE001) * scaleX;
					}
					Screen.DrawText(smallfont, Font.CR_GRAY, textXpos, ypos, "", DTA_ScaleX, scaleX, DTA_ScaleY, scaleY);
				}
				else
				{
					// Draw text
					Screen.DrawText(smallfont, Font.CR_GRAY, textXpos, ypos, lines[line], DTA_ScaleX, scaleX, DTA_ScaleY, scaleY);
					// Draw image
					String lineNumString = String.Format("%d", line);
					String imageName = images.At(lineNumString);
					if (imageName.Length())
					{
						TextureID imageTexture = TexMan.CheckForTexture(imageName);
						Screen.DrawTexture(imageTexture, true, xpos, ypos, DTA_ScaleX, scaleX, DTA_ScaleY, scaleY);
						// Draw border around image (debug)
						/*
						int imageWidth, imageHeight;
						[imageWidth, imageHeight] = TexMan.GetSize(imageTexture);
						Screen.DrawLineFrame(Color(255, 255, 0, 0), int(xpos), int(ypos), imageWidth * scaleX, imageHeight * scaleY);
						*/
					}
				}
				ypos += smallfont.GetHeight() * scaleY;
			}
			// Draw the scroll bar
			if (lines.Size() > maxLines)
			{
				// xpos is at the left side of the lines, so move it to the
				// right side to draw the scroll bar graphics.
				xpos += msgWidth;
				ypos = ystart;
				Screen.DrawTexture(arrowUp, false, xpos, ypos, DTA_CleanNoMove_1, true);
				// Screen.DrawLineFrame(Color(255, 255, 0, 0), int(xpos), int(ypos), 32 * CleanXFac_1, 32 * CleanYFac_1); // Debug
				// The total height of the scroll bar is the screen height *
				// .875. The height of each scrollbar graphic is 32. Two arrows
				// at the top and bottom make 64.
				double scrollBarHeight = Screen.GetHeight() * .875 - 64 * CleanYFac_1;
				double scrollBarPct = double(minLine) / (lines.Size() - maxLines);
				// The scroll bar is 96px tall.
				double scrollBarYOffset = -scrollBarPct * 96 * CleanYFac_1;
				// ypos += 32 * CleanYFac_1; // Debug
				// Screen.DrawLineFrame(Color(255, 0, 255, 0), int(xpos), int(ypos), 32 * CleanXFac_1, int(scrollBarHeight)); // Debug
				ypos = ystart + 32 * CleanYFac_1 + scrollBarHeight * scrollBarPct;
				Screen.DrawTexture(scrollTop, false, xpos, ypos + scrollBarYOffset, DTA_CleanNoMove_1, true);
				ypos += 32 * CleanYFac_1;
				Screen.DrawTexture(scrollMid, false, xpos, ypos + scrollBarYOffset, DTA_CleanNoMove_1, true);
				ypos += 32 * CleanYFac_1;
				Screen.DrawTexture(scrollBot, false, xpos, ypos + scrollBarYOffset, DTA_CleanNoMove_1, true);
				// Start height plus height of up arrow and scroll bar
				ypos = ystart + 32 * CleanYFac_1 + scrollBarHeight;
				Screen.DrawTexture(arrowDown, false, xpos, ypos, DTA_CleanNoMove_1, true);
				// Screen.DrawLineFrame(Color(255, 0, 0, 255), int(xpos), int(ypos), 32 * CleanXFac_1, 32 * CleanYFac_1); // Debug
			}
		}
		else
		{
			String emptyLogText = StringTable.Localize("MESSAGELOGEMPTY", false);
			double xpos = (Screen.GetWidth() / 2) - (smallfont.StringWidth(emptyLogText) * scaleX / 2);
			double ypos = (Screen.GetHeight() / 2) - (smallfont.GetHeight() * scaleY / 2);
			Screen.DrawText(smallfont, Font.CR_GRAY, xpos, ypos, emptyLogText, DTA_ScaleX, scaleX, DTA_ScaleY, scaleY);
		}
		Super.Drawer(); // "Back" button
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		int scale = 1;
		switch (mkey)
		{
		case MKEY_PageUp:
		case MKEY_PageDown:
			scale = 10;
		case MKEY_Up:
		case MKEY_Down:
			int direction = (mkey == MKEY_Up || mkey == MKEY_PageUp) ? -1 : 1;
			return Scroll(direction * scale);
		}
		return Super.MenuEvent(mkey, fromcontroller);
	}

	override bool MouseEvent(int type, int mx, int my)
	{
		int totalHeight = int(Screen.GetHeight() * .875);
		int scrollBarX = int(max(0, Screen.GetWidth() / 2 * (1 - (4./3) / Screen.GetAspectRatio())) + 10 * scaleX + msgWidth);
		int upArrowY = int(Screen.GetHeight() * .0625);
		int upArrowHeight = 32 * CleanYFac_1;
		int scrollBarY = upArrowY + 32 * CleanYFac_1;
		int scrollBarWidth = 32 * CleanXFac_1;
		int scrollBarHeight = totalHeight - 64 * CleanYFac_1;
		int downArrowY = scrollBarY + scrollBarHeight;
		int downArrowHeight = 32 * CleanYFac_1;
		if (lines.Size() <= maxLines)
		{
			// No need to scroll the message log if all the lines fit
			return false;
		}
		if (dragging)
		{
			if (type == MOUSE_Release)
			{
				dragging = false;
			}
			else
			{
				double percent = clamp(my - scrollBarY, 0, scrollBarHeight) / double(scrollBarHeight);
				SetLine(percentToLine(percent));
			}
			return true;
		}
		else if (mx >= scrollBarX && (mx - scrollBarX) < scrollBarWidth && my >= upArrowY && (my - upArrowY) < totalHeight)
		{
			if (type == MOUSE_Click)
			{
				// Clicked on one of the arrows
				if (my - upArrowY < upArrowHeight)
				{
					SetLine(minLine - 1);
					return true;
				}
				else if (my >= downArrowY && my - downArrowY < downArrowHeight)
				{
					SetLine(minLine + 1);
					return true;
				}
				else
				{ // Clicked on the scroll bar
					dragging = true;
				}
				return true;
			}
		}
		return false;
	}

	override bool OnUIEvent(UIEvent e)
	{
		// Handle mouse wheel
		switch(e.type)
		{
		case UIEvent.Type_WheelUp:
		case UIEvent.Type_WheelDown:
			int direction = (e.type == UIEvent.Type_WheelUp) ? -1 : 1;
			Scroll(direction * 5);
			return true;
		}
		return Super.OnUIEvent(e);
	}

	protected int percentToLine(double percent)
	{
		int maxLine = lines.Size() - maxLines;
		return int(floor(maxLine * percent));
	}

	protected void SetLine(int line)
	{
		minLine = clamp(line, 0, lines.Size() - maxLines);
	}

	protected bool Scroll(int by)
	{
		int maxLine = minLine + maxLines;
		bool allowMove = lines.Size() > maxLines && (
			(by > 0 && maxLine < lines.Size()) || // Scroll down
			(by < 0 && minLine > 0)); // Scroll up
		if (allowMove)
		{
			SetLine(minLine + by);
			return true;
		}
		else
		{
			return false;
		}
	}
}

// openmenu MessageLogMenu
