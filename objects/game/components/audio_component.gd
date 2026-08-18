class_name AudioComponent
extends AudioStreamPlayer2D


@export var audio_stream: AudioStream

var source: Node2D


func _ready() -> void:
	stream = audio_stream
	Audio.audio_components.append(self)


func _exit_tree() -> void:
	Audio.audio_components.erase(self)


func play_clip(clip_name: StringName, volume: float = 0.5) -> void:
	volume_linear = volume
	
	if not playing:
		play()

	get_stream_playback().switch_to_clip_by_name(clip_name)
