# Four Elements Godot

New **Godot 4.7** implementation of **Four Elements**.

## Status

This repository is the new target implementation for Four Elements.

The previous Phaser repository remains useful as:

- mechanics reference;
- UX/state/render prototype;
- documentation source;
- gameplay rules baseline.

Phaser code should **not** be ported 1:1.

## Goal

Build Four Elements as a 3D RTS with:

- modular tanks: hull mesh + turret mesh;
- `TurretSocket` and `MuzzleSocket` markers;
- faction material overrides;
- orthographic/isometric camera;
- readable RTS controls and HUD;
- gradual M0 technical vertical slice first.

## Open locally

Recommended local path:

```text
D:\Projects\four-elements-godot
```

Clone:

```bash
git clone https://github.com/ratoker-jpg/four-elements-godot.git
cd four-elements-godot
```

Open in Godot:

1. Start Godot 4.7.
2. Choose **Import / Open project**.
3. Select this repository folder.
4. Open `project.godot`.

## Current milestone

`GODOT-M0 — Technical Vertical Slice`

See:

- `docs/GAME_TARGET_VISION_FROM_PHASER.md`
- `docs/PROJECT_STATE.md`
- `docs/CURRENT_NEXT_STEP.md`
- `docs/GODOT_M0_TECHNICAL_SLICE.md`
- `docs/ASSET_PIPELINE.md`
- `docs/GODOT_MIGRATION_HANDOFF.md`

## Development rule

Do not split implementation into Low/Medium micro-PRs.

Use:

- High
- High+
- Very High

Small tasks should be acceptance criteria inside larger implementation steps.
