extends Node
class_name StartStateLoader

# M2: builds the initial start-state data (HQ, minerals, infinite mineral, starting tank)
# using a MapGrid + OccupancyGrid. Pure data -- does NOT instantiate visual scenes.
# GameRoot reads this data and spawns the visual placeholders.

const HQ_FOOTPRINT := Vector2i(3, 3)
const MINERAL_FOOTPRINT := Vector2i(1, 1)
const INFINITE_MINERAL_FOOTPRINT := Vector2i(2, 2)

const HQ_ENTITY_ID := "hq"
const INFINITE_MINERAL_ENTITY_ID := "infinite_mineral"
const STARTING_TANK_ENTITY_ID := "tank_0"

@export var map_size_cells: Vector2i = Vector2i(64, 64)
@export var cell_size_world: float = 64.0

var map_grid: MapGrid
var occupancy: OccupancyGrid

# Struct-like dictionaries describing the start state.
# Each entry: { entity_id, anchor_cell, footprint, world_position, kind }
var entities: Array = []

func build() -> void:
	map_grid = MapGrid.new(map_size_cells, cell_size_world)
	occupancy = OccupancyGrid.new()
	entities.clear()

	# HQ near lower-left. Anchor at (4, 53) so a 3x3 footprint occupies cells
	# (4..6, 53..55), leaving room from the map edge.
	var hq_anchor := Vector2i(4, 53)
	_register_entity(HQ_ENTITY_ID, hq_anchor, HQ_FOOTPRINT, "hq")

	# Standard 1x1 minerals near HQ starter area.
	var mineral_anchors := [
		Vector2i(10, 50),
		Vector2i(12, 52),
		Vector2i(9, 55),
		Vector2i(13, 56),
		Vector2i(8, 48),
		Vector2i(15, 49),
	]
	for i in range(mineral_anchors.size()):
		var anchor: Vector2i = mineral_anchors[i]
		if not _try_register_entity("mineral_%d" % i, anchor, MINERAL_FOOTPRINT, "mineral"):
			push_warning("StartStateLoader: could not place mineral_%d at %s" % [i, str(anchor)])

	# Infinite 2x2 mineral near map center.
	var center_anchor := Vector2i(31, 31)
	_register_entity(INFINITE_MINERAL_ENTITY_ID, center_anchor, INFINITE_MINERAL_FOOTPRINT, "infinite_mineral")

	# Starting tank does NOT occupy grid cells in M2 (units are ~0.75x0.75 and we
	# do not reserve unit occupancy this milestone). We still record it as an entity
	# for the HUD/selection systems.
	var tank_cell := Vector2i(8, 50)
	entities.append({
		"entity_id": STARTING_TANK_ENTITY_ID,
		"anchor_cell": tank_cell,
		"footprint": Vector2i(0, 0),
		"world_position": map_grid.grid_to_world(tank_cell),
		"kind": "tank",
	})

func _register_entity(entity_id: String, anchor: Vector2i, footprint: Vector2i, kind: String) -> void:
	var cells := map_grid.cells_for_footprint(anchor, footprint)
	for cell in cells:
		if not map_grid.is_in_bounds(cell):
			push_warning("StartStateLoader: entity %s has cell %s out of bounds" % [entity_id, str(cell)])
	occupancy.mark_occupied(entity_id, cells)
	entities.append({
		"entity_id": entity_id,
		"anchor_cell": anchor,
		"footprint": footprint,
		"world_position": map_grid.footprint_center_world(anchor, footprint),
		"kind": kind,
	})

func _try_register_entity(entity_id: String, anchor: Vector2i, footprint: Vector2i, kind: String) -> bool:
	var cells := map_grid.cells_for_footprint(anchor, footprint)
	for cell in cells:
		if not map_grid.is_in_bounds(cell):
			return false
		if not occupancy.is_cell_free(cell):
			return false
	_register_entity(entity_id, anchor, footprint, kind)
	return true

func get_entities_of_kind(kind: String) -> Array:
	var result: Array = []
	for entity in entities:
		if entity.get("kind", "") == kind:
			result.append(entity)
	return result

func get_entity_by_id(entity_id: String) -> Dictionary:
	for entity in entities:
		if entity.get("entity_id", "") == entity_id:
			return entity
	return {}
