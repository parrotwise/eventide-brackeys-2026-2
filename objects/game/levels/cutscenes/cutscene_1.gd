extends Control


var skipper: CutsceneSkipper:
	get: return $Skipper


func _ready() -> void:
	skipper.skip_requested.connect(skip)
	
	## TODO: Replace with the commented-out call after Wwise migration
	Audio.play_music(Audio.Track.TRACK2)
	# Audio.post_event(Audio.Event.MUSIC_START)


func _on_texture_button_pressed() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)


func skip() -> void:
	skipper.feedback_text.hide()
	TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)
