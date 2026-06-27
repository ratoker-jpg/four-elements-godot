# GODOT_DATA_MODEL_BASELINE

Date: 2026-06-28
Status: docs-only — extracted baseline data tables from Phaser source
Project: Four Elements Godot
Source baseline: `ratoker-jpg/four-elements-phaser`

---

## 1. Purpose

This document extracts baseline data tables from the Phaser project so the Godot implementation can start from concrete values, not guesses.

**Extraction rule**: Every value in this document is marked as `PHASER FACT` (extracted verbatim from Phaser source) or `GODOT DECISION` (recommended for Godot). No value is invented; if a value is missing, the cell says `NOT IN PHASER` and the Notes column explains what decision is required.

---

## 2. Factions

**Source**: `src/config/factionData.ts` (`FACTION_CONFIGS`), `src/config/localization.ts` (`FACTION_DISPLAY`, `FACTION_BONUS`, `FACTION_ROLE`), `src/config/coreMechanicsTypes.ts` (`AcceptedFactionId`)

| ID | Russian name | Passive bonus direction | Current placeholder effect | Godot implementation note |
|---|---|---|---|---|
| `cyan` | Поток | mobility / fast tempo | `civilUnitProductionSpeedMultiplier: 1.1` | `res://resources/factions/cyan.tres` — passive multiplier on civil unit production tick |
| `green` | Росток | building / economy | `buildingSpeedMultiplier: 1.1`, `processingSpeedMultiplier: 1.05` | `res://resources/factions/green.tres` — passive multiplier on construction + separator processing |
| `yellow` | Искра | combat production | `combatUnitProductionSpeedMultiplier: 1.1` | `res://resources/factions/yellow.tres` — passive multiplier on combat unit production tick (when implemented) |
| `purple` | Око | vision / territory | `territoryVisionRadiusBonus: 1` | `res://resources/factions/purple.tres` — flat +1 to all vision source radii |

**Rules (PHASER FACT)**:
- Passive bonuses only — no active abilities.
- No unique faction tech trees.
- No direct damage bonuses.
- All values are reference placeholders, not final balance.

**Color values (PHASER FACT)**:
| Faction | primaryColor (CSS) | primaryColorNum (Phaser hex) |
|---|---|---|
| cyan | `#00ffff` | `0x00ffff` |
| green | `#66ff66` | `0x66ff66` |
| yellow | `#ffcc00` | `0xffcc00` |
| purple | `#cc66ff` | `0xcc66ff` |

**Additional start option (GODOT DECISION, from `GAME_DESIGN_BASELINE.md`)**:
- "Random" faction option: chooses one of the 4 factions + `+50 minerals` at game start.

---

## 3. Hulls

**Source**: `src/config/bodyData.ts` (`BODY_CONFIGS`), `src/config/coreMechanicsTypes.ts` (`AcceptedBodyId`, `BodyConfig`, `BodyFootprintClass`, `MLevelData<T>`)

**Accepted hull IDs (7)**: `wasp`, `hornet`, `hunter`, `viking`, `dictator`, `titan`, `mammoth`

**M0-M3 rules (PHASER FACT)**:
- HP increases M0→M3
- Armor increases M0→M3
- Speed increases M0→M3
- Acceleration increases M0→M3
- Braking increases M0→M3
- Body turn speed increases M0→M3
- Mass does NOT change (hard rule)
- Footprint class does NOT change
- Recoil resistance does NOT increase

**Armor formula (PHASER FACT)**: `finalDamage = max(rawDamage - armor, rawDamage * minDamagePercent)`

| ID | Russian name | Role | Footprint class | Mass (kg) | minDamagePercent | HP M0-M3 | Armor M0-M3 | MaxSpeed M0-M3 | Godot scene target |
|---|---|---|---|---|---|---|---|---|---|
| `wasp` | Васп | light fast scout / hit-and-run | light | 2200 | 0.25 | 130/145/165/180 | 2/3/4/5 | 11.5/12.0/12.5/13.0 | `res://scenes/units/hulls/wasp.tscn` |
| `hornet` | Хорнет | light raider / mobile fighter | light | 2400 | 0.22 | 155/170/190/210 | 3/4/5/7 | 10.5/11.0/11.5/12.0 | `res://scenes/units/hulls/hornet.tscn` |
| `hunter` | Хантер | universal medium / baseline | medium | 3000 | 0.20 | 210/235/260/285 | 5/7/9/12 | 8.5/9.0/9.5/10.0 | `res://scenes/units/hulls/hunter.tscn` |
| `viking` | Викинг | medium-heavy brawler | medium | 3000 | 0.18 | 235/260/290/315 | 8/10/13/16 | 7.5/8.0/8.5/9.0 | `res://scenes/units/hulls/viking.tscn` |
| `dictator` | Диктатор | medium-heavy support/control | medium | 3300 | 0.18 | 255/285/315/345 | 7/9/12/15 | 6.8/7.2/7.6/8.0 | `res://scenes/units/hulls/dictator.tscn` |
| `titan` | Титан | heavy frontline / stable firing platform | heavy | 5000 | 0.15 | 310/345/380/420 | 12/16/20/25 | 5.0/5.3/5.7/6.0 | `res://scenes/units/hulls/titan.tscn` |
| `mammoth` | Мамонт | super-heavy fortress | heavy | 5500 | 0.12 | 370/410/455/500 | 16/21/26/32 | 4.2/4.5/4.7/5.0 | `res://scenes/units/hulls/mammoth.tscn` |

**Additional M0-M3 fields (PHASER FACT, not shown in table for brevity)**:
- `acceleration`: wasp 7.0→8.0, hornet 6.0→7.0, hunter 4.7→5.5, viking 4.2→5.0, dictator 3.8→4.5, titan 2.5→3.0, mammoth 2.1→2.5
- `braking`: wasp 5.2→6.0, hornet 4.7→5.5, hunter 3.8→4.5, viking 3.4→4.0, dictator 3.0→3.5, titan 2.1→2.5, mammoth 1.7→2.0
- `bodyTurnSpeed` (deg/s): wasp 130→150, hornet 112→130, hunter 120→140, viking 95→110, dictator 112→130, titan 78→90, mammoth 68→80

**Footprint class grouping (PHASER FACT)**:
- light: wasp, hornet
- medium: hunter, viking, dictator
- heavy: titan, mammoth

**Godot implementation note**: Each hull gets a `.tres` resource with all M0-M3 arrays + a `.tscn` scene with `MeshInstance3D` (hull mesh) + `TurretSocket` (Marker3D for turret mount) + `CollisionShape3D` (footprint). M-level changes modify stat multipliers, not the mesh.

---

## 4. Weapons / turrets

**Source**: `src/config/weaponData.ts` (`WEAPON_CONFIGS`), `src/config/coreMechanicsTypes.ts` (`AcceptedWeaponId`, `WeaponConfig`, `WeaponFireType`, `WeaponRangeClass`)

**Accepted weapon IDs (10)**: `smoky`, `thunder`, `railgun`, `flamethrower`, `freeze`, `isida`, `vulcan`, `twins`, `ricochet`, `hammer`

**Excluded**: `shaft` (explicitly excluded from production config)

**Fire type categories (PHASER FACT)**: `cooldown`, `wind_up`, `canister_stream`, `overheat`, `near_continuous`, `magazine`, `drum`

**Range class (PHASER FACT)**: `short`, `medium`, `long`

**M0-M3 rules (PHASER FACT)**:
- Damage/heal improves M0→M3
- Turret turn speed improves M0→M3
- Profile-specific parameters improve M0→M3
- Railgun M3 still turns slower than short-range weapons at M0

| ID | Russian name | Fire type | Range class | Main damage / support model | VFX profile key | Godot implementation note |
|---|---|---|---|---|---|---|
| `smoky` | Смоки | cooldown | medium | directDamage 16/18/19/20; cooldown 900/850/820/800ms; turretTurn 130/138/144/150 | `instant_projectile` | `res://scenes/units/turrets/smoky.tscn` — projectile + cooldown |
| `thunder` | Гром | cooldown | medium | directDamage 20/22/24/25; splashRadius 1.5; splashFalloff true; selfDamageScale 0.3; cooldown 1400→1200ms | `instant_splash` | Splash projectile + AoE damage |
| `railgun` | Рельса | wind_up | long | directDamage 32/35/38/40; penetration true (max 3 targets); windUp 800→500ms; cooldown 3000→2500ms; turretTurn 70→90 | `line_pierce` | Wind-up + penetrating ray |
| `flamethrower` | Огнемёт | canister_stream | short | damagePerSecond 24/26/28/30; canister capacity 80→110, drain 15→12, regen 6→9 | `cone_stream` | Canister stream + burn VFX |
| `freeze` | Фриз | canister_stream | short | damagePerSecond 12/13/14/15; canister same as flamethrower | `cone_stream` | Canister stream + slow/freeze effect |
| `isida` | Изида | canister_stream | short | heal-only (no damage); healPerSecond 20/22/24/25; target ally | `beam_support` | Heal beam (support weapon) |
| `vulcan` | Вулкан | overheat | medium | directDamage 4/4.5/4.7/5; heatPerShot 12→9, maxHeat 100, cooling 8→11, overheatPenalty 3000ms, spinUp 400ms | `rapid_fire_overheat` | Rapid-fire + overheat mechanic |
| `twins` | Твинс | near_continuous | medium | directDamage 10/11/11.5/12; cooldown 650→600ms | `plasma_projectile` | Twin plasma projectiles |
| `ricochet` | Рикошет | magazine | medium | directDamage 15/16/17/18; stockSize 4/5/5/6, regen 0.5→0.8/sec | `ricochet_projectile` | Magazine + bounce mechanic |
| `hammer` | Молот | drum | short | directDamage 28/30/33/35; volleyCount 3, pelletCount 5, delayBetweenVolleys 250→180ms, reload 3000→2300ms | `shotgun_cone` | Drum/shotgun burst |

**Range values (PHASER FACT, tile units)**:

| Weapon | minRange | idealRange | maxRange | stopDistance |
|---|---|---|---|---|
| smoky | 1 | 5 | 7 | 5 |
| thunder | 2 | 4 | 6 | 4 |
| railgun | 3 | 9 | 13 | 8 |
| flamethrower | 0 | 2 | 4 | 2 |
| freeze | 0 | 2 | 4 | 2 |
| isida | 0 | 2 | 4 | 2 |
| vulcan | 1 | 4 | 6 | 4 |
| twins | 1 | 4 | 6 | 4 |
| ricochet | 1 | 4 | 6 | 4 |
| hammer | 0 | 2 | 4 | 2 |

**Asset normalization note (GODOT DECISION)**: Old modular asset workflow uses `vulcan_b` as a runtime turret ID. Normalize to `vulcan` during Godot asset import.

**Godot implementation note**: Each turret gets a `.tres` resource (stats) + `.tscn` scene with `MeshInstance3D` (turret mesh) + `MuzzleSocket` (Marker3D for projectile spawn) + rotation axis on Y. VFX profile key routes to a `VFXController` child node.

---

## 5. Resources

**Source**: `src/state/types.ts` (`ResourceType`, `RESOURCE_RAW_AMOUNTS`), `src/config/coreMechanicsTypes.ts` (`AcceptedResourceClassId`, `ResourceClassConfig`, `ResourcePlacementZone`)

### 5.1 Legacy resource types (PHASER FACT)

| Legacy ID | Amount | Footprint |
|---|---|---|
| `small` | 20 | 1 |
| `medium` | 60 | 1 |
| `large` | 120 | 1 |
| `infinite` | 999_999 | 3 |

### 5.2 Accepted six-class resource model (PHASER FACT)

| Class ID | Russian name | Strategic role | Placement zone | Footprint | amountMin | amountMax | isInfinite |
|---|---|---|---|---|---|---|---|
| `very_poor` | Очень бедная залежь | starter zone, quick depletion | starter | 1 | NOT IN PHASER (placeholder) | NOT IN PHASER | false |
| `poor` | Бедная залежь | starter zone, initial gathering | starter | 1 | NOT IN PHASER | NOT IN PHASER | false |
| `medium` | Средняя залежь | side zone, stable income | side | 1 | NOT IN PHASER | NOT IN PHASER | false |
| `rich` | Богатая залежь | contested zone, worth fighting for | contested | 1 | NOT IN PHASER | NOT IN PHASER | false |
| `very_rich` | Очень богатая залежь | contested zone, strategic value | contested | 1 | NOT IN PHASER | NOT IN PHASER | false |
| `infinite` | Бесконечная залежь | center of map, never depletes | center | 3 | N/A | N/A | true |

**Note (PHASER FACT)**: The exact `amountMin`/`amountMax` values for finite classes are in `src/config/resourceClassData.ts` (referenced but not read in this audit). The `resolveResourceRawAmount` helper uses midpoint of [amountMin, amountMax] for finite, `RESOURCE_RAW_AMOUNTS.infinite` (999_999) for infinite.

### 5.3 Placement zones (PHASER FACT, from `generatedMap.ts`)

| Zone | Position | Classes used |
|---|---|---|
| starter | Near HQ (within ~10 tiles) | very_poor, poor, medium |
| side | Intermediate distance | medium, rich |
| contested | Far from HQ, near center edges | rich, very_rich |
| center | Map center | infinite (single 2×2 deposit) |

**Infinite deposit rule (PHASER FACT)**: Exactly one infinite resourceClass deposit per map (the center 2×2). Validation enforces this.

### 5.4 Harvester behavior (PHASER FACT + GODOT DECISION)

- PHASER FACT: `handleIdle` searches nearest resource by **harvester position**.
- GODOT DECISION: Auto-gather scoring should use **HQ/base distance** (Denis direction). Manual targeted resource overrides until depleted, then returns to auto-gather.
- PHASER FACT: Gather duration = 1000ms, unload duration = 500ms, cargo capacity = 20 raw, harvester speed = 2.5 tiles/sec.

---

## 6. Buildings

**Source**: `src/state/construction.ts` (`BUILDING_CONFIG`), `src/config/coreMechanicsTypes.ts` (`AcceptedBuildingId`, `BuildingConfig`, `BuildingReadiness`, `BuildingCategory`), `src/config/localization.ts` (`BUILDING_STRINGS`, `BUILDING_ROLE_STRINGS`)

**Accepted building IDs (10)**: `hq`, `separator`, `raw_storage`, `energy_storage`, `elements_storage`, `units_factory`, `power_plant`, `energy_reactor`, `repair_center`, `defense_tower`

**Note on naming (PHASER FACT)**: Phaser `BuildingType` uses kebab-case (`raw-storage`, `matter-storage`); production config uses snake_case (`raw_storage`, `energy_storage`). The mapping is: `matter-storage` → `energy_storage` (displayed as "Хранилище энергии"). Godot should pick ONE convention.

| Accepted ID | Russian name | Role | Category | Readiness | Buildable | Cost (matter) | Build time (ms) | Footprint | HP | Vision radius | Godot status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `hq` | Главное здание | Стартовая база, приём ресурсов, питание, хранилище | core_economy | gameplay_ready | (starting) | N/A | N/A | 3×3 | NOT IN PHASER | 8 | Implement first (M2) |
| `separator` | Сепаратор | Перерабатывает сырьё в энергию и элементы | core_economy | gameplay_ready | yes | 60 | 20000 | 2×2 | NOT IN PHASER | NOT IN PHASER | Implement (M2) |
| `raw_storage` | Хранилище сырья | Увеличивает лимит хранения сырья (+200) | storage | gameplay_ready | yes | 40 | 15000 | 2×2 | NOT IN PHASER | NOT IN PHASER | Implement (M2) |
| `energy_storage` | Хранилище энергии | Увеличивает лимит хранения энергии (+200) | storage | gameplay_ready | yes | 40 | 15000 | 2×2 | NOT IN PHASER | NOT IN PHASER | Implement (M2) |
| `elements_storage` | Хранилище элементов | Увеличивает лимит хранения элементов (+200) | storage | gameplay_ready | yes | 50 | 18000 | 2×2 | NOT IN PHASER | NOT IN PHASER | Implement (M2) |
| `units_factory` | Фабрика юнитов | Производит строителей и сборщиков | production | gameplay_ready | yes | 120 | 40000 | 2×2 | NOT IN PHASER | NOT IN PHASER | Implement (M3) |
| `power_plant` | Электростанция | Вырабатывает питание (+15 power) | power | gameplay_ready | yes | 100 | 25000 | 2×2 | NOT IN PHASER | NOT IN PHASER | Implement (M2) |
| `energy_reactor` | Энергореактор | Улучшенная энергетика (не реализовано) | power | visual_ready | no | 80 | 20000 | 2×2 | NOT IN PHASER | NOT IN PHASER | Defer |
| `repair_center` | Ремонтный центр | Стационарный ремонт (не реализовано) | support | deferred | no | NOT IN PHASER | NOT IN PHASER | NOT IN PHASER | NOT IN PHASER | NOT IN PHASER | Defer |
| `defense_tower` | Оборонная башня | Оборона базы (не реализовано) | defense | deferred | no | NOT IN PHASER | NOT IN PHASER | NOT IN PHASER | NOT IN PHASER | NOT IN PHASER | Defer |

**Storage bonuses (PHASER FACT)**:
- `raw_storage`: +200 raw cap
- `energy_storage` (matter-storage): +200 matter cap
- `elements_storage`: +200 element cap (in elementUnits)

**Power constants (PHASER FACT)**:
- HQ base power: 10
- Power-plant generation: 15 each
- Separator active consumption: 5
- Units-factory active consumption: 4

**Separator processing (PHASER FACT)**:
- Input: 12 raw per cycle
- Output: 10 matter + 2 elementUnits per cycle
- Cycle duration: 5000ms
- Active power consumption: 5

**Building ID normalization (GODOT DECISION)**: Use snake_case consistently in Godot (`raw_storage`, `energy_storage`, `elements_storage`, `units_factory`, `power_plant`, `energy_reactor`, `repair_center`, `defense_tower`). Map Phaser kebab-case to snake_case on any data import.

---

## 7. Production

**Source**: `src/state/production.ts` (`startUnitProduction`, `cancelFactoryQueueItem`, cost lookup helpers), `src/state/types.ts` (production constants)

### 7.1 Builder production (PHASER FACT)

| Field | Value |
|---|---|
| Cost (matter) | 40 |
| Cost (elementUnits) | 10 |
| Production duration | 15000ms (15s) |
| Queue limit | 2 |

### 7.2 Harvester production (PHASER FACT)

| Field | Value |
|---|---|
| Cost (matter) | 50 |
| Cost (elementUnits) | 10 |
| Production duration | 20000ms (20s) |
| Queue limit | 2 |

### 7.3 Wasp+Smoky M0 combat unit (PHASER FACT — reserved constants)

| Field | Value |
|---|---|
| Cost (matter) | 45 (= WASP_CHASSIS_MATTER_COST 20 + SMOKY_WEAPON_MATTER_COST 25) |
| Cost (elementUnits) | 10 (= WASP_CHASSIS_ELEMENT_COST 5 + SMOKY_WEAPON_ELEMENT_COST 5) |
| Production duration | 25000ms (25s) (= WASP_CHASSIS_PRODUCTION_DURATION_MS 7000 + SMOKY_WEAPON_PRODUCTION_DURATION_MS 18000) |
| Queue limit | 2 (shared with builder/harvester) |

### 7.4 Queue rules (PHASER FACT)

- Queue limit: 2 items per factory
- Only the first non-completed item progresses
- Factory consumes 4 power only while actively producing
- If power unavailable, progress pauses (preserved, not reset)
- Completed item does not consume power while waiting to spawn
- Element and matter costs deducted at enqueue time
- Cancel: removes item, **no refund**
- Unit cap: DEFAULT_UNIT_CAP = 10 (builders + harvesters; combat units count toward cap per PR #325)

### 7.5 What is missing (GODOT DECISION)

- **Dynamic hull+turret cost calculation**: Phaser has reserved constants for Wasp+Smoky only. Phase 3/6 of the Phaser roadmap plans `UnitCostTable` with additive hull+turret costs. Godot should design for this from the start: `production_cost = hull_cost + turret_cost`, `production_time = max(hull_time, turret_time) + assembly_offset`.
- **M1/M2/M3 production**: Phaser only reserves M0. Godot should defer M1+ production until XP/upgrade system is designed.
- **Cancel refund**: Phaser has no refund. GODOT DECISION: consider partial refund for in-progress items (Phase 6 of Phaser roadmap mentions this) — defer for now.
- **Combat unit structured key**: Phaser `ProducibleUnitType` is flat string. GODOT DECISION: use structured `CombatProductionRequest { hullId: BodyId, turretId: WeaponId, mod: ModLevel }` from the start.

---

## 8. Starting state

### 8.1 Phaser current state (PHASER FACT)

**Source**: `src/state/createInitialState.ts`, `src/state/generatedMap.ts`

| Item | Value |
|---|---|
| HQ position | (4, mapHeight-7) — lower-left, 3×3 footprint |
| Builder count | 1 (from map data, NE of HQ at hq.tx+1, hq.ty-1) |
| Harvester count | 2 (extra, placed NE of HQ — candidates: east, east-north, north-east, north, west-north) |
| Starter combat tank | 0 in standard mode; 1 Wasp+Smoky M0 only when `includeModularCombat=true` (devtools/arena) |
| Starting raw | 30 (START_RAW) |
| Starting matter | 120 (START_MATTER) |
| Starting elements | 0 for all factions |
| HQ raw cap | 200 |
| HQ matter cap | 200 |
| HQ element cap | 200 (elementUnits) |
| HQ base power | 10 |
| Default unit cap | 10 (builders + harvesters) |

### 8.2 Godot target state (GODOT DECISION)

| Item | Value | Notes |
|---|---|---|
| HQ position | Lower-left, 3×3 footprint | Same as Phaser |
| Builder count | 1 | Same |
| Harvester count | 2 | Same |
| Starter combat tank | **1 Wasp M0 + Smoky M0** | **CHANGE**: part of normal baseline, not dev-only |
| Starting raw | 30 | Same |
| Starting matter | 120 | Same |
| Starting elements | 0 | Same |
| Caps | 200/200/200 | Same |
| HQ base power | 10 | Same |
| Default unit cap | 10 | Same (combat units count toward cap) |

### 8.3 Contradictions

1. **Starter combat tank**: Phaser standard mode strips it (no modular textures loaded). Denis wants it as normal baseline. GODOT DECISION: include starter Wasp+Smoky M0 in normal baseline — Godot has real 3D assets, no texture-loading constraint.
2. **Harvester auto-search origin**: Phaser searches by harvester position. Denis wants HQ-centered. GODOT DECISION: HQ-centered auto-search.
3. **Resource naming**: Phaser internal = raw/matter/elementUnits/power. Denis player-facing = minerals/energy/elements. GODOT DECISION: internal names stay; UI labels use Denis vocabulary. Recommend Russian: Сырьё→Минералы, Энергия (unchanged), Элементы, Питание.

---

## 9. Economy constants summary

**Source**: `src/state/types.ts`

| Constant | Value | Description |
|---|---|---|
| `START_RAW` | 30 | Starting raw minerals |
| `START_MATTER` | 120 | Starting processed matter |
| `HQ_RAW_CAP` | 200 | Base HQ raw storage |
| `HQ_MATTER_CAP` | 200 | Base HQ matter storage |
| `HQ_ELEMENT_CAP` | 200 | Base HQ element storage (elementUnits) |
| `RAW_STORAGE_RAW_BONUS` | 200 | Raw cap bonus per raw-storage building |
| `MATTER_STORAGE_MATTER_BONUS` | 200 | Matter cap bonus per matter-storage building |
| `ELEMENT_STORAGE_ELEMENT_BONUS` | 200 | Element cap bonus per element-storage building |
| `HQ_BASE_POWER` | 10 | Base power from HQ |
| `POWER_PLANT_GENERATION` | 15 | Power per power-plant |
| `SEPARATOR_ACTIVE_POWER_CONSUMPTION` | 5 | Power consumed by active separator |
| `UNITS_FACTORY_ACTIVE_POWER_CONSUMPTION` | 4 | Power consumed by active factory |
| `SEP_RAW_COST` | 12 | Raw consumed per separator cycle |
| `SEP_MATTER_YIELD` | 10 | Matter produced per separator cycle |
| `SEP_ELEMENT_YIELD` | 2 | ElementUnits produced per separator cycle |
| `SEP_CYCLE_MS` | 5000 | Separator cycle duration |
| `ELEMENT_UNITS_PER_ELEMENT` | 10 | Conversion: 10 elementUnits = 1 displayed element |
| `DEFAULT_UNIT_CAP` | 10 | Max civil units (builders + harvesters + combat units) |
| `QUEUE_LIMIT` | 2 | Max items in factory production queue |

---

## 10. Vision constants

**Source**: `src/state/visibility.ts`

| Constant | Value | Description |
|---|---|---|
| `BUILDER_VISION_RADIUS` | 4 | Tiles (diamond/Manhattan) |
| `HARVESTER_VISION_RADIUS` | 5 | Tiles (diamond/Manhattan) |
| `HQ_VISION_RADIUS` | 8 | Tiles (diamond/Manhattan) |
| `PURPLE_FACTION_VISION_BONUS` | 1 | Flat bonus to all sources for purple faction |

**Vision model (PHASER FACT)**: Three-state tile (`unexplored` / `explored` / `visible`). Diamond radius (Manhattan distance `|dx| + |dy| <= radius`). Full recompute per frame. Explored grid persists in saves; visible grid is stripped and recomputed.

---

## 11. Movement constants

**Source**: `src/state/updateGameState.ts`, `src/state/builder.ts`

| Constant | Value | Description |
|---|---|---|
| `DEFAULT_SPEED` (harvester) | 2.5 | Tiles per second |
| `BUILDER_SPEED` | 3.0 | Tiles per second |
| `ARRIVAL_THRESHOLD` | 0.03 | Tiles (sub-pixel snap) |
| `GATHER_DURATION_MS` | 1000 | Harvester gather cycle |
| `UNLOAD_DURATION_MS` | 500 | Harvester unload cycle |
| `DEFAULT_CARGO_CAPACITY` | 20 | Raw units per harvester load |

**Delta clamping (PHASER FACT)**: All update functions clamp `deltaMs` to 200ms max to prevent physics explosion on frame stalls.

---

## 12. Maintenance rule

Update this document when:
- A Godot milestone implements a data table (mark as "IMPLEMENTED in Godot M{x}").
- Phaser balance values change (update PHASER FACT columns).
- Denis resolves an open decision (move from contradictions to the table).
- New data is extracted from Phaser (add row/section).

Keep this document as the single source of truth for baseline data values until Godot has its own balanced config resources.
