class Objective : Thinker
{
	String text;
	int order;
	bool secondary, complete;
	String symbolfont;
	transient ui Font Symbols;
	int timer;

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
		obj.symbolfont = "Symbols";
		obj.timer = -1;
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
		handler.objectives[o].timer = 70;
	}

	ui virtual void DrawObjective(Font fnt, double x, double y, double w = 800, double h = 600, double alpha = 1.0, bool mode = 0)
	{
		String output = StringTable.Localize(text, false);

		if (!Symbols) { Symbols = Font.GetFont(symbolfont); }

		// Use unicode check mark characters; print untranslated because the check is green
		String status = complete ? "☑" : "☐";

		if (mode == 1)
		{
			Vector2 hudscale = StatusBar.GetHudScale();

			int clr = Font.CR_WHITE;
			if (complete)
			{
				clr = Font.CR_GOLD;

				if (timer <= 50)
				{
					alpha *= (timer - 15) / 35.0;
					alpha = clamp(alpha, 0.0, 1.0);
				}
			}

			DrawToHud.DrawText(status, (x, y), Symbols, alpha, hudscale.y, (w, h), Font.CR_UNTRANSLATED);
			DrawToHud.DrawText(output, (x + Symbols.StringWidth("  "), y + 1), fnt, alpha, hudscale.y, (w, h), clr);
		}
		else
		{
			output = (complete ? StringTable.Localize("MO_ICON_ACC", false) : StringTable.Localize("MO_ICON_OPN", false)) .. output;

			screen.DrawText(Symbols, Font.CR_UNTRANSLATED, x, y, status, DTA_VirtualWidthF, w, DTA_VirtualHeightF, h, DTA_Alpha, alpha);
			screen.DrawText(fnt, Font.CR_UNTRANSLATED, x + fnt.StringWidth("  "), y, output, DTA_VirtualWidthF, w, DTA_VirtualHeightF, h, DTA_Alpha, alpha);
		}
	}
}

class ObjectiveHandler : EventHandler
{
	Array<Objective> objectives;
	int active[players.Size()];
	double alpha;
	ui int height;
	transient CVar alt;

	override void OnRegister()
	{
		SetOrder(-500); // Make sure other render overlays display on top of this one
		alt = CVar.FindCVar("boa_altobjectivestyle");
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

		handler.active[pnum] = ++handler.active[pnum] % (2 + handler.alt.GetBool());
	}

	override void WorldTick()
	{
		alpha = 1.0;

		int incomplete;

		for (int a = 0; a < objectives.Size(); a++)
		{
			if (objectives[a].timer > 0) { objectives[a].timer = max(0, objectives[a].timer - 1); }
			if (!objectives[a].complete || objectives[a].timer != 0) { incomplete++; }
		}


		if (active[consoleplayer] == 2 && !incomplete) { active[consoleplayer] = 0; }
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (
			!active[consoleplayer] || // And only if they have the objectives toggled on
			screenblocks > 11 || // And don't show objectives when no hud is visible (screenblocks 12)
			automapactive // Or if the automap is active
		)
		{
			height = 0;
			return;
		} 

		if (active[consoleplayer] == 2 && alt.GetBool())
		{
			height = DrawMinimal(-4, 10);
		}
		else
		{
			bool wide = false;

			WideObjectivesDataHandler dataHandler = WideObjectivesDataHandler(StaticEventHandler.Find("WideObjectivesDataHandler"));
			if (datahandler) { wide = dataHandler.shouldUseWideObjectivesBox(); }

			height = 0;
			DrawChalkBoard(wide);
		}
	}

	ui void DrawChalkBoard(bool wide = false)
	{
		TextureID bgtex;

		Vector2 hudscale = StatusBar.GetHudScale();
		Vector2 destsize = (800, 600);

		String primary = StringTable.Localize("MO_PRIMARY", false);
		String secondary = StringTable.Localize("MO_SECONDARY", false);

		double posx, posy;
		int lineheight = 13;
		Font fnt = SmallFont;

		if (wide) { bgtex = TexMan.CheckForTexture("OBJECTGY"); }
		else { bgtex = TexMan.CheckForTexture("OBJECTGX"); }

		posx = destsize.x / 2;
		posy = destsize.y / 5;

		if (bgtex.IsValid())
		{
			Vector2 size = TexMan.GetScaledSize(bgtex);
			screen.DrawTexture(bgtex, true, posx, posy + size.y / 2, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_CenterOffset, true, DTA_Alpha, alpha);
		}

		posx -= wide ? 140 : 100;
		posy += destsize.y / 30;

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
			objectives[o].DrawObjective(fnt, int(posx), int(posy), destsize.x, destsize.y, alpha); // Call each objective's internal drawing function
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
			objectives[o].DrawObjective(fnt, posx, posy, destsize.x, destsize.y, alpha); // Call each objective's internal drawing function
			posy += lineheight;
			o = FindNext(true, count++);
		}
	}

	ui int DrawMinimal(double posx = 5, double posy = 11)
	{
		Vector2 destsize = (320, 200);

		Font fnt = Font.GetFont("THREEFIV");
		int lineheight = fnt.GetHeight() + 2;
		int boxheight = 0;
		int boxwidth = 0;

		bool drawspace = false;

		for (int l = 0; l < objectives.Size(); l++)
		{
			String line = StringTable.Localize(objectives[l].text, false);
			boxwidth = max(boxwidth, fnt.StringWidth(line));

			if (!objectives[l].complete || objectives[l].timer > 0)
			{
				double height = lineheight;

				if (!drawspace && objectives[l].secondary)
				{
					drawspace = true;
					height *= 1.5 * (objectives[L].timer == -1 ? 1.0 : min(1.0, objectives[l].timer / 15.0));
				}
				else
				{
					height *= objectives[L].timer == -1 ? 1.0 : min(1.0, objectives[l].timer / 15.0);
				}

				boxheight += int(height);
			}
		}

		boxwidth += lineheight + SmallFont.StringWidth("  ");

		if (boxheight == 0) { return 0; }
		boxheight += lineheight;

		if (posx < 0) { posx -= boxwidth; }
		if (posy < 0) { posy -= boxheight; }

		DrawToHUD.DrawFrame("FRAME_", int(posx - lineheight / 2), int(posy - lineheight / 2), boxwidth, boxheight, 0x1b1b1b, 1.0, 0.53);

		// Draw primary objectives
		int count = 0, shown = 0;
		int o;
		
		//  Draw the objectives, in order
		o = FindNext(false, count++);
		while (o != objectives.Size())
		{
			if (!objectives[o].complete || objectives[o].timer > 0)
			{
				objectives[o].DrawObjective(fnt, posx, posy, destsize.x, destsize.y, alpha, 1); // Call each objective's internal drawing function
				double height = lineheight * (objectives[o].timer == -1 ? 1.0 : min(1.0, objectives[o].timer / 15.0));
				posy += height;
				shown++;
			}
			o = FindNext(false, count++);
		}

		// Draw secondary objectives
		if (shown) { posy += lineheight / 2; }

		count--;

		//  Draw the objectives, in order
		o = FindNext(true, count++);
		while (o != objectives.Size())
		{
			if (!objectives[o].complete || objectives[o].timer > 0)
			{
				objectives[o].DrawObjective(fnt, posx, posy, destsize.x, destsize.y, alpha, 1); // Call each objective's internal drawing function
				double height = lineheight * (objectives[o].timer == -1 ? 1.0 : min(1.0, objectives[o].timer / 15.0));
				posy += height;
				shown++;
			}
			o = FindNext(true, count++);
		}

		return boxheight;
	}
}