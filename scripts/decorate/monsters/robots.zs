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

class TeslaTurret : NaziStandard
{
	Default
	{
	//$Category Monsters (BoA)/Defensive Devices
	//$Title Tesla Turret (Invulnerable)
	//$Color 4
	Radius 16;
	Height 96;
	Speed 0;
	MaxTargetRange 640;
	-CASTSPRITESHADOW  //needed for shadows
	-COUNTKILL
	+DONTTHRUST
	+INVULNERABLE
	+LOOKALLAROUND
	+NOBLOOD
	+NOTAUTOAIMED //because it's invulnerable, some ammo saved
	Obituary "$TESLAT";
	SeeSound "";
	PainSound "";
	DeathSound "";
	}
	States
	{
	Spawn:
		TSLT A 1 A_NaziLook;
		"####" A 0 A_StartSound("Tesla/Loop", CHAN_ITEM, CHANF_LOOPING, 1.0, ATTN_STATIC);
		Loop;
	See:
		"####" A 1 A_NaziChase;
		"####" A 0 A_StartSound("Tesla/Loop", CHAN_ITEM, CHANF_LOOPING, 1.0, ATTN_STATIC);
		Loop;
	Missile:
		"####" A 4 A_FaceTarget;
		"####" A 0 BRIGHT A_StartSound("Tesla/Attack");
		"####" AAAAAA 4 {
			A_StartSound("tesla/kill");
			A_SpawnProjectile("TPortLightningWaveSpawner", 54, 0, 0, CMF_AIMDIRECTION, 0);
			A_SpawnProjectile("TPortLightningWaveSpawner", 54, 0, 180, CMF_AIMDIRECTION, 0);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,54,0,0,0,0,0,160);
			A_SpawnItemEx("TPortLightningWaveSpawner",0,0,54,0,0,0,0,0,160);
			A_LightningAttack("LightningBeamPillarZap2", 0, 0, 54, 0, -90, true);
			A_LightningAttack("LightningBeamZap2", 0, 0, 54, 0, 0, false);
		}
		"####" AA 0 A_SpawnItemEx("SparkB",0,0,54,0,random(-1,1),random(-1,1),random(0,360),TESLA_FLAGS1,random(157,203));
		"####" A 0 A_SpawnItemEx("SparkFlareB",0,0,54,0,0,0,random(0,360),TESLA_FLAGS2);
		"####" A 5;
		"####" A 0 A_JumpIfInTargetLOS("See", 0, JLOSF_CLOSENOJUMP, 0, 640);
		Loop;
	//no Death states because it's invulnerable
	}
}