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

// Base class for actors which can be taken control of by enemies.
// E.g. Mechs, MG turrets, etc.
// This actor checks whether any "controller" is within range,
// and replaces the actor with the "replacement".
class ControllableBase : Actor
{
	String controllers;
	String replacements;

	Property Controllers: controllers;
	Property Replacements: replacements;

	Default
	{
		-COUNTKILL
	}

	States
	{
	Spawn:
		SMGS X 1;
	Active:
		"####" "#" 35 A_CheckReplace(64);
		Loop;
	Inactive:
		TNT1 A 0 A_Jump(256, "Spawn");
		Goto Spawn;
	}

	// Check whether a valid controller is within range, and replace the
	// controllable actor with the new one if so.
	void A_CheckReplace(double range)
	{
		BlockThingsIterator iter = BlockThingsIterator.Create(self, range, true);
		while (iter.Next())
		{
			if (abs(iter.thing.Pos.Z - Pos.Z) < range && CheckReplace(iter.thing))
			{
				return;
			}
		}
	}

	override void Touch(Actor toucher)
	{
		// Don't affect players!
		if (toucher.player)
		{
			return;
		}
		CheckReplace(toucher);
	}

	// Check whether the controller can control this actor, and replace it with
	// the new actor.
	bool CheckReplace(Actor toucher)
	{
		Array<String> controllerClasses;
		controllers.Split(controllerClasses, "|", TOK_SKIPEMPTY);
		Array<String> replacementClasses;
		replacements.Split(replacementClasses, "|", TOK_SKIPEMPTY);
		if (replacementClasses.Size() != controllerClasses.Size())
		{
			return false;
		}
		for (int i = 0; i < controllerClasses.Size(); i++)
		{
			class<Actor> controller = controllerClasses[i];
			class<Actor> replacement = replacementClasses[i];
			if (toucher.GetClass() == controller)
			{
				Actor replaced = Spawn(replacement, Pos, NO_REPLACE);
				toucher.CopyFriendliness(replaced, true, false);
				toucher.ClearCounters();
				toucher.Destroy();
				Destroy();
				return true;
			}
		}
		return false;
	}
}