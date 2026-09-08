class_name Equipment
extends Resource

@export_group("Identifiers")
## A name to be exposed to the player.
@export var name: String
## A description to be exposed to the player.
@export_multiline() var description: String
## An icon to be exposed to the player.
@export var icon: Texture2D
## Implement the persistent effect of using this Equipment as a Status effect.
@export var equipped_status: Status
## Implement the activated effect of using this Equipment as an Action.
@export var activated_ability: Action

var owner: Character
