#ifdef GLSLVIEWER
#define USER_SHADER
#include "gzcompat.frag"
#endif

#define MAX_ITERATIONS 8

uniform float timer;

vec4 add_blur(sampler2D source, vec4 color, int iterations)
{
	ivec2 tex_size = textureSize(source, 0);
	float uv_y_inc = 2. / float(tex_size.y);
	iterations = clamp(iterations, 0, MAX_ITERATIONS);
	float mix_factor = 1. / float(iterations);
	for(int i = 1; i < MAX_ITERATIONS; i++)
	{
		if (i > iterations) break;
		vec2 uv = vTexCoord.xy;
		uv.y += i * uv_y_inc;
		color = mix(color, texture(source, uv), mix_factor);
	}
	return color;
}

// From https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
// Unknown license

float zrand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noize(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);

	float res = mix(
		mix(zrand(ip),zrand(ip+vec2(1.0,0.0)),u.x),
		mix(zrand(ip+vec2(0.0,1.0)),zrand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

// 	<https://www.shadertoy.com/view/MdX3Rr>
//	by inigo quilez
const mat2 m2 = mat2(0.8,-0.6,0.6,0.8);
float fbm( in vec2 p ){
    float f = 0.0;
    f += 0.5000*noize( p ); p = m2*p*2.02;
    f += 0.2500*noize( p ); p = m2*p*2.03;
    f += 0.1250*noize( p ); p = m2*p*2.01;
    f += 0.0625*noize( p );

    return f/0.9375;
}

#define NOISE_SCALE 8.

vec4 add_fbm_blur(vec2 uv, int tex_height, int iterations)
{
	vec2 myUv = uv;
	float uv_y_inc = 2. / float(tex_height);
	iterations = clamp(iterations, 0, MAX_ITERATIONS);
	float mix_factor = 1. / float(iterations);
	vec4 color = vec4(fbm(uv * NOISE_SCALE));
	for(int i = 1; i < MAX_ITERATIONS; i++)
	{
		if (i > iterations) break;
		myUv = uv;
		myUv.y += i * uv_y_inc;
		color = mix(color, vec4(fbm(myUv * NOISE_SCALE)), mix_factor);
	}
	return color;
}

vec4 Process(vec4 color)
{
	vec4 final_color = color;
	final_color = add_blur(tex, final_color, 3);
	vec2 fbmUv = vTexCoord.xy; fbmUv.y -= timer;
	final_color += add_fbm_blur(fbmUv * NOISE_SCALE, textureSize(tex, 0).y / 2, 6);
	return final_color;
	// return vec4(1.,0.,0.,1.);
}
