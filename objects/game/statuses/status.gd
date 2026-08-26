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
## Value to be added to the owner's health. Negative values subtract health.
@export var max_health_adder: int = 0
##Value to be added to the owner's healing. Negative values subtract healing.
@export var healing_adder: int = 0
## Allows the owner to attack twice in one turn.
@export var can_attack_twice: bool = false

@export var triggers: Array[Trigger] = []

var owner: Character


func apply_to(character: Character) -> void:
	owner = character
	
	for trigger: Trigger in triggers:
		trigger.effect = trigger.effect.duplicate()
		trigger.effect.owner = character
	
	owner.state_component.add_max_health(max_health_adder)

	Game.level.status_tracker_component.track(self)
	
	applied.emit(owner)
	
	for trigger: Trigger in triggers:
		if trigger.trigger_type == Enums.TriggerType.IMMEDIATE:
			trigger.fire()


func remove() -> void:
	Game.level.status_tracker_component.untrack(self)
	
	owner.state_component.add_max_health(- max_health_adder)

	removed.emit(owner)

	owner = null


func modify_effect(effect: Effect) -> Effect:
	effect.damage += damage_adder
	effect.healing += healing_adder
 
	return effect
