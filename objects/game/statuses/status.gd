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

@export_subgroup("Adders")
@export var damage_dealt_adder: int = 0
@export var damage_taken_adder: int = 0
@export var healing_applied_adder: int = 0
@export var healing_received_adder: int = 0
@export var max_health_adder: int = 0

@export_subgroup("Multipliers")
@export var damage_dealt_multiplier: float = 1.0 
@export var missing_hp_to_dmg_dealt_mult: float = 0.0
@export var damage_dealt_to_splash_mult: float = 0.0
@export var damage_taken_to_splash_mult: float = 0.0
@export var damage_taken_multiplier: float = 1.0 
@export var healing_applied_multiplier: float = 1.0
@export var healing_received_multiplier: float = 1.0
@export var max_health_multiplier: float = 1.0
@export var power_multiplier: float = 1.0

@export_subgroup("Flags")
@export var can_attack_twice: bool = false
@export var can_be_healed: bool = true
## Cannot move or be moved by force.
@export var can_be_moved: bool = true
@export var movement_is_free: bool = false
@export var granted_actions: Array[Action] = []
@export var no_more_please: bool = false

@export_group("Positional")
@export var grant_ahead: Status = null
@export var grant_adjacent: Status = null

@export_group("Triggers")
@export var triggers: Array[Trigger] = []
@export var trigger_uses: int = -1
@export var remove_when_triggers_used_up: bool = true

@export_group("")
@export var stacking_type: Enums.StackingType

var granted_statuses: Array[Status] = []
var stack: int = 1

var owner: Character


func apply_to(character: Character) -> void:
	owner = character
	
	for i: int in granted_actions.size():
		granted_actions[i] = granted_actions[i].duplicate()
		granted_actions[i].owner = character

	for i: int in triggers.size():
		triggers[i] = triggers[i].duplicate()
	
	for trigger: Trigger in triggers:
		trigger.effect = trigger.effect.duplicate()
		trigger.effect.owner = character
		trigger.effect.source = self

	applied.emit(owner)
	
	Game.level.status_tracker_component.track(self)

	for trigger: Trigger in triggers:
		if trigger.trigger_type == Enums.TriggerType.SOURCE_APPLIED:
			trigger.fire()


func remove() -> void:
	for trigger: Trigger in triggers:
		if trigger.trigger_type == Enums.TriggerType.SOURCE_REMOVED:
			trigger.fire()
	
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
	
	if effect.source.name == &'Sling Slop' and no_more_please:
		effect.cause_lose_turn = true
	
	var missing_health_ratio: float = 1.0 - (float(owner.state_component.current_health) / owner.state_component.max_health)
	var final_damage_dealt_multiplier = damage_dealt_multiplier + missing_hp_to_dmg_dealt_mult * missing_health_ratio

	if owner == effect.owner:
		effect.damage = floori(effect.damage * final_damage_dealt_multiplier)
		effect.damage += damage_dealt_adder
		effect.damage_explosive = floori(effect.damage_explosive * final_damage_dealt_multiplier)
		effect.damage_explosive += damage_dealt_adder
		effect.healing = floori(effect.healing * healing_applied_multiplier)
		effect.healing += healing_applied_adder
		effect.add_max_health = floori((1 - max_health_multiplier) * effect.owner.state_component.max_health)
		effect.add_max_health += max_health_adder

		if (effect.damage or effect.damage_explosive) and is_instance_valid(effect.target):
			for adjacent: Character in Game.level.characters.get_adjacent_to(effect.target):
				var splash_effect: Effect = Effect.create(self, effect.owner, adjacent)

				splash_effect.damage = roundi(effect.damage * damage_dealt_to_splash_mult)
				splash_effect.damage_explosive = roundi(effect.damage_explosive * damage_dealt_to_splash_mult)

				effect.extra_effects.append(splash_effect)
	
	if owner == effect.target:
		effect.damage = floori(effect.damage * damage_taken_multiplier)
		effect.damage += damage_taken_adder
		effect.damage_explosive = floori(effect.damage_explosive * damage_taken_multiplier)
		effect.damage_explosive += damage_taken_adder
		effect.healing = floori(effect.healing * healing_received_multiplier)
		effect.healing += healing_received_adder
		effect.add_max_health = floori((1 - max_health_multiplier) * effect.owner.state_component.max_health)
		effect.add_max_health += max_health_adder

		if (effect.damage or effect.damage_explosive) and is_instance_valid(effect.target):
			for adjacent: Character in Game.level.characters.get_adjacent_to(effect.target):
				var splash_effect: Effect = Effect.create(self, effect.owner, adjacent)
				
				splash_effect.damage = roundi(effect.damage * damage_taken_to_splash_mult)
				splash_effect.damage_explosive = roundi(effect.damage_explosive * damage_taken_to_splash_mult)
				
				effect.extra_effects.append(splash_effect)
	
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
					character.state_component.apply_status(grant_ahead)
				)
	
	if grant_adjacent:
		for character: Character in characters_adjacent:
			if not character.state_component.active_statuses.any(func(s): return s.name == grant_adjacent.name):
				granted_statuses.append(
					character.state_component.apply_status(grant_adjacent)
				)
