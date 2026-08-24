class_name Equipment
extends Resource

@export_group("Required vars")
## A name to be exposed to the player.
@export var name: String
## A description to be exposed to the player.
@export_multiline() var description: String


@export_group("Optional vars")
## Value to be added to the user's attack. Negative values subtract attack.
@export var attack_adder: float = 0
## Value to be added to the user's health. Negative values subtract health.
@export var health_adder: float = 0
## Allows the user to attack twice in one turn.
@export var can_attack_twice: bool = false
## An array of StatusEffect resources.
@export var status_effects: Array[StatusEffect] = []
