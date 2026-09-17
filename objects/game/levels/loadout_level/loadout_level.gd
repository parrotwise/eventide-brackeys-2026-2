class_name LoadoutLevel
extends Node


var selector: LoadoutSelector:
	get: return $Selector
var ui: LoadoutUI:
	get: return $UI
var characters: Array[Character]:
	get: return ui.characters
var equipment_buttons: Array[EquipmentButton]:
	get: return ui.equipment_buttons
var selected_character: Character:
	get: return selector.current_character


func _ready() -> void:
	Game.loadout = self
	
	selector.character_selected.connect(ui.display_character)

	for button: EquipmentButton in equipment_buttons:
		button.equipment_selected.connect(save_equipment_selection)
		button.button.disabled = true
	
	Game.equipment_start.emit()


func save_equipment_selection(equipment: Equipment, is_equipped: bool) -> void:
	if Game.inventories.has(selected_character.id):
		if is_equipped:
			Game.inventories[selected_character.id].append(equipment)
			Debug.debug(selected_character.id + " gained " + equipment.name)
		else:
			Game.inventories[selected_character.id].erase(equipment)
			Debug.debug(selected_character.id + " removed " + equipment.name)
	else:
		Game.inventories.get_or_add(selected_character.name, [equipment])
		Debug.debug(selected_character.id + " gained " + equipment.name)
	
	ui.refresh()


func submit_allocation() -> void:
	Game.equipment_end.emit()
	# TODO: Don't do ↓this↓ here, connect Game.equipment_end to it in transitions script
	TransitionLayer.transition_simple_fade(TransitionLayer.cutscene_3)
