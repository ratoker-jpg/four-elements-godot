# Project State

Date: 2026-06-27

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

`GODOT-M0 — Technical Vertical Slice`

The current PR only bootstraps the repository and documentation baseline.

## Out of scope for current bootstrap

- gameplay implementation;
- full economy;
- AI;
- multiplayer;
- all hulls/turrets;
- full asset import;
- save/load;
- fog of war;
- full map editor.
