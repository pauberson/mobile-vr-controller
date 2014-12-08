float twoPI = 6.28318530717959;

vec2 waveCentre = vec2(0, 0);
float waveLength = 400.0;
float amplitude = 50.0;
float phaseDuration = 3.0;

float currentAnimTime = mod(u_time, phaseDuration) / phaseDuration ;
float distFromCentre = distance(_geometry.position.xy, waveCentre);
float normalisedDistance = mod(distFromCentre, waveLength) / waveLength;

_geometry.position.z = amplitude * sin((normalisedDistance - currentAnimTime) * twoPI);
_geometry.normal = vec3(0.0, 1.0, 0.0);