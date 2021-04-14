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
	TextureID SpaceSuitGraphic;
	TextureID GasMaskGraphic;
	Vector2 SpaceSuitSize;

	override void OnRegister()
	{
		SpaceSuitGraphic = TexMan.CheckForTexture("STGMASK", TexMan.Type_Any);
		SpaceSuitSize = TexMan.GetScaledSize(SpaceSuitGraphic);
		GasMaskGraphic = TexMan.CheckForTexture("STGZASK", TexMan.Type_Any);
	}

	override void RenderUnderlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		if ((p.cheats & CF_CHASECAM) == 0)
		{
			int vWidth = int(200 * Screen.GetAspectRatio());
			int vXOffset = 320 - vWidth / 2;
			Inventory SpaceSuit = p.mo.FindInventory("PowerSpaceSuit");
			int lightlevel = p.mo.CurSector.lightlevel;
			//double maskAlpha = lightlevel <= 64 ? lightlevel / 64.0 : 1.0; // Experiment
			double maskAlpha = 1.0;

			// Pull brightness of dynamic lights around the player from the stealth/visibility code
			let vis = p.mo.FindInventory("BoAVisibility");
			if (vis) { lightlevel += int(BoAVisibility(vis).extravisibility); }

			//double blackAlpha = lightlevel > 64 ? 1.0 - (lightlevel - 64.0) / 192.0 : 1.0; // Experiment
			double blackAlpha = 1.0 - (lightlevel / 255.0);
			if (SpaceSuit)
			{
				// gfg this took me FOREVER to figure out.
				// But basically, the "position" is the offset from the offset
				// position, and the offset position acts as the pivot point 
				// for rotations and such... At least, in my experience.
				double xpos = 320 - vXOffset;
				double ypos = 100;
				double ang = (sin(level.time * 10) * p.mo.vel.xy.length()) / 10;

				// Draw rotated texture
				Screen.DrawTexture(SpaceSuitGraphic, false, xpos, ypos,
					DTA_Rotate, -ang,
					DTA_CenterOffset, true,
					DTA_VirtualHeight, 200,
					DTA_VirtualWidth, vWidth,
					DTA_KeepRatio, true,
					DTA_Alpha, maskAlpha);

				// Darken the mask graphic in dark sectors by drawing it again
				// as a black silhouette.
				Screen.DrawTexture(SpaceSuitGraphic, false, xpos, ypos,
					DTA_Rotate, -ang,
					DTA_CenterOffset, true,
					DTA_VirtualHeight, 200,
					DTA_VirtualWidth, vWidth,
					DTA_KeepRatio, true,
					DTA_FillColor, 0,
					DTA_Alpha, blackAlpha);
			}
			Inventory ZyklonGasMask = p.mo.FindInventory("PowerZyklonMask");
			if (ZyklonGasMask)
			{
				Screen.DrawTexture(GasMaskGraphic, false, 0.0, 0.0,
					DTA_TopOffset, 80,
					DTA_LeftOffset, vXOffset,
					DTA_VirtualHeight, 200,
					DTA_VirtualWidth, vWidth,
					DTA_KeepRatio, true,
					DTA_Alpha, maskAlpha);
				// Darken in dark sectors
				Screen.DrawTexture(GasMaskGraphic, false, 0.0, 0.0,
					DTA_TopOffset, 80,
					DTA_LeftOffset, vXOffset,
					DTA_VirtualHeight, 200,
					DTA_VirtualWidth, vWidth,
					DTA_KeepRatio, true,
					DTA_FillColor, 0,
					DTA_Alpha, blackAlpha);
			}
		}
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
		if (loading > 0) { loading--; }
		if (unloading > 0) { unloading++; }
	}

	override void RenderOverlay(RenderEvent e)
	{
		// No overlays for cartridge levels
		if (level.levelnum >= 151 && level.levelnum <= 153) { return; }

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
				screen.DrawText(fnt, Font.CR_GRAY, 65, 20 - fnt.GetHeight() / 2, level.levelname, DTA_Alpha, titlealpha, DTA_VirtualWidth, int(480 * Screen.GetAspectRatio()), DTA_VirtualHeight, 480, DTA_KeepRatio, true);
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