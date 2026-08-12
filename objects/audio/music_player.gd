class_name MusicPlayer
extends AudioStreamPlayer


func play_clip(clip_name: StringName, volume: float = 0.5) -> void:
	volume_linear = volume
	
	if not playing:
		play()

	get_stream_playback().switch_to_clip_by_name(clip_name)
