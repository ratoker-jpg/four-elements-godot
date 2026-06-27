# GODOT-M1E Forward Axis Hotfix Report

Date: 2026-06-28
Milestone: GODOT-M1E-HF1
Branch: `godot-m1e-hotfix-forward-axis`
Base: `main` (after PR #5 merge)

---

## 1. Problem

After PR #5 (GODOT-M1E) was merged and tested locally in Godot, the Tank3D visually drove backwards. All movement mechanics worked correctly — selection, right-click move, target marker, preview line, arrival at target — but the hull model faced the opposite direction of travel.

## 2. Root cause

The movement yaw calculation used `atan2(direction.x, direction.z)`, which assumes the model's visual forward axis is +Z. The imported Wasp GLB model's visual forward axis is -Z (facing toward the camera/default view), so the yaw calculated for movement direction pointed the model 180° away from the intended facing.

This is a classic mismatch between movement math conventions and asset export orientation. The movement direction itself was correct (tank traveled toward the clicked target); only the visual rotation was wrong.

## 3. Fix

Added a configurable visual forward yaw offset export and applied it to the movement rotation calculation.

### New export

```gdscript
@export var visual_forward_yaw_offset_degrees := 180.0
```

Default is 180.0 because the current Wasp GLB faces -Z while the movement yaw assumes +Z forward. This offset rotates the visual facing by 180° so the hull points toward the movement direction.

### Rotation calculation update

Before:
```gdscript
var target_yaw := atan2(direction.x, direction.z)
rotation.y = lerp_angle(rotation.y, target_yaw, min(turn_speed * delta, 1.0))
```

After:
```gdscript
var target_yaw := atan2(direction.x, direction.z) + deg_to_rad(visual_forward_yaw_offset_degrees)
rotation.y = lerp_angle(rotation.y, target_yaw, min(turn_speed * delta, 1.0))
```

### What did NOT change

- **Movement direction**: the tank still moves toward the clicked target. Only the visual rotation is offset.
- **Movement speed / arrival / stop**: all M1E movement polish behavior preserved.
- **Existing API**: `move_to`, `stop_moving`, `has_move_target`, `get_move_target`, `is_moving` — all unchanged.
- **Selection indicator, debug markers, faction materials, hull/turret assembly** — all untouched.
- **Target marker and preview line** — untouched (they use `global_position`, not `rotation`).

### Configurability

The offset is an `@export` so it can be tuned per-scene or per-hull in the Godot inspector without code changes. If a future hull asset has a different forward axis, the offset can be adjusted (e.g. 0.0 for +Z forward, 90.0 for +X forward, -90.0 for -X forward, 180.0 for -Z forward).

---

## 4. Files changed

| File | Change |
|---|---|
| `scripts/units/tank_3d.gd` | Added `visual_forward_yaw_offset_degrees` export (default 180.0); applied offset to `target_yaw` in `_update_movement()` |
| `docs/GODOT_M1E_FORWARD_AXIS_HOTFIX_REPORT.md` | New — this report |

**Total**: 2 files (1 changed, 1 new).

No scene files changed. No new scripts. No asset changes.

---

## 5. Validation

### Godot executable availability

**Godot executable is NOT available in this environment.** No runtime validation was performed.

### Static validation performed

| Check | Result |
|---|---|
| `visual_forward_yaw_offset_degrees` export added | ✅ Pass |
| `deg_to_rad(visual_forward_yaw_offset_degrees)` applied to `target_yaw` | ✅ Pass |
| Tab indentation preserved (no mixed tabs/spaces) | ✅ Pass |
| Existing API methods unchanged (`move_to`, `stop_moving`, `has_move_target`, `get_move_target`, `is_moving`) | ✅ Pass |
| Movement direction calculation unchanged (only yaw offset added) | ✅ Pass |
| No other files touched | ✅ Pass |
| GDScript syntax sanity (manual review) | ✅ Pass |

### What was NOT validated

- Runtime visual confirmation that the tank now faces forward.
- The exact offset value (180.0) — this is the most likely fix based on the symptom description ("drives backwards" = 180° off), but Denis must confirm visually in Godot.
- If 180.0 does not fix it, the offset can be tuned in the inspector (0.0, 90.0, -90.0, 180.0) without code changes.

---

## 6. Scope excluded

- turret aim
- projectiles
- damage
- combat
- economy
- harvesting
- construction
- AI
- pathfinding
- multi-select
- new assets
- broad refactors

---

## 7. Final status

```
READY_FOR_LOCAL_FORWARD_AXIS_VALIDATION
```

Denis must open the project in Godot 4.7, run `M1E_MovementPolishTest.tscn`, right-click to move the tank, and confirm the hull now faces the movement direction. If the offset needs tuning, adjust `visual_forward_yaw_offset_degrees` in the inspector — no code change required.
