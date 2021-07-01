/*
 * Copyright (c) 2021 AFADoomer
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
	int flags, anchor, priority, zindex;
	int margin[4]; // top, right, bottom, left
	bool visible;
	double alpha;
	private int screenblocksval;

	Font BigFont, HUDFont;

	PlayerInfo player;

	static Widget Init(class<Widget> type, String widgetname, int anchor = WDG_TOP | WDG_LEFT, int flags = 0, int priority = 0, Vector2 offset = (0, 0), int zindex = 0)
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
		w.zindex = zindex;

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

	void CalcRelPos(in out Vector2 pos, int index, bool simple = false)
	{
		Vector2 hudscale = StatusBar.GetHudScale();

		Vector2 relpos = (0, 0);

		if (index > -1 && !simple)
		{
			int spacing = 0;

			let w = FindPrev(anchor, index, priority); // Find the next item down in the 'stack' for this anchor point
			if (w)
			{
				if (anchor & WDG_BOTTOM)
				{
					spacing = w.margin[0] + margin[2] - 2;
					relpos.y = -w.pos.y + spacing;
				}
				else
				{
					spacing = w.margin[2] + margin[0] - 2;
					relpos.y = w.pos.y + w.size.y + spacing;
				}
			}

			let p = FindPrev(anchor, index, priority, true); // Find the next item over at the same priority level for this anchor point
			if (p)
			{
				if (anchor & WDG_RIGHT)
				{
					spacing = p.margin[1] + margin[3] - 2;
					relpos.x = -p.pos.x + spacing;
				}
				else
				{
					spacing = p.margin[3] + margin[1] - 2;
					relpos.x = p.pos.x + p.size.x + spacing;
				}
			}
		}

		setpos.y = 3 + margin[0];
		setpos.x = 3 + margin[3];

		// If this wasn't offset at all, assume it's the first in the stack, and apply edge-of-screen offsets as necessary
		if (relpos.y == 0)
		{
		 	if (BoAStatusBar(Statusbar))
			{
				if (anchor == WDG_RIGHT && vid_fps) { relpos.y += int(NewSmallFont.GetHeight() / GetConScale(con_scale) / hudscale.y); }
				if (!(anchor & WDG_BOTTOM) && !(anchor & WDG_MIDDLE))
				{
					if (pos.y > BoAStatusBar(Statusbar).maptop) { relpos.y = max(BoAStatusBar(Statusbar).maptop, pos.y - 12); }
					else if (pos.y < BoAStatusBar(Statusbar).maptop) { relpos.y = min(BoAStatusBar(Statusbar).maptop, pos.y + 12); }
				}
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
				!(player.mo is "TankPlayer" || player.mo is "KeenPlayer")
			) { return true; }
		
		return false;
	}

	virtual void DoTick(int index = 0)
	{
		visible = SetVisibility();
		if (!visible) { alpha = 0.0; }

		SetMargins();
		CalcRelPos(pos, index, !size.length());

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

	static void TickWidgets()
	{
		for (int w = 0; w < BoAStatusBar(Statusbar).widgets.Size(); w++)
		{
			BoAStatusBar(Statusbar).widgets[w].DoTick(w);
		}
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

			DrawToHUD.DrawFrame("FRAME_", int(framepos.x - margin[1]), int(framepos.y - margin[0]), size.x + margin[1] + margin[3], size.y + margin[0] + margin[2], 0x1b1b1b, alpha, 0.53 * alpha);
		}

		screenblocksval = screenblocks;

		return size;
	}

	static int, int GetZIndexRange()
	{
		int min = 0;
		int max = 0;

		for (int w = 0; w < BoAStatusBar(Statusbar).widgets.Size(); w++)
		{
			int z = BoAStatusBar(Statusbar).widgets[w].zindex;
			if (z < min) { min = z; }
			if (z > max) { max = z; }
		}

		return min, max;
	}

	static void DrawWidgets()
	{
		StatusBar.BeginHUD(1.0, false);

		int zindex, max;
		[zindex, max] = GetZIndexRange();

		while (zindex <= max)
		{
			for (int w = 0; w < BoAStatusBar(Statusbar).widgets.Size(); w++)
			{
				let wdg = BoAStatusBar(Statusbar).widgets[w];
				if (wdg && wdg.visible && wdg.zindex == zindex) { wdg.Draw(); }
			}

			zindex++;
		}
	}

	// From v_draw.cpp
	int GetConScale(int altval = 0)
	{
		int scaleval;

		if (altval > 0) { scaleval = (altval+1) / 2; }
		else if (uiscale == 0)
		{
			// Default should try to scale to 640x400
			int vscale = screen.GetHeight() / 800;
			int hscale = screen.GetWidth() / 1280;
			scaleval = clamp(vscale, 1, hscale);
		}
		else { scaleval = (uiscale + 1) / 2; }

		// block scales that result in something larger than the current screen.
		int vmax = screen.GetHeight() / 400;
		int hmax = screen.GetWidth() / 640;
		int max = MAX(vmax, hmax);
		return MAX(1, MIN(scaleval, max));
	}

	static int GetHealthColor(Actor mo, double shade = 1.0)
	{
		color clr;
		int red, green, blue;
		int health = int(mo.health * 100. / mo.Default.health);

		if (mo.player && (mo.player.cheats & CF_GODMODE || mo.player.cheats & CF_GODMODE2))
		{ // Gold for god mode...
			red = 255;
			green = 255;
			blue = 64;
		} 
		else
		{
			health = clamp(health, 0, 100);

			if (health < 50)
			{
				red = 255;
				green = health * 255 / 50;
			}
			else
			{
				red = (100 - health) * 255 / 50;
				green = 255;
			}
		}

		clr = (int(red * shade) << 16) | (int(green * shade) << 8) | int(blue * shade);

		return clr;
	}
}

class HealthWidget : Widget
{
	TextureID rctex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		HealthWidget wdg = HealthWidget(Widget.Init("HealthWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));

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

		DrawToHud.DrawTexture(StatusBar.GetMugShot(5, flags, face), position, alpha, flags:DrawToHUD.TEX_DEFAULT);
	}
}

class CountWidget : Widget
{
	TextureID bagtex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		CountWidget wdg = CountWidget(Widget.Init("CountWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));

		if (wdg)
		{
			wdg.bagtex = TexMan.CheckForTexture("HUD_COIN");
		}
	}

	override bool SetVisibility()
	{
		if (
				BoAStatusBar(StatusBar) && 
				BoAStatusBar(StatusBar).barstate == StatusBar.HUD_Fullscreen && 
				!automapactive && 
				!player.mo.FindInventory("CutsceneEnabled") &&
				!(player.mo is "KeenPlayer")
			) { return true; }
		
		return false;
	}

	override Vector2 Draw()
	{
		int timey = 13;

		if (player.mo is "TankPlayer")
		{
			size = (64, HUDFont.GetHeight() + 3);
			timey = 0;
			Super.Draw();
		}
		else
		{
			size = (64, 21);
			Super.Draw();

			//Money
			int amt = 0;
			let money = player.mo.FindInventory("CoinItem");
			if (money) { amt = money.amount; }

			DrawToHud.DrawTexture(bagtex, (pos.x - 1, pos.y - 1), alpha, flags:DrawToHUD.TEX_DEFAULT);
			DrawToHud.DrawText(String.Format("%3i", amt), (pos.x + 61, pos.y), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
		}

		//Time
		String time = level.TimeFormatted();

		if (BoAStatusBar(StatusBar).hour || BoAStatusBar(StatusBar).minute || BoAStatusBar(StatusBar).second)
		{
			time = String.Format("%02i", BoAStatusBar(StatusBar).hour) .. ":" .. String.Format("%02i", BoAStatusBar(StatusBar).minute) .. ":" .. String.Format("%02i", BoAStatusBar(StatusBar).second);
		}

		DrawToHud.Dim(0x0, 0.2 * alpha, int(pos.x - (margin[3] - 3)), int(pos.y + timey), int(size.x + (margin[3] + margin[1]) - 6), HUDFont.GetHeight() + 3);
		StatusBar.DrawString(BoAStatusBar(StatusBar).mHUDFont, time, (pos.x + 17, pos.y + timey + 1), alpha:alpha);

		return size;
	}
}

class KeyWidget : Widget
{
	static const String keys[] = { "BoABlueKey", "BoAGreenKey", "BoAYellowKey", "BoAPurpleKey", "BoARedKey", "BoACyanKey", "AstroBlueKey", "AstroYellowKey", "AstroRedKey" };

	TextureID locktex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		KeyWidget wdg = KeyWidget(Widget.Init("KeyWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));

		if (wdg)
		{
			wdg.locktex = TexMan.CheckForTexture("HUD_LOCK");
		}
	}

	override Vector2 Draw()
	{
		size = (45, 21);

		Super.Draw();

		DrawToHud.DrawTexture(locktex, (pos.x + 1, pos.y + 3), alpha, flags:DrawToHUD.TEX_DEFAULT);

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

				DrawToHud.DrawTexture(key.icon, (pos.x + offsetx, pos.y + offsety), alpha, flags:DrawToHUD.TEX_DEFAULT);
			}
		}

		return size;
	}
}

class CurrentAmmoWidget : Widget
{
	TextureID grenadetex, astrogrenadetex;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		CurrentAmmoWidget wdg = CurrentAmmoWidget(Widget.Init("CurrentAmmoWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));

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
		Inventory ammo1, ammo2;
		int ammocount1, ammocount2;
		[ammo1, ammo2, ammocount1, ammocount2] = BoAStatusBar(StatusBar).GetWeaponAmmo();

		int iconsize = 14;
		Vector2 texscale;
		if (ammo1)
		{
			texscale = ZScriptTools.ScaleTextureTo(ammo1.icon, iconsize);
			DrawToHud.DrawTexture(ammo1.icon, (pos.x + 40, pos.y + 18), alpha, destsize:texscale * iconsize, flags:DrawToHUD.TEX_DEFAULT);
			DrawToHud.DrawText(String.Format("%3i", ammocount1), (pos.x + 91, pos.y + 19), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
		}

		if (ammo2 && ammo2 != ammo1)
		{
			texscale = ZScriptTools.ScaleTextureTo(ammo2.icon, iconsize);
			DrawToHud.DrawTexture(ammo2.icon, (pos.x + 40, pos.y + 2), alpha, destsize:texscale * iconsize, flags:DrawToHUD.TEX_DEFAULT);
			DrawToHud.DrawText(String.Format("%3i", ammocount2), (pos.x + 91, pos.y + 3), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_RIGHT);
		}

		//Grenade
		let grenades = player.mo.FindInventory("GrenadePickup");
		if (grenades)
		{
			if (player.mo.FindInventory("AstroGrenadeToken")) { DrawToHud.DrawTexture(astrogrenadetex, (pos.x + 2, pos.y + 17), alpha, flags:DrawToHUD.TEX_DEFAULT); }
			else { DrawToHud.DrawTexture(grenadetex, (pos.x + 2, pos.y + 17), alpha, flags:DrawToHUD.TEX_DEFAULT); }

			DrawToHud.DrawText(String.Format("%i", grenades.amount), (pos.x + 18, pos.y + 19), BigFont, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
		}

		return size;
	}
}

class WeaponWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		WeaponWidget wdg = WeaponWidget(Widget.Init("WeaponWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));
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
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		InventoryWidget wdg = InventoryWidget(Widget.Init("InventoryWidget", widgetname, anchor, 0, priority, pos, zindex));
	}

	override bool SetVisibility()
	{
		if (
				BoAStatusBar(StatusBar) && 
				BoAStatusBar(StatusBar).barstate == StatusBar.HUD_Fullscreen && 
				!automapactive && 
				!player.mo.FindInventory("CutsceneEnabled") &&
				!(player.mo is "KeenPlayer")
			) { return true; }
		
		return false;
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

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		PuzzleItemWidget wdg = PuzzleItemWidget(Widget.Init("PuzzleItemWidget", widgetname, anchor, 0, priority, pos, zindex));
				
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
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		StealthWidget wdg = StealthWidget(Widget.Init("StealthWidget", widgetname, anchor, 0, priority, pos, zindex));

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

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		PowerWidget wdg = PowerWidget(Widget.Init("PowerWidget", widgetname, anchor, 0, priority, pos, zindex));

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
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		AirSupplyWidget wdg = AirSupplyWidget(Widget.Init("AirSupplyWidget", widgetname, anchor, 0, priority, pos, zindex));
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
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		StaminaWidget wdg = StaminaWidget(Widget.Init("StaminaWidget", widgetname, anchor, 0, priority, pos, zindex));
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
	Class<Inventory> ammotype;
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

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		AmmoWidget wdg = AmmoWidget(Widget.Init("AmmoWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));

		if (wdg)
		{
			wdg.margin[0] = 4;
			wdg.margin[1] = 8;
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

					if (wmo)
					{
						Inventory ammo1 = Inventory(wmo.Ammo1);
						Inventory ammo2 = Inventory(wmo.Ammo2);

						if (wmo is "NaziWeapon" && !ammo1 && !ammo2)
						{
							ammo1 = player.mo.FindInventory(NaziWeapon(wmo).ammoitem);
						}

						// Only show ammo for weapons in the player's inventory
						if (ammo1 || ammo2)
						{
							class<Inventory> ammo1class, ammo2class;
							if (ammo1) { ammo1class = ammo1.GetClass(); }
							if (ammo2) { ammo2class = ammo2.GetClass(); }

							if (wmo is "NaziWeapon") // Special handling for Nazis magazine/loaded ammo setup
							{
								SetAmmo(ammo2class, ammo1class);
							}
							else
							{
								SetAmmo(ammo1class);
								SetAmmo(ammo2class);
							}
						}
					}
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

	int FindAmmo(class<Inventory> ammotype)
	{
		for (int a = 0; a < ammotypes.Size(); a++)
		{
			if (ammotypes[a] && ammotypes[a].ammotype == ammotype) { return a; }
		}

		return ammotypes.Size();
	}

	void SetAmmo(class<Inventory> ammotype, class<Inventory> ammotypeloaded = null, bool carried = true)
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

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		PositionWidget wdg = PositionWidget(Widget.Init("PositionWidget", widgetname, anchor, 0, priority, pos, zindex));
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
	int ticker, printlevel;
	Font fnt;

	enum AddTypes
	{
		NEWLINE,
		APPENDLINE,
		REPLACELINE
	}

	void Print(double x, double y, double logalpha = 1.0, Font printfnt = null)
	{
		if (!printfnt) { printfnt = fnt; }
		DrawToHud.DrawText(text, (x, y), printfnt, alpha * logalpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);	
	}

	static void Clear(String logname = "Notifications")
	{
		LogWidget w = LogWidget(Widget.Find(logname));
		if (w) { w.messages.Clear(); }
	}

	static bool DrawPrompt(String txt, String logname = "Chat", Font fnt = null)
	{
		if (!fnt) { fnt = SmallFont; }

		LogWidget w = LogWidget(Widget.Find(logname));
		if (w)
		{
			String cursor = fnt.GetCursor();
			if (level.time % 20 < 10) { cursor = ""; }

			w.prompt = String.Format("\c%c>\cC%s%s", 65 + msg4color, txt.Left(txt.Length() - 1), cursor);
			w.promptfnt = fnt;
			return w.visible;
		}

		return false;
	}

	static bool Add(PlayerInfo player, String text, String logname = "Notifications", int printlevel = 0, Font fnt = null)
	{
		LogWidget w = LogWidget(Widget.Find(logname));

		if (w)
		{
			int clr = 65;

			switch (printlevel & PRINT_TYPES)
			{
				case PRINT_LOW:
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
				default:
					clr = Font.CR_UNTRANSLATED;
					break;
			}

			String temp;
			BrokenString lines;
			if (!fnt) { fnt = w.fnt; }

			if (w.addtype == APPENDLINE && w.messages.Size() && w.messages[w.messages.Size() - 1].printlevel == printlevel)
			{
				[temp, lines] = BrokenString.BreakString(w.messages[w.messages.Size() - 1].text .. text, int(w.size.x), false, String.Format("%c", clr), fnt);
			}
			else
			{
				[temp, lines] = BrokenString.BreakString(text, int(w.size.x), false, String.Format("%c", clr), fnt);
				if (w.addtype == APPENDLINE) { w.addtype = NEWLINE; }
			}

			if (lines.Count() == 0) { return w.visible; }

			for (int l = 0; l < lines.Count(); l++)
			{
				String line = lines.StringAt(l);
				String temp = ZScriptTools.StripColorCodes(line);

				if (l == lines.Count() - 1 && !temp.length()) { continue; }

				Log m;
				
				if (w.addtype == NEWLINE || !w.messages.Size())
				{
					m = New("Log");
					w.messages.Push(m);
				}
				else { m = w.messages[w.messages.Size() - 1]; }

				if (m)
				{
					m.fnt = fnt;
					m.player = player;
					m.printlevel = printlevel;
					m.text = line;
				}

				w.addtype = NEWLINE;
			}

			switch (text.ByteAt(text.length() - 1))
			{
				case 0x09:	w.addtype = REPLACELINE;	break;
				case 0x0A:	w.addtype = NEWLINE;		break;
				default:	w.addtype = APPENDLINE;		break;
			}
		}

		return w.visible;
	}
}

class LogWidget : Widget
{
	Array<Log> messages;
	int addtype;
	Font fnt, promptfnt;
	String prompt;

	int lasttick;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		LogWidget wdg = LogWidget(Widget.Init("LogWidget", widgetname, anchor, 0, priority, pos, zindex));

		if (wdg)
		{
			wdg.margin[0] = 4;
			wdg.margin[1] = 8;
		}
	}

	virtual void SetFont()
	{
		fnt = SmallFont;
	}

	override bool SetVisibility()
	{
		return true;
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
				if (!ZScriptTools.StripColorCodes(ZScriptTools.Trim(m.text)).length()) { messages.Delete(i); continue; }

				double holdtime = 35 * con_notifytime;
				double intime = 6.0;
				double outtime = 6.0;

				m.ticker++;
				if (m.ticker <= intime) { m.alpha = m.ticker / intime; }
				else if (m.ticker > holdtime - outtime) { m.alpha = clamp(1.0 - (m.ticker - holdtime - outtime) / outtime, 0.0, 1.0); }

				if (m.alpha == 0.0)
				{
					m.height = max(0, m.height - 1);
					if (m.height == 0) { messages.Delete(i); continue; }
				}
				else { m.height = fnt.GetHeight(); }
			}
		}

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		if (!messages.Size() && !prompt.length()) { return (0, 0); }

		int lineheight = fnt.GetHeight();

		double rightoffset = 0;
		if (!(flags & WDG_RIGHT))
		{
			int checkflags = WDG_RIGHT;
			if (anchor & WDG_BOTTOM) { checkflags |= WDG_BOTTOM; }
			Widget right = FindPrev(checkflags, -1, 0, true);
			if (right) { rightoffset = -right.pos.x + right.margin[3] + margin[1] - 2; }
			else if (BoAStatusbar(StatusBar)) { rightoffset = BoAStatusbar(StatusBar).widthoffset; }
		}

		double height = 0;

		if (anchor & WDG_BOTTOM) { height = con_notifylines * lineheight; }
		else
		{
			for (int i = 0; i < messages.Size(); i++)
			{
				if (messages[i].player != players[consoleplayer]) { continue; }
				if (!ZScriptTools.StripColorCodes(ZScriptTools.Trim(messages[i].text)).length()) { continue ; }

				height += messages[i].height;
			}
		}

		if (prompt) { height += lineheight; }

		Vector2 hudscale = StatusBar.GetHudScale();
		size = (Screen.GetWidth() / hudscale.x - pos.x - rightoffset, height);
		Super.Draw();

		double yoffset = 0;

		if (anchor & WDG_BOTTOM)
		{
			yoffset = -lineheight * 2;
			for (int i = messages.Size() - 1; i >= 0; i--)
			{
				if (i > con_notifylines) { continue; }
				if (messages[i].player != players[consoleplayer]) { continue; }
				if (!ZScriptTools.StripColorCodes(ZScriptTools.Trim(messages[i].text)).length()) { continue ; }

				messages[i].Print(pos.x, pos.y + height + yoffset, alpha);

				yoffset -= lineheight;
			}

			yoffset = height - lineheight;

			if (prompt.length())
			{
				DrawToHud.Dim(0x0, 0.2 * alpha, int(pos.x - (margin[3] - 3)), int(pos.y + yoffset - 1), int(size.x + (margin[3] + margin[1]) - 6), promptfnt.GetHeight() + 2);
				DrawToHud.DrawText(prompt, (pos.x, pos.y + yoffset), promptfnt, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
				prompt = "";
			}
		}
		else
		{
			for (int i = 0; i < messages.Size(); i++)
			{
				if (i < con_notifylines)
				{
					if (messages[i].player != players[consoleplayer]) { continue; }
					if (!ZScriptTools.StripColorCodes(ZScriptTools.Trim(messages[i].text)).length()) { continue ; }

					messages[i].Print(pos.x, pos.y + yoffset, alpha);

					yoffset += messages[i].height;
				}
			}

			if (prompt.length())
			{
				DrawToHud.Dim(0x0, 0.2 * alpha, int(pos.x - (margin[3] - 3)), int(pos.y + height - lineheight - 1), int(size.x + (margin[3] + margin[1]) - 6), promptfnt.GetHeight() + 2);
				DrawToHud.DrawText(prompt, (pos.x, pos.y + yoffset), promptfnt, alpha, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
				prompt = "";
			}
		}

		return size;
	}
}

class ActiveEffectWidget : Widget
{
	int iconsize;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		ActiveEffectWidget wdg = ActiveEffectWidget(Widget.Init("ActiveEffectWidget", widgetname, anchor, 0, priority, pos, zindex));

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
			if (Powerup(item) && item.icon && item.icon.IsValid())
			{
				Color amtclr = Powerup(item).BlendColor;
				if (amtclr == 0) { amtclr = 0xDDDDDD; }

				DrawEffectIcon(item.icon, Powerup(item).EffectTics, Powerup(item).Default.EffectTics, (drawposx, drawposy), amtclr);
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
		DrawToHUD.DrawTimer(duration, maxduration, clr, (pos.x, pos.y), 0.5);

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

class DamageWidget : Widget
{
	transient CVar enabled;
	DamageTracker damagehandler;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		DamageWidget wdg = DamageWidget(Widget.Init("DamageWidget", widgetname, anchor, 0, priority, pos, zindex));
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

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		double anglestep = 2.5;

		TextureID indicator = TexMan.CheckForTexture("HUD_DMG");

		Super.Draw();

		if (!damagehandler) { damagehandler = DamageTracker(EventHandler.Find("DamageTracker")); }
		if (!damagehandler) { return (0, 0); }

		for (int i = 0; i < damagehandler.events.Size(); i++)
		{
			let current = damagehandler.events[i];
			if (current.player != player) { continue; }

			double anglerange = anglestep * current.distance / 2.0;

			for (double a = -anglerange; a <= anglerange; a += anglestep)
			{
				DrawToHud.DrawTransformedTexture(indicator, pos, alpha * current.alpha * (1.0 - (abs(a) / max(anglerange, 1))), current.angle + a, 1.0, current.clr);
			}
		}

		return (0, 0);
	}
}

class GrenadeWidget : Widget
{
	transient CVar enabled;
	ThingTracker tracker;

	protected Le_GlScreen gl_proj;
	protected Le_Viewport viewport;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		GrenadeWidget wdg = GrenadeWidget(Widget.Init("GrenadeWidget", widgetname, anchor, 0, priority, pos, zindex));

		if (wdg)
		{
			wdg.gl_proj = new("Le_GlScreen");
		}
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
		if (!enabled) { enabled = CVar.FindCVar("boa_hudgrenadeindicators"); }

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		TextureID indicator = TexMan.CheckForTexture("HUD_IND");

		Super.Draw();

		if (!tracker) { tracker = ThingTracker(EventHandler.Find("ThingTracker")); }
		if (!tracker) { return (0, 0); }

		viewport.FromHud();
		gl_proj.CacheResolution();
		gl_proj.CacheFov(player.fov);
		gl_proj.OrientForPlayer(player);
		gl_proj.BeginProjection();

		let p = player.mo;

		for (int i = 0; i < tracker.grenades.Size(); i++)
		{
			let current = GrenadeBase(tracker.grenades[i]);

			if (current.target == player.mo && current.GetAge() < 35) { continue; } // Ignore the player's own grenades for the first second

			double dist = p.Distance3D(current);
			double maxdist = current.feardistance * 3;

			if (dist > maxdist || !current.bDrawIndicator) { continue; }

			Vector2 relativelocation = level.Vec2Diff(player.camera.pos.xy, current.pos.xy);
			relativelocation.y *= -1;
			relativelocation = Actor.RotateVector(relativelocation, player.camera.angle - 90);

			gl_proj.ProjectWorldPos(current.pos);

			Vector2 hudscale = StatusBar.GetHudScale();
			Vector2 grenadescreenpos = viewport.SceneToWindow(gl_proj.ProjectToNormal());
			grenadescreenpos.x /= hudscale.x;
			grenadescreenpos.y /= hudscale.y;

			Vector2 grenadepos = pos + relativelocation.Unit() * 128;

			double angle = atan2(grenadepos.y - grenadescreenpos.y, grenadepos.x - grenadescreenpos.x) + 90;
			if (!gl_proj.IsInFront()) { angle += 180; }

			TextureID icon = TexMan.CheckForTexture(current.iconname); 

			Color clr = 0xFF0000;

			if (Actor.InStateSequence(current.CurState, current.FindState("Death")))
			{
				// Fade from yellow to red
				int c = int(0xFF * clamp(current.tics * 1.0 / 35, 0, 1.0));
				clr += c * 0x100;
			}
			else { clr += 0xFF00; }

			double scale = 1.0 - clamp(dist / maxdist, 0.0, 1.0);
			double alpha = scale;
			DrawToHud.DrawTransformedTexture(indicator, grenadepos, 0.8 * alpha, angle, scale, clr);
			if (icon.IsValid()) { DrawToHud.DrawTransformedTexture(icon, grenadepos, alpha, angle, scale * 1.5, 0xFFFFFF); }
		}

		return (0, 0);
	}
}

class KeenWidget : Widget
{
	override bool SetVisibility()
	{
		if (
				BoAStatusBar(StatusBar) &&
				!automapactive &&
				screenblocks < 12 &&
				!player.mo.FindInventory("CutsceneEnabled") &&
				player.mo is "KeenPlayer"
			) { return true; }
		
		return false;
	}
}

class KeenStatsWidget : KeenWidget
{
	Font fnt;
	TextureID bkg, health, keybkg;

	static const String keys[] = { "CKYellowKey", "CKBlueKey", "CKRedKey", "CKGreenKey" };

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		KeenStatsWidget wdg = KeenStatsWidget(Widget.Init("KeenStatsWidget", widgetname, anchor, 0, priority, pos, zindex));
		if (wdg)
		{
			wdg.fnt = Font.GetFont("HUDFont_Keen");
			wdg.bkg = TexMan.CheckForTexture("CKHUDBKG");
			wdg.health = TexMan.CheckForTexture("CKHLTHM");
			wdg.keybkg = TexMan.CheckForTexture("CKHUDKBG");
		}
	}

	override Vector2 Draw()
	{
		double scale = 2.0;

		size = (172, 64);
		if (player.mo.FindInventory("CKPuzzleItem", true)) { size.x = 202; }
		Super.Draw();

		alpha = 1.0;

		DrawToHud.DrawTexture(bkg, pos, alpha, scale, flags:DrawToHUD.TEX_DEFAULT);

		Inventory treasure = player.mo.FindInventory("CKTreasure");
		String score = String.Format("%i", min((treasure ? treasure.amount : 0) * 100, 999999999));
		DrawToHud.DrawText(score, (pos.x + 160 - fnt.StringWidth(score) * scale, pos.y + 8), fnt, alpha, scale, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);

		Inventory ammo1, ammo2;
		int ammocount1, ammocount2;
		[ammo1, ammo2, ammocount1, ammocount2] = BoAStatusBar(StatusBar).GetWeaponAmmo();
		if (ammo1)
		{
			String ammo = String.Format("%i", min(99, ammocount1));
			DrawToHud.DrawText(ammo, (pos.x + 160 - fnt.StringWidth(ammo) * scale, pos.y + 40), fnt, alpha, scale, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
		}

		// Draw a lifewater drop over the helmet - this is health percentage, not lives as in the original game
		DrawToHud.DrawTexture(health, (pos.x + 18, pos.y + 38), alpha, scale, flags:DrawToHUD.TEX_DEFAULT);

		String health = String.Format("%i", min(999, player.health));
		DrawToHud.DrawText(health, (pos.x + 80 - fnt.StringWidth(health) * scale, pos.y + 40), fnt, alpha, scale, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);

		if (player.mo.FindInventory("CKPuzzleItem", true)) { DrawToHud.DrawTexture(keybkg, (pos.x + 166, pos.y), alpha, scale, flags:DrawToHUD.TEX_DEFAULT); }

		for (int k = 0; k < keys.Size(); k++)
		{
			let key = player.mo.FindInventory(keys[k]);
			if (key)
			{
				int offsetx = 172;
				int offsety = 6 + k * 12; // Space key slot rows 10 pixels apart

				DrawToHud.DrawTexture(key.icon, (pos.x + offsetx, pos.y + offsety), alpha, scale, flags:DrawToHUD.TEX_DEFAULT);
			}
		}

		return size;
	}
}

class KeenInventoryWidget : KeenWidget
{
	Font fnt;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		KeenInventoryWidget wdg = KeenInventoryWidget(Widget.Init("KeenInventoryWidget", widgetname, anchor, 0, priority, pos, zindex));
		if (wdg)
		{
			wdg.fnt = Font.GetFont("HUDFont_Keen_Small");
		}
	}

	override Vector2 Draw()
	{
		if (player.mo.InvSel)
		{
			size = (32, 48);
			Super.Draw();

			Vector2 texsize = ZScriptTools.ScaleTextureTo(player.mo.InvSel.Icon, 32);
			BoAStatusBar(StatusBar).DrawInventoryIcon(player.mo.InvSel, (pos.x + 16, pos.y), StatusBar.DI_ITEM_TOP | StatusBar.DI_ITEM_HCENTER, scale:texsize);
		
			if (player.mo.InvSel is "CKPogoStick")
			{
				String status = CKPogoStick(player.mo.InvSel).active ? "ON" : "OFF";
				DrawToHud.DrawText(status, (pos.x + 16, pos.y + 16 + 8 + fnt.GetHeight() * 2), fnt, alpha, 2.0, shade:Font.CR_WHITE, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_CENTERED);
			}
		}
		else { size = (0, 0); }

		return size;
	}
}

class TankHealthWidget : Widget
{
	TextureID tank, glow;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		TankHealthWidget wdg = TankHealthWidget(Widget.Init("TankHealthWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));
		if (wdg)
		{
			wdg.tank = TexMan.CheckForTexture("TANKSTAT", TexMan.Type_Any);
			wdg.glow = TexMan.CheckForTexture("TANKGLOW", TexMan.Type_Any);
		}
	}

	override bool SetVisibility()
	{
		if (
				!automapactive &&
				screenblocks < 12 &&
				!player.mo.FindInventory("CutsceneEnabled") &&
				player.mo is "TankPlayer"
			) { return true; }
		
		return false;
	}

	override Vector2 Draw()
	{
		double scale = 1.0;
		Color tankclr = Widget.GetHealthColor(player.mo, 0.5);
		Color glowclr = Widget.GetHealthColor(player.mo, 0.95);

		double healthpercent = player.health * 100. / player.mo.Default.health;
		String healthstring = int(healthpercent) .. "%";

		double pulse = healthpercent < 25 ? (sin(level.time * (26 - healthpercent)) + 1.0) / 2 : 0.5; // Start blinking at less than 25% health, faster as health decreases

		size = (56, 94);
		Super.Draw();

		Vector2 drawpos = pos + size / 2;

		DrawToHud.DrawTexture(tank, drawpos - (0, 8), alpha * 0.85, scale / 4, tankclr, flags:DrawToHud.TEX_COLOROVERLAY | DrawToHUD.TEX_CENTERED);
		DrawToHud.DrawTexture(glow, drawpos - (0, 8), alpha * pulse, scale / 4, glowclr, flags:DrawToHud.TEX_COLOROVERLAY | DrawToHUD.TEX_CENTERED);

		DrawToHud.DrawText(healthstring, (drawpos.x, pos.y + size.y - 16), BigFont, alpha * 0.8, scale, shade:Font.CR_GRAY, flags:ZScriptTools.STR_MIDDLE | ZScriptTools.STR_CENTERED);

		return size;
	}
}

class AutomapWidget : Widget
{
	int titleheight, lineheight;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		AutomapWidget wdg = AutomapWidget(Widget.Init("AutomapWidget", widgetname, anchor, 0, priority, pos, zindex));
		if (wdg)
		{
			wdg.titleheight = BigFont.GetHeight();
			wdg.lineheight = SmallFont.GetHeight();
		}
	}

	override bool SetVisibility()
	{
		if (
				automapactive
			) { return true; }
		
		return false;
	}

	// Original code from shared_sbar.cpp
	override Vector2 Draw()
	{
		let fnt = SmallFont;
		let titlefnt = BigFont;

		if (player.mo is "KeenPlayer")
		{
			fnt = Font.GetFont("Classic");
			titlefnt = fnt;
		}

		int clr = Font.CR_GRAY;
		int titleclr = Font.FindFontColor("LightGray");

		String monsters = StringTable.Localize("AM_MONSTERS", false);
		String secrets = StringTable.Localize("AM_SECRETS", false);
		String items = StringTable.Localize("AM_ITEMS", false);

		double height = titleheight + lineheight / 2 + (am_showtime || am_showtotaltime) * lineheight * 1.5 + !deathmatch * ((am_showmonsters && level.total_monsters > 0) + (am_showsecrets && level.total_secrets > 0) + (am_showitems && level.total_items > 0)) * lineheight;
		double width = 0, labelwidth = 0;

		for (int i = 0; i < 3; i++)
		{
			String label;
			int curwidth;

			Switch (i)
			{
				case 0:
					label = monsters;
					break;
				case 1:
					label = secrets;
					break;
				case 2:
					label = items;
					break;
			}

			curwidth = fnt.StringWidth(label .. "   ");

			if (curwidth > labelwidth) { labelwidth = curwidth; }
		}

		String levelname = level.LevelName;
		if (idmypos) { levelname = levelname .. " (" .. level.mapname.MakeUpper() .. ")"; }

		width = max(labelwidth + fnt.StringWidth("0000/0000"), titlefnt.StringWidth(levelname));

		size = (width, height);
		Super.Draw();

		double y = pos.y;

		DrawToHud.DrawText(levelname, pos, titlefnt, alpha, 1.0, shade:titleclr);
		y += titleheight;

		y += int(lineheight / 2);

		String time;

		if (am_showtime) { time = level.TimeFormatted(); }

		if (am_showtotaltime)
		{
			if (am_showtime) { time = time .. " / " .. level.TimeFormatted(true); }
			else { time = level.TimeFormatted(true); }
		}

		if (am_showtime || am_showtotaltime)
		{
			let scale = BoAStatusBar.GetUIScale(hud_scale);
			let vwidth = screen.GetWidth() / scale;
			let vheight = screen.GetHeight() / scale;

			screen.DrawText(fnt, clr, pos.x, y, time, DTA_VirtualWidth, vwidth, DTA_VirtualHeight, vheight, DTA_Monospace, 2, DTA_Spacing, fnt.GetCharWidth("0"), DTA_KeepRatio, true, DTA_Alpha, alpha);
			y += int(lineheight * 3 / 2);
		}

		if (!deathmatch)
		{
			String value;

			if (am_showmonsters && level.total_monsters > 0)
			{
				DrawToHud.DrawText(monsters, (pos.x, y), fnt, alpha, 1.0, shade:clr);

				value = value.Format("%d/%d", level.killed_monsters, level.total_monsters);
				DrawToHud.DrawText(value, (pos.x + labelwidth, y), fnt, alpha, 1.0, shade:Font.CR_RED);

				y += lineheight;
			}

			if (am_showsecrets && level.total_secrets > 0)
			{
				DrawToHud.DrawText(secrets, (pos.x, y), fnt, alpha, 1.0, shade:clr);

				value = value.Format("%d/%d", level.found_secrets, level.total_secrets);
				DrawToHud.DrawText(value, (pos.x + labelwidth, y), fnt, alpha, 1.0, shade:Font.CR_GOLD);

				y += lineheight;
			}

			// Draw item count
			if (am_showitems && level.total_items > 0)
			{
				DrawToHud.DrawText(items, (pos.x, y), fnt, alpha, 1.0, shade:clr);

				value = value.Format("%d/%d", level.found_items, level.total_items);
				DrawToHud.DrawText(value, (pos.x + labelwidth, y), fnt, alpha, 1.0, shade:Font.CR_YELLOW);

				y += lineheight;
			}
		}

		return (size.x, y);
	}
}