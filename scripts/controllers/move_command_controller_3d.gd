extends Node

# M1D right-click move command controller for the currently selected unit.

@export var camera_path: NodePath
@export var selection_controller_path: NodePath
@export var ray_length := 5000.0
@export var show_debug_target_marker := true

@onready var camera: Camera3D = get_node_or_null(camera_path) as Camera3D
@onready var selection_controller: Node = get_node_or_null(selection_controller_path)

var debug_target_marker: MeshInstance3D

func _ready() -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d()
	if camera == null:
		push_warning("MoveCommandController3D has no Camera3D to raycast from.")
	if selection_controller == null:
		push_warning("MoveCommandController3D has no selection controller.")
	_ensure_debug_target_marker()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			_command_move_from_screen_position(mouse_event.position)

func _command_move_from_screen_position(screen_position: Vector2) -> void:
	var selected_unit := _get_selected_unit()
	if selected_unit == null or not selected_unit.has_method("move_to"):
		return

	var ground_point: Variant = _raycast_ground(screen_position)
	if ground_point == null:
		return

	selected_unit.move_to(ground_point)
	_show_debug_target(ground_point)

func _get_selected_unit() -> Node:
	if selection_controller == null or not selection_controller.has_method("get_selected_unit"):
		return null
	return selection_controller.get_selected_unit()

func _raycast_ground(screen_position: Vector2) -> Variant:
	if camera == null:
		return null

	var origin := camera.project_ray_origin(screen_position)
	var end := origin + camera.project_ray_normal(screen_position) * ray_length
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	return result.get("position")

func _ensure_debug_target_marker() -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 12.0
	mesh.height = 24.0
	mesh.radial_segments = 16
	mesh.rings = 8

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.35, 0.05, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.95, 0.35, 0.05, 1.0)
	material.emission_energy_multiplier = 1.2

	debug_target_marker = MeshInstance3D.new()
	debug_target_marker.name = "DebugCommandTarget"
	debug_target_marker.mesh = mesh
	debug_target_marker.material_override = material
	debug_target_marker.visible = false
	add_child(debug_target_marker)

func _show_debug_target(world_position: Vector3) -> void:
	if debug_target_marker == null:
		return

	debug_target_marker.visible = show_debug_target_marker
	if show_debug_target_marker:
		debug_target_marker.global_position = world_position + Vector3.UP * 12.0
