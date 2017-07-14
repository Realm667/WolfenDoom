void main() {
	vec2 newCoord = TexCoord;
	// scale the coord around (0.5, 0.5)
	newCoord -= 0.5;
	newCoord *= zoomFactor;
	newCoord += 0.5;
	// if the pixel isn't on screen, return black
	if (newCoord.x > 0 && newCoord.x < 1 && newCoord.y > 0 && newCoord.y < 1)
		FragColor = texture(InputTexture, newCoord);
	else FragColor = vec4(0, 0, 0, 0);
}