//#define FADE_DISTANCE 512.

vec4 Process (vec4 color)
{
	vec4 pixel = texture(tex, vTexCoord.xy);
	float alpha = min(1., pixelpos.w / FADE_DISTANCE);
	return vec4(pixel.rgb, pixel.a * alpha);
}