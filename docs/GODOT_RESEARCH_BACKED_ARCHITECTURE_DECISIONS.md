# GODOT Research-backed Architecture Decisions

## 0. Purpose

This document records the architecture decisions extracted from the Godot/isometric transcript research pass.

It supplements:

- `docs/GODOT_AGGRESSIVE_GAME_ROADMAP.md`

The aggressive roadmap remains the main milestone plan. This document explains what the transcript research changes or reinforces before implementing `GODOT-M2`.

---

## 1. Research input

Source material:

- ZIP archive with English YouTube transcript files about Godot, isometric games, TileMap workflows, devlogs, terrain, collisions, and first playable releases.
- Follow-up research report: `Godot Transcript Research Report for Four Elements`.

Important limitation:

- The research analyzed transcripts only, not videos.
- Several sources are Godot 3.x, 2D TileMap, Unity, or general devlogs.
- Therefore, transcript findings should guide architecture, not be copied as direct Godot 4.7 API instructions.

---

## 2. Main conclusion

The research reinforces the roadmap decision:

> Stop polishing isolated tank details. Build the game through large High / High+ / Very High vertical slices.

M1 already proved the required technical foundation:

- 3DS/GLB asset path works.
- Tank3D works.
- RTS camera works.
- Selection works.
- Right-click movement works.
- Movement marker/preview works.
- Forward axis was fixed and visually validated.

Next priority is not turret/projectile polish.

Next priority is:

```text
GODOT-M2: Playable Game Shell + Map + Start State
```

---

## 3. Decisions confirmed by research

## 3.1. Separate game logic from visual scenes

Decision:

- Game rules must not live inside mesh/placeholder nodes only.
- Visual scenes package rendering and editor-friendly hierarchy.
- Logic systems own rules, state transitions, validation, and commands.

Implication for Four Elements:

- `Tank3D` remains a visual/runtime unit scene.
- Map cells, resource counts, building footprints, commands, construction, and production must live in systems/data.

M2 must introduce this separation early.

---

## 3.2. M2 must create `MapGrid`

Decision:

M2 must introduce a dedicated grid/world coordinate layer.

Required responsibilities:

```text
grid_to_world(cell)
world_to_grid(world_position)
is_in_bounds(cell)
cells_for_footprint(anchor_cell, footprint_size)
map_size_cells
cell_size_world
```

Why:

- Buildings, resources, units, selection, movement, placement, and economy all depend on a stable coordinate model.
- Without `MapGrid`, later construction/economy/combat work will attach rules directly to visual nodes and create architecture debt.

---

## 3.3. M2 should create `OccupancyGrid`, even if simple

Decision:

M2 should include a first version of `OccupancyGrid`.

Minimum responsibilities:

```text
mark_occupied(entity_id, cells)
clear_occupied(entity_id)
is_cell_free(cell)
are_cells_free(cells)
get_occupant(cell)
```

M2 use cases:

- HQ 3x3 footprint blocks cells.
- Standard minerals 1x1 block cells.
- Infinite mineral 2x2 blocks cells.
- Map bounds are validated.
- Debug overlay can show occupied cells.

Later use cases:

- M3 harvester/resource interactions.
- M4 construction placement validation.
- M5 production spawn validation.
- M6 death/despawn cleanup.

---

## 3.4. Entities should be scenes with metadata, not dead map tiles

Decision:

HQ, minerals, buildings, units, ghosts, resource nodes, factories, projectiles, and combat targets should be separate scenes/entities with metadata.

Minimum metadata examples:

```text
entity_id
entity_type
faction
footprint_size
anchor_cell
is_placeholder
replacement_note
```

For M2:

- `HQPlaceholder3x3`
- `MineralPlaceholder1x1`
- `InfiniteMineralPlaceholder2x2`
- current `Tank3D`

Do not represent these as painted static tiles only.

---

## 3.5. Placeholder policy is not optional

Decision:

If an asset is missing, use a placeholder and mark it clearly.

Every placeholder must be:

- clearly named;
- visually obvious as temporary;
- documented in the milestone report;
- easy to replace with a real asset;
- compatible with the future real scene contract;
- tagged with a replacement note.

Suggested note:

```gdscript
# PLACEHOLDER_ASSET: replace with final asset when available.
```

For M2 this applies to:

- HQ/base;
- standard minerals;
- infinite mineral;
- HUD visuals;
- ground/map visuals if no final assets exist.

---

## 3.6. Use old Phaser assets when available

Decision:

Before creating new placeholder art, check whether a usable asset exists in the old Phaser repository.

Priority:

1. Existing Godot assets.
2. Old Phaser repository assets.
3. Existing local 3DS/texture pipeline outputs.
4. Temporary placeholders.

Minerals/resources are explicitly allowed to come from the old Phaser repository.

Other usable assets from the Phaser repository may also be migrated if they help the vertical slice.

---

## 3.7. Do not use 2D TileMap/YSort as the foundation for the 3D RTS

Decision:

The research contains many useful 2D TileMap/YSort concepts, but Four Elements should not base its core architecture on 2D TileMap/YSort.

Reject as foundation:

- Godot 3.x `TileMap` API;
- 2D `YSort` as the core render model;
- manual TileMap painting as the RTS map pipeline;
- runtime tile replacement for buildings/resources;
- tutorial-only node paths and hardcoded scene references.

Keep conceptually:

- layered organization;
- grid/world coordinate separation;
- reusable props/entities;
- explicit collision/blocked areas;
- debug visibility for collision and footprints.

---

## 3.8. M2 should be fixed-map first, not procedural-generation first

Decision:

Do not start M2 with procedural map generation.

M2 should use a fixed deterministic start map:

```text
small 64x64
```

The map should include:

- visible ground;
- map bounds;
- player spawn;
- HQ placeholder 3x3;
- several standard minerals 1x1;
- one infinite mineral 2x2, preferably center/contested;
- one starting Tank3D;
- HUD placeholder.

Procedural generation can come later after the core loop exists.

---

## 3.9. M2 should include debug visualization

Decision:

M2 should include basic debug visibility for grid/footprints/occupancy.

Minimum debug overlay:

- map bounds;
- grid cells or sampled grid markers;
- HQ footprint;
- mineral footprints;
- infinite mineral footprint;
- occupied cells;
- maybe selected cell under cursor.

Why:

High-risk vertical slices need validation visibility. Without debug visibility, map/footprint bugs are too hard to diagnose.

---

## 3.10. HUD must not own game logic

Decision:

HUD displays state and sends player intent, but does not own economy/construction/production rules.

M2 HUD can be placeholder, but it should already follow this boundary.

M2 HUD minimum:

```text
Raw: 0
Energy: 0
Units: N
Selected: <entity name/type>
Controls hint
Debug status
```

Later:

- M3 updates Raw from `EconomyState`.
- M4 build panel sends build intent to `ConstructionSystem`.
- M5 production panel sends production intent to `ProductionSystem`.

---

## 4. M2 required architecture shape

M2 should implement a recognizable game shell using existing M1 controls.

Recommended structure:

```text
GameRoot.tscn
├── Systems
│   ├── MapGrid
│   ├── OccupancyGrid
│   ├── SelectionController3D        # existing/adapted
│   ├── MoveCommandController3D      # existing/adapted
│   └── StartStateLoader
├── MapRoot
│   ├── Ground                       # placeholder allowed
│   ├── Resources
│   ├── Buildings
│   ├── Units
│   ├── Markers
│   └── Debug
└── HUD                              # placeholder allowed
```

M2 must keep current features working:

- RTS camera;
- select starting Tank3D;
- right-click move;
- movement marker;
- movement preview;
- correct Tank3D forward direction.

---

## 5. M2 acceptance criteria update

M2 is successful only if all of these are true:

1. There is one clear scene to run from Godot.
2. It looks like the start of an RTS game, not a tank test.
3. The scene includes a visible map.
4. The scene includes HQ/base placeholder with 3x3 footprint.
5. The scene includes standard mineral placeholders with 1x1 footprint.
6. The scene includes an infinite mineral placeholder with 2x2 footprint.
7. The scene includes a starting Tank3D.
8. Tank selection and right-click movement still work.
9. HUD placeholder displays at least Raw, Energy, Units, Selected/Controls info.
10. MapGrid exists and is used by map/entity placement.
11. OccupancyGrid exists and stores HQ/mineral occupied cells.
12. Placeholders are clearly marked and documented.
13. The milestone report lists every placeholder and how to replace it.
14. No turret/projectile/combat/economy loop is added in M2 unless needed as a placeholder display only.

---

## 6. What M2 must not do

M2 must not expand into:

- turret aim;
- projectiles;
- damage;
- combat loop;
- full economy loop;
- harvester loop;
- building placement;
- production queue;
- AI enemy;
- procedural world generation;
- lighting/terrain polish;
- 2D TileMap/YSort migration.

These belong to later vertical slices.

---

## 7. Updated milestone emphasis

The aggressive roadmap remains:

| Milestone | Risk | Emphasis after research |
|---|---:|---|
| M2 — Playable Game Shell + Map + Start State | High | `GameRoot`, `MapGrid`, `OccupancyGrid`, fixed map, HQ/minerals/HUD placeholders |
| M3 — First Economy Loop | Very High | `ResourceNode`, harvester state, deposit to HQ, `EconomyState`, HUD update |
| M4 — Construction Loop | Very High | building ghost, footprint validation, cost, construction timer, completed building |
| M5 — Production Loop | High+ | factory, queue, timer, spawn new selectable/movable unit |
| M6 — Combat Loop | High+ | target, turret aim, projectile, hit, HP, death |
| M7 — Match Objective | Very High | enemy base/waves, win/loss, restart/return flow |

---

## 8. Open validation questions before/during M2

M2 must decide or document:

1. What is one tile in Godot world units?
2. Is footprint anchor center, top-left, bottom-left, or another convention?
3. Does right-click movement remain free 3D movement or snap to grid target cells?
4. Do units reserve occupancy cells or only buildings/resources reserve occupancy in M2?
5. How are placeholder entities marked in the scene tree?
6. Where is `MapGrid` stored: regular node under `Systems` or autoload?
7. Where is `OccupancyGrid` stored: regular node under `Systems` or autoload?
8. How does `HUD` receive selected entity/economy data without owning game logic?
9. How are Phaser assets imported if used for minerals/resources?

---

## 9. Final implementation instruction

Next implementation PR should be:

```text
GODOT-M2: GameRoot, MapGrid, Occupancy, Start State
```

This is the practical name for:

```text
GODOT-M2: Playable Game Shell + Map + Start State
```

M2 must be one large High-risk vertical slice that turns the project from a tank-control test into the first recognizable RTS game scene.
