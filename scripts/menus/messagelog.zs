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

class MessageLogHandler : StaticEventHandler
{
	Array<String> messages;

	static void Add(String message)
	{
		MessageLogHandler handler = MessageLogHandler(StaticEventHandler.Find("MessageLogHandler"));
		if (!handler) { return; }
		handler.messages.Push(message);
	}
}

class MessageLogMenu : GenericMenu
{
	MessageLogHandler log;

	override void Init(Menu parent)
	{
		Super.Init(parent);
		log = MessageLogHandler(StaticEventHandler.Find("MessageLogHandler"));
	}

	protected clearscope String getMessageText(String message)
	{
		if (message.ByteAt(0) == 124) // '|'
		{
			return StringTable.Localize(message.Mid(1), false);
		}
		Array<String> pieces;
		message.Split(pieces, "|", TOK_SKIPEMPTY);
		String fulltext = "";
		for (int i = 0; i < pieces.Size(); i++)
		{
			fulltext = fulltext .. StringTable.Localize(pieces[i], false);
		}
		return fulltext;
	}

	override void Drawer()
	{
		if (log.messages.Size())
		{
			double xpos = max(0, Screen.GetWidth() / 2 * (1 - (4./3) / Screen.GetAspectRatio())) + 10 * CleanXFac_1;
			// Display messages in a 4:3 "space", with side padding. Also,
			// there is additional right side padding for the scroll bar.
			int msgWidth = min(Screen.GetWidth(), Screen.GetWidth() * (4./3) / Screen.GetAspectRatio()) - 20 * CleanXFac_1;
			double ypos = Screen.GetHeight(); // Start at the bottom and go up
			// Draw most recent messages first
			for (int i = log.messages.Size() - 1; i >= 0; i--)
			{
				String messageText = getMessageText(log.messages[i]);

				BrokenString breakInfo;
				String textLines;
				[textLines, breakInfo] = BrokenString.BreakString(messageText, msgWidth / CleanXFac_1, fnt: smallfont);
				ypos -= smallfont.GetHeight() * CleanYFac_1;

				for (int i = breakInfo.Count(); i >= 0; i--)
				{
					Screen.DrawText(smallfont, Font.CR_UNTRANSLATED, xpos, ypos, breakInfo.lines[i], DTA_CleanNoMove_1, true);
					ypos -= smallfont.GetHeight() * CleanYFac_1;
				}
				
				/*
				// Draw spacer between each message
				if (i != log.messages.Size() - 1)
				{
					ypos -= 10 * CleanYFac_1;
					Screen.DrawTexture()
				}
				*/
			}
		}
		else
		{
			String emptyLogText = StringTable.Localize("MESSAGELOGEMPTY", false);
			double xpos = (CleanWidth_1 * CleanXFac_1 / 2) - (smallfont.StringWidth(emptyLogText) * CleanXFac_1 / 2);
			double ypos = (CleanHeight_1 * CleanYFac_1 / 2) - (smallfont.GetHeight() * CleanYFac_1 / 2);
			Screen.DrawText(smallfont, Font.CR_GRAY, xpos, ypos, emptyLogText, DTA_CleanNoMove_1, true);
		}
	}
}