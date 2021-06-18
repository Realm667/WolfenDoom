// Force pixelation
// © 2021 Talon1024 - MIT License

vec4 Process(vec4 color)
{
	vec2 texCoord = vTexCoord.st;
	ivec2 size = textureSize(tex, 0);
	vec2 pixelCoord = (floor(texCoord * size) + .5) / size;
	return getTexel(pixelCoord);
}
