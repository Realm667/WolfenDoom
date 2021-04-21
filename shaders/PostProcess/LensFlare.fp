void main()
{
	vec2 texSize = textureSize(InputTexture, 0);

	vec2 uv = TexCoord;
    uv *=  1.0 - uv.yx;

	vec4 src = texture(InputTexture, TexCoord);
	vec4 c = vec4(src.rgb, 1.0);

	vec4 fsrc = texture(InputTexture, TexCoord);
	vec4 fc = vec4(src.rgb, 1.0);
	
	vec2 tc = TexCoord;
	
	float size = 0.5;
	for(int i = 0; i < samples; i ++)
	{
		vec2 tc = TexCoord;
		size += distance;
		tc.x *= 1.0-size;
		tc.x += size/2;
		
		tc.y *= 1.0-size;
		tc.y += size/2;
		
		fsrc = texture(InputTexture, tc);
		fc += vec4(fsrc.rgb, 1.0);
	}

	size = 0.35;
	for(int i = 0; i < samples; i ++)
	{
		vec2 tc = TexCoord;
		size += distance;
		tc.x *= 1.0-size;
		tc.x += size/2;
		
		tc.y *= 1.0-size;
		tc.y += size/2;
		
		fsrc = texture(InputTexture, tc);
		fc += vec4(fsrc.rgb, 1.0);
	}
	
	size = 0.8;
	for(int i = 0; i < samples; i ++)
	{
		vec2 tc = TexCoord;
		size += distance;
		tc.x *= 1.0-size;
		tc.x += size/2;
		
		tc.y *= 1.0-size;
		tc.y += size/2;
		
		fsrc = texture(InputTexture, tc);
		fc += vec4(fsrc.rgb, 1.0);
	}
	
	size = 1.0;
	for(int i = 0; i < samples; i ++)
	{
		vec2 tc = TexCoord;
		size += distance;
		tc.x *= 1.0-size;
		tc.x += size/2;
		
		tc.y *= 1.0-size;
		tc.y += size/2;
		
		fsrc = texture(InputTexture, tc);
		fc += vec4(fsrc.rgb, 1.0);
	}
	
	size = 0.98;
	for(int i = 0; i < samples; i ++)
	{
		size += distance*2;
		vec2 tc = TexCoord;
		tc.x *= size;
		tc.y *= size;
		fsrc = texture(InputTexture, tc);
		fc += vec4(fsrc.rgb, 1.0);
	}
	
	fc = fc/(samples*3);
	fc = fc-threshold;
	fc = clamp(fc,0.0,1000000.0);
	
	FragColor = vec4(c + (fc * vec4(0.8, 0.8, 1.0, 1.0))*amount);
}
