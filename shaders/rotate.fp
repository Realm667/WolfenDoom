//mxd. Rotates given texture around it's center
uniform float timer;
const float pi = 3.14159265358979323846;
const float speed = 0.25;

vec4 Process(vec4 color)
{
	vec2 t = gl_TexCoord[0].st - 0.5;

	float tcos = cos(pi * timer * speed);
	float tsin = sin(pi * timer * speed);

	float tx = mod((tcos * t.x - tsin * t.y) - 0.5, 1.0);
	float ty = mod((tsin * t.x + tcos * t.y) - 0.5, 1.0);

  return getTexel(vec2(tx, ty)) * color;
}