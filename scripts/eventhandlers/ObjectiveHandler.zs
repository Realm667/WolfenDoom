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

			int insertat = o;
			for (int l = 0; l < insertat; l++)
			{
				if (handler.objectives[l].order <= order) { continue; }
				insertat = l;
			}

			handler.objectives.Insert(insertat, obj);
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

			DrawToHud.DrawText(status, (x, y), Symbols, alpha, 1.0, (w, h), Font.CR_UNTRANSLATED);
			DrawToHud.DrawText(output, (x + Symbols.StringWidth("  "), y + 1), fnt, alpha, 1.0, (w, h), clr);
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
	transient CVar stats;

	override void OnRegister()
	{
		SetOrder(-500); // Make sure other render overlays display on top of this one
		alt = CVar.FindCVar("boa_hudobjectives");
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

	ui int FindNext(bool secondary = false, int start = -1)
	{
		for (int a = start + 1; a < objectives.Size(); a++)
		{
			if (objectives[a].secondary == secondary) { return a; }
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

		handler.active[pnum] = ++handler.active[pnum] % (2 + (handler.alt.GetInt() == 1));
	}

	override void WorldTick()
	{
		alpha = 1.0;

		int incomplete;
		stats = CVar.FindCVar("boa_hudstats");

		for (int a = 0; a < objectives.Size(); a++)
		{
			if (objectives[a].timer > 0) { objectives[a].timer = max(0, objectives[a].timer - 1); }
			if (!objectives[a].complete || objectives[a].timer != 0) { incomplete++; }
		}

		if (active[consoleplayer] == 2 && !incomplete && (!stats || !stats.GetBool())) { active[consoleplayer] = 0; }
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

		if (active[consoleplayer] == 1)
		{
			bool wide = false;

			WideObjectivesDataHandler dataHandler = WideObjectivesDataHandler(StaticEventHandler.Find("WideObjectivesDataHandler"));
			if (datahandler) { wide = dataHandler.shouldUseWideObjectivesBox(); }

			height = 0;
			DrawChalkboard(wide);
		}
	}

	ui void DrawChalkboard(bool wide = false)
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

		int o;
		
		//  Draw the objectives, in order
		o = FindNext(false);
		while (o != objectives.Size())
		{
			if (objectives[o].text.length())
			{
				objectives[o].DrawObjective(fnt, int(posx), int(posy), destsize.x, destsize.y, alpha); // Call each objective's internal drawing function
				posy += lineheight;
			}
			o = FindNext(false, o);
		}

		// Draw secondary objectives
		//  Draw the title
		screen.DrawText(SmallFont, Font.CR_UNTRANSLATED, posx, posy, secondary, DTA_VirtualWidthF, destsize.x, DTA_VirtualHeightF, destsize.y, DTA_Alpha, alpha);
		posy += lineheight;

		//  Draw the objectives, in order
		o = FindNext(true);
		while (o != objectives.Size())
		{
			if (objectives[o].text.length())
			{
				objectives[o].DrawObjective(fnt, posx, posy, destsize.x, destsize.y, alpha); // Call each objective's internal drawing function
				posy += lineheight;
			}
			o = FindNext(true, o);
		}
	}
}

class ObjectivesWidget : Widget
{
	ObjectiveHandler handler;
	transient CVar stats;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		ObjectivesWidget wdg = ObjectivesWidget(Widget.Init("ObjectivesWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));
		
		if (wdg)
		{
			wdg.margin[0] = 4;
			wdg.margin[1] = 8;
		}
	}

	override bool SetVisibility()
	{
		if (!handler) { handler = ObjectiveHandler(EventHandler.Find("ObjectiveHandler")); }

		if (
				(
					(!stats || !stats.GetBool()) && 
					(!handler.objectives.Size() && !level.total_monsters && !level.total_secrets && !level.total_items)
				) ||
				automapactive ||
				screenblocks > 11 ||
				player.mo.FindInventory("CutsceneEnabled") ||
				(player.morphtics && player.mo is "KeenPlayer")
		)
		{
			return false;
		}

		if (handler.active[player.mo.PlayerNumber()] == 2 || (handler.alt && handler.alt.GetInt() > 1)) { return true; }
		
		return false;
	}

	override Vector2 Draw()
	{
		if (!handler) { handler = ObjectiveHandler(EventHandler.Find("ObjectiveHandler")); }

		Vector2 destsize = (320, 200);

		Font fnt = Font.GetFont("THREEFIV");
		String monsters = StringTable.Localize("AM_MONSTERS", false);
		String secrets = StringTable.Localize("AM_SECRETS", false);
		String items = StringTable.Localize("AM_ITEMS", false);
		stats = CVar.FindCVar("boa_hudstats");

		int lineheight = fnt.GetHeight() + 2;
		int boxheight = 0;
		int boxwidth = 0;

		bool drawspace = false;
		int count = 0;

		for (int l = 0; l < handler.objectives.Size(); l++)
		{
			let o = handler.objectives[l];

			String line = StringTable.Localize(o.text, false);
			boxwidth = max(boxwidth, fnt.StringWidth(line));

			if (o.text.length() && (!o.complete || o.timer > 0))
			{
				double height = lineheight;

				if (!drawspace && o.secondary)
				{
					drawspace = true;
					height *= 1.5 * (o.timer == -1 ? 1.0 : min(1.0, o.timer / 15.0));
				}
				else
				{
					height *= o.timer == -1 ? 1.0 : min(1.0, o.timer / 15.0);
				}

				count++;
				boxheight += int(height);
			}
		}

		boxwidth += SmallFont.StringWidth("  ");
		
		int linewidth = 0, printstats = 0;
		String temp = "  : XXX/XXX";

		if (stats && stats.GetBool())
		{
			if (am_showmonsters || am_showsecrets || am_showitems)
			{
				boxheight += int(lineheight * (!!count ? 1.5 : 1.0));
				int strwidth = HUDFont.StringWidth(temp) + 5;

				if (am_showmonsters && level.total_monsters > 0)
				{
					linewidth += strwidth;
					printstats++;
				}
				if (am_showsecrets && level.total_secrets > 0)
				{
					if (linewidth > 0) { linewidth += 1;}
					linewidth += strwidth;
					printstats++;
				}
				if (am_showitems && level.total_items > 0)
				{
					if (linewidth > 0) { linewidth += 1;}
					linewidth += strwidth;
					printstats++;
				}

				boxwidth = max(boxwidth, linewidth);
			}
		}

		if (boxheight == 0) { return (0, 0); }
		
		size = (boxwidth, boxheight);
		Super.Draw();

		Vector2 drawpos = pos;

		// Draw primary objectives
		int o;
		
		//  Draw the primary objectives
		o = handler.FindNext(false);
		while (o != handler.objectives.Size())
		{
			let ob = handler.objectives[o];

			if (ob.text.length() && (!ob.complete || ob.timer > 0))
			{
				ob.DrawObjective(fnt, drawpos.x, drawpos.y, destsize.x, destsize.y, alpha, 1); // Call each objective's internal drawing function
				double height = lineheight * (ob.timer == -1 ? 1.0 : min(1.0, ob.timer / 15.0));
				drawpos.y += height;
			}
			o = handler.FindNext(false, o);
		}

		// Draw secondary objectives
		if (drawspace) { drawpos.y += lineheight / 2; }

		//  Draw the objectives, in order
		o = handler.FindNext(true);
		while (o != handler.objectives.Size())
		{
			let ob = handler.objectives[o];

			if (ob.text.length() && (!ob.complete || ob.timer > 0))
			{
				ob.DrawObjective(fnt, drawpos.x, drawpos.y, destsize.x, destsize.y, alpha, 1); // Call each objective's internal drawing function
				double height = lineheight * (ob.timer == -1 ? 1.0 : min(1.0, ob.timer / 15.0));
				drawpos.y += height;
			}
			o = handler.FindNext(true, o);
		}

		if (count) { drawpos.y += lineheight / 2.0; }

		if (stats && stats.GetBool() && printstats)
		{
			Font Symbols = Font.GetFont("Symbols");

			int step = int(boxwidth / printstats + 1);
			double textpos = drawpos.x + step / 2;

			DrawToHud.Dim(0x0, 0.2 * alpha, int(drawpos.x - (margin[3] - 3)), int(drawpos.y - 1), int(size.x + (margin[3] + margin[1]) - 6), HUDFont.GetHeight() + 3);
			
			if (am_showmonsters && level.total_monsters > 0)
			{
				temp = String.Format("  : %i/%i", level.killed_monsters, level.total_monsters);
				DrawToHud.DrawText("💀", (textpos - HUDFont.StringWidth(temp) / 2, drawpos.y - 1), Symbols, alpha, shade:Font.CR_UNTRANSLATED, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_CENTERED);
				StatusBar.DrawString(BoAStatusBar(StatusBar).mHUDFont, temp, (textpos, drawpos.y), StatusBar.DI_TEXT_ALIGN_CENTER, Font.CR_GRAY, alpha);
				textpos += step;
			}

			if (am_showsecrets && level.total_secrets > 0)
			{
				temp = String.Format("  : %i/%i", level.found_secrets, level.total_secrets);
				DrawToHud.DrawText("⚑", (textpos - HUDFont.StringWidth(temp) / 2, drawpos.y - 1), Symbols, alpha, shade:Font.CR_UNTRANSLATED, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_CENTERED);
				StatusBar.DrawString(BoAStatusBar(StatusBar).mHUDFont, temp, (textpos, drawpos.y), StatusBar.DI_TEXT_ALIGN_CENTER, Font.CR_GRAY, alpha);
				textpos += step;
			}

			if (am_showitems && level.total_items > 0)
			{
				temp = String.Format("  : %i/%i", level.found_items, level.total_items);
				DrawToHud.DrawText("🪙", (textpos - HUDFont.StringWidth(temp) / 2, drawpos.y - 1), Symbols, alpha, shade:Font.CR_UNTRANSLATED, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_CENTERED);
				StatusBar.DrawString(BoAStatusBar(StatusBar).mHUDFont, temp, (textpos, drawpos.y), StatusBar.DI_TEXT_ALIGN_CENTER, Font.CR_GRAY, alpha);
			}
		}

		return size;
	}
}