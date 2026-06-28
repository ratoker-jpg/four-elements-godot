extends Node3D
class_name GameRoot

# M2: orchestrates the RTS start scene. Owns MapGrid, OccupancyGrid, StartStateLoader.
# Spawns visual placeholders for HQ, minerals, infinite mineral, and starting Tank3D.
# Wires existing M1 camera, selection, and move-command controllers.
#
# The user runs this scene directly with Run Current Scene (F6).

@export var map_size_cells: Vector2i = Vector2i(64, 64)
@export var cell_size_world: float = 64.0
@export var show_debug_visualization := true
@export var debug_grid_step_cells := 8
@export var tank_visual_scale := 0.12

@onready var systems: Node = $Systems
@onready var camera_rig: Node3D = $RTSCameraRig
@onready var selection_controller: Node = $Systems/SelectionController3D
@onready var map_root: Node3D = $MapRoot
@onready var ground_root: Node3D = $MapRoot/Ground
@onready var resources_root: Node3D = $MapRoot/Resources
@onready var buildings_root: Node3D = $MapRoot/Buildings
@onready var units_root: Node3D = $MapRoot/Units
@onready var markers_root: Node3D = $MapRoot/Markers
@onready var debug_root: Node3D = $MapRoot/Debug
@onready var hud: CanvasLayer = $HUD

var map_grid: MapGrid
var occupancy: OccupancyGrid
var start_state: StartStateLoader

# Scene references for visual placeholders.
const HQ_PLACEHOLDER_SCENE := preload("res://scenes/placeholders/HQPlaceholder3x3.tscn")
const MINERAL_PLACEHOLDER_SCENE := preload("res://scenes/placeholders/MineralPlaceholder1x1.tscn")
const INFINITE_MINERAL_PLACEHOLDER_SCENE := preload("res://scenes/placeholders/InfiniteMineralPlaceholder2x2.tscn")
const TANK_SCENE := preload("res://scenes/units/Tank3D.tscn")

func _ready() -> void:
	start_state = StartStateLoader.new()
	start_state.map_size_cells = map_size_cells
	start_state.cell_size_world = cell_size_world
	start_state.build()
	map_grid = start_state.map_grid
	occupancy = start_state.occupancy

	_build_ground()
	_spawn_entities()
	_build_debug_visualization()
	_focus_camera_on_start_area()
	_wire_hud()

func _build_ground() -> void:
	# Simple ground plane sized to the map.
	var world_size := map_grid.map_world_size()
	var mesh := PlaneMesh.new()
	mesh.size = world_size
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.20, 0.17, 1.0)
	material.roughness = 0.9
	var ground := MeshInstance3D.new()
	ground.name = "GroundPlane"
	ground.mesh = mesh
	ground.material_override = material
	# Center the plane on the map.
	ground.global_position = Vector3(world_size.x * 0.5, 0.0, world_size.y * 0.5)
	ground_root.add_child(ground)

	# Static body for raycast picking.
	var body := StaticBody3D.new()
	body.name = "GroundBody"
	var shape := BoxShape3D.new()
	shape.size = Vector3(world_size.x, 1.0, world_size.y)
	var col := CollisionShape3D.new()
	col.shape = shape
	col.global_position = Vector3(world_size.x * 0.5, -0.5, world_size.y * 0.5)
	body.add_child(col)
	ground_root.add_child(body)

func _spawn_entities() -> void:
	for entity in start_state.entities:
		var kind: String = entity.get("kind", "")
		var world_pos: Vector3 = entity.get("world_position", Vector3.ZERO)
		match kind:
			"hq":
				_spawn_placeholder(HQ_PLACEHOLDER_SCENE, entity, world_pos)
			"mineral":
				_spawn_placeholder(MINERAL_PLACEHOLDER_SCENE, entity, world_pos)
			"infinite_mineral":
				_spawn_placeholder(INFINITE_MINERAL_PLACEHOLDER_SCENE, entity, world_pos)
			"tank":
				_spawn_tank(entity, world_pos)

func _spawn_placeholder(scene: PackedScene, entity: Dictionary, world_pos: Vector3) -> void:
	var node := scene.instantiate() as Node3D
	if node == null:
		push_error("GameRoot: could not instantiate placeholder scene")
		return
	node.global_position = world_pos
	if node.has_method("set_entity_data"):
		node.set_entity_data(entity)
	var kind: String = entity.get("kind", "")
	match kind:
		"hq":
			buildings_root.add_child(node)
		"mineral", "infinite_mineral":
			resources_root.add_child(node)
		_:
			map_root.add_child(node)

func _spawn_tank(entity: Dictionary, world_pos: Vector3) -> void:
	var tank := TANK_SCENE.instantiate() as Node3D
	if tank == null:
		push_error("GameRoot: could not instantiate Tank3D")
		return
	tank.global_position = world_pos
	# M2 keeps the M1 tank scene intact, but scales this instance so it reads as
	# a mobile unit beside 64-unit RTS cells instead of as a building.
	tank.scale = Vector3.ONE * tank_visual_scale
	tank.set("show_debug_markers", false)
	tank.set("show_debug_move_target", false)
	# Scale M1 movement values for the larger M2 world.
	tank.set("move_speed", 240.0)
	tank.set("stop_distance", 16.0)
	tank.set("arrival_slowdown_distance", 120.0)
	tank.set("min_move_distance", 8.0)
	units_root.add_child(tank)

func _build_debug_visualization() -> void:
	debug_root.visible = show_debug_visualization
	if not show_debug_visualization:
		return

	var world_size := map_grid.map_world_size()
	# Map bounds outline.
	_add_rect_debug(Vector3(0, 0.1, 0), Vector3(world_size.x, 0.1, 0), Vector3(world_size.x, 0.1, world_size.y), Vector3(0, 0.1, world_size.y), Color(1, 0.9, 0.25, 0.45))

	# Sampled grid lines. Every 8 cells keeps orientation without overwhelming play.
	var grid_step: int = maxi(debug_grid_step_cells, 1)
	for i in range(0, map_size_cells.x + 1, grid_step):
		var x := float(i) * cell_size_world
		_add_line_debug(Vector3(x, 0.08, 0), Vector3(x, 0.08, world_size.y), Color(0.65, 0.78, 0.68, 0.16))
	for j in range(0, map_size_cells.y + 1, grid_step):
		var z := float(j) * cell_size_world
		_add_line_debug(Vector3(0, 0.08, z), Vector3(world_size.x, 0.08, z), Color(0.65, 0.78, 0.68, 0.16))

	# Footprint outlines for each occupied entity.
	for entity in start_state.entities:
		var footprint: Vector2i = entity.get("footprint", Vector2i.ZERO)
		if footprint.x <= 0 or footprint.y <= 0:
			continue
		var anchor: Vector2i = entity.get("anchor_cell", Vector2i.ZERO)
		var min_world := Vector3(float(anchor.x) * cell_size_world, 0.15, float(anchor.y) * cell_size_world)
		var max_world := Vector3(float(anchor.x + footprint.x) * cell_size_world, 0.15, float(anchor.y + footprint.y) * cell_size_world)
		var color := Color(0.25, 0.95, 0.45, 0.55)
		match entity.get("kind", ""):
			"hq":
				color = Color(0.25, 0.65, 1.0, 0.65)
			"infinite_mineral":
				color = Color(1.0, 0.82, 0.25, 0.65)
		_add_rect_debug(min_world, Vector3(max_world.x, 0.15, min_world.z), max_world, Vector3(min_world.x, 0.15, max_world.z), color)

	# Occupied-cell dots are intentionally tiny so they read as data, not scenery.
	for cell_key in occupancy.get_all_occupied_cells():
		var cell: Vector2i = cell_key
		var center := map_grid.grid_to_world(cell)
		_add_dot_debug(center + Vector3(0, 0.2, 0), Color(1, 0.25, 0.2, 0.35))

func _add_line_debug(a: Vector3, b: Vector3, color: Color) -> void:
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(a)
	mesh.surface_add_vertex(b)
	mesh.surface_end()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = false
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	debug_root.add_child(mi)

func _add_rect_debug(a: Vector3, b: Vector3, c: Vector3, d: Vector3, color: Color) -> void:
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(a)
	mesh.surface_add_vertex(b)
	mesh.surface_add_vertex(b)
	mesh.surface_add_vertex(c)
	mesh.surface_add_vertex(c)
	mesh.surface_add_vertex(d)
	mesh.surface_add_vertex(d)
	mesh.surface_add_vertex(a)
	mesh.surface_end()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = false
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	debug_root.add_child(mi)

func _add_dot_debug(pos: Vector3, color: Color) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 2.2
	mesh.height = 4.4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.4
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = false
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.global_position = pos
	debug_root.add_child(mi)

func _focus_camera_on_start_area() -> void:
	if camera_rig == null:
		return

	var focus_points: Array[Vector3] = []
	for entity in start_state.entities:
		var kind: String = entity.get("kind", "")
		if kind == "hq" or kind == "tank" or kind == "mineral":
			focus_points.append(entity.get("world_position", Vector3.ZERO))
	if focus_points.is_empty():
		return

	var focus := Vector3.ZERO
	for point in focus_points:
		focus += point
	focus /= float(focus_points.size())
	camera_rig.global_position = Vector3(focus.x, 0.0, focus.z)
	camera_rig.set("zoom", 620.0)
	camera_rig.set("yaw", 0.15)
	if camera_rig.has_method("_update_camera_transform"):
		camera_rig.call("_update_camera_transform")

func _wire_hud() -> void:
	if hud == null or not hud.has_method("update_state"):
		return
	hud.update_state({
		"map_size": str(map_size_cells.x) + "x" + str(map_size_cells.y),
		"hq_footprint": "3x3",
		"mineral_count": start_state.get_entities_of_kind("mineral").size(),
		"occupied_cells": occupancy.occupied_cell_count(),
		"raw": 0,
		"energy": 0,
		"units": start_state.get_entities_of_kind("tank").size(),
		"selected": "<none>",
	})
	if selection_controller != null and selection_controller.has_signal("selection_changed"):
		var callback := Callable(self, "on_selection_changed")
		if not selection_controller.is_connected("selection_changed", callback):
			selection_controller.connect("selection_changed", callback)

# Called by SelectionController3D via signal wiring (if added in a future milestone).
func on_selection_changed(selected_node: Node) -> void:
	if hud == null or not hud.has_method("update_selected"):
		return
	if selected_node == null:
		hud.update_selected("<none>")
	else:
		hud.update_selected(selected_node.name)
