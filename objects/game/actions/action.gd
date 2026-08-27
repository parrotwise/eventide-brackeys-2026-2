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

@export var range_type: Enums.RangeType = Enums.RangeType.ANY
@export var target_group: Enums.BattleGroupType = Enums.BattleGroupType.OTHER_GROUP

var owner: Character


func use(user: Character, target: Character) -> void:
	used.emit(user, target)


func can_target(target: Character) -> bool:
	if not is_instance_valid(owner) or not is_instance_valid(target):
		return false

	var target_is_valid: bool = true

	var own_group: StringName = owner.battle_group
	var other_group: StringName = Character.ALLIES_GROUP if own_group == Character.ENEMIES_GROUP else Character.ENEMIES_GROUP

	match range_type:
		Enums.RangeType.MELEE:
			target_is_valid = target_is_valid and owner.is_in_melee() and target.is_in_melee()
	
	match target_group:
		Enums.BattleGroupType.OWN_GROUP:
			target_is_valid = target_is_valid and target.battle_group == own_group
		Enums.BattleGroupType.OTHER_GROUP:
			target_is_valid = target_is_valid and target.battle_group == other_group
	
	return target_is_valid


func valid_targets() -> Array[Character]:
	return Array(
		Game.level.characters.all.filter(func(c): return can_target(c)),
		TYPE_OBJECT, &'Node2D', Character
	)
