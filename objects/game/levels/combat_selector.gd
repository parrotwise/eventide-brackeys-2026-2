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

signal target_submitted(
	action: Action,
	user: Character,
	target: Character
)


var current_action: Action = null
var current_target: Character = null
var current_user: Character = null
var is_targeting: bool = false


func _ready() -> void:
	Game.start.connect(reset)


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

	current_target = target

	target_selected.emit(
		current_action,
		current_user,
		current_target
	)


func submit_target() -> void:
	if current_action == null or current_user == null or current_target == null:
		return

	if not current_action.can_target(current_target):
		Debug.info(
			"%s is not a valid target." % current_target.name
		)
		return

	target_submitted.emit(
		current_action,
		current_user,
		current_target
	)
	
	current_action.use(current_user, current_target)
	
	cycle_through_allies()


func cycle_through_characters(direction := Enums.Direction.RIGHT) -> void:
	if is_targeting:
		cycle_through_targets(direction)
	else:
		cycle_through_allies(direction)


func cycle_through_allies(direction := Enums.Direction.RIGHT) -> void:
	var free_allies: Array[Character] = Game.level.characters.free_allies

	if not free_allies:
		return
	
	if not current_user:
		select_ally(free_allies[0])
	
	else:
		var index: int = free_allies.find(current_user)

		if direction == Enums.Direction.RIGHT:
			index = (index + 1) % free_allies.size()
		elif direction == Enums.Direction.LEFT:
			index = (index - 1) % free_allies.size()
		
		select_ally(free_allies[index])


func cycle_through_targets(direction := Enums.Direction.RIGHT) -> void:
	if not current_action:
		return
	
	var valid_targets: Array[Character] = current_action.valid_targets()

	if not current_target:
		select_target(valid_targets[0])
	
	else:
		var index: int = valid_targets.find(current_user)

		if direction == Enums.Direction.RIGHT:
			index = (index + 1) % valid_targets.size()
		elif direction == Enums.Direction.LEFT:
			index = (index - 1) % valid_targets.size()
		
		select_target(valid_targets[index])


func cancel_action() -> void:
	current_target = null
	current_action = null
	is_targeting = false


func reset() -> void:
	cancel_action()
	current_user = null
	cycle_through_allies()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'cycle_characters_right'):
		cycle_through_characters(Enums.Direction.RIGHT)
	if event.is_action_pressed(&'cycle_characters_left'):
		cycle_through_characters(Enums.Direction.LEFT)
