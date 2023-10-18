precision mediump float;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec3 uTint;

varying vec2 vUv;

float PI = 3.1415926535897932384626433832795;

// Function to calculate brightness
float calculateBrightness(vec4 color) {
    return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}

// Function to perform Gaussian blur on a texture
vec4 gaussianBlur(sampler2D image, vec2 uv, vec2 resolution, float radius) {
    vec4 color = vec4(0.0);
    vec2 step = 1.0 / resolution;
    float weightSum = 0.0;

    for(int i = -4; i <= 4; ++i) {
        for(int j = -4; j <= 4; ++j) {
            float weight = exp(-(float(i*i + j*j) / (2.0 * radius * radius))) / (2.0 * PI * radius * radius);
            color += texture2D(image, uv + vec2(i, j) * step) * weight;
            weightSum += weight;
        }
    }

    return color / weightSum;
}

void main() {

    vec4 texColor = texture2D(uTexture, vUv);

// 1. TINT
    // overlay tint blending
    vec4 blendedColor;
    blendedColor.r = (texColor.r < 0.5) ? (2.0 * texColor.r * uTint.r) : (1.0 - 2.0 * (1.0 - texColor.r) * (1.0 - uTint.r));
    blendedColor.g = (texColor.g < 0.5) ? (2.0 * texColor.g * uTint.g) : (1.0 - 2.0 * (1.0 - texColor.g) * (1.0 - uTint.g));
    blendedColor.b = (texColor.b < 0.5) ? (2.0 * texColor.b * uTint.b) : (1.0 - 2.0 * (1.0 - texColor.b) * (1.0 - uTint.b));
    blendedColor.a = 1.0;

// 2. BLOOM
    // 1. Brightness Thresholding
    float brightness = calculateBrightness(texColor);
    // time threshold for bloom
    // float threshold = 0.5 + 0.5 * sin(uTime); // 0 - 1
    float period = 6.0; // Time it takes to complete one cycle from 0 to 1 and back to 0
    float modTime = mod(uTime, 2.0 * period); // Time within the current cycle
    float threshold = 1.0 - abs(1.0 - 2.0 * fract(modTime / (2.0 * period))); // 0-1-0

    // float threshold = 0.5;
    vec4 brightColor = brightness > threshold ? blendedColor*1.0 : vec4(0.0,0.0,0.0,1.0);

    // 2. Blurring
    float blurRadius = 0.0001; // Set the radius of the Gaussian blur
    vec4 blurredColor = gaussianBlur(uTexture, vUv, uResolution, blurRadius);

    // 3. Combining
    vec4 finalColor = brightColor + blurredColor; // Simple additive blending

    gl_FragColor = finalColor;
}