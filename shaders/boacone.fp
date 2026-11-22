vec4 Process(vec4 color)
{
    vec4 pixel = texture(conesource, vTexCoord.xy);
    return vec4(pixel.rgb, pixel.a * clamp(pixelpos.w / 512., 0., 1.));
}
