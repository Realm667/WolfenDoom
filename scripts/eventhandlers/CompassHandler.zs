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

class CompassIcon
{
	Actor mo;
	String icon;
	double alpha;
}

class CompassHandler : EventHandler
{
	Array<CompassIcon> CompassItems;
	const compassX = 85.0;
	const compassY = 105.0;
	const compassRadius = 46.0;
	const compassIconSize = 12.0;
	const distFactor = 0.1;

	double drawflash;
	transient ui CVar scalecvar;

	uint FindCompassItem(Actor mo) // Helper function to find a thing in a child class (Used in place of CompassItems.Find(mo) since the mo is nested in a CompassIcon object
	{
		for (int i = 0; i < CompassItems.Size(); i++)
		{
			if (CompassItems[i] && CompassItems[i].mo == mo) { return i; }
		}
		return CompassItems.Size();
	}

	static clearscope String GetDefaultIcon(Actor thing, bool usesprite = false) // Icon handling for anything that doesn't have the icon set already (CompassItem actors handle their icons internally)
	{
		if (!thing) { return ""; }

		String txName;

		// The objective indicators (ObjectiveIcon and ExclamationCompass) use a red exclamation mark
		// The other activation markers use an orange exclamation mark
		// Mission quest items use their inventory icon (or spawn sprite if no icon is set)
		// Miscellaneous items use a grey dot
		if (usesprite || thing is "ObjectiveIcon" || thing is "ExclamationBase" || thing is "ScientistUniform")
		{
			// Use the spawn sprite as the icon
			TextureID icon = thing.CurState.GetSpriteTexture(0);
			txName = TexMan.GetName(icon);

			// Fall back to the orange exclamation point if it's invisible or a model (this is what the Exclamations generally use)
			if (txName == "TNT1A0" || txName == "MDLSA0") { txName = "GOAL2"; }
		}
		else if (thing.GetRenderStyle() != STYLE_None || thing is "TankBase") // Anything else that is set to show up (usually via ACS) will use GOAL1 if it's not invisible
		{
			txName = "GOAL1"; // Grey dot
		}

		return txName;
	}

	void Add(Actor thing, String iconName = "")
	{
		if (!thing) { return; }

		int i = FindCompassItem(thing);
		if (i < CompassItems.Size()) // If it's already there, just update the icon
		{
			CompassItems[i].icon = iconName;
		}
		else
		{
			CompassIcon item = New("CompassIcon");
			item.mo = thing;
			item.icon = iconName;
			item.alpha = 0.0;

			if (thing is "ObjectiveIcon" || thing is "ExclamationBase")
			{ // Push these to be drawn on top
				CompassItems.Push(item);
			}
			else
			{ // Insert these to be drawn behind other objects
				CompassItems.Insert(0, item);
			}
		}
	}

	override void WorldTick()
	{
		for (int i = 0; i < CompassItems.Size(); i++)
		{
			if (CompassItems[i].mo)
			{
				// Fade to the icon's alpha value
				if (CompassItems[i].alpha < CompassItems[i].mo.alpha) { CompassItems[i].alpha = min(CompassItems[i].alpha + 0.05, CompassItems[i].mo.alpha); }
				else if (CompassItems[i].alpha > CompassItems[i].mo.alpha) { CompassItems[i].alpha = max(CompassItems[i].alpha - 0.05, CompassItems[i].mo.alpha); }
			}
		}
	}

	override void WorldThingDied(WorldEvent e)
	{
		int i = FindCompassItem(e.Thing);

		if (i < CompassItems.Size())
		{
			CompassItems[i].Destroy();
			CompassItems.Delete(i, 1);
			CompassItems.ShrinkToFit();
		}		
	}
}

class CompassWidget : Widget
{
	CompassHandler handler;

	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		CompassWidget wdg = CompassWidget(Widget.Init("CompassWidget", widgetname, anchor, 0, priority, pos, zindex));
		if (wdg)
		{
			wdg.margin[0] = 16;
			wdg.margin[2] = 4;
		}
	}

	override bool SetVisibility()
	{
		BoACompass cmps = BoACompass(player.mo.FindInventory("BoACompass"));

		if (
				!cmps ||
				!cmps.active ||
				automapactive ||
				screenblocks > 11 ||
				player.mo.FindInventory("CutsceneEnabled") ||
				player.mo.FindInventory("IncomingMessage") ||
				(level.levelnum >= 151 && level.levelnum <= 153) || // Specifically disable on the Keen maps
				player.mo is "KeenPlayer" ||
				!handler
		)
		{
			return false;
		}

		return true;
	}

	override void DoTick(int index)
	{
		if (!handler) { handler = CompassHandler(EventHandler.Find("CompassHandler")); }

		Super.DoTick(index);
	}

	override Vector2 Draw()
	{
		// Find compass and background textures
		TextureID cmpsbg = TexMan.CheckForTexture("COMPASS");
		TextureID cmpsrose = TexMan.CheckForTexture("COMP_BKG");
		TextureID cmpsflash = TexMan.CheckForTexture("COMP_FLS");

		double compassscale = 1.0;
		if (!handler.scalecvar) { handler.scalecvar = CVar.FindCVar("boa_hudcompassscale"); }
		if (handler.scalecvar && handler.scalecvar.GetFloat() > 0) { compassscale = handler.scalecvar.GetFloat(); }

		size = TexMan.GetScaledSize(cmpsbg) * compassscale;
		Super.Draw();

		double compassalpha = (1.0 - player.BlendA) * alpha; // Fade the compass if there's a screen blend/fade in effect

		double compassradius = handler.compassRadius;
		double compassX = pos.x + size.x / 2;
		double compassY = pos.y + size.y / 2;
		double compassIconSize = handler.compassIconSize;
		double distfactor = handler.distFactor;

		// Draw the compass itself
		DrawToHUD.DrawTexture(cmpsbg, (compassX, compassY - 6.0), compassalpha, compassScale);

		// Draw the background compass directions
		DrawToHUD.DrawTransformedTexture(cmpsrose, (compassX, compassY), compassalpha, player.camera.angle - 90, compassScale); // Use player angle, offset so that 90 degrees on the map is shown as north

		// Draw icons
		for (int i = 0; i < handler.CompassItems.Size(); i++)
		{
			Actor mo = handler.CompassItems[i].mo;
			if (!mo) { continue; }
			if (mo is "Inventory" && Inventory(mo).Owner) { continue; }
			if (mo is "ScientistUniform" && !mo.bSolid) { continue; }
			if (mo.bDormant || mo.health <= 0) { if (am_cheat % 4 < 1) { continue; } }

			TextureID icon = TexMan.CheckForTexture(handler.CompassItems[i].icon, TexMan.Type_Any);
			Vector2 relativeLocation = level.Vec2Diff(player.camera.pos.xy, mo.pos.xy);

			// Account for chasecam
			if (player.cheats & CF_CHASECAM != 0)
			{
				CVar chaseDist = CVar.GetCVar("chase_dist", player);
				Vector2 chaseDiff = Actor.AngleToVector(player.camera.angle, chaseDist.GetFloat() * cos(player.camera.pitch));
				relativeLocation -= chaseDiff;
			}

			relativeLocation.Y *= -1;

			relativeLocation = Actor.RotateVector(relativeLocation, player.camera.angle - 90);

			double pointradius = compassRadius * compassScale - compassIconSize * compassscale;

			if (relativeLocation.Length() * distFactor > pointRadius)
			{
				relativeLocation = relativeLocation.Unit() * pointRadius / distFactor;
			}

			double iconX = compassX + relativeLocation.X * distFactor;
			double iconY = compassY + relativeLocation.Y * distFactor;

			// Handle objects that need to know if the sprite changed
			if (mo is "Exclamation")
			{
				icon = mo.CurState.GetSpriteTexture(0);
			}

			// Get the image size and scale it down if necessary
			Vector2 size = TexMan.GetScaledSize(icon);
			double maxsize = max(size.x, size.y);
			double scale = 1.0;

			// Scale the image down to the max icon size set in constant above.  Smaller images will stay as they are
			if (maxsize > compassIconSize) { scale = compassIconSize / maxsize; }

			// If it's the default 'dot' icon...
			if (handler.CompassItems[i].icon == "GOAL1")
			{
				// Scale the icon slightly based on size (radius) of the actor
				scale *= clamp(mo.radius / 32.0, 0, 1.0) * 0.75 + 0.25;
			}

			// Fade the icon the farther away the thing is
			double alpha = handler.CompassItems[i].alpha * compassalpha * clamp(2048 / max(player.mo.Distance3D(mo), 0.1), 0.25, 0.95);

			// Dark outline/shadow effect behind the icon
			DrawToHUD.DrawTexture(icon, (iconX, iconY), alpha, scale * 1.25 * compassScale, 0x050505);

			// Draw the icon
			DrawToHUD.DrawTexture(icon, (iconX, iconY), alpha, scale * compassScale);

			// If the actor has a forced health bar (e.g., the Nebelwerfer in C1M5), overlay the health color of the actor
			if (Base(mo) && Base(mo).user_drawhealthbar)
			{
				double hlth = double(mo.health) / mo.SpawnHealth();

				int r = int(255 * (1.0 - hlth));
				int g = int(255 * hlth);

				DrawToHUD.DrawTexture(icon, (iconX, iconY), alpha, scale * compassScale, color(r, g, 0));
			}
			else if (PlayerFollower(mo) && mo.bFriendly)
			{
				DrawToHUD.DrawTexture(icon, (iconX, iconY), alpha, scale * compassScale, color(0, 0, 200));
				TextureID tex = TexMan.CheckForTexture("Arrow", TexMan.Type_Any);
				if (tex)
				{
					DrawToHUD.DrawTransformedTexture(tex, (iconX, iconY), alpha / 2, player.camera.angle - mo.angle, scale * compassScale);
				}
			}

		}

		double flashduration = 35;

		if (handler.drawflash > level.time - flashduration - 35)
		{
			double phase = (level.time - handler.drawflash) / flashduration;
			double flashalpha;

			if (phase < 0.25) { flashalpha = phase / 0.25; } // Fade in
			else if (phase < 0.5) { flashalpha = 1.0; } // Hold
			else { flashalpha = 1.0 - (phase - 0.5); } // Fade out

			// Draw the gold flash around the perimeter of the compass
			DrawToHUD.DrawTransformedTexture(cmpsflash, (compassX, compassY), compassalpha / 3 * flashalpha * 0.75, -105 + 360 * phase, compassScale);
		}

		// Redraw the compass texture on top with a lower alpha so that the glass actually looks translucent
		DrawToHUD.DrawTexture(cmpsbg, (compassX, compassY - 6.0), compassalpha / 2, compassScale);

		return size;
	}
}