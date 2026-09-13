class_name Action
extends Resource


signal used(user: Character, target: Character)
signal uses_expended()
signal uses_restored()


@export_group("Identifiers")

@export var name: String
@export_multiline() var description: String
@export var icon: Texture

@export_group("Audio")

## TODO: Deprecated!
@export var sfx: Audio.Clip
##       ...replaced with these below
@export var post_event: Audio.Event
@export var set_state: Audio.State
@export var set_switch: Audio.Switch
@export var switch_value: String

@export_group("Effect Definition")

@export var target_damage: int = 0
@export var target_damage_explosive: int = 0
@export var target_damage_poison: int = 0
@export var splash_damage: int = 0
@export var target_healing: int = 0
@export var target_healing_ratio: float = 0

@export var power_as_target_damage: bool = false
@export var power_as_target_damage_explosive: bool = false
@export var power_as_target_damage_poison: bool = false
@export var power_as_target_healing: bool = false

@export var swap_places: bool = false
@export var knockback_steps: int = 0
@export var knockback_to_rear: bool = false
@export var pull_steps: int = 0
@export var pull_to_front: bool = false

@export var crunch_peanuts: bool = false
@export var reattach_sootgut: bool = false

@export var cause_miss_action: bool = false
@export var cause_lose_turn: bool = false
@export var remove_source_status: bool = false
@export var repeat_on_random_target: bool = false

@export var applied_statuses: Array[Status] = []
@export var created_objects: Array[PackedScene] = []
@export var number_of_uses: int = 1
@export var free_action: bool = false

@export_category("Targeting")

@export var range_type: Enums.RangeType = Enums.RangeType.ANY
@export var target_group: Enums.BattleGroupType = Enums.BattleGroupType.OTHER_GROUP

var owner: Character
var uses_left: int = 0


func use(user: Character, target: Character) -> void:
	if not can_be_used():
		return
	
	uses_left -= 1

	if not uses_left:
		uses_expended.emit()
	
	Game.level.effector_component.apply(self, user, target)

	## TODO: Deprecated!
	Audio.play_sfx(sfx)
	##       ...replaced with these below
	Audio.post_event(post_event)
	Audio.set_state(set_state)
	Audio.set_switch(set_switch, switch_value)
	
	used.emit(user, target)


func restore_uses() -> void:
	if uses_left == 0 and number_of_uses > 0:
		uses_restored.emit()

	uses_left = number_of_uses


func remove_uses() -> void:
	if uses_left > 0:
		uses_expended.emit()
	
	uses_left = 0


func can_be_used() -> bool:
	if not uses_left:
		return false
	
	if swap_places and not owner.state_component.can_move:
		return false
	
	return true


func can_target(target: Character) -> bool:
	if not is_instance_valid(owner) or not is_instance_valid(target):
		return false
	
	if swap_places and not target.state_component.can_move:
		return false
	
	var target_is_valid: bool = true

	var own_group: StringName = owner.battle_group
	var other_group: StringName = Character.ALLIES_GROUP if own_group == Character.ENEMIES_GROUP else Character.ENEMIES_GROUP
	
	match range_type:
		Enums.RangeType.SELF:
			target_is_valid = target_is_valid and owner == target
		Enums.RangeType.MELEE:
			target_is_valid = target_is_valid and Game.level.characters.is_in_melee(owner) and Game.level.characters.is_in_melee(target)
		Enums.RangeType.CHARACTER_AHEAD:
			target_is_valid = target_is_valid and target == Game.level.characters.get_ahead_of(owner)
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
