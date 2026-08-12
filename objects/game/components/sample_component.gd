class_name SampleComponent
extends Node


var player: Player


func _process(_delta: float) -> void:
	player.sprite.self_modulate = player.sprite.self_modulate.lerp(
		Random.randsample([Color.WHITE, Color.BLACK]),
		Random.randfloat(0.05, 0.10)
	)
