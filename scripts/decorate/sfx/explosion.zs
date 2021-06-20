/*
 * Copyright (c) 2017-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer,
 *                         Talon1024
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

// -----------------------------------------------------------------------------
// Half-Life 2 styled explosions
//
// Made by KeksDose, December 1 2013
//
// These are smoky explosions with a quick flash. You can directly spawn them
// from either ACS or DECORATE, or place them in a map with the "Dormant" flag
// and simply activate them with a line special.
// -----------------------------------------------------------------------------

class GeneralExplosion_Medium : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Explosion Effect (activatable)
	//$Color 12
	//$Arg0 "Quake"
	//$Arg0Type 11
	//$Arg0Enum { 0 = "Yes"; 1 = "No"; }
	//$Arg1 "Sound"
	//$Arg1Type 11
	//$Arg1Enum { 0 = "Yes"; 1 = "No"; }
	+NOINTERACTION
	DamageType "Explosion";
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_JumpIf(Args[1], 2);
		TNT1 A 0 A_StartSound("EXPLOSION_SOUND", CHAN_AUTO, 0, 0.75, ATTN_IDLE);
		TNT1 A 0 A_JumpIf(!Args[0], "Quake");
		Goto Explosion;
	Quake:
		TNT1 A 0 Radius_Quake(10,10,0,16,0);
		Goto Explosion;
	Explosion:
		TNT1 A 0 A_Explode(100, 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}

class FriendlyExplosion_Medium : SwitchableDecoration
{
	Default
	{
	+NOINTERACTION
	DamageType "FriendlyFrag";
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("EXPLOSION_SOUND", CHAN_AUTO, 0, 0.75, ATTN_IDLE);
	Quake:
		TNT1 A 0 Radius_Quake(10,10,0,16,0);
		Goto Explosion;
	Explosion:
		TNT1 A 0 A_Explode(100, 192, 0, TRUE);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}

class EnemyExplosion_Medium : SwitchableDecoration
{
	Default
	{
	+NOINTERACTION
	DamageType "EnemyFrag";
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("EXPLOSION_SOUND", CHAN_AUTO, 0,  0.75, ATTN_IDLE);
	Quake:
		TNT1 A 0 Radius_Quake(10,10,0,16,0);
		Goto Explosion;
	Explosion:
		TNT1 A 0 A_Explode(50, 192, 0, TRUE);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}

class KD_HL2GeneratorBase: Actor { Default { +NOINTERACTION } }

class KD_HL2ExplosionBase : SmokeBase
{
	Default
	{
	+FORCEXYBILLBOARD
	+NOINTERACTION
	RenderStyle "Add";
	Alpha 0.99;
	}
}

class KD_HL2Flash : KD_HL2ExplosionBase
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(frandom(0.5, 0.8) * Scale.X);
		TNT1 A 0 A_Jump(256,1,2);
		EXN1 AB 0 LIGHT("FireSpawnerSmall") A_Jump(256,"Fade");
	Fade:
		"####" "#" 1 BRIGHT LIGHT("FireSpawnerLarge") A_FadeOut(frandom(0.05, 0.10) * (6 - boa_boomswitch));
		Loop;
	}
}

class KD_HL2Smoke : KD_HL2ExplosionBase
{
	Default
	{
	RenderStyle "Translucent";
	Alpha 0.8;
	}
	States
	{
	Spawn:
		TSMK A 1 A_SetScale(Scale.X + frandom(0.005, 0.015));
		TSMK A 0 A_FadeOut(frandom(0.006, 0.012) * (6 - boa_boomswitch),FTF_REMOVE);
		Loop;
	}
}

class KD_HL2SmokeGenerator : KD_HL2GeneratorBase
{
	States
	{
	Spawn:
		TNT1 A 0 A_Countdown;
		TNT1 A 0 A_SpawnItemEx("KD_HL2Smoke", 0, 0, 0, 0.0,frandom(0.0, 2.5) * Scale.X,frandom(-2.0, 2.0) * Scale.X, random(0, 359),SXF_CLIENTSIDE | SXF_TRANSFERSCALE, 30);
		Loop;
	}
}

class KD_HL2Spark : KD_HL2ExplosionBase
{
	Default
	{
	+BRIGHT
	}
	States
	{
	Spawn:
		PAO1 A 5 NODELAY LIGHT("BOACLMN1") A_SetScale(frandom(0.07, 0.1) * Scale.X);
	Drop:
		PAO1 A 0 A_ChangeVelocity(frandom(0.98, 0.99) * Vel.X,frandom(0.98, 0.99) * Vel.Y,Vel.Z - frandom(0.2, 0.5), CVF_REPLACE);
		PAO1 A 1 A_SetScale(Scale.X - 0.002);
		PAO1 A 0 A_FadeOut(0.01 * (6 - boa_boomswitch),FTF_REMOVE);
		Loop;
	}
}

class KD_HL2SparkGenerator : KD_HL2GeneratorBase
{
	States
	{
	Spawn:
		TNT1 A 0 A_Countdown;
		TNT1 AAA 0 A_SpawnItemEx("KD_HL2Spark", 0, 0, 0, 0.0,frandom(0.0, 13.5) * Scale.X,frandom(-1.0, 9.5) * Scale.X, random(0, 359),SXF_CLIENTSIDE | SXF_TRANSFERSCALE, 60);
		Loop;
	}
}

//////////////////////////////////////
// Variants in Size by Tormentor667 //
//////////////////////////////////////
class GeneralExplosion_Large : GeneralExplosion_Medium { Default { Scale 2.0; } }
class GeneralExplosion_Small : GeneralExplosion_Medium { Default { Scale 0.5; } }
class GeneralExplosion_Nazis : GeneralExplosion_Medium
{
	Default
	{
	Scale 0.5;
	}
	States
	{
	Explosion:
		TNT1 A 0 A_Explode(25, 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}

class GeneralExplosion_NazisL : GeneralExplosion_Medium
{
	Default
	{
	Scale 2.0;
	}
	States
	{
	Explosion:
		TNT1 A 0 A_Explode(25, 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}

//////////////////////////////////////
// Variant for Astrostein ////////////
//////////////////////////////////////
class KD_HL2FlashAstrostein : KD_HL2ExplosionBase
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(frandom(0.5, 0.8) * Scale.X);
		TNT1 A 0 A_Jump(256,1,2);
		EXN2 AB 0 LIGHT("FireSpawnerSmall") A_Jump(256,"Fade");
	Fade:
		"####" "#" 1 BRIGHT LIGHT("AstrosteinExplosionSpawnerLarge") A_FadeOut(frandom(0.05, 0.10),FTF_REMOVE);
		Wait;
	}
}

class AstrosteinExplosion_Medium : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Astrostein Explosion Effect (activatable)
	//$Color 12
	+NOINTERACTION
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("astrostein/explosion");
		TNT1 A 0 Radius_Quake(10,10,0,16,0);
		TNT1 A 0 A_Explode(100, 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch==0,"EndSpawn");
		TNT1 A 0 A_SpawnItemEx("KD_HL2FlashAstrostein", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveGreen", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class AstrosteinExplosion_Decorative : AstrosteinExplosion_Medium
{
	Default
	{
	//$Title Astrostein Explosion Effect, no damage (activatable)
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("astrostein/explosion");
		TNT1 A 0 Radius_Quake(10,10,0,16,0);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch==0,"EndSpawn");
		TNT1 A 0 A_SpawnItemEx("KD_HL2FlashAstrostein", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveGreen", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class AstrosteinExplosion_Large : AstrosteinExplosion_Medium { Default { Scale 2.0; } }
class AstrosteinExplosion_Small : AstrosteinExplosion_Medium { Default { Scale 0.5; } }

//////////////////////////////////////
// Variant for Prototypes ////////////
//////////////////////////////////////
class KD_HL2FlashProto : KD_HL2ExplosionBase
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SetScale(frandom(0.5, 0.8) * Scale.X);
		TNT1 A 0 A_Jump(256,1,2);
		EXN3 AB 0 LIGHT("FireSpawnerSmall") A_Jump(256,"Fade");
	Fade:
		"####" "#" 1 BRIGHT LIGHT("ProtoExplosionSpawnerLarge") A_FadeOut(frandom(0.05, 0.10),FTF_REMOVE);
		Wait;
	}
}

class ProtoExplosion_Medium : SwitchableDecoration
{
	Default
	{
	+NOINTERACTION
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("astrostein/explosion");
		TNT1 A 0 Radius_Quake(10,10,0,16,0);
		TNT1 A 0 A_Explode(random(10,20), 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch==0,"EndSpawn");
		TNT1 A 0 A_SpawnItemEx("KD_HL2FlashProto", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveRed", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class ProtoExplosion_Large : ProtoExplosion_Medium { Default { Scale 2.0; } }
class ProtoExplosion_Small : ProtoExplosion_Medium { Default { Scale 0.5; } }

//////////////////////////////
// Variant for lags - Ozy81 //
//////////////////////////////
//This use CVARs only for the explosion check, all other values are forced to 1

class SceneryExplosion_Medium : GeneralExplosion_Medium
{
	Default
	{
	//$Title Scenery Explosion Effect (activatable)
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_CheckSightOrRange(1280, "Unseen");
		TNT1 A 0 A_StartSound("EXPLOSION_SOUND", CHAN_AUTO, 0, 0.75, ATTN_IDLE);
		TNT1 A 0 A_JumpIf(!Args[0], "Quake");
		Goto Explosion;
	Quake:
		TNT1 A 0 Radius_Quake(10,10,0,16,0);
		Goto Explosion;
	Explosion:
		TNT1 A 0 A_Explode(100, 192);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_LagsFlash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_LagsSmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("KD_LagsSparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	Unseen:
		"####" "#" 25;
		Goto Spawn;
	}
}

class SceneryExplosion_Large : SceneryExplosion_Medium { Default { Scale 2.0; } }
class SceneryExplosion_Small : SceneryExplosion_Medium { Default { Scale 0.5; } }

class KD_LagsFlash : KD_HL2Flash
{
	States
	{
	Fade:
		"####" "#" 1 BRIGHT LIGHT("FireSpawnerLarge") A_FadeOut(frandom(0.05, 0.10) * 1,FTF_REMOVE);
		Loop;
	}
}

class KD_LagsSmoke : KD_HL2Smoke
{
	States
	{
	Spawn:
		TSMK A 1 A_SetScale(Scale.X + frandom(0.005, 0.015));
		TSMK A 0 A_FadeOut(frandom(0.006, 0.012) * 1,FTF_REMOVE);
		Loop;
	}
}

class KD_LagsSmokeGenerator : KD_HL2SmokeGenerator
{
	States
	{
	Spawn:
		TNT1 A 0 A_Countdown;
		TNT1 A 0 A_SpawnItemEx("KD_LagsSmoke", 0, 0, 0, 0.0,frandom(0.0, 2.5) * Scale.X,frandom(-2.0, 2.0) * Scale.X, random(0, 359),SXF_CLIENTSIDE | SXF_TRANSFERSCALE, 30);
		Loop;
	}
}

class KD_LagsSpark : KD_HL2Spark
{
	States
	{
	Drop:
		PAO1 A 0 A_ChangeVelocity(frandom(0.98, 0.99) * Vel.X,frandom(0.98, 0.99) * Vel.Y,Vel.Z - frandom(0.2, 0.5), CVF_REPLACE);
		PAO1 A 1 A_SetScale(Scale.X - 0.002);
		PAO1 A 0 A_FadeOut(0.01 * 1,FTF_REMOVE);
		Loop;
	}
}

class KD_LagsSparkGenerator :  KD_HL2SparkGenerator
{
	States
	{
	Spawn:
		TNT1 A 0 A_Countdown;
		TNT1 A 0 A_SpawnItemEx("KD_LagsSpark", 0, 0, 0, 0.0,frandom(0.0, 13.5) * Scale.X,frandom(-1.0, 9.5) * Scale.X, random(0, 359),SXF_CLIENTSIDE | SXF_TRANSFERSCALE, 60);
		Loop;
	}
}

class GeneralExplosion_ShockwaveOrange: Actor
{
	Default
	{
	+NOINTERACTION
	+ROLLSPRITE
	+FORCEXYBILLBOARD
	+BRIGHT
	RenderStyle "Add";
	Alpha 0.75;
	}
	States
	{
	Spawn:
		SHWV A 0;
	Setup:
		"####" "#" 0 {
			Roll = frandom(0.0, 360.0);
			Scale *= .5;
		}
	Expand:
		"####" "#" 1 {
			Scale *= 1.1875;
			A_FadeOut(0.09375, FTF_REMOVE);
		}
		Loop;
	}
}

class GeneralExplosion_ShockwaveGreen : GeneralExplosion_ShockwaveOrange
{
	States
	{
	Spawn:
		SHWV B 0;
		Goto Setup;
	}
}

class GeneralExplosion_ShockwaveRed : GeneralExplosion_ShockwaveOrange
{
	States
	{
	Spawn:
		SHWV C 0;
		Goto Setup;
	}
}