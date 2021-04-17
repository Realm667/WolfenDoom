// Modified by AFADoomer from https://www.codeproject.com/Articles/236394/Bi-Cubic-and-Bi-Linear-Interpolation-with-GLSL

// Shader to force bicubic sampling for images
// Used to enable clean rescaling of crosshair overlay graphics even when engine filtering is set to 'None'

float Triangular(float f)
{
	f = f / 2.0;

	if( f < 0.0 ) { return ( f + 1.0 ); }
	else { return ( 1.0 - f ); }

	return 0.0;
}

vec4 BiCubic(vec2 TexCoord)
{
	ivec2 texsize = textureSize(tex, 0);

	float texelSizeX = 1.0 / texsize.x; //size of one texel 
	float texelSizeY = 1.0 / texsize.y; //size of one texel 

	vec4 nSum = vec4( 0.0, 0.0, 0.0, 0.0 );
	vec4 nDenom = vec4( 0.0, 0.0, 0.0, 0.0 );

	float a = fract( TexCoord.x * texsize.x ); // get the decimal part
	float b = fract( TexCoord.y * texsize.y ); // get the decimal part

	vec2 offset = vec2(texelSizeX / 2., texelSizeY / 2.);
	for( int m = -1; m <= 2; m++ )
	{
		for( int n =-1; n <= 2; n++)
		{
			vec4 vecData = getTexel(TexCoord + offset + vec2(offset.x * float( m ), offset.y * float( n )));
			float f  = Triangular( float( m ) - a );
			vec4 vecCoeff1 = vec4(f);
			float f1 = Triangular ( -( float( n ) - b ) );
			vec4 vecCoeff2 = vec4(f1);

			nSum = nSum + ( vecData * vecCoeff2 * vecCoeff1  );
			nDenom = nDenom + (( vecCoeff2 * vecCoeff1 ));
		}
	}
	return nSum / nDenom;
}

vec4 ProcessTexel()
{
	return BiCubic(vTexCoord.st);
}