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
		$BottomPanel/ButtonGroups/ActionButtons.get_children(),
		TYPE_OBJECT, &'Control', ActionButton
	)
var pause_menu: Control:
	get: return $PauseMenu


func set_action_buttons(character: Character) -> void:
	for button: ActionButton in action_buttons:
		button.hide()
	
	if character.actions.size() > 4:
		Debug.error("Character '%s' has too many actions (more than 4)." % character.name, Debug.Verbosity.CALLER)
	
	for action_index: int in character.actions.size():
		var action: Action = character.actions[action_index]
		var button: ActionButton = action_buttons[action_index]
		
		button.show()
		button.icon_texture = character.actions[action_index].icon
		
		var action_tooltip: String = character.actions[action_index].name + "\n" + character.actions[action_index].description
		button.button.tooltip_text = action_tooltip

		for connection: Dictionary in button.pressed.get_connections():
			button.pressed.disconnect(connection['callable'])
		
		button.pressed.connect(Game.level.selector_component.select_action.bind(action))
