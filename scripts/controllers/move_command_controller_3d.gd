extends Node

# M1D right-click move command controller, polished in M1E.
# Issues move commands to the currently selected unit and shows:
# - a fading target marker at the clicked ground position
# - a straight-line preview from the selected tank to its move target
#
# M1E additions:
# - drives MoveTargetMarker3D for clearer right-click feedback
# - drives MovePreviewLine3D for a straight-line move preview
# - keeps the legacy DebugCommandTarget sphere hidden by default
# - wires move_finished to hide the preview when the tank stops

@export var camera_path: NodePath
@export var selection_controller_path: NodePath
@export var ray_length := 5000.0
@export var show_debug_target_marker := false
# M1E: optional node paths to the dev marker/preview nodes. If unset, the
# controller still works — it just skips the visual feedback.
@export var move_target_marker_path: NodePath
@export var move_preview_line_path: NodePath

@onready var camera: Camera3D = get_node_or_null(camera_path) as Camera3D
@onready var selection_controller: Node = get_node_or_null(selection_controller_path)
@onready var move_target_marker: Node = get_node_or_null(move_target_marker_path)
@onready var move_preview_line: Node = get_node_or_null(move_preview_line_path)

var debug_target_marker: MeshInstance3D
var _wired_unit: Node

func _ready() -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d()
	if camera == null:
		push_warning("MoveCommandController3D has no Camera3D to raycast from.")
	if selection_controller == null:
		push_warning("MoveCommandController3D has no selection controller.")
	_ensure_debug_target_marker()
	_wire_preview_to_selection()

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
	_show_move_target_marker(ground_point)
	_show_preview_line(selected_unit, ground_point)
	_wire_move_finished(selected_unit)

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

# M1E: drive the dev target marker if it is wired in the scene.
func _show_move_target_marker(world_position: Vector3) -> void:
	if move_target_marker == null or not move_target_marker.has_method("show_marker"):
		return
	move_target_marker.show_marker(world_position)

# M1E: drive the dev preview line if it is wired in the scene.
func _show_preview_line(unit: Node, target_position: Vector3) -> void:
	if move_preview_line == null or not move_preview_line.has_method("track_unit"):
		return
	move_preview_line.track_unit(unit)
	if move_preview_line.has_method("show_preview") and unit.has_method("global_position"):
		move_preview_line.show_preview(unit.global_position, target_position)

# M1E: keep the preview line tracking the selected unit so it shrinks as the tank
# approaches the target. Also wire move_finished so the preview hides on arrival.
func _wire_preview_to_selection() -> void:
	if move_preview_line == null or selection_controller == null:
		return
	var selected_unit := _get_selected_unit()
	if selected_unit != null:
		move_preview_line.track_unit(selected_unit)

func _wire_move_finished(unit: Node) -> void:
	if unit == _wired_unit:
		return
	if _wired_unit != null and is_instance_valid(_wired_unit) and _wired_unit.has_signal("move_finished"):
		if _wired_unit.is_connected("move_finished", Callable(self, "_on_unit_move_finished")):
			_wired_unit.disconnect("move_finished", Callable(self, "_on_unit_move_finished"))
	_wired_unit = unit
	if unit != null and unit.has_signal("move_finished"):
		if not unit.is_connected("move_finished", Callable(self, "_on_unit_move_finished")):
			unit.connect("move_finished", Callable(self, "_on_unit_move_finished"))

func _on_unit_move_finished(_final_position: Vector3) -> void:
	if move_preview_line != null and move_preview_line.has_method("hide_preview"):
		move_preview_line.hide_preview()
