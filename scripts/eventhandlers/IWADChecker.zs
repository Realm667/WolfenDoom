/*
 * Copyright (c) 2020 N00b, Talon1024
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

class IWADChecker : EventHandler
{
	// Check if BoA is being loaded as a PWAD, and display the IWADNotice if it
	// is.
	void CheckIWAD()
	{
		// If the IWAD's autoname value doesn't match the BoA C3 release autoname, then show the notice
		if (!(WadInfo.GetIWADInfoEntry("autoname") == "WolfenDoom.BoA.v3"))
		{
			//console.printf("Current IWAD is " .. WadInfo.GetIWADInfoEntry("name") .. ".");
			Menu.SetMenu("IWADNotice");
			Level.setFrozen(true);
		}
	}

	void CheckRenderer()
	{
		// Ensure player is using a renderer which supports shaders
		/*
		if (!(r_renderercaps & RFF_MATSHADER) && !(r_renderercaps & RFF_POSTSHADER))
		{
			Menu.SetMenu("IWADNotice");
			Level.setFrozen(true);
		}
		*/
	}

	void DisplayDisclaimer()
	{
		Menu.SetMenu("Disclaimer");
		Level.setFrozen(true);
	}

	override void WorldTick()
	{
		CVar firstrun = CVar.FindCVar("boa_firstrun");

		if (level.time == 5)
		{
			// List here in reverse order displayed (they logically open "on top" of each other)
			if (firstrun && firstrun.GetBool())
			{
				DisplayDisclaimer();
				firstrun.SetBool(false);
			}
			CheckRenderer();
			CheckIWAD();
			Destroy();
		}
	}
}