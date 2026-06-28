extends Node3D
class_name PlaceholderEntity

# PLACEHOLDER_ASSET: replace with final asset when available.
# Shared base for M2 placeholder visuals (HQ, minerals, infinite mineral).
# Stores the entity data dictionary from StartStateLoader for debug/inspection.

@export var debug_label_text := ""
var entity_data: Dictionary = {}

func set_entity_data(data: Dictionary) -> void:
	entity_data = data
	debug_label_text = data.get("entity_id", "")
