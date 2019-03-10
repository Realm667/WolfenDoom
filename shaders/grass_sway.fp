//mxd. Simple grass sway shader
uniform float timer;
const float pi = 3.14159265358979323846;
const float sway_ammount = 0.05;

vec4 Process(vec4 color)
{
	vec2 t = gl_TexCoord[0].st;
	t.x += sin(pi * 0.5 * (t.y + timer * 0.5)) * sway_ammount * (1.0 - t.y);
	return getTexel(t) * color;
}