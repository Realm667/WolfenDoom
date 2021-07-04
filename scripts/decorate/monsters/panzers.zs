/*
 * Copyright (c) 2015-2021 Ozymandias81, Tormentor667, Ed the Bat, MaxED, Talon1024,
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

//OzyTanks defs here...

//Ka-Boom base code from Russian Overkill by PillowBlaster - Tweaked by Ozymandias81
class KaBoom: Actor
{
	Default
	{
	Scale 1.1;
	RenderStyle "Add";
	Projectile;
	+BRIGHT
	+NOINTERACTION
	}
	States
	{
	Spawn:
		BFE1 ABCDE 2;
		"####" FGHI 2 A_Explode(75,128);
		"####" JKL 2;
		Stop;
	}
}

class KaBoomer: Actor
{
	Default
	{
	+NOGRAVITY
	+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 AA 1 A_SpawnItemEx("KaBoom",0,0,0,random(-4,4),random(-4,4),random(-2,6),random(0,359),SXF_TRANSFERTRANSLATION|SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION,40);
		Stop;
	}
}

class Nuke : SmokeBase
{
	Default
	{
	+NOBLOCKMAP
	+NOGRAVITY
	+NOINTERACTION
	Radius 0;
	Height 0;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_StartSound("panzer/explode", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 Radius_Quake(7,30,0,96,0);
		"####" A 0 A_SpawnItemEx("TankBoom",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS);
		"####" A 0 A_SpawnItemEx("TankFlare");
		"####" A 25 A_SpawnItemEx("NukeFloor");
		"####" AA 0 A_SpawnItemEx("NukeSmokeFloor");
		"####" A 0 A_SpawnItemEx("TankPillar",0,0,0,0,0,2);
		"####" A 45 A_SpawnItemEx("TankSmokePillar",0,0,0,0,0,2);
		"####" A 0 A_SpawnItemEx("TankMushroom",0,0,56);
		"####" AA 0 A_SpawnItemEx("TankSmokeMushroom",0,0,56);
		Stop;
	}
}

class TankBoom: Actor
{
	Default
	{
	+FORCERADIUSDMG
	+NOBLOCKMAP
	+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAA 2 A_Explode(10,128,0);
		Stop;
	}
}

class TankFire : Nuke
{
	Default
	{
	RenderStyle "Add";
	+BRIGHT
	+DONTSPLASH
	+EXPLODEONWATER
	+NOINTERACTION
	Scale 0.4;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4);
		FLA1 A 2 A_FadeOut(0.03);
		Wait;
		FLA2 A 2 A_FadeOut(0.02);
		Wait;
		FLA3 A 2 A_FadeOut(0.03);
		Wait;
		FLA4 A 2 A_FadeOut(0.02);
		Wait;
	}
}

class TankFlare : TankFire
{
	Default
	{
	Scale 0.6;
	+NOINTERACTION
	}
	States
	{
	Spawn:
		FLAR B 1 A_FadeOut(0.015);
		Wait;
	}
}

class NukeSmoke : Nuke
{
	Default
	{
	Scale 1.0;
	+DONTSPLASH
	+EXPLODEONWATER
	Alpha 0.5;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 0 A_Jump(256,1,2,3,4);
		NSMK ABCD 0 A_Jump(256,"End");
	End:
		NSMK "#" 2 A_FadeOut(0.008);
		Wait;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class NukeFloor : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("TankFire",0,0,0,0.1 * random(0,30),0.1 * random(0,30),0,random(0,359),128);
		Stop;
	}
}

class NukeSmokeFloor : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("NukeSmoke",0,0,0,0.1 * random(0,30),0.1 * random(0,30),0,random(0,359),128);
		Stop;
	}
}

class TankPillar : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("TankFire",0,0,0,0.1 * random(0,10),0.1 * random(0,10),random(0,-3),random(0,359),128);
		"####" A 0 A_SpawnItemEx("TankSmokeRing");
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("TankFire",0,0,0,0.1 * random(0,10),0.1 * random(0,10),random(0,-3),random(0,359),128);
		Stop;
	}
}

class TankSmokePillar : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("NukeSmoke",0,0,0,0.1 * random(0,10),0.1 * random(0,10),0.1 * random(0,-40),random(0,359),128);
		Stop;
	}
}

class TankMushroom : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("TankFire",0,0,0,0.1 * random(0,25),0.01 * random(0,25),0.1 * random(-10,10),random(0,359),128);
		Stop;
	}
}

class TankSmokeMushroom : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("NukeSmoke",0,0,0,0.1 * random(0,25),0.1 * random(0,25),0.1 * random(-10,10),random(0,359),128);
		Stop;
	}
}

class TankSmokeRing : Nuke
{
	int user_theta;
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 0 A_SpawnItemEx("NukeSmoke",0,0,0,1,0,0,user_theta);
		UWMR A 0 { user_theta = user_theta+20; }
		"####" A 0 A_JumpIf(user_theta==360,1);
		Loop;
		TNT1 A 0;
		Stop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

//Nebelwerfers
class NebBoom : TankBoom
{
	Default
	{
	-FORCERADIUSDMG
	}
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAA 2 A_Explode(5,32,0);
		Stop;
	}
}

class NebFire : TankFire
{
	Default
	{
	Scale 0.15;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4);
		FLA1 A 1 A_FadeOut(0.04);
		Wait;
		FLA2 A 1 A_FadeOut(0.02);
		Wait;
		FLA3 A 1 A_FadeOut(0.04);
		Wait;
		FLA4 A 1 A_FadeOut(0.02);
		Wait;
	}
}

class NebSmoke : NukeSmoke
{
	Default
	{
	Scale 0.35;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 0 A_Jump(256,1,2,3,4);
		NSMK ABCD 0 A_Jump(256,"End");
	End:
		NSMK "#" 1 A_FadeOut(0.008);
		Wait;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class NebFlare : TankFlare { Default { Scale 0.25; } }

class NebFloor : NukeFloor
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAA 1 A_SpawnItemEx("NebFire",0,0,0,0.1 * random(0,12),0.1 * random(0,12),0.1 * random(-3,3),random(0,359),128);
		Stop;
	}
}

class NebSmokeFloor : NukeSmokeFloor
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAA 1 A_SpawnItemEx("NebSmoke",0,0,0,0.1 * random(0,15),0.1 * random(0,15),0,random(0,359),128);
		Stop;
	}
}

class NebSmokePillar : TankSmokePillar
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAA 1 A_SpawnItemEx("NebSmoke",0,0,0,0.1 * random(0,5),0.1 * random(0,5),0.1 * random(0,-20),random(0,359),128);
		Stop;
	}
}

class NebSmokeMushroom : TankSmokeMushroom
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAA 1 A_SpawnItemEx("NebSmoke",0,0,0,0.1 * random(0,15),0.1 * random(0,15),0.1 * random(-5,5),random(0,359),128);
		Stop;
	}
}

class NebNuke : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0 Radius_Quake(3,8,0,24,0);
		"####" A 0 A_SpawnItemEx("NebBoom",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS);
		"####" A 0 A_SpawnItemEx("NebFlare");
		"####" A 3 A_SpawnItemEx("NebFloor");
		"####" A 0 A_SpawnItemEx("NebSmokeFloor");
		"####" A 6 A_SpawnItemEx("NebSmokePillar",0,0,0,0,0,2);
		"####" A 0 A_SpawnItemEx("NebSmokeMushroom",0,0,0);
		Stop;
	}
}

class PanzerNuke : Nuke //for panzerschreck rockets
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_StartSound("panzer/explode", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 Radius_Quake(7,30,0,96,0);
		"####" A 0 A_SpawnItemEx("TankBoom",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS);
		"####" A 0 A_SpawnItemEx("TankFlare");
		"####" A 6 A_SpawnItemEx("NukeFloor");
		"####" AA 0 A_SpawnItemEx("NukeSmokeFloor");
		"####" A 11 A_SpawnItemEx("TankSmokePillar",0,0,0,0,0,2);
		"####" AA 0 A_SpawnItemEx("TankSmokeMushroom",0,0,56);
		Stop;
	}
}

class KaZomBoom : KaBoom //Zombie KaBoom
{
	States
	{
	Spawn:
		BFE1 ABCDE 2;
		"####" F 0 A_Explode(random(45,65),144,TRUE,128);
		"####" FGHIJKL 2;
		Stop;
	}
}

class ZombieNuke : Nuke //for zombiekazi
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_StartSound("EXPLOSION_SOUND", CHAN_AUTO, 0, 1.0, ATTN_NORM);
		"####" A 0 Radius_Quake(10,10,0,16,0);
		"####" A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		"####" A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" A 0 A_SpawnItemEx("KD_HL2SmokeGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		"####" A 0 A_SpawnItemEx("KD_HL2SparkGenerator", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		Stop;
	}
}

//UFOs
class UFONuke : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0 A_StartSound("panzer/explode", CHAN_ITEM, 0, 1.0, ATTN_NORM);
		"####" A 0 A_SpawnItemEx("UFOFlare");
		"####" A 25 A_SpawnItemEx("UFONukeFloor");
		"####" A 0 A_SpawnItemEx("UFONukeSmokeFloor");
		"####" A 0 A_SpawnItemEx("UFOPillar",0,0,-8,0,0,2);
		"####" A 45 A_SpawnItemEx("UFOSmokePillar",0,0,-8,0,0,2);
		"####" A 0 A_SpawnItemEx("UFOMushroom",0,0,-8);
		"####" A 0 A_SpawnItemEx("UFOSmokeMushroom",0,0,-8);
		Stop;
	}
}

class UFOFire : TankFire
{
	Default
	{
	Scale 4.0;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4);
		FLA1 A 2 A_FadeOut(0.01);
		Wait;
		FLA2 A 2 A_FadeOut(0.02);
		Wait;
		FLA3 A 2 A_FadeOut(0.01);
		Wait;
		FLA4 A 2 A_FadeOut(0.02);
		Wait;
	}
}

class UFOFlare : TankFlare { Default { Scale 1.8; } }

class UFONukeSmoke : NukeSmoke
{
	Default
	{
	Scale 3.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 0 A_Jump(256,1,2,3,4);
		NSMK ABCD 0 A_Jump(256,"End");
	End:
		NSMK "#" 2 A_FadeOut(0.001);
		Wait;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class UFONukeFloor : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("UFOFire",0,0,0,-0.1 * random(0,30),-0.1 * random(0,30),0,random(0,359),128);
		Stop;
	}
}

class UFONukeSmokeFloor : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("UFONukeSmoke",0,0,0,-0.1 * random(0,30),-0.1 * random(0,30),0,random(0,359),128);
		Stop;
	}
}

class UFOPillar : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("UFOFire",0,0,0,-0.1 * random(0,10),-0.1 * random(0,10),random(0,-3),random(0,359),128);
		"####" A 0 A_SpawnItemEx("UFOSmokeRing");
		"####" AAAAAAAAAAAA 1 A_SpawnItemEx("UFOFire",0,0,0,-0.1 * random(0,10),-0.1 * random(0,10),random(0,-3),random(0,359),128);
		Stop;
	}
}

class UFOSmokePillar : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("UFONukeSmoke",0,0,0,-0.1 * random(0,10),-0.1 * random(0,10),-0.1 * random(0,-40),random(0,359),128);
		Stop;
	}
}

class UFOMushroom : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("UFOFire",0,0,0,-0.1 * random(0,25),-0.01 * random(0,25),-0.1 * random(-10,10),random(0,359),128);
		Stop;
	}
}

class UFOSmokeMushroom : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("UFONukeSmoke",0,0,0,-0.1 * random(0,25),-0.1 * random(0,25),-0.1 * random(-10,10),random(0,359),128);
		Stop;
	}
}

class UFOSmokeRing : Nuke
{
	int user_theta;
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 0 A_SpawnItemEx("UFONukeSmoke",0,0,0,1,0,0,user_theta);
		UWMR A 0 { user_theta = user_theta+20; }
		"####" A 0 A_JumpIf(user_theta==360,1);
		Loop;
		TNT1 A 0;
		Stop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}


class LZ127Nuke : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0 A_StartSound("panzer/explode", CHAN_ITEM, 0, 1.0, ATTN_NORM);
		"####" A 0 A_SpawnItemEx("LZ127Flare");
		"####" A 25 A_SpawnItemEx("LZ127NukeFloor");
		"####" A 0 A_SpawnItemEx("LZ127NukeSmokeFloor");
		"####" A 0 A_SpawnItemEx("LZ127Pillar",0,0,-8,0,0,2);
		"####" A 45 A_SpawnItemEx("LZ127SmokePillar",0,0,-8,0,0,2);
		"####" A 0 A_SpawnItemEx("LZ127Mushroom",0,0,-8);
		"####" A 0 A_SpawnItemEx("LZ127SmokeMushroom",0,0,-8);
		Stop;
	}
}

class LZ127Fire : TankFire
{
	Default
	{
	Scale 10.0;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4);
		FLA1 A 2 A_FadeOut(0.01);
		Wait;
		FLA2 A 2 A_FadeOut(0.02);
		Wait;
		FLA3 A 2 A_FadeOut(0.01);
		Wait;
		FLA4 A 2 A_FadeOut(0.02);
		Wait;
	}
}

class LZ127Flare : TankFlare { Default { Scale 8.8; } }

class LZ127NukeSmoke : NukeSmoke
{
	Default
	{
	Scale 9.7;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 0 A_Jump(256,1,2,3,4);
		NSMK ABCD 0 A_Jump(256,"End");
	End:
		NSMK "#" 2 A_FadeOut(0.001);
		Wait;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class LZ127NukeFloor : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("LZ127Fire",0,0,0,-0.1 * random(0,30),-0.1 * random(0,30),0,random(0,359),128);
		Stop;
	}
}

class LZ127NukeSmokeFloor : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("LZ127NukeSmoke",0,0,0,-0.1 * random(0,30),-0.1 * random(0,30),0,random(0,359),128);
		Stop;
	}
}

class LZ127Pillar : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("LZ127Fire",0,0,0,-0.1 * random(0,10),-0.1 * random(0,10),random(0,-3),random(0,359),128);
		"####" A 0 A_SpawnItemEx("LZ127SmokeRing");
		"####" AAAAAAAAAAAA 1 A_SpawnItemEx("LZ127Fire",0,0,0,-0.1 * random(0,10),-0.1 * random(0,10),random(0,-3),random(0,359),128);
		Stop;
	}
}

class LZ127SmokePillar : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("LZ127NukeSmoke",0,0,0,-0.1 * random(0,10),-0.1 * random(0,10),-0.1 * random(0,-40),random(0,359),128);
		Stop;
	}
}

class LZ127Mushroom : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("LZ127Fire",0,0,0,-0.1 * random(0,25),-0.01 * random(0,25),-0.1 * random(-10,10),random(0,359),128);
		Stop;
	}
}

class LZ127SmokeMushroom : Nuke
{
	States
	{
	Spawn:
		TNT1 A 0;
		"####" AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("LZ127NukeSmoke",0,0,0,-0.1 * random(0,25),-0.1 * random(0,25),-0.1 * random(-10,10),random(0,359),128);
		Stop;
	}
}

class LZ127SmokeRing : Nuke
{
	int user_theta;
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(boa_smokeswitch==0,"EndSpawn");
		TNT1 A 0 A_SpawnItemEx("LZ127NukeSmoke",0,0,0,1,0,0,user_theta);
		UWMR A 0 { user_theta = user_theta+20; }
		"####" A 0 A_JumpIf(user_theta==360,1);
		Loop;
		TNT1 A 0;
		Stop;
	EndSpawn:
		TNT1 A 1;
		Stop;
	}
}

class DestroyedTank1 : TankSmokeSpawner
{
	Default
	{
	//$Category Models (BoA)/Vehicles
	//$Title Tank 1 (Panther Panzer IV, destroyed)
	//$Color 4
	//$Sprite MDLAA0
	Radius 64;
	Height 96;
	Mass 0x7ffffff;
	+FLOORCLIP
	+INVULNERABLE
	+NOBLOOD
	+NOBLOODDECALS
	+NODAMAGE
	+NOTAUTOAIMED
	+SHOOTABLE
	+SOLID
	BloodType "TankSpark";
	}
	States
	{
	Spawn:
	Active:
		MDLA A 12 SpawnEffect();
		Loop;
	}
}

class DestroyedTank2 : DestroyedTank1
{
	Default
	{
	//$Title Tank 2 (KFZ 251 HalfTrack, destroyed)
	Height 88;
	Radius 48;
	}
}

class DestroyedTank3 : DestroyedTank1
{
	Default
	{
	//$Title Tank 3 (Tiger I Panzer, destroyed)
	Height 88;
	}
}

class DestroyedTank4 : DestroyedTank1
{
	Default
	{
	//$Title Tank 4 (Light Panzer KFZ 222, destroyed)
	Height 80;
	}
}

class DestroyedT34Tank : DestroyedTank1
{
	Default
	{
	//$Title T-34 Soviet Standard Tank (destroyed)
	Radius 96;
	Height 88;
	}
}