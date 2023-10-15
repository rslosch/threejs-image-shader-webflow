import './styles/style.css'
import * as THREE from 'three'
import vertexShader from './shaders/vertex.glsl'
import fragmentShader from './shaders/fragment.glsl'

// Canvas
const canvas = document.querySelector('.webgl')

// Scene
const scene = new THREE.Scene()

//getBoundingClientRect of canvas parent element
let canvasBox = document.querySelector(".card_wrapper").getBoundingClientRect()

// Sizes
const sizes = {
    width: canvasBox.width,
    height: canvasBox.height
}

// Aspect Ratio of the wrapper
const aspectRatio = sizes.width / sizes.height;

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = canvasBox.width
    sizes.height = canvasBox.height

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
})

// Camera
const camera = new THREE.OrthographicCamera(-aspectRatio, aspectRatio, 1, -1, 0.1, 1000)
camera.position.z = 1
scene.add(camera)

// Shader Material
let shaderMaterial = new THREE.ShaderMaterial({
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
    uniforms: {
        uTexture: { value: null },  // Texture will be set later
        uTint: { value: new THREE.Vector3(76/255, 76/255, 229/255) },
        uTime: { value: 0.0 }
    }
});

// Loader
const textureLoader = new THREE.TextureLoader()

// textureLoader.load('https://uploads-ssl.webflow.com/65297f96bc3e2514c0eb1391/6529b534422fddacbfac9709_img-v1-bw.jpg', (texture) => {
// textureLoader.load('https://uploads-ssl.webflow.com/65297f96bc3e2514c0eb1391/65299343818b1d4d5ce9405c_img-v1.jpg', (texture) => {
// textureLoader.load('https://uploads-ssl.webflow.com/65297f96bc3e2514c0eb1391/652b45279c1f4e8c4121b535_img-v3.jpg', (texture) => {
textureLoader.load('  https://uploads-ssl.webflow.com/65297f96bc3e2514c0eb1391/652b45b529f6f7d9d285744b_img-v4.jpg', (texture) => {
  
    // let geometry;

    // // Aspect Ratio
    // const aspectRatio = sizes.width / sizes.height;

    // // Get the aspect ratio of the image texture
    // const imageAspect = texture.image.width / texture.image.height;
        
    // // Adjust the size of the PlaneGeometry to match the aspect ratio of the image
    // geometry = new THREE.PlaneGeometry(2 * imageAspect, 2);

    let geometry;

    // Get the aspect ratio of the image texture
    const imageAspect = texture.image.width / texture.image.height;

    // Determine which aspect ratio is larger
    if (aspectRatio > imageAspect) {
        // If the aspect ratio of the wrapper is wider than the imageAspect
        const width = 2 * (aspectRatio / imageAspect);
        const height = 2;
        geometry = new THREE.PlaneGeometry(2, height);
    } else {
        // else, set the PlaneGeometry size to match the aspect ratio of the image
        geometry = new THREE.PlaneGeometry(2 * imageAspect, 2);
    }

    shaderMaterial = new THREE.ShaderMaterial({
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
        uniforms: {
            uTime: { value: 0.0 },
            uResolution: { value: new THREE.Vector2(sizes.width, sizes.height) },
            uTexture: {value: texture}, // Pass the loaded texture to the shader
            uTint: { value: new THREE.Vector3(55/255, 255/255, 0/255) },  // Convert RGB to [0, 1] range
            uSpeed: { value: 0.25 },
            uSpan: { value: 8.0 },

        }
    })
    
    // Create and add the mesh to the scene
    const mesh = new THREE.Mesh(geometry, shaderMaterial);
    scene.add(mesh);
    
    // Re-render the scene after the texture is loaded
    renderer.render(scene, camera);
});


// Renderer
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.render(scene, camera)

// Create a clock to keep track of the elapsed time
const clock = new THREE.Clock();

// Animation
const animate = () => {
    requestAnimationFrame(animate)

     // Get the elapsed time
     const elapsedTime = clock.getElapsedTime();

     // Update the uTime uniform in the shader material
     shaderMaterial.uniforms.uTime.value = elapsedTime;

    renderer.render(scene, camera)
}
animate()

