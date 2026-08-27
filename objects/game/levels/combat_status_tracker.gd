class_name CombatStatusTracker
extends Node


## All active status effects in combat_level
var _active_statuses: Array[Status] = []
var active_statuses: Array[Status]:
	get: return _active_statuses

var cached_targets: Dictionary[String, Character] = {
	'last_attacker': null
}


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func _on_combat_start() -> void:
	# Cache targets first
	for character: Character in Game.level.characters.all:
		# Can't bind callables here due to 'key' in dict / 'method' in dict ambiguity
		character.action_used.connect(func(): cached_targets['last_attacker'] = character)

	# Trigger effects after
	for character: Character in Game.level.characters.all:
		character.state_component.damage_taken.connect(
			fire_triggers.bind(Enums.TriggerType.DAMAGE_TAKEN, character)
		)


func track(status: Status) -> void:
	if status == null:
		return
	
	if status in _active_statuses:
		return
	
	_active_statuses.append(status)


func untrack(status: Status) -> void:
	if status == null:
		return
	
	_active_statuses.erase(status)


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
				Enums.TargetType.NEAREST_ENEMY: # Auto-detected
					trigger.fire()
				Enums.TargetType.LAST_ATTACKER:
					trigger.fire(cached_targets['last_attacker'])


func modify_effect(effect: Effect) -> Effect:
	for status: Status in active_statuses:
		# Resource instance modified in-place
		status.modify_effect(effect)
	
	return effect
