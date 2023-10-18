import './styles/style.css'
import * as THREE from 'three';
import vertexShader from './shaders/vertex.glsl';
import vertexShaderv6 from './shaders/vertexv6.glsl';
import fragmentShaderv1 from './shaders/fragment.glsl';
import fragmentShaderv2 from './shaders/fragmentv2.glsl';
import fragmentShaderv3 from './shaders/fragmentv3.glsl';
import fragmentShaderv4 from './shaders/fragmentv4.glsl';
import fragmentShaderv5 from './shaders/fragmentv5.glsl';
import fragmentShaderv6 from './shaders/fragmentv6.glsl';



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
            uTime: { value: 0.0 },
            uTexture: { value: null },
            uTextureSize: { value: new THREE.Vector2(sizes.width, sizes.height) },
            uTint: { value: null },
            uResolution: { value: new THREE.Vector2(sizes.width, sizes.height)},
            uCenter: { value: new THREE.Vector2(-1, -1) }, // Initialize to a default value
            uBoundsMax: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
            uBoundsMin: { value: new THREE.Vector2(0, 0) }


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
            vertexShader: vertexShaderv6,
            fragmentShader: fragmentShaderv6,
            uniforms: {
                uTime: { value: 0.0 },
                uTexture: { value: texture },
                uTextureSize: { value: new THREE.Vector2(sizes.width, sizes.height) },
                uTint: { value: new THREE.Vector3(r / 255, g / 255, b / 255)},
                uResolution: { value: new THREE.Vector2(sizes.width, sizes.height) },
                uCenter: { value: new THREE.Vector2(-1, -1) }, // Initialize to a default value
                uBoundsMax: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
                uBoundsMin: { value: new THREE.Vector2(0, 0) }
            }
        });

        cardWrapper.shaderMaterial = shaderMaterial;  // Store it here for access in onMouseEnter and onMouseLeave

        const mesh = new THREE.Mesh(geometry, shaderMaterial);
        scene.add(mesh);

        renderer.render(scene, camera);
    });

    window.addEventListener('mousemove', onMouseMove);

    let xMouse = 0;
    let yMouse = 0;

    function onMouseMove(event) {
        xMouse = event.clientX;
        yMouse = event.clientY;
        updateUniforms();
    }

    function updateUniforms() {
        cardWrappers.forEach((cardWrapper) => {
            const shaderMaterial = cardWrapper.shaderMaterial;
            if (shaderMaterial) {
                shaderMaterial.uniforms.uCenter.value = new THREE.Vector2(xMouse, yMouse);
            }
        });
    }

    // Animation
    const clock = new THREE.Clock();
    const animate = () => {
        requestAnimationFrame(animate);
        const elapsedTime = clock.getElapsedTime();
        shaderMaterial.uniforms.uTime.value = elapsedTime;
        // shaderMaterial.uniforms.uCenter.value = new THREE.Vector2(xMouse, yMouse);
        renderer.render(scene, camera);
    };
    animate();
});
