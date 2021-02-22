/*
 * Copyright (c) 2020 Talon1024, N00b
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

class DebugEventHandler : StaticEventHandler
{
	bool showvel;

	void ShowRemainingEnemies(class<Actor> base = "Base")
	{
		ThinkerIterator it = ThinkerIterator.Create(base);
		int count = 0;
		Actor mo;
		while( (mo = Actor(it.Next ())) )
		{
			if (!mo.CountsAsKill() || mo.Health <= 0 || mo.bDormant)
			{
				continue;
			}
			else
			{
				Console.Printf("%s at (%.3f, %.3f, %.3f)", mo.GetClassName(), mo.Pos);
				count += 1;
			}
		}
		Console.Printf("%d \"live\" enemies found", count);
	}

	void ShowRemainingTreasures(class<Actor> base = "Inventory")
	{
		ThinkerIterator it = ThinkerIterator.Create(base);
		int count = 0;
		Actor mo;
		while( (mo = Actor(it.Next ())) )
		{
			if (!mo.bCountItem || !mo.bSpecial || mo.bDormant)
			{
				continue;
			}
			else
			{
				Console.Printf("%s at (%.3f, %.3f, %.3f)", mo.GetClassName(), mo.Pos);
				count += 1;
			}
		}
		Console.Printf("%d treasure items found", count);
	}

	void ShowSkill()
	{
		Console.Printf("Skill: %d", skill);
	}

	void ShowSpeed()
	{
		showvel = !showvel;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		// netevent showliveenemies
		if (e.name ~== "showliveenemies")
		{
			ShowRemainingEnemies();
		}
		else if (e.name ~== "showtreasures")
		{
			ShowRemainingTreasures();
		}
		else if (e.name ~== "showskill")
		{
			ShowSkill();
		}
		else if (e.name ~== "showspeed")
		{
			ShowSpeed();
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		Actor player = players[consoleplayer].mo;
		if (showvel)
		{
			Screen.DrawText(smallfont, Font.CR_GRAY, 20.0, 20.0, String.Format("Speed: %.3f", player.Vel.Length()));
		}
	}
}