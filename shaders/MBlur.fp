//Motion blur shader taken from https://forum.zdoom.org/viewtopic.php?f=103&t=62772
void main()
{
	vec4 C = vec4(0,0,0,0);
	int i;
	
	if( blendmode == 1 )
	{
		for( i = 0; i < samples; i++ )
		{
			C.rgb += max( C.rgb, texture( InputTexture, TexCoord + steps * i ).rgb ) * increment ;
		}
	}
	else
	{
		for( i = 0; i < samples; i++ )
		{
			C.rgb += texture( InputTexture, TexCoord + steps * i ).rgb * increment ;
		}
	}
	
	FragColor = C ;
}