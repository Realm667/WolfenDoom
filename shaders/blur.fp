// Modified by AFADoomer from https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5

void main() {
	vec4 sum = vec4(0.0);
	float radius = 0.0001 * min(amount, 125);

	float hstep = 0.7;
	float vstep = 1.0;

	sum += texture(InputTexture, vec2(TexCoord.x - 2.0 * radius * hstep, TexCoord.y - 2.0 * radius * vstep)) * 0.0162162162 * alpha;
	sum += texture(InputTexture, vec2(TexCoord.x - 1.5 * radius * hstep, TexCoord.y - 1.5 * radius * vstep)) * 0.0540540541 * alpha;
	sum += texture(InputTexture, vec2(TexCoord.x - 1.0 * radius * hstep, TexCoord.y - 1.0 * radius * vstep)) * 0.1216216216 * alpha;
	sum += texture(InputTexture, vec2(TexCoord.x - 0.5 * radius * hstep, TexCoord.y - 0.5 * radius * vstep)) * 0.1945945946 * alpha;
	
	sum += texture(InputTexture, vec2(TexCoord.x, TexCoord.y)) * 0.2270270270;
	
	sum += texture(InputTexture, vec2(TexCoord.x + 0.5 * radius * hstep, TexCoord.y + 0.5 * radius * vstep)) * 0.1945945946 * alpha;
	sum += texture(InputTexture, vec2(TexCoord.x + 1.0 * radius * hstep, TexCoord.y + 1.0 * radius * vstep)) * 0.1216216216 * alpha;
	sum += texture(InputTexture, vec2(TexCoord.x + 1.5 * radius * hstep, TexCoord.y + 1.5 * radius * vstep)) * 0.0540540541 * alpha;
	sum += texture(InputTexture, vec2(TexCoord.x + 2.0 * radius * hstep, TexCoord.y + 2.0 * radius * vstep)) * 0.0162162162 * alpha;

	sum /= 0.2270270270 + 0.772972973 * alpha;

	FragColor = vec4(sum.rgb, 1.0);
}