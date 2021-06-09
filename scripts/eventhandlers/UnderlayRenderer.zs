/*
 * Copyright (c) 2018-2020 Talon1024, AFADoomer
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

// Used for rendering space suit and gas mask HUD graphics below the HUD
class UnderlayRenderer : EventHandler
{
	Array<overlay> overlays;

	override void RenderUnderlay(RenderEvent e)
	{
		for (int a = 0; a < overlays.Size(); a++)
		{
			let o = overlays[a];

			if (o)
			{
				if (o.player == players[consoleplayer] && !(o.flags & Overlay.OnHUD)) { DrawOverlay(o); }
			}
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		for (int a = 0; a < overlays.Size(); a++)
		{
			let o = overlays[a];

			if (o)
			{
				if (o.player == players[consoleplayer] && (o.flags & Overlay.OnHUD)) { DrawOverlay(o); }
			}
		}
	}

	override void WorldTick()
	{
		for (int a = 0; a < overlays.Size(); a++)
		{
			let o = overlays[a];

			if (o)
			{
				// If it's done fading in and out, delete it.
				if (o.holdtime != -1 && level.time > o.holdtime + o.outtime) { overlays.Delete(a); }
			}
		}
	}

	ui void DrawOverlay(overlay o)
	{
		if (automapactive)
		{
			if (!(o.flags & Overlay.OnMap)) { return; }
		}
		else if (o.flags & Overlay.NotOn3DView) { return; }

		if (players[consoleplayer].cheats & CF_CHASECAM && !(o.flags & Overlay.OnChaseCam)) { return; }

		int timer = level.time;
		Actor mo = o.player.mo;

		double drawalpha, blackalpha;

		if (o.intime && timer - o.start < o.intime) // Fade in
		{
			drawalpha = double(timer - o.start) / o.intime;
		}
		else if (timer < o.holdtime || o.holdtime == -1)  // Draw at full alpha while holding
		{
			drawalpha = 1.0;
		}
		else if (o.outtime) // Fade out
		{
			drawalpha = 1.0 - double(timer - o.holdtime) / o.outtime;
		}

		if (o.flags & Overlay.LightEffects)
		{
			int lightlevel = mo.CurSector.lightlevel;

			// Pull brightness of dynamic lights around the player from the stealth/visibility code
			let vis = mo.FindInventory("BoAVisibility");
			if (vis) { lightlevel += int(BoAVisibility(vis).extravisibility); }

			blackalpha = 1.0 - (lightlevel / 255.0);
		}

		 // Use the passed in alpha value to scale the alpha values
		drawalpha *= o.alpha;
		blackalpha *= drawalpha;

		TextureID image = TexMan.CheckForTexture(o.image, TexMan.Type_Any);

		if (o.flags & Overlay.Fit) // scale to fit the screen at the narrowest dimension, maintaining aspect ratio
		{
			screen.DrawTexture(image, true, o.offsets.x, o.offsets.y, DTA_FullScreenEx, FSMode_ScaleToFill, DTA_Alpha, drawalpha, DTA_Rotate, o.angle);

			// Darken the mask graphic in dark sectors by drawing it again as a black silhouette.
			if (blackalpha && o.flags & Overlay.LightEffects) { screen.DrawTexture(image, true, o.offsets.x, o.offsets.y, DTA_FullScreenEx, FSMode_ScaleToFill, DTA_Alpha, blackalpha, DTA_Rotate, o.angle, DTA_FillColor, 0); }
		}
		if (o.flags & Overlay.Force320x200) // This is basically the old gas mask and space suit drawing code by Talon1024
		{
			int vWidth = int(200 * Screen.GetAspectRatio());
			int vXOffset = 320 - vWidth / 2;

			// gfg this took me FOREVER to figure out.
			// But basically, the "position" is the offset from the offset
			// position, and the offset position acts as the pivot point 
			// for rotations and such... At least, in my experience.
			double xpos = o.offsets.x + 320 - vXOffset;
			double ypos = o.offsets.y + 100;

			screen.DrawTexture(image, true, xpos, ypos,
				DTA_CenterOffset, true,
				DTA_VirtualHeight, 200,
				DTA_VirtualWidth, vWidth,
				DTA_KeepRatio, true, 
				DTA_Alpha, drawalpha, 
				DTA_Rotate, o.angle);

			// Darken the mask graphic in dark sectors by drawing it again as a black silhouette.
			if (blackalpha && o.flags & Overlay.LightEffects)
			{
				screen.DrawTexture(image, true, xpos, ypos, 
					DTA_CenterOffset, true,
					DTA_VirtualHeight, 200,
					DTA_VirtualWidth, vWidth,
					DTA_KeepRatio, true, 
					DTA_Alpha, blackalpha, 
					DTA_Rotate, o.angle,
					DTA_FillColor, 0);
			}
		}
		else // Stretch to fill the screen, disregarding aspect ratio
		{
			int height = int(Screen.GetHeight());
			int width = int(Screen.GetWidth());

			screen.DrawTexture(image, true, o.offsets.x, o.offsets.y, DTA_DestWidth, width, DTA_DestHeight, height, DTA_Alpha, drawalpha, DTA_Rotate, o.angle);
			
			// Darken the mask graphic in dark sectors by drawing it again as a black silhouette.
			if (blackalpha && o.flags & Overlay.LightEffects) { screen.DrawTexture(image, true, o.offsets.x, o.offsets.y, DTA_DestWidth, width, DTA_DestHeight, height, DTA_Alpha, blackalpha, DTA_Rotate, o.angle, DTA_FillColor, 0); }
		}
	}

	overlay AddOverlay(PlayerInfo player, String image, int holdtime, int intime, int outtime, double alpha = 1.0, uint index = 0, int flags = Overlay.Default, double angle = 0, Vector2 offsets = (0, 0))
	{
		bool newoverlay = false;
		overlay o = FindOverlay(player, image, index);

		if (!o)
		{
			o = New("overlay");

			if (o)
			{
				overlays.Insert(index, o);
				o.start = level.time;
				o.index = index;
				o.player = player;
				o.image = image;
			}
		}

		if (o)
		{
			if (holdtime + intime + outtime == 0 || holdtime < 0) { holdtime = -1; }
			else { holdtime = level.time + holdtime + intime; } // Base off of level.time so that stackable effects will extend it properly

			if (o.flags != flags) { o.start = level.time; }

			o.intime = intime;
			o.holdtime = holdtime; 
			o.outtime = outtime;
			o.flags = flags;
			o.alpha = alpha;
			o.angle = angle;
			o.offsets = offsets;

			return o;
		}

		return null;
	}

	overlay FindOverlay(PlayerInfo p, String image, int index = 0)
	{
		for (int o = 0; o < overlays.Size(); o++)
		{
			let this = overlays[o];
			if (this && this.player == p && this.image ~== image && this.index == index) { return this; }
		}

		return null;
	}
}

class Overlay : Thinker
{
	enum DrawFlags
	{
		Default = 0,		// Stretch to fit screen (see heartbeat effect)
		Fit = 1,			// Keep aspect ratio and fit at narrowest dimension to ensure screen coverage; may crop sides or top/bottom (see ice effect)
		OnHUD = 2,			// Draw on top of HUD elements
		OnMap = 4,			// Draw on top of the automap
		LightEffects = 8,	// Uses sector light and player visibility info to darken the overlay in darker sectors (see spacesuit and gasmask)
		Force320x200 = 16,	// Keep aspect ratio, but otherwise force to 320x200 screen size (see spacesuit and gasmask)
		OnChaseCam = 32,	// Draw in chasecam view
		NotOn3DView = 64	// Don't draw on normal game view (when automap is inactive)
	}

	PlayerInfo player;
	String image;
	int intime, holdtime, outtime, start, flags, index;
	double alpha, angle;
	Vector2 offsets;

	static overlay Init(PlayerInfo player, String image, int holdtime, int intime, int outtime, double alpha = 1.0, uint index = 0, int flags = Overlay.Default, double angle = 0, Vector2 offsets = (0, 0))
	{
		if (!player) { return null; }

		let handler = UnderlayRenderer(EventHandler.Find("UnderlayRenderer"));
		if (!handler) { return null; }

		return handler.AddOverlay(player, image, holdtime, intime, outtime, alpha, index, flags, angle, offsets);
	}

	// Wrapper for setting an overlay from ACS
	// Used in C3M5_A subway crash sequence script and cutscenes
	//  ScriptCall("Overlay", "ACSInit", "M_INJ", 0, 0, 175, 2.0);
	static overlay ACSInit(Actor mo, String image, int holdtime, int intime, int outtime, double alpha = 1.0, int index = 0, int flags = Overlay.Default, double angle = 0, Vector2 offsets = (0, 0))
	{
		PlayerInfo p;
		if (mo && mo.player) { p = mo.player; } // Use the activating player
		else { p = players[consoleplayer]; } // If none was passed, apply to current viewing player

		let handler = UnderlayRenderer(EventHandler.Find("UnderlayRenderer"));
		if (!handler) { return null; }

		return handler.AddOverlay(p, image, holdtime, intime, outtime, alpha, index, flags, angle, offsets);

	}
}

class LoadScreen : StaticEventHandler
{
	TextureID LoadingGraphic, AltGraphic, BackgroundGraphic, FadeGraphic;
	transient Font fnt;
	int loading, unloading;
	Vector2 size, bgsize, fadesize;
	String loadstring;
	int loaded;

	override void OnRegister()
	{
		LoadingGraphic = TexMan.CheckForTexture("graphics/general/Loading.png", TexMan.Type_Any);
		AltGraphic = TexMan.CheckForTexture("graphics/general/M_DOOM.png", TexMan.Type_Any);
		BackgroundGraphic = TexMan.CheckForTexture("graphics/general/Loading0.png", TexMan.Type_Any);
		FadeGraphic = TexMan.CheckForTexture("graphics/hud/general/MOVIEHUD.png", TexMan.Type_Any);

		[size.x, size.y] = TexMan.GetSize(LoadingGraphic);
		[bgsize.x, bgsize.y] = TexMan.GetSize(BackgroundGraphic);
		[fadesize.x, fadesize.y] = TexMan.GetSize(FadeGraphic);

		fnt = BigFont;
	}

	override void WorldLoaded(WorldEvent e)
	{
		unloading = 0;
		loading = 120;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		loaded = 0;
		unloading = 1;
	}

	override void WorldTick()
	{
		if (level.time < 5) { return; }

		if (loading > 0) { loading--; }
		if (unloading > 0) { unloading++; }
	}

	override void RenderOverlay(RenderEvent e)
	{
		// No overlays for cartridge levels
		if (level.levelnum >= 151 && level.levelnum <= 153) { return; }
		if (level.time < 5) { return; }

		double scale = Screen.GetHeight() / 720;

		int x = int(Screen.GetWidth() - 176 * scale / 2);
		int y = int(Screen.GetHeight() - 128 * scale / 2);

		if (unloading)
		{
			double alpha = min(0.6, double(unloading) / 2);

			if (!players[consoleplayer].mo.FindInventory("CutsceneEnabled")) // Only draw letterbox if there's no cutscene.
			{
				screen.DrawTexture(FadeGraphic, false, 0, 0, DTA_FullScreenEx, 2, DTA_Alpha, alpha / 0.6);
			}

			screen.DrawTexture(BackgroundGraphic, true, x, y, DTA_Alpha, alpha / 0.6, DTA_CenterOffset, true, DTA_DestWidth, int(bgsize.x * scale), DTA_DestHeight, int(bgsize.y * scale));
			screen.DrawTexture(LoadingGraphic, false, x, y, DTA_Alpha, alpha, DTA_CenterOffset, true, DTA_DestWidth, int(size.x * scale), DTA_DestHeight, int(size.y * scale));
		}
		else if (loading && gamestate != GS_TITLELEVEL && gamestate != GS_FINALE)
		{
			double alpha = min(0.6, double(loading - 30) / 20);
			double titlealpha = clamp(double(-15 + loading) / 20, 0.0, 0.65);
			double fadealpha = clamp(double(-35 + loading - 60) / 20, 0.0, 1.0);

			if (!players[consoleplayer].mo.FindInventory("CutsceneEnabled")) // Only draw letterbox and show map title if there's no cutscene.
			{
				screen.DrawTexture(FadeGraphic, false, 0, 0, DTA_FullScreenEx, 2, DTA_Alpha, alpha / 0.6);

				// Adjust position for screen widgets and forced hud ratio
				int offset = 16;
				Widget topleft = Widget.FindBase(Widget.WDG_TOP | Widget.WDG_LEFT, 0);
				if (topleft) { offset = 8 + int(topleft.pos.x + topleft.size.x + topleft.margin[1]); }
				else if (BoAStatusbar(StatusBar)) { offset += BoAStatusbar(StatusBar).widthoffset; }

				DrawToHud.DrawText(level.levelname, (offset, 20 - fnt.GetHeight() / 2), fnt, titlealpha, 1.5, shade:Font.CR_GRAY, flags:ZScriptTools.STR_TOP | ZScriptTools.STR_LEFT);
			}

			screen.DrawTexture(BackgroundGraphic, true, x, y, DTA_Alpha, alpha / 0.6, DTA_CenterOffset, true, DTA_DestWidth, int(bgsize.x * scale), DTA_DestHeight, int(bgsize.y * scale));
			screen.DrawTexture(AltGraphic, false, x, y, DTA_Alpha, fadealpha * alpha, DTA_CenterOffset, true, DTA_DestWidth, int(size.x * scale), DTA_DestHeight, int(size.y * scale));
			screen.DrawTexture(LoadingGraphic, false, x, y, DTA_Alpha, alpha, DTA_CenterOffset, true, DTA_DestWidth, int(size.x * scale), DTA_DestHeight, int(size.y * scale));
		}

		// Catch edge cases where the status bar isn't on top...
		if (BoAStatusBar(StatusBar) && BoAStatusBar(StatusBar).savetimer)
		{
			BoAStatusBar(StatusBar).DrawSaveIcon();
		}
	}
}