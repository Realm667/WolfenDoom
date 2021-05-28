/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, Talon1024,
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

//////////////////////
// EXCLAMATION MARK //
//////////////////////
class Exclamation : ExclamationBase
{
	Default
	{
		//$Title Exclamation Mark
		//$Sprite EXCLA0
		Radius 8;
		Height 64;
		Scale 1.35;
		RenderStyle "Translucent";
		Alpha 1.0;
		+CLIENTSIDEONLY
		+NOGRAVITY
	}
	States
	{
	Spawn:
		EXCL A 0;
		Goto Active;
	Active:
		EXCL A -1 Bright;
		Stop;
	Inactive:
		TNT1 A -1;
		Stop;
	}
}

class ExclamationCompass : ExclamationBase
{
	Default
	{
		//$Title Objective Map Marker (Compass)
		//$Sprite EXCLC0
		Radius 8;
		Height 8;
		+INVISIBLE
		ExclamationBase.ShowOnSpawn 1;
	}
	States
	{
	Spawn:
		EXCL C 0;
		Goto Active;
	Active:
		EXCL C -1 BRIGHT;
		Stop;
	Inactive:
		TNT1 A -1;
		Stop;
	}
}

class ExclamationTouchable : Exclamation
{
	Default
	{
		//$Title Exclamation Mark (greyed out on touching)
		ExclamationBase.TouchRange 72.0;
	}
	States
	{
	Touched:
		EXCL A 35 Bright;
	TouchLoop:
		EXCL B -1;
		Stop;
	}
}

class ExclamationTextpaper : ExclamationTouchable
{
	Default
	{
		//$Title Exclamation Text (greyed out on touching)
		//$Sprite EXCLF0
		ExclamationBase.TouchRange 72.0;
		Scale 1.0;
	}
	States
	{
	Spawn:
		EXCL F 0;
		Goto Active;
	Active:
		EXCL F -1 Bright;
		Stop;
	Inactive:
		TNT1 A -1;
		Stop;
	Touched:
		EXCL F 35 Bright;
	TouchLoop:
		EXCL G -1;
		Stop;
	}
}

class ExclamationHintpaper : ExclamationTouchable
{
	Default
	{
		//$Title Exclamation Secret Hint (greyed out on touching)
		//$Sprite EXCLH0
		ExclamationBase.TouchRange 72.0;
		Scale 1.0;
	}
	States
	{
	Spawn:
		EXCL H 0;
		Goto Active;
	Active:
		EXCL H -1 Bright;
		Stop;
	Inactive:
		TNT1 A -1;
		Stop;
	Touched:
		EXCL H 35 Bright;
	TouchLoop:
		EXCL I -1;
		Stop;
	}
}

class InteractionIcon: Actor
{
	Default
	{
		Height 8;
		Radius 64;
		Scale 1.0;
		RenderStyle "Translucent";
		Alpha 1.0;
		-SOLID
		+CLIENTSIDEONLY
		+FLOATBOB
		+LOOKALLAROUND
		+NOBLOCKMAP
		+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_CheckRange(128.0, "FadeAway", TRUE);
		ICNI A 1 BRIGHT;
		Loop;
	FadeAway:
		"####" A 10;
		Goto Spawn;
	}
}

class InteractionIcon25Health : InteractionIcon
{
	States
	{
	Spawn:
		ICNI A 0 NODELAY {
			PlayerPawn pmo = players[consoleplayer].mo;
			if (pmo.health >= 25 || Distance2D(pmo) > 128.0)
			{
				return ResolveState("FadeAway");
			}
			A_FadeIn(0.0625, FTF_CLAMP);
			return ResolveState(null);
		}
		ICNI A 1 BRIGHT;
		Loop;
	FadeAway:
		ICNI A 1 A_FadeOut(0.0625, FTF_CLAMP);
		Goto Spawn;
	}
}

class ObjectiveIcon : BoAMapMarker
{
	Default
	{
		//$Category Misc (BoA)
		//$Title Objective Map Marker (Automap & Compass)
		//$Color 1
	}
	States
	{
	Spawn:
		EXCL C -1;
		Stop;
	}
}