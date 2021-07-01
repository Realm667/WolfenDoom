class ScreenLabelItem
{
	Actor mo;
	String icon;
	String text;
	double alpha;
	color clr;
	int type;
	bool distscale;
}

class ScreenLabelHandler : EventHandler
{
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

	uint FindItem(Actor mo) // Helper function to find a thing in a child class since the mo is nested in a object
	{
		for (int i = 0; i < ScreenLabelItems.Size(); i++)
		{
			if (ScreenLabelItems[i] && ScreenLabelItems[i].mo == mo) { return i; }
		}
		return ScreenLabelItems.Size();
	}

	void AddItem(Actor thing, String iconName = "", String text = "", color clr = 0xFFFFFF, double alpha = 1.0, int type = 0, int distscale = 0)
	{
		if (!thing) { return; }

		int i = FindItem(thing);
		if (i < ScreenLabelItems.Size()) // If it's already there, just update the properties
		{
			ScreenLabelItems[i].icon = iconName;
			ScreenLabelItems[i].text = text;
			ScreenLabelItems[i].alpha = alpha;
			ScreenLabelItems[i].clr = clr;
			ScreenLabelItems[i].type = type;
			ScreenLabelItems[i].distscale = distscale;
		}
		else
		{
			ScreenLabelItem item = New("ScreenLabelItem");
			item.mo = thing;
			item.icon = iconName;
			item.text = text;
			item.alpha = alpha;
			item.clr = clr;
			item.type = type;
			item.distscale = distscale;

			ScreenLabelItems.Push(item);
		}
	}

	static void Add(int actorTID = 0, String text = "", String iconName = "", color clr = 0xFFFFFF, double alpha = 0.8, int type = 0)
	{
		ScreenLabelHandler handler = ScreenLabelHandler(EventHandler.Find("ScreenLabelHandler"));
		if (!handler) { return; } // If no handler was found (somehow), silently fail

		if (actorTID)
		{
			let it = level.CreateActorIterator(actorTID, "Actor");
			Actor mo;

			while (mo = Actor(it.Next()))
			{
				handler.AddItem(mo, iconName, text, clr, alpha, type); // Add each thing that has a matching TID
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
				(
					Inventory(ScreenLabelItems[i].mo) && 
					Inventory(ScreenLabelItems[i].mo).owner
				)
			) { continue; }

			Actor mo = ScreenLabelItems[i].mo;

			double dist = Level.Vec3Diff(e.viewpos, mo.pos).Length();
			double alpha = ScreenLabelItems[i].alpha;

			if (dist > 768) { continue; }
			if (dist > 256) { alpha = 1.0 - (dist - 256) / 512; }

			double fovscale = p.fov / 90;

			Vector3 worldpos = e.viewpos + level.Vec3Diff(e.viewpos, mo.pos + (0, 0, mo.height + 16 + mo.GetBobOffset())); // World position of object, offset from viewpoint
			gl_proj.ProjectWorldPos(worldpos); // Translate that to the screen, using the viewpoint's info

			if (!gl_proj.IsInScreen()) { continue; } // If the coordinates are off the screen, then skip drawing this item

			Vector2 drawpos = viewport.SceneToWindow(gl_proj.ProjectToNormal());
			Vector2 startpos = drawpos;

			// Get icon image information in order to properly offset text and set frame size
			TextureID image;
			Vector2 imagedimensions = (0, 0);
			if (ScreenLabelItems[i].icon)
			{
				image = TexMan.CheckForTexture(ScreenLabelItems[i].icon, TexMan.Type_Any);
				if (image) { imagedimensions = TexMan.GetScaledSize(image) * vid_scalefactor; }
			}

			// Get text content in order to calculate frame size
			String text = StringTable.Localize(ScreenLabelItems[i].text);
			String temp; BrokenString lines;
			[temp, lines] = BrokenString.BreakString(text, int(48 * SmallFont.StringWidth(" ")), fnt:SmallFont);

			double textscale = 1 / fovscale;
			double lineheight = int(SmallFont.GetHeight() * textscale);

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
					screen.DrawText(SmallFont, Font.CR_WHITE, drawpos.x - SmallFont.StringWidth(line) * textscale / 2, drawpos.y + s * lineheight, line, DTA_ScaleX, textscale, DTA_ScaleY, textscale, DTA_Alpha, alpha);
				}
			}
		}
	}

	ui double PitchTo(Actor mo, Actor source = null, double zoffset = 0.0)
	{
		if (!source) { source = Actor(self); }
		if (!source) { return 0; }

		double distxy = max(source.Distance2D(mo), 1);
		double distz = source.pos.z + zoffset - mo.pos.z;

		return atan(distz / distxy);
	}
}