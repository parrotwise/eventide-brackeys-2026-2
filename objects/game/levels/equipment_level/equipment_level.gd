class_name EquipmentLevel
extends Node


var selector: EquipmentSelector:
	get: return $Selector
var inventories: Dictionary:
	get: return Game.inventories
var character_lineup: HBoxContainer:
	get: return %CharacterLineup
var characters: Array[Character]:
	get: return Array(
		character_lineup.get_children().reduce(func(accum, node): return accum + node.get_children(), []),
		TYPE_OBJECT, &'Node2D', Character
	)
var equipment_grid: GridContainer:
	get: return %EquipmentGrid
var center_stage: Control:
	get: return %CenterStage

var selected_character: Character


func _ready() -> void:
	Game.equipment = self

	for item: EquipmentButton in equipment_grid.get_children():
		item.equipment_selected.connect(save_equipment_selection)
		item.button.disabled = true
	
	for character: Character in characters:
		character.input.submitted.connect(_on_character_selected)


func save_equipment_selection(equipment: Equipment, is_equipped: bool) -> void:
	if inventories.has(selected_character.id):
		if is_equipped:
			inventories[selected_character.id].append(equipment)
			Debug.info(selected_character.id + " gained " + equipment.name)
		else:
			inventories[selected_character.id].erase(equipment)
			Debug.info(selected_character.id + " removed " + equipment.name)
	else:
		inventories.get_or_add(selected_character.name, [equipment])
		Debug.info(selected_character.id + " gained " + equipment.name)
	Debug.debug(str(Game.inventories), Debug.Verbosity.CALLER)
	check_equipment_grid()


func check_equipment_grid() -> void:
	var is_owned_by_selected: bool
	for item: EquipmentButton in equipment_grid.get_children():
		# If the item is owned by the currently selected character, we can make sure it is enabled and pressed.
		is_owned_by_selected = inventories.has(selected_character.name) and (item.equipment in inventories[selected_character.name])
		if is_owned_by_selected:
			item.button.disabled = false
			item.button.button_pressed = true
			continue
		# If the item is not yet selected, then it is already enabled and may stay enabled.
		if !item.button.button_pressed:
			item.button.disabled = false
			continue
		# If the item is pressed by owned by someone else, disable it.
		item.button.disabled = true
	
	if inventories.has(selected_character.name) and (inventories[selected_character.name].size() >= 2):
		for item: EquipmentButton in equipment_grid.get_children():
			is_owned_by_selected = item.equipment in inventories[selected_character.name]
			if is_owned_by_selected:
				item.button.disabled = false
			else:
				item.button.disabled = true


func _on_embark_button_pressed() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.cutscene_3)


func _on_character_selected(character: Character) -> void:
	selected_character = character
	
	# Create a clone to display.
	var selected_ally: Actor = character.actor.duplicate()
	selected_ally.scale = 1.3 * Vector2.ONE
	for child in center_stage.get_children():
		child.queue_free()
	center_stage.add_child(selected_ally)
	
	# Update the equipment grid per the selected character.
	check_equipment_grid()
