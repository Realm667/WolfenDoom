class MapObject : Object3d
{
	Default
	{
		+NOINTERACTION
	}
}

class EisenhimmelHangarDoors : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Eisenhimmel hangar doors (Animated, Set state "Close")
		//$Color 3
	}
    States
    {
    Spawn:
        MDLA A -1;
    Hold:
        "####" "#" -1;
        Stop;
    Close:
        MDLA ABCDEFGH 114;
        Goto Hold;
    }
}

class ArnhemCathedral : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem Cathedral
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 512;
		Height 1024;
	}
}

class ArnhemHouseA : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House A
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 164;
		Height 384;
	}
}

class ArnhemHouseB : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House B
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 181;
		Height 384;
	}
}

class ArnhemHouseC : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House C
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 116;
		Height 416;
	}
}

class ArnhemHouseD : MapObject
{
	Default
	{
		//$Category Models (BoA)/Map Objects
		//$Title Arnhem House D
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 136;
		Height 464;
	}
}
