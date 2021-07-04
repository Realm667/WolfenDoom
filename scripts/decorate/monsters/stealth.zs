/*
 * Copyright (c) 2018-2021 Ozymandias81, AFADoomer, Talon1024, MaxED
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

///////////
//ENEMIES//
///////////

class SneakableSSMP40Guard : SSMP40Guard
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title SS Guard (MP40, sneak-friendly)
	//$Color 4
	//$Sprite SSMGA1
	Nazi.Sneakable;
	}
}

class SneakableSSMP40GuardStatic : SneakableSSMP40Guard
{
	int user_angle;
	Default
	{
	//$Title SS Guard Static (MP40, sneak-friendly, doesn't move)
	//$Sprite SSMGE1
	Speed 0;
	}
	States
	{
	Spawn:
		SSMG A 0 NODELAY { user_angle = (int) (angle); }
		Goto Look;
	See: //doesn't roll - ozy81
	See.Dodge:
		"####" N 1 { A_SetAngle(user_angle); A_Chase("Missile", "Missile", CHF_DONTMOVE | CHF_NODIRECTIONTURN); }
		Loop;
	}
}

class SneakableSSMP40GuardStatic2 : SneakableSSMP40Guard
{
	int user_angle;
	Default
	{
	//$Title SS Guard Static for Turrets (MP40, sneak-friendly, silent, doesn't move)
	//$Sprite SSMGG1
	SeeSound "";
	Speed 0;
	}
	States
	{
	Spawn:
		SSMG A 0 NODELAY { user_angle = (int) (angle); }
		Goto Look;
	See: //doesn't roll - ozy81
	See.Dodge:
		"####" N 1 { A_SetAngle(user_angle); A_Chase("Missile", "Missile", CHF_DONTMOVE | CHF_NODIRECTIONTURN); }
		Loop;
	}
}

class MGTurretStealth : MGTurret
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Automatic Turret (stealth, hidden, nokillcount)
	//$Color 4
	Nazi.Sneakable;
	Mass 0xFFFFFFF;
	PainChance 255;
	-COUNTKILL
	-NOPAIN
	+ALLOWPAIN
	+INVULNERABLE
	+NEVERTARGET
	+NOBLOOD
	+NOGRAVITY
	RenderStyle "None";
	PainSound "metal/pain";
	SeeSound "";
	}
	States
	{
	Missile: //This 'turret' fires and reloads like an MP40 Guard
		"####" A 5 { A_FaceTarget(); A_StartSound("nazi/mp40", CHAN_WEAPON); }
		"####" B 4 A_SpawnProjectile("EnemySMGTracer",24,4,random(-8,8));
		"####" A 0 {user_count++; if(user_count > 39) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" C 2 A_MonsterRefire(10, "See");
		Loop;
	Reload:
		"####" A 35 A_StartSound("mp40/reload", CHAN_WEAPON);
		Goto See;
	Pain: //Disable for 2 seconds when shot, then go to reload
		"####" C 70;
		Goto Reload;
	}
}

//Variants
class SneakableSSGuard : SSGuard
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title SS Guard (Pistol, sneak-friendly)
	//$Color 4
	//$Sprite SSPGA1
	Nazi.Sneakable;
	Nazi.NoAltDeath 1;
	}
}

class SneakableSSOfficer : SSOfficer
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title SS Officer (sneak-friendly)
	//$Color 4
	//$Sprite SSOFA1
	Nazi.Sneakable;
	Nazi.NoAltDeath 1;
	}
}

class SneakableSSToilet : SSToilet
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Toilet SS Officer (sneak-friendly)
	//$Color 4
	//$Sprite SSOTA0
	Nazi.Sneakable;
	}
}

class SneakableWaffenSS : WaffenSS
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Waffen SS (sneak-friendly)
	//$Color 4
	//$Sprite WAFFA1
	Nazi.Sneakable;
	}
}

class SneakableMP40Guard : MP40Guard
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Afrika Korps Guard (MP40, sneak-friendly)
	//$Color 4
	//$Sprite MGRDA1
	Nazi.Sneakable;
	}
}

class SneakableGuard : Guard
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Afrika Korps Guard (Pistol, sneak-friendly)
	//$Color 4
	//$Sprite GARDA1
	Nazi.Sneakable;
	Nazi.NoAltDeath 1;
	}
}

class SneakableOfficer : Officer
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Afrika Korps Officer (sneak-friendly)
	//$Color 4
	//$Sprite OFFIA1
	Nazi.Sneakable;
	Nazi.NoAltDeath 1;
	}
}

class SneakableWMP40Guard : WMP40Guard
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Wehrmacht Guard (MP40, sneak-friendly)
	//$Color 4
	//$Sprite MGR2A1
	Nazi.Sneakable;
	}
}

class SneakableWGuard : WGuard
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Wehrmacht Guard (Pistol, sneak-friendly)
	//$Color 4
	//$Sprite GRD2A1
	Nazi.Sneakable;
	Nazi.NoAltDeath 1;
	}
}

class SneakableWToilet : WToilet
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Toilet Wehrmacht Guard (Pistol, sneak-friendly)
	//$Color 4
	//$Sprite GRDTA0
	Nazi.Sneakable;
	}
}

class SneakableWOfficer : WOfficer
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Wehrmacht Officer (sneak-friendly)
	//$Color 4
	//$Sprite OFR2A1
	Nazi.Sneakable;
	Nazi.NoAltDeath 1;
	}
}

class SneakableWMP40GuardSleep : WMP40GuardSleep
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Wehrmacht Guard, Sleeping (MP40, sneak-friendly)
	//$Color 4
	//$Sprite MGR2O0
	Nazi.Sneakable;
	Dropitem "";
	}
}

class SneakableGestapo : Gestapo
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Gestapo Officer (sneak-friendly)
	//$Color 4
	//$Sprite GSAPN1
	Nazi.Sneakable;
	Nazi.PerceptionTime 70; // About 2 seconds
	Nazi.PerceptionFOV 120; // Relatively wide view
	Nazi.PerceptionDistance 384.0; // Half again more than the normal sight distance for sneakables
	}
}

class SneakableScientist : Scientist
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Scientist (young) (sneak-friendly)
	//$Color 4
	//$Sprite SCN2N1
	Nazi.Sneakable;
	}
}

class SneakableScientist2 : Scientist2
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Scientist (old) (sneak-friendly)
	//$Color 4
	//$Sprite SCNTN1
	Nazi.Sneakable;
	}
}

class SneakableMechanic : Mechanic
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Mechanic (sneak-friendly)
	//$Color 4
	//$Sprite MNICN1
	Nazi.Sneakable;
	}
}

class SneakableWRifleGuard : WRifleGuard
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Wehrmacht Guard (Rifle, sneak-friendly)
	//$Color 4
	//$Sprite RGR2N1
	Nazi.Sneakable;
	}
}

class SneakableMarineGeneral : MarineGeneral
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title General Seeteufel (Boss, sneak-friendly)
	//$Color 4
	//$Sprite SEETA0
	Nazi.Sneakable;
	}
}

class SneakableLOfficer : LOfficer
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Luftwaffe Officer (MP40, sneak-friendly)
	//$Color 4
	//$Sprite LOFRA1
	Nazi.Sneakable;
	}
}

class SneakableSSOccult : SSOccult
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title SS Occult Officer (Random Flame/Electric Attacks, sneak-friendly)
	//$Color 4
	//$Sprite SSOCA0
	Nazi.Sneakable;
	}
}

class SneakableSSOccultFire : SSOccultFire
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title SS Occult Officer (Flame Attacks, sneak-friendly)
	//$Color 4
	//$Sprite SSOCE0
	Nazi.Sneakable;
	}
}

class SneakableSSOccultElectric : SSOccultElectric
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title SS Occult Officer (Thunder Attacks, sneak-friendly)
	//$Color 4
	//$Sprite SSOCB0
	Nazi.Sneakable;
	}
}

// This guy is pretty much custom-tailored for the watchtowers in C2M1...  He's sneakable,
// but has some custom handling to look all around at close range and to alert on proximity
// at a much larger radius than normal Nazis (because he only has one rotation and also
// looks like he's watching you through a scope.
// He also still drops his weapon - mostly so the weapon balance doesn't change.
// No altdeaths for this actor too.
class SneakableWSniper : WSniper
{
	Default
	{
	//$Category Monsters (BoA)/Sneak-Friendly
	//$Title Wehrmacht Sniper (sneak-friendly)
	//$Color 4
	//$Sprite SNIWB0
	Nazi.Sneakable;
	Nazi.SneakableCloseSightRadius 144;
	+LOOKALLAROUND
	}
	States
	{
	Death:
		SNIW I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_NoBlocking; // Keep the drops for weapon balance
		"####" L 5;
		"####" M -1;
		Stop;
	}
}