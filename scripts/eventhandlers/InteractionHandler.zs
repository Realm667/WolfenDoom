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

class InteractionHandler : EventHandler
{
	ParsedValue texturesounds;

	override void OnRegister()
	{
		texturesounds = FileReader.Parse("data/TextureSounds.txt");
	}

	static String GetSound(String texture)
	{
		InteractionHandler handler = InteractionHandler(EventHandler.Find("InteractionHandler"));
		if (!handler) { return ""; }

		String snd = FileReader.GetString(handler.texturesounds, "TextureSounds." .. texture, true);
		if (!snd.length()) { snd = FileReader.GetString(handler.texturesounds, "TextureSounds.default", true); }

		return snd;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "opensafe")
		{
			ThinkerIterator it = ThinkerIterator.Create("Safe", Thinker.STAT_DEFAULT);
			Safe mo;

			while (mo = Safe(Actor(it.Next())))
			{
				if (int(mo.pos.x) != e.args[0] || int(mo.pos.y) != e.args[1] || int(mo.pos.z) != e.args[2]) { continue; }

				mo.DoOpen();
				return;
			}
		}
		else if (e.Name == "testfonts")
		{
			ZScriptTools.TestFonts();
		}
		else if (e.Name == "testuifont")
		{
			ZScriptTools.TestFontFallback();
		}
	}
}