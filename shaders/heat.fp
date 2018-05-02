// Modified by AFADoomer from http://www.blog.nathanhaze.com/glsl-desert-mirageheat-wave-effect/

const float stepsize = 0.000015;
const float stepscale = 200.0;
const float timescale = 1.0;

void main()
{
	float amt = clamp(amount, 0.0, 128.0);

	vec2 offset;

	offset.x =  stepsize * amt * sin(stepscale * TexCoord.x) * sin(timescale * timer);
	offset.y =  stepsize * amt * sin(stepscale / 2 * TexCoord.y) * sin(timescale * timer);

	vec4 color = texture(InputTexture, TexCoord.xy + offset);

	FragColor = vec4(color.rgb, 1.0);
}