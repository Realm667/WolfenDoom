//
//  Modified version of Nash's Tilt++ v1.5
//    https://forum.zdoom.org/viewtopic.php?f=43&t=55413
//
//===========================================================================
//
// Tilt++.pk3
//
// Unified player camera tilting for strafing, moving, swimming and death
//
// Written by Nash Muhandes
//
// Feel free to use this in your mods. You don't have to ask my permission!
//
//===========================================================================

// Heavily reworked by AFADoomer, though the guts still belong to Nash
// Level tilting addition by AFADoomer, with work by Talon1024

class BoATilt : CustomInventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
	}

	double strafeInput, strafeBuffer;
	double moveTiltOsc;
	double deathTiltOsc;
	double deathTiltAngle;
	double lastRoll;
	double lastLevelTilt;
	double lastPitch;

	double, double CalcLevelTilt()
	{
		//===========================================================================
		//
		// Level Tilting
		//
		//===========================================================================
		double curPitch = 0;
		double curLevelTilt = 0;

		if (owner && BoAPlayer(owner))
		{
			double leveltilt = BoAPlayer(owner).leveltilt;

			if (leveltilt != 0) // If the level is tilted
			{
				double leveltiltangle = BoAPlayer(owner).leveltiltangle;
				double offsetangle = deltaangle(leveltiltangle, owner.angle);

				curLevelTilt = sin(offsetangle) * leveltilt;

				// Level tilt pitch. Hopefully, this doesn't conflict with weapon recoil. - Talon1024
				curPitch = cos(offsetangle) * leveltilt;
			}
			else
			{
				lastPitch = 0;
				curLevelTilt = 0;
			}
		}

		return curPitch, curLevelTilt;
	}

	double CalcStrafeTilt()
	{
		//===========================================================================
		//
		// Strafe Tilting
		//
		//===========================================================================
		double strafeTiltSpeed = 1.0;
		double strafeTiltAngle = 0.5;
		double strafeTiltReversed = false;

		// normalized strafe input
		int dir;
		if (strafeTiltReversed) dir = -1;
		else dir = 1;
		strafeInput = strafeTiltSpeed * (owner.GetPlayerInput(INPUT_SIDEMOVE) / 10240.0);
		strafeInput *= strafeTiltAngle;
		strafeInput *= dir;

		return strafeInput;
	}

	double CalcMovementTilt()
	{
		//===========================================================================
		//
		// Movement Tilting
		//
		//===========================================================================
		double moveTiltScalar = 0.5;
		double moveTiltAngle = 0.015;
		double moveTiltSpeed = 15.0;

		double r = 0;

		// get player's velocity
		double v = owner.Vel.Length() * moveTiltScalar;

		// increment angle
		moveTiltOsc += moveTiltSpeed;

		// clamp angle
		if (moveTiltOsc >= 360. || moveTiltOsc < 0.)
		{
			moveTiltOsc = 0.;
		}

		// calculate roll
		r = Sin(moveTiltOsc);
		r *= moveTiltAngle;
		r *= v;

		return r;
	}

	double CalcDeathTilt()
	{
		//===========================================================================
		//
		// Death Tilting
		//
		//===========================================================================
		double r = 0;

		if (!(owner.Health > 0))
		{
			double deathTiltSpeed = 1.0;

			if (deathTiltAngle == 0)
			{
				// vary the angle a little
				deathTiltAngle = -90.f;
				deathTiltAngle += FRandom(-45.f, 45.f);
				deathTiltAngle *= RandomPick(-1, 1);
			}

			if (deathTiltOsc < 22.5)
			{
				deathTiltOsc += deathTiltSpeed;
			}

			r = Sin(deathTiltOsc);
			r *= deathTiltAngle;
		}
		else
		{
			deathTiltOsc = 0;
			deathTiltAngle = 0;
		}

		return r;
	}

	override void DoEffect(void)
	{
		if (!owner) { return; }

		double curLevelTilt = 0;

		// Level tilt processing is required for C3M5_C, so dont allow deactivating it
		if (BoAPlayer(owner) && BoAPlayer(owner).leveltilt) // But also only run this if the level tilt value is set!
		{
			double pitchoffset;
			[pitchoffset, curLevelTilt] = CalcLevelTilt();
			// A_SetViewPitch does not affect aim direction, so use A_SetPitch
			owner.A_SetPitch(owner.pitch + (pitchoffset - lastPitch), SPF_INTERPOLATE);
			lastPitch = pitchoffset;
		}

		// Call A_SetViewRoll here with the level tilt, so that it is only
		// called once, but allow all other effects to be disabled via their
		// respective CVars
		if (!boa_tilteffects)
		{
			owner.A_SetViewRoll(owner.viewroll + (curLevelTilt - lastLevelTilt), SPF_INTERPOLATE);
			lastLevelTilt = curLevelTilt;
			return;
		}

		double curRoll = 0;

		// If on the ground or on an object
		if ((owner.Pos.Z == owner.FloorZ || owner.bOnMObj) && owner.Health > 0)
		{
			if (boa_strafetilt) { curRoll += CalcStrafeTilt(); } // Do strafe tilt, if enabled
			curRoll += CalcMovementTilt(); // Do movement tilt
		}

		curRoll += CalcDeathTilt(); // Always check if we need to do death tilt

		if (abs(curRoll) > 0.000001) { curRoll *= 0.75; } // Stabilize tilt

		// Apply the sum of all rolling routines (including after stabilization)
		owner.A_SetViewRoll(owner.viewroll + (curRoll - lastRoll) + (curLevelTilt - lastLevelTilt), SPF_INTERPOLATE);
		lastLevelTilt = curLevelTilt;
		lastRoll = curRoll;
	}

	//===========================================================================
	//
	//
	//
	//===========================================================================
	States
	{
		Use:
			TNT1 A 0;
			Fail;
		Pickup:
			TNT1 A 0 { return true; }
			Stop;
	}
}