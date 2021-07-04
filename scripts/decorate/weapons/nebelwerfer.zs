/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, Talon1024,
 *                         AFADoomer
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

class Nebelwerfer : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (6) Nebelwerfer
	//$Color 14
	Weapon.SelectionOrder 2500;
	Weapon.AmmoUse 1;
	Weapon.AmmoGive 10;
	Weapon.AmmoType "NebAmmo";
	Weapon.UpSound "nebelwerfer/select";
	Tag "$TAGNEBWP";
	Inventory.PickupMessage "$WERFER";
	-WEAPON.AMMO_CHECKBOTH
	-WEAPON.NOALERT
	}
	States
	{
	Ready:
		NEBG A 1 A_WeaponReady;
		Loop;
	Deselect:
		NEBG A 0 A_Lower;
		NEBG A 1 A_Lower;
		Loop;
	Select:
		NEBG A 0 A_Raise;
		NEBG A 1 A_Raise;
		Loop;
	Fire:
		NEBG A 0 A_GunFlash;
		NEBG A 0 A_StartSound("nebelwerfer/fire", CHAN_WEAPON);
		NEBG A 2 A_FireProjectile("NebRocket");
		NEBG BCDEB 2 A_SetPitch(pitch-(0.5*boa_recoilamount));
		NEBG DEFC 5;
		NEBG BA 2 A_ReFire;
		Goto Ready;
	Flash:
		NEBF A 2 A_Light2;
		TNT1 A 2 A_Light1;
		Goto LightDone;
	Spawn:
		NEBL A -1;
		Stop;
	}
}

class NebRocket : GrenadeBase
{
	Default
	{
	Radius 11;
	Height 8;
	Speed 35;
	DamageFunction (6*random(1,8));
	DamageType "Rocket";
	Projectile;
	+FORCERADIUSDMG
	+RANDOMIZE
	+WINDTHRUST
	+THRUGHOST
	Scale 0.5;
	DeathSound "nebelwerfer/xplode";
	Decal "Scorch";
	ProjectileKickback 100;
	GrenadeBase.SplashType "Missile";
	}
	States
	{
	Spawn:
		MNSS A 0 NODELAY A_StartSound("nazi/missileengine", CHAN_AUTO, CHANF_LOOPING, 0.3);
	Fly:
		MNSS A 1 BRIGHT LIGHT("NEBLIGHT") A_SpawnItemEx("RocketFlame",random(-1,1),0,random(-1,1));
		Loop;
	Death:
	Crash:
		EXP1 A 0 A_SetScale(0.85,0.95);
		EXP1 A 0 A_SpawnGroundSplash;
		EXP1 A 0 A_AlertMonsters;
		EXP1 A 0 A_StopSound(CHAN_AUTO);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("TracerSpark_Longlive", 0, 0, 0, frandom(-5.0,5.0), frandom(-5.0,5.0), frandom(-5.0,5.0), random(0,359)); //T667 improvements
		TNT1 A 0 A_SpawnItemEx("NebNuke",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 8 A_SpawnItemEx("GeneralExplosion_Small",56,0,32);
		FRME A 1 BRIGHT LIGHT("NEBEXPLO") { A_Explode(64,56); A_SpawnItemEx("ZScorch");}
		FRME BCDEFGHIHJKLMNOPQRS 1 BRIGHT LIGHT("NEBEXPLO");
		Stop;
	}
}

class NebRocket2 : NebRocket { Default { DamageType "Truck"; } }

class RocketFlame: Actor
{
	Default
	{
	Projectile;
	+NOCLIP
	Scale 0.15;
	Alpha 0.5;
	RenderStyle "Add";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		XPLO AB 2 BRIGHT LIGHT("NEBEXPLO");
		XPLO C 2 BRIGHT LIGHT("NEBEXPLO") A_SpawnItemEx("RPG8RocketTrail",random(-1,1),0,1, 0, 0, frandom(0.1,0.3));
		Stop;
	}
}

class RPG8RocketTrail : RocketFlame
{
	Default
	{
	Scale 0.18;
	Alpha 0.5;
	RenderStyle "Translucent";
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 1 A_Jump(256, "Flyloop1", "Flyloop2", "Flyloop3", "Flyloop4");
	Flyloop1:
		SMOK A 1 { A_SetScale(Scale.X+0.010); A_FadeOut(.008, FTF_REMOVE); }
		Loop;
	Flyloop2:
		SMOK B 1 { A_SetScale(Scale.X+0.015); A_FadeOut(.007, FTF_REMOVE); }
		Loop;
	Flyloop3:
		SMOK C 1 { A_SetScale(Scale.X+0.005); A_FadeOut(.006, FTF_REMOVE); }
		Loop;
	Flyloop4:
		SMOK D 1 { A_SetScale(Scale.X+0.010); A_FadeOut(.005, FTF_REMOVE); }
		Loop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class MutantFlame : RocketFlame
{
	States
	{
	Spawn:
		TNT1 A 1;
		XPLO AB 2 BRIGHT LIGHT("MUTNEXPL");
		XPLO C 2 BRIGHT LIGHT("MUTNEXPL") A_SpawnItemEx("RPG8RocketTrail",random(-1,1),0,1, 0, 0, frandom(0.1,0.3));
		Stop;
	}
}

class ZombieFlame : RocketFlame { Default { RenderStyle "Shadow"; } }