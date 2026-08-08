
class VampireBoAPlayer: BoAPlayer
{
	int tics_since_last_kill;
	
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		tics_since_last_kill = -350; //ten-second handicap at the level beginning
	}
	
	override void Tick()
	{
		if (health > 0 && !VampireHandler.VampireSpecialSequenceLevel())
		{
			if (!CountInv("RegenPowerup")) { ++tics_since_last_kill; }
			else { if (tics_since_last_kill >= 3) { tics_since_last_kill -= 3; } }
			if (tics_since_last_kill > 1050) //30 seconds
			{
				if (tics_since_last_kill % 64 == 0) { //2x slower than drowning
					A_DamageSelf(1 + (tics_since_last_kill / 64 - 16));
				}
			}
		}
		Super.Tick();
	}
}