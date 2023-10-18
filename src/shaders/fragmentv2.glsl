precision mediump float;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec3 uTint;

varying vec2 vUv;

void main(){
    vec4 texColor = texture2D(uTexture, vUv);

    float luminance = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
    texColor.rgb = mix(vec3(luminance), texColor.rgb, 0.0); // Fully desaturated
    vec3 luminanceWeights = vec3(luminance);


    // Create a spatial sine wave based on time and UV coordinates
    float freq = 1.0;
    float amp = 1.25;
    float direction = -vUv.x * vUv.y;
    float wave = 1. + abs(sin((uTime/2.0 + (direction) * 3.141516) * freq) * amp);

    // Modulate the wave based on luminance
    float modulatedWave = wave * (1.0 - luminance);

// GLOW
    // Blend the luminance color with the tint
    vec3 tintedLuminance = mix(luminanceWeights, uTint, modulatedWave);

    // Increase brightness based on the modulated wave
    vec3 brightnessWeight = vec3(0.25);
    vec3 brightColor = texColor.rgb * brightnessWeight;
    // Increase saturation
    vec3 saturatedColor = mix(tintedLuminance, brightColor, 0.75);
    vec3 finalColor = mix(texColor.rgb, saturatedColor, modulatedWave);    
    // Mix the original color with the glow color based on the modulated wave 

    gl_FragColor = vec4(finalColor, 1.0);
    // gl_FragColor = vec4(modulatedWave, 1.0)

}
