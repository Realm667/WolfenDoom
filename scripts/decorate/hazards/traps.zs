class GroundSpikes : SwitchableDecoration
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title Ground Spikes (inactive)
		//$Color 3
		Radius 16;
		Height 48;
		+BUMPSPECIAL
		Obituary "$OBSPIKES";
	}
	States
	{
	Spawn:
	Active:
		BSPK A 2 A_StartSound("SpikeToggle");
		"####" BCDE 2;
		"####" A 0 A_SetSolid;
		"####" F -1 Thing_SetSpecial(0,73,0,22,0);
		Stop;
	Inactive:
		"####" F 2 Thing_SetSpecial(0,0,0,0,0);
		"####" EDCB 2;
		"####" A -1 A_UnSetSolid;
		Stop;
	}
}

///////////
// NAILS //
///////////
class Nail: Actor
{
	Default
	{
		Projectile;
		Radius 4;
		Height 8;
		Speed 44;
		DamageFunction (4 * random(1,8));
		Scale 0.5;
		+BLOODSPLATTER
		SeeSound "NailFlight";
	}
	States
	{
	Spawn:
		DART A 1 A_SpawnItemEx("NailBlur");
		Loop;
	Crash:
	Death:
		"####" B 0 A_StartSound("NailHit");
		"####" BCDEFG 2;
		Stop;
	XDeath:
		"####" B 0 A_StartSound("NailHitBleed");
		"####" BCDEFG 2;
		Stop;
	}
}

class NailBlur: Actor
{
	Default
	{
		Height 8;
		Radius 1;
		Scale 0.5;
		Speed 0.2;
		+NOGRAVITY
		+DROPOFF
		RenderStyle "Translucent";
	}
	States
	{
	Spawn:
		DART A 1 A_FadeOut(0.2);
		Loop;
	}
}

class NailFlame : Nail
{
	States
	{
	Spawn:
		DARF A 1 BRIGHT LIGHT("Chandelier4") A_SpawnItemEx("NailBlur");
		Loop;
	Crash:
	Death:
		DART B 0 A_StartSound("NailHit");
		"####" BCDEFG 2;
		Stop;
	XDeath:
		"####" B 0 A_StartSound("NailHitBleed");
		"####" BCDEFG 2;
		Stop;
	}
}

class BossDagger : Nail
{
	Default
	{
		Speed 32;
		DamageFunction (8*random(1,8));
		Scale 1.0;
		-BRIGHT
	}
	States
	{
	Spawn:
		DGGR A 1 A_SpawnItemEx("DaggerBlur");
		Loop;
	Crash:
		DGGR AA 1 A_StartSound("Cleaver/Crash",CHAN_VOICE);
		Goto Death;
	Death:
		DGGR A 0 A_SpawnItemEx("HackPuff");
		DGGR A 1 A_FadeOut(0.4);
		Stop;
	}
}

class DaggerBlur : NailBlur
{
	Default
	{
		Scale 0.9;
		Speed 0.3;
		-BRIGHT
	}
	States
	{
	Spawn:
		DGGR A 1 A_FadeOut(0.2);
		Loop;
	}
}

//External Actors
class ScorpionNail : Nail
{
	Default
	{
		Speed 48;
		Scale 0.4;
		SeeSound "scorpion/sting1";
		DeathSound "scorpion/sting2";
	}
}

class PowerSlow : PowerSpeed { Default { Powerup.Duration -4; Speed 0.33; } }
class SlowFreeze : PowerupGiver { Default { +INVENTORY.AUTOACTIVATE +INVENTORY.ADDITIVETIME -INVENTORY.INVBAR Powerup.Type "PowerSlow"; } }

class IceDart : FastProjectile
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 32;
		Scale 1.1;
		DamageFunction (random(5,8));
		DamageType "IceWater";
		Projectile;
		+BLOODSPLATTER
		+BRIGHT
		+FORCERADIUSDMG
		+SEEKERMISSILE
		Alpha 0.9;
		Decal "PlasmaScorchLower";
		Renderstyle "Add";
		SeeSound "IceFlight";
	}
	States
	{
	Spawn:
	See:
		ICED A 1 LIGHT("ICEBALL") A_SpawnItemEx("IceTrail");
		"####" "#" 0 A_SeekerMissile(1, 3);
		Loop;
	XDeath:
		"####" B 0 {A_StartSound("IceHit"); A_RadiusGive("SlowFreeze", 48, RGF_PLAYERS | RGF_CUBE, 1);}
	Death:
		ICEX AAAAAAAA 0 A_SpawnItemEx("Smoke_Small", 0, 0, 0, random(10, 30)*0.1, 0, random(0, 10)*0.1, random(0,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
		"####" AAAA 0 A_SpawnItemEx("Smoke_Medium", 0, 0, 0, random(10, 30)*0.04, 0, random(0, 10)*0.04, random(0,360), SXF_CLIENTSIDE|SXF_NOCHECKPOSITION);
		"####" ABCDEFGHIJKLMA 1 {A_SetRenderStyle(0.5,STYLE_Add); A_SetScale(0.5); A_FadeOut(0.1);}
		Stop;
	}
}

class IceTrail: Actor
{
	Default {
		Radius 8;
		Height 8;
		+BRIGHT
		+NOINTERACTION
		Alpha 0.5;
		Renderstyle "Add";
	}
	States
	{
	Spawn:
		ICET AABBCDEFG 1;
		Stop;
	}
}