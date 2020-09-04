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

void swap32(int* toSwap)
{
	int temp = *toSwap;
	*toSwap = (
		(temp & 0x000000FF) << 24 |
		(temp & 0x0000FF00) << 8 |
		(temp & 0x00FF0000) >> 8 |
		(temp & 0xFF000000) >> 24);
}

int writepng( struct image_data* idata, const char *filename, int ox, int oy )
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
	// Set up grAb chunk (offsets)
	unsigned char* grab_name = (unsigned char*) "grAb";
	int offsets[2];
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
	// Set up rows
	png_bytep* rowps = malloc(sizeof(png_bytep) * idata->height);
	for (unsigned int row = 0; row < idata->height; row++)
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

FT_Library ftlib;
FT_Face fnt;

int pxsiz;

int gradient = 0;
int upshift = 0;

void putpixel( struct image_data* idata, uint8_t v, uint8_t a, uint32_t x, uint32_t y )
{
	if ( (x >= idata->width) || (y >= idata->height) ) return;
	uint32_t tpos = (x+y*idata->width) * idata->channels;
	// add alpha
	int alph = idata->data[tpos+1];
	alph += a;
	if ( alph > 255 ) alph = 255;
	idata->data[tpos+1] = alph;
	// blend color
	int col = idata->data[tpos]*(a-255);
	// col += v*a;
	col += v;
	if ( col > 255 ) col = 255;
	idata->data[tpos] = col;
}

uint8_t lerpg( float a )
{
	return (uint8_t)(a*191+64);
}

int draw_glyph( struct image_data* idata, FT_Bitmap *bmp, uint8_t v, uint32_t px, uint32_t py )
{
	int drawn = 0;
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
				unsigned p = bmp->pitch;
				uint8_t *prow = &bmp->buffer[p*row];
				uint8_t a = ((prow[col>>3])&(128>>(col&7)))?255:0;
				if ( !drawn ) drawn = (a > 0);
				putpixel(idata,rv,a,px+col,py+row);
			}
		}
	}
	return drawn;
}

int main( int argc, char **argv )
{
	if ( argc < 3 )
	{
		fprintf(stderr,"usage: mkfontsingle <font name> <pxsize>"
			" [unicode range (hex)] [gradient type] [y offset]\n\n"
			"gradient type: 1 is darker at the bottom, 2 is darker at the top\n"
		);
		return 1;
	}
	char endie[4] = {1, 0, 0, 0};
	int* enda = (int*) endie;
	if ( *enda != 1 )
	{
		littleEndian = 0;
	}
	if ( FT_Init_FreeType(&ftlib) )
		return 2;
	uint32_t range[2] = {0x0021,0x00FF};
	sscanf(argv[2],"%d",&pxsiz);
	if ( argc > 3 ) sscanf(argv[3],"%x-%x",&range[0],&range[1]);
	if ( argc > 4 ) sscanf(argv[4],"%d",&gradient);
	if ( argc > 5 ) sscanf(argv[5],"%d",&upshift);
	if ( FT_New_Face(ftlib,argv[1],0,&fnt) )
		return 4;
	if ( FT_Set_Pixel_Sizes(fnt,0,pxsiz) )
		return 8;
	int channels = 2; // Gray/alpha
	struct image_data idata;
	FT_Select_Charmap(fnt,FT_ENCODING_UNICODE);
	for ( uint32_t i=range[0]; i<=range[1]; i++ )
	{
		FT_UInt glyph = FT_Get_Char_Index(fnt,i);
		if ( !FT_Load_Glyph(fnt,glyph,FT_LOAD_DEFAULT) && glyph )
		{
			FT_Render_Glyph(fnt->glyph,FT_RENDER_MODE_NORMAL);
			idata.width = fnt->glyph->bitmap.width;
			idata.height = fnt->glyph->bitmap.rows;
			idata.channels = channels;
			idata.data = malloc(idata.width * idata.height * channels);
			memset(idata.data, 0, idata.width * idata.height * channels);
			// Position within image
			int xpos = 0;
			int ypos = 0;
			// Calculate glyph X and Y offsets
			// printf("Glyph %d linearHoriAdvance: %.3f\n", i, (float) fnt->glyph->linearHoriAdvance / 65536.0);
			// printf("Glyph %d linearVertAdvance: %.3f\n", i, (float) fnt->glyph->linearVertAdvance / 65536.0);
			int glyphHeight = (int)roundf((float) fnt->glyph->linearVertAdvance / 65536.0);
			int glyphWidth = (int)roundf((float) fnt->glyph->linearHoriAdvance / 65536.0);
			int xoffset = -fnt->glyph->bitmap_left;
			int yoffset = fnt->glyph->bitmap_top - glyphHeight + upshift;
			int valid = draw_glyph(&idata, &fnt->glyph->bitmap,255,xpos,ypos);
			if ( valid )
			{
				char fname[256];
				snprintf(fname,256,"%04X.png",i);
				writepng(&idata, fname, xoffset, yoffset);
			}
			free(idata.data);
		}
	}
	FT_Done_Face(fnt);
	FT_Done_FreeType(ftlib);
	return 0;
}
