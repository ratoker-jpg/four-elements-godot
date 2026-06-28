extends CanvasLayer
class_name HudPlaceholder

# M2: compact HUD. Displays raw/energy/units/selected + controls hint + debug text.
# Does NOT own game logic. Receives display data via update_state() / update_selected().

@onready var resources_label: Label = $Panel/Margin/VBox/ResourcesText
@onready var selected_label: Label = $Panel/Margin/VBox/SelectedText
@onready var debug_label: Label = $Panel/Margin/VBox/DebugText

func update_state(data: Dictionary) -> void:
	if resources_label:
		resources_label.text = "Raw: %s\nEnergy: %s\nUnits: %s" % [
			str(data.get("raw", 0)),
			str(data.get("energy", 0)),
			str(data.get("units", 0)),
		]
	if selected_label:
		selected_label.text = "Selected: %s" % str(data.get("selected", "<none>"))
	if debug_label:
		var map_size: String = data.get("map_size", "?")
		var mineral_count: int = data.get("mineral_count", 0)
		var occupied: int = data.get("occupied_cells", 0)
		debug_label.text = "Map: %s\nOccupied: %d\nMinerals: %d" % [map_size, occupied, mineral_count]

func update_selected(label_text: String) -> void:
	if selected_label:
		selected_label.text = "Selected: %s" % label_text
