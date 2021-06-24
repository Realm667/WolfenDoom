/*
 * Copyright (c) 2017-2021 Ozymandias81, Tormentor667, AFADoomer, Talon1024
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

////////
//MAIN//
////////

//ozy - The difference here comes with quakes & frame sequences
class MechBoss : Nazi
{
	Default
	{
	Mass 1000;
	Scale 1.0;
	Damagefactor "Normal", 0.75;
	}
	States
	{
	See:
	Idle:
		Goto See.BossMech;
	}
}

//ATTACKS - NAZIS
class GoeringProjectile : NebRocket
{
	Default
	{
	Radius 6;
	Height 16;
	Health 10;
	Mass 99999;
	Scale 1.0;
	Speed 5;
	+NOBLOOD
	+SHOOTABLE
	-FORCERADIUSDMG
	-NOBLOCKMAP
	SeeSound "nebelwerfer/fire";
	}
	States
	{
	Spawn:
		MNSS A 0 NODELAY A_StartSound("nazi/missileengine", CHAN_AUTO, CHANF_LOOPING, 0.3);
	Fly:
		MNSS AAAAAAAAAA 8 BRIGHT LIGHT("NEBLIGHT")
			{
				A_SpawnItemEx("TracerSpark", random(-8,8), random(-8,8), random(-8,8), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SpawnItemEx("TracerSpark", random(-8,8), random(-8,8), random(-8,8), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SpawnItemEx("TracerSpark", random(-8,8), random(-8,8), random(-8,8), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SpawnItemEx("TracerSpark", random(-8,8), random(-8,8), random(-8,8), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SpawnItemEx("TracerSpark", random(-8,8), random(-8,8), random(-8,8), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SpawnItemEx("FlamerSmoke1");
			}
		MNSS A 1 BRIGHT LIGHT("NEBLIGHT")
			{ A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 0, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 20, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 40, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 60, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 80, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 100, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 120, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 140, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 160, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 180, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 200, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 220, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 240, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 260, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 280, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 300, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 320, SXF_SETMASTER);
			  A_SpawnItemEx("GoeringBall", 16, 0, 0, 15, 0, 0, 340, SXF_SETMASTER);
			}
		Loop;
	Death:
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		FRME A 1 BRIGHT LIGHT("NEBEXPLO") A_Explode(random(25,30));
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("NEBEXPLO");
		Stop;
	}
}

class GoeringBall: Actor
{
	Default
	{
	Radius 6;
	Height 8;
	Speed 15;
	DamageFunction (3*random(1,8));
	RenderStyle "Add";
	SeeSound "Goering/shotsit";
	DeathSound "Goering/shotdth";
	Projectile;
	+BRIGHT
	+RANDOMIZE
	Decal "PlasmaScorchLower";
	}
	States
	{
	Spawn:
		SDFB A 1 A_SpawnItemEx("GoeringBall_Trail", 0, 0, 0);
		Loop;
	Death:
		SDFB BCDE 6;
		Stop;
	}
}

class GoeringBall_Trail: Actor
{
	Default
	{
	Scale 0.3;
	+BRIGHT
	+NOBLOCKMAP
	+NOGRAVITY
	+ROLLSPRITE
	}
	States
	{
	Spawn:
		SDFB BBBCCCDDDEEE 1 { A_Fadeout(0.09); A_SetRoll(roll+32.0, SPF_INTERPOLATE); }
		Loop;
	}
}

class OccultBlazeFX1: Actor
{
	Default
	{
	Radius 16;
	Height 2;
	Speed 0;
	DamageFunction (random(0,1));
	DamageType "Fire";
	Renderstyle "Add";
	Species "Nazi";
	Scale 0.85;
	Alpha 0.75;
	Projectile;
	MaxStepHeight 12;
	+BLOODLESSIMPACT
	+FLOORHUGGER
	+THRUGHOST
	+THRUSPECIES
	+WINDTHRUST
	}
	States
	{
	Spawn:
		BLZF ABCDCBA 4;
		Stop;
	}
}

class OccultBlazeFX2 : OccultBlazeFX1
{
	Default
	{
	Radius 8;
	Scale 0.55;
	Renderstyle "Translucent";
	Alpha 0.75;
	+RIPPER
	}
}

class OccultBlazeFX3 : OccultBlazeFX1
{
	Default
	{
	Radius 4;
	Damage 0;
	Scale 0.35;
	Renderstyle "Translucent";
	Alpha 0.75;
	+RIPPER
	}
}

class OccultBlazeFlames: Actor
{
	Default
	{
	Radius 16;
	Height 32;
	Speed 8;
	DamageFunction (random(2,4));
	DamageType "Fire";
	Renderstyle "Add";
	Species "Nazi";
	Scale 0.85;
	Alpha 0.45;
	Projectile;
	+BLOODLESSIMPACT
	+FLOORHUGGER
	+NODROPOFF
	+THRUGHOST
	+THRUSPECIES
	+WINDTHRUST
	Obituary "$OBLAZES";
	SeeSound "flamer/fire";
	DeathSound "flamer/napalm";
	Decal "Scorch";
	}
	States
	{
	Spawn:
		BLZF ABCDCBA 3 {
				A_SpawnProjectile("OccultBlazeFX1");
				A_SpawnProjectile("OccultBlazeFX3");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
		Loop;
	Death:
		"####" EFGHIJ 3;
		"####" J 3 A_FadeOut (0.05);
		Stop;
	}
}

class OccultBlazeFlames2 : OccultBlazeFlames
{
	Default
	{
	Radius 32;
	Speed 16;
	+RIPPER
	}
	States
	{
	Spawn:
		BLZF ABCDCBA 3 {
				A_SpawnProjectile("OccultBlazeFX2");
				A_SpawnProjectile("OccultBlazeFX3");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
		Loop;
	}
}

class ZyklonBlazeFX1 : OccultBlazeFX1
{
	Default
	{
	DamageType "UndeadPoison";
	Species "Zombie";
	}
	States
	{
	Spawn:
		ZYZF ABCDCBA 4;
		Stop;
	}
}

class ZyklonBlazeFX2 : ZyklonBlazeFX1
{
	Default
	{
	Radius 8;
	Scale 0.55;
	Renderstyle "Translucent";
	Alpha 0.75;
	+RIPPER
	}
}

class ZyklonBlazeFX3 : ZyklonBlazeFX1
{
	Default
	{
	Radius 4;
	Damage 0;
	Scale 0.35;
	Renderstyle "Translucent";
	Alpha 0.75;
	+RIPPER
	}
}

class OccultZyklonFlames : OccultBlazeFlames
{
	Default
	{
	Speed 12;
	DamageType "UndeadPoison";
	Species "Zombie";
	Obituary "$ZBLAZES";
	}
	States
	{
	Spawn:
		ZYZF ABCDCBA 3 {
				A_SpawnProjectile("ZyklonBlazeFX1");
				A_SpawnProjectile("ZyklonBlazeFX3");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
		Loop;
	Death:
		"####" EFGHIJ 3;
		"####" J 3 A_FadeOut (0.05);
		Stop;
	}
}

class OccultZyklonFlames2 : OccultZyklonFlames
{
	Default
	{
	Radius 32;
	Speed 16;
	+RIPPER
	}
	States
	{
	Spawn:
		ZYZF ABCDCBA 3 {
				A_SpawnProjectile("ZyklonBlazeFX2");
				A_SpawnProjectile("ZyklonBlazeFX3");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
		Loop;
	}
}

class RumbleFX1 : OccultBlazeFX1
{
	Default
	{
	Radius 8;
	Scale 0.1;
	DamageType "UndeadPoison";
	Renderstyle "Translucent";
	Alpha 0.8;
	+RIPPER
	}
	States
	{
	Spawn:
		SPLM AAAAAAAAAA 1 A_SetScale(Scale.X+0.06, Scale.Y+0.06);
		SPLM AAAAAAAAAA 2 {
					A_SetScale(Scale.X, Scale.Y-0.03);
					A_SetTranslucent(alpha-0.1);
				  }
		Stop;
	}
}

class RumbleFX2 : RumbleFX1
{
	States
	{
	Spawn:
		SPLM BBBBBBBBBB 1 A_SetScale(Scale.X+0.06, Scale.Y+0.06);
		SPLM BBBBBBBBBB 2 {
					A_SetScale(Scale.X, Scale.Y-0.03);
					A_SetTranslucent(alpha-0.1);
				  }
		Stop;
	}
}

class RumbleWaves: Actor
{
	Default
	{
	Radius 40;
	Height 64;
	Speed 16;
	DamageFunction (random(2,4));
	DamageType "UndeadPoison";
	Species "Nazi";
	Projectile;
	+BLOODLESSIMPACT
	+FLOORHUGGER
	+THRUGHOST
	+THRUSPECIES
	MaxStepHeight 4;
	Obituary "$OBRUMBLE";
	SeeSound "flamer/fire";
	DeathSound "flamer/napalm";
	Decal "Scorch";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_Jump(128, "Dirt2");
	Dirt1:
		"####" A 4      {
				A_SpawnProjectile("RumbleFX1");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
	Goto Spawn;
	Dirt2:
		"####" A 4      {
				A_SpawnProjectile("RumbleFX2");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
	Goto Spawn;
	Death:
		TNT1 A 0 A_Explode(20, 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 20);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_RadiusThrust(3000, 128);
		TNT1 A 0 A_RadiusThrust(256, 128, RTF_THRUSTZ);
		Stop;
	}
}

class PowerNumbness : PowerSpeed
{
	Default
	{
		Inventory.Icon "ICO_NUMB";
		Speed 0.5;
	}
}

class CurseNumbness : PowerupGiver
{
	Default
	{
	PowerUp.Type "PowerNumbness";
	PowerUp.Duration -1;
	Powerup.Color "00 00 22", .2;
	Inventory.MaxAmount 0;
	+INVENTORY.AUTOACTIVATE
	+INVENTORY.QUIET
	+INVENTORY.ADDITIVETIME
	}
}

class BarkFX1 : RumbleFX1
{
	Default
	{
	Radius 8;
	Scale 2.2;
	DamageType "Numbness";
	Renderstyle "Translucent";
	Alpha 0.6;
	+RIPPER
	}
	States
	{
	Spawn:
		BARK AABBAABBAA 1 A_SetScale(Scale.X+1.06, Scale.Y+1.06);
		BARK BBAABBAABB 2 {
					A_SetScale(Scale.X, Scale.Y+1.03);
					A_SetTranslucent(alpha-0.1);
				  }
		Stop;
	}
}

class BarkFX2 : RumbleFX2
{
	States
	{
	Spawn:
		BARK BBAABBAABB 1 A_SetScale(Scale.X+1.06, Scale.Y+1.06);
		BARK AABBAABBAA 2 {
					A_SetScale(Scale.X, Scale.Y+1.03);
					A_SetTranslucent(alpha-0.1);
				  }
		Stop;
	}
}

class BarkWaves : RumbleWaves
{
	Default
	{
	Speed 20;
	-FLOORHUGGER
	DamageType "Numbness";
	Obituary "$OBBARK";
	SeeSound "dog/sight";
	DeathSound "geist/die";
	Decal "None";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_Jump(128, "Dirt2");
	Dirt1:
		"####" A 4      {
				A_SpawnProjectile("BarkFX1");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
	Goto Spawn;
	Dirt2:
		"####" A 4      {
				A_SpawnProjectile("BarkFX2");
				A_RadiusGive("HeatShaderControl", radius+64, RGF_PLAYERS | RGF_GIVESELF, 32);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);}
				}
	Goto Spawn;
	Death:
		TNT1 A 0 A_Explode(20, 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 20);
		TNT1 A 0 A_RadiusThrust(5000, 128);
		Stop;
	}
}

class ClusterBomb : GrenadeBase
{
	Default
	{
	Radius 4;
	Height 3;
	Speed 40;
	DamageFunction (random(1,8));
	DamageType "Frag";
	Reactiontime 8; //for countdown
	Projectile;
	-NOGRAVITY
	-NOTELEPORT
	+WINDTHRUST
	+GrenadeBase.DRAWINDICATOR
	Obituary "$OBGRENADE";
	BounceType "Doom";
	BounceFactor 0.4;
	WallBounceFactor 0.6;
	SeeSound "clusterbomb/fire";
	BounceSound "grenade/bounce";
	GrenadeBase.Icon "HUD_TRGN";
	}
	States
	{
	Spawn:
		TRGN A 20 A_SetAngle(angle + 359, SPF_INTERPOLATE);
		"####" A 0 A_Countdown;
		Loop;
	Death:
		TRGN A 35;
		TNT1 A 0 A_AlertMonsters;
		"####" A 0 A_SetScale(1.75,1.75);
		"####" A 0 A_SetTranslucent(0.75,1);
		"####" A 0 A_StartSound("clusterbomb/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator");
		"####" A 0 A_SpawnItemEx("KD_HL2SparkGenerator");
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnitemEx("ClusterBomb_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0);
		"####" A 1 Radius_Quake(10,10,0,16,0);
		Stop;
	}
}

class ClusterBomb_Debris: Actor
{
	Default
	{
	Radius 8;
	Height 16;
	Mass 20;
	DamageFunction (2*random(1,8));
	Scale 0.5;
	Gravity 0.75;
	Projectile;
	-NOGRAVITY
	+RANDOMIZE
	+ROLLSPRITE
	BounceType "Hexen";
	BounceFactor 0.8;
	BounceSound "clusterbomb/debrisbounce";
	WallBounceFactor 0.8;
	BounceCount 5;
	}
	States
	{
	Spawn:
		NLPJ A 4 NODELAY { A_SetRoll(roll + 15, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass"); }
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" A 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0;
		Stop;
	}
}

class HardClusterBomb_Debris : ClusterBomb_Debris { Default { +MTHRUSPECIES DamageFunction (3*random(1,8)); } }

class HimmlerMortar : GrenadeBase
{
	Default
	{
	Radius 4;
	Height 4;
	Speed 15;
	DamageFunction (10*random(1,8));
	Gravity 0.25;
	Scale 0.8;
	Projectile;
	-NOGRAVITY
	+GRENADETRAIL
	+GrenadeBase.DRAWINDICATOR
	BounceSound "grenade/bounce";
	GrenadeBase.FearDistance 192;
	GrenadeBase.Icon "HUD_MORA";
	}
	States
	{
	Spawn:
		MORA A 20;
		MORB A 16;
	GoDown:
		MORC A 13;
		Loop;
	Death:
		MORD A 1 { bNoGravity = FALSE; }
		TNT1 A 0 A_AlertMonsters;
		"####" A 0 A_StartSound("clusterbomb/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator");
		"####" A 0 A_SpawnItemEx("KD_HL2SparkGenerator");
		"####" AAAAAAAAAAAAAAAAAAAA 0 A_SpawnitemEx("Mortar_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0);
		"####" AAAAAAAAA 0 A_SpawnitemEx("ClusterBomb_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0);
		"####" A 1 Radius_Quake(20,35,0,32,0);
		Stop;
	}
}

class ZMortar : HimmlerMortar
{
	Default
	{
	Speed 18;
	DamageFunction (random(4,10));
	DamageType "MutantPoison";
	Gravity 0.20;
	Obituary "$OBGASMORT";
	+GrenadeBase.DRAWINDICATOR
	GrenadeBase.FearDistance 192;
	GrenadeBase.Icon "HUD_MORA";
	}
	States
	{
	Spawn:
		ZORA A 20;
		ZORB A 16;
	GoDown:
		ZORC A 13;
		Loop;
	Death:
		ZORD A 1 { bNoGravity = FALSE; }
		TNT1 A 0 A_AlertMonsters;
		"####" A 0 A_StartSound("clusterbomb/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator");
		"####" A 0 A_SpawnItemEx("KD_HL2SparkGenerator");
		"####" AAAAAAAAAAAAAAAAAAAA 0 A_SpawnitemEx("Mortar_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0);
		"####" AAAAAAAAA 0 A_SpawnitemEx("ClusterBomb_Debris", 0, 0, 8, random(2,16), random(2,16), random(2,16), random(0,359), 0, 0);
		TNT1 A 0 BRIGHT A_SpawnProjectile("PoisonCloudUndead",16,0,0,2,0);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("UndeadSmoke",random(-64,64),random(-64,64),random(-48,48),Vel.X,0,frandom(0.5,1),0,SXF_TRANSFERTRANSLATION,160);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("ZyklonZCloud",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		"####" AAAAAAAAA 1 A_SpawnItemEx("Zombie_FlyingBlood", random(2,-2), random(2,-2), random(2,2), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class Mortar_Debris : ClusterBomb_Debris
{
	Default
	{
	Scale 0.2;
	}
	States
	{
	Spawn:
		MORD A 4 NODELAY { A_SetRoll(roll - 15, SPF_INTERPOLATE); A_JumpIf(waterlevel == 3, "AdjustMass"); }
		Loop;
	AdjustMass: //mxd
		"####" "#" 0 A_SetMass(400);
		Goto Swim;
	Swim: //mxd
		"####" A 2 A_ScaleVelocity(0.7);
		"####" A 2 A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128);
		Loop;
	Death:
		"####" A 0;
		Stop;
	}
}

class GasBomb : ClusterBomb
{
	Default
	{
	Speed 30;
	DamageType "MutantPoison";
	Reactiontime 12;
	Obituary "$OBGASBOMB";
	DeathSound "world/barrelboom";
	Translation "16:47=[34,0,7]:[0,0,0]","168:191=[36,0,9]:[2,0,0]";
	}
	States
	{
	Spawn:
		TRGN A 25 A_SetAngle(angle + 359, SPF_INTERPOLATE);
		"####" A 0 A_Countdown;
		Loop;
	Death:
		TRGN A 40;
		TNT1 A 0 A_AlertMonsters;
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator");
		"####" A 0 A_SpawnItemEx("KD_HL2SparkGenerator");
		"####" A 0 BRIGHT A_SpawnProjectile("PoisonCloudUndead",16,0,0,2,0);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("UndeadFartCloud",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("UndeadSmoke",random(-64,64),random(-64,64),random(-48,48),Vel.X,0,frandom(0.5,1),0,SXF_TRANSFERTRANSLATION,160);
		"####" A 1 Radius_Quake(10,10,0,16,0);
		Stop;
	}
}

class NebRocketEnemy : NebRocket
{
	Default
	{
	Speed 15;
	-FORCERADIUSDMG;
	SeeSound "nebelwerfer/fire";
	}
	States
	{
	Death:
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		FRME A 1 BRIGHT LIGHT("NEBEXPLO") A_Explode(random(25,30));
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("NEBEXPLO");
		Stop;
	}
}

class HardNebRocketEnemy : NebRocketEnemy { Default { +MTHRUSPECIES } }

class MiniRocket: Actor
{
	Default
	{
	Radius 11;
	Height 8;
	Speed 15;
	DamageFunction (5*random(1,8));
	Projectile;
	+RANDOMIZE
	Scale 0.47;
	SeeSound "nazi/missilef";
	DeathSound "world/barrelboom";
	}
	States
	{
	Spawn:
		NMIS A 0 NODELAY A_StartSound("nazi/missileengine", CHAN_AUTO, CHANF_LOOPING, 0.3);
		NMIS A 1 BRIGHT LIGHT("OTTOFIRE") A_SpawnItemEx("RocketFlame",random(-1,1),0,random(-1,1));
		Wait;
	Death:
		FRME A 1 BRIGHT LIGHT("OTTOFIRE") A_Explode(20,40);
		FRME A 0 A_StopSound(CHAN_AUTO);
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("OTTOFIRE");
		Stop;
	}
}

class HardMiniRocket : MiniRocket { Default { +MTHRUSPECIES } }

class MiniMiniRocket : MiniRocket
{
	Default
	{
	Scale 0.27;
	DamageFunction (random(1,4)*4);
	DeathSound "nebelwerfer/xplode";
	}
}

class HardMiniMiniRocket : MiniMiniRocket { Default { +MTHRUSPECIES } }

class SeekerRocket : MiniRocket
{
	Default
	{
	Scale 0.27;
	DamageFunction (random(1,4)*4);
	MaxTargetRange 128;
	+SEEKERMISSILE
	DeathSound "nebelwerfer/xplode";
	}
	States
	{
	Spawn:
		NMIS A 0 NODELAY A_StartSound("nazi/missileengine", CHAN_AUTO, CHANF_LOOPING, 0.3);
		NMIS A 1 BRIGHT LIGHT("OTTOFIRE") {A_SeekerMissile(8, random(8,16)); A_SpawnItemEx("RocketFlame",random(-1,1),0,random(-1,1));}
		Wait;
	Death:
		FRME A 1 BRIGHT LIGHT("OTTOFIRE") A_Explode(20,40);
		FRME A 0 A_StopSound(CHAN_AUTO);
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("OTTOFIRE");
		Stop;
	}
}

class HardSeekerRocket : SeekerRocket { Default { +MTHRUSPECIES MaxTargetRange 192; } }
/*
//ATTACKS - ROBOTS
class MechaRocket : MiniRocket
{
	Default
	{
	Speed 27;
	}
	States
	{
	Death:
		FRME A 1 BRIGHT LIGHT("OTTOFIRE") A_Explode(25,45); //5 dmg more
		FRME A 0 A_StopSound(CHAN_AUTO);
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("OTTOFIRE");
		Stop;
	}
}

class HardMechaRocket : MechaRocket { Default { +MTHRUSPECIES } }
*/

class MiniMechaRocket : MiniRocket
{
	int user_wspeed;
	double user_wrange;
	
	Default
	{
	Speed 20;
	Scale 0.27;
	DamageFunction (random(1,2)*5); //5-10 damage + 10 splash damage
	DeathSound "nebelwerfer/xplode";
	}
	States
	{
	Spawn:
		NMIS A 0 NODELAY {
			user_wspeed = random(2, 4) * (random(0, 1) * 2 - 1); /*the first parameter is integer afaik from wiki*/
			user_wrange = frandom(3.0, 5.0);
		}
	Spawn.Fly:
		NMIS A 0 A_StartSound("nazi/missileengine", CHAN_AUTO, CHANF_LOOPING, 0.3);
		"####" "#" 1 {
			A_Weave(user_wspeed, user_wspeed, user_wrange, user_wrange);
			A_SpawnItemEx("RocketFlame",random(-1,1),0,random(-1,1));
		}
		Loop;
	Death:
		FRME A 1 BRIGHT LIGHT("OTTOFIRE") A_Explode(random(16,32), 96, 0);
		FRME A 0 A_StopSound(CHAN_AUTO);
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("OTTOFIRE");
		Stop;
	}
}

class HardMiniMechaRocket : MiniMechaRocket { Default { +MTHRUSPECIES } }

//ATTACKS - BOSSES
class FlyingNeedle : MiniRocket
{
	Default
	{
	Speed 10;
	DamageType "MutantPoison";
	PoisonDamageType "MutantPoisonAmbience";
	PoisonDamage 3, 4;
	SeeSound "";
	DeathSound "gshardnd";
	Gravity 0.3;
	Scale 0.47;
	-NOGRAVITY
	+ADDITIVEPOISONDAMAGE
	+ADDITIVEPOISONDURATION
	}
	States
	{
	Spawn:
		NEDL ABCD 3;
		Loop;
	Death:
		TNT1 A 1;
		Stop;
	}
}

class FlyingNeedleNoGrav : FlyingNeedle
{
	Default
	{
	Scale 0.55;
	+NOGRAVITY
	}
}

class HardFlyingNeedle : FlyingNeedle { Default { +MTHRUSPECIES } }

class HardFlyingNeedleNoGrav : FlyingNeedleNoGrav { Default { +MTHRUSPECIES } }

class FlyingNeedleZ : MiniRocket
{
	Default
	{
	Speed 12;
	DamageType "UndeadPoison";
	PoisonDamageType "UndeadPoisonAmbience";
	PoisonDamage 1, 2;
	SeeSound "";
	DeathSound "gshardnd";
	Gravity 0.3;
	Scale 0.47;
	-NOGRAVITY
	+ADDITIVEPOISONDAMAGE
	+ADDITIVEPOISONDURATION
	}
	States
	{
	Spawn:
		NEDL EFGH 3;
		Loop;
	Death:
		TNT1 AA 0 A_SpawnItemEx("ZyklonBCloud",random(-4,4),random(-4,4),random(4,4),frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(0.0,1.0),0,128);
		Stop;
	}
}

class FlyingNeedleZNoGrav : FlyingNeedleZ
{
	Default
	{
	Scale 0.55;
	+NOGRAVITY
	}
}

class HardFlyingNeedleZ : FlyingNeedleZ { Default { +MTHRUSPECIES } }

class HardFlyingNeedleZNoGrav : FlyingNeedleZNoGrav { Default { +MTHRUSPECIES } }

class FlyingHack : MiniRocket
{
	Default
	{
	Radius 8;
	Speed 13;
	Gravity 0.3;
	Scale 0.47;
	DamageType "None";
	DamageFunction (random(1,2));
	SeeSound "";
	DeathSound "dspfwood";
	-NOGRAVITY
	+RANDOMIZE
	+RIPPER
	}
	States
	{
	Spawn:
		CLVR A 4 A_SpawnItem("CleaverTrail1");
		CLVR B 4 A_SpawnItem("CleaverTrail2");
		CLVR C 4 A_SpawnItem("CleaverTrail3");
		CLVR D 4 A_SpawnItem("CleaverTrail4");
		CLVR E 4 A_SpawnItem("CleaverTrail5");
		CLVR F 4 A_SpawnItem("CleaverTrail6");
		CLVR G 4 A_SpawnItem("CleaverTrail7");
		CLVR H 4 A_SpawnItem("CleaverTrail8");
		Loop;
	Death:
		CLVR I 0 A_SpawnItemEx("HackPuff");
		CLVR IIJJKKLL 1 A_FadeOut(0.2);
		Stop;
	Crash:
		CLVR II 1 A_StartSound("Cleaver/Crash",CHAN_VOICE);
		Goto Death;
	}
}

class HardFlyingHack : Flyinghack { Default { +MTHRUSPECIES Speed 18; } }

class HackPuff: Actor
{
	Default
	{
	+NOBLOCKMAP
	+NOEXTREMEDEATH
	+NOGRAVITY
	+PUFFONACTORS
	RenderStyle "Translucent";
	Alpha 0.5;
	}
	States
	{
	Spawn:
	Melee:
	Crash:
		POOF A 3 A_StartSound("knife/stone");
		POOF BCDE 3;
		Stop;
	Death:
	XDeath:
		POOF A 3 A_StartSound("knife/hit");
		Goto Crash+1;
	}
}

class Flamerbolt : Flamebolt
{
	Default
	{
	DamageFunction (random(0,1));
	}
	States
	{
	Animation:
		"####" A 3 BRIGHT LIGHT("BOAFLAMW") { A_SetScale(Scale.X+0.05); A_FadeOut(0.05); }
		"####" A 0 A_Jump(128, "Smoke1", "Smoke2", "Smoke3");
		Goto Death;
	Death:
		"####" A 1 LIGHT("BOAFLAMW") { A_SetScale(Scale.X+0.05); A_FadeOut(0.05); }
		Goto Death;
	}
}

class EnemyFlamerShot : Flamerbolt { }
class HardEnemyFlamerShot : EnemyFlamerShot { Default { +MTHRUSPECIES } }
class EnemyFlamebolt : Flameball { Default { DamageFunction (8 * random(1,8)); } }
class HardEnemyFlamebolt : EnemyFlamebolt { Default { +MTHRUSPECIES } }

class EnemyFlamebolt2 : EnemyFlamebolt
{
	Default
	{
	DamageFunction (random(1,4)*5);
	Scale .35;
	}
	States
	{
	Death:
		FBLX ABCDEFGHIJK 2 BRIGHT LIGHT("BOAFLMW2");
		Stop;
	}
}

class HardEnemyFlamebolt2 : EnemyFlamebolt2 { Default { +MTHRUSPECIES } }

//ATTACKS - MUTANTS
class MutantFartCloud : GrenadeBase
{
	Default
	{
	Radius 2;
	Height 2;
	DamageType "MutantPoison";
	+NOINTERACTION
	+WINDTHRUST
	RenderStyle "Translucent";
	Alpha 0.3;
	GrenadeBase.FearDistance 128;
	}
	States
	{
	Spawn:
		FUGS AAAAA 2;
	Fade:
		FUGS AAAAA 2 A_FadeOut (0.05);
		FUGS AAAAA 2 A_FadeIn (0.05);
		FUGS AAAAA 2 A_FadeOut (0.05);
		FUGS AAAAA 2 A_FadeIn (0.05);
		FUGS AAAAA 2 A_FadeOut (0.05);
		FUGS AAAAA 2 A_FadeIn (0.05);
		FUGS AAAAA 2 A_FadeOut (0.05);
		FUGS AAAAA 2 A_FadeIn (0.05);
		Stop;
	}
}

class MutantSmoke: Actor
{
	Default
	{
	Radius 2;
	Height 2;
	Scale 0.3;
	Gravity 0.3;
	Alpha 0.5;
	VSpeed 2.5;
	+DONTSPLASH
	+FORCEXYBILLBOARD
	+MISSILE
	+MOVEWITHSECTOR
	+NOBLOCKMAP
	+NOGRAVITY
	+WINDTHRUST
	RenderStyle "Shaded";
	StencilColor "E0 00 E0";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		CLFX A 8 A_FadeOut(0.05);
		Wait;
	}
}

class MutantRocket: Actor
{
	Default
	{
	Radius 8;
	Height 8;
	Speed 12;
	FastSpeed 14;
	DamageFunction (random(1,3));
	DamageType "MutantPoison";
	Projectile;
	Scale 0.4;
	+RANDOMIZE
	SeeSound "nazi/missilef";
	DeathSound "world/barrelboom";
	}
	States
	{
	Spawn:
		NMIS A 0 NODELAY A_StartSound("nazi/missileengine", CHAN_AUTO, CHANF_LOOPING, 0.3);
	Fly:
		NMIS A 1 BRIGHT LIGHT("MUTNROCK") A_SpawnItemEx("MutantFlame",random(-1,1),0,random(-1,1));
		Loop;
	Death:
		FUGS A 1 BRIGHT LIGHT("MUTNROCK") A_Explode(5,15);
		FUGS A 0 A_StopSound(CHAN_AUTO);
		FUGS A 0 BRIGHT A_SpawnProjectile("PoisonCloudMutant",16,0,0,2,0);
		FUGS AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("MutantFartCloud",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		FUGS AAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("MutantSmoke",random(-64,64),random(-64,64),random(-48,48),Vel.X,0,frandom(0.5,1),0,SXF_TRANSFERTRANSLATION,160);
		FUGS AAAAAAAAAA 1 BRIGHT LIGHT("MUTNROCK");
		Stop;
	}
}

class HardMutantRocket : MutantRocket { Default { DamageFunction (random(2,4)); +MTHRUSPECIES } }

class PoisonCloudMutant : GrenadeBase
{
	Default
	{
	Radius 20;
	Height 30;
	Reactiontime 5;
	+BLOCKEDBYSOLIDACTORS
	+BLOODLESSIMPACT
	+CANBLAST
	+DONTSPLASH
	+DONTTHRUST
	+DROPOFF
	+FOILINVUL
	+NOBLOCKMAP
	+NODAMAGETHRUST
	+NOGRAVITY
	RenderStyle "Translucent";
	Alpha 0.6;
	DamageType "MutantPoison";
	GrenadeBase.FearDistance 128;
	}
	States
	{
	Spawn:
		TNT1 A 1;
		"####" A 2 A_Explode(5,128,0,0,128);
		"####" A 20 A_Countdown;
		Loop;
	Death:
		"####" A 7;
		"####" A 6;
		Stop;
	}
}

class MutantBounceBall: Actor
{
	Default
	{
	Radius 4;
	Height 8;
	Scale 0.3;
	Projectile;
	Speed 12;
	DamageFunction (3*random(1,8));
	Gravity 0.125;
	RenderStyle "Add";
	BounceType "Grenade";
	BounceFactor 0.9;
	WallBounceFactor 0.9;
	BounceCount 5;
	DeathSound "supaproj/explode";
	BounceSound "supaproj/bounce";
	Obituary "$SUPABALL";
	-NOGRAVITY
	+THRUGHOST
	+WINDTHRUST
	}
	States
	{
	Spawn:
		SMBL AB 4 A_SpawnItemEx("SparkP",0,0,0,random(1,2),random(1,2),random(1,2),random(1,360));
		Loop;
	Death:
		TNT1 AAAAA 0 A_SpawnItemEx("SparkP",0,0,0,random(1,2),random(1,2),random(1,2),random(1,360));
		TNT1 A 0 A_SpawnItemEx("SparkFlareP");
		SMBL CDE 4;
		Stop;
	}
}

class RedBounceBall : MutantBounceBall
{
	Default
	{
	Scale 0.5;
	Speed 16;
	DamageFunction (4*random(1,8));
	BounceFactor 1.2;
	WallBounceFactor 1.2;
	BounceCount 7;
	Obituary "$ELSABALL";
	}
	States
	{
	Spawn:
		EMBL AB 4 A_SpawnItemEx("SparkR",0,0,0,random(1,2),random(1,2),random(1,2),random(1,360));
		Loop;
	Death:
		TNT1 AAAAA 0 A_SpawnItemEx("SparkR",0,0,0,random(1,2),random(1,2),random(1,2),random(1,360));
		TNT1 A 0 A_SpawnItemEx("SparkFlareR");
		EMBL CDE 4;
		Stop;
	}
}

class CleaverTrail1: Actor
{
	Default
	{
	+NOBLOCKMAP
	+NOGRAVITY
	+RANDOMIZE
	-SOLID
	}
	States
	{
	Spawn:
		CLVR A 1 A_FadeOut(0.04);
		Loop;
	}
}

class CleaverTrail2 : CleaverTrail1
{
	States
	{
	Spawn:
		CLVR B 1 A_FadeOut(0.04);
		Loop;
	}
}

class CleaverTrail3 : CleaverTrail1
{
	States
	{
	Spawn:
		CLVR C 1 A_FadeOut(0.04);
		Loop;
	}
}

class CleaverTrail4 : CleaverTrail1
{
	States
	{
	Spawn:
		CLVR D 1 A_FadeOut(0.04);
		Loop;
	}
}

class CleaverTrail5 : CleaverTrail1
{
	States
	{
	Spawn:
		CLVR E 1 A_FadeOut(0.04);
		Loop;
	}
}

class CleaverTrail6 : CleaverTrail1
{
	States
	{
	Spawn:
		CLVR F 1 A_FadeOut(0.04);
		Loop;
	}
}

class CleaverTrail7 : CleaverTrail1
{
	States
	{
	Spawn:
		CLVR G 1 A_FadeOut(0.04);
		Loop;
	}
}

class CleaverTrail8 : CleaverTrail1
{
	States
	{
	Spawn:
		CLVR H 1 A_FadeOut(0.04);
		Loop;
	}
}

class FlyingCleaver: Actor
{
	Default
	{
	Radius 8;
	Speed 15;
	DamageFunction (random(4,6));
	DamageType "None";
	DeathSound "dspfwood";
	PROJECTILE;
	+RANDOMIZE
	+RIPPER
	}
	States
	{
	Spawn:
		CLVR A 4 A_SpawnItem("CleaverTrail1");
		CLVR B 4 A_SpawnItem("CleaverTrail2");
		CLVR C 4 A_SpawnItem("CleaverTrail3");
		CLVR D 4 A_SpawnItem("CleaverTrail4");
		CLVR E 4 A_SpawnItem("CleaverTrail5");
		CLVR F 4 A_SpawnItem("CleaverTrail6");
		CLVR G 4 A_SpawnItem("CleaverTrail7");
		CLVR H 4 A_SpawnItem("CleaverTrail8");
		Loop;
	Death:
		CLVR I 0 A_SpawnItemEx("HackPuff");
		CLVR IIJJKKLL 1 A_FadeOut(0.2);
		Stop;
	Crash:
		CLVR II 1 A_StartSound("Cleaver/Crash",CHAN_VOICE);
		Goto Death;
	}
}

class HardFlyingCleaver : FlyingCleaver { Default { +MTHRUSPECIES } }

//OCCULT STUFF
class ZyklonBBomb : ClusterBomb
{
	Default
	{
	Speed 20;
    Gravity 0.3;
	DamageType "UndeadPoison";
	Obituary "$OBZYKLON";
	DeathSound "mortard1";
	SeeSound "mortarf1";
	GrenadeBase.Icon "HUD_ZBGN";
	}
	States
	{
	Spawn:
		ZBGN A 25 LIGHT("AODEPLASMATRAIL_3") A_SetAngle(angle + 359, SPF_INTERPOLATE);
		"####" A 0 A_Countdown;
		Loop;
	Death:
		ZBGN A 40;
		TNT1 A 0 A_AlertMonsters;
		"####" A 0 A_Scream;
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator");
		"####" A 0 A_StartSound("mortarg1");
		"####" A 0 LIGHT("AODEPLASMATRAIL_1") A_SpawnProjectile("PoisonCloudUndead",16,0,0,2,0);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("ZyklonBCloud",random(-16,16),random(-16,16),random(8,16),frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(0.0,1.0),0,128);
		Stop;
	}
}

class ZyklonBCloud : ParticleBase
{
	Default
	{
	Radius 48;
	Height 32;
	Scale 1.5;
	DamageFunction (2*random(1,8));
	PoisonDamage 2;
	DamageType "UndeadPoisonAmbience";
	Projectile;
	+WINDTHRUST
	RenderStyle "Translucent";
	Alpha 0.4;
	}
	States
	{
	Spawn:
		ZBGS A 2;
	Fade:
		"####" A 3 A_FadeOut(0.004);
		"####" A 0 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		Loop;
	}
}

class ZyklonZCloud : ZyklonBCloud
{
	Default
	{
	PoisonDamage 1;
	Alpha 0.3;
	}
	States
	{
	Spawn:
		ZBGS C 2;
	Fade:
		"####" C 3 A_FadeOut(0.004);
		"####" C 0 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		Loop;
	}
}

class ZyklonZCloud2 : ZyklonZCloud
{
	Default
	{
	Scale 1.0;
	DamageFunction (random(0,1));
	PoisonDamage 1;
	}
	States
	{
	Spawn:
		ZBGS C 1;
	Fade:
		"####" C 3 A_FadeOut(0.004);
		"####" C 0 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		Loop;
	}
}

class ZyklonZCloud3 : ZyklonZCloud2
{
	Default
	{
	Damage 0;
	PoisonDamage 0;
	}
	States
	{
	Spawn:
		ZBGS C 1;
	Fade:
		"####" C 3 A_FadeOut(0.04);
		"####" C 0 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		Loop;
	}
}

class ZyklonZCloud4 : ZyklonZCloud2 { Default { Scale 0.5; } }
class ZyklonZCloud5 : ZyklonZCloud3 { Default { Scale 0.5; } }

class ZyklonBBall: Actor
{
	Default
	{
	Radius 11;
	Height 8;
	Speed 15;
	DamageFunction (10*random(1,8));
	PoisonDamage 2;
	Scale 1.0;
	DamageType "UndeadPoisonAmbience";
	Projectile;
	+BRIGHT
	+RANDOMIZE
	+SEEKERMISSILE
	Alpha 1.0;
	RenderStyle "Translucent";
	SeeSound "tgfr1";
	DeathSound "tgfr2";
	}
	States
	{
	Spawn:
		ZART AB 5 LIGHT("AODEPLASMATRAIL_2") A_SeekerMissile(0, 15);
		Loop;
	Death:
		"####" C 1 LIGHT("AODEPLASMATRAIL_1");
		"####" CDEF 4 LIGHT("AODEPLASMATRAIL_2");
		Stop;
	}
}

class ZombieSoul: Actor
{
	Default
	{
	+NOBLOCKMAP
	+NOGRAVITY
	Renderstyle "Add";
	Alpha 0.3;
	Scale 0.5;
	SeeSound "ZSCREAM2";
	}
	States
	{
	Spawn:
		ZOFX ABCD 5 LIGHT("ZOMBIEFOG");
		Stop;
	}
}

class ZombieRocket : MiniRocket
{
	Default
	{
	Speed 20;
	DamageFunction (3*random(1,8));
	Renderstyle "Shadow";
	}
	States
	{
	Spawn:
		NMIS A 0 NODELAY A_StartSound("nazi/missileengine", CHAN_AUTO, CHANF_LOOPING, 0.3);
		NMIS A 1 BRIGHT LIGHT("OTTOFIRE") A_SpawnItemEx("ZombieFlame",random(-1,1),0,random(-1,1));
		Wait;
	Death:
		FRME A 1 BRIGHT LIGHT("OTTOFIRE") A_Explode(15,35);
		"####" A 0 A_StopSound(CHAN_AUTO);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator");
		"####" A 0 A_SpawnItemEx("KD_HL2SparkGenerator");
		"####" A 0 BRIGHT A_SpawnProjectile("PoisonCloudUndead",16,0,0,2,0);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("UndeadFartCloud",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("UndeadSmoke",random(-64,64),random(-64,64),random(-48,48),Vel.X,0,frandom(0.5,1),0,SXF_TRANSFERTRANSLATION,160);
		"####" BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("OTTOFIRE");
		Stop;
	}
}

class HardZombieRocket : ZombieRocket { Default { +MTHRUSPECIES } }

class ZombieVomit: Actor
{
	Default
	{
	Radius 8;
	Height 8;
	Speed 20;
	Gravity 0.5;
	FastSpeed 24;
	DamageFunction (random(3,8));
	Scale 0.45;
	Projectile;
	SeeSound "Blood/Spit";
	DeathSound "Blood/Impact";
	DamageType "UndeadPoison";
	Decal "ZBloodSmear";
	MaxTargetRange 256;
	-NOGRAVITY
	}
	States
	{
	Spawn:
		ZVOM A 0 A_SpawnItemEx("Zombie_FlyingBloodTrail", 0, 0, 0, 1);
		ZVOM ABCDEF 1 LIGHT("ZOMBIEFOG");
		Loop;
	Death:
		TNT1 A 0 BRIGHT A_SpawnProjectile("PoisonCloudUndead",16,0,0,2,0);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("UndeadSmoke",random(-64,64),random(-64,64),random(-48,48),Vel.X,0,frandom(0.5,1),0,SXF_TRANSFERTRANSLATION,160);
		"####" AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("ZyklonZCloud",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		"####" AAAAAAAAA 1 A_SpawnItemEx("Zombie_FlyingBlood", random(2,-2), random(2,-2), random(2,2), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class ZombieVomit_C3M6A: ZombieVomit
{
	Default
	{
    DamageFunction (random(1,4));
	}
    States
    {
    Death:
		TNT1 A 0 BRIGHT A_SpawnProjectile("PoisonCloudUndead",16,0,0,2,0);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("UndeadSmoke",random(-64,64),random(-64,64),random(-48,48),Vel.X,0,frandom(0.5,1),0,SXF_TRANSFERTRANSLATION,160);
		"####" AAAAAAAA 0 A_SpawnItemEx("ZyklonZCloud",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128); //2x less ZyklonClouds
		"####" AAAAAAAAA 1 A_SpawnItemEx("Zombie_FlyingBlood", random(2,-2), random(2,-2), random(2,2), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE);
		Stop;
    }
}

class ZFlyingHack : FlyingHack
{
	Default
	{
	Speed 16;
	-RIPPER
	DamageFunction (random(17, 31)); //since it is not a ripper anymore, and used only by a boss monster ZombieButcher --N00b
	DamageType "UndeadPoison";
	}
	States
	{
	Spawn:
		CLVR A 4 A_SpawnItem("CleaverTrail1");
		CLVR B 4 A_SpawnItem("CleaverTrail2");
		CLVR C 4 A_SpawnItem("CleaverTrail3");
		CLVR D 4 A_SpawnItem("CleaverTrail4");
		CLVR E 4 A_SpawnItem("CleaverTrail5");
		CLVR F 4 A_SpawnItem("CleaverTrail6");
		CLVR G 4 A_SpawnItem("CleaverTrail7");
		CLVR H 4 A_SpawnItem("CleaverTrail8");
		Loop;
	Death:
		CLVR I 0 A_SpawnItemEx("HackPuff");
		CLVR IIJJKKLL 1 A_FadeOut(0.2);
		Stop;
	Crash:
		CLVR II 1 A_StartSound("Cleaver/Crash",CHAN_VOICE);
		Goto Death;
	}
}

class ZHardFlyingHack : ZFlyingHack { Default { +MTHRUSPECIES Speed 24; } }

class ZHackPuff : HackPuff
{
	States
	{
	Death:
	XDeath:
		POOF AAAAAAAA 0 A_SpawnItemEx("ZyklonBCloud",random(-16,16),random(-16,16),random(8,16),frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(0.0,1.0),0,128);
		POOF A 3 A_StartSound("knife/hit");
		Goto Crash+1;
	}
}

class BloodSkullCloud: Actor
{
	Default
	{
	Radius 48;
	Height 32;
	Scale 1.1;
	Projectile;
	+WINDTHRUST
	RenderStyle "Translucent";
	Alpha 0.4;
	}
	States
	{
	Spawn:
		ZBGS B 2;
	Fade:
		"####" B 3 A_FadeOut(0.01);
		"####" B 0 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		Loop;
	}
}

class ZFlamebolt: Actor
{
	Default
	{
	Speed 10;
	Radius 16;
	DamageFunction (random(1,2));
	PoisonDamage 4;
	Scale 0.1;
	Alpha 0.9;
	Projectile;
	+BLOODLESSIMPACT
	+WINDTHRUST
	+ROLLSPRITE
	DamageType "UndeadPoisonAmbience";
	RenderStyle "Add";
	Decal "Scorch";
	SeeSound "STEAM_BURST";
	Obituary "$OBZYKF";
	}
	States
	{
	Spawn:
		"####" A 0 NODELAY A_Jump(256, "Flame1", "Flame2", "Flame3", "Flame4");
		Stop;
	Flame1:
		ZFLM A 0;
		Goto Animation;
	Flame2:
		ZFLM B 0;
		Goto Animation;
	Flame3:
		ZFLM C 0;
		Goto Animation;
	Flame4:
		ZFLM D 0;
		Goto Animation;
	Animation:
		"####" "#" 3 BRIGHT LIGHT("ZYKFLAMW") { A_SetScale(Scale.X+0.05); A_FadeOut(0.05); A_SetRoll(Roll+28, SPF_INTERPOLATE); }
		"####" "#" 0 A_Jump(128, "Smoke1", "Smoke2", "Smoke3");
		Goto Death;
	Smoke1:
		"####" "#" 0 A_SpawnItemEx("FlamerSmoke1");
		Goto Death;
	Smoke2:
		"####" "#" 0 A_SpawnItemEx("FlamerSmoke2");
		Goto Death;
	Smoke3:
		"####" "#" 0 A_SpawnItemEx("FlamerSmoke3");
		Goto Death;
	Death:
		"####" "#" 1 LIGHT("ZYKFLAMW") { A_SetScale(Scale.X+0.05); A_FadeOut(0.05); }
		Goto Death;
	}
}

class ZFlameball : ZFlamebolt
{
	Default
	{
	DamageFunction (10*random(1,8));
	Speed 12;
	Scale 0.3;
	Alpha 0.5;
	+SEEKERMISSILE
	SeeSound "flamer/napalm";
	DeathSound "nebelwerfer/xplode";
	}
	States
	{
	Spawn:
		ZBAL A 4 BRIGHT LIGHT("ZYKFLMW2")
			{
				A_SpawnItemEx("SparkG", random(-32,32), random(-32,32), random(-32,32), random(-2,2), random(-2,2), random(-2,2), random(0,359));
				A_SetRoll(Roll+24, SPF_INTERPOLATE);
				if (waterlevel > 0) {
					A_ScaleVelocity(0.0);
					return ResolveState("Death");
				}
				A_SeekerMissile(0, 7, SMF_PRECISE);
				return ResolveState(null);
			}
		"####" A 0 A_Jump(255, "Smoke1", "Smoke2", "Smoke3");
		Loop;
	Smoke1:
		"####" A 0 A_SpawnItemEx("FlamerSmoke1");
		"####" A 0 A_Jump (192,1,2);
		"####" A 0 A_SpawnItemEx("ZFlame1A");
		"####" A 0 A_SpawnItemEx("ZFlame1B");
		Goto Spawn;
	Smoke2:
		"####" A 0 A_SpawnItemEx("FlamerSmoke2");
		"####" A 0 A_Jump (192,1,2);
		"####" A 0 A_SpawnItemEx("ZFlame1A");
		"####" A 0 A_SpawnItemEx("ZFlame1B");
		Goto Spawn;
	Smoke3:
		"####" A 0 A_SpawnItemEx("FlamerSmoke3");
		"####" A 0 A_Jump (192,1,2);
		"####" A 0 A_SpawnItemEx("ZFlame1A");
		"####" A 0 A_SpawnItemEx("ZFlame1B");
		Goto Spawn;
	Death:
		"####" A 0 A_SpawnItemEx("NebSmokeFloor");
		"####" A 0 A_SpawnItemEx("NebSmokeMushroom",0,0,0);
		"####" A 0 A_SpawnItemEx("NebSmokePillar",0,0,0,0,0,2);
		"####" A 0 A_SetScale(1.0);
		"####" AAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("SparkG", random(-32,32), random(-32,32), random(-32,32), random(-4,4), random(-4,4), random(-4,4), random(0,359));
		"####" AAAAAAAAAAAA 0 A_SpawnItemEx("ZyklonBCloud",random(-64,64),random(-64,64),random(-48,48),0,0,0.1,0,128);
		ZBLX A 2 BRIGHT LIGHT("ZYKFLMW2") A_Explode(random(16,24),128,0,FALSE,64,0,0);
		ZBLX BCDEFGHIJK 2 BRIGHT LIGHT("ZYKFLMW2");
		Stop;
	}
}

/////////////////////////
// Mengele Projectiles //
/////////////////////////

class MengeleBomb : GrenadeBase
{
	Default
	{
	Radius 8;
	Height 16;
	Speed 20;
	DamageFunction (1*random(1,8));
	DamageType "Frag";
	Reactiontime 16; //for countdown
	Projectile;
	-NOGRAVITY
	-NOTELEPORT
	+WINDTHRUST
	+ROLLSPRITE
	+ROLLCENTER
	+GrenadeBase.DRAWINDICATOR
	Obituary "$OBGRENADE";
	BounceType "Doom";
	BounceFactor 0.6;
	WallBounceFactor 0.6;
	Gravity 0.4;
	SeeSound "clusterbomb/fire";
	BounceSound "grenade/bounce";
	GrenadeBase.Icon "HUD_THRM";
	}
	States
	{
	Spawn:
		THRM AAAABBBBB 2 A_SetRoll(roll + 8, SPF_INTERPOLATE);
		"####" A 0 A_Countdown;
		Loop;
	Death:
		THRM ABAB 8;
		"####" A 0 A_AlertMonsters;
		"####" B 0 A_StartSound("clusterbomb/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" ABABA 0 A_SpawnItemEx("ZyklonBCloud",random(-4,4),random(-4,4),random(4,4),frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(0.0,1.0),0,128);
		"####" ABABA 4 A_SpawnItemEx("MengeleBombFire", random(0,16), random(0,16), random(0,16), 0, 0, 0, 0, 0, 0);
		"####" A 0 A_SpawnitemEx("ZyklonSkull", 0, 0, 16, 0, 0, 0, 0, 0, 0);
		"####" AAAAAAAAAA 5 
				{
					A_Fadeout(0.1);
					A_SpawnItemEx("ZyklonBCloud",random(-4,4),random(-4,4),random(4,4),frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(0.0,1.0),0,128);
				}
		Stop;
	}
}

class MengeleBombFire: Actor
{
	Default
	{
	XScale 0.2;
	YScale 0.2;
	+NOBLOCKMAP
	Alpha 1.0;
	Renderstyle "Add";
	}
	States
	{
	Spawn:
		ZYZF ABCD 3 
		{
			A_SetScale(Scale.X*1.1, Scale.X*1.3);
			A_FadeOut(0.05);
		}
		Loop;
	}
}

class MengeleFireSpawner: Actor
{
	Default
	{
	Radius 8;
	Height 8;
	Speed 6;
	Damage 0;
	+BLOODLESSIMPACT
	+FLOORHUGGER
	+INVISIBLE //avoid spamming black dots with sprites filters enabled - ozy81
	+RIPPER
	Projectile;
	MissileHeight 0;
	}
	States
	{
	Spawn: 
		TNT1 A 6 A_SpawnProjectile("MengeleFire",8.0,frandom(-2.0,2.0),0,CMF_CHECKTARGETDEAD);
		Loop;
	Death:  
		TNT1 A 6;
		Stop;
	}
}

class MengeleFire: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Scale 1.2;
	Speed 0;
	DamageFunction (20*random(1,8));
	Projectile;
	RenderStyle "Add";
	Alpha 0.8;
	+BRIGHT
	+FLOORHUGGER
	+NOCLIP
	}
	States
	{
	Spawn:
		XXBF AB 3;
		XXBF C 0 A_StartSound("Goering/shotdth", 0, 0, 0.2);
		XXBF C 3 A_Explode(5,64,0);
		XXBF DEFGHIJKLMNOPQRST 3;
		Stop;
	}
}

//////// Mengele End ////////

class ZyklonGrenadePacket : GrenadeBase
{
	Default
	{
	Radius 8;
	Height 16;
	Speed 25;
	Scale 0.4;
	DamageFunction (1);
	DamageType "Frag";
	Projectile;
	-NOGRAVITY
	-NOTELEPORT
	+WINDTHRUST
	+GrenadeBase.DRAWINDICATOR
	Obituary "$OBGRENADE";
	GrenadeBase.Icon "HUD_ZTHW";
	}
	States
	{
	Spawn:
		ZTHW ABCDEFGH 2;
		Loop;
	Death:
		EXN2 A 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		EXN2 A 2;
		TNT1 A 0 A_AlertMonsters;
		"####" A 0 A_Explode(8,96);
		"####" A 0 A_SpawnItemEx("ZyklonBlazeFX2");
		"####" A 2 Radius_Quake(10,10,0,16,0);
		"####" A 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		"####" ABABA 0 A_SpawnItemEx("ZyklonBCloud",random(-4,4),random(-4,4),random(4,4),frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(0.0,1.0),0,128);
		"####" AAAAAAAAAA 5 
				{
					A_SpawnItemEx("ZyklonBCloud",random(-4,4),random(-4,4),random(4,4),frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(0.0,1.0),0,128);
				}
		Stop;
	}
}

class ZFlameball_Scenery : ZFlameball { Default { +NEVERTARGET } }

class UndeadFartCloud: Actor
{
	Default
	{
	Radius 2;
	Height 2;
	DamageType "UndeadPoison";
	+NOINTERACTION
	+WINDTHRUST
	RenderStyle "Translucent";
	Alpha 0.3;
	}
	States
	{
	Spawn:
		ZBGS DDDDD 2;
	Fade:
		"####" DDDDD 2 A_FadeOut (0.05);
		"####" DDDDD 2 A_FadeIn (0.05);
		"####" DDDDD 2 A_FadeOut (0.05);
		"####" DDDDD 2 A_FadeIn (0.05);
		"####" DDDDD 2 A_FadeOut (0.05);
		"####" DDDDD 2 A_FadeIn (0.05);
		"####" DDDDD 2 A_FadeOut (0.05);
		"####" DDDDD 2 A_FadeIn (0.05);
		"####" DDDDD 2 A_FadeOut (0.05);
		Stop;
	}
}

class UndeadSmoke : MutantSmoke { Default { StencilColor "05 05 05"; } }

class PoisonCloudUndead : GrenadeBase
{
	Default
	{
	Radius 20;
	Height 30;
	Reactiontime 2;
	DamageType "UndeadPoison";
	RenderStyle "Translucent";
	Alpha 0.6;
	+BLOCKEDBYSOLIDACTORS
	+BLOODLESSIMPACT
	+CANBLAST
	+DONTSPLASH
	+DONTTHRUST
	+DROPOFF
	+FOILINVUL
	+NOBLOCKMAP
	+NODAMAGETHRUST
	+NOGRAVITY
	GrenadeBase.FearDistance 96;
	}
	States
	{
	Spawn:
		TNT1 A 1;
		"####" A 4 A_Explode(3,64,0,0,96);
		"####" A 20 A_Countdown;
		Loop;
	Death:
		"####" A 7;
		"####" A 6;
		Stop;
	}
}

class AODEPlasmaBlast: Actor
{
	Default
	{
	Radius 13;
	Height 8;
	Speed 25;
	DamageFunction (3*random(1,8));
	Projectile;
	DamageType "Disintegrate";
	Scale .75;
	+BLOODLESSIMPACT
	+BRIGHT
	+NOEXTREMEDEATH
	+RANDOMIZE
	RenderStyle "Add";
	Alpha 0.75;
	SeeSound "electricplasma/shoot";
	DeathSound "electricplasma/hit";
	Decal "SwordLightning";
	}
	States
	{
	Spawn:
		EBLT GH 0 A_SpawnProjectile("AODEPlasmaBlastTrail", 0, 0, 0);
		"####" GH 2 A_BishopMissileWeave;
		Loop;
	Death:
		"####" IJK 3;
		Stop;
	}
}

class AODEPlasmaBlastTrail: Actor
{
	Default
	{
	Radius 13;
	Height 8;
	Speed 0;
	Damage 0;
	Projectile;
	+BRIGHT
	+RANDOMIZE
	RenderStyle "Add";
	Alpha 0.75;
	}
	States
	{
	Spawn:
		EBLT ABC 3 A_BishopMissileWeave;
		Goto Death;
	Death:
		"####" DEF 4 A_FadeOut(0.25);
		Loop;
	}
}

class AODEPainPlasmaBlast : AODEPlasmaBlast { Default { Speed 15; } }

class AODEBlastPod: Actor //From the Vore actor - Projectile sprites by Vader - Tweaked by Ozy81
{
	Default
	{
	Radius 16;
	Height 16;
	Speed 6;
	FastSpeed 9;
	DamageFunction (random(10,20));
	Projectile;
	+BRIGHT
	+SEEKERMISSILE
	RenderStyle "Add";
	Alpha 0.9;
	SeeSound "aode/fire";
	DeathSound "aode/hit";
	Decal "BFGLightning";
	Scale 2.5;
	}
	States
	{
	Spawn:
		CNOB A 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" A 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" A 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" A 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" B 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" B 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" B 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" B 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" C 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" C 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" C 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" C 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" C 0 A_JumpIfTargetInLOS(1, 360, 1);
		Loop;
		"####" A 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" A 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" A 0 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" A 1 A_SpawnItemEx("AODEBlastPodTrail", random(5, -5), 0, random(5, -1), 0, 0, 0, 180);
		"####" C 0 A_JumpIfTargetInLOS(1, 360, 1);
		Goto Spawn+4;
		"####" BBB 0 A_SeekerMissile(90, 90, 2);
		Goto Spawn+4;
	Death:
		"####" D 0 A_Explode(30, 90);
		"####" DEFGHI 4;
		Stop;
	}
}

class AODEBlastPodTrail: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Speed 0;
	Projectile;
	RenderStyle "Add";
	Alpha 0.9;
	+NOCLIP
	}
	States
	{
	Spawn:
	Death:
		TNT1 A 3;
		CNOT ABCDE 3 BRIGHT;
		Stop;
	}
}

class AODEClone1: Actor
{
	Default
	{
	Radius 48;
	Height 96;
	Speed 0;
	Damage 0;
	Mass 2000;
	RenderStyle "Translucent";
	Alpha 0.3;
	PROJECTILE;
	+FLOAT
	+FLOATBOB
	+NOGRAVITY
	}
	States
	{
	Spawn:
		AODE A 10 A_Fadeout(0.005);
		Stop;
	}
}

class AODEClone2 : AODEClone1
{
	States
	{
	Spawn:
		AODE B 10 A_Fadeout(0.005);
		Stop;
	}
}

class AODEClone3 : AODEClone1
{
	States
	{
	Spawn:
		AODE C 10 A_Fadeout(0.005);
		Stop;
	}
}

class AODEClone4 : AODEClone1
{
	States
	{
	Spawn:
		AODE D 10 A_Fadeout(0.005);
		Stop;
	}
}

class SmokeMonsterProjectile: Actor
{
	Default
	{
	Height 32;
	Radius 16;
	Speed 10;
	Projectile;
	+NOGRAVITY
	+THRUSPECIES
	Species "Smoke";
	}
	States
	{
	Spawn:
		TNT1 AAAAAA 0 A_SpawnItemEx("MonsterHole", 0, 0, 8, Random(-1, 1), Random(-1, 1), Random(-1,1), Random(1,360), SXF_SETMASTER);
		TNT1 A 1;
		Loop;
	}
}

class MonsterHole : Appendage
{
	Default
	{
	+NOCLIP
	+NOGRAVITY
	+SHOOTABLE
	+THRUSPECIES
	RenderStyle "Translucent";
	Alpha 0.3;
	Scale .75;
	Species "Smoke";
	}
	States
	{
	Spawn:
		TNT1 A 2;
		SMMO ABCDEFGHIJKLMNOPQ 2;
		Stop;
	}
}

class MonsterHole2 : MonsterHole
{
	Default
	{
	Scale 1.0;
	+RANDOMIZE
	Species "Zombie";
	}
	States
	{
	Spawn:
		TNT1 A 2 A_Jump(64,"SpawnAlt"); //prevent doing huge amount of damage - ozy81
		TNT1 A 0 {
			if (!CheckRange(boa_sfxlod, true))
			{
				A_SpawnItemEx("ZyklonZCloud4",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360),128);
			}
		}
		ZMMO ABCDEFGHIJKLMNOPQ 2;
		Stop;
	Spawn.Alt:
		TNT1 A 0 {
			if (!CheckRange(boa_sfxlod, true))
			{
				A_SpawnItemEx("ZyklonZCloud5",0,0,8,random(-1,1),random(-1,1),random(-1,1),random(1,360),128);
			}
		}
		ZMMO ABCDEFGHIJKLMNOPQ 2;
		Stop;
	}
}

class ZyklonCritter: Actor
{
	Default
	{
	+DONTSQUASH
	+NOBLOCKMAP
	+NOGRAVITY
	+NOLIFTDROP
	+NONSHOOTABLE
	+NOTARGET
	+NOTELEOTHER
	+NOTIMEFREEZE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(255,1,2);
		TNT1 A -1 A_SpawnItemEx("ZBatFamiliar",random(-4,4),random(-4,4),0,0,SXF_NOCHECKPOSITION,0);
		TNT1 A -1 A_SpawnItemEx("ZyklonSkull",random(-4,4),random(-4,4),0,0,SXF_NOCHECKPOSITION,0);
		Stop;
	}
}

class SkullBloodDrip : ParticleBase
{
	Default
	{
	Radius 1;
	Height 4;
	+DONTSPLASH
	+MISSILE
	Scale 0.4;
	Gravity 0.7;
	}
	States
	{
	Spawn:
		BDR2 A 50;
		Stop;
	}
}

class BloodSpit: Actor
{
	Default
	{
	Radius 6;
	Height 6;
	Speed 17;
	DamageFunction (3*random(1,8));
	Scale 0.5;
	SeeSound "Blood/Spit";
	DeathSound "Blood/Impact";
	Projectile;
	Decal "BloodSplat";
	}
	States
	{
	Spawn:
		BSHT AB 2 A_SpawnItemEx("BloodSpitTrail");
		Loop;
	Death:
		BSHT CD 6;
		Stop;
	}
}

class BloodSpitTrail: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Projectile;
	RenderStyle "Translucent";
	Alpha 0.8;
	Scale 0.3;
	+NOCLIP
	}
	States
	{
	Spawn:
		BSHT CD 4;
		Stop;
	}
}

class ZSkullBloodDrip : SkullBloodDrip
{
	States
	{
	Spawn:
		BDR3 A 50;
		Stop;
	}
}

class ZBloodSpit : BloodSpit
{
	Default
	{
	Speed 24;
	PoisonDamage 2;
	DamageType "UndeadPoisonAmbience";
	Decal "ZBloodSplat";
	}
	States
	{
	Spawn:
		BSHZ AB 2 A_SpawnItemEx("ZBloodSpitTrail");
		Loop;
	Death:
		BSHZ CD 6;
		Stop;
	}
}

class ZBloodSpitTrail : BloodSpitTrail
{
	States
	{
	Spawn:
		BSHZ CD 4;
		Stop;
	}
}

//CRITTERS STUFF
//UPDATE: These blockers now are needed ONLY for blocking spiders, bats & scorpions, so we still need them - ozy81
class ActorBlocker: Actor
{
	Default
	{
	//$Category Monsters (BoA)/Behavior
	//$Title Critters Blocker (large radius)
	//$Color 4
	Height 1;
	Radius 256;
	Mass 99999999;
	Species "Player";
	+DONTSPLASH
	+GHOST
	+NOGRAVITY
	+SOLID
	+THRUSPECIES
	}
}

//we need it smaller for narrow places/situations
class ActorBlockerMini : ActorBlocker
{
	Default
	{
	//$Category Monsters (BoA)/Behavior
	//$Title Critters Blocker (small radius)
	//$Color 4
	Radius 32;
	}
}

class Gibs1: Actor
{
	Default
	{
	Radius 10;
	Height 10;
	Mass 6;
	Speed 14;
	BounceType "Doom";
	+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13);
		GIB1 AB 0 A_Jump(256,"End");
		GIB2 ABC 0 A_Jump(256,"End");
		GIB3 BC 0 A_Jump(256,"End");
		GIB4 ABC 0 A_Jump(256,"End");
		GIB5 ABC 0 A_Jump(256,"End");
	End:
		"####" "#######" 4 A_SpawnProjectile("BloodFlySM",0,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(-100,100));
		"####" "#" 700 A_SpawnProjectile("BloodFlySM",0,0,random(0,360),CMF_AIMDIRECTION|CMF_BADPITCH,random(-100,100));
		Stop;
	}
}

class BloodTrail: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Projectile;
	+CLIENTSIDEONLY
	+NOCLIP
	}
	States
	{
	Spawn:
		BLUD CBA 3;
		Stop;
	}
}

class BloodTrailSM : BloodTrail { Default { Scale 0.5; } }

class BloodFly: Actor
{
	Default
	{
	Radius 0;
	Height 0;
	Mass 50;
	Speed 6;
	Projectile;
	-NOGRAVITY
	+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		BLUD C 2 A_SpawnItemEx("BloodTrail");
		Loop;
	Death:
		BLUD CBA 8;
		Stop;
	}
}

class BloodFly2 : BloodFly
{
	Default
	{
	Scale 0.6;
	Speed 8;
	}
	States
	{
	Spawn:
		BLUD C 1;
		Loop;
	Death:
		BLUD CBA 4;
		Stop;
	}
}

class BloodFlySM : BloodFly
{
	Default
	{
	Scale 0.5;
	Mass 100;
	Speed 8;
	}
	States
	{
	Spawn:
		BLUD C 1 A_SpawnItemEx("BloodTrailSM");
		Loop;
	}
}

class ScorpionSpit: Actor
{
	Default
	{
	Scale 0.5;
	Radius 13;
	Height 8;
	Speed 28;
	VSpeed 20;
	DamageFunction (6*random(1,8));
	Projectile;
	Gravity 0.4;
	DamageType "PoisonCloud";
	PoisonDamage 20;
	SeeSound "scorpion/spit";
	-NOGRAVITY
	}
	States
	{
	Spawn:
		SPIT A 0 NODELAY A_SetScale(Scale.X + frandom(-0.05,0.05),Scale.Y + frandom(-0.05,0.05));
		Goto See;
	See:
		SPIT A 3 A_SpawnItemEx("NashGore_FlyingBlood",0,0,0,0,0,0,0,128);
		Loop;
	}
}

class ScorpionChunk: Actor
{
	Default
	{
	Radius 8;
	Height 8;
	Scale 0.6;
	Mass 50;
	BounceType "Doom";
	BounceCount 1;
	Gravity 0.6;
	DeathSound "gore/splat";
	Projectile;
	-NOGRAVITY
	+BOUNCEAUTOOFF
	+CANBOUNCEWATER
	+DONTSPLASH
	+FORCEXYBILLBOARD
	+MOVEWITHSECTOR
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(Scale.X + frandom(-0.1,0.1),Scale.Y + frandom(-0.1,0.1));
		TNT1 A 0 A_Jump(256,1,2,3,4,5,6,7);
		SCRG ABCDEFG 0 A_Jump(256,"Chunk");
		Stop;
	Chunk:
		SCRG "#" 6 A_SpawnItemEx("ScorpionFlyingBlood",random(-1,1),random(-1,1));
		Loop;
	Death:
		SCRG "#" 0 A_SpawnItemEx("ScorpionBlood");
		SCRG "#" 250 A_CheckSight("Vanish");
		Wait;
	Vanish:
		TNT1 A 0;
		Stop;
	}
}

class BigScorpionChunk : ScorpionChunk
{
	Default
	{
	Scale 1.1;
	Mass 60;
	Gravity 0.8;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(Scale.X + frandom(-0.1,0.1),Scale.Y + frandom(-0.1,0.1));
		TNT1 A 0 A_Jump(256,1,2,3,4,5,6,7);
		SC2G ABCDEFG 0 A_Jump(256,"Chunk");
		Stop;
	Chunk:
		SC2G "#" 6 A_SpawnItemEx("NashGore_FlyingBlood",random(-1,1),random(-1,1));
		Loop;
	Death:
		SC2G "#" 0 A_SpawnItemEx("NashGore_Blood");
		SC2G "#" 250 A_CheckSight("Vanish");
		Wait;
	}
}

class MKScorpionChunk : ScorpionChunk
{
	Default
	{
	Scale 1.5;
	Mass 70;
	Gravity 0.9;
	}
}

//LOPER STUFF
class LoperZap: Actor
{
	Default
	{
	+ALLOWPARTICLES
	+NOBLOCKMAP
	+NOGRAVITY
	+NOTELEPORT
	Mass 0;
	RenderStyle "Translucent";
	Alpha 0.6;
	Scale 0.5;
	Translation "112:127=192:200";
	}
	States
	{
	Spawn:
		TNT1 AA 0 A_SpawnItemEx("TPortLightningWaveSpawner2",0,0,8,0,0,0,0,0,160);
		EBLT HIG 3 BRIGHT A_SpawnItemEx("SparkB",0,0,8,0,0,1,0,0,160);
		Stop;
	}
}

class ZTracer: Actor
{
	Default
	{
	Radius 5;
	Height 5;
	Speed 15;
	ReactionTime 175;
	DamageFunction (5*random(1,8));
	DamageType "Fire";
	RenderStyle "Add";
	Alpha 0.67;
	Projectile;
	-NOGRAVITY
	+BRIGHT
	+FLOORHUGGER
	Translation "112:127=192:200";
	Obituary "$LOPRHIT3";
	SeeSound "electricplasma/shoot";
	DeathSound "electricplasma/hit";
	Decal "SwordLightning";
	}
	States
	{
	Spawn:
	See:
		TNT1 A 1 LIGHT("LOPERLIT");
		"####" A 0 A_Countdown;
		"####" A 0 A_SpawnProjectile("ZTracerPuff",0,0,0,0);
		Loop;
	Death:
		EBLT G 4;
		"####" H 4 A_Explode(16,16);
		"####" IJK 3;
		Stop;
	}
}

class HardZTracer : ZTracer { Default { +MTHRUSPECIES } }

class ZTracerPuff: Actor
{
	Default
	{
	Radius 1;
	Height 1;
	Speed 0;
	RenderStyle "Add";
	DamageType "Fire";
	Alpha 0.67;
	Projectile;
	-NOGRAVITY
	+FLOORHUGGER
	+RANDOMIZE
	Translation "112:127=192:200";
	}
	States
	{
	Spawn:
		TNT1 AA 0 A_SpawnItemEx("TPortLightningWaveSpawner2",0,0,8,0,0,0,0,0,160);
		"####" AAAAAAAAA 0 A_SpawnItemEx("SparkB",0,0,8,0,0,1,0,0,160);
		EBLT ABCDEFEDCB 3 BRIGHT A_Explode(2,4);
		Stop;
	}
}

//Support Actors from TPortal//
class VisualSpecialEffect: Actor
{
	Default
	{
	+CLIENTSIDEONLY
	+FORCEXYBILLBOARD
	+NOBLOCKMAP
	+NOCLIP
	+NOGRAVITY
	+NOINTERACTION
	+NOTELEPORT
	}
}

class TPortLightning : VisualSpecialEffect
{
	Default
	{
	RenderStyle "Add";
	Alpha 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0; // Huh, that's the jump...
		"####" A 0 A_Jump(256,random(1,72));
	Select:
		BLL1 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
		BLL2 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
		BLL3 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
		BLL4 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
	Fade:
		"----" A 1 BRIGHT A_FadeOut(0.15);
		Loop;
	}
}

class MouthLightning : TPortLightning
{
	Default
	{
	Reactiontime 28;
	}
	States
	{
	Spawn:
		TESH ABBABAABABAABBAB 1 { A_Countdown(); A_RadiusThrust(3000, 256); A_RadiusThrust(256, 128, RTF_THRUSTZ); }
		Loop;
	Death:
		"####" "#" 1 BRIGHT A_FadeOut(0.15);
		Loop;
	}
}

class TPortLightningSmall : TPortLightning { Default { Scale 0.1; } }
class TPortLightningMedium : TPortLightning { Default { Scale 0.2; } }
class TPortLightningLarge : TPortLightning { Default { Scale 0.3; } }
class TPortLightningHuge : TPortLightning { Default { Scale 0.4; } }

class TPortLightningSmallH : TPortLightning { Default { Scale 1.1; } }
class TPortLightningMediumH : TPortLightning { Default { Scale 2.2; } }
class TPortLightningLargeH : TPortLightning { Default { Scale 3.3; } }
class TPortLightningHugeH : TPortLightning { Default { Scale 4.4; } }

// A wave of lightning
class TPortLightningWave : VisualSpecialEffect
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_SpawnItemEx("TPortLightningSmall",random(-2,2),random(-2,2),random(-2,2),0,0,0,0,0,32);
		"####" A 0 A_SpawnItemEx("TPortLightningMedium",random(-3,3),random(-3,3),random(-3,3),0,0,0,0,0,56);
		"####" A 0 A_SpawnItemEx("TPortLightningLarge",random(-4,4),random(-4,4),random(-3,3),0,0,0,0,0,96);
		"####" A 0 A_SpawnItemEx("TPortLightningHuge",random(-5,5),random(-5,5),random(-5,5),0,0,0,0,0,144);
		Stop;
	}
}

class TPortLightningWave2 : VisualSpecialEffect
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_SpawnItemEx("TPortLightningSmallH",random(-2,2),random(-2,2),random(-2,2),0,0,0,0,0,32);
		"####" A 0 A_SpawnItemEx("TPortLightningMediumH",random(-3,3),random(-3,3),random(-3,3),0,0,0,0,0,56);
		"####" A 0 A_SpawnItemEx("TPortLightningLargeH",random(-4,4),random(-4,4),random(-3,3),0,0,0,0,0,96);
		"####" A 0 A_SpawnItemEx("TPortLightningHugeH",random(-5,5),random(-5,5),random(-5,5),0,0,0,0,0,144);
		Stop;
	}
}

class TPortLightningWaveZap : VisualSpecialEffect
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_SpawnItemEx("TPortLightningSmall",random(-2,2),random(-2,2),random(-2,2),0,0,0,0,0,32);
		"####" A 0 A_SpawnItemEx("TPortLightningSmall",random(-3,3),random(-3,3),random(-3,3),0,0,0,0,0,56);
		"####" A 0 A_SpawnItemEx("TPortLightningSmall",random(-4,4),random(-4,4),random(-3,3),0,0,0,0,0,96);
		"####" A 0 A_SpawnItemEx("TPortLightningSmall",random(-5,5),random(-5,5),random(-5,5),0,0,0,0,0,144);
		Stop;
	}
}

// Spawns lightning waves
class TPortLightningWaveSpawner : VisualSpecialEffect
{
	Default
	{
	+RANDOMIZE
	}
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_StartSound("TPortalZap");
		"####" A 2 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave");
		"####" A 1 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave");
		"####" A 3 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave");
		"####" A 5 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave");
		"####" A 1 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave");
		"####" A 2 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave");
		"####" A 4 A_SpawnItem("TPortLightningWave");
		Stop;
	}
}

class TPortLightningWaveSpawnerH : TPortLightningWaveSpawner
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_StartSound("TPortalZap");
		"####" A 2 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave2");
		"####" A 1 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave2");
		"####" A 3 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave2");
		"####" A 5 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave2");
		"####" A 1 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave2");
		"####" A 2 LIGHT("TPortZap") A_SpawnItem("TPortLightningWave2");
		"####" A 4 A_SpawnItem("TPortLightningWave2");
		Stop;
	}
}

class TPortLightningWaveSpawner2 : VisualSpecialEffect
{
	Default
	{
	+RANDOMIZE
	}
	States
	{
	Spawn:
		TNT1 A 0;
		"####" A 0 A_StartSound("TPortalZap");
		"####" A 2 A_SpawnItem("TPortLightningWaveZap");
		"####" A 1 A_SpawnItem("TPortLightningWaveZap");
		"####" A 3 A_SpawnItem("TPortLightningWaveZap");
		"####" A 5 A_SpawnItem("TPortLightningWaveZap");
		"####" A 1 A_SpawnItem("TPortLightningWaveZap");
		"####" A 2 A_SpawnItem("TPortLightningWaveZap");
		"####" A 4 A_SpawnItem("TPortLightningWave");
		Stop;
	}
}

class ReflectiveOrb : VisualSpecialEffect
{
	Default
	{
	RenderStyle "Add";
	Alpha 0.8;
	Scale 1.25;
	ReactionTime 48;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_SetTranslucent(0.1,1);
		TNT1 A 0 A_StartSound("hitler/orbapp", CHAN_AUTO, CHANF_LOOPING, 1.0);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.2,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.3,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.4,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.5,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.6,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.7,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.8,1);
	SpawnCreepy:
		ORBP A 0 A_SpawnItemEx("CreepyGhostSpawner2", 0, 0, 64, 0, 0, 0, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
	SpawnLoop:
		ORBP ABCDCB 1 BRIGHT A_Countdown;
		Loop;
	Death:
		TNT1 A 0 A_StopSound(CHAN_AUTO);
		TNT1 A 0 A_StartSound("hitler/orbfade", CHAN_AUTO, 1.0);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.8,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.7,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.6,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.5,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.4,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.3,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.2,1);
		ORBP ABCDCB 1 BRIGHT;
		TNT1 A 0 A_SetTranslucent(0.1,1);
		TNT1 A 1 A_RemoveChildren(TRUE, RMVF_MISC);
		Stop;
	}
}

//UNSORTED
class SleepEffect: Actor
{
	Default
	{
	DistanceCheck "boa_sfxlod";
	+CLIENTSIDEONLY
	+FORCEXYBILLBOARD
	+NOBLOCKMAP
	+WINDTHRUST
	+NOGRAVITY
	+FLOATBOB
	-SOLID
	RenderStyle "Translucent";
	Alpha 0.001;
	Scale 0.2;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(Scale.X*(frandom(0.7,1.0)), Scale.Y*(frandom(0.7,1.0)));
		TNT1 A 0 A_Jump(256,1,2);
		SLZZ A 0 A_Jump(256,"End");
		SLZZ A 0 A_Jump(256,"End");
	End:
		"####" AAAAAAAAAAAAAA 1 A_FadeIn(0.05);
		"####" AAAAAAAAAAAAAAAAAAAAAAAAA 2 {A_FadeOut(0.03); A_SetScale(Scale.X*1.05, Scale.Y*1.05);}
		Stop;
	}
}

class NaziMedPow : RegenPowerup
{
	Default
	{
		Powerup.Duration -20;
		Powerup.Strength 1;
	}
}

class NaziMedicBox : PowerupGiver
{
	Default
	{
	Scale 0.65;
	Inventory.MaxAmount 1;
	Inventory.PickupMessage "$NMBOX";
	Powerup.Type "NaziMedPow";
	-COUNTITEM
	-INVENTORY.INVBAR
	+INVENTORY.ALWAYSPICKUP
	+INVENTORY.AUTOACTIVATE
	}
	States
	{
	Spawn:
		MBOX A -1;
		Stop;
	}
}

class ToolBox: Actor
{
	Default
	{
	Scale 0.65;
	}
	States
	{
	Spawn:
		TBOX A -1;
		Stop;
	}
}

class HitlerSuitScrap: Actor
{
	Default
	{
	Scale 1.2;
	}
	States
	{
	Spawn:
		HIT2 AB 20;
		"####" C -1;
		Stop;
	}
}