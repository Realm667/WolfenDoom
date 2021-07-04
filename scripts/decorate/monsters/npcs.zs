/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, MaxED, AFADoomer, Talon1024                    
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

class StatistBarkeeper : Base
{
	Default
	{
		//$Category Monsters (BoA)/NPCs
		//$Title Juliette Bertrand, Barkeeper (NPC)
		//$Color 4
		Height 56;
		Mass 100;
		Scale 0.65;
		+FRIENDLY
		+NONSHOOTABLE
		+SOLID
		+DONTTHRUST
		-COUNTKILL //N00b
		Monster;
	}

	States
	{
		Spawn:
			BDKP A 80;
			"####" B 40;
			"####" CB 40;
			"####" D 80;
			"####" DACB 40;
			"####" E 40;
			"####" F 40;
			Loop;
		Greet:
			BDKP G 4;
			BDKP HIHJHIHJH 7;
			BDKP K 4;
			Goto Spawn;
	}

	override bool Used(Actor user)
	{
		AchievementTracker.CheckSpecials(special);
		level.ExecuteSpecial(special, user, null, null, args[0], args[1], args[2], args[3], args[4]);

		return true;
	}
}

class Clerk : StatistBarkeeper
{
	Default
	{
	//$Title Lt. Laz Rojas
	}
	States
	{
	Spawn:
		BLCK A 0 NODELAY A_Jump(256,"Pose1","Pose2");
	Pose1:
		BLCK A -1;
		Stop;
	Pose1:
		BLCK B -1;
		Stop;
	}
}

class StatistMedic : StatistBarkeeper
{
	Default
	{
	//$Title Ty Halderman, Medic (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		MEDC A 80;
		"####" B 40;
		"####" CB 40;
		"####" D 80;
		"####" DACB 40;
		"####" E 40;
		"####" F 40;
		Loop;
	}
}

class StatistAFA : StatistBarkeeper
{
	Default
	{
	//$Title AFADoomer, Radio Technician (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		AFAD A 80;
		"####" B 40;
		"####" CB 40;
		"####" F 80;
		"####" A 80;
		"####" DE 40;
		"####" DA 80;
		"####" GABC 40;
		"####" B 40;
		Loop;
	}
}

class StatistSSAscher : StatistBarkeeper
{
	Default
	{
	//$Title Sgt Ascher (SS Uniform)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		ASCH A 0 NODELAY A_Jump(128, "SpawnLoop2");
	SpawnLoop1:
		"####" A 80;
		"####" B 40;
		"####" CB 40;
		"####" D 80;
		"####" A 80;
		"####" BE 40;
		"####" CA 80;
		Goto Spawn;
	SpawnLoop2:
		"####" F 80;
		"####" G 40;
		"####" HG 40;
		"####" I 80;
		"####" F 80;
		"####" GJ 40;
		"####" HF 80;
		Goto Spawn;
	}
}

class StatistPeeingMan : StatistBarkeeper
{
	Default
	{
	//$Title Col. Baker, Old Marine Peeing (NPC)
	Scale 0.67;
	-USESPECIAL
	+DONTFACETALKER
	}
	States
	{
	Spawn:
		OLDM A 1 A_SetTics(random(20,40)); //possible whistle here
		"####" BCDCCDBD 1 A_SetTics(random(20,40));
		"####" "#" 1 A_Jump(128,"Left","Right");
		Loop;
	Left:
		"####" EFGFFGEG 1 A_SetTics(random(20,40));
		"####" "#" 1 A_Jump(32,"Right");
		Goto Spawn;
	Right:
		"####" HIJIIJHJ 1 A_SetTics(random(20,40));
		"####" "#" 1 A_Jump(32,"Left");
		Goto Spawn;
	}
}

class StatistStierlitz1 : StatistBarkeeper
{
	Default
	{
	//$Title Col. Stierlitz, Civilian clothes (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		STIE A 80;
		"####" B 40;
		"####" CB 40;
		"####" B 80;
		Loop;
	}
}

class StatistStierlitz2 : StatistBarkeeper
{
	Default
	{
	//$Title Col. Stierlitz, SS uniform (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		STIE D 80;
		"####" E 40;
		"####" FE 40;
		"####" E 80;
		Loop;
	Aim:
		STIE D 8;
		STIE J 8;
		STIE K 1000;
		Wait;
	}
}

class StatistStierlitz3 : StatistBarkeeper
{
	Default
	{
	//$Title Col. Stierlitz, Prisoner clothes (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		STIE G 80;
		"####" H 40;
		"####" IH 40;
		"####" H 80;
		Loop;
	}
}

class StatistVolkoff : StatistBarkeeper
{
	Default
	{
	//$Title Polk. Volkoff (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		YEVG A 80;
		"####" B 40;
		"####" CB 40;
		"####" B 80;
		Loop;
	}
}

class StatistDimitri : StatistBarkeeper
{
	Default
	{
	//$Title Dimitri, Tankist Engineer (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		RUST A 80;
		"####" B 40;
		"####" CB 40;
		"####" B 80;
		Loop;
	}
}

class StatistZhukov : StatistBarkeeper
{
	Default
	{
	//$Title Marshal Zhukov (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		ZHUK E 80;
		"####" F 40;
		"####" GH 40;
		"####" A 80;
		"####" BDCA 40;
		"####" CA 40;
		"####" FE 40;
		Loop;
	}
}

class StatistSSMerchant : StatistBarkeeper
{
	Default
	{
	//$Title Fritz, SS Merchant (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		MERK A 1 A_SetTics(random(20,40));
		"####" BCDCCDBD 1 A_SetTics(random(20,40));
		"####" "#" 1 A_Jump(128,"SeeAround");
		Loop;
	SeeAround:
		"####" DEFEEDFD 1 A_SetTics(random(20,40));
		"####" "#" 1 A_Jump(32,"Spawn");
		Goto Spawn;
	SellLeft: //called via scripts
		"####" GHIJKKJHJLGF 1 A_SetTics(random(60,120));
		"####" "#" 1 A_Jump(192,"SeeAround");
		Goto Spawn;
	SellRight: //called via scripts
		"####" NOPQRSOPNONM 1 A_SetTics(random(60,120));
		"####" "#" 1 A_Jump(192,"SeeAround");
		Goto Spawn;
	}
}

class StatistNWSmuggler : StatistBarkeeper
{
	Default
	{
	//$Title Mikkel, Norwegian Smuggler (NPC)
	Scale 0.67;
	-USESPECIAL
	+NODAMAGE
	}
	States
	{
	Spawn:
		SMGL A 1 A_SetTics(random(20,40));
		"####" AEEFFEFF 1 A_SetTics(random(20,40));
		"####" "#" 1 A_Jump(128,"Smoke");
		Loop;
	Smoke:
		"####" A 80;
		"####" BCDB 40;
		"####" E 40;
		"####" F 40;
		Goto Spawn;
	}
}

class StatistWehrmachtSpy: StatistBarkeeper
{
	Default
	{
	//$Title Surrendering Wehrmacht Soldier for C3M5_A (NPC)
	Scale 0.67;
	-USESPECIAL
	}
	States
	{
	Spawn:
		GRDS A 0;
		Goto Look;
	Look:
		"####" A 0 A_StartSound("nazi/snore", CHAN_VOICE, 0, 1.0, ATTN_STATIC);
		"####" A 40;
		"####" BBB 10 A_SpawnItemEx("SleepEffect", random(-2,2), random(-2,2), random(24,32), 0, 0, 1, 0, SXF_SETMASTER | SXF_CLIENTSIDE);
		Loop;
	See: //SetState("See") from scripts
		"####" C 13;
		"####" D 11;
		"####" E 9;
		Goto See.Loop;
	See.Loop:
		"####" F 0;
		"####" F 32 A_Jump(64, "Blink");
		Goto See.Loop;
	Blink:
		"####" F 8;
		"####" G 16;
		"####" F 8;
		Goto See.Loop;
	}
}

class StatistSpion: StatistBarkeeper
{
	Default
	{
		//$Title Nazi Spy (NPC)
	}
	States
	{
	Spawn:
		OBNC A 35 A_Jump(64, "ZoomOut");
		Loop;
	ZoomOut:
		OBNC B 35 A_Jump(192, "Blink", "Search1", "Search2");
		OBNC B 35 A_Jump(32, "ZoomOut");
		Goto Spawn;
	Blink:
		OBNC B 14;
		OBNC C 7;
		OBNC B 35;
		OBNC A 35;
		Goto Spawn;
	Search1:
		OBNC D 14;
		OBNC B 7;
		OBNC E 14;
		OBNC A 35;
		Goto Spawn;
	Search2:
		OBNC E 14;
		OBNC B 7;
		OBNC D 14;
		OBNC A 35;
		Goto Spawn;
	}
}

class StatistBarkeeperMale : StatistBarkeeper
{
	Default
	{
		//$Title Haggis McMutton, Barkeeper (NPC)
	}
	States
	{
	Spawn:
		BDK2 A 80;
		"####" B 40;
		"####" CB 40;
		"####" D 80;
		"####" DACB 40;
		"####" E 40;
		"####" F 40;
		Loop;
	}
}

class StatistSinger : SwitchableDecoration
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title Marlene Dietrich (NPC)
	//$Color 4
	//$Sprite MADIA0
	Height 56;
	Mass 100;
	Scale 0.67;
	+NONSHOOTABLE
	+SOLID
	+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		MADI A 0;
	Active:
		MADI ABCDEFBGDHFIB 8 A_SetSolid;
		Loop;
	Inactive:
		TNT1 A -1 A_UnSetSolid;
		Loop;
	}
}

class StatistDarren : StatistBarkeeper
{
	Default
	{
	//$Title Dirty Douglas, Headquarters (NPC)
	Translation 1;
	Species "Ally";
	+INVULNERABLE
	}
	States
	{
	Spawn:
		DARS A 0 NODELAY A_Jump(256,"Idle1","Idle2","Idle3","Idle4","Idle5","Idle6");
	Idle1:
		"####" A 20;
		"####" B 40;
		"####" CB 40;
		"####" A 80;
		"####" TACB 40;
		"####" B 40;
		"####" C 40;
		"####" C 0 A_Jump(32,"Idle2","Idle3","Idle6");
		Goto Spawn;
	Idle2:
		"####" A 20;
		"####" D 40;
		"####" EF 40;
		"####" A 80;
		"####" DFEA 40;
		"####" F 40;
		"####" D 40;
		"####" C 0 A_Jump(32,"Idle1","Idle3","Idle6");
		Goto Spawn;
	Idle3:
		"####" G 20;
		"####" H 40;
		"####" IH 40;
		"####" G 80;
		"####" HIGH 40;
		"####" I 40;
		"####" G 40;
		"####" G 0 A_Jump(32,"Idle2","Idle4");
		Goto Spawn;
	Idle4:
		"####" J 20;
		"####" K 40;
		"####" LK 40;
		"####" J 80;
		"####" KJLK 40;
		"####" L 40;
		"####" J 40;
		"####" J 0 A_Jump(32,"Idle5","Idle6");
		Goto Spawn;
	Idle5:
		"####" M 40;
		"####" N 80;
		"####" MO 80;
		"####" G 80;
		"####" MNON 40;
		"####" M 40;
		"####" O 60;
		"####" O 0 A_Jump(32,"Idle2","Idle4");
		Goto Spawn;
	Idle6:
		"####" P 80;
		"####" QRSQ 40;
		"####" P 40;
		"####" T 40;
		"####" T 0 A_Jump(32,"Idle1","Idle2","Idle4");
		Goto Spawn;
	}
}

class KittySinger: Actor
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title Saloon Kitty (NPC, Shootable)
	//$Color 4
	Height 56;
	Health 10;
	Mass 600;
	Scale 0.67;
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	+CASTSPRITESHADOW
	Species "Nazi";
	}
	States
	{
	Spawn:
		KITY A 0;
	SpawnLoop:
		"####" A 0 A_CheckRange(768,"SpawnLoopSilent");
		"####" A 1;
		"####" B 0 A_StartSound("SALOONKY", CHAN_AUTO, CHANF_LOOPING, 1.0, ATTN_STATIC);
		"####" ABCDBACDADCB 8;
		Loop;
	SpawnLoopSilent:
		"####" A 0 A_StopSound(CHAN_AUTO);
		"####" ABCDBACDADCB 8;
		Goto SpawnLoop;
	Death:
		"####" E 0 A_StopSound(CHAN_AUTO);
		"####" E 1 A_UnSetSolid;
		"####" FGHIJ 5;
		"####" K -1;
		Stop;
	}
}

class FatSinger : KittySinger
{
	Default
	{
	//$Title Brunhilde "Singing Fat Lady" (NPC, Shootable)
	Scale 0.47;
	}
	States
	{
	Spawn:
		BRUN A 0;
	SpawnLoop:
		BRUN AAAACDEFBGBACEDFGBACEFGGDDCC 24;
		Loop;
	Death:
		"####" G 5 A_UnSetSolid;
		"####" HI 4;
		"####" I 0 A_StartSound("FATSCREM", CHAN_AUTO, 0, 3.0, ATTN_STATIC);
		"####" JK 1 A_SetTics(random(8,12));
		"####" JK 1 { A_SetTics(random(1,2)); A_StartSound("nazi/farts", CHAN_AUTO, 0, frandom(1.0,3.0), ATTN_STATIC); }
		SLOP H 0 A_SpawnItemEx("Debris_FatAxe", 0, 12, 24, random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" H 0 A_SpawnItemEx("Debris_FatShield", 0, -12, 24, random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" H 0 A_SpawnItemEx("Debris_FatHelm", 0, 0, 56, random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIIIIIIIIII 0 A_SpawnItemEx("BloodSkullCloud",random(-16,16),random(-16,16),random(24,48),random(1,2), random(1,2), random(1,2), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 0 A_SpawnItemEx("Debris_FatFlesh", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIIIIIIIIIIIIIIIIII 0 A_SpawnItemEx("Debris_Flesh", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIIIIIIIIIII 0 A_SpawnItemEx("Debris_Flesh2", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIII 0 A_SpawnItemEx("NashGore_FlyingBlood", random(-16,16), random(-16,16), random(24,48), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IJKL 5;
		"####" M 5;
		"####" N -1;
		Stop;
	}
}

class ZFatSinger : FatSinger
{
	Default
	{
	//$Title Zombiefied Brunhilde "Singing Fat Lady" (NPC, Shootable)
	}
	States
	{
	Spawn:
		ZRUN A 0;
	SpawnLoop:
		ZRUN AAAACDEFBGBACEDFGBACEFGGDDCC 24;
		Loop;
	}
}

class BloodMime : KittySinger
{
	Default
	{
	//$Title Blood Mime (NPC, Easteregg)
	}
	States
	{
	Spawn:
		MIME A 0;
	SpawnLoop:
		MIME AAAACDBBACDBACDDCC 1 A_SetTics(random(12,24));
		Loop;
	Death:
		"####" "#" 5 A_UnSetSolid;
		"####" "#" 4;
		"####" "#" 0 A_StartSound("FATSCREM", CHAN_AUTO, 0, 3.0, ATTN_STATIC);
		"####" "#" 10 A_StartSound("nazi/farts", CHAN_AUTO, 0, frandom(1.0,3.0), ATTN_STATIC);
		SLOP HHHHHHHHHHHHHHHHHHHHHHHH 0 A_SpawnItemEx("Debris_Flesh", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIIIIIIIIIIIIIIIIII 0 A_SpawnItemEx("Debris_Flesh", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIIIIIIIIIII 0 A_SpawnItemEx("Debris_Flesh2", random(-16,16), random(-16,16), random(24,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IIIIIIIII 0 A_SpawnItemEx("NashGore_FlyingBlood", random(-16,16), random(-16,16), random(24,48), random(1,6), random(1,6), random(1,6), random(0,360), SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
		"####" IJKL 5;
		"####" M 5;
		"####" N -1;
		Stop;
	}
}

class Marine3AStatist : Marine1
{
	Default
	{
	Height 56;
	Mass 100;
	Scale 0.67;
	+FRIENDLY
	+SOLID
	}
	States
	{
	Spawn:
		ARH2 A -1;
		Stop;
	}
}

class Marine3BStatist : Marine3AStatist
{
	States
	{
	Spawn:
		MAH2 A -1;
		Stop;
	}
}

class GeneralAllied : Base
{
	Default
	{
	//$Category Monsters (BoA)/NPCs
	//$Title General Miller
	//$Color 4
	Obituary "$MILLER";
	Height 56;
	Mass 100;
	Scale 0.67;
	+SOLID
	+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		GENR O -1;
		Stop;
	}
}

class HelmetlessMarine1T : StatistBarkeeper
{
	Default
	{
	//$Title Helmetless Marine 1, Talking (NPC)
	Scale 0.67;
	Translation 1;
	}
	States
	{
	Spawn:
		ALL1 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" D 5 A_Jump(128,2);
		"####" DACB 12;
		"####" E 8;
		Loop;
	}
}

class HelmetlessMarine1C : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Marine 1, Cup (NPC)
	}
	States
	{
	Spawn:
		ALC1 A -1;
		Stop;
	}
}

class HelmetlessMarine1H : HelmetlessMarine1T
{
	Default
	{
		//$Title Helmetless Marine 1, Hands Crossed (NPC)
	}
	States
	{
	Spawn:
		ALH1 A -1;
		Stop;
	}
}

class HelmetlessMarine1O : HelmetlessMarine1T
{
	Default
	{
		//$Title Helmetless Marine 1, Smoking (NPC)
	}
	States
	{
	Spawn:
		ALO1 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" ACB 12;
		Loop;
	}
}

class HelmetlessMarine1S : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Marine 1, Standing (NPC)
	}
	States
	{
	Spawn:
		ALL1 A -1;
		Stop;
	}
}

class HelmetlessMarine2C : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Marine 2, Cup (NPC)
	}
	States
	{
	Spawn:
		ALC2 A -1;
		Stop;
	}
}

class HelmetlessMarine2H : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Marine 2, Hands Crossed (NPC)
	}
	States
	{
	Spawn:
		ALH2 A -1;
		Stop;
	}
}

class HelmetlessMarine2O : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Marine 2, Smoking (NPC)
	}
	States
	{
	Spawn:
		ALO2 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" ACB 12;
		Loop;
	}
}

class HelmetlessMarine2S : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Marine 2, Standing (NPC)
	}
	States
	{
	Spawn:
		ALL2 A -1;
		Stop;
	}
}

class HelmetlessMarine2T : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Marine 2, Talking (NPC)
	}
	States
	{
	Spawn:
		ALL2 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" D 5 A_Jump(128,2);
		"####" DACB 12;
		"####" E 8;
		Loop;
	}
}

class HelmetlessPara1C : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Paratrooper, Cup (NPC)
	}
	States
	{
	Spawn:
		ALC3 A -1;
		Stop;
	}
}

class HelmetlessPara1H : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Paratrooper, Hands Crossed (NPC)
	}
	States
	{
	Spawn:
		ALH3 A -1;
		Stop;
	}
}

class HelmetlessPara1O : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Paratrooper, Smoking (NPC)
	}
	States
	{
	Spawn:
		ALO3 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" ACB 12;
		Loop;
	}
}

class HelmetlessPara1S : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Paratrooper 1, Standing (NPC)
	}
	States
	{
	Spawn:
		ALL3 A -1;
		Stop;
	}
}

class HelmetlessPara1T : HelmetlessMarine1T
{
	Default
	{
	//$Title Helmetless Paratrooper 1, Talking (NPC)
	}
	States
	{
	Spawn:
		ALL3 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" D 5 A_Jump(128,2);
		"####" DACB 12;
		"####" E 8;
		Loop;
	}
}
//never use these randoms for talkable npcs! --ozy81
class HelmetlessAlliedRC : HelmetlessMarine1T
{
	Default
	{
	//$Title Random Helmetless Allied Soldier, Cup (NPC)
	}
	States
	{
	Spawn:
		ALC1 A 0 NODELAY A_SetScale(Scale.X, frandom(0.67, 0.69) );
	Randomize:
		ALC1 A 0 A_Jump(256,"Pose1","Pose2","Pose3");
		Stop;
	Pose1:
		ALC1 A -1;
		Stop;
	Pose2:
		ALC2 A -1;
		Stop;
	Pose3:
		ALC3 A -1;
		Stop;
	}
}

class HelmetlessAlliedRH : HelmetlessMarine1T
{
	Default
	{
	//$Title Random Helmetless Allied Soldier, Crossed Arms (NPC)
	}
	States
	{
	Spawn:
		ALH1 A 0 NODELAY A_SetScale(Scale.X, frandom(0.67, 0.69) );
	Randomize:
		ALH1 A 0 A_Jump(256,"Pose1","Pose2","Pose3");
		Stop;
	Pose1:
		ALH1 A -1;
		Stop;
	Pose2:
		ALH2 A -1;
		Stop;
	Pose3:
		ALH3 A -1;
		Stop;
	}
}

class HelmetlessAlliedRO : HelmetlessMarine1T
{
	Default
	{
	//$Title Random Helmetless Allied Soldier, Smoking (NPC)
	}
	States
	{
	Spawn:
		ALO1 A 0 NODELAY A_SetScale(Scale.X, frandom(0.67, 0.69) );
	Randomize:
		ALO1 A 0 A_Jump(256,"Pose1","Pose2","Pose3");
		Stop;
	Pose1:
		ALO1 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" ACB 12;
		Loop;
	Pose2:
		ALO2 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" ACB 12;
		Loop;
	Pose3:
		ALO3 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" ACB 12;
		Loop;
	}
}

class HelmetlessAlliedRS : HelmetlessMarine1T
{
	Default
	{
	//$Title Random Helmetless Allied Soldier, Standing (NPC)
	}
	States
	{
	Spawn:
		ALL1 A 0 NODELAY A_SetScale(Scale.X, frandom(0.67, 0.69) );
	Randomize:
		ALL1 A 0 A_Jump(256,"Pose1","Pose2","Pose3");
		Stop;
	Pose1:
		ALL1 A -1;
		Stop;
	Pose2:
		ALL2 A -1;
		Stop;
	Pose3:
		ALL3 A -1;
		Stop;
	}
}

class HelmetlessAlliedRT : HelmetlessMarine1T
{
	Default
	{
	//$Title Random Helmetless Allied Soldier, Talking (NPC)
	}
	States
	{
	Spawn:
		ALL1 A 0 NODELAY A_SetScale(Scale.X, frandom(0.67, 0.69) );
	Randomize:
		ALL1 A 0 A_Jump(256,"Pose1","Pose2","Pose3");
		Stop;
	Pose1:
		ALL1 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" D 5 A_Jump(128,2);
		"####" DACB 12;
		"####" E 8;
		Loop;
	Pose2:
		ALL2 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" D 5 A_Jump(128,2);
		"####" DACB 12;
		"####" E 8;
		Loop;
	Pose3:
		ALL3 A 5;
		"####" B 8 A_Jump(128,2);
		"####" CB 8;
		"####" D 5 A_Jump(128,2);
		"####" DACB 12;
		"####" E 8;
		Loop;
	}
}

//Concentration Camp NPCS
class Camp_StaticBroom: Actor
{
	Default
	{
	//$Category Concentration Camp (BoA)/Static
	//$Title Shootable Prisoner (with broom)
	//$Color 3
	Height 48;
	Health 500;
	Mass 600;
	Scale 0.65;
	+CASTSPRITESHADOW
	+FRIENDLY
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	+THRUSPECIES
	DeathSound "urss/death";
	Species "PlayerFollower";
	}
	States
	{
	Spawn:
		PRSA A -1;
		Stop;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" BCD 6 ;
		"####" E 8 A_Scream;
		"####" F -1;
		Stop;
	}
}

class Camp_StaticShovel : Camp_StaticBroom
{
	Default
	{
	//$Title Shootable Prisoner (with shovel)
	}
	States
	{
	Spawn:
		PRSB A -1;
		Stop;
	}
}

class Camp_StaticShovelLow : Camp_StaticBroom
{
	Default
	{
	//$Title Shootable Prisoner (with shovel, low)
	Height 24;
	+DONTTHRUST
	}
	States
	{
	Spawn:
		PRSD A -1;
		Stop;
	}
}

class Camp_StaticKneeing : Camp_StaticBroom
{
	Default
	{
	//$Title Shootable Prisoner (hurt, kneel)
	Height 32;
	}
	States
	{
	Spawn:
		PRSE A -1;
		Stop;
	}
}

class Camp_StaticStandingA : Camp_StaticBroom
{
	Default
	{
	//$Title Shootable Prisoner (standing, bald)
	}
	States
	{
	Spawn:
		PRSF A -1;
		Stop;
	}
}

class Camp_StaticStandingB : Camp_StaticBroom
{
	Default
	{
	//$Title Shootable Prisoner (standing, hat)
	}
	States
	{
	Spawn:
		PRSG A -1;
		Stop;
	}
}

class Camp_StaticStandingBTalk : StatistBarkeeper
{
	Default
	{
	//$Title Prisoner (standing, hat, talkable)
	-NOTAUTOAIMED	// Conversation fix - Talon1024
	-SOLID			// Avoid potential map breaking behaviors, since we can "use" it to climb high heights, like huts on c3m1 - Ozy81
	-USESPECIAL
	+DONTTHRUST		// prevent actor from moving if hit - ozy81
	}
	States
	{
	Spawn:
		PRSG A -1;
		Stop;
	}
}

class Camp_StaticWashBroom : Camp_StaticBroom
{
	Default
	{
	//$Title Shootable Prisoner (washbroom)
	}
	States
	{
	Spawn:
		PRSH A -1;
		Stop;
	}
}

class Camp_StaticSit : Camp_StaticBroom
{
	Default
	{
	//$Title Shootable Prisoner (sit on a bench)
	Height 32;
	+FORCEXYBILLBOARD
	}
	States
	{
	Spawn:
		PRSI A -1;
		Stop;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" B 8 A_Scream;
		"####" B -1;
		Stop;
	}
}

class Camp_StaticSitTalk : StatistBarkeeper
{
	Default
	{
	//$Title Prisoner (sit on the wc, talkable)
	Height 32;
	+FORCEXYBILLBOARD
	+DONTFACETALKER
	-USESPECIAL
	-SOLID
	}
	States
	{
	Spawn:
		PRSI A -1;
	}
}

class Camp_StaticShovelDig: Actor
{
	Default
	{
	//$Category Concentration Camp (BoA)/Static
	//$Title Shootable Prisoner (digging with shovel)
	//$Color 3
	Height 48;
	Health 500;
	Mass 600;
	Scale 0.65;
	+CASTSPRITESHADOW
	+FRIENDLY
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	DeathSound "urss/death";
	Species "PlayerFollower";
	}
	States
	{
	Spawn:
		PRSC A 0;
	SpawnLoop:
		PRSC A 0 A_CheckRange(512,"SpawnLoopSilent");
		PRSC A 1 A_SetTics(random(24,32));
		"####" B 0 A_StartSound("floor/dirt", CHAN_ITEM, 0, 1.0);
		"####" BCDE 1 A_SetTics(random(12,16));
		Loop;
	SpawnLoopSilent:
		PRSC A 0 A_StopSound(CHAN_ITEM);
		"####" A 1 A_SetTics(random(24,32));
		"####" BCDE 1 A_SetTics(random(12,16));
		Goto SpawnLoop;
	Death:
		"####" A 0 A_UnSetSolid;
		"####" FGH 8;
		"####" I 6 A_Scream;
		"####" J -1;
		Stop;
	}
}

class Camp_StaticHammeringL : Camp_StaticShovelDig
{
	Default
	{
	//$Title Shootable Prisoner (hammering, left)
	}
	States
	{
	Spawn:
		HAMM A 0 NoDelay A_Jump(256,"SpawnLoop");
	SpawnLoop:
		HAMM A 0 A_CheckRange(512,"SpawnLoopSilent");
		HAMM A 1 A_SetTics(random(24,32));
		"####" B 0 A_StartSound("floor/gravel", CHAN_ITEM, 0, 1.0);
		"####" BCD 1 A_SetTics(random(12,16));
		"####" CDCD 1 A_SetTics(random(12,16));
		"####" BB 1 A_SetTics(random(12,16));
		Loop;
	SpawnLoopSilent:
		HAMM A 0 A_StopSound(CHAN_ITEM);
		"####" A 1 A_SetTics(random(24,32));
		"####" BCD 1 A_SetTics(random(12,16));
		"####" CDCD 1 A_SetTics(random(12,16));
		"####" BB 1 A_SetTics(random(12,16));
		Goto SpawnLoop;
	Death:
		PRSN I 5 A_Scream;
		"####" J 6;
		"####" K 5 A_NoBlocking;
		"####" L 5 A_Jump(1,2,3);
		"####" M -1;
		"####" N -1;
		"####" O -1;
		Stop;
	}
}

class Camp_StaticHammeringR : Camp_StaticHammeringL
{
	Default
	{
	//$Title Shootable Prisoner (hammering, right)
	}
	States
	{
	Spawn:
		HAMM A 0 NODELAY A_SetScale(Scale.X * -1, Scale.Y);
		"####" A 0 A_Jump(256,"SpawnLoop");
	}
}

class Camp_StaticShirtlessNH: Actor
{
	Default
	{
	//$Category Concentration Camp (BoA)/Static
	//$Title Decorative Prisoner (shirtless, no hitbox)
	//$Color 3
	Height 48;
	Scale 0.65;
	+CASTSPRITESHADOW
	+NOGRAVITY
	+NOINTERACTION
	}
	States
	{
	Spawn:
		PRSS E -1;
		Stop;
	}
}

class Camp_StaticBaldNH : Camp_StaticShirtlessNH
{
	Default
	{
	//$Title Decorative Prisoner (bald, no hitbox)
	}
	States
	{
	Spawn:
		PRSN E -1;
		Stop;
	}
}

class Camp_PrisonerBald : NaziStandard //it has shooting frames but actually he doesn't - ozy81
{
	double user_basescale;
	Default
	{
	//$Category Concentration Camp (BoA)
	//$Title Wandering Prisoner (bald)
	//$Color 3
	Health 500;
	PainChance 128; // Was 255; but we can't always force to pain state, because then immediate successive hits make the actor freeze on the first pain sprite for some time
	Speed 1;
	Radius 20;
	Height 50;
	Mass 80;
	Monster;
	-COUNTKILL
	+FLOORCLIP
	+FRIENDLY
	+JUSTHIT
	+NEVERTARGET
	+NOSPLASHALERT
	+PUSHABLE
	+SLIDESONWALLS
	+INVULNERABLE
	+ALLOWPAIN
	MaxStepHeight 16;
	MaxDropoffHeight 32;
	SeeSound "urss/sighted";
	PainSound "urss/pain";
	DeathSound "urss/death";
	Species "PlayerFollower";
	Nazi.ZombieVariant "Camp_PrisonerZombie";
	}
	States
	{
	Spawn:
		PRSN E 0 NODELAY {
			bUseSpecial = FALSE; //let's pretend when the actor is active we can't interact with it

			// Normalize scale amounts so actor height and radius aren't so far apart that they look disproportionate.
			user_basescale = FRandom(-0.1, 0.05);
			A_SetScale(Scale.X + user_basescale * FRandom(0.0, 0.65), Scale.Y + user_basescale * FRandom(0.0, 0.65));
		}
	Active: //check if it's active though
	SpawnLoop:
		"####" E 1 {
			// Previously used A_Look2, but A_Look2 does NOT execute specials, so made it impossible to set navigation goals
			// This replicates the essential bits (alert on sound only, and jump to See after a random interval)
			A_LookEx(LOF_NOSIGHTCHECK);
			if (Random[wander](0, 255) < 30) { return resolveState("See"); }
			return ResolveState(null);
		}
		Loop;
	See:
		"####" "#" 0 { user_incombat = TRUE; A_SetSpeed(1);}
		"####" "#" 0 { if (bFRIGHTENED) { SetStateLabel("See.Frightened"); } }
		"####" # 0 A_PlayStepSound();
		"####" AA 1 A_WanderGoal(0, 768);
		"####" AAAAA 1 A_WanderGoal(0, 768);
		"####" AA 1 A_WanderGoal(0, 768);
		"####" AAAAA 1 A_WanderGoal(0, 768);
		"####" BB 1 A_WanderGoal(0, 768);
		"####" BBBBB 1 A_WanderGoal(0, 768);
		"####" BB 1 A_WanderGoal(0, 768);
		"####" BBBBB 1 A_WanderGoal(0, 768);
		"####" # 0 A_PlayStepSound();
		"####" CC 1 A_WanderGoal(0, 768);
		"####" CCCCC 1 A_WanderGoal(0, 768);
		"####" CC 1 A_WanderGoal(0, 768);
		"####" CCCCC 1 A_WanderGoal(0, 768);
		"####" DD 1 A_WanderGoal(0, 768);
		"####" DDDDD 1 A_WanderGoal(0, 768);
		"####" DD 1 A_WanderGoal(0, 768);
		"####" DDDDD 1 A_WanderGoal(0, 768);
		"####" A 0 {
			if (!goal && Random[lookaround](0, 255) < 32) { return resolveState("LookAround"); }
			return ResolveState(null);
		}
		Loop;
	See.Frightened:
		"####" "#" 0 { A_SetSpeed(random(4,6)); }
		"####" # 0 A_PlayStepSound();
		"####" A 1 A_WanderGoal(0, 768);
		"####" AAA 1 A_WanderGoal(0, 768);
		"####" A 1 A_WanderGoal(0, 768);
		"####" AAA 1 A_WanderGoal(0, 768);
		"####" B 1 A_WanderGoal(0, 768);
		"####" BBB 1 A_WanderGoal(0, 768);
		"####" B 1 A_WanderGoal(0, 768);
		"####" BBB 1 A_WanderGoal(0, 768);
		"####" # 0 A_PlayStepSound();
		"####" C 1 A_WanderGoal(0, 768);
		"####" CCC 1 A_WanderGoal(0, 768);
		"####" C 1 A_WanderGoal(0, 768);
		"####" CCC 1 A_WanderGoal(0, 768);
		"####" D 1 A_WanderGoal(0, 768);
		"####" DDD 1 A_WanderGoal(0, 768);
		"####" D 1 A_WanderGoal(0, 768);
		"####" DDD 1 A_WanderGoal(0, 768);
		"####" A 0 {
			if (Random[lookaround](0, 255) < 8) { return ResolveState("LookAround.Frightened"); } // Even goal-seekers can crouch sometimes
			return ResolveState(null);
		}
		Goto See; // Go back to normal see so that they can become un-frightened once the frightener is out of range
	LookAround:
		"####" E 10 A_SetAngle(random(-45,45)+angle);
		"####" E 0 A_SetTics(random(35,105));
		"####" E 0;
		"####" A 0 A_Jump(32, "See");
		"####" A 0 A_Jump(4, "Cough"); //insert from here random sounds and give each call a separate state - ozy81
		Loop;
	LookAround.Frightened:
		"####" A 0 { // When crouching, don't allow jump to pain state, and allow bullets to pass through
			bAllowPain = false;
			bNonShootable = true;
		}
		"####" P 1 A_SetTics(random(12,16));
		"####" QRQRSQP 1 A_SetTics(random(48,96));
		"####" E 1;
		"####" A 0 { // Restore pain jump and bullet hits, and be frightened when done crouching
			bAllowPain = true;
			bNonShootable = false;
			frighttimeout = 35 + Random(0, 7) * 5;
			frightener = target;
		}
		Goto See.Frightened;
	Cough:
		"####" A 0 A_Jump(32, "See"); //try to reduce coughing probabilities in a significantly way - ozy81
		"####" E 0 A_CheckRange(768,"NoCough");
		"####" E 0 A_StartSound("camp/cough", CHAN_ITEM, 0, 0.8);
		"####" E 80;
		"####" A 0 A_Jump(32, "See");
		Loop;
	NoCough:
		"####" E 0 A_StopSound(CHAN_ITEM);
		"####" E 80;
		"####" A 0 A_Jump(32, "See");
		Loop;
	Pain:
		"####" H 1 A_SpawnItemEx("Pain_Overlay", Scale.X+3, 0, Height-8, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_USEBLOODCOLOR);
		"####" H 5 {
				A_Pain();
				frighttimeout = 35 + Random(0, 7) * 5; // FRIGHTENED flag is set by code in Base class when frighttimeout value is greater than zero
				frightener = target;

				if (Random(0, 19) == 0) { SetStateLabel("LookAround.Frightened"); } // 1 in 20 chance that they will crouch immediately when shot
			}
		Goto See.Frightened;
	Death:
		"####" I 5 A_Scream;
		"####" J 6;
		"####" K 5 A_NoBlocking;
		"####" L 5 A_Jump(1,2,3);
		"####" M -1;
		"####" N -1;
		"####" O -1;
		Stop;
	Inactive:
		"####" E 0 {bUseSpecial = TRUE;}
		"####" E -1;
		Stop;
	}
}

class Camp_PrisonerBaldShirtless : Camp_PrisonerBald
{
	Default
	{
	//$Title Wandering Prisoner, Shirtless (bald)
	Health 15;
	Nazi.ZombieVariant "Camp_PrisonerZombie";
	}
	States
	{
	Spawn:
		PRSS E 0 NODELAY { bUseSpecial = FALSE; A_SetScale(Scale.X + frandom(-0.2,0.2),Scale.Y + frandom(-0.2,0.2)); }
	Active:
	SpawnLoop:
		PRSS E 1 {
			A_LookEx(LOF_NOSIGHTCHECK);
			if (Random[wander](0, 255) < 30) { return resolveState("See"); }
			return ResolveState(null);
		}
		Loop;
	}
}