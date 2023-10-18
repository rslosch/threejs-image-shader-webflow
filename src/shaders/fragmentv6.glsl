#ifdef GL_ES
precision highp float;
#endif

uniform float uTime;
uniform vec3 uTint;
uniform float uTransition;
uniform float uFrequency;
uniform sampler2D uTexture;
uniform vec2 uTextureSize;
uniform vec2 uCenter;
uniform vec2 uBoundsMin;
uniform vec2 uBoundsMax;

varying vec2 vUv;

const float width = 1.0;
const float power = 6.0;
const float spread = 0.1;

const float PI = 3.14159265359;

float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 ripple(vec3 t, vec3 width) {
    vec3 ft = fract(t);
    return smoothstep(vec3(0.0), width / 2.0, ft) * smoothstep(width, width / 2.0, ft);
}

mat3 rotationMatrix(vec3 axis, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    vec3 as = axis * s;
    mat3 p = mat3(axis.x * axis, axis.y * axis, axis.z * axis);
    mat3 q = mat3(c, -as.z, as.y, as.z, c, -as.x, -as.y, as.x, c);
    return p * oc + q;
}

vec3 mixRotate(vec3 a, vec3 b, vec3 perp, float t) {
    vec3 origin = a + (b - a) * .5;
    vec3 a0 = a - origin;
    vec3 b0 = b - origin;
    vec3 axis = cross(normalize(a0), normalize(perp));
    float angle = t * PI;
    return abs(origin + rotationMatrix(axis, angle) * a0);
}

vec2 cover(vec2 p, vec2 dest, vec2 src) {
    float scale = max( dest.x / src.x, dest.y / src.y );
    vec2 scaledSize = src * scale;
    vec2 coord = p / scaledSize;
    vec2 margin = ( dest - scaledSize ) / 2.;
    return coord - margin / scaledSize;
}

void main() {
    vec2 size = uBoundsMax - uBoundsMin;
    vec2 centerLocal = uCenter - uBoundsMin;
    centerLocal.y = size.y - centerLocal.y;
    
    float mouseDist = length(gl_FragCoord.xy - centerLocal);

    vec2 texCoord = cover(gl_FragCoord.xy, size, uTextureSize);
    texCoord.y = 1.0 - texCoord.y;

    vec3 tex0 = texture2D(uTexture, vUv).rgb;
    vec3 tex1 = texture2D(uTexture, vUv).rgb;

    vec3 c0 = mix(vec3(0.0), uTint, luminance(tex0));
    vec3 c1 = uTint;

    vec3 rgbSpread = vec3(spread, spread * 2.0, spread * 3.0);
    vec3 t = tex1 + (-uTime / 8.0) + mouseDist * .001 + rgbSpread;
    vec3 fac = pow(ripple(t, vec3(1.0)), vec3(power));

    vec3 color = mixRotate(c0, c1, tex0, mix(fac.x, 1.0, uTransition));

    gl_FragColor = vec4(color, 1.0);
}
