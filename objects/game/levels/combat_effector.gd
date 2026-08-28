class_name CombatEffector
extends Node


signal action_used(action: Action, user: Character, target: Character)
signal action_finished(action: Action, user: Character, target: Character)
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

	if action.target_damage > 0:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].damage += action.target_damage

	if action.splash_damage > 0:
		for adjacent: Character in Game.level.characters.get_adjacent_to(target):
			if adjacent not in effects:
				effects[adjacent] = _new_effect(user, action)
			
			effects[adjacent].damage += action.splash_damage

	if action.target_healing > 0:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].healing += action.target_healing

	if action.power_as_target_damage:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].damage += user.state_component.power

	if action.power_as_target_healing:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].healing += user.state_component.power

	if action.swap_places:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].swap_places = true

	if action.knockback:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].knockback = true

	if action.pull:
		if target not in effects:
			effects[target] = _new_effect(user, action)
		
		effects[target].pull = true
	
	for effect: Effect in effects.values():
		# Resource instance modified in-place
		Game.level.status_tracker_component.modify_effect(effect)

	return effects


func apply(action: Action, user: Character, target: Character) -> void:
	var effects: Dictionary[Character, Effect] = interpret(action, user, target)
	var enqueued: Array[Effect] = []
	
	for affected: Character in effects:
		var effect: Effect = effects[affected]
		effect.target = affected

		enqueued.append(effect)
		
		effect.applied.connect(effect_applied.emit.bind(effect, affected))
		effect.applied.connect(enqueued.erase.bind(effect))
		effect.apply()
	
	action_used.emit(action, user, target)
	
	while enqueued:
		await get_tree().create_timer(0.2).timeout
	
	action_finished.emit(action, user, target)


func _new_effect(user: Character, source: Variant) -> Effect:
	var effect := Effect.new()
	effect.owner = user
	effect.source = source
	return effect
