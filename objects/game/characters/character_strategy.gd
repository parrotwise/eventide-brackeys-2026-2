class_name CharacterStrategy
extends Node


signal action_chosen(action: Action, user: Character, target: Character)

var character: Character
 

func take_turn() -> void:
	var action: Action = null
	
	if character.actions_component.basic_attack.uses_left:
		action = character.actions_component.basic_attack

	for skill: Action in character.actions_component.skills:
		if not skill.uses_left:
			continue
		
		match skill.name:
			&'Pick Up & Cronch':
				if Random.randfloat() < 0.70: action = skill
			&'Jaw Cruncher':
				if Random.randfloat() < 0.50: action = skill
			&'Powder Satchel':
				if Random.randfloat() < 0.50: action = skill
			&'Mug Toss':
				if Random.randfloat() < 0.65: action = skill
			&'Two for One':
				if Random.randfloat() < 0.70: action = skill
			&'Peanut Scatter':
				if Random.randfloat() < 0.50: action = skill
			&'Keelhaul Tug':
				if Random.randfloat() < 0.50: action = skill
			&'Roll the Pot':
				if Random.randfloat() < 0.30: action = skill
			&'Laser-Focused':
				if Random.randfloat() < 0.75: action = skill
			_:
				if Random.randfloat() < 0.50: action = skill
	
	var target: Character = Random.randsample(action.valid_targets()) if action else null

	var is_big_cat: bool = character.actions_component.skills.any(func(s): return s.name == &'Jaw Cruncher')
	var is_in_melee: bool = Game.level.characters.is_in_melee(character)
	var can_reposition: bool = character.actions_component.reposition.uses_left

	if is_big_cat and not is_in_melee and can_reposition:
		action = character.actions_component.reposition
		target = Game.level.characters.get_ahead_of(character)
	
	if action == null:
		action_chosen.emit(null, character, null)
		return

	if target == null:
		action_chosen.emit(null, character, null)
		return

	action_chosen.emit(action, character, target)
	
	await Game.level.queue.await_empty()

	if character == Game.level.turn_tracker_component.current_character:
		take_turn()
