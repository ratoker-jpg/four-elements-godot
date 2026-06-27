extends Node3D

# M1E dev-only move target marker.
# Shows a fading ring at the clicked ground position when a move command is issued.
# Does not participate in picking/raycast (no collision, top_level = true).
# The marker fades out over marker_lifetime seconds and then hides itself.

@export var marker_radius := 14.0
@export var marker_lifetime := 0.8
@export var initial_alpha := 1.0
@export var lift_height := 2.0

var _mesh_instance: MeshInstance3D
var _material: StandardMaterial3D
var _elapsed: float = 0.0
var _active: bool = false

func _ready() -> void:
	_ensure_mesh()
	hide_marker()

func show_marker(world_position: Vector3) -> void:
	if _mesh_instance == null:
		_ensure_mesh()
	if _mesh_instance == null:
		return

	_mesh_instance.global_position = Vector3(
		world_position.x,
		world_position.y + lift_height,
		world_position.z,
	)
	_elapsed = 0.0
	_active = true
	_mesh_instance.visible = true
	_apply_alpha(initial_alpha)

func hide_marker() -> void:
	_active = false
	if _mesh_instance:
		_mesh_instance.visible = false

func _process(delta: float) -> void:
	if not _active:
		return

	_elapsed += delta
	if _elapsed >= marker_lifetime:
		hide_marker()
		return

	var t := _elapsed / marker_lifetime
	var alpha := clampf(lerpf(initial_alpha, 0.0, t), 0.0, 1.0)
	_apply_alpha(alpha)

func _ensure_mesh() -> void:
	if _mesh_instance != null:
		return

	var mesh := CylinderMesh.new()
	mesh.top_radius = marker_radius
	mesh.bottom_radius = marker_radius
	mesh.height = 1.0
	mesh.radial_segments = 32
	mesh.rings = 1

	_material = StandardMaterial3D.new()
	_material.albedo_color = Color(0.15, 0.7, 1.0, initial_alpha)
	_material.emission_enabled = true
	_material.emission = Color(0.15, 0.7, 1.0, 1.0)
	_material.emission_energy_multiplier = 1.2
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.no_depth_test = true

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "MoveTargetMarker"
	_mesh_instance.top_level = true
	_mesh_instance.mesh = mesh
	_mesh_instance.material_override = _material
	add_child(_mesh_instance)

func _apply_alpha(alpha: float) -> void:
	if _material == null:
		return
	var color := _material.albedo_color
	_material.albedo_color = Color(color.r, color.g, color.b, alpha)
