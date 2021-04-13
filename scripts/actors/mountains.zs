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

class Mountains : Actor
{
	double leveltilt, leveltiltangle;
	double oldpitch, oldroll;
	Actor centerpoint;

	Default
	{
		//$Category Skyboxes (BoA)
		//$Title Snowy Mountains Skybox
		//$Arg0 "Centerpoint TID"
		//$Arg0Tooltip "TID of an actor to pivot the mountains around if the level is tilted."
		//$Arg0Default 0

		+NOINTERACTION
		Height 0;
		Radius 0;
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		SpawnPoint = pos;

		if (args[0] != 0)
		{
			ActorIterator it = ActorIterator.Create(args[0], "Actor");
			centerpoint = it.Next();
		}

		oldpitch = pitch;
		oldroll = roll;

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

		double angledelta = 0;

		if (centerpoint)
		{
			double dist = Distance2D(centerpoint);
			double relangle = AngleTo(centerpoint);
			double relpitch = sin(relangle) * pitch + cos(relangle) * roll;

			double zoffset = dist * tan(relpitch);

			// Adjust the z-height of the model to keep the centerpoint at the correct relative height
			SetOrigin((pos.x, pos.y, SpawnPoint.z + zoffset / 2), true);

			angledelta = deltaangle(angle, centerpoint.angle);
		}

		pitch = (leveltilt * sin(angledelta + leveltiltangle) / 2) + oldpitch / 2;
		roll = (leveltilt * cos(angledelta + leveltiltangle) / 2) + oldroll / 2;

		oldpitch = pitch;
		oldroll = roll;
	}
}