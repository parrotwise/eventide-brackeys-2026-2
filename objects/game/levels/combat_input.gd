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


func _on_combat_start() -> void:
	pass
