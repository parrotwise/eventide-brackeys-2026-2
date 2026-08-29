class_name CombatEffector
extends Node


signal action_submitted(action: Action, user: Character, target: Character)
signal action_missed(action: Action, user: Character, target: Character)
signal action_used(action: Action, user: Character, target: Character)
signal action_finished(action: Action, user: Character, target: Character)
signal effect_applied(effect: Effect, affected: Character)


var missed_actions: Array[Action] = []


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
			effects[target] = _new_effect(action, user, target)
		
		effects[target].damage += action.target_damage

	if action.splash_damage > 0:
		for adjacent: Character in Game.level.characters.get_adjacent_to(target):
			if adjacent not in effects:
				effects[adjacent] = _new_effect(action, user, adjacent)
			
			effects[adjacent].damage += action.splash_damage

	if action.target_healing > 0:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].healing += action.target_healing

	if action.power_as_target_damage:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].damage += user.state_component.power

	if action.power_as_target_healing:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].healing += user.state_component.power

	if action.swap_places:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].swap_places = true

	if action.knockback_once:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].knockback_once = true

	if action.knockback_to_rear:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].knockback_to_rear = true

	if action.pull_once:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].pull_once = true

	if action.pull_to_front:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].pull_to_front = true

	if action.cause_miss_action:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].cause_miss_action = true

	if action.remove_source_status:
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].remove_source_status = true
	
	if action.applied_statuses.size() > 0:                      # <-- new block
		if target not in effects:
			effects[target] = _new_effect(action, user, target)
		
		effects[target].applied_statuses.append_array(action.applied_statuses)
	
	if action.repeat_on_random_target:
		var repeat: Action = action.duplicate()
		repeat.owner = action.owner
		repeat.repeat_on_random_target = false

		var random_target: Character = Random.randsample(repeat.valid_targets())
		var repeat_effects: Dictionary[Character, Effect] = interpret(repeat, user, random_target)

		for repeat_affected: Character in repeat_effects:
			var repeat_effect: Effect = repeat_effects[repeat_affected]

			if repeat_affected not in effects:
				effects[repeat_affected] = repeat_effect
			else:
				effects[repeat_affected].merge_with(repeat_effect)
	
	for effect: Effect in effects.values():
		# Resource instance modified in-place
		Game.level.status_tracker_component.modify_effect(effect)

	return effects


func apply(action: Action, user: Character, target: Character) -> void:
	var effects: Dictionary[Character, Effect] = interpret(action, user, target)
	var enqueued: Array[Effect] = []
	
	action_submitted.emit(action, user, target)

	if action in missed_actions:
		action_missed.emit(action, user, target)
		missed_actions.erase(action)

	else:
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


func _new_effect(source: Variant, user: Character, target: Character) -> Effect:
	var effect := Effect.new()
	effect.source = source
	effect.owner = user
	effect.target = target
	return effect
