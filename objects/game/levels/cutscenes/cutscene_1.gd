extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	## TODO: Replace with the commented-out call after Wwise migration
	Audio.play_music(Audio.Track.TRACK2)
	# Audio.post_event(Audio.Event.MUSIC_START)


func _on_texture_button_pressed() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)
