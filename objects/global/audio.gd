extends Node


var sfx_player_template: PackedScene = preload('res://objects/audio/sfx_player.tscn')
var music_player_template: PackedScene = preload('res://objects/audio/music_player.tscn')

@onready var sfx_player: SFXPlayer = sfx_player_template.instantiate()
@onready var music_player: MusicPlayer = music_player_template.instantiate()


func play_sfx(clip_name: StringName, volume: float = 0.5) -> void:
	sfx_player.play_clip(clip_name, volume)


func play_music(clip_name: StringName, volume: float = 0.5) -> void:
	music_player.play_clip(clip_name, volume)


func stop_music() -> void:
	music_player.stop()
