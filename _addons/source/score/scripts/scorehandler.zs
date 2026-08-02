class ScoreHandler : StaticEventHandler
{
    const bonusstep = 40000;

    ParsedValue scoredata, rewarddata;
    int BonusAmt[MAXPLAYERS];
    bool initialized;

    override void OnRegister()
    {
		ParsedValue data = FileReader.Parse("data/ScoreAmounts.txt");
        scoredata = data.Find("Enemies");
        rewarddata = data.Find("Rewards");
    }

    override void UITick()
    {
        if (!initialized)
        {
            let compass = Widget.Find("Compass");
            if (compass) { compass.priority = 2; }
            ScoreWidget.Init("Score", Widget.WDG_TOP | Widget.WDG_LEFT, 1);
        }
    }

    override void WorldThingDied (WorldEvent e)
    {
        color clr = "CC0000";

        let thing = e.Thing;
        let killer = e.Thing.target;

        if (thing && thing.Default.bCountKill && killer && killer.player)
        {
            if (!thing.bFriendly || (Nazi(thing) && Nazi(thing).user_sneakable))
            {
                int amt = GetScoreAmt(thing);
                thing = Actor.Spawn("ScorePosition", thing.Pos, NO_REPLACE);
                thing.target = killer;

                killer.score += amt;

                if (rewarddata && killer.score >= BonusAmt[killer.PlayerNumber()])
                {
                    if (BonusAmt[killer.PlayerNumber()] > 0)
                    {
                        if (GiveReward(killer, BonusAmt[killer.PlayerNumber()])) { clr = "CCAA00"; }
                    }

                    BonusAmt[killer.PlayerNumber()] += bonusstep;
                }

                thing.A_Face(killer);
                SpawnDigits(thing, amt, "ScoreNumber", clr);
            }
        }
    }

    int GetScoreAmt(Actor mo)
    {
        int score;
        
        if (scoredata) { score = FileReader.GetInt(scoredata, mo.GetClassName()); }
        if (!score) { score = max(100, mo.Default.health * 5); } // Fallback for enemies that aren't included in the score data list

        return score;
    }

    bool GiveReward(Actor mo, int amt)
    {
        ParsedValue rewards, reward;
        
        rewards = rewarddata.Find(String.Format("%i", amt)); // Try to find the reward associated with this point value
        if (!rewards) { rewards = rewarddata.Find("Default"); } // If there's not one, fall back to the default reward
        if (!rewards) { return false; } // If no default was set, return here

        mo.A_SetMugshotState("Grin");
        mo.A_StartSound("classic/life", CHAN_VOICE);

        while (reward = rewards.Next())
        {
            int dropamt = reward.value.ToInt();
            if (reward.keyname ~== "Health") { mo.GiveBody(dropamt); }
            else { Nazi.SpyGive(mo, reward.keyname, dropamt); }
        }

        return true;
    }

    void SpawnDigits(Actor origin, int number, Class<Actor> numactor, color clr)
	{
		int digits;
		int temp = number;

		double position;
		double width = 14 * 0.8;
        double velz = 0.8;
        double angle = origin.AngleTo(origin.target);

		while (temp)
		{
			digits++;
			temp /= 10;
		}

		position = width * digits / 2 - width / 2;

		for (int i = 0; i < digits; i++)
		{
			int digit = number % 10;

            Actor mo = Actor.Spawn(numactor, origin.pos + (Actor.RotateVector((0, -position), origin.angle + 180), 10));

			if (mo)
			{
				FlatNumber(mo).value = digit;
                mo.SetShade(clr);
                mo.master = origin;
                mo.vel.z = velz;
			}

			number /= 10;
			position -= width;
		}
	}
}

class ScoreWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		ScoreWidget wdg = ScoreWidget(Widget.Init("ScoreWidget", widgetname, anchor, WDG_DRAWFRAME, priority, pos, zindex));
	}

	override bool IsVisible()
	{
		if (
				BoAStatusBar(StatusBar) &&
                screenblocks < 12 &&
				!automapactive && 
				!player.mo.FindInventory("CutsceneEnabled") &&
				!(player.mo is "KeenPlayer")
			) { return true; }
		
		return false;
	}

	override Vector2 Draw()
	{
        String score;
        if (player.mo) { score = String.Format("%i", player.mo.score); }
        if (!score.length()) { score = "0"; }

        size = (max(BigFont.StringWidth(score), 64), BigFont.GetHeight());
        Super.Draw();

        DrawToHUD.DrawText(score, (pos.x + size.x, pos.y + 1), BigFont, alpha, 1.0, shade:Font.CR_GOLD, flags:ZScriptTools.STR_RIGHT);

		return size;
	}
}

// Workaround for sharks - See https://github.com/Realm667/WolfenDoom/issues/942
class ScorePosition : Actor
{
    Default
    {
        +NOINTERACTION
        +NOSECTOR
        +NOBLOCKMAP
    }

    States
    {
    Spawn:
        // 60 (Spawn) + 25 (Fade) + 1 just in case
        TNT1 A 86;
        Stop;
    }
}

class ScoreNumber : FlatNumber
{
    Default
    {
        +BRIGHT
        Alpha 1.0;
        StencilColor "CC0000";
        Scale 0.8;
    }

	States
	{
		Spawn:
			FNUM A 60;
        Fade:
            // 25 tics
            FNUM # 1 A_FadeOut(0.04, FTF_REMOVE);
			Loop;
	}

    override void Tick()
    {
		if (Level.IsFrozen()) { return; }

        if (master && master.target)
        {
            master.A_Face(master.target);
            angle = master.angle;
        }

        Super.Tick();

        offset.z += vel.z;
        Scale *= 1.0025;
    }
}