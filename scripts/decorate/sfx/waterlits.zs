//this was CaptainToenail stuff... shame on me... (ozy)
class UWLightGenerator1 : EffectSpawner
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Water Lights Generator (Water)
	//$Color 12
	//$Sprite UNKNA0
	+CLIENTSIDEONLY
	+DONTSPLASH
	+NOBLOCKMAP
	+NOGRAVITY
	+NOTIMEFREEZE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(CallACS("boa_litsswitch")==0,"EndSpawn");
	Active:
		TNT1 A 1 A_CheckSight("Unsighted");
		TNT1 A 0 { if (CheckRange(boa_sfxlod, true)) { SetStateLabel("Active"); } }
		"####" A 1 A_SpawnItemEx("UWaterLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		"####" A 1 A_SpawnItemEx("UWaterLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		Loop;
	Unsighted:
		TNT1 A 1;
		"####" A 0 A_Jump(256,"Spawn");
	Inactive:
		TNT1 A -1;
		Stop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

//...but these are new...
class UWLightGenerator2 : UWLightGenerator1
{
	Default
	{
	//$Title Water Lights Generator (Lava)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(CallACS("boa_litsswitch")==0,"EndSpawn");
	Active:
		TNT1 A 1 A_CheckSight("Unsighted");
		TNT1 A 0 { if (CheckRange(boa_sfxlod, true)) { SetStateLabel("Active"); } }
		"####" A 1 A_SpawnItemEx("ULavaLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		"####" A 1 A_SpawnItemEx("ULavaLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		Loop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class UWLightGenerator3 : UWLightGenerator1
{
	Default
	{
	//$Title Water Lights Generator (Gore)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(CallACS("boa_litsswitch")==0,"EndSpawn");
	Active:
		TNT1 A 1 A_CheckSight("Unsighted");
		TNT1 A 0 { if (CheckRange(boa_sfxlod, true)) { SetStateLabel("Active"); } }
		"####" A 1 A_SpawnItemEx("UGoreLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		"####" A 1 A_SpawnItemEx("UGoreLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		Loop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class UWLightGenerator4 : UWLightGenerator1
{
	Default
	{
	//$Title Water Lights Generator (Hazard)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(CallACS("boa_litsswitch")==0,"EndSpawn");
	Active:
		TNT1 A 1 A_CheckSight("Unsighted");
		TNT1 A 0 { if (CheckRange(boa_sfxlod, true)) { SetStateLabel("Active"); } }
		"####" A 1 A_SpawnItemEx("UHazardLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		"####" A 1 A_SpawnItemEx("UHazardLShooter",0,0,0,random(-32,32),random(-32,32),random(-32,0),random(0,32),160);
		Loop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class UWaterLShooter: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Speed 1;
	Projectile;
	+BLOODLESSIMPACT
	+DONTSPLASH
	+NOBLOCKMAP
	+RANDOMIZE
	RenderStyle "None";
	}
	States
	{
	Spawn:
		BAL1 A 1 A_JumpIf(waterlevel < 3,1);
		Loop;
		BAL1 A 1 A_Stop;
		Stop;
	Death:
		BAL1 CDE 8 A_FadeOut(0.025);
		Stop;
	}
}

class ULavaLShooter : UWaterLShooter{}
class UGoreLShooter : UWaterLShooter{}
class UHazardLShooter : UWaterLShooter{}

//Tormentor667 light rays
class UnderwaterLightRay : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Underwater Light Ray
	//$Color 12
	//$Sprite LRAYA0
	Height 128;
	Radius 32;
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	+ROLLSPRITE
	+WALLSPRITE
	+ROLLCENTER
	RenderStyle "Add";
	Scale 0.5;
	Alpha 1.0;
	}
	States
	{
	Spawn:
	Active:
		LRAY A -1 BRIGHT;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}

class UnderwaterLightRayCone : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Underwater Light Ray (cone)
	//$Color 12
	//$Sprite VOLTC0
	Height 128;
	Radius 32;
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	+ROLLSPRITE
	+WALLSPRITE
	+ROLLCENTER
	RenderStyle "Add";
	Scale 0.5;
	Alpha 1.0;
	}
	States
	{
	Spawn:
	Active:
		VOLT C -1 BRIGHT;
		Loop;
	Inactive:
		TNT1 A -1;
		Loop;
	}
}