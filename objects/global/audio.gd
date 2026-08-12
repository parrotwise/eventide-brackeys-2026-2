extends Node


var sfx_player: PackedScene = preload('res://objects/audio/sfx_player.tscn')
var music_player: PackedScene = preload('res://objects/audio/music_player.tscn')


func _ready() -> void:
	add_child(sfx_player.instantiate())
	add_child(music_player.instantiate())


func play_sfx(clip_name: StringName, volume: float = 0.5) -> void:
	if has_node(^'SFXPlayer'):
		_start_player($SFXPlayer, clip_name, volume)


func play_music(clip_name: StringName, volume: float = 0.5) -> void:
	if has_node(^'MusicPlayer'):
		_start_player($MusicPlayer, clip_name, volume)


func stop_music() -> void:
	if has_node(^'MusicPlayer'):
		_stop_player($MusicPlayer)


func _start_player(asp: AudioStreamPlayer, clip_name: StringName, volume: float = 0.5) -> void:
	asp.volume_linear = volume
	
	if not asp.playing:
		asp.play()

	asp.get_stream_playback().switch_to_clip_by_name(clip_name)


func _stop_player(asp: AudioStreamPlayer) -> void:
	if asp.playing:
		asp.stop()
