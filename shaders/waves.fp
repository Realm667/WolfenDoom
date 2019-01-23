const float pi = 3.14159265358979323846;

vec4 Process(vec4 color)
{
	vec2 texCoord = vTexCoord.st;
	vec2 offset1, offset2;

	// Set offsets for rippling the texture
	offset1.x = 0.005 * cos(timer + 200.0 * texCoord.y);
	offset1.y = 0.05 * cos(timer + 50.0 * texCoord.y);

	// This is basically the old warp2 shader - secondary image is used as a very subdued background warp
	offset2.y = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.15 + 900.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.15 + 300.0/8192.0));
	offset2.x = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.125 + 700.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.125 + 1200.0/8192.0));

	offset2 *= 0.25;

	return getTexel(texCoord + offset1) * 0.85 + texture2D(background, texCoord + offset2) * 0.05;
}