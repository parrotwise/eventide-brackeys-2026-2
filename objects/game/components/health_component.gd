class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal knockout

@export var max_health: int = 100

var character: Character
var current_health: int
var knocked_out: bool = false


func _ready() -> void:
	current_health = max_health


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
