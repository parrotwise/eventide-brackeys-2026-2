class_name CombatSelector
extends Node


signal action_selected(
	action: Action
)

signal action_cancelled()

signal ally_selected(
	ally: Character
)

signal target_selected(
	action: Action,
	user: Character,
	target: Character
)

signal target_cancelled(
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
var _responsive: bool = true


func _ready() -> void:
	Game.start.connect(reset)


func select_action(action: Action, player_input: bool = true) -> void:
	if player_input and not _responsive:
		return
	
	if not is_instance_valid(action):
		return
	
	if current_action == action:
		return

	current_action = action
	is_targeting = true

	action_selected.emit(current_action)


func select_character(character: Character, player_input: bool = true) -> void:
	if player_input and not _responsive:
		return
	
	if not is_instance_valid(character):
		return
	
	if is_targeting:
		select_target(character)
	else:
		select_ally(character)


func select_ally(ally: Character, player_input: bool = true) -> void:
	if player_input and not _responsive:
		return
	
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


func select_target(target: Character, player_input: bool = true) -> void:
	if player_input and not _responsive:
		return
	
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
		Game.pointer.switch_to(Enums.PointerType.DISABLED)
		return

	current_target = target

	target_selected.emit(
		current_action,
		current_user,
		current_target
	)


func submit_target(player_input: bool = true) -> void:
	if player_input and not _responsive:
		return
	
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
	
	if Game.pointer.type in [
		Enums.PointerType.TARGET, 
		Enums.PointerType.ATTACK, 
		Enums.PointerType.SLOP, 
		Enums.PointerType.SWAP
	]:
		Game.pointer.switch_to(Enums.PointerType.DEFAULT)
	
	current_action.use(current_user, current_target)


func cycle_through_characters(direction := Enums.Direction.RIGHT, player_input: bool = true) -> void:
	if is_targeting:
		cycle_through_targets(direction, player_input)
	else:
		cycle_through_allies(direction, player_input)


func cycle_through_allies(direction := Enums.Direction.RIGHT, player_input: bool = true) -> void:
	var free_allies: Array[Character] = Game.level.characters.free_allies

	if not free_allies:
		return
	
	if not current_user:
		select_ally(free_allies[0], player_input)
	
	else:
		var index: int = free_allies.find(current_user)

		if direction == Enums.Direction.RIGHT:
			index = (index - 1) % free_allies.size()
		elif direction == Enums.Direction.LEFT:
			index = (index + 1) % free_allies.size()
		
		select_ally(free_allies[index], player_input)


func cycle_through_targets(direction := Enums.Direction.RIGHT, player_input: bool = true) -> void:
	if not current_action:
		return
	
	var valid_targets: Array[Character] = current_action.valid_targets()
	valid_targets.sort_custom(
		func (c1: Character, c2: Character) -> bool:
			var i1: int = Game.level.characters.index_of(c1)
			var i2: int = Game.level.characters.index_of(c2)
			var s1: int = 100 + i1 if c1 in Game.level.characters.enemies else -i1
			var s2: int = 100 + i2 if c2 in Game.level.characters.enemies else -i2
			return s1 < s2
	)

	if not current_target:
		select_target(valid_targets[0], player_input)
	
	else:
		var index: int = valid_targets.find(current_target)

		if direction == Enums.Direction.RIGHT:
			index = (index + 1) % valid_targets.size()
		elif direction == Enums.Direction.LEFT:
			index = (index - 1) % valid_targets.size()
		
		select_target(valid_targets[index], player_input)


func deselect_character(character: Character, player_input: bool = true) -> void:
	if player_input and not _responsive:
		return
	
	if not is_instance_valid(character):
		return
	
	if is_targeting and character == current_target:
		cancel_target()


func cancel_target() -> void:
	target_cancelled.emit(
		current_action,
		current_user,
		current_target
	)

	current_target = null


func cancel_action() -> void:
	cancel_target()

	current_action = null
	is_targeting = false

	action_cancelled.emit()


func reset() -> void:
	cancel_action()
	current_user = null
	cycle_through_allies(Enums.Direction.RIGHT, false)


func pause() -> void:
	_responsive = false


func resume() -> void:
	_responsive = true
