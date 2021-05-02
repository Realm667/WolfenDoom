/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, Nash,
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

//const NASHGORE_BLOODSPOT_DURATION = 1050; //not needed anymore because of cvars - Ozy81
const NASHGORE_BLOODFLAGS1 = SXF_TRANSFERTRANSLATION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE | SXF_ABSOLUTEVELOCITY;
const NASHGORE_BLOODFLAGS2 = SXF_TRANSFERTRANSLATION | SXF_ABSOLUTEVELOCITY | SXF_ABSOLUTEANGLE | SXF_NOCHECKPOSITION;
const NASHGORE_BLOODFLAGS3 = SXF_TRANSFERTRANSLATION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE;

// Base blood
class NashGore_BloodBase : BloodBase
{
	Default
	{
		-SOLID
		+CANNOTPUSH
		+CORPSE
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
		+NOBLOCKMONST
		+NOTELEPORT
	}
}

// Emulated regular Doom blood
class NashGore_DoomBlood : Blood
{
	Default
	{
		+DONTSPLASH
		+FORCEXYBILLBOARD
	}
}

// added for BoA
class NashGore_RavenBlood : BloodSplatter
{
	Default
	{
		+DONTSPLASH
		+FORCEXYBILLBOARD
	}
}

// Modify the internal Blood actor to spawn flying blood
class NashGore_Blood : Blood replaces Blood
{
	Default
	{
		-RANDOMIZE
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SpawnItem("NashGore_DoomBlood", 0, 0, 0, 1);
	SpawnDone:
		TNT1 A 0 A_SpawnItemEx("NashGore_FlyingBlood", 0, 0, 0, frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.0, 6.0), 0, NASHGORE_BLOODFLAGS1, 64);
		TNT1 AA 0 A_SpawnItemEx("NashGore_SplatMaker", 0, 0, 0, frandom(-5, 5), frandom(-5, 5), frandom(0, 5), random(0, 360), NASHGORE_BLOODFLAGS2);
		TNT1 AA 4 A_SpawnItemEx("NashGore_BloodSplasher", 0, 0, 0, frandom(-2.0, 2.0), frandom(-2.0, 2.0), frandom(1.0, 2.0), random(0, 360), NASHGORE_BLOODFLAGS1, 128);
		Stop;
	}
}

// added for BoA
class NashGore_BloodSplatter : NashGore_Blood replaces BloodSplatter
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SpawnItem("NashGore_RavenBlood", 0, 0, 0, 1);
		TNT1 A 0 A_Jump(256, "SpawnDone");
		Stop;
	}
}

// Blood actor that flies outwards and leaves trails behind
class NashGore_FlyingBlood : NashGore_BloodBase
{
	Default
	{
		Radius 8;
		Height 2;
		Gravity 0.25;
	}
	States
	{
	Spawn:
	FlyingNormal:
		TNT1 A 2 A_SpawnItem("NashGore_FlyingBloodTrail", 0, 0, 0, 1);
		TNT1 A 0 A_Jump(12, "RandomlyDestroy");
		TNT1 A 0 A_Jump(27, "FlyingDecel");
		Loop;
	FlyingDecel:
		TNT1 A 2 A_SpawnItem("NashGore_FlyingBloodTrail", 0, 0, 0, 1);
		TNT1 A 0 A_ChangeVelocity(Vel.X * 0.8, Vel.Y * 0.8, Vel.Z, CVF_REPLACE);
		Loop;
	RandomlyDestroy:
		TNT1 A 0;
		Stop;
	Crash:
		TNT1 A 0 A_StartSound("bloodsplat");
		TNT1 A 0 A_SpawnItem("NashGore_BloodSplash", 0, 0, 0, 1);
	BloodSplasher:
		TNT1 A 0 A_SpawnItemEx("NashGore_BloodSpot", 0, 0, 0, 0, 0, 0, frandom(0, 360), 7, 128);
		TNT1 AAAAA 1 A_SpawnItemEx("NashGore_BloodSplasher", 0, 0, 0, frandom(-2.0, 2.0), frandom(-2.0, 2.0), frandom(1.0, 2.0), random(0, 360), NASHGORE_BLOODFLAGS1, 150);
		Stop;
	}
}

// Blood trails spawned by FlyingBlood
class NashGore_FlyingBloodTrail : NashGore_BloodBase
{
	Default
	{
		Radius 1;
		Height 1;
		Gravity 0.15;
		Scale 0.55;
	}
	States
	{
	Spawn:
		BTRL ABCD 4;
		Loop;
	Crash:
		TNT1 A 0;
		Stop;
	}
}

// Blood splashers, generates Random splashes
class NashGore_BloodSplasher : NashGore_BloodBase
{
	Default
	{
		Radius 1;
		Height 1;
		Gravity 0.20;
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Loop;
	Crash:
		TNT1 A 0 A_SpawnItem("NashGore_BloodSplash", 0, 0, 0, 1);
		TNT1 A 0 A_SpawnItemEx("NashGore_BloodSpot", 0, 0, 0, 0, 0, 0, random(0, 360), NASHGORE_BLOODFLAGS3, 200);
		Stop;
	}
}

// Blood spots that temporarily stay on the floor
class NashGore_BloodSpot : NashGore_BloodBase
{
	Default
	{
		Radius 4;
		Height 2;
		Alpha 0.85;
		-NOBLOCKMAP
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_SpawnItem("NashGore_BloodSplash", 0, 0, 0, 1);
		TNT1 A 0 A_Jump(256, "BloodSpot1", "BloodSpot2", "BloodSpot3", "BloodSpot4");
	BloodSpot1:
		BSPT A 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	BloodSpot2:
		BSPT B 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	BloodSpot3:
		BSPT C 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	BloodSpot4:
		BSPT D 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	FadeOut:
		"####" "#" 2 A_FadeOut(0.005);
		Loop;
	}
}

// Blood splashes
class NashGore_BloodSplash : NashGore_BloodBase
{
	Default
	{
		Radius 1;
		Height 2;
		Scale 0.5;
		-NOBLOCKMAP
	}
	States
	{
	Spawn:
		BSPL ABCDE 5;
		Stop;
	}
}

// Blood splat decal maker
class NashGore_SplatMaker: Actor
{
	Default
	{
		Radius 4;
		Height 8;
		PROJECTILE;
	}
	States
	{
	Spawn:
		TNT1 A 3;
	Death:
		TNT1 A 1;
		Stop;
	}
}

// BOA Translations
class BossBlood : NashGore_Blood { Default { Translation "16:47=112:127","168:191=112:127"; } }
class BossFlyingBlood : NashGore_FlyingBlood { Default { Translation "16:47=112:127","168:191=112:127"; } }
class MutantBlood : NashGore_Blood { Default { Translation "16:47=[205,0,215]:[40,0,96]","168:191=[205,0,215]:[40,0,96]"; } }
class MutantFlyingBlood : NashGore_FlyingBlood { Default { Translation "16:47=[205,0,215]:[40,0,96]","168:191=[205,0,215]:[40,0,96]"; } }
class ScorpionBlood : NashGore_Blood { Default { Translation "16:47=208:223","168:191=210:224"; } }
class ScorpionFlyingBlood : NashGore_FlyingBlood { Default { Translation "16:47=208:223","168:191=210:224"; } }
class UndeadBlood : NashGore_Blood { Default { Translation "16:47=[34,0,7]:[0,0,0]","168:191=[36,0,9]:[2,0,0]"; } }
class UndeadFlyingBlood : NashGore_FlyingBlood { Default { Translation "16:47=[34,0,7]:[0,0,0]","168:191=[36,0,9]:[2,0,0]"; } }
class UndeadFlyingBloodTrail : NashGore_FlyingBloodTrail { Default { Translation "16:47=[34,0,7]:[0,0,0]","168:191=[36,0,9]:[2,0,0]"; } }

class Pain_Overlay: Actor
{
	Default
	{
		Radius 1;
		Height 1;
		-SOLID
		+DONTSPLASH
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+NOTELEPORT
	}
	States
	{
	Spawn:
		PNSP A 1;
		"####" A 0 A_Fadeout(.1);
		Loop;
	}
}

//Zombie related variants - needed for brightmaps
class Zombie_DoomBlood : NashGore_DoomBlood
{
	Default
	{
		Decal "ZBloodSmear";
		Translation "16:47=[0,112,69]:[0,112,85]","168:191=[0,112,69]:[0,112,85]";
	}
}

class ZombieBlood : NashGore_Blood
{
	Default
	{
		Decal "ZBloodSmear";
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SpawnItem("Zombie_DoomBlood", 0, 0, 0, 1);
	SpawnDone:
		TNT1 A 0 A_SpawnItemEx("Zombie_FlyingBlood", 0, 0, 0, frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.1, 6.0) * RandomPick(-1, 1), frandom(0.0, 6.0), 0, NASHGORE_BLOODFLAGS1, 64);
		TNT1 AA 0 A_SpawnItemEx("Zombie_SplatMaker", 0, 0, 0, frandom(-5, 5), frandom(-5, 5), frandom(0, 5), random(0, 360), NASHGORE_BLOODFLAGS2);
		TNT1 AA 4 A_SpawnItemEx("Zombie_BloodSplasher", 0, 0, 0, frandom(-2.0, 2.0), frandom(-2.0, 2.0), frandom(1.0, 2.0), random(0, 360), NASHGORE_BLOODFLAGS1, 128);
		Stop;
	}
}

class Zombie_BloodSplatter : NashGore_BloodSplatter
{
	Default
	{
		Decal "ZBloodSmear";
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_SpawnItem("NashGore_RavenBlood", 0, 0, 0, 1);
		TNT1 A 0 A_Jump(256, "SpawnDone");
		Stop;
	}
}

class Zombie_FlyingBlood : NashGore_FlyingBlood
{
	Default
	{
		Decal "ZBloodSmear";
	}
	States
	{
	Spawn:
	FlyingNormal:
		TNT1 A 2 A_SpawnItem("Zombie_FlyingBloodTrail", 0, 0, 0, 1);
		TNT1 A 0 A_Jump(12, "RandomlyDestroy");
		TNT1 A 0 A_Jump(27, "FlyingDecel");
		Loop;
	FlyingDecel:
		TNT1 A 2 A_SpawnItem("Zombie_FlyingBloodTrail", 0, 0, 0, 1);
		TNT1 A 0 A_ChangeVelocity(Vel.X * 0.8, Vel.Y * 0.8, Vel.Z, CVF_REPLACE);
		Loop;
	RandomlyDestroy:
		TNT1 A 0;
		Stop;
	Crash:
		TNT1 A 0 A_StartSound("bloodsplat");
		TNT1 A 0 A_SpawnItem("Zombie_BloodSplash", 0, 0, 0, 1);
	BloodSplasher:
		TNT1 A 0 A_SpawnItemEx("Zombie_BloodSpot", 0, 0, 0, 0, 0, 0, frandom(0, 360), 7, 128);
		TNT1 AAAAA 1 A_SpawnItemEx("Zombie_BloodSplasher", 0, 0, 0, frandom(-2.0, 2.0), frandom(-2.0, 2.0), frandom(1.0, 2.0), random(0, 360), NASHGORE_BLOODFLAGS1, 150);
		Stop;
	}
}

class Zombie_FlyingBloodTrail : NashGore_FlyingBloodTrail
{
	Default
	{
		Decal "ZBloodSmear";
	}
	States
	{
	Spawn:
		ZTRL ABCD 4;
		Loop;
	}
}

class Zombie_BloodSplasher : NashGore_BloodSplasher
{
	Default
	{
		Decal "ZBloodSmear";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Loop;
	Crash:
		TNT1 A 0 A_SpawnItem("Zombie_BloodSplash", 0, 0, 0, 1);
		TNT1 A 0 A_SpawnItemEx("Zombie_BloodSpot", 0, 0, 0, 0, 0, 0, random(0, 360), NASHGORE_BLOODFLAGS3, 200);
		Stop;
	}
}

class Zombie_BloodSpot : NashGore_BloodSpot
{
	Default
	{
		Decal "ZBloodSmear";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_SpawnItem("Zombie_BloodSplash", 0, 0, 0, 1);
		TNT1 A 0 A_Jump(256, "BloodSpot1", "BloodSpot2", "BloodSpot3", "BloodSpot4");
	BloodSpot1:
		ZSPT AEI 1 A_SetTics(random(24,35));
		"####" M 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	BloodSpot2:
		ZSPT BFJ 1 A_SetTics(random(24,35));
		"####" N 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	BloodSpot3:
		ZSPT CGK 1 A_SetTics(random(24,35));
		"####" O 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	BloodSpot4:
		ZSPT DHL 1 A_SetTics(random(24,35));
		"####" P 0 A_SetTics(35*boa_bloodlifetime);
		"####" "#" 0 A_Jump(256, "FadeOut");
	FadeOut:
		"####" "#" 2 A_FadeOut(0.005);
		Loop;
	}
}

class Zombie_BloodSplash : NashGore_BloodSplash
{
	Default
	{
		Decal "ZBloodSmear";
	}
	States
	{
	Spawn:
		ZSPL ABCDE 5;
		Stop;
	}
}

class Zombie_SplatMaker : NashGore_SplatMaker
{
	Default
	{
		Decal "ZBloodSmear";
		Translation "16:47=[0,112,69]:[0,112,85]","168:191=[0,112,69]:[0,112,85]";
	}
}

class ZPain_Overlay : Pain_Overlay
{
	States
	{
	Spawn:
		PNSZ A 1;
		"####" A 0 A_Fadeout(.1);
		Loop;
	}
}