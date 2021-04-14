/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, AFADoomer, Talon1024
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

//Straight from wiki - DAMAGE_THING special: (https://zdoom.org/wiki/DamageThing)
//"If amount is 0, then the thing is guaranteed to be killed regardless of any invulnerability (including God and Buddha)"
//So no 200 but 0 as Arg0 - Ozy81
class Electricity1 : SwitchableDecoration
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title Electricity (large)
		//$Color 3
		//$Sprite ELECA0
		//$Arg0 "Harmless"
		//$Arg0Tooltip "Values greater than 0 make this actor harmless"
		DistanceCheck "boa_sfxlod";
		Radius 16;
		Height 128;
		+BUMPSPECIAL
		+RANDOMIZE
		DamageType "IceWater";
		Obituary "$OBFIZZLE";
		Activation THINGSPEC_MonsterTrigger;
	}
	States
	{
	Spawn:
	Active:
		ELEC A 0 NODELAY A_JumpIf(args[0] > 0, 2);
		"####" A 0 Thing_SetSpecial(0,73,0,22,0);
		"####" A 0 A_SetSolid;
		"####" A 0 A_Jump(256, "ActiveAnim"); // Goto doesn't work for inheritance - Talon1024
	ActiveAnim:
		ELEC A 0 A_Jump(128, 2);
		"####" ABCD 3;
		Loop;
	Inactive:
		TNT1 A 0 Thing_SetSpecial(0,0,0,0,0);
		"####" A 0 A_UnSetSolid;
		"####" A 0 A_Jump(256, "OffAnim");
	OffAnim:
		"####" A 2;
		Loop;
	}
}

class Electricity2 : Electricity1
{
	Default
	{
		//$Title Electricity (small)
		//$Sprite ELECE0
		Height 64;
	}
	States
	{
	ActiveAnim:
		ELEC EFGH 3;
		Loop;
	}
}

class Electricity3 : Electricity1
{
	Default
	{
		//$Title Electricity (large, horizontal)
		//$Sprite ELECI0
		Height 16;
		Radius 64;
	}
	States
	{
	ActiveAnim:
		ELEC IJKL 3;
		Loop;
	}
}

class Electricity4 : Electricity1
{
	Default
	{
		//$Title Electricity (thin, pitchable/rollable)
		//$Sprite LABZF0
		Height 2;
		Radius 56;
		Scale 0.2;
		+FLATSPRITE
		+NOGRAVITY
		+ROLLSPRITE
		Alpha 1.0;
		Renderstyle "Add";
	}
	States
	{
	ActiveAnim:
		LABZ F 0 A_Jump(256,1,5,9,13,17);
		"####" GHIJKLMNOJNGIHMKOL 2;
		Loop;
	}
}

class ElectricOrb1 : Electricity1
{
	Default
	{
		//$Title Electric Orb (big)
		//$Sprite LABZA0
		Height 16;
		+NOGRAVITY
	}
	States
	{
	ActiveAnim:
		LABZ BCDE 3;
		Loop;
	}
}

class ElectricOrb2 : Electricity1
{
	Default
	{
		//$Title Electric Orb (small)
		//$Sprite LABZP0
		Height 16;
		+NOGRAVITY
	}
	States
	{
	ActiveAnim:
		LABZ PQRST 3;
		Loop;
	}
}