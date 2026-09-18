class_name LoadoutUI
extends CanvasLayer


@export var equipment_button_template: PackedScene

var character_lineup: HBoxContainer:
	get: return %CharacterLineup
var equipment_grid: GridContainer:
	get: return %EquipmentGrid
var center_stage: Control:
	get: return %CenterStage
var embark_button: TextureButton:
	get: return %EmbarkButton
var keyboard_reference: Panel:
	get: return $KeyboardReference
var settings_menu: SettingsMenu:
	get: return $SettingsMenu
var open_settings_button: ActionButton:
	get: return %OpenSettingsButton

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
	get: return Game.loadout.selector.current_character


func _ready() -> void:
	## TODO: Replace with the commented-out callable after Wwise migration
	open_settings_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# open_settings_button.pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	open_settings_button.pressed.connect(open_settings)
	open_settings_button.button.disabled = false

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


func show_keyboard_reference() -> void:
	keyboard_reference.show()


func hide_keyboard_reference() -> void:
	keyboard_reference.hide()


func open_settings() -> void:
	settings_menu.show()


func _on_equipment_start() -> void:
	for button: EquipmentButton in equipment_buttons:
		equipment_grid.remove_child(button)
		button.queue_free()
	
	for equipment: Equipment in Game.available_equipment:
		var button := equipment_button_template.instantiate() as EquipmentButton
		equipment_grid.add_child(button)
		button.setup(equipment)
	
	refresh()

	embark_button.pressed.connect(Game.loadout.submit_allocation)
