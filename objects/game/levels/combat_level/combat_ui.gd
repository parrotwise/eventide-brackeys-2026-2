class_name CombatUI
extends CanvasLayer


var top_panel: PanelContainer:
	get: return $TopPanel
var bottom_panel: PanelContainer:
	get: return $BottomPanel
var action_buttons: Array[ActionButton]:
	get: return Array(
		$BottomPanel/MarginContainer/ButtonGroups/ActionButtons.get_children(),
		TYPE_OBJECT, &'Control', ActionButton
	)
var equipment_buttons: Array[CombatEquipmentButton]:
	get: return Array(
		$BottomPanel/MarginContainer/ButtonGroups/EquipmentButtons.get_children(),
		TYPE_OBJECT, &'Control', CombatEquipmentButton
	)
var passive_button: PassiveButton:
	get: return $BottomPanel/MarginContainer/ButtonGroups/PassiveButton
var keyboard_reference: Panel:
	get: return $KeyboardReference
var pause_menu: Control:
	get: return $PauseMenu
var settings_menu: Control:
	get: return $SettingsMenu
var open_settings_button: ActionButton:
	get: return %OpenSettingsButton
var close_settings_button: ActionButton:
	get: return $SettingsMenu/%CloseSettingsButton


func _ready() -> void:
	## TODO: Replace with the commented-out callable after Wwise migration
	open_settings_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# open_settings_button.pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	open_settings_button.pressed.connect(open_settings)
	
	## TODO: Replace with the commented-out callable after Wwise migration
	close_settings_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# close_settings_button.pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	close_settings_button.pressed.connect(close_settings)


func setup_bottom_bar(character: Character) -> void:
	reset_bottom_bar()
	
	if character.actions.size() > 4:
		Debug.error("Character '%s' has too many actions, only 4 will be shown." % character.name)
	if character.equipment.size() > 4:
		Debug.error("Character '%s' has too many items, only 4 will be shown." % character.name)
	
	for i: int in mini(4, character.actions.size()):
		var action: Action = character.actions[i]
		action_buttons[i].setup(action)
		action_buttons[i].show()
	
	for i: int in mini(4, character.equipment.size()):
		var equipment: Equipment = character.equipment[i]
		equipment_buttons[i].setup(equipment)
		equipment_buttons[i].show()
	
	passive_button.setup(character.state_component.passive_status)


func reset_bottom_bar() -> void:
	for button: ActionButton in action_buttons:
		button.hide()
	for button: CombatEquipmentButton in equipment_buttons:
		button.hide()


func show_keyboard_reference() -> void:
	keyboard_reference.show()


func hide_keyboard_reference() -> void:
	keyboard_reference.hide()


func close_settings() -> void:
	settings_menu.hide()


func open_settings() -> void:
	settings_menu.show()
