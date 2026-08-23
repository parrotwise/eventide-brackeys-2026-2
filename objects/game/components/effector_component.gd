class_name EffectorComponent
extends Node


signal action_effect_applied(
	action: Action,
	user: Character,
	target: Character
)


func apply_action_effects(
	action: Action,
	user: Character,
	target: Character
) -> void:
	if action == null:
		return

	if user == null or target == null:
		return

	_apply_action(action, target)

	action_effect_applied.emit(action, user, target)


func _apply_action(action: Action, target: Character) -> void:
	if action.damage > 0:
		target.health_component.take_damage(action.damage)

	if action.healing > 0:
		target.health_component.heal(action.healing)
