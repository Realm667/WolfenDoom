// Adapted by AFADoomer from https://github.com/prideout/recipes/blob/master/demo-Lava.glsl

uniform float fogDensity = 0.3;
uniform vec3 fogColor = vec3(0, 0, 0);

vec4 Process(vec4 color)
{
	vec2 position = -1.0 + 2.0 * vTexCoord.st;

	vec4 noise = texture2D(background, vTexCoord.st);
	vec2 T1 = vTexCoord.st + vec2(1.5, -1.5) * timer * 0.02;
	vec2 T2 = vTexCoord.st + vec2(-0.5, 2.0) * timer * 0.01;
				
	T1.x += noise.x * 2.0;
	T1.y += noise.y * 2.0;
	T2.x -= noise.y * 0.2;
	T2.y += noise.z * 0.2;
				
	float p = texture(background, T1 * 2.0).a;
				
	color = getTexel(T2 * 2.0);
	vec4 temp = color * (vec4(p, p, p, p) * 2.0) + (color * color - 0.1);
				
	if(temp.r > 1.0) { temp.bg += clamp(temp.r - 2.0, 0.0, 100.0); }
	if(temp.g > 1.0) { temp.rb += temp.g - 1.0; }
	if(temp.b > 1.0) { temp.rg += temp.b - 1.0; }
				
	FragColor = temp;

	float depth = gl_FragCoord.z * 4; 
	const float LOG2 = 1.442695;
	float fogFactor = exp2(-fogDensity * fogDensity * depth * depth * LOG2);
	fogFactor = 1.0 - clamp(fogFactor, 0.0, 1.0);
				
	return mix(FragColor, vec4(fogColor, temp.a), fogFactor);
}