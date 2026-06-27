# Asset Pipeline

## Rule

`.3ds` is raw source material.

`.blend` is the editable working source.

`.glb` is the preferred runtime import format for Godot.

## Source layout

```text
assets_src/
├─ 3ds/
│  ├─ hulls/
│  └─ turrets/
├─ blender/
│  ├─ hulls/
│  └─ turrets/
└─ generated/
```

## Godot runtime asset layout

```text
assets/
├─ models/
│  ├─ hulls/
│  ├─ turrets/
│  ├─ buildings/
│  └─ environment/
├─ materials/
├─ textures/
└─ ui/
```

## Pipeline

```text
.3ds / generated 3D model
↓
Blender cleanup
↓
.blend / .glb
↓
Godot scene
```

## Hull validation checklist

For every hull:

- scale is sane;
- origin is correct;
- forward direction is consistent;
- ground contact is correct;
- collision footprint is defined;
- `TurretSocket` exists;
- faction material slots are ready.

## Turret validation checklist

For every turret:

- origin is correct;
- rotation axis is correct;
- `MuzzleSocket` exists;
- recoil direction is clear;
- material slots are ready;
- scale matches target hulls.

## First asset proof

Only import and validate:

- Wasp hull;
- Smoky turret.

Do not import all hulls and turrets before the pipeline is proven.
