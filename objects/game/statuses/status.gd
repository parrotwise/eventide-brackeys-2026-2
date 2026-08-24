class_name Status
extends Resource


@export_group("Identifiers")
## A name to be exposed to the player.
@export var name: String
## A description to be exposed to the player.
@export_multiline() var description: String
## An icon to be exposed to the player.
@export var icon: Texture

@export var vfx: PackedScene

@export_group("Effect Definition")
## Value to be added to the owner's attack. Negative values subtract attack.
@export var attack_adder: float = 0
## Value to be added to the owner's health. Negative values subtract health.
@export var health_adder: float = 0
## Allows the owner to attack twice in one turn.
@export var can_attack_twice: bool = false
