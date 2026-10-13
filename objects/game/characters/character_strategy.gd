class_name CharacterStrategy
extends Node


signal action_chosen(action: Action, user: Character, target: Character)

var character: Character

var _paused: bool = false


func pause() -> void:
	_paused = true


func take_turn(heuristic: bool = false) -> void:
	while _paused:
		await Game.combat.queue.await_time(1)
	
	var action: Action = null
	var target: Character = null
	
	if character.actions.basic_attack.can_be_used():
		action = character.actions.basic_attack

	for skill: Action in character.actions.skills:
		if not skill.can_be_used():
			continue
		
		if not action or not action.can_be_used():
			action = skill
			continue
		
		match skill.name:
			&'ACTION_CRUNCH_PEANUTS_NAME':
				if Random.randfloat() < 0.70: action = skill
			&'ACTION_SKILL_BC_NAME':
				if Random.randfloat() < 0.50: action = skill
			&'ACTION_SKILL_EC_NAME':
				if Random.randfloat() < 0.50: action = skill
			&'ACTION_SKILL_RC_NAME':
				if Random.randfloat() < 0.65: action = skill
			&'ACTION_SKILL_SC_NAME':
				if Random.randfloat() < 0.70: action = skill
			&'ACTION_SKILL_PC_NAME':
				if Random.randfloat() < 0.50: action = skill
			&'ACTION_SKILL_BHC_NAME':
				if Random.randfloat() < 0.50: action = skill
			&'ACTION_SKILL_GC_NAME':
				if Random.randfloat() < 0.30: action = skill
			&'ACTION_SKILL_NC_NAME':
				if Random.randfloat() < 0.75: action = skill
			_:
				if Random.randfloat() < 0.50: action = skill

	var is_big_cat: bool = character.actions.skills.any(func(s): return s.name == &'ACTION_SKILL_BC_NAME')
	var is_in_melee: bool = Game.combat.characters.is_in_melee(character)
	var can_reposition: bool = character.actions.reposition.can_be_used()
	
	if is_big_cat and not is_in_melee and can_reposition:
		action = character.actions.reposition
		target = Game.combat.characters.get_ahead_of(character)
	
	elif action:
		var valid_targets: Array[Character] = action.valid_targets()

		if heuristic:
			for valid_target: Character in valid_targets.duplicate():
				if valid_target.battle_group == character.battle_group and action.name in [
					&'ACTION_SKILL_PC_NAME',
					&'ACTION_SKILL_EC_NAME',
				]:
					valid_targets.erase(valid_target)
				
				if action.name == &'ACTION_SKILL_PC_NAME' and valid_target.state.missing_health_ratio:
					valid_targets.erase(valid_target)
				
				if action.name == &'ACTION_SKILL_GC_NAME':
					if valid_target.state.active_statuses.any(func(s): return s.name == &'OBJECT_SOOTGUT_NAME'):
						valid_targets.erase(valid_target)
					
					if valid_target.state.current_health > (
						Game.combat.characters.allies
						if valid_target.battle_group == Character.ALLIES_GROUP else
						Game.combat.characters.enemies
					).reduce(
						func(min_health, ch):
							return mini(min_health, ch.state.current_health),
						9999
					):
						valid_targets.erase(valid_target)

				var effects: Dictionary[Character, Effect] = Game.combat.effector.interpret(
					action, character, valid_target
				)

				for affected: Character in effects:
					var effect: Effect = effects[affected]
					
					if affected.battle_group == character.battle_group:
						if (
							effect.stacked_damage
							or effect.stacked_damage_explosive
							or effect.stacked_damage_poison
							or effect.applied_statuses.any(func(s): return s.name in [
								&'STATUS_IMMOBILIZED_NAME',
								&'STATUS_NASTY_CUTS_NAME',
								&'STATUS_POISONED_NAME',
								&'STATUS_STUNNED_NAME',
							])
						):
							valid_targets.erase(valid_target)
						
						if (
							(effect.stacked_healing or effect.stacked_healing_ratio)
							and affected.state.missing_health_ratio < 0.2
						):
							valid_targets.erase(valid_target)
					
					elif (
						(effect.stacked_healing or effect.stacked_healing_ratio)
						and not (
							(
								affected.state.missing_health_ratio < 0.2
								and effect.applied_statuses.any(func(s): return s.no_more_please)
							)
							or effect.applied_statuses.any(func(s): return s.name in [
								&'STATUS_IMMOBILIZED_NAME',
								&'STATUS_NASTY_CUTS_NAME',
								&'STATUS_POISONED_NAME',
								&'STATUS_STUNNED_NAME',
							])
						)
					):
						valid_targets.erase(valid_target)
		
		target = Random.randsample(valid_targets)
	
	if action == null:
		action_chosen.emit(null, character, null)
		return

	if target == null:
		if heuristic:
			take_turn(false)
			return
		
		else:
			action_chosen.emit(null, character, null)
			return

	action_chosen.emit(action, character, target)
	
	await Game.combat.queue.await_empty()

	if character == Game.combat.turn_tracker.current_character:
		await Game.combat.queue.await_action_delay()
		take_turn(heuristic)
