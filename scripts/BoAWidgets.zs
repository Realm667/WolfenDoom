class Widget ui
{
	enum WidgetPositions
	{
		WDG_TOP = 0,
		WDG_LEFT = 0,
		WDG_BOTTOM = 1,
		WDG_RIGHT = 2,
		WDG_MIDDLE = 4,
		WDG_CENTER = 8
	};

	enum WidgetFlags
	{
		WDG_DRAWFRAME = 1,
		WDG_DRAWFRAME_CENTERED = 2
	};

	int ticker;
	Vector2 setpos, pos, size, offset;
	String widgetname;
	int flags, anchor, margin[4], priority, screenblocksval;
	bool visible;
	double alpha;

	Font BigFont, HUDFont;

	PlayerInfo player;

	static Widget Init(class<Widget> type, String widgetname, int anchor = WDG_TOP | WDG_LEFT, int flags = 0, int priority = 0, Vector2 offset = (0, 0))
	{
		if (!BoAStatusBar(StatusBar)) { return null; }

		Widget w = Widget.Find(widgetname);

		if (!w)
		{
			w = Widget(New(type));
			w.widgetname = widgetname;
			w.priority = priority;
		
			int insertat = BoAStatusBar(StatusBar).widgets.Size();

			for (int g = 0; g < insertat; g++)
			{
				if (BoAStatusBar(StatusBar).widgets[g].priority <= priority) { continue; }

				insertat = g;
			}

			BoAStatusBar(StatusBar).widgets.Insert(insertat, w);
		}

		w.anchor = anchor;
		w.flags = flags;
		w.offset = offset;
		w.player = players[consoleplayer];
		w.BigFont = Font.GetFont("BigFont");
		w.HUDFont = Font.GetFont("ThreeFiv");

		w.margin[0] = 4;
		for (int i = 1; i < 4; i++) { w.margin[i] = -1; }

		w.setpos = (7, 7);

		return w;
	}

	static Widget Find(String widgetname, int start = 0)
	{
		if (!BoAStatusBar(StatusBar)) { return null; }
		
		for (int a = start; a < BoAStatusBar(StatusBar).widgets.Size(); a++)
		{
			if (BoAStatusBar(StatusBar).widgets[a].widgetname == widgetname) { return BoAStatusBar(StatusBar).widgets[a]; }
		}

		return null;
	}

	static void Show(String widgetname)
	{
		Widget w = Widget.Find(widgetname);

		if (w) { w.visible = true; }
	}

	static void Hide(String widgetname)
	{
		Widget w = Widget.Find(widgetname);

		if (w) { w.visible = false; }
	}

	static Widget FindBase(int anchor, int priority)
	{
		if (!BoAStatusBar(StatusBar)) { return null; }
	
		for (int a = 0; a < BoAStatusBar(StatusBar).widgets.Size(); a++)
		{
			let w = BoAStatusBar(StatusBar).widgets[a];
			if (w && w.anchor == anchor && w.priority == priority && w.visible) { return w; }
		}

		return null;
	}

	static Widget FindPrev(int anchor, int start = -1, int priority = 0, bool peer = false)
	{
		if (!BoAStatusBar(StatusBar)) { return null; }

		if (start == -1) { start = BoAStatusBar(StatusBar).widgets.Size() - 1; }
		Widget s = BoAStatusBar(StatusBar).widgets[start];

		for (int a = start; a >= 0; a--)
		{
			let w = BoAStatusBar(StatusBar).widgets[a];
			if (w && w != s && w.visible && w.anchor == anchor)
			{
				if (peer)
				{
					if (w.priority == priority) { return w; }
				}
				else if (w.priority < priority)
				{
					return FindBase(anchor, w.priority);
				}
			}
		}

		return null;
	}

	void CalcRelPos(in out Vector2 pos, int index)
	{
		Vector2 hudscale = StatusBar.GetHudScale();

		Vector2 relpos = (0, 0);

		if (index > -1)
		{
			int spacing = 0;

			let w = FindPrev(anchor, index, priority); // Find the next item down in the 'stack' for this anchor point
			if (w)
			{
				if (anchor & WDG_BOTTOM)
				{
					spacing = w.margin[1] + margin[3] - 2;
					relpos.y = -w.pos.y + spacing;
				}
				else
				{
					spacing = w.margin[3] + margin[1] - 2;
					relpos.y = w.pos.y + w.size.y + spacing;
				}
			}

			let p = FindPrev(anchor, index, priority, true); // Find the next item over at the same priority level for this anchor point
			if (p)
			{
				if (anchor & WDG_RIGHT)
				{
					spacing = p.margin[0] + margin[2] - 2;
					relpos.x = -p.pos.x + spacing;
				}
				else
				{
					spacing = p.margin[2] + margin[0] - 2;
					relpos.x = p.pos.x + p.size.x + spacing;
				}
			}
		}

		setpos.x = 3 + margin[0];
		setpos.x = 3 + margin[1];

		// If this wasn't offset at all, assume it's the first in the stack, and apply edge-of-screen offsets as necessary
		if (relpos.y == 0)
		{
		 	if (BoAStatusBar(Statusbar))
			{
				if (anchor == WDG_RIGHT && vid_fps) { relpos.y += int(NewSmallFont.GetHeight() / BoAStatusBar(Statusbar).GetConScale(con_scale) / hudscale.y); }
				if (!(anchor & WDG_BOTTOM) && !(anchor & WDG_MIDDLE)) { relpos.y += BoAStatusBar(Statusbar).maptop; }
			}

			if (anchor & WDG_BOTTOM && screenblocks < 11) { relpos.y += 32;	}
			
			pos.y = setpos.y + relpos.y;
		}
		else { pos.y = relpos.y; }

		if (relpos.x == 0)
		{
			// Handle offsets if HUD is set up to use forced aspect ratio
			int widthoffset = 0;
			if (BoAStatusbar(StatusBar)) { widthoffset = BoAStatusbar(StatusBar).widthoffset; }

			pos.x = setpos.x + widthoffset;
		}
		else { pos.x = relpos.x; }
	}

	virtual bool SetVisibility()
	{
		if (
				BoAStatusBar(StatusBar) && 
				BoAStatusBar(StatusBar).barstate == StatusBar.HUD_Fullscreen && 
				!automapactive && 
				!player.mo.FindInventory("CutsceneEnabled") &&
				!player.morphtics
			) { return true; }
		
		return false;
	}

	virtual void DoTick(int index = 0)
	{
		visible = SetVisibility();
		if (!visible || size == (0, 0)) { alpha = 0.0; }

		SetMargins();
		CalcRelPos(pos, index);

		Vector2 hudscale = StatusBar.GetHudScale();

		if (anchor & WDG_BOTTOM) { pos.y = -(pos.y + offset.y + size.y); }
		else if (anchor & WDG_MIDDLE) { pos.y += Screen.GetHeight() / hudscale.y / 2; }

		if (anchor & WDG_RIGHT) { pos.x = -(pos.x + offset.x + size.x); }
		else if (anchor & WDG_CENTER)
		{
			int widthoffset = 0;
			if (BoAStatusbar(StatusBar)) { widthoffset = BoAStatusbar(StatusBar).widthoffset; }

			pos.x += (Screen.GetWidth() / hudscale.x) / 2 - widthoffset;
		}

		ticker++;
	}

	void SetMargins()
	{
		// Allow setting just one margin to set all of them, or set just two to also set the mirroring sides
		if (margin[1] == -1) { margin[1] = margin[0]; }
		if (margin[2] == -1) { margin[2] = margin[0]; }
		if (margin[3] == -1) { margin[3] = margin[1]; }
	}

	virtual Vector2 Draw()
	{
		visible = SetVisibility();

		if (
			!visible ||
			(screenblocksval > screenblocks && screenblocks > 9) ||
			(screenblocksval < screenblocks && screenblocks > 10)
		) { alpha = 0.0; }
		if (alpha < 1.0) { alpha = min(1.0, alpha + 1.0 / 18); }

		if (flags & WDG_DRAWFRAME)
		{
			Vector2 framepos = pos + offset;
			if (flags & WDG_DRAWFRAME_CENTERED)
			{
				framepos.x -= size.x / 2;
				framepos.y -= size.y / 2;
			}

			DrawToHUD.DrawFrame("FRAME_", int(framepos.x - margin[0]), int(framepos.y - margin[1]), size.x + margin[0] + margin[2], size.y + margin[1] + margin[3], 0x1b1b1b, alpha, 0.53 * alpha);
		}

		screenblocksval = screenblocks;

		return size;
	}
}

class HealthWidget : Widget
{
	TextureID rctex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		HealthWidget wdg = HealthWidget(Widget.Init("HealthWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos));

		if (wdg)
		{
			wdg.rctex = TexMan.CheckForTexture("HUD_RC");
		}
	}

	override Vector2 Draw()
	{
		size = (103, 33);

		Super.Draw();

		//Mugshot
		DrawMugShot((pos.x, pos.y + 1));

		//Health
		DrawToHud.DrawTexture(rctex, (pos.x + 44, pos.y + 9), alpha);
		DrawToHud.DrawText(String.Format("%3i", player.health), (pos.x + 87, pos.y + 3), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
		DrawToHud.DrawText("%", (pos.x + 100, pos.y + 3), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);

		//Armor
		let armor = player.mo.FindInventory("BasicArmor");
		if (armor != null && armor.Amount > 0)
		{
			DrawToHud.DrawTexture(armor.icon, (pos.x + 44, pos.y + 25), alpha, destsize:(12, 12));
			DrawToHud.DrawText(String.Format("%3i", StatusBar.GetArmorAmount()), (pos.x + 87, pos.y + 19), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
			DrawToHud.DrawText("%", (pos.x + 100, pos.y + 19), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
		}

		return size;
	}

	virtual void DrawMugShot(Vector2 position)
	{
		int flags = MugShot.STANDARD;
		String face = player.mo.face;

		if (NaziWeapon(player.readyweapon) && NaziWeapon(player.readyweapon).bNoRampage) { flags |= MugShot.DISABLERAMPAGE; }

		let disguise = DisguiseToken(player.mo.FindInventory("DisguiseToken", True));
		if (disguise)
		{
			flags |= MugShot.CUSTOM;
			face = disguise.HUDSprite; 
		}

		DrawToHud.DrawTexture(StatusBar.GetMugShot(5, flags, face), position, alpha, centered:false);
	}
}

class CountWidget : Widget
{
	TextureID bagtex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		CountWidget wdg = CountWidget(Widget.Init("CountWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos));

		if (wdg)
		{
			wdg.bagtex = TexMan.CheckForTexture("HUD_COIN");
		}
	}

	override Vector2 Draw()
	{
		size = (64, 21);

		Super.Draw();

		//Money
		int amt = 0;
		let money = player.mo.FindInventory("CoinItem");
		if (money) { amt = money.amount; }

		DrawToHud.DrawTexture(bagtex, (pos.x - 1, pos.y - 1), alpha, centered:false);
		DrawToHud.DrawText(String.Format("%3i", amt), (pos.x + 61, pos.y), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);

		//Time
		String time = level.TimeFormatted();

		if (BoAStatusBar(StatusBar).hour || BoAStatusBar(StatusBar).minute || BoAStatusBar(StatusBar).second)
		{
			time = String.Format("%02i", BoAStatusBar(StatusBar).hour) .. ":" .. String.Format("%02i", BoAStatusBar(StatusBar).minute) .. ":" .. String.Format("%02i", BoAStatusBar(StatusBar).second);
		}

		DrawToHud.Dim(0x0, 0.2 * alpha, int(pos.x - 1), int(pos.y + 13), int(size.x + 2), HUDFont.GetHeight() + 3);
		StatusBar.DrawString(BoAStatusBar(StatusBar).mHUDFont, time, (pos.x + 17, pos.y + 14), alpha:alpha);

		return size;
	}
}

class KeyWidget : Widget
{
	static const String keys[] = { "BoABlueKey", "BoAGreenKey", "BoAYellowKey", "BoAPurpleKey", "BoARedKey", "BoACyanKey", "AstroBlueKey", "AstroYellowKey", "AstroRedKey" };

	TextureID locktex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		KeyWidget wdg = KeyWidget(Widget.Init("KeyWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos));

		if (wdg)
		{
			wdg.locktex = TexMan.CheckForTexture("HUD_LOCK");
		}
	}

	override Vector2 Draw()
	{
		size = (45, 21);

		Super.Draw();

		DrawToHud.DrawTexture(locktex, (pos.x + 1, pos.y + 3), alpha, centered:false);

		//Keys
		for (int k = 0; k < keys.Size(); k++)
		{
			let key = player.mo.FindInventory(keys[k]);
			if (key)
			{
				// Calculate offsets for the correct slot
				int slot = k;
				if (slot > 5) { slot = (k - 6) * 2; } // Make the Astrostein keys use key slots 1, 3, and 5

				int offsetx = 39 - (slot / 2) * 10; // Space key slot columns 10 pixels apart
				int offsety = 1 + (slot % 2) * 10; // Space key slot rows 10 pixels apart

				DrawToHud.DrawTexture(key.icon, (pos.x + offsetx, pos.y + offsety), alpha, centered:false);
			}
		}

		return size;
	}
}

class CurrentAmmoWidget : Widget
{
	TextureID grenadetex, astrogrenadetex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		CurrentAmmoWidget wdg = CurrentAmmoWidget(Widget.Init("CurrentAmmoWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos));

		if (wdg)
		{
			wdg.grenadetex = TexMan.CheckForTexture("HUD_GREN");
			wdg.astrogrenadetex = TexMan.CheckForTexture("HUD_GRAS");
		}
	}

	override Vector2 Draw()
	{
		size = (94, 33);

		Super.Draw();

		//Ammo
		Ammo ammo1, ammo2;
		int ammocount1, ammocount2;
		[ammo1, ammo2, ammocount1, ammocount2] = StatusBar.GetCurrentAmmo();

		if (ammo1)
		{
			DrawToHud.DrawTexture(ammo1.icon, (pos.x + 40, pos.y + 18), alpha, centered:false);
			DrawToHud.DrawText(String.Format("%3i", ammocount1), (pos.x + 91, pos.y + 19), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
		}

		if (ammo2 && ammo2 != ammo1)
		{
			DrawToHud.DrawTexture(ammo2.icon, (pos.x + 40, pos.y + 2), alpha, centered:false);
			DrawToHud.DrawText(String.Format("%3i", ammocount2), (pos.x + 91, pos.y + 3), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
		}

		//Grenade
		let grenades = player.mo.FindInventory("GrenadePickup");
		if (grenades)
		{
			if (player.mo.FindInventory("AstroGrenadeToken")) { DrawToHud.DrawTexture(astrogrenadetex, (pos.x + 2, pos.y + 17), alpha, centered:false); }
			else { DrawToHud.DrawTexture(grenadetex, (pos.x + 2, pos.y + 17), alpha, centered:false); }

			DrawToHud.DrawText(String.Format("%i", grenades.amount), (pos.x + 18, pos.y + 19), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
		}

		return size;
	}
}

class WeaponWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		WeaponWidget wdg = WeaponWidget(Widget.Init("WeaponWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos));
	}

	override Vector2 Draw()
	{
		size = (94, 6);

		Super.Draw();

		StatusBar.DrawString(BoAStatusBar(StatusBar).mHUDFont, StatusBar.GetWeaponTag(), (pos.x + 46, pos.y), StatusBar.DI_TEXT_ALIGN_CENTER, alpha:alpha);

		return size;
	}
}

class InventoryWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		InventoryWidget wdg = InventoryWidget(Widget.Init("InventoryWidget", widgetname, anchor, 0, priority, pos));
	}

	override Vector2 Draw()
	{
		if (level.NoInventoryBar) { return (0, 0); }

		size = (33, 33);

		Super.Draw();

		if (player.mo.InvSel) { BoAStatusBar(StatusBar).DrawIcon(player.mo.InvSel, int(pos.x + 16), int(pos.y + 16), 32, alpha:alpha); }

		return size;
	}
}

class PuzzleItemWidget : Widget
{
	int rows, cols, iconsize, maxrows;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		PuzzleItemWidget wdg = PuzzleItemWidget(Widget.Init("PuzzleItemWidget", widgetname, anchor, 0, priority, pos));
				
		if (wdg)
		{
			wdg.iconsize = 20;
		}
	}

	override bool SetVisibility()
	{
		if (
			level.NoInventoryBar ||
			screenblocks > 11 ||
			player.mo.FindInventory("CutsceneEnabled") ||
			player.morphtics
		) { return false; }

		return true;
	}

	override void DoTick(int index)
	{
		Vector2 hudscale = Statusbar.GetHudScale();
		
		if (screenblocks < 11)
		{
			maxrows = 9;
			offset.x = 7;
		}
		else
		{
			maxrows = int((Screen.GetHeight() / hudscale.y - 52 - pos.y) / (iconsize + 2));
			offset.x = 16;
		}

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		Super.Draw();

		[cols, rows] = BoAStatusBar(StatusBar).DrawPuzzleItems(int(pos.x + (cols - 1) * (iconsize + 2) + 1), int(pos.y + 1), iconsize, maxrows, -1, false, StatusBar.DI_ITEM_LEFT_TOP, alpha);

		size = ((iconsize + 2) * cols, (iconsize + 2) * rows);

		return size;
	}
}

class StealthWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		StealthWidget wdg = StealthWidget(Widget.Init("StealthWidget", widgetname, anchor, 0, priority, pos));

		if (wdg && wdg.flags & WDG_DRAWFRAME) { wdg.flags |= WDG_DRAWFRAME_CENTERED; }
	}

	override bool SetVisibility()
	{
		if (Super.SetVisibility()) { return !!BoAStatusBar(StatusBar).LivingSneakableActors(); }
		return false;
	}

	override Vector2 Draw()
	{
		if (!BoAStatusBar(StatusBar)) { return (0, 0); }

		size = (192, 16);

		Super.Draw();

		BoAStatusBar(StatusBar).DrawVisibilityBar((pos.x, pos.y), 0, 1.0, alpha);

		return size;
	}
}

class PowerWidget : Widget
{
	bool active;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		PowerWidget wdg = PowerWidget(Widget.Init("PowerWidget", widgetname, anchor, 0, priority, pos));

		if (wdg && wdg.flags & WDG_DRAWFRAME) { wdg.flags |= WDG_DRAWFRAME_CENTERED; }
	}

	override Vector2 Draw()
	{
		if (!BoAStatusBar(StatusBar)) { return (0, 0); }

		size = (70, 54);

		if (active) { Super.Draw(); }

		active = BoAStatusBar(StatusBar).DrawMinesweeper(int(pos.x), int(pos.y), StatusBar.DI_ITEM_CENTER, alpha) | BoAStatusBar(StatusBar).DrawLantern(int(pos.x), int(pos.y), StatusBar.DI_ITEM_CENTER, alpha);

		return size;
	}
}

class AirSupplyWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		AirSupplyWidget wdg = AirSupplyWidget(Widget.Init("AirSupplyWidget", widgetname, anchor, 0, priority, pos));
	}

	override Vector2 Draw()
	{
		if (!BoAStatusBar(StatusBar)) { return (0, 0); }

		size = (8, 97);

		Super.Draw();

		StatusBar.DrawBar("VERTAIRF", "VERTAIRE", BoAStatusBar(StatusBar).mAirInterpolator.GetValue(), level.airsupply, (pos.x, pos.y), 0, StatusBar.SHADER_VERT | StatusBar.SHADER_REVERSE, StatusBar.DI_ITEM_OFFSETS, alpha);

		return size;
	}
}

class StaminaWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		StaminaWidget wdg = StaminaWidget(Widget.Init("StaminaWidget", widgetname, anchor, 0, priority, pos));
	}

	override Vector2 Draw()
	{
		if (!BoAStatusBar(StatusBar)) { return (0, 0); }

		size = (8, 97);

		Super.Draw();

		StatusBar.DrawBar("VERTSTMF", "VERTSTME", BoAStatusBar(StatusBar).mStaminaInterpolator.GetValue(), 100, (pos.x, pos.y), 0, StatusBar.SHADER_VERT | StatusBar.SHADER_REVERSE, StatusBar.DI_ITEM_OFFSETS, alpha);

		return size;
	}
}

class AmmoInfo
{
	Class<Ammo> ammotype;
	int chambered;
	int carried;
	TextureID icon;

	int GetAmount()
	{
		return carried + chambered;
	}
}

class AmmoWidget : Widget
{
	Array<AmmoInfo> ammotypes;
	transient CVar show;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		AmmoWidget wdg = AmmoWidget(Widget.Init("AmmoWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos));

		if (wdg)
		{
			wdg.margin[0] = 8;
			wdg.margin[1] = 4;
		}
	}

	override bool SetVisibility()
	{
		show = CVar.FindCVar("boa_hudammostats");
		if (show && !show.GetBool()) { return false; }

		return Super.SetVisibility();
	}

	override Vector2 Draw()
	{
		ammotypes.Clear();

		// Some logic adapted from the engine's alt_hud.zs here
		for (int k = 0; k < PlayerPawn.NUM_WEAPON_SLOTS; k++) 
		{
			int slotsize = player.weapons.SlotSize(k);

			for (int j = 0; j < slotsize; j++)
			{
				let weap = player.weapons.GetWeapon(k, j);
				if (weap)
				{
					let wmo = Weapon(player.mo.FindInventory(weap));
					// Only show ammo for weapons in the player's inventory
					if (wmo && (wmo.AmmoType1 || wmo.AmmoType2))
					{
						if (wmo is "NaziWeapon") // Special handling for Nazis magazine/loaded ammo setup
						{
							SetAmmo(wmo.AmmoType2, wmo.AmmoType1);
						}
						else
						{
							SetAmmo(wmo.AmmoType1);
							SetAmmo(wmo.AmmoType2);
						}
					}

					// Show ammo for all weapons that are assigned to a player's weapon slots
/*
					let wpn = GetDefaultByType(weap);
					if (wpn && (wpn.AmmoType1 || wpn.AmmoType2) && (!wpn.bCheatNotWeapon || wmo))
					{
						class<Object> type = (class<Object>)(weap);
						while (type.GetParentClass() && type.GetParentClass() != "Weapon") { type = type.GetParentClass(); }

						if (type == "NaziWeapon") // Special handling for Nazis magazine/loaded ammo setup
						{
							SetAmmo(wpn.AmmoType2, wpn.AmmoType1, !!wmo);
						}
						else
						{
							SetAmmo(wpn.AmmoType1);
							SetAmmo(wpn.AmmoType2);
						}
					}
*/
				}
			}
		}

		if (!ammotypes.Size())
		{
			visible = false;
			return (0, 0);
		}

		int typewidth = HUDFont.StringWidth("     ") + 6;
		int typeheight = HUDFont.GetHeight();
		size = (typewidth, max(45, ammotypes.Size() * typeheight));

		Super.Draw();

		for (int t = 0; t < ammotypes.Size(); t++)
		{
			if (!ammotypes[t]) { continue; }

			Vector2 drawpos = pos;
			drawpos.y += 1;

			let ammotype = GetDefaultByType(ammotypes[t].ammotype);
			if (ammotypes.Size())
			{
				drawpos.y += typeheight * t;
				Vector2 iconsize = TexMan.GetScaledSize(ammotypes[t].icon);
				double ratio = iconsize.y / iconsize.x;

				DrawToHud.DrawTexture(ammotypes[t].icon, (drawpos.x + 3, drawpos.y + 3), alpha, destsize:(6 / ratio, 6));
				DrawToHud.DrawText(String.Format("%i", ammotypes[t].GetAmount()), (drawpos.x + typewidth, drawpos.y), HUDFont, alpha, shade:Font.CR_WHITE, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
			}
		}

		return size;
	}

	int FindAmmo(class<ammo> ammotype)
	{
		for (int a = 0; a < ammotypes.Size(); a++)
		{
			if (ammotypes[a] && ammotypes[a].ammotype == ammotype) { return a; }
		}

		return ammotypes.Size();
	}

	void SetAmmo(class<Ammo> ammotype, class<Ammo> ammotypeloaded = null, bool carried = true)
	{
		if (!ammotype && ammotypeloaded) { ammotype = ammotypeloaded; }
		if (ammotype == ammotypeloaded) { ammotypeloaded = null; }

		if (ammotype)
		{
			AmmoInfo info;

			int a = FindAmmo(ammotype);
			if (a == ammotypes.Size())
			{
				info = New("AmmoInfo");
				ammotypes.Push(info);
				info.ammotype = ammotype;
				info.icon = GetDefaultbyType(ammotype).icon;

				if (player.mo.FindInventory(ammotype)) { info.carried = player.mo.FindInventory(ammotype).amount; }
				if (!carried) { return; }
				if (ammotypeloaded && player.mo.FindInventory(ammotypeloaded)) { info.chambered = player.mo.FindInventory(ammotypeloaded).amount; }
			}
			else if (ammotypeloaded && carried)
			{
				info = ammotypes[a];
				if (player.mo.FindInventory(ammotypeloaded)) { info.chambered += player.mo.FindInventory(ammotypeloaded).amount; }
			}

		}
	}
}

class PositionWidget : Widget
{
	Font fnt;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		PositionWidget wdg = PositionWidget(Widget.Init("PositionWidget", widgetname, anchor, 0, priority, pos));
	}

	override bool SetVisibility()
	{
		return !!idmypos;
	}

	override void DoTick(int index)
	{
		fnt = HUDFont;

		if (screenblocks > 10)
		{
			anchor = WDG_RIGHT;
		}
		else
		{
			anchor = WDG_BOTTOM | WDG_RIGHT;
		}

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		int headercolor = Font.CR_GRAY;
		int infocolor = Font.FindFontColor("LightGray");

		let scalevec = StatusBar.GetHUDScale();
		double scale = int(scalevec.X);
		int vwidth = int(screen.GetWidth() / scale);
		int vheight = int(screen.GetHeight() / scale);

		int height = fnt.GetHeight();
		int width = fnt.StringWidth("X: -00000.00");

		int x = int(pos.x);
		int y = int(pos.y);

		size = (width, height * 7);
		Super.Draw();

		// Draw coordinates
		Vector3 playerpos = player.mo.Pos;
		String header, value;

		// Draw map name
		DrawToHud.DrawText(level.mapname.MakeUpper(), (x, y), fnt, alpha, shade:Font.CR_RED, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);

		y += height;
		
		for (int i = 0; i < 3; y += height, ++i)
		{
			double v = i == 0 ? playerpos.x : i == 1 ? playerpos.y : playerpos.z;

			header = String.Format("%c:", int("X") + i);
			value = String.Format("%5.2f", v);

			DrawToHud.DrawText(header, (x, y), fnt, alpha, shade:headercolor, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
			DrawToHud.DrawText(value, (x + width - fnt.StringWidth(value), y), fnt, alpha, shade:infocolor, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
		}

		y += height;

		// Draw player angle
		DrawToHud.DrawText("A:", (x, y), fnt, alpha, shade:headercolor, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
		value = String.Format("%0.2f", player.mo.angle);
		DrawToHud.DrawText(value, (x + width - fnt.StringWidth(value), y), fnt, alpha, shade:infocolor, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);

		y += height;

		// Draw player pitch
		DrawToHud.DrawText("P:", (x, y), fnt, alpha, shade:headercolor, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
		value = String.Format("%0.2f", player.mo.pitch);
		DrawToHud.DrawText(value, (x + width - fnt.StringWidth(value), y), fnt, alpha, shade:infocolor, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);

		return size;
	}
}

class Log ui
{
	PlayerInfo player;
	String text;
	double alpha, height;
	int ticker;
	Font fnt;

	void Print(Font fnt, double x, double y, double logalpha = 1.0)
	{
		DrawToHud.DrawText(text, (x, y), fnt, alpha * logalpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);	
	}

	static void Add(PlayerInfo player, String text, String logname = "Log", int level = 0)
	{
		LogWidget w = LogWidget(Widget.Find(logname));

		if (w)
		{
			int clr = 65;

			switch (level)
			{
				case PRINT_LOW:
				default:
					clr += msg0color;
					break;
				case PRINT_MEDIUM:
					clr += msg1color;
					break;
				case PRINT_HIGH:
					clr += msg2color;
					break;
				case PRINT_CHAT:
					clr += msg3color;
					break;
				case PRINT_TEAMCHAT:
					clr += msg4color;
					break;
				case PRINT_BOLD:
					clr += msgmidcolor;
					break;
			}

			String temp;
			BrokenString lines;
			[temp, lines] = BrokenString.BreakString(text, int(w.size.x), false, String.Format("%c", clr), w.fnt);

			for (int l = 0; l <= lines.Count(); l++)
			{
				String line = lines.StringAt(l);
				String temp = ZScriptTools.StripColorCodes(line);

				let m = New("Log");
				if (m && temp.length())
				{
					m.fnt = w.fnt;
					m.player = player;
					m.text = line;
					w.messages.Push(m);
				}
			}
			/*
			let m = New("Log");
			if (m)
			{
				m.fnt = w.fnt;
				m.player = player;
				m.text = text;
				w.messages.Push(m);
			}
			*/
		}
	}
}

class LogWidget : Widget
{
	Array<Log> messages;
	int lineheight;
	Font fnt;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		LogWidget wdg = LogWidget(Widget.Init("LogWidget", widgetname, anchor, 0, priority, pos));

		if (wdg)
		{
			wdg.margin[0] = 8;
			wdg.margin[1] = 4;
		}
	}

	virtual void SetFont()
	{
		fnt = SmallFont;
	}

	override void DoTick(int index)
	{
		SetFont();

		int delta = max(0, messages.Size() - con_notifylines);
		for (int d = 0; d < delta; d++) { messages.Delete(d); } // Delete oldest notifications off the top of the stack if we've hit the limit for number shown

		for (int i = 0; i < min(con_notifylines, messages.Size()); i++)
		{
			let m = messages[i];

			if (m)
			{
				m.ticker++;
				if (m.ticker < 8) { m.alpha = m.ticker / 6.0; }
				else if (m.ticker > 35 * con_notifytime - 6) { m.alpha = clamp(1.0 - (m.ticker - 35 * con_notifytime - 6) / 6.0, 0.0, 1.0); }

				if (m.alpha == 0.0)
				{
					m.height = max(0, m.height - 1);
					if (m.height == 0) { messages.Delete(i); }
				}
				else { m.height = lineheight; }
			}
		}
	
		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		lineheight = fnt.GetHeight();

		double rightoffset = 0;
		Widget topright = FindPrev(WDG_RIGHT, -1, 0, true);
		if (topright) { rightoffset = -topright.pos.x + topright.margin[0] + margin[2] - 2; }

		Vector2 hudscale = StatusBar.GetHudScale();
		size = (Screen.GetWidth() / hudscale.x - pos.x - rightoffset, lineheight * con_notifylines);
		Super.Draw();

		double yoffset = 0;

		for (int i = 0; i < messages.Size(); i++)
		{
			if (i < con_notifylines)
			{
				if (messages[i].player != players[consoleplayer]) { continue; }
				if (i > 0) { yoffset += messages[i - 1].height; }
			
				messages[i].Print(fnt, pos.x, pos.y + yoffset, alpha);
			}
		}

		return size;
	}
}

class ActiveEffectWidget : Widget
{
	int iconsize;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		ActiveEffectWidget wdg = ActiveEffectWidget(Widget.Init("ActiveEffectWidget", widgetname, anchor, 0, priority, pos));

		if (wdg)
		{
			wdg.iconsize = 24;
		}
	}

	override bool SetVisibility()
	{
		if (
				automapactive ||
				screenblocks > 11 ||
				player.mo.FindInventory("CutsceneEnabled") ||
				player.morphtics
		)
		{
			return false;
		}

		return true;
	}

	override void DoTick(int index)
	{
		if (screenblocks < 11)
		{
			anchor = WDG_RIGHT;
			priority = 0;
		}
		else
		{
			anchor = WDG_BOTTOM | WDG_LEFT;
			priority = 1;
		}

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		Inventory item;
		int count = 0;

		for (item = player.mo.Inv; item != null; item = item.Inv)
		{
			if (Powerup(item))
			{
				let icon = Powerup(item).GetPowerupIcon();
				if (icon.IsValid()) { count++; }
			}
		}
		if (player.poisoncount) { count++; }
		if (player.hazardcount) { count++; }
		if (player.mo.poisondurationreceived) { count++; }

		if (count) { size = (count * (iconsize + 2), iconsize + 1); }
		Super.Draw();

		if (!count) { return size; }

		double drawposx = int(pos.x + iconsize / 2);
		double drawposy = int(pos.y + iconsize / 2);
		int spacing = iconsize + 2;

		for (item = player.mo.Inv; item != null; item = item.Inv)
		{
			if (Powerup(item))
			{
				Color amtclr = Powerup(item).BlendColor;
				if (amtclr == 0) { amtclr = 0xDDDDDD; }

				if (item.icon) { DrawEffectIcon(item.icon, Powerup(item).EffectTics, Powerup(item).Default.EffectTics, (drawposx, drawposy), amtclr); }
				drawposx += spacing;
			}
		}

		if (player.poisoncount)
		{
			DrawEffectIcon(TexMan.CheckForTexture("ICO_POIS"), player.poisoncount, 100, (drawposx, drawposy), GetPoisonColor(player.poisonpaintype));
			drawposx += spacing;
		}

		if (player.hazardcount)
		{
			DrawEffectIcon(TexMan.CheckForTexture("ICO_POIS"), min(1, player.hazardcount), 1, (drawposx, drawposy), GetPoisonColor(player.hazardtype));
			drawposx += spacing;
		}

		if (player.mo.poisondurationreceived)
		{
			DrawEffectIcon(TexMan.CheckForTexture("ICO_POIS"), player.mo.poisondurationreceived, int(player.mo.poisonperiodreceived ? 60.0 / player.mo.poisonperiodreceived : 60.0), (drawposx, drawposy), GetPoisonColor(player.mo.poisondamagetypereceived));
			drawposx += spacing;
		}

		return size;
	}

	void DrawTimer(int time, int maxtime, Color clr, Vector2 pos = (0, 0), double scale = 1.0)
	{
		TextureID fill = TexMan.CheckForTexture("STATUSF");
		TextureID back = TexMan.CheckForTexture("STATUSB");
		TextureID border = TexMan.CheckForTexture("STATUSO");

		// Snap draw coordinates to integers for clean scaling;
		pos.x = int(pos.x);
		pos.y = int(pos.y);

		if (back.IsValid()) { DrawToHud.DrawTexture(back, pos, alpha, scale); }

		if (fill.IsValid() && time < 0x7FFFFFFF)  // Don't draw amount indicators for infinite powerups
		{
			double angle = 360.0 * time / maxtime;

			int quads = int(angle / 90);

			for (int q = quads; q > 0; q--)
			{
				DrawToHud.DrawTransformedTexture(fill, pos, alpha, (90 * q - 1) - 90, scale, clr);
			}

			int top = 0, left = 0, bottom = 0x7FFFFFFF, right = 0x7FFFFFFF;

			switch (quads % 4)
			{
				case 3:
					bottom = int(pos.y);
					break;
				case 2:
					right = int(pos.x);
					break;
				case 1:
					top = int(pos.y);
					break;
				default:
					left = int(pos.x);
					break;
			}

			DrawToHud.DrawTransformedTexture(fill, pos, alpha, angle - 90, scale, clr, top, left, bottom, right);
		}

		if (border.IsValid()) { DrawToHud.DrawTexture(border, pos, alpha, scale); }
	}

	virtual Color GetPoisonColor(Name poisontype)
	{
		if (poisontype == "MutantPoison" || poisontype == "MutantPoisonAmbience")
		{
			return 0xFF6400C8;
		}
		else if (poisontype == "UndeadPoison" || poisontype == "UndeadPoisonAmbience")
		{
			return 0xFF005A40;
		}

		return 0x0A6600;
	}

	void DrawEffectIcon(TextureID icon, int duration, int maxduration, Vector2 pos, Color clr = 0xDDDDDD)
	{
		DrawTimer(duration, maxduration, clr, (pos.x, pos.y), 0.5);

		if (icon.IsValid())
		{
			Vector2 texsize = TexMan.GetScaledSize(icon);
			if (texsize.x > iconsize || texsize.y > iconsize)
			{
				if (texsize.y > texsize.x)
				{
					texsize.y = iconsize * 1.0 / texsize.y;
					texsize.x = texsize.y;
				}
				else
				{
					texsize.x = iconsize * 1.0 / texsize.x;
					texsize.y = texsize.x;
				}
			}
			else { texsize = (1.0, 1.0); }

			StatusBar.DrawTexture(icon, (pos.x, pos.y), StatusBar.DI_ITEM_CENTER, alpha * 0.85, scale:0.75 * texsize);
		}
	}
}

class DamageInfo
{
	Actor attacker;
	String infoname;
	Vector3 attackerpos;
	int distance;
	int angle;
	int timeout;
	int nextupdate;
	double alpha;
	Color clr;
}

class DamageWidget : Widget
{
	Array<DamageInfo> indicators;
	transient CVar enabled;
	int damagecount;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0))
	{
		DamageWidget wdg = DamageWidget(Widget.Init("DamageWidget", widgetname, anchor, 0, priority, pos));
	}

	override bool SetVisibility()
	{
		if (
				automapactive ||
				screenblocks > 11 ||
				player.mo.FindInventory("CutsceneEnabled") ||
				player.morphtics ||
				(enabled && !enabled.GetBool())
		)
		{
			return false;
		}

		return true;
	}

	override void DoTick(int index)
	{
		if (!enabled) { enabled = CVar.FindCVar("boa_huddamageindicators"); }

		if (player.mo && player.damagecount)
		{
			Actor attacker = null;
			String infoname = "";

			// If the attacker is still alive, use their data
			if (player.attacker)
			{
				// Unless it's an internal damage effect
				if (player.attacker != player.mo) { attacker = player.attacker; }
			}
			else // Otherwise, treat it as world-induced damage
			{
				infoname = "World";
			}

			DamageInfo info;

			// Save information about a new attacker if it isn't already being tracked
			int attackerindex = FindAttacker(attacker, infoname);
			if (attackerindex == indicators.Size())
			{
				info = New("DamageInfo");
				info.attacker = attacker;
				info.infoname = infoname;
				info.clr = player.mo.GetPainFlash();

				indicators.Push(info);
			}
			else { info = indicators[attackerindex]; }

			// And save additional information
			if (info)
			{
				if (level.time > info.nextupdate)
				{
					if (player.attacker)
					{
						info.attackerpos = player.attacker.pos;
						info.angle = int(360 - player.mo.deltaangle(player.mo.angle, player.mo.AngleTo(player.attacker)));
					}
					else  // If no attacker actor, assume it was something behind the player's current movement direction that caused the damage (e.g., explosion)
					{
						if (damagecount < player.damagecount) // Update/replace with any new damage to the player
						{
							info.attackerpos = player.mo.pos - player.mo.vel;
							info.angle = int(360 - player.mo.deltaangle(player.mo.angle, atan2(-player.mo.vel.y, -player.mo.vel.x)));

						}
						damagecount = player.damagecount;
					}

					info.nextupdate = level.time + 18;
					info.distance = clamp(int(56 - level.Vec3Diff(player.mo.pos, info.attackerpos).length() / 64), 0, 64);

					info.timeout = level.time + min(70, player.damagecount * 4);
				}
			}
		}

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		double anglestep = 2.5;

		TextureID indicator = TexMan.CheckForTexture("HUD_DMG");
		if (indicator.IsValid()) { size = TexMan.GetScaledSize(indicator); }

		Super.Draw();

		for (int i = 0; i < indicators.Size(); i++)
		{
			let current = indicators[i];

			if (current.timeout < level.time)
			{
				indicators.Delete(i);
				continue;
			}

			if (current.timeout - level.time < 35) { current.alpha = (current.timeout - level.time) / 35.0; }
			else if (current.alpha < 1.0) { current.alpha += 0.125; }

			double anglerange = anglestep * current.distance / 2.0;

			for (double a = -anglerange; a <= anglerange; a += anglestep)
			{
				DrawToHud.DrawTransformedTexture(indicator, pos, alpha * current.alpha * (1.0 - (abs(a) / max(anglerange, 1))), current.angle + a, 1.0, current.clr);
			}
		}

		return size;
	}

	int FindAttacker(Actor attacker, String infoname = "")
	{
		for (int i = 0; i < indicators.Size(); i++)
		{
			if (attacker && indicators[i].attacker == attacker) { return i; }
			else if (infoname.length() && indicators[i].infoname ~== infoname) { return i; }
		}

		return indicators.Size();
	}
}