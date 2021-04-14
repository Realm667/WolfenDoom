/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, AFADoomer
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

class RatSpawner: Actor
{
	Default
	{
		//$Category Fauna (BoA)
		//$Title Rats (arg0 Amount, arg1 Radius)
		//$Color 0
		//$Sprite MOUSA1
		//$Arg0 "Amount"
		//$Arg0Tooltip "Amount of Rats, from 1-5"
		//$Arg1 "Radius"
		//$Arg1Tooltip "Radius in map units"
		Radius 2;
		Height 2;
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_JumpIf(Args[0]==5,5);
		"####" A 0 A_JumpIf(Args[0]==4,5);
		"####" A 0 A_JumpIf(Args[0]==3,5);
		"####" A 0 A_JumpIf(Args[0]==2,5);
		"####" A 0 A_JumpIf(Args[0]==1,5);
		"####" AAAAA 0 A_SpawnItemEx("ScurryRat", random (-Args[1], Args[1]), 0, 0, 0, 0, 0, random (0, 360),0 ,0 ,tid);
		"####" A 1;
		Stop;
	}
}

class ScurryRat : Base
{
	Default
	{
		Radius 8;
		Height 8;
		Health 1;
		Mass 50;
		Speed 8;
		Scale 0.20;
		-CANUSEWALLS
		-CANPUSHWALLS
		+AMBUSH
		+FLOORCLIP
		+FRIGHTENED
		+LOOKALLAROUND
		+NEVERRESPAWN
		+STANDSTILL
		+TOUCHY
		+VULNERABLE
		ActiveSound "rat/active";
		DeathSound "rat/death";
		SeeSound "rat/squeek";
	}
	States
	{
	Spawn:
		MOUS A 10 A_LookThroughDisguise;
		Loop;
	See:
		MOUS A 1 A_Chase;
		"####" A 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" A 1 A_Chase;
		"####" A 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		"####" B 1 A_Chase;
		"####" B 1 A_Chase(null,null,CHF_NOPLAYACTIVE);
		"####" A 0 A_CheckSight ("Vanish");
		Loop;
	Vanish:
		TNT1 A 1;
		Stop;
	Death:
		MOUS H 3 A_ScreamAndUnblock;
		"####" IJKL 3;
		"####" M -1;
		Stop;
	}
}