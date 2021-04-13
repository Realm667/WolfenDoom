/////////////////////////
// FOG by TORMENTOR667 //
//   edits by zrrion   //
/////////////////////////
class FogCloud_Generator : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Fog Spawner (Switchable)
	//$Color 12
	//$Sprite GZDBA0
	//$Arg0 "Radius"
	//$Arg0Tooltip "Radius in map units"
	Radius 1;
	Height 1;
	+CLIENTSIDEONLY
	+MISSILE
	+NOBLOCKMAP
	+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(CallACS("boa_fogswitch")==0,"EndSpawn");
	Active:
		TNT1 A 0 A_JumpIf(ARGS[0]!=0,"MaperInput");
		TNT1 A 0 A_Jump(128,1,2);
		TNT1 A 0 A_SpawnItemEx("FogCloud_V1", random(random(-96, 96), random(-64, 64)), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("FogCloud_V2", random(random(-96, 96), random(-64, 64)), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("FogCloud_V3", random(random(-96, 96), random(-64, 64)), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		Stop;
	MaperInput:
		TNT1 A 0 A_Jump(128,1,2);
		TNT1 A 0 A_SpawnItemEx("FogCloud_V1", random(-ARGS[0],ARGS[0]), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("FogCloud_V2", random(-ARGS[0],ARGS[0]), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("FogCloud_V3", random(-ARGS[0],ARGS[0]), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		Stop;
	Inactive:
	EndSpawn:
		TNT1 A 1 A_RemoveChildren(TRUE, RMVF_MISC);
		Stop;
	}
}

class FogCloud_V1: Actor
{
	Default
	{
	DistanceCheck "boa_scenelod";
	Radius 1;
	Height 1;
	+MISSILE
	+NOBLOCKMAP
	+NOGRAVITY
	Alpha .25;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(frandom(2,2.25));
		TNT1 A 0 A_Jump(256,1,2,3,4);
		AWCF ABCD 0 A_Jump(256,"Coolness");
	Coolness:
		"----" AAAAAAAAAAAAAAAAAAAA 10 A_FadeIn(0.002);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" AAAAAAAAAAAAAA 4;
		"----" AAAAAAAAAAAAAAAAAAAA 10 A_FadeOut(0.002,FTF_REMOVE);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		AWCF AAAAAAAAAAAAAA 4;
		Loop;
	}
}

class FogCloud_V2 : FogCloud_V1
{
	States
	{
	Coolness:
		"----" AAAAAAAAAAAAAA 11 A_FadeIn(0.002);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" AAAAAAAAAAAAAA 5;
		"----" AAAAAAAAAAAAAA 11 A_FadeOut(0.002,FTF_REMOVE);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" AAAAAAAAAAAAAA 5;
		Loop;
	}
}

class FogCloud_V3 : FogCloud_V1
{
	States
	{
	Coolness:
		"----" AAAAAAAAAAAAAA 12 A_FadeIn(0.002);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" AAAAAAAAAAAAAA 6;
		"----" AAAAAAAAAAAAAA 12 A_FadeOut(0.002,FTF_REMOVE);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" AAAAAAAAAAAAAA 6;
		Loop;
	}
}

////////////////////////////////
// ZYKLON FOG by TORMENTOR667 //
////////////////////////////////
class ZyklonFogCloud_Generator : FogCloud_Generator
{
	Default
	{
	//$Title Fog Spawner (Zyklon C, Switchable)
	//$Sprite GZDBB0
	}
	States
	{
	Spawn:
		TNT1 A 0 A_JumpIf(CallACS("boa_fogswitch")==0,"EndSpawn");
	Active:
		TNT1 A 0 A_JumpIf(ARGS[0]!=0,"MaperInput");
		TNT1 A 0 A_Jump(128,1,2);
		TNT1 A 0 A_SpawnItemEx("ZyklonFogCloud_V1", random(random(-96, 96), random(-64, 64)), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("ZyklonFogCloud_V2", random(random(-96, 96), random(-64, 64)), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("ZyklonFogCloud_V3", random(random(-96, 96), random(-64, 64)), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		Stop;
	MaperInput:
		TNT1 A 0 A_Jump(128,1,2);
		TNT1 A 0 A_SpawnItemEx("ZyklonFogCloud_V1", random(-ARGS[0],ARGS[0]), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("ZyklonFogCloud_V2", random(-ARGS[0],ARGS[0]), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		TNT1 A 0 A_SpawnItemEx("ZyklonFogCloud_V3", random(-ARGS[0],ARGS[0]), 0, random(0, random(32, 48)), 0, 0, 0, random(0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE | SXF_SETMASTER, 129, tid);
		Stop;
	Inactive:
	EndSpawn:
		TNT1 A 1 A_RemoveChildren(TRUE, RMVF_MISC);
		Stop;
	}
}

class ZyklonFogCloud_V1 : FogCloud_V1
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(frandom(2,2.25));
		TNT1 A 0 A_Jump(256,1,2,3,4);
		AWCF EFGH 0 A_Jump(256,"Coolness");
	Coolness:
		"----" EEEEEEEEEEEEEEEEEEEE 10 A_FadeIn(0.002);
		"----" E 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" EEEEEEEEEEEEE 4;
		"----" EEEEEEEEEEEEEEEEEEEE 10 A_FadeOut(0.002,FTF_REMOVE);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		AWCF EEEEEEEEEEEEEE 4;
		Loop;
	}
}

class ZyklonFogCloud_V2 : ZyklonFogCloud_V1
{
	States
	{
	Coolness:
		"----" EEEEEEEEEEEEEE 11 A_FadeIn(0.002);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" EEEEEEEEEEEEEE 5;
		"----" EEEEEEEEEEEEEE 11 A_FadeOut(0.002,FTF_REMOVE);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" EEEEEEEEEEEEEE 5;
		Loop;
	}
}

class ZyklonFogCloud_V3 : ZyklonFogCloud_V1
{
	States
	{
	Coolness:
		"----" EEEEEEEEEEEEEE 12 A_FadeIn(0.002);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" EEEEEEEEEEEEEE 6;
		"----" EEEEEEEEEEEEEE 12 A_FadeOut(0.002,FTF_REMOVE);
		"----" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
		"----" A 0;
		"----" EEEEEEEEEEEEEE 6;
		Loop;
	}
}