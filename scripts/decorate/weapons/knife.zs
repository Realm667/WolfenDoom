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

class KnifeSilent : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (1) Knife
	//$Color 14
	Scale 0.35;
	DamageType "Knife";
	+FORCEPAIN
	+WEAPON.MELEEWEAPON
	+WEAPON.NOALERT
	+WEAPON.NOAUTOFIRE
	+WEAPON.WIMPY_WEAPON
	+NaziWeapon.NORAMPAGE
	Tag "$TAGKNIFE";
	Weapon.BobStyle "Smooth";
	Weapon.BobSpeed 1.5;
	Weapon.BobRangeX 1.5;
	Inventory.PickupMessage "$KNIFE";
	Weapon.SelectionOrder 10000;
	}
	States
	{
	Spawn:
		KNFE A -1;
		Stop;
	Ready:
		KNFG A 1 A_WeaponReady;
		Loop;
	Deselect:
		KNFG A 1 A_Lower;
		Loop;
	Select:
		KNFG A 1 A_Raise;
		Loop;
	Fire:
		KNFG A 0 A_JumpIfInventory("PowerStrength", 1, "Fire.Berserked");
	Fire.Normal:
		KNFG A 1 A_StartSound("knife/swing", CHAN_WEAPON);
		KNFG B 1 A_CustomPunch(10, 1, 0, "KnifePuff", 64);
		Goto Fire.End;
	Fire.Berserked:
		KNFG A 1 A_StartSound("knife/swing", CHAN_WEAPON);
		KNFG B 1 A_CustomPunch(10*5, 1, 0, "KnifePuff", 64); //Quintuple Damage with NaziBerserk, suggested by N00b - ozy81
	Fire.End:
		KNFG CDEFGHJKLMN 1;
		KNFG A 10;
		Goto Ready;
	}
}

class KnifePuff : ShovelPuff
{
	Default
	{
	AttackSound "";
	SeeSound "";
	Scale 0.4;
	Obituary "$OBKNIFE";
	PainType "SilentKnifeAttack"; //mxd. Used to invoke Pain.SilentKnifeAttack exclusively on stealth monsters
	DamageType "Melee";
	}
	States
	{
	Spawn:
	Melee:
	Crash:
		POOF A 3 A_StartSound("knife/stone");
		POOF BCDE 3;
		Stop;
	XDeath:
		POOF A 3 A_StartSound("knife/hit");
		Goto Crash+1;
	}
}