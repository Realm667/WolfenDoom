//Motion blur shader taken from https://forum.zdoom.org/viewtopic.php?f=103&t=62772
void main()
{
	vec4 C = vec4(0,0,0,0);
	int i;

	for( i = 0; i < samples; i++ )
	{
		vec3 texel = texture( InputTexture, TexCoord + steps * i ).rgb;
		C.rgb += ((blendmode == 1) ? max( C.rgb, texel ) : texel) * increment;
	}
	FragColor = C;
}