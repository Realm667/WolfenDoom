class RadioactiveBarrel : Obstacle3d //3d actor
{
	Default
	{
	//$Category Props (BoA)/Industrial
	//$Title Radioactive Barrel
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 16;
	Height 43;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class RadioactiveBarrel2 : RadioactiveBarrel //3d actor
{
	Default
	{
	//$Title Radioactive Barrel, stackable
	+NOGRAVITY
	}
}

class Crane: Actor //3d actor
{
	Default
	{
	//$Category Props (BoA)/Industrial
	//$Title Crane
	//$Color 3
	DistanceCheck "boa_scenelod";
	Radius 8;
	Height 80;
	+NOGRAVITY
	+SOLID
	+SPAWNCEILING
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class UBoat : Crane
{
	Default
	{
	//$Title U-Boat
	Height 40;
	}
	States
	{
	Spawn:
		UBOT A -1;
		Stop;
	}
}

class Zapper: Actor
{
	Default
	{
	//$Category Props (BoA)/Industrial
	//$Title Zapper
	//$Color 3
	Radius 8;
	Height 56;
	Scale 0.5;
	+SOLID
	}
	States
	{
	Spawn:
		EZAP ABCDEFGH 3;
		Loop;
	}
}

class Pipe1: Actor
{
	Default
	{
	//$Category Props (BoA)/Industrial/Pipes
	//$Title Pipe (thick)
	//$Color 3
	Radius 8;
	Height 128;
	+SOLID
	}
	States
	{
	Spawn:
		PIPE A -1;
		Stop;
	}
}

class Pipe2 : Pipe1
{
	Default
	{
	//$Title Pipe (middle)
	}
	States
	{
	Spawn:
		PIPE B -1;
		Stop;
	}
}

class Pipe3 : Pipe1
{
	Default
	{
	//$Title Pipe (small)
	}
	States
	{
	Spawn:
		PIPE C -1;
		Stop;
	}
}

class Pipe4 : Pipe1
{
	Default
	{
	//$Title Pipe (thin)
	}
	States
	{
	Spawn:
		PIPE D -1;
		Stop;
	}
}