/*
 * Copyright (c) 2019-2021 Ozymandias81
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

class TMCivBase: Actor
{
	Default
	{
		//$Category Cutscenes (BoA)
		DistanceCheck "boa_scenelod";
		Scale 0.65;
		+NOBLOCKMAP
		+CASTSPRITESHADOW
	}
}

class TMCivFemale1 : TMCivBase
{
	Default
	{
		//$Title Random Female Civilian (brown hair)
		Scale 0.63;
	}
	States
	{
	Spawn:
		FEM1 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.58, 0.63) );
	Randomize:
		FEM1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9");
		Stop;
	Pose1:
		"####" AABBCC 1 A_SetTics(random(10,20));
		"####" DD 1 A_SetTics(random(80,160));
		Loop;
	Pose2:
		"####" DDEEFF 1 A_SetTics(random(10,20));
		"####" EEDD 1 A_SetTics(random(40,60));
		Loop;
	Pose3:
		"####" G -1;
		Stop;
	Pose4:
		"####" H -1;
		Stop;
	Pose5:
		"####" I -1;
		Stop;
	Pose6:
		"####" FEFEFFE 1 A_SetTics(random(80,160));
		Loop;
	Pose7:
		"####" JKJKJJK 1 A_SetTics(random(80,160));
		Loop;
	Pose8:
		"####" AADD 1 A_SetTics(random(10,20));
		"####" JKJKJKDA 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		"####" AADL 1 A_SetTics(random(8,14));
		"####" MNO 1 A_SetTics(random(5,10));
		"####" LLD 1 A_SetTics(random(8,14));
		Loop;
	}
}

class TMCivFemale2 : TMCivFemale1
{
	Default
	{
		//$Title Random Female Civilian (red hair)
	}
	States
	{
	Spawn:
		FEM2 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.58, 0.63) );
	Randomize:
		FEM2 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9");
		Stop;
	}
}

class TMCivFemale3 : TMCivFemale1
{
	Default
	{
		//$Title Random Female Civilian (black hair)
	}
	States
	{
	Spawn:
		FEM3 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.58, 0.63) );
	Randomize:
		FEM3 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9");
		Stop;
	}
}

class TMCivFemale4 : TMCivFemale1
{
	Default
	{
		//$Title Random Female Civilian (blonde hair)
	}
	States
	{
	Spawn:
		FEM4 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.58, 0.63) );
	Randomize:
		FEM4 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9");
		Stop;
	}
}

class TMCivMale1 : TMCivBase
{
	Default
	{
		//$Title Random Male Civilian (brown hair)
	}
	States
	{
	Spawn:
		MAL1 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MAL1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13");
		Stop;
	Pose1:
		"####" AABBCC 1 A_SetTics(random(10,20));
		"####" DD 1 A_SetTics(random(80,160));
		Loop;
	Pose2:
		"####" AAEEFF 1 A_SetTics(random(10,20));
		"####" GGFF 1 A_SetTics(random(40,60));
		Loop;
	Pose3:
		"####" A -1;
		Loop;
	Pose4:
		"####" FGFGFFG 1 A_SetTics(random(80,160));
		Loop;
	Pose5:
		"####" HIHIHHI 1 A_SetTics(random(80,160));
		Loop;
	Pose6:
		"####" FEFEFFE 1 A_SetTics(random(80,160));
		Loop;
	Pose7:
		"####" AABJ 1 A_SetTics(random(8,14));
		"####" KLM 1 A_SetTics(random(5,10));
		"####" JJA 1 A_SetTics(random(8,14));
		Loop;
	Pose8:
		"####" NNOOPP 1 A_SetTics(random(10,20));
		"####" QQ 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		"####" NNRRSS 1 A_SetTics(random(10,20));
		"####" TTSS 1 A_SetTics(random(40,60));
		Loop;
	Pose10:
		"####" N -1;
		Stop;
	Pose11:
		"####" STSTSST 1 A_SetTics(random(80,160));
		Loop;
	Pose12:
		"####" UVUVUUV 1 A_SetTics(random(80,160));
		Loop;
	Pose13:
		"####" NNWWXX 1 A_SetTics(random(10,20));
		"####" YY 1 A_SetTics(random(80,160));
		Loop;
	}
}

class TMCivMale2 : TMCivMale1
{
	Default
	{
		//$Title Random Male Civilian (black hair)
	}
	States
	{
	Spawn:
		MAL2 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MAL2 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13");
		Stop;
	}
}

class TMCivMale3 : TMCivMale1
{
	Default
	{
		//$Title Random Male Civilian (red hair)
	}
	States
	{
	Spawn:
		MAL3 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MAL3 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13");
		Stop;
	}
}

class TMCivMale4 : TMCivMale1
{
	Default
	{
		//$Title Random Male Civilian (blonde hair)
	}
	States
	{
	Spawn:
		MAL4 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MAL4 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13");
		Stop;
	}
}

class TMCivMale5 : TMCivMale1
{
	Default
	{
		//$Title Random Male Civilian (bald)
	}
	States
	{
	Spawn:
		MAL5 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MAL5 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13");
		Stop;
	}
}

class TMCivMale6 : TMCivBase
{
	Default
	{
		//$Title Random Male Civilian with Hat (brown hair)
	}
	States
	{
	Spawn:
		MHA1 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MHA1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose1:
		"####" NNAABB 1 A_SetTics(random(10,20));
		"####" CCB 1 A_SetTics(random(80,160));
		Loop;
	Pose2:
		"####" NNDDEE 1 A_SetTics(random(10,20));
		"####" FFEE 1 A_SetTics(random(40,60));
		Loop;
	Pose3:
		"####" NNAAGG 1 A_SetTics(random(10,20));
		"####" HHG 1 A_SetTics(random(80,160));
		"####" I 1 A_SetTics(random(10,20));
		Loop;
	Pose4:
		"####" N -1;
		Stop;
	Pose5:
		"####" NNII 1 A_SetTics(random(10,20));
		"####" OO 1 A_SetTics(random(80,160));
		"####" I 1 A_SetTics(random(10,20));
		Loop;
	Pose6:
		"####" NNII 1 A_SetTics(random(10,20));
		"####" OO 1 A_SetTics(random(80,160));
		"####" PQRRQP 1 A_SetTics(random(40,60));
		"####" OI 1 A_SetTics(random(10,20));
		Loop;
	Pose7:
		"####" NTAA 1 A_SetTics(random(10,20));
		"####" UUOO 1 A_SetTics(random(80,160));
		"####" I 1 A_SetTics(random(10,20));
		Loop;
	Pose8:
		"####" NTAA 1 A_SetTics(random(10,20));
		"####" UUOO 1 A_SetTics(random(80,160));
		"####" PQRRQP 1 A_SetTics(random(40,60));
		"####" OI 1 A_SetTics(random(10,20));
		Loop;
	Pose9:
		"####" PQRRQP 1 A_SetTics(random(40,60));
		Loop;
	Pose10:
		"####" S -1;
		Stop;
	Pose11:
		"####" NABJ 1 A_SetTics(random(8,14));
		"####" KLM 1 A_SetTics(random(5,10));
		"####" JJA 1 A_SetTics(random(8,14));
		Loop;
	}
}

class TMCivMale7 : TMCivMale6
{
	Default
	{
		//$Title Random Male Civilian with Hat (black hair)
	}
	States
	{
	Spawn:
		MHA2 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MHA2 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	}
}

class TMCivMale8 : TMCivMale6
{
	Default
	{
		//$Title Random Male Civilian with Hat (red hair)
	}
	States
	{
	Spawn:
		MHA3 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MHA3 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	}
}

class TMCivMale9 : TMCivMale6
{
	Default
	{
		//$Title Random Male Civilian with Hat (blonde hair)
	}
	States
	{
	Spawn:
		MHA4 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MHA4 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	}
}

class TMCivMale10 : TMCivMale6
{
	Default
	{
		//$Title Random Male Civilian with Hat (bald)
		//$Sprite MHA5S0
	}
	States
	{
	Spawn:
		MHA1 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		MHA1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose6:
		"####" NNII 1 A_SetTics(random(10,20));
		"####" OO 1 A_SetTics(random(80,160));
		MHA5 PQRRQP 1 A_SetTics(random(40,60));
		MHA1 OI 1 A_SetTics(random(10,20));
		Loop;
	Pose8:
		"####" NTAA 1 A_SetTics(random(10,20));
		"####" UUOO 1 A_SetTics(random(80,160));
		MHA5 PQRRQP 1 A_SetTics(random(40,60));
		MHA1 OI 1 A_SetTics(random(10,20));
		Loop;
	Pose9:
		MHA5 PQRRQP 1 A_SetTics(random(40,60));
		Loop;
	Pose10:
		MHA5 S -1;
		Stop;
	Pose11:
		"####" NABJ 1 A_SetTics(random(8,14));
		"####" KL 1 A_SetTics(random(5,7));
		MHA5 M 1 A_SetTics(random(2,3));
		MHA1 JJA 1 A_SetTics(random(8,14));
		Loop;
	}
}

class TMCivGirl1 : TMCivBase
{
	Default
	{
		//$Title Random Little Girl (black hair)
		Scale 0.63;
	}
	States
	{
	Spawn:
		CFL1 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CFL1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose1:
		"####" A -1;
		Stop;
	Pose2:
		"####" AABBCC 1 A_SetTics(random(10,20));
		"####" DD 1 A_SetTics(random(80,160));
		Loop;
	Pose3:
		"####" CDDC 1 A_SetTics(random(40,60));
		Loop;
	Pose4: //this Pose suffer of random Scale.X values - ozy81
		"####" EEFF 1 A_SetTics(random(10,20));
		"####" GGF 1 A_SetTics(random(80,160));
		Loop;
	Pose5:
		"####" G -1;
		Stop;
	Pose6:
		"####" AAHHI 1 A_SetTics(random(10,20));
		"####" JJIJIIH 1 A_SetTics(random(40,60));
		Loop;
	Pose7:
		"####" AAKL 1 A_SetTics(random(8,14));
		"####" MNOP 1 A_SetTics(random(7,12));
		"####" KK 1 A_SetTics(random(8,14));
		Loop;
	Pose8:
		CFFL AABCBBCCB 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CFFL CCDEDDEED 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CFFL FF 1 A_SetTics(random(10,20));
		CFFL CCDEDDEED 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CFFL F -1;
		Stop;
	}
}

class TMCivGirl2 : TMCivGirl1
{
	Default
	{
		//$Title Random Little Girl (blonde hair)
	}
	States
	{
	Spawn:
		CFL2 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CFL2 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose8:
		CFFL GGHIHHIIH 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CFFL IIJKJJKKJ 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CFFL LL 1 A_SetTics(random(10,20));
		CFFL IIJKJJKKJ 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CFFL L -1;
		Stop;
	}
}

class TMCivGirl3 : TMCivGirl1
{
	Default
	{
		//$Title Random Little Girl (red hair)
	}
	States
	{
	Spawn:
		CFL3 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CFL3 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose8:
		CFFL MMNONNOON 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CFFL OOPQPPQQP 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CFFL RR 1 A_SetTics(random(10,20));
		CFFL OOPQPPQQP 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CFFL R -1;
		Stop;
	}
}

class TMCivGirl4 : TMCivGirl1
{
	Default
	{
		//$Title Random Little Girl (brown hair)
	}
	States
	{
	Spawn:
		CFL4 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CFL4 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose8:
		CFFL SSTUTTUUT 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CFFL UUVWVVWWV 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CFFL XX 1 A_SetTics(random(10,20));
		CFFL UUVWVVWWV 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CFFL X -1;
		Stop;
	}
}

class TMCivBoy1 : TMCivGirl1
{
	Default
	{
		//$Title Random Little Boy (black hair)
	}
	States
	{
	Spawn:
		CHL1 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CHL1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose8:
		CHFL AABCBBCCB 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CHFL CCDEDDEED 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CHFL FF 1 A_SetTics(random(10,20));
		CHFL CCDEDDEED 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CHFL F -1;
		Stop;
	}
}

class TMCivBoy2 : TMCivGirl1
{
	Default
	{
		//$Title Random Little Boy (blonde hair)
	}
	States
	{
	Spawn:
		CHL2 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CHL2 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose8:
		CHFL GGHIHHIIH 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CHFL IIJKJJKKJ 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CHFL LL 1 A_SetTics(random(10,20));
		CHFL IIJKJJKKJ 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CHFL L -1;
		Stop;
	}
}

class TMCivBoy3 : TMCivGirl1
{
	Default
	{
		//$Title Random Little Boy (red hair)
	}
	States
	{
	Spawn:
		CHL3 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CHL3 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose8:
		CHFL MMNONNOON 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CHFL OOPQPPQQP 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CHFL RR 1 A_SetTics(random(10,20));
		CHFL OOPQPPQQP 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CHFL R -1;
		Stop;
	}
}

class TMCivBoy4 : TMCivGirl1
{
	Default
	{
		//$Title Random Little Boy (brown hair)
	}
	States
	{
	Spawn:
		CHL4 A 0 NODELAY A_SetScale(Scale.X, frandom(0.58, 0.63) );
	Randomize:
		CHL4 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11");
		Stop;
	Pose8:
		CHFL SSTUTTUUT 1 A_SetTics(random(80,160));
		Loop;
	Pose9:
		CHFL UUVWVVWWV 1 A_SetTics(random(60,120));
		Loop;
	Pose10:
		CHFL XX 1 A_SetTics(random(10,20));
		CHFL UUVWVVWWV 1 A_SetTics(random(40,60));
		Loop;
	Pose11:
		CHFL X -1;
		Stop;
	}
}

class TMCivExtra1 : TMCivBase
{
	Default
	{
		//$Title Random Sleeveless Civilian (thin)
	}
	States
	{
	Spawn:
		XTR1 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		XTR1 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16");
		Stop;
	Pose1:
		"####" A -1;
		Stop;
	Pose2:
		"####" B -1;
		Stop;
	Pose3:
		"####" C -1;
		Stop;
	Pose4:
		"####" D -1;
		Stop;
	Pose5:
		"####" E -1;
		Stop;
	Pose6:
		"####" F -1;
		Stop;
	Pose7:
		"####" G -1;
		Stop;
	Pose8:
		"####" H -1;
		Stop;
	Pose9:
		"####" I -1;
		Stop;
	Pose10:
		"####" J -1;
		Stop;
	Pose11:
		"####" K -1;
		Stop;
	Pose12:
		"####" L -1;
		Stop;
	Pose13:
		"####" M -1;
		Stop;
	Pose14:
		"####" N -1;
		Stop;
	Pose15:
		"####" O -1;
		Stop;
	Pose16:
		"####" P -1;
		Stop;
	}
}

class TMCivExtra2 : TMCivExtra1
{
	Default
	{
		//$Title Random Sleeveless Civilian (fat)
	}
	States
	{
	Spawn:
		XTR2 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		XTR2 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16");
		Stop;
	}
}

class TMCivExtra3 : TMCivExtra1
{
	Default
	{
		//$Title Random Sleeveless Civilian (crossed arms)
	}
	States
	{
	Spawn:
		XTR3 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		XTR3 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose18","Pose19","Pose20");
		Stop;
	Pose17:
		"####" Q -1;
		Stop;
	Pose18:
		"####" R -1;
		Stop;
	Pose19:
		"####" S -1;
		Stop;
	Pose20:
		"####" T -1;
		Stop;
	}
}

class TMCivExtra4 : TMCivExtra1
{
	Default
	{
		//$Title Random Sleeveless Civilian (with wrench)
	}
	States
	{
	Spawn:
		XTR4 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		XTR4 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose18","Pose19","Pose20");
		Stop;
	Pose17:
		"####" Q -1;
		Stop;
	Pose18:
		"####" R -1;
		Stop;
	Pose19:
		"####" S -1;
		Stop;
	Pose20:
		"####" T -1;
		Stop;
	}
}

class TMCivExtra5 : TMCivExtra1
{
	Default
	{
		//$Title Random Sleeveless Civilian (toolbox & wrench)
	}
	States
	{
	Spawn:
		XTR5 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		XTR5 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose18","Pose19","Pose20");
		Stop;
	Pose17:
		"####" Q -1;
		Stop;
	Pose18:
		"####" R -1;
		Stop;
	Pose19:
		"####" S -1;
		Stop;
	Pose20:
		"####" T -1;
		Stop;
	}
}

class TMCivExtra6 : TMCivExtra1
{
	Default
	{
		//$Title Random Sleeveless Civilian (animated, bald)
	}
	States
	{
	Spawn:
		XTR6 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		XTR6 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	Pose1:
		"####" A -1;
		Stop;
	Pose2:
		"####" A 80;
		"####" B 40;
		"####" CB 40;
		"####" D 80;
		"####" A 80;
		"####" BE 40;
		"####" CA 80;
		Loop;
	Pose3:
		"####" F -1;
		Stop;
	Pose4:
		"####" F 80;
		"####" G 40;
		"####" HG 40;
		"####" I 80;
		"####" F 80;
		"####" GJ 40;
		"####" HF 80;
		Loop;
	Pose5:
		"####" K -1;
		Stop;
	Pose6:
		"####" K 80;
		"####" L 40;
		"####" ML 40;
		"####" N 80;
		"####" K 80;
		"####" LO 40;
		"####" MK 80;
		Loop;
	Pose7:
		"####" P -1;
		Stop;
	Pose8:
		"####" P 80;
		"####" Q 40;
		"####" RQ 40;
		"####" S 80;
		"####" P 80;
		"####" QT 40;
		"####" RP 80;
		Loop;
	}
}

class TMCivExtra7 : TMCivExtra1
{
	Default
	{
		//$Title Random Sleeveless Civilian (animated, hat)
	}
	States
	{
	Spawn:
		XTR7 A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		XTR7 A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8","Pose9","Pose10","Pose11","Pose12","Pose13","Pose14","Pose15","Pose16","Pose17","Pose18","Pose19","Pose20","Pose21","Pose22","Pose23","Pose24","Pose25","Pose26","Pose27","Pose28","Pose29","Pose30","Pose31","Pose32");
		Stop;
	Pose1:
		"####" A -1;
		Stop;
	Pose2:
		"####" B -1;
		Stop;
	Pose3:
		"####" C -1;
		Stop;
	Pose4:
		"####" D -1;
		Stop;
	Pose5:
		"####" E -1;
		Stop;
	Pose6:
		"####" F -1;
		Stop;
	Pose7:
		"####" FE 40;
		"####" GHIJKLGHIJKLGHIJKLG 1 A_SetTics(random(10,15));
		"####" EF 40;
		Loop;
	Pose8:
		"####" GHIJKLGHIJKLGHIJKLG 1 A_SetTics(random(10,15));
		Loop;
	Pose9:
		"####" M -1;
		Stop;
	Pose10:
		"####" N -1;
		Stop;
	Pose11:
		"####" O -1;
		Stop;
	Pose12:
		"####" P -1;
		Stop;
	Pose13:
		"####" Q -1;
		Stop;
	Pose14:
		"####" R -1;
		Stop;
	Pose15:
		"####" RQ 40;
		"####" STUVWXSTUVWXSTUVWXS 1 A_SetTics(random(10,15));
		"####" QR 40;
		Loop;
	Pose16:
		"####" STUVWXSTUVWXSTUVWXS 1 A_SetTics(random(10,15));
		Loop;
	Pose17:
		XTR8 A -1;
		Stop;
	Pose18:
		XTR8 B -1;
		Stop;
	Pose19:
		XTR8 C -1;
		Stop;
	Pose20:
		XTR8 D -1;
		Stop;
	Pose21:
		XTR8 E -1;
		Stop;
	Pose22:
		XTR8 F -1;
		Stop;
	Pose23:
		XTR8 FE 40;
		XTR8 GHIJKLGHIJKLGHIJKLG 1 A_SetTics(random(10,15));
		XTR8 EF 40;
		Loop;
	Pose24:
		XTR8 GHIJKLGHIJKLGHIJKLG 1 A_SetTics(random(10,15));
		Loop;
	Pose25:
		XTR8 M -1;
		Stop;
	Pose26:
		XTR8 N -1;
		Stop;
	Pose27:
		XTR8 O -1;
		Stop;
	Pose28:
		XTR8 P -1;
		Stop;
	Pose29:
		XTR8 Q -1;
		Stop;
	Pose30:
		XTR8 R -1;
		Stop;
	Pose31:
		XTR8 RQ 40;
		XTR8 STUVWXSTUVWXSTUVWXS 1 A_SetTics(random(10,15));
		XTR8 QR 40;
		Loop;
	Pose32:
		XTR8 STUVWXSTUVWXSTUVWXS 1 A_SetTics(random(10,15));
		Loop;
	}
}

class TMCivExtra8 : TMCivExtra1
{
	Default
	{
		//$Title Random Vagrant (also animated)
	}
	States
	{
	Spawn:
		HOBO A 0 NODELAY A_SetScale(Scale.X * RandomPick(-1.0, 1.0), frandom(0.60, 0.70) );
	Randomize:
		HOBO A 0 A_Jump(256,"Pose1","Pose2","Pose3","Pose4","Pose5","Pose6","Pose7","Pose8");
		Stop;
	Pose1:
		"####" A -1;
		Stop;
	Pose2:
		"####" B -1;
		Stop;
	Pose3:
		"####" C -1;
		Stop;
	Pose4:
		"####" D -1;
		Stop;
	Pose5:
		"####" E -1;
		Stop;
	Pose6:
		"####" F -1;
		Stop;
	Pose7:
		"####" J -1;
		Stop;
	Pose8:
		"####" F 1 A_SetTics(random(20,40));
		"####" GGHHIIHIHHIHIIGGHHIG 1 A_SetTics(random(80,160));
		Loop;
	}
}