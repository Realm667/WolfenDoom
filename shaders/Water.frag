void main() {
	if (waterFactor > 0) {
		float tau = 6.28318530717958647692;

		vec2 texSize = textureSize(InputTexture, 0);

		// offset the pixel location by this amount, a sine wave to create a wobble effect
		vec2 waterOffset = vec2(waterFactor * sin(tau * TexCoord.y + timer * 0.05), waterFactor * sin(tau * TexCoord.x + timer * 0.05));
		vec2 coord = TexCoord + waterOffset;

		// return black if the resulting coord isn't on screen
		vec4 color = (coord.x > 0 && coord.x < 1 && coord.y > 0 && coord.y < 1) ?
			texture(InputTexture, coord) : vec4(0, 0, 0, 0);

		FragColor = color;
	}
	else FragColor = texture(InputTexture, TexCoord);
}