class_name CombatUI
extends CanvasLayer


var top_panel: PanelContainer:
	get: return $TopPanel
var bottom_panel: PanelContainer:
	get: return $BottomPanel
var action_buttons_grid: GridContainer:
	get: return $BottomPanel/ActionButtons
var action_buttons: Array[TextureButton]:
	get: return Array(
		action_buttons_grid.get_children(),
		TYPE_OBJECT, &'TextureButton', TextureButton
	)
var pause_menu: Control:
	get: return $PauseMenu


func set_action_buttons(character: Character) -> void:
	for button: TextureButton in action_buttons:
		button.queue_free()
	
	for action: Action in character.actions:
		var button := TextureButton.new()

		## TODO: Configure button
		# button.name = '%sButton' % [action.name]
		# button.texture_normal = action.icon

		action_buttons_grid.add_child(button)
