/*
 * Copyright (C) 2019-2020 Dennis "Exl" Meuwissen
 *
 * This work is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike 4.0 International License. To view a
 * copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 * You are free to copy and redistribute the material in any medium or format;
 * and remix, transform, and build upon the material. If you do so, you must
 * give appropriate credit, provide a link to the license, and indicate if
 * changes were made. You may do so in any reasonable manner, but not in any way
 * that suggests the licensor endorses you or your use. You may not use the
 * material for commercial purposes. If you remix, transform, or build upon the
 * material, you must distribute your contributions under the same license as
 * the original.
**/

#define MAXCOLOR 15.0
#define COLORS 16.0

#define LUT_WIDTH 256.0
#define LUT_HEIGHT 16.0

#define TEXTURE_WIDTH 256.0
#define TEXTURE_HEIGHT 256.0

vec4 lookup(sampler2D original, vec2 texCoord, sampler2D lut, int lutIndex)
{
    vec4 px = clamp(texture(original, texCoord.xy), 0.0, 1.0);

    float cell = px.b * MAXCOLOR;
    float cell_l = floor(cell);
    float cell_h = ceil(cell);

    const float half_px_x = 0.5 / TEXTURE_WIDTH;
    const float half_px_y = 0.5 / TEXTURE_HEIGHT;

    float top = lutIndex * (1.0 / (TEXTURE_HEIGHT / LUT_HEIGHT));

    float r_offset = half_px_x + px.r / COLORS * (MAXCOLOR / COLORS);
    float g_offset = half_px_y + px.g / COLORS * (MAXCOLOR / COLORS) + top;

    vec2 lut_pos_l = vec2(cell_l / COLORS + r_offset, g_offset);
    vec2 lut_pos_h = vec2(cell_h / COLORS + r_offset, g_offset);

    vec4 graded_color_l = texture(lut, lut_pos_l);
    vec4 graded_color_h = texture(lut, lut_pos_h);

    return mix(graded_color_l, graded_color_h, fract(cell));
}

void main()
{
    vec4 fragA = lookup(InputTexture, TexCoord, lut, lutA);
    vec4 fragB = lookup(InputTexture, TexCoord, lut, lutB);

    FragColor = mix(fragA, fragB, clamp(alpha, 0.0, 1.0));
}
