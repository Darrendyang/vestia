# Asset Licenses and Provenance

## Demo clothing photography

The eight demo wardrobe photographs in `apps/mobile/assets/clothes/` are sourced from Unsplash and bundled locally so the demo does not depend on hotlinked images or placeholder icons.

These photographs are **not** licensed under Vestia's Apache-2.0 license. Their use and distribution are governed by the [Unsplash License](https://unsplash.com/license). They are used as demonstration content, not as AI-generated garments or user photos.

| Local asset | Source image |
|---|---|
| `blue-pattern-shirt.jpg` | https://images.unsplash.com/photo-1596755094514-f87e34085b2c |
| `white-graphic-tee.jpg` | https://images.unsplash.com/photo-1576566588028-4147f3842f27 |
| `pink-trousers.jpg` | https://images.unsplash.com/photo-1594633312681-425c7b97ccd1 |
| `blue-jeans.jpg` | https://images.unsplash.com/photo-1542272604-787c3835535d |
| `beige-trench.jpg` | https://images.unsplash.com/photo-1539533018447-63fcce2678e3 |
| `brown-sneakers.jpg` | https://images.unsplash.com/photo-1549298916-b41d501d3772 |
| `red-dress.jpg` | https://images.unsplash.com/photo-1595777457583-95e059d581b8 |
| `red-canvas-shoes.jpg` | https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77 |

The demo metadata was manually reviewed against the photographs: colors, categories, materials, and display names describe the actual garments. Before replacing any asset, preserve this visual/metadata consistency and record the new source and license.

## Product screenshots

The screenshots and composite showcase images in `docs/images/` are generated from the running Vestia application. They include the demo clothing photographs listed above and are subject to the same third-party asset terms.

## Human portrait and 3D avatar

- `apps/mobile/assets/avatar/avatar-portrait.jpg` is sourced from [Unsplash image `photo-1494790108377-be9c29b29330`](https://images.unsplash.com/photo-1494790108377-be9c29b29330) and is subject to the Unsplash License. It is a demo profile portrait, not an identity claim or a reconstructed user avatar.
- `apps/mobile/assets/avatar/michelle.glb` is the Michelle model distributed in the [three.js examples](https://github.com/mrdoob/three.js/tree/dev/examples/models/gltf). The GLB is used as a clearly labeled demo digital human. Three.js source code is MIT-licensed; model and animation assets may have separate terms and must not be assumed to be covered by Vestia's Apache-2.0 license or the three.js code license.
- The local Three.js modules under `apps/mobile/assets/viewer/` are from the [three.js project](https://github.com/mrdoob/three.js), released under the MIT License.

The current 3D viewer provides real GLB rendering and interchangeable geometric garments. It is not a personalized body scan, a learned VTON result, or a physical fit simulation.
