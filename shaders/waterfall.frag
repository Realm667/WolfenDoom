// #version 330 core // Uncomment this if you're using glslViewer!
// gzcompat.frag is a "compatibility layer" that lets you write texture shaders
// for GZDoom using glslViewer.
// glslViewer: https://github.com/patriciogonzalezvivo/glslViewer
// gzcompat.frag: https://gist.github.com/Talon1024/f704e883851f447ca1985a1d8a45bf95
#ifdef GLSLVIEWER
#define USER_SHADER
#include "gzcompat.frag"
#endif

uniform float timer;

// By Talon1024
// Blurred base texture
#if defined(BLUR) && BLUR > 1
vec4 add_blur(sampler2D source, vec4 color)
{
	ivec2 tex_size = textureSize(source, 0);
	float uv_y_inc = 2. / float(tex_size.y);
	float mix_factor = 1. / float(BLUR);
	for(int i = 1; i < BLUR; i++)
	{
		vec2 uv = vTexCoord.xy;
		uv.y += i * uv_y_inc;
		color = mix(color, texture(source, uv), mix_factor);
	}
	return color;
}
#endif

// Look in boashaders.txt
// #define NOISE_SCALE 8.
// #define NOISE_DISTANCE 768.
// #define OVERLAY_SCALE_X 1.5
// #define OVERLAY_SCALE_Y 1.5
// #define OVERLAY_OPACITY .5
// #define BLUR 1

vec4 Process(vec4 color) // color is white for some reason.. A GZDoom bug?
{
	vec4 finalColor = texture(tex, vTexCoord.xy);
	#if defined(BLUR) && BLUR > 1
	finalColor = add_blur(tex, finalColor);
	#endif
	vec2 fbmUv = vTexCoord.xy; fbmUv.y -= timer;
	vec4 fbmColor = texture(fbmnoise, fbmUv);
	// return fbmColor;
	fbmColor *= texture(tex, vTexCoord.xy); // Colorize fbm
	fbmColor *= min(1., NOISE_DISTANCE / pixelpos.w);
	vec2 overlayUv = vTexCoord.xy;
	overlayUv *= vec2(OVERLAY_SCALE_X, OVERLAY_SCALE_Y);
	overlayUv.y -= timer * .5;
	finalColor = mix(finalColor, texture(tex, overlayUv), OVERLAY_OPACITY);
	finalColor += fbmColor;
	return finalColor;
}
