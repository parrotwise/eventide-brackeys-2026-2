extends Control


func _ready() -> void:
	await get_tree().create_timer(7).timeout
	TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)
