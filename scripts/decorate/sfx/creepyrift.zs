/*
 * Copyright (c) 2017-2021 Ozymandias81, Tormentor667, AFADoomer
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

//Following actors were based over Ghastly Dragon's DarknessRift
const FLAGS_CREEPY = SXF_NOCHECKPOSITION | SXF_SETMASTER | SXF_CLIENTSIDE;
const FLAGS_CREEPY2 = SXF_SETMASTER | SXF_CLIENTSIDE;

class CreepyRiftSpawner : SwitchableDecoration
{
	Default
	{
	//$Category Special Effects (BoA)
	//$Title Creepy Rift Effect Spawner (DO NOT SET THIS DORMANT)
	//$Color 12
	//$Sprite DRFTA0
	Radius 40;
	Height 60;
	Mass 500;
	Speed 0;
	SeeSound "creepyrift/active";
	Renderstyle "Add";
	Alpha 0.1;
	-SOLID
	+FLOAT
	+FRIENDLY
	+LOOKALLAROUND
	+NOGRAVITY
	}
	States
		{
		Spawn:
			TNT1 A 1;
			Wait;
		Active:
			TNT1 A 0 A_StartSound("creepyrift/loop", CHAN_AUTO, CHANF_LOOPING, 1.0, ATTN_NONE);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("DamnedSoulSpawner", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			SpawnLoop:
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2 A_Look;
			Loop;
		See:
			TNT1 A 0 A_StartSound("creepyrift/loop", CHAN_AUTO, CHANF_LOOPING, 1.0, ATTN_NONE);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2 A_Chase;
			TNT1 A 0 A_StartSound("creepyrift/loop", CHAN_AUTO, CHANF_LOOPING, 1.0, ATTN_NONE);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_Jump(200, 4);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			Goto See;
			TNT1 A 0 A_Jump(128, 2);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			Goto See;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyGhost", random(-128, 128), 0, 0, 0, 0, random(1,4), Random(0, 360), FLAGS_CREEPY, 128);
			TNT1 A 2 A_SpawnItemEx("CreepyGhost", 0, 0, 0, 0, 0, 0, random(0,360), FLAGS_CREEPY2, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 2;
			Goto See;
		Inactive:
			TNT1 A 0 A_StopSound(CHAN_AUTO);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
			TNT1 A 0 A_SpawnItemEx("CreepyCloudSpawner", 0, 0, 30, 0, 0, 0, 0, 128);
		Remove:
			TNT1 A 0 A_RemoveChildren(TRUE, RMVF_MISC);
		Fade:
			TNT1 A 1;
			TNT1 A 0 A_SpawnItemEx("CreepySwirl", 0, 0, 128, 0, 0, 0, 0, 0);
			Stop;
		}
}

class CreepySwirl: Actor
{
	Default
	{
	Radius 40;
	Height 60;
	Mass 500;
	Speed 0;
	SeeSound "creepyrift/active";
	Renderstyle "Add";
	Alpha 0.1;
	-SOLID
	+FLOAT
	+FRIENDLY
	+LOOKALLAROUND
	+NOGRAVITY
	}
	States
		{
		Spawn:
			SWRL ABCDEFGHI 3 BRIGHT {A_SetScale(2.0, 2.0); A_FadeIn(0.1);}
			SWRL JKLMNOPXY 3 BRIGHT {A_SetScale(2.0, 2.0); A_FadeOut(0.11);}
			Stop;
		}
}

class CreepyCloudSpawner: Actor
{
	Default
	{
	Height 0;
	Radius 0;
	-SOLID
	+DONTSQUASH
	+NOBLOCKMAP
	+NOGRAVITY
	+NOLIFTDROP
	+NOTARGET
	+NOTELEOTHER
	}
	States
		{
		Spawn:
			TNT1 A 0;
			TNT1 A 1 A_SpawnItemEx("CreepyCloud", 0, 0, 0, random(-4, 4), random(-4, 4), random(-2, 2));
			Stop;
		}
}

class CreepyCloud : CreepyCloudSpawner
{
	Default
	{
	Renderstyle "Translucent";
	Alpha 0.7;
	Scale 3.5;
	+FLOAT
	}
	States
		{
		Spawn:
			DRFT A 0;
			"####" A 0 A_Jump(128, 6);
			"####" ABCDE 4 A_FadeOut(0.05);
			Goto Spawn+1;
			"####" F 0 A_Jump(128, 6);
			"####" FGHIJ 4 A_FadeOut(0.05);
			Goto Spawn+7;
			"####" KLMNO 4 A_FadeOut(0.05);
			Goto Spawn+12;
		}
}

//Following actors are based on Captain Toenail's Damned Souls - Ozy81
class DamnedSoulSpawner: Actor
{
	Default
	{
	Radius 2;
	Height 2;
	+NOINTERACTION
	}
	States
		{
		Spawn:
		Active:
			TNT1 A 0;
			TNT1 A 0;
			TNT1 A 6 A_SpawnItemEx("DamnedSoul", random (-192, 192), 0, 0, 0, 0, random(1,6), random (0, 360), SXF_NOCHECKPOSITION | SXF_CLIENTSIDE, random(64,128));
			Loop;
		Inactive:
			TNT1 A 1;
			Loop;
		}
}

class DamnedSoul : SimpleActor
{
	Default
	{
	Radius 2;
	Height 2;
	Speed 1;
	Alpha 0;
	Scale 1.0;
	RenderStyle "Add";
	Projectile;
	+BRIGHT
	+CLIENTSIDEONLY
	+NOINTERACTION
	}
	States
		{
		Spawn:
			HADE D 0 NODELAY A_SetScale(Scale.X + frandom(-0.7, 0.3));
			"####" D 0 A_StartSound ("creepy/moans");
		FadeIn:
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
			"####" D 1 A_SetTranslucent (alpha+0.03, 1);
		Linger:
			HADE D 4;
		FadeOut:
			HADE D 1 A_FadeOut(0.02);
			Loop;
		}
}