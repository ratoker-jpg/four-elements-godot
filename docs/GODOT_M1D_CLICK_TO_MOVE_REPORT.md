# GODOT-M1D Click-to-Move Report

## 1. Goal

Add simple RTS-style click-to-move for one selected `Tank3D`: select the tank, right-click the ground, move in a straight line, rotate toward travel direction, and stop near the target.

## 2. Files created/changed

- `scripts/controllers/move_command_controller_3d.gd`
- `scenes/dev/M1D_ClickToMoveTest.tscn`
- `docs/GODOT_M1D_CLICK_TO_MOVE_REPORT.md`
- `scripts/units/tank_3d.gd`
- `scripts/controllers/selection_controller_3d.gd`

## 3. Tank3D movement API

`Tank3D` now exposes:

- `move_to(world_position: Vector3) -> void`
- `stop_moving() -> void`
- `has_move_target() -> bool`
- `get_move_target() -> Vector3`

Movement exports:

- `move_speed`
- `turn_speed`
- `stop_distance`
- `movement_enabled`
- `show_debug_move_target`

## 4. Move command controller

`move_command_controller_3d.gd` uses the configured camera and selection controller. On right mouse click, it gets the currently selected unit, raycasts against ground bodies, and calls `move_to()` on the selected unit. It includes an optional visible debug command target marker.

## 5. Dev scene controls

- WASD / arrows: camera pan
- Mouse wheel: zoom
- Q/E: rotate camera
- Left click tank: select
- Left click empty: deselect
- Right click ground while selected: move selected tank

## 6. Validation result

Godot executable used:

`D:\Games\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`

Validation completed:

- `--headless --path . --check-only --script res://scripts/units/tank_3d.gd` exited successfully after fixing typed-inference warnings.
- `--headless --path . --check-only --script res://scripts/controllers/selection_controller_3d.gd` exited successfully.
- `--headless --path . --check-only --script res://scripts/controllers/move_command_controller_3d.gd` exited successfully after fixing typed-inference warnings.
- `--headless --path . --scene res://scenes/dev/M1D_ClickToMoveTest.tscn --quit-after 2` exited successfully.
- `--headless --path . --scene res://scenes/dev/M1C_CameraGridSelectionTest.tscn --quit-after 2` exited successfully.
- `--headless --path . --scene res://scenes/units/Tank3D.tscn --quit-after 2` exited successfully.
- `rg -n 'res://' scenes scripts docs\GODOT_M1D_CLICK_TO_MOVE_REPORT.md` showed expected scene/script/asset references.

Interactive right-click movement cannot be fully exercised headlessly, but the movement API, command controller script, M1D scene, existing M1C scene, and `Tank3D` scene all parse/load successfully.

## 7. Godot-generated sidecars

Existing Godot sidecars present and kept:

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

No new `move_command_controller_3d.gd.uid` sidecar was observed after validation. `.godot/` cache entries remain ignored by `.gitignore`.

## 8. Git status

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
?? docs/GODOT_M1D_CLICK_TO_MOVE_REPORT.md
?? scenes/dev/AssetProof_WaspSmoky.tscn
?? scenes/dev/M1C_CameraGridSelectionTest.tscn
?? scenes/dev/M1D_ClickToMoveTest.tscn
?? scenes/dev/Tank3D_RuntimeTest.tscn
?? scenes/units/Tank3D.tscn
?? scripts/camera/rts_camera_3d.gd
?? scripts/camera/rts_camera_3d.gd.uid
?? scripts/controllers/move_command_controller_3d.gd
?? scripts/controllers/selection_controller_3d.gd
?? scripts/controllers/selection_controller_3d.gd.uid
?? scripts/dev/asset_proof_wasp_smoky.gd
?? scripts/dev/asset_proof_wasp_smoky.gd.uid
?? scripts/dev/grid_ground_3d.gd
?? scripts/dev/grid_ground_3d.gd.uid
?? scripts/units/tank_3d.gd
?? scripts/units/tank_3d.gd.uid
```

`project.godot` was dirty before this task and was not intentionally edited.

## 9. Remaining risks

- Click-to-move was validated structurally and through scene/script loading, but not interactively in headless mode.
- Movement is straight-line transform movement only; there is no pathfinding, avoidance, formation, or tile occupation.
- The M1D dev scene overrides `Tank3D.move_speed` and `stop_distance` to make motion visible at the current asset/grid scale; the reusable script defaults remain `4.0` and `0.15`.
- Ground command raycast depends on the M1D scene's simple `StaticBody3D` ground collider.

## 10. Final status

READY_FOR_M1E_PATH_PREVIEW_OR_MOVEMENT_POLISH
