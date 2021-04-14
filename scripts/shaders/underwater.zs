/*
 * Copyright (c) 2018-2020 AFADoomer
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

class WaterHandler : StaticEventHandler {
	override void RenderOverlay(RenderEvent e) {
		// set the player's timer up correctly (more-than-1-tick precision)
		PlayerInfo p = players[consoleplayer];
		Shader.SetUniform1f(p, "watershader", "timer", gametic + e.FracTic);

		if (p.mo.waterlevel >= 3) {
			Shader.SetEnabled(p, "watershader", true);
			Shader.SetEnabled(p, "waterzoomshader", true);
			double effectSize = CVar.GetCVar("boa_uweffectsize", p).GetFloat();
			Shader.SetUniform1f(p, "watershader", "waterFactor", effectSize);
			Shader.SetUniform1f(p, "waterzoomshader", "zoomFactor", 1 - (effectSize * 2));
		}
		else {
			Shader.SetEnabled(p, "watershader", false);
			Shader.SetEnabled(p, "waterzoomshader", false);
		}
	}
}