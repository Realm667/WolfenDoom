vec4 ProcessTexel()
{
	vec2 texCoord = vTexCoord.st;
	return getTexel(texCoord);
}

vec4 ProcessLight(vec4 color)
{
	vec4 brightpix = desaturate(vec4(255, 255, 255, 255));
	return vec4(min (color.rgb + brightpix.rgb, 1.0), color.a);
}