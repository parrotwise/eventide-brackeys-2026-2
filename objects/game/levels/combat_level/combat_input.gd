class_name CombatInput
extends Node


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'right_click') or event.is_action_pressed(&'cancel'):
		Game.level.selector_component.cancel_action.call_deferred()
	
	if event.is_action_pressed(&'keyboard_reference'):
		Game.level.ui.show_keyboard_reference()
	if event.is_action_released(&'keyboard_reference'):
		Game.level.ui.hide_keyboard_reference()
	
	var menu: SettingsMenu = Game.level.ui.settings_menu
	
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
		var selected_ally: Character = Game.level.selector_component.current_user

		if is_instance_valid(selected_ally):
			var actions: Array[Action] = selected_ally.actions_component.actions
			
			for i: int in actions.size():
				if not is_instance_valid(actions[i]) or not actions[i].can_be_used():
					continue
				
				if event.is_action_pressed(&'select_action_%d' % [i + 1]):
					Game.level.selector_component.select_action(actions[i])
		
		var selected_action: Action = Game.level.selector_component.current_action
		var selected_target: Character = Game.level.selector_component.current_target
		
		if is_instance_valid(selected_action):
			if event.is_action_pressed(&'escape') or event.is_action_pressed(&'cancel'):
				Game.level.selector_component.cancel_action()
				Game.pointer.switch_to(Enums.PointerType.DEFAULT)
			
			if is_instance_valid(selected_target) and event.is_action_pressed(&'submit'):
				selected_target.input_component.submit_as_target()
		
		elif event.is_action_pressed(&'escape'):
			Game.level.ui.settings_menu.visible = true
				
		if event.is_action_pressed(&'cycle_forward'):
			Game.level.selector_component.cycle_through_characters(Enums.Direction.RIGHT)

		if event.is_action_pressed(&'cycle_backward'):
			Game.level.selector_component.cycle_through_characters(Enums.Direction.LEFT)


func _on_combat_start() -> void:
	pass
