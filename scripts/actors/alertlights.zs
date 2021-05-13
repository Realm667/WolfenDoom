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

/*

  Version of standard dynamic light that spawns a helper actor that sets the
  visibility variable of any player in proximity to the light, based on the
  distance that the payer is from the center of the light

  These lights automatically replace all point lights.

*/
class AlertPointLight : PointLight replaces PointLight
{
	override void PostBeginPlay()
	{
		if (!(SpawnFlags & MTF_DORMANT)) { SpawnLight(); }

		Super.PostBeginPlay();
	}

	override void Activate(Actor activator)
	{
		Super.Activate(activator);

		if (bDormant) { DestroyLight(); }
		else { SpawnLight(); }
	}

	override void Deactivate(Actor activator)
	{
		Super.Deactivate(activator);

		if (bDormant) { DestroyLight(); }
		else { SpawnLight(); }
	}

	void SpawnLight()
	{
		Actor mo = Spawn("AlertLight", pos);
		if (mo) { mo.master = self; }

		bDormant = false;
	}

	void DestroyLight()
	{
		A_RemoveChildren(TRUE, RMVF_MISC);

		bDormant = true;
	}
}

/*

  Helper actor that handles changing the player's visibility value based on
  how close the player is to the center of the light.

  By default, when spawned by the point light replacement above, which sets
  itself as master to the AlertLight, this actor automatically scales itself
  to match the dynamic light's radius, and uses the brightness of the dynamic
  light to scale the visibility value that it sets for the player.

  If placed directly in-editor, argument 0 is used to set the radius of the
  visibility increase (with a fall-back to 64 units if no value is provided),
  and the brightness of the light is assumed to be 100%.

  If spawned by an actor that sets itself as the AlertLight's tracer, the
  brightness of the light is scaled based on the alpha value of the tracer
  actor.  This is used in-game by the Volumetric Light actor.

*/
class AlertLight : Actor
{
	double checkRadius;
	double oldVisibility;
	bool hasmaster, wasculled;

	Default
	{
		//$Category Misc (BoA)
		//$Title Alert Light (stealth)
		//$Color 1
		DistanceCheck "boa_sfxlod";
		+INVISIBLE
		+NOGRAVITY
	}

	States
	{
		Spawn:
			UNKN A 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		if (master) {
			if (master.bDormant) { Destroy(); return; }

			hasmaster = true;
			checkRadius = master.args[3]; // If spawned and master is set, use parent's arg[3] as check radius
		} else {
			checkRadius = args[0]; // Otherwise, use the actor's arg[0]
		}
		if (!checkRadius) { checkRadius = 64; } // If nothing was set, use 64 map unit radius

		if (!wasculled) { EffectsManager.Add(self, checkRadius * 2, true); } // Spawn the actor back in at twice its radius
	}

	void A_AddVisibility(Actor lighttarget = null, int minlight = 0)
	{
		if (!lighttarget) { lighttarget = target; } // For backwards compatibility, just in case...

		if (lighttarget)
		{
			Inventory vis = lighttarget.FindInventory("BoAVisibility");
			if (vis)
			{
				double brightness = 1;
				if (tracer) { brightness = min(tracer.alpha * 1.5, 1.0); }
				if (master) { brightness = (master.args[0] + master.args[1] + master.args[2]) / (255. * 3) * 1.25; } // Calculate the light's overall brightness

				double amount = checkRadius * 2 - Distance3d(lighttarget) + 8 + minlight; // Calculate visibility based on how close the player is to the light

				amount *= brightness; // Adjust based on brightness level
				amount = max(amount, 0); // No negative visibility level

				oldVisibility = BoAVisibility(vis).extravisibility;
				BoAVisibility(vis).extravisibility  = int(oldvisibility + Max(amount - oldVisibility, 0)); // Set the new visibility - use delta in value instead of overriding so that multiple lights can be additive in visibility
			}
		}
	}

	override void Tick()
	{
		if (!CheckRange(checkRadius * 2, true))
		{
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				if (playeringame[i] && players[i].mo)
				{
					if (Distance3D(players[i].mo) < checkRadius * 2) { A_AddVisibility(players[i].mo); }
				}
			}

			if (hasmaster && !master) { Destroy(); }
		}

		Super.Tick();
	}
}

class SpotlightMount : Actor
{
	Actor light;
	int user_minAngle;
	int user_maxAngle;
	int user_position;
	int user_sightRange;
	int user_holdTime;
	int user_direction;

	Default
	{
		//$Category Hazards (BoA)
		//$Title Spotlight
		//$Color 3
		//$Arg0 "Left Swing Amount"
		//$Arg0Tooltip "Radius of turn to the left in degrees\nDefault: 0"
		//$Arg1 "Right Swing Amount"
		//$Arg1Tooltip "Radius of turn to the right in degrees\nDefault: 0"
		//$Arg2 "Script Number"
		//$Arg2Tooltip "Script to run when player enters range of spotlight\nDefault: 0"
		//$Arg3 "Script Argument 1"
		//$Arg3Tooltip "Argument to pass to script as argument 1\nDefault: 0"
		//$Arg4 "Script Argument 2"
		//$Arg4Tooltip "Argument to pass to script as argument 2\nDefault: 0"
		+DONTFALL
		+DONTTHRUST
		+NOBLOOD
		+SHOOTABLE
		+FLOORCLIP
		+DONTSPLASH
		+NOGRAVITY
		Health 100;
		Height 56;
		DistanceCheck "boa_scenelod";
	}

	States
	{
		Spawn:
			MDLA A Random(1, 35);
		SpawnLoop:
			MDLA A 1;
			Loop;
		Death:
			"####" B 0 {
				A_RemoveChildren(TRUE, RMVF_EVERYTHING);
				A_SpawnItemEx("Debris_GlassShard_Medium", 0, 0, 0, random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
				A_StartSound("GLASS5");
				A_SpawnProjectile("SparkB", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkW", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkW", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkO", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkO", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkO", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkO", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
				A_SpawnProjectile("SparkY", 0, 0, random(0,360), CMF_AIMDIRECTION|CMF_BADPITCH, random(-67,-113));
			}
			"####" B -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		if (pitch == 0 && args[0] == 0 && args[1] == 0)
		{
			pitch = 90;
			args[0] = 45;
			args[1] = 45;
		}

		user_minAngle = -args[1];
		user_maxAngle = args[0];
		user_position = 0;
		user_sightRange = 1024;
		user_direction = RandomPick(-1, 1);

		A_SpawnItemEx("SpotlightFlare", 5.0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
		A_SpawnItemEx("SpotlightBeam", 0, 0, 0, 0, 0, 0, 0, SXF_SETMASTER | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		if (health && bShootable)
		{
			if (args[0] != 0 && args[1] != 0) {
				if (user_position >= user_maxAngle || user_position <= user_minAngle) {
					user_holdTime++;
					if (user_holdTime >= 70) {
						user_holdTime = Random(0, 35);
						user_direction = -user_direction;
						user_position += user_direction;
						angle += user_direction;
					}
				} else {
					user_position += user_direction;
					angle += user_direction;
				}
			}
		}

		Super.Tick();
	}
}

class SpotlightFlare : SwitchableDecoration
{
	Default
	{
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		Height 16;
		Radius 16;
		Scale 0.5;
		RenderStyle "Add";
		DistanceCheck "boa_sfxlod";
	}

	States
	{
		Spawn:
			TNT1 A 0 NODELAY A_SetScale(2.0);
		Active:
			FLAR A 1 BRIGHT;
			TNT1 A 0 A_Warp(AAPTR_MASTER, cos(pitch) * 5.0, 0, sin(pitch) * 5.0, 0, WARPF_COPYPITCH);
			Loop;
		Inactive:
			TNT1 A -1;
			Loop;
	}
}

class SpotlightBeam : Actor
{
	Actor light;

	Default
	{
		+BRIGHT
		+NOBLOCKMAP
		+NOGRAVITY
		DistanceCheck "boa_sfxlod";
		RenderStyle "Add";
		Alpha 0.4;
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		if (!light)
		{
			light = Spawn("SpotlightBeamLight", pos);
			if (light) { light.master = self; }
		}

		if (master)
		{
			angle = master.angle;
			pitch = master.pitch;

			if (pos != master.pos) { SetOrigin(master.pos, true); }
		}

		Super.Tick();
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
	}

}

class SpotlightBeamLight : SpotLightAttenuated
{
	Actor mount;

	override void PostBeginPlay()
	{
		args[0] = 220;
		args[1] = 220;
		args[2] = 255;
		args[3] = 1024;

		spotinnerangle = 17;
		spotouterangle = 18;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (master)
		{
			angle = master.angle;
			pitch = master.pitch + (master is "SpotLightBeam" ? 90 : 0);

			if (master.master) { mount = master.master; }

			if (pos != master.pos) { SetOrigin(master.pos, true); }
		}
		else { Destroy(); }

		A_LookEx(LOF_NOSOUNDCHECK | LOF_DONTCHASEGOAL | LOF_NOSEESOUND | LOF_NOJUMP, 0, args[3], 0, spotouterangle * 2, null);

		if (target)
		{
			// SphericalCoords calculates the "spherical coordinates" from a 
			// point to another point. X is the yaw offset, Y is the pitch 
			// offset, and Z is the distance. It was added to GZDoom in response
			// to a feature request for a "PitchTo" function.
			// Calculate both feet and head positions
			Vector3 toFeet = Level.SphericalCoords(Pos, target.Pos, (angle, pitch));
			Vector3 headPos = target.Pos; headPos.Z += target.Height;
			Vector3 toHead = Level.SphericalCoords(Pos, headPos, (angle, pitch));
			// Get distance from spotlight to target's feet and head
			double feetDist = toFeet.x * toFeet.x + toFeet.y * toFeet.y;
			double headDist = toHead.x * toHead.x + toHead.y * toHead.y;
			double reldist = sqrt(min(feetDist, headDist));
			if (reldist < spotouterangle)
			{
				AddVisibility(reldist); // Do the visibility calculations and addition

				if (mount && mount.args[2]) { // Execute the script that is set on the spotlight base
					ACS_ExecuteAlways(mount.args[2], 0, mount.args[3], mount.args[4]);
				} else {
					A_AlertMonsters(1280); //Still fall back to alerting monsters if no script number supplied.
				}
			}
		}

		target = null;

		Super.Tick();
	}

	void AddVisibility(double amt, double max = 75)
	{
		if (target)
		{
			Inventory vis = target.FindInventory("BoAVisibility");
			if (vis)
			{
				double brightness = (args[0] + args[1] + args[2]) / (255. * 3) * 1.25; // Calculate the light's overall brightness

				double amount;

				if (spotinnerangle - amt < 0) // When in between inner and outer angles...
				{
					amount = spotouterangle - amt;
					amount = amount / max((spotouterangle - spotinnerangle), 1) * max; // Ramp up intensity proportionate to distance from inner angle edge
				}
				else { amount = max; } // Use full amount when located inside the center radius of the spotlight

				amount *= brightness; // Adjust based on brightness level

				amount = clamp(amount, 0, max); // Make sure the numbers are within the right range

				double oldVisibility = BoAVisibility(vis).extravisibility;
				BoAVisibility(vis).extravisibility  = int(oldvisibility + Max(amount - oldVisibility, 0)); // Set the new visibility - use delta in value instead of overriding so that multiple lights can be additive in visibility
			}
		}
	}
}

class SpotlightFlickerAdditiveBoA : SpotlightFlickerAdditive replaces SpotlightFlickerAdditive
{
	override void Tick()
	{
		if (!bDormant && CheckIfSeen()) // If not dormant and a player is in line of sight
		{
			for (int p = 0; p < MAXPLAYERS; p++) // Iterate through all of the players and see which ones are in sight
			{
				Actor mo = players[p].mo;

				if (mo && Distance2D(mo) <= args[4] * 2) // If they're in range, light them
				{
					DoVisibilityHandling(mo);

				}
			}
		}

		Super.Tick();
	}

	void AddVisibility(Actor target, double amt, double max = 75)
	{
		if (target)
		{
			Inventory vis = target.FindInventory("BoAVisibility");
			if (vis)
			{
				double brightness = (args[0] + args[1] + args[2]) / (255. * 3) * 1.25; // Calculate the light's overall brightness
				brightness *= FRandom(0.25, 0.5); // Fudge the brightness level due to flickering

				double amount;

				if (spotinnerangle - amt < 0) // When in between inner and outer angles...
				{
					amount = spotouterangle - amt;
					amount = amount / max((spotouterangle - spotinnerangle), 1) * max; // Ramp up intensity proportionate to distance from inner angle edge
				}
				else { amount = max; } // Use full amount when located inside the center radius of the spotlight

				amount *= brightness; // Adjust based on brightness level

				amount = clamp(amount, 0, max); // Make sure the numbers are within the right range

				double oldVisibility = BoAVisibility(vis).extravisibility;
				BoAVisibility(vis).extravisibility  = int(oldvisibility + Max(amount - oldVisibility, 0)); // Set the new visibility - use delta in value instead of overriding so that multiple lights can be additive in visibility
			}
		}
	}

	void DoVisibilityHandling(Actor target)
	{
		// Calculate both feet and head positions
		Vector3 toFeet = Level.SphericalCoords(Pos, target.Pos, (angle, pitch));
		Vector3 headPos = target.Pos; headPos.Z += target.Height;
		Vector3 toHead = Level.SphericalCoords(Pos, headPos, (angle, pitch));
		// Get distance from spotlight to target's feet and head
		double feetDist = toFeet.x * toFeet.x + toFeet.y * toFeet.y;
		double headDist = toHead.x * toHead.x + toHead.y * toHead.y;
		double reldist = sqrt(min(feetDist, headDist));

		if (reldist < spotouterangle)
		{
			AddVisibility(target, reldist); // Do the visibility calculations and addition. 
		}
	}
}

class StrobeEmitter : Actor
{
	Actor light1, light2;
	Color lightcolor;
	int range;
	transient FLineTraceData trace;
	EffectsManager manager;

	Property LightColor:lightcolor;
	Property Range:range;

	Default
	{
		//$Category Lights (BoA)
		//$Color 11

		Radius 16;
		Height 16;
		Speed 10;
		+DONTSPLASH
		+NOGRAVITY
		+SPAWNCEILING
		StrobeEmitter.LightColor 0xFFFFFF;
		StrobeEmitter.Range 1024.0;
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Inactive:
			"####" A -1;
			Stop;
		Active:
			"####" DCBA 4 Bright;
			Loop;
		SpriteList:
			STRB A 0;
			STRG A 0;
			STRR A 0;
			STRY A 0;
	}

	override void PostBeginPlay()
	{
		bDormant = true;

		CVar shadowmaps = CVar.FindCVar("gl_light_shadowmap");

		if (shadowmaps && shadowmaps.GetInt() == 0) // If shadowmaps are enabled, don't limit the range...  You still get slowdown, but only on initial light spawn
		{
			// Find the shortest distance to a wall, and use that as the light's max range (min of 128 units)
			for (int i = 0; i < 360; i += int(Speed))
			{
				LineTrace(i, range, 35, TRF_THRUACTORS | TRF_THRUBLOCK | TRF_THRUHITSCAN, 0.0, 0.0, 0.0, trace);
				if (trace.Distance > 128 && trace.Distance < range) { range = int(trace.Distance); }
			}
		}

		// Set the sprite based on the assigned light color
		String spr = "STR";

		// Basic filter only catches "pure" colors, but it's good enough to catch the colors used by our strobes...
		if (lightcolor.r)
		{
			if (lightcolor.g) { spr = spr .. "Y"; } // Yellow
			else if (lightcolor.b) { } // Purple, but we don't have a sprite for that
			else { spr = spr .. "R"; } // Red
		}
		else if (lightcolor.g)
		{
			if (lightcolor.b) { } // Cyan, but we don't have a sprite for that
			else { spr = spr .. "G"; } // Green
		}
		else
		{
			spr = spr .. "B"; // Blue
		}

		if (spr.length() < 4) { Destroy(); return; } // If sprite name wasn't completed by the filter, Destroy the light
		else
		{
			int s = GetSpriteIndex(spr); // Find the sprite and set it
			if (s) { sprite = s; }
		}

		manager = EffectsManager.GetManager();

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		if (globalfreeze || level.Frozen || bDormant) { return; }

		if (manager)
		{
			int interval;
			bool forceculled;

			[interval, forceculled] = manager.Culled(pos.xy);
			if (forceculled || interval > range * 1.5 / 512.0) { return; }
		}
		else if (CheckSightOrRange(range * 1.5)) { return; }

		// Spin the lights
		if (light1) { light1.angle += Speed; }
		if (light2) { light2.angle += Speed; }
	}

	override void Activate(Actor activator)
	{
		bDormant = false;
		SpawnLights();

		SetStateLabel("Active");
	}

	override void Deactivate(Actor activator)
	{
		bDormant = true;
		if (light1) { light1.Destroy(); }
		if (light2) { light2.Destroy(); }

		SetStateLabel("Inactive");
	}

	void SpawnLights()
	{
		while (!light1) { light1 = Spawn("SpotLightBoA", pos - (0, 0, height / 2)); }
		light1.master = self;
		light1.pitch = 35;
		DynamicLight(light1).spotinnerangle = 10;
		DynamicLight(light1).spotouterangle = 25;
		light1.args[DynamicLight.LIGHT_INTENSITY] = range;
		light1.args[DynamicLight.LIGHT_RED] = lightcolor.r;
		light1.args[DynamicLight.LIGHT_GREEN] = lightcolor.g;
		light1.args[DynamicLight.LIGHT_BLUE] = lightcolor.b;

		while (!light2) { light2 = Spawn("SpotLightBoA", pos - (0, 0, height / 2)); }
		light2.master = self;
		light2.angle += 180;
		light2.pitch = 35;
		DynamicLight(light2).spotinnerangle = 10;
		DynamicLight(light2).spotouterangle = 25;
		light2.args[DynamicLight.LIGHT_INTENSITY] = range;
		light2.args[DynamicLight.LIGHT_RED] = lightcolor.r;
		light2.args[DynamicLight.LIGHT_GREEN] = lightcolor.g;
		light2.args[DynamicLight.LIGHT_BLUE] = lightcolor.b;
	}
}

class StrobeEmitterBlue : StrobeEmitter
{
	Default
	{
		//$Title 2d Strobe Light (BLUE, SWITCHABLE)
		StrobeEmitter.LightColor 0x0000CC;
	}
}

class StrobeEmitterGreen : StrobeEmitter
{
	Default
	{
		//$Title 2d Strobe Light (GREEN, SWITCHABLE)
		StrobeEmitter.LightColor 0x00CC00;
	}
}

class StrobeEmitterRed : StrobeEmitter
{
	Default
	{
		//$Title 2d Strobe Light (RED, SWITCHABLE)
		StrobeEmitter.LightColor 0xCC0000;
	}
}

class StrobeEmitterYellow : StrobeEmitter
{
	Default
	{
		//$Title 2d Strobe Light (YELLOW, SWITCHABLE)
		StrobeEmitter.LightColor 0xCC6600;
	}
}

class SpotLightBoA : SpotLight
{
	override void Tick()
	{
		if (!master) { Destroy(); }

		Super.Tick();
	}
}