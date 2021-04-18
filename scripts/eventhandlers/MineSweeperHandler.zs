/*
 * Copyright (c) 2018-2020 AFADoomer, Talon1024
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

class MineSweeperHandler : EventHandler
{
	Array<Actor> ScannableThings;

	// Libeye things
	protected Le_GlScreen			gl_proj;
	protected Le_Viewport			viewport;

	// kd: This prepares the projector and text, which we have to align
	// ourselves. You have to new the projector, otherwise, you may get a
	// vm-abort, if you're unfamiliar.
	override void OnRegister () {
		gl_proj = new("Le_GlScreen");
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (
			!e.Thing ||
			!(e.Thing is "Mine") ||
			e.Thing is "UnderwaterMine" ||
			e.Thing.health <= 0 ||
			e.Thing.bDormant ||
			ScannableThings.Find(e.Thing) < ScannableThings.Size()
		) { return; }

		ScannableThings.push(e.Thing);
	}

	override void WorldThingDestroyed(WorldEvent e)
	{
		int i = ScannableThings.Find(e.Thing);

		if (i < ScannableThings.Size())
		{
			ScannableThings.Delete(i, 1);
			ScannableThings.ShrinkToFit();
		}
	}

	override void RenderOverlay( RenderEvent e )
	{
		PlayerInfo p = players[consoleplayer];

		if (!p || !p.mo) { return; }

		viewport.FromHud();
		gl_proj.CacheResolution();
		gl_proj.CacheFov(p.fov);
		gl_proj.OrientForRenderOverlay(e);
		gl_proj.BeginProjection();

		MineSweeper ms = MineSweeper(p.mo.FindInventory("MineSweeper"));

		if (ms && ms.active)
		{
			for (int i = 0; i < ScannableThings.Size(); i++)
			{
				Actor mo = ScannableThings[i];
				if (!mo) continue;

				double dist = p.mo.Distance3D(mo);
				if (dist > 512 ) { continue; }

				Vector3 worldpos = e.viewpos + level.Vec3Diff(e.viewpos, mo.pos); // World position of object, offset from viewpoint
				gl_proj.ProjectWorldPos(worldpos); // Translate that to the screen, using the viewpoint's info

				if (!gl_proj.IsInScreen()) { continue; } // If the coordinates are off the screen, then skip drawing this item

				Vector2 drawpos = viewport.SceneToWindow(gl_proj.ProjectToNormal());

				TextureID image = mo.SpawnState.GetSpriteTexture(0);

				Vector2 dimensions = TexMan.GetScaledSize(image);
				dimensions.x *= mo.scale.x;
				dimensions.y *= mo.scale.y;
				dimensions /= dist / 320 * p.fov / 90; // Scale with fov to account for zooming

				color clr = 0xDE1B15;
				double alpha = max(1.0 - (dist - 256) / 256, 0);

				screen.DrawTexture (image, false, drawpos.x, drawpos.y, DTA_DestWidthF, dimensions.x, DTA_DestHeightF, dimensions.y, DTA_AlphaChannel, true, DTA_FillColor, clr & 0xFFFFFF, DTA_Alpha, alpha);
			}
		}
	}
}