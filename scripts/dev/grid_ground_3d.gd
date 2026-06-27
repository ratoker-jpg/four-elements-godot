extends Node3D

# Lightweight dev-only ground and visual grid for M1C.

@export var grid_cells := 40
@export var cell_size := 64.0
@export var ground_color := Color(0.11, 0.14, 0.13, 1.0)
@export var grid_color := Color(0.28, 0.36, 0.34, 1.0)

func _ready() -> void:
	_create_ground()
	_create_grid()

func _create_ground() -> void:
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(grid_cells * cell_size, grid_cells * cell_size)

	var material := StandardMaterial3D.new()
	material.albedo_color = ground_color

	var ground := MeshInstance3D.new()
	ground.name = "GroundPlane"
	ground.mesh = mesh
	ground.material_override = material
	add_child(ground)

func _create_grid() -> void:
	var half_size := grid_cells * cell_size * 0.5
	var line_mesh := ImmediateMesh.new()
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	for index in range(grid_cells + 1):
		var offset := -half_size + float(index) * cell_size
		line_mesh.surface_add_vertex(Vector3(-half_size, 0.06, offset))
		line_mesh.surface_add_vertex(Vector3(half_size, 0.06, offset))
		line_mesh.surface_add_vertex(Vector3(offset, 0.06, -half_size))
		line_mesh.surface_add_vertex(Vector3(offset, 0.06, half_size))

	line_mesh.surface_end()

	var material := StandardMaterial3D.new()
	material.albedo_color = grid_color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var grid := MeshInstance3D.new()
	grid.name = "GridLines"
	grid.mesh = line_mesh
	grid.material_override = material
	add_child(grid)
