/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, Guardsoul,
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

const TESLA_FLAGS1 = SXF_ABSOLUTEPOSITION | SXF_CLIENTSIDE;
const TESLA_FLAGS2 = SXF_TRANSFERSCALE | SXF_CLIENTSIDE;

class Radar: SceneryBase //3d ACTOR
{
	Default
	{
		//$Category Props (BoA)/Tech
		//$Title Radar
		//$Color 3
		DistanceCheck "boa_scenelod";
		Radius 32;
		Height 48;
		Scale 0.75;
		+SOLID
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class TeslaLab1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Tech
		//$Title Tesla Device (Off)
		//$Color 3
		Radius 32;
		Height 48;
		Scale 0.6;
		+DONTTHRUST
		+NOGRAVITY
		+NOTAUTOAIMED
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TESL A -1;
		Stop;
	}
}

class TeslaLab2 : SwitchableDecoration
{
	Default
	{
	//$Category Props (BoA)/Tech
	//$Title Tesla Device, with Effects (short)
	//$Color 3
	Radius 16;
	Height 24;
	+DONTTHRUST
	+NOGRAVITY
	+NOTAUTOAIMED
	+RANDOMIZE
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("tesla/active", CHAN_ITEM, CHANF_LOOPING, 0.7, ATTN_STATIC);
	ActiveLoop:
		TESL C 0 A_CheckRange(512,"Unsighted");
		"####" C 8 LIGHT("TESLIT2");
		"####" AA 0 A_SpawnItemEx("SparkB",0,frandom(-2.0,2.0),Scale.Y*40,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*40,0,0,0,random(0,360),SXF_CLIENTSIDE);
		"####" D 8 LIGHT("TESLIT2");
		"####" AA 0 A_SpawnItemEx("SparkB",0,frandom(-2.0,2.0),Scale.Y*48,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*48,0,0,0,random(0,360),SXF_CLIENTSIDE);
		"####" B 8 LIGHT("TESLIT2");
		"####" AA 0 A_SpawnItemEx("SparkB",0,frandom(-2.0,2.0),Scale.Y*32,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*32,0,0,0,random(0,360),SXF_CLIENTSIDE);
		Loop;
	Inactive:
		TESL N -1 A_StopSound(CHAN_ITEM);
		Stop;
	Unsighted:
		TNT1 A 0 A_StopSound(CHAN_ITEM);
	SilentLoop:
		TESL C 8 LIGHT("TESLIT2");
		"####" AA 0 A_SpawnItemEx("SparkB",0,frandom(-2.0,2.0),Scale.Y*40,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*40,0,0,0,random(0,360),SXF_CLIENTSIDE);
		"####" D 8 LIGHT("TESLIT2");
		"####" AA 0 A_SpawnItemEx("SparkB",0,frandom(-2.0,2.0),Scale.Y*48,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*48,0,0,0,random(0,360),SXF_CLIENTSIDE);
		"####" B 8 LIGHT("TESLIT2");
		"####" AA 0 A_SpawnItemEx("SparkB",0,frandom(-2.0,2.0),Scale.Y*32,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*32,0,0,0,random(0,360),SXF_CLIENTSIDE);
		Goto Active;
	}
}

class TeslaLab3 : TeslaLab2
{
	Default
	{
	//$Title Tesla Device, with Effects (tall)
	Height 96;
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("tesla/active", CHAN_ITEM, CHANF_LOOPING, 0.7, ATTN_STATIC);
	ActiveLoop:
		TESL F 0 A_CheckRange(512,"Unsighted");
		"####" F 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-8,Scale.Y*64,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*64,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*8,Scale.Y*64,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" G 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-12,Scale.Y*72,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*80,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*12,Scale.Y*72,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" H 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-16,Scale.Y*88,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*96,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*16,Scale.Y*88,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" I 6 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-20,Scale.Y*100,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*112,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*20,Scale.Y*100,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" J 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-24,Scale.Y*116,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*122,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*24,Scale.Y*116,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" K 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-28,Scale.Y*122,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*126,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*28,Scale.Y*122,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" L 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-32,Scale.Y*126,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*130,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*32,Scale.Y*126,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" E 4 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-4,Scale.Y*52,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*52,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*4,Scale.Y*52,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		Loop;
	Inactive:
		TESL M -1 A_StopSound(CHAN_ITEM);
		Stop;
	Unsighted:
		TNT1 A 0 A_StopSound(CHAN_ITEM);
	SilentLoop:
		TESL F 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-8,Scale.Y*64,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*64,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*8,Scale.Y*64,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" G 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-12,Scale.Y*72,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*80,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*12,Scale.Y*72,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" H 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-16,Scale.Y*88,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*96,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*16,Scale.Y*88,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" I 6 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-20,Scale.Y*100,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*112,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*20,Scale.Y*100,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" J 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-24,Scale.Y*116,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*122,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*24,Scale.Y*116,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" K 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-28,Scale.Y*122,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*126,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*28,Scale.Y*122,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" L 5 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-32,Scale.Y*126,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*130,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*32,Scale.Y*126,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" E 4 LIGHT("TESLIT1");
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*-4,Scale.Y*52,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,Scale.Y*52,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" AA 0 A_SpawnItemEx("SparkB",0,Scale.X*4,Scale.Y*52,0,frandom(-1.0,1.0),frandom(-1.0,1.0),random(0,360),TESLA_FLAGS1,random(157,203));
		Goto Active;
	}
}

class TeslaLab4 : TeslaLab2
{
	Default
	{
	//$Title Tesla Device, no Effects (short)
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("tesla/active", CHAN_ITEM, CHANF_LOOPING, 0.7, ATTN_STATIC);
		ActiveLoop:
		TESL CDB 4 LIGHT("TESLIT2") A_CheckRange(512,"Unsighted");
		Loop;
	Inactive:
		"####" N -1 A_StopSound(CHAN_ITEM);
		Stop;
	Unsighted:
		TNT1 A 0 A_StopSound(CHAN_ITEM);
	SilentLoop:
		TESL CDB 4 LIGHT("TESLIT2");
		Goto Active;
	}
}

class TeslaLab5 : TeslaLab2
{
	Default
	{
	//$Title Tesla Device, no Effects (tall)
	Height 96;
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 A_StartSound("tesla/active", CHAN_ITEM, CHANF_LOOPING, 0.7, ATTN_STATIC);
		ActiveLoop:
		TESL FGHIJKLE 4 LIGHT("TESLIT1") A_CheckRange(512,"Unsighted");
		Loop;
	Inactive:
		"####" M -1 A_StopSound(CHAN_ITEM);
		Stop;
	Unsighted:
		TNT1 A 0 A_StopSound(CHAN_ITEM);
	SilentLoop:
		TESL FGHIJKLE 4 LIGHT("TESLIT1");
		Goto Active;
	}
}

class Pmetal1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Tech
		//$Title Metal Junk 1
		//$Color 3
		+CLIENTSIDEONLY
		+CORPSE
		+MOVEWITHSECTOR
		+NOTELEPORT
		Height 1;
		Radius 1;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		MTLJ A -1;
		MTLJ B -1;
		MTLJ C -1;
		Stop;
	}
}

class Pmetal2 : Pmetal1
{
	Default
	{
	//$Title Metal Junk 2
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		MTLJ D -1;
		MTLJ E -1;
		MTLJ F -1;
		Stop;
	}
}

class Pmetal3 : Pmetal1
{
	Default
	{
	//$Title Metal Junk 3
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		MTLJ G -1;
		MTLJ H -1;
		MTLJ I -1;
		Stop;
	}
}

class Pmetal4 : Pmetal1
{
	Default
	{
	//$Title Metal Junk 4
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		MTLJ J -1;
		MTLJ K -1;
		MTLJ L -1;
		Stop;
	}
}

class Pmetal5 : Pmetal1
{
	Default
	{
	//$Title Metal Junk 5
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		MTLJ M -1;
		MTLJ N -1;
		Stop;
	}
}