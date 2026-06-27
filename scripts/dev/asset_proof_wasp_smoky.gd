extends Node3D

# GODOT-M1A asset proof only.
# This is not gameplay and not the final Tank3D architecture. It only verifies that
# the M0G Wasp/Smoky GLB, material, and metadata package can assemble in Godot.

const WASP_SCENE := "res://assets/models/hulls/wasp/wasp_0123.glb"
const SMOKY_SCENE := "res://assets/models/turrets/smoky/smoky_01.glb"
const WASP_MATERIAL := "res://assets/materials/hulls/wasp/cyan_m0.tres"
const SMOKY_MATERIAL := "res://assets/materials/turrets/smoky/cyan_m0.tres"
const WASP_METADATA := "res://assets/metadata/hulls/wasp_0123.json"
const SMOKY_METADATA := "res://assets/metadata/turrets/smoky_01.json"

@onready var hull_mount: Node3D = $VehicleRoot/HullMount
@onready var turret_mount: Node3D = $VehicleRoot/TurretMount
@onready var marker_root: Node3D = $VehicleRoot/DebugMarkers

func _ready() -> void:
	var wasp_metadata := _read_json(WASP_METADATA)
	var smoky_metadata := _read_json(SMOKY_METADATA)

	var hull_instance := _instantiate_scene(WASP_SCENE, "WaspHull")
	var turret_instance := _instantiate_scene(SMOKY_SCENE, "SmokyTurret")
	hull_mount.add_child(hull_instance)
	turret_mount.add_child(turret_instance)

	_apply_material_recursive(hull_instance, load(WASP_MATERIAL) as Material)
	_apply_material_recursive(turret_instance, load(SMOKY_MATERIAL) as Material)

	var socket_local := _marker_local_or_metadata(
		hull_instance,
		"TurretSocket",
		wasp_metadata["sockets"]["TurretSocket"]["local_position"]
	)
	var pivot_local := _marker_local_or_metadata(
		turret_instance,
		"TurretPivot",
		smoky_metadata["markers"]["TurretPivot"]["local_position"]
	)
	var muzzle_local := _marker_local_or_metadata(
		turret_instance,
		"MuzzleSocket",
		smoky_metadata["markers"]["MuzzleSocket"]["local_position"]
	)

	turret_mount.position = socket_local - pivot_local
	_add_marker("TurretSocket", socket_local, Color.CYAN, 4.0)
	_add_marker("TurretPivot", turret_mount.position + pivot_local, Color.YELLOW, 4.0)
	_add_marker("MuzzleSocket", turret_mount.position + muzzle_local, Color.RED, 7.0)

	print("GODOT-M1A asset proof: assembled Wasp + Smoky using GLB marker nodes with sidecar metadata fallback.")

func _read_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("Missing or empty metadata: %s" % path)
		return {}
	var parsed := JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid metadata JSON: %s" % path)
		return {}
	return parsed

func _instantiate_scene(path: String, node_name: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Could not load GLB scene: %s" % path)
		return Node3D.new()
	var instance := packed.instantiate()
	instance.name = node_name
	return instance as Node3D

func _apply_material_recursive(node: Node, material: Material) -> void:
	if material == null:
		push_error("Missing material for %s" % node.name)
		return
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh:
			for surface_index in mesh_instance.mesh.get_surface_count():
				mesh_instance.set_surface_override_material(surface_index, material)
	for child in node.get_children():
		_apply_material_recursive(child, material)

func _vector_from_array(values: Array) -> Vector3:
	if values.size() < 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))

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
	marker_root.add_child(marker)
