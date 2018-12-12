void main()
{
	vec2 texSize = textureSize(InputTexture, 0);

	vec2 uv = TexCoord;
    uv *=  1.0 - uv.yx;

	vec4 src = texture(InputTexture, TexCoord);
	vec4 c = vec4(src.rgb, 1.0);
	
	c += (fract(sin(dot(TexCoord.xy ,vec2(12.9898,78.233)+timer)) * 43758.5453)-0.5)*amount;
	
    FragColor = vec4(c);
}
