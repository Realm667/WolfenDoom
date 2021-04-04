const float pi = 3.14159265358979323846;

void main()
{
	vec4 base = texture(InputTexture, TexCoord);

	if (alpha <= 0.0) { FragColor = base; return; }

	float tcos = cos(timer / 50.);
	float tsin = sin(timer / 50.);

	vec2 samplecoords;

	samplecoords = vec2(TexCoord.x + tcos * 0.05, TexCoord.y + tsin * 0.05);
	vec4 sample1a = texture(InputTexture, samplecoords);

	samplecoords = vec2(TexCoord.x - tcos * 0.05, TexCoord.y - tsin * 0.05);
	vec4 sample1b = texture(InputTexture, samplecoords);

	samplecoords = vec2(TexCoord.x + tsin * 0.1, TexCoord.y + tcos * 0.1);
	vec4 sample2a = texture(InputTexture, samplecoords);

	samplecoords = vec2(TexCoord.x - tsin * 0.1, TexCoord.y - tcos * 0.1);
	vec4 sample2b = texture(InputTexture, samplecoords);

	vec3 sample1 = mix(sample1a.rgb, sample1b.rgb, 0.5);
	vec3 sample2 = mix(sample2a.rgb, sample2b.rgb, 0.5);

	vec3 samples = mix(sample1.rgb, sample2.rgb, 0.2);

	FragColor = vec4(mix(base.rgb, samples, alpha), 1.0);
}