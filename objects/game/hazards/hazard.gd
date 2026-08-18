class_name Hazard
extends Node2D


@export var damage: int

var sprite: Sprite2D:
	get: return $Sprite
var hitbox_component: HitboxComponent:
	get: return $HitboxComponent


func _ready() -> void:
	Game.hazards.append(self)

	hitbox_component.hazard = self
	hitbox_component.hit.connect(_on_hitting)


func _exit_tree() -> void:
	Game.hazards.erase(self)


func _on_hitting(_character: Player) -> void:
	queue_free()
