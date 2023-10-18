#ifdef GL_ES
precision mediump float;
#endif

attribute vec2 a_position;
// attribute vec2 a_texcoord;

varying vec2 vUv;

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
    // gl_Position = vec4(a_position, 0.0, 1.0);
    // v_texcoord = a_texcoord;
}
