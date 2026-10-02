class_name LoadoutLevel
extends Node


@export var bandage_uses: int = 2

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

	Game.loadout_end.connect(_on_loadout_end)
	
	ui.refresh()
	selector.character_selected.connect(func(_char): ui.refresh())

	Game.loadout_start.emit()


func submit_allocation() -> void:
	Game.loadout_end.emit()


func toggle_equipment(toggled_on: bool, equipment: Equipment) -> void:
	if not equipment:
		return
	if not selected_character:
		return
	
	if selected_character.id not in Game.inventories:
		Game.inventories[selected_character.id] = []
	
	if toggled_on and equipment not in Game.inventories[selected_character.id]:
		selected_character.state.active_statuses.append(equipment.equipped_status)
		Game.inventories[selected_character.id].append(equipment)
		Debug.debug(selected_character.id + " equipped " + equipment.name)
	
	elif not toggled_on and equipment in Game.inventories[selected_character.id]:
		selected_character.state.active_statuses.erase(equipment.equipped_status)
		Game.inventories[selected_character.id].erase(equipment)
		Debug.debug(selected_character.id + " unequipped " + equipment.name)
	
	ui.refresh()


func _on_loadout_end() -> void:
	if Game.stage == Game.Stage.LOADOUT1:
		TransitionLayer.transition_simple_fade(TransitionLayer.cutscene_3)
	else:
		TransitionLayer.transition_simple_fade(TransitionLayer.cutscene_second_mutiny)
