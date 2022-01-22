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

class ScreenLabelItem
{
	Actor mo;
	String icon;
	String text;
	double alpha;
	color clr;
	int type;
	bool draw[MAXPLAYERS];
}

class ScreenLabelHandler : EventHandler
{
	enum Types
	{
		LBL_Default,
		LBL_ColorMarker,
		LBL_Discreet,
	};

	Array<ScreenLabelItem> ScreenLabelItems;

	protected Le_GlScreen			gl_proj;
	protected Le_Viewport			viewport;

	override void OnRegister ()
	{
		gl_proj = new("Le_GlScreen");
	}

	override void WorldThingDestroyed(WorldEvent e)
	{
		int i = FindItem(e.Thing);

		if (i < ScreenLabelItems.Size())
		{
			ScreenLabelItems.Delete(i, 1);
			ScreenLabelItems.ShrinkToFit();
		}
	}

	uint FindItem(Actor mo) // Helper function to find a thing in a child class since the mo is nested in an object
	{
		for (int i = 0; i < ScreenLabelItems.Size(); i++)
		{
			if (ScreenLabelItems[i] && ScreenLabelItems[i].mo == mo) { return i; }
		}
		return ScreenLabelItems.Size();
	}

	void AddItem(Actor thing, String iconName = "", String text = "", color clr = 0xFFFFFF, double alpha = 1.0, int type = LBL_Default)
	{
		if (!thing) { return; }

		int i = FindItem(thing);

		ScreenLabelItem item;
		if (i == ScreenLabelItems.Size())
		{
			item = New("ScreenLabelItem");
			item.mo = thing;
			ScreenLabelItems.Push(item);
		}
		else { item = ScreenLabelItems[i]; }

		if (item)
		{
			item.icon = iconName;
			item.text = text;
			item.alpha = alpha;
			item.clr = clr;
			item.type = type;
		}
	}

	// Static call for adding via ACS by actor TID
	static void Add(int actorTID = 0, String text = "", String iconName = "", color clr = 0xFFFFFF, double alpha = 0.8, int type = LBL_Default)
	{
		ScreenLabelHandler handler = ScreenLabelHandler(EventHandler.Find("ScreenLabelHandler"));
		if (!handler) { return; } // If no handler was found (somehow), silently fail

		if (actorTID)
		{
			let it = level.CreateActorIterator(actorTID, "Actor");
			Actor mo;

			while (mo = Actor(it.Next()))
			{
				handler.AddItem(mo, iconName, text, clr, alpha, type);
			}
		} 
	}

	static void Remove(Actor thing)
	{
		if (!thing) { return; } // If no thing was passed, silently fail

		ScreenLabelHandler handler = ScreenLabelHandler(EventHandler.Find("ScreenLabelHandler"));
		if (!handler) { return; }

		int i = handler.FindItem(thing);

		if (i < handler.ScreenLabelItems.Size())
		{
			handler.ScreenLabelItems[i].Destroy();
			handler.ScreenLabelItems.Delete(i, 1);
			handler.ScreenLabelItems.ShrinkToFit();
		}
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (e.thing is "PlayerPawn") { AddItem(e.thing, "MP_MARK", "", 0x0, 0.8, LBL_ColorMarker); }
	}

	override void WorldTick()
	{
		for (int i = 0; i < ScreenLabelItems.Size(); i++)
		{
			for (int p = 0; p < MAXPLAYERS; p++)
			{
				if (!playeringame[p]) { continue; }

				if (ScreenLabelItems[i].mo && ScreenLabelItems[i].mo.radius == 0 && ScreenLabelItems[i].mo.height == 0)
				{
					ScreenLabelItems[i].draw[p] = true;
					continue;
				}

				ScreenLabelItems[i].draw[p] = !!(players[p].mo && ScreenLabelItems[i].mo && players[p].mo.CheckSight(ScreenLabelItems[i].mo, SF_IGNOREVISIBILITY && SF_IGNOREWATERBOUNDARY));
			}
		}
	}

	override void RenderUnderlay( RenderEvent e )
	{
		PlayerInfo p = players[consoleplayer];

		if (!p || !p.mo || automapactive) { return; }

		viewport.FromHud();
		gl_proj.CacheResolution();
		gl_proj.CacheFov(p.fov);
		gl_proj.OrientForRenderOverlay(e);
		gl_proj.BeginProjection();

		for (int i = 0; i < ScreenLabelItems.Size(); i++)
		{
			if (
				!ScreenLabelItems[i] || 
				!ScreenLabelItems[i].mo || 
				ScreenLabelItems[i].mo.bDormant ||
				ScreenLabelItems[i].mo == p.mo ||
				(
					Inventory(ScreenLabelItems[i].mo) && 
					Inventory(ScreenLabelItems[i].mo).owner
				) ||
				!ScreenLabelItems[i].draw[consoleplayer]
			) { continue; }

			Actor mo = ScreenLabelItems[i].mo;

			double dist = Level.Vec3Diff(e.viewpos, mo.pos).Length();
			double alpha = ScreenLabelItems[i].alpha;
			double fovscale = p.fov / 90;

			Vector3 worldpos = e.viewpos + level.Vec3Diff(e.viewpos, mo.pos + (0, 0, mo.height + 16 + mo.GetBobOffset())); // World position of object, offset from viewpoint
			gl_proj.ProjectWorldPos(worldpos); // Translate that to the screen, using the viewpoint's info

			if (!gl_proj.IsInScreen()) { continue; } // If the coordinates are off the screen, then skip drawing this item

			Vector2 drawpos = viewport.SceneToWindow(gl_proj.ProjectToNormal());
			Vector2 startpos = drawpos;

			switch (ScreenLabelItems[i].type)
			{
				case LBL_ColorMarker:
					if (multiplayer)
					{
						double lightlevel, fogfactor;
						[lightlevel, fogfactor] = ZScriptTools.GetLightLevel(mo.CurSector);
						alpha *= (lightlevel - fogfactor) / 255.0;
						alpha = clamp(alpha, 0.0, 1.0);

 						// Hide nametags when crouched
						if (mo.player) { alpha *= (mo.player.crouchfactor - 0.5) / 0.5; }

						if (alpha == 0.0) { continue; }

						double scale = vid_scalefactor * (256 / dist) / fovscale;
						Color clr = mo.player ? mo.player.GetColor() : 0x0;
						drawpos = startpos;

						if (ScreenLabelItems[i].icon)
						{
							TextureID icon = TexMan.CheckForTexture(ScreenLabelItems[i].icon, TexMan.Type_Any);
							TextureID border = TexMan.CheckForTexture("MP_MARK2", TexMan.Type_Any);
							TextureID bkg = TexMan.CheckForTexture("MP_MARK3", TexMan.Type_Any);
							TextureID iconbkg = TexMan.CheckForTexture("MP_MARK4", TexMan.Type_Any);

							if (icon)
							{
								Vector2 icondimensions = TexMan.GetScaledSize(icon);
								double picscale = 112.0 / icondimensions.x;
								icondimensions *= picscale * scale;
								drawpos.y -= icondimensions.y / 2;

								if (bkg) { screen.DrawTexture(bkg, true, drawpos.x, drawpos.y, DTA_DestWidthF, icondimensions.x, DTA_DestHeightF, icondimensions.y, DTA_CenterOffset, true, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, clr); }
								if (border) { screen.DrawTexture(border, true, drawpos.x, drawpos.y, DTA_DestWidthF, icondimensions.x, DTA_DestHeightF, icondimensions.y, DTA_CenterOffset, true, DTA_Alpha, alpha); }
								if (iconbkg) { screen.DrawTexture(iconbkg, true, drawpos.x, drawpos.y, DTA_DestWidthF, icondimensions.x, DTA_DestHeightF, icondimensions.y, DTA_CenterOffset, true, DTA_Alpha, alpha, DTA_AlphaChannel, true, DTA_FillColor, clr); }
								screen.DrawTexture(icon, true, drawpos.x, drawpos.y, DTA_DestWidthF, icondimensions.x, DTA_DestHeightF, icondimensions.y, DTA_CenterOffset, true, DTA_Alpha, alpha);
							}
						}

						if (mo.player)
						{
							dist *= fovscale;
							if (dist > 768) { continue; }
							if (dist > 256) { alpha *= 1.0 - (dist - 256) / 512; }

							String playername = mo.player.GetUserName();
							screen.DrawText(BigFont, Font.FindFontColor("RedandWhite"), drawpos.x - BigFont.StringWidth(playername) * scale / 2, drawpos.y, playername, DTA_ScaleX, scale, DTA_ScaleY, scale, DTA_Alpha, alpha * 1.25);
						}
					}
					break;
				case LBL_Discreet:
					if (true)
					{
						if (dist > 768) { continue; }
						if (dist > 256) { alpha = 1.0 - (dist - 256) / 512; }

						Font tinyfont = Font.FindFont("THREEFIV");

						String text = StringTable.Localize(ScreenLabelItems[i].text);
						String temp; BrokenString lines;
						[temp, lines] = BrokenString.BreakString(text, int(48 * tinyfont.StringWidth(" ")), fnt:tinyfont);

						double textscale = 0.5 / fovscale;
						double lineheight = int(tinyfont.GetHeight() * textscale) + 1;

						textscale /= dist / 512;
						lineheight /= dist / 512;
						
						color clr = ScreenLabelItems[i].clr;
						double bgalpha = alpha * 0.5;

						double textheight = lines.Count() * lineheight;
						double textwidth = 100 * textscale;

						for (int l = 0; l < lines.Count(); l++)
						{
							double w = lines.StringWidth(l) * textscale;
							if (w > textwidth) { textwidth = w; }
						}

						double boxwidth = textwidth;

						drawpos.x -= boxwidth / 2;
						drawpos.y -= textheight;

						// Draw the text
						if (lines.Count())
						{
							drawpos = startpos;
							drawpos.y -= textheight / 2 + lines.Count() * lineheight / 2;

							for (int s = 0; s < lines.Count(); s++)
							{
								String line = lines.StringAt(s);
								screen.DrawText(tinyfont, Font.CR_WHITE, drawpos.x, drawpos.y + s * lineheight, line, DTA_ScaleX, textscale, DTA_ScaleY, textscale, DTA_Alpha, alpha);
							}
						}
					}
					break;
				case LBL_Default:
				default:
					if (dist > 768) { continue; }
					if (dist > 256) { alpha = 1.0 - (dist - 256) / 512; }

					// Get icon image information in order to properly offset text and set frame size
					TextureID image;
					Vector2 imagedimensions = (0, 0);
					if (ScreenLabelItems[i].icon)
					{
						image = TexMan.CheckForTexture(ScreenLabelItems[i].icon, TexMan.Type_Any);
						if (image) { imagedimensions = TexMan.GetScaledSize(image) * vid_scalefactor; }
					}

					Font fnt = SmallFont;

					// Get text content in order to calculate frame size
					String text = StringTable.Localize(ScreenLabelItems[i].text);
					String temp; BrokenString lines;
					[temp, lines] = BrokenString.BreakString(text, int(48 * fnt.StringWidth(" ")), fnt:fnt);

					double textscale = 1 / fovscale;
					double lineheight = int(fnt.GetHeight() * textscale);

					// Draw the frame
					TextureID tl, tm, tr, ml, mm, mr, bl, bm, br;
					tl = TexMan.CheckForTexture("POPUP_TL", TexMan.Type_Any);
					tm = TexMan.CheckForTexture("POPUP_T", TexMan.Type_Any);
					tr = TexMan.CheckForTexture("POPUP_TR", TexMan.Type_Any);
					ml = TexMan.CheckForTexture("POPUP_L", TexMan.Type_Any);
					mm = TexMan.CheckForTexture("POPUP_F", TexMan.Type_Any);
					mr = TexMan.CheckForTexture("POPUP_R", TexMan.Type_Any);
					bl = TexMan.CheckForTexture("POPUP_BL", TexMan.Type_Any);
					bm = TexMan.CheckForTexture("POPUP_B", TexMan.Type_Any);
					br = TexMan.CheckForTexture("POPUP_BR", TexMan.Type_Any);

					Vector2 dimensions = TexMan.GetScaledSize(tl) * vid_scalefactor;
					dimensions /= dist / 512 * fovscale; 
					imagedimensions /= dist / 512 * fovscale;
					textscale /= dist / 512;
					lineheight /= dist / 512;
					
					color clr = ScreenLabelItems[i].clr;
					double bgalpha = alpha * 0.5;

					double textheight = max(max(lines.Count() * lineheight, dimensions.y), imagedimensions.y);
					double textwidth = 100 * textscale;

					for (int l = 0; l < lines.Count(); l++)
					{
						double w = lines.StringWidth(l) * textscale;
						if (w > textwidth) { textwidth = w; }
					}

					double boxwidth = textwidth + imagedimensions.x + dimensions.x * (image ? 2 : 1);

					drawpos.x -= boxwidth / 2 + dimensions.x;
					drawpos.y -= textheight + dimensions.y;

					bool colorize = !(clr == 0xFFFFFF);

					screen.DrawTexture (tl, false, drawpos.x, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					screen.DrawTexture (tm, false, drawpos.x + dimensions.x, drawpos.y, DTA_DestWidthF, boxwidth, DTA_DestHeightF, dimensions.y, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					screen.DrawTexture (tr, false, drawpos.x + dimensions.x + boxwidth, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					drawpos.y += dimensions.x;
					screen.DrawTexture (ml, false, drawpos.x, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, textheight, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					screen.DrawTexture (mm, false, drawpos.x + dimensions.x, drawpos.y, DTA_DestWidthF, boxwidth, DTA_DestHeightF, textheight, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					screen.DrawTexture (mr, false, drawpos.x + dimensions.x + boxwidth, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, textheight, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					drawpos.y += textheight;
					screen.DrawTexture (bl, false, drawpos.x, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					screen.DrawTexture (bm, false, drawpos.x + dimensions.x, drawpos.y, DTA_DestWidthF, boxwidth, DTA_DestHeightF, dimensions.y, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);
					screen.DrawTexture (br, false, drawpos.x + dimensions.x + boxwidth, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_Alpha, bgalpha, DTA_AlphaChannel, colorize, DTA_FillColor, clr & 0xFFFFFF);

					// Draw the icon
					if (image)
					{
						drawpos = startpos;
						drawpos.x -= boxwidth / 2 - imagedimensions.x / 2 - dimensions.x / 2;
						drawpos.y -= imagedimensions.y / 2;

						color clr = ScreenLabelItems[i].clr;
						screen.DrawTexture (image, true, drawpos.x, drawpos.y, DTA_DestWidthF, imagedimensions.x, DTA_DestHeightF, imagedimensions.y, DTA_CenterOffset, true, DTA_Alpha, alpha);
					}

					// Draw the text
					if (lines.Count())
					{
						drawpos = startpos;
						drawpos.x += imagedimensions.x / 2;
						drawpos.y -= textheight / 2 + lines.Count() * lineheight / 2;

						for (int s = 0; s < lines.Count(); s++)
						{
							String line = lines.StringAt(s);
							screen.DrawText(fnt, Font.CR_WHITE, drawpos.x - fnt.StringWidth(line) * textscale / 2, drawpos.y + s * lineheight, line, DTA_ScaleX, textscale, DTA_ScaleY, textscale, DTA_Alpha, alpha);
						}
					}
					break;
			}
		}
	}
}