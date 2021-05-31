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
	bool showlightlevel;

	void ShowRemainingEnemies(class<Actor> base = "Base")
	{
		ThinkerIterator it = ThinkerIterator.Create(base);
		int count = 0;
		Actor mo;
		while( (mo = Actor(it.Next ())) )
		{
			if (!(mo.CountsAsKill() || (Nazi(mo) && Nazi(mo).user_sneakable)) || mo.Health <= 0 || mo.bDormant)
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

	protected String FormatLevelData(LevelData ld)
	{
		String info = String.Format("%s (%s, level %d)\n", ld.levelname, ld.mapname, ld.levelnum);
		info.AppendFormat("Kills: %d/%d, Items: %d/%d, Secrets: %d/%d, Time: %d tics\n", ld.killcount, ld.totalkills, ld.itemcount, ld.totalitems, ld.secretcount, ld.totalsecrets, ld.leveltime);
		return info;
	}

	void ShowStatsText()
	{
		PersistentMapStatsHandler pstats = PersistentMapStatsHandler(EventHandler.Find("PersistentMapStatsHandler"));
		MapStatsHandler stats = MapStatsHandler(StaticEventHandler.Find("MapStatsHandler"));
		if (!stats || !pstats) { return; }
		Console.Printf("From MapStatsHandler:");
		String Levels = "";
		for (int i = 0; i < stats.Levels.Size(); i++)
		{
			Levels = Levels .. FormatLevelData(stats.Levels[i]);
		}
		Console.Printf(Levels);
		String SpecialItemPickups = "";
		for (int i = 0; i < stats.SpecialItemPickups.Size(); i++)
		{
			SpecialItemPickups.AppendFormat("%s ", stats.SpecialItemPickups[i]);
		}
		Console.Printf("SpecialItemPickups: %s", SpecialItemPickups);
		Console.Printf("============================================");
		Console.Printf("From PersistentMapStatsHandler:");
		Levels = "";
		for (int i = 0; i < pstats.Levels.Size(); i++)
		{
			Levels = Levels .. FormatLevelData(pstats.Levels[i]);
		}
		Console.Printf(Levels);
		SpecialItemPickups = "";
		for (int i = 0; i < pstats.SpecialItemPickups.Size(); i++)
		{
			SpecialItemPickups.AppendFormat("%s ", pstats.SpecialItemPickups[i]);
		}
		Console.Printf("SpecialItemPickups: %s", SpecialItemPickups);
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
			Console.Printf("Skill: %d", skill);
		}
		else if (e.name ~== "showspeed")
		{
			showvel = !showvel;
		}
		else if (e.name ~== "showlightlevel")
		{
			showlightlevel = !showlightlevel;
		}
		else if (e.name ~== "showstats")
		{
			ShowStatsText();
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		Actor player = players[consoleplayer].mo;
		double y = 20.0;
		if (showvel)
		{
			Screen.DrawText(smallfont, Font.CR_GRAY, 20.0, y, String.Format("Speed: %.3f", player.Vel.Length()));
			y += 20;
		}
		if (showlightlevel)
		{
			int lightlevel;
			double fogfactor;
			[lightlevel, fogfactor] = ZScriptTools.GetLightLevel(player.CurSector);
			Screen.DrawText(smallfont, Font.CR_GRAY, 20.0, y, String.Format("Light level: %d %.3f", lightlevel, fogfactor));
			y += 20;
		}
	}
}