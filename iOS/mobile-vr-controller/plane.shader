float twoPI =   6.2831853071796;
float PI =      3.1415926535898;
float halfPI =  1.5707663267949;

uniform vec2 waveCentre;
uniform float waveLength;
uniform float amplitude;
uniform float phaseDuration;
uniform float fallOffRadius;

uniform float curTime;
uniform float animStartTime;
uniform float animEndTime;
uniform float animFadeTime;

float ease(float t) { return (cos(t*PI) + 1.0) * 0.5;}

#pragma body

float fadeAmount =  ease(1.0 - max(0.0, min(1.0,(animEndTime - curTime) / animFadeTime) )) ;

float currentAnimTime = mod(curTime-animStartTime, phaseDuration) / phaseDuration ;

float distFromCentre = distance(_geometry.position.xy, waveCentre);
float normalisedDistance = mod(distFromCentre, waveLength) / waveLength;
float posInRipple = (normalisedDistance - currentAnimTime)*twoPI;
float sinPos = sin(posInRipple);
float cosPos = cos(posInRipple);

vec2 posFromWaveCentre = _geometry.position.xy - waveCentre;
vec2 normalToCentre = normalize(posFromWaveCentre * -1.0);

float falloff = ease(min(1.0, distFromCentre / fallOffRadius)) * fadeAmount;

_geometry.position.z += -amplitude * falloff * cosPos;

float nx = sinPos * 0.5 * normalToCentre.x * falloff;
float ny = sinPos * 0.5 * normalToCentre.y * falloff;

_geometry.normal = normalize(_geometry.normal + vec3(nx, ny, 1.0-nx-ny));
