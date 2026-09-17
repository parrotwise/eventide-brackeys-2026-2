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

@export var healing_ratio: float = 0
var stacked_healing_ratio: float:
	get: return healing_ratio * stack_mult

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

var repeat_on_target: Character = null

var stack_mult: int:
	get: return source.stack if is_instance_valid(source) and source is Status else 1


static func create(p_source: Variant, p_user: Character, p_target: Character) -> Effect:
	var effect := Effect.new()
	effect.source = p_source
	effect.owner = p_user
	effect.target = p_target
	return effect


func apply(bypass_queue: bool = false) -> void:
	if not target:
		return
	
	if not bypass_queue:
		Game.combat.queue.push_effect(self)
		await Game.combat.queue.await_effect(self)
		return
	
	var total_damage: int = stacked_damage + stacked_damage_explosive + stacked_damage_poison
	var total_healing: int = stacked_healing + ceili(stacked_healing_ratio * target.state.max_health)
	
	## Immediate effects first
	if total_damage:
		target.state.take_damage(total_damage, stacked_damage_explosive > 0)
	if total_healing:
		target.state.heal(total_healing)
	if swap_places:
		Game.combat.characters.swap_places(owner, target)
	for __ in knockback_steps:
		Game.combat.characters.move_backward(target)
	while knockback_to_rear:
		var old_index: int = Game.combat.characters.index_of(target)
		Game.combat.characters.move_backward(target)
		if old_index == Game.combat.characters.index_of(target):
			break
	for __ in pull_steps:
		Game.combat.characters.move_forward(target)
	while pull_to_front:
		var old_index: int = Game.combat.characters.index_of(target)
		Game.combat.characters.move_forward(target)
		if old_index == Game.combat.characters.index_of(target):
			break
	if crunch_peanuts:
		for object: GroundObject in Game.combat.ground_objects.objects:
			if object.name == &'Peanuts' and object.character == owner:
				object.despawn()
	if reattach_sootgut:
		for object: GroundObject in Game.combat.ground_objects.objects:
			if object.name == &'Sootgut':
				object.attach_to(target)
	if increase_basic_attack_max_uses:
		target.actions.basic_attack.number_of_uses += 1
		target.actions.basic_attack.uses_left += 1
	if cooldown_basic_attack:
		target.actions.basic_attack.remove_uses()
		target.actions.action_cooldowns[target.actions.basic_attack] = cooldown_basic_attack
	if cooldown_reposition:
		target.actions.reposition.remove_uses()
		target.actions.action_cooldowns[target.actions.reposition] = cooldown_reposition
	if cooldown_character_skill:
		target.actions.skills[0].remove_uses()
		target.actions.action_cooldowns[target.actions.skills[0]] = cooldown_character_skill
	if free_reposition:
		target.actions.reposition.free_action = true
	if cause_miss_action:
		Game.combat.effector.missed_actions.append(
			Game.combat.status_tracker.cached['last_action']
		)
	if cause_lose_turn:
		Game.combat.turn_tracker.lose_turn(target)
	
	## Persistent effects next
	for status: Status in applied_statuses:
		await target.state.apply_status(status)
	for object: PackedScene in created_objects:
		Game.combat.ground_objects.spawn(object, target)
	
	if remove_source_status:
		source.owner.state_component.remove_status(source)

	## TODO: Deprecated!
	Audio.play_sfx(sfx)
	##       ...replaced with these below
	Audio.post_event(post_event)
	Audio.set_state(set_state)
	Audio.set_switch(set_switch, switch_value)
	
	for extra_effect: Effect in extra_effects:
		await extra_effect.apply(bypass_queue)

	if repeat_on_target:
		var repeat: Effect = duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		repeat.owner = owner
		repeat.source = source
		repeat.target = repeat_on_target
		repeat.repeat_on_target = null
		await repeat.apply(bypass_queue)
	
	applied.emit()
