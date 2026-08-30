extends Node


var selector: CombatSelector:
	get: return $Selector
var inventories: Dictionary:
	get: return Game.inventories
var character_lineup: HBoxContainer:
	get: return %CharacterLineup
var equipment_grid: GridContainer:
	get: return %EquipmentGrid
var center_stage: Control:
	get: return %CenterStage

var selected_character: Character
var character_equipment: Array[Equipment] = []

var test: Array
func _ready() -> void:
	for item: EquipmentButton in equipment_grid.get_children():
		item.equipment_selected.connect(save_equipment_selection)
		item.disabled = true


func save_equipment_selection(equipment: Equipment, is_equipped: bool) -> void:
	if inventories.has(selected_character.name):
		if is_equipped:
			inventories[selected_character.name].append(equipment)
			Debug.info(selected_character.name + " gained " + equipment.name)
			check_equipment_grid()
		else:
			inventories[selected_character.name].erase(equipment)
			Debug.info(selected_character.name + " removed " + equipment.name)
	else:
		inventories.get_or_add(selected_character.name, character_equipment)
		Debug.info(selected_character.name + " gained " + equipment.name)


func check_equipment_grid() -> void:
	var is_owned_by_selected: bool
	for item: EquipmentButton in equipment_grid.get_children():
		# If the item is not yet selected, then it is already enabled and may stay enabled.
		if !item.button.button_pressed:
			item.disabled = false
			continue
		# If the item is owned by the currently selected character, we can make sure it is enabled.
		is_owned_by_selected = inventories.has(selected_character.name) and (item.equipment in inventories[selected_character.name])
		if is_owned_by_selected:
			item.disabled = false
			continue
		# If the item is pressed by owned by someone else, disable it.
		item.disabled = true
	
	if inventories.has(selected_character.name) and (inventories[selected_character.name].size() >= 2):
		for item: EquipmentButton in equipment_grid.get_children():
			is_owned_by_selected = item.equipment in inventories[selected_character.name]
			if is_owned_by_selected:
				item.disabled = false
			else:
				item.disabled = true


func _on_embark_button_pressed() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.cutscene_3)


func _on_character_selected(char: Character) -> void:
	selected_character = char
	var selected_ally: Character = char.duplicate()
	selected_ally.scale = 1.3 * Vector2.ONE
	for child in center_stage.get_children():
		child.queue_free()
	center_stage.add_child(selected_ally)
	# Update the equipment grid per the selected character.
	check_equipment_grid()
