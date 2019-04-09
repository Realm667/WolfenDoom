#define MAXCOLOR 15.0
#define COLORS 16.0

#define LUT_WIDTH 256.0
#define LUT_HEIGHT 16.0

#define TEXTURE_WIDTH 256.0
#define TEXTURE_HEIGHT 256.0

vec4 lookup(sampler2D original, vec2 texCoord, sampler2D lut, int lutIndex)
{
    const vec4 px = clamp(texture2D(original, texCoord.xy), 0.0, 1.0);

    const float cell = px.b * MAXCOLOR;
    const float cell_l = floor(cell);
    const float cell_h = ceil(cell);

    const float half_px_x = 0.5 / TEXTURE_WIDTH;
    const float half_px_y = 0.5 / TEXTURE_HEIGHT;

    const float top = lutIndex * (1.0 / (TEXTURE_HEIGHT / LUT_HEIGHT));

    const float r_offset = half_px_x + px.r / COLORS * (MAXCOLOR / COLORS);
    const float g_offset = half_px_y + px.g / COLORS * (MAXCOLOR / COLORS) + top;

    const vec2 lut_pos_l = vec2(cell_l / COLORS + r_offset, g_offset);
    const vec2 lut_pos_h = vec2(cell_h / COLORS + r_offset, g_offset);

    const vec4 graded_color_l = texture2D(lut, lut_pos_l);
    const vec4 graded_color_h = texture2D(lut, lut_pos_h);

    return mix(graded_color_l, graded_color_h, fract(cell));
}

void main()
{
    const vec4 fragA = lookup(InputTexture, TexCoord, lut, lutA);
    const vec4 fragB = lookup(InputTexture, TexCoord, lut, lutB);

    FragColor = mix(fragA, fragB, clamp(alpha, 0.0, 1.0));
}
