/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat
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

class FireExtinguisher : ExplosiveBarrel
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title Fire Extinguisher
		//$Color 3
		Height 64;
		Radius 8;
		Scale 0.5;
		DeathSound "nebelwerfer/xplode";
		Obituary "$OBEXTING";
		+DONTTHRUST
	}
	States
	{
	Spawn:
		GASF A -1;
		Stop;
	Death:
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Medium",0,0,32);
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Metal1", random(0,8), random(0,8), random(16,32), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 6 A_Scream;
		Stop;
	}
}

class GasBottle : FireExtinguisher
{
	Default
	{
		//$Title Gas Bottle
		Height 56;
		Obituary "$OBGASBTL";
	}
	States
	{
	Spawn:
		GASB A -1;
		Stop;
	Death:
		"####" A 3 A_Jump(64,4);
		"####" A 3 A_Jump(64,2);
		"####" A 3 A_Jump(64,2);
		"####" A 3;
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Medium");
		"####" AAAAAA 0 A_SpawnItemEx("Debris_Metal1", random(0,8), random(0,8), random(16,32), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 6 A_Scream;
		Stop;
	}
}

class Bomb : GasBottle
{
	Default
	{
		//$Title Bomb
		Height 48;
		Obituary "$OBBOMB";
	}
	States
	{
	Spawn:
		BOMB A -1;
		Stop;
	}
}

class FlakShellAP : GasBottle
{
	Default
	{
		//$Title 88mm AP Shell (shootable)
		Height 62;
		Obituary "$OBFLAKAP";
	}
	States
	{
	Spawn:
		FL36 A -1;
		Stop;
	}
}

class FlakShellHE : GasBottle
{
	Default
	{
		//$Title 88mm HE Shell (shootable)
		Height 64;
		Health 1; // HE shell, detonates instantly
		// more fearsome sound?
		Obituary "$OBFLAKHE";
	}
	States
	{
	Spawn:
		FL36 B -1;
		Stop;
	Death:
		"####" A 3;
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Large");
		"####" A 0 A_Explode(64, 320); // HE effect
		"####" AAAAAAAAAAAAAA 0 A_SpawnItemEx("Debris_Metal1", random(0,8), random(0,8), random(16,32), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		"####" A 6 A_Scream;
		Stop;
	}
}

class Flak38Box : GasBottle
{
	Default
	{
		//$Title 20mm Magazine Box (shootable)
		Height 40;
		Radius 32;
		Obituary "$OBFLAK38";
	}
	States
	{
	Spawn:
		FL38 A -1;
		Stop;
	}
}