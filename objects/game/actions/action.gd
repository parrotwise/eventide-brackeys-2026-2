class_name Action
extends Resource


signal used(user: Character, target: Character)


@export_group("Identifiers")

@export var name: String
@export_multiline() var description: String
@export var icon: Texture

@export_group("Effect Definition")

@export var target_damage: int = 0
@export var splash_damage: int = 0
@export var target_healing: int = 0

@export var power_as_target_damage: bool = false
@export var power_as_target_healing: bool = false

@export var swap_places: bool = false
@export var knockback_once: bool = false
@export var knockback_to_rear: bool = false
@export var pull_once: bool = false
@export var pull_to_front: bool = false

@export var cause_miss_action: bool = false
@export var remove_source_status: bool = false

@export var applied_statuses: Array[Status] = []

@export_category("Targeting")

@export var range_type: Enums.RangeType = Enums.RangeType.ANY
@export var target_group: Enums.BattleGroupType = Enums.BattleGroupType.OTHER_GROUP

var owner: Character


func use(user: Character, target: Character) -> void:
	Game.level.effector_component.apply(self, user, target)
	used.emit(user, target)


func can_target(target: Character) -> bool:
	if not is_instance_valid(owner) or not is_instance_valid(target):
		return false

	var target_is_valid: bool = true

	var own_group: StringName = owner.battle_group
	var other_group: StringName = Character.ALLIES_GROUP if own_group == Character.ENEMIES_GROUP else Character.ENEMIES_GROUP
	
	match range_type:
		Enums.RangeType.SELF:
			target_is_valid = target_is_valid and owner == target
		Enums.RangeType.MELEE:
			target_is_valid = target_is_valid and Game.level.characters.is_in_melee(owner) and Game.level.characters.is_in_melee(target)
		Enums.RangeType.ADJACENT_ALLY:
			target_is_valid = target_is_valid and target in Game.level.characters.get_adjacent_to(owner)
	
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
