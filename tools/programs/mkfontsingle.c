/*
	mkfontsingle.c : Make font pngs for gzdoom, in an ugly cheap way.
	This code is a mess but I keep it here so people know how much I had
	to suffer to get this done.
	(C)2020 Marisa Kirisame, UnSX Team.
	Released under the MIT license:

	Copyright (c) 2020 Marisa Kirisame

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <png.h>
#include <ft2build.h>
#include FT_FREETYPE_H

uint8_t littleEndian = 1;

struct image_data {
	uint32_t width;
	uint32_t height;
	uint32_t channels; // Number of bytes per row
	uint8_t* data;
};

void swap32(int32_t* toSwap)
{
	int32_t temp = *toSwap;
	*toSwap = (
		(temp & 0x000000FF) << 24 |
		(temp & 0x0000FF00) << 8 |
		(temp & 0x00FF0000) >> 8 |
		(temp & 0xFF000000) >> 24);
}

int32_t writepng( struct image_data* idata, const int8_t *filename, int32_t ox, int32_t oy )
{
	if ( !filename ) return 0;
	png_structp pngp;
	png_infop infp;
	FILE *pf;
	if ( !(pf = fopen(filename,"wb")) ) return 0;
	pngp = png_create_write_struct(PNG_LIBPNG_VER_STRING,0,0,0);
	if ( !pngp )
	{
		fclose(pf);
		return 0;
	}
	infp = png_create_info_struct(pngp);
	if ( !infp )
	{
		fclose(pf);
		png_destroy_write_struct(&pngp,0);
		return 0;
	}
	if ( setjmp(png_jmpbuf(pngp)) )
	{
		png_destroy_write_struct(&pngp,&infp);
		fclose(pf);
		return 0;
	}
	png_init_io(pngp,pf);
	png_set_IHDR(pngp,infp,idata->width,idata->height,8,PNG_COLOR_TYPE_GRAY_ALPHA,
		PNG_INTERLACE_NONE,PNG_COMPRESSION_TYPE_BASE,
		PNG_FILTER_TYPE_BASE);
	// Set up grAb chunk (offsets). If x and y offset is 0, grAb chunk is not needed.
	if (ox > 0 || oy > 0)
	{
		uint8_t* grab_name = (uint8_t*) "grAb";
		int32_t offsets[2];
		offsets[0] = ox;
		offsets[1] = oy;
		if (littleEndian)
		{
			swap32(offsets + 0);
			swap32(offsets + 1);
		}
		png_unknown_chunk grab_chunk;
		memcpy(grab_chunk.name, grab_name, 5);
		grab_chunk.data = (png_bytep) offsets;
		grab_chunk.size = 8;
		grab_chunk.location = PNG_HAVE_IHDR;
		png_set_unknown_chunks(pngp, infp, &grab_chunk, 1);
	}
	// Set up rows
	png_bytep* rowps = malloc(sizeof(png_bytep) * idata->height);
	for (uint32_t row = 0; row < idata->height; row++)
	{
		rowps[row] = idata->data + row * idata->width * idata->channels;
	}
	// Write image
	png_write_info(pngp,infp);
	png_write_image(pngp,rowps);
	png_write_end(pngp,infp);
	png_destroy_write_struct(&pngp,&infp);
	fclose(pf);
	free(rowps);
	return 1;
}

void putpixel( struct image_data* idata, uint8_t v, uint8_t a, uint32_t x, uint32_t y )
{
	if ( (x >= idata->width) || (y >= idata->height) ) return;
	uint32_t tpos = (x+y*idata->width) * idata->channels;
	// add alpha
	int32_t alph = idata->data[tpos+1];
	alph += a;
	if ( alph > 255 ) alph = 255;
	idata->data[tpos+1] = alph;
	// blend color
	int32_t col = idata->data[tpos]*(a-255);
	// col += v*a;
	col += v;
	if ( col > 255 ) col = 255;
	idata->data[tpos] = col;
}

uint8_t lerpg( float a )
{
	return (uint8_t)(a*191+64);
}

int32_t draw_glyph( struct image_data* idata, FT_Bitmap *bmp, uint8_t v, uint32_t px, uint32_t py, uint8_t gradient )
{
	int32_t drawn = 0;
	uint32_t col, row;
	for (row=0; row < bmp->rows; row++)
	{
		uint8_t rv = v;
		// apply gradient, if any
		if ( v == 255 )
		{
			float a = (row + 1) / (float)bmp->rows;
			if ( gradient == 1 ) rv = lerpg(1.-a);
			else if ( gradient == 2 ) rv = lerpg(a);
		}
		for (col=0; col < bmp->width; col++)
		{
			if ( bmp->pixel_mode == FT_PIXEL_MODE_GRAY )
			{
				uint8_t a = bmp->buffer[col+row*bmp->pitch];
				if ( !drawn ) drawn = (a > 0);
				putpixel(idata,rv,a,px+col,py+row);
			}
			else if ( bmp->pixel_mode == FT_PIXEL_MODE_MONO )
			{
				// thanks to https://stackoverflow.com/a/14905971
				uint32_t p = bmp->pitch;
				uint8_t *prow = &bmp->buffer[p*row];
				uint8_t a = ((prow[col>>3])&(128>>(col&7)))?255:0;
				if ( !drawn ) drawn = (a > 0);
				putpixel(idata,rv,a,px+col,py+row);
			}
		}
	}
	return drawn;
}

void write_inf(char* fontName, int32_t kerning, int32_t height, int32_t spacewidth)
{
	int32_t length = 0;
	if (fontName) {
		length += snprintf(NULL, 0, "// %s\n", fontName);
	}
	length += snprintf(NULL, 0, "Kerning %d\nFontHeight %d\n", kerning, height);
	if ( spacewidth > 0 )
	{
		length += snprintf(NULL, 0, "SpaceWidth %d\n", spacewidth);
	}
	int8_t* data = malloc(length);
	int8_t* cur = data;
	cur += sprintf(cur, "// %s\n", fontName);
	cur += sprintf(cur, "Kerning %d\nFontHeight %d\n", kerning, height);
	if ( spacewidth > 0 )
	{
		sprintf(cur, "SpaceWidth %d\n", spacewidth);
	}
	FILE* f = fopen("font.inf", "w");
	fwrite(data, sizeof(int8_t), length, f);
	fclose(f);
	free(data);
}

void render_glyphset(FT_Face fnt, char* fontName, uint32_t low, uint32_t high, int32_t gradient, int32_t upshift, uint8_t padding)
{
	int32_t channels = 2; // Gray/alpha
	struct image_data idata;
	int32_t minHeight = 0, maxHeight = 0, spaceWidth = 0;
	// Get space width
	FT_UInt glyph = FT_Get_Char_Index(fnt,' ');
	if ( !FT_Load_Glyph(fnt,glyph,FT_LOAD_DEFAULT) && glyph )
	{
		spaceWidth = (int32_t)roundf((float)fnt->glyph->linearHoriAdvance / 65536.0);
	}
	for ( uint32_t i=low; i<=high; i++ )
	{
		FT_UInt glyph = FT_Get_Char_Index(fnt,i);
		if ( !FT_Load_Glyph(fnt,glyph,FT_LOAD_DEFAULT) && glyph )
		{
			FT_Render_Glyph(fnt->glyph,FT_RENDER_MODE_NORMAL);
			idata.width = fnt->glyph->bitmap.width + padding * 2;
			idata.height = fnt->glyph->bitmap.rows + padding * 2;
			idata.channels = channels;
			idata.data = malloc(idata.width * idata.height * channels);
			memset(idata.data, 0, idata.width * idata.height * channels);
			// Calculate glyph X and Y offsets
			// printf("Glyph %d linearHoriAdvance: %.3f\n", i, (float) fnt->glyph->linearHoriAdvance / 65536.0);
			// printf("Glyph %d linearVertAdvance: %.3f\n", i, (float) fnt->glyph->linearVertAdvance / 65536.0);
			int32_t glyphHeight = (int32_t)roundf((float) fnt->glyph->linearVertAdvance / 65536.0);
			minHeight = minHeight == 0 ? glyphHeight : minHeight < glyphHeight ? minHeight : glyphHeight;
			maxHeight = maxHeight == 0 ? glyphHeight : maxHeight > glyphHeight ? maxHeight : glyphHeight;
			int32_t glyphWidth = (int32_t)roundf((float) fnt->glyph->linearHoriAdvance / 65536.0);
			int32_t xoffset = -fnt->glyph->bitmap_left;
			int32_t yoffset = fnt->glyph->bitmap_top - glyphHeight + upshift;
			int32_t valid = draw_glyph(&idata, &fnt->glyph->bitmap,255,padding,padding,gradient);
			if ( valid )
			{
				int8_t fname[256];
				snprintf(fname,256,"%04X.png",i);
				writepng(&idata, fname, xoffset, yoffset);
			}
			free(idata.data);
		}
	}
	write_inf(fontName, 1, minHeight + maxHeight / 2, spaceWidth);
}

void write_inf_monospace(char* fontName, int32_t width, int32_t height)
{
	int32_t length = 0;
	if (fontName) {
		length += snprintf(NULL, 0, "// %s\n", fontName);
	}
	length += snprintf(NULL, 0, "CellSize %d, %d\n", width, height);
	int8_t* data = malloc(length);
	int8_t* cur = data;
	cur += sprintf(cur, "// %s\n", fontName);
	cur += sprintf(cur, "CellSize %d, %d\n", width, height);
	FILE* f = fopen("font.inf", "w");
	fwrite(data, sizeof(int8_t), length, f);
	fclose(f);
	free(data);
}

// For monospace fonts
void render_glyphsheet(FT_Face fnt, char* fontName, int32_t charwidth, int32_t charheight, uint32_t low, uint32_t high, int32_t gradient, int32_t upshift, int32_t maxtop, uint8_t padding)
{
	// Render a glyph sheet for monospace fonts
	int32_t channels = 2; // Gray/alpha
	struct image_data idata;
	uint32_t count = high - low + 1;
	uint32_t rows = (uint32_t) floor(sqrt((double)count));
	uint32_t columns = (uint32_t) ceil((double)count / (double)rows);
	int8_t fname[9];
	sprintf(fname, "%04x.png", low);
	// Set up image data
	charwidth += padding * 2; // Add cell padding
	charheight += padding * 2;
	idata.width = columns * charwidth;
	idata.height = rows * charheight;
	idata.channels = channels;
	idata.data = malloc(idata.width * idata.height * channels);
	memset(idata.data, 0, idata.width * idata.height * channels);
	for ( uint32_t i=low; i<=high; i++ )
	{
		FT_UInt glyph = FT_Get_Char_Index(fnt,i);
		uint32_t sheetindex = i - low;
		uint32_t column = sheetindex % columns;
		uint32_t row = sheetindex / columns;
		if ( !FT_Load_Glyph(fnt,glyph,FT_LOAD_DEFAULT) && glyph )
		{
			FT_Render_Glyph(fnt->glyph,FT_RENDER_MODE_NORMAL);
			// Calculate glyph X and Y offsets
			// int32_t glyphHeight = (int32_t)roundf((float) fnt->glyph->linearVertAdvance / 65536.0);
			int32_t cellxoffset = fnt->glyph->bitmap_left + padding;
			if (cellxoffset < 0) { cellxoffset = 0; }
			int32_t cellyoffset = maxtop - fnt->glyph->bitmap_top - upshift + padding;
			int32_t xoffset = column * charwidth + cellxoffset;
			int32_t yoffset = row * charheight + cellyoffset;
			int32_t valid = draw_glyph(&idata, &fnt->glyph->bitmap,255,xoffset,yoffset,gradient);
		}
	}
	writepng(&idata, fname, 0, 0);
	write_inf_monospace(fontName, charwidth, charheight);
}

int32_t main( int32_t argc, int8_t **argv )
{
	if ( argc < 3 )
	{
		fprintf(stderr,"usage: mkfontsingle <font name> <pxsize>"
			" [--range <unicode range>] [--gradient <gradient type>] "
			"[--upshift <y offset>] [--mincharheight <mincharheight>] "
			"[--padding <width>]\n\n"
			"range: Range of Unicode characters to convert, in hexadecimal format. e.g. \"0401-0451\" for all characters in the Russian Alphabet.\n"
			"gradient type: 1 is darker at the bottom, 2 is darker at the top.\n"
			"upshift: Amount to increase or decrease Y offset by. Affects non-monospace fonts only.\n"
			"mincharheight: Force the height of all monospace character cells to be no shorter than this. Affects monospace fonts only.\n"
			"padding: Amount of space (pixels) to add to the edges of each font character image.\n"
		);
		return 1;
	}
	// Test endianness (byte ordering) of CPU
	int8_t endie[4] = {1, 0, 0, 0};
	int32_t* enda = (int32_t*) endie;
	if ( *enda != 1 )
	{
		littleEndian = 0;
	}
	// Init FreeType
	FT_Library ftlib;
	FT_Face fnt;
	if ( FT_Init_FreeType(&ftlib) )
		return 2;
	// Parse positional arguments
	uint32_t range[2] = {0x0021,0x00FF};
	int32_t pxsiz;
	// Crude implementation of basename
	char* baseNameStart = argv[1];
	char* baseNameEnd = NULL;
	for (uint32_t i = strlen(argv[1]) - 1; i > 0; i--) {
		if (baseNameStart == argv[1] && argv[1][i] == '/') {
			baseNameStart = argv[1] + i + 1;
		}
		if (baseNameStart == argv[1] && argv[1][i] == '.') {
			baseNameEnd = argv[1] + i;
		}
	}
	if (!baseNameEnd) baseNameEnd = baseNameStart + strlen(baseNameStart);
	char* fontName = malloc(baseNameEnd - baseNameStart + 1);
	memcpy(fontName, baseNameStart, baseNameEnd - baseNameStart);
	sscanf(argv[2],"%d",&pxsiz);
	// Parse options
	int32_t gradient = 0;
	int32_t upshift = 0;
	int32_t mincharheight = pxsiz;
	uint8_t padding = 0;
	for (int i = 2; i < argc; i++)
	{
		if (!strcmp(argv[i], "--range") && argc > i)
		{
			int rangeresult = sscanf(argv[i+1], "%x-%x", &range[0], &range[1]);
			/*
			if (rangeresult == EOF)
			{
				sscanf(argv[i+1], "%x", &range[0]);
				range[1] = range[0];
			}
			*/
			// sscanf(argv[i+1], "%x-%x", range); // Does this work?
		}
		else if (!strcmp(argv[i], "--gradient") && argc > i)
		{
			sscanf(argv[++i], "%d", &gradient);
		}
		else if (!strcmp(argv[i], "--upshift") && argc > i)
		{
			sscanf(argv[++i], "%d", &upshift);
		}
		else if (!strcmp(argv[i], "--mincharheight") && argc > i)
		{
			sscanf(argv[++i], "%d", &mincharheight);
		}
		else if (!strcmp(argv[i], "--padding") && argc > 1)
		{
			sscanf(argv[++i], "%hhu", &padding);
		}
	}
	if (range[0] > range[1])
	{
		uint32_t high = range[0];
		range[0] = range[1];
		range[1] = high;
	}
	// Set up font and font size
	if ( FT_New_Face(ftlib,argv[1],0,&fnt) )
		return 4;
	if ( FT_Set_Pixel_Sizes(fnt,0,pxsiz) )
		return 8;

	FT_Select_Charmap(fnt,FT_ENCODING_UNICODE);
	// Is font monospace?
	int32_t monospace = -1;
	int32_t maxtop = 0;
	for ( uint32_t i=range[0]; i<=range[1]; i++ )
	{
		FT_UInt glyph = FT_Get_Char_Index(fnt,i);
		if ( !FT_Load_Glyph(fnt,glyph,FT_LOAD_DEFAULT) && glyph )
		{
			// Needed to set bitmap_top
			FT_Render_Glyph(fnt->glyph,FT_RENDER_MODE_NORMAL);
			if ( monospace == -1 )
			{
				monospace = fnt->glyph->advance.x;
			}
			else if ( fnt->glyph->advance.x != monospace )
			{
				// Not a monospace font
				monospace = 0;
				break;
			}
			int32_t charheight = fnt->glyph->bitmap.rows + (fnt->glyph->bitmap.rows - fnt->glyph->bitmap_top);
			if (charheight > mincharheight)
			{
				// printf("mincharheight %d\n", mincharheight);
				mincharheight = charheight;
			}
			if (fnt->glyph->bitmap_top > maxtop)
			{
				maxtop = fnt->glyph->bitmap_top;
			}
		}
	}
	if ( monospace == 0 )
	{
		render_glyphset(fnt,fontName,range[0],range[1],gradient,upshift,padding);
	}
	else
	{
		monospace = (uint32_t) round((double)monospace / 64.0);
		render_glyphsheet(fnt,fontName,monospace,mincharheight,range[0],range[1],gradient,upshift,maxtop,padding);
	}
	FT_Done_Face(fnt);
	FT_Done_FreeType(ftlib);
	return 0;
}
