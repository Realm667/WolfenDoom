//mxd. Simple underwater plants sway shader
uniform float timer;
const float pi = 3.14159265358979323846;
const float sway_ammount = 0.1;

vec4 Process(vec4 color)
{
	vec2 t = gl_TexCoord[0].st;
  vec2 offset = vec2(0, 0);
	offset.y = sin(pi * 1.2 * (t.x + timer * 0.125)) * sway_ammount * (1.0 - t.y);
  offset.x = sin(pi * 2.0 * (t.y + timer * 0.125)) * sway_ammount * (1.0 - t.y);
  return getTexel(t + offset) * color;
}