class_name CombatStatusTracker
extends Node



signal status_applied(status: Status)
signal status_removed(status: Status)
signal trigger_fired(trigger: Trigger)
signal effect_modified(effect: Effect, status: Status)

## All active status effects in combat_level
var _active_statuses: Array[Status] = []
var active_statuses: Array[Status]:
	get: return _active_statuses

var cached: Dictionary[String, Variant] = {
	'last_action': null,
	'last_attacker': null,
	'last_reposition_ahead': null,
	'last_reposition_behind': null,
}


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func track(status: Status) -> void:
	if status == null:
		return
	
	if status in _active_statuses:
		return
	
	_active_statuses.append(status)

	status.refresh_granted_statuses()

	status.effect_modified.connect(
		func (effect: Effect):
			effect_modified.emit(effect, status)
			fire_triggers(Enums.TriggerType.SOURCE_MODIFIED_EFFECT, status.owner, status)
	)

	for trigger: Trigger in status.triggers:
		trigger.fired.connect(trigger_fired.emit.bind(trigger))

	status_applied.emit(status)


func untrack(status: Status) -> void:
	if status == null:
		return
	
	_active_statuses.erase(status)

	status_removed.emit(status)


func acquire_target(target_type: Enums.TargetType, owner_ref: Character) -> Character:
	match target_type:
		Enums.TargetType.CHARACTER_AHEAD:
			return Game.combat.characters.get_ahead_of(owner_ref)
		Enums.TargetType.LAST_ATTACKER:
			return cached['last_attacker']
		Enums.TargetType.LAST_REPOSITION_SELF:
			return (
				cached['last_reposition_ahead']
				if cached['last_reposition_ahead'] == owner_ref
				else cached['last_reposition_behind']
			)
		Enums.TargetType.LAST_REPOSITION_OTHER:
			return (
				cached['last_reposition_ahead']
				if cached['last_reposition_behind'] == owner_ref
				else cached['last_reposition_behind']
			)
	
	return null


func fire_triggers(trigger_type: Enums.TriggerType, specific_owner: Character = null, specific_status: Status = null) -> void:
	for status: Status in active_statuses:
		if specific_status not in [null, status]:
			continue
		if specific_owner not in [null, status.owner]:
			continue

		for trigger: Trigger in status.triggers:
			if trigger_type != trigger.trigger_type:
				continue
			
			await trigger.fire(acquire_target(trigger.target_type, specific_owner))


func modify_effect(effect: Effect) -> Effect:
	for status: Status in active_statuses:
		# Resource instance modified in-place
		status.modify_effect(effect)
	
	return effect


func _on_combat_start() -> void:
	# /***************\
	# ) CACHE TARGETS (
	# \***************/

	Game.combat.effector.action_submitted.connect(
		func (action: Action, user: Character, _target: Character):
			cached['last_action'] = action
			cached['last_attacker'] = user
	)

	Game.combat.characters.characters_repositioned.connect(
		func (char_ahead: Character, char_behind: Character):
			cached['last_reposition_ahead'] = char_ahead
			cached['last_reposition_behind'] = char_behind
	)

	# /*****************\
	# ) TRIGGER EFFECTS (
	# \*****************/

	for character: Character in Game.combat.characters.all:
		character.state.damage_taken.connect(
			fire_triggers.bind(Enums.TriggerType.DAMAGE_TAKEN, character)
		)
	
	for character: Character in Game.combat.characters.all:
		character.state.explosive_damage_taken.connect(
			fire_triggers.bind(Enums.TriggerType.EXPLOSIVE_DAMAGE_TAKEN, character)
		)
	
	for character: Character in Game.combat.characters.all:
		character.state.healing_received.connect(
			fire_triggers.bind(Enums.TriggerType.HEALING_RECEIVED, character)
		)
	
	Game.combat.characters.characters_repositioned.connect(
		func (char_ahead: Character, char_behind: Character):
			fire_triggers(Enums.TriggerType.REPOSITIONED, char_ahead)
			fire_triggers(Enums.TriggerType.REPOSITIONED, char_behind)
	)
	
	Game.combat.effector.action_submitted.connect(
		func (action: Action, user: Character, _target: Character):
			fire_triggers(Enums.TriggerType.USING_ACTION, user)

			if action == user.actions.basic_attack:
				fire_triggers(Enums.TriggerType.USING_BASIC_ATTACK, user)

			elif action == user.actions.reposition:
				fire_triggers(Enums.TriggerType.USING_REPOSITION, user)

			elif action == user.actions.skills[0]:
				fire_triggers(Enums.TriggerType.USING_CHARACTER_SKILL, user)
	)
	
	Game.combat.effector.action_finished.connect(
		func (action: Action):
			fire_triggers(Enums.TriggerType.FINISHED_ACTION, action.owner)

			if action == action.owner.actions.basic_attack:
				fire_triggers(Enums.TriggerType.FINISHED_BASIC_ATTACK, action.owner)

			elif action == action.owner.actions.reposition:
				fire_triggers(Enums.TriggerType.FINISHED_REPOSITION, action.owner)

			elif action == action.owner.actions.skills[0]:
				fire_triggers(Enums.TriggerType.FINISHED_CHARACTER_SKILL, action.owner)
	)
	
	Game.combat.turn_tracker.turn_started.connect(
		func (character: Character):
			if character in Game.combat.characters.enemies:
				fire_triggers(Enums.TriggerType.START_TURN, character)
	)

	Game.combat.turn_tracker.round_started.connect(
		func (_round_number: int):
			for character in Game.combat.characters.allies:
				fire_triggers(Enums.TriggerType.START_TURN, character)
	)

	Game.combat.turn_tracker.turn_lost.connect(
		func (character: Character):
			if character in Game.combat.characters.all:
				fire_triggers(Enums.TriggerType.LOSE_TURN, character)
	)

	Game.combat.turn_tracker.turn_ended.connect(
		func (character: Character):
			if character in Game.combat.characters.all:
				fire_triggers(Enums.TriggerType.END_TURN, character)
	)
	
	Game.combat.turn_tracker.battle_group_started.connect(
		func (battle_group: StringName):
			if battle_group == Game.combat.turn_tracker.ALLIES_GROUP:
				for character in Game.combat.characters.enemies:
					fire_triggers(Enums.TriggerType.END_PHASE, character)
				for character in Game.combat.characters.allies:
					fire_triggers(Enums.TriggerType.START_PHASE, character)
			
			elif battle_group == Game.combat.turn_tracker.ENEMIES_GROUP:
				for character in Game.combat.characters.allies:
					fire_triggers(Enums.TriggerType.END_PHASE, character)
				for character in Game.combat.characters.enemies:
					fire_triggers(Enums.TriggerType.START_PHASE, character)
	)

	# /****************\
	# ) REFRESH STATES (
	# \****************/

	Game.combat.characters.characters_repositioned.connect(
		func (char_ahead: Character, char_behind: Character):
			if is_instance_valid(char_ahead):
				for status: Status in char_ahead.state.active_statuses:
					status.refresh_granted_statuses.call_deferred()

			if is_instance_valid(char_behind):
				for status: Status in char_behind.state.active_statuses:
					status.refresh_granted_statuses.call_deferred()
	)
