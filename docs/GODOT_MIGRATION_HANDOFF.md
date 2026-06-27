# Godot Migration Handoff

Date: 2026-06-27

## Short conclusion

We are not continuing Phaser as the main implementation engine.

Phaser remains useful as:

```text
mechanics reference
+ documentation source
+ UX/state/render prototype
+ baseline for gameplay rules
```

The new game should be built in **Godot 4.7** as a 3D RTS with an orthographic/isometric camera.

## Main reason

The Phaser project spends too much effort simulating 3D through PNG matrices:

```text
7 hulls
× 10 turrets
× M0-M3 modifications
× faction variants
× directions
× effects
× T1/T2/T3 buildings
```

This causes too much manual work around:

- asset count;
- offsets;
- pivot points;
- turret sockets;
- muzzle points;
- z-sort;
- fallback loading;
- visual QA.

## New asset model

Godot should use a normal 3D composition:

```text
Hull Mesh
+ Turret Mesh
+ TurretSocket / Marker3D
+ MuzzleSocket / Marker3D
+ faction material override
+ orthographic 3D camera
```

## Important asset context

There are `.3ds` models for hulls and turrets.

Expected source pipeline:

```text
.3ds / generated 3D model
↓
Blender cleanup
↓
.blend / .glb
↓
Godot scene
```

Godot will not magically convert PNG into good 3D.

## What to carry from Phaser

Carry over:

- accepted mechanics;
- UX contracts;
- game rules;
- resource logic;
- faction rules;
- harvester loop;
- territory rules;
- UI expectations.

Do **not** carry over:

- PNG matrix runtime;
- Phaser render hacks;
- manual offset tuner;
- full modular PNG preload;
- browser-specific smoke tooling;
- Phaser scene architecture as-is.

## M0 technical slice

The first milestone must prove the migration is worth it.

M0 should include:

- one map/plane/grid;
- orthographic isometric camera;
- one Wasp hull;
- one Smoky turret;
- one assembled `Tank3D`;
- `TurretSocket`;
- `MuzzleSocket`;
- selection ring;
- placeholder health bar;
- click-to-move;
- hull rotation to movement;
- turret aim to target;
- dummy target;
- projectile from muzzle;
- factory placeholder;
- button to produce Wasp + Smoky.

M0 should not include:

- full economy;
- AI;
- multiplayer;
- all hulls/turrets;
- M1/M2/M3;
- all factions;
- full map editor;
- save/load;
- fog of war.

## Process rule

Do not split work into Low/Medium micro-PRs.

Use:

- High;
- High+;
- Very High.

Small tasks belong inside acceptance criteria of larger PRs.
