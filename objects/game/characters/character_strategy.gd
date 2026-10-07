class_name CharacterStrategy
extends Node


signal action_chosen(action: Action, user: Character, target: Character)

var character: Character

var _paused: bool = false


func pause() -> void:
	_paused = true


func take_turn() -> void:
	while _paused:
		await Game.combat.queue.await_time(1)
	
	var action: Action = null
	
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
	
	var target: Character = Random.randsample(action.valid_targets()) if action else null

	var is_big_cat: bool = character.actions.skills.any(func(s): return s.name == &'ACTION_SKILL_BC_NAME')
	var is_in_melee: bool = Game.combat.characters.is_in_melee(character)
	var can_reposition: bool = character.actions.reposition.can_be_used()

	if is_big_cat and not is_in_melee and can_reposition:
		action = character.actions.reposition
		target = Game.combat.characters.get_ahead_of(character)
	
	if action == null:
		action_chosen.emit(null, character, null)
		return

	if target == null:
		action_chosen.emit(null, character, null)
		return

	action_chosen.emit(action, character, target)
	
	await Game.combat.queue.await_empty()

	if character == Game.combat.turn_tracker.current_character:
		await Game.combat.queue.await_action_delay()
		take_turn()
