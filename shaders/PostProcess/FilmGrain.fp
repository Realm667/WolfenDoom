// Pixelated Film Grain Shader
// Ported by Nash Muhandes, from the following sources:
// https://www.shadertoy.com/view/Mdj3zd
// https://gamedev.stackexchange.com/questions/164607/how-to-implement-a-pixelated-screen-transition-shader
// http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/

float rand(vec2 co)
{
	float a = 12.9898;
	float b = 78.233;
	float c = 43758.5453;
	float dt = dot(co.xy, vec2(a, b));
	float sn = mod(dt, 3.14);
	return fract(sin(sn) * c);
}

void main()
{
	vec2 uv = TexCoord;
	vec2 texSize = textureSize(InputTexture, 0);

	float px = texSize.x / pixelSize;
	vec2 newUV = floor(uv * texSize / px) / texSize * px;

	float r = rand(newUV * timer);
	vec4 VI = texture(InputTexture, uv);
	VI = (VI * r) * amount + VI * (1.0 - amount);
	FragColor = vec4(VI);
}
