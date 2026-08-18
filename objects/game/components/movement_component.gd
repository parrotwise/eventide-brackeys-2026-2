class_name MovementComponent
extends Node

## Copied and modified from another project.


const ACCELERATION_SPEED: float = 6
const DECELERATION_SPEED: float = 6

@export var speed: float = 600.0

var character: Player
var new_velocity: Vector2


func update_velocities(direction: Vector2) -> void:
	if direction:
		new_velocity = direction * speed
		character.velocity.x = move_toward(character.velocity.x, new_velocity.x, ACCELERATION_SPEED)
		character.velocity.y = move_toward(character.velocity.y, new_velocity.y, ACCELERATION_SPEED)
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, DECELERATION_SPEED)
		character.velocity.y = move_toward(character.velocity.y, 0, DECELERATION_SPEED)
		# Loop deceleration until zero.
		if character.velocity:
			update_velocities(direction)
	
	character.move_and_slide()
	
	# Update the sprite to match player movement.
	if direction.x > 0:
		character.sprite.flip_h = true
	elif direction.x < 0:
		character.sprite.flip_h = false
