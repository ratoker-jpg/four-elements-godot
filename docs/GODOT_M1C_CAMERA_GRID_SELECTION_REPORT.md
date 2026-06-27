# GODOT-M1C Camera/Grid/Selection Report

## 1. Goal

Create the first playable-feeling Godot dev scene with RTS-style camera panning/zooming, visible ground/grid, one `Tank3D` instance, mouse selection, and a visible selection indicator.

## 2. Files created/changed

- `scripts/camera/rts_camera_3d.gd`
- `scripts/controllers/selection_controller_3d.gd`
- `scripts/dev/grid_ground_3d.gd`
- `scenes/dev/M1C_CameraGridSelectionTest.tscn`
- `docs/GODOT_M1C_CAMERA_GRID_SELECTION_REPORT.md`
- `scenes/units/Tank3D.tscn`
- `scripts/units/tank_3d.gd`

## 3. Camera controls

The dev scene uses `RTSCameraRig` with `rts_camera_3d.gd`.

- WASD and arrow keys pan over the X/Z plane.
- Mouse wheel zooms in and out.
- Q/E rotates the rig.
- Movement and rotation are frame-rate independent.
- Exported settings include `pan_speed`, `zoom_speed`, `min_zoom`, `max_zoom`, and `edge_scroll_enabled`, which defaults to `false`.

The script uses raw key checks and does not require `project.godot` input-map edits.

## 4. Grid/ground implementation

`grid_ground_3d.gd` creates a dev-only ground plane and visual grid at runtime. The grid is approximate and does not implement pathfinding, tile occupation, build rules, or map systems.

## 5. Selection implementation

`selection_controller_3d.gd` listens for left mouse clicks, raycasts from the configured `Camera3D`, and walks up from the raycast collider to find a node exposing `set_selected()` and `is_selected()`.

Clicking a tank selects it. Clicking empty space clears selection.

## 6. Tank3D changes

`Tank3D` now includes:

- `set_selected(value: bool)`
- `is_selected() -> bool`
- `get_selection_root() -> Node3D`
- a visible `SelectionIndicator` mesh controlled by script
- an approximate `Area3D` selection collider with `CollisionShape3D`

## 7. Validation result

Godot executable used:

`D:\Games\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`

Validation completed:

- `--headless --path . --check-only --script res://scripts/units/tank_3d.gd` exited successfully.
- `--headless --path . --check-only --script res://scripts/camera/rts_camera_3d.gd` exited successfully.
- `--headless --path . --check-only --script res://scripts/controllers/selection_controller_3d.gd` exited successfully.
- `--headless --path . --check-only --script res://scripts/dev/grid_ground_3d.gd` exited successfully.
- First scene launch showed missing GLB import metadata for the Wasp/Smoky `.glb` resources.
- `--headless --path . --import` exited successfully and generated required import sidecars/cache.
- `--headless --path . --scene res://scenes/dev/M1C_CameraGridSelectionTest.tscn --quit-after 2` exited successfully after import.
- `rg -n 'res://' scenes scripts docs\GODOT_M1C_CAMERA_GRID_SELECTION_REPORT.md` showed expected scene/script/asset references.

Click selection cannot be fully exercised headlessly, but the selection script parses and the scene launches with the camera, controller, `Tank3D`, collider, and selection indicator present.

## 8. Godot-generated sidecars

Generated and kept as necessary for import/reference stability:

- `assets/models/hulls/wasp/wasp_0123.glb.import`
- `assets/models/turrets/smoky/smoky_01.glb.import`
- `assets/textures/hulls/wasp/cyan/m0.png.import`
- `assets/textures/hulls/wasp/green/m0.png.import`
- `assets/textures/hulls/wasp/purple/m0.png.import`
- `assets/textures/hulls/wasp/yellow/m0.png.import`
- `assets/textures/turrets/smoky/cyan/m0.png.import`
- `assets/textures/turrets/smoky/green/m0.png.import`
- `assets/textures/turrets/smoky/purple/m0.png.import`
- `assets/textures/turrets/smoky/yellow/m0.png.import`
- `scripts/camera/rts_camera_3d.gd.uid`
- `scripts/controllers/selection_controller_3d.gd.uid`
- `scripts/dev/asset_proof_wasp_smoky.gd.uid`
- `scripts/dev/grid_ground_3d.gd.uid`
- `scripts/units/tank_3d.gd.uid`

Godot also generated ignored `.godot/imported` cache entries for the GLBs/textures. `.godot/` is already ignored by `.gitignore`.

## 9. Git status

Final `git status --short --branch -uall` includes:

```text
## main...origin/main
 M project.godot
?? assets/materials/hulls/wasp/cyan_m0.tres
?? assets/materials/hulls/wasp/green_m0.tres
?? assets/materials/hulls/wasp/purple_m0.tres
?? assets/materials/hulls/wasp/yellow_m0.tres
?? assets/materials/turrets/smoky/cyan_m0.tres
?? assets/materials/turrets/smoky/green_m0.tres
?? assets/materials/turrets/smoky/purple_m0.tres
?? assets/materials/turrets/smoky/yellow_m0.tres
?? assets/metadata/hulls/wasp_0123.json
?? assets/metadata/turrets/smoky_01.json
?? assets/models/hulls/wasp/wasp_0123.glb
?? assets/models/hulls/wasp/wasp_0123.glb.import
?? assets/models/turrets/smoky/smoky_01.glb
?? assets/models/turrets/smoky/smoky_01.glb.import
?? assets/textures/hulls/wasp/cyan/m0.png
?? assets/textures/hulls/wasp/cyan/m0.png.import
?? assets/textures/hulls/wasp/green/m0.png
?? assets/textures/hulls/wasp/green/m0.png.import
?? assets/textures/hulls/wasp/purple/m0.png
?? assets/textures/hulls/wasp/purple/m0.png.import
?? assets/textures/hulls/wasp/yellow/m0.png
?? assets/textures/hulls/wasp/yellow/m0.png.import
?? assets/textures/turrets/smoky/cyan/m0.png
?? assets/textures/turrets/smoky/cyan/m0.png.import
?? assets/textures/turrets/smoky/green/m0.png
?? assets/textures/turrets/smoky/green/m0.png.import
?? assets/textures/turrets/smoky/purple/m0.png
?? assets/textures/turrets/smoky/purple/m0.png.import
?? assets/textures/turrets/smoky/yellow/m0.png
?? assets/textures/turrets/smoky/yellow/m0.png.import
?? docs/GODOT_M1A_ASSET_PROOF_REPORT.md
?? docs/GODOT_M1B_TANK3D_RUNTIME_REPORT.md
?? docs/GODOT_M1C_CAMERA_GRID_SELECTION_REPORT.md
?? scenes/dev/AssetProof_WaspSmoky.tscn
?? scenes/dev/M1C_CameraGridSelectionTest.tscn
?? scenes/dev/Tank3D_RuntimeTest.tscn
?? scenes/units/Tank3D.tscn
?? scripts/camera/rts_camera_3d.gd
?? scripts/camera/rts_camera_3d.gd.uid
?? scripts/controllers/selection_controller_3d.gd
?? scripts/controllers/selection_controller_3d.gd.uid
?? scripts/dev/asset_proof_wasp_smoky.gd
?? scripts/dev/asset_proof_wasp_smoky.gd.uid
?? scripts/dev/grid_ground_3d.gd
?? scripts/dev/grid_ground_3d.gd.uid
?? scripts/units/tank_3d.gd
?? scripts/units/tank_3d.gd.uid
```

`project.godot` was dirty before this task and was not intentionally edited. No input-map changes were made.

## 10. Remaining risks

- Mouse selection was validated structurally and through script parsing, but not interactively in headless mode.
- The selection collider is intentionally approximate and may need tuning after visual playtesting.
- The grid is a dev-only visual helper and does not represent pathfinding, tile occupation, or build placement.
- The camera has basic RTS controls only; edge scroll exists but is disabled by default.

## 11. Final status

READY_FOR_M1D_CLICK_TO_MOVE
