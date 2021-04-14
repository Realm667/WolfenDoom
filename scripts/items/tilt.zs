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
	double moveTiltOsc, underwaterTiltOsc;
	double deathTiltOsc;
	double deathTiltAngle;
	double lastRoll;
	double lastLevelTilt;
	double lastPitch;

	//===========================================================================
	//
	// Calculate and apply the combined tilt roll amount
	//
	//===========================================================================
	void Tilt_CalcViewRoll (void)
	{
		// CVARS ///////////////////////////////////////////////////////////////
		bool strafeTiltEnabled = boa_strafetilt;
		bool moveTiltEnabled = true;
		bool underwaterTiltEnabled = false;
		bool deathTiltEnabled = true;
		double strafeTiltSpeed = 1.0;
		double strafeTiltAngle = 0.5;
		double strafeTiltReversed = false;
		double moveTiltScalar = 0.5;
		double moveTiltAngle = 0.015;
		double moveTiltSpeed = 15.0;
		double underwaterTiltSpeed = 0.8;
		double underwaterTiltAngle = 0.2;
		double underwaterTiltScalar = 1.0;

		// Shared variables we'll need later
		double r, v;
		double curRoll = 0, curLevelTilt = 0;

		//===========================================================================
		//
		// Level Tilting
		//
		//===========================================================================

		if (owner && BoAPlayer(owner))
		{
			double leveltilt = BoAPlayer(owner).leveltilt;

			if (leveltilt != 0) // If the level is tilted
			{
				double leveltiltangle = BoAPlayer(owner).leveltiltangle;
				double offsetangle = deltaangle(leveltiltangle, owner.angle);

				curLevelTilt = sin(offsetangle) * leveltilt;

				// Level tilt pitch. Hopefully, this doesn't conflict with weapon recoil. - Talon1024
				double curPitch = cos(offsetangle) * leveltilt;
				Owner.A_SetPitch(Owner.pitch + (curPitch - lastPitch), SPF_INTERPOLATE);
				lastPitch = curPitch;
			}
			else
			{
				lastPitch = 0;
				curLevelTilt = 0;
			}
		}

		//===========================================================================
		//
		// Strafe Tilting
		//
		//===========================================================================

		// normalized strafe input
		if (strafeTiltEnabled && ((Owner.Pos.Z == Owner.FloorZ) || (Owner.bOnMObj)) && Owner.Health > 0)
		{
			int dir;
			if (strafeTiltReversed) dir = -1;
			else dir = 1;
			strafeInput = strafeTiltSpeed * (Owner.GetPlayerInput(INPUT_SIDEMOVE) / 10240.0);
			strafeInput *= strafeTiltAngle;
			strafeInput *= dir;
		}

		// tilt!
		curRoll += strafeInput;

		//===========================================================================
		//
		// Movement Tilting
		//
		//===========================================================================

		if (moveTiltEnabled && ((Owner.Pos.Z == Owner.FloorZ) || (Owner.bOnMObj)) && Owner.Health > 0)
		{
			// get player's velocity
			v = Owner.Vel.Length() * moveTiltScalar;

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
		}

		// tilt!
		curRoll += r;

		//===========================================================================
		//
		// Underwater Tilting
		//
		//===========================================================================

		if (Owner.WaterLevel >= 3 && underwaterTiltEnabled)
		{
			// fixed rate of 15
			v = 15. * underwaterTiltScalar;

			// increment angle
			underwaterTiltOsc += underwaterTiltSpeed;

			// clamp angle
			if (underwaterTiltOsc >= 360. || underwaterTiltOsc < 0.)
			{
				underwaterTiltOsc = 0.;
			}

			// calculate roll
			r = Sin(underwaterTiltOsc);
			r *= underwaterTiltAngle;
			r *= v;
		}

		// tilt!
		curRoll += r;

		//===========================================================================
		//
		// Death Tilting
		//
		//===========================================================================

		if (!(Owner.Health > 0) && deathTiltEnabled)
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

		// tilt!
		curRoll += r;

		//===========================================================================
		//
		// Tilt Post Processing
		//
		//===========================================================================

		if (abs(curRoll) > 0.000001)
		{
			// Stabilize tilt
			curRoll *= 0.75;
		}

		// Apply the sum of all rolling routines
		// (including after stabilization)
		Owner.A_SetRoll(Owner.Roll + (curRoll - lastRoll) + (curLevelTilt - lastLevelTilt), SPF_INTERPOLATE);
		lastLevelTilt = curLevelTilt;
		lastRoll = curRoll;
	}

	override void Tick(void)
	{
		if (Owner && Owner is "PlayerPawn")
		{
			Tilt_CalcViewRoll();
		}

		Super.Tick();
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
		TNT1 A 0
		{
			return true;
		}
		Stop;
	}
}