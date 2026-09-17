class_name CombatInput
extends Node


func _ready() -> void:
	Game.combat_start.connect(_on_combat_start)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'right_click') or event.is_action_pressed(&'cancel'):
		Game.combat.selector.cancel_action.call_deferred()
	
	if event.is_action_pressed(&'keyboard_reference'):
		Game.combat.ui.show_keyboard_reference()
	if event.is_action_released(&'keyboard_reference'):
		Game.combat.ui.hide_keyboard_reference()
	
	var menu: SettingsMenu = Game.combat.ui.settings_menu
	
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
		var selected_ally: Character = Game.combat.selector.current_user

		if is_instance_valid(selected_ally):
			var actions: Array[Action] = selected_ally.actions.actions
			
			for i: int in actions.size():
				if not is_instance_valid(actions[i]) or not actions[i].can_be_used():
					continue
				
				if event.is_action_pressed(&'select_action_%d' % [i + 1]):
					Game.combat.selector.select_action(actions[i])

					for button: ActionButton in Game.combat.ui.action_buttons:
						if button.action == actions[i]:
							button.button.grab_focus()
				
				elif event.is_action_released(&'select_action_%d' % [i + 1]):
					for button: ActionButton in Game.combat.ui.action_buttons:
						if button.action == actions[i]:
							button.button.release_focus()
		
		var selected_action: Action = Game.combat.selector.current_action
		var selected_target: Character = Game.combat.selector.current_target
		
		if is_instance_valid(selected_action):
			if event.is_action_pressed(&'escape') or event.is_action_pressed(&'cancel'):
				Game.combat.selector.cancel_action()
				Game.pointer.switch_to(Enums.PointerType.DEFAULT)
			
			if is_instance_valid(selected_target) and event.is_action_pressed(&'submit'):
				selected_target.input.submit_as_target()
		
		elif event.is_action_pressed(&'escape'):
			Game.combat.ui.settings_menu.visible = true
				
		if event.is_action_pressed(&'cycle_forward'):
			Game.combat.selector.cycle_through_characters(Enums.Direction.RIGHT)

		if event.is_action_pressed(&'cycle_backward'):
			Game.combat.selector.cycle_through_characters(Enums.Direction.LEFT)


func _on_combat_start() -> void:
	pass
