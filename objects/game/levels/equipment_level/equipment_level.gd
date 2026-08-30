extends Node


var selector: CombatSelector:
	get: return $Selector
var inventories: Dictionary:
	get: return Game.inventories
var character_lineup: HBoxContainer:
	get: return %CharacterLineup
var center_stage: Control:
	get: return %CenterStage

var selected_character: Character
var character_equipment: Array[Equipment] = []


func select_character(char: Character) -> void:
	selected_character = char
	
	# Remove character from visual lineup.
	for child: Character in character_lineup.get_children():
		if child == char:
			child.hide()
	
	# Place character on center stage.
	center_stage.get_children().clear()


func save_equipment_selection() -> void:
	if inventories.has(selected_character.name):
		inventories[selected_character.name] = character_equipment
	else:
		inventories.get_or_add(selected_character.name, character_equipment)


func _on_embark_button_pressed() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.cutscene_3)


func _on_character_selected(char: Character) -> void:
	var selected_ally: Character = char.duplicate()
	selected_ally.scale = 1.5 * Vector2.ONE
	for child in center_stage.get_children():
		child.queue_free()
	center_stage.add_child(selected_ally)
