precision mediump float;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec3 uTint;

varying vec2 vUv;

void main(){
    // Fetch the original texture color
    vec4 texColor = texture2D(uTexture, vUv);

    // Calculate the luminance of the pixel using dot product
    float luminance = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
    // vec3 luminanceWeights = mix(vec3(luminance), uTint, 0.5); // Add tint on the weights.
    vec3 luminanceWeights = vec3(luminance);

// WAVE
    float wave = 0.25;
    float freq = 1.0;
    float amp = 0.1;
    for(int i = 0; i < 10; ++i) {  // 10 iterations, adjust as needed
        float direction = -vUv.x * vUv.y * float(i) * 0.1;  // Modify direction based on iteration
        wave += abs(sin((uTime/3.0 + direction * 3.141516) * freq) * amp) * (1.0 - luminance);
    }

    // // Modulate the wave based on luminance
    float modulatedWave = wave * (1.0 - luminance);

    // Blend the luminance color with the tint
    vec3 tintedLuminance = mix(luminanceWeights, uTint, modulatedWave);

// GLOW
    // Apply the modulated wave to the luminance
    vec3 luminanceWave = tintedLuminance + modulatedWave;
    // Mix the original color with the new color based on the modulated wave
    vec3 finalColor = mix(texColor.rgb, luminanceWave-0.6, modulatedWave);

    // Set the fragment color
    gl_FragColor = vec4(finalColor, 1.0);
    // gl_FragColor = vec4(vec3(modulatedWave), 1.0);
    // gl_FragColor = vec4(vec3(wave), 1.0);
}