/*
 * Copyright (c) 2017-2021 Ozymandias81, Talon1024
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

class TMBlazko: Actor
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Titlemap Blazko
		+CLIENTSIDEONLY
		+NOGRAVITY
		+NOINTERACTION
	}
	States
	{
	Spawn:
		BLAZ A -1;
		Stop;
	}
}

class TMBlazko2 : TMBlazko
{
	Default
	{
		//$Title Prison Blazko
	}
	States
	{
	Spawn:
		BLAZ B -1;
		Stop;
	}
}

class TMBlazko3 : TMBlazko
{
	Default
	{
		//$Title Portal Blazko
		Scale 0.5;
	}
	States
	{
	Spawn:
		BLAZ C -1;
		Stop;
	}
}

class TMBlazko4 : TMBlazko
{
	Default
	{
		//$Title The End Blazko
	}
	States
	{
	Spawn:
		BLAZ D -1;
		Stop;
	}
}

class TMWZombie : TMBlazko
{
	Default
	{
		//$Title Wehrmacht Zombie Sample for Experiments
		Scale 0.67;
	}
	States
	{
	Spawn:
		ZBIT N -1;
		Stop;
	}
}

class TMSeeteufel : TMBlazko
{
	Default
	{
		//$Title General Seeteufel for C2M4
		Scale 0.67;
	}
	States
	{
	Spawn:
		SEET A -1;
		Stop;
	}
}

class TMGuard: Actor
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Titlemap Soldier
		Scale 0.65;
		+CLIENTSIDEONLY
		+NOINTERACTION
	}
	States
	{
	Spawn:
		MGR2 A -1;
		Stop;
	}
}

class TMGuard2 : TMGuard
{
	Default
	{
		//$Title Wehrmacht Guard, Decorative
	}
	States
	{
	Spawn:
		MGR2 N -1;
		Stop;
	}
}

class TMGuardWithShadow : TMGuard
{
	Default
	{
		//$Title Titlemap Soldier (with shadow)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		MGR2 A -1;
		Stop;
	}
}

class TMMechanicNT : TMGuard
{
	Default
	{
		//$Title Mechanic without Toolbox for Cutscenes (with shadow)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		MNIC O -1;
		Stop;
	}
}

class TMMechanic : TMGuard
{
	Default
	{
		//$Title Mechanic for Cutscenes (with shadow)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		MNIC N -1;
		Stop;
	}
}

class TMScientist : TMGuard //present on c1m2
{
	Default
	{
		//$Title Scientist young Cutscenes (with shadow)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		SCN2 N -1;
		Stop;
	}
}

class TMScientist2 : TMGuard //present on c1m2
{
	Default
	{
		//$Title Scientist old Cutscenes (with shadow)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		SCNT N -1;
		Stop;
	}
}

class TMDog : TMGuardWithShadow
{
	Default
	{
		//$Title Titlemap Doge (with shadow)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		DOG3 L -1;
		Stop;
	}
}

class TMLightBeam : SwitchableDecoration
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Titlemap Light Beam
		RenderRadius 512;
		Height 56;
		Alpha 0.4;
		RenderStyle "Add";
		+BRIGHT
		+DONTSPLASH
		+FLOORCLIP
		+NOGRAVITY
	}
	States
	{
	Spawn:
		MDLA A 1 NODELAY;
	Active:
		MDLA A -1;
		Stop;
	Inactive:
		TNT1 A -1;
		Stop;
	}
}
//shadows have been commented out from some actors because they drastically ruin performance on CUTSCEN1, I leave them for lulz - ozy81
class TMFanfare1 : SwitchableDecoration
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Fanfare Banner Carrier (Activate to make him walk)
		Height 56;
		Radius 8;
		Scale 0.65;
		+NOBLOCKMAP
		-CASTSPRITESHADOW
	}
	States
	{
	Inactive:
	Spawn:
		BANN N -1;
		Stop;
	Active:
		"####" A 1;
		"####" AAA 1;
		"####" A 1;
		"####" AAA 1;
		"####" B 1;
		"####" BBB 1;
		"####" B 1;
		"####" BBB 1;
		"####" C 1;
		"####" CCC 1;
		"####" C 1;
		"####" CCC 1;
		"####" D 1;
		"####" DDD 1;
		"####" D 1;
		"####" DDD 1;
		Loop;
	}
}

class TMFanfare2 : TMGuard
{
	Default
	{
		//$Title Fanfare Trumpet Soldier (Right)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		TRUM A -1;
		Stop;
	}
}

class TMFanfare3 : TMFanfare2
{
	Default
	{
		//$Title Fanfare Trumpet Soldier (Left)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		TRUM B -1;
		Stop;
	}
}

class TMFanfare4 : TMFanfare1
{
	Default
	{
		//$Title Fanfare SSMP40 Soldier (Activate to make him walk)
		-CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		SSMG N -1;
		Stop;
	}
}

class TMFanfare5 : TMFanfare1
{
	Default
	{
		//$Title Fanfare SS Officer (Activate to make him walk)
		-CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		SSOF N -1;
		Stop;
	}
}

class TMHitler : TMFanfare1
{
	Default
	{
		//$Title Adolf Hitler (Speech)
		+CASTSPRITESHADOW
	}
	States
	{
	Inactive:
		ADFS EDCBA 20;
		ADFS A 300;
	Spawn:
		ADFS E -1;
		Stop;
	Active:
		"####" D 1 A_SetTics(random(40,60));
		"####" CBDDDEBCBDBECCBDD 1 A_SetTics(random(32,64));
		Goto Inactive;
	}
}

class TMGauleiter : TMGuard
{
	Default
	{
		//$Title Gauleiter
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		GAUL A -1;
		Stop;
	}
}

class TMGauleiterNS : TMGauleiter
{
	Default
	{
		//$Title Gauleiter (No Shadow)
		-CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		GAUL A -1;
		Stop;
	}
}

class TMMiller : TMGuard
{
	Default
	{
		//$Title General Miller for HQs
		Scale 0.67;
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		GENR O -1;
		Stop;
	}
}

class TMMarineHQ1 : TMCivBase
{
	Default
	{
		//$Title Marine with MP40, Ocher, Cutscenes
		Translation 1;
	}
	States
	{
	Spawn:
		ARMH A -1;
		Stop;
	}
}

class TMMarineHQ2 : TMMarineHQ1
{
	Default
	{
		//$Title Marine with MP40, Green, Cutscenes
	}
	States
	{
	Spawn:
		MARH A -1;
		Stop;
	}
}

class TMMarineHQ3 : TMMarineHQ1
{
	Default
	{
		//$Title Marine with MP40, Brown, Cutscenes
	}
	States
	{
	Spawn:
		PARS A -1;
		Stop;
	}
}

class TMMarineHQ1NW : TMCivBase
{
	Default
	{
		//$Title Marine weaponless, Ocher, Cutscenes
		Translation 1;
	}
	States
	{
	Spawn:
		ARH2 A -1;
		Stop;
	}
}

class TMMarineHQ2NW : TMMarineHQ1
{
	Default
	{
		//$Title Marine weaponless, Green, Cutscenes
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		MAH2 A -1;
		Stop;
	}
}

class TMMarineHQ3NW : TMMarineHQ1
{
	Default
	{
		//$Title Marine weaponless, Brown, Cutscenes
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		PARP A -1;
		Stop;
	}
}

class TMMarineHQ4 : TMMarineHQ1
{
	Default
	{
		//$Title Random Marine, Weaponless, Cutscenes
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		RNDM A 0;
	Randomize:
		RNDM A 0 A_Jump(256,"Pose1","Pose2","Pose3");
	Pose1:
		PARP A -1;
		Stop;
	Pose2:
		ARH2 A -1;
		Stop;
	Pose3:
		MAH2 A -1;
		Stop;
	}
}

class TMMarineHQ5 : TMMarineHQ1
{
	Default
	{
		//$Title Random Marine, Armed, Cutscenes
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		RNDM B 0;
	Randomize:
		RNDM B 0 A_Jump(256,"Pose1","Pose2","Pose3");
	Pose1:
		PAR2 A -1;
		Stop;
	Pose2:
		ARMH A -1;
		Stop;
	Pose3:
		MARH A -1;
		Stop;
	}
}

class TMRDragunovGuard : TMMarineHQ1
{
	Default
	{
		//$Title NKVD Russian Dragunov Guard, Cutscenes
	}
	States
	{
	Spawn:
		NKVR N -1;
		Stop;
	}
}

class TMAscher : TMMarineHQ1
{
	Default
	{
		//$Title Sgt. Ascher, Cutscenes
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		PARS A -1;
		Stop;
	}
}

class TMClerk : TMMarineHQ1
{
	Default
	{
		//$Title Lt. Laz Rojas, Cutscenes
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		BLCK B -1;
		Stop;
	}
}

class TMStatistBarkeeper : TMCivBase
{
	Default
	{
		//$Title Juliette Bertrand, Cutscenes
	}
	States
	{
	Spawn:
		BDKP A 0;
	SpawnLoop:
		BDKP A 80;
		"####" B 40;
		"####" CB 40;
		"####" D 80;
		"####" DACB 40;
		"####" E 40;
		"####" F 40;
		Loop;
	}
}

class TMStatistBarkeeperMale : TMStatistBarkeeper
{
	Default
	{
		//$Title Haggis McMutton, Cutscenes
	}
	States
	{
	Spawn:
		BDK2 A 0;
	SpawnLoop:
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

class TMStatistMedic : TMStatistBarkeeper
{
	Default
	{
		//$Title Ty Halderman, Cutscenes
		Scale 0.67;
	}
	States
	{
	Spawn:
		MEDC A 0;
	SpawnLoop:
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

class TMStatistAFA : TMStatistMedic
{
	Default
	{
		//$Title AFADoomer, Cutscenes
	}
	States
	{
	Spawn:
		AFAD A 0;
	SpawnLoop:
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

class TMStatistDimitri : TMStatistMedic
{
	Default
	{
		//$Title Dimitri, Cutscenes
	}
	States
	{
	Spawn:
		RUST A 0;
	SpawnLoop:
		RUST A 80;
		"####" B 40;
		"####" CB 40;
		"####" B 80;
		Loop;
	}
}

class TMStatistYevgeny : TMStatistMedic
{
	Default
	{
		//$Title Yevgeny, Cutscenes
	}
	States
	{
	Spawn:
		YEVG A 0;
	SpawnLoop:
		YEVG A 80;
		"####" B 40;
		"####" CB 40;
		"####" B 80;
		Loop;
	}
}

class TMHitler2 : TMGuard
{
	Default
	{
		//$Title Adolf Hitler (Downfall)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		HISC A -1;
		Stop;
	}
}

class TMTankPanzer3 : TMFanfare1
{
	Default
	{
		//$Title Fanfare Tank Panzer III
		Scale 1.0;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class TMSSTank1 : TMBlazko
{
	Default
	{
		//$Title Titlemap Panther Panzer IV
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class TMRUFlag : TMBlazko
{
	Default
	{
		//$Title Russian Flag
	}
	States
	{
	Spawn:
		RUSF AB 1 A_SetTics(random(20,80));
		"####" BA 1 A_SetTics(random(20,80));
		Loop;
	}
}

class TMMarine1: Actor
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Random Happy Marine 1 (brown hair)
		DistanceCheck "boa_scenelod";
		Scale 0.65;
		Translation 1;
		+NOBLOCKMAP
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		FIN1 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIN1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose17","Pose17");
	Pose1:
		"####" AABBDD 1 A_SetTics(random(10,20));
		"####" CC 1 A_SetTics(random(80,160));
		Loop;
	Pose2:
		"####" AABBDD 1 A_SetTics(random(10,20));
		"####" EEDDDDBB 1 A_SetTics(random(40,60));
		Loop;
	Pose3:
		"####" FFGG 1 A_SetTics(random(5,10));
		"####" HHIHIHG 1 A_SetTics(random(20,50));
		Loop;
	Pose4:
		"####" HHIHIHIHH 1 A_SetTics(random(20,50));
		Loop;
	Pose5:
		"####" FFFF 1 A_SetTics(random(5,10));
		"####" JJKJKJKJJ 1 A_SetTics(random(10,20));
		Loop;
	Pose6:
		"####" L -1;
		Stop;
	Pose7:
		"####" LLMM 1 A_SetTics(random(10,20));
		"####" NN 1 A_SetTics(random(80,160));
		Loop;
	Pose8:
		"####" N -1;
		Stop;
	Pose9:
		"####" NN 1 A_SetTics(random(10,20));
		"####" OOPPOPOPO 1 A_SetTics(random(40,60));
		Loop;
	Pose10:
		"####" QQRR 1 A_SetTics(random(10,20));
		"####" SS 1 A_SetTics(random(80,160));
		Loop;
	Pose11:
		"####" S -1;
		Stop;
	Pose12:
		"####" SS 1 A_SetTics(random(10,20));
		"####" TTUUTUTUT 1 A_SetTics(random(40,60));
		Loop;
	Pose14:
		"####" V -1;
		Stop;
	Pose14:
		"####" VVWW 1 A_SetTics(random(10,20));
		"####" XX 1 A_SetTics(random(80,160));
		Loop;
	Pose15:
		"####" X -1;
		Stop;
	Pose16:
		"####" XX 1 A_SetTics(random(10,20));
		"####" YYZZYZYZY 1 A_SetTics(random(40,60));
		Loop;
	Pose17:
		FIN1 LLFG 1 A_SetTics(random(5,10));
		FIJ1 AABCDAA 1 A_SetTics(random(5,10));
		Loop;
	}
}

class TMMarine1B : TMMarine1
{
	Default
	{
		//$Title Random Happy Marine 1 (black hair)
	}
	States
	{
	Spawn:
		FIB1 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIB1 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	Pose1:
		"####" OOPPOPOPO 1 A_SetTics(random(40,60));
		Loop;
	Pose2:
		"####" QQRR 1 A_SetTics(random(10,20));
		"####" SS 1 A_SetTics(random(80,160));
		Loop;
	Pose3:
		"####" S -1;
		Stop;
	Pose4:
		"####" SS 1 A_SetTics(random(10,20));
		"####" TTUUTUTUT 1 A_SetTics(random(40,60));
		Loop;
	Pose5:
		"####" V -1;
		Stop;
	Pose6:
		"####" VVWW 1 A_SetTics(random(10,20));
		"####" XX 1 A_SetTics(random(80,160));
		Loop;
	Pose7:
		"####" X -1;
		Stop;
	Pose8:
		"####" XX 1 A_SetTics(random(10,20));
		"####" YYZZYZYZY 1 A_SetTics(random(40,60));
		Loop;
	}
}

class TMMarine1G : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 1 (gray hair)
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		FIG1 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIG1 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine1R : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 1 (red hair)
	}
	States
	{
	Spawn:
		FSR1 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FSR1 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine1Y : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 1 (blonde hair)
	}
	States
	{
	Spawn:
		FIY1 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIY1 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine2 : TMMarine1
{
	Default
	{
		//$Title Random Happy Marine 2 (brown hair)
	}
	States
	{
	Spawn:
		FIN2 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIN2 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose17","Pose17");
		Stop;
	Pose17:
		FIN2 LLFG 1 A_SetTics(random(5,10));
		FIJ2 AABCDAA 1 A_SetTics(random(5,10));
		Loop;
	}
}

class TMMarine2B : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 2 (black hair)
	}
	States
	{
	Spawn:
		FIB2 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIB2 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine2G : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 2 (gray hair)
	}
	States
	{
	Spawn:
		FIG2 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIG2 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine2R : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 2 (red hair)
	}
	States
	{
	Spawn:
		FSR2 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FSR2 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine2Y : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 2 (blonde hair)
	}
	States
	{
	Spawn:
		FIY2 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIY2 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine3 : TMMarine1
{
	Default
	{
		//$Title Random Happy Marine 3 (brown hair)
	}
	States
	{
	Spawn:
		FIN3 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIN3 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose17","Pose17");
		Stop;
	Pose17:
		FIN3 LLFG 1 A_SetTics(random(5,10));
		FIJ3 AABCDAA 1 A_SetTics(random(5,10));
		Loop;
	}
}

class TMMarine3B : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 3 (black hair)
	}
	States
	{
	Spawn:
		FIB3 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIB3 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine3G : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 3 (gray hair)
	}
	States
	{
	Spawn:
		FIG3 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIG3 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine3R : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 3 (red hair)
	}
	States
	{
	Spawn:
		FSR3 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FSR3 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine3Y : TMMarine1B
{
	Default
	{
		//$Title Random Happy Marine 3 (blonde hair)
	}
	States
	{
	Spawn:
		FIY3 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIY3 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine4: Actor
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Random Happy Soviet 1 (brown hair)
		DistanceCheck "boa_scenelod";
		Scale 0.65;
		+NOBLOCKMAP
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		FIN4 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIN4 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose17","Pose17");
		Stop;
	Pose1:
		"####" AABBDD 1 A_SetTics(random(10,20));
		"####" CC 1 A_SetTics(random(80,160));
		Loop;
	Pose2:
		"####" AABBDD 1 A_SetTics(random(10,20));
		"####" EEDDDDBB 1 A_SetTics(random(40,60));
		Loop;
	Pose3:
		"####" FFGG 1 A_SetTics(random(5,10));
		"####" HHIHIHG 1 A_SetTics(random(20,50));
		Loop;
	Pose4:
		"####" HHIHIHIHH 1 A_SetTics(random(20,50));
		Loop;
	Pose5:
		"####" FFFF 1 A_SetTics(random(5,10));
		"####" JJKJKJKJJ 1 A_SetTics(random(10,20));
		Loop;
	Pose6:
		"####" L -1;
		Stop;
	Pose7:
		"####" LLMM 1 A_SetTics(random(10,20));
		"####" NN 1 A_SetTics(random(80,160));
		Loop;
	Pose8:
		"####" N -1;
		Stop;
	Pose9:
		"####" NN 1 A_SetTics(random(10,20));
		"####" OOPPOPOPO 1 A_SetTics(random(40,60));
		Loop;
	Pose10:
		"####" QQRR 1 A_SetTics(random(10,20));
		"####" SS 1 A_SetTics(random(80,160));
		Loop;
	Pose11:
		"####" S -1;
		Stop;
	Pose12:
		"####" SS 1 A_SetTics(random(10,20));
		"####" TTUUTUTUT 1 A_SetTics(random(40,60));
		Loop;
	Pose14:
		"####" V -1;
		Stop;
	Pose14:
		"####" VVWW 1 A_SetTics(random(10,20));
		"####" XX 1 A_SetTics(random(80,160));
		Loop;
	Pose15:
		"####" X -1;
		Stop;
	Pose16:
		"####" XX 1 A_SetTics(random(10,20));
		"####" YYZZYZYZY 1 A_SetTics(random(40,60));
		Loop;
	Pose17:
		FIN4 LLFG 1 A_SetTics(random(5,10));
		FIJ4 AABCDAA 1 A_SetTics(random(5,10));
		Loop;
	}
}

class TMMarine4B : TMMarine4
{
	Default
	{
		//$Title Random Happy Soviet 1 (black hair)
	}
	States
	{
	Spawn:
		FIB4 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIB4 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
	Pose1:
		"####" OOPPOPOPO 1 A_SetTics(random(40,60));
		Loop;
	Pose2:
		"####" QQRR 1 A_SetTics(random(10,20));
		"####" SS 1 A_SetTics(random(80,160));
		Loop;
	Pose3:
		"####" S -1;
		Stop;
	Pose4:
		"####" SS 1 A_SetTics(random(10,20));
		"####" TTUUTUTUT 1 A_SetTics(random(40,60));
		Loop;
	Pose5:
		"####" V -1;
		Stop;
	Pose6:
		"####" VVWW 1 A_SetTics(random(10,20));
		"####" XX 1 A_SetTics(random(80,160));
		Loop;
	Pose7:
		"####" X -1;
		Stop;
	Pose8:
		"####" XX 1 A_SetTics(random(10,20));
		"####" YYZZYZYZY 1 A_SetTics(random(40,60));
		Loop;
	}
}

class TMMarine4G : TMMarine4B
{
	Default
	{
		//$Title Random Happy Soviet 1 (gray hair)
	}
	States
	{
	Spawn:
		FIG4 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIG4 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine4R : TMMarine4B
{
	Default
	{
		//$Title Random Happy Soviet 1 (red hair)
	}
	States
	{
	Spawn:
		FSR4 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FSR4 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMMarine4Y : TMMarine4B
{
	Default
	{
		//$Title Random Happy Soviet 1 (blonde hair)
	}
	States
	{
	Spawn:
		FIY4 O 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIY4 O 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	}
}

class TMWound1: Actor
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Random Wounded Marine (brown hair, random country)
		DistanceCheck "boa_scenelod";
		Scale 0.65;
		+NOBLOCKMAP
		+CASTSPRITESHADOW
	}
	States
	{
	Spawn:
		FIN5 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIN5 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4");
		Stop;
	Pose1:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIN5 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose2:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIN6 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose3:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIN7 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose4:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIN8 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	SetPose:
		"####" "#" -1;
		Stop;
	}
}

class TMWound2 : TMWound1
{
	Default
	{
		//$Title Random Wounded Marine (black hair, random country)
	}
	States
	{
	Spawn:
		FIB5 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIB5 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4");
		Stop;
	Pose1:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIB5 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose2:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIB6 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose3:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIB7 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose4:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIB8 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	SetPose:
		"####" "#" -1;
		Stop;
	}
}

class TMWound3 : TMWound1
{
	Default
	{
		//$Title Random Wounded Marine (gray hair, random country)
	}
	States
	{
	Spawn:
		FIG5 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIG5 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4");
		Stop;
	Pose1:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIG5 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose2:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIG6 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose3:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIG7 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose4:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIG8 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	SetPose:
		"####" "#" -1;
		Stop;
	}
}

class TMWound4 : TMWound1
{
	Default
	{
		//$Title Random Wounded Marine (red hair, random country)
	}
	States
	{
	Spawn:
		FSR5 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FSR5 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4");
		Stop;
	Pose1:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FSR5 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose2:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FSR6 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose3:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FSR7 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose4:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FSR8 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	SetPose:
		"####" "#" -1;
		Stop;
	}
}

class TMWound5 : TMWound1
{
	Default
	{
		//$Title Random Wounded Marine (blonde hair, random country)
	}
	States
	{
	Spawn:
		FIY5 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		FIY5 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4");
		Stop;
	Pose1:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIY5 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose2:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIY6 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose3:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIY7 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	Pose4:
		"####" A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10);
		FIY8 ABCDEFGHIJ 0 A_Jump(256,"SetPose");
	SetPose:
		"####" "#" -1;
		Stop;
	}
}

class SSTank3Part1 : ModelBase
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Tiger I Panzer, Body part
		DistanceCheck "boa_scenelod";
		Radius 64;
		Height 64;
	}
}

class SSTank3Part2 : ModelBase
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Tiger I Panzer, Turret part
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 24;
	}
}

class TMModelIncaTrain : ModelBase
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Train for Cutscenes (no lod)
		RenderRadius 256;
		Radius 4;
		Height 4;
	}
}

class TMModelRailBoxcar : TMModelIncaTrain
{
	Default
	{
		//$Title Train Boxcar for Cutscenes (no lod)
	}
}

class TMModelRailBoxcar2 : TMModelIncaTrain
{
	Default
	{
		//$Title Train Boxcar KZ for Cutscenes (no lod)
	}
}

class TMModelRailTanker : TMModelIncaTrain
{
	Default
	{
		//$Title Train Tanker for Cutscenes (no lod)
	}
}

class TMTrainWheels : ModelBase
{
	Default
	{
		//$Category Cutscenes (BoA)
		//$Title Train Wheels for Cutscenes (no lod)
		Radius 4;
		Height 4;
	}
}