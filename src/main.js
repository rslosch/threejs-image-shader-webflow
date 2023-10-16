import './styles/style.css'
import * as THREE from 'three';
import vertexShader from './shaders/vertex.glsl';
import fragmentShaderv1 from './shaders/fragment.glsl';
import fragmentShaderv2 from './shaders/fragmentv2.glsl';
import fragmentShaderv3 from './shaders/fragmentv3.glsl';

console.log("Hello from main.js");

// Iterate through all cards
const cardWrappers = document.querySelectorAll('.card_wrapper');

cardWrappers.forEach((cardWrapper) => {
    // Canvas
    const canvas = cardWrapper.querySelector('.webgl');

    // Initialize Three.js scene
    const scene = new THREE.Scene();

    // Extract canvas size and aspect ratio
    let canvasBox = cardWrapper.getBoundingClientRect();
    const sizes = {
        width: canvasBox.width,
        height: canvasBox.height
    };
    const aspectRatio = sizes.width / sizes.height;

    // Initialize Orthographic camera
    const camera = new THREE.OrthographicCamera(-aspectRatio, aspectRatio, 1, -1, 0.1, 1000);
    camera.position.z = 1;
    scene.add(camera);

    // Initialize WebGL Renderer
    const renderer = new THREE.WebGLRenderer({
        canvas: canvas
    });
    renderer.setSize(sizes.width, sizes.height);

    // Extract background color
    const cardShaderElement = cardWrapper.querySelector('.card_shader');
    const computedStyle = window.getComputedStyle(cardShaderElement);
    const backgroundColor = computedStyle.backgroundColor;

    // Function to extract RGB from string
    function extractRGB(color) {
        const regex = /rgb\((\d+),\s*(\d+),\s*(\d+)\)/;
        const match = color.match(regex);

        if (match) {
            return {
                r: parseInt(match[1], 10),
                g: parseInt(match[2], 10),
                b: parseInt(match[3], 10)
            };
        } else {
            return null;
        }
    }

    const rgbValues = extractRGB(backgroundColor);
    let r, g, b;
    if (rgbValues) {
        ({ r, g, b } = rgbValues);
    }

    // Extract image texture URL
    const cardShaderImgElement = cardWrapper.querySelector('.card_shader-img');
    const url = cardShaderImgElement.getAttribute('src');

    // INITIALIZE Shader material with uniform properties
    let shaderMaterial = new THREE.ShaderMaterial({
        vertexShader: null,
        fragmentShader: null,
        uniforms: {
            uTexture: { value: null },
            uTint: { value: null },
            uTime: { value: 0.0 }
        }
    });

    // Load the texture
    const textureLoader = new THREE.TextureLoader();
    textureLoader.load(url, (texture) => {

        
        // Get the aspect ratio of the image texture
        const imageAspect = texture.image.width / texture.image.height;
        
        let geometry;
        if (aspectRatio > imageAspect) {
            geometry = new THREE.PlaneGeometry(2 * aspectRatio, 2);
        } else {
            geometry = new THREE.PlaneGeometry(2 * imageAspect, 2);
        }

        shaderMaterial = new THREE.ShaderMaterial({
            vertexShader: vertexShader,
            fragmentShader: fragmentShaderv2,
            uniforms: {
                uTime: { value: 0.0 },
                uResolution: { value: new THREE.Vector2(sizes.width, sizes.height) },
                uTexture: { value: texture },
                uTint: { value: new THREE.Vector3(r / 255, g / 255, b / 255) }
            }
        });

        const mesh = new THREE.Mesh(geometry, shaderMaterial);
        scene.add(mesh);

        renderer.render(scene, camera);
    });

    // Animation
    const clock = new THREE.Clock();
    const animate = () => {
        requestAnimationFrame(animate);
        const elapsedTime = clock.getElapsedTime();
        shaderMaterial.uniforms.uTime.value = elapsedTime;
        renderer.render(scene, camera);
    };
    animate();
});
