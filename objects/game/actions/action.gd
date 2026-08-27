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

var owner: Character


func use(user: Character, target: Character) -> void:
	used.emit(user, target)


func can_target(target: Character) -> bool:
	if not is_instance_valid(owner) or not is_instance_valid(target):
		return false

	var target_is_valid: bool = true

	match range_type:
		Enums.RangeType.ALLY:
			target_is_valid = target_is_valid and owner.battle_group == target.battle_group
		Enums.RangeType.MELEE:
			target_is_valid = target_is_valid and owner.is_in_melee() and target.is_in_melee()

	return target_is_valid


func valid_targets() -> Array[Character]:
	return Array(
		Game.level.characters.all.filter(func(c): return can_target(c)),
		TYPE_OBJECT, &'Node2D', Character
	)
