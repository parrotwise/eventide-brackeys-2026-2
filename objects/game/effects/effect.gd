class_name Effect
extends Resource


signal applied()

@export_group("Effect Definition")

@export var damage: int = 0
@export var healing: int = 0
@export var applied_statuses: Array[Status] = []

var owner: Character
var target: Character


func apply(_bypass_queue: bool = false) -> void:
	if not target:
		return
	
	## Immediate effects first
	target.state_component.take_damage(damage)
	target.state_component.heal(healing)
	
	## Persistent effects next
	for status: Status in applied_statuses:
		target.state_component.apply_status(status)
	
	applied.emit()
