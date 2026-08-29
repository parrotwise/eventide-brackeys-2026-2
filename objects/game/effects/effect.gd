class_name Effect
extends Resource


signal applied()

@export_group("Effect Definition")

@export var damage: int = 0
@export var damage_explosive: int = 0
@export var healing: int = 0
@export var add_max_health: int = 0

@export var swap_places: bool = false
@export var knockback_once: bool = false
@export var knockback_to_rear: bool = false
@export var pull_once: bool = false
@export var pull_to_front: bool = false

@export var crunch_peanuts: bool = false
@export var reattach_sootgut: bool = false

@export var cause_miss_action: bool = false
@export var remove_source_status: bool = false

@export var applied_statuses: Array[Status] = []
@export var created_objects: Array[PackedScene] = []

var source: Variant  # The parent Action or Status
var owner: Character
var target: Character


func merge_with(other: Effect) -> Effect:
	damage += other.damage
	damage_explosive += other.damage_explosive
	healing += other.healing
	add_max_health += other.add_max_health

	swap_places = swap_places or other.swap_places
	knockback_once = knockback_once or other.knockback_once
	knockback_to_rear = knockback_to_rear or other.knockback_to_rear
	pull_once = pull_once or other.pull_once
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
		return
	
	## Immediate effects first
	if damage or damage_explosive:
		target.state_component.take_damage(damage + damage_explosive, damage_explosive > 0)
	if healing:
		target.state_component.heal(healing)
	if add_max_health:
		target.state_component.add_max_health(add_max_health)
	if swap_places:
		Game.level.characters.swap_places(owner, target)
	if knockback_once:
		Game.level.characters.move_backward(target)
	if knockback_to_rear:
		while not Game.level.characters.is_in_rear(target):
			Game.level.characters.move_backward(target)
	if pull_once:
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
	if cause_miss_action:
		Game.level.effector_component.missed_actions.append(
			Game.level.status_tracker_component.cached['last_action']
		)
	
	## Persistent effects next
	for status: Status in applied_statuses:
		target.state_component.apply_status(status)
	for object: PackedScene in created_objects:
		Game.level.ground_objects.spawn(object, target)
	
	if remove_source_status:
		source.owner.state_component.remove_status(source)
	
	applied.emit()
