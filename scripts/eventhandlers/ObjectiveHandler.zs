class Objective : Thinker
{
	String text;
	int order;
	bool secondary, complete;
	Font Symbols;

	// This is how to set up objectives directly via ZSCript calls:
	//  ACS: ScriptCall("Objective", "Add", text, num, false, false, true);
	//  ZSCript: Objective.Add(text, order, num, false, false, true);
	//   text:      The text string or localization to display as the objective
	//   order:     The order of the objective in the listing.  You are no longer limited to
	//              only three items for primary and secondary, but still can only show a 
	//              total of six at once on the current background graphic
	//   secondary: false if this is a primary objective, true if secondary
	//   complete:  true if completed, false if not
	//   quiet:     Displays "New Objective Added" message and plays sound if true
	//
	// New additions that share either a text string or order number with an existing 
	// entry will replace the older entry
	//
	static void Add(String text = "", int order = -1, bool secondary = false, int complete = -1, bool quiet = false)
	{
		if (!quiet)
		{
			ObjectiveMessage.Init(null, "MO_ADDED", "OBJADD", "misc/objective_add");
		}

		if (!text.length() && order == -1) { return; }

		ObjectiveHandler handler = ObjectiveHandler(EventHandler.Find("ObjectiveHandler"));
		if (!handler) { return; }

		Objective obj;

		int o = handler.Find(text, order);
		if (o == handler.objectives.Size())
		{
			obj = New("Objective");
			handler.objectives.Push(obj);
		}
		else
		{
			obj = handler.objectives[o];
		}

		obj.text = text;
		obj.order = order;
		obj.secondary = secondary;
		if (complete >= 0) { obj.complete = complete; }
		obj.Symbols = Font.GetFont("Symbols");
	}

	static void Completed(String text = "", int order = -1, bool quiet = false)
	{
		if (!quiet)
		{
			ObjectiveMessage.Init(null, "MO_ACCOMP", "OBJICON", "misc/objective_acc");
			BoACompass.Flash();
		}

		if (!text.length() && order == -1) { return; }

		ObjectiveHandler handler = ObjectiveHandler(EventHandler.Find("ObjectiveHandler"));
		if (!handler) { return; }

		int o = handler.Find(text, order);
		if (o == handler.objectives.Size()) { return; }

		handler.objectives[o].complete = true;
	}

	ui virtual void DrawObjective(Font fnt, int x, int y, int w = 800, int h = 600, double alpha = 1.0)
	{
		// Use unicode check mark characters; print untranslated because the check is green
		String status = complete ? "☑" : "☐";
		String output = complete ? StringTable.Localize("MO_ICON_ACC", false) : StringTable.Localize("MO_ICON_OPN", false);

		output = output .. StringTable.Localize(text, false);

		screen.DrawText(Symbols, Font.CR_UNTRANSLATED, x, y, status, DTA_VirtualWidthF, w, DTA_VirtualHeightF, h, DTA_Alpha, alpha);
		screen.DrawText(SmallFont, Font.CR_UNTRANSLATED, x + SmallFont.StringWidth("  "), y, output, DTA_VirtualWidthF, w, DTA_VirtualHeightF, h, DTA_Alpha, alpha);
	}
}

class ObjectiveHandler : EventHandler
{
	Array<Objective> objectives;
	bool active[players.Size()];
	double alpha;

	override void OnRegister()
	{
		SetOrder(-500); // Make sure other render overlays display on top of this one
	}

	// Search for an objective by either string value or index order
	int Find(String text, int order = -1)
	{
		int a;

		if (text.length())
		{
			for (a = 0; a < objectives.Size(); a++)
			{
				if (objectives[a].text ~== text) { return a; }
			}
		}

		if (order > -1)
		{
			for (a = 0; a < objectives.Size(); a++)
			{
				if (objectives[a].order == order) { return a; }
			}		
		}

		return objectives.Size();
	}

	ui int FindNext(bool secondary = false, int order = 0)
	{
		for (int a = 0; a < objectives.Size(); a++)
		{
			if (
				objectives[a].secondary == secondary &&
				objectives[a].order == order
			) { return a; }
		}

		return objectives.Size();
	}

	static void Toggle(Actor mo)
	{
		if (!mo || level.levelnum == 99) { return; }

		int pnum = mo.PlayerNumber();
		if (pnum < 0 || mo is "KeenPlayer") { return; }

		ObjectiveHandler handler = ObjectiveHandler(EventHandler.Find("ObjectiveHandler"));
		if (!handler) { return; }

		handler.active[pnum] = !handler.active[pnum];
	}

	override void WorldTick()
	{
		alpha = 1.0;
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (
			!active[consoleplayer] || // And only if they have the objectives toggled on
			screenblocks > 11 // And don't show objectives when no hud is visible (screenblocks 12)
		) { return; } 

		bool wide = false;
		TextureID bgtex;
		Vector2 destsize = (800, 600);

		String primary = StringTable.Localize("MO_PRIMARY", false);
		String secondary = StringTable.Localize("MO_SECONDARY", false);

		WideObjectivesDataHandler dataHandler = WideObjectivesDataHandler(StaticEventHandler.Find("WideObjectivesDataHandler"));
		if (datahandler) { wide = dataHandler.shouldUseWideObjectivesBox(); }

		if (wide) { bgtex = TexMan.CheckForTexture("OBJECTGY"); }
		else { bgtex = TexMan.CheckForTexture("OBJECTGX"); }

		double posx = 400;
		double posy = 115;
		int lineheight = 13;

		if (bgtex.IsValid())
		{
			Vector2 size = TexMan.GetScaledSize(bgtex);
			screen.DrawTexture(bgtex, true, posx, posy + size.y / 2, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_CenterOffset, true, DTA_Alpha, alpha);
		}

		posx = wide ? 260 : 300;
		posy += 20;

		// Draw primary objectives
		//  Draw the title
		screen.DrawText(SmallFont, Font.CR_UNTRANSLATED, posx, posy, primary, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_Alpha, alpha);
		posy += lineheight;

		int count = 0;
		int o;
		
		//  Draw the objectives, in order
		o = FindNext(false, count++);
		while (o != objectives.Size())
		{
			objectives[o].DrawObjective(SmallFont, int(posx), int(posy), int(destsize.x), int(destsize.y), alpha); // Call each objective's internal drawing function
			posy += lineheight;
			o = FindNext(false, count++);
		}

		// Draw secondary objectives
		//  Draw the title
		screen.DrawText(SmallFont, Font.CR_UNTRANSLATED, posx, posy, secondary, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_Alpha, alpha);
		posy += lineheight;

		count--;

		//  Draw the objectives, in order
		o = FindNext(true, count++);
		while (o != objectives.Size())
		{
			objectives[o].DrawObjective(SmallFont, int(posx), int(posy), int(destsize.x), int(destsize.y), alpha); // Call each objective's internal drawing function
			posy += lineheight;
			o = FindNext(true, count++);
		}
	}
}
