class_name CombatEffector
extends Node


signal action_used(action: Action, user: Character, target: Character)
signal effect_applied(effect: Effect, affected: Character)


func interpret(
	action: Action,
	user: Character,
	target: Character
) -> Dictionary[Character, Effect]:
	
	var effects: Dictionary[Character, Effect] = {}

	if action == null:
		return effects

	if user == null or target == null:
		return effects

	if action.damage > 0:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].damage = action.damage

	if action.healing > 0:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].healing = action.healing
	
	for effect: Effect in effects.values():
		# Resource instance modified in-place
		Game.level.status_tracker_component.modify_effect(effect)

	return effects


func apply(action: Action, user: Character, target: Character) -> void:
	var effects: Dictionary[Character, Effect] = interpret(action, user, target)
	
	for affected: Character in effects:
		var effect: Effect = effects[affected]
		effect.target = affected
		
		effect.applied.connect(effect_applied.emit.bind(effect, affected))
		effect.apply()

	action_used.emit(action, user, target)


func _new_effect(user: Character, source: Variant) -> Effect:
	var effect := Effect.new()
	effect.owner = user
	effect.source = source
	return effect
