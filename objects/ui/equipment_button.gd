class_name EquipmentButton
extends Control


@export var equipment: Equipment

var button: TextureButton:
	get: return $ButtonBG/TextureButton
var icon: TextureRect:
	get: return $ButtonBG/TextureButton/MarginContainer/Icon

var tooltip_header: String:
	get: return equipment.name if equipment else ''
var tooltip_description: String:
	get: return equipment.description if equipment else ''


func _ready() -> void:
	setup(equipment)


func setup(new_equipment: Equipment) -> void:
	if not new_equipment:
		hide()
		return
	
	equipment = new_equipment

	for connection: Dictionary in button.toggled.get_connections():
		button.toggled.disconnect(connection['callable'])
	
	button.toggled.connect(Game.loadout.toggle_equipment.bind(equipment))
	
	icon.texture = equipment.icon

	show()
