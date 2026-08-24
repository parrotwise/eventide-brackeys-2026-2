class_name Action
extends Resource


signal used(user: Character, target: Character)


@export_category("Effects")

@export var damage: int = 0
@export var healing: int = 0

@export_category("Targeting")

@export var range: float = 500.0

var character: Character


func use(user: Character, target: Character) -> void:
	used.emit(user, target)
