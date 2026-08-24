class_name StateComponent
extends Node


signal health_changed(current_health: int, max_health: int)
signal knockout

signal status_applied(status: Status)

signal status_removed(status: Status)


@export_group("Health")
@export var max_health: int = 100

@export_group("Status Effects")
## The Character's passive ability
@export var passive_status: Status


var character: Character
var current_health: int
var knocked_out: bool = false


## Status effects currently affecting this Character
var _active_statuses: Array[Status] = []
var active_statuses: Array[Status]:
	get:
		return _active_statuses.duplicate()


func _ready() -> void:
	current_health = max_health
	
	if passive_status != null:
		apply_status(passive_status)

func take_damage(damage: int) -> void:
	if knocked_out:
		return
	
	current_health = maxi(0, current_health - damage)
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		knocked_out = true
		knockout.emit()
		
func heal(amount: int) -> void:
	if knocked_out:
		return
	
	current_health = mini(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
	
func reset_health() -> void:
	current_health = max_health
	knocked_out = false
	health_changed.emit(current_health, max_health)


func apply_status(status_template: Status) -> void:
	if status_template == null:
		return
	
	var status: Status = status_template.duplicate(true)
	
	_active_statuses.append(status)
	
	if status.max_health_adder != 0:
		max_health += int(status.max_health_adder)
		current_health = mini(current_health, max_health)
	
	status.apply_to(character)
	
	status_applied.emit(status)


func remove_status(status: Status) -> void:
	if status == null:
		return
	
	if status not in _active_statuses:
		return
	
	if status.max_health_adder != 0:
		max_health -= int(status.max_health_adder)
		current_health = mini(current_health, max_health)
	
	status.remove_from()
	_active_statuses.erase(status)
	
	status_removed.emit(status)
