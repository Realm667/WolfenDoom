/*
 * Copyright (c) 2018-2022 AFADoomer
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

class linespecial
{
	int special;
	Actor activator;
	line linedef;
	bool lineside;
	int arg1;
	int arg2;
	int arg3;
	int arg4;
	int arg5;

	int calltime;
}

class switchtype
{
	Array<String> On;
	Array<String> Off;
	String ActivateSound;
	String DeactivateSound;
	int delay;
}

class InteractionHandler : EventHandler
{
	ParsedValue texturesounds;
	ParsedValue switchconfig;
	
	Array<linespecial> queue;
	Array<switchtype> switches;

	override void OnRegister()
	{
		texturesounds = FileReader.Parse("data/TextureSounds.txt");

		// Pares the switch data into an array for faster lookups
		switchconfig = FileReader.Parse("data/Switches.txt");
		switchconfig.Init();
		ParsedValue switchdefaults = switchconfig.Find("default");
		ParsedValue switchinfo = switchconfig.Find("switch");
		while (switchinfo)
		{
			let sw = New("switchtype");
			FileReader.GetStrings(sw.On, switchinfo, "textures.on", true);
			FileReader.GetStrings(sw.Off, switchinfo, "textures.off", true);

			sw.ActivateSound = FileReader.GetString(switchinfo, "sounds.on", true);
			if (!sw.ActivateSound.length()) { sw.ActivateSound = FileReader.GetString(switchdefaults, "sounds.on", true); }

			sw.DeactivateSound = FileReader.GetString(switchinfo, "sounds.off", true);
			if (!sw.DeactivateSound.length()) { sw.DeactivateSound = FileReader.GetString(switchdefaults, "sounds.off", true); }

			String delay = FileReader.GetString(switchinfo, "actiondelay", true);
			if (!delay.length()) { delay = FileReader.GetString(switchdefaults, "actiondelay", true); }
			sw.delay = delay.ToInt();

			switches.Push(sw);

			switchinfo = switchconfig.Next("switch");
		}
	}

	static String GetSound(String texture)
	{
		InteractionHandler handler = InteractionHandler(EventHandler.Find("InteractionHandler"));
		if (!handler) { return ""; }

		String snd = FileReader.GetString(handler.texturesounds, "TextureSounds." .. texture, true);
		if (!snd.length()) { snd = FileReader.GetString(handler.texturesounds, "TextureSounds.default", true); }

		return snd;
	}

	// Check the switch texture against entries in the data\switches.txt file, and
	// swap the textures and play sounds as appropriate
	static int DoSwitchTexture(Side sidedef, int which = side.mid, Actor thing = null)
	{
		TextureID tex = sidedef.GetTexture(which);
		if (!tex.IsValid()) { return -1; }

		InteractionHandler handler = InteractionHandler(EventHandler.Find("InteractionHandler"));
		if (!handler) { return -1; }

		String texname = TexMan.GetName(tex).MakeUpper();
		String switchsound;
		int delay = -1;
		bool found = false;

		for (int s = 0; s < handler.switches.Size() && !found; s++)
		{
			let sw = handler.switches[s];

			int i = sw.On.Find(texname);
			if (i == sw.On.Size())
			{
				i = sw.Off.Find(texname);
				if (i == sw.Off.Size()) { continue; }
				else
				{
					while (i >= sw.On.Size()) { i--; }
					texname = sw.On[i];
					switchsound = sw.ActivateSound;
					delay = sw.delay;
					found = true;
				}
			}
			else
			{
				while (i >= sw.Off.Size()) { i--; }
				texname = sw.Off[i];
				switchsound = sw.DeactivateSound;
				delay = sw.delay;
				found = true;
			}
		}

		if (found)
		{
			if (switchsound != "")
			{
				if (thing && thing.player) { thing.A_StopSound(CHAN_VOICE); } // Squelch the usefail sound
				S_StartSound(switchsound, CHAN_VOICE, CHANF_LISTENERZ, 1.0);
			}

			tex = TexMan.CheckForTexture(texname);
			if (tex.IsValid()) { sidedef.SetTexture(which, tex); }

			return delay;
		}

		return -1;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "opensafe")
		{
			ThinkerIterator it = ThinkerIterator.Create("Safe", Thinker.STAT_DEFAULT);
			Safe mo;

			while (mo = Safe(Actor(it.Next())))
			{
				if (int(mo.pos.x) != e.args[0] || int(mo.pos.y) != e.args[1] || int(mo.pos.z) != e.args[2]) { continue; }

				mo.DoOpen();
				return;
			}
		}
		else if (e.Name == "testfonts")
		{
			ZScriptTools.TestFonts();
		}
		else if (e.Name == "testuifont")
		{
			ZScriptTools.TestFontFallback();
		}
	}

	override void WorldLinePreActivated(WorldEvent e)
	{
		// If a player uses a line that is a toggleable switch, do the texture 
		// change and queue the line special to be run after the change is complete
		let ln = e.ActivatedLine;

		if (
			ln &&
			ln.special && 
			ln.flags & Line.ML_REPEAT_SPECIAL &&
			e.Thing is "PlayerPawn" && 
			(e.ActivationType == SPAC_USE || e.ActivationType == SPAC_UseBack)
		)
		{
			int delay = -1;

			for (int w = 0; w < 3 && delay < 0; w++)
			{
				delay = DoSwitchTexture(ln.sidedef[0], w, e.thing);
			}

			if (delay > -1)
			{
				// Don't run the line special now; queue it so it can run after the switch appears to activate
				e.ShouldActivate = false;

				linespecial sp = New("Linespecial");
				queue.Push(sp);

				sp.special = ln.special;
				sp.activator = e.Thing;
				sp.linedef = ln;
				sp.lineside = 0;
				sp.arg1 = ln.args[0];
				sp.arg2 = ln.args[1];
				sp.arg3 = ln.args[2];
				sp.arg4 = ln.args[3];
				sp.arg5 = ln.args[4];
				sp.calltime = level.maptime + delay; // Delay must be at least 1 for the action to run after the texture changes
			}
		}
	}

	override void WorldTick()
	{
		// Run queued line actions for toggle switches
		if (queue.Size())
		{
			for (int q = 0; q < queue.Size(); q++)
			{
				if (queue[q].calltime < level.maptime) { queue.Delete(q); }
				else if (queue[q].calltime == level.maptime)
				{
					level.ExecuteSpecial(queue[q].special, queue[q].activator, queue[q].linedef, queue[q].lineside, queue[q].arg1, queue[q].arg2, queue[q].arg3, queue[q].arg4, queue[q].arg5);
				}
			}
		}
	}
}