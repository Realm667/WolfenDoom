//this is a simple tweaked variant of the original shader that had also all other PBR and Normal materials calcs included, which we don't need
#define RELIEF_PARALLAX

mat3 GetTBN();
vec2 ParallaxMap(mat3 tbn);

void SetupMaterial(inout Material material)
{
    mat3 tbn = GetTBN();
    vec2 texCoord = ParallaxMap(tbn);

    material.Base = getTexel(texCoord);
    material.Normal = normalize(vWorldNormal.xyz);
    material.Bright = texture(brighttexture, texCoord); //force the check for brightmaps, otherwise doesn't work - ozy81
}

// Tangent/bitangent/normal space to world space transform matrix
mat3 GetTBN()
{
    vec3 n = normalize(vWorldNormal.xyz);
    vec3 p = pixelpos.xyz;
    vec2 uv = vTexCoord.st;

    // get edge vectors of the pixel triangle
    vec3 dp1 = dFdx(p);
    vec3 dp2 = dFdy(p);
    vec2 duv1 = dFdx(uv);
    vec2 duv2 = dFdy(uv);

    // solve the linear system
    vec3 dp2perp = cross(n, dp2); // cross(dp2, n);
    vec3 dp1perp = cross(dp1, n); // cross(n, dp1);
    vec3 t = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 b = dp2perp * duv1.y + dp1perp * duv2.y;

    // construct a scale-invariant frame
    float invmax = inversesqrt(max(dot(t,t), dot(b,b)));
    return mat3(t * invmax, b * invmax, n);
}

float GetDisplacementAt(vec2 currentTexCoords)
{
    return 0.55 - texture(displacement, currentTexCoords).r * 1.14;
}

#if defined(NORMAL_PARALLAX)
vec2 ParallaxMap(mat3 tbn)
{
    const float parallaxScale = 0.5;

    // Calculate fragment view direction in tangent space
    mat3 invTBN = transpose(tbn);
    vec3 V = normalize(clamp(0.0, 1.0)(invTBN * (uCameraPos.xyz - pixelpos.xyz));

    vec2 texCoords = vTexCoord.st;
    vec2 p = V.xy / abs(V.z) * GetDisplacementAt(texCoords) * parallaxScale;
    return texCoords - p;
}

#elif defined(RELIEF_PARALLAX)
vec2 ParallaxMap(mat3 tbn)
{
    const float parallaxScale = 0.48;
    const float minLayers = 8.0;
    const float maxLayers = 12.0;

    // Calculate fragment view direction in tangent space
    mat3 invTBN = transpose(tbn);
    vec3 V = normalize(invTBN * (uCameraPos.xyz - pixelpos.xyz));
    vec2 T = vTexCoord.st;

    float numLayers = mix(maxLayers, minLayers, clamp(abs(V.z), 0.0, 1.0)); // clamp is required due to precision loss

    // calculate the size of each layer
    float layerDepth = 1.0 / numLayers;

    // depth of current layer
    float currentLayerDepth = 0.0;

    // the amount to shift the texture coordinates per layer (from vector P)
    vec2 P = V.xy * parallaxScale;
    vec2 deltaTexCoords = P / numLayers;
    vec2 currentTexCoords = T + (P * 0.02);
    float currentDepthMapValue = GetDisplacementAt(currentTexCoords);

    while (currentLayerDepth < currentDepthMapValue)
    {
        // shift texture coordinates along direction of P
        currentTexCoords -= deltaTexCoords;

        // get depthmap value at current texture coordinates
        currentDepthMapValue = GetDisplacementAt(currentTexCoords);

        // get depth of next layer
        currentLayerDepth += layerDepth;
    }

	deltaTexCoords *= 0.5;
	layerDepth *= 0.5;

	currentTexCoords += deltaTexCoords;
	currentLayerDepth -= layerDepth;

	const int _reliefSteps = 8;
	int currentStep = _reliefSteps;
	while (currentStep > 0) {
	float currentGetDisplacementAt = GetDisplacementAt(currentTexCoords);
		deltaTexCoords *= 0.5;
		layerDepth *= 0.5;


		if (currentGetDisplacementAt > currentLayerDepth) {
			currentTexCoords -= deltaTexCoords;
			currentLayerDepth += layerDepth;
		}

		else {
			currentTexCoords += deltaTexCoords;
			currentLayerDepth -= layerDepth;
		}
		currentStep--;
	}

	return currentTexCoords - (P * 0.01);
}
#endif