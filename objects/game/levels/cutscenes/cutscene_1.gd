extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_music(Audio.Track.TRACK2)


func _on_texture_button_pressed() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.equipment_level)
