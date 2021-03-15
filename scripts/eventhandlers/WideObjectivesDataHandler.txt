/*
 * Copyright (c) 2020 Talon1024
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

class WideObjectivesDataHandler : StaticEventHandler
{
	private Dictionary languages;

	override void OnRegister()
	{
		languages = Dictionary.Create();
		ParsedValue data = FileReader.Parse("data/WideObjectives.txt");
		for (int i = 0; i < data.Children.Size(); i++)
		{
			languages.Insert(data.Children[i].KeyName, parseBoolValue(data.Children[i].Value));
		}
	}

	private String parseBoolValue(String value)
	{
		if (value ~== "true") {
			return "1";
		} else if (value ~== "false") {
			return "0";
		}
		return "0";
	}

	clearscope bool shouldUseWideObjectivesBox()
	{
		return shouldUseWideObjectivesBoxFor(language);
	}

	clearscope bool shouldUseWideObjectivesBoxFor(String language)
	{
		String value = languages.At(language);
		if (value.Length() < 1) {
			return 1;
		}
		return value.ToInt();
	}
}