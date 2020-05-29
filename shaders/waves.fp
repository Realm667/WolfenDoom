const float pi = 3.14159265358979323846;

vec2 GetRippleOffset(vec2 texCoord)
{
	vec2 offset;

	offset.x = 0.005 * cos(timer + 200.0 * texCoord.y);
	offset.y = 0.05 * cos(timer + 50.0 * texCoord.y);

	return offset;
}

vec2 GetWarpOffset(vec2 texCoord)
{
	vec2 offset;

	// This is basically the old warp2 shader - secondary image is used as a very subdued background warp
	offset.y = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.15 + 900.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.15 + 300.0/8192.0));
	offset.x = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.125 + 700.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.125 + 1200.0/8192.0));

	offset *= 0.25;

	return offset;
}

void SetupMaterial(inout Material material)
{
	vec2 texCoord = vTexCoord.st;
	vec2 rippleoffset = GetRippleOffset(texCoord);
	vec2 warpoffset = GetWarpOffset(texCoord);

	// Material material;
	material.Base = getTexel(texCoord + rippleoffset) * 0.85 + texture(background, texCoord + warpoffset) * 0.05;
	material.Normal = ApplyNormalMap(texCoord + rippleoffset);
#if defined(SPECULAR)
	material.Specular = texture(texture3, texCoord + rippleoffset).rgb;
	material.Glossiness = uSpecularMaterial.x;
	material.SpecularLevel = uSpecularMaterial.y;
#endif
#if defined(BRIGHTMAP)
	material.Bright = texture(brighttexture, vTexCoord.st);
#endif
	// return material;
}