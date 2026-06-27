extends Node3D

# M1E dev-only straight-line move preview.
# Draws a simple line from the selected tank to its current move target.
# This is NOT pathfinding — just a straight-line debug preview.
# Hide the preview when there is no selected unit or no active move target.

@export var line_width := 3.0
@export var line_color := Color(0.2, 0.85, 1.0, 0.85)
@export var lift_height := 3.0

var _line: MeshInstance3D
var _material: StandardMaterial3D
var _tracked_unit: Node

func _ready() -> void:
	_ensure_line()
	hide_preview()

func track_unit(unit: Node) -> void:
	_tracked_unit = unit

func show_preview(from_position: Vector3, to_position: Vector3) -> void:
	if _line == null:
		_ensure_line()
	if _line == null:
		return

	var from: Vector3 = Vector3(from_position.x, from_position.y + lift_height, from_position.z)
	var to: Vector3 = Vector3(to_position.x, to_position.y + lift_height, to_position.z)
	var distance: float = from.distance_to(to)
	if distance < 0.001:
		hide_preview()
		return

	# Build a thin box mesh oriented along the from->to direction.
	var mesh := BoxMesh.new()
	mesh.size = Vector3(line_width, line_width, distance)

	if _line.mesh is BoxMesh:
		_line.mesh = mesh
	else:
		_line.mesh = mesh

	_line.visible = true

	# Position at midpoint and look_at the target so the box's -Z axis points at it.
	var midpoint: Vector3 = from.lerp(to, 0.5)
	_line.global_position = midpoint
	_line.look_at(to, Vector3.UP)

func hide_preview() -> void:
	if _line:
		_line.visible = false

func _process(_delta: float) -> void:
	# Continuously update the preview while the tracked unit is moving so the line
	# shrinks as the tank approaches the target.
	if _tracked_unit == null or not is_instance_valid(_tracked_unit):
		hide_preview()
		return

	if not _tracked_unit.has_method("is_moving") or not _tracked_unit.is_moving():
		hide_preview()
		return

	if not _tracked_unit.has_method("get_move_target"):
		hide_preview()
		return

	var tracked_unit_3d: Node3D = _tracked_unit as Node3D
	if tracked_unit_3d == null:
		hide_preview()
		return

	var from: Vector3 = tracked_unit_3d.global_position
	var to: Vector3 = _tracked_unit.get_move_target()
	show_preview(from, to)

func _ensure_line() -> void:
	if _line != null:
		return

	var mesh := BoxMesh.new()
	mesh.size = Vector3(line_width, line_width, 1.0)

	_material = StandardMaterial3D.new()
	_material.albedo_color = line_color
	_material.emission_enabled = true
	_material.emission = line_color
	_material.emission_energy_multiplier = 0.8
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.no_depth_test = true

	_line = MeshInstance3D.new()
	_line.name = "MovePreviewLine"
	_line.top_level = true
	_line.mesh = mesh
	_line.material_override = _material
	_line.visible = false
	add_child(_line)
