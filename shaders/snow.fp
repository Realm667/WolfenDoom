// Random function from https://thebookofshaders.com/10/
float random (vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// Modified by AFADoomer from https://www.shadertoy.com/view/XlBGzm
// Original 'Midnight Snow' shader by RavenWorks - https://www.shadertoy.com/user/RavenWorks

const float PI =3.141592;

float obj_ball(vec3 p, vec3 center, float radius){
	return length(p-center)-radius;
}
float obj_cylinder(vec3 p, vec3 center, vec2 size, float roundness){
	vec3 tp = p-center;
	vec2 d = abs(vec2(length(tp.yz),tp.x)) - size;
	return min(max(d.x,d.y)+roundness,0.0) + length(max(d,0.0))-roundness;
}
float obj_planeY(vec3 p, float planeY){
	return p.y-planeY;
}
float obj_roundline( vec3 p, vec3 a, vec3 b, float r ){
	vec3 pa = p - a, ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h ) - r;
}
float obj_box(vec3 p, vec3 center, vec3 size, float roundness){
	vec3 d = abs(p-center) - (size-roundness);
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)) - roundness;
}

float maxd = 256.0; //Max depth
float nearestD = maxd;
vec3 color = texture(InputTexture, TexCoord).rgb;

float flakeDistance(vec3 p)
{
 	float snowPush = timer / 25.0;

	p.x += snowPush * -10.0;
	p.y += snowPush * 1.5;
	p.z += snowPush * -0.25;

	const float modDist = 4.0;

	float stepX = floor(p.x/modDist);
	float stepY = floor(p.y/modDist);
	float stepZ = floor(p.z/modDist);

	vec3 flakeP = vec3(
		mod(p.x,modDist),
		mod(p.y,modDist),
		mod(p.z,modDist)
	);

	vec3 flakePos = vec3(modDist*0.5);

	flakePos.x += sin(snowPush+stepY*1.0)*(2.0/5.0)*modDist;
	flakePos.y += sin(snowPush+stepZ*1.3)*(2.0/5.0)*modDist;
	flakePos.z += sin(snowPush+stepX*1.7)*(2.0/5.0)*modDist;

	return obj_cylinder(flakeP, flakePos, vec2(size / 200.0, size / 10.0) * random(TexCoord), (size / 200.0) * random(TexCoord));
}


void generatesnow(out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir)
{
	vec3 scrCoord = fragRayOri;
	vec3 curCameraRayUnit = fragRayDir;
	vec3 p = scrCoord;

	float f=1.0;
	float d=0.01;
	const vec3 flakeE=vec3(0.007,0,0);

	for(int i = 0; i < maxparticles; i++)
	{
		if ((abs(d) < .001) || (f > maxd)) break;

		f += d * (16.0 / maxparticles);
		p=scrCoord + curCameraRayUnit*f;
		d = flakeDistance(p);
	}
	
	if (f < nearestD && abs(d)<0.001)
	{
		nearestD = f;

		float distFade = max(0.0, 1.0 - (nearestD / 20.0));
		color += mix(vec3(0.0, 0.0, 0.0), particlecolor, distFade * alpha);
	}

	fragColor = vec4(color, 1.0);
}

void main()
{
	float adjustedangle = (-angle / 360.);
	float adjustedpitch = (pitch / 90.);

	float camLookX = PI * adjustedangle * 2;
	float camLookY = PI * adjustedpitch / 2;

	float vertFov = 50.0 * fov / 90.0;
	float horizFov = fov;
	vec4 fovAngsMono = vec4(horizFov/2.0, horizFov/2.0, vertFov/2.0, vertFov/2.0);

	vec2 fragFrac = TexCoord;

	vec4 fovAngs = fovAngsMono;

	vec3 cameraRight = vec3(cos(camLookX),0.0,sin(camLookX));
	vec3 cameraFwd = vec3(cos(camLookX+PI*0.5)*cos(camLookY),sin(camLookY),sin(camLookX+PI*0.5)*cos(camLookY));
	vec3 cameraUp = -cross(cameraRight,cameraFwd);
	cameraFwd *= -1.0;

	// position
	vec3 cameraPos = vec3(-position.y, position.z, -position.x) / 25.0;

	float fovL = -fovAngs.x/180.0*PI;
	float fovR =  fovAngs.y/180.0*PI;
	float fovU = -fovAngs.z/180.0*PI;
	float fovD =  fovAngs.w/180.0*PI;

	float fovMiddleX = (fovR + fovL) * 0.5;
	float fovMiddleY = (fovU + fovD) * 0.5;
	float fovHalfX = (fovR - fovL) * 0.5;
	float fovHalfY = (fovD - fovU) * 0.5;

	float scrWorldHalfX = sin(fovHalfX)/sin(PI*0.5 - fovHalfX);
	float scrWorldHalfY = sin(fovHalfY)/sin(PI*0.5 - fovHalfY);

	// determine screen plane size from FOV values, then interpolate to find current pixel's world coord

	vec2 vPos = fragFrac;//0 to 1
	vPos.x -= (-fovL/(fovHalfX*2.0));
	vPos.y -= (-fovU/(fovHalfY*2.0));

	vec3 screenPlaneCenter = cameraPos+cameraFwd;
	vec3 scrCoord = screenPlaneCenter + vPos.x*cameraRight*scrWorldHalfX*2.0 + vPos.y*cameraUp*scrWorldHalfY*2.0;
	vec3 curCameraRayUnit = normalize(scrCoord-cameraPos);

	generatesnow(FragColor, TexCoord, scrCoord, curCameraRayUnit);
}