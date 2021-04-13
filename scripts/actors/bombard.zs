/*
 * Copyright (c) 2020 Talon1024
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

// Bombardment shot - C1M3
class BombardShot : Actor
{
	Sound flybySound;
	int flybyTics;

	Default
	{
		Projectile;
		Damage 0;
		Speed 40;
		ReactionTime 0;
		Gravity 0.125;
		-NOGRAVITY
	}

	States
	{
	Spawn:
		TRGN A 1 {
			A_SpawnItemEx("BodySmoke");
			reactiontime -= 1;
			if (reactiontime == flybyTics)
			{
				A_StartSound(flybySound, attenuation: 0.5);
			}
		}
		Loop;
	Crash:
	Death:
		TNT1 A 0 {
			A_StartSound("panzer/explode");
			A_SpawnItemEx("GeneralExplosion_Medium");
		}
		Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		static const Sound sounds[] = { "EXPLOSION_LEADIN01", "EXPLOSION_LEADIN02", "EXPLOSION_LEADIN03", "EXPLOSION_LEADIN04" };
		flybySound = sounds[Random(0, 3)];
		flybyTics = int(ceil(S_GetLength(flybySound) * TICRATE));
	}

	static Actor Fire(Vector3 origin, Vector3 target, int forceTime = 0)
	{
		Actor shot = Spawn("BombardShot", origin, ALLOW_REPLACE);
		double speed = Actor.GetDefaultSpeed("BombardShot");
		Vector2 posDiff = Level.Vec2Diff(origin.XY, target.XY);
		double distance = posDiff.Length();
		double time = forceTime;
		if (forceTime > 0)
		{
			speed = distance / forceTime;
			shot.reactiontime = forceTime;
		}
		else
		{
			time = distance / speed;
			shot.reactiontime = int(floor(time));
		}
		shot.Angle = atan2(posDiff.Y, posDiff.X);
		double gravity = shot.GetGravity();
		double heightDiff = target.Z - origin.Z;
		shot.VelFromAngle(speed, shot.Angle);
		shot.Vel.Z = ZScriptTools.ArcZVel(time, gravity, heightDiff);
		return shot;
	}

	// Another wrapper for Fire function, taking a shooter TID and target TID,
	// and also a bitfield containing information about whether the shooter or
	// the target should be random
	static void FireFrom(int tid, int targettid, int flags = 0, int forceTime = 0)
	{
		Array<Actor> origins;
		Array<Actor> targets;
		ActorIterator originIter = Level.CreateActorIterator(tid);
		ActorIterator targetIter = Level.CreateActorIterator(targettid);
		Actor origin = null;
		Actor target = null;
		int bitIndexRandomOrigin = 0;
		int bitIndexRandomTarget = 1;
		int bitIndexAllOrigins = 2;
		int bitIndexAllTargets = 3;
		// Random origin or not?
		if (ZScriptTools.BitIsSet(flags, bitIndexRandomOrigin) || ZScriptTools.BitIsSet(flags, bitIndexAllOrigins))
		{
			origin = originIter.Next();
			while (origin != null)
			{
				origins.Push(origin);
				origin = originIter.Next();
			}
			origin = origins[Random(0, origins.Size() - 1)];
		}
		else
		{
			origin = originIter.Next();
		}
		// Random target or not?
		if (ZScriptTools.BitIsSet(flags, bitIndexRandomTarget) || ZScriptTools.BitIsSet(flags, bitIndexAllTargets))
		{
			target = targetIter.Next();
			while (target != null)
			{
				targets.Push(target);
				target = targetIter.Next();
			}
			target = targets[Random(0, targets.Size() - 1)];
		}
		else
		{
			target = targetIter.Next();
		}
		double forceSpeed = 0;
		if (ZScriptTools.BitIsSet(flags, bitIndexAllTargets) && ZScriptTools.BitIsSet(flags, bitIndexAllOrigins))
		{
			int largerSize = origins.Size();
			int smallerSize = targets.Size();
			int largerArray = 0;
			if (targets.Size() > origins.Size())
			{
				largerSize = targets.Size();
				smallerSize = origins.Size();
				largerArray = 1;
			}
			for(int i = 0; i < largerSize; i++)
			{
				// Pick a random value from the smaller array, and iterate normally through the larger array
				if (largerArray)
				{
					// targets > origins
					origin = origins[i < smallerSize ? i : Random(0, smallerSize - 1)];
					target = targets[i];
				}
				else
				{
					// origins > targets
					origin = origins[i];
					target = targets[i < smallerSize ? i : Random(0, smallerSize - 1)];
				}
				BombardShot.Fire(origin.Pos, target.Pos, forceTime);
			}
		}
		else if (ZScriptTools.BitIsSet(flags, bitIndexAllTargets))
		{
			// All targets, single origin
			for (int i = 0; i < targets.Size(); i++)
			{
				target = targets[i];
				BombardShot.Fire(origin.Pos, target.Pos, forceTime);
			}
		}
		else if (ZScriptTools.BitIsSet(flags, bitIndexAllOrigins))
		{
			// All origins, single target
			for (int i = 0; i < origins.Size(); i++)
			{
				origin = origins[i];
				BombardShot.Fire(origin.Pos, target.Pos, forceTime);
			}
		}
		else
		{
			BombardShot.Fire(origin.Pos, target.Pos, forceTime);
		}
	}
}