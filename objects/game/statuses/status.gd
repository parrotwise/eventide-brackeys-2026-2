class_name Status
extends Resource


signal applied(character: Character)
signal removed(character: Character)

@export_group("Identifiers")
## A name to be exposed to the player.
@export var name: String
## A description to be exposed to the player.
@export_multiline() var description: String
## An icon to be exposed to the player.
@export var icon: Texture
@export var passive_icon_normal: Texture
@export var passive_icon_hover: Texture
@export var vfx: PackedScene

@export_group("Effect")
## Likelihood of the following effects being applied. Odds apply all at once, not to each effect.
@export_range(0, 1, 0.01) var likelihood: float = 1
@export_range(0, 1, 0.01) var condition_owner_health_ratio_min: float = 0

@export_subgroup("Adders")

@export var _damage_dealt_adder: int = 0
var damage_dealt_adder: int:
	get: return _damage_dealt_adder * stack

@export var _damage_taken_adder: int = 0
var damage_taken_adder: int:
	get: return _damage_taken_adder * stack

@export var _healing_applied_adder: int = 0
var healing_applied_adder: int:
	get: return _healing_applied_adder * stack

@export var _healing_received_adder: int = 0
var healing_received_adder: int:
	get: return _healing_received_adder * stack

@export var _max_health_adder: int = 0
var max_health_adder: int:
	get: return _max_health_adder * stack

@export var _power_adder: int = 0
var power_adder: int:
	get: return _power_adder * stack

@export_subgroup("Multipliers")

@export var _damage_dealt_multiplier: float = 1.0
var damage_dealt_multiplier: float:
	get: return 1.0 + (_damage_dealt_multiplier - 1.0) * stack

@export var _missing_hp_to_dmg_dealt_mult: float = 0.0
var missing_hp_to_dmg_dealt_mult: float:
	get: return _missing_hp_to_dmg_dealt_mult * stack

@export var _damage_dealt_to_splash_both_sides_mult: float = 0.0
var damage_dealt_to_splash_both_sides_mult: float:
	get: return _damage_dealt_to_splash_both_sides_mult * stack

@export var _damage_dealt_to_splash_one_side_mult: float = 0.0
var damage_dealt_to_splash_one_side_mult: float:
	get: return _damage_dealt_to_splash_one_side_mult * stack

@export var _damage_taken_to_splash_both_sides_mult: float = 0.0
var damage_taken_to_splash_both_sides_mult: float:
	get: return _damage_taken_to_splash_both_sides_mult * stack

@export var _damage_taken_to_splash_one_side_mult: float = 0.0
var damage_taken_to_splash_one_side_mult: float:
	get: return _damage_taken_to_splash_one_side_mult * stack

@export var _damage_taken_multiplier: float = 1.0 
var damage_taken_multiplier: float:
	get: return 1.0 + (_damage_taken_multiplier - 1.0) * stack

@export var _healing_applied_multiplier: float = 1.0
var healing_applied_multiplier: float:
	get: return 1.0 + (_healing_applied_multiplier - 1.0) * stack

@export var _healing_received_multiplier: float = 1.0
var healing_received_multiplier: float:
	get: return 1.0 + (_healing_received_multiplier - 1.0) * stack

@export var _max_health_multiplier: float = 1.0
var max_health_multiplier: float:
	get: return 1.0 + (_max_health_multiplier - 1.0) * stack

@export var _power_multiplier: float = 1.0
var power_multiplier: float:
	get: return 1.0 + (_power_multiplier - 1.0) * stack

@export_subgroup("Flags")
@export var can_attack_twice: bool = false
@export var can_be_healed: bool = true
@export var can_be_moved: bool = true
@export var no_more_please: bool = false
@export var max_health_one: bool = false

@export_group("Grants")
@export var granted_actions: Array[Action] = []
@export var grant_ahead: Status = null
@export var grant_adjacent: Status = null

@export_group("Triggers")
@export var triggers: Array[Trigger] = []
@export var trigger_uses: int = -1
@export var remove_when_triggers_used_up: bool = true
@export var attacks_apply_statuses: Array[Status] = []
@export var base_healing_applied_applies_statuses: Array[Status] = []
@export var base_healing_received_applies_statuses: Array[Status] = []
@export var healing_applied_applies_statuses: Array[Status] = []
@export var healing_received_applies_statuses: Array[Status] = []
@export var base_damage_dealt_applies_statuses: Array[Status] = []
@export var base_damage_taken_applies_statuses: Array[Status] = []
@export var damage_dealt_applies_statuses: Array[Status] = []
@export var damage_taken_applies_statuses: Array[Status] = []

@export_group("")
@export var stacking_type: Enums.StackingType

var granted_statuses: Array[Status] = []
var stack: int = 1

var owner: Character


func apply_to(character: Character) -> void:
	owner = character
	
	for i: int in granted_actions.size():
		granted_actions[i] = granted_actions[i].duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		granted_actions[i].owner = character

	for i: int in triggers.size():
		triggers[i] = triggers[i].duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	for trigger: Trigger in triggers:
		trigger.effect = trigger.effect.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		trigger.effect.owner = character
		trigger.effect.source = self

	applied.emit(owner)
	
	Game.level.status_tracker_component.track(self)

	for trigger: Trigger in triggers:
		if trigger.trigger_type == Enums.TriggerType.SOURCE_APPLIED:
			await trigger.fire()


func remove() -> void:
	for trigger: Trigger in triggers:
		if trigger.trigger_type == Enums.TriggerType.SOURCE_REMOVED:
			await trigger.fire()
	
	Game.level.status_tracker_component.untrack(self)

	removed.emit(owner)

	owner = null


func remove_trigger(trigger: Trigger) -> void:
	triggers.erase(trigger)


func modify_effect(effect: Effect) -> Effect:
	if not is_instance_valid(owner) or not is_instance_valid(effect.owner):
		return
	
	if randf() > likelihood:
		return
	
	if owner.state_component.current_health_ratio < condition_owner_health_ratio_min:
		return
	
	if effect.source.name == &'Sling Slop' and no_more_please:
		effect.cause_lose_turn = true
	
	var final_damage_dealt_multiplier = damage_dealt_multiplier + missing_hp_to_dmg_dealt_mult * owner.state_component.missing_health_ratio
	
	if owner == effect.owner:
		var base_damage_dealt: bool = (effect.damage or effect.damage_explosive) and is_instance_valid(effect.target)
		var base_healing_applied: bool = (effect.healing) and is_instance_valid(effect.target)

		effect.damage = floori(effect.damage * final_damage_dealt_multiplier)
		effect.damage += damage_dealt_adder
		effect.damage_explosive = floori(effect.damage_explosive * final_damage_dealt_multiplier)
		effect.healing = floori(effect.healing * healing_applied_multiplier)
		effect.healing += healing_applied_adder

		var damage_dealt: bool = (effect.damage or effect.damage_explosive) and is_instance_valid(effect.target)
		var healing_applied: bool = (effect.healing) and is_instance_valid(effect.target)

		if base_damage_dealt:
			for status: Status in base_damage_dealt_applies_statuses:
				effect.applied_statuses.append(status)
		
		if base_healing_applied:
			for status: Status in base_healing_applied_applies_statuses:
				effect.applied_statuses.append(status)

		if damage_dealt:
			for status: Status in damage_dealt_applies_statuses:
				effect.applied_statuses.append(status)
			
			for adjacent: Character in Game.level.characters.get_adjacent_to(effect.target):
				var splash_effect: Effect = Effect.create(self, effect.owner, adjacent)

				splash_effect.damage = roundi(effect.damage * damage_dealt_to_splash_both_sides_mult)
				splash_effect.damage_explosive = roundi(effect.damage_explosive * damage_dealt_to_splash_both_sides_mult)

				effect.extra_effects.append(splash_effect)
			
			for adjacent: Character in Random.shuffle(Game.level.characters.get_adjacent_to(effect.target)):
				var splash_effect: Effect = Effect.create(self, effect.owner, adjacent)

				splash_effect.damage = roundi(effect.damage * damage_dealt_to_splash_one_side_mult)
				splash_effect.damage_explosive = roundi(effect.damage_explosive * damage_dealt_to_splash_one_side_mult)

				effect.extra_effects.append(splash_effect)
				break
		
		if healing_applied:
			for status: Status in healing_applied_applies_statuses:
				effect.applied_statuses.append(status)
		
		if effect.source == owner.actions_component.basic_attack:
			for status: Status in attacks_apply_statuses:
				effect.applied_statuses.append(status)
	
	if owner == effect.target:
		var base_damage_taken: bool = (effect.damage or effect.damage_explosive) and is_instance_valid(effect.target)
		var base_healing_received: bool = (effect.healing) and is_instance_valid(effect.target)
		
		effect.damage = floori(effect.damage * damage_taken_multiplier)
		effect.damage += damage_taken_adder
		effect.damage_explosive = floori(effect.damage_explosive * damage_taken_multiplier)
		effect.healing = floori(effect.healing * healing_received_multiplier)
		effect.healing += healing_received_adder

		var damage_taken: bool = (effect.damage or effect.damage_explosive) and is_instance_valid(effect.target)
		var healing_received: bool = (effect.healing) and is_instance_valid(effect.target)

		if base_damage_taken:
			for status: Status in base_damage_taken_applies_statuses:
				effect.applied_statuses.append(status)
			
		if base_healing_received:
			for status: Status in base_healing_received_applies_statuses:
				effect.applied_statuses.append(status)
			
		if damage_taken:
			for status: Status in damage_taken_applies_statuses:
				effect.applied_statuses.append(status)
			
			for adjacent: Character in Game.level.characters.get_adjacent_to(effect.target):
				var splash_effect: Effect = Effect.create(self, effect.owner, adjacent)
				
				splash_effect.damage = ceili(effect.damage * damage_taken_to_splash_both_sides_mult)
				splash_effect.damage_explosive = ceili(effect.damage_explosive * damage_taken_to_splash_both_sides_mult)
				
				effect.extra_effects.append(splash_effect)
			
			for adjacent: Character in Random.shuffle(Game.level.characters.get_adjacent_to(effect.target)):
				var splash_effect: Effect = Effect.create(self, effect.owner, adjacent)
				
				splash_effect.damage = ceili(effect.damage * damage_taken_to_splash_one_side_mult)
				splash_effect.damage_explosive = ceili(effect.damage_explosive * damage_taken_to_splash_one_side_mult)
				
				effect.extra_effects.append(splash_effect)
				break
			
		if healing_received:
			for status: Status in healing_received_applies_statuses:
				effect.applied_statuses.append(status)
	
	return effect


func refresh_granted_statuses() -> void:
	var characters_ahead: Array[Character] = Game.level.characters.get_all_ahead_of(owner)
	var characters_adjacent: Array[Character] = Game.level.characters.get_adjacent_to(owner)

	var revoked_statuses: Array[Status] = []

	for status: Status in granted_statuses:
		var granted_ahead: bool = grant_ahead and status.name == grant_ahead.name
		if granted_ahead and status.owner not in characters_ahead:
			revoked_statuses.append(status)

		var granted_adjacent: bool = grant_adjacent and status.name == grant_adjacent.name
		if granted_adjacent and status.owner not in characters_adjacent:
			revoked_statuses.append(status)
	
	for status: Status in revoked_statuses:
		granted_statuses.erase(status)
		status.owner.state_component.remove_status(status)
	
	if grant_ahead:
		for character: Character in characters_ahead:
			if not character.state_component.active_statuses.any(func(s): return s.name == grant_ahead.name):
				granted_statuses.append(
					await character.state_component.apply_status(grant_ahead)
				)
	
	if grant_adjacent:
		for character: Character in characters_adjacent:
			if not character.state_component.active_statuses.any(func(s): return s.name == grant_adjacent.name):
				granted_statuses.append(
					await character.state_component.apply_status(grant_adjacent)
				)
