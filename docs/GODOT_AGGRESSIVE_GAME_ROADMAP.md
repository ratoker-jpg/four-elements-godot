# GODOT Aggressive Game Roadmap

## 0. Decision

The project is no longer optimizing for tiny low-risk steps.

Current direction:

- Prefer **High / High+ / Very High** vertical-slice milestones.
- Stop spending roadmap time on isolated tank polish unless it blocks the playable game loop.
- Every milestone should make the project feel more like a playable RTS game.
- Technical proofs are useful only when they unlock map, resources, base, economy, production, combat, or win/loss flow.

M1 proved that the 3D asset/runtime path works. The next work should build the game.

---

## 1. Current status

### M1 — 3D / RTS control foundation

Status: **DONE**

Already proven:

- 3DS → GLB → Godot asset path works for the current Wasp/Smoky proof.
- Tank3D can assemble hull + turret + material variant.
- RTS camera exists.
- Single-unit selection exists.
- Right-click movement exists.
- Move target marker and move preview exist.
- Forward-axis hotfix confirmed visually: the tank no longer drives backwards.

Important: this is still **not a game**. It is a technical foundation.

---

## 2. Roadmap principle

### 2.1. High-risk milestones are preferred

Do not split game systems into overly small low-risk PRs unless a blocking bug forces it.

Bad roadmap direction:

- Add one button.
- Add one counter.
- Add one placeholder.
- Polish tank movement.
- Polish turret visual before there is a game loop.

Preferred roadmap direction:

- Add the playable shell.
- Add map + spawn + HQ + resources + HUD.
- Add first economy loop.
- Add construction loop.
- Add production loop.
- Add combat loop.
- Add win/loss loop.

### 2.2. Vertical slice over isolated polish

Each milestone should answer:

> Is there now more of the actual RTS game?

Not:

> Did one technical component become cleaner?

---

## 3. Asset policy

### 3.1. Use real assets when available

If an asset exists in the old Phaser repository or existing local pipeline, use it.

Allowed migration sources:

- current Godot assets
- old Phaser repository assets
- existing generated GLB/texture pipeline outputs
- local 3DS/texture source pipeline when needed

Minerals/resources may be migrated from the old Phaser repository.

Other usable assets from the old Phaser repository should also be considered before creating new temporary visuals.

### 3.2. Placeholder policy

If a required asset does not exist, create a temporary placeholder instead of blocking the gameplay milestone.

Mandatory placeholder rules:

1. Placeholder must be clearly named.

   Examples:

   - `PlaceholderHQ3x3`
   - `PlaceholderFactory2x2`
   - `PlaceholderMineral1x1`
   - `PlaceholderInfiniteMineral2x2`

2. Placeholder must be visually obvious as temporary.

   Examples:

   - simple colored cube
   - simple colored cylinder
   - basic low-poly marker
   - debug material

3. Placeholder must be documented in the milestone report.

4. Placeholder must be easy to replace later.

5. Placeholder scene should keep the same public contract as the future real asset.

   Examples:

   - same root node type
   - same footprint metadata
   - same collision size
   - same script API where possible

6. Every placeholder must include a replacement note.

   Suggested comment:

   ```gdscript
   # PLACEHOLDER_ASSET: replace with final asset when available.
   ```

7. Do not hide placeholders inside generic names.

   Bad:

   - `HQ.tscn` with no note that it is fake
   - `Mineral.tscn` with hidden debug geometry

   Good:

   - `HQ.tscn` using child `PlaceholderHQ3x3`
   - report section: `Temporary assets used`

---

## 4. Grid / footprint rules

These rules are project-level defaults unless a later design document overrides them.

| Entity type | Footprint |
|---|---:|
| Base / HQ | `3x3` tiles |
| Other buildings | `2x2` tiles |
| Standard minerals | `1x1` tile |
| Infinite mineral deposit | `2x2` tiles |
| Units | smaller than `1x1`, approx `0.75x0.75` |

### 4.1. Base

The main base / HQ occupies a 3x3 tile footprint.

This should be used for:

- placement validation
- blocking/collision footprint
- map spawn layout
- resource pathing assumptions

### 4.2. Other buildings

Default non-HQ building footprint is 2x2.

Examples:

- factory
- storage
- separator
- power plant
- repair building
- tower, unless later design requires another footprint

### 4.3. Minerals

Default mineral/resource node footprint is 1x1.

The infinite/center mineral deposit is 2x2.

### 4.4. Units

Units should be smaller than a full tile.

Default unit footprint target:

```text
0.75 x 0.75 tiles
```

This keeps units readable inside tile-based placement/pathing without visually filling the whole tile.

---

## 5. Map size rules

The Godot roadmap uses 3 map variants:

| Variant | Target size |
|---|---:|
| Small | `64x64` |
| Medium | `96x96` |
| Huge | `128x128` |

### 5.1. Phaser source note

The old Phaser repository currently contains generated map size constants:

| Phaser option | Size |
|---|---:|
| `small` | `32x32` |
| `standard` | `48x48` |
| `large` | `64x64` |

For the Godot roadmap, use the new target set:

```text
64x64 / 96x96 / 128x128
```

Treat the Phaser sizes as legacy/half-scale reference unless a later implementation PR decides to preserve exact Phaser parity.

---

## 6. Aggressive milestone roadmap

## M2 — Playable Game Shell + Map + Start State

Risk: **High**

Goal:

> Launch the project and see the beginning of an RTS game, not a dev scene.

Scope:

- playable game entry scene
- menu or direct game start, whichever is faster and cleaner
- game scene with map root
- map bounds
- visible terrain/ground
- player spawn zone
- starting Tank3D from M1
- HQ/base placeholder, 3x3
- standard mineral placeholders, 1x1
- infinite mineral placeholder, 2x2, preferably near/at center
- HUD placeholder with at least:
  - Raw
  - Energy
  - Units
- documentation: what scene to run and how to validate

Acceptance criteria:

- User can run one clear scene from Godot.
- Scene visually communicates: map + base + resources + unit.
- Tank can still be selected and moved.
- HQ and minerals are visible.
- Placeholder assets are clearly marked if used.

Explicitly excluded:

- full economy
- harvesting loop
- construction
- production
- combat
- AI
- win/loss

---

## M3 — First Economy Loop

Risk: **Very High**

Goal:

> Player can collect raw resource and see the economy counter change.

Scope:

- ResourceNode with amount
- Harvester unit or temporary harvester placeholder
- command harvester to resource
- harvest timer
- cargo state
- return/deposit to HQ
- Raw counter update in HUD

Acceptance criteria:

- Player can cause raw to increase through a visible harvester/resource/HQ loop.
- Resource amount decreases unless the node is infinite.
- Infinite deposit does not run out.
- HUD updates from game state, not hardcoded UI text.

Explicitly excluded:

- production queue
- building placement
- advanced pathfinding
- AI opponent
- combat

---

## M4 — Construction Loop

Risk: **Very High**

Goal:

> Player can spend resources to place a building.

Scope:

- building catalog starter set
- building ghost
- tile footprint validation
- HQ 3x3 rule
- other buildings 2x2 rule
- resource cost
- Raw spending
- construction timer
- completed building appears on map

Acceptance criteria:

- Player can select/build at least one building.
- If resources are insufficient, build is rejected.
- If footprint is blocked, build is rejected.
- If valid, resources are spent and building appears after timer.

Explicitly excluded:

- full tech tree
- advanced UI polish
- AI
- combat

---

## M5 — Production Loop

Risk: **High+**

Goal:

> Player can produce a new unit from a building.

Scope:

- Factory building
- production UI
- production cost
- production timer
- spawn point
- new unit spawn
- unit selectable/movable after spawn

Acceptance criteria:

- Player can spend resources and create a unit.
- Spawned unit works with existing selection and movement.

Explicitly excluded:

- multiple queues
- upgrades
- AI
- combat polish

---

## M6 — Combat Loop

Risk: **High+**

Goal:

> Units can attack and destroy a target.

Scope:

- enemy dummy unit/building
- turret aim
- muzzle socket projectile spawn
- projectile visual
- hit detection
- HP
- damage
- death/despawn

Acceptance criteria:

- Player unit can attack a target.
- Target loses HP.
- Target dies at 0 HP.

Explicitly excluded:

- advanced AI
- balance pass
- upgrades
- full faction asymmetry

---

## M7 — Match Objective

Risk: **Very High**

Goal:

> The game can be won or lost.

Scope:

- enemy base or wave spawner
- simple enemy behavior
- win condition
- lose condition
- restart/return to menu

Acceptance criteria:

- Player can win.
- Player can lose.
- Result is visible in UI.

---

## 7. PR policy

### 7.1. Preferred PR shape

Each PR should be a meaningful vertical slice.

Preferred:

- `GODOT-M2: Playable Game Shell + Map + Start State`
- `GODOT-M3: First Economy Loop`
- `GODOT-M4: Construction Loop`

Avoid:

- `Add one label`
- `Add one empty node`
- `Move one script`
- `Polish tank marker`

### 7.2. When small PRs are allowed

Small PRs are allowed only when:

- a blocking bug prevents the current milestone from being validated
- a hotfix is required after merge
- repository hygiene is required before a high-risk milestone
- an asset import issue blocks the vertical slice

### 7.3. Validation expectations

High-risk milestones must include:

- clear manual test steps
- scene to run
- expected result
- known placeholders
- known limitations
- final status

Final statuses should be explicit:

- `READY_FOR_LOCAL_VALIDATION`
- `READY_FOR_MERGE_AFTER_LOCAL_VALIDATION`
- `BLOCKED_GDSCRIPT_PARSE`
- `BLOCKED_SCENE_LOAD`
- `BLOCKED_RUNTIME_ERROR`
- `BLOCKED_ASSET_MISSING`

---

## 8. Immediate next milestone

Next PR should be:

```text
GODOT-M2: Playable Game Shell + Map + Start State
```

Risk: **High**

The goal is to stop launching isolated dev scenes and start launching a recognizable RTS game shell.

M2 must create the first clear gameplay scene with:

- map
- HQ placeholder
- minerals/resource placeholders
- starting unit
- HUD placeholder
- current selection/movement still working

After M2, the project should feel like the beginning of a game, not a tank test.
