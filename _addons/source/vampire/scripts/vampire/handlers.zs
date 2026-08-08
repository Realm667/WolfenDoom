class VampireHandler: EventHandler
{
	override void WorldThingDied (WorldEvent e)
	{
		if (e.Thing.bISMONSTER && e.Thing.bCOUNTKILL)
		{
			VampireBoAPlayer killer = VampireBoAPlayer(e.Thing.target);
			if (killer && killer.health > 0) {
				if (killer.tics_since_last_kill > 1050) killer.tics_since_last_kill = 875; //2x bonus
				if (e.Thing is 'WereWaffenSS')
				{
					killer.tics_since_last_kill = 0; //reset
				}
				else if (e.Thing is 'Rottweiler' || e.Thing is 'GermanShepherd' || e.Thing is 'Doberman') //werewolf dogs
				{
					killer.tics_since_last_kill -= 350; //10 seconds
				}
				else killer.tics_since_last_kill -= 175; //5 seconds
				if (killer.tics_since_last_kill < 0) killer.tics_since_last_kill = 0;
			}
		}
	}
	clearscope static bool VampireSpecialSequenceLevel() {
		return level.levelnum == 99 || level.levelname == "TITLEMAP" || level.levelnum == 400 ||
			level.levelname == "CREDITSM" || level.levelname.IndexOf("CUTSCEN") != -1 || level.levelnum == 104 || (level.levelnum >= 151 && level.levelnum <= 153);
	}
	override void CheckReplacement(ReplaceEvent e)
	{
		if (e.Replacee is 'WaffenSS') {
			e.Replacement = 'WereWaffenSS';
		}
	}
}