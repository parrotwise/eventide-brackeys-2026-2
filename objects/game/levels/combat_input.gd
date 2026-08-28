class_name CombatInput
extends Node


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func _unhandled_input(_event: InputEvent) -> void:
	pass


func _on_combat_start() -> void:
	pass
