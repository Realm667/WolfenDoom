class UnderwaterPlant1: Actor
{
	Default
	{
	//$Category Props (BoA)/Underwater
	//$Title Underwater Seaweed (long)
	//$Color 3
	Radius 8;
	Height 96;
	}
	States
	{
	Spawn:
		UWPL A -1;
		Stop;
	}
}

class UnderwaterPlant2 : UnderwaterPlant1
{
	Default
	{
	//$Title Underwater Seaweed (small)
	Height 32;
	}
	States
	{
	Spawn:
		UWPL B -1;
		Stop;
	}
}

class UnderwaterPlant3 : UnderwaterPlant2
{
	Default
	{
	//$Title Underwater Seaweed (thin)
	}
	States
	{
	Spawn:
		UWPL C -1;
		Stop;
	}
}