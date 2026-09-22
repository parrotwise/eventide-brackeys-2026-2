class_name LoadoutLevel
extends Node


var selector: LoadoutSelector:
	get: return $Selector
var ui: LoadoutUI:
	get: return $UI
var characters: Array[Character]:
	get: return ui.characters
var selected_character: Character:
	get: return selector.current_character


func _ready() -> void:
	Game.loadout = self
	
	selector.character_selected.connect(func(_char): ui.refresh())
	
	Game.loadout_start.emit()


func submit_allocation() -> void:
	Game.loadout_end.emit()
	# TODO: Don't do ↓this↓ here, connect Game.equipment_end to it in transitions script
	TransitionLayer.transition_simple_fade(TransitionLayer.cutscene_3)


func toggle_equipment(toggled_on: bool, equipment: Equipment) -> void:
	if not equipment:
		return
	if not selected_character:
		return
	
	if selected_character.id not in Game.inventories:
		Game.inventories[selected_character.id] = []
	
	if toggled_on:
		Game.inventories[selected_character.id].append(equipment)
		Debug.debug(selected_character.id + " equipped " + equipment.name)
	else:
		Game.inventories[selected_character.id].erase(equipment)
		Debug.debug(selected_character.id + " unequipped " + equipment.name)
	
	ui.refresh()
