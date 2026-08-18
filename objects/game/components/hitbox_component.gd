class_name HitboxComponent
extends Area2D


signal hit(character: Player)

var hazard: Node2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		hit.emit(area.character)
