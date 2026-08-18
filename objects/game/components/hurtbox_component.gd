class_name HurtboxComponent
extends Area2D


signal hurt(by_hazard: Node)

var character: Player


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		hurt.emit(area.hazard)
