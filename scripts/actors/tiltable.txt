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

class Tiltable : Actor
{
	double leveltilt, oldtilt, leveltiltangle;
	double spawnheight;
	bool falling;
	Vector3 oldpos;
	double oldvel;

	Default
	{
		MaxStepHeight 0;
	}

	override void PostBeginPlay()
	{
		spawnheight = pos.z;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		if (globalfreeze || level.Frozen) { return; }

		for (int i = 0; i < MAXPLAYERS; i++)
		{
			PlayerPawn mo = players[i].mo;
			if (playeringame[i] && BoAPlayer(mo))
			{
				leveltilt = BoAPlayer(mo).leveltilt;
				leveltiltangle = BoAPlayer(mo).leveltiltangle;
				break;
			}
		}

		if (abs(leveltilt) >= min(mass, 1000) / 1000.0 * Random(20, 45)) // 45 degrees is the max for *not* sliding - so everything will slide at least some at this point
		{
			bNoGravity = leveltilt != 0;
			bSolid = True;

			double grav = level.gravity * CurSector.gravity * Gravity * 0.00125 * floorz == pos.z ? 100.0 / (min(Mass, 1000) * max(cos(leveltilt), 0.01)) : 1;

			vel.x -= grav * sin(leveltilt) * cos(leveltiltangle);
			vel.y -= grav * sin(leveltilt) * sin(leveltiltangle);
			vel.z -= grav * cos(leveltilt);

			if (leveltilt != oldtilt)
			{
				double abstilt = abs(leveltilt);
				double newradius = Default.radius * cos(abstilt) + Default.height / 2 * sin(abstilt);
				double newheight = Default.radius * sin(abstilt) + Default.height / 2 * cos(abstilt);

				if (height != newheight || radius != newradius) { A_SetSize(newradius, newheight, true); }

				oldtilt = leveltilt;
			}

			if (pos != oldpos)
			{
				angle += Random(-1, 1) * vel.Length();
			}

			if (abs(spawnheight - pos.z) >= 8) { falling = true; }

			if (
				health > 0 &&
				(
					(falling && pos.z == floorz) || 
					(pos == oldpos && vel.Length() != oldvel && vel.Length() > FRandom(1.0, 2.0) * 100 / min(Mass, 500))
				)
			)
			{
				DamageMobj(null, null, health, "none", DMG_FORCED);
			}

			oldpos = pos;
			oldvel = vel.Length();
		}
		else if (oldtilt != 0 && leveltilt == 0)
		{
			A_SetSize(Default.Radius, Default.Height);
			oldtilt = 0;
		}
	}
}