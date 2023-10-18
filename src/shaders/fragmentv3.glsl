precision mediump float;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform vec3 uTint;

varying vec2 vUv;

void main() {
    // DIFFERENCE SHADER

    // Calculate the offset based on vUv
    vec2 offset;
    offset.x = sin(vUv.y * 2.0 * 3.14159 + uTime) * 0.01;  // Example function for offset.x
    offset.y = cos(vUv.y * 2.0 * 3.14159 + uTime) * 0.01;  // Example function for offset.y

    // Sample the color from the texture at the original vUv
    vec4 color1 = texture2D(uTexture, vUv - offset); // Subtract offset, add Offset / 2.0, etc.
    // vec3 tintedColor1 = mix(color1.rgb, uTint, 0.1);

    // Sample another color from the texture at vUv + offset
    vec4 color2 = texture2D(uTexture, vUv + offset);
    // vec3 tintedColor2 = mix(color2.rgb, uTint, 0.15);


    // Calculate the absolute difference between the two colors
    vec4 diffColor = abs(color2 - color1);
    // vec4 diffColor = abs(vec4(tintedColor1, 1.0) - vec4(tintedColor2, 1.0));


    // Mix the tint into the difference color
    vec3 finalColor = mix(diffColor.rgb, uTint, 0.2);

    gl_FragColor = vec4(finalColor.rgb, 1.0);

}