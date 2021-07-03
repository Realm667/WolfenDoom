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

// This code replaces ACS-based messages that were originally coded by:
//   Dialogue Messages:     Ed the Bat, with work by MaxED, Talon1024, and Ozymandias81
//   Developer Messages:    Talon1024
//   Hint Messages:         AFADoomer
//
// While minimal code was directly taken from the ACS implementation, their work served
// as the template for the creation of the message classes below.

// Base class that all message objects inherit from
//  Used to store message attributes and to initialize messages, as well as to
//  hold functions specific to each message type.  
class MessageBase : Thinker
{
	enum msgflags
	{
		MSG_DEFAULT = 0,
		MSG_NOFADEIN = 1,
		MSG_NOFADEOUT = 2,
		MSG_FULLSCREEN = 4,
		MSG_ALLOWREPLACE = 8,
		MSG_ALLOWMULTIPLE = 16,
		MSG_PERSIST = 32
	}

	MessageHandler handler;

	String text;
	String msgname;
	int time, intime, outtime, priority;
	PlayerInfo player;

	int flags;
	double alpha;
	int ticker;
	int delay;

	// How far the message extends into the screen.  Negative value means bottom of screen.
	ui double protrusion;

	// Broken string handling
	transient ui double width;
	ui String brokentext;
	transient ui BrokenString lines;

	static MessageBase Init(Actor mo, String msgname, String text, int intime, int outtime, class<MessageBase> type = "MessageBase", int priority = 0, int flags = 0)
	{
		let handler = MessageHandler.Get();
		if (!handler) { return null; }

		MessageBase msg;

		if (flags & MSG_ALLOWREPLACE)
		{
			// If a message with this name already exists, allow replacing it.
			// Reset the ticker and set the fade-in time to zero.
			msg = handler.FindMessage(msgname);
			if (msg)
			{
				msg.ticker = !!msg.ticker; // Make sure an active message is set to 1 tick; inactive is still zero
				intime = 0;
			}
		}

		if (!msg)
		{
			msg = MessageBase(New(type));
			msg.msgname = msgname;
			msg.handler = handler;
			msg.priority = priority;

			int insertat = handler.messages.Size();

			for (int m = 0; m < insertat; m++)
			{
				if (handler.messages[m].priority <= priority) { continue; }

				insertat = m;
			}

			handler.messages.Insert(insertat, msg);

			// If multiple are allowed to be shown on screen at once, make sure they all stay 
			// visible and can't disappear at once if they all are shown at the same time
			if (msg.flags & MSG_ALLOWMULTIPLE && insertat > 0 && handler.messages[insertat - 1].priority == priority) { msg.time = handler.messages[insertat - 1].time - handler.messages[insertat - 1].ticker; }
		}

		msg.text = text;
		msg.time += ZScriptTools.GetMessageTime(text) + intime + outtime;
		msg.intime = intime;
		msg.outtime = outtime;
		msg.flags = flags;

		PlayerInfo player;
		if (mo && mo.player) { player = mo.player; }
		else { player = players[consoleplayer]; }
		msg.player = player;

		// Add this type of message to the handler if it wasn't already aware of it
		if (handler.types.Find(type) == handler.types.Size()) { handler.types.Push(type); }

		// Log the message to the console, emulating built-in message printing
		if (player && text.length())
		{
			player.SetLogText("\cL----------------------------------------");
			player.SetLogText("$" .. text);
			player.SetLogText("\cL----------------------------------------");
		}

		return msg;
	}

	// Tick the function and calculate fade in/out alpha values
	virtual void DoTick()
	{
		delay = max(0, delay - 1);
		
		if (delay == 0)
		{
			if (!handler) { handler = MessageHandler.Get(); }

			ticker++;

			if (intime > 0 && ticker < intime) { alpha = ticker / double(intime); }
			else if (ticker > time - outtime)
			{
				if (outtime > 0) { alpha = (time - ticker) / double(outtime); }
				else { alpha = 0.0; }
			}
			else { alpha = 1.0; }

			alpha = clamp(alpha, 0.0, 1.0);
		}
		else
		{
			ticker = 0;
			alpha = 0.0;
		}
	}

	// Stop drawing the message with a specific name
	static void Clear(String msgname, int outtime = 0)
	{
		if (!msgname.length()) { return; }

		let handler = MessageHandler.Get();
		if (!handler) { return; }

		MessageBase msg = handler.FindMessage(msgname);
		if (msg)
		{
			// Set up the message to fade immediately with the passed in outtime in tics
			msg.outtime = outtime;
			msg.time = msg.ticker + outtime;
		}
	}

	// Code to run at start of message fade-in
	virtual void Start() {}

	// Code to run at end of message fade-out
	virtual void End() {}

	// Return the duration of the message in tics; modified in other classes to accomodate type-on speed
	virtual int GetTime() { return time; }

	// Draw the message
	virtual ui double DrawMessage() { return 0; }
}

// Standard top-of-screen NPC message
class Message : MessageBase
{
	ui int msgwidth, barwidth;
	String icon;
	double typespeed;
	String charname; // Name of NPC - useful for player follower and spy messages
	ui String fulltext;

	static int Init(Actor mo, String icon, String text, int intime = 35, int outtime = 35)
	{
		Message msg = Message(MessageBase.Init(mo, icon, text, intime, outtime, "Message", 1));
		if (msg)
		{
			msg.icon = icon;
			MessageLogHandler.Add(String.Format("|%s", msg.text));

			return msg.GetTime();
		}

		return 0;
	}

	// For player followers, briefings, and undercover allied spies
	static int InitWithName(Actor mo, String icon, String text, String charname, int intime = 35, int outtime = 35)
	{
		Message msg = Message(MessageBase.Init(mo, icon, text, intime, outtime, "Message", 1));
		if (msg)
		{
			msg.charname = charname;
			msg.icon = icon;
			MessageLogHandler.Add(String.Format("%s|%s", msg.charname, msg.text));

			return msg.GetTime();
		}

		return 0;
	}

	override void Start()
	{
		if (!handler.fullscreen) { player.mo.SetInventory("IncomingMessage", 1); }
		player.mo.A_StartSound("RADIONOS", CHAN_AUTO, CHANF_LOCAL);

		time = max(time, ZScriptTools.PlaySound(player.mo, text));
	}

	override void End()
	{
		player.mo.SetInventory("IncomingMessage", 0);
	}

	override int GetTime()
	{
		return int(time / (typespeed > 0 ? typespeed : 1.0));
	}

	override double DrawMessage()
	{
		if (width == 0)
		{
			fulltext = StringTable.Localize(charname, false);
			// Character name is given
			if (fulltext.Length()) { fulltext = fulltext .. "\cC"; }
			fulltext = fulltext .. StringTable.Localize(text, false);
		}

		if (flags & MSG_FULLSCREEN)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();
			barwidth = int(min(Screen.GetHeight() / hudscale.y, Screen.GetWidth() / hudscale.x - 240));
			msgwidth = barwidth - 64;
		}
		else { msgwidth = 540; }

		Vector2 destsize = (640, 400);
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

		int typeticks = int((ticker - 35) * (typespeed > 0 ? typespeed : 1.0));

		if (width != msgwidth)
		{
			[brokentext, lines] = BrokenString.BreakString(fulltext, msgwidth, false, "C");

			width = msgwidth;
		}
		if (flags & MSG_FULLSCREEN)
		{
			int lineheight = int(SmallFont.GetHeight());

			Vector2 hudscale = StatusBar.GetHUDScale();
			Vector2 size = (0, 0);

			int x = int(Screen.GetWidth() / hudscale.x / 2 - barwidth / 2); // Position scaled relative to screen center
			int y = int(8 + handler.topoffset * Screen.GetHeight() / hudscale.y);
			int margin = 8;

			if (headtex) { size = TexMan.GetScaledSize(headtex) * 1.25; }

			double boxheight = (lines.Count() - 1) * lineheight + margin * 2;
			boxheight = max(boxheight, size.y + margin);
			boxheight += margin;

			DrawToHUD.DrawFrame("FRAME_", x - 4, y - 4, msgwidth + size.x + margin * 4 + 8, boxheight + 8, 0x1b1b1b, 1.0 * staticalpha, 0.53 * staticalpha);

			y += margin;

			if (headtex)
			{
				DrawToHUD.DrawFrame("INSET_", x + margin, y, size.x, size.y - 2, 0x404040, 0.5 * staticalpha);
				DrawToHUD.DrawTexture(headtex, (x + margin, y), staticalpha, 1.25, flags:DrawToHUD.TEX_DEFAULT);
			}

			x += size.x ? int(size.x + margin * 2) : 0;

			if (ticker > 35 && text.length())
			{ // text.length() instead of fulltext.length() because there's no point in just showing the character's name
				ZScriptTools.TypeString(SmallFont, lines, msgwidth, (x, y), typeticks, 1.0, alpha, (destsize.x / 2 * hudscale.x, destsize.y / 2 * hudscale.y), ZScriptTools.STR_LEFT | ZScriptTools.STR_TOP);
			}

			protrusion = (y + boxheight) / (Screen.GetHeight() / hudscale.y);
		}
		else
		{
			double y = handler.topoffset * 200;

			Vector2 bgpos = (160.0, y + 24.0);
			Vector2 headpos = (21.0, y + 16.0);

			bgtex = TexMan.CheckForTexture("HEADBAR");
			ovltex = TexMan.CheckForTexture("HEADBOVL");

			if (bgtex) { screen.DrawTexture(bgtex, true, bgpos.x, bgpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, staticalpha); }
			if (headtex) { screen.DrawTexture(headtex, true, headpos.x, headpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, staticalpha); }
			if (ovltex) { screen.DrawTexture(ovltex, true, bgpos.x, bgpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, staticalpha); }

			y = handler.topoffset * destsize.y;

			if (ticker > 35 && text.length())
			{ // text.length() instead of fulltext.length() because there's no point in just showing the character's name
				ZScriptTools.TypeString(SmallFont, lines, msgwidth, (100.0, y + 4.0), typeticks, 1.0, alpha, destsize, ZScriptTools.STR_LEFT | ZScriptTools.STR_TOP | ZScriptTools.STR_FIXED);
			}

			protrusion = handler.topoffset + 32.0 / 200;
		}

		return protrusion;
	}
}

// This may be overkill, but it is in data scope, which is the default for
// objects, and accessible by both the play and ui contexts
class MessageChangeManager
{
	bool pending;
	clearscope bool Apply()
	{
		if (pending)
		{
			pending = false;
			return true;
		}
		return false;
	}
	clearscope void Pend(bool set)
	{
		pending = set;
	}
}

// Message which stays on screen until removed. The text content can also be replaced.
class BriefingMessage : Message
{
	MessageChangeManager change;

	static int Init(Actor mo, String icon, String text, int intime = 35, int outtime = 35)
	{
		BriefingMessage msg = BriefingMessage(MessageBase.Init(mo, icon, text, intime, outtime, "BriefingMessage"));
		if (msg)
		{
			msg.icon = icon;
			msg.time = 2147483647;
			msg.typespeed = 2.0;
			msg.change = new("MessageChangeManager");
			MessageLogHandler.Add(String.Format("|%s", msg.text));
		
			return msg.GetTime();
		}

		return 0;
	}

	// For player followers, briefings, and undercover allied spies
	static int InitWithName(Actor mo, String icon, String text, String charname, int intime = 35, int outtime = 35)
	{
		BriefingMessage msg = BriefingMessage(MessageBase.Init(mo, icon, text, intime, outtime, "BriefingMessage"));
		if (msg)
		{
			msg.charname = charname;
			msg.icon = icon;
			msg.time = 2147483647;
			msg.typespeed = 2.0;
			msg.change = new("MessageChangeManager");
			MessageLogHandler.Add(String.Format("%s|%s", msg.charname, msg.text));

			return msg.GetTime();
		}

		return 0;
	}

	static BriefingMessage Get()
	{
		let handler = MessageHandler.Get();
		MessageBase msg = handler.NextMessage("BriefingMessage");
		if (msg)
		{
			return BriefingMessage(msg);
		}
		return null;
	}

	// Fade the message out
	static void SetShouldEnd(bool end)
	{
		BriefingMessage msg = BriefingMessage.Get();
		if (!msg) { return; }

		msg.time = msg.ticker;
		msg.outtime = 0;
	}

	// Set the entry to use for the message text
	static int SetEntry(String entry)
	{
		BriefingMessage msg = BriefingMessage.Get();
		if (!msg) { return 0; }
		msg.text = entry;
		// So that briefings work properly
		msg.change.Pend(true);
		// Start typing the new text from the beginning, rather than having it appear all at once.
		msg.ticker = 35;
		MessageLogHandler.Add(String.Format("%s|%s", msg.charname, msg.text));
		return msg.GetTime();
	}

	override void Start()
	{
		if (!handler.fullscreen) { player.mo.SetInventory("IncomingMessage", 1); }

		time = max(time, ZScriptTools.PlaySound(player.mo, text));
	}

	override int GetTime()
	{
		return int(ZScriptTools.GetMessageTime(text) / (typespeed > 0 ? typespeed : 1.0));
	}

	override double DrawMessage()
	{
		if (change.Apply())
		{
			lines.Destroy();
			lines = null;
			width = 0;
		}
		return Super.DrawMessage();
	}
}

// Radio message with 2 icons. The first icon fades into the next one.
class FadeIconMessage : Message
{
	String icon2;

	static int Init(Actor mo, String icon, String icon2, String text, int intime = 35, int outtime = 35)
	{
		FadeIconMessage msg = FadeIconMessage(MessageBase.Init(mo, icon, text, intime, outtime, "FadeIconMessage"));
		if (msg)
		{
			msg.icon = icon;
			msg.icon2 = icon2;
			MessageLogHandler.Add(String.Format("|%s", msg.text));
		
			return msg.GetTime();
		}

		return 0;
	}

	override double DrawMessage()
	{
		protrusion = Super.DrawMessage();

		TextureID ovltex, headtex2;

		if (ticker > 35 && ticker < time * 0.75) { headtex2 = TexMan.CheckForTexture(icon2 .. "!"); }
		if (!headtex2.IsValid()) { headtex2 = TexMan.CheckForTexture(icon2 .. "0"); }

		double staticalpha = alpha;
		if (flags & MSG_NOFADEIN && ticker < 35) { staticalpha = 1.0; }
		else if (flags & MSG_NOFADEOUT && ticker > time - 35) { staticalpha = 1.0; }

		double head2alpha = ticker / double(time - outtime);
		if (ticker > time - outtime) { head2alpha = alpha; }

		if (flags & MSG_FULLSCREEN)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();
			int x = int(Screen.GetWidth() / hudscale.x / 2 - barwidth / 2); // Position scaled relative to screen center
			int y = int(8 + handler.topoffset * Screen.GetHeight() / hudscale.y);
			int margin = 8;

			y += margin;

			if (headtex2)
			{
				DrawToHUD.DrawTexture(headtex2, (x + margin, y), head2alpha, 1.25, flags:DrawToHUD.TEX_DEFAULT);
			}
		}
		else
		{
			double y = handler.topoffset * 200;
			Vector2 headpos = (21.0, y + 16.0);
			Vector2 bgpos = (160.0, y + 24.0);

			ovltex = TexMan.CheckForTexture("HEADBOVL");

			if (headtex2) { screen.DrawTexture(headtex2, true, headpos.x, headpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, head2alpha); }
			if (ovltex) { screen.DrawTexture(ovltex, true, bgpos.x, bgpos.y, DTA_320x200, true, DTA_CenterOffset, true, DTA_Alpha, staticalpha); }
		}

		return protrusion;
	}
}

// Standard bottom-of-screen hint messages
class HintMessage : MessageBase
{
	ui int msgwidth;
	String key;
	ui double textw;
	ui double texth;

	static int Init(Actor mo, String text, String key)
	{
		HintMessage msg = HintMessage(MessageBase.Init(mo, text, text, 20, 20, "HintMessage"));
		if (msg)
		{
			msg.key = key;

			return msg.GetTime();
		}

		return 0;
	}

	override void Start()
	{
		if (!player.mo.FindInventory("CutsceneEnabled")) { player.mo.A_StartSound("menu/change", CHAN_AUTO, CHANF_LOCAL, 0.75); }
	}

	override double DrawMessage()
	{
		int msgwidth = 300;
		int lineheight = int(SmallFont.GetHeight());

		if (width != msgwidth)
		{
			[brokentext, lines] = BrokenString.BreakString(StringTable.Localize(text, false), msgwidth, true, "C");

			if (key && key.length())
			{
				String keystring = ACSTools.GetKeyPressString(key, true, "Dark Gray", "Gray");
				lines.lines.Push(keystring);
				brokentext = brokentext .. "\n" .. keystring;
			}

			for (int lw = 0; lw < lines.Count(); lw++)
			{
				int linewidth = lines.StringWidth(lw);
				if (linewidth > textw) { textw = linewidth; }

				texth += lineheight;
			}

			width = msgwidth;
		}

		Vector2 destsize = (640, 480);
		double posx, posy;
		
		if (flags & MSG_FULLSCREEN && screenblocks > 10)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();

			posx = Screen.GetWidth() / hudscale.x / 2;
			posy = Screen.GetHeight() / hudscale.y - handler.bottomoffset * Screen.GetHeight() / hudscale.y;

			if (player.mo.FindInventory("CutsceneEnabled"))
			{
				posy -= 20 * Screen.GetHeight() / hudscale.y / destsize.y;
				posy -= texth / 2;
			}
			else		
			{
				posy -= 8 * Screen.GetHeight() / hudscale.y / destsize.y;

				ThinkerIterator it = ThinkerIterator.Create("StealthBase", Thinker.STAT_DEFAULT - 2);
				if (StealthBase(it.Next())) { posy -= 32.0; }

				posy -= texth;
			}

			protrusion = -(1.0 - posy * hudscale.y / Screen.GetHeight());

			for (int l = 0; l < lines.Count(); l++)
			{
				DrawToHUD.DrawText(lines.StringAt(l), (posx, posy), SmallFont, alpha, 1.0, destsize, Font.CR_GRAY, ZScriptTools.STR_TOP | ZScriptTools.STR_CENTERED);
				posy += lineheight;
			}
		}
		else
		{
			double uiscale = BoAStatusBar.GetUIScale(st_scale);
			posx = destsize.x / 2;
			posy = destsize.y * StatusBar.GetTopOfStatusBar() / Screen.GetHeight() - 8.0 * uiscale - handler.bottomoffset *destsize.y;
		
			if (!player.mo.FindInventory("CutsceneEnabled"))
			{
				ThinkerIterator it = ThinkerIterator.Create("StealthBase", Thinker.STAT_DEFAULT - 2);
				if (StealthBase(it.Next())) { posy -= 8.0 * uiscale; }
			}

			posy -= texth;

			protrusion = -(1.0 - posy / destsize.y);

			for (int l = 0; l < lines.Count(); l++)
			{
				screen.DrawText(SmallFont, Font.CR_GRAY, posx - lines.StringWidth(l) / 2, posy, lines.StringAt(l), DTA_VirtualWidth, int(destsize.x), DTA_VirtualHeight, int(destsize.y), DTA_Alpha, alpha);
				posy += lineheight;
			}
		}

		return protrusion;
	}
}

class ObjectiveMessage : MessageBase
{
	String image, snd;
	double posx, posy;
	Vector2 destsize;
	int objflags;

	enum MessageFlags
	{
		OBJ_DEFAULT = 0,
		OBJ_HIDETEXT = 1
	}

	static int Init(Actor mo, String text, String image = "", String snd = "", int time = 0, int objflags = 0, double posx = 400, double posy = 135, Vector2 destsize = (800, 600))
	{
		ObjectiveMessage msg = ObjectiveMessage(MessageBase.Init(mo, text, text, 18, 18, "ObjectiveMessage", 0, MSG_ALLOWREPLACE));
		if (msg)
		{
			msg.image = image;
			msg.snd = snd;
			msg.posx = posx;
			msg.posy = posy;
			msg.destsize = destsize;

			if (objflags & OBJ_HIDETEXT) { msg.text = ""; }

			if (time > 0) { msg.time = time; }
			else if (time < 0) { msg.time = 0x7FFFFFFF; }

			msg.objflags = objflags;

			return msg.GetTime();
		}

		return 0;
	}

	override void Start()
	{
		player.mo.A_StartSound(snd, CHAN_AUTO, CHANF_DEFAULT, 0.45);
	}

	override double DrawMessage()
	{
		TextureID tex = TexMan.CheckForTexture(image);
		String msgstr = StringTable.Localize(text, false);

		Vector2 hudscale = StatusBar.GetHUDScale();
		double x = posx / destsize.x * Screen.GetWidth() / hudscale.x;
		double y = posy / destsize.y * Screen.GetHeight() / hudscale.y;

		if (tex.IsValid())
		{
			screen.DrawTexture(tex, true, posx, posy, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_CenterOffset, true, DTA_Alpha, alpha);
		}

		if (msgstr.length())
		{
			screen.DrawText(SmallFont, Font.CR_GRAY, posx - SmallFont.StringWidth(msgstr) / 2, posy - SmallFont.GetHeight() / 2, msgstr, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_Alpha, alpha);
		}

		return 0;
	}
}

// Developer commentary
class DevCommentary : MessageBase
{
	ui int msgwidth, barwidth;
	double typespeed;
	String image;
	ui String title;
	transient ui BrokenString titlelines, textlines;

	static int Init(Actor mo, String text, int intime = 18, int outtime = 18)
	{
		CVar devcom = CVar.FindCVar("boa_devcomswitch");
		if (devcom && !devcom.GetBool()) { return 0; }

		Array<String> input;
		text.Split(input, "|");

		if (input.Size()) { text = input[0]; }
		DevCommentary msg = DevCommentary(MessageBase.Init(mo, text, text, intime, outtime, "DevCommentary", 1));
		if (msg)
		{
			if (msg && input.Size() > 1) { msg.image = input[1]; }
			MessageLogHandler.Add(String.Format("MESSAGELOGTYPE_DEVCOM|%s", text), msg.image);

			return msg.GetTime();
		}

		return 0;
	}

	override int GetTime()
	{
		return int(time / (typespeed > 0 ? typespeed : 1.0));
	}

	override double DrawMessage()
	{
		if (flags & MSG_FULLSCREEN)
		{
			Vector2 hudscale = StatusBar.GetHUDScale();
			barwidth = int(min(Screen.GetHeight() * 1.25 / hudscale.y, Screen.GetWidth() / hudscale.x - 128));
		}
		else
		{
			barwidth = 720;
		}

		Vector2 destsize = (640, 480);
		TextureID imagetex;
		Vector2 size = (0, 0);

		imagetex = TexMan.CheckForTexture(image);
		if (imagetex) { size = TexMan.GetScaledSize(imagetex); }

		msgwidth = int(barwidth - size.x);


		if (width != msgwidth)
		{
			[brokentext, lines] = BrokenString.BreakString(StringTable.Localize(text, false), msgwidth, false, "C");
			[title, titlelines] = BrokenString.BreakString(lines.StringAt(0), msgwidth, false, "C");

			brokentext = "";
			textlines = BrokenString.Init(SmallFont);

			for (int b = 2; b < lines.Count(); b++)
			{
				brokentext = brokentext .. lines.StringAt(b);
				if (b < lines.Count() - 1) { brokentext = brokentext .. "\n"; }

				textlines.lines.Push(lines.lines[b]);
			}

			width = msgwidth;
		}

		int lineheight = int(SmallFont.GetHeight());

		Vector2 hudscale = StatusBar.GetHUDScale();

		int x = int(Screen.GetWidth() / hudscale.x / 2 - barwidth / 2); // Position scaled relative to screen center
		int margin = 4;
		int y;

		if (flags & MSG_FULLSCREEN && screenblocks > 10)
		{
			y = int(Screen.GetHeight() / hudscale.y - handler.bottomoffset * Screen.GetHeight() / hudscale.y);

			if (player.mo.FindInventory("CutsceneEnabled")) { y -= int(64 * Screen.GetHeight() / hudscale.y / destsize.y); }
			else { y -= int(16 * Screen.GetHeight() / hudscale.y / destsize.y); }
		}
		else { y = int(StatusBar.GetTopOfStatusBar() - 32 - handler.bottomoffset * destsize.y); }

		double boxheight = (lines.Count() - 1) * lineheight + margin;
		boxheight = max(boxheight, size.y + margin * 2);
		boxheight += margin;

		y -= int(boxheight);

		protrusion = -(1.0 - (y - margin) * hudscale.y / Screen.GetHeight());

		DrawToHUD.DrawFrame("DEV_", x, y, msgwidth + size.x + margin * 4, boxheight, 0x11273c, 1.0 * alpha, 0.8 * alpha);

		DrawToHUD.DrawTimer(time - ticker, time, 0x265380, (x + msgwidth + size.x + margin * 2, y + 1), 0.4, 0.99 * alpha, "", "");

		if (imagetex) { DrawToHUD.DrawTexture(imagetex, (x + margin, y + 16 + margin), alpha, 1.0, flags:DrawToHUD.TEX_DEFAULT); }

		int bodyx = x + (size.x ? int(size.x + margin * 4) : 0);
		y -= 5; 

		if (ticker > 35)
		{
			if (titlelines.Count()) { ZScriptTools.TypeString(SmallFont, titlelines, msgwidth, (x, y), int((ticker - 35) * 1.5), 1.0, alpha, (destsize.x / 2 * hudscale.x, destsize.y / 2 * hudscale.y), ZScriptTools.STR_LEFT | ZScriptTools.STR_TOP); }
			if (textlines.Count()) { ZScriptTools.TypeString(SmallFont, textlines, msgwidth, (bodyx, y + lineheight * 2 + 4), int((ticker - 35) * 1.5), 1.0, alpha, (destsize.x / 2 * hudscale.x, destsize.y / 2 * hudscale.y), ZScriptTools.STR_LEFT | ZScriptTools.STR_TOP); }
		}

		return protrusion;
	}
}

// Countdowns, enemy counters, etc.
class CountdownMessage : MessageBase
{
	String bkg;
	bool textfadein;

	static int Init(Actor mo, String text = "", int clr = Font.CR_GRAY, int holdtime = 210, int intime = 35, int outtime = 35, String bkg = "HELTHBAR", String msgname = "")
	{
		if (!msgname.length()) { msgname = bkg; }
		CountdownMessage msg = CountdownMessage(MessageBase.Init(mo, msgname, text, intime, outtime, "CountdownMessage", 2, MSG_ALLOWREPLACE | MSG_ALLOWMULTIPLE));
		if (msg)
		{
			msg.time = holdtime + intime + outtime;
			msg.bkg = bkg;

			return msg.GetTime();
		}

		return 0;
	}

	override double DrawMessage()
	{
		Vector2 destsize = (640, 480);
		Vector2 pos = (320.0, handler.topoffset * destsize.y + 32.0);

		TextureID bgtex = TexMan.CheckForTexture(bkg);
		Vector2 size = (0, 0);
		if (bgtex.IsValid())
		{
			size = TexMan.GetScaledSize(bgtex);
			screen.DrawTexture(bgtex, true, pos.x, pos.y, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_CenterOffset, true, DTA_Alpha, alpha); 
		}

		screen.DrawText(BigFont, Font.CR_GRAY, pos.x - BigFont.StringWidth(text) / 2, pos.y - BigFont.GetHeight() / 2, text, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_Alpha, alpha); 

		protrusion = handler.topoffset + size.y / destsize.y;

		return protrusion;
	}
}

// Message when achievements are awarded
class AchievementMessage : MessageBase
{
	String image, snd, bkg;
	double posx, posy;
	Vector2 destsize;
	Color clr;
	String fontname;
	String fontcolor;

	static int Init(Actor mo, String text, String image = "", String snd = "", String bkg = "BG_", Color clr = 0x000000, String fontname = "", String fontcolor = "C")
	{
		AchievementMessage msg = AchievementMessage(MessageBase.Init(mo, text, text, 18, 18, "AchievementMessage", 5, MSG_ALLOWMULTIPLE | MSG_PERSIST));
		if (msg)
		{
			msg.image = image;
			msg.snd = snd;
			msg.delay = 2;
			msg.bkg = bkg;
			msg.clr = clr;
			msg.fontname = !fontname.length() ? "SmallFont" : fontname;
			msg.fontcolor = fontcolor;

			return msg.GetTime();
		}

		return 0;
	}

	override void Start()
	{
		player.mo.A_StartSound(snd, CHAN_AUTO, CHANF_DEFAULT, 0.45);
	}

	override double DrawMessage()
	{
		Font fnt = Font.GetFont(fontname);

		TextureID tex = TexMan.CheckForTexture(image);
		String msgstr = StringTable.Localize(text, false);
		Vector2 destsize = (640, 400);

		int msgwidth = 200;
		int imgsize = 24;
		int margin = 4;
		int boxwidth = msgwidth + imgsize + margin * 2;

		if (width != msgwidth)
		{
			[brokentext, lines] = BrokenString.BreakString(StringTable.Localize(text, false), msgwidth, false, "C");

			width = msgwidth;
		}

		int lineheight = int(fnt.GetHeight());
		Vector2 hudscale = StatusBar.GetHUDScale();

		int x = int(Screen.GetWidth() / hudscale.x / 2 - boxwidth / 2); // Position scaled relative to screen center
		int y = int(16 + margin + handler.topoffset * Screen.GetHeight() / hudscale.y);

		double boxheight = max(imgsize, (lines.Count() - 1) * lineheight) + margin * 2;

		DrawToHUD.DrawFrame(bkg, x - margin, y - margin, boxwidth + margin * 2, boxheight + margin * 2, clr, alpha, alpha);

		if (tex.IsValid()) { DrawToHUD.DrawTexture(tex, (x + margin + imgsize / 2, y + margin + imgsize / 2), alpha, 1.0); }

		for (int l = 0; l < lines.Count(); l++)
		{
			DrawToHUD.DrawText(lines.StringAt(l), (x + imgsize + margin * 3, y), fnt, alpha, 1.0, destsize, Font.CR_GRAY, ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
			y += lineheight;
		}

		return handler.topoffset + (boxheight + margin) / destsize.y;
	}
}

// Handler to manage which messages are drawn
//  Call the message drawer and tick functions and cleans up expired messages
class MessageHandler : EventHandler
{
	Array<MessageBase> messages; // Track all queued messages
	Array<class<MessageBase> > types; // Track each unique type of message.  Classes are added here in MessageBase.Init

	ui double topoffset, bottomoffset;
	bool fullscreen;

	// Retrieve the message handler
	static MessageHandler Get()
	{
		MessageHandler handler = MessageHandler(EventHandler.Find("MessageHandler"));
		return handler;
	}

	ui static double GetOffset(int which = 0) // 0 = top, 1 = bottom
	{
		MessageHandler handler = MessageHandler(EventHandler.Find("MessageHandler"));
		if (!handler) { return 0; }

		if (which == 1) { return handler.bottomoffset; }
		return handler.topoffset;
	}

	override void WorldTick()
	{
		if (!messages.Size()) { return; }

		fullscreen = false;

		CVar altstyle = CVar.FindCVar("boa_altmessagestyle"); // Allow forcing the new-style messages at all aspect ratios
		double ratio = Screen.GetAspectRatio();

		if (
			screenblocks == 11 ||
			ratio < (4.0 / 3) || // Use the new-style menus on odd resolutions narrower than 4:3
			ratio > (16.0 / 9 + 0.00001) || // and on ultra-widescreen resolutions over 16:9
			(altstyle && altstyle.GetBool()) || 
			players[consoleplayer].mo.FindInventory("CutsceneEnabled")
		) { fullscreen = true; }
		
		// Allow one of each type of message to be viewed at once
		for (int t = 0; t < types.Size(); t++)
		{
			if (!types[t]) { continue; }

			int current;
			MessageBase m;
			[m, current] = NextMessage(types[t]);

			if (m)
			{
				if (fullscreen) { m.flags |= MessageBase.MSG_FULLSCREEN; }
				else { m.flags &= ~MessageBase.MSG_FULLSCREEN; }

				if (m.flags & MessageBase.MSG_ALLOWMULTIPLE)
				{
					TickMessage(m);

					MessageBase n;
					[n, current] = NextMessage(types[t], current + 1);

					while(n)
					{
						TickMessage(n);
						[n, current] = NextMessage(types[t], current + 1);
					}
				}
				else
				{
					TickMessage(m);
				}
			}
		}
	}

	// Tick the passed in message and manage fade transition flags
	void TickMessage(MessageBase m)
	{
		if (m)
		{
			int i = messages.Find(m); // Index of current message in the messages array

			if (m.ticker > m.time)
			{
				// Do message end functions
				m.End();

				if (m.flags & MessageBase.MSG_NOFADEOUT)
				{
					// If set to not fade out between this message and the next
					let nm = NextMessage(m.GetClass(), i + 1);
					if (nm)
					{
						// Flag the next message to not fade in and tick it early so the transition is seamless
						if (m.flags & MessageBase.MSG_FULLSCREEN) { nm.flags |= MessageBase.MSG_FULLSCREEN; }
						nm.flags |= MessageBase.MSG_NOFADEIN;
						nm.intime = 0;
						nm.DoTick();
					}
				}

				messages.Delete(i);
			}
			else
			{
				int flags = 0;

				// Do message start functions
				if (m.ticker == 1 && m.delay == 0 && m.player == players[consoleplayer]) { m.Start(); }

				if (m.msgname && !(flags & MessageBase.MSG_NOFADEOUT) && i < messages.Size())
				{
					// If the next message of this class has the same name, don't fade out in between
					let nm = NextMessage(m.GetClass(), i + 1);
					if (nm && nm.msgname == m.msgname) { flags |= MessageBase.MSG_NOFADEOUT; }
				}

				m.flags |= flags;

				m.DoTick();
			}
		}
	}

	// Find the next message of a given class/type, optionally starting at a specific point in the array
	MessageBase, int NextMessage(class<MessageBase> type, int start = 0)
	{
		for (int a = start; a < messages.Size(); a++)
		{
			if (messages[a].GetClass() == type) { return messages[a], a; }
		}

		return null, 0;
	}

	// Find a message with a given name
	MessageBase FindMessage(String msgname, int start = 0)
	{
		for (int a = start; a < messages.Size(); a++)
		{
			if (messages[a].msgname == msgname) { return messages[a]; }
		}

		return null;
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (screenblocks > 11) { return; } // Don't show messages when no hud is visible (screenblocks 12)

		// These are recalculated cumulatively every tick
		topoffset = 0;
		bottomoffset = 0;

		for (int a = 0; a < messages.Size(); a++)
		{
			let m = messages[a];

			if (
				m &&
				m.ticker > 0 && // Only render messages that are currently being ticked
				e.camera && e.camera == m.player.camera // and that belong to the viewing player
			)
			{
				double protrusion = m.DrawMessage(); // Call each message's internal drawing function
				if (!(m.flags & MessageBase.MSG_NOFADEOUT)) { protrusion *= m.alpha; }

				if (protrusion < 0 && -protrusion > bottomoffset) { bottomoffset = -protrusion; }
				else if (protrusion > 0 && protrusion > topoffset) { topoffset = protrusion; }
			}
		}
	}
}

class PersistentMessageHandler : StaticEventHandler
{
	Array<MessageBase> messages;

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) { return; } // Only handle transitions between levels
		MessageHandler handler = MessageHandler(EventHandler.Find("MessageHandler"));
		if (!handler) { return; }

		handler.messages.Clear();

		for (int m = 0; m < messages.Size(); m++)
		{
			if (messages[m])
			{
				messages[m].ChangeStatNum(Thinker.STAT_DEFAULT);
				handler.messages.Insert(handler.messages.Size(), messages[m]);
				if (handler.types.Find(messages[m].GetClass()) == handler.types.Size()) { handler.types.Push(messages[m].GetClass()); }

				messages[m] = null;
			}
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		if (e.IsSaveGame) { return; }
		MessageHandler handler = MessageHandler(EventHandler.Find("MessageHandler"));
		if (!handler) { return; }

		for (int m = 0; m < handler.messages.Size(); m++)
		{
			if (handler.messages[m] && handler.messages[m].flags & MessageBase.MSG_PERSIST)
			{
				handler.messages[m].ChangeStatNum(Thinker.STAT_STATIC);
				handler.messages[m].delay += 35; // Let the initial level load pass
				messages.Insert(messages.Size(), handler.messages[m]);
			}
		}
	}

	static void Add(int at, MessageBase msg)
	{
		PersistentMessageHandler handler = PersistentMessageHandler(StaticEventHandler.Find("PersistentMessageHandler"));
		if (!handler) { return; }

		if (msg.flags & MessageBase.MSG_PERSIST)
		{
			msg.ChangeStatNum(Thinker.STAT_TRAVELLING);
			console.printf("Saved " .. msg.text);
			handler.messages.Insert(at, msg);
		}
	}
}