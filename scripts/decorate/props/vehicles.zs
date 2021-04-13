class Plane1: Actor
{
	Default
	{
	//$Category Props (BoA)/2D Vehicles
	//$Title Plane (grey)
	//$Color 3
	Radius 96;
	Height 96;
	+SOLID
	}
	States
	{
	Spawn:
		PLNE A -1;
		Stop;
	}
}

class Plane2 : Plane1
{
	Default
	{
	//$Title Plane (green)
	}
	States
	{
	Spawn:
		PLNE B -1;
		Stop;
	}
}

class Truck1 : Plane1
{
	Default
	{
	//$Title Truck (side)
	}
	States
	{
	Spawn:
		CAR1 A -1;
		Stop;
	}
}

class TruckFront : Plane1
{
	Default
	{
	//$Title Truck (front)
	Radius 64;
	}
	States
	{
	Spawn:
		CAR1 B -1;
		Stop;
	}
}

class Truck3 : TruckFront
{
	Default
	{
	//$Title Truck (back)
	}
	States
	{
	Spawn:
		CAR1 C -1;
		Stop;
	}
}

class TankD1 : Plane1
{
	Default
	{
	//$Title Tank 1 (360)
	Radius 60;
	}
	States
	{
	Spawn:
		PTNK A -1;
		Stop;
	}
}

class TankD2 : TankD1
{
	Default
	{
	//$Title Tank 2 (360)
	}
	States
	{
	Spawn:
		PTN2 A -1;
		Stop;
	}
}

class TankD3 : TankD1
{
	Default
	{
	//$Title Tank 3 (360)
	}
	States
	{
	Spawn:
		PTN3 A -1;
		Stop;
	}
}

class BomberInAir : Plane1
{
	Default
	{
	//$Title Bomber (flying, from below)
	Radius 16;
	Height 32;
	Scale 0.1;
	-SOLID
	+FLATSPRITE
	+NOGRAVITY
	}
	States
	{
	Spawn:
		BMBR A -1;
		Stop;
	}
}

class BomberInAir_C3M2 : BomberInAir
{
	Default
	{
	//$Title Bomber (flying, from below, tan)
	}
	States
	{
	Spawn:
		BMBR B -1;
		Stop;
	}
}