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

class MessageBase : Thinker
{
	enum flags
	{
		MSG_DEFAULT = 0,
		MSG_NOFADEIN = 1,
		MSG_NOFADEOUT = 2,
		MSG_FULLSCREEN = 4
	}

	String text;
	String msgname;
	int time, intime, outtime;
	PlayerInfo player;

	double alpha;
	int ticker;

	static MessageBase Init(Actor mo, String text, int intime, int outtime, class<MessageBase> type = "MessageBase")
	{
		let handler = MessageHandler(EventHandler.Find("MessageHandler"));
		if (!handler) { return null; }

		MessageBase msg = MessageBase(New(type));
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
		if (handler.types.Find(type) == handler.types.Size()) { handler.types.Push(type); }

		return msg;
	}

	virtual void DoTick()
	{
		ticker++;

		if (ticker < intime) { alpha = ticker / double(intime); }
		else if (ticker > time - outtime) { alpha = (time - ticker) / double(outtime); }
		else { alpha = 1.0; }

		alpha = clamp(alpha, 0.0, 1.0);
	}

	virtual void Start() {}
	virtual void End() {}
	virtual ui void DrawMessage(int flags) {}

	int PlaySound()
	{
		// Get localized SNDINFO entry for voice acting
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
}

// Standard top-of-screen NPC message
class Message : MessageBase
{
	ui int msgwidth, barwidth;
	String icon;

	static void Init(Actor mo, String icon, String text, int intime = 35, int outtime = 35)
	{
		Message msg = Message(MessageBase.Init(mo, text, intime, outtime, "Message"));
		msg.msgname = icon; // Set the name to the icon string so that messages with the same icon don't fade in between
		msg.icon = icon;
	}

	override void Start()
	{
		player.mo.SetInventory("IncomingMessage", 1);
		player.mo.A_StartSound("RADIONOS", CHAN_AUTO, CHANF_LOCAL);

		time = max(time, PlaySound());
	}

	override void End()
	{
		player.mo.SetInventory("IncomingMessage", 0);
	}

	override void DrawMessage(int flags)
	{
		if (flags & MessageBase.MSG_FULLSCREEN)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();
			barwidth = int(min(Screen.GetHeight() / hudscale.y, Screen.GetWidth() / hudscale.x - 240));
			msgwidth = barwidth - 64;
		}
		else { msgwidth = 540; }

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
		if (flags & MSG_NOFADEIN && ticker < 35) { staticalpha = 1.0; }
		else if (flags & MSG_NOFADEOUT && ticker > time - 35) { staticalpha = 1.0; }

		if (flags & MSG_FULLSCREEN)
		{
			String brokentext;
			BrokenString lines;
			[brokentext, lines] = BrokenString.BreakString(StringTable.Localize(text, false), msgwidth, false, "C");
			int lineheight = int(SmallFont.GetHeight());

			Vector2 hudscale = StatusBar.GetHUDScale();
			Vector2 size = (0, 0);

			int x = int(Screen.GetWidth() / hudscale.x / 2 - barwidth / 2); // Position scaled relative to screen center
			int y = 8;
			int margin = 8;

			if (headtex) { size = TexMan.GetScaledSize(headtex) * 1.25; }

			double boxheight = lines.Count() * lineheight + margin * 2;
			boxheight = max(boxheight, size.y + margin);
			boxheight += margin;

			DrawToHUD.DrawFrame("FRAME_", x, y, msgwidth + size.x + margin * 4, boxheight, 0x1b1b1b, 1.0 * staticalpha, 0.5 * staticalpha);

			y += margin;

			if (headtex)
			{
				DrawToHUD.DrawFrame("INSET_", x + margin, y, size.x, size.y - 2, 0x404040, 0.5 * staticalpha);
				DrawToHUD.DrawTexture(headtex, (x + margin, y), staticalpha, 1.25, centered:false);
			}

			x += size.x ? int(size.x + margin * 2) : 0;

			if (ticker > 35 && text.length())
			{
				ZScriptTools.TypeString(SmallFont, text, msgwidth, (x, y), ticker - 35, hudscale.y, alpha, (320 * hudscale.x, 200 * hudscale.y), ZScriptTools.STR_LEFT | ZScriptTools.STR_TOP);
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
				ZScriptTools.TypeString(SmallFont, text, msgwidth, (100.0, 4.0), ticker - 35, 1.0, alpha, (640, 400), ZScriptTools.STR_LEFT | ZScriptTools.STR_TOP | ZScriptTools.STR_FIXED);
			}
		}
	}
}

// Standard bottom-of-screen hint messages
class HintMessage : MessageBase
{
	ui int msgwidth;
	String key;

	static void Init(Actor mo, String text, String key)
	{
		HintMessage msg = HintMessage(MessageBase.Init(mo, text, 35, 35, "HintMessage"));
		msg.key = key;
	}

	override void Start()
	{
		player.mo.A_StartSound("menu/change", CHAN_AUTO, CHANF_LOCAL, 0.75);
	}

	override void DrawMessage(int flags)
	{
		String brokentext;
		BrokenString lines;
		[brokentext, lines] = BrokenString.BreakString(StringTable.Localize(text, false), 300, true, "C");
		int lineheight = int(SmallFont.GetHeight());

		if (key && key.length())
		{
			String keystring = ACSTools.GetKeyPressString(key, true, "Dark Gray", "Gray");
			lines.lines.Push(keystring);
			brokentext = brokentext .. "\n" .. keystring;
		}

		double textw = 0;
		double texth = 0;
		for (int lw = 0; lw <= lines.Count(); lw++)
		{
			int width = lines.StringWidth(lw);
			if (width > textw) { textw = width; }

			texth += lineheight;
		}

		double posx, posy;
		
		if (flags & MSG_FULLSCREEN)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();

			posx = Screen.GetWidth() / hudscale.x / 2;
			posy = Screen.GetHeight() / hudscale.y - 8.0;
		
			if (!player.mo.FindInventory("CutsceneEnabled"))
			{
				Vector2 hudscale = StatusBar.GetHUDScale();

				ThinkerIterator it = ThinkerIterator.Create("StealthBase", Thinker.STAT_DEFAULT - 2);
				if (StealthBase(it.Next())) { posy -= 32.0; }
			}

			posy -= texth;

			for (int l = 0; l <= lines.Count(); l++)
			{
				DrawToHUD.DrawText(lines.StringAt(l), (posx, posy), SmallFont, 1.0, 1.0 * hudscale.y, (640, 480), Font.CR_GRAY, ZScriptTools.STR_CENTERED);
				posy += lineheight;
			}
		}
		else
		{
			double uiscale = BoAStatusBar.GetUIScale(st_scale);
			posx = 320.0;
			posy = 480.0 * StatusBar.GetTopOfStatusBar() / Screen.GetHeight() - 8.0 * uiscale;
		
			if (!player.mo.FindInventory("CutsceneEnabled"))
			{
				ThinkerIterator it = ThinkerIterator.Create("StealthBase", Thinker.STAT_DEFAULT - 2);
				if (StealthBase(it.Next())) { posy -= 8.0 * uiscale; }
			}

			posy -= texth;

			for (int l = 0; l <= lines.Count(); l++)
			{
				screen.DrawText(SmallFont, Font.CR_GRAY, posx - lines.StringWidth(l) / 2, posy, lines.StringAt(l), DTA_VirtualWidth, 640, DTA_VirtualHeight, 480, DTA_Alpha, alpha);
				posy += lineheight;
			}
		}
	}
}

class MessageHandler : EventHandler
{
	Array<MessageBase> messages;
	Array<class<MessageBase> > types;
	String active[8];
	int flags;

	override void WorldTick()
	{
		if (!messages.Size())
		{
			active[consoleplayer] = "";
			return;
		}

		flags = 0;

		CVar altstyle = CVar.FindCVar("boa_altmessagestyle");
		if (screenblocks == 11 || Screen.GetHeight() > Screen.GetWidth() || (altstyle && altstyle.GetBool())) { flags |= MessageBase.MSG_FULLSCREEN; }
		
		// Allow one of each type of message to be viewed at once
		for (int t = 0; t < types.Size(); t++)
		{
			if (!types[t]) { continue; }

			MessageBase m = NextMessage(types[t]);
			if (m) { TickMessage(m); }
		}
	}

	void TickMessage(MessageBase m)
	{
		if (m)
		{
			if (m.ticker > m.time)
			{
				m.End();

				int i = messages.Find(m);
				if (i < messages.Size()) { messages.Delete(i); }
			}
			else
			{
				if (m.ticker == 0 && m.player == players[consoleplayer])
				{
					m.Start();

					// Flag so that we can try not to fade message backgrounds and icons in between messages with the same name
					if (!!(active[consoleplayer] == m.msgname)) { flags |= MessageBase.MSG_NOFADEIN; }

					active[consoleplayer] = m.msgname;
				}

				if (!(flags & MessageBase.MSG_NOFADEOUT) && messages.Size() > 1)
				{
					let nm = messages[1];
					if (nm.msgname == m.msgname) { flags |= MessageBase.MSG_NOFADEOUT; }
				}

				m.DoTick();
			}
		}
	}

	MessageBase NextMessage(class<MessageBase> type)
	{
		for (int a = 0; a < messages.Size(); a++)
		{
			if (messages[a].GetClass() == type) { return messages[a]; }
		}

		return null;
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (screenblocks > 11) { return; }

		for (int a = 0; a < messages.Size(); a++)
		{
			let m = messages[a];

			if (
				m &&
				m.ticker > 0 &&
				e.camera &&
				e.camera == m.player.camera
			)
			{
				m.DrawMessage(flags);
			}
		}
	}
}