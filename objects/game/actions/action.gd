class_name Action
extends Resource


signal used(user: Character, target: Character)


@export_group("Identifiers")

@export var name: String
@export_multiline() var description: String
@export var icon: Texture

@export_group("Effect Definition")

@export var damage: int = 0
@export var healing: int = 0

@export_category("Targeting")

@export var range_type: Enums.RangeType = Enums.RangeType.MELEE


func use(user: Character, target: Character) -> void:
	used.emit(user, target)
