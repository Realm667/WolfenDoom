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

class Debris : SceneryBase
{
	int moundstyle;
	bool domound;

	Property MoundStyle:moundstyle;
	Property DrawMound:domound;

	Default
	{
		Height 32;
		Radius 64;
		MaxStepHeight 48;
		MaxDropoffHeight 48;
		+SOLID
		+INVISIBLE
		+CullActorBase.DONTCULL
		Debris.MoundStyle 0;
		Debris.DrawMound true;

		// Hijack DropItem list for ease of customization.  
		// If the chance (second parameter) is negative, it's treated as a chance of 255, 
		// with the value used to bound a Random(x, y) call for the amount.  So, the 
		// DebrisGirder actor here will spawn between 2 and 4 times, the pipe between 2 and 10, etc.
		// Note that the random amount also scale with size, so if you make something with a 
		// large radius (e.g., 64), or you scale the actor up in-editor, you'll end up with 
		// that scale amount more items spawned (to fill space).
		DropItem "DebrisGirder", -2, 4;
		DropItem "DebrisPipe", -2, 10;
		DropItem "DebrisBeam", -10, 15;
		DropItem "DebrisBrick", -10, 15;
		DropItem "DebrisChunk", -10, 15;
		DropItem "DebrisBottle", 0, 2;
		DropItem "DebrisBottle2", 0, 2;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		scale.x = scale.x * Radius / 24;
		scale.y = scale.y * Height / 40;

		A_SetSize(Radius * scale.x, Height * scale.y);

		bDontCull = bDontCull || (boa_debriscullstyle > 0);

		double spread = min(Radius * 2, Radius + 32);

		if (domound)
		{ 
			Actor mound = Spawn("DebrisMound", pos);
			if (mound)
			{
				mound.master = self;
				mound.frame = clamp(moundstyle, 0, 2);
				mound.angle = Random(1, 360);

				if (bWasCulled)
				{
					if (mound.GetRenderStyle() == STYLE_Normal) { mound.A_SetRenderStyle(alpha, STYLE_Translucent); }
					mound.alpha = 0.0;
				}
			}
		}

		DropItem drops = GetDropItems();
		DropItem item = drops;

		if (item)
		{
			while (item)
			{
				String itemName = String.Format("%s", item.Name);
				if (itemName.Length() > 0 && item.Name != 'None')
				{
					Class<Actor> cls = item.Name;

					if (cls)
					{
						Class<Actor> rep = GetReplacement(cls);
						if (rep) { cls = rep; }
					}

					if (cls)
					{
						int amt = int(max(item.Amount, 1) * scale.x);
						int pr = item.probability;

						if (pr < 1)
						{
							amt = Random(int(-pr * scale.x), amt);
							pr = 255;
						}

						SpawnRandom(item.Name, pr, max(amt, 1), spread * 1.1, spread * 0.75);
					}
					else if (developer) { A_Log(TEXTCOLOR_RED .. "Unknown item class ".. item.Name .." attempted to drop from a debris spawner\n"); }
				}

				item = item.Next;
			}
		}

		Super.PostBeginPlay();
	}

	void SpawnRandom(Class<Actor> debrisclass, int probability = 255, int amt = 1, float distance = -1, float mindistance = 0)
	{
		if (amt <= 0) { return; }

		if (distance < 0) { distance = Radius; }

		for (int c = 0; c < amt; c++)
		{
			if (Random() < probability)
			{
				double spawnangle = Random(0, 359);
				double spawndist = mindistance + FRandom(0, distance - mindistance);
			
				Vector2 spawnpos = AngleToVector(spawnangle, spawndist);

				if (!boa_debriscullstyle && bWasCulled && !DebrisBase(GetDefaultByType(debrisclass))) { continue; } // Don't respawn non-DebrisBase actors that weren't culled out

				Actor mo = Spawn(debrisclass, ((pos.xy + spawnpos), GetZAt(pos.x + spawnpos.x, pos.y + spawnpos.y, 0, GZF_ABSOLUTEPOS)));

				// Don't keep objects that are spawned on floors above or on the other side of map geometry.
				if (mo && !CheckSight(mo)) { mo.Destroy(); }

				if (mo)
				{
					mo.master = self;
					if (DebrisBase(mo))
					{
 						if (DebrisBase(mo).doscale) { mo.scale = FRandom(0.25, 1.5) * mo.scale; }
					}

					if (!(mo is "DebrisBase"))
					{
						mo.bRollSprite = true;
						mo.pitch = FRandom(-15, -atan(Height / spawndist)); // Match the average height of the spawned items to the height of the pile
						mo.roll = Random(-30, 30);
						mo.angle = mo.AngleTo(self) + Random(-35, 35);
						mo.SetOrigin((mo.pos.xy, floorz), false);
						if (!boa_debriscullstyle) { mo.master = null; }
					
						if (Random() < 128 && mo.FindState("Death")) { mo.SetStateLabel("Death"); }
					}

					if (bWasCulled)
					{
						if (mo.GetRenderStyle() == STYLE_Normal) { mo.A_SetRenderStyle(alpha, STYLE_Translucent); }
						mo.alpha = 0.0;
					}
				}
			}
		}
	}

	override void OnDestroy()
	{
		if (!boa_debriscullstyle) { A_RemoveChildren(true, RMVF_EVERYTHING, "DebrisBase"); }
	}
}

class DebrisBase : StaticActor
{
	int variants;
	int user_variant;
	bool doscale;
	double maxscale;
	Vector3 oldpos;
	bool bWasCulled; // Placeholder for eventual culling support for debris piles

	Property VariantCount:variants;
	Property ShouldScale:doscale;

	Default
	{
		//$Category Props (BoA)/Debris
		//$Color 3
		Height 4;
		Radius 2;
		Mass 50;
		DebrisBase.ShouldScale true;
		DebrisBase.VariantCount 1;
		DistanceCheck "boa_scenelod";
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (!bWasCulled)
		{
			if (user_variant) { frame = user_variant; }
			else { frame = Random(0, variants - 1); }

			maxscale = 1.5;

			if (master)
			{
				double dist = Distance2D(master);

				pitch = -atan((master.pos.z + master.Height - pos.z) / dist) + FRandom(-5, 15);
				roll = Random(-30, 30);
				angle = AngleTo(master) + Random(-35, 35);

				maxscale = (dist * 2.5) / (Radius * scale.x);
			}
		}

		Super.PostBeginPlay();
	}
}

class DebrisMound : SceneryBase
{
	Default
	{
		Radius 64;
		MaxStepHeight 48;
		MaxDropoffHeight 48;
		RenderRadius 512;
		DistanceCheck "boa_scenelod";
		+CullActorBase.DONTCULL
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (!bWasCulled)
		{
			if (
				floorpic == TexMan.CheckForTexture("CNCR_G99", TexMan.Type_Any) ||
				floorpic == TexMan.CheckForTexture("textures/CNCR_G99.png", TexMan.Type_Any) ||
				floorpic == TexMan.CheckForTexture("DEBR_G01", TexMan.Type_Any) ||
				floorpic == TexMan.CheckForTexture("textures/DEBR_G01.png", TexMan.Type_Any) ||
				floorpic == TexMan.CheckForTexture("DEBR_G02", TexMan.Type_Any) ||
				floorpic == TexMan.CheckForTexture("textures/DEBR_G02.png", TexMan.Type_Any)
			)
			{  // Only spawn the mound if we're not on a debris pile texture already
				Destroy();
				return;
			}

			if (master)
			{
				scale = master.scale;
				scale.y = min(scale.y, scale.x / 3.5); // Don't make tall, pointy mounds
				A_SetSize(master.radius, master.height);
			}

			double distx = Radius;
			double disty = Radius;

			for (int i = 0; i <= 1; i++) { distx = GetMoveDistance(180 * i, distx); }
			for (int i = 0; i <= 1; i++) { disty = GetMoveDistance(90 + 180 * i, disty); }

			A_SetSize(0);

			double zoffset = VehicleBase.SetPitchRoll(self, distx, disty, 360, true);

			SetOrigin((pos.xy, floorz - zoffset), false);
		}

		Super.PostBeginPlay();
	}

	double GetMoveDistance(double angle, double range = 256)
	{
		Vector2 pointpos = (range, 0);

		double s = sin(angle);
		double c = cos(angle);
		pointpos = Vec2Offset(pointpos.x * c + pointpos.y * s, pointpos.x * s - pointpos.y * c);

		if (!level.IsPointInMap((pointpos, floorz))) { return range; }

		bool blocked;

		for (double i = 8; i <= range; i += 8)
		{
			blocked = CheckBlock(CBF_DROPOFF | CBF_NOLINES | CBF_NOACTORS, AAPTR_DEFAULT, i, 0, 0, angle);

			if (blocked) { return i; }
		}

		return range;
	}
}

class DebrisChunk : DebrisBase
{
	Default
	{
		//$Title Debris - Random Chunk
		DebrisBase.VariantCount 12;
		DebrisBase.ShouldScale false;
		DistanceCheck "boa_scenelod";
	}
}

class DebrisPipe : DebrisBase
{
	Default
	{
		//$Title Debris - Pipe
		Radius 140;
		Mass 100;
		DebrisBase.VariantCount 6;
		DistanceCheck "boa_scenelod";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!bWasCulled) { scale *= FRandom(0.5, maxscale); }
	}
}

class DebrisBeam : DebrisBase
{
	Default
	{
		//$Title Debris - Wooden Beam
		Radius 128;
		Mass 150;
		DebrisBase.VariantCount 5;
		DistanceCheck "boa_scenelod";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!bWasCulled)
		{
			scale.x *= FRandom(0.75, maxscale);
			scale.y *= FRandom(0.5, maxscale);
		}
	}
}

class DebrisGirder : DebrisBase
{
	Default
	{
		//$Title Debris - Girder
		Radius 116;
		Mass 300;
		DebrisBase.VariantCount 3;
		DistanceCheck "boa_scenelod";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!bWasCulled) { scale *= FRandom(0.5, min(maxscale, 2.5)); }
	}
}

class DebrisBrick : DebrisBase 
{
	Default
	{
		//$Title Debris - Brick
		Radius 14;
		DebrisBase.ShouldScale false;
		DistanceCheck "boa_scenelod";
	}
}

class DebrisBottle : DebrisChunk
{
	Default
	{
		DebrisBase.ShouldScale false;
		DebrisBase.VariantCount 2;
		DistanceCheck "boa_scenelod";
		RenderStyle "Translucent";
		Alpha 0.95;
	}
}

class DebrisBottle2 : DebrisBottle
{
	Default
	{
		DistanceCheck "boa_scenelod";
	}
}

class DebrisCorrugated : DebrisBase
{
	Default
	{
		//$Title Debris - Corrugated Metal
		Radius 70;
		Mass 10;
		DistanceCheck "boa_scenelod";
		DebrisBase.ShouldScale false;
		DebrisBase.VariantCount 2;
	}
}

class JunkPile1 : Debris
{
	Default
	{
		//$Category Props (BoA)/Debris
		//$Title Junk Pile (middle)
		Radius 25;
		Height 20;
		+SOLID
		DropItem "DebrisGirder", -2, 4;
		DropItem "DebrisPipe", -2, 10;
		DropItem "DebrisBeam", -10, 15;
		DropItem "DebrisBrick", -10, 15;
		DropItem "DebrisChunk", -10, 15;
		DropItem "DebrisBottle", 0, 2;
		DropItem "DebrisBottle2", 0, 2;
	}
}

class JunkPile2 : Debris
{
	Default
	{
		//$Category Props (BoA)/Debris
		//$Title Junk Pile (large)
		Radius 28;
		Height 28;
		+SOLID
		DropItem "DebrisGirder", -2, 4;
		DropItem "DebrisPipe", -2, 10;
		DropItem "DebrisBeam", -10, 15;
		DropItem "DebrisBrick", -10, 15;
		DropItem "DebrisChunk", -10, 15;
		DropItem "DebrisBottle", 0, 2;
		DropItem "DebrisBottle2", 0, 2;
	}
}

class JunkPile3 : Debris
{
	Default
	{
		//$Category Props (BoA)/Debris
		//$Title Junk Pile (small, with sprites)
		Radius 24;
		Height 8;
		+SOLID
		DropItem "DebrisGirder", -2, 4;
		DropItem "DebrisPipe", -2, 10;
		DropItem "DebrisBeam", -10, 15;
		DropItem "DebrisBrick", -10, 15;
		DropItem "DebrisChunk", -10, 15;
		DropItem "DebrisBottle", 0, 2;
		DropItem "DebrisBottle2", 0, 2;
		DropItem "Radiator_Short", 128;
		DropItem "Chair3", 64;
		DropItem "Table8", 64;
		DropItem "Bunk_Bed1", 64;
		DropItem "WineBottle", 255, 5;
	}
}

class JunkPile4 : Debris
{
	Default
	{
		//$Category Props (BoA)/Debris
		//$Title Junk Pile (large, with corrugated sheets)
		Radius 32;
		Height 32;
		+SOLID
		DropItem "DebrisGirder", -2, 4;
		DropItem "DebrisPipe", -2, 10;
		DropItem "DebrisBeam", -10, 15;
		DropItem "DebrisBrick", -10, 15;
		DropItem "DebrisChunk", -10, 15;
		DropItem "DebrisBottle", 0, 2;
		DropItem "DebrisBottle2", 0, 2;
		DropItem "DebrisCorrugated", 255, 2;
	}
}

class JunkPileAstro : Debris
{
	Default
	{
		//$Category Astrostein (BoA)/Props
		//$Title Junk Pile (Astrostein)
		Radius 28;
		Height 28;
		+SOLID
		Debris.MoundStyle 2; // Trash heap
		DropItem "DebrisGirder", -2, 4;
		DropItem "DebrisPipe", -2, 10;
		DropItem "DebrisBeam", -10, 15;
		DropItem "DebrisChunk", -10, 15;
		DropItem "PMetal1", 0, 2;
		DropItem "PMetal2", 0, 2;
		DropItem "PMetal3", 0, 2;
		DropItem "PMetal4", 0, 2;
		DropItem "PMetal5", 0, 2;
	}
}