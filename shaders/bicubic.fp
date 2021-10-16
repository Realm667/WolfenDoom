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
	ivec2 texSize = textureSize(tex, 0);
	vec2 pixelUv = (floor(TexCoord * texSize) + .5) / texSize;
	vec2 pixelSize = 1. / texSize;

	vec4 nSum = vec4( 0.0, 0.0, 0.0, 0.0 );
	vec4 nDenom = vec4( 0.0, 0.0, 0.0, 0.0 );

	vec2 ab = fract(TexCoord * texSize); // get the decimal part

	for( int m = -1; m <= 2; m++ )
	{
		for( int n =-1; n <= 2; n++)
		{
			vec2 pixelOffset = vec2(m, n);
			vec4 vecData = getTexel(pixelUv + pixelOffset * pixelSize);
			float f  = Triangular( float( m ) - ab[0] );
			vec4 vecCoeff1 = vec4(f);
			float f1 = Triangular ( -( float( n ) - ab[1] ) );
			vec4 vecCoeff2 = vec4(f1);

			nSum = nSum + ( vecData * vecCoeff2 * vecCoeff1  );
			nDenom = nDenom + (( vecCoeff2 * vecCoeff1 ));
		}
	}
	return nSum / nDenom;
}

vec4 Process(vec4 color)
{
	return BiCubic(vTexCoord.st);
}