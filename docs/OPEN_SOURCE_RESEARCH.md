# Open-Source Technology Research

## Conclusion

No reviewed GitHub project provides a production-ready, commercially cleared implementation of Vestia's complete wardrobe, Style DNA, avatar, arbitrary-garment 3D try-on, and cross-platform shopping scope.

Vestia therefore combines original business logic with mature infrastructure and carefully gated AI providers.

## Useful components

| Project | Candidate use | Integration position |
|---|---|---|
| PaddleOCR | Chinese order screenshot OCR | Evaluate for private recognition workers |
| rembg | Background removal baseline | Simple flat-lay garment images |
| SAM 2 | Prompt-assisted segmentation | Combine with detection or user guidance |
| pgvector | Wardrobe, style, and product vectors | Default early-stage vector store |
| Three.js / model-viewer | Approved GLB viewing | Isolated Flutter viewer bridge |
| glTF Transform | Asset validation and optimization | 3D asset CI |
| LiteLLM | Model routing and cost controls | Optional community-edition gateway |
| LightFM / Recommenders | Later ranking experiments | Compare against the rule baseline after enough behavior data |

## Research-only or restricted projects

IDM-VTON, OOTDiffusion, and CatVTON are released under CC BY-NC-SA 4.0 according to their repositories. They are not production dependencies unless separate commercial rights are obtained.

SMPL-X has a non-commercial default license. ROMP's Apache-2.0 code license does not clear SMPL body assets. Commercial avatar deployment requires appropriate asset rights or an alternative licensed body model.

InstantMesh can inform coarse-mesh research, but a generated mesh does not include garment patterns, physical sizing, rigging, collision behavior, fabric parameters, or reliable back-side details. It is not a universal production try-on pipeline.

Qwen-Image provides a more permissive candidate route for general image editing. Each exact model version and weight card still requires license archival, and garment/identity quality must pass Vestia's dedicated VTON evaluation.

## Full-application references

OOTDify offers useful references for private buckets, row-level security, signed URLs, honest provider states, and shopping adapter interfaces. It is not a complete production VTON or marketplace implementation and is not used as Vestia's application base.

Other small wardrobe projects provide interaction ideas such as local outfit builders, laundry states, and cost-per-wear reporting. Code without an explicit license is not copied.

## Sources

- https://github.com/yisol/IDM-VTON
- https://github.com/levihsu/OOTDiffusion
- https://github.com/Zheng-Chong/CatVTON
- https://github.com/QwenLM/Qwen-Image
- https://github.com/vchoutas/smplx
- https://github.com/Arthur151/ROMP
- https://github.com/TencentARC/InstantMesh
- https://github.com/PaddlePaddle/PaddleOCR
- https://github.com/facebookresearch/sam2
- https://github.com/pgvector/pgvector
- https://github.com/onetwothird/OOTDify

See the Chinese research document for the dated repository and license snapshots.
