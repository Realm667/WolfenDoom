/*
 * Copyright (c) 2018-2021 AFADoomer
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

// AFADoomer's ugly but functional parser for nested bracketed data
// Free for use with attribution
// Used for Info/Help pages and parsing of various data files
class ParsedValue
{
	String KeyName;
	String Value;
	Array<ParsedValue> Children;
	ParsedValue Parent;

	private int index;

	void Init()
	{
		index = -1;
	}

	ParsedValue Next(String n = "")
	{
		while (++index < children.Size())
		{
			if (!n.length() || children[index].KeyName ~== n) { return children[index]; }
		}

		return null;
	}

	ParsedValue Find(String n = "", int instance = 1)
	{
		int i = -1;
		int count = 0;

		while (++i < children.Size())
		{
			if (!n.length() || children[i].KeyName ~== n)
			{
				if (++count == instance)
				{
					index = i;
					children[i].Init();
					return children[i];
				}
			}
		}

		return null;
	}
}

class FileReader
{
	static ParsedValue Parse(String path)
	{
		ParsedValue root = new("ParsedValue");
		ParseString(ReadLump(path), root);

		return root;
	}

	static String ReadLump(String lumpname)
	{
		int lump = -1;

		lump = Wads.CheckNumForFullName(lumpname);

		if (lump > -1) { return Wads.ReadLump(lump); }

		return "";
	}

	static int ParseString(String input, ParsedValue parent = null)
	{
		String token = "";
		int length = 0;
		ParsedValue block, key;
		bool linecomment, blockcomment;

		if (parent == null) { console.printf("\cgERROR: \ckParent node of parsed string cannot be null."); return 0; }

		for (int i = 0; i < input.Length(); i++)
		{
			length = i;

			switch(input.ByteAt(i))
			{
				case 13: // \r (Carriage Return)
					if (i < input.Length() - 1 && input.ByteAt(i + 1) == 10) { break; }
				case 10: // \n (Line Feed)
					linecomment = false;
				case 0:  // null
				case 9:  // Tab
					break;
				case 47: // /
					if (i < input.Length() - 1 && input.ByteAt(i + 1) == "/") { linecomment = true; }
					else if (i < input.Length() - 1 && input.ByteAt(i + 1) == "*") { blockcomment = true; }
					else if (i > 0 && input.ByteAt(i - 1) == "*") { blockcomment = false; }
					else if (!blockcomment && !linecomment) { token = token .. input.Mid(i, 1); }
					break;
				case 59: // ;
					if (blockcomment || linecomment) { break; }
					key = new("ParsedValue");
					key.parent = parent;
					Array<String> temp;
					temp.Clear();

					token.Split(temp, "=");
					if (temp.Size())
					{
						key.keyname = ZScriptTools.Trim(temp[0]);
						if (temp.Size() > 1) { key.value = ZScriptTools.Trim(temp[1]); }

						if (parent) { parent.Children.Push(key); }
					}

					token = "";
					break;
				case 123: // {
					if (blockcomment || linecomment) { break; }
					block = new("ParsedValue");
					block.parent = parent;
					block.KeyName = ZScriptTools.Trim(token);

					if (parent) { parent.Children.Push(block); }

					token = "";
					int l = 0;
					l = ParseString(input.mid(i + 1), block);
					i += l + 1;
					break;
				case 125: // }
					if (blockcomment || linecomment) { break; }
					if (ZScriptTools.Trim(token).length()) { console.printf("Missing semi-colon after %s", token); }
					return i;
					break;
				default:
					if (blockcomment || linecomment) { break; }
					token = token .. input.Mid(i, 1);
					break;
			}
		}

		return length;
	}

	static String DumpData(ParsedValue data, int depth = 0)
	{
		String output = "";
		String padding = "";

		for (int s = 1; s < depth; s++)
		{
			padding = padding .. "    ";
		}

		if (data.keyname && data.value) {
			output.AppendFormat("%sKey: %s = %s\n", padding, data.keyname, data.value);
			console.printf("%sKey: %s = %s", padding, data.keyname, data.value); }
		else if (data.keyname) {
			output.AppendFormat("%s%s\n", padding, data.keyname);
			console.printf("%s%s", padding, data.keyname);
		}

		if (data.Children.Size())
		{
			for (int i = 0; i < data.Children.Size(); i++)
			{
				DumpData(data.Children[i], depth + 1);
			}
		}

		return output;
	}

	static int GetInt(ParsedValue data, String path)
	{
		return GetString(data, path).ToInt();
	}

	static double GetDouble(ParsedValue data, String path)
	{
		return GetString(data, path).ToDouble();
	}

	static bool GetBool(ParsedValue data, String path)
	{
		String val = GetString(data, path);

		if (val == "0" || !val.length()) { return false; }

		return true;
	}

	static String GetString(ParsedValue data, String path, bool strip = false)
	{
		ParsedValue current = data;
		Array<String> temp;

		path.Split(temp, ".");

		for (int i = 0; i < temp.Size(); i++)
		{
			for (int j = 0; j < current.Children.Size(); j++)
			{
				if (current.children[j].keyname ~== temp[i])
				{
					current = current.Children[j];
					break;
				}
			}
		}

		if (!current.value) { return ""; }

		return strip ? StripQuotes(current.value) : current.value;
	}

	static String StripQuotes(String input)
	{
		if (input.Length() < 1) { return ""; }

		input = ZScriptTools.Trim(input);

		// If there are both leading and trailing quotes, remove them, otherwise leave them alone
		if (input.GetNextCodePoint(0) == 0x0022 && input.GetNextCodePoint(input.CodePointCount() - 1) == 0x0022)
		{
			input.Remove(0, 1);
			input.DeleteLastCharacter();
		}

		return input;
	}
}