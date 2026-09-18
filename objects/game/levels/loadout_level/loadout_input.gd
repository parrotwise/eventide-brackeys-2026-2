class_name LoadoutInput
extends Node


func _ready() -> void:
	Game.loadout_start.connect(_on_loadout_start)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'keyboard_reference'):
		Game.loadout.ui.show_keyboard_reference()
	if event.is_action_released(&'keyboard_reference'):
		Game.loadout.ui.hide_keyboard_reference()
	
	var menu: SettingsMenu = Game.loadout.ui.settings_menu
	
	if menu.visible:
		if menu.focused:
			if event.is_action_pressed(&'increase'):
				menu.slider_increasing = true
			
			if event.is_action_released(&'increase'):
				menu.slider_increasing = false
			
			if event.is_action_pressed(&'decrease'):
				menu.slider_decreasing = true
			
			if event.is_action_released(&'decrease'):
				menu.slider_decreasing = false
			
			if event.is_action_pressed(&'submit'):
				menu.submit_focused()
		
		if event.is_action_pressed(&'cycle_forward'):
			menu.cycle_through_focusables(Enums.Direction.DOWN)

		if event.is_action_pressed(&'cycle_backward'):
			menu.cycle_through_focusables(Enums.Direction.UP)

		if event.is_action_pressed(&'escape'):
			menu.visible = false

	else:
		if event.is_action_pressed(&'escape'):
			Game.loadout.ui.settings_menu.visible = true
				
		if event.is_action_pressed(&'cycle_forward'):
			Game.loadout.selector.cycle_through_characters(Enums.Direction.RIGHT)

		if event.is_action_pressed(&'cycle_backward'):
			Game.loadout.selector.cycle_through_characters(Enums.Direction.LEFT)


func _on_loadout_start() -> void:
	pass
