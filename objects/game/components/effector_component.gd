class_name EffectorComponent
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
			effects[target] = Effect.new()
		
		effects[target].damage = action.damage

	if action.healing > 0:
		if target not in effects:
			effects[target] = Effect.new()
		
		effects[target].healing = action.healing

	return effects


func apply(action: Action, user: Character, target: Character) -> void:
	var effects: Dictionary[Character, Effect] = interpret(action, user, target)

	for affected: Character in effects:
		var effect: Effect = effects[affected]
		
		effect.applied.connect(effect_applied.emit.bind(effect, affected))
		effect.apply()

	action_used.emit(action, user, target)
