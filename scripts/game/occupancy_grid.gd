extends RefCounted
class_name OccupancyGrid

# M2: tracks which cells are occupied by which entity. Pure data, no visuals.
# Entity IDs are strings (e.g. "hq", "mineral_0", "infinite_mineral", "tank_0").

var _cell_to_entity: Dictionary = {}
var _entity_to_cells: Dictionary = {}

func clear() -> void:
	_cell_to_entity.clear()
	_entity_to_cells.clear()

func mark_occupied(entity_id: String, cells: Array) -> void:
	# Remove any previous occupancy for this entity, then re-add.
	clear_occupied(entity_id)
	var cell_list: Array = []
	for cell in cells:
		if cell is Vector2i:
			_cell_to_entity[cell] = entity_id
			cell_list.append(cell)
	_entity_to_cells[entity_id] = cell_list

func clear_occupied(entity_id: String) -> void:
	if not _entity_to_cells.has(entity_id):
		return
	for cell in _entity_to_cells[entity_id]:
		if _cell_to_entity.get(cell) == entity_id:
			_cell_to_entity.erase(cell)
	_entity_to_cells.erase(entity_id)

func is_cell_free(cell: Vector2i) -> bool:
	return not _cell_to_entity.has(cell)

func are_cells_free(cells: Array) -> bool:
	for cell in cells:
		if cell is Vector2i and _cell_to_entity.has(cell):
			return false
	return true

func get_occupant(cell: Vector2i) -> String:
	return _cell_to_entity.get(cell, "")

func get_cells_for_entity(entity_id: String) -> Array:
	return _entity_to_cells.get(entity_id, [])

func occupied_cell_count() -> int:
	return _cell_to_entity.size()

func get_all_occupied_cells() -> Array:
	return _cell_to_entity.keys()

func entity_count() -> int:
	return _entity_to_cells.size()
