// Modified by AFADoomer from http://www.blog.nathanhaze.com/glsl-desert-mirageheat-wave-effect/
// and https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5

const float stepsize = 0.000015; // The amplitude of the distortion waves
const float stepscale = 2.5; // The scale of the effect (this controls the number of repetitions of the pattern that are crammed into screen space, so higher numbers means more repetitions, so smaller effect scale)
const float timescale = 0.15; // The speed of the effect (modifies timer, so 0.5 means every two timer ticks, 2.0 means every half timer tick, etc.)
const float bluramt = 25; // The max amount of blur to give the scene

float random() 
{
	vec2 co = vec2(mod(timer, 1000.0) / 1000.0, 1.0);
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); // This is a commonly used pseudo-random number algortihm for GLSL
}

void main()
{
	// Max amount is 128
	float amt = clamp(amount, 0.0, 128.0);

	// Calculate timer-based modifier value that accounts for stepsize
	float step = stepsize * 8750000.0; // No idea why I'm using this modifier value, but it works.  Trial and error...  
	float t = step + mod(radians(timer * timescale), radians(90.0)) * step;

	// Re-center the coordinates so that the edges of the screen actually distort equally
	float coordx = mod(timer * timescale, 750.0) / 1000.0 - abs(TexCoord.x - 0.5);

	vec2 offset = vec2(0.0);
	offset.x = stepsize * amt * sin(stepscale * TexCoord.y) * sin(t * mod(coordx, 1.0));
	offset.y = stepsize * amt * sin(stepscale * TexCoord.x) * sin(t * TexCoord.y);

	// Add blur effect
	float radius = 0.0001 * min(amt, bluramt); // Scale blur up with shader control inventory amount, up to a max of bluramt.
	float hstep = 0.7;
	float vstep = 1.0;

	vec4 sum = vec4(0.0);
	sum += texture(InputTexture, vec2(TexCoord.x - 2.0 * radius * hstep, TexCoord.y - 2.0 * radius * vstep) + offset) * 0.0162162162;
	sum += texture(InputTexture, vec2(TexCoord.x - 1.5 * radius * hstep, TexCoord.y - 1.5 * radius * vstep) + offset) * 0.0540540541;
	sum += texture(InputTexture, vec2(TexCoord.x - 1.0 * radius * hstep, TexCoord.y - 1.0 * radius * vstep) + offset) * 0.1216216216;
	sum += texture(InputTexture, vec2(TexCoord.x - 0.5 * radius * hstep, TexCoord.y - 0.5 * radius * vstep) + offset) * 0.1945945946;
	
	sum += texture(InputTexture, vec2(TexCoord.x, TexCoord.y) + offset) * 0.2270270270;
	
	sum += texture(InputTexture, vec2(TexCoord.x + 0.5 * radius * hstep, TexCoord.y + 0.5 * radius * vstep) + offset) * 0.1945945946;
	sum += texture(InputTexture, vec2(TexCoord.x + 1.0 * radius * hstep, TexCoord.y + 1.0 * radius * vstep) + offset) * 0.1216216216;
	sum += texture(InputTexture, vec2(TexCoord.x + 1.5 * radius * hstep, TexCoord.y + 1.5 * radius * vstep) + offset) * 0.0540540541;
	sum += texture(InputTexture, vec2(TexCoord.x + 2.0 * radius * hstep, TexCoord.y + 2.0 * radius * vstep) + offset) * 0.0162162162;

	sum /= 0.2270270270 + 0.772972973;

	FragColor = vec4(sum.rgb, 1.0);
}