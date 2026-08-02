/*
 * Copyright (c) 2018-2021 Ozymandias81, AFADoomer
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

// I was conflicted during the implementation of this. With guns, sure, some of them could be samey, but atleast they're different enough in how powerful, how they sound, how their altfires work, and even how rare their ammo is. In what way can I make a knife different from another knife? Even though I got knives ranging from the Fairbairn all the way to the KaBar, something needs to be done to make them unique mechanics wise. And so, for this particular knife, I toyed with the idea of a slash attack that hits for several smaller but constant damage. Works pretty good for enemies that are stunlocked easily or tiny enemies that the one-dot-at-a-time knife might have difficulties hitting.

// I had plans for a Spear of Destiny weapon, believe it or not. Didn't end up going through with it at the end, 'cause it'd be weird to have the final boss of CH1 be sandblasted in 10 seconds with an energy blast. Maybe later if I could find more things to lead to 60.

class Kabar : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (1) KaBar
	//$Color 14
	Scale 0.35;
	Weapon.SlotNumber 1;
	DamageType "Knife";
	+FORCEPAIN
	+WEAPON.MELEEWEAPON
	+WEAPON.NOALERT
	+WEAPON.NOAUTOFIRE
	+WEAPON.WIMPY_WEAPON
	Tag "Ka-Bar Knife";
	Weapon.BobStyle "Smooth";
	Weapon.BobSpeed 1.5;
	Weapon.BobRangeX 1.5;
	Inventory.PickupMessage "You got the Ka-Bar Knife!";
	Weapon.SelectionOrder 10000;
	Weapon.UpSound "select/knife";
	}
	States
	{
	Spawn:
		KABR W -1;
		Stop;
	Ready:
		KABR A 1 A_WeaponReady;
		Loop;
	Deselect:
		KABR A 1 A_Lower;
		KABR A 0 A_Lower;
		Loop;
	Select:
		KABR A 1 A_Raise;
		KABR A 0 A_Raise;
		Loop;
	Fire:
		KABR A 0 A_JumpIfInventory("PowerStrength", 1, "FirePower");
		KABR A 1 A_StartSound("knife/swing", CHAN_WEAPON);
		KABR B 1;
		KABR C 1 A_CustomPunch(2, 1, 0, "KnifePuff", 64);
		KABR D 1 A_CustomPunch(2, 1, 0, "KnifePuff", 64);
		KABR E 1 A_CustomPunch(2, 1, 0, "KnifePuff", 64);
		KABR F 1 A_CustomPunch(2, 1, 0, "KnifePuff", 64);
		KABR G 1 A_CustomPunch(2, 1, 0, "KnifePuff", 64);
		KABR H 1 A_CustomPunch(2, 1, 0, "KnifePuff", 64);
		KABR B 1 A_CustomPunch(2, 1, 0, "KnifePuff", 64);
		Goto Fire.End;
	Fire.End:
		KABR B 1;
		KABR B 1;
		KABR A 1;
		KABR A 10;
		Goto Ready;
	FirePower:
		KABR A 1 A_StartSound("knife/swing", CHAN_WEAPON);
		KABR B 1;
		KABR C 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		KABR D 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		KABR E 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		KABR F 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		KABR G 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		KABR H 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		KABR B 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		Goto Fire.End;
	}
}