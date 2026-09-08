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
@export var base_max_health: int = 100
@export var passive_status: Status

var power_multiplier: float:
	get: return active_statuses.reduce(func(accum: float, status: Status): return accum * status.power_multiplier, 1.0)
var power_adder: int:
	get: return active_statuses.reduce(func(accum: int, status: Status): return accum + status.power_adder, 0)
var power: int:
	get: return roundi(base_power * power_multiplier) + power_adder

var max_health_multiplier: float:
	get: return active_statuses.reduce(func(accum: float, status: Status): return accum * status.max_health_multiplier, 1.0)
var max_health_adder: int:
	get: return active_statuses.reduce(func(accum: int, status: Status): return accum + status.max_health_adder, 0)
var max_health_one: bool:
	get: return active_statuses.reduce(func(accum: int, status: Status): return accum or status.max_health_one, false)
var max_health: int:
	get: return 1 if max_health_one else (ceili(base_max_health * max_health_multiplier) + max_health_adder)

var character: Character
var current_health: int
var knocked_out: bool = false

var current_health_ratio: float:
	get: return float(current_health) / max_health
var missing_health_ratio: float:
	get: return 1.0 - current_health_ratio

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


func refresh_health() -> void:
	var previous_health: int = current_health

	current_health = clampi(current_health, 0, max_health)
	
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

	refresh_health()

	return status


func remove_status(status: Status) -> void:
	if status == null:
		return
	
	if status not in _active_statuses:
		return
	
	status.remove()
	_active_statuses.erase(status)
	
	status_removed.emit(status)

	refresh_health()
