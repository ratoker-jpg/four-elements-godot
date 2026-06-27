# GODOT-M1A Asset Proof Report

## 1. M0G validation summary

- M0G final status: `READY_FOR_GODOT_M1`
- Wasp GLB exists and re-import validation passed: `assets/models/hulls/wasp/wasp_0123.glb`
- Smoky GLB exists and re-import validation passed: `assets/models/turrets/smoky/smoky_01.glb`
- Wasp UV layers after re-import: `UVMap`
- Smoky UV layers after re-import: `UVMap`
- Animation actions after re-import: none reported
- Wasp marker: `TurretSocket` found in GLB validation and sidecar metadata
- Smoky markers: `TurretPivot` and `MuzzleSocket` found in GLB validation and sidecar metadata
- Wasp M0 faction textures found: cyan, green, yellow, purple
- Smoky M0 faction textures found: cyan, green, yellow, purple
- Material templates found for all copied M0 faction variants

## 2. Files copied into Godot repo

- `assets/models/hulls/wasp/wasp_0123.glb`
- `assets/models/turrets/smoky/smoky_01.glb`
- `assets/textures/hulls/wasp/cyan/m0.png`
- `assets/textures/hulls/wasp/green/m0.png`
- `assets/textures/hulls/wasp/yellow/m0.png`
- `assets/textures/hulls/wasp/purple/m0.png`
- `assets/textures/turrets/smoky/cyan/m0.png`
- `assets/textures/turrets/smoky/green/m0.png`
- `assets/textures/turrets/smoky/yellow/m0.png`
- `assets/textures/turrets/smoky/purple/m0.png`
- `assets/materials/hulls/wasp/cyan_m0.tres`
- `assets/materials/hulls/wasp/green_m0.tres`
- `assets/materials/hulls/wasp/yellow_m0.tres`
- `assets/materials/hulls/wasp/purple_m0.tres`
- `assets/materials/turrets/smoky/cyan_m0.tres`
- `assets/materials/turrets/smoky/green_m0.tres`
- `assets/materials/turrets/smoky/yellow_m0.tres`
- `assets/materials/turrets/smoky/purple_m0.tres`
- `assets/metadata/hulls/wasp_0123.json`
- `assets/metadata/turrets/smoky_01.json`

## 3. Scene created

- `scenes/dev/AssetProof_WaspSmoky.tscn`
- `scripts/dev/asset_proof_wasp_smoky.gd`

The scene is rooted at `Node3D` and contains a camera, directional light, ground plane, debug marker root, and proof label.

## 4. Socket/pivot/muzzle assembly method

The proof script instances the copied Wasp and Smoky GLBs at runtime. It prefers imported GLB marker nodes for assembly:

- Wasp `TurretSocket`
- Smoky `TurretPivot`
- Smoky `MuzzleSocket`

The sidecar JSON files remain loaded and are used as fallback/documentation if a marker node is not found. The turret mount position is computed as:

```text
turret_position = wasp_turret_socket - smoky_turret_pivot
```

A visible red sphere is added at the assembled `MuzzleSocket` position.

## 5. Material/texture application method

The proof script loads the cyan M0 material templates:

- `assets/materials/hulls/wasp/cyan_m0.tres`
- `assets/materials/turrets/smoky/cyan_m0.tres`

It applies them recursively to every `MeshInstance3D` in the corresponding GLB instance using surface override materials. The material templates reference copied textures through `res://assets/textures/...`.

## 6. Godot validation result

Godot executable was not found in PATH or common local locations during this run, so no headless Godot import was performed.

Validation completed by local file and text checks:

- all required copied assets exist in the Godot repo;
- scene and script files exist;
- M0G Blender validation confirms both GLBs import and markers/UVs are present;
- scene references only copied `res://` resources.

## 7. Git status

Pre-existing dirty file:

- `project.godot`

New M1A files/directories:

- `assets/materials/hulls/`
- `assets/materials/turrets/`
- `assets/metadata/`
- `assets/models/hulls/wasp/`
- `assets/models/turrets/smoky/`
- `assets/textures/hulls/`
- `assets/textures/turrets/`
- `scenes/dev/`
- `scripts/dev/`
- `docs/GODOT_M1A_ASSET_PROOF_REPORT.md`

## 8. Remaining risks

- Godot editor/headless import still needs to be run once a local Godot executable is available.
- The proof uses marker nodes when available; sidecar fallback vectors may need axis-conversion review if marker nodes are ever absent.
- Materials are simple `StandardMaterial3D` albedo templates; final rendering may need unshaded/emission tuning to match the old sprite-lightmap look.
- This scene is a proof only and is not final gameplay or Tank3D runtime architecture.

## 9. Final status

READY_FOR_M1B_TANK3D_RUNTIME
