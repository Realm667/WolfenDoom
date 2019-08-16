// Pixelated Film Grain Shader
// Ported by Nash Muhandes, from the following sources:
// https://www.shadertoy.com/view/Mdj3zd
// https://gamedev.stackexchange.com/questions/164607/how-to-implement-a-pixelated-screen-transition-shader

float rand(vec2 co)
{
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
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
