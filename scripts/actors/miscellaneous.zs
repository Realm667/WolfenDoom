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

class InvisibleBridgeBlocking : InvisibleBridge replaces InvisibleBridge
{
	Default
	{
		+DONTTHRUST
		+NOBLOOD
		+NODAMAGE
		+NOTAUTOAIMED
		+SHOOTABLE
	}
}

class ModelOpelTruckWindows : Actor
{
	Default
	{
		+NOINTERACTION
		Height 56;
		DistanceCheck "boa_scenelod";	
		RenderStyle "Shaded";
		StencilColor "CC CC CC";
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}

	override void BeginPlay()
	{
		// STATNUM values set the order in which an actor is Ticked by the game loop.
		//  This change causes this actor to Tick *after* the pathfollower moves and
		//  the rail script has adjusted the truck model, instead of before the
		//  script runs, as would be the default behavior.
		ChangeStatNum(STAT_SCRIPTS + 1);
	}

	override void Tick()
	{
		if (master)
		{
			A_Warp(AAPTR_MASTER, flags:WARPF_COPYPITCH | WARPF_COPYINTERPOLATION | WARPF_NOCHECKPOSITION);
		}
		Super.Tick();
	}
}

class CrankModel : Actor
{
	int init, amt;

	Default
	{
		+NOGRAVITY
		Height 0;
		Radius 0;
	}

	States
	{
		Spawn:
			MDLA A 35;
		SpawnLoop:
			MDLA B 1 A_DoCrank();
			Loop;
	}

	void A_DoCrank()
	{
		if (!init) { init = amt; }
		roll = amt - init;
	}
}

class FlattenableProp : GrassBase // Tall grass/rye, etc. that can be trampled down
{
	int touchtime;
	int fallpitch;

	Default
	{
		+NOBLOOD
		+NODAMAGE
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		+SPECIAL
	}

	override void PostBeginPlay()
	{
		A_SetSize(Radius, 1);

		Super.PostBeginPlay();
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		Touch(inflictor);

		return 0; // No actual damage to the actor
	}

	override void Touch(Actor toucher)
	{
		if (!toucher) { return; }

		touchtime++;
		bFlatSprite = true;

		if (touchtime < 5) { angle = AngleTo(toucher) + 180; }
		if (!fallpitch) { fallpitch = Random(70, 85); }

		pitch = clamp(-fallpitch + touchtime * 15, -fallpitch, 0);

		if (pitch == -fallpitch)
		{
			bSpecial = false;
			bSolid = false;
			bShootable = false;
		}
	}
}

class ActorPositionable : Base
{
	enum RotationFlags
	{
		ROT_MatchAngle = 1,
		ROT_MatchPitch = 2,
		ROT_MatchRoll = 4,
	};

	Default
	{
		-CASTSPRITESHADOW
	}

	Vector3 spawnoffset;
	Vector3 offset;

	override void PostBeginPlay()
	{
		if (!master) { Destroy(); return; }

		spawnoffset = pos - master.pos;

		Vector2 temp = RotateVector((spawnoffset.x, spawnoffset.y), -master.angle);
		spawnoffset = (temp.x, temp.y, spawnoffset.z);

		Species = master.Species;

		Super.PostBeginPlay();
	}

	void RotateWithMaster(int flags = ROT_MatchAngle | ROT_MatchPitch | ROT_MatchRoll)
	{
		Vector2 temp;

		// Keep the actor in the correct position, regardless of pitch/roll of the master actor
		if (master)
		{
			if (spawnoffset != (0, 0, 0))
			{
				temp = RotateVector((spawnoffset.y, spawnoffset.z), master.roll);
				offset = (spawnoffset.x, temp.x, temp.y);

				temp = RotateVector((offset.x, offset.z), 360 - master.pitch);
				offset = (temp.x, offset.y, temp.y);

				temp = RotateVector((offset.x, offset.y), master.angle);
				offset = (temp.x, temp.y, offset.z);
			}

			SetOrigin(master.pos + offset, true);

			if (flags & ROT_MatchAngle) { angle = master.angle; }

			double delta = deltaangle(master.angle, angle);

			if (flags & ROT_MatchPitch) { pitch = master.roll * sin(-delta) + master.pitch * cos(delta); }
			if (flags & ROT_MatchRoll) { roll = master.roll * cos(-delta) + master.pitch * sin(delta); }
		}
	}

	override void Tick()
	{
		RotateWithMaster();

		Super.Tick();
	}
}

class StaticActor : Actor
{
	bool nostatic;

	Property NoStatic:nostatic;

	Default
	{
		StaticActor.NoStatic false;
	}

	override void Tick()
	{
		Super.Tick();

		// If the actor stops animating (tics of -1) and isn't shootable or alive and moving, then stop ticking the actor.
		if (
			!nostatic &&
			tics == -1 && 
			(
				!bShootable ||
				health <= 0
			) && 
			vel == (0, 0, 0) &&
			(
				bNoGravity ||
				pos.z == floorz
			)
		)
		{
			ChangeStatNum(STAT_FIRST_THINKING - 1);
		}
	}
}

// Actor that does the bare minumum of ticking
// Use for static, non-interactive actors
//
// Derived from bits and pieces of p_mobj.cpp
class SimpleActor : Actor
{
	Vector2 floorxy;
	Vector3 oldpos;

	override void Tick()
	{
		if (IsFrozen()) { return; }

		Vector2 curfloorxy = (curSector.GetXOffset(sector.floor), curSector.GetYOffset(sector.floor)); // Hacky scroll check because MF8_INSCROLLSEC not externalized to ZScript?
		bool dotick = (curfloorxy != floorxy) || curSector.flags & sector.SECF_PUSH || (pos != oldpos);

		if (dotick) // Only run a full Tick once; or if we are on a carrying floor, pushers are enabled in the sector (wind), or if we moved by some external force
		{
			oldpos = pos;
			Super.Tick();
			floorxy = curfloorxy;
			return;
		}

		if (vel != (0, 0, 0)) // Apply velocity as required
		{
			SetXYZ(Vec3Offset(vel.X, vel.Y, vel.Z)); // Vec3Offset is portal-aware; use instead of just pos + vel, which is not
		}

		// Tick through actor states as normal
		if (tics == -1) { return; }
		else if (--tics <= 0)
		{
			SetState(CurState.NextState);
		}
	}
}

class AscherParachuting : Actor
{
	Default
	{
		+NOINTERACTION;
		+NOGRAVITY;
		+FLOATBOB;
		FloatBobStrength 0.25;
		Scale 0.5;
	}

	States
	{
		Spawn:
			ASCP A -1;
			Stop;
	}
}

class MineCartEMoving : ModelBase
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Mine Cart, Empty (for movement sequence)
		//$Color 3

		+CANPASS
		+DONTTHRUST
		-FLOORCLIP
		+NOBLOOD
		+NOBLOODDECALS
		+NODAMAGE
		+NOGRAVITY
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
		+CullActorBase.DONTCULL

		DistanceCheck "boa_scenelod";
		Radius 34;
		Height 24;
		Health -1;
		Speed 0;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		double amt = (speed ? speed : vel.length()); // C1M6's ACS rail script sets speed variable to movement speed of cart

		if (amt && other.bShootable && !other.player && !PlayerPawn(other))
		{
			target = other;
			A_DamageTarget(0x7FFFFFFF, "Trample");
			A_StartSound("cartstop", CHAN_VOICE, 0, amt);
		}

		return true;
	}
}

// Actor that passes damage through to its master, if one is set
class Appendage : Actor
{
	Actor body;

	override void PostBeginPlay()
	{
		body = self;
		while (body && body.master) { body = body.master; }

		if (body != self)
		{
			CopyBloodColor(body);
			bNoBlood = body.bNoBlood;
			bNoBloodDecals = body.bNoBloodDecals;
		}
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		// Co-opt the main actor's poison start time to store the time that the last appendage damage happened
		// so that we can't kill enemies with a single explosion that affects dozens of appendage/cloud actors
		if (body && (body.PoisonPeriodReceived < level.time || (body.Poisoner && body.Poisoner != inflictor)))
		{
			body.PoisonPeriodReceived = level.time;
			body.Poisoner = inflictor;
			body.DamageMobj(inflictor, source, damage, mod, flags, angle);
		}

		return 0;
	}
}

class ScreenLabel : SimpleActor
{
	String user_text, user_icon;

	Default
	{
		//$Category Misc (BoA)
		//$Title Screen Label
		//$Arg0 Use user_text and user_icon
		+INVISIBLE
		+NOINTERACTION
		Height 0;
		Radius 0;
	}

	States
	{
		Spawn:
			AMRK A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		ScreenLabelHandler handler = ScreenLabelHandler(EventHandler.Find("ScreenLabelHandler"));
		if (!handler) { return; }

		handler.AddItem(self, user_icon, user_text, 0xFFFFFF, 0.8);
	}
}