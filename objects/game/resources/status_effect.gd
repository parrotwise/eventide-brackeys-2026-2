class_name StatusEffect
extends Resource


@export_group("Required vars")
## A name to be exposed to the player.
@export var name: String
## A description to be exposed to the player.
@export_multiline() var description: String
## An icon to be exposed to the player.
@export var icon: Texture

@export_group("Optional vars")
@export var vfx: PackedScene
