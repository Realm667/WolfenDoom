// Take a palette and a bunch of PNG files, and make all of those PNG files use
// the palette

// #include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

// Necessary for reading grAb chunk (offsets)
#define PNG_USER_CHUNKS_SUPPORTED
#define PNG_READ_UNKNOWN_CHUNKS_SUPPORTED
#define PNG_READ_USER_CHUNKS_SUPPORTED
#define PNG_STORE_UNKNOWN_CHUNKS_SUPPORTED
// Most font characters have transparency
#define PNG_tRNS_SUPPORTED
#include "png.h"

// Boolean type - not in C by default
typedef char bool;
#define FALSE -1
#define TRUE 1

typedef unsigned char byte;

typedef struct palette_entry {
    byte r;
    byte g;
    byte b;
} palette_entry_t;

typedef struct palette {
    byte entry_count;
    palette_entry_t* entries;
} palette_t;

void help();
palette_t* read_palette(const char* fname);
palette_t* read_text_palette(const char* fname);
byte parse_hex(const char* hex);
palette_t* read_bin_palette(const char* fname);
int process_unknown_chunk(png_structp png_ptr, png_unknown_chunkp chunk_ptr);
bool process_png(const char* fname, palette_t* pal);
// double colour_distance_rgb(const palette_entry_t* to_compare, const palette_entry_t* against);

int main(int argc, char** argv){
    if(argc == 1){
        help();
        return 0;
    // First argument is palette file, as a list of newline-separated strings
    }else if(argc > 1){
        // Open and read palette
        palette_t* pal = read_palette(argv[1]);
        // For each following argument:
        for(int argi = 2; argi < argc; argi++){
            // If argument is a PNG file:
            int arglen = strlen(argv[argi]);
            char* extn = argv[argi] + arglen - 4;
            if(strncasecmp(extn, ".png", 4) == 0){
                // Open it and process it
                if(process_png(argv[argi], pal) == FALSE){
                    fprintf(stderr, "Failed to process %s!\n", argv[argi]);
                }
            }
        }
        free(pal->entries);
        free(pal);
    }
}

void help(){
    puts("Palhack: Bulk-replace palettes in PNG files\n\n"
        "Usage: palhack palette [png...]\n\n"
        "palette is expected to be any text file with a list of colours in "
        "hexadecimal format. For example:\n\n"
        "#a8921b\n"
        "#9a4b31\n"
        "#badaff\n\n"
        "Note that the first entry of the palette will be transparent\n\n"
        "The following arguments are expected to be PNG files.");
}

palette_t* read_palette(const char* fname){
    // This is a high-level function which decides whether to read text or
    // binary data, based on the file name.
    int filenameLen = strlen(fname);
    const char* extn = fname + filenameLen - 4; // Assume 3 letters for the extension
    if(strncasecmp(".txt", extn, 4) == 0){ // Read text if extension is .txt
        return read_text_palette(fname);
    }
    // Read binary otherwise
    return read_bin_palette(fname);
}

palette_t* read_text_palette(const char* fname){
    // Open palette file and read data from it
    FILE* f = fopen(fname, "r");
    fseek(f, 0, SEEK_END);
    long flength = ftell(f);
    fseek(f, 0, SEEK_SET);
    char* fdata = malloc(flength);
    fread(fdata, 1, flength, f);
    fclose(f);
    // Parse the data
    long parser = 0;
    palette_t* pal = malloc(sizeof(palette_t));
    // Read through data once to count colours
    pal->entry_count = 0;
    while(parser < flength){
        if(fdata[parser] == '#'){
            // Next 6 characters are in hexadecimal RGB format
            pal->entry_count += 1;
        }
        parser += 1;
    }
    // Allocate entries and read through colours again
    parser = 0;
    pal->entries = malloc(pal->entry_count * sizeof(palette_entry_t));
    byte cur_entry = 0;
    while(parser < flength){
        if(fdata[parser] == '#'){
            // Next 6 characters are in hexadecimal RGB format
            parser += 1;
            pal->entries[cur_entry].r = parse_hex(fdata + parser);
            parser += 2;
            pal->entries[cur_entry].g = parse_hex(fdata + parser);
            parser += 2;
            pal->entries[cur_entry].b = parse_hex(fdata + parser);
            parser += 2;
            cur_entry += 1;
        }
        parser += 1;
    }
    free(fdata);
    return pal;
}

// Parse a hexadecimal pair
byte parse_hex(const char* hex){
    byte value = 0;
    byte sub = 0;
    // Parse second character (low nibble)
    byte parser = 1;
    if(hex[parser] >= 48 && hex[parser] <= 57){
        sub = 48;
    }else if(hex[parser] >= 65 && hex[parser] <= 70){
        sub = 55; // A will be 10, F will be 15
    }else if(hex[parser] >= 97 && hex[parser] <= 102){
        sub = 87; // a will be 10, f will be 15
    }
    value = hex[parser] - sub;
    // Parse first character (high nibble)
    parser = 0;
    if(hex[parser] >= 48 && hex[parser] <= 57){
        sub = 48;
    }else if(hex[parser] >= 65 && hex[parser] <= 70){
        sub = 55; // A will be 10, F will be 15
    }else if(hex[parser] >= 97 && hex[parser] <= 102){
        sub = 87; // a will be 10, f will be 15
    }
    value += (hex[parser] - sub) << 4;
    return value;
}

palette_t* read_bin_palette(const char* fname){
    // Open palette file and read data from it
    FILE* f = fopen(fname, "r");
    fseek(f, 0, SEEK_END);
    long flength = ftell(f);
    fseek(f, 0, SEEK_SET);
    byte* fdata = malloc(flength);
    fread(fdata, 1, flength, f);
    fclose(f);
    // Allocate palette
    palette_t* pal = malloc(sizeof(palette_t));
    memset(pal, 0, sizeof(palette_t));
    // Numbers greater than 255 won't fit inside a single byte.
    if((flength / 3) > 255){
        return pal;
    }
    // Since this is a binary file, no text parsing is required.
    // Assume colours are in RGB format, with one byte per component.
    pal->entries = (palette_entry_t*) fdata;
    pal->entry_count = flength / 3;
    return pal;
}

int process_unknown_chunk(png_structp png_ptr, png_unknown_chunkp chunk_ptr){
    if(strncmp((const char*)chunk_ptr->name, "grAb", 4) == 0){
        // Process grAb chunk - get offsets
        byte* offsets = png_get_user_chunk_ptr(png_ptr);
        memcpy(offsets, chunk_ptr->data, 8);
        return 1; // Processed; discard chunk
    }
    return 0; // Unknown; Keep chunk
}

bool process_png(const char* fname, palette_t* pal){
    png_image image;
    // Allocate buffer for PLTE chunk
    byte palbufsize = pal->entry_count * 3 + 3;
    byte* palbuf = malloc(palbufsize);
    // Set up palette buffer
    memset(palbuf, 0, 3);
    memcpy(palbuf + 3, pal->entries, pal->entry_count * 3);
    // Clear image
    memset(&image, 0, (sizeof(png_image)));
    // Check PNG header
    FILE* f = fopen(fname, "r");
    byte header[8];
    if(fread(header, 1, 8, f) != 8){
        fclose(f);
        fprintf(stderr, "Can't read %s.\n", fname);
        return FALSE;
    }
    if(png_sig_cmp(header, 0, 8)){
        fclose(f);
        fprintf(stderr, "%s isn't a PNG.\n", fname);
        return FALSE;
    }
    // Read PNG file
    png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if(!png_ptr){
        return FALSE;
    }
    png_infop info_ptr = png_create_info_struct(png_ptr);
    if(!info_ptr){
        png_destroy_read_struct(&png_ptr, NULL, NULL);
        fclose(f);
        return FALSE;
    }
    if(setjmp(png_jmpbuf(png_ptr))){
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        fclose(f);
        return FALSE;
    }
    png_init_io(png_ptr, f);
    // Already checked PNG header
    png_set_sig_bytes(png_ptr, 8);
    char* grab_name = "grAb"; // Keep grAb chunk, it contains X and Y offsets
    // png_set_keep_unknown_chunks(png_ptr, PNG_HANDLE_CHUNK_IF_SAFE, grab_name, 1);
    unsigned int width, height;
    byte offsets[8]; // Information for Doom PNG files
    png_set_read_user_chunk_fn(png_ptr, offsets, process_unknown_chunk);
    int bit_depth, color_type;
    png_read_info(png_ptr, info_ptr);
    png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type, NULL, NULL, NULL);
    // Don't hack an image which isn't paletted.
    if(color_type != 3){
        fclose(f);
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        fprintf(stderr, "%s isn't paletted! Convert it to the font palette with SLADE first.\n", fname);
        return FALSE;
    }
    // Set up palette quantization and other things
    // png_set_quantize(png_ptr, (png_colorp) pal->entries, pal->entry_count, pal->entry_count, NULL, 0);
    // Read the image
    png_byte** row_pointers = malloc(height * sizeof(png_byte*));
    for(unsigned int row = 0; row < height; row++){
        row_pointers[row] = malloc(png_get_rowbytes(png_ptr, info_ptr));
    }
    png_read_image(png_ptr, row_pointers);
    png_read_end(png_ptr, info_ptr);
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    // Save the image
    fclose(f);
    f = fopen(fname, "w");
    if(f == NULL){
        return FALSE;
    }
    // Set up write/info structs
    png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if(png_ptr == NULL){
        fclose(f);
        return FALSE;
    }
    info_ptr = png_create_info_struct(png_ptr);
    if(info_ptr == NULL){
        fclose(f);
        png_destroy_write_struct(&png_ptr, NULL);
        return FALSE;
    }
    // Set up error handling
    if(setjmp(png_jmpbuf(png_ptr))){
        png_destroy_write_struct(&png_ptr, &info_ptr);
        fclose(f);
        return FALSE;
    }
    // Begin writing PNG
    png_init_io(png_ptr, f);
    png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, PNG_COLOR_TYPE_PALETTE, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);
    byte transparent_colour = 0;
    png_set_PLTE(png_ptr, info_ptr, (png_colorp) palbuf, pal->entry_count + 1);
    png_set_tRNS(png_ptr, info_ptr, &transparent_colour, 1, NULL);
    // Write grAb chunk
    png_unknown_chunk grab_chunk;
    memcpy(grab_chunk.name, grab_name, 5);
    grab_chunk.data = offsets;
    grab_chunk.size = 8;
    grab_chunk.location = PNG_HAVE_IHDR;
    png_set_unknown_chunks(png_ptr, info_ptr, &grab_chunk, 1);
    // Write image
    png_write_info(png_ptr, info_ptr);
    png_write_image(png_ptr, row_pointers);
    png_write_end(png_ptr, info_ptr);
    // Shut down
    free(palbuf);
    for(unsigned int row = 0; row < height; row++){
        free(row_pointers[row]);
        row_pointers[row] = NULL;
    }
    free(row_pointers);
    row_pointers = NULL;
    png_destroy_write_struct(&png_ptr, &info_ptr);
    fclose(f);
    return TRUE;
}
/*
// Find "distance" between two colours
double colour_distance_rgb(const palette_entry_t* to_compare, const palette_entry_t* against){
    byte rdiff = to_compare->r - against->r;
    byte gdiff = to_compare->g - against->g;
    byte bdiff = to_compare->b - against->b;
    double lengthSquared = rdiff * rdiff + gdiff * gdiff + bdiff * bdiff;
    return sqrt(lengthSquared);
}
*/
