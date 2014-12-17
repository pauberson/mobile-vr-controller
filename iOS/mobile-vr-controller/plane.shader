float twoPI = 6.28318530717959;

vec2 waveCentre = vec2(0, 0);
float waveLength = 400.0;
float amplitude = 20.0;
float phaseDuration = 3.0;

float currentAnimTime = mod(u_time, phaseDuration) / phaseDuration ;
float distFromCentre = distance(_geometry.position.xy, waveCentre);
float normalisedDistance = mod(distFromCentre, waveLength) / waveLength;
float posInRipple = (normalisedDistance - currentAnimTime)*twoPI;
float sinPos = sin(posInRipple);
float cosPos = cos(posInRipple);

vec2 posFromWaveCentre = _geometry.position.xy - waveCentre;
vec2 normalToCentre = normalize(posFromWaveCentre * -1.0);

//_geometry.position.z += amplitude * sinPos;
//_geometry.normal += vec3(cosPos*0.5*normalToCentre.x, cosPos*0.5*normalToCentre.y, cosPos);