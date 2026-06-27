# GODOT_IMPLEMENTATION_ROADMAP

Date: 2026-06-28
Status: docs-only — proposed Godot implementation roadmap after Phaser source extraction audit
Project: Four Elements Godot
Source baseline: `ratoker-jpg/four-elements-phaser`

---

## 1. Purpose

This document proposes a Godot implementation roadmap after the Phaser source extraction audit (GODOT-M0C). It defines milestones GODOT-M0C through GODOT-M6, each sized High / High+ / Very High.

**Process rule**: Do not split work into Low/Medium micro-PRs. Each milestone is one substantial PR. Small tasks belong inside acceptance criteria of larger milestones.

---

## 2. Milestone overview

| Milestone | Name | Size | Depends on |
|---|---|---|---|
| GODOT-M0C | Phaser Source Extraction Audit | High | (this PR — docs only) |
| GODOT-M0D | Godot Tooling & Plugin Audit | High | M0C |
| GODOT-M1 | 3D Asset Proof + Camera/Grid | Very High | M0D |
| GODOT-M2 | Starting Base + Harvester + Economy | Very High | M1 |
| GODOT-M3 | Builder Construction + Unit Factory Loop | Very High | M2 |
| GODOT-M4 | Combat Loop (T1 Slice: Smoky + Railgun) | High+ | M3 |
| GODOT-M4B | Weapon Mechanics Expansion | High+ | M4 |
| GODOT-M5A | Map + Fog + Territory | Very High | M4B |
| GODOT-M5B | RTS UX + Save/Load | Very High | M5A |
| GODOT-M6 | Enemy AI Draft | High+ | M5B |

**Total estimated effort**: 9 milestones, all High+ or Very High.

**Critical path**: M0C → M0D → M1 → M2 → M3 → M4 → M4B → M5A → M5B → M6

**Stop condition**: If M1 cannot assemble Wasp+Smoky cleanly in 3D, stop and fix the asset pipeline first. Do not build on broken scale/origin/socket/muzzle assumptions.

**Note on M5 split**: M5 was originally one epic milestone bundling map/fog/territory + RTS UX + save/load. It has been split into M5A (map/fog/territory) and M5B (RTS UX + save/load) to keep each PR at a reviewable Very High scope.

---

## 3. GODOT-M0C — Phaser Source Extraction Audit

**Size**: High (docs-only)

### Goal

Extract accepted Phaser game rules, data configs, and UX decisions into Godot docs so runtime implementation can proceed without repeatedly re-reading the Phaser repo.

### Scope

- Create `docs/PHASER_TO_GODOT_SYSTEM_MAP.md` — system-by-system mapping table.
- Create `docs/GODOT_DATA_MODEL_BASELINE.md` — baseline data tables (factions, hulls, weapons, resources, buildings, production, starting state).
- Create `docs/GODOT_IMPLEMENTATION_ROADMAP.md` — this document.

### Non-goals

- No runtime implementation.
- No asset changes.
- No package/dependency changes.
- No tests.
- No Phaser code porting.

### Source references from Phaser

- `docs/project/CODEMAP.md`
- `docs/project/FINAL_RTS_FOUNDATION_ROADMAP_2026_06_22.md`
- `docs/project/CAMERA_PROJECTION_CONTRACT.md`
- `src/state/types.ts`, `src/state/createInitialState.ts`, `src/state/updateGameState.ts`
- `src/state/production.ts`, `src/state/construction.ts`, `src/state/builder.ts`
- `src/state/generatedMap.ts`, `src/state/visibility.ts`
- `src/config/coreMechanicsTypes.ts`, `src/config/factionData.ts`, `src/config/bodyData.ts`, `src/config/weaponData.ts`, `src/config/resourceClassData.ts`, `src/config/localization.ts`
- HUD/input files: `commandCardGrid.ts`, `commandPanelViewModel.ts`, `GameInputController.ts`, `HudMinimap.ts`, `controlGroups.ts`, `unitSelection.ts`

### Godot files likely affected

- `docs/PHASER_TO_GODOT_SYSTEM_MAP.md` (new)
- `docs/GODOT_DATA_MODEL_BASELINE.md` (new)
- `docs/GODOT_IMPLEMENTATION_ROADMAP.md` (new)
- `docs/GODOT_TOOLING_PLUGIN_AUDIT.md` (new — M0D audit, included in this PR)
- `docs/PROJECT_STATE.md` (update — mark M0C done, next is M0D then M1)
- `docs/CURRENT_NEXT_STEP.md` (update — next is M0D)

### Acceptance criteria

- All four docs exist and are readable Markdown.
- System map covers all 25 systems listed in PHASER_TO_GODOT_SYSTEM_MAP.md §3.
- Data model baseline includes all 7 tables (factions, hulls, weapons, resources, buildings, production, starting state) with correct values from `resourceClassData.ts`.
- Roadmap has 9 milestones (M0D, M1, M2, M3, M4, M4B, M5A, M5B, M6) each with goal/scope/non-goals/source references/acceptance criteria/validation/risks/size.
- Tooling audit doc covers 8 categories with at least 8-12 tools evaluated.
- Contradictions section explicitly lists the open decisions.
- No "TBD" without explaining what source is missing and what decision is required.
- `PROJECT_STATE.md` and `CURRENT_NEXT_STEP.md` updated to point at M0D as next step (not stale M0A/M0B).

### Validation

- Markdown files are readable (visual check).
- Internal links/paths are correct where possible.
- No runtime validation needed (docs-only).

### Risks

- Audit may miss Phaser files not in the read list. Mitigation: CODEMAP.md was read first as routing map.
- Data values may be stale if Phaser repo advanced past the audited commit. Mitigation: shallow clone at latest main was used.

### Estimated size: High

---

## 3B. GODOT-M0D — Godot Tooling & Plugin Audit

**Size**: High (docs-only / tooling decision)
**Risk**: Medium
**Depends on**: M0C

### Goal

Evaluate Godot Asset Store / editor addons before starting runtime implementation, and decide which tools are worth adopting for Four Elements. This is an **audit first** — do NOT install plugins in this milestone.

### Scope

- Audit Godot Asset Store / editor addons across 8 categories (see `docs/GODOT_TOOLING_PLUGIN_AUDIT.md`).
- For each tool, evaluate: potential value, runtime dependency, maintenance risk, Godot 4.7 compatibility, license, and recommendation.
- Produce a recommendation table in `docs/GODOT_TOOLING_PLUGIN_AUDIT.md`.
- Default stance: do not install plugins unless they clearly reduce work and have low lock-in.
- For M1, prefer simple native Godot implementation: custom RTS camera, simple plane/grid, no terrain plugin, no AI plugin, no Git plugin dependency.

### Non-goals

- No plugin installation.
- No `addons/` directory changes.
- No `project.godot` plugin activation.
- No runtime implementation.
- No asset changes.

### Source references

- Godot Asset Library (https://godotengine.org/asset-library/asset)
- Godot 4.7 documentation
- `docs/ASSET_PIPELINE.md` — existing asset pipeline decisions
- `docs/GODOT_M0_TECHNICAL_SLICE.md` — M0 scope that M0D informs

### Godot files likely affected

- `docs/GODOT_TOOLING_PLUGIN_AUDIT.md` (new — the audit document)
- `docs/GODOT_IMPLEMENTATION_ROADMAP.md` (this document — link to audit)

### Acceptance criteria

- `docs/GODOT_TOOLING_PLUGIN_AUDIT.md` exists and is readable Markdown.
- Audit covers at least 8 categories: Git/source control, project visibility/AI assistance, terrain/map editing, camera helpers, GDScript formatting/code quality, state machines/AI behavior, editor readability/custom icons, debugging/logging.
- At least 8-12 specific tools evaluated in the recommendation table.
- Each tool has: category, potential value, runtime dependency?, maintenance risk, Godot 4.7 compatibility, recommendation, notes.
- Decision rule documented: default = do not install; plugins allowed later only if compatible with 4.7, actively maintained, MIT/compatible license, easy to remove, not required for core gameplay unless explicitly approved.
- M1 explicitly scoped to use native Godot only (no plugins).

### Validation

- Markdown file is readable.
- No `addons/` directory created.
- No `project.godot` changes.
- No runtime files changed.

### Risks

- **Audit scope creep**: Evaluating too many tools delays M1. Mitigation: cap at 8-12 tools across 8 categories; spend max 1-2 hours.
- **Stale compatibility info**: Godot 4.7 is recent; some addons may not be updated yet. Mitigation: check addon's last update date and Godot version compatibility on Asset Library.
- **Decision reversal**: A tool rejected in M0D may become useful later. Mitigation: mark decisions as "defer" rather than "reject" where appropriate; allow re-audit at any milestone.

### Estimated size: High

---

## 4. GODOT-M1 — 3D Asset Proof + Camera/Grid

**Size**: Very High

### Goal

Prove that the Godot migration gives a cleaner and faster implementation path than Phaser + PNG matrix rendering. Assemble Wasp+Smoky as a real 3D tank with correct sockets and muzzle.

### Scope

- Import Wasp hull `.3ds`/`.glb` into Godot.
- Import Smoky turret `.3ds`/`.glb` into Godot.
- Create `Tank3D` scene: `MeshInstance3D` (hull) + `TurretSocket` (Marker3D) + `MeshInstance3D` (turret, child of TurretSocket) + `MuzzleSocket` (Marker3D on turret).
- Add `CollisionShape3D` for hull footprint.
- Add faction material override (cyan/green/yellow/purple).
- Add orthographic/isometric camera (fixed angle, pan + zoom, no rotation).
- Add simple ground/grid scene (flat plane with grid texture or `MeshInstance3D`).
- Add selection ring (projected on ground plane, NOT screen-space circle).
- Add placeholder health bar (billboard or projected).
- Add click-to-move: LMB selects tank, RMB issues move command.
- Hull rotates toward movement direction.
- Turret rotates toward target independently.
- Add dummy target (static `StaticBody3D` with HP).
- Add projectile spawn from `MuzzleSocket`.
- Add factory placeholder (simple box building) with button to produce Wasp+Smoky.

### Non-goals

- Full economy.
- Full building tree.
- AI.
- Multiplayer.
- All 7 hulls (only Wasp).
- All 10 turrets (only Smoky).
- M1/M2/M3 progression.
- All 4 factions (only cyan, or cyan+green for material proof).
- Complete map editor.
- Save/load.
- Fog of war.
- Minimap.
- Command card grid.
- Control groups.

### Source references from Phaser

- `src/config/bodyData.ts` — Wasp hull stats (hp 130, mass 2200, armor 2, speed 11.5, footprintClass light).
- `src/config/weaponData.ts` — Smoky weapon stats (directDamage 16, cooldown 900ms, range medium 1-7, turretTurnSpeed 130).
- `src/config/coreMechanicsTypes.ts` — `BodyConfig`, `WeaponConfig`, `MLevelData` types.
- `docs/project/CAMERA_PROJECTION_CONTRACT.md` — camera rules (fixed isometric, no rotation, ground-plane projection).
- `docs/ASSET_PIPELINE.md` — `.3ds → .blend → .glb → Godot scene` pipeline.

### Godot files likely affected

- `assets/models/hulls/wasp.glb` (new)
- `assets/models/turrets/smoky.glb` (new)
- `assets/materials/faction_cyan.tres`, `faction_green.tres`, `faction_yellow.tres`, `faction_purple.tres` (new)
- `scenes/units/Tank3D.tscn` (new)
- `scenes/units/hulls/wasp.tscn` (new)
- `scenes/units/turrets/smoky.tscn` (new)
- `scenes/environment/Ground3D.tscn` (new)
- `scenes/main/Playground.tscn` (new — M1 test scene)
- `scripts/units/TankController.gd` (new)
- `scripts/units/TurretController.gd` (new)
- `scripts/camera/RTSCamera3D.gd` (new)
- `scripts/units/Projectile.gd` (new)
- `scripts/units/DummyTarget.gd` (new)
- `resources/hulls/wasp.tres` (new — data resource)
- `resources/weapons/smoky.tres` (new — data resource)
- `resources/factions/cyan.tres` (new — data resource)

### Acceptance criteria

- Godot project opens without errors.
- Wasp hull imports with correct scale, origin, forward direction, ground contact.
- Smoky turret imports with correct origin, rotation axis, muzzle point.
- `Tank3D` scene assembles: hull + turret on TurretSocket + MuzzleSocket on turret.
- Turret sits correctly on hull (no floating, no clipping).
- Projectile spawns from MuzzleSocket (not from hull center).
- Orthographic camera gives readable RTS/isometric view.
- Camera can pan (WASD or edge scroll) and zoom (wheel).
- Camera cannot rotate.
- Tank can be selected (LMB click → selection ring appears on ground).
- Tank can be moved (RMB click → hull rotates toward target, moves).
- Turret can aim at dummy target independently of hull direction.
- Projectile hits dummy target, reduces HP, dummy is destroyed at 0 HP.
- Factory placeholder button produces a Wasp+Smoky tank (appears near factory).
- Faction material override works (cyan tank vs green tank visually distinct).
- Iteration is faster and cleaner than Phaser + PNG.

### Validation

- Godot project opens without errors.
- No console warnings about missing assets.
- `npm`-equivalent: Godot has no built-in test runner; manual QA is primary.
- If Godot unit tests are added later (e.g. GUT framework), add tests for:
  - Tank3D assembly (hull + turret + sockets exist).
  - Projectile spawn position = MuzzleSocket global position.
  - Hull rotation toward move target.

### Risks

- **Asset scale/origin issues**: `.3ds` files may have inconsistent scales or origins. Mitigation: validate in Blender first; document expected scale/origin in `ASSET_PIPELINE.md`.
- **Camera angle mismatch**: Phaser is 2.5D isometric; Godot 3D orthographic may look different. Mitigation: match Phaser camera constants (TILE_W=76, TILE_H=38 → 2:1 isometric ratio) as starting point.
- **Muzzle position drift**: If MuzzleSocket is placed wrong, projectiles spawn from incorrect positions. Mitigation: visual debug gizmo showing MuzzleSocket global position.
- **Performance**: 3D rendering may be slower than Phaser 2D for same scene complexity. Mitigation: use simple meshes in M1; optimize later.

### Estimated size: Very High

---

## 5. GODOT-M2 — Starting Base + Harvester + Economy

**Size**: Very High

### Goal

Establish the starting base and economy loop: HQ + 2 harvesters + 1 builder + 1 Wasp+Smoky M0 tank + resource deposits + harvester gather/unload loop + economy display. M2 focuses on the **harvester/economy loop only** — no builder construction, no build commands, no units factory.

### Scope

- Create HQ building scene (3×3 footprint, T1). HQ is pre-placed at game start (not built by player).
- Create harvester unit scene (civil unit, gather/deliver loop).
- Create builder unit scene (civil unit, selectable + movable, but **no construction state machine** — that is M3).
- Place starting state: HQ at lower-left, 2 harvesters NE of HQ, 1 builder NE of HQ, 1 Wasp+Smoky M0 tank NE of HQ.
- Place resource deposits near HQ (very_poor/poor/medium classes per Phaser anchor model).
- Implement harvester state machine: idle → moving-to-resource → gathering → returning-to-hq → unloading → repeat.
- **HQ-centered auto-search**: harvester auto-gather scoring uses HQ distance, NOT harvester position (Denis direction, contradicts Phaser).
- Manual resource click override: player clicks specific deposit → harvester targets it until depleted → returns to auto-gather.
- Implement economy state: raw/minerals, matter/energy, element_units/elements, power.
- Implement separator processing (12 raw → 10 matter + 2 elementUnits per 5000ms cycle, 5 power) — separator is **pre-placed** or placeholder for economy validation.
- Implement power system (HQ base 10 + power-plant 15 each) — power-plant is **pre-placed** or placeholder for economy validation.
- Implement storage cap bonuses (+200 per storage building) — storage buildings are **pre-placed** or placeholder.
- Implement resource display in UI (top-left strip: minerals/energy/elements/power).

### Non-goals

- **Builder construction state machine** (M3) — builder exists as a unit but cannot build.
- **Build commands** (M3) — no Q/W/E/R/A/F build hotkeys.
- **Building auto-placement** (M3) — no placement system.
- **Construction progress / building completion** (M3).
- **Units factory** (M3).
- Combat (M4).
- Map generation (M5A — use fixed test map for M2).
- Fog of war (M5A).
- Minimap (M5B).
- Command card grid (M5B).
- Control groups (M5B).
- Save/load (M5B).
- Enemy AI (M6).
- Click-to-place building UX (deferred — auto-placement only).
- T2/T3 HQ tiers (deferred).
- XP/upgrade system (deferred).

### Source references from Phaser

- `src/state/createInitialState.ts` — starting state factory, extra harvesters, starter modular combat.
- `src/state/updateGameState.ts` — harvester state machine, economy tick (`allocatePowerAndProcess`, `recomputePower`).
- `src/state/types.ts` — `EconomyState`, `HarvesterState`, all economy constants.
- `src/config/coreMechanicsTypes.ts` — `AcceptedBuildingId`, `BuildingConfig`, `ResourceClassConfig`.
- `src/config/resourceClassData.ts` — 6-class resource amounts (150-50000).
- `src/config/localization.ts` — Russian labels for economy, buildings, status.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §3-9 — extracted data tables.

### Godot files likely affected

- `scenes/buildings/HQ.tscn` (new — pre-placed)
- `scenes/buildings/Separator.tscn` (new — pre-placed/placeholder for economy validation)
- `scenes/buildings/PowerPlant.tscn` (new — pre-placed/placeholder)
- `scenes/buildings/RawStorage.tscn` (new — pre-placed/placeholder)
- `scenes/buildings/MatterStorage.tscn` (new — pre-placed/placeholder)
- `scenes/buildings/ElementStorage.tscn` (new — pre-placed/placeholder)
- `scenes/units/Harvester.tscn` (new)
- `scenes/units/Builder.tscn` (new — selectable/movable, no construction yet)
- `scenes/environment/ResourceDeposit.tscn` (new)
- `scenes/main/GameScene.tscn` (new — main game scene)
- `scripts/state/GameState.gd` (new — autoload)
- `scripts/state/Economy.gd` (new)
- `scripts/state/HarvesterStateMachine.gd` (new)
- `scripts/ui/ResourceStrip.gd` (new)
- `resources/buildings/*.tres` (new — one per building type)
- `resources/resources/*.tres` (new — one per resource class)

### Acceptance criteria

- Game starts with HQ + 2 harvesters + 1 builder + 1 Wasp+Smoky M0 tank.
- Resources visible near HQ (at least 4 deposits: 2 very_poor, 1 poor, 1 medium).
- Harvester auto-gathers: moves to nearest resource (by **HQ distance**, not harvester position), gathers 1000ms, returns to HQ, unloads 500ms, repeats.
- Manual resource click: click deposit → harvester targets it → after depletion, returns to auto-gather.
- Economy display updates: raw/minerals increases when harvester unloads, matter/energy + elements increase when separator processes.
- Separator processes: consumes 12 raw, produces 10 matter + 2 elementUnits per 5000ms cycle, consumes 5 power.
- Power display: HQ provides 10, power-plant provides +15 each.
- Storage caps enforced: raw cap 200 (base) + 200 per raw-storage building.
- Builder unit exists, is selectable, can be moved (RMB), but **cannot build** (no construction state machine).
- No build commands available (Q/W/E/R/A/F do nothing or are unmapped).
- No crashes on save/load attempt (save/load itself is M5B).

### Validation

- Manual QA: start game → verify starting state → harvester loop → economy updates → separator processing.
- Economy invariants: raw + matter + elements never go negative.
- Power: consumed <= generated (separators pause if insufficient power).
- Harvester pathfinding: grid-based A* on flat test map (no navmesh required for M2).

### Risks

- **Harvester pathfinding**: Use deterministic grid A* mapped to 3D coordinates (mirrors Phaser BFS). Do NOT use NavigationServer3D/navmesh for M2 — test grid pathfinding on flat ground first; revisit navmesh only if grid proves insufficient.
- **HQ-centered auto-search**: Contradicts Phaser (harvester-position search). Mitigation: implement as `findNearestResourceFromHq(state, harvester)`; document the decision.
- **Economy deadlock**: If separator consumes all raw, no construction happens in M2 (no builder). Mitigation: separator pauses when raw < 12; no deadlock possible without construction.
- **Pre-placed buildings**: Pre-placing separator/power-plant/storage for economy validation means M3 must add the ability to build them. Mitigation: pre-placed buildings use the same scenes/resources as M3-built buildings — no rework needed.

### Estimated size: Very High

---

## 6. GODOT-M3 — Builder Construction + Unit Factory Loop

**Size**: Very High

### Goal

Implement builder construction loop (build commands, auto-placement, construction progress, building completion) and units factory production (produce builder/harvester/Wasp+Smoky M0 from the factory).

### Scope

- Implement builder construction state machine: idle → moving-to-site → building → idle.
- Implement builder-centric auto-placement: builder selects building type → system finds nearest valid tile near builder → builder moves to adjacent tile → construction progresses.
- Implement build commands: Q=separator, W=raw-storage, E=matter-storage, R=element-storage, A=power-plant, F=units-factory (auto-placement near builder).
- Implement construction progress: builder arrives at site → progress advances → building completed → builder returns to idle.
- Implement building completion: register completed building into economy (separator → processing, storage → cap bonus, units-factory → production state).
- Implement units factory building scene (2×2 footprint, cost 120 matter, 40000ms build time).
- Implement production queue (limit 2, no refund on cancel).
- Implement `startUnitProduction(state, factoryTx, factoryTy, request)` for:
  - Builder (40 matter, 10 elements, 15000ms)
  - Harvester (50 matter, 10 elements, 20000ms)
  - Wasp+Smoky M0 (45 matter, 10 elements, 25000ms) — structured request `{hullId:'wasp', turretId:'smoky', mod:'m0'}`
- Implement production tick: factory consumes 4 power while active, progress advances, completed item spawns unit near factory.
- Implement `spawnCombatUnit(state, tx, ty, request)` — creates `ModularCombatUnit` with `bodyId`, `weaponId`, `mod`, `faction`, `id`.
- Implement unit cap (DEFAULT_UNIT_CAP=10, includes all controllable units: builders + harvesters + combat units — GODOT DECISION).
- Implement factory production UI: select factory → see production buttons (builder/harvester/wasp-smoky) → click to enqueue.
- Implement queue display: show progress bars for queue items.
- Implement cancel queue item (no refund).

### Non-goals

- Hull/turret selection UI (Phase 3 of Phaser roadmap — two-column FactoryProductionPanel).
- M1/M2/M3 production (deferred — M0 only).
- Dynamic hull+turret cost calculation (deferred — use reserved constants).
- XP/upgrade system (deferred).
- Combat (M4).
- Map generation (M5A).
- Fog of war (M5A).
- Minimap (M5B).
- Command card grid (M5B — use simple buttons for M3).
- Control groups (M5B).
- Save/load (M5B).

### Source references from Phaser

- `src/state/production.ts` — `startUnitProduction`, `cancelFactoryQueueItem`, cost lookup helpers.
- `src/state/updateGameState.ts` — `allocatePowerAndProcess`, `processFactorySpawns`, `spawnBuilder`, `spawnHarvesterUnit`.
- `src/state/builder.ts` — `assignIdleBuilders`, `updateBuilders`, `releaseBuilder`.
- `src/state/construction.ts` — `placeConstructionSite`, `updateConstructionSiteProgress`, `BUILDING_CONFIG`.
- `src/state/types.ts` — `ProducibleUnitType`, `ProductionQueueItem`, `UnitFactoryRuntimeState`, production constants.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §7 — production data tables.

### Godot files likely affected

- `scenes/buildings/UnitsFactory.tscn` (new)
- `scripts/state/ProductionSystem.gd` (new)
- `scripts/state/BuilderStateMachine.gd` (new)
- `scripts/state/ConstructionSystem.gd` (new)
- `scripts/state/PlacementSystem.gd` (new — auto-placement near builder)
- `scripts/units/CombatUnit.gd` (new — ModularCombatUnit controller)
- `scripts/ui/FactoryPanel.gd` (new — simple production buttons, not full two-column panel)
- `scripts/ui/QueueDisplay.gd` (new)
- `resources/production/*.tres` (new — production cost configs)

### Acceptance criteria

- Builder can be selected → build command issued (Q/W/E/R/A/F) → building auto-placed near builder → builder moves to site → construction progresses → building completed → builder returns to idle.
- Completed separator registers into economy and begins processing.
- Completed storage building applies cap bonus (+200).
- Completed units-factory registers into production state.
- Units factory can be built (cost 120 matter, 40000ms).
- Select factory → production buttons appear (builder/harvester/wasp-smoky).
- Click builder button → 40 matter + 10 elements deducted → queue item added → progress bar advances (15000ms) → builder spawns near factory.
- Click harvester button → 50 matter + 10 elements deducted → 20000ms → harvester spawns.
- Click wasp-smoky button → 45 matter + 10 elements deducted → 25000ms → Wasp+Smoky M0 tank spawns near factory.
- Queue limit enforced (max 2 items).
- Cancel queue item: item removed, no refund.
- Unit cap enforced: cannot produce beyond 10 total units (builders + harvesters + combat units).
- Factory pauses production if insufficient power (progress preserved, not reset).
- Cannot produce without sufficient matter/elements (blocked reason shown).
- Builder/harvester production still works after combat unit production is added.

### Validation

- Manual QA: build factory → produce each unit type → verify costs/timing/spawn position.
- Production invariants: matter/elements never go negative.
- Queue invariant: queue length <= 2.
- Unit cap invariant: total units <= 10.
- Power invariant: factory pauses when power insufficient.

### Risks

- **Structured production key**: Phaser uses flat string `'wasp-smoky'`; Godot should use structured `CombatProductionRequest`. Mitigation: design `CombatProductionRequest` resource from the start.
- **Spawn position**: combat unit may spawn on occupied tile. Mitigation: ring search around factory (same as Phaser `findSpawnPosition`).
- **Power allocation**: Phaser allocates power in build order (separators first, then factories). Mitigation: Godot should use same order to avoid factories starving separators.
- **Cancel during production**: No refund means player loses resources. Mitigation: confirm dialog for cancel of in-progress item (UI polish, not blocker).

### Estimated size: Very High

---

## 7. GODOT-M4 — Combat Loop (T1 Slice: Smoky + Railgun)

**Size**: High+

### Goal

Implement the **T1 combat slice only**: tanks can attack dummy targets with Smoky (cooldown projectile) and Railgun (wind-up penetration ray), deal damage using the target's armor, destroy targets, and die. All other weapon mechanics are deferred to M4B.

### Scope

- Implement `CombatSystem` autoload: damage calculation, hit detection, death handling.
- Implement `DamageCalculator`: `finalDamage = max(rawDamage - targetArmor, rawDamage * targetMinDamagePercent)` — uses **target's** armor and minDamagePercent, not attacker's.
- Implement projectile spawning from `MuzzleSocket` (Smoky: projectile; Railgun: instant ray).
- Implement hit detection via Godot 3D physics (`RayCast3D` for railgun instant hit, `Area3D` for smoky projectile).
- Implement target acquisition: RMB on enemy/dummy → tank acquires target → turret rotates toward target → fires when in range and turret aligned.
- Implement **T1 weapon fire types only**:
  - Smoky: `cooldown` fire type, directDamage 16 (M0), cooldown 900ms, projectile travels to target.
  - Railgun: `wind_up` fire type, directDamage 32 (M0), windUp 800ms, cooldown 3000ms, penetration (max 3 targets in a line via RayCast3D).
- Implement penetration (railgun: max 3 targets along the ray).
- Implement HP/death: unit/dummy HP reaches 0 → destroyed → removed from scene.
- Implement dummy target scene (static `StaticBody3D` with HP, armor, minDamagePercent — no AI).
- Implement basic win/lose placeholder: destroy all dummy targets → "Victory" message.

### Non-goals

- **All non-T1 weapon mechanics** (deferred to M4B): Thunder splash, Flamethrower stream, Freeze stream/slow, Isida heal beam, Vulcan overheat, Twins near-continuous, Ricochet magazine/bounce, Hammer drum/shotgun.
- **Splash damage** (deferred to M4B — Thunder).
- **Continuous damage / stream weapons** (deferred to M4B — Flamethrower/Freeze/Isida).
- **Heal beam** (deferred to M4B — Isida).
- **Overheat mechanic** (deferred to M4B — Vulcan).
- Enemy AI (M6).
- Attack-move / formations / patrol / hold-position.
- Shift-queue commands.
- Multi-unit target coordination (each tank targets independently).
- Full VFX polish (basic projectiles only).
- Audio/SFX.
- All 7 hulls (Wasp only for M4 minimal validation; Hunter acceptable if already exists from M3, but not required).
- M1/M2/M3 upgrades (M0 only).
- XP system (deferred).
- Fog of war affecting combat (M5A).

### Source references from Phaser

- `src/config/weaponData.ts` — Smoky and Railgun configs (fire type, damage, cooldown, range, profile-specific).
- `src/config/bodyData.ts` — HP/armor arrays for Wasp (and Hunter if used).
- `src/state/blockoutDamage.ts` — damage application, hit detection (reference only — Godot uses 3D physics, not screen-space math).
- `src/state/combatHitModel.ts` — projected hit detection (reference for damage model, not geometry).
- `src/state/weaponFireCoordinator.ts` — fire coordination logic.
- `src/state/combatTargeting.ts` — target acquisition/clearing.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §3-4 — hull/weapon data tables.

### Godot files likely affected

- `scripts/combat/CombatSystem.gd` (new — autoload)
- `scripts/combat/DamageCalculator.gd` (new)
- `scripts/combat/Projectile.gd` (new — reusable projectile scene for Smoky)
- `scripts/combat/HitDetector.gd` (new — RayCast3D for Railgun, Area3D for Smoky projectile)
- `scripts/units/TurretController.gd` (update — add target acquisition + fire logic for Smoky + Railgun)
- `scripts/units/CombatUnit.gd` (update — add HP, death, target management)
- `scenes/units/DummyTarget.tscn` (new)
- `scenes/effects/Projectile.tscn` (new)
- `resources/weapons/smoky.tres` (new — M0 stats)
- `resources/weapons/railgun.tres` (new — M0 stats)

### Acceptance criteria

- Wasp+Smoky M0 tank can attack dummy target.
- RMB on dummy → turret rotates toward dummy → fires when aligned and in range.
- Smoky projectile spawns from MuzzleSocket, travels toward target, hits target.
- Railgun wind-up plays → instant ray from MuzzleSocket → hits first target → penetrates up to 3 targets in a line.
- **Damage formula uses target's armor** (not attacker's):
  - Dummy target defined with: `armor = 0`, `minDamagePercent = 1.0` (no damage reduction).
  - Smoky M0 directDamage = 16 → `finalDamage = max(16 - 0, 16 * 1.0) = 16`.
  - If target is a Wasp M0 (armor 2, minDamagePercent 0.25): `finalDamage = max(16 - 2, 16 * 0.25) = max(14, 4) = 14`.
- Dummy HP decreases; at 0 HP, dummy is destroyed (removed from scene).
- Tank death: HP 0 → unit removed from scene → selection cleared if selected.
- "Victory" message when all dummy targets destroyed.

### Validation

- Manual QA: spawn Wasp+Smoky tank + dummy → attack → verify damage/HP/death.
- Damage formula test: `finalDamage = max(rawDamage - targetArmor, rawDamage * targetMinDamagePercent)`.
- Penetration test (Railgun): ray hits up to 3 targets in order.
- Turret alignment test: turret does not fire until within threshold (e.g. 5 degrees) of target.

### Risks

- **3D hit detection vs Phaser screen-space**: Phaser uses screen-space geometry; Godot uses 3D physics. Results may differ for edge cases (glancing hits, friendly fire). Mitigation: use `Area3D` overlap for projectiles; `RayCast3D` for instant-hit weapons.
- **Turret alignment**: Turret must be aligned with target before firing. Mitigation: check `turretAngle` vs `angleToTarget` within threshold (e.g. 5 degrees).
- **Damage formula confusion**: Damage must use **target's** armor/minDamagePercent, not attacker's. Mitigation: `DamageCalculator` takes `(rawDamage, targetArmor, targetMinDamagePercent)` — attacker stats are not inputs to damage reduction.
- **Railgun penetration edge cases**: Ray may hit fewer than 3 targets if targets are not in a line. Mitigation: penetration count is a maximum, not a guarantee.

### Estimated size: High+

---

## 7B. GODOT-M4B — Weapon Mechanics Expansion

**Size**: High+
**Depends on**: M4

### Goal

Expand combat to support all remaining weapon fire types beyond the T1 Smoky + Railgun slice implemented in M4.

### Scope

- Implement splash damage (Thunder: radius 1.5, falloff, selfDamageScale 0.3).
- Implement continuous damage / stream weapons (Flamethrower: DPS 24, canister; Freeze: DPS 12 + slow effect).
- Implement heal beam (Isida: healPerSecond 20, target ally, no damage).
- Implement overheat mechanic (Vulcan: heatPerShot, maxHeat, cooling, overheatPenalty, spinUp).
- Implement near-continuous fire (Twins: cooldown 650ms, plasma projectiles).
- Implement magazine + bounce (Ricochet: stockSize 4-6, regen, bounce on hit).
- Implement drum/shotgun burst (Hammer: volleyCount 3, pelletCount 5, delayBetweenVolleys, reload).
- Add weapon resources for all 8 expanded weapons (M0 stats).
- Add VFX routing per `vfxProfileKey`.

### Non-goals

- Enemy AI (M6).
- Attack-move / formations / patrol / hold-position.
- M1/M2/M3 weapon upgrades (M0 only for M4B).
- XP system (deferred).
- Fog of war affecting combat (M5A).
- Audio/SFX.

### Source references from Phaser

- `src/config/weaponData.ts` — all 10 weapon configs (fire type, damage, cooldown, profile-specific).
- `src/state/blockoutDamage.ts` — `tickContinuousDamage`, `findSplashTargets`, `findConeTargets`, `findBeamTargets`, etc.
- `src/state/weaponFireCoordinator.ts` — fire coordination for all fire types.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §4 — full weapon data table.

### Godot files likely affected

- `scripts/combat/CombatSystem.gd` (update — add splash, stream, overheat, magazine, drum handlers)
- `scripts/combat/StreamWeaponController.gd` (new — for canister_stream weapons)
- `scripts/combat/OverheatController.gd` (new — for Vulcan)
- `scripts/combat/MagazineController.gd` (new — for Ricochet)
- `scripts/combat/DrumController.gd` (new — for Hammer)
- `scripts/combat/HealBeam.gd` (new — for Isida)
- `resources/weapons/thunder.tres`, `flamethrower.tres`, `freeze.tres`, `isida.tres`, `vulcan.tres`, `twins.tres`, `ricochet.tres`, `hammer.tres` (new)

### Acceptance criteria

- Thunder: splash damage applied to all targets within 1.5 tiles of impact, with falloff.
- Flamethrower: continuous DPS while fireHeld, canister drains/regens.
- Freeze: continuous DPS + slow effect on target.
- Isida: heal beam on ally, no damage to enemy.
- Vulcan: overheat mechanic — heat accumulates per shot, overheats at maxHeat, penalizes, cools down.
- Twins: near-continuous plasma projectiles, cooldown 650ms.
- Ricochet: magazine of 4-6 shots, regenerates over time, bounces on hit.
- Hammer: drum burst — 3 volleys of 5 pellets, delay between volleys, reload after.
- All weapons fire from MuzzleSocket.
- All weapons use `DamageCalculator` with target's armor.

### Validation

- Manual QA: spawn tank + dummy for each weapon type → verify mechanic works.
- Splash radius test: targets within radius take damage, outside do not.
- Heal test: Isida heals ally, does not damage enemy.
- Overheat test: Vulcan overheats after N shots, penalizes, cools down.
- Magazine test: Ricochet depletes stock, regenerates, bounces.

### Risks

- **Continuous damage timing**: Stream weapons deal damage per tick, not per shot. Mitigation: use `tickContinuousDamage` pattern from Phaser (cadence check via `lastDamageTickAt`).
- **Overheat balance**: Heat accumulation/cooldown must be server-authoritative. Mitigation: track heat in `CombatUnit` state, not in turret node.
- **VFX complexity**: 8 new weapon VFX profiles. Mitigation: route via `vfxProfileKey` to a `VFXController` child node; implement one profile at a time.
- **Magazine/bounce edge cases**: Ricochet bounce may hit friendly units or bounce off-map. Mitigation: clamp bounce count, friendly-fire rule.

### Estimated size: High+

---

## 8. GODOT-M5A — Map + Fog + Territory

**Size**: Very High
**Depends on**: M4B

### Goal

Implement deterministic map generation (including mirrored maps for PvP fairness), fog of war, and territory spread. This is the first half of the original M5 — it focuses on the world/map layer.

### Scope

- Implement `MapGenerator`: deterministic seed (Mulberry32 or Godot `RandomNumberGenerator`), sizes (small 32×32, standard 48×48, large 64×64), patch-based terrain, anchor-based 6-class resource placement, HQ at lower-left, 1 builder NE of HQ, center infinite deposit (footprint 2).
- Implement mirrored map generation for PvP fairness (mirror one half).
- Implement fog of war: three-state tile (unexplored/explored/visible), diamond radius vision, full recompute per frame. Vision sources: HQ (8), buildings (per config), builders (4), harvesters (5). Purple faction +1 to all.
- Implement territory layer: gradual spread from owned buildings, max radius 10, 45-60s for 2×2 building, does not block construction.

### Non-goals

- Minimap (M5B).
- Command card grid (M5B).
- Control groups (M5B).
- Selection model / drag-box (M5B).
- Input routing / RTS controls (M5B).
- Save/load (M5B).
- Full HUD (M5B).
- Enemy AI (M6).
- Attack-move / formations / patrol / hold-position.
- Shift-queue commands.
- Audio/SFX/music.
- Multiplayer.
- Tutorial.
- Mobile/touch.
- Multi-language beyond Russian.

### Source references from Phaser

- `src/state/generatedMap.ts` — map generation, Mulberry32, anchor-based resources, validation.
- `src/state/visibility.ts` — fog/vision system, `VisionState`, `collectVisionSources`, `recomputeVisibility`.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §5, §10 — resource class data + vision constants.

### Godot files likely affected

- `scripts/state/MapGenerator.gd` (new)
- `scripts/state/FogOfWar.gd` (new)
- `scripts/state/TerritorySystem.gd` (new)
- `scenes/environment/MapRoot.tscn` (new — map container)

### Acceptance criteria

- Map generation: seed "test" + standard size → deterministic 48×48 map with HQ at (4,41), resources near HQ, center infinite deposit (footprint 2).
- Mirrored map: two player HQs at mirrored positions, resources mirrored.
- Fog of war: unexplored tiles black, explored tiles dimmed, visible tiles clear. HQ provides vision radius 8.
- Territory: building placement → territory spreads gradually over 45-60s, max radius 10, does not block construction.
- Map determinism: same seed → same map.

### Validation

- Manual QA: generate map → verify resources/HQ/center deposit → fog/vision → territory spread.
- Map determinism: same seed → same map.
- Fog: no vision through unexplored tiles.
- Territory: does not block construction.

### Risks

- **Mirrored map fairness**: Mirror may not produce perfectly fair maps if terrain patches are random. Mitigation: generate one half, mirror it.
- **Fog performance**: Full recompute per frame may be slow for large maps (64×64 = 4096 tiles × N sources). Mitigation: dirty-flag recompute (only when sources change), incremental update.
- **Territory gradual spread**: Phaser doesn't implement this. Mitigation: use wave-front propagation (BFS from owned buildings, one cell per N ms).

### Estimated size: Very High

---

## 8B. GODOT-M5B — RTS UX + Save/Load

**Size**: Very High
**Depends on**: M5A

### Goal

Implement the full RTS UX layer: minimap, command card grid, control groups, selection, input routing, HUD, and save/load. This is the second half of the original M5.

### Scope

- Implement minimap: `SubViewport` camera, click-to-center, drag-to-pan, fog layer, selection highlights, pings.
- Implement command card grid: 4×3 grid (Q W E R / A S D F / Z X C V), context-aware (builder/harvester/factory/multi-select/none).
- Implement control groups: Ctrl+1-9 assign, 1-9 recall, double-tap centers camera.
- Implement selection: LMB select, Shift+click toggle, drag-box multi-select, double-click same-type.
- Implement RTS controls: LMB=select only, RMB=command (move/harvest/attack), S=stop, Esc=priority chain (cancel → deselect → close overlay → pause).
- Implement save/load: Godot resource serialization, versioned saves, migration helpers.
- Implement full HUD: bottom bar (200px safe-area), resource strip (top-left), selection panel, queue display, feedback/status lane.

### Non-goals

- Map generation (M5A).
- Fog of war (M5A).
- Territory (M5A).
- Enemy AI (M6).
- Attack-move / formations / patrol / hold-position.
- Shift-queue commands.
- Audio/SFX/music.
- Multiplayer.
- Tutorial.
- Mobile/touch.
- Multi-language beyond Russian.

### Source references from Phaser

- `src/phaser/ui/hud/HudMinimap.ts` + `minimapViewModel.ts` — minimap renderer + view model.
- `src/phaser/ui/hud/commandCardGrid.ts` + `commandPanelViewModel.ts` — command card grid + view model.
- `src/state/controlGroups.ts` — `ControlGroupManager`.
- `src/state/unitSelection.ts` — selection model.
- `src/phaser/input/GameInputController.ts` — input routing.
- `src/state/commandRouter.ts` — `routeLmbClick`, `routeRmbClick`, `routeSKey`, `routeEscKey`.
- `src/phaser/ui/hud/hudLayout.ts` — HUD layout constants.
- `src/state/saveGame.ts` — save/load reference.

### Godot files likely affected

- `scripts/state/SelectionManager.gd` (new — autoload)
- `scripts/state/ControlGroupManager.gd` (new — autoload)
- `scripts/state/SaveSystem.gd` (new — autoload)
- `scripts/ui/HudMinimap.gd` (new)
- `scripts/ui/CommandCard.gd` (new)
- `scripts/ui/SelectionPanel.gd` (new)
- `scripts/ui/ResourceStrip.gd` (update)
- `scripts/ui/QueueDisplay.gd` (update)
- `scripts/ui/FeedbackLane.gd` (new)
- `scripts/input/InputRouter.gd` (new — LMB/RMB/S/Esc routing)
- `scenes/ui/Hud.tscn` (new — full HUD scene)
- `scenes/main/GameScene.tscn` (update — wire HUD)

### Acceptance criteria

- Minimap: click to center camera, drag to pan, fog layer visible, selection highlights pulse.
- Command card: select builder → Q=separator, W=raw-storage, E=matter-storage, R=element-storage, A=power-plant, F=units-factory, S=stop. Select factory → production buttons appear.
- Control groups: Ctrl+1 assigns selected units → 1 recalls → double-tap 1 centers camera.
- Selection: LMB selects, Shift+click toggles, drag-box multi-selects, double-click selects all same-type in viewport.
- RTS controls: LMB=select, RMB=move/harvest/attack, S=stop, Esc=priority chain.
- Save/load: save game → load game → state restored (economy, units, buildings, vision explored grid).
- HUD: bottom bar 200px, resource strip top-left, selection panel, queue display, feedback lane.

### Validation

- Manual QA: minimap → command card → control groups → save/load.
- Save/load: round-trip preserves all state.
- Control groups: 9 groups, double-tap centering works.

### Risks

- **Save/load compatibility**: Godot resource serialization may change between versions. Mitigation: version field + migration helpers (same pattern as Phaser).
- **Input routing complexity**: Phaser's `GameInputController` is 1352 lines. Mitigation: split into `InputRouter` (pure routing) + `InputController` (Phaser/Godot adapter).

### Estimated size: Very High

---

## 9. GODOT-M6 — Enemy AI Draft

**Size**: High+
**Depends on**: M5B

### Goal

Implement a basic enemy AI that can gather resources, build a base, produce units, and attack the player. Difficulty is behavior-based, not stat-based.

### Scope

- Implement `EnemyAI` autoload: per-faction AI controller.
- Implement difficulty levels: Easy (scripted), Medium (adaptive), Hard (analytical).
- Easy: scripted build order (HQ → separator → power-plant → units-factory → produce units → attack at threshold).
- Medium: reacts to player threats (if player attacks, defend; if player expands, scout).
- Hard: analyzes player economy/army composition, adapts production and attack timing.
- Implement AI harvester control: auto-gather (same HQ-centered rule as player).
- Implement AI builder control: auto-placement (same as player).
- Implement AI factory control: produce combat units based on difficulty.
- Implement AI combat control: acquire targets, move to attack, retreat when low HP.
- Implement AI win/lose: destroy player HQ = AI wins; player destroys AI HQ = player wins.
- Implement "no enemy AI before playable loop" rule: AI only activates after M1-M5B are stable.

### Non-goals

- Multiplayer AI (single-player vs AI only).
- Multiple AI personalities (one per difficulty).
- Diplomacy/alliance.
- AI tutorial mode.
- AI cheating (no stat bonuses for higher difficulty — behavior only).
- Campaign.
- Replay system.

### Source references from Phaser

- `src/state/blockoutAi.ts` — Arena dev AI (passive/stationary_shooter/chaser/hold_position) — reference only, not production AI.
- `docs/GAME_TARGET_VISION_FROM_PHASER.md` §23 — enemy AI design direction.
- `docs/GAME_DESIGN_BASELINE.md` — difficulty = behavior, not stat cheating.

### Godot files likely affected

- `scripts/ai/EnemyAI.gd` (new — autoload)
- `scripts/ai/AIController.gd` (new — per-faction controller)
- `scripts/ai/AIEconomy.gd` (new — harvester/builder management)
- `scripts/ai/AIProduction.gd` (new — factory management)
- `scripts/ai/AICombat.gd` (new — combat control)
- `scripts/ai/AIDifficulty.gd` (new — difficulty enum + behavior selection)
- `resources/ai/*.tres` (new — difficulty configs)

### Acceptance criteria

- Easy AI: builds HQ → separator → power-plant → units-factory → produces 3 combat units → attacks player at 5-minute mark.
- Medium AI: scouts player at 3 minutes, reacts to player attacks (recalls units to defend), expands to second resource zone at 7 minutes.
- Hard AI: analyzes player army composition, counters with appropriate units, attacks when player economy is weak.
- AI does NOT cheat (no extra resources, no stat bonuses).
- AI cannot see through fog of war (respects same vision rules as player).
- Win condition: destroy all AI HQ buildings → "Victory".
- Lose condition: player HQ destroyed → "Defeat".
- AI does not activate in sandbox/playground mode (M1 scene).

### Validation

- Manual QA: start game vs Easy AI → survive 10 minutes → AI attacks at 5 min → destroy AI HQ → victory.
- AI fairness: AI starts with same resources as player.
- AI vision: AI cannot react to units it cannot see (fog of war respected).
- Difficulty scaling: Hard AI wins more often than Easy AI (statistical, not deterministic).

### Risks

- **AI complexity**: Full strategic AI is very expensive to build. Mitigation: start with Easy (scripted), add Medium/Hard incrementally.
- **AI fairness**: If AI gets free resources, it's not behavior-based. Mitigation: AI uses same `EconomyState` as player, no cheats.
- **AI fog cheating**: AI must not read player unit positions through fog. Mitigation: AI maintains its own `VisionState`, only reacts to visible player units.
- **AI deadlock**: AI may get stuck if build order fails (no valid placement, insufficient resources). Mitigation: fallback build order, retry logic.
- **Performance**: AI decision-making every frame is expensive. Mitigation: AI tick at 500ms intervals (not every frame).

### Estimated size: High+

---

## 10. Milestone dependency graph

```text
M0C (Phaser source extraction audit)
  ↓
M0D (Godot tooling & plugin audit)
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

All milestones are sequential — no parallelism. Each milestone depends on the previous one being merged and stable.

---

## 11. Process rules

### 11.1 PR sizing

- Each milestone is one PR.
- No Low/Medium micro-PRs.
- Small tasks belong inside acceptance criteria of the milestone PR.
- Sizes: High, High+, Very High only.

### 11.2 Merge gate

- Denis must manually QA each milestone before merge.
- Visual/runtime PRs need Denis visual approval even if tests pass.
- M1 has a stop condition: if Wasp+Smoky cannot be assembled cleanly, stop and fix asset pipeline first.

### 11.3 Non-goals across all milestones

- No Phaser code porting (rules/data only).
- No PNG matrix recreation.
- No full modular preload.
- No combined hull×turret production matrix.
- No number keys 1-9 for build commands (control groups only).
- No click-to-place building UX (auto-placement only, unless Denis later approves).
- No enemy AI before playable loop is stable (M1-M5B).
- No multiplayer.
- No mobile/touch.
- No audio/SFX/music (deferred).
- No plugin installation before M0D audit (M0D is docs-only; plugins only allowed after explicit approval per M0D decision rule).

---

## 12. Maintenance rule

Update this document when:
- A milestone is started (mark as "IN PROGRESS").
- A milestone is merged (mark as "DONE via PR #xxx").
- Scope changes (update scope/non-goals/acceptance criteria).
- Risks are realized (update risk notes).
- Denis changes a design decision (update milestone scope).

Keep this document as the single source of truth for Godot implementation sequencing until all milestones are complete.
