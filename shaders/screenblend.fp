vec3 color = vec3(-1);

// hsv functions from https://gist.github.com/patriciogonzalezvivo/114c1653de9e3da6e1e3
vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    	float d = q.x - min(q.w, q.y);
    	float e = 1.0e-10;
    	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    vec3 image = texture(InputTexture, TexCoord).rgb;   
	FragColor = vec4(mix(image, min(blendcolor, hsv2rgb(image)), alpha), 1.0);
}
