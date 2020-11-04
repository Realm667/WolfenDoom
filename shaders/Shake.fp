// From old video shader by jmpep, ported to GZDoom by Nash Muhandes
// Modified for WolfenDoom: Blade of Agony by Kevin "Talon1024" Caccamo
// https://www.shadertoy.com/view/Xdl3D8
// License: See comments section for the shader
/*
heliumsoft, 2017-08-29
Very nice old TV effect.
Can i use your code in commercial project?

jmpep, 2017-08-29
@heliumsoft Yes, of course, you can use it for whatever you like :)
*/

#define MAX_SHAKE 0.002
#define FREQUENCY 15.0

vec2 uv;

float rand(vec2 co)
{
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float rand(float c)
{
	return rand(vec2(c, 1.0));
}

void main()
{
	uv = TexCoord;

	// Set frequency of global effect to 20 variations per second
	float t = float(int(timer * FREQUENCY));

	// Get some image movement
	vec2 suv = uv + speed * MAX_SHAKE * vec2(rand(t), rand(t + 23.0));

	// Get the image
	vec3 image = texture(InputTexture, vec2(suv.x, suv.y)).xyz;

	// Show the image modulated by the defects
	FragColor.xyz = image;
}
