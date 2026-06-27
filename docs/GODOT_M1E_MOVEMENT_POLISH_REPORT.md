# GODOT-M1E Movement Polish Report

Date: 2026-06-28
Milestone: GODOT-M1E
Branch: `godot-m1e-movement-polish`
Base: `main` (merge commit `095a7a24ab6d0971800cbf1de52a2a769f4c6f1a` from PR #4)

---

## 1. Goal

Polish Tank3D straight-line movement and add clearer right-click target feedback + a simple straight-line move preview. No pathfinding, no combat, no economy — this milestone is only movement feel and dev-side visual feedback.

---

## 2. Files created/changed

### Changed

| File | Change |
|---|---|
| `scripts/units/tank_3d.gd` | Added arrival slowdown, min_move_distance, is_moving(), move_started/move_finished signals; tab indentation preserved |
| `scripts/controllers/move_command_controller_3d.gd` | Integrated MoveTargetMarker + MovePreviewLine; wired move_finished to hide preview; legacy debug sphere hidden by default |

### Created

| File | Purpose |
|---|---|
| `scripts/dev/move_target_marker_3d.gd` | Fading ring marker at clicked ground position |
| `scripts/dev/move_preview_line_3d.gd` | Straight-line preview from tank to move target |
| `scenes/dev/M1E_MovementPolishTest.tscn` | Dev scene with Tank3D + camera + controllers + marker + preview line |

### Unchanged (old scenes preserved)

- `scenes/dev/M1C_CameraGridSelectionTest.tscn` — untouched
- `scenes/dev/M1D_ClickToMoveTest.tscn` — untouched
- `scenes/units/Tank3D.tscn` — untouched
- `scripts/camera/rts_camera_3d.gd` — untouched
- `scripts/controllers/selection_controller_3d.gd` — untouched
- `scripts/dev/grid_ground_3d.gd` — untouched

---

## 3. Movement polish

### What changed in `tank_3d.gd`

- **`arrival_slowdown_distance` (export, default 1.2)**: within this distance of the target, speed scales down linearly (`speed_scale = clampf(distance / arrival_slowdown_distance, 0.15, 1.0)`). This eliminates the jitter/oscillation that occurred when the tank reached the target at full speed.
- **`min_move_distance` (export, default 0.05)**: right-clicks closer than this to the current position are ignored as no-ops. Prevents micro-jitter from accidental clicks on the tank itself.
- **`is_moving() -> bool`**: convenience accessor for dev UI / preview systems.
- **`signal move_started(target_position)`**: emitted when movement begins (only if not already active).
- **`signal move_finished(final_position)`**: emitted when movement stops (arrival, or explicit `stop_moving()`).
- **Stop behavior**: when `distance <= stop_distance`, the tank snaps to the flat target position to avoid floating-point drift, then calls `stop_moving()` which emits `move_finished`.
- **Rotation**: unchanged `lerp_angle` with `min(turn_speed * delta, 1.0)` clamp — already prevented overshoot, but now combined with arrival slowdown so the tank turns more gently as it approaches.

### Preserved API (no breaking changes)

- `move_to(world_position: Vector3) -> void`
- `stop_moving() -> void`
- `has_move_target() -> bool`
- `get_move_target() -> Vector3`
- `set_selected(value)`, `is_selected()`, `get_selection_root()`
- `rebuild()` — hull/turret assembly untouched
- Selection indicator, debug markers, faction materials — all untouched

### What was NOT changed

- No physics body added (movement is purely kinematic via `global_position`).
- No pathfinding, no obstacle avoidance, no navmesh.
- No turret rotation changes (turret aim is M1F scope).
- No asset changes.

---

## 4. Target marker

### `scripts/dev/move_target_marker_3d.gd`

- **Visual**: a cyan cylinder ring (radius 14.0) that appears at the clicked ground position.
- **Lifetime**: fades out over `marker_lifetime` (0.8s) via alpha interpolation.
- **No collision**: `top_level = true`, no `CollisionShape3D` — does not block picking/raycast.
- **API**: `show_marker(world_position)`, `hide_marker()`.
- **Material**: transparent, `no_depth_test = true` so it renders on top of ground.

### Integration

- `MoveCommandController3D` calls `move_target_marker.show_marker(ground_point)` on every successful right-click move command.
- The marker is wired via `move_target_marker_path` NodePath export in the controller; if unset, the controller skips it (graceful degradation).

---

## 5. Preview line

### `scripts/dev/move_preview_line_3d.gd`

- **Visual**: a thin cyan box mesh (width 3.0) oriented along the from→to direction.
- **Behavior**: `_process()` continuously updates the line from the tracked unit's current position to its move target, so the line shrinks as the tank approaches.
- **Hide conditions**: hides when no tracked unit, unit invalid, unit not moving (`is_moving() == false`), or distance < 0.001.
- **No collision**: `top_level = true`, no collision — purely visual.
- **API**: `track_unit(node)`, `show_preview(from, to)`, `hide_preview()`.
- **Material**: transparent, `no_depth_test = true`.

### Integration

- `MoveCommandController3D` calls `move_preview_line.track_unit(unit)` + `show_preview(unit.global_position, target)` on move command.
- Controller wires `move_finished` signal to `_on_unit_move_finished` which calls `hide_preview()`.
- The preview line is wired via `move_preview_line_path` NodePath export; if unset, controller skips it.

### Important limitation

This is a **straight-line preview only**. It does NOT show pathfinding, obstacle avoidance, or navmesh routing. It is explicitly an M1E dev/debug visualization.

---

## 6. Optional stop/cancel behavior

### Decision: deferred (S hotkey conflicts with camera pan)

The RTS camera (`rts_camera_3d.gd`) uses `KEY_S` and `KEY_DOWN` for backward panning. Binding S to "stop selected unit" would conflict with camera movement.

**Skipped**: global stop hotkey.

**Alternatives considered**:
- Right-click very near current position → stop: `min_move_distance` already handles this as a no-op (ignores the click), which effectively means clicking on the tank does nothing. This is acceptable for M1E — the tank stops naturally when it reaches its target.
- Right-click on the tank itself → stop: not implemented because selection raycast picks the tank on left-click, and right-click on the tank would currently issue a move command to the tank's position (which `min_move_distance` then ignores).

**Deferred to**: M5B (RTS UX + Save/Load) when a proper input router with separate camera vs command key handling is implemented. At that point S can be remapped or a dedicated stop key (e.g. X) can be added.

---

## 7. Dev scene

### `scenes/dev/M1E_MovementPolishTest.tscn`

Contains:
- **Tank3D** (Wasp+Smoky, cyan, M0) with M1E export overrides: `move_speed=120`, `stop_distance=8`, `arrival_slowdown_distance=60`, `min_move_distance=4`.
- **RTSCameraRig** with Camera3D (current, fov 55).
- **GridGround** (dev grid + ground plane).
- **GroundBody** (StaticBody3D with BoxShape3D for raycast).
- **SelectionController3D** (left-click select).
- **MoveCommandController3D** (right-click move, wired to marker + preview line).
- **MoveTargetMarker** (Node3D with `move_target_marker_3d.gd`).
- **MovePreviewLine** (Node3D with `move_preview_line_3d.gd`).
- **SunLight** (DirectionalLight3D).
- **WorldEnvironment** (ambient light).
- **M1ELabel** (Label3D with controls hint).

### Controls

- **WASD / arrows**: camera pan
- **Mouse wheel**: zoom
- **Q / E**: camera rotate
- **Left click tank**: select
- **Left click empty**: deselect
- **Right click ground**: move selected tank (shows fading marker + preview line)
- **Stop hotkey**: not available (S is camera pan — deferred to M5B)

### Old scenes preserved

- `scenes/dev/M1C_CameraGridSelectionTest.tscn` — untouched
- `scenes/dev/M1D_ClickToMoveTest.tscn` — untouched

---

## 8. Validation result

### Godot executable availability

**Godot executable is NOT available in this environment.** No runtime validation was performed.

### Static validation performed

| Check | Result |
|---|---|
| All changed/new files exist | ✅ Pass |
| All `res://` references in M1E scene resolve to existing files | ✅ Pass (7/7) |
| `Tank3D.tscn` still exists and references `tank_3d.gd` | ✅ Pass |
| `M1D_ClickToMoveTest.tscn` still exists | ✅ Pass |
| `M1E_MovementPolishTest.tscn` load_steps matches resource count | ✅ Pass (load_steps=10, 7 ext + 2 sub + 1 scene) |
| GDScript indentation (tabs only, no mixed) — `tank_3d.gd` | ✅ Pass |
| GDScript indentation — `move_command_controller_3d.gd` | ✅ Pass |
| GDScript indentation — `move_target_marker_3d.gd` | ✅ Pass |
| GDScript indentation — `move_preview_line_3d.gd` | ✅ Pass |
| No missing referenced scripts/scenes/assets | ✅ Pass |
| Godot 4 syntax sanity (extends, @export, @onready, func, signals) | ✅ Pass (manual review) |

### What was NOT validated

- Scene does not actually load in Godot (no executable).
- Scripts do not actually parse in Godot (no executable).
- Runtime behavior (movement feel, marker fade, preview shrink) is not verified.
- These require Denis to open the project in Godot 4.7 and run `M1E_MovementPolishTest.tscn`.

---

## 9. Godot-generated sidecars

No `.godot/` cache files were committed. No `.uid` files were created for the new scripts — Godot will generate them on first open.

The following new scripts will need `.uid` files generated by Godot on first open:
- `scripts/dev/move_target_marker_3d.gd`
- `scripts/dev/move_preview_line_3d.gd`

This is expected behavior — Godot generates `.uid` files automatically when the project is opened.

---

## 10. Git status / PR status

- **Branch**: `godot-m1e-movement-polish`
- **Base**: `main`
- **Commit**: (will be created after this report)
- **PR**: (will be opened after push)
- **Changed files**: 5 (2 changed scripts, 2 new scripts, 1 new scene, 1 new report doc)

---

## 11. Remaining risks

1. **No runtime validation**: Godot executable was not available. The scene may have a subtle issue that only appears at load time (e.g. node path mismatch, export var type mismatch). Denis must open the project and run the scene to confirm.
2. **Stop hotkey deferred**: S conflicts with camera pan. Players cannot manually stop a moving tank via hotkey in M1E. The tank stops on arrival or when given a new move command. Deferred to M5B.
3. **Preview line is straight-only**: It does not reflect any future pathfinding. When pathfinding is added (M5A or later), the preview must be updated to show the actual path, not a straight line.
4. **Marker + preview are dev-only**: The scripts live in `scripts/dev/` and are intended for M1E debug visualization. They should not be used as production UI without refactor.
5. **`min_move_distance` default is small (0.05)**: For the M1E dev scene, it was overridden to 4.0 because the tank uses large-scale units (move_speed=120). Other scenes may need to tune this value.

---

## 12. Final status

```
READY_FOR_M1F_TURRET_AIM_PROJECTILE_PROOF
```
