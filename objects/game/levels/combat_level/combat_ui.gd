class_name CombatUI
extends CanvasLayer


var top_panel: PanelContainer:
	get: return $TopPanel
var bottom_panel: PanelContainer:
	get: return $BottomPanel
var passive_icon: TextureRect:
	get: return $BottomPanel/BottomPanel/PassiveBG/PassiveIcon
var equipment_buttons_grid: HFlowContainer:
	get: return $BottomPanel/BottomPanel/EquipmentButtons
var action_buttons: Array[ActionButton]:
	get: return Array(
		$BottomPanel/MarginContainer/ButtonGroups/ActionButtons.get_children(),
		TYPE_OBJECT, &'Control', ActionButton
	)
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
	open_settings_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	open_settings_button.pressed.connect(open_settings)
	close_settings_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	close_settings_button.pressed.connect(close_settings)


func set_action_buttons(character: Character) -> void:
	for button: ActionButton in action_buttons:
		button.hide()
	
	if character.actions.size() > 4:
		Debug.error("Character '%s' has too many actions (more than 4)." % character.name, Debug.Verbosity.CALLER)
	
	for action_index: int in character.actions.size():
		var action: Action = character.actions[action_index]
		var button: ActionButton = action_buttons[action_index]
		
		button.setup(action)
		button.show()


func reset_action_panel() -> void:
	for button: ActionButton in action_buttons:
		button.hide()


func show_keyboard_reference() -> void:
	keyboard_reference.show()


func hide_keyboard_reference() -> void:
	keyboard_reference.hide()


func close_settings() -> void:
	settings_menu.hide()


func open_settings() -> void:
	settings_menu.show()
