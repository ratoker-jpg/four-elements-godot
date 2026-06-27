# GODOT-M0 — Technical Vertical Slice

## Purpose

Prove that the Godot migration gives a cleaner and faster implementation path than Phaser + PNG matrix rendering.

## M0 must include

- 1 simple map / plane / grid;
- 1 orthographic/isometric camera;
- 1 Wasp hull;
- 1 Smoky turret;
- 1 assembled `Tank3D` scene;
- `TurretSocket`;
- `MuzzleSocket`;
- selection ring;
- placeholder health bar;
- click-to-move;
- hull rotates toward movement direction;
- turret rotates toward target;
- dummy target;
- projectile spawns from muzzle;
- factory placeholder;
- button to produce Wasp + Smoky.

## M0 must not include

- full economy;
- complete building tree;
- AI;
- multiplayer;
- all 7 hulls;
- all 10 turrets;
- M1/M2/M3;
- all factions;
- complete map editor;
- save/load;
- fog of war.

## Minimum success criteria

The migration is confirmed only if M0 shows:

1. Godot project opens.
2. Wasp + Smoky assembles as a 3D tank.
3. Turret sits correctly on the hull.
4. Projectile spawns from the muzzle.
5. Camera gives readable RTS/isometric view.
6. Tank can be selected and moved.
7. One tank can be produced through a factory placeholder.
8. Iteration is faster and cleaner than Phaser + PNG.

## Stop condition

If Wasp + Smoky cannot be assembled cleanly, stop and fix the asset pipeline first.

Do not build the full game on top of broken scale/origin/socket/muzzle assumptions.
