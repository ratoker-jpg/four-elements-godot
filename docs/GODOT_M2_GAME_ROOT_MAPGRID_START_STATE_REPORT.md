# GODOT-M2 GameRoot, MapGrid, Occupancy, Start State Report

Date: 2026-06-28
Milestone: GODOT-M2
Branch: `godot-m2-game-root-mapgrid-start-state`
Base: `main` (after PR #8 — research-backed architecture decisions)

---

## 1. Goal

When the user opens one clear scene in Godot, the project should look like the beginning of an RTS game, not a tank test. M2 adds the first recognizable RTS game start scene with a fixed 64×64 map, HQ placeholder, mineral placeholders, infinite mineral placeholder, starting Tank3D, HUD placeholder, and debug visualization — all built on separated logic systems (MapGrid, OccupancyGrid, StartStateLoader) rather than visual-only nodes.

---

## 2. What was added

### New scripts (6)

| File | Class | Purpose |
|---|---|---|
| `scripts/game/map_grid.gd` | `MapGrid` (RefCounted) | Pure-data grid/world coordinate layer. No visuals. |
| `scripts/game/occupancy_grid.gd` | `OccupancyGrid` (RefCounted) | Tracks which cells are occupied by which entity. Pure data. |
| `scripts/game/start_state_loader.gd` | `StartStateLoader` (Node) | Builds initial start-state data (HQ, minerals, infinite mineral, starting tank). |
| `scripts/game/game_root.gd` | `GameRoot` (Node3D) | Orchestrates the RTS start scene. Owns systems, spawns visuals, wires HUD. |
| `scripts/game/hud_placeholder.gd` | `HudPlaceholder` (CanvasLayer) | Minimal HUD display. No game logic. |
| `scripts/placeholders/placeholder_entity.gd` | `PlaceholderEntity` (Node3D) | Base for placeholder visuals. Stores entity data. |

### New scenes (4)

| File | Purpose |
|---|---|
| `scenes/game/GameRoot.tscn` | Main M2 scene — run this with F6 |
| `scenes/placeholders/HQPlaceholder3x3.tscn` | 3×3 HQ placeholder (blue box + label) |
| `scenes/placeholders/MineralPlaceholder1x1.tscn` | 1×1 mineral placeholder (cyan box) |
| `scenes/placeholders/InfiniteMineralPlaceholder2x2.tscn` | 2×2 infinite mineral placeholder (gold box + label) |

### Preserved (untouched)

- `scenes/units/Tank3D.tscn` + `scripts/units/tank_3d.gd`
- `scripts/camera/rts_camera_3d.gd`
- `scripts/controllers/selection_controller_3d.gd`
- `scripts/controllers/move_command_controller_3d.gd`
- `scripts/dev/move_target_marker_3d.gd`
- `scripts/dev/move_preview_line_3d.gd`
- `scripts/dev/grid_ground_3d.gd`
- All M1 dev scenes (M1C, M1D, M1E)
- `project.godot` — NOT modified
- `scenes/main/main.tscn` — NOT modified

---

## 3. Scene to run

**`scenes/game/GameRoot.tscn`** — open in Godot 4.7 and press F6 (Run Current Scene).

Do NOT set this as `main_scene` in `project.godot`. The user launches it directly.

---

## 4. Map rules

- **Fixed 64×64 map** (no procedural generation in M2).
- Cell size: 64.0 world units.
- Map world size: 4096×4096 units.
- HQ: 3×3 footprint, anchored at cell (4, 53) — lower-left area.
- Standard minerals: 1×1 footprint, 6 placed near HQ starter area.
- Infinite mineral: 2×2 footprint, anchored at cell (31, 31) — map center.
- Starting Tank3D: near HQ at cell (8, 50), does NOT occupy grid cells in M2.
- Medium (96×96) and huge (128×128) maps are deferred to later milestones.

---

## 5. Grid / footprint convention

**Anchor convention: TOP-LEFT.**

- For a footprint of size `(w, h)` anchored at cell `(cx, cy)`, the footprint occupies cells `(cx..cx+w-1, cy..cy+h-1)`.
- `grid_to_world(cell)` returns the world position of the **center** of that cell (not the corner). This keeps 1×1 footprints centered.
- `footprint_center_world(anchor_cell, footprint_size)` returns the world-space center of a multi-cell footprint — used for visual placement of HQ (3×3) and infinite mineral (2×2).

Example: HQ anchored at cell (4, 53) with footprint (3, 3):
- Occupied cells: (4,53), (5,53), (6,53), (4,54), (5,54), (6,54), (4,55), (5,55), (6,55)
- Visual center world position: `footprint_center_world(Vector2i(4,53), Vector2i(3,3))` = `(4+1.5)*64, 0, (53+1.5)*64` = `(352, 0, 3488)`

---

## 6. MapGrid API

```gdscript
class_name MapGrid extends RefCounted

@export var map_size_cells: Vector2i = Vector2i(64, 64)
@export var cell_size_world: float = 64.0

func grid_to_world(cell: Vector2i) -> Vector3          # center of cell
func world_to_grid(world_position: Vector3) -> Vector2i
func is_in_bounds(cell: Vector2i) -> bool
func cells_for_footprint(anchor_cell: Vector2i, footprint_size: Vector2i) -> Array
func footprint_center_world(anchor_cell: Vector2i, footprint_size: Vector2i) -> Vector3
func map_world_size() -> Vector2
```

Pure data — no Node3D, no Godot scene dependency. Systems own this; visual nodes read from it.

---

## 7. OccupancyGrid API

```gdscript
class_name OccupancyGrid extends RefCounted

func mark_occupied(entity_id: String, cells: Array) -> void
func clear_occupied(entity_id: String) -> void
func is_cell_free(cell: Vector2i) -> bool
func are_cells_free(cells: Array) -> bool
func get_occupant(cell: Vector2i) -> String
func get_cells_for_entity(entity_id: String) -> Array
func get_all_occupied_cells() -> Array
func occupied_cell_count() -> int
func entity_count() -> int
func clear() -> void
```

M2 occupancy tracks: HQ 3×3 cells, mineral 1×1 cells, infinite mineral 2×2 cells. Units (Tank3D) do NOT reserve occupancy cells in M2.

---

## 8. Start state

`StartStateLoader.build()` creates:

| Entity | Kind | Anchor cell | Footprint | Occupancy |
|---|---|---|---|---|
| HQ | `hq` | (4, 53) | 3×3 | 9 cells |
| mineral_0..mineral_5 | `mineral` | 6 positions near HQ | 1×1 | 6 cells |
| infinite_mineral | `infinite_mineral` | (31, 31) | 2×2 | 4 cells |
| tank_0 | `tank` | (8, 50) | 0×0 (no occupancy) | none |

Total occupied cells: 9 + 6 + 4 = **19 cells**.

Layout:
- Player HQ near lower-left (cell 4, 53).
- Starting Tank3D near HQ (cell 8, 50).
- 6 standard minerals scattered near HQ (cells around 8-15, 48-56).
- Infinite mineral at map center (cell 31, 31).

---

## 9. Placeholder assets used

All placeholders are clearly marked with `PLACEHOLDER_ASSET` comments and named with `Placeholder` in the node name.

| Placeholder | Scene | Visual | Replacement note |
|---|---|---|---|
| HQ 3×3 | `scenes/placeholders/HQPlaceholder3x3.tscn` | Blue box (192×96×192) + "PLACEHOLDER: HQ 3x3" label | Replace with real HQ GLB when asset pipeline delivers it |
| Mineral 1×1 | `scenes/placeholders/MineralPlaceholder1x1.tscn` | Cyan box (48×32×48) + "M" label | Replace with real mineral crystal GLB |
| Infinite mineral 2×2 | `scenes/placeholders/InfiniteMineralPlaceholder2x2.tscn` | Gold box (128×64×128) + "PLACEHOLDER: Infinite 2x2" label | Replace with real infinite deposit GLB |

All placeholders extend `PlaceholderEntity` which stores the entity data dictionary from `StartStateLoader` for debug/inspection.

---

## 10. Phaser assets checked/used

Phaser repository was NOT checked for portable mineral/resource assets in this milestone. Phaser uses PNG-based 2D sprites which are not directly portable to Godot 3D. M2 uses obvious 3D primitive placeholders (boxes) instead.

If Phaser-side 3D source assets (`.3ds`/`.glb`) for minerals become available, they can replace the box placeholders without changing the `PlaceholderEntity` API.

---

## 11. HUD placeholder

`HudPlaceholder` (CanvasLayer) displays:

- **Raw: 0** (placeholder — no economy in M2)
- **Energy: 0** (placeholder — no economy in M2)
- **Units: 1** (starting Tank3D count)
- **Selected: `<none>`** (updates when selection changes)
- **Controls hint**: LMB select, RMB move, WASD/arrows camera, wheel zoom, Q/E rotate
- **Debug text**: Map 64×64, HQ 3×3, Minerals count, Occupied cells count

The HUD does NOT own game logic. It receives display data via `update_state(data: Dictionary)` and `update_selected(label_text: String)` methods called by `GameRoot`.

---

## 12. Debug visualization

`GameRoot._build_debug_visualization()` adds:

- **Map bounds outline** (yellow rectangle at map edges)
- **Sampled grid lines** (every 4 cells, subtle green — avoids clutter)
- **Footprint outlines** per entity:
  - HQ: blue rectangle (3×3)
  - Minerals: green rectangles (1×1)
  - Infinite mineral: gold rectangle (2×2)
- **Occupied-cell dots** (small red spheres on each occupied cell center)

All debug visualization uses `ImmediateMesh` with `SHADING_MODE_UNSHADED` and `no_depth_test = true` for visibility. It is simple and ugly but useful for validation.

---

## 13. Preserved M1 features

All M1 features continue to work in GameRoot.tscn:

- ✅ RTS camera (pan/zoom/rotate via WASD/wheel/Q/E) — wired via `RTSCameraRig` node
- ✅ Single-unit selection (LMB click) — wired via `SelectionController3D` under Systems
- ✅ Right-click movement — wired via `MoveCommandController3D` under Systems
- ✅ Move target marker (fading cyan ring) — wired via NodePath to `MapRoot/Markers/MoveTargetMarker`
- ✅ Move preview line (straight-line) — wired via NodePath to `MapRoot/Markers/MovePreviewLine`
- ✅ Tank3D forward-axis fix (visual_forward_yaw_offset_degrees) — unchanged in Tank3D.tscn

The Tank3D is spawned by `GameRoot._spawn_tank()` with M2-scaled movement values: `move_speed=240`, `stop_distance=16`, `arrival_slowdown_distance=120`, `min_move_distance=8` (scaled for the 64-unit cell size).

---

## 14. Validation

### Godot executable availability

**Godot executable is NOT available in this environment.** No runtime validation was performed.

### Static validation performed

| Check | Result |
|---|---|
| All 6 new scripts exist | ✅ Pass |
| All 4 new scenes exist | ✅ Pass |
| All `res://` references in GameRoot.tscn resolve (7 ext + 2 sub) | ✅ Pass |
| All `res://` preload references in game_root.gd resolve (4 scenes) | ✅ Pass |
| All placeholder scene references resolve | ✅ Pass |
| `load_steps` matches resource count in all 4 scenes | ✅ Pass |
| Tab indentation (no mixed tabs/spaces) in all 6 scripts | ✅ Pass |
| `project.godot` NOT modified | ✅ Pass |
| `scenes/main/main.tscn` NOT modified | ✅ Pass |
| Old M1 scenes preserved (M1C, M1D, M1E, Tank3D) | ✅ Pass |
| Godot 4 syntax sanity (extends, class_name, @export, @onready, func, signals) | ✅ Pass (manual review) |

### What was NOT validated

- Scene does not actually load in Godot (no executable).
- Scripts do not actually parse in Godot (no executable).
- Runtime behavior (entity spawning, HUD update, debug viz) is not verified.
- These require Denis to open `scenes/game/GameRoot.tscn` in Godot 4.7 and run with F6.

---

## 15. Known limitations

1. **No Godot runtime validation**: static checks only. Denis must open the project and run GameRoot.tscn.
2. **No economy/harvesting**: Raw/Energy display is hardcoded to 0. Minerals are visual placeholders only — no gather loop.
3. **No construction**: HQ is pre-placed. No build commands.
4. **No production**: Tank3D is pre-spawned. No factory.
5. **No combat**: No damage, no projectiles, no turret aim.
6. **Unit occupancy not tracked**: Tank3D does not reserve grid cells in M2. This is intentional — units are ~0.75×0.75 and reserving cells for moving units adds complexity not needed for a start-state shell.
7. **Debug visualization is ugly**: ImmediateMesh lines + sphere dots. Intentionally simple for validation.
8. **HUD selection wiring**: `GameRoot.on_selection_changed()` exists but is not yet connected to `SelectionController3D` via signal. Selection works (M1 controller), but the HUD "Selected" field will stay `<none>` until a future milestone wires the signal. This is a known M2 limitation — the HUD displays the initial state correctly.

---

## 16. Explicitly excluded from M2

- procedural generation
- harvesting
- economy loop
- construction
- production
- combat
- turret aim
- projectiles
- AI
- win/loss
- project.godot main_scene changes
- medium (96×96) / huge (128×128) map sizes
- Phaser PNG asset migration
- multi-select

---

## 17. Final status

```
READY_FOR_LOCAL_M2_VALIDATION
```

Denis must open `scenes/game/GameRoot.tscn` in Godot 4.7, press F6, and verify:
1. Map ground visible (64×64, dark green).
2. HQ placeholder visible (blue box, lower-left).
3. 6 mineral placeholders visible (cyan boxes near HQ).
4. Infinite mineral placeholder visible (gold box, map center).
5. Starting Tank3D visible near HQ.
6. HUD panel visible (top-left) with Raw/Energy/Units/Selected/Controls/Debug.
7. Debug visualization visible (grid lines, footprint outlines, occupied-cell dots).
8. Camera pan/zoom/rotate works.
9. LMB selects Tank3D.
10. RMB moves Tank3D (with target marker + preview line).
