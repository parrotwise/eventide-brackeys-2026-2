class_name Effect
extends Resource


signal applied()

@export_group("Effect Definition")

@export var damage: int = 0
@export var healing: int = 0
@export var add_max_health: int = 0

@export var swap_places: bool = false
@export var knockback_once: bool = false
@export var knockback_to_rear: bool = false
@export var pull_once: bool = false
@export var pull_to_front: bool = false

@export var applied_statuses: Array[Status] = []

var source: Variant  # The parent Action or Status
var owner: Character
var target: Character


func apply(bypass_queue: bool = false) -> void:
	if not target:
		return
	
	if not bypass_queue:
		Game.level.queue.push_effect(self)
		return
	
	## Immediate effects first
	if damage:
		target.state_component.take_damage(damage)
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
	
	## Persistent effects next
	for status: Status in applied_statuses:
		target.state_component.apply_status(status)
	
	applied.emit()
