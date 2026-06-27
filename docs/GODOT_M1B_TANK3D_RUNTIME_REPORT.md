# GODOT-M1B Tank3D Runtime Report

## 1. Goal

Create the first reusable Godot `Tank3D` runtime skeleton using the already imported M1A Wasp hull and Smoky turret assets.

## 2. Files created/changed

- `scenes/units/Tank3D.tscn`
- `scripts/units/tank_3d.gd`
- `scenes/dev/Tank3D_RuntimeTest.tscn`
- `docs/GODOT_M1B_TANK3D_RUNTIME_REPORT.md`

## 3. Tank3D structure

`Tank3D.tscn` uses a `Node3D` root with the required internal nodes:

- `HullRoot`
- `TurretRoot`
- `DebugRoot`

The script instances the selected hull under `HullRoot` and the selected turret under `TurretRoot`.

## 4. Asset assembly method

The runtime script loads the hull GLB and turret GLB from configured asset definitions. It resolves the hull `TurretSocket`, turret `TurretPivot`, and turret `MuzzleSocket` by looking for named GLB marker nodes first. If a marker is not present, it falls back to the sidecar metadata JSON local position.

The turret root is positioned so the turret pivot aligns to the hull turret socket.

## 5. Material/faction switching

The script exposes `hull_id`, `turret_id`, `faction`, `hull_mod`, and `turret_mod`. It supports `cyan`, `green`, `yellow`, and `purple` faction values and builds material paths from the selected faction/mod rather than hardcoding cyan.

## 6. Debug markers

`show_debug_markers` defaults to `true`. When enabled, `DebugRoot` receives visible sphere markers for:

- `TurretSocket`
- `TurretPivot`
- `MuzzleSocket`

## 7. Validation result

Godot executable found:

`D:\Games\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`

Validation completed:

- `--headless --path . --import` exited successfully.
- `--headless --path . --check-only --script res://scripts/units/tank_3d.gd` exited successfully after fixing a typed-inference warning.
- `--headless --path . --scene res://scenes/dev/Tank3D_RuntimeTest.tscn --quit-after 2` exited successfully.
- Static path check confirmed the Tank3D scene, script, runtime test scene, GLBs, metadata, and all cyan/green/yellow/purple material resources exist.

Godot generated temporary import/UID sidecars during validation, including asset `.import` files and script `.gd.uid` files. They were removed because they are outside the allowed edit list for this task.

## 8. Git status

Final `git status --short --branch`:

```text
## main...origin/main
 M project.godot
?? assets/materials/hulls/
?? assets/materials/turrets/
?? assets/metadata/
?? assets/models/hulls/wasp/
?? assets/models/turrets/smoky/
?? assets/textures/hulls/
?? assets/textures/turrets/
?? docs/GODOT_M1A_ASSET_PROOF_REPORT.md
?? docs/GODOT_M1B_TANK3D_RUNTIME_REPORT.md
?? scenes/dev/
?? scenes/units/Tank3D.tscn
?? scripts/dev/
?? scripts/units/tank_3d.gd
```

`project.godot` was dirty before this task and was not intentionally edited.

## 9. Remaining risks

- The runtime skeleton currently includes configured definitions only for the imported `wasp` hull and `smoky` turret.
- Marker-node assembly depends on imported GLB marker names when present; the script falls back to sidecar metadata when marker nodes are absent.
- This milestone intentionally does not include movement, selection, projectile, damage, AI, economy, or construction behavior.

## 10. Final status

READY_FOR_M1C_CAMERA_GRID_SELECTION
