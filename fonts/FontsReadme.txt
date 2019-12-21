I converted these fonts from the original BMF and FON2 files using this: https://github.com/Talon1024/ZFontConverter

Having each font in GZDoom unicode format will make it easier to edit the fonts, add new characters, replace characters, add Russian characters, etc.

The names of the PNG files are the hexadecimal code points for the unicode characters they correspond to. For example: Latin capital E (U+0045) is 0045.png

I have only tested smallfont ingame, and since PNG fonts lack certain features of BMF fonts, some long briefing/dialogue texts may overflow the box. Obviously, we'll need to test each piece of text to ensure it fits within the box at the top. We may even need to do some manual tweaking to correct kerning and space widths.