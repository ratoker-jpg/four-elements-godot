extends CanvasLayer
class_name HudPlaceholder

# M2: minimal HUD. Displays raw/energy/units/selected + controls hint + debug text.
# Does NOT own game logic. Receives display data via update_state() / update_selected().

@onready var raw_label: Label = $Panel/VBox/RawValue
@onready var energy_label: Label = $Panel/VBox/EnergyValue
@onready var units_label: Label = $Panel/VBox/UnitsValue
@onready var selected_label: Label = $Panel/VBox/SelectedValue
@onready var debug_label: Label = $Panel/VBox/DebugText

func update_state(data: Dictionary) -> void:
	if raw_label:
		raw_label.text = str(data.get("raw", 0))
	if energy_label:
		energy_label.text = str(data.get("energy", 0))
	if units_label:
		units_label.text = str(data.get("units", 0))
	if debug_label:
		var map_size: String = data.get("map_size", "?")
		var hq_fp: String = data.get("hq_footprint", "?")
		var mineral_count: int = data.get("mineral_count", 0)
		var occupied: int = data.get("occupied_cells", 0)
		debug_label.text = "Map: %s\nHQ: %s\nMinerals: %d\nOccupied cells: %d" % [map_size, hq_fp, mineral_count, occupied]

func update_selected(label_text: String) -> void:
	if selected_label:
		selected_label.text = label_text
