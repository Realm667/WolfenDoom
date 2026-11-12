//mxd. Simple grass sway shader
uniform float timer;
const float pi = 3.14159265358979323846;
const float sway_ammount = 0.05;

vec4 Process(vec4 color)
{
	vec2 t = gl_TexCoord[0].st;
	t.x += sin(pi * 0.5 * (t.y + timer * 0.5)) * sway_ammount * (1.0 - t.y);
	// Do not filter across opposite sprite edges or repeat the swaying image.
	vec2 size = vec2(textureSize(tex, 0));
	vec2 inset = 0.5 / size;
	vec4 texel = getTexel(clamp(t, inset, vec2(1.0) - inset));
	vec2 border = clamp(min(t, vec2(1.0) - t) * size + 0.5, 0.0, 1.0);
	texel.a *= border.x * border.y;
	return texel * color;
}
