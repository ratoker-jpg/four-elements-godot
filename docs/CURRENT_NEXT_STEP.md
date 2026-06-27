# Current Next Step

Date: 2026-06-28

## Current task

```text
GODOT-M0C — Phaser Source Extraction Audit (IN REVIEW via PR #3)
GODOT-M0D — Godot Tooling & Plugin Audit (IN REVIEW via PR #3, same PR)
```

## Goal

PR #3 contains both M0C and M0D:
- M0C: Extract accepted Phaser game rules, data configs, and UX decisions into Godot docs.
- M0D: Audit Godot Asset Store / editor addons before starting runtime implementation.

## Acceptance criteria (PR #3)

- `docs/PHASER_TO_GODOT_SYSTEM_MAP.md` — 25 systems mapped.
- `docs/GODOT_DATA_MODEL_BASELINE.md` — 7 data tables with correct values from Phaser source (including `resourceClassData.ts`).
- `docs/GODOT_IMPLEMENTATION_ROADMAP.md` — 9 milestones (M0D, M1, M2, M3, M4, M4B, M5A, M5B, M6).
- `docs/GODOT_TOOLING_PLUGIN_AUDIT.md` — 8 categories, 11 tools evaluated.
- `docs/PROJECT_STATE.md` — updated to point at M0C/M0D (not stale M0A/M0B).
- `docs/CURRENT_NEXT_STEP.md` — this file, updated.
- No runtime code, assets, configs, tests, or dependencies changed.
- No plugins installed.

## Next implementation milestone after PR #3 merge

```text
GODOT-M1 — 3D Asset Proof + Camera/Grid (Very High)
```

Expected scope:
- import one Wasp hull;
- import one Smoky turret;
- clean/export via Blender if assets are ready;
- assemble `Tank3D` scene with `TurretSocket` and `MuzzleSocket` markers;
- add orthographic/isometric camera (custom `RTSCamera3D.gd`, no Phantom Camera);
- add simple ground/grid scene;
- add selection placeholder;
- add dummy target;
- add projectile from `MuzzleSocket`;
- add factory placeholder button to produce Wasp+Smoky.

**Stop condition**: If Wasp+Smoky cannot be assembled cleanly in 3D, stop and fix the asset pipeline first.

See `docs/GODOT_IMPLEMENTATION_ROADMAP.md` §4 for full M1 details.

## Do not start yet

- full economy (M2);
- builder construction (M3);
- combat (M4);
- weapon mechanics expansion (M4B);
- map generation / fog (M5A);
- RTS UX / save-load (M5B);
- AI (M6);
- multiplayer;
- all 7 hulls;
- all 10 turrets;
- M1/M2/M3 progression;
- complete map editor;
- plugin installation (M0D audit decides; default = no plugins for M1).
