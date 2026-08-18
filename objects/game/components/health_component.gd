class_name HealthComponent
extends Node


signal knockout()

@export var max_health: int

var character: Player

@onready var current_health: int = max_health
@onready var knocked_out: bool = false


func take_damage(damage: int) -> void:
	if knocked_out:
		return
	
	current_health = maxi(0, current_health - damage)

	if current_health == 0:
		knocked_out = true
		knockout.emit()
