extends Node3D

# Simple M1C RTS camera rig. The rig pans over the X/Z plane while its child
# Camera3D looks down from an isometric-ish offset.

@export var pan_speed := 420.0
@export var zoom_speed := 90.0
@export var min_zoom := 220.0
@export var max_zoom := 900.0
@export var edge_scroll_enabled := false
@export var edge_scroll_margin := 24.0
@export var rotate_speed := 1.8

@onready var camera: Camera3D = $Camera3D

var zoom := 520.0
var yaw := 0.0

func _ready() -> void:
	_update_camera_transform()

func _process(delta: float) -> void:
	var pan_input := _get_pan_input()
	if edge_scroll_enabled:
		pan_input += _get_edge_scroll_input()
	if pan_input.length_squared() > 1.0:
		pan_input = pan_input.normalized()

	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var forward := Vector3(sin(yaw), 0.0, cos(yaw))
	global_position += (right * pan_input.x + forward * pan_input.y) * pan_speed * delta

	var rotate_input := 0.0
	if Input.is_key_pressed(KEY_Q):
		rotate_input += 1.0
	if Input.is_key_pressed(KEY_E):
		rotate_input -= 1.0
	if rotate_input != 0.0:
		yaw += rotate_input * rotate_speed * delta
		_update_camera_transform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = max(min_zoom, zoom - zoom_speed)
			_update_camera_transform()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = min(max_zoom, zoom + zoom_speed)
			_update_camera_transform()

func get_camera() -> Camera3D:
	return camera

func _get_pan_input() -> Vector2:
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input.y += 1.0
	return input

func _get_edge_scroll_input() -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return Vector2.ZERO

	var mouse_position := viewport.get_mouse_position()
	var viewport_size := Vector2(viewport.get_visible_rect().size)
	var input := Vector2.ZERO

	if mouse_position.x <= edge_scroll_margin:
		input.x -= 1.0
	elif mouse_position.x >= viewport_size.x - edge_scroll_margin:
		input.x += 1.0
	if mouse_position.y <= edge_scroll_margin:
		input.y -= 1.0
	elif mouse_position.y >= viewport_size.y - edge_scroll_margin:
		input.y += 1.0

	return input

func _update_camera_transform() -> void:
	if camera == null:
		return

	var horizontal_distance := zoom * 0.85
	var height := zoom * 0.65
	var offset := Vector3(sin(yaw) * horizontal_distance, height, cos(yaw) * horizontal_distance)
	camera.position = offset
	camera.look_at(global_position, Vector3.UP)
