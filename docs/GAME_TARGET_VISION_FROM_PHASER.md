# GAME_TARGET_VISION_FROM_PHASER

Date: 2026-06-27
Status: draft source-of-truth for Godot migration planning
Project: Four Elements Godot
Source baseline: `ratoker-jpg/four-elements-phaser`

---

## 1. Why this document exists

Before implementing the Godot version, we need a stable image of the game we are rebuilding.

The goal is **not** to rewrite Four Elements from memory.

The goal is to extract the accepted game shape from:

- the Phaser repository;
- accepted Phaser roadmap/docs;
- existing code/configs;
- Denis' current product direction;
- modular asset workflow reports.

This document defines the target game that Godot should reproduce and improve.

---

## 2. Core game identity

Four Elements is a classic RTS in the spirit of StarCraft / Warcraft / mobile RTS games.

The player:

1. chooses a faction;
2. starts with a base and starting units;
3. gathers resources;
4. builds production/economy structures;
5. produces modular combat tanks;
6. controls territory and vision;
7. destroys enemy bases to win.

Godot should not turn this into a different genre.

It remains:

```text
base building + economy + modular tank combat + RTS control
```

---

## 3. Phaser baseline that matters

The Phaser project is not just a throwaway prototype.

It already contains:

- pure TypeScript game state layer;
- generated maps;
- factions;
- harvester loop;
- economy state;
- production state;
- builders and construction;
- RTS HUD/command-card work;
- selection/control groups;
- minimap/camera interaction;
- fog/vision;
- arena combat sandbox;
- modular hull/turret asset pipeline;
- accepted body/weapon/faction config data.

For Godot, the Phaser code should not be ported 1:1, but accepted behavior and data contracts should be treated as the first source to audit.

---

## 4. Factions

There are four core factions:

```text
cyan
purple
yellow
green
```

In the Phaser production config, these are represented as:

```text
cyan   — Поток
purple — Око
yellow — Искра
green  — Росток
```

Current accepted direction:

| Faction | Direction | Current config placeholder |
|---|---|---|
| cyan | mobility / fast tempo | civil unit production speed x1.1 |
| green | building / economy | building speed x1.1, processing speed x1.05 |
| yellow | combat production | combat unit production speed x1.1 |
| purple | vision / territory | territory vision radius +1 |

Rules:

- faction bonuses are passive;
- no active abilities at this stage;
- no unique faction tech trees at this stage;
- no direct damage bonus at this stage;
- exact balance is not final.

Godot should preserve faction identity as data-driven configs.

---

## 5. Victory and defeat

Target rule:

- victory: all enemy HQ/base structures are destroyed, or future diplomacy makes all remaining opponents allied/neutral;
- defeat: the player's HQ/base is destroyed.

Diplomacy/trade/alliance is future scope, not early implementation.

---

## 6. Starting state

Target start for the playable RTS loop:

```text
HQ / Base T1
2 harvesters
1 builder
1 starter combat tank: Wasp M0 hull + Smoky M0 turret
```

Phaser currently creates:

- HQ from map data;
- one builder in generated maps;
- two extra harvesters near HQ;
- optional starter modular-combat Wasp+Smoky M0 only when `includeModularCombat` is true.

Godot target:

- starter Wasp+Smoky M0 should be part of the normal playable baseline, not only dev/arena mode;
- start positions must avoid overlap and invalid tiles;
- starting units should spawn near HQ in valid adjacent tiles.

---

## 7. Camera and presentation

Phaser used a fixed isometric/axonometric 2.5D camera contract.

Godot should keep the gameplay readability:

- fixed isometric/orthographic RTS camera;
- player can pan;
- player can zoom;
- player cannot rotate camera during normal gameplay;
- ground markers, footprints, selection rings and ranges must respect the ground plane.

Godot can implement this with a real 3D orthographic camera instead of Phaser projection math, but the player-facing result should remain a readable isometric RTS view.

---

## 8. RTS UI target

The target UI is a classic RTS surface:

- main playfield;
- bottom HUD;
- minimap area;
- command card / hotkey grid;
- selected unit/building panel;
- resource display;
- queue/production status;
- feedback/status lane.

Phaser already has accepted UX work around:

- AoE4-inspired bottom HUD rebuild;
- command card with 4x3 grid;
- Q/W/E/R/A/S/D/F/Z/X/C/V style grid hotkeys;
- minimap camera interaction;
- selection/control groups;
- RTS feedback/alerts;
- fog/vision;
- final HUD polish.

Godot should not blindly copy Phaser UI code, but should keep the intended RTS UX:

- `1-9` selects control groups;
- `Ctrl+1-9` assigns control groups;
- Stop should remain a global command for selected units;
- command card should expose actions by selected entity type;
- hotkeys must not conflict with essential RTS group behavior.

---

## 9. Resources and economy

The current Phaser economy model has:

- raw minerals gathered by harvesters;
- processed matter used for construction;
- faction elements tracked internally as elementUnits;
- power generated/consumed by buildings;
- separators converting raw into matter + faction elements;
- storage caps for raw, matter and elements.

Current Phaser starting values:

```text
START_RAW = 30
START_MATTER = 120
HQ raw cap = 200
HQ matter cap = 200
HQ element cap = 200 elementUnits
HQ base power = 10
```

Current separator processing placeholder:

```text
12 raw -> 10 matter + 2 elementUnits
cycle: 5000 ms
active power consumption: 5
```

Godot target rule:

- minerals/raw are gathered in the world;
- matter/processed material is used for construction and production;
- power is a separate constraint/resource;
- elements/faction elementUnits are separate progression/production resource;
- avoid economy deadlocks where automatic conversion spends all build resource;
- exact naming can be cleaned up later, but the model must stay explicit.

---

## 10. Resources on map

Phaser has two related models.

Legacy resource type:

```text
small
medium
large
infinite
```

Legacy amounts:

```text
small = 20
medium = 60
large = 120
infinite = 999999
```

Accepted six-class production model:

```text
very_poor
poor
medium
rich
very_rich
infinite
```

Target map distribution:

- starter zone: many weak/small deposits around base;
- near start: some medium deposits;
- side/intermediate zones: medium/rich deposits;
- contested zones: rich/very rich deposits;
- center: infinite deposit.

Important harvester behavior:

- when idle/auto-gathering, harvester should choose resources by a stable rule that prioritizes the player's economic base loop;
- Denis' current rule: auto-search should be based from the base/HQ, not purely from the harvester's current position;
- if the player manually targets a specific deposit, that deposit becomes current priority;
- after the manually targeted deposit is done, harvester returns to normal automatic resource selection.

This differs from the current Phaser helper, which searches nearest resource by harvester position. Godot should implement Denis' target rule unless later changed.

---

## 11. Harvesters

Harvesters are civil units.

Expected behavior:

1. player can select a harvester;
2. player can press/trigger gather command;
3. harvester automatically finds an available resource;
4. harvester moves to an adjacent approach tile, not onto the resource tile;
5. harvester gathers;
6. harvester returns to HQ/base;
7. harvester unloads;
8. harvester repeats.

Manual control:

- player can manually move harvesters;
- player can manually click a specific resource to prioritize it;
- manual move should not permanently break the auto-gather loop.

Non-goals for early implementation:

- no complex worker AI;
- no advanced resource assignment UI;
- no multiple dropoff building logic unless already needed.

---

## 12. Builder and construction

Builder is a civil unit.

Denis' current target rule:

- player selects a builder;
- player chooses building type through command card/hotkey;
- builder/system automatically places the building near the builder;
- player does not need to manually pick the exact construction tile in the early version.

Placement rules:

- building must not overlap other buildings;
- building must not be adjacent/in contact if a spacing rule requires one empty tile;
- building must not overlap resources/obstacles;
- building should preserve at least one-tile spacing from resources and other blocked objects where practical;
- builder should be able to reach a valid adjacent construction tile;
- territory does not forbid construction unless a later design explicitly adds that rule.

Important correction against one Phaser roadmap path:

- Phaser Phase 9 proposed click-to-place and marked it as a Denis approval gate.
- Denis currently wants automatic near-builder placement, not manual exact tile placement.
- Therefore Godot should implement **builder-centric auto-placement**, not click-to-place, unless Denis later changes the UX.

---

## 13. Buildings and base tiers

Current accepted building IDs from Phaser production config:

```text
hq
separator
raw_storage
energy_storage
elements_storage
units_factory
power_plant
energy_reactor
repair_center
defense_tower
```

Early Godot target:

### T1 base

T1 starts the game and should support the first playable loop.

Available early production/building scope:

- HQ/Base T1;
- separator;
- storage as needed;
- power plant / basic power building as needed;
- units factory;
- maybe repair/defense later, not required for first slice unless already cheap.

### T2 / T3 base

Future scope:

- HQ can upgrade from T1 to T2 and T3;
- higher tiers unlock more hulls/turrets/buildings/production options;
- exact unlock table is not final yet.

Rule:

- do not design all T2/T3 balance now;
- reserve the tier system in data structures.

---

## 14. Units Factory

Units Factory is the main production building for civil and combat units.

Early T1 production target:

```text
builder
harvester
Wasp hull
Hunter hull
Smoky turret
Railgun turret
```

Default combat production:

- player chooses hull + turret;
- factory assembles a modular tank;
- initial production is M0;
- no combined hull×turret production matrix;
- any legal hull + turret combination is allowed unless explicitly restricted later.

Phaser roadmap already recommends hull and turret columns in a factory production panel, where total cost/time updates based on selected hull and turret.

---

## 15. Modular combat tanks

Combat units are modular tanks.

A tank is composed from:

```text
Hull + Turret
```

Godot target composition:

```text
Hull Mesh
+ Turret Mesh
+ TurretSocket / Marker3D on hull
+ MuzzleSocket / Marker3D on turret
+ faction material override
```

Accepted hulls from Phaser production config:

```text
wasp
hornet
hunter
viking
dictator
titan
mammoth
```

Accepted weapons/turrets from Phaser production config:

```text
smoky
thunder
railgun
flamethrower
freeze
isida
vulcan
twins
ricochet
hammer
```

The all-factions modular asset workflow also uses runtime turret id `vulcan_b`, which should be normalized/mapped to production id `vulcan` during Godot asset import.

---

## 16. Hull roles

Current Phaser body config placeholder roles:

| Hull | Role direction |
|---|---|
| wasp | light, fastest scout / hit-and-run |
| hornet | light raider / mobile fighter |
| hunter | universal medium / baseline |
| viking | medium-heavy brawler |
| dictator | medium-heavy support/control platform |
| titan | heavy frontline / stable firing platform |
| mammoth | super-heavy fortress |

M0-M3 rules:

- HP increases M0 -> M3;
- armor increases M0 -> M3;
- speed increases M0 -> M3;
- acceleration increases M0 -> M3;
- braking increases M0 -> M3;
- body turn speed increases M0 -> M3;
- mass does not change across M0-M3;
- footprint class does not change across M0-M3.

---

## 17. Turret / weapon roles

Current Phaser weapon config has 10 accepted weapons and fire type categories:

| Weapon | Fire type | Direction |
|---|---|---|
| smoky | cooldown | medium-range basic cannon |
| thunder | cooldown | medium-range splash/explosive |
| railgun | wind_up | long-range penetrating shot |
| flamethrower | canister_stream | short-range stream damage |
| freeze | canister_stream | short-range slow/freeze stream |
| isida | canister_stream + support | heal beam only |
| vulcan | overheat | rapid-fire spin-up weapon |
| twins | near_continuous | twin plasma shots |
| ricochet | magazine | charge/magazine projectile |
| hammer | drum | burst/shotgun weapon |

M0-M3 rules:

- damage/heal improves M0 -> M3;
- turret turn speed improves M0 -> M3;
- profile-specific parameters improve M0 -> M3;
- VFX readability should improve with higher M-levels;
- railgun remains slower-turning than short-range weapons.

---

## 18. Combat unit progression

Target rule from Denis:

- builder and harvester do not level up;
- combat tanks gain experience through killing enemies;
- once enough experience is available, player can upgrade either hull or turret;
- hull and turret M-levels are independent;
- max level is M3;
- a unit is fully maxed only when both hull and turret reach M3.

Example:

```text
Wasp M0 + Smoky M0
-> turret upgraded to Smoky M3
-> hull remains Wasp M0
-> unit still keeps earning/using XP until hull also reaches M3
```

Godot should model this as:

```text
hull_id
hull_mod_level
turret_id
turret_mod_level
xp
upgrade_state
```

Exact XP thresholds and upgrade costs are not final and should be defined in a dedicated balance config.

---

## 19. Movement and feel

Movement target:

- units move on/over a readable RTS ground plane;
- no idle bobbing for stationary units;
- acceleration/deceleration should communicate mass;
- light hulls accelerate and turn faster;
- heavy hulls feel slower and heavier;
- dust/track effects only while moving;
- turret can aim independently from hull direction.

Phaser already has movement/dust/animation direction as accepted concepts; Godot should implement them natively rather than copying Phaser render hacks.

---

## 20. Combat target model

Early combat target:

- starter tank can attack a dummy/static enemy target;
- projectile or shot spawns from turret muzzle;
- damage reduces HP;
- destroyed object is removed/marked destroyed.

Future combat target:

- enemies are real players/bots;
- target acquisition;
- attack/move commands;
- line-of-fire and obstacle interactions;
- weapon-specific VFX and effects.

---

## 21. Map generation

Current Phaser generated maps:

- deterministic seed using Mulberry32;
- map sizes: small 32x32, standard 48x48, large 64x64;
- sand/industrial styles;
- patch-based terrain, not per-cell noise;
- HQ in lower-left area;
- one builder near HQ;
- resource anchors using six-class model;
- obstacles/decor deferred because invisible blockers were worse than no blockers.

Godot target:

- deterministic generated maps;
- standard and large sizes at minimum;
- starter area around player HQ;
- mirrored/fair map generation before real enemy AI;
- obstacles visible before they block gameplay;
- center infinite deposit;
- no invisible blocking objects.

---

## 22. Fog, vision and territory

Phaser has implemented fog/vision in player-only MVP.

Godot target:

- unexplored / explored / visible state;
- HQ and units provide vision;
- purple faction can later increase territory/vision radius;
- territory control should be slow and readable;
- territory should not instantly recolor the map;
- territory should not block construction in the early model.

Territory spread target from previous decisions:

- cells color gradually;
- no instant flood fill;
- max spread radius from building around 10 cells;
- for a 2x2 building, cells under/around it should become controlled over time, not instantly.

---

## 23. Enemy AI

Enemy AI is future scope after playable human loop.

Difficulty should not simply mean stat cheating.

Target design:

| Difficulty | Expected behavior |
|---|---|
| Easy | simple scripted/logical actions, basic build/gather/attack |
| Medium | basic reasoning and adaptation, reacts to obvious threats |
| Hard | analyzes current situation, adapts production/scouting/attack/defense |

Do not begin full Enemy AI before:

- starting loop works;
- production works;
- modular units work;
- combat dummy works;
- map/fog/controls are stable.

---

## 24. Asset pipeline target

Godot should use real 3D source assets where possible.

Known asset workflow from uploaded/tooling docs:

- four factions: cyan, green, yellow, purple;
- 7 hulls;
- 10 turrets;
- 4 mods M0-M3;
- 16 directions in Phaser PNG workflow;
- modular production model: hull sprite separately, turret sprite separately, socket/pivot metadata separately;
- no combined hull×turret runtime matrix;
- expected old PNG workflow output: 1792 hull PNG + 2560 turret PNG = 4352 runtime PNG.

Godot should replace this with:

```text
.3ds / source model
-> Blender cleanup
-> .blend / .glb
-> Godot scene
```

Important imported metadata concepts:

- hull has turret socket / mount anchor;
- turret has pivot anchor;
- turret has muzzle point;
- Dictator has an accepted render scale override in the old PNG workflow, but in Godot the better fix is real 3D scale/origin validation, not PNG-frame hacks.

---

## 25. Godot migration principle

Do not port Phaser code directly.

Port:

- game rules;
- data contracts;
- configs;
- accepted UX decisions;
- asset metadata logic;
- testable behavior.

Do not port:

- PNG matrix renderer;
- Phaser scene architecture;
- manual sprite offset hacks;
- browser/canvas-specific render workarounds;
- dev-only arena paths as production architecture.

---

## 26. Suggested Godot milestones from this target vision

### GODOT-M0A — Bootstrap + migration docs

Already done.

### GODOT-M0B — Game Vision + Phaser Source Audit Docs

This document.

Scope:

- establish target game image;
- identify what Phaser already has;
- map what Godot should preserve;
- define contradictions/decisions before implementation.

### GODOT-M1 — 3D Asset Proof + Camera/Grid

Scope:

- orthographic/isometric camera;
- simple ground/grid;
- import Wasp and Smoky;
- create Tank3D scene with hull + turret + muzzle;
- select/move starter tank;
- shoot dummy.

### GODOT-M2 — Starting Base Loop

Scope:

- HQ T1;
- 2 harvesters;
- 1 builder;
- 1 Wasp+Smoky M0;
- resource deposits near base;
- harvester gather/unload loop;
- basic economy display.

### GODOT-M3 — Builder + Unit Factory Loop

Scope:

- builder-centric auto-placement;
- units factory;
- produce builder/harvester;
- produce Wasp/Hunter + Smoky/Railgun M0;
- production queue.

### GODOT-M4 — Combat Loop

Scope:

- dummy target;
- damage/HP/death;
- attack command;
- turret aiming;
- projectile/VFX from muzzle;
- basic win/lose placeholder.

### GODOT-M5 — Map/Fog/RTS UX

Scope:

- minimap;
- control groups;
- command card;
- fog/vision;
- basic territory layer;
- save/load draft.

### GODOT-M6 — Enemy AI Draft

Scope only after M1-M5 are stable.

---

## 27. Open decisions / contradictions to resolve

### 27.1 Resource names

Phaser uses:

```text
raw
matter
elementUnits
power
```

Denis often says:

```text
minerals
energy
elements
```

Need one player-facing vocabulary and one internal data vocabulary.

Recommended:

- player-facing: minerals, energy, elements;
- internal: raw/matter/power/elementUnits only if useful, but hidden from UI.

### 27.2 Builder placement

Phaser roadmap Phase 9 proposed click-to-place with Denis approval gate.

Current Denis direction is auto-placement near builder.

Recommended Godot decision:

- M1-M3: builder-centric auto-placement;
- later optional: advanced click-to-place mode if needed.

### 27.3 Harvester resource search origin

Current Phaser helper finds nearest resource from harvester position.

Current Denis direction: automatic resource search should be based from HQ/base unless player manually assigns a deposit.

Recommended Godot decision:

- auto-gather target scoring uses HQ/base distance first;
- manual targeted resource overrides until depleted/unavailable.

### 27.4 Combat unit unlocks per HQ tier

Current clear T1 target:

```text
Wasp
Hunter
Smoky
Railgun
```

T2/T3 unlock tables are not final.

Recommended:

- reserve data fields now;
- do not invent full unlock tree until design pass.

### 27.5 XP and upgrade cost

Concept is accepted; thresholds are not final.

Recommended:

- model XP and independent hull/turret M-levels early;
- balance later.

---

## 28. Immediate next useful work

Before runtime implementation, do one heavier audit PR or prompt for Codex/GLM:

```text
GODOT-M0C — Phaser Source Extraction Audit
```

Goal:

- inspect current Phaser repo in detail;
- extract exact configs for factions, bodies, weapons, resources, buildings, UI/hotkeys, production and map gen;
- create Godot migration mapping tables;
- identify what can be copied as data, what must be rewritten, what is obsolete.

Output docs:

```text
docs/PHASER_TO_GODOT_SYSTEM_MAP.md
docs/GODOT_IMPLEMENTATION_ROADMAP.md
docs/GODOT_DATA_MODEL_BASELINE.md
```

Only after that should Godot runtime implementation continue.
