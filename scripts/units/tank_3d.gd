extends Node3D

# GODOT-M1B runtime skeleton only.
# Loads a hull and turret, assembles them through marker nodes with metadata fallback,
# and applies faction materials. Gameplay behavior belongs in later milestones.

const SUPPORTED_FACTIONS := ["cyan", "green", "yellow", "purple"]

const HULLS := {
	"wasp": {
		"scene_path": "res://assets/models/hulls/wasp/wasp_0123.glb",
		"metadata_path": "res://assets/metadata/hulls/wasp_0123.json",
		"material_dir": "res://assets/materials/hulls/wasp",
		"socket_name": "TurretSocket",
	}
}

const TURRETS := {
	"smoky": {
		"scene_path": "res://assets/models/turrets/smoky/smoky_01.glb",
		"metadata_path": "res://assets/metadata/turrets/smoky_01.json",
		"material_dir": "res://assets/materials/turrets/smoky",
		"pivot_name": "TurretPivot",
		"muzzle_name": "MuzzleSocket",
	}
}

@export var hull_id := "wasp"
@export var turret_id := "smoky"
@export_enum("cyan", "green", "yellow", "purple") var faction := "cyan"
@export var hull_mod := "m0"
@export var turret_mod := "m0"
@export var show_debug_markers := true
@export var move_speed := 4.0
@export var turn_speed := 8.0
@export var stop_distance := 0.15
@export var movement_enabled := true
@export var show_debug_move_target := true

@onready var hull_root: Node3D = $HullRoot
@onready var turret_root: Node3D = $TurretRoot
@onready var debug_root: Node3D = $DebugRoot
@onready var selection_indicator: Node3D = $SelectionIndicator

var hull_instance: Node3D
var turret_instance: Node3D
var selected := false
var move_target := Vector3.ZERO
var move_target_active := false
var debug_move_target_marker: MeshInstance3D

func _ready() -> void:
	rebuild()
	set_selected(selected)
	_ensure_debug_move_target_marker()

func _process(delta: float) -> void:
	_update_movement(delta)

func set_selected(value: bool) -> void:
	selected = value
	if selection_indicator:
		selection_indicator.visible = selected

func is_selected() -> bool:
	return selected

func get_selection_root() -> Node3D:
	return self

func move_to(world_position: Vector3) -> void:
	if not movement_enabled:
		return

	move_target = Vector3(world_position.x, global_position.y, world_position.z)
	move_target_active = true
	_update_debug_move_target_marker()

func stop_moving() -> void:
	move_target_active = false
	_update_debug_move_target_marker()

func has_move_target() -> bool:
	return move_target_active

func get_move_target() -> Vector3:
	return move_target

func rebuild() -> void:
	_clear_runtime_children()

	var hull_definition := _get_definition(HULLS, hull_id, "hull")
	var turret_definition := _get_definition(TURRETS, turret_id, "turret")
	if hull_definition.is_empty() or turret_definition.is_empty():
		return

	var hull_metadata := _read_json(String(hull_definition["metadata_path"]))
	var turret_metadata := _read_json(String(turret_definition["metadata_path"]))
	if hull_metadata.is_empty() or turret_metadata.is_empty():
		return

	hull_instance = _instantiate_scene(String(hull_definition["scene_path"]), "%s_hull" % hull_id)
	turret_instance = _instantiate_scene(String(turret_definition["scene_path"]), "%s_turret" % turret_id)
	if hull_instance == null or turret_instance == null:
		return

	hull_root.add_child(hull_instance)
	turret_root.add_child(turret_instance)

	_apply_material_recursive(hull_instance, _load_material(String(hull_definition["material_dir"]), faction, hull_mod))
	_apply_material_recursive(turret_instance, _load_material(String(turret_definition["material_dir"]), faction, turret_mod))

	var socket_name := String(hull_definition["socket_name"])
	var pivot_name := String(turret_definition["pivot_name"])
	var muzzle_name := String(turret_definition["muzzle_name"])

	var socket_local := _marker_local_or_metadata(
		hull_instance,
		socket_name,
		_get_nested_array(hull_metadata, ["sockets", socket_name, "local_position"])
	)
	var pivot_local := _marker_local_or_metadata(
		turret_instance,
		pivot_name,
		_get_nested_array(turret_metadata, ["markers", pivot_name, "local_position"])
	)
	var muzzle_local := _marker_local_or_metadata(
		turret_instance,
		muzzle_name,
		_get_nested_array(turret_metadata, ["markers", muzzle_name, "local_position"])
	)

	turret_root.position = socket_local - pivot_local
	debug_root.visible = show_debug_markers
	if show_debug_markers:
		_add_marker("TurretSocket", socket_local, Color.CYAN, 4.0)
		_add_marker("TurretPivot", turret_root.position + pivot_local, Color.YELLOW, 4.0)
		_add_marker("MuzzleSocket", turret_root.position + muzzle_local, Color.RED, 7.0)

func _get_definition(definitions: Dictionary, asset_id: String, asset_kind: String) -> Dictionary:
	if definitions.has(asset_id):
		return definitions[asset_id]
	push_error("Unsupported %s_id: %s" % [asset_kind, asset_id])
	return {}

func _clear_runtime_children() -> void:
	for root in [hull_root, turret_root, debug_root]:
		for child in root.get_children():
			root.remove_child(child)
			child.queue_free()
	hull_instance = null
	turret_instance = null
	turret_root.position = Vector3.ZERO

func _read_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("Missing or empty metadata: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid metadata JSON: %s" % path)
		return {}
	return parsed

func _instantiate_scene(path: String, node_name: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Could not load GLB scene: %s" % path)
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		push_error("GLB root is not Node3D: %s" % path)
		return null
	instance.name = node_name
	return instance

func _load_material(material_dir: String, material_faction: String, mod_id: String) -> Material:
	if not SUPPORTED_FACTIONS.has(material_faction):
		push_error("Unsupported faction: %s" % material_faction)
		return null

	var material_path := "%s/%s_%s.tres" % [material_dir, material_faction, mod_id]
	if not ResourceLoader.exists(material_path):
		push_error("Missing material: %s" % material_path)
		return null
	return load(material_path) as Material

func _apply_material_recursive(node: Node, material: Material) -> void:
	if material == null:
		return
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh:
			for surface_index in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(surface_index, material)
	for child in node.get_children():
		_apply_material_recursive(child, material)

func _marker_local_or_metadata(root: Node3D, marker_name: String, fallback_values: Array) -> Vector3:
	var marker := _find_descendant_by_name(root, marker_name)
	if marker is Node3D:
		return root.to_local((marker as Node3D).global_position)
	push_warning("Marker %s not found in %s; falling back to sidecar metadata vector." % [marker_name, root.name])
	return _vector_from_array(fallback_values)

func _find_descendant_by_name(root: Node, node_name: String) -> Node:
	if root.name == node_name:
		return root
	for child in root.get_children():
		var found := _find_descendant_by_name(child, node_name)
		if found:
			return found
	return null

func _get_nested_array(metadata: Dictionary, keys: Array) -> Array:
	var current: Variant = metadata
	for key in keys:
		if typeof(current) != TYPE_DICTIONARY or not current.has(key):
			push_error("Metadata path missing: %s" % "/".join(keys))
			return []
		current = current[key]
	if typeof(current) != TYPE_ARRAY:
		push_error("Metadata path is not an array: %s" % "/".join(keys))
		return []
	return current

func _vector_from_array(values: Array) -> Vector3:
	if values.size() < 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))

func _add_marker(marker_name: String, marker_position: Vector3, color: Color, radius: float) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.5

	var marker := MeshInstance3D.new()
	marker.name = marker_name
	marker.mesh = mesh
	marker.material_override = material
	marker.position = marker_position
	debug_root.add_child(marker)

func _update_movement(delta: float) -> void:
	if not movement_enabled or not move_target_active:
		return

	var current_position := global_position
	var offset := Vector3(
		move_target.x - current_position.x,
		0.0,
		move_target.z - current_position.z
	)
	var distance := offset.length()
	if distance <= stop_distance:
		global_position = Vector3(move_target.x, current_position.y, move_target.z)
		stop_moving()
		return

	var direction := offset / distance
	var step: float = min(move_speed * delta, distance)
	global_position = current_position + direction * step

	if direction.length_squared() > 0.0:
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, min(turn_speed * delta, 1.0))

func _ensure_debug_move_target_marker() -> void:
	if debug_move_target_marker != null:
		return

	var mesh := SphereMesh.new()
	mesh.radius = 10.0
	mesh.height = 20.0
	mesh.radial_segments = 16
	mesh.rings = 8

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.65, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.65, 1.0, 1.0)
	material.emission_energy_multiplier = 1.2

	debug_move_target_marker = MeshInstance3D.new()
	debug_move_target_marker.name = "DebugMoveTarget"
	debug_move_target_marker.top_level = true
	debug_move_target_marker.mesh = mesh
	debug_move_target_marker.material_override = material
	add_child(debug_move_target_marker)
	_update_debug_move_target_marker()

func _update_debug_move_target_marker() -> void:
	if debug_move_target_marker == null:
		return

	debug_move_target_marker.visible = show_debug_move_target and move_target_active
	if debug_move_target_marker.visible:
		debug_move_target_marker.global_position = move_target + Vector3.UP * 8.0
