uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec3 uTint;
uniform float uSpeed; // Speed of the sine wave
uniform float uSpan;  // Span of the sine wave

varying vec2 vUv;

void main(){
      // Fetch the original texture color
    vec4 texColor = texture2D(uTexture, vUv);

    // Calculate the luminance of the pixel using dot product
    float luminance = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 luminanceWeights = vec3(luminance);

// WAVE METHOD 1
    // // Create a spatial sine wave based on time and UV coordinates
    // float freq = 1.0;
    // float amp = 2.0;
    // float direction = -vUv.x * vUv.y;
    // float wave = 1. + abs(sin((uTime + (direction) * 3.141516) * freq) * amp);

// WAVE METHOD 2
    float wave = 0.25;
    float freq = 1.0;
    float amp = 0.15;
    // Simulate recursive-like behavior
    for(int i = 0; i < 10; ++i) {  // 10 iterations, adjust as needed
        float direction = -vUv.x * vUv.y * float(i) * 0.1;  // Modify direction based on iteration
        wave += abs(sin((uTime/1.5 + direction * 3.141516) * freq) * amp) * (1.0 - luminance);
    }

    // // Modulate the wave based on luminance
    float modulatedWave = wave * (1.0 - luminance);

    // Blend the luminance color with the tint
    vec3 tintedLuminance = mix(luminanceWeights, uTint, modulatedWave);

// GLOW METHOD 1
    // // Apply the modulated wave to the luminance
    // vec3 luminanceWave = tintedLuminance + modulatedWave;
    // // Mix the original color with the new color based on the modulated wave
    // vec3 finalColor = mix(texColor.rgb, luminanceWave - 0.8, modulatedWave);

// GLOW METHOD 2
    // Increase brightness based on the modulated wave
    vec3 brightColor = texColor.rgb + vec3(0.5) * modulatedWave;
    // Increase saturation
    vec3 saturatedColor = mix(tintedLuminance, brightColor, 0.5);
    // vec3 saturatedColor = mix(vec3(luminance), brightColor, 0.5);
    // Mix the original color with the glow color based on the modulated wave
    vec3 finalColor = mix(texColor.rgb, saturatedColor, modulatedWave);
    // Apply the tint (again) to the final color
    finalColor = mix(finalColor, uTint, 0.1);  // 0.2 is the tint intensity, adjust as needed

    // Set the fragment color
    gl_FragColor = vec4(finalColor, 1.0);
    // gl_FragColor = vec4(vec3(modulatedWave), 1.0);
    // gl_FragColor = vec4(vec3(wave), 1.0);

}