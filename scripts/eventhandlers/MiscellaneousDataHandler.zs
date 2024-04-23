/*
 * Copyright (c) 2020-2024 Talon1024, AFADoomer
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

class MiscellaneousDataHandler : StaticEventHandler
{
	ParsedValue splashdata, textcolordata;

	override void OnRegister()
	{
		splashdata = FileReader.Parse("data/GroundSplashes.txt");

		/*
		String groundSplashData = FileReader.DumpData(splashdata, 1);
		Console.Printf("Ground splash data:\n%s", groundSplashData);
		*/

		// Parse defined text colors
		textcolordata = FileReader.Parse("textcolors.txt", true);
		for (int d = 0; d < textcolordata.children.Size(); d++)
		{
			Array<String> temp;
			textcolordata.children[d].keyname.Split(temp, " ");
			textcolordata.children[d].keyname = temp[0]; // Only store the first listed name

			for (int c = 0; c < textcolordata.children[d].children.Size(); c++)
			{
				String colordata = textcolordata.children[d].children[c].keyname;

				// Only store the 'Flat:' color for lookup - ignore text colors that don't have this defined
				int start = colordata.IndexOf("Flat:");
				if (start > -1)
				{
					int i = colordata.IndexOf("#", colordata.IndexOf("Flat:")) + 1;
					if (i > -1) { textcolordata.children[d].value = colordata.mid(i, 6); }
				}
			}
		}
	}
}