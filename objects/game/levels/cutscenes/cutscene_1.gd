extends Control


var skipper: CutsceneSkipper:
	get: return $Skipper


func _ready() -> void:
	skipper.skip_requested.connect(skip)
	
	Audio.play_music(Audio.Track.TRACK2)


func _on_texture_button_pressed() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)


func skip() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)
