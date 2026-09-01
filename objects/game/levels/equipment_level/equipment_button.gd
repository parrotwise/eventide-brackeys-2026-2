class_name EquipmentButton
extends Control


signal equipment_selected(equipment: Equipment, is_equipped: bool)

@export var equipment: Equipment

var button: TextureButton:
	get: return $ButtonBG/TextureButton

var eq_icon: TextureRect:
	get: return $ButtonBG/TextureButton/MarginContainer/Icon

var tooltip: Tooltip:
	get: return $Tooltip


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check if the button has an equipment assigned. If not, hide self.
	if !equipment:
		hide()
		return
	
	eq_icon.texture = equipment.icon
	
	tooltip.header = equipment.name
	tooltip.description = equipment.description


func _on_texture_button_toggled(toggled_on: bool) -> void:
	equipment_selected.emit(equipment, toggled_on)
