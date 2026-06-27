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
| GODOT-M1 | 3D Asset Proof + Camera/Grid | Very High | M0C |
| GODOT-M2 | Starting Base Loop | Very High | M1 |
| GODOT-M3 | Builder + Unit Factory Loop | Very High | M2 |
| GODOT-M4 | Combat Loop | High+ | M3 |
| GODOT-M5 | Map/Fog/RTS UX | Very High | M4 |
| GODOT-M6 | Enemy AI Draft | High+ | M5 |

**Total estimated effort**: 6 milestones, all High+ or Very High.

**Critical path**: M0C → M1 → M2 → M3 → M4 → M5 → M6

**Stop condition**: If M1 cannot assemble Wasp+Smoky cleanly in 3D, stop and fix the asset pipeline first. Do not build on broken scale/origin/socket/muzzle assumptions.

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
- `src/config/coreMechanicsTypes.ts`, `src/config/factionData.ts`, `src/config/bodyData.ts`, `src/config/weaponData.ts`, `src/config/localization.ts`
- HUD/input files: `commandCardGrid.ts`, `commandPanelViewModel.ts`, `GameInputController.ts`, `HudMinimap.ts`, `controlGroups.ts`, `unitSelection.ts`

### Godot files likely affected

- `docs/PHASER_TO_GODOT_SYSTEM_MAP.md` (new)
- `docs/GODOT_DATA_MODEL_BASELINE.md` (new)
- `docs/GODOT_IMPLEMENTATION_ROADMAP.md` (new)
- `docs/PROJECT_STATE.md` (update — mark M0C done)
- `docs/CURRENT_NEXT_STEP.md` (update — next is M1)

### Acceptance criteria

- All three docs exist and are readable Markdown.
- System map covers all 25 systems listed in PHASER_TO_GODOT_SYSTEM_MAP.md §3.
- Data model baseline includes all 7 tables (factions, hulls, weapons, resources, buildings, production, starting state).
- Roadmap has 6 milestones (M1-M6) each with goal/scope/non-goals/source references/acceptance criteria/validation/risks/size.
- Contradictions section explicitly lists the 5+ open decisions.
- No "TBD" without explaining what source is missing and what decision is required.

### Validation

- Markdown files are readable (visual check).
- Internal links/paths are correct where possible.
- No runtime validation needed (docs-only).

### Risks

- Audit may miss Phaser files not in the read list. Mitigation: CODEMAP.md was read first as routing map.
- Data values may be stale if Phaser repo advanced past the audited commit. Mitigation: shallow clone at latest main was used.

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

## 5. GODOT-M2 — Starting Base Loop

**Size**: Very High

### Goal

Establish the starting base loop: HQ + 2 harvesters + 1 builder + 1 Wasp+Smoky M0 tank + resource deposits + harvester gather/unload loop + basic economy display.

### Scope

- Create HQ building scene (3×3 footprint, T1).
- Create harvester unit scene (civil unit, gather/deliver loop).
- Create builder unit scene (civil unit, construction — placement deferred to M3).
- Place starting state: HQ at lower-left, 2 harvesters NE of HQ, 1 builder NE of HQ, 1 Wasp+Smoky M0 tank NE of HQ.
- Place resource deposits near HQ (very_poor/poor/medium classes per Phaser anchor model).
- Implement harvester state machine: idle → moving-to-resource → gathering → returning-to-hq → unloading → repeat.
- **HQ-centered auto-search**: harvester auto-gather scoring uses HQ distance, NOT harvester position (Denis direction, contradicts Phaser).
- Manual resource click override: player clicks specific deposit → harvester targets it until depleted → returns to auto-gather.
- Implement economy state: raw, matter, elements, power.
- Implement separator processing (12 raw → 10 matter + 2 elementUnits per 5000ms cycle, 5 power).
- Implement power system (HQ base 10 + power-plant 15 each).
- Implement resource display in UI (top-left strip: raw/matter/elements/power).
- Implement build commands for: separator, raw-storage, matter-storage, element-storage, power-plant (auto-placement near builder — placement logic in M3, but build command wiring here).
- Implement storage cap bonuses (+200 per storage building).

### Non-goals

- Units factory (M3).
- Combat (M4).
- Map generation (M5 — use fixed test map for M2).
- Fog of war (M5).
- Minimap (M5).
- Command card grid (M5).
- Control groups (M5).
- Save/load (M5).
- Enemy AI (M6).
- Click-to-place building UX (deferred — auto-placement only).
- T2/T3 HQ tiers (deferred).
- XP/upgrade system (deferred).

### Source references from Phaser

- `src/state/createInitialState.ts` — starting state factory, extra harvesters, starter modular combat.
- `src/state/updateGameState.ts` — harvester state machine, economy tick (`allocatePowerAndProcess`, `recomputePower`).
- `src/state/types.ts` — `EconomyState`, `HarvesterState`, all economy constants.
- `src/state/construction.ts` — `BUILDING_CONFIG`, building placement, completion.
- `src/config/coreMechanicsTypes.ts` — `AcceptedBuildingId`, `BuildingConfig`, `ResourceClassConfig`.
- `src/config/localization.ts` — Russian labels for economy, buildings, status.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §3-9 — extracted data tables.

### Godot files likely affected

- `scenes/buildings/HQ.tscn` (new)
- `scenes/buildings/Separator.tscn` (new)
- `scenes/buildings/RawStorage.tscn` (new)
- `scenes/buildings/MatterStorage.tscn` (new)
- `scenes/buildings/ElementStorage.tscn` (new)
- `scenes/buildings/PowerPlant.tscn` (new)
- `scenes/units/Harvester.tscn` (new)
- `scenes/units/Builder.tscn` (new)
- `scenes/environment/ResourceDeposit.tscn` (new)
- `scenes/main/GameScene.tscn` (new — main game scene)
- `scripts/state/GameState.gd` (new — autoload)
- `scripts/state/Economy.gd` (new)
- `scripts/state/HarvesterStateMachine.gd` (new)
- `scripts/state/ConstructionSystem.gd` (new)
- `scripts/ui/ResourceStrip.gd` (new)
- `resources/buildings/*.tres` (new — one per building type)
- `resources/resources/*.tres` (new — one per resource class)

### Acceptance criteria

- Game starts with HQ + 2 harvesters + 1 builder + 1 Wasp+Smoky M0 tank.
- Resources visible near HQ (at least 4 deposits: 2 very_poor, 1 poor, 1 medium).
- Harvester auto-gathers: moves to nearest resource (by **HQ distance**, not harvester position), gathers 1000ms, returns to HQ, unloads 500ms, repeats.
- Manual resource click: click deposit → harvester targets it → after depletion, returns to auto-gather.
- Economy display updates: raw increases when harvester unloads, matter/elements increase when separator processes.
- Separator processes: consumes 12 raw, produces 10 matter + 2 elementUnits per 5000ms cycle, consumes 5 power.
- Power display: HQ provides 10, power-plant provides +15 each.
- Build commands work: select builder → press Q (separator) → building auto-placed near builder → construction progresses → building completed.
- Storage caps enforced: raw cap 200 (base) + 200 per raw-storage building.
- Cannot build without sufficient matter (blocked reason shown).
- Cannot build if no idle builder (blocked reason shown).
- No crashes on save/load attempt (save/load itself is M5).

### Validation

- Manual QA: start game → verify starting state → harvester loop → economy updates → build a separator → verify processing.
- Economy invariants: raw + matter + elements never go negative.
- Power: consumed <= generated (factories/separators pause if insufficient power).
- Unit cap: cannot produce beyond 10 civil units.

### Risks

- **Harvester pathfinding**: Godot `NavigationServer3D` may behave differently from Phaser BFS. Mitigation: use `NavigationRegion3D` with baked navmesh; test on flat ground first.
- **HQ-centered auto-search**: Contradicts Phaser (harvester-position search). Mitigation: implement as `findNearestResourceFromHq(state, harvester)`; document the decision.
- **Economy deadlock**: If separator consumes all raw, builder can't build. Mitigation: reserve minimum raw for construction (Phaser doesn't do this — add as Godot improvement).
- **Building placement**: Auto-placement may fail on crowded maps. Mitigation: ring search up to 5 tiles (same as Phaser `findSpawnPosition`).

### Estimated size: Very High

---

## 6. GODOT-M3 — Builder + Unit Factory Loop

**Size**: Very High

### Goal

Implement builder construction loop and units factory production: produce builder/harvester/Wasp+Smoky M0 from the factory.

### Scope

- Implement builder construction state machine: idle → moving-to-site → building → idle.
- Implement builder-centric auto-placement: builder selects building type → system finds nearest valid tile near builder → builder moves to adjacent tile → construction progresses.
- Implement units factory building scene (2×2 footprint, cost 120 matter, 40000ms build time).
- Implement production queue (limit 2, no refund on cancel).
- Implement `startUnitProduction(state, factoryTx, factoryTy, request)` for:
  - Builder (40 matter, 10 elements, 15000ms)
  - Harvester (50 matter, 10 elements, 20000ms)
  - Wasp+Smoky M0 (45 matter, 10 elements, 25000ms) — structured request `{hullId:'wasp', turretId:'smoky', mod:'m0'}`
- Implement production tick: factory consumes 4 power while active, progress advances, completed item spawns unit near factory.
- Implement `spawnCombatUnit(state, tx, ty, request)` — creates `ModularCombatUnit` with `bodyId`, `weaponId`, `mod`, `faction`, `id`.
- Implement unit cap (DEFAULT_UNIT_CAP=10, includes combat units).
- Implement factory production UI: select factory → see production buttons (builder/harvester/wasp-smoky) → click to enqueue.
- Implement queue display: show progress bars for queue items.
- Implement cancel queue item (no refund).

### Non-goals

- Hull/turret selection UI (Phase 3 of Phaser roadmap — two-column FactoryProductionPanel).
- M1/M2/M3 production (deferred — M0 only).
- Dynamic hull+turret cost calculation (deferred — use reserved constants).
- XP/upgrade system (deferred).
- Combat (M4).
- Map generation (M5).
- Fog of war (M5).
- Minimap (M5).
- Command card grid (M5 — use simple buttons for M3).
- Control groups (M5).
- Save/load (M5).

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
- `scripts/state/PlacementSystem.gd` (new — auto-placement near builder)
- `scripts/units/CombatUnit.gd` (new — ModularCombatUnit controller)
- `scripts/ui/FactoryPanel.gd` (new — simple production buttons, not full two-column panel)
- `scripts/ui/QueueDisplay.gd` (new)
- `resources/production/*.tres` (new — production cost configs)

### Acceptance criteria

- Builder can be selected → build command issued → building auto-placed near builder → builder moves to site → construction progresses → building completed → builder returns to idle.
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

## 7. GODOT-M4 — Combat Loop

**Size**: High+

### Goal

Implement the combat loop: tanks can attack dummy targets, deal damage, destroy targets, and die.

### Scope

- Implement `CombatSystem` autoload: damage calculation, hit detection, death handling.
- Implement `DamageCalculator`: `finalDamage = max(rawDamage - armor, rawDamage * minDamagePercent)`.
- Implement projectile spawning from `MuzzleSocket`.
- Implement hit detection via Godot 3D physics (`RayCast3D` for instant hits, `Area3D` for projectiles).
- Implement target acquisition: RMB on enemy → tank acquires target → turret rotates toward target → fires when in range and turret aligned.
- Implement weapon fire types: `cooldown` (smoky), `wind_up` (railgun), `canister_stream` (flamethrower/freeze/isida), `overheat` (vulcan), `near_continuous` (twins), `magazine` (ricochet), `drum` (hammer).
- Implement continuous damage (`tickContinuousDamage` for stream weapons).
- Implement splash damage (thunder: radius 1.5, falloff).
- Implement penetration (railgun: max 3 targets).
- Implement heal beam (isida: heal ally, no damage).
- Implement HP/death: unit HP reaches 0 → unit destroyed → removed from scene.
- Implement dummy target scene (static `StaticBody3D` with HP, no AI).
- Implement basic win/lose placeholder: destroy all dummy targets → "Victory" message.

### Non-goals

- Enemy AI (M6).
- Attack-move / formations / patrol / hold-position.
- Shift-queue commands.
- Multi-unit target coordination (each tank targets independently).
- Full VFX polish (basic projectiles only).
- Audio/SFX.
- All 7 hulls (Wasp + Hunter for T1).
- All 10 turrets (Smoky + Railgun for T1).
- M1/M2/M3 upgrades (M0 only).
- XP system (deferred).
- Fog of war affecting combat (M5).

### Source references from Phaser

- `src/config/weaponData.ts` — all 10 weapon configs (fire type, damage, cooldown, range, profile-specific).
- `src/config/bodyData.ts` — HP/armor arrays for all 7 hulls.
- `src/state/blockoutDamage.ts` — damage application, hit detection (reference only — Godot uses 3D physics, not screen-space math).
- `src/state/combatHitModel.ts` — projected hit detection (reference for damage model, not geometry).
- `src/state/weaponFireCoordinator.ts` — fire coordination logic.
- `src/state/combatTargeting.ts` — target acquisition/clearing.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §3-4 — hull/weapon data tables.

### Godot files likely affected

- `scripts/combat/CombatSystem.gd` (new — autoload)
- `scripts/combat/DamageCalculator.gd` (new)
- `scripts/combat/Projectile.gd` (new — reusable projectile scene)
- `scripts/combat/HitDetector.gd` (new — RayCast3D/Area3D wrapper)
- `scripts/units/TurretController.gd` (update — add target acquisition + fire logic)
- `scripts/units/CombatUnit.gd` (update — add HP, death, target management)
- `scenes/units/DummyTarget.tscn` (new)
- `scenes/effects/Projectile.tscn` (new)
- `resources/weapons/*.tres` (new — one per weapon type, M0 stats)

### Acceptance criteria

- Wasp+Smoky M0 tank can attack dummy target.
- RMB on dummy → turret rotates toward dummy → fires when aligned and in range.
- Projectile spawns from MuzzleSocket, travels toward target, hits target.
- Damage applied: `finalDamage = max(16 - 2, 16 * 0.25) = 14` (Wasp M0 armor 2, minDamagePercent 0.25).
- Dummy HP decreases; at 0 HP, dummy is destroyed (removed from scene).
- Multiple weapon types work: smoky (cooldown), railgun (wind_up + penetration), thunder (splash), flamethrower (stream), vulcan (overheat), twins (near_continuous), ricochet (magazine), hammer (drum), isida (heal ally), freeze (stream + slow).
- Heal beam (isida) heals allied tank, does not damage.
- Splash (thunder) damages all targets within 1.5 tiles of impact.
- Penetration (railgun) hits up to 3 targets in a line.
- Tank death: HP 0 → unit removed from scene → selection cleared if selected.
- "Victory" message when all dummy targets destroyed.

### Validation

- Manual QA: spawn tank + dummy → attack → verify damage/HP/death.
- Damage formula test: `finalDamage = max(rawDamage - armor, rawDamage * minDamagePercent)`.
- Splash radius test: targets within radius take damage, outside do not.
- Penetration test: ray hits up to 3 targets in order.
- Heal test: isida heals ally, does not damage enemy.

### Risks

- **3D hit detection vs Phaser screen-space**: Phaser uses screen-space geometry; Godot uses 3D physics. Results may differ for edge cases (glancing hits, friendly fire). Mitigation: use `Area3D` overlap for projectiles; `RayCast3D` for instant-hit weapons.
- **Turret alignment**: Turret must be aligned with target before firing. Mitigation: check `turretAngle` vs `angleToTarget` within threshold (e.g. 5 degrees).
- **Continuous damage timing**: Stream weapons (flamethrower/freeze/isida) deal damage per tick, not per shot. Mitigation: use `tickContinuousDamage` pattern from Phaser (cadence check via `lastDamageTickAt`).
- **Overheat mechanic**: Vulcan heat accumulation must be server-authoritative (no client-side only). Mitigation: track heat in `CombatUnit` state, not in turret node.

### Estimated size: High+

---

## 8. GODOT-M5 — Map/Fog/RTS UX

**Size**: Very High

### Goal

Implement map generation, fog of war, and full RTS UX (minimap, command card grid, control groups, selection, save/load).

### Scope

- Implement `MapGenerator`: deterministic seed (Mulberry32 or Godot `RandomNumberGenerator`), sizes (small 32×32, standard 48×48, large 64×64), patch-based terrain, anchor-based 6-class resource placement, HQ at lower-left, 1 builder NE of HQ, center infinite deposit.
- Implement mirrored map generation for PvP fairness (mirror one half).
- Implement fog of war: three-state tile (unexplored/explored/visible), diamond radius vision, full recompute per frame. Vision sources: HQ (8), buildings (per config), builders (4), harvesters (5). Purple faction +1 to all.
- Implement territory layer: gradual spread from owned buildings, max radius 10, 45-60s for 2×2 building, does not block construction.
- Implement minimap: `SubViewport` camera, click-to-center, drag-to-pan, fog layer, selection highlights, pings.
- Implement command card grid: 4×3 grid (Q W E R / A S D F / Z X C V), context-aware (builder/harvester/factory/multi-select/none).
- Implement control groups: Ctrl+1-9 assign, 1-9 recall, double-tap centers camera.
- Implement selection: LMB select, Shift+click toggle, drag-box multi-select, double-click same-type.
- Implement RTS controls: LMB=select only, RMB=command (move/harvest/attack), S=stop, Esc=priority chain (cancel → deselect → close overlay → pause).
- Implement save/load: Godot resource serialization, versioned saves, migration helpers.
- Implement full HUD: bottom bar (200px safe-area), resource strip (top-left), selection panel, queue display, feedback/status lane.

### Non-goals

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
- `src/phaser/ui/hud/HudMinimap.ts` + `minimapViewModel.ts` — minimap renderer + view model.
- `src/phaser/ui/hud/commandCardGrid.ts` + `commandPanelViewModel.ts` — command card grid + view model.
- `src/state/controlGroups.ts` — `ControlGroupManager`.
- `src/state/unitSelection.ts` — selection model.
- `src/phaser/input/GameInputController.ts` — input routing.
- `src/state/commandRouter.ts` — `routeLmbClick`, `routeRmbClick`, `routeSKey`, `routeEscKey`.
- `src/phaser/ui/hud/hudLayout.ts` — HUD layout constants.
- `src/state/saveGame.ts` — save/load reference.
- `docs/GODOT_DATA_MODEL_BASELINE.md` §10-11 — vision/movement constants.

### Godot files likely affected

- `scripts/state/MapGenerator.gd` (new)
- `scripts/state/FogOfWar.gd` (new)
- `scripts/state/TerritorySystem.gd` (new)
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

- Map generation: seed "test" + standard size → deterministic 48×48 map with HQ at (4,41), resources near HQ, center infinite deposit.
- Mirrored map: two player HQs at mirrored positions, resources mirrored.
- Fog of war: unexplored tiles black, explored tiles dimmed, visible tiles clear. HQ provides vision radius 8.
- Territory: building placement → territory spreads gradually over 45-60s, max radius 10.
- Minimap: click to center camera, drag to pan, fog layer visible, selection highlights pulse.
- Command card: select builder → Q=separator, W=raw-storage, E=matter-storage, R=element-storage, A=power-plant, F=units-factory, S=stop. Select factory → production buttons appear.
- Control groups: Ctrl+1 assigns selected units → 1 recalls → double-tap 1 centers camera.
- Selection: LMB selects, Shift+click toggles, drag-box multi-selects, double-click selects all same-type in viewport.
- RTS controls: LMB=select, RMB=move/harvest/attack, S=stop, Esc=priority chain.
- Save/load: save game → load game → state restored (economy, units, buildings, vision explored grid).
- HUD: bottom bar 200px, resource strip top-left, selection panel, queue display, feedback lane.

### Validation

- Manual QA: generate map → verify resources/HQ/center deposit → fog/vision → minimap → command card → control groups → save/load.
- Map determinism: same seed → same map.
- Fog: no vision through unexplored tiles.
- Save/load: round-trip preserves all state.
- Control groups: 9 groups, double-tap centering works.

### Risks

- **Mirrored map fairness**: Mirror may not produce perfectly fair maps if terrain patches are random. Mitigation: generate one half, mirror it.
- **Fog performance**: Full recompute per frame may be slow for large maps (64×64 = 4096 tiles × N sources). Mitigation: dirty-flag recompute (only when sources change), incremental update.
- **Territory gradual spread**: Phaser doesn't implement this. Mitigation: use wave-front propagation (BFS from owned buildings, one cell per N ms).
- **Save/load compatibility**: Godot resource serialization may change between versions. Mitigation: version field + migration helpers (same pattern as Phaser).
- **Input routing complexity**: Phaser's `GameInputController` is 1352 lines. Mitigation: split into `InputRouter` (pure routing) + `InputController` (Phaser/Godot adapter).

### Estimated size: Very High

---

## 9. GODOT-M6 — Enemy AI Draft

**Size**: High+

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
- Implement "no enemy AI before playable loop" rule: AI only activates after M1-M5 are stable.

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
M0C (audit)
  ↓
M1 (3D asset proof + camera/grid)
  ↓
M2 (starting base loop)
  ↓
M3 (builder + unit factory loop)
  ↓
M4 (combat loop)
  ↓
M5 (map/fog/RTS UX)
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
- No enemy AI before playable loop is stable (M1-M5).
- No multiplayer.
- No mobile/touch.
- No audio/SFX/music (deferred).

---

## 12. Maintenance rule

Update this document when:
- A milestone is started (mark as "IN PROGRESS").
- A milestone is merged (mark as "DONE via PR #xxx").
- Scope changes (update scope/non-goals/acceptance criteria).
- Risks are realized (update risk notes).
- Denis changes a design decision (update milestone scope).

Keep this document as the single source of truth for Godot implementation sequencing until all milestones are complete.
