extends Node

# M1C single-select controller. It raycasts from the active camera and selects
# objects that expose set_selected()/is_selected().

@export var camera_path: NodePath
@export var ray_length := 5000.0

@onready var camera: Camera3D = get_node_or_null(camera_path) as Camera3D

signal selection_changed(selected_node: Node)

var selected: Node

func _ready() -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d()
	if camera == null:
		push_warning("SelectionController3D has no Camera3D to raycast from.")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_select_from_screen_position(mouse_event.position)

func clear_selection() -> void:
	if selected and selected.has_method("set_selected"):
		selected.set_selected(false)
	if selected != null:
		selected = null
		selection_changed.emit(null)
		return
	selected = null

func get_selected_unit() -> Node:
	return selected

func _select_from_screen_position(screen_position: Vector2) -> void:
	if camera == null:
		clear_selection()
		return

	var origin := camera.project_ray_origin(screen_position)
	var end := origin + camera.project_ray_normal(screen_position) * ray_length
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var space_state := camera.get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query)
	var next_selected: Node = null

	if not result.is_empty():
		next_selected = _find_selectable(result.get("collider"))

	if next_selected != selected:
		if selected and selected.has_method("set_selected"):
			selected.set_selected(false)
		selected = next_selected
		if selected and selected.has_method("set_selected"):
			selected.set_selected(true)
		selection_changed.emit(selected)

func _find_selectable(value: Variant) -> Node:
	if not value is Node:
		return null

	var current := value as Node
	while current:
		if current.has_method("set_selected") and current.has_method("is_selected"):
			return current
		current = current.get_parent()

	return null
