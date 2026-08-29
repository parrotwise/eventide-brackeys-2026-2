class_name CombatStatusTracker
extends Node



signal status_applied(status: Status)
signal status_removed(status: Status)
signal trigger_fired(trigger: Trigger)

## All active status effects in combat_level
var _active_statuses: Array[Status] = []
var active_statuses: Array[Status]:
	get: return _active_statuses

var cached: Dictionary[String, Variant] = {
	'last_action': null,
	'last_attacker': null,
}


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func track(status: Status) -> void:
	if status == null:
		return
	
	if status in _active_statuses:
		return
	
	_active_statuses.append(status)

	status_applied.emit(status)


func untrack(status: Status) -> void:
	if status == null:
		return
	
	_active_statuses.erase(status)

	status_removed.emit(status)


func fire_triggers(trigger_type: Enums.TriggerType, specific_owner: Character = null) -> void:
	for status: Status in active_statuses:
		if specific_owner not in [null, status.owner]:
			continue
		
		for trigger: Trigger in status.triggers:
			if trigger_type != trigger.trigger_type:
				continue
			
			match trigger.target_type:
				Enums.TargetType.SELF: # Auto-detected
					trigger.fire()
					trigger_fired.emit(trigger)
				Enums.TargetType.NEAREST_ENEMY: # Auto-detected
					trigger.fire()
					trigger_fired.emit(trigger)
				Enums.TargetType.CHARACTER_AHEAD:
					trigger.fire(Game.level.characters.get_ahead_of(status.owner))
					trigger_fired.emit(trigger)
				Enums.TargetType.LAST_ATTACKER:
					trigger.fire(cached['last_attacker'])
					trigger_fired.emit(trigger)


func modify_effect(effect: Effect) -> Effect:
	for status: Status in active_statuses:
		# Resource instance modified in-place
		status.modify_effect(effect)
	
	return effect


func _on_combat_start() -> void:
	# Cache targets first
	Game.level.effector_component.action_submitted.connect(_on_action_submitted)

	# Trigger effects after
	for character: Character in Game.level.characters.all:
		character.state_component.damage_taken.connect(
			fire_triggers.bind(Enums.TriggerType.DAMAGE_TAKEN, character)
		)
	
	Game.level.effector_component.action_submitted.connect(
		func (_action: Action, user: Character, _target: Character):
			fire_triggers(Enums.TriggerType.USING_ACTION, user)
	)

	Game.level.turn_tracker_component.turn_started.connect(
		func (character: Character):
			if character in Game.level.characters.enemies:
				fire_triggers(Enums.TriggerType.START_TURN, character)
	)

	Game.level.turn_tracker_component.round_started.connect(
		func(_round_number):
			for character in Game.level.characters.allies:
				fire_triggers(Enums.TriggerType.START_TURN, character)
	)


func _on_action_submitted(action: Action, user: Character, _target: Character) -> void:
	cached['last_action'] = action
	cached['last_attacker'] = user
