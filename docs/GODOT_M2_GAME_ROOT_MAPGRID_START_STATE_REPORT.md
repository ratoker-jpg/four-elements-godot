# GODOT-M2 GameRoot, MapGrid, Occupancy, Start State Report

Date: 2026-06-28
Milestone: GODOT-M2
Branch: `godot-m2-game-root-mapgrid-start-state`
Base: `main` after PR #8

---

## 1. Goal

M2 adds the first recognizable RTS start scene in Godot:

- one run-current-scene entry point: `res://scenes/game/GameRoot.tscn`
- fixed 64x64 map
- HQ 3x3 placeholder
- six mineral 1x1 placeholders
- one infinite mineral 2x2 placeholder
- one starting Tank3D
- compact HUD placeholder
- readable debug grid and footprint visualization
- preserved M1 camera, selection, move marker, move preview, and tank movement behavior

M2 does not add economy, construction, production, combat, pathfinding, AI, or win/loss logic.

---

## 2. Files added or used by M2

### Scripts

| File | Class | Purpose |
|---|---|---|
| `scripts/game/map_grid.gd` | `MapGrid` | Pure-data grid/world coordinate layer. |
| `scripts/game/occupancy_grid.gd` | `OccupancyGrid` | Tracks occupied map cells by entity id. |
| `scripts/game/start_state_loader.gd` | `StartStateLoader` | Builds HQ, minerals, infinite mineral, and starting tank state. |
| `scripts/game/game_root.gd` | `GameRoot` | Orchestrates scene startup, visuals, HUD, camera focus, and debug visualization. |
| `scripts/game/hud_placeholder.gd` | `HudPlaceholder` | Compact HUD display only; no game logic. |
| `scripts/placeholders/placeholder_entity.gd` | `PlaceholderEntity` | Shared base for placeholder visuals and entity metadata. |
| `scripts/controllers/selection_controller_3d.gd` | `SelectionController3D` | M1 controller, now emits `selection_changed`. |

### Scenes

| File | Purpose |
|---|---|
| `scenes/game/GameRoot.tscn` | Main M2 scene. Run this with F6 / Run Current Scene. |
| `scenes/placeholders/HQPlaceholder3x3.tscn` | 3x3 HQ placeholder. |
| `scenes/placeholders/MineralPlaceholder1x1.tscn` | 1x1 mineral placeholder. |
| `scenes/placeholders/InfiniteMineralPlaceholder2x2.tscn` | 2x2 infinite mineral placeholder. |

### Explicitly preserved

- `project.godot` was not modified by this repair.
- `scenes/main/main.tscn` was not modified by this repair.
- Shared Tank3D scene/script were not changed.
- M1 dev scenes remain loadable.

---

## 3. Scene to run

Open:

```text
res://scenes/game/GameRoot.tscn
```

Then press F6 / Run Current Scene.

Do not set this as `project.godot` main scene for M2.

---

## 4. Map and start-state rules

- Map size: 64x64 cells.
- Cell size: 64.0 world units.
- Map world size: 4096x4096 units.
- HQ footprint: 3x3 cells, anchored at `(4, 53)`.
- Standard minerals: six 1x1 cells near the HQ.
- Infinite mineral: 2x2 cells at map center, anchored at `(31, 31)`.
- Starting Tank3D: cell `(8, 50)`, does not reserve occupancy cells in M2.
- Occupied cells: 19 total (HQ 9 + minerals 6 + infinite mineral 4).

Anchor convention is top-left. `grid_to_world()` returns cell center. `footprint_center_world()` returns the visual center for multi-cell footprints.

---

## 5. HUD

`HudPlaceholder` displays a compact top-left panel:

- `Four Elements / M2 Start`
- `Raw: 0`
- `Energy: 0`
- `Units: 1`
- `Selected: <none>` before selection
- short controls block: LMB select, RMB move, WASD/arrows camera, Wheel zoom, Q/E rotate
- debug block: Map, Occupied, Minerals

The HUD does not own game logic. `GameRoot` updates it through `update_state()` and `update_selected()`.

Selection now updates live:

- before selection: `Selected: <none>`
- after selecting the tank: `Selected: Tank3D`
- after clicking empty ground: `Selected: <none>`

---

## 6. Camera

GameRoot now starts the RTS camera on the HQ/tank/mineral cluster instead of the map center.

Startup focus uses the start-state HQ, tank, and mineral positions, then applies:

- camera target near `(672, 0, 3344)`
- zoom `620.0`
- yaw `0.15`

The first view is intended to show the tank, HQ, nearby minerals, readable ground/grid, and compact HUD.

---

## 7. Scale

The shared `Tank3D.tscn` remains unchanged.

GameRoot applies an M2-only visual scale override to the spawned Tank3D:

```gdscript
tank.scale = Vector3.ONE * 0.12
```

This keeps the unit visually smaller than a 1x1 cell and prevents it from reading like a building. M2 movement values remain scaled for the 64-unit world:

- `move_speed = 240.0`
- `stop_distance = 16.0`
- `arrival_slowdown_distance = 120.0`
- `min_move_distance = 8.0`

---

## 8. Debug visualization

Debug visualization remains useful but is less noisy:

- full grid sampled every 8 cells instead of every 4
- lower alpha grid and footprint outlines
- smaller occupied-cell dots
- subtle map bounds
- export toggle: `show_debug_visualization`
- export step: `debug_grid_step_cells`

This should read as an RTS shell with debug overlay, not a pure debug map.

---

## 9. Placeholder assets

Placeholders remain intentionally temporary.

- HQ: compact blue 3x3 block, label `HQ 3x3`
- Minerals: small cyan 1x1 blocks, label `M`
- Infinite mineral: gold 2x2 block, label `Infinite 2x2`

`PlaceholderEntity` still stores entity data from `StartStateLoader` for inspection and later replacement.

---

## 10. Preserved M1 controls

Validated behavior:

- RTS camera node loads and starts current.
- LMB-style ray selection selects the Tank3D.
- Empty-ground selection clears the selected tank.
- RMB-style move command creates a Tank3D move target.
- Move target marker becomes visible.
- Move preview line becomes visible.
- Tank3D moves after command.
- Old M1E movement polish scene still loads.

---

## Local repair after first visual run

### What was wrong

- HUD panel was too large and felt like a debug block.
- HUD text used too many separate labels and the controls line was too long.
- `Selected` stayed `<none>` because the selection controller emitted no change signal.
- Camera started at map center instead of the player base/tank/mineral area.
- Tank3D read too large against 64-unit cells.
- Debug grid, footprint, and occupied-cell visualization were too dominant.
- Placeholder labels were too loud for first-run readability.

### What was changed

- Rebuilt the HUD as a compact `PanelContainer` around 300 px wide.
- Split controls into short readable lines.
- Combined resource values into a compact block.
- Added `selection_changed(selected_node: Node)` to `SelectionController3D`.
- Connected `SelectionController3D.selection_changed` in `GameRoot._wire_hud()`.
- Focused the camera on the HQ/tank/mineral start cluster.
- Applied M2-only Tank3D visual scale `0.12`.
- Disabled spawned Tank3D internal debug markers in GameRoot.
- Reduced debug grid density and alpha.
- Shrunk occupied-cell dots.
- Tuned placeholder sizes, colors, and labels.

### Local validation result

Godot 4.7 stable was downloaded to a temporary local folder for CLI validation:

```text
C:\Users\Den\AppData\Local\Temp\godot47\Godot_v4.7-stable_win64.exe
```

Version:

```text
4.7.stable.official.5b4e0cb0f
```

Runtime checks:

| Check | Result |
|---|---|
| `res://scenes/game/GameRoot.tscn` headless scene load | Pass |
| `res://scenes/units/Tank3D.tscn` headless scene load | Pass |
| `res://scenes/dev/M1E_MovementPolishTest.tscn` headless scene load | Pass |
| Normal display-driver launch of `GameRoot.tscn` | Pass |
| Automated HUD starts as `Selected: <none>` | Pass |
| Automated LMB-style ray selects Tank3D | Pass |
| Automated HUD selected updates to `Tank3D` | Pass |
| Automated empty-ground click clears selection | Pass |
| Automated RMB-style command creates active move target | Pass |
| Automated move target marker becomes visible | Pass |
| Automated move preview line becomes visible | Pass |
| Automated Tank3D moves after command | Pass |
| `git diff --check` on changed repair files | Pass |

Validation output:

```text
M2_RUNTIME_VALIDATION_PASS
```

### Remaining limitations

- Placeholder art is still temporary.
- Human editor F6 visual inspection is still useful for final subjective readability judgment.
- Economy, harvesting, construction, production, combat, pathfinding, AI, and win/loss remain out of M2 scope.

---

## Explicitly excluded from M2

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
- `project.godot` main scene changes
- medium (96x96) / huge (128x128) map sizes
- Phaser PNG asset migration
- multi-select

---

## Final status

```text
M2_LOCAL_VALIDATION_PASSED
```
