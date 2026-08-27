class_name CombatSelector
extends Node


signal action_selected(
	action: Action
)

signal ally_selected(
	ally: Character
)

signal target_selected(
	action: Action,
	user: Character,
	target: Character
)


var current_action: Action = null
var current_user: Character = null
var is_targeting: bool = false


func select_action(action: Action) -> void:
	if not is_instance_valid(action):
		return
	
	if current_action == action:
		return

	current_action = action
	is_targeting = true

	action_selected.emit(current_action)


func select_character(character: Character) -> void:
	if not is_instance_valid(character):
		return
	
	if is_targeting:
		select_target(character)
	else:
		select_ally(character)


func select_ally(ally: Character) -> void:
	if not is_instance_valid(ally):
		return
	
	if current_user == ally:
		return
	
	if ally.battle_group != ally.ALLIES_GROUP:
		return

	if ally in Game.level.turn_tracker_component.acted_allies:
		return
	
	cancel_action()

	current_user = ally

	ally_selected.emit(current_user)


func select_target(target: Character) -> void:
	if not is_targeting:
		return

	if current_action == null or current_user == null:
		return

	if target == null:
		return

	if not current_action.can_target(target):
		Debug.info(
			"%s is not a valid target." % target.name
		)
		return

	current_action.use(current_user, target)

	target_selected.emit(
		current_action,
		current_user,
		target
	)
	
	cancel_action()


func cancel_action() -> void:
	current_action = null
	is_targeting = false


func reset() -> void:
	cancel_action()
	current_user = null
