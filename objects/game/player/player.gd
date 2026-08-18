class_name Player
extends CharacterBody2D


var sprite: Sprite2D:
	get: return $Sprite
var collider: CollisionShape2D:
	get: return $Collider
var input_component: InputComponent:
	get: return $InputComponent
var movement_component: MovementComponent:
	get: return $MovementComponent
var health_component: HealthComponent:
	get: return $HealthComponent
var hurtbox_component: HurtboxComponent:
	get: return $HurtboxComponent
var audio_component: AudioComponent:
	get: return $AudioComponent


func _ready() -> void:
	Game.player = self

	input_component.character = self
	input_component.movement_input.connect(movement_component.update_velocities)

	hurtbox_component.character = self
	hurtbox_component.hurt.connect(_on_hurt_by)

	health_component.character = self
	health_component.knockout.connect(Game.end.emit)

	movement_component.character = self
	audio_component.source = self


func _on_hurt_by(hazard: Hazard) -> void:
	health_component.take_damage(hazard.damage)
	audio_component.play_clip(&'grunt', 0.5)
	
	Debug.info('Took %d damage, %d health left.' % [hazard.damage, health_component.current_health])
