class_name CombatUI
extends CanvasLayer


var top_panel: PanelContainer:
	get: return $TopPanel
var bottom_panel: PanelContainer:
	get: return $BottomPanel
var action_buttons_grid: HFlowContainer:
	get: return $BottomPanel/BottomPanel/ActionButtons
var passive_icon: TextureRect:
	get: return $BottomPanel/BottomPanel/PassiveBG/PassiveIcon
var equipment_buttons_grid: HFlowContainer:
	get: return $BottomPanel/BottomPanel/EquipmentButtons
var action_buttons: Array[TextureButton]:
	get: return Array(
		action_buttons_grid.get_children(),
		TYPE_OBJECT, &'TextureButton', TextureButton
	)
var pause_menu: Control:
	get: return $PauseMenu


func set_action_buttons(character: Character) -> void:
	for button: TextureButton in action_buttons:
		button.hide()
	
	if character.actions.size() > 4:
		Debug.error("Character '%s' has too many actions (more than 4)." % character.name, Debug.Verbosity.CALLER)
	
	for action_index: int in character.actions.size():
		var button: TextureButton = action_buttons[action_index]
		var action_icon: TextureRect = button.get_child(0)
		
		button.show()
		
		if action_icon:
			action_icon.texture = character.actions[action_index].icon
		
		var action_tooltip: String = character.actions[action_index].name + "\n" + character.actions[action_index].description
		button.tooltip_text = action_tooltip
