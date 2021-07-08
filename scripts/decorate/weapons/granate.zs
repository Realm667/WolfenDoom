/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer, yqco,
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

class HQ_Checker : Inventory { Default { Inventory.MaxAmount 1; } }

class GrenadePickup : IntervalUseItem
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title Grenade
	//$Color 14
	Scale 0.25;
	Inventory.PickupMessage "$GRENADE";
	Tag "$TAGFRAGN";
	Inventory.Icon "THRPB0";
	Inventory.MaxAmount 9;
	Inventory.InterHubamount 9;
	Inventory.UseSound "grenade/throw";
	Inventory.PickupSound "grenade/pickup";
	ReactionTime 12;  // Interval between usages - Talon1024
	-NOGRAVITY
	+INVENTORY.INVBAR
	}
	States
	{
	Spawn:
		THRP A -1;
		Stop;
	Use:
		TNT1 A 0 A_JumpIfInventory("HQ_Checker",1,"Stupid");
		TNT1 A 0 A_JumpIfInventory("AstroGrenadeToken", 1, 2);
		TNT1 A 0 A_FireProjectile("HandGrenade",0,0,0,0,FPF_NOAUTOAIM);
		Stop;
		TNT1 A 0 {
			A_TakeInventory("AstroGrenadeToken",1,TIF_NOTAKEINFINITE);
			A_FireProjectile("AstroHandGrenade",0,0,0,0,FPF_NOAUTOAIM);
		}
		Stop;
	Stupid:
		TNT1 A 0 A_Print("$STUPID1",3.5);
		Fail;
	}

	override void Tick()
	{
		if (owner && owner.FindInventory("AstroGrenadeToken"))
		{
			icon = TexMan.CheckForTexture("ASGNB0");
		}
		else { icon = Default.icon; }

		Super.Tick();
	}
}

class HandGrenade : GrenadeBase //no hard variant since it is used also by players - ozy81
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 40;
		FastSpeed 45;
		DamageFunction (1);
		DamageType "Frag";
		Scale 0.25;
		Projectile;
		-NOGRAVITY
		-NOTELEPORT
		+WINDTHRUST
		+FORCEXYBILLBOARD
		+GrenadeBase.DRAWINDICATOR
		Obituary "$OBGRENADE";
		BounceType "Doom";
		BounceFactor 0.2;
		WallBounceFactor 0.6;
		BounceSound "grenade/bounce";
		GrenadeBase.FearDistance 192;
		GrenadeBase.SplashType "Missile";
		GrenadeBase.Icon "HUD_GREN";
	}

	States
	{
		Spawn:
			THRW A 2 A_CountDown;
			THRW BCDEFGH 2;
			TNT1 A 0 A_JumpIf(waterlevel == 3, "AdjustMass");
			Loop;
		AdjustMass:
			"####" "#" 0 { A_SetMass(800); ClearBounce(); }
			Goto Swim;
		Swim:
			THRW A 2 { A_CountDown(); A_ScaleVelocity(0.7); A_SpawnItemEx("Bubble", 0, 0, 0, 0, 0, 2, random (0, 360), 0, 128); }
			THRW BCDEFGH 2;
			Loop;
		Death:
			THRW B 35 { floorclip -= 2; }
			TNT1 A 0 A_SpawnGroundSplash;
			TNT1 A 0 A_AlertMonsters(512);
			TNT1 A 0 A_SetScale(1.75,1.75);
			TNT1 A 0 A_SetTranslucent(0.75,1);
			TNT1 A 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
			TNT1 A 1 A_SpawnItemEx("GeneralExplosion_Medium");
			TNT1 A 1 Radius_Quake(10,10,0,16,0);
			Stop;
	}

	override void PostBeginPlay()
	{
		if (target && target.player)
		{
			AchievementTracker.CheckAchievement(target.PlayerNumber(), AchievementTracker.ACH_BOOM);

			AchievementTracker tracker = AchievementTracker(StaticEventHandler.Find("AchievementTracker"));
			if (tracker) { tracker.grenades[target.PlayerNumber()]++; }
		}
		Super.PostBeginPlay();
	}
}

class HansGrenade : HandGrenade //Fast version for Afrika Boss
{
	Default
	{
	Speed 50;
	FastSpeed 55;
	BounceFactor 0.4;
	WallBounceFactor 0.8;
	}
	States
	{
	Death:
		THRW B 10 { floorclip -= 2; }
		TNT1 A 0 A_SpawnGroundSplash;
		TNT1 A 0 A_AlertMonsters(512);
		TNT1 A 0 A_SetScale(1.75,1.75);
		TNT1 A 0 A_SetTranslucent(0.75,1);
		TNT1 A 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		TNT1 A 1 A_SpawnItemEx("GeneralExplosion_Medium");
		TNT1 A 1 Radius_Quake(20,20,0,32,0);
		Stop;
	}
}

class HardHansGrenade : HansGrenade //skill 5 grenades have +30 speed to prevent grenadeers and bosses attack aimlessly - ozy81
{
	Default
	{
	Speed 80;
	FastSpeed 85;
	}
}

class VeryFastGrenade : HandGrenade //Very fast version for Grenadeers
{
	Default
	{
	Speed 100;
	FastSpeed 105;
	BounceFactor 0.4;
	WallBounceFactor 0.8;
	}
	States
	{
	Death:
		THRW B 35 { floorclip -= 2; }
		TNT1 A 0 A_SpawnGroundSplash;
		TNT1 A 0 A_AlertMonsters(512);
		TNT1 A 0 A_SetScale(1.75,1.75);
		TNT1 A 0 A_SetTranslucent(0.75,1);
		TNT1 A 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		TNT1 A 1 A_SpawnItemEx("GeneralExplosion_Medium");
		TNT1 A 1 Radius_Quake(10,10,0,16,0);
		Stop;
	}
}

class HardVeryFastGrenade : VeryFastGrenade
{
	Default
	{
	Speed 130;
	FastSpeed 135;
	}
}

class SlowGrenade : HandGrenade //Slow version for Grenadeers
{
	Default
	{
	Speed 20;
	FastSpeed 25;
	BounceFactor 0.5;
	WallBounceFactor 1.0;
	}
	States
	{
	Death:
		THRW B 45 { floorclip -= 2; }
		TNT1 A 0 A_SpawnGroundSplash;
		TNT1 A 0 A_AlertMonsters(512);
		TNT1 A 0 A_SetScale(1.75,1.75);
		TNT1 A 0 A_SetTranslucent(0.75,1);
		TNT1 A 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		TNT1 A 1 A_SpawnItemEx("GeneralExplosion_Medium");
		TNT1 A 1 Radius_Quake(10,10,0,16,0);
		Stop;
	}
}

class HardSlowGrenade : SlowGrenade
{
	Default
	{
	Speed 50;
	FastSpeed 55;
	}
}

class VerySlowGrenade : HandGrenade //Very slow version for Grenadeers
{
	Default
	{
	Speed 10;
	FastSpeed 15;
	BounceFactor 0.8;
	WallBounceFactor 1.6;
	}
	States
	{
	Death:
		THRW B 70 { floorclip -= 2; }
		TNT1 A 0 A_SpawnGroundSplash;
		TNT1 A 0 A_AlertMonsters(512);
		TNT1 A 0 A_SetScale(1.75,1.75);
		TNT1 A 0 A_SetTranslucent(0.75,1);
		TNT1 A 0 A_StartSound("grenade/explode", CHAN_AUTO, 0, 1.0, 0.1);
		TNT1 A 1 A_SpawnItemEx("GeneralExplosion_Medium");
		TNT1 A 1 Radius_Quake(10,10,0,16,0);
		Stop;
	}
}

class HardVerySlowGrenade : VerySlowGrenade
{
	Default
	{
	Speed 30;
	FastSpeed 35;
	}
}