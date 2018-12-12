void main()
{
	vec2 texSize = textureSize(InputTexture, 0);

	vec2 uv = TexCoord;
    uv *=  1.0 - uv.yx;

	vec4 src = texture(InputTexture, TexCoord);
	vec4 c = vec4(src.rgb, 1.0);
	
	vec2 tc = TexCoord;
	for(int i = 0; i < samples; i ++)
	{
		tc.x += bx;
		tc.y += by;
		src = texture(InputTexture, tc);
		c += vec4(src.rgb, 1.0);
	}
	
	
    FragColor = vec4(c/(samples+1));
}
