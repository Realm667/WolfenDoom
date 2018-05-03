// Modified by AFADoomer from http://www.blog.nathanhaze.com/glsl-desert-mirageheat-wave-effect/
// and https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5

const float stepsize = 0.000015;
const float stepscale = 10.0;
const float timescale = 0.5;
const float bluramt = 25;

void main()
{
	float amt = clamp(amount, 0.0, 128.0);
	float t = 131.25 + mod(radians(timer * timescale), radians(90)) * 131.25;

	vec2 offset = vec2(0.0);

	offset.x = stepsize * amt * sin(stepscale * TexCoord.y) * sin(t * TexCoord.x);
	offset.y = stepsize * amt * sin(stepscale / 2 * TexCoord.x) * sin(t * TexCoord.y);

	vec4 sum = vec4(0.0);

	float radius = 0.0001 * min(amt, bluramt);
	float hstep = 0.7;
	float vstep = 1.0;

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