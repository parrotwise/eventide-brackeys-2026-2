class_name Effect
extends Resource


signal applied()

@export_group("Identifiers")

@export var name: String = ""

@export_group("Audio")

## TODO: Deprecated!
@export var sfx: Audio.Clip
##       ...replaced with these below
@export var post_event: Audio.Event
@export var set_state: Audio.State
@export var set_switch: Audio.Switch
@export var switch_value: String

@export_group("Effect Definition")

@export var damage: int = 0
var stacked_damage: int:
	get: return damage * stack_mult

@export var damage_explosive: int = 0
var stacked_damage_explosive: int:
	get: return damage_explosive * stack_mult

@export var damage_poison: int = 0
var stacked_damage_poison: int:
	get: return damage_poison * (2 ** (stack_mult - 1))

@export var healing: int = 0
var stacked_healing: int:
	get: return healing * stack_mult

@export var swap_places: bool = false
@export var knockback_steps: int = 0
@export var knockback_to_rear: bool = false
@export var pull_steps: int = 0
@export var pull_to_front: bool = false

@export var crunch_peanuts: bool = false
@export var reattach_sootgut: bool = false

@export var increase_basic_attack_max_uses: int = 0
@export var cooldown_basic_attack: int = 0
@export var cooldown_reposition: int = 0
@export var cooldown_character_skill: int = 0
@export var free_reposition: bool = false

@export var cause_miss_action: bool = false
@export var cause_lose_turn: bool = false
@export var remove_source_status: bool = false

@export var applied_statuses: Array[Status] = []
@export var created_objects: Array[PackedScene] = []
@export var extra_effects: Array[Effect] = []

var source: Variant  # The parent Action or Status
var owner: Character
var target: Character

var stack_mult: int:
	get: return source.stack if is_instance_valid(source) and source is Status else 1


static func create(p_source: Variant, p_user: Character, p_target: Character) -> Effect:
	var effect := Effect.new()
	effect.source = p_source
	effect.owner = p_user
	effect.target = p_target
	return effect


func merge_with(other: Effect) -> Effect:
	damage += other.damage
	damage_explosive += other.damage_explosive
	healing += other.healing

	swap_places = swap_places or other.swap_places
	knockback_steps = knockback_steps + other.knockback_steps
	knockback_to_rear = knockback_to_rear or other.knockback_to_rear
	pull_steps = pull_steps + other.pull_steps
	pull_to_front = pull_to_front or other.pull_to_front

	crunch_peanuts = crunch_peanuts or other.crunch_peanuts
	reattach_sootgut = reattach_sootgut or other.reattach_sootgut

	cause_miss_action = cause_miss_action or other.cause_miss_action
	remove_source_status = remove_source_status or other.remove_source_status

	applied_statuses.append_array(other.applied_statuses)

	return self


func apply(bypass_queue: bool = false) -> void:
	if not target:
		return
	
	if not bypass_queue:
		Game.level.queue.push_effect(self)
		await Game.level.queue.await_effect(self)
		return
	
	var total_damage: int = stacked_damage + stacked_damage_explosive + stacked_damage_poison
	var total_healing: int = stacked_healing
	
	## Immediate effects first
	if total_damage:
		target.state_component.take_damage(total_damage, stacked_damage_explosive > 0)
	if total_healing:
		target.state_component.heal(total_healing)
	if swap_places:
		Game.level.characters.swap_places(owner, target)
	for __ in knockback_steps:
		Game.level.characters.move_backward(target)
	if knockback_to_rear:
		while not Game.level.characters.is_in_rear(target):
			Game.level.characters.move_backward(target)
	for __ in pull_steps:
		Game.level.characters.move_forward(target)
	if pull_to_front:
		while not Game.level.characters.is_in_melee(target):
			Game.level.characters.move_forward(target)
	if crunch_peanuts:
		for object: GroundObject in Game.level.ground_objects.objects:
			if object.name == &'Peanuts' and object.character == owner:
				object.despawn()
	if reattach_sootgut:
		for object: GroundObject in Game.level.ground_objects.objects:
			if object.name == &'Sootgut':
				object.attach_to(target)
	if increase_basic_attack_max_uses:
		target.actions_component.basic_attack.number_of_uses += 1
		target.actions_component.basic_attack.uses_left += 1
	if cooldown_basic_attack:
		target.actions_component.basic_attack.remove_uses()
		target.actions_component.action_cooldowns[target.actions_component.basic_attack] = cooldown_basic_attack
	if cooldown_reposition:
		target.actions_component.reposition.remove_uses()
		target.actions_component.action_cooldowns[target.actions_component.reposition] = cooldown_reposition
	if cooldown_character_skill:
		target.actions_component.skills[0].remove_uses()
		target.actions_component.action_cooldowns[target.actions_component.skills[0]] = cooldown_character_skill
	if free_reposition:
		target.actions_component.reposition.free_action = true
	if cause_miss_action:
		Game.level.effector_component.missed_actions.append(
			Game.level.status_tracker_component.cached['last_action']
		)
	if cause_lose_turn:
		Game.level.turn_tracker_component.lose_turn(target)
	
	## Persistent effects next
	for status: Status in applied_statuses:
		await target.state_component.apply_status(status)
	for object: PackedScene in created_objects:
		Game.level.ground_objects.spawn(object, target)
	
	if remove_source_status:
		source.owner.state_component.remove_status(source)

	## TODO: Deprecated!
	Audio.play_sfx(sfx)
	##       ...replaced with these below
	Audio.post_event(post_event)
	Audio.set_state(set_state)
	Audio.set_switch(set_switch, switch_value)
	
	applied.emit()

	for extra_effect: Effect in extra_effects:
		await extra_effect.apply(bypass_queue)
