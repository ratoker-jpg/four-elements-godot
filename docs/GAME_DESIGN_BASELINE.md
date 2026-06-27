# Game Design Baseline

## Core vision

Four Elements remains a mobile-friendly RTS:

- player chooses a faction;
- player builds a base;
- harvesters gather minerals;
- buildings produce economy and units;
- territory expands gradually;
- modular combat tanks are assembled from hull + turret;
- the camera is RTS/isometric and readable.

Do not turn the project into a different game.

## Factions

Core factions:

- cyan;
- green;
- yellow;
- purple.

Additional start option:

- Random.

Random should:

- choose one of the four factions;
- keep the selected faction bonus;
- add `+50 minerals` at game start.

## Resources

Resource baseline:

- minerals / matter are the construction base;
- energy is a separate resource;
- element resources are separate progression/faction resources.

Important rule:

```text
Energy must not replace minerals.
```

## Harvester loop

The harvester should:

1. find minerals;
2. move to deposit;
3. harvest;
4. return to base;
5. unload;
6. repeat.

Manual selection and manual movement should remain possible.

## Resource distribution

- many small crystals around starting base;
- some medium crystals near start;
- medium and large crystals closer to center;
- central infinite deposit.

## Territory

Territory should:

- spread gradually;
- color one cell at a time;
- expand as a wave from already owned cells;
- have max radius of `10` cells from a building;
- not block construction;
- not instantly recolor the map.

For a `2×2` building, owned cells under the building should appear gradually across roughly `45–60` seconds, not instantly.

## Construction

The player selects the building type, not the exact tile.

The builder/system should find the nearest suitable place.

Building on enemy territory is allowed.

The error `builder cannot reach` is a bug in normal construction flow, not intended behavior.

## RTS controls

Expected controls:

- manual builder/harvester movement;
- click indicator:
  - green for accepted command;
  - red for blocked path;
- control groups:
  - `1-9` selects group;
  - `Ctrl+1-9` assigns group.

## Animation rule

Stationary units should not idle-bob.

Animation is allowed only during:

- movement;
- gathering;
- construction;
- unloading;
- turning;
- attacking.
