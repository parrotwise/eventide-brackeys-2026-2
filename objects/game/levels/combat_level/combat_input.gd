class_name CombatInput
extends Node


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'right_click'):
		Game.level.selector_component.cancel_action.call_deferred()
	
	if event.is_action_pressed(&'keyboard_reference'):
		Game.level.ui.show_keyboard_reference()
	if event.is_action_released(&'keyboard_reference'):
		Game.level.ui.hide_keyboard_reference()
	
	var selected_ally: Character = Game.level.selector_component.current_user

	if is_instance_valid(selected_ally):
		var basic_attack: Action = selected_ally.actions_component.basic_attack
		var reposition: Action = selected_ally.actions_component.reposition
		var skills: Array[Action] = selected_ally.actions_component.skills
		
		if event.is_action_pressed(&'select_action_1'):
			if is_instance_valid(basic_attack) and basic_attack.can_be_used():
				Game.level.selector_component.select_action(basic_attack)
		
		if event.is_action_pressed(&'select_action_2'):
			if is_instance_valid(reposition) and reposition.can_be_used():
				Game.level.selector_component.select_action(reposition)
		
		for i: int in skills.size():
			var skill: Action = skills[i]

			if event.is_action_pressed(&'select_action_%d' % [i + 3]):
				if is_instance_valid(skill) and skill.can_be_used():
					Game.level.selector_component.select_action(skill)
	
	if Game.level.selector_component.current_action:
		if event.is_action_pressed(&'escape') or event.is_action_pressed(&'cancel'):
			Game.level.selector_component.cancel_action()
			Game.pointer.switch_to(Enums.PointerType.DEFAULT)
	
	elif event.is_action_pressed(&'escape'):
		Game.level.ui.settings_menu.visible = not Game.level.ui.settings_menu.visible


func _on_combat_start() -> void:
	pass
