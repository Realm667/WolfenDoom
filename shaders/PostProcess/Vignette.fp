void main()
{
	vec2 texSize = textureSize(InputTexture, 0);

	vec2 uv = TexCoord;
    uv *=  1.0 - uv.yx;
    float vig = uv.x * uv.y * intensity;
    vig = pow(vig, falloff);

	vig = clamp(vig, 0.0, 1.0);

	vec4 src = texture(InputTexture, TexCoord);
	vec4 c = vec4(src.rgb * vig, 1.0);
    FragColor = vec4(c);
}
