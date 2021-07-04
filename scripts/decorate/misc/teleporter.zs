/*
 * Copyright (c) 2015-2021 Tormentor667, MaxED, Ozymandias81
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

//teleports player if he's in sight and below actor
class ExTeleportIfPlayerBelow: Actor
{
	Default
	{
		//$Category Teleports
		//$Title Teleport (player below)
		//$Sprite TELED0
		//$Arg0 "Destination Tag"
		//$Arg0Type 14
		Radius 16;
		Height 16;
		RenderStyle "None";
		+NOGRAVITY
	}
	States
	{
	Spawn:
		TELE D 2;
		"####" D 4 A_LookEx(LOF_NOSOUNDCHECK, 0, 152, 0, 360);
		Loop;
	See:
		"####" D 4 A_CheckSight("Spawn");
		"####" D 0 A_JumpIf(CallACS("ExGetPlayerZ") < Pos.Z, "Teleport");
		Loop;
	Teleport:
		"####" D 0 ACS_NamedExecute("ExTeleportPlayer", 0, TID, args[0]);
		"####" D 8;
		Goto Spawn;
	}
}

//teleports player if he's in sight and above actor
class ExTeleportIfPlayerAbove : ExTeleportIfPlayerBelow
{
	Default
	{
		//$Title Teleport (player above)
		//$Sprite TELEU0
	}
	States
	{
	See:
		TELE U 4 A_CheckSight("Spawn");
		"####" U 0 A_JumpIf(CallACS("ExGetPlayerZ") > Pos.Z, "Teleport");
		Loop;
	}
}