uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec3 uTint;

varying vec2 vUv;

vec3 generateTargetColor(vec3 baseColor) {
    // Manipulate the baseColor (uTint) to generate a target color
    // Initialize target color with baseColor
    vec3 target = baseColor;
    target.r = mod(target.r + 0.2, 1.0);  // Add 0.2 to Red, wrap around at 1.0
    target.g = mod(target.g * 1.1, 1.0);  // Multiply Green by 1.1, wrap around at 1.0
    target.b = mod(target.b - 0.1, 1.0);  // Subtract 0.1 from Blue, wrap around at 1.0

    // Ensure the components are within [0, 1]
    target = clamp(target, 0.0, 1.0);

    return target;

    return target;
}


void main(){
 // Fetch the original texture color
vec3 texColor = texture2D(uTexture, vUv).rgb;

// Calculate the luminance of the pixel
float luminance = dot(texColor, vec3(0.299, 0.587, 0.114));

// Define the target color for interpolation
vec3 targetColor = generateTargetColor(uTint);

// Calculate the interpolation parameter t using uTime
float t = (sin(uTime) + 1.0) / 2.0;

// Perform linear interpolation between uTint and targetColor
vec3 animatedTint = mix(uTint, targetColor, t);

// Conditionally apply the animated tint based on luminance
// Darker pixels (lower luminance) will receive more of the tint
float blendFactor = 1.0 - luminance;
vec3 blendedColor = mix(texColor, animatedTint, blendFactor);

// Set the fragment color
gl_FragColor = vec4(blendedColor, 1.0);

}

