class_name CharacterInput
extends Node

## Copied and modified from another project.


signal movement_input(move_direction: Vector2)

var character: Character
var is_moving: bool = false


func _process(_delta: float) -> void:
	get_direction_vector()


func get_direction_vector() -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		if not is_moving:
			is_moving = true
		movement_input.emit(direction)
	elif is_moving:
		is_moving = false
		movement_input.emit(Vector2.ZERO)
