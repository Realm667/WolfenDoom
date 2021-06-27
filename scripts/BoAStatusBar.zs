/*
 * Copyright (c) 2018-2020 AFADoomer
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

class BoAStatusBar : BaseStatusBar
{
	HUDFont mBigFont;
	HUDFont mHUDFont;
	HUDFont mSmallFont;
	Font ClassicFont;

	DynamicValueInterpolator mAirInterpolator;
	DynamicValueInterpolator mBatteryInterpolator;
	DynamicValueInterpolator mOilInterpolator;
	DynamicValueInterpolator mSpaceSuitInterpolator;
	DynamicValueInterpolator mStaminaInterpolator;
	DynamicValueInterpolator mSuspicionInterpolator;
	DynamicValueInterpolator mVisibilityInterpolator;

	bool stealth;
	double basealpha;
	double healthbaralpha;
	double velocity, oldangle, oldpitch;
	int alertedcount;
	int barstate;
	int LastHealth;
	int LastMaxHealth;
	int paintimer;
	int savetimer;
	int savetimertime;
	String LastIcon;
	String LastTag;
	double hour, minute, second;
	Inventory lastinv;
	int maptop, maptexty;
	Actor currenttarget;
	int targettime;
	int widthoffset;

	Array<widget> widgets;

	protected Le_GlScreen gl_proj;
	protected Le_Viewport viewport;

	override void Init()
	{
		Super.Init();
		gl_proj = new("Le_GlScreen");
		SetSize(0, 320, 200);
		CompleteBorder = True;

		// Create the fonts used
		mBigFont = HUDFont.Create("BIGFONT", 0);
		mSmallFont = HUDFont.Create("SMALLFONT", 0);
		mHUDFont = HUDFont.Create("THREEFIV", 0);

		ClassicFont = Font.GetFont("Classic");

		mAirInterpolator = DynamicValueInterpolator.Create(0, 1.25, 1, 40);
		mBatteryInterpolator = DynamicValueInterpolator.Create(0, 1.25, 1, 40);
		mOilInterpolator = DynamicValueInterpolator.Create(0, 1.25, 1, 40);
		mSpaceSuitInterpolator = DynamicValueInterpolator.Create(0, 1.25, 1, 40);
		mStaminaInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mSuspicionInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);
		mVisibilityInterpolator = DynamicValueInterpolator.Create(0, 0.25, 1, 8);

		savetimertime = 70;

		AutomapWidget.Init("Automap Info", Widget.WDG_TOP | Widget.WDG_LEFT, 0);
		KeenStatsWidget.Init("Keen HUD", Widget.WDG_TOP | Widget.WDG_LEFT, 0);
		CountWidget.Init("Money and Time", Widget.WDG_TOP | Widget.WDG_LEFT, 0);
		LogWidget.Init("Notifications", Widget.WDG_TOP | Widget.WDG_LEFT, 0, zindex:100);
		CompassWidget.Init("Compass", Widget.WDG_TOP | Widget.WDG_LEFT, 1);

		ObjectivesWidget.Init("Objectives", Widget.WDG_RIGHT, 0);
		KeenInventoryWidget.Init("Keen Inventory", Widget.WDG_RIGHT, 0);
		PositionWidget.Init("Position", Widget.WDG_RIGHT, 0);
		KeyWidget.Init("Keys", Widget.WDG_RIGHT, 1);
		PuzzleItemWidget.Init("Puzzle Items", Widget.WDG_RIGHT, 2, (16, 0));

		AirSupplyWidget.Init("Air Supply", Widget.WDG_MIDDLE, 0, (0, -32));

		HealthWidget.Init("Health and Armor", Widget.WDG_BOTTOM, 0);
		TankHealthWidget.Init("Tank Health", Widget.WDG_BOTTOM, 0);
		InventoryWidget.Init("Selected Inventory", Widget.WDG_BOTTOM, 0);
		LogWidget.Init("Chat", Widget.WDG_BOTTOM, 0, zindex:99);
		ActiveEffectWidget.Init("Active Effects", Widget.WDG_BOTTOM, 1);

		StaminaWidget.Init("Stamina", Widget.WDG_MIDDLE | Widget.WDG_RIGHT, 0, (0, -32));
		
		CurrentAmmoWidget.Init("Current Ammo", Widget.WDG_BOTTOM | Widget.WDG_RIGHT, 0);
		AmmoWidget.Init("Ammo Summary", Widget.WDG_BOTTOM | Widget.WDG_RIGHT, 0);
		WeaponWidget.Init("Weapon", Widget.WDG_BOTTOM | Widget.WDG_RIGHT, 1);

		StealthWidget.Init("Stealth Bar", Widget.WDG_BOTTOM | Widget.WDG_CENTER, 0, (0, 12));
		PowerWidget.Init("Lantern and Minesweeper Power", Widget.WDG_BOTTOM | Widget.WDG_CENTER, 1, (0, 16));

		DamageWidget.Init("Damage Indicator", Widget.WDG_MIDDLE | Widget.WDG_CENTER, 0);
		GrenadeWidget.Init("Grenade Indicator", Widget.WDG_MIDDLE | Widget.WDG_CENTER, 0);

		CalcOffsets();
	}

	override void NewGame ()
	{
		Super.NewGame();

		mAirInterpolator.Reset(0);
		mBatteryInterpolator.Reset(0);
		mOilInterpolator.Reset(0);
		mSpaceSuitInterpolator.Reset(0);
		mStaminaInterpolator.Reset(0);
		mSuspicionInterpolator.Reset(0);
		mVisibilityInterpolator.Reset(0);
	}

	override bool ProcessNotify(EPrintLevel printlevel, String outline)
	{
		bool processed = false;

		if (gameaction == ga_savegame || gameaction == ga_autosave)
		{
			// Don't print save messages
			savetimer = savetimertime;
			processed = true;
		}

		if (!processed && printlevel & PRINT_TYPES <= PRINT_TEAMCHAT)
		{
			Font fnt = (CPlayer.mo is "KeenPlayer") ? ClassicFont : SmallFont;

			if (printlevel <= PRINT_HIGH) { Log.Add(CPlayer, outline, "Notifications", printlevel, fnt); }
			else { Log.Add(CPlayer, outline, "Chat", printlevel, fnt); }

			processed = true; 
		}

		return processed;
	}

	override void Tick()
	{
		maptop = CheckInventory("IncomingMessage", 1) ? int(48 / 200.0 * Screen.GetHeight() / BoAStatusBar.GetUIScale(hud_scale)) : 0;
		if (maptexty > maptop) { maptexty = max(maptop, maptexty - 12); }
		else if (maptexty < maptop) { maptexty = min(maptop, maptexty + 12); }

		Super.Tick();

		savetimer = max(0, savetimer - 1);

		mAirInterpolator.Update(GetAirTime());
		mStaminaInterpolator.Update(GetAmount("Stamina")); // This is a custom inventory item, not CPlayer.mo.stamina!

		if (CheckInventory("MineSweeper", 1)) { mBatteryInterpolator.Update(GetAmount("Power")); }
		if (CheckInventory("LanternPickup", 1)) { mOilInterpolator.Update(GetAmount("LanternOil")); }
		if (CheckInventory("PowerSpaceSuit", 1)) { mSpaceSuitInterpolator.Update(CPlayer.mo.GetEffectTicsForItem("SpaceSuit")); }

		Inventory vis = CPlayer.mo.FindInventory("BoAVisibility");
		if (vis)
		{
			mVisibilityInterpolator.Update(int(BoAVisibility(vis).visibility));

			alertedcount = BoAVisibility(vis).alertedcount;

			if (alertedcount)
			{
				mSuspicionInterpolator.Update(100);  // Force the suspicion level to 100% if sneakable enemies are alerted
			}
			else  // Otherwise use actual suspicion level
			{
				mSuspicionInterpolator.Update(int(BoAVisibility(vis).suspicion));
			}
		}

		// This gets rid of needing to double-press useinv to immediately use a newly selected inventory item.
		CPlayer.inventorytics = 0;

		Widget.TickWidgets();
	}

	override void Draw (int state, double TicFrac)
	{
		CalcOffsets();

		Super.Draw(state, TicFrac);

		if (CPlayer.mo.FindInventory("CutsceneEnabled") || CPlayer.morphtics || level.maptime < 5)
		{
			if (automapactive || state == HUD_StatusBar)
			{
				if (CPlayer.morphtics)
				{
					SetSize(0, 320, 200);
					UpdateScreenGeometry();
					BeginStatusBar(true);
				}
				else
				{
					BeginStatusBar();
					DrawImage("AMBAR", (-54, 152), DI_ITEM_OFFSETS);
				}
			}

			if (!automapactive && CPlayer.morphtics)
			{
				if (CPlayer.mo is "TankPlayer") { DrawTankStatusBar(); }
				else if (CPlayer.mo is "KeenPlayer") { DrawKeenStatusBar(); }
			}
		}
		else if (!automapactive)
		{
			// Draw fullscreen overlays, regardless of status bar state
			BeginHUD(1, True);
				DrawHealthBars();

				//Draw Mask for Space Suit
				if (CheckInventory("PowerSpaceSuit", 1))
				{
					int current, max;
					[current, max] = CPlayer.mo.GetEffectTicsForItem("SpaceSuit");

					current = mSpaceSuitInterpolator.GetValue();
					DrawBar("HORZSP2F", "HORZSP2E", current, max, (-18, 73), 0, SHADER_HORZ, DI_SCREEN_CENTER | DI_ITEM_OFFSETS);
				}

				DrawCrosshairHint();

				if (GetGlobalACSValue(60) > -1) { DrawDayNightState(); }
			BeginHUD(1, False);

			barstate = state;

			if (state == HUD_StatusBar)
			{
				SetSize(32, 320, 200);
				BeginStatusBar(False);
				DrawMainBar(TicFrac);
			}
		}
		else
		{
			SetSize(0, 320, 200);
		}

		Widget.DrawWidgets();

		DrawSaveIcon();
	}

	virtual void DrawSaveIcon()
	{
		if (savetimer)
		{
			TextureID save = TexMan.CheckForTexture("SAVEICON", TexMan.Type_Any);

			if (save)
			{
				double savealpha = 1.0;

				if (savetimer > (savetimertime - 15)) { savealpha = (savetimertime - savetimer) / 15.0; }
				else if (savetimer <= 15) { savealpha = savetimer / 15.0; }

				screen.DrawTexture(save, true, 620, 20, DTA_CenterOffset, true, DTA_KeepRatio, true, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_Alpha, savealpha);
			}
		}
	}

	virtual void DrawMainBar(double TicFrac)
	{
		DrawImage("HUDBAR", (-54, 152), DI_ITEM_OFFSETS);

		bool disguisetag = DrawVisibilityBar((85, 153), scale: 0.5);

		//Minesweeper & Lantern
		DrawMinesweeper(162, 138, DI_SCREEN_OFFSETS);
		DrawLantern(162, 138, DI_SCREEN_OFFSETS);

		//AirControl & Stamina
		DrawBar("HORZAIRF", "HORZAIRE", mAirInterpolator.GetValue(), level.airsupply, (36, 160), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
		DrawBar("HORZSTMF", "HORZSTME", mStaminaInterpolator.GetValue(), 100, (88, 160), 0, SHADER_HORZ, DI_ITEM_OFFSETS);

		//Ammo
		Inventory ammo1, ammo2;
		int ammocount1, ammocount2;
		[ammo1, ammo2, ammocount1, ammocount2] = GetWeaponAmmo();
		if (ammo1) { DrawString(mBigFont, FormatNumber(ammocount1, 3), (229, 171), DI_TEXT_ALIGN_RIGHT); }
		if (ammo2 && ammo1 != ammo2) { DrawString(mBigFont, FormatNumber(ammocount2, 3), (229, 185), DI_TEXT_ALIGN_RIGHT); }

		//Ammo Icons
		Vector2 texsize;
		if (ammo1)
		{
		 	texsize = ZScriptTools.ScaleTextureTo(ammo1.icon, 16);
			DrawInventoryIcon(ammo1, (231, 170), DI_ITEM_OFFSETS, scale:texsize);
		}
		
		if (ammo2 && ammo2 != ammo1)
		{
			texsize = ZScriptTools.ScaleTextureTo(ammo2.icon, 16);
			DrawInventoryIcon(ammo2, (231, 184), DI_ITEM_OFFSETS, scale:texsize);
		}

		//Weapon
		if (!disguisetag) { DrawString(mHUDFont, GetWeaponTag(), (190, 159), DI_TEXT_ALIGN_CENTER); }

		//Time
		String time = level.TimeFormatted();

		if (hour || minute || second)
		{
			time = FormatNumber(int(hour), 2, 2, FNF_FILLZEROS) .. ":" .. FormatNumber(int(minute), 2, 2, FNF_FILLZEROS) .. ":" .. FormatNumber(int(second), 2, 2, FNF_FILLZEROS);
		}

		DrawString(mHUDFont, time, (250, 159));

		//Health
		DrawString(mBigFont, FormatNumber(CPlayer.health, 3), (52, 171), DI_TEXT_ALIGN_RIGHT);
		DrawString(mBigFont, "%", (65, 171), DI_TEXT_ALIGN_RIGHT);

		//Armor
		let armor = CPlayer.mo.FindInventory("BasicArmor");
		if (armor != null && armor.Amount > 0)
		{
			DrawIcon(armor, 4, 184, 24, DI_ITEM_OFFSETS);
			DrawString(mBigFont, FormatNumber(GetArmorAmount(), 3), (52, 185), DI_TEXT_ALIGN_RIGHT);
			DrawString(mBigFont, "%", (65, 185), DI_TEXT_ALIGN_RIGHT);
		}

		//Money
		DrawString(mBigFont, FormatNumber(GetAmount("CoinItem")), (138, 171), DI_TEXT_ALIGN_LEFT);

		//Grenade
		DrawString(mBigFont, FormatNumber(GetAmount("GrenadePickup")), (138, 185), DI_TEXT_ALIGN_LEFT);

		String grenadetex = "HUD_GREN";
		if (CPlayer.mo.FindInventory("AstroGrenadeToken")) { grenadetex = "HUD_GRAS"; }
		DrawImage(grenadetex, (122, 184), DI_ITEM_OFFSETS);

		//Keys
		if (GetAmount("BoABlueKey")) { DrawImage("STKEYS0", (254, 171), DI_ITEM_OFFSETS); }
		if (GetAmount("BoAGreenKey")) { DrawImage("STKEYS3", (260, 171), DI_ITEM_OFFSETS); }
		if (GetAmount("BoAYellowKey")) { DrawImage("STKEYS1", (254, 180), DI_ITEM_OFFSETS); }
		if (GetAmount("BoAPurpleKey")) { DrawImage("STKEYS4", (260, 180), DI_ITEM_OFFSETS); }
		if (GetAmount("BoARedKey")) { DrawImage("STKEYS2", (254, 189), DI_ITEM_OFFSETS); }
		if (GetAmount("BoACyanKey")) { DrawImage("STKEYS5", (260, 189), DI_ITEM_OFFSETS); }

		if (GetAmount("AstroBlueKey")) { DrawImage("ATKEYS0", (254, 171), DI_ITEM_OFFSETS); }
		if (GetAmount("AstroYellowKey")) { DrawImage("ATKEYS1", (254, 180), DI_ITEM_OFFSETS); }
		if (GetAmount("AstroRedKey")) { DrawImage("ATKEYS2", (254, 189), DI_ITEM_OFFSETS); }

		//Ammo
		DrawString(mHUDFont, FormatNumber(GetAmount("Ammo9mm"), 3), (284, 172), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFont, FormatNumber(GetAmount("Ammo12Gauge"), 3), (284, 178), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFont, FormatNumber(GetAmount("MauserAmmo"), 3), (284, 184), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFont, FormatNumber(GetAmount("FlameAmmo"), 3), (284, 190), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFont, FormatNumber(GetAmount("NebAmmo"), 3), (307, 172), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFont, FormatNumber(GetAmount("PanzerAmmo"), 3), (307, 178), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFont, FormatNumber(GetAmount("TeslaCell"), 3), (307, 184), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFont, FormatNumber(GetAmount("Soul"), 3), (307, 190), DI_TEXT_ALIGN_RIGHT);

		if (CPlayer.mo.InvSel != null && !level.NoInventoryBar)
		{
			DrawInventorySelection(94, 184, 28);
		}
		else
		{
			DrawMugShot((76, 168));
		}

		DrawImage("HUDBROVL", (74, 168), DI_ITEM_OFFSETS);
	}

	virtual void DrawInventorySelection(int x, int y, int size = 32)
	{
		DrawIcon(CPlayer.mo.InvSel, x, y, size);
	}

	int CountPuzzleItems(int maxrows = 0, int col = 1)
	{
		int count = 0;
		Inventory nextinv = CPlayer.mo.Inv;

		while (nextinv)
		{
			if (!nextinv.bInvBar && nextinv is "PuzzleItem" && !(nextinv is "CoinItem") && !(nextinv is "CKPuzzleItem") && nextinv.icon)
			{
				count++;
			}

			if (maxrows > 0 && count == maxrows)
			{
				if (--col == 0) { break; }
				else { count = 0; }
			}

			nextinv = nextinv.Inv;
		}

		return count;
	}

	virtual int, int DrawPuzzleItems(int x, int y, int size = 32, int maxrows = 6, int maxcols = 0, bool vcenter = false, int flags = 0, double alpha = 1.0)
	{
		if (!CPlayer.mo.Inv) { return 0, 0; }

		int starty = y;
		int rows = 1;
		int rowcount = 1;
		int cols = 1;

		Inventory nextinv = CPlayer.mo.Inv;

		if (vcenter) { y -= int((size + 2) * CountPuzzleItems(maxrows) / 2.0); }

		nextinv = CPlayer.mo.Inv;

		while (nextinv)
		{
			// Draw puzzle items that are not already in the inventory bar, not drawn elsewhere, and not tied to Keen maps (and have an icon defined)
			if (!nextinv.bInvBar && nextinv is "PuzzleItem" && !(nextinv is "CoinItem") && !(nextinv is "CKPuzzleItem") && nextinv.icon)
			{
				DrawIcon(nextinv, x, y, size, flags, alpha);

				// Move down a block
				if (maxrows <= 0 || rows < maxrows)
				{
					y += size + 2;
					rows++;
					rowcount = max(rowcount, rows);
				}
				else if (maxcols <= 0 || cols <= maxcols) // Wrap to the next column if we're too long
				{
					y = vcenter ? starty - int((size + 2) * CountPuzzleItems(maxrows, cols + 1) / 2.0) : starty;
					rows = 1;

					x -= size + 2;
					cols++;
				}
				else
				{
					break;
				}
			}

			nextinv = nextinv.Inv;
		}

		return cols, rowcount;
	}

	virtual void DrawIcon(Inventory item, int x, int y, int size, int flags = DI_ITEM_CENTER, double alpha = 1.0, bool amounts = true, int style = STYLE_Translucent, color clr = 0xFFFFFFFF)
	{
		Vector2 texsize, iconsize;
		[texsize, iconsize] = ZScriptTools.ScaleTextureTo(item.icon, size);
		Vector2 textpos = (x, y);

		if (flags & DI_ITEM_LEFT)
		{
			x += int((size - iconsize.x) / 2); // Center the icon in the size-defined cell
			textpos.x += size - 2;
		}
		else if (flags & DI_ITEM_RIGHT) {}
		else
		{
			textpos.x += size / 2 - 2;
		}

		if (flags & DI_ITEM_VCENTER)
		{
			textpos.y += size / 2 - 2;
		}
		else if (flags & DI_ITEM_TOP)
		{
			y += int((size - iconsize.y) / 2); // Center the icon in the size-defined cell
			textpos.y += size - 2;
		}

		DrawInventoryIcon(item, (x, y), flags, item.alpha * alpha, scale:texsize, style:style, clr:clr);

		if (!amounts) { return; }

		if (item is "RepairKit" && CPlayer.mo is "TankPlayer")
		{
			RepairKit(item).DrawStatus(int(textpos.x), int(textpos.y), size, alpha);
		}
		else if (item is "BasicArmor")
		{
/*
			let armor = BasicArmor(CPlayer.mo.FindInventory("BasicArmor"));
			if (!armor) { return; }

			String value = FormatNumber(int(armor.SavePercent * 100)) .. "%";
			DrawString(mHUDFont, value, (textpos.x, textpos.y - mHUDFont.mFont.GetHeight() / 2), DI_TEXT_ALIGN_CENTER, Font.CR_GRAY);
*/
		}
		else if (item.Amount > 1)
		{
			DrawString(mHUDFont, FormatNumber(item.Amount), (textpos.x, textpos.y - mHUDFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD, alpha);
		}
		else if (item is "PoweredInventory") // For powered inventory items, show current fuel level as a percentage
		{
			let item = PoweredInventory(item);
			Inventory fuel;

			if (item) { fuel = CPlayer.mo.FindInventory(item.fuelclass); }

			if (fuel)
			{
				int amt = int(100 * fuel.Amount / fuel.MaxAmount);
				DrawString(mHUDFont, FormatNumber(amt) .. "%", (textpos.x, textpos.y - mHUDFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD, alpha);
			}
		}
		else if (item is "PowerupToggler")
		{
			int maxamt = PowerupToggler(item).Default.EffectTics;
			int amt = int(100 * PowerupToggler(item).EffectTics / maxamt);

			if (maxamt < 0x7FFFFFFF) { DrawString(mHUDFont, FormatNumber(amt) .. "%", (textpos.x, textpos.y - mHUDFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD, alpha); }
		}

	}

	bool DrawLantern(int posx, int posy, int flags = DI_SCREEN_CENTER_BOTTOM, double alpha = 1.0)
	{
		if (CheckInventory("LanternPickup", 1))
		{
			int current = mOilInterpolator.GetValue();
			int max = GetMaxAmount("LanternOil");

			LanternPickup l = LanternPickup(CPlayer.mo.FindInventory("LanternPickup"));

			if (l && l.active)
			{
				DrawImage("LANT_BAK", (posx, posy), flags, alpha);
				DrawBar("LANT_ON", "LANT_OFF", current, max, (posx, posy), 0, SHADER_VERT | SHADER_REVERSE, flags, alpha);

				return true;
			}
		}

		return false;
	}

	bool DrawMineSweeper(int posx, int posy, int flags = DI_SCREEN_CENTER_BOTTOM, double alpha = 1.0)
	{
		if (CheckInventory("MineSweeper", 1))
		{
			int current = mBatteryInterpolator.GetValue();
			int max = GetMaxAmount("Power");

			MineSweeper ms = MineSweeper(CPlayer.mo.FindInventory("MineSweeper"));

			if (ms && ms.active)
			{
				DrawImage("SWEP_BAK", (posx, posy), flags, alpha);
				DrawBar("SWEP_ON", "SWEP_OFF", current, max, (posx, posy), 0, SHADER_HORZ, flags, alpha);

				return true;
			}
		}

		return false;
	}

	virtual void DrawDayNightState()
	{
		double ACStime = GetGlobalACSValue(60) / 65536.0;

		double secduration = 1.0 / (24 * 60 * 60);

		if (ACStime == 0)
		{
			hour = 17;
			minute = 15;
			second = 0;
		}
		else
		{
			second = ACStime / secduration;
			minute = second / 60 + 15;	// Offset these by 15 and 17 to have a start time that's not midnight (aiming for 1715 sunset, 0715 sunrise)
			hour = minute / 60 + 17; 	// 

			second %= 60;
			minute %= 60;
			hour %= 24;
		}

		// TODO - Handle drawing day/night hud indicator here...  Using these values for the time indicator is already handled in the time drawing code.
	}

	//Custom version of DrawBar that allows drawing with alpha - mostly copy/paste from original function, modified to allow alpha and scaling
	void DrawBarAlpha(String ongfx, String offgfx, double curval, double maxval, Vector2 position, int border, int vertical, int flags = 0, double alpha = 1., double scale = 1.)
	{
		let ontex = TexMan.CheckForTexture(ongfx, TexMan.TYPE_MiscPatch);
		if (!ontex.IsValid()) return;
		let offtex = TexMan.CheckForTexture(offgfx, TexMan.TYPE_MiscPatch);

		Vector2 texsize = TexMan.GetScaledSize(ontex);
		texsize.x *= scale;
		texsize.y *= scale;
		[position, flags] = AdjustPosition(position, flags, texsize.X, texsize.Y);

		double value = (maxval != 0) ? clamp(curval / maxval, 0, 1) : 0;
		if(border != 0) value = 1. - value; //invert since the new drawing method requires drawing the bg on the fg.

		// {cx, cb, cr, cy}
		double Clip[4];
		Clip[0] = Clip[1] = Clip[2] = Clip[3] = 0;

		bool horizontal = !(vertical & SHADER_VERT);
		bool reverse = !!(vertical & SHADER_REVERSE);
		double sizeOfImage = (horizontal ? texsize.X - border*2 : texsize.Y - border*2);
		Clip[(!horizontal) | ((!reverse)<<1)] = sizeOfImage - sizeOfImage * value;

		// preserve the active clipping rectangle
		int cx, cy, cw, ch;
		[cx, cy, cw, ch] = screen.GetClipRect();

		if(border != 0)
		{
			for(int i = 0; i < 4; i++) Clip[i] += border;

			//Draw the whole foreground
			DrawTexture(ontex, position, flags | DI_ITEM_LEFT_TOP, alpha, scale: (scale, scale));
			SetClipRect(position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3], flags);
		}

		if (offtex.IsValid()) { DrawTexture(offtex, position, flags | DI_ITEM_LEFT_TOP, alpha, scale: (scale, scale)); }

		if (border == 0)
		{
			SetClipRect(position.X + Clip[0], position.Y + Clip[1], texsize.X - Clip[0] - Clip[2], texsize.Y - Clip[1] - Clip[3], flags);
			DrawTexture(ontex, position, flags | DI_ITEM_LEFT_TOP, alpha, scale: (scale, scale));
		}
		// restore the previous clipping rectangle
		screen.SetClipRect(cx, cy, cw, ch);
	}

	bool LivingSneakableActors()
	{
		if (level.time < 5 || level.time % 35 == 0) // Cut down on how often this is run
		{
			ThinkerIterator it = ThinkerIterator.Create("StealthBase", Thinker.STAT_DEFAULT - 2); // Just iterate over the sneakable eyes - faster than all Nazi actors
			StealthBase mo;
			while (mo = StealthBase(it.Next()))
			{
				stealth = true;
				return true;
			}

			stealth = false;
			return false;
		}

		return stealth; // Set up like this so it basically returns last known value if it's not time to re-poll
	}

	virtual void DrawMugShot(Vector2 position)
	{
		int flags = MugShot.STANDARD;
		String face = CPlayer.mo.face;

		if (NaziWeapon(CPlayer.readyweapon) && NaziWeapon(CPlayer.readyweapon).bNoRampage) { flags |= MugShot.DISABLERAMPAGE; }

		let disguise = DisguiseToken(CPlayer.mo.FindInventory("DisguiseToken", True));
		if (disguise)
		{
			flags |= MugShot.CUSTOM;
			face = disguise.HUDSprite; 
		}

		DrawTexture(GetMugShot(5, flags, face), position, DI_ITEM_OFFSETS);
	}

	virtual bool DrawVisibilityBar(Vector2 position = (0, -20), int flags = DI_SCREEN_HCENTER | DI_SCREEN_BOTTOM, double scale = 1.0, double alpha = 1.0)
	{
		Inventory disguise;

		if (CPlayer.mo.FindInventory("BoAVisibility"))
		{
			int current, max;

			double x = position.x;
			double y = position.y;

			if (LivingSneakableActors())
			{
				if (basealpha < 1) { basealpha += 0.05; }

				basealpha *= alpha;

				if (barstate == HUD_StatusBar) { DrawImage("VIS_BKG", (x - 4 * scale, y + 6 * scale), flags | DI_ITEM_CENTER, basealpha, (-1, -1), (2 * scale, 2 * scale)); }

				// Scale visibility to show more useful granularity
				current = Clamp(mVisibilityInterpolator.GetValue() - 50, 0, 50);
				max = 50;

				if (alertedcount)
				{
					if (barstate == HUD_Fullscreen)
					{
						DrawImage("EYE", (x + 112 * scale, y - 1 * scale), flags | DI_ITEM_CENTER, basealpha, (-1, -1), (0.5 * scale, 0.5 * scale));
						DrawString(mHUDFont, FormatNumber(alertedcount), (x + 124 * scale, y * scale - 2), flags | DI_TEXT_ALIGN_RIGHT, Font.CR_GRAY);
					}
					else
					{
						DrawImage("EYE", (170, 190), flags | DI_ITEM_CENTER, basealpha, (-1, -1), (0.25, 0.25));
						DrawString(mHUDFont, FormatNumber(alertedcount), (178, 190), flags | DI_TEXT_ALIGN_RIGHT, Font.CR_GRAY);
					}
				}

				int suspicion = mSuspicionInterpolator.GetValue();

				current = max(current, suspicion - 50);

				DrawBarAlpha("VIS_BLK", barstate == HUD_StatusBar ? "VIS_BAC2" : "VIS_BACK", current, max, (x, y), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, basealpha, scale);

				disguise = CPlayer.mo.FindInventory("DisguiseToken", True);

				// If the player has an active disguise, a stealth weapon selected, and NoTarget enabled, grey out the visibility bar and show the disguise icon
				if (disguise && DisguiseToken(disguise).notargettimeout && CPlayer.cheats & CF_NOTARGET)
				{
					DrawBarAlpha("VIS_RED", "", current, max, (x, y), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, basealpha * suspicion / 100., scale);

					if (barstate == HUD_Fullscreen)
					{
						String disguisetag = disguise.GetTag();
						if (disguisetag != "") { disguisetag = " - " .. disguisetag; }

						DrawInventoryIcon(disguise, (x - 104 * scale, y), flags | DI_ITEM_CENTER, basealpha, (-1, -1), (scale, scale));
						DrawString(mHUDFont, StringTable.Localize("$DISGUISED") .. disguisetag, (x, y - 4), flags | DI_TEXT_ALIGN_CENTER, Font.CR_GRAY, basealpha - (suspicion / 100.));
					}
					else
					{
						DrawInventoryIcon(disguise, (240, 184), flags | DI_ITEM_CENTER, basealpha, (-1, -1), (0.75, 0.75));
						DrawString(mHUDFont, StringTable.Localize("$DISGUISED"), (190, 159), DI_TEXT_ALIGN_CENTER, Font.CR_GRAY, basealpha - (suspicion / 100.));
					}
				}
				else
				{
					disguise = null;

					DrawBarAlpha("VIS_GRN", "", current, max, (x, y), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, basealpha, scale);
					DrawBarAlpha("VIS_YEL", "", current, max, (x, y), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, basealpha * current / (max * .8), scale);
					DrawBarAlpha("VIS_RED", "", current, max, (x, y), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, basealpha * current / double(max), scale);
				}
			}
			else
			{
				current = mVisibilityInterpolator.GetValue();
				max = 100;

				if (basealpha > 0) { basealpha -= 0.05; }
				DrawBarAlpha("VIS_BLK", "VIS_BACK", current, max, (x, y), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, basealpha, scale);
			}
		}

		return !!disguise;
	}

	void DrawHealthBars()
	{
		if (screenblocks > 11) { return; }

		Actor mo;

		if (BoAPlayer(CPlayer.mo))
		{
			mo = BoAPlayer(CPlayer.mo).CrosshairTarget;

			if (mo) { while (mo.master) { mo = mo.master; } } // Use the actor's master if it has one

			if (!mo || mo && (!mo.bShootable || mo.health <= 0 || !mo.bBoss)) { mo = BoAPlayer(CPlayer.mo).ForcedHealthBar; } // Fall back to the "force-drawn" one, if there is one
		}

		if (mo && mo.bShootable && mo.health > 0 && (mo.bBoss || (Base(mo) && Base(mo).user_DrawHealthBar)))
		{
			LastTag = mo.GetTag();
			LastHealth = mo.health;
			LastMaxHealth = mo.GetSpawnHealth();
			if (Base(mo))
			{
				LastIcon = Base(mo).BossIcon;
				LastMaxHealth = mo.GetSpawnHealth();
			}
			else { LastIcon = ""; }

			if (healthbaralpha < 1) { healthbaralpha += 0.2; }
		}
		else
		{
			if (mo && mo.health <= 0) { LastHealth = 0; }
			if (healthbaralpha > 0) { healthbaralpha -= 0.2; }
		}

		if (healthbaralpha > 0) { DrawHealthBar(LastTag, LastHealth, LastMaxHealth, LastIcon); }
	}

	virtual void DrawHealthBar(String tag, int health, int maxhealth, String icon = "")
	{
		int flags = DI_SCREEN_TOP | DI_SCREEN_HCENTER;

		double screenoffset = MessageHandler.GetOffset();
		int basey = 16 + (screenoffset > 0 ? int(screenoffset * 300) : 0);

		DrawBarAlpha("HEALTHMX", "HEALTH00", health, maxhealth, (0, basey), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, 1.0 * healthbaralpha);
		DrawBarAlpha("HEALTH_Y", "", health, maxhealth, (0, basey), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, ((maxhealth - health) / (maxhealth * 0.25)) * healthbaralpha);
		DrawBarAlpha("HEALTH_R", "", health, maxhealth, (0, basey), 0, SHADER_HORZ, flags | DI_ITEM_CENTER, ((maxhealth - health) / (maxhealth * 0.75)) * healthbaralpha);
		DrawImage(icon, (-70, basey), flags | DI_ITEM_CENTER, healthbaralpha, (-1, -1), (0.5, 0.5));

		String nametag = tag;

		Vector2 hudscale = Statusbar.GetHudScale();
		Vector2 screenpos;

		double hscale = max(1.0, Screen.GetHeight() / ((200 / 10) * mSmallFont.mFont.GetHeight()));
		double wscale = 152.0 * hscale / SmallFont.StringWidth(nametag);
		double scale = min(wscale, hscale);

		int width = int(Screen.GetWidth() / scale);
		int height = int(Screen.GetHeight() / scale);

		screenpos.x = width / 2;
		screenpos.y = basey * (hudscale.y / scale);

		screenpos.y -= mSmallFont.mFont.GetHeight() / 2;
		screenpos.x -= SmallFont.StringWidth(nametag) / 2;

		screen.DrawText(SmallFont, Font.CR_GRAY, screenpos.x, screenpos.y, nametag, DTA_KeepRatio, true, DTA_VirtualWidth, width, DTA_VirtualHeight, height, DTA_Alpha, healthbaralpha * 0.75);
	}

	virtual void DrawCrosshairHint()
	{
		int crosshair = 0;
		String crosshairstring;
		Actor crosshairtarget;
		color clr = 0x000000;
		TextureID CrosshairImage;
		double chscale = max(0.35, crosshairscale); // Scale with crosshair, down to a certain point
		double size = (vid_scalefactor > 0 ? vid_scalefactor : 1.0) * clamp(Screen.GetWidth() / 1920.0, 0.25, 1.0) * 3.5 * chscale; // Smaller screen widths get smaller overlays
		Vector2 dimensions;
		double w, h;
		double maxwidth = chscale * max(64.0, int(screen.GetWidth() / 20));

		if (BoAPlayer(CPlayer.mo))
		{
			// Try to retrieve the values from the player
			crosshair = BoAPlayer(CPlayer.mo).crosshair;
			crosshairstring = BoAPlayer(CPlayer.mo).crosshairstring;
			crosshairtarget = BoAPlayer(CPlayer.mo).crosshairtarget;
		}

		// Don't continue if there's no crosshair, we're in titlemap, or the player is dead
		if (
			(!crosshair && !crosshairstring && !crosshairtarget) || 
			CPlayer.cheats & CF_CHASECAM ||
			gamestate == GS_TITLELEVEL || 
			CPlayer.health <= 0
		) { return; }

		if (crosshair) // Integer values take precedence over class names (mostly for setting status via ACS)
		{
			if (crosshair >= 80 && crosshair <= 90)
			{
				clr = 0xDEDEDE;  // If it's a status indicator, make it white/grey
			}
			else
			{
				clr = 0x00FF00; // Otherwise make it green (as if the item is in inventory)
			}

			CrosshairImage = TexMan.CheckForTexture("XHAIR" .. crosshair, TexMan.Type_Any);

			dimensions = TexMan.GetScaledSize(CrosshairImage);

			maxwidth = 64.0 / min(1.0, vid_scalefactor);

			if (dimensions.x > dimensions.y)
			{
				dimensions.y *= maxwidth / dimensions.x;
				dimensions.x = maxwidth;
			}
			else
			{
				dimensions.x *= maxwidth / dimensions.y;
				dimensions.y = maxwidth ;
			}
		}

		if (!CrosshairImage && crosshairstring)
		{
			Class<Inventory> item = crosshairstring;

			if (item) // If it's a valid inventory item, use the inventory actor class's info
			{ 
				let def = GetDefaultByType(item);

				if (def)
				{
					size *= 1.75 / min(1.0, vid_scalefactor);

					TextureID icon = def.Icon; // First, try to use the Inventory item's icon as the crosshair

					if (icon)
					{
						dimensions = TexMan.GetScaledSize(icon);

						if (dimensions.x >= 32 || dimensions.y >= 32) // But only if it's big enough
						{
							CrosshairImage = icon;
						} 
					}

					if (!CrosshairImage) // If it wasn't big enough, use the spawn state sprite
					{
						CrosshairImage = def.SpawnState.GetSpriteTexture(0);
						dimensions = TexMan.GetScaledSize(CrosshairImage);
					}

					if (CPlayer.mo.FindInventory(crosshairstring))
					{
						clr = 0x00FF00; // Make the icon green if the item is in inventory
					}
					else
					{
						clr = 0xFF8800; // Otherwise make it orange and pulse the size of icon if you don't have it
						size *= (crosshair < 80 || (crosshair > 90 && crosshair < 98)) ? 1.0 + 0.1 * sin(level.time * 15 % 360) : 1.0;
					}

					// Force everything to maxwidth pixels at widest dimension
					if (dimensions.x > dimensions.y)
					{
						dimensions.y *= maxwidth / dimensions.x;
						dimensions.x = maxwidth;
					}
					else
					{
						dimensions.x *= maxwidth / dimensions.y;
						dimensions.y = maxwidth;
					}
				}
			}
			else // Fall back to trying to use the string value as an image name
			{
				TextureID icon = TexMan.CheckForTexture(crosshairstring, TexMan.Type_Any);

				if (icon)
				{
					dimensions = TexMan.GetScaledSize(icon);

					CrosshairImage = icon;
					clr = 0x00FF00; // Make the icon green as if the item is in inventory

					// Force everything to maxwidth pixels at widest dimension
					if (dimensions.x > dimensions.y)
					{
						dimensions.y *= maxwidth / dimensions.x;
						dimensions.x = maxwidth;
					}
					else
					{
						dimensions.x *= maxwidth / dimensions.y;
						dimensions.y = maxwidth;
					}
				}
			}
		}

		if (CrosshairImage)
		{
			// Handle the scaling size multiplier here
			dimensions *= size;

			// Draw centered on screen, with offsets forced to center of the icon
			if (clr > 0) { screen.DrawTexture (CrosshairImage, false, screen.GetWidth() / 2, screen.GetHeight() / 2, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_AlphaChannel, true, DTA_FillColor, clr & 0xFFFFFF, DTA_CenterOffset, true); }
			else { screen.DrawTexture (CrosshairImage, false, screen.GetWidth() / 2, screen.GetHeight() / 2, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_CenterOffset, true); }
		}

		if (crosshairtarget && crosshairtarget != CPlayer.mo && CPlayer.ReadyWeapon && CPlayer.ReadyWeapon != Weapon(CPlayer.mo.FindInventory("NullWeapon")))
		{
			TextureID CrosshairOverlay;
			int pulsespeed = 5;
			double crosshairalpha = 1.0;

			if (crosshairtarget.bShootable && crosshairtarget.health > 0)
			{
				if (crosshairtarget.bFriendly && (crosshairtarget.Species == "Ally" || crosshairtarget is "PlayerFollower"))
				{ // In case the player is looking at a friendly
					size *= 1.25 - clamp(CPlayer.fov / 90.0 * CPlayer.mo.Distance3D(crosshairtarget) / 2048.0, 0.0, 0.75);
					CrosshairOverlay = TexMan.CheckForTexture("SHOT", TexMan.Type_Any);
					dimensions = TexMan.GetScaledSize(CrosshairOverlay) * size;
					screen.DrawTexture(CrosshairOverlay, false, screen.GetWidth() / 2, screen.GetHeight() / 2, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_CenterOffset, true, DTA_Alpha, crosshairalpha * 0.5);
					CrosshairOverlay = TexMan.CheckForTexture("NOSHOT", TexMan.Type_Any);
					pulsespeed = 20;
				}
				else if (CPlayer.ReadyWeapon is "KnifeSilent" && Nazi(crosshairtarget) && !Nazi(crosshairtarget).user_incombat && !(crosshairtarget is "WGuard_Wounded") && CPlayer.mo.Distance2D(crosshairtarget) < crosshairtarget.radius + 64.0)
				{
					if (crosshairtarget == currenttarget)
					{
						targettime++;

						CrosshairOverlay = TexMan.CheckForTexture("KNFEA0", TexMan.Type_Any);
						clr = 0xDD7700;
						pulsespeed = 0;
						crosshairalpha = clamp(targettime * 0.1, 0.0, 1.0);
					}
					else
					{
						currenttarget = crosshairtarget;
						targettime = 0;
					}
				}
				else if (Base(crosshairtarget) && Base(crosshairtarget).user_targetcrosshair)
				{
					size *= 1.25 - clamp(CPlayer.fov / 90.0 * CPlayer.mo.Distance3D(crosshairtarget) / 2048.0, 0.0, 0.75);

					CrosshairOverlay = TexMan.CheckForTexture("SHOT", TexMan.Type_Any);
					clr = 0xFFFF00;
				}
				else if (crosshairtarget.bFriendly && (!Nazi(crosshairtarget) || !Nazi(crosshairtarget).user_sneakable))
				{
					size *= 1.25 - clamp(CPlayer.fov / 90.0 * CPlayer.mo.Distance3D(crosshairtarget) / 2048.0, 0.0, 0.75);

					if (crosshairtarget == currenttarget)
					{
						targettime++;

						if (targettime > 45)
						{
							crosshairalpha = clamp((targettime - 45) * 0.006, 0.0, 1.0);

							CrosshairOverlay = TexMan.CheckForTexture("SHOT", TexMan.Type_Any);
							dimensions = TexMan.GetScaledSize(CrosshairOverlay) * size;
							screen.DrawTexture(CrosshairOverlay, false, screen.GetWidth() / 2, screen.GetHeight() / 2, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_CenterOffset, true, DTA_Alpha, crosshairalpha * 0.5);

							CrosshairOverlay = TexMan.CheckForTexture("NOSHOT", TexMan.Type_Any);
							pulsespeed = 20;
						}
					}
					else
					{
						currenttarget = crosshairtarget;
						targettime = 0;
					}
				}
			}

			if (CrosshairOverlay.IsValid())
			{
				// Handle the scaling size multiplier here
				dimensions = TexMan.GetScaledSize(CrosshairOverlay) * size * (1.0 + 0.125 * sin(level.time * pulsespeed)); // Pulse the size of the indicator

				// Draw centered on screen, with offsets forced to center of the icon
				if (clr > 0) { screen.DrawTexture(CrosshairOverlay, false, screen.GetWidth() / 2, screen.GetHeight() / 2, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_AlphaChannel, true, DTA_FillColor, clr & 0xFFFFFF, DTA_CenterOffset, true, DTA_Alpha, crosshairalpha * (0.5 + 0.125 * sin(level.time * pulsespeed))); }
				else { screen.DrawTexture(CrosshairOverlay, false, screen.GetWidth() / 2, screen.GetHeight() / 2, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_CenterOffset, true, DTA_Alpha, crosshairalpha * (0.5 + 0.125 * sin(level.time * pulsespeed))); }
			}
		}
		else { currenttarget = null; }
	}

	virtual void DrawTankStatusBar()
	{
		let tankplayer = TankPlayer(CPlayer.mo);
		let targetactor = tankplayer.CrosshairActor;

		Let wpn = TankCannonWeapon(CPlayer.mo.FindInventory("TankCannonWeapon", true));
		color shellclr;
		double dotscale = 1.25;

		if (wpn && CPlayer.ReadyWeapon && CPlayer.ReadyWeapon == Weapon(wpn))
		{
			if (wpn.cannontimeout > 0)
			{
				shellclr = 0xFF9900;
				dotscale = 1.5 + 0.5 * sin(level.time * 25);
			}
			else
			{
				shellclr = 0x009900;
			}
		}

		DrawThirdPersonCrosshair(tankplayer.CrosshairPos, tankplayer.CrosshairDist, targetactor, scale:dotscale, clr:shellclr);

		if (CPlayer.cheats & CF_CHASECAM)
		{
			TextureID image = TexMan.CheckForTexture("TANKVIEW", TexMan.Type_MiscPatch);
			screen.DrawTexture(image, false, 0, 0, DTA_FullscreenEx, 1, DTA_KeepRatio, true);
		}
	}

	void DrawThirdPersonCrosshair(Vector3 hitlocation, double hitdist = 128, Actor targetactor = null, String crosshair1 = "XHAIRB2", String crosshair2 = "XHAIRB7", double scale = 1.0, color clr = 0x222222)
	{
		gl_proj.CacheResolution();
		gl_proj.CacheFov(CPlayer.fov);
		gl_proj.Reorient(CPlayer.camera.pos,(
						CPlayer.camera.angle,
						CPlayer.camera.pitch,
						CPlayer.camera.roll));
		gl_proj.BeginProjection();

		Vector2 dimensions;

		Vector3 worldpos = CPlayer.camera.pos + level.Vec3Diff(CPlayer.camera.pos, hitlocation); // World position of object, offset from viewpoint
		gl_proj.ProjectWorldPos(worldpos); // Translate that to the screen, using the viewpoint's info

		if (gl_proj.IsInScreen()) // If the coordinates are off the screen somehow, then skip drawing
		{
			viewport.FromHud();
			Vector2 drawpos = viewport.SceneToWindow(gl_proj.ProjectToNormal());

			TextureID image = TexMan.CheckForTexture(crosshair1, TexMan.Type_MiscPatch);

			dimensions = TexMan.GetScaledSize(image);
			double scaleamt = clamp(hitdist / 680 * CPlayer.fov / 90, 0.5, 1.5); // Scale with fov to account for zooming
	
			dimensions /= scaleamt;

			color cclr = 0xDDDDDD; // Light grey by default

			if (targetactor && targetactor.bShootable && targetactor != CPlayer.mo && (!targetactor.master || targetactor.master != CPlayer.mo))
			{
				if (targetactor.bIsMonster && CPlayer.mo.isFriend(targetactor)) { cclr = 0x00CD00; } // Green for allies
				else if (targetactor.bIsMonster)
				{
					cclr = 0xCD0000; // Red for enemies
					dimensions *= 1 + (sin(level.time * 25) + 1.0) / 2;
				} 
				else if (!targetactor.bNoDamage && !targetactor.bInvulnerable)
				{
					cclr = 0xCDCD00; // Yellow for other shootables
					dimensions *= 1 + 0.5 * (sin(level.time * 25) + 1.0) / 2;
				} 
			}

			screen.DrawTexture(image, false, drawpos.x, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_AlphaChannel, true, DTA_FillColor, cclr & 0xFFFFFF);

			// Small cross in the center is dark for visibility
			TextureID image2 = TexMan.CheckForTexture(crosshair2, TexMan.Type_MiscPatch); 
			dimensions = TexMan.GetScaledSize(image2);
			dimensions /= scaleamt;
			dimensions *= scale;

			screen.DrawTexture(image2, false, drawpos.x, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_AlphaChannel, true, DTA_FillColor, clr & 0xFFFFFF);
		}
	}

	virtual void DrawKeenStatusBar() // The bulk of this is handled via widgets
	{
		if (CPlayer.mo.CurState == CPlayer.mo.FindState("Pain"))
		{
			paintimer = 20;
		}

		if (paintimer > 0)
		{
			paintimer--;

			double width = Screen.GetWidth();
			double height = Screen.GetHeight();

			TextureID pain = TexMan.CheckForTexture("graphics/hud/keen/pain.png", TexMan.Type_ANY);
			screen.DrawTexture(pain, false, 0, 0, DTA_VirtualWidthF, width, DTA_VirtualHeightF, height, DTA_DestWidthF, width, DTA_DestHeightF, height, DTA_Alpha, 0.35, DTA_FlipX, Random(0, 1), DTA_FlipY, Random(0, 1));
		}

		let keen = KeenPlayer(CPlayer.mo);
		if (keen && CPlayer.cheats & CF_CHASECAM) { DrawThirdPersonCrosshair(keen.CrosshairPos, keen.CrosshairDist, null, "XHAIRB1", "XHAIRB5"); }

		CPlayer.mo.InvSel = CPlayer.mo.FindInventory("CKPogoStick");
	}

	override void DrawMyPos() {} // Drawn via widget

	override void DrawAutomapHUD(double ticFrac)
	{
		// Vignette the edges...  The rest is handled in the widget code
		let tex = TexMan.CheckForTexture ("CONVBACK", TexMan.Type_MiscPatch);
		if (tex.isValid())
		{
			Vector2 size = TexMan.GetScaledSize(tex);
			screen.DrawTexture(tex, false, 0, 0, DTA_DestWidth, screen.GetWidth(), DTA_DestHeight, Screen.GetHeight(), DTA_Alpha, 0.75);
		}
	}

	// From v_draw.cpp
	static int GetUIScale(int altval = 0)
	{
		int scaleval;

		if (altval > 0) { scaleval = altval; }
		else if (uiscale == 0)
		{
			// Default should try to scale to 640x400
			int vscale = screen.GetHeight() / 400;
			int hscale = screen.GetWidth() / 640;
			scaleval = clamp(vscale, 1, hscale);
		}
		else { scaleval = uiscale; }

		// block scales that result in something larger than the current screen.
		int vmax = screen.GetHeight() / 200;
		int hmax = screen.GetWidth() / 320;
		int max = MAX(vmax, hmax);
		return MAX(1,MIN(scaleval, max));
	}

	virtual void CalcOffsets()
	{
		CVar hudratio = CVar.FindCVar("boa_hudratio");

		int boa_hudratio = hudratio.GetInt();
		double ratio;
		
		switch (boa_hudratio)
		{
			// These match the built-in ratios currently defined in the ForceRatios option value
			case 1:
				ratio = 16.0 / 9;
				break;
			case 2:
				ratio = 16.0 / 10;
				break;
			case 3:
				ratio = 4.0 / 3;
				break;
			case 4:
				ratio = 5.0 / 4;
				break;
			case 5:
				ratio = 17.0 / 10;
				break;
			case 6:
				ratio = 21.0 / 9;
				break;
			default:
				widthoffset = 0;
				return;
		}

		// If the ratio selected is wider than the current screen, don't do any offsetting
		if (ratio >= Screen.GetAspectRatio())
		{
			widthoffset = 0;
			return;
		}

		// Account for hud scaling, both automatic and manual
		Vector2 scale = Statusbar.getHUDScale();
		double h = Screen.GetHeight() / scale.y;
		double w = h * ratio;

		widthoffset = int((Screen.GetWidth() / scale.x - w) / 2);
	}

	override void DrawPowerUps() {} // Drawn via screen widget

	// Modified version of the internal function
	void DrawInventoryIcon(Inventory item, Vector2 pos, int flags = 0, double alpha = 1.0, Vector2 boxsize = (-1, -1), Vector2 scale = (1.,1.), int style = STYLE_Translucent, Color clr = 0xFFFFFFFF)
	{
		TextureID texture;
		Vector2 applyscale;
		[texture, applyscale] = GetIcon(item, flags, false);
		
		if (texture.IsValid())
		{
			if ((flags & DI_DIMDEPLETED) && item.Amount <= 0) flags |= DI_DIM;
			applyscale.X *= scale.X;
			applyscale.Y *= scale.Y;

			if (clr.a == 0) { clr += 0xFF000000; } // Make sure the color's alpha value is set

			DrawTexture(texture, pos, flags, alpha, boxsize, applyscale, style, clr);
		}
	}

	// Modified from statusbar.zs that allows checking alternate inventory-based "ammo" for NaziWeapon class
	Inventory, Inventory, int, int GetWeaponAmmo()
	{
		Inventory ammo1, ammo2;

		if (CPlayer.ReadyWeapon)
		{
			ammo1 = Inventory(CPlayer.ReadyWeapon.Ammo1);
			ammo2 = Inventory(CPlayer.ReadyWeapon.Ammo2);

			if (!ammo1)
			{
				if (CPlayer.ReadyWeapon is "NaziWeapon" && NaziWeapon(CPlayer.ReadyWeapon).ammoitem)
				{
					ammo1 = CPlayer.mo.FindInventory(NaziWeapon(CPlayer.ReadyWeapon).ammoitem);
				}

				if (!ammo1)
				{
					ammo1 = ammo2;
					ammo2 = null;
				}
			}
		}
		else
		{
			ammo1 = ammo2 = null;
		}

		let ammocount1 = !!ammo1 ? ammo1.Amount : 0;
		let ammocount2 = !!ammo2 ? ammo2.Amount : 0;

		return ammo1, ammo2, ammocount1, ammocount2;
	}

	override void FlushNotify()
	{
		Log.Clear("Notifications");
	}

	override bool DrawChat(String txt)
	{
		Font fnt = SmallFont;
		if (CPlayer.mo is "KeenPlayer") { fnt = ClassicFont; }

		return Log.DrawPrompt(txt .. " ", "Chat", fnt);
	}

	override void ScreenSizeChanged()
	{
		CalcOffsets();

		Super.ScreenSizeChanged();
	}

	override bool ProcessMidPrint(Font fnt, String msg, bool bold)
	{
		// Classic-style popup for Keen
		if (CPlayer.mo is "KeenPlayer")
		{
			ClassicMessageBox.PrintMessage("\c[TrueBlack]" .. ZScriptTools.StripColorCodes(msg), 2, "", 0, 70, 13, 6);

			return true;
		}

		// Normal message for regular BoA play...
		return false;
	}
}