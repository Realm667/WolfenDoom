/*
 * Copyright (c) 2017-2021 Ozymandias81, Guardsoul, Tormentor667, AFADoomer,
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

//////////
//MECHAS//
//////////

class MechaNaziStanding1 : ControllableBase
{
	Default
	{
	//$Category Monsters (BoA)/Mechas
	//$Title Empty Wehrmacht Mecha-Nazi (Wehrmacht Guards only)
	Radius 48;
	Height 128;
	Health -1;
	Scale 1.16;
	+INVULNERABLE
	ControllableBase.Controllers "WGuard";
	ControllableBase.Replacements "MechaNaziWalking1";
	}
	States
	{
	Spawn:
		MCST A 1 NODELAY A_SetTics(Random(1, 35));
		Goto Active;
	Active:
		"####" "#" 35 A_CheckReplace(128);
		Loop;
		// No Death states because it is invulnerable
	}
}

class MechaNaziStanding2 : MechaNaziStanding1
{
	Default
	{
	//$Title Empty Afrika Korps Mecha-Nazi (Afrika Korps Guards only)
	ControllableBase.Controllers "Guard";
	ControllableBase.Replacements "MechaNaziWalking2";
	}
	States
	{
	Spawn:
		MCST B 1 NODELAY A_SetTics(Random(1, 35));
		Goto Active;
	Active:
		"####" "#" 35 A_CheckReplace(128);
		Loop;
	}
}

class MechaNaziStanding3 : MechaNaziStanding1
{
	Default
	{
	//$Title Empty Gebirgsjager Mecha-Nazi (Arctic Rifle Guards only)
	ControllableBase.Controllers "ArcticRifleGuard";
	ControllableBase.Replacements "MechaNaziWalking3";
	}
	States
	{
	Spawn:
		MCST C 1 NODELAY A_SetTics(Random(1, 35));
		Goto Active;
	Active:
		"####" "#" 35 A_CheckReplace(128);
		Loop;
	}
}

class MechaNaziStanding4 : MechaNaziStanding1
{
	Default
	{
	//$Title Empty SS Mecha-Nazi (SS Guards only)
	ControllableBase.Controllers "SSGuard";
	ControllableBase.Replacements "MechaNaziWalking4";
	}
	States
	{
	Spawn:
		MCST D 1 NODELAY A_SetTics(Random(1, 35));
		Goto Active;
	Active:
		"####" "#" 35 A_CheckReplace(128);
		Loop;
	}
}

class MechaNaziStanding5 : MechaNaziStanding1
{
	Default
	{
	//$Title Empty Kriegsmarine Mecha-Nazi (SS Guards only)
	ControllableBase.Controllers "SSGuard";
	ControllableBase.Replacements "MechaNaziWalking5";
	}
	States
	{
	Spawn:
		MCST E 1 NODELAY A_SetTics(Random(1, 35));
		Goto Active;
	Active:
		"####" "#" 35 A_CheckReplace(128);
		Loop;
	}
}

class MechaNaziWalking1 : MechBoss
{
	Default
	{
	//$Category Monsters (BoA)/Mechas
	//$Title Thor's Hammer Mecha-Nazi (Boss, Wehrmacht)
	//$Color 4
	Radius 48;
	Height 128;
	Health 800;
	Mass 3000;
	Speed 2.2777777;
	Obituary "$MECHBOSA";
	SeeSound "mech/wake";
	DeathSound "mech/death";
	DropItem "NebAmmo", 128;
	DropItem "NebAmmo", 128;
	DropItem "NebAmmoBox", 64;
	DropItem "GrenadePickup", 128;
	Base.BossIcon "BOSSICO1";
	+BOSS
	+NOPAIN
	MaxStepHeight 32;
	BloodType "TankSpark";
	Tag "$TAGWEHRMECHA";
	}
	States
	{
	Spawn:
		MCWR N 0;
		Goto Look;
	Look:
		"####" "#" 20 A_Look;
		Loop;
	Missile:
		"####" N 9 A_FaceTarget;
		"####" G 5 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",96,48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 5 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 5 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 9 A_FaceTarget;
		"####" F 5 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",96,-48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 5 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 5 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 9 A_FaceTarget;
		"####" G 5 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",96,48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 5 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 5 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 9 A_FaceTarget;
		"####" F 5 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",96,-48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 5 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 5 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 7 A_FaceTarget;
		"####" N 0 A_JumpIf(Health<300,"Missile2");
		Goto See;
	Missile2:
		"####" N 2 A_FaceTarget;
		"####" G 4 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",96,48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 4 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 4 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 2 A_FaceTarget;
		"####" F 4 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",96,-48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 4 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 4 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 2 A_FaceTarget;
		"####" G 4 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",96,48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 4 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" G 4 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",80,64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 2 A_FaceTarget;
		"####" F 4 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",96,-48,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 4 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-32,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" F 4 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",80,-64,frandom(-4, 4),CMF_OFFSETPITCH,-4);
		"####" N 7 A_FaceTarget;
		Goto See;
	Death:
		TNT1 A 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_IDLE);
		"####" A 0 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AA 0 A_SpawnItemEx("Debris_Mecha", random(8,40), random(16,44), random(32,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAA 0 A_SpawnItemEx("Debris_Mecha", random(16,80), random(32,88), random(64,96), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_Mecha", random(32,96), random(64,128), random(72,128), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("Nuke", 0, 0, 64, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 1 A_SpawnItemEx("KaBoomer", 0, 0, 32, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 1 A_SpawnItemEx("GeneralExplosion_Large", 0, 0, 64);
		"####" A 1 A_CheckAltDeath;
		Stop;
	Death.Alt1:
		"####" A 64;
		"####" A 1 A_SpawnItemEx("WGuard_Wounded", 0, 0, 0);
		Stop;
	}
}

class MechaNaziWalking2 : MechaNaziWalking1
{
	Default
	{
	//$Title Thor's Hammer Mecha-Nazi (Boss, Afrika Korps)
	Obituary "$MECHBOSB";
	Tag "$TAGAFRMECHA";
	}
	States
	{
	Spawn:
		MCAF N 0;
		Goto Look;
	Death:
		TNT1 A 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_IDLE);
		"####" A 0 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AA 0 A_SpawnItemEx("Debris_Mecha2", random(8,40), random(16,44), random(32,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAA 0 A_SpawnItemEx("Debris_Mecha2", random(16,80), random(32,88), random(64,96), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_Mecha2", random(32,96), random(64,128), random(72,128), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("Nuke", 0, 0, 64, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 1 A_SpawnItemEx("KaBoomer", 0, 0, 32, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 1 A_SpawnItemEx("GeneralExplosion_Large", 0, 0, 64);
		"####" A 1 A_CheckAltDeath;
		Stop;
	Death.Alt1:
		"####" A 64;
		"####" A 1 A_SpawnItemEx("Guard_Wounded", 0, 0, 0);
		Stop;
	}
}

class MechaNaziWalking3 : MechaNaziWalking1 //No Wounde soldiers
{
	Default
	{
	//$Title Thor's Hammer Mecha-Nazi (Boss, Arctic)
	Obituary "$MECHBOSC";
	Tag "$TAGARCTICMECHA";
	}
	States
	{
	Spawn:
		MCSN N 0;
		Goto Look;
	Death:
		TNT1 A 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_IDLE);
		"####" A 0 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AA 0 A_SpawnItemEx("Debris_Mecha3", random(8,40), random(16,44), random(32,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAA 0 A_SpawnItemEx("Debris_Mecha3", random(16,80), random(32,88), random(64,96), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_Mecha3", random(32,96), random(64,128), random(72,128), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("Nuke", 0, 0, 64, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 1 A_SpawnItemEx("KaBoomer", 0, 0, 32, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 1 A_SpawnItemEx("GeneralExplosion_Large", 0, 0, 64);
		Stop;
	}
}

class MechaNaziWalking4 : MechaNaziWalking1
{
	Default
	{
	//$Title Thor's Hammer Mecha-Nazi (Boss, SS)
	Obituary "$MECHBOSD";
	Tag "$TAGSSMECHA";
	}
	States
	{
	Spawn:
		MCSS N 0;
		Goto Look;
	Death:
		TNT1 A 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_IDLE);
		"####" A 0 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AA 0 A_SpawnItemEx("Debris_Mecha4", random(8,40), random(16,44), random(32,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAA 0 A_SpawnItemEx("Debris_Mecha4", random(16,80), random(32,88), random(64,96), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_Mecha4", random(32,96), random(64,128), random(72,128), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("Nuke", 0, 0, 64, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 1 A_SpawnItemEx("KaBoomer", 0, 0, 32, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 1 A_SpawnItemEx("GeneralExplosion_Large", 0, 0, 64);
		"####" A 1 A_CheckAltDeath;
		Stop;
	Death.Alt1:
		"####" A 64;
		"####" A 1 A_SpawnItemEx("SSGuard_Wounded", 0, 0, 0);
		Stop;
	}
}

class MechaNaziWalking5 : MechaNaziWalking1
{
	Default
	{
	//$Title Thor's Hammer Mecha-Nazi (Boss, Navy)
	Obituary "$MECHBOSE";
	Tag "$TAGNAVYMECHA";
	}
	States
	{
	Spawn:
		MAVY N 0;
		Goto Look;
	Missile:
		"####" N 0 A_JumpIf(Health<400,"Missile2");
		"####" N 10 A_FaceTarget;
		"####" GGGGGG 1 LIGHT("OTTOFIRE") A_SpawnProjectile("EnemyFlamerShot",96,48);
		"####" G 6;
		"####" FFFFFF 1 LIGHT("OTT2FIRE") A_SpawnProjectile("EnemyFlamerShot",96,-48);
		"####" F 8;
		"####" G 6 A_MonsterRefire(64,"See");
		Goto See;
	Missile2:
		"####" N 10 A_FaceTarget;
		"####" GGGGGG 1 LIGHT("OTTOFIRE") A_SpawnProjectile("EnemyFlamerShot",96,48);
		"####" G 6;
		"####" FFFFFF 1 LIGHT("OTT2FIRE") A_SpawnProjectile("EnemyFlamerShot",96,-48);
		"####" F 8;
		"####" G 4 LIGHT("OTTOFIRE") A_SpawnProjectile("MiniMechaRocket",96,48);
		"####" G 4;
		"####" F 4 LIGHT("OTT2FIRE") A_SpawnProjectile("MiniMechaRocket",96,-48);
		"####" F 6;
		Goto See;
	Death: //no special death, needs fitting debris
		TNT1 A 0 A_StartSound("weapons/explode", CHAN_AUTO, 0, 1.0, ATTN_IDLE);
		"####" A 0 A_Scream;
		"####" A 0 A_NoBlocking;
		"####" AA 0 A_SpawnItemEx("Debris_Mecha5", random(8,40), random(16,44), random(32,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAA 0 A_SpawnItemEx("Debris_Mecha5", random(16,80), random(32,88), random(64,96), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" AAAA 0 A_SpawnItemEx("Debris_Mecha5", random(32,96), random(64,128), random(72,128), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 0 A_SpawnItemEx("Nuke", 0, 0, 64, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		"####" A 1 A_SpawnItemEx("KaBoomer", 0, 0, 32, 0, 0, 0, 0, SXF_TRANSFERPOINTERS);
		"####" A 1 A_SpawnItemEx("GeneralExplosion_Large", 0, 0, 64);
		Stop;
	}
}