// Adapted by AFADoomer from https://github.com/prideout/recipes/blob/master/demo-Lava.glsl
const float fogDensity = 0.3;
const vec3 fogColor = vec3(0, 0, 0);

vec4 texture_bilinear(in sampler2D t, in vec2 uv);

vec4 ProcessTexel()
{
	vec2 texCoord = vTexCoord.st;

	vec4 noise = texture_bilinear(foreground, vTexCoord.st * 1.5);
	vec2 T1 = texCoord + vec2(1.5, -1.5) * mod(timer, 1024) * 0.02 + noise.xy * 2.0;
	vec2 T2 = texCoord + vec2(-0.5, 2.0) * mod(timer, 1024) * 0.01 + noise.xy * 0.2;

	float p = texture_bilinear(foreground, T1 * 2.0).a;

	vec4 color = texture_bilinear(tex, T2 / 2.0);
	vec4 FragColor = color * (vec4(p, p, p, p) * 1.5) + (color * color - 0.1);

	if (FragColor.r > 1.0) { FragColor.bg += clamp(FragColor.r - 2.0, 0.0, 100.0); }
	if (FragColor.g > 1.0) { FragColor.rb += FragColor.g - 1.0; }
	if (FragColor.b > 1.0) { FragColor.rg += FragColor.b - 1.0; }

	return mix(FragColor, vec4(fogColor, FragColor.a), fogDensity);
}

// Derived from the old GZDoom brightmaps shader
vec4 ProcessLight(vec4 color)
{
	// Use the processed image as its own brightmap
	vec4 brightpix = desaturate(FragColor);
	return vec4(min(color.rgb + brightpix.rgb, 1.0), color.a);
}

// Modified by AFADoomer from peterfilm and sashley at https://community.khronos.org/t/manual-bilinear-filter/58504
vec4 texture_bilinear(in sampler2D t, in vec2 uv)
{
	vec2 texSize = textureSize(t, 0);
	vec2 texelSize = 1.0 / texSize;

	vec2 f = fract( uv * texSize );
	uv += ( 0.5 - f ) * texelSize;

	vec4 tl = texture(t, uv);
	vec4 tr = texture(t, uv + vec2(texelSize.x, 0.0));
	vec4 bl = texture(t, uv + vec2(0.0, texelSize.y));
	vec4 br = texture(t, uv + vec2(texelSize.x, texelSize.y));

	vec4 tA = mix( tl, tr, f.x );
	vec4 tB = mix( bl, br, f.x );

	return mix( tA, tB, f.y );
}
