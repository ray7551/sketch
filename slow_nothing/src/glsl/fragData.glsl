#define PI 3.14159

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uMouse;
uniform float uMorph;
uniform vec2 uGrid;

const int   complexity  = 10;   // More points of color.
const float mouseSpeed  = 0.3;  // control the color changing
const float fixedOffset = 0.7;  // Drives complexity in the amount of curls/cuves.  Zero is a single whirlpool.
const float fluidSpeed  = 0.07; // Drives speed, smaller number will make it slower.
const float baseColor   = 0.6;
const float BLUR        = 0.47;


// more about noise:
// http://thebookofshaders.com/11/
// return a random value between 0.0 and 1.0
float random(float x) {
  return fract(sin(x) * SEED);
}
// return unsigned value between 0.0 and 1.0, which smoothly changed along x
float noise(float x) {
  float i = floor(x);
  float f = fract(x);
  return mix(random(i), random(i + 1.0), smoothstep(0.0, 1.0, f));
}
// return signed value between -1.0 and 1.0
float noiseS(float x) {
  return noise(x) * 2.0 - 1.0;
}

vec4 modeOrigin(vec2 p, float t, float noiseTime, float noiseSTime, float noiseSTime1, float blur) {
  for(int i=1; i <= complexity; i++) {
    p += blur / float(i) * sin(
        float(i) * p.yx + t + PI * vec2(noiseSTime, noiseSTime1))
      + fixedOffset;
  }
  for(int i=1; i <= complexity; i++) {
    p += blur / float(i) * cos(
        float(i) * p.yx + t + PI * vec2(noiseSTime, noiseSTime1))
      + fixedOffset;
  }
  p += uMouse * mouseSpeed;

  vec2 grid = uGrid * 2.0; // set complexity to 0 to debug the grid
  return vec4(
    baseColor * vec3(
      sin(grid * p + vec2(2.0 * noiseSTime, 3.0 * noiseSTime1)),
      sin(p.x + p.y + noiseSTime)
    )
    + baseColor,
    1.0);
}

vec4 modeSlow1(vec2 p, float t, float noiseTime, float noiseSTime, float noiseSTime1, float blur) {
  vec2 temp = t + PI * vec2(noiseSTime, noiseSTime1);
  for(int i=1; i <= complexity; i++) {
    p += blur / float(i) * sin(
        float(i) * p.yx + temp)
      + fixedOffset;
  }
  for(int i=1; i <= complexity; i++) {
    p += blur / float(i) * cos(
        (p.y - p.x) + temp)
      + fixedOffset;
  }
  p += uMouse * mouseSpeed;

  vec2 grid = uGrid * 1.0; // set complexity to 0 to debug the grid
  return vec4(
    baseColor * vec3(
      sin(grid * p + vec2(2.0 * noiseSTime, 3.0 * noiseSTime1)),
      sin(p.x + p.y + noiseSTime)
    )
    + baseColor,
    1.0);
}

vec4 modeSlow2(vec2 p, float t, float noiseTime, float noiseSTime, float noiseSTime1, float blur) {
  vec2 temp = cos((p.y - p.x) + t + PI * vec2(noiseSTime, noiseSTime1));
  for(int i=1; i <= complexity; i++) {
    p += blur / float(i) * sin(t + temp)
      + fixedOffset;
  }
  p += uMouse * mouseSpeed;

  vec2 grid = uGrid * 2.0; // set complexity to 0 to debug the grid
  return vec4(
    baseColor * vec3(
      sin(grid * p + vec2(2.0 * noiseSTime, 3.0 * noiseSTime1)),
      sin(p.x + p.y + noiseSTime)
    )
    + baseColor,
    1.0);
}

vec4 modeWater(vec2 p, float t, float noiseTime, float noiseSTime, float noiseSTime1, float blur) {
  const float color_intensity = 0.7;
  for(int i=1; i <= complexity; i++) {
    p += blur / float(i) * vec2(
      sin(float(i) * p.y + t*fluidSpeed + PI * noiseTime),
      sin(float(i) * p.x + t*fluidSpeed + PI * noiseTime)
    )
    + uMouse * mouseSpeed * 0.05 + fixedOffset;
  }
  return vec4(
    color_intensity * sin(uGrid.x * p.x + noiseSTime) + color_intensity,
    color_intensity * sin(uGrid.y * p.y + noiseSTime1) + color_intensity,
    color_intensity * sin(p.x + p.y + t) + color_intensity,
    1.0);
}

void main() {
  vec2 p = (2.0 * gl_FragCoord.xy - uResolution) / min(uResolution.x, uResolution.y) * 0.7;
  float t = uTime * fluidSpeed + uMorph;
  float noiseTime = noise(t);
  float noiseSTime = noiseS(t);
  float noiseSTime1 = noiseS(t + 1.0);
  float blur = (BLUR + 0.14 * noiseSTime);

  gl_FragData[0] = MODE0(p, t, noiseTime, noiseSTime, noiseSTime1, blur);
  gl_FragData[1] = MODE1(p, t, noiseTime, noiseSTime, noiseSTime1, blur);
}