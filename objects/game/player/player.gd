class_name Player
extends CharacterBody2D


var sprite: Sprite2D:
	get: return $Sprite
var collider: CollisionShape2D:
	get: return $Collider
var sample_component: SampleComponent:
	get: return $SampleComponent


func _ready() -> void:
	Game.player = self
	sample_component.player = self
