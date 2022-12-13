// Clamp vertically
// © 2022 Talon1024 - MIT License

vec4 Process(vec4 color) {
	ivec2 size = textureSize(tex, 0);
	vec2 pixelUv = 1. / vec2(size);
	float y = clamp(vTexCoord.y, pixelUv.y, 1. - pixelUv.y);
	vec2 uv = vec2(vTexCoord.x, y);
	return getTexel(uv);
}
