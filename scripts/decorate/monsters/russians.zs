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

class ROfficer : Guard
{
	Default
	{
	//$Category Monsters (BoA)/Allied Soldiers
	//$Title NKVD Russian Officer
	Health 50;
	Speed 3.0;
	DropItem "";
	Species "Ally";
	+FRIENDLY
	Obituary "$ROFFICER";
	SeeSound "urss/sighted";
	PainSound "urss/pain";
	DeathSound "urss/death";
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		NKVO N 1;
		Goto Look;
	See:
		Goto See.Faster;
	Missile: //1 shoot x round
		"####" E 4 A_FaceTarget;
	Missile.Aimed:
		"####" F 4 A_FaceTarget;
		"####" G 0 A_StartSound("urss/tokarev", CHAN_WEAPON);
		"####" G 6 LIGHT("NAZIFIRE") A_SpawnProjectile("REnemyPistolTracer",52,1,random(-4,4));
		"####" F 5 A_SpawnItemEx("Casing9mm", 1,0,54, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 0 {user_count++; if(user_count > 7) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" F 0 A_Jump(256,"See");
		Stop;
	Reload:
		"####" E 0 {bNoPain = TRUE;}
		"####" E 25 A_StartSound("urss/tokarelo", CHAN_ITEM, 0, frandom (0.3,0.6), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("Casing9mm", 1, 0, 56, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		"####" "#" 0 A_Jump(256, "See");
	Death.Rifle:
	Death:
		"####" I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	}
}

class RPPSHGuard1 : MP40Guard
{
	Default
	{
	//$Category Monsters (BoA)/Allied Soldiers
	//$Title NKVD Russian PPSH Guard (Winter Hat)
	Health 50;
	Speed 2.5;
	DropItem "";
	Species "Ally";
	+FRIENDLY
	Obituary "$RPGUARDS";
	SeeSound "urss/sighted";
	PainSound "urss/pain";
	DeathSound "urss/death";
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		NKVF N 1;
		Goto Look;
	See:
		Goto See.Normal;
	Missile:
		"####" E 3 A_FaceTarget;
	Missile.Aimed:
		"####" E 3 A_FaceTarget;
		"####" F 0 A_StartSound("urss/ppsh", CHAN_WEAPON);
		"####" F 3 LIGHT("NAZIFIRE") A_SpawnProjectile("REnemySMGTracer",40,4,random(-8,8));
		"####" F 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 2 A_FaceTarget;
		"####" G 0 A_StartSound("urss/ppsh", CHAN_WEAPON);
		"####" G 3 LIGHT("NAZIFIRE") A_SpawnProjectile("REnemySMGTracer",40,4,random(-12,12));
		"####" G 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {user_count++; if(user_count > 15) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		"####" E 3 A_MonsterRefire(32,"See");
		"####" E 0 A_FaceTarget;
		Goto Missile + 2;
	Reload:
		NKVF E 0 {bNoPain = TRUE;}
		"####" E 40 A_StartSound("urss/ppshrelo", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	Death.Rifle:
	Death:
		"####" I 5;
		"####" J 5 A_Scream;
		"####" K 5 A_UnblockAndDrop;
		"####" L 5;
		"####" M -1;
		Stop;
	}
}

class RPPSHGuard2 : RPPSHGuard1
{
	Default
	{
	//$Title NKVD Russian PPSH Guard (Peak)
	Speed 2.2;
	Nazi.CrouchChance 0;
	}
	States
	{
	Spawn:
		NKVP N 1;
		Goto Look;
	Reload:
		NKVP E 0 {bNoPain = TRUE;}
		"####" E 40 A_StartSound("urss/ppshrelo", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	}
}

class RPPSHGuard3 : RPPSHGuard1
{
	Default
	{
	//$Title NKVD Russian PPSH Guard (Trench)
	Speed 1.5;
	}
	States
	{
	Spawn:
		NKVT N 1;
		Goto Look;
	Reload:
		NKVT E 0 {bNoPain = TRUE;}
		"####" E 30 A_StartSound("urss/ppshrelo", CHAN_WEAPON);
		"####" E 0 A_SpawnItemEx("Casing9mm", 6,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	}
}

class RDragunovGuard : RPPSHGuard1
{
	Default
	{
	//$Title NKVD Russian Dragunov Guard (Helmet)
	Obituary "$RDRAGNOV";
	Speed 1.7;
	}
	States
	{
	Spawn:
		NKVR N 1;
		Goto Look;
	Missile:
		"####" E 10 A_FaceTarget;
	Missile.Aimed:
		"####" F 10 A_FaceTarget;
		"####" G 0 A_StartSound("urss/dragunov", CHAN_WEAPON);
		"####" G 8 LIGHT("NAZIFIRE") A_SpawnProjectile("REnemyRifleTracer",40,8,random(-1,1));
		"####" G 0 A_SpawnItemEx("MauserRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" F 8;
		"####" F 0 {user_count++; if(user_count > 9) {user_count = 0; return ResolveState("Reload");} return ResolveState(null);}
		Goto See;
	Reload:
		NKVR E 0 {bNoPain = TRUE;}
		"####" E 45 A_StartSound("urss/dragrelo", CHAN_ITEM, 0, frandom (0.6,0.9), ATTN_NORM);
		"####" E 0 A_SpawnItemEx("MauserRifleCasing", 8,0,42, random(3,4), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
		"####" E 0 {bNoPain = FALSE;}
		Goto See;
	}
}