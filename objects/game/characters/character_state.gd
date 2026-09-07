class_name CharacterState
extends Node


signal health_changed(previous_health: int, current_health: int)
signal damage_taken()
signal explosive_damage_taken()
signal healing_received()
signal knockout()

signal status_applied(status: Status)
signal status_removed(status: Status)

@export var base_power: int = 10
@export var max_health: int = 100
@export var passive_status: Status

var power_multiplier: float:
	get: return active_statuses.reduce(func(accum: float, status: Status): return accum * status.power_multiplier, 1.0)
var power_adder: int:
	get: return active_statuses.reduce(func(accum: int, status: Status): return accum + status.power_adder, 0)
var power: int:
	get: return roundi(base_power * power_multiplier) + power_adder

var character: Character
var current_health: int
var knocked_out: bool = false

## Status effects currently affecting this Character
var _active_statuses: Array[Status] = []
var active_statuses: Array[Status]:
	get: return _active_statuses


func _ready() -> void:
	current_health = max_health

	Game.start.connect(_on_combat_start)


func _on_combat_start() -> void:
	if passive_status != null:
		apply_status(passive_status)


func take_damage(damage: int, explosive: bool = false) -> void:
	if knocked_out:
		return
	
	var previous_health: int = current_health
	
	current_health = maxi(0, current_health - damage)

	if current_health == previous_health:
		return
	
	health_changed.emit(previous_health, current_health)
	damage_taken.emit()

	if explosive:
		explosive_damage_taken.emit()
	
	if current_health == 0:
		knocked_out = true
		knockout.emit()

		Game.level.characters.remove(character)


func heal(amount: int) -> void:
	if knocked_out:
		return
	
	var previous_health: int = current_health

	current_health = mini(max_health, current_health + amount)

	if current_health == previous_health:
		return
	
	health_changed.emit(previous_health, current_health)
	healing_received.emit()


func add_max_health(amount: int) -> void:
	if knocked_out:
		return
	
	max_health = maxi(0, max_health + amount)
	
	var previous_health: int = current_health

	current_health = mini(max_health, current_health)

	if current_health == previous_health:
		return
	
	health_changed.emit(previous_health, current_health)
	
	if current_health == 0:
		knocked_out = true
		knockout.emit()

		Game.level.characters.remove(character)


func reset_health() -> void:
	var previous_health: int = current_health

	current_health = max_health
	knocked_out = false
	
	if current_health == previous_health:
		return
	
	health_changed.emit(previous_health, current_health)


func apply_status(status_template: Status) -> Status:
	if status_template == null:
		return null
	
	match status_template.stacking_type:
		Enums.StackingType.UNIQUE:
			if _active_statuses.any(func(s): return s.name == status_template.name):
				return null
		Enums.StackingType.STACKING:
			for status: Status in active_statuses:
				if status.name == status_template.name:
					status.stack += 1
					return null

	var status: Status = status_template.duplicate(true)
	
	_active_statuses.append(status)
	
	status.applied.connect(func(_character): status_applied.emit(status))
	status.apply_to(character)

	return status


func remove_status(status: Status) -> void:
	if status == null:
		return
	
	if status not in _active_statuses:
		return
	
	status.remove()
	_active_statuses.erase(status)
	
	status_removed.emit(status)
