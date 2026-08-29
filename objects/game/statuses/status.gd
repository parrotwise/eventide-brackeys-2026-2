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
@export var vfx: PackedScene

@export_group("Effect")
@export var damage_dealt_adder: int = 0
@export var damage_taken_adder: int = 0
@export var healing_applied_adder: int = 0
@export var healing_received_adder: int = 0
@export var damage_dealt_multiplier: float = 1.0 
@export var damage_taken_multiplier: float = 1.0 
@export var healing_applied_multiplier: float = 1.0
@export var healing_received_multiplier: float = 1.0
@export var can_attack_twice: bool = false

@export_group("Triggers")
@export var triggers: Array[Trigger] = []
@export var trigger_uses: int = -1
@export var remove_when_triggers_used_up: bool = true

@export_group("")
@export var stacking_type: Enums.StackingType

var stack: int = 1

var owner: Character


func apply_to(character: Character) -> void:
	owner = character
	
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
	if owner == effect.owner:
		effect.damage = floori(effect.damage * damage_dealt_multiplier)
		effect.damage += damage_dealt_adder
		effect.damage_explosive = floori(effect.damage_explosive * damage_dealt_multiplier)
		effect.damage_explosive += damage_dealt_adder
		effect.healing = floori(effect.healing * healing_applied_multiplier)
		effect.healing += healing_applied_adder
	
	if owner == effect.target:
		effect.damage = floori(effect.damage * damage_taken_multiplier)
		effect.damage += damage_taken_adder
		effect.damage_explosive = floori(effect.damage_explosive * damage_taken_multiplier)
		effect.damage_explosive += damage_taken_adder
		effect.healing = floori(effect.healing * healing_received_multiplier)
		effect.healing += healing_received_adder
	
	return effect
