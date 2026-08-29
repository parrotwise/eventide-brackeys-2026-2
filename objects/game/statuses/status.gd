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

@export_group("Effect Definition")
## Value to be added to the owner's damage. Negative values subtract damage.
@export var damage_adder: int = 0
##Value to be added to the owner's healing. Negative values subtract healing.
@export var healing_adder: int = 0
@export var damage_multiplier: float = 1.0 
## Allows the owner to attack twice in one turn.
@export var can_attack_twice: bool = false

@export var stacking_type: Enums.StackingType
@export var triggers: Array[Trigger] = []

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


func modify_effect(effect: Effect) -> Effect:
	if owner == effect.owner:
		effect.damage += damage_adder
		effect.healing += healing_adder
		effect.damage = floori(effect.damage * damage_multiplier)
	return effect
