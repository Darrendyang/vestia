import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const container = document.getElementById('viewer');
const loading = document.getElementById('loading');
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(34, 1, 0.1, 100);
camera.position.set(3.4, 2.05, 5.2);
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.15;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
container.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.target.set(0, 1.45, 0);
controls.enableDamping = true;
controls.dampingFactor = 0.06;
controls.minDistance = 2.6;
controls.maxDistance = 8;
controls.minPolarAngle = Math.PI * 0.18;
controls.maxPolarAngle = Math.PI * 0.72;
controls.autoRotate = false;
controls.autoRotateSpeed = 0.65;
controls.update();

scene.add(new THREE.HemisphereLight(0xc9e8ff, 0x263128, 2.1));
const keyLight = new THREE.DirectionalLight(0xffead7, 3.2);
keyLight.position.set(3, 5, 4);
keyLight.castShadow = true;
keyLight.shadow.mapSize.set(1024, 1024);
scene.add(keyLight);
const rimLight = new THREE.DirectionalLight(0x8ef2d0, 2.0);
rimLight.position.set(-4, 3, -3);
scene.add(rimLight);
const warmLight = new THREE.PointLight(0xf2a68d, 18, 12);
warmLight.position.set(-3, 1.5, 2.5);
scene.add(warmLight);

const ground = new THREE.Mesh(
  new THREE.CircleGeometry(2.25, 64),
  new THREE.MeshStandardMaterial({ color: 0x172c30, roughness: 0.92, metalness: 0.05 }),
);
ground.rotation.x = -Math.PI / 2;
ground.receiveShadow = true;
scene.add(ground);
const ring = new THREE.Mesh(
  new THREE.RingGeometry(1.72, 1.75, 64),
  new THREE.MeshBasicMaterial({ color: 0x8ef2d0, transparent: true, opacity: 0.24, side: THREE.DoubleSide }),
);
ring.rotation.x = -Math.PI / 2;
ring.position.y = 0.004;
scene.add(ring);

const avatar = new THREE.Group();
scene.add(avatar);
const garments = {};
let currentGarment = null;
let currentMaterial = null;

function fabric(color) {
  return new THREE.MeshPhysicalMaterial({
    color,
    roughness: 0.76,
    metalness: 0.02,
    sheen: 0.65,
    sheenRoughness: 0.82,
    side: THREE.DoubleSide,
  });
}

function clothMesh(geometry, material, position, scale = [1, 1, 1]) {
  const mesh = new THREE.Mesh(geometry, material);
  mesh.position.set(...position);
  mesh.scale.set(...scale);
  mesh.castShadow = true;
  mesh.receiveShadow = true;
  return mesh;
}

function createJacket() {
  const group = new THREE.Group();
  const material = fabric(0xb38a62);
  group.add(clothMesh(new THREE.CylinderGeometry(0.40, 0.47, 0.98, 40, 1, true), material, [0, 1.72, 0], [1, 1, 0.76]));
  const left = clothMesh(new THREE.CylinderGeometry(0.13, 0.105, 0.82, 20), material, [-0.48, 1.76, 0]);
  left.rotation.z = -0.24;
  group.add(left);
  const right = clothMesh(new THREE.CylinderGeometry(0.13, 0.105, 0.82, 20), material, [0.48, 1.76, 0]);
  right.rotation.z = 0.24;
  group.add(right);
  group.add(clothMesh(new THREE.BoxGeometry(0.018, 0.88, 0.018), fabric(0x4b3c32), [0, 1.7, 0.36]));
  const belt = clothMesh(new THREE.TorusGeometry(0.42, 0.025, 10, 40), fabric(0x6d503b), [0, 1.48, 0], [1, 1, 0.76]);
  belt.rotation.x = Math.PI / 2;
  group.add(belt);
  group.userData.material = material;
  return group;
}

function createShirt() {
  const group = new THREE.Group();
  const material = fabric(0x5879a8);
  group.add(clothMesh(new THREE.CylinderGeometry(0.35, 0.41, 0.78, 40, 1, true), material, [0, 1.85, 0], [1, 1, 0.73]));
  const left = clothMesh(new THREE.CylinderGeometry(0.12, 0.10, 0.52, 20), material, [-0.43, 1.94, 0]);
  left.rotation.z = -0.34;
  group.add(left);
  const right = clothMesh(new THREE.CylinderGeometry(0.12, 0.10, 0.52, 20), material, [0.43, 1.94, 0]);
  right.rotation.z = 0.34;
  group.add(right);
  const stripe = clothMesh(new THREE.TorusGeometry(0.34, 0.018, 8, 40), fabric(0xe8e4dc), [0, 2.20, 0], [1, 1, 0.73]);
  stripe.rotation.x = Math.PI / 2;
  group.add(stripe);
  group.userData.material = material;
  return group;
}

function createDress() {
  const group = new THREE.Group();
  const material = fabric(0xb52e46);
  group.add(clothMesh(new THREE.CylinderGeometry(0.32, 0.76, 1.65, 48, 1, true), material, [0, 1.12, 0], [1, 1, 0.78]));
  const waist = clothMesh(new THREE.TorusGeometry(0.33, 0.024, 10, 40), fabric(0x6e1f32), [0, 1.78, 0], [1, 1, 0.76]);
  waist.rotation.x = Math.PI / 2;
  group.add(waist);
  group.userData.material = material;
  return group;
}

function selectOutfit(name) {
  if (currentGarment) avatar.remove(currentGarment);
  currentGarment = garments[name];
  currentMaterial = currentGarment.userData.material;
  avatar.add(currentGarment);
  const labels = { commute: '通勤风衣', casual: '休闲上装', date: '礼服裙' };
  document.getElementById('outfit-name').textContent = labels[name];
  document.querySelectorAll('.outfit').forEach(button => button.classList.toggle('active', button.dataset.outfit === name));
}

function resize() {
  const width = container.clientWidth;
  const height = container.clientHeight;
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
  renderer.setSize(width, height, false);
}
new ResizeObserver(resize).observe(container);
resize();

new GLTFLoader().load('../avatar/michelle.glb', gltf => {
  const model = gltf.scene;
  const initialBox = new THREE.Box3().setFromObject(model);
  const initialSize = initialBox.getSize(new THREE.Vector3());
  model.scale.setScalar(3.05 / initialSize.y);
  const box = new THREE.Box3().setFromObject(model);
  const center = box.getCenter(new THREE.Vector3());
  model.position.x -= center.x;
  model.position.z -= center.z;
  model.position.y -= box.min.y;
  model.traverse(node => {
    if (node.isMesh) {
      node.castShadow = true;
      node.receiveShadow = true;
      if (node.material) node.material.roughness = 0.72;
    }
  });
  avatar.add(model);
  garments.commute = createJacket();
  garments.casual = createShirt();
  garments.date = createDress();
  selectOutfit('commute');
  loading.classList.add('done');
}, event => {
  if (event.total > 0) {
    const percent = Math.round(event.loaded / event.total * 100);
    loading.querySelector('span').textContent = `正在加载真实人体模型 ${percent}%`;
  }
}, error => {
  loading.querySelector('span').textContent = `3D 模型加载失败：${error.message || '请检查资源'}`;
  console.error(error);
});

document.querySelectorAll('.outfit').forEach(button => button.addEventListener('click', () => selectOutfit(button.dataset.outfit)));
document.querySelectorAll('.color').forEach(button => button.addEventListener('click', () => {
  if (!currentMaterial) return;
  currentMaterial.color.set(button.dataset.color);
  document.querySelectorAll('.color').forEach(item => item.classList.toggle('active', item === button));
}));
document.getElementById('rotate').addEventListener('click', event => {
  controls.autoRotate = !controls.autoRotate;
  event.currentTarget.classList.toggle('active', controls.autoRotate);
});
document.getElementById('reset').addEventListener('click', () => {
  camera.position.set(3.4, 2.05, 5.2);
  controls.target.set(0, 1.45, 0);
  controls.update();
});
const clock = new THREE.Clock();
function animate() {
  requestAnimationFrame(animate);
  controls.update(clock.getDelta());
  renderer.render(scene, camera);
}
animate();

window.VestiaViewer = { selectOutfit, camera, controls, scene, renderer };
