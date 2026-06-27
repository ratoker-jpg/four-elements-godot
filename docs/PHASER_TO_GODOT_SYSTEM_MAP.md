# PHASER_TO_GODOT_SYSTEM_MAP

Date: 2026-06-28
Status: docs-only audit — extracted from Phaser source
Project: Four Elements Godot
Source baseline: `ratoker-jpg/four-elements-phaser` (cloned at `/home/z/my-project/repo`)
Target repo: `ratoker-jpg/four-elements-godot`

---

## 1. Purpose

This document maps the current Phaser project system-by-system into a clean Godot implementation plan.

It answers:

1. What already exists in Phaser.
2. What should be preserved as game rules.
3. What should be copied only as data/config.
4. What should be rewritten natively in Godot.
5. What should be discarded as Phaser/browser/dev-only implementation.
6. What decisions are contradictory or still open.
7. What Godot implementation roadmap should follow after the audit.

**Extraction rule**: Phaser facts are marked as `PHASER FACT`. Godot recommendations are marked as `GODOT DECISION`. Assumptions are marked `ASSUMPTION`.

---

## 2. Legend

| Column | Meaning |
|---|---|
| System | Logical game system being audited. |
| Phaser source files | Concrete files in the Phaser repo. |
| Current Phaser status | What state Phaser has it in (implemented / partial / reserved / dev-only / not implemented). |
| Godot target | What the Godot repo should end up with. |
| Port as data? | Whether the values can be lifted as config/data tables. |
| Rewrite? | Whether the runtime logic must be reimplemented natively. |
| Discard? | Whether the Phaser implementation is browser/dev-specific and should be dropped. |
| Notes / risks | Caveats, contradictions, open decisions. |

---

## 3. System-by-system mapping

### 3.1 Game loop / state model

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Game loop / state model | `src/state/types.ts` (GameState interface, ~500 lines), `src/state/updateGameState.ts` (882 lines, `updateGameState(state, deltaMs)` entry point) | Implemented. Pure TypeScript, no Phaser imports. Per-frame: harvester update → `allocatePowerAndProcess` (economy + production) → `recomputePower`. Delta clamped to 200ms. | Godot autoload `GameState` resource; `_process(delta)` calls `update_state(delta)`. Keep delta clamp. | Partial (type shape) | Yes (loop) | No | PHASER FACT: combat tick is NOT in `updateGameState.ts` — it lives in `weaponFireCoordinator.ts` etc. GODOT DECISION: unify civil + combat tick in one Godot `WorldController._process` to avoid Phaser's split-brain. |

### 3.2 Factions

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Factions | `src/config/factionData.ts` (123 lines, `FACTION_CONFIGS`), `src/config/coreMechanicsTypes.ts` (`AcceptedFactionId = 'cyan'\|'green'\|'yellow'\|'purple'`, `FactionConfig` interface), `src/config/localization.ts` (`FACTION_DISPLAY`, `FACTION_BONUS`, `FACTION_ROLE`) | Implemented as data. 4 factions: cyan=Поток (mobility), green=Росток (economy), yellow=Искра (combat), purple=Око (vision). Passive bonuses only, no active abilities. | Godot `res://resources/factions/faction_data.tres` (4 resources). | Yes | No | No | PHASER FACT: bonuses are placeholder multipliers (1.1x production speed, +1 vision radius). GODOT DECISION: keep as data, balance later. |

### 3.3 Starting state

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Starting state | `src/state/createInitialState.ts` (562 lines), `createInitialState(mapData, playerFaction, mapNameOverride, options)` | Implemented. Creates: HQ entity, builders from map, 2 extra harvesters near HQ (NE bias), optional starter modular-combat Wasp+Smoky M0 (only when `includeModularCombat=true` — devtools/arena only). Economy: START_RAW=30, START_MATTER=120, caps HQ_RAW_CAP=HQ_MATTER_CAP=HQ_ELEMENT_CAP=200. | Godot `StartingState` factory. Starter Wasp+Smoky M0 should be **normal baseline**, not dev-only. | Partial (constants) | Yes (factory) | No | PHASER FACT: `ModularCombatUnit` is hardcoded `chassis:'wasp', weapon:'smoky', mod:'m0'`. GODOT DECISION: generalize to `bodyId:BodyId, weaponId:WeaponId, mod:ModLevel` per the Phase 2 (PR #325) direction. CONTRADICTION: Phaser standard mode strips modular combat; Denis wants it as normal baseline. |

### 3.4 Resources and economy

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Resources / economy | `src/state/types.ts` (`EconomyState`, `START_RAW=30`, `START_MATTER=120`, `HQ_RAW_CAP=200`, `HQ_MATTER_CAP=200`, `HQ_ELEMENT_CAP=200`, separator constants `SEP_RAW_COST=12`, `SEP_MATTER_YIELD=10`, `SEP_ELEMENT_YIELD=2`, `SEP_CYCLE_MS=5000`, `ELEMENT_UNITS_PER_ELEMENT=10`), `src/state/updateGameState.ts` (`allocatePowerAndProcess`, `recomputePower`) | Implemented. Resources: raw, matter, elements (per faction, in elementUnits), power. Separator converts 12 raw → 10 matter + 2 elementUnits per 5000ms cycle, consuming 5 power. HQ base power=10, power-plant=+15. | Godot `Economy` autoload; separator processing node. | Yes (constants) | Yes (tick) | No | CONTRADICTION: Phaser uses `raw/matter/elementUnits/power` internally but Denis says player-facing should be `minerals/energy/elements`. GODOT DECISION: internal names match Phaser; player-facing UI uses Denis's vocabulary. See §6 contradiction #3. |

### 3.5 Harvester loop

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Harvester loop | `src/state/updateGameState.ts` (`updateHarvester`, `handleIdle`, `handleMovingToResource`, `handleGathering`, `handleReturningToHQ`, `handleUnloading`), `src/state/types.ts` (`HarvesterState`, phases: idle/moving-to-resource/gathering/returning-to-hq/unloading/manual-move), constants `GATHER_DURATION_MS=1000`, `UNLOAD_DURATION_MS=500`, `DEFAULT_CARGO_CAPACITY=20`, `DEFAULT_SPEED=2.5` | Implemented. Idle → finds nearest resource (by harvester position) → BFS to approach tile → gather 1000ms → BFS to HQ adjacent → unload 500ms → repeat. Manual-move override supported. | Godot `Harvester` node with state machine. | Yes (constants) | Yes (state machine) | No | CONTRADICTION: Phaser searches nearest resource by **harvester position**; Denis wants **HQ/base-centered** auto-search. GODOT DECISION: auto-gather scoring uses HQ distance; manual targeted resource overrides until depleted. See §6 contradiction #2. |

### 3.6 Builder / construction

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Builder / construction | `src/state/builder.ts` (302 lines, `assignIdleBuilders`, `updateBuilders`, `releaseBuilder`), `src/state/construction.ts` (336 lines, `BUILDING_CONFIG`, `canPlaceBuilding`, `placeConstructionSite`, `updateConstructionSiteProgress`), `src/state/types.ts` (`BuilderPlacement`, phases: idle/moving-to-site/building), constants `BUILDER_SPEED=3.0`, `ARRIVAL_THRESHOLD=0.03` | Implemented. Builder picks site from queue → BFS to adjacent tile → builds → releases to idle. Placement is **programmatic** (auto-find nearest valid tile via occupancy map), not click-to-place. | Godot `Builder` node + `ConstructionSystem`. | Yes (config) | Yes (state machine) | No | CONTRADICTION: Phaser RTS Foundation Roadmap Phase 9 proposed **click-to-place** as a Denis approval gate. Denis currently wants **builder-centric auto-placement**. GODOT DECISION: implement auto-placement; defer click-to-place unless Denis later approves. See §6 contradiction #1. |

### 3.7 Buildings

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Buildings | `src/state/construction.ts` (`BUILDING_CONFIG` keyed by `BuildingType`), `src/config/coreMechanicsTypes.ts` (`AcceptedBuildingId` = hq/separator/raw_storage/energy_storage/elements_storage/units_factory/power_plant/energy_reactor/repair_center/defense_tower; `BuildingConfig` interface with category/readiness/isBuildable/cost/hp/footprint/vision), `src/config/buildingData.ts` (referenced), `src/config/localization.ts` (`BUILDING_STRINGS`, `BUILDING_ROLE_STRINGS`) | Implemented (gameplay_ready): hq, separator, raw-storage, matter-storage (→energy_storage), element-storage, power-plant, units-factory. Visual-ready (not buildable): energy-plant (→energy_reactor), repair-center, defense-tower, command-relay. All footprints 2×2 except HQ (3×3). Costs: separator=60, storage=40-50, power-plant=100, units-factory=120 matter. | Godot `res://resources/buildings/` (one `.tres` per type) + `Building` scene. | Yes (full config) | Yes (scene) | No | PHASER FACT: `matter-storage` maps to production id `energy_storage` (displayed as "Хранилище энергии"). GODOT DECISION: keep the 10 accepted building IDs; reserve repair/defense/reactor data but mark `readiness=deferred`. |

### 3.8 HQ tiers T1/T2/T3

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| HQ tiers | (no dedicated file; HQ is a single `BuildingType='hq'` with footprint 3×3 in construction.ts; no tier upgrade path exists) | Not implemented. HQ is a single tier. | Godot HQ with `tier: 1|2|3` field; upgrade action. | No (no source data) | Yes (new) | No | OPEN DECISION: T2/T3 unlock table is not final. GODOT DECISION: reserve `tier` field now; do not invent unlock tree until design pass. See §6 contradiction #4. |

### 3.9 Units factory

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Units factory | `src/state/production.ts` (203 lines, `startUnitProduction`, `cancelFactoryQueueItem`), `src/state/types.ts` (`ProducibleUnitType = 'builder'\|'harvester'` — **NOTE**: PR #325 extends to `'wasp-smoky'` but that's on a branch, not yet merged into the audited main), `ProductionQueueItem`, `UnitFactoryRuntimeState`, constants `QUEUE_LIMIT=2`, `BUILDER_PRODUCTION_MATTER_COST=40`, `BUILDER_PRODUCTION_ELEMENT_COST=10`, `BUILDER_PRODUCTION_DURATION_MS=15000`, `HARVESTER_PRODUCTION_MATTER_COST=50`, `HARVESTER_PRODUCTION_ELEMENT_COST=10`, `HARVESTER_PRODUCTION_DURATION_MS=20000`, reserved combat constants `WASP_SMOKY_TOTAL_MATTER_COST=45`, `WASP_SMOKY_TOTAL_ELEMENT_COST=10`, `WASP_SMOKY_TOTAL_PRODUCTION_DURATION_MS=25000` | Implemented for builder/harvester. Combat unit production reserved (constants exist, not wired). Queue limit=2, no refund on cancel. Power: 4 per active factory. | Godot `UnitsFactory` node + production queue UI. | Yes (constants) | Yes (queue logic) | No | PHASER FACT: `ProducibleUnitType` is currently `'builder'\|'harvester'` only on main. GODOT DECISION: start Godot with builder/harvester/wasp-smoky; design for structured `{hullId}:{turretId}` keys from the start (per Phaser Phase 2/3 direction). |

### 3.10 Modular combat tanks

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Modular combat tanks | `src/state/types.ts` (`ModularCombatUnit`: hardcoded `chassis:'wasp', weapon:'smoky', mod:'m0', faction`), `src/state/createInitialState.ts` (`createExtraModularCombat`), `src/modular/normalCombatToModularVisual.ts` (maps to modular render), `src/phaser/render/ModularTankRenderer.ts` (legacy static debug path) | Partial. State-only starter unit exists (dev-only). Arena/blockout vehicles (`BlockoutVehicleState`) are the real combat runtime — separate from `ModularCombatUnit`. Render is via PNG matrix (7 hulls × 10 turrets × M0-M3 × 4 factions × 16 dirs). | Godot `Tank3D` scene: Hull Mesh + Turret Mesh + TurretSocket/Marker3D + MuzzleSocket/Marker3D + faction material override. | No (state shape) | Yes (full rewrite) | Yes (PNG matrix) | PHASER FACT: PNG matrix is the reason for migration — 4352+ runtime PNGs. GODOT DECISION: discard PNG matrix entirely; use real 3D `.glb` assets. Normalize `vulcan_b` → `vulcan` on import. |

### 3.11 Hull data

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Hull data | `src/config/bodyData.ts` (190 lines, `BODY_CONFIGS` for 7 hulls: wasp/hornet/hunter/viking/dictator/titan/mammoth), `src/config/coreMechanicsTypes.ts` (`BodyConfig` interface, `MLevelData<T>=[T,T,T,T]`, `BodyFootprintClass='light'\|'medium'\|'heavy'`) | Implemented as data. Per hull: hp[4], mass, armor[4], minDamagePercent, maxSpeed[4], acceleration[4], braking[4], bodyTurnSpeed[4], footprintClass. M0→M3 increases all except mass/footprint. | Godot `res://resources/hulls/{id}.tres` (7 resources). | Yes (full) | No | No | PHASER FACT: armor formula is `finalDamage = max(rawDamage - armor, rawDamage * minDamagePercent)`. GODOT DECISION: keep formula; expose as `DamageCalculator` helper. |

### 3.12 Turret/weapon data

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Turret/weapon data | `src/config/weaponData.ts` (324 lines, `WEAPON_CONFIGS` for 10 weapons: smoky/thunder/railgun/flamethrower/freeze/isida/vulcan/twins/ricochet/hammer — **shaft excluded**), `src/config/coreMechanicsTypes.ts` (`WeaponConfig`, `WeaponFireType`, `WeaponRangeClass`) | Implemented as data. Per weapon: fireType, rangeClass, min/ideal/max/stop range, damage model (direct/splash/penetration/DPS/heal), cooldown[4], profile-specific (windUp/canister/overheat/magazine/drum), turretTurnSpeed[4], vfxProfileKey. | Godot `res://resources/weapons/{id}.tres` (10 resources). | Yes (full) | No | No | PHASER FACT: `vulcan_b` appears in modular asset workflow; normalize to `vulcan`. GODOT DECISION: keep 10 weapons; exclude shaft; preserve fire-type categories for VFX routing. |

### 3.13 M0-M3 progression

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| M0-M3 progression | `src/config/bodyData.ts` (M0-M3 arrays), `src/config/weaponData.ts` (M0-M3 arrays), `src/config/coreMechanicsTypes.ts` (`ModificationLevel=0|1|2|3`, `MLevelData<T>`) | Implemented as data arrays. Hull and turret M-levels are **independent** (per FINAL_RTS_FOUNDATION_ROADMAP Phase 4/5). Mass/footprint do NOT change. | Godot `ModLevel` enum + `MLevelData<T>` array resources. | Yes (full) | No | No | GODOT DECISION: model `hull_mod_level` and `turret_mod_level` as separate fields on `Tank3D`. |

### 3.14 XP / upgrades

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| XP / upgrades | (not implemented in Phaser source; mentioned in `GAME_TARGET_VISION_FROM_PHASER.md` §18 and FINAL_RTS_FOUNDATION_ROADMAP Phase 4/5) | Not implemented. Concept accepted: XP from kills only; builders/harvesters do not level; hull and turret upgrade independently; max M3. | Godot `XPSystem` + upgrade actions. | No (no source data) | Yes (new) | No | OPEN DECISION: XP thresholds and upgrade costs are not final. GODOT DECISION: model fields now (`xp`, `hull_mod_level`, `turret_mod_level`); balance later. See §6 contradiction #5. |

### 3.15 Map generation

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Map generation | `src/state/generatedMap.ts` (756 lines, `createGeneratedMapData`, `createValidatedGeneratedMapData`), `src/config/resourceAnchors.ts` (referenced), `src/state/gameSetup.ts` (`MapStyle='sand'\|'industrial'`) | Implemented. Mulberry32 PRNG (deterministic). Sizes: small=32×32, standard=48×48, large=64×64. Patch-based terrain (sand-dominant + sand-light/dark patches + ripple/pebble/cracked detail). HQ at (4, mapHeight-7) lower-left. 1 builder NE of HQ. Anchor-based 6-class resource placement: starter=very_poor/poor/medium, side=medium/rich, contested=rich/very_rich, center=infinite (2×2). Obstacles/decor **deferred** (empty arrays — invisible blockers worse than none). | Godot `MapGenerator` with seed + size; mirrored maps for fairness. | Partial (size constants) | Yes (generator) | No | GODOT DECISION: keep deterministic seed; add mirror mode for PvP fairness; obstacles must be **visible** before they block. Center infinite deposit stays. |

### 3.16 Fog / vision / territory

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Fog / vision / territory | `src/state/visibility.ts` (348 lines, `VisionState`, `collectVisionSources`, `recomputeVisibility`), constants `BUILDER_VISION_RADIUS=4`, `HARVESTER_VISION_RADIUS=5`, `HQ_VISION_RADIUS=8`, `PURPLE_FACTION_VISION_BONUS=1` | Implemented (player-only MVP). Three-state tile: unexplored/explored/visible. Diamond radius (Manhattan distance). Full recompute per frame. Purple faction gets +1 to all sources. Explored grid persists in saves; visible grid recomputed. | Godot `FogOfWar` node + territory layer. | Yes (radius constants) | Yes (recompute) | No | GODOT DECISION: keep three-state model; add gradual territory spread (wave from owned cells, max radius 10, 45-60s for 2×2 building — per `GAME_DESIGN_BASELINE.md`). Territory does NOT block construction. |

### 3.17 RTS UI / HUD

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| RTS UI / HUD | `src/phaser/ui/hud/hudLayout.ts` (112 lines, constants `HUD_BAR_HEIGHT=200`, `HUD_MINIMAP_WIDTH=240`, `COMMAND_CARD_COLS=4`, `COMMAND_CARD_ROWS=3`), `src/phaser/ui/hud/VisualHudCore.ts` (orchestrator), `src/phaser/ui/PlaytestHud.ts` (legacy DOM buttons) | Implemented. Bottom HUD bar (200px) is camera safe-area; top-left resource strip is DOM overlay. 4×3 command card grid. | Godot `Control` UI scene with bottom HUD + minimap + command card + selection panel + resource display. | Partial (layout constants) | Yes (full UI) | Yes (Phaser DOM/Canvas split) | GODOT DECISION: use Godot native `Control` nodes; single UI scene; bottom HUD as camera safe-area. |

### 3.18 Command card / hotkeys

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Command card / hotkeys | `src/phaser/ui/hud/commandCardGrid.ts` (237 lines, 4×3 grid Q W E R / A S D F / Z X C V), `src/phaser/ui/hud/commandPanelViewModel.ts` (320 lines, `buildCommandCardViewModel`, `PRODUCE_COMMANDS`), `src/state/commandRegistry.ts` (`MVP_COMMAND_DEFS`, `registerMvpCommands`), `src/phaser/input/GameInputController.ts` (1352 lines, `wireCommandCallbacks`) | Implemented. 4×3 grid with fixed slots. Build commands: Q=separator, W=raw-storage, E=matter-storage, R=element-storage, A=power-plant, F=units-factory. S=Stop (mandatory). Produce: N=builder, G=harvester. Legacy aliases: B=separator, P=power-plant. Number keys 1-9 = control groups (NOT build). | Godot `CommandCard` Control + `InputMap` actions. | Yes (slot mapping) | Yes (UI + input) | No | PHASER FACT: SELECTION-CONTROL-GROUPS-05 removed ONE/TWO/THREE legacy build aliases — number keys are control groups only. GODOT DECISION: preserve this; never reassign 1-9 to build commands. |

### 3.19 Selection / control groups

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Selection / control groups | `src/state/unitSelection.ts` (242 lines, `SingleSelection\|MultiSelection\|null`), `src/state/controlGroups.ts` (100 lines, `ControlGroupManager`, groups 1-9, double-tap to center), `src/phaser/input/GameInputController.ts` (drag-box, double-click same-type, Shift+click toggle) | Implemented. Multi-select via drag-box or double-click same-type. Ctrl+1-9 assigns; 1-9 recalls; double-tap centers camera. | Godot `SelectionManager` + `ControlGroupManager` autoloads. | No | Yes (full) | No | GODOT DECISION: keep StarCraft-style controls; LMB=select only, RMB=command, S=stop. |

### 3.20 Minimap

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Minimap | `src/phaser/ui/hud/HudMinimap.ts` (478 lines, canvas renderer), `src/phaser/ui/hud/minimapViewModel.ts` (311 lines, `buildMinimapViewModel`, `tileToMinimap`), constants `HUD_MINIMAP_WIDTH=240`, `HUD_MINIMAP_HEIGHT=172` | Implemented. Click-to-center-camera, drag-to-pan. Fog layer on minimap. Selection highlights (pulsing cyan). Pings (FEEDBACK-ALERTS-06). Own units/buildings always visible; enemy only in explored+visible tiles. | Godot `Minimap` TextureRect/SubViewport. | Yes (color constants) | Yes (renderer) | No | GODOT DECISION: use `SubViewport` for minimap camera; same fog/selection/ping features. |

### 3.21 Combat loop

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Combat loop | `src/state/weaponFireCoordinator.ts`, `src/state/blockoutDamage.ts` (1187 lines), `src/state/combatHitModel.ts` (501 lines), `src/state/combatTargeting.ts`, `src/state/blockoutWeaponVfx.ts`, `src/state/blockoutMovement.ts`, `src/state/movementStateMachine.ts`, `src/config/blockoutMovementData.ts`, `src/state/blockoutVehicleState.ts` | Implemented (Arena/dev only). Hit detection: `findDirectHitTarget`, `findSplashTargets`, `findPenetrationTargets`, `findConeTargets`, `findBeamTargets`, `findShotgunTargets`, `findRicochetTargets`. `isSameTeamAlly` filter (ally/enemy). Continuous damage (`tickContinuousDamage`). Armor formula. | Godot `CombatSystem` + `Projectile` nodes + `DamageCalculator`. | Partial (damage formulas) | Yes (full) | Yes (Phaser screen-space hit detection) | GODOT DECISION: use Godot 3D physics (`RayCast3D`, `Area3D`) for hit detection instead of Phaser's screen-space math. Keep damage/armor formula as data. |

### 3.22 Dummy target / early combat validation

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Dummy target | (no dedicated file; Arena mode uses `blockoutVehicles` with `team:'enemy'` and `aiMode:'passive'` as static targets) | Implemented (Arena only). No normal-mode dummy. | Godot `DummyTarget` scene (static destructible). | No | Yes (new scene) | No | GODOT DECISION: add `DummyTarget` as a `StaticBody3D` with HP; used for M0/M4 combat validation. |

### 3.23 Enemy AI future scope

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Enemy AI | `src/state/blockoutAi.ts` (Arena dev only: passive/stationary_shooter/chaser/hold_position) | Dev-only Arena AI. No strategic AI. | Godot `EnemyAI` (deferred until M6). | No | Yes (new, deferred) | Yes (Phaser Arena AI) | GODOT DECISION: difficulty = behavior/intelligence, not stat cheating. Easy=scripted, Medium=adaptive, Hard=analytical. Do NOT start until human playable loop is stable. |

### 3.24 Asset pipeline

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Asset pipeline | `src/assets/generatedHullAssets.ts`, `src/assets/modularUnitAssets.ts`, `src/assets/assetManifest.ts`, `src/phaser/PreloadScene.ts`, `src/phaser/render/BlockoutVehicleRenderer.ts`, `src/phaser/render/ModularTankRenderer.ts` | PNG matrix: 7 hulls × 10 turrets × M0-M3 × 4 factions × 16 dirs = 4352+ runtime PNGs. On-demand loading via `requestModularVehicleSet()`. | Godot `.3ds → .blend → .glb → scene` pipeline. | No | Yes (full) | Yes (PNG matrix) | GODOT DECISION: discard PNG matrix; use real 3D `.glb` with `TurretSocket`/`MuzzleSocket` markers. Do NOT preload all combinations. See `ASSET_PIPELINE.md`. |

### 3.25 Save/load

| System | Phaser source files | Current Phaser status | Godot target | Port as data? | Rewrite? | Discard? | Notes / risks |
|---|---|---|---|---|---|---|---|
| Save/load | `src/state/saveGame.ts` (referenced; `SAVE_VERSION` bumped to 3 in PR #324 to add `combatUnits`), `src/state/createInitialState.ts` (`stripModularCombatFromState`, `ensureBuilderIds`) | Implemented. Versioned saves with migration. Strips blockout vehicles (dev-only). Persists: map data, economy, harvesters, production, vision (explored grid only), builders. | Godot `save_game.tres` resource serialization. | No | Yes (full) | No | GODOT DECISION: use Godot resource serialization; version field; migration helpers. Defer until M5. |

---

## 4. Cross-system observations

### 4.1 State layer purity

PHASER FACT: The Phaser state layer (`src/state/`) is pure TypeScript with zero Phaser imports. This is a clean separation that Godot should preserve — gameplay state in autoloads/resources, rendering in scene nodes.

GODOT DECISION: Keep `GameState` as a pure data resource; never put gameplay logic in `_process` of visual nodes.

### 4.2 Config as data

PHASER FACT: All balance data (factions, bodies, weapons, buildings, resources) lives in `src/config/` as typed constants. This is directly portable to Godot `.tres` resources.

GODOT DECISION: Create `res://resources/{factions,hulls,weapons,buildings,resources}/` with one `.tres` per ID. Use typed `Resource` subclasses matching Phaser interfaces.

### 4.3 Render layer discard

PHASER FACT: The Phaser render layer (`src/phaser/render/`) is 100% browser/canvas-specific. PNG matrix rendering, offset tuning, direction remapping — all of this is replaced by Godot's 3D engine.

GODOT DECISION: Do not port any render code. Start fresh with Godot 3D scenes.

### 4.4 Input layer partial rewrite

PHASER FACT: Input routing (`commandRouter.ts`) is pure TypeScript and could theoretically port. But `GameInputController.ts` is Phaser-specific (pointer events, keyboard, camera).

GODOT DECISION: Reimplement input using Godot `InputEvent` + `InputMap`. Keep the routing logic (LMB=select, RMB=command, S=stop, Esc=priority chain) as a design reference.

---

## 5. What to carry vs discard — summary

### 5.1 Carry to Godot

```text
Game rules:
- 4 factions with passive bonuses
- Economy model: raw → matter + elements, power constraint
- Harvester gather/deliver loop (with HQ-centered auto-search fix)
- Builder auto-placement near builder
- Building configs (10 types, 7 gameplay-ready)
- Production queue (limit 2, no refund)
- Modular tank model: hull + turret, independent M0-M3
- 7 hulls, 10 weapons (shaft excluded)
- Damage/armor formula
- Map generation (deterministic seed, 6-class resources, center infinite)
- Fog/vision (three-state, diamond radius)
- RTS controls (1-9=groups, Ctrl+1-9=assign, S=stop, LMB=select, RMB=command)
- 4×3 command card grid (Q W E R / A S D F / Z X C V)
- Russian UI labels

Data configs:
- FACTION_CONFIGS (4 factions)
- BODY_CONFIGS (7 hulls, M0-M3 arrays)
- WEAPON_CONFIGS (10 weapons, M0-M3 arrays)
- BUILDING_CONFIG (10 types, footprints/costs/times)
- Resource class config (6 classes)
- Localization strings (Russian)
```

### 5.2 Discard (Phaser/browser/dev-only)

```text
- PNG matrix renderer (BlockoutVehicleRenderer, ModularTankRenderer)
- Generated hull asset texture keys
- Phaser scene architecture (GameScene, PreloadScene, etc.)
- Camera projection math (replaced by Godot 3D orthographic camera)
- DOM HUD overlay (PlaytestHud, HudCommandPanel DOM)
- Canvas minimap (replaced by SubViewport)
- Blockout Arena dev mode (separate from production combat)
- Manual sprite offset tuner / WaspHullPlacementCalibrator
- Browser-specific qa:smoke tooling
- Phaser preload/fallback loading logic
```

### 5.3 Rewrite natively in Godot

```text
- 3D Tank scene (hull mesh + turret mesh + sockets)
- Orthographic/isometric camera
- 3D ground/grid
- 3D pathfinding (NavigationServer3D)
- 3D hit detection (RayCast3D, Area3D)
- Godot Control UI (HUD, command card, minimap, selection)
- Godot InputMap (keyboard + mouse)
- Save/load (Resource serialization)
- Combat system (projectiles, damage, death)
- Map generator (3D tiles)
- Fog of war (3D visibility)
```

---

## 6. Contradictions and open decisions

### 6.1 Builder placement

- PHASER FACT: `construction.ts` uses programmatic auto-placement (find nearest valid tile via occupancy map). FINAL_RTS_FOUNDATION_ROADMAP Phase 9 proposed **click-to-place** as a Denis approval gate.
- DENIS DIRECTION: Builder-centric auto-placement, not click-to-place.
- GODOT DECISION: Implement auto-placement. Defer click-to-place unless Denis later approves.
- Status: **RESOLVED** — auto-placement.

### 6.2 Harvester resource search origin

- PHASER FACT: `updateGameState.ts` `handleIdle` calls `findNearestAvailableResource` which searches by **harvester position**.
- DENIS DIRECTION: Auto-search should be based from **HQ/base**, not harvester position. Manual resource click overrides until depleted.
- GODOT DECISION: Implement HQ-centered auto-search; manual override with return-to-auto on depletion.
- Status: **RESOLVED** — HQ-centered with manual override.

### 6.3 Resource naming

- PHASER FACT: Internal names are `raw`, `matter`, `elementUnits`, `power`. UI labels (from `localization.ts`) are `hud_raw='Сырьё'`, `hud_matter='Энергия'`, `hud_power='Питание'`.
- DENIS DIRECTION: Player-facing vocabulary should be `minerals`, `energy`, `elements`.
- GODOT DECISION: Keep Phaser internal names (raw/matter/elementUnits/power) for code clarity; map to player-facing labels in UI only. Recommend: `raw`→"Минералы", `matter`→"Энергия", `elementUnits`→"Элементы", `power`→"Питание".
- Status: **OPEN** — needs Denis confirmation on exact Russian labels.

### 6.4 T2/T3 unlock table

- PHASER FACT: No tier system exists. HQ is single-tier.
- DENIS DIRECTION: T1/T2/T3 progression is accepted but unlock table is not final.
- GODOT DECISION: Reserve `tier` field on HQ; do not invent unlock tree until design pass.
- Status: **OPEN** — needs design pass.

### 6.5 XP thresholds and upgrade costs

- PHASER FACT: Not implemented. Concept accepted: XP from kills only; independent hull/turret M0-M3.
- DENIS DIRECTION: Model the fields now; balance later.
- GODOT DECISION: Add `xp: int`, `hull_mod_level: ModLevel`, `turret_mod_level: ModLevel` to `Tank3D`. Defer threshold/cost config.
- Status: **OPEN** — needs balance pass.

### 6.6 Energy-plant vs energy-reactor naming

- PHASER FACT: `BuildingType='energy-plant'` maps to production id `energy_reactor` (displayed as "Энергореактор"). Marked `visual_ready`, not buildable.
- GODOT DECISION: Keep both names in data; clarify in Godot which is the buildable T1 power building (`power_plant`) vs the deferred upgrade (`energy_reactor`).
- Status: **OPEN** — naming cleanup needed.

### 6.7 Combat unit production key format

- PHASER FACT: `ProducibleUnitType` is `'builder' | 'harvester'` on main. PR #325 (branch) adds `'wasp-smoky'` as a flat string. FINAL_RTS_FOUNDATION_ROADMAP Phase 2 recommends structured `{hullId}:{turretId}` key.
- GODOT DECISION: Start Godot with structured `CombatProductionRequest { hullId, turretId, mod }` from the beginning — avoid flat string keys.
- Status: **RESOLVED** — structured request object.

---

## 7. Godot implementation roadmap after audit

See `docs/GODOT_IMPLEMENTATION_ROADMAP.md` for the milestone sequence (GODOT-M0C through GODOT-M6).

---

## 8. Source files read for this audit

### Phaser repo (`/home/z/my-project/repo`)

```text
docs/project/CODEMAP.md
docs/project/FINAL_RTS_FOUNDATION_ROADMAP_2026_06_22.md
docs/project/CAMERA_PROJECTION_CONTRACT.md
src/state/types.ts
src/state/createInitialState.ts
src/state/updateGameState.ts
src/state/production.ts
src/state/construction.ts
src/state/builder.ts
src/state/generatedMap.ts
src/state/visibility.ts
src/state/unitSelection.ts
src/state/controlGroups.ts
src/config/coreMechanicsTypes.ts
src/config/factionData.ts
src/config/bodyData.ts
src/config/weaponData.ts
src/config/localization.ts
src/phaser/ui/hud/commandCardGrid.ts
src/phaser/ui/hud/commandPanelViewModel.ts
src/phaser/ui/hud/hudLayout.ts
src/phaser/ui/hud/HudMinimap.ts
src/phaser/ui/hud/minimapViewModel.ts
src/phaser/input/GameInputController.ts
```

### Godot repo (`/home/z/my-project/godot-repo`)

```text
README.md
docs/GAME_TARGET_VISION_FROM_PHASER.md
docs/PROJECT_STATE.md
docs/CURRENT_NEXT_STEP.md
docs/GODOT_M0_TECHNICAL_SLICE.md
docs/ASSET_PIPELINE.md
docs/GODOT_MIGRATION_HANDOFF.md
docs/GAME_DESIGN_BASELINE.md
```

---

## 9. Maintenance rule

Update this document when:

- A Godot milestone implements a system (mark as "IMPLEMENTED in Godot M{x}").
- A contradiction is resolved (move from §6 to the system row).
- New Phaser source is audited (add row).
- Denis changes a design decision (update GODOT DECISION).

Keep this document as the single source of truth for Phaser→Godot system mapping until all systems are implemented natively in Godot.
