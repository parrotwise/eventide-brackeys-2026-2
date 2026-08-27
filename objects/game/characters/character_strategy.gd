class_name StrategyComponent
extends Node

signal action_chosen(action: Action, user: Character, target: Character)

var character: Character
 
func take_turn() -> void:
	var action: Action = _choose_random_action()
	if action == null:
		action_chosen.emit(null, character, null)
		return

	var target: Character = _choose_random_target(action)
	if target == null:
		action_chosen.emit(null, character, null)
		return

	action_chosen.emit(action, character, target)

	
func _choose_random_action() -> Action:
	var available: Array[Action] = character.actions
	if available.is_empty():
		return null
	return available.pick_random()

func _choose_random_target(action: Action) -> Character:
	var valid_targets: Array[Character] = get_valid_targets(action)
	if valid_targets.is_empty():
		return null
	return valid_targets.pick_random()

func get_valid_targets(action: Action) -> Array[Character]:
	if action.healing > 0 and action.damage <= 0:
		return Game.level.enemies
	return Game.level.allies
