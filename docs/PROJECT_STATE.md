# Project State

Date: 2026-06-28

## Decision

Four Elements is moving from the Phaser implementation to a new Godot 4.7 project.

The Phaser project remains a reference, not the new implementation base.

## Old active repository

```text
ratoker-jpg/four-elements-phaser
```

## New target repository

```text
ratoker-jpg/four-elements-godot
```

## Why migrate

The Phaser version became too expensive because the game needs a modular 3D-like vehicle system:

```text
7 hulls × 10 turrets × M0-M3 × factions × directions × effects × buildings
```

In Phaser/PNG this creates too much work around:

- offsets;
- pivots;
- sockets;
- muzzle origins;
- z-sort;
- preload/fallback;
- visual QA;
- large asset matrix.

## New direction

Build the game as a 3D RTS in Godot with:

- `Hull Mesh`;
- `Turret Mesh`;
- `TurretSocket` / `Marker3D`;
- `MuzzleSocket` / `Marker3D`;
- faction material override;
- orthographic/isometric camera.

## Current milestone

```text
GODOT-M0C — Phaser Source Extraction Audit (IN REVIEW via PR #3)
GODOT-M0D — Godot Tooling & Plugin Audit (IN REVIEW via PR #3, same PR)
```

PR #3 contains both M0C (source extraction audit) and M0D (tooling/plugin audit). After PR #3 is merged, the next milestone is **GODOT-M1 — 3D Asset Proof + Camera/Grid**.

## Milestone sequence

```text
M0C (Phaser source extraction audit)   [IN REVIEW PR #3]
  ↓
M0D (Godot tooling & plugin audit)     [IN REVIEW PR #3]
  ↓
M1 (3D asset proof + camera/grid)
  ↓
M2 (starting base + harvester + economy)
  ↓
M3 (builder construction + unit factory loop)
  ↓
M4 (combat loop — T1 slice: Smoky + Railgun)
  ↓
M4B (weapon mechanics expansion)
  ↓
M5A (map + fog + territory)
  ↓
M5B (RTS UX + save/load)
  ↓
M6 (enemy AI draft)
```

See `docs/GODOT_IMPLEMENTATION_ROADMAP.md` for full milestone details.

## Source-of-truth docs

Read before project work:

```text
docs/PHASER_TO_GODOT_SYSTEM_MAP.md
docs/GODOT_DATA_MODEL_BASELINE.md
docs/GODOT_IMPLEMENTATION_ROADMAP.md
docs/GODOT_TOOLING_PLUGIN_AUDIT.md
docs/GAME_TARGET_VISION_FROM_PHASER.md
docs/GODOT_M0_TECHNICAL_SLICE.md
docs/ASSET_PIPELINE.md
docs/GODOT_MIGRATION_HANDOFF.md
docs/GAME_DESIGN_BASELINE.md
```

## Out of scope for current PR (#3)

- gameplay implementation;
- full economy;
- AI;
- multiplayer;
- all hulls/turrets;
- full asset import;
- save/load;
- fog of war;
- full map editor;
- plugin installation (M0D is docs-only audit).
