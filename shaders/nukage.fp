// Adapted by AFADoomer from https://github.com/prideout/recipes/blob/master/demo-Lava.glsl
// Same as lava.fp, but favors green channel instead of red, with no brightmap-style handling
const float fogDensity = 0.25;
const vec3 fogColor = vec3(0, 0, 0);

vec4 ProcessTexel()
{
	vec4 noise = texture(foreground, vTexCoord.st);
	vec2 T1 = vTexCoord.st + vec2(1.5, -1.5) * mod(timer, 1024) * 0.02 + noise.xy * 2.0;
	vec2 T2 = vTexCoord.st + vec2(-0.5, 2.0) * mod(timer, 1024) * 0.01 + noise.xy * 2.0;
				
	float p = texture(foreground, T1 * 2.0).a / 2;
				
	vec4 color = getTexel(T2 * 2.0);
	FragColor = color * (vec4(p, p, p, p) * 2.0) + (color * color - 0.1);
				
	if(FragColor.r > 1.0) { FragColor.bg += FragColor.r - 1.0; }
	if(FragColor.g > 1.0) { FragColor.rb += clamp(FragColor.g - 2.0, 0.0, 100.0); }
	if(FragColor.b > 1.0) { FragColor.rg += FragColor.b - 1.0; }
	
	FragColor.a = clamp(FragColor.a, 0.0, 1.0);
	return mix(FragColor, vec4(fogColor, FragColor.a), fogDensity);
}