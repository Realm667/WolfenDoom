/*
 * Copyright (c) 2021 AFADoomer, Talon1024
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

class Message : Thinker
{
	String icon;
	String text;
	int time, intime, outtime;
	PlayerInfo player;

	double alpha;
	int ticker;

	static void Init(Actor mo, String icon, String text, int intime = 35, int outtime = 35)
	{
		let handler = MessageHandler(EventHandler.Find("MessageHandler"));
		if (!handler) { return; }

		Message msg = New("Message");
		msg.icon = icon;
		msg.text = text;
		msg.time = ZScriptTools.GetMessageTime(text) + intime + outtime;
		msg.intime = intime;
		msg.outtime = outtime;
		PlayerInfo player;
		if (mo && mo.player)
		{
			player = mo.player;
		}
		else
		{
			player = players[consoleplayer];
		}
		msg.player = player;

		handler.messages.Push(msg);
	}

	virtual void DoTick()
	{
		ticker++;
		
		if (ticker < intime) { alpha = ticker / double(intime); }
		else if (ticker > time - outtime) { alpha = (time - ticker) / double(outtime); }
		else { alpha = 1.0; }

		alpha = clamp(alpha, 0.0, 1.0);
	}

	virtual void Start()
	{
		player.mo.SetInventory("IncomingMessage", 1);
		player.mo.A_StartSound("RADIONOS", CHAN_AUTO, CHANF_LOCAL);

		time = max(time, PlaySound());
	}

	virtual void End()
	{
		player.mo.SetInventory("IncomingMessage", 0);
	}

	int PlaySound()
	{
		// Get localized SNDINFO entry for localized voice acting
		String messageKey = "SND_" .. text;
		String messageEntry = StringTable.Localize(messageKey, false);

		bool hassound = !(messageKey ~== messageEntry);
		
		double soundLength = 0;
		if (hasSound) { soundLength = S_GetLength(messageEntry); }

		if (!hasSound || soundLength == 0)
		{
			if (boa_debugvoiceovers) { console.printf("\cgMissing voiceover: \cjCheck SNDINFO entry and audio file for \cf%s\cj!", text); }

			return 0;
		}

		player.mo.A_StartSound(messageEntry, CHAN_BODY, CHANF_LOCAL);

		return int(soundLength * 35);
	}

	virtual ui void DrawMessage(int msgwidth, int barwidth, bool fullscreenstyle, bool bNoFadeIn, bool bNoFadeOut)
	{
		TextureID bgtex, ovltex, headtex;

		if (ticker > 35 && ticker < time * 0.75) // Talk once faded in and through 3/4 of display time
		{
			headtex = TexMan.CheckForTexture(icon .. "1"); // ANIMDEFS-defined talking head
		}

		if (!headtex.IsValid()) // Fall back to static face if not currently animated (or animated face not found)
		{
			headtex = TexMan.CheckForTexture(icon .. "0"); // Static head
		}

		double staticalpha = alpha;
		if (bNoFadeIn && ticker < 35) { staticalpha = 1.0; }
		else if (bNoFadeOut && ticker > time - 35) { staticalpha = 1.0; }

		if (fullscreenstyle)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();
			Vector2 size = (0, 0);

			int x = int(Screen.GetWidth() / hudscale.x / 2 - barwidth / 2); // Position scaled relative to screen center
			int y = 8;
			int margin = 8;

			if (headtex) { size = TexMan.GetScaledSize(headtex); }

			DrawToHUD.DrawFrame("FRAME_", x, y, int(msgwidth + size.x + margin * 4), 70, 0x1b1b1b, 1.0 * staticalpha, 0.5 * staticalpha);

			y += margin;

			if (headtex)
			{
				DrawToHUD.DrawTexture(headtex, (x + size.x / 2 + margin, y + size.y / 2 + margin), staticalpha, 1.25);
			}

			x += size.x ? int(size.x + margin * 2) : 0;

			if (ticker > 35 && text.length())
			{
				ZScriptTools.TypeString(SmallFont, text, msgwidth, (x, y), ticker - 35, hudscale.y, alpha, (320 * hudscale.x, 200 * hudscale.y));
			}
		}
		else
		{
			Vector2 bgpos = (160.0, 24.0);
			Vector2 headpos = (21.0, 16.0);

			bgtex = TexMan.CheckForTexture("HEADBAR");
			ovltex = TexMan.CheckForTexture("HEADBOVL");

			if (bgtex) { screen.DrawTexture(bgtex, true, bgpos.x, bgpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, staticalpha); }
			if (headtex) { screen.DrawTexture(headtex, true, headpos.x, headpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, staticalpha); }
			if (ovltex) { screen.DrawTexture(ovltex, true, bgpos.x, bgpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, staticalpha); }

			if (ticker > 35 && text.length())
			{
				ZScriptTools.TypeString(SmallFont, text, msgwidth, (100.0, 4.0), ticker - 35, 1.0, alpha, (640, 400), true);
			}
		}
	}
}

class MessageHandler : EventHandler
{
	Array<Message> messages;
	ui int barwidth, msgwidth;
	String active[8];
	bool bNoFadeIn, bNoFadeOut;
	bool fullscreenstyle;

	override void WorldTick()
	{
		if (!messages.Size())
		{
			active[consoleplayer] = "";
			bNoFadeIn = false;
			bNoFadeOut = false;
			messages.Clear();
			return;
		}

		CVar altstyle = CVar.FindCVar("boa_altmessagestyle");
		if (screenblocks == 11 || Screen.GetHeight() > Screen.GetWidth() || (altstyle && altstyle.GetBool())) { fullscreenstyle = true; }
		else { fullscreenstyle = false; }
		
		let m = messages[0];
		if (m)
		{
			if (m.ticker > m.time)
			{
				m.End();
				messages.Delete(0);
			}
			else
			{
				if (m.ticker == 0 && m.player == players[consoleplayer])
				{
					m.Start();

					// Try not to fade message backgrounds and icons in between messages with the same icon
					bNoFadeIn = !!(active[consoleplayer] == m.icon);
					bNoFadeOut = false;

					active[consoleplayer] = m.icon;
				}

				if (!bNoFadeOut && messages.Size() > 1)
				{
					let nm = messages[1];
					if (nm.icon == m.icon) { bNoFadeOut = true; }
				}

				m.DoTick();
			}
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (fullscreenstyle)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();
			barwidth = int(min(Screen.GetHeight() / hudscale.y, Screen.GetWidth() / hudscale.x - 240));
			msgwidth = barwidth - 64;
		}
		else if (screenblocks < 11) { msgwidth = 540; }
		else { return; }

		for (int a = 0; a < messages.Size(); a++)
		{
			let m = messages[a];

			if (
				m &&
				e.camera &&
				e.camera.player	&& 
				e.camera.player == m.player
			)
			{
				m.DrawMessage(msgwidth, barwidth, fullscreenstyle, bNoFadeIn, bNoFadeOut);
				return; // Only draw one message per player at a time
			}
		}
	}
}