/*
 * Copyright (c) 2019-2020 AFADoomer
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

// The bDormant true/false values for normal MapMarker actors are reversed in the current GZDoom version...
// Bug report here: https://forum.zdoom.org/viewtopic.php?f=2&t=61717
// Since this hasn't been fixed and was identified months ago, a workaround is included here.
class BoAMapMarker : MapMarker
{
	String user_icon; // This will only affect the compass icon, not the automap icon

	override void PostBeginPlay()
	{
		BoACompass.Add(self, user_icon);

		if (!(SpawnFlags & MTF_DORMANT)) { Activate(null); }
		else { Deactivate(null); }
	}

	override void Activate (Actor activator)
	{
		bDormant = false; 
	}

	override void Deactivate (Actor activator)
	{
		bDormant = true;
	}
}

class ExclamationBase : SwitchableDecoration
{
	bool onCompass;
	double touchRange, targetAlpha;
	String user_icon;

	Property ShowOnSpawn:onCompass;
	Property TouchRange:touchRange;

	Default
	{
		//$Category Misc (BoA)
		//$Color 1

		RenderStyle "Translucent";
		ExclamationBase.ShowOnSpawn false;
		ExclamationBase.TouchRange 0;
	}

	override void PostBeginPlay()
	{
		if (onCompass) { BoACompass.Add(self, user_icon); }

		if (!(SpawnFlags & MTF_DORMANT)) { Activate(null); }
		else { Deactivate(null); }

		if (alpha) { targetAlpha = alpha; }
		else { targetAlpha = 1.0; }

		alpha = 0.0;
	}

	override void Activate (Actor activator)
	{
		bDormant = false; 
		touchRange = Default.touchRange; // Allow resetting touch deactivation by re-activating the actor
		SetStateLabel("Active");
	}

	override void OnDestroy()
	{
		Deactivate(null);
	}

	override void Deactivate (Actor activator)
	{
		bDormant = true;
		SetStateLabel("Inactive");
	}

	override void Tick()
	{
		Super.Tick();

		if (!bDormant)
		{
			alpha = min(targetalpha, alpha + 0.05);
		}
		else
		{
			alpha = max(0, alpha - 0.05);
		}

		DoProximityChecks();
	}

	void DoProximityChecks()
	{
		if (!onCompass && !CheckRange(2048.0) && !CheckIfSeen())
		{
			BoACompass.Add(self, user_icon);
			onCompass = true;
		}

		if (touchRange && !CheckRange(touchRange))
		{
			SetStateLabel("Touched");
			touchRange = 0;
		}
	}
}