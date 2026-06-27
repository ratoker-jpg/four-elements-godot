# Current Next Step

## Current task

`GODOT-M0A — Godot Project Bootstrap + Migration Docs`

## Goal

Create the initial Godot repository baseline so the project can be opened locally and used by GLM/Codex for the first real implementation step.

## Acceptance criteria

- `project.godot` exists.
- Minimal main scene exists.
- Godot-specific `.gitignore` exists.
- Folder structure exists through `.gitkeep` placeholders.
- Documentation baseline exists.
- No Phaser code is ported.
- No bulk asset import is done.
- No generated Godot cache is committed.

## Next implementation task after this PR

`GODOT-M0B — Camera + Grid + Tank3D Asset Proof`

Expected scope:

- import one Wasp hull;
- import one Smoky turret;
- clean/export via Blender if assets are ready;
- assemble `Tank3D` scene;
- add `TurretSocket` and `MuzzleSocket` markers;
- add orthographic/isometric camera;
- add simple ground/grid scene;
- add selection placeholder.

## Do not start yet

- full economy;
- AI;
- multiplayer;
- all 7 hulls;
- all 10 turrets;
- M1/M2/M3;
- complete map editor;
- save/load;
- fog of war.
