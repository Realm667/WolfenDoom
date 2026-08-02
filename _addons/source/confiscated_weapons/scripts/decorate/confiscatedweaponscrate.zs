/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, m-x-d, AFADoomer
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

// I originally wanted Confiscated Weapons to be a custom shop of sorts. Placed in the Headquarters Intermap, it'd serve as a hub for all these weapons and ammo you could buy for later missions. However, there are several problems regarding this particular plan.

// The first would be how the game wipes all of your inventory the moment a mission's done. This is both a blessing and a curse. A blessing, since I don't really have to worry about implementing 50 whole new weapons to BoA without the classic bloat problem, you'd get maybe 3-4 new weapons (maybe more if you're lucky), and then have all of them wiped not 40-50 minutes later. A curse, since if players spent a large sum of gold to acquire these weapons and then have all of them wiped after a mission (especially if it's a short one), there would be figurative rioting in the streets.

// Also, if I were to implement the shop anyways, I'll have to deal with the Strife-like dialogue system. I haven't looked much into it, but I'm pretty sure it's just the Strife system with some more bells and whistles. I've got experience dealing with Strife DIALOGUE with the HDest Bootcamp, and if I can avoid another one of that, I'd do it in a heartbeat.

// And so I decided to take the easiest possible method to integrate all these weapons in to Blade of Agony. By hijacking the barrels used to spawn goodies in the base game. This has several side effects, naturally. For one, this does remove the ambiguity on whether a breakable is explosive or not. If it looks like a barrel, it's explosive. If it's a crate, it's goodies. The classic Half-Life-like system, for better and worse. Another side effect is that the pickup balance for the maps goes out the window, down the piping, and into the guttering. Especially if a player acquires a Slot 8 weapon like the MG42. Good luck keeping a section challenging when the player can bullethose 100 Mauser rounds in less than a minute. But well, such is the nature of a weapons mod that stuffs in as many as it could.

// I do recommend loading a mod like Use-to-Pickup or something so that you don't end up grabbing something you don't like. Just remember to turn it off when passing through the soulgates in Chapter 3 lest you want to get softlocked.

class ConfiscatedWeaponsCrate : TNTBarrel1 replaces GoodieBarrel1
{
	Default
	{
		//$Title Confiscated Weapons Crate
		DeathSound "WOODBRK";
		DropItem "Ammo12Gauge", 64;
		DropItem "Ammo9mm", 64;
		DropItem "Bandages", 48;
		DropItem "Dogfood", 64;
		DropItem "GrenadePickup", 16;
		DropItem "MauserAmmo", 64, 5;
		DropItem "Meal", 32, 1;
		Dropitem "Medikit_Small", 16;
		//Confiscated Melee
		Dropitem "Kabar", 6;		
		Dropitem "BrassKnucks", 6;		
		Dropitem "ThrowingKnife", 6;		
		//Confiscated Handguns
		Dropitem "TT33", 8;
		Dropitem "Welrod", 8;
		Dropitem "Colt1911", 8;
		Dropitem "PPK", 8;
		Dropitem "C96", 8;
		Dropitem "Webley", 8;
		Dropitem "BrownHP", 8;
		Dropitem "Nambu", 8;
		//Confiscated Shotguns
		Dropitem "Ithaca37", 4;		
		Dropitem "CoachGun", 2;		
		//Confiscated SMGs
		DropItem "Thompson", 4;
		DropItem "PPSH41", 3;
		Dropitem "M3Grease", 5;
		Dropitem "PPS43", 4;
		Dropitem "MP18", 5;
		Dropitem "MAS38", 5;
		Dropitem "T100", 5;
		Dropitem "STNV", 4;
		Dropitem "T1928", 2;
		//Confiscated Rifles
		DropItem "Enfield", 4;
		DropItem "Garand", 4;
		Dropitem "DeLisle", 4;
		Dropitem "MosinNagant", 4;
		Dropitem "SVT40", 2;
		Dropitem "M1C", 5;
		Dropitem "Springfield", 2;
		Dropitem "JM1941", 2;
		Dropitem "AVS36", 1;
		Dropitem "Type99", 1;
		//Confiscated Assault Rifle
		DropItem "STG44", 2;
		Dropitem "FG42", 2;
		//Confiscated Machine Guns
		DropItem "BAR3006", 2;
		Dropitem "Bren", 1;
		Dropitem "LewisGun", 1;
		Dropitem "MG42", 1;
		Dropitem "MG34", 1;
		Dropitem "DP27", 1;
		Dropitem "30CAL", 1;
		//Confiscated Anti-Personnel
		Dropitem "MortarPlayer", 1;
		Dropitem "M2Flamer", 1;
		//Confiscated Launchers
		Dropitem "Panzerfaust", 1;
		Dropitem "Bazooka", 1;
		Dropitem "PIAT", 1;
		//Confiscated Ammunition
		Dropitem "45ACPAmmoBox", 8;
		Dropitem "WebleyAmmo", 12;
		Dropitem "792KurzAmmo", 8;
		Dropitem "3006AmmoBox", 8;
		Dropitem "TokarevAmmo", 16;
		Dropitem "765LongueAmmo", 16;
		Dropitem "NambuAmmo", 16;
		Dropitem "NagantAmmo", 8;
		Dropitem "ArisakaAmmo", 12;
		Dropitem "PPKAmmo", 32;
		Dropitem "PIATAmmo", 3;
		Dropitem "MortarAmmo", 4;
		Dropitem "BazookaAmmo", 2;
		//Confiscated Grenades
		DropItem "MK2Frag", 12;
		DropItem "MillsGrenade", 12;
		DropItem "Geballte", 4;
		DropItem "Dynamite", 1;
		DropItem "PlayerSatchels", 1;
	Scale 0.50;
	}
	States
	{
	Spawn:
		XCRA A -1;
		Stop;
	Death:
		TNT1 A 0 A_Scream;
		XCRA A 2 A_SpawnItemEx("BarrelFrags");
		TNT1 A 0 A_SpawnItemEx("PowerPlantSmokePuff", random(-3,3), random(-3,3), 0, 0, 0, 3);
		TNT1 A 0 A_NoBlocking(false); // DropItems handled in the BarrelSpawner actor - so that you can override drops via arg0str
		Stop;
	}
}