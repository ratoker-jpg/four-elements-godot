extends RefCounted
class_name MapGrid

# M2: pure-data grid/world coordinate layer. No visuals, no Node3D, no Godot scene
# dependency. Systems own this; visual nodes read from it for placement.
#
# Anchor convention: TOP-LEFT.
#   - For a footprint of size (w, h) anchored at cell (cx, cy), the footprint
#     occupies cells (cx..cx+w-1, cy..cy+h-1).
#   - The anchor cell is the top-left corner of the footprint in grid space.
#   - grid_to_world(anchor_cell) returns the world position of the CENTER of
#     the anchor cell -- NOT the corner. This keeps 1x1 footprints centered.
#   - For multi-cell footprints, callers should compute the center via
#     footprint_center_world(anchor_cell, footprint_size) for visual placement.

@export var map_size_cells: Vector2i = Vector2i(64, 64)
@export var cell_size_world: float = 64.0

func _init(p_map_size_cells: Vector2i = Vector2i(64, 64), p_cell_size_world: float = 64.0) -> void:
	map_size_cells = p_map_size_cells
	cell_size_world = p_cell_size_world

# Convert a grid cell to the world position of that cell's CENTER.
func grid_to_world(cell: Vector2i) -> Vector3:
	var half_cell := cell_size_world * 0.5
	return Vector3(
		float(cell.x) * cell_size_world + half_cell,
		0.0,
		float(cell.y) * cell_size_world + half_cell,
	)

# Convert a world position to the grid cell that contains it.
func world_to_grid(world_position: Vector3) -> Vector2i:
	return Vector2i(
		int(floor(world_position.x / cell_size_world)),
		int(floor(world_position.z / cell_size_world)),
	)

func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < map_size_cells.x and cell.y < map_size_cells.y

# Return all cells covered by a footprint anchored at anchor_cell (top-left convention).
func cells_for_footprint(anchor_cell: Vector2i, footprint_size: Vector2i) -> Array:
	var cells: Array = []
	for dy in range(footprint_size.y):
		for dx in range(footprint_size.x):
			cells.append(Vector2i(anchor_cell.x + dx, anchor_cell.y + dy))
	return cells

# World-space center of a footprint anchored at anchor_cell.
func footprint_center_world(anchor_cell: Vector2i, footprint_size: Vector2i) -> Vector3:
	var half_w := (float(footprint_size.x) * 0.5) * cell_size_world
	var half_h := (float(footprint_size.y) * 0.5) * cell_size_world
	var anchor_world := Vector3(
		float(anchor_cell.x) * cell_size_world,
		0.0,
		float(anchor_cell.y) * cell_size_world,
	)
	return anchor_world + Vector3(half_w, 0.0, half_h)

func map_world_size() -> Vector2:
	return Vector2(
		float(map_size_cells.x) * cell_size_world,
		float(map_size_cells.y) * cell_size_world,
	)
