/*
 * Copyright (c) 2021-2022 AFADoomer
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

class ScreenLabelItem : Thinker
{
	Actor mo;
	Line ln;
	int linespecial, activation;
	Array<uint> lines;
	String icon;
	String text;
	double alpha;
	color clr;
	int type, fade[MAXPLAYERS];
	bool draw[MAXPLAYERS];
	int interval;
	int animationinterval;

	EffectsManager manager;

	override void PostBeginPlay()
	{
		animationinterval = Random(1, 8);
		interval = Random(1, 105);

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (mo)
		{
			if (manager)
			{
				int interval;
				bool forceculled;

				[interval, forceculled] = manager.Culled(mo.pos.xy);
				if (forceculled || interval > 2) { return; }
			}
			else { manager = EffectsManager.GetManager(); }
		}

		Super.Tick();

		if (type == ScreenLabelHandler.LBL_Glint)
		{
			if (!mo) { Destroy(); }
			else
			{
				if (!animationinterval) { animationinterval = Random(1, 8); } //  Wait between 1 and 8 seconds before glinting
				int frame = ((mo.GetAge() + interval) % (35 * animationinterval)) / 3;
				switch (frame)
				{
					case 1:
					case 3:
					case 4:
					case 6:
						alpha = 0.5;
						icon = "GLINTA0";
						break;
					case 2:
						alpha = 0.75;
						icon = "GLINTB0";
						break;
					case 5:
						alpha = 1.0;
						icon = "GLINTB0";
					case 7:
						alpha = 0.25;
						icon = "GLINTA0";
						break;
					case 8:
						animationinterval = 0; // Reset wait time to another random duration
					default:
						alpha = 0.0;
						icon = "";
					break;
				}
			}
		}

		if (type == ScreenLabelHandler.LBL_Item)
		{
			if (!mo) { Destroy(); }
			else if (
				mo.bSpecial != mo.Default.bSpecial ||
				mo.bShootable != mo.Default.bShootable ||
				mo.bSolid != mo.Default.bSolid ||
				mo.bUseSpecial != mo.Default.bUseSpecial ||
				Safe(mo) && Safe(mo).isopen ||
				BoASupplyChest(mo) && BoASupplyChest(mo).open ||
				mo.master
			) { ScreenLabelHandler.Remove(mo); }

			if (ln)
			{
				if (
					ln.special != linespecial ||
					ln.activation != activation
				) { ScreenLabelHandler.Remove(mo); }
			}
		}
	}
}

class ScreenLabelCull : ScreenLabelItem
{
	override void Tick()
	{
		if (mo)
		{
			text = String.Format("%s\nAlpha: %2f", mo.GetClassName(), mo.alpha);
		}

		Super.Tick();
	}
}

class ScreenLabelHandler : EventHandler
{
	enum Types
	{
		LBL_Default,
		LBL_ColorMarker,
		LBL_Discrete,
		LBL_Item,
		LBL_Glint,
	};

	Array<ScreenLabelItem> ScreenLabelItems;
	transient CVar revar;

	protected Le_GlScreen gl_proj;
	protected Le_Viewport viewport;

	override void OnRegister()
	{
		gl_proj = new("Le_GlScreen");
		revar = CVar.FindCVar("boa_remode");
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

	uint FindItem(Actor mo, in out Array<uint> items = null) // Helper function to find a thing in a child class since the mo is nested in an object
	{
		if (items) { items.Clear(); }

		// Return the list of items from last to first
		for (int i = ScreenLabelItems.Size() - 1; i > -1; i--)
		{
			if (ScreenLabelItems[i] && ScreenLabelItems[i].mo == mo)
			{
				if (!items) { return i; }
				else { items.Push(i); }
			}
		}

		if (items && items.Size()) { return items[0]; }

		return ScreenLabelItems.Size();
	}

	uint FindLine(Line ln, in out Array<uint> items = null)
	{
		if (items) { items.Clear(); }

		// Return the list of items from last to first
		for (int i = ScreenLabelItems.Size() - 1; i > -1; i--)
		{
			if (ScreenLabelItems[i] && ScreenLabelItems[i].ln == ln)
			{
				if (!items) { return i; }
				else { items.Push(i); }
			}
		}

		if (items && items.Size()) { return items[0]; }

		return ScreenLabelItems.Size();
	}

	bool, ScreenLabelItem FindEquivalentLines(Line ln, in out Array<uint> lines)
	{
		if (!ln) { return false, null; }

		bool ret = false;
		ScreenLabelItem output = null;

		for (int i = 0; i < level.lines.Size(); i++)
		{
			if (
				level.lines[i].special == ln.special &&
				level.lines[i].args[0] == ln.args[0] &&
				level.lines[i].args[1] == ln.args[1] &&
				level.lines[i].args[2] == ln.args[2] &&
				level.lines[i].args[3] == ln.args[3] &&
				level.lines[i].args[4] == ln.args[4] &&
				level.vec2diff((level.lines[i].v1.p + level.lines[i].v1.p) / 2, (ln.v1.p + ln.v2.p) / 2).length() < 56
			)
			{
				ret = true;
				lines.Push(i);

				if (!output)
				{
					int j = FindLine(level.lines[i]);
					if (j != ScreenLabelItems.Size()) { output = ScreenLabelItems[j]; }
				}
			}
		}

		return ret, output;
	}

	ScreenLabelItem AddItem(class<ScreenLabelItem> cls, Actor thing, String iconName = "", String text = "", color clr = 0x0, double alpha = 1.0, int type = LBL_Default, bool update = true)
	{
		if (!thing) { return null; }

		int i = ScreenLabelItems.Size();
		if (update) { i = FindItem(thing); }

		ScreenLabelItem item;
		if (i == ScreenLabelItems.Size())
		{
			item = ScreenLabelItem(New(cls));
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

		return item;
	}

	// Static call for adding via ACS by actor TID
	static void Add(int actorTID = 0, String text = "", String iconName = "", color clr = 0xFFFFFF, double alpha = 0.8, int type = LBL_Default, bool update = false)
	{
		ScreenLabelHandler handler = ScreenLabelHandler(EventHandler.Find("ScreenLabelHandler"));
		if (!handler) { return; } // If no handler was found (somehow), silently fail

		if (actorTID)
		{
			let it = level.CreateActorIterator(actorTID, "Actor");
			Actor mo;

			while (mo = Actor(it.Next()))
			{
				handler.AddItem("ScreenLabelItem", mo, iconName, text, clr, alpha, type, update);
			}
		} 
	}

	static void Remove(Actor thing)
	{
		if (!thing) { return; } // If no thing was passed, silently fail

		ScreenLabelHandler handler = ScreenLabelHandler(EventHandler.Find("ScreenLabelHandler"));
		if (!handler) { return; }

		Array<uint> labels;
		int i = handler.FindItem(thing, labels);

		if (i < handler.ScreenLabelItems.Size())
		{
			for (int j = 0; j < labels.Size(); j++)
			{
				handler.ScreenLabelItems[labels[j]].Destroy();
				handler.ScreenLabelItems.Delete(labels[j], 1);
			}

			handler.ScreenLabelItems.ShrinkToFit();
		}
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (!e.thing) { return; }

		if (e.thing is "PlayerPawn") { AddItem("ScreenLabelItem", e.thing, "MP_MARK", "", 0x0, 0.8, LBL_ColorMarker); }

		if (revar && revar.GetBool()) // Add additional markers only if special mode is engaged via CVar
		{
			bool destroyable = e.thing.bShootable && e.thing.health > 0 && !e.thing.bNoDamage && !e.Thing.bInvulnerable && e.thing.bSolid;

			if (
				e.thing is "InteractiveItem" ||
				e.thing is "UniformStand" ||
				e.thing is "Safe" || 
				e.thing is "TurretStand" ||
				e.thing is "BoASupplyChest" ||
				e.thing is "CoffeeMachine" ||
				e.thing is "Nazi" && !Nazi(e.thing).wasused && !e.thing.special && e.thing.bFriendly && !Nazi(e.thing).user_sneakable && e.thing.Default.Species == "Nazi" && (!e.thing.target || !e.thing.target.bShootable) && Nazi(e.thing).activationcount < 2 && e.thing.health > 0
			) { AddItem("ScreenLabelItem", e.thing, "ITEMMARK", StringTable.Localize("$CNTRLMNU_USE") .. "\n[[+use:1]]", 0x0, 1.0, LBL_Item); }
			else if (
				e.thing is "AlarmPanel" ||
				e.thing is "GoodieBarrel1" ||
				(e.thing is "BarrelSpawner" && (BarrelSpawner(e.thing).user_spawntype || e.thing.special || e.thing.args[0])) ||
				(e.thing is "DestructionSpawner" && (DestructionSpawner(e.thing).user_spawntype || e.thing.special || e.thing.args[0])) ||
				(destroyable && e.thing.special && !e.thing.bIsMonster && !(e.Thing is "PlayerPawn"))
			) { AddItem("ScreenLabelItem", e.thing, "ITEMMARK", StringTable.Localize("$CNTRLMNU_ATTACK") .. "\n[[+attack:1]]", 0x0, 1.0, LBL_Item); }
			else if (
				e.thing.bPushable || // We really don't care about most of these, but there's not a good way to filter them out...
				e.thing is "StatueBreakable"
			) { AddItem("ScreenLabelItem", e.thing, "ITEMMARK", StringTable.Localize("$CNTRLMNU_FORWARD") .. "\n[[+forward:1]]", 0x0, 1.0, LBL_Item); }
			else if (e.thing.bSpecial && !e.thing.bInvisible && e.thing.alpha > 0) { AddItem("ScreenLabelItem", e.thing, "ITEMMARK", "", 0x0, 1.0, LBL_Item); }
		}

		if (e.thing is "Key_RE") { AddItem("ScreenLabelItem", e.thing, "", "", 0x0, 1.0, LBL_Glint, false); }
		else if (e.thing is "Gem") { AddItem("ScreenLabelItem", e.thing, "", "", 0xc7ecb9, 1.0, LBL_Glint, false); }
		else if (e.thing is "StatueKey") { AddItem("ScreenLabelItem", e.thing, "", "", 0x3eedc1, 1.0, LBL_Glint, false); }
	}

	override void WorldTick()
	{
		for (int i = 0; i < ScreenLabelItems.Size(); i++)
		{
			for (int p = 0; p < MAXPLAYERS; p++)
			{
				if (!playeringame[p] || !ScreenLabelItems[i]) { continue; }

				Vector3 pos = ScreenLabelItems[i].mo.pos;
				if (ScreenLabelItems[i].ln) { pos.xy = (ScreenLabelItems[i].ln.v1.p + ScreenLabelItems[i].ln.v2.p) / 2; }
				if (pos != ScreenLabelItems[i].mo.pos) { ScreenLabelItems[i].mo.SetXYZ(pos); }

				ScreenLabelItems[i].draw[p] = !!(players[p].mo && ScreenLabelItems[i].mo && ScreenLabelItems[i].mo.CheckSight(players[p].mo, SF_IGNOREVISIBILITY && SF_IGNOREWATERBOUNDARY));
				if (ScreenLabelItems[i].mo is "CoffeeMachine" && players[p].health >= 25) { ScreenLabelItems[i].draw[p] = false; }
				if (ScreenLabelItems[i].type == LBL_Glint)
				{
					// Only do this for labels that need more strict line-of-sight checking
					FLineTraceData LOF;
					Vector3 spos = LevelLocals.SphericalCoords(pos, players[p].mo.pos);
					bool hit = ScreenLabelItems[i].mo.LineTrace(-spos.x, 512, -spos.y, 0, ScreenLabelItems[i].mo.height / 2, 16, 0, LOF);
					if (hit && (!LOF.HitActor || LOF.HitActor != players[p].mo)) { ScreenLabelItems[i].draw[p] = false; }
				}

				let pp = BoAPlayer(players[p].mo);
				if (!pp) { continue; }

				if (ScreenLabelItems[i].ln)
				{
					bool undercrosshair = !!(ScreenLabelItems[i].ln == pp.CrosshairLine);

					if (!undercrosshair && ScreenLabelItems[i].lines.size())
					{
						for (int n = 0; n < ScreenLabelItems[i].lines.size() && !undercrosshair; n++)
						{
							if (level.lines[ScreenLabelItems[i].lines[n]] == pp.CrosshairLine) { undercrosshair = true; }
						}
					}

					if (undercrosshair) { ScreenLabelItems[i].fade[p] = min(ScreenLabelItems[i].fade[p] + 1, 16); }
					else if (ScreenLabelItems[i].fade[p]) { ScreenLabelItems[i].fade[p] = max(ScreenLabelItems[i].fade[p] - 1, 0); }
				}
				else if (ScreenLabelItems[i].mo)
				{
					if (ScreenLabelItems[i].mo == pp.CrosshairTarget) { ScreenLabelItems[i].fade[p] = min(ScreenLabelItems[i].fade[p] + 1, 16); }
					else if (ScreenLabelItems[i].fade[p]) { ScreenLabelItems[i].fade[p] = max(ScreenLabelItems[i].fade[p] - 1, 0); }
				}

				if (ScreenLabelItems[i].text)
				{
					int rangeindex = ScreenLabelItems[i].text.RightIndexOf(":") + 1;
					if (rangeindex > 0)
					{
						int endrangeindex = ScreenLabelItems[i].text.RightIndexOf("]]") - rangeindex;
						String range = ScreenLabelItems[i].text.Mid(rangeindex, endrangeindex);

						if (range.IndexOf("-") == -1)
						{
							ScreenLabelItems[i].text.Substitute(range, String.Format("%i", level.time / 70));
						}
					}
				}
			}
		}
	}

	bool CheckLineTexture(Line ln, String texture)
	{
		for (int s = line.front; s <= line.back; s++)
		{
			side sd = ln.sidedef[s];

			if (sd)
			{
				for (int w = side.top; w <= side.bottom; w++)
				{
					TextureID tex = sd.GetTexture(w);
					if (tex.IsValid())
					{
						String texname = TexMan.GetName(tex);
						texname = texname.MakeLower();
						texture = texture.MakeLower();
						if (texname.IndexOf(texture) > -1) { return true; }
					}
				}
			}
		}

		return false;
	}

	override void WorldLoaded (WorldEvent e)
	{
		if (!revar || !revar.GetBool()) { return; }
		
		for (int l = 0; l < level.lines.Size(); l++)
		{
			line ln = level.lines[l];

			// Add to textures that are made generically interactive via ZScript
			bool usable = CheckLineTexture(ln, "CABN_T02");

			if (
				(
					(!(ln.flags & Line.ML_DONTDRAW)) && // Don't add to hidden lines
					(ln.activation & SPAC_Use || ln.activation & SPAC_Push || ln.activation & SPAC_Impact) && // Only add to player interaction lines
					( // Don't show activation hints for polyobject rotate lines or door activation lines that are actually on the door
						(ln.special > 3 && ln.special < 7) ||
						(ln.special > 8 && ln.special < 15 && ln.args[0]) ||
						(ln.special > 14 && ln.special < 90) ||
						(ln.special > 91 && ln.special < 105) ||
						(ln.special > 104 && ln.special < 107 && ln.args[0]) ||
						(ln.special > 106)
					)
				) ||
				usable // ZScript-driven texture activation
			)
			{
				// Skip adding to breakable mirrors and routinely usable (non plot-advancing) surfaces
				if (
					CheckLineTexture(ln, "MIRR_W01") || 
					CheckLineTexture(ln, "MIRR_W02") ||
					CheckLineTexture(ln, "BATH_DE2")
				) { continue; }

				ScreenLabel label;

				// Collapse indicators for nearby lines with the same special and args
				Array<uint> lines;
				bool other;
				ScreenLabelItem current;
				[other, current] = FindEquivalentLines(ln, lines);
				if (other && current)
				{
					double xmin = min(ln.v1.p.x, ln.v2.p.x);
					double xmax = max(ln.v1.p.x, ln.v2.p.x);
					double ymin = min(ln.v1.p.y, ln.v2.p.y);
					double ymax = max(ln.v1.p.y, ln.v2.p.y);

					for (int m = 0; m < lines.Size(); m++)
					{
						Line nextline = level.lines[lines[m]];

						xmin = min(xmin, nextline.v1.p.x, nextline.v2.p.x);
						xmax = max(xmax, nextline.v1.p.x, nextline.v2.p.x);

						ymin = min(ymin, nextline.v1.p.y, nextline.v2.p.y);
						ymax = max(ymax, nextline.v1.p.y, nextline.v2.p.y);
					}

					label = ScreenLabel(current.mo);
					if (label)
					{
						Vector3 centerpos = (xmin + (xmax - xmin) / 2, ymin + (ymax - ymin) / 2, label.pos.z);
						label.SetXYZ(centerpos);
					}

					current.lines.Move(lines);
				}
				else // Place a new marker on the line
				{
					Vector2 pos = (ln.v1.p + ln.v2.p) / 2;

					double floorz = ln.frontsector.floorplane.ZAtPoint(pos);
					double ceilingz = ln.frontsector.ceilingplane.ZAtPoint(pos);

					Side frontside = ln.sidedef[line.front];

					double floordiff = 0;
					double ceildiff = 0;
					double z = 0;
					double scale = 1.0;

					if (ln.backsector)
					{
						floordiff = ln.backsector.floorplane.ZAtPoint(pos) - floorz;
						ceildiff = ceilingz - ln.backsector.ceilingplane.ZAtPoint(pos);
					}

					TextureID tex;
					Vector2 texsize;

					if (!ln.backsector || (floordiff == 0 && ceildiff == 0))
					{
						scale = frontside.GetTextureYScale(Side.mid);
						z = frontside.GetTextureYOffset(Side.mid) / scale;

						tex = frontside.GetTexture(Side.mid);
						texsize = TexMan.GetScaledSize(tex) / scale;

						if (ln.flags & line.ML_DONTPEGBOTTOM)
						{
							z += ln.frontsector.GetPlaneTexZ(Sector.floor);
							z += texsize.y * 3 / 4;
						}
						else
						{
							z += ln.frontsector.GetPlaneTexZ(Sector.ceiling);
							z += texsize.y / 4;
						}

						z = clamp(z, floorz + 16, min(floorz + 96, ceilingz - 16));
					}
					else if (floordiff > 0)
					{
						scale = frontside.GetTextureYScale(Side.bottom);
						z = frontside.GetTextureYOffset(Side.bottom) / scale;

						tex = frontside.GetTexture(Side.bottom);
						texsize = TexMan.GetScaledSize(tex) / scale;

						if (ln.flags & line.ML_DONTPEGBOTTOM)
						{
							z += ln.frontsector.GetPlaneTexZ(Sector.ceiling);
							z -= texsize.y * 3 / 4;
						}
						else
						{
							z += ln.backsector.GetPlaneTexZ(Sector.floor);
							z -= texsize.y / 4;
						}

						z = min(z, floorz + floordiff * 5 / 4);
					}
					else if (ceildiff > 0)
					{
						scale = frontside.GetTextureYScale(Side.top);
						z = frontside.GetTextureYOffset(Side.top) / scale;

						tex = frontside.GetTexture(Side.top);
						texsize = TexMan.GetScaledSize(tex) / scale;

						if (ln.flags & line.ML_DONTPEGTOP)
						{
							z += ln.frontsector.GetPlaneTexZ(Sector.ceiling);
							z += texsize.y * 3 / 4;
						}
						else
						{
							z += ln.backsector.GetPlaneTexZ(Sector.ceiling);
							z += texsize.y * 3 / 4;
						}

						z = max(z, ceilingz - ceildiff / 4);
					}

					if (usable) { z = min(z, floorz + 64); } // Default the position of the label to eye height for usable textures

					label = ScreenLabel(Actor.Spawn("ScreenLabel", (pos, z)));
					if (label)
					{
						String text = "";
						if (ln.activation & SPAC_Use || usable) { text = StringTable.Localize("$CNTRLMNU_USE") .. "\n[[+use:1]]"; }
						else if (ln.activation & SPAC_Push) { text = StringTable.Localize("$CNTRLMNU_FORWARD") .. "\n[[+forward:1]]"; }
						else if (ln.activation & SPAC_Impact) { text = StringTable.Localize("$CNTRLMNU_ATTACK") .. "\n[[+attack:1]]"; }
 
						ScreenLabelItem new = AddItem("ScreenLabelItem", label, "ITEMMARK", text, 0x0, 1.0, LBL_Item);
						if (new)
						{
							new.ln = ln;
							new.linespecial = ln.special;
							new.activation = ln.activation;
						}
					}
				}
			}
		}
	}

	override void RenderUnderlay(RenderEvent e)
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
				ScreenLabelItems[i].mo == p.mo ||
				(
					Inventory(ScreenLabelItems[i].mo) && 
					Inventory(ScreenLabelItems[i].mo).owner
				) ||
				!ScreenLabelItems[i].draw[consoleplayer]
			) { continue; }

			if (
				(
					ScreenLabelItems[i].type == LBL_Default ||
					ScreenLabelItems[i].type == LBL_Glint ||
					ScreenLabelItems[i].mo.bSpecial
				) && 
				ScreenLabelItems[i].mo.bDormant // Only turn labels off on dormant items that can normally be picked up.
			) { continue; }

			Actor mo = ScreenLabelItems[i].mo;
			Line ln = ScreenLabelItems[i].ln;

			Vector3 pos = mo.pos;
			if (ln) { pos.xy = (ln.v1.p + ln.v2.p) / 2; }

			double dist = Level.Vec3Diff(e.viewpos, pos).Length();
			double alpha = ScreenLabelItems[i].alpha;
			double fovscale = p.fov / 90;

			double top = mo.height;
			double side = mo.radius;

			// Get the sprite height and use that as top draw height if possible
			TextureID spritetex = mo.SpawnState.GetSpriteTexture(0);
			if (spritetex)
			{
				String sname = TexMan.GetName(spritetex);
				if (!(sname == "MDLAA0" || sname == "MDLSA0" || sname == "TNT1A0" || sname == "UNKNA0" || sname == "AMRKA0"))
				{
					Vector2 size = TexMan.GetScaledSize(spritetex);
					Vector2 offset = TexMan.GetScaledOffset(spritetex);

					top = offset.y * mo.scale.y;
					side = abs(offset.x * mo.scale.y);
				}
			}

			Vector3 offset = (0, 0, mo.GetBobOffset());
			if (ScreenLabelItems[i].type == LBL_Item) { offset.z += top + 4; }
			else if (ScreenLabelItems[i].type == LBL_Glint)
			{
				offset.z += top / 2;
				side = 0;
			}
			else { offset.z += top + 16; }

			side = min(side, offset.z);

			// Account for actor pitch
			offset.xy = Actor.RotateVector((offset.z * sin(mo.pitch) / (side ? 2 : 1), 0), mo.angle);
			offset.z = max(side, offset.z * cos(mo.pitch));

			Vector3 worldpos = e.viewpos + level.Vec3Diff(e.viewpos, pos + offset); // World position of object, offset from viewpoint
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
				case LBL_Discrete:
					if (true)
					{
						if (dist > 768) { continue; }
						if (dist > 256) { alpha = 1.0 - (dist - 256) / 512; }

						Font tinyfont = Font.GetFont("THREEFIV");

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
				case LBL_Item:
					if (revar && revar.GetBool())
					{
						if (dist > 256) { continue; }
						else if (dist > 160) { alpha = 1.0 - (dist - 160) / 64; }

						TextureID image;
						Vector2 imagedimensions = (0, 0);
						if (ScreenLabelItems[i].icon)
						{
							image = TexMan.CheckForTexture(ScreenLabelItems[i].icon, TexMan.Type_Any);
							if (image) { imagedimensions = TexMan.GetScaledSize(image); }
						}

						Font fnt = Font.GetFont("MiniFont");

						String text = StringTable.Localize(ScreenLabelItems[i].text);
						String temp; BrokenString lines;
						[temp, lines] = BrokenString.BreakString(text, int(48 * fnt.StringWidth(" ")), fnt:fnt);

						double scaleamt = 20.0;
						CVar scalecvar = CVar.FindCVar("boa_itemlabelscale");
						if (scalecvar) { scaleamt /= max(0.01, scalecvar.GetFloat()); }
						double scaleval = (Screen.GetHeight() / scaleamt) / imagedimensions.y;

						double textscale = scaleval / (fovscale * dist / 256);
						double imagescale = 0.5 * textscale;
						double lineheight = int(fnt.GetHeight() * textscale);
						double buttonheight = int(Button.GetHeight(null, textscale));
						imagedimensions *= imagescale;

						// Draw the icon
						if (image)
						{
							drawpos.y -= imagedimensions.y / 3;
							DrawToHUD.DrawTexture(image, drawpos, alpha, imagescale, ScreenLabelItems[i].clr ? ScreenLabelItems[i].clr : -1, (-1, -1), DrawToHud.TEX_CENTERED | DrawToHUD.TEX_NOSCALE | (ScreenLabelItems[i].clr ? DrawtoHUD.TEX_COLOROVERLAY : 0));
						}

						let p = players[consoleplayer].mo;
						if (!p || !lines.Count()) { continue; }

						double range = p.UseRange * 3;
						if (range && dist > range * 1.25) { alpha *= 1.0 - (dist - range) / range; }

						if (ScreenLabelItems[i].fade[consoleplayer] == 0 || alpha == 0.0) { continue; }

						double cmdalpha = clamp(ScreenLabelItems[i].fade[consoleplayer] / 16.0, 0.0, 1.0);
						
						if (lines.Count())
						{
							drawpos.y -= imagedimensions.y / 2 + 8 * textscale;

							for (int s = lines.Count() - 1; s > -1; s--)
							{
								String line = lines.StringAt(s);
								if ((line.IndexOf("[[") > -1 && line.IndexOf("]]") > -1)) { drawpos.y -= buttonheight - lineheight; }

								DrawToHUD.DrawText(line, drawpos, fnt, alpha * cmdalpha, textscale, (-1, -1), 0xFFFFFF, ZScriptTools.STR_CENTERED | ZScriptTools.STR_NOSCALE);
								drawpos.y -= lineheight;

								if ((line.IndexOf("[[") > -1 && line.IndexOf("]]") > -1)) { drawpos.y -= 12 * textscale; }
							}
						}
					}
					break;
				case LBL_Glint:
						if (dist > 512) { continue; }
						else if (dist > 384) { alpha = 1.0 - (dist - 384) / 128; }

						alpha *= 2.0;

						if (ScreenLabelItems[i].icon && ScreenLabelItems[i].alpha)
						{
							TextureID glint = TexMan.CheckForTexture(ScreenLabelItems[i].icon, TexMan.Type_Any);
							if (glint.IsValid())
							{
								Vector2 imagedimensions = TexMan.GetScaledSize(glint);

								double scaleamt = 40.0;
								CVar scalecvar = CVar.FindCVar("boa_itemlabelscale");
								if (scalecvar) { scaleamt /= max(0.01, scalecvar.GetFloat()); }
								double scaleval = (Screen.GetHeight() / scaleamt) / imagedimensions.y;

								double glintscale = scaleval / (fovscale * dist / 512);
								DrawToHUD.DrawTexture(glint, drawpos, ScreenLabelItems[i].alpha * alpha, glintscale, ScreenLabelItems[i].clr ? ScreenLabelItems[i].clr : -1, (-1, -1), DrawToHud.TEX_CENTERED | DrawToHUD.TEX_NOSCALE | (ScreenLabelItems[i].clr ? DrawtoHUD.TEX_COLOROVERLAY : 0));
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