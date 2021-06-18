/*
 * Copyright (c) 2020 Daniel Gimmer, AFADoomer
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

class Boulder : Actor
{
	Vector3 oldpos;
	int flags;
	BoAMatrix4 matrix;
	double x, y, z;

	FlagDef HUGGER:flags, 0;

	Default
	{
		BounceFactor 0.9;
		DeathSound "boulder/stop";
		Damage 250;
		Gravity 1.5;
		Height 48;
		Mass 500;
		Obituary "$BOULDER";
		Radius 24;
		Speed 10;
		PushFactor 0.5;
		+BOUNCEONFLOORS
		+DONTRIP
		+DROPOFF
		+MISSILE
		+NOBOUNCESOUND
		+NODAMAGETHRUST
		+NOEXTREMEDEATH
		+RIPPER
		+SOLID
	}

	States
	{
		Spawn:
			MDLA A 1;
		Roll:
			"####" "#" 2;
			Loop;
		Death:
			"####" "#" 2 {
				// If an actor falls onto an instant-death floor, scale it down to simulate falling into the abyss, and then remove it
				if (pos.z <= curSector.floorplane.ZatPoint(pos.xy) && curSector.damagetype == "InstantDeath")
				{
					scale *= 0.95;
					A_SetSize(Default.Radius * scale.x, Default.Height * scale.y);

					if (scale.x < 0.05) { Destroy(); }
				}

				A_StopSound(CHAN_5);

				bPushable = true;
				bSolid = true;
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		matrix = BoAMatrix4.fromEulerAngles(0, pitch, roll);

		if (bHugger)
		{
			bFloorHugger = true;
			bDontRip = false;
			bNoBounceSound = false;
			bSolid = false;
			bActivateImpact = true;
			bActivatePCross = true;
			A_ChangeLinkFlags(false);
		}

		pushfactor /= Mass / 200;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		oldpos = pos;

		Super.Tick();

		angle = 0;

		if (IsFrozen()) { return; }

		double minvel = Mass * GetGravity() / 1000;

		Vector3 relpos = pos - oldpos;

		if (!vel.length()) { vel = relpos; } // Allow pushing from a full stop to increase velocity

		// Handle object rotation
		if (pos.z == floorz)
		{
			Vector3 normal = curSector.floorplane.Normal;

			// Get the "downhill" vector - https://stackoverflow.com/questions/14369233/finding-the-downhill-direction-vector-when-given-a-plane-defined-by-a-normal-and
			Vector3 gradient;
			gradient.x = normal.x * normal.z;
			gradient.y = normal.y * normal.z;
			gradient.z = (normal.x * normal.x) + (normal.y * normal.y);

			if (bHugger && vel.length()) { vel = vel.Unit() * Speed; }
			else 
			{
				// Give the boulder velocity based on downhill slope (up to max speed)
				if (vel.length() < Speed) { vel += gradient * Speed * GetGravity(); }
				if (vel.length() > Speed) { vel = vel.Unit() * Speed; }
			}

			Vector3 forward = vel cross normal;

			double circ = 2 * 3.14159265359 * Radius;
			double rotdist = 360 * relpos.length() / circ; // Base rotation on actual movement distance in the last tick.

			matrix = matrix.rotate(forward.Unit(), rotdist);
			[x, y, z] = matrix.rotationToEulerAngles();
		}

		if (vel.xy.length() > minvel)
		{
			if (pos.z == floorz || bOnMobj)
			{
				double amt = clamp((relpos.length() - minvel) / Speed, 0, 1);

				A_StartSound("boulder/roll", CHAN_5, CHANF_LOOPING | CHANF_NOSTOP, amt);
				A_SoundVolume(CHAN_5, amt);

				if (tics == 2) { A_Quake(1, 2, 0, int(192 * amt), ""); }
			}
			else
			{
				A_SoundVolume(CHAN_5, 0);

				double deltaz = pos.z - floorz;
				if (bHugger && deltaz > 96.0)
				{
					vel.xy /= max(1.0, deltaz / 64.0); // Simulate massive air friction over dropoffs for floor huggers...
				}
			}

			if (vel.length() > 5.0)
			{
				SetDamage(Default.damage);
				bRipper = Default.bRipper;
			}

			if (!InStateSequence(CurState, FindState("Roll"))) { SetStateLabel("Roll"); }

			// Apply new rotation, or continue existing rotation while in air
			angle = Normalize180(angle + x);
			pitch = Normalize180(pitch - y);
			roll = Normalize180(roll - z);
		}
		else
		{
			vel.xy *= 0;

			if (pos.z == floorz && !InStateSequence(CurState, FindState("Death")))
			{
				SetDamage(0);
				bRipper = false;
				bSolid = true;
				bHugger = false;

				A_StopSound(CHAN_5);

				if (curSector.damagetype != "InstantDeath") { A_StartSound("Boulder/Stop"); }

				SetStateLabel("Death");
			}
			else if (pos.z > floorz) { vel.z = -Speed * GetGravity(); }
		}
	}
}

class BoulderGray : Boulder {}

class BoulderSpawner : SwitchableDecoration
{
	class<Boulder> boulderclass;
	int flags;

	FlagDef HUGGER:flags, 0;
	FlagDef ACTIVATED:flags, 1;

	Property BoulderClass:boulderclass;

	Default
	{
		//$Category Hazards (BoA)
		//$Color 3
		Radius 24;
		Height 48;
		+SOLID
		Obituary "$BOULDER";
	}

	States
	{
		Spawn:
		Inactive:
			MDLA A -1;
			Stop;
		Active:
			TNT1 A 1 {
				if (!bActivated) // Only spawn a boulder on first activation
				{
					bool spawned;
					Actor mo;

					[spawned, mo] = A_SpawnItemEx(boulderclass, 0, 0, 0, 10);
					if (Boulder(mo)) { Boulder(mo).bHugger = bHugger; }

					bActivated = true;
					bSolid = false;
				}
			}
			TNT1 A -1; // Keep the actor around so that the boulder crush obituary will work properly
			Stop;
	}
}

class BoulderStartGrey : BoulderSpawner
{
	Default
	{
		//$Title Boulder grey (bounce, inactive)
		BoulderSpawner.BoulderClass "BoulderGray";
	}
}

class BoulderStartGreyHugger : BoulderSpawner
{
	Default
	{
		//$Title Boulder grey (hugger, inactive)
		BoulderSpawner.BoulderClass "BoulderGray";
		+BoulderSpawner.HUGGER;
	}
}

class BoulderStartBrown : BoulderSpawner
{
	Default
	{
		//$Title Boulder brown (bounce, inactive)
		BoulderSpawner.BoulderClass "Boulder";
	}
}

class BoulderStartBrownHugger : BoulderSpawner
{
	Default
	{
		//$Title Boulder brown (hugger, inactive)
		BoulderSpawner.BoulderClass "Boulder";
		+BoulderSpawner.HUGGER;
	}
}