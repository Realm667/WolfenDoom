uniform float timer;

// Defines are in boashaders.txt, and are used to configure the shader.
// #define NOISE_SCALE 1.
// #define NOISE_DISTANCE 768.
// #define OVERLAY_SCALE_X 1.5
// #define OVERLAY_SCALE_Y 1.5
// #define OVERLAY_OPACITY .5

vec4 Process(vec4 color) // color is white for some reason.. A GZDoom bug?
{
	// Get initial colour for the effect
	vec4 texColor = getTexel(vTexCoord.xy);
	vec4 finalColor = texColor;
	// Calculate "fbm" (Fractional Brownian Motion) noise.
	vec2 fbmUv = vTexCoord.xy; fbmUv.y -= timer;
	vec4 fbmColor = texture(fbmnoise, fbmUv);
	fbmColor *= texColor; // Colorize fbm
	fbmColor *= min(1., NOISE_DISTANCE / pixelpos.w);
	// Calculate UV coordinates for overlay texture
	vec2 overlayUv = vTexCoord.xy;
	overlayUv *= vec2(OVERLAY_SCALE_X, OVERLAY_SCALE_Y);
	overlayUv.y -= timer * .5;
	// Compose the effects together for the final colour
	finalColor = mix(finalColor, getTexel(overlayUv), OVERLAY_OPACITY);
	finalColor += fbmColor;
	return finalColor;
}
