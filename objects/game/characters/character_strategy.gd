class_name CharacterStrategy
extends Node


signal action_chosen(action: Action, user: Character, target: Character)

var character: Character
 

func take_turn() -> void:
	var action: Action = Random.randsample(
		character.actions_component.skills + Array(
			[character.actions_component.basic_attack],
			TYPE_OBJECT, &'Resource', Action
		)
	)
	if action == null:
		action_chosen.emit(null, character, null)
		return

	var target: Character = Random.randsample(action.valid_targets())
	if target == null:
		action_chosen.emit(null, character, null)
		return

	action_chosen.emit(action, character, target)
