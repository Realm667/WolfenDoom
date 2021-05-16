/*
 * Copyright (c) 2017-2020 AFADoomer
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

// Use STANDSTILL flag in editor to tell the viewpont to ignore re-calculating the 
// anchor offset when the player crosses line portals
class SkyViewPointStatic : SkyViewPoint
{
	Actor base, anchor;
	double heightoffset;
	double scaling;
	Vector2 anchoroffset;

	Default
	{
		//$Category Skyboxes (BoA)
		//$Title Skybox ViewPoint (Static)
		//$Arg1 "Skybox Scene Scale"
		//$Arg1Tooltip "The scale of the skybox's scene (default is 100).  The larger this number is, the farther away the skybox contents will appear to be."
		//$Arg1Default 100
		//$Arg2 "Anchor Object TID"
		//$Arg2Tooltip "TID of an actor to anchor the skybox on.  Default value (0) means to anchor on player start spot."
		//$Arg2Default 0
		//$Arg3 "Make this the default sky"
		//$Arg3Tooltip " Should this become the default sky (as if it had no TID)?\nThis allows setting a starting TID on the viewpoint, but still setting the default level sky."
		//$Arg3Type 11
		//$Arg3Enum { 0 = "False"; 1 = "True"; }
		//$Arg3Default 0
		+NOCLIP
		Height 0;
		Radius 0;
	}

	static void SetAnchor(int tid, int anchorid = -1)
	{
		if (!tid) { return; }

		ActorIterator it = ActorIterator.Create(tid, "SkyViewPointStatic");
		SkyViewPointStatic mo = SkyViewPointStatic(it.Next());

		if (!mo)
		{
			console.printf("ERROR: Invalid SkyViewPointStatic TID.");
			return;
		}

		if (anchorid < 0 && mo.args[2] != 0) { anchorid = mo.args[2]; }

		if (anchorid > 0)
		{
			it = ActorIterator.Create(anchorid, "Actor");
			mo.anchor = it.Next();
			
			mo.anchoroffset = (0, 0);
		}

		mo.base = players[consoleplayer].camera;

		if (!mo.anchor)
		{
			mo.anchor = Spawn("SkyViewPointAnchor", players[consoleplayer].mo.pos); // Use player's position as a fallback anchor point if no anchor is in place
		}

		mo.heightoffset = mo.SpawnPoint.z - mo.anchor.pos.z - 17.25; // To match normal skybox offset height

		if ((mo.tid == 0 && level.sectorPortals[0].mSkybox == null) || mo.args[3] > 0)
		{
			level.sectorPortals[0].mSkybox = mo;
			level.sectorPortals[0].mDestination = mo.CurSector;
		}
	}

	override void PostBeginPlay()
	{
		// Set the scaling value according to whatever arg 1 value is passed
		scaling = args[1] == 0 ? 100 : args[1];

		// Save the spawn location vector for later
		SpawnPoint = pos;

		if (!tid) { ChangeTID(FindUniqueTID()); }

		SetAnchor(tid);
	}

	override void Tick()
	{
		Super.Tick();

		if (base && base.player && SpawnPoint != (0, 0, 0))
		{
			Vector2 offset = (base.pos.xy - anchor.pos.xy) / scaling;
			offset = RotateVector(offset, angle);

			// Set the viewpoint's height location
			double heightdelta = (base.player.viewz - anchor.pos.z) / scaling;

			heightdelta /= 2;

			Vector3 dest = (SpawnPoint.xy + offset - anchoroffset, SpawnPoint.z + heightdelta);
			double dist = (dest.xy - pos.xy).length();

			if (base.bTeleport || dist <= 32.0 || level.time < 5 || bStandStill)
			{
				SetXYZ(dest);
			}
			else
			{
				anchoroffset = (SpawnPoint.xy + offset) - pos.xy;
			}
		}
		else
		{
			SetAnchor(tid);
		}
	}
}

class SkyViewpointAnchor : MapSpot
{
	Default
	{
		//$Category Skyboxes (BoA)
		//$Title Skybox ViewPoint Anchor
		//$NotAngled
	}
}