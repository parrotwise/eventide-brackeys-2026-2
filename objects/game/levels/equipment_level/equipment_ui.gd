class_name EquipmentUI
extends CanvasLayer


var character_lineup: HBoxContainer:
	get: return %CharacterLineup
var equipment_grid: GridContainer:
	get: return %EquipmentGrid
var center_stage: Control:
	get: return %CenterStage
var embark_button: TextureButton:
	get: return %EmbarkButton

var characters: Array[Character]:
	get: return Array(
		character_lineup.get_children().reduce(func(accum, node): return accum + node.get_children(), []),
		TYPE_OBJECT, &'Node2D', Character
	)
var equipment_buttons: Array[EquipmentButton]:
	get: return Array(
		equipment_grid.get_children(),
		TYPE_OBJECT, &'Control', EquipmentButton
	)

var selected_character: Character:
	get: return Game.equipment.selector.current_character


func _ready() -> void:
	Game.equipment_start.connect(_on_equipment_start)


func display_character(character: Character) -> void:
	# Create a clone to display.
	var selected_ally: Actor = character.actor.duplicate()
	selected_ally.scale = 1.3 * Vector2.ONE
	for child in center_stage.get_children():
		child.queue_free()
	center_stage.add_child(selected_ally)
	
	# Update the equipment grid per the selected character.
	refresh()


func refresh() -> void:
	var is_owned_by_selected: bool
	for button: EquipmentButton in equipment_buttons:
		# If the item is owned by the currently selected character, we can make sure it is enabled and pressed.
		is_owned_by_selected = Game.inventories.has(selected_character.name) and (button.equipment in Game.inventories[selected_character.name])
		if is_owned_by_selected:
			button.button.disabled = false
			button.button.button_pressed = true
			continue
		# If the item is not yet selected, then it is already enabled and may stay enabled.
		if !button.button.button_pressed:
			button.button.disabled = false
			continue
		# If the item is pressed by owned by someone else, disable it.
		button.button.disabled = true
	
	if Game.inventories.has(selected_character.name) and (Game.inventories[selected_character.name].size() >= 2):
		for button: EquipmentButton in equipment_buttons:
			is_owned_by_selected = button.equipment in Game.inventories[selected_character.name]
			if is_owned_by_selected:
				button.button.disabled = false
			else:
				button.button.disabled = true


func _on_equipment_start() -> void:
	embark_button.pressed.connect(Game.equipment.submit_allocation)
