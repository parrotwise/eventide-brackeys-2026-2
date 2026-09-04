extends Node


enum Clip {
	NONE,
	BC_ABILITY_CHARGE,
	BC_ABILITY_SLAM,
	BC_ATTACK,
	BHC_ABILITY,
	BHC_ATTACK,
	EC_ABILITY,
	EC_ATTACK,
	EC_ATTACK_NO_FUSE,
	GC_ABILITY,
	GC_ATTACK,
	PC_ABILITY,
	PC_ATTACK,
	RC_ABILITY,
	RC_ATTACK,
	SC_ABILITY,
	SC_ATTACK,
	NC_ABILITY,
	NC_ATTACK,
	EAT_CRUNCH,
	UI_BUTTON,
}

enum Track {
	TRACK1,
	TRACK2,
}

var master_volume: float = 0.5
var music_volume: float = 0.5
var sfx_volume: float = 0.5

var sfx_player_template: PackedScene = preload('res://objects/audio/sfx_player.tscn')
var music_player_template: PackedScene = preload('res://objects/audio/music_player.tscn')

var audio_components: Array[CharacterAudio] = []

var sfx_player: SFXPlayer
var music_player: MusicPlayer


func _ready() -> void:
	sfx_player = sfx_player_template.instantiate()
	music_player = music_player_template.instantiate()

	add_child(sfx_player)
	add_child(music_player)


func _process(_delta: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index('Master'), master_volume
	)
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index('Music'), music_volume
	)
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index('SFX'), sfx_volume
	)


func play_sfx(clip: Clip, volume: float = 0.5) -> void:
	var clip_name: StringName = _pick_clip(clip)
	if clip_name:
		sfx_player.play_clip(clip_name, volume)


func play_music(track: Track, volume: float = 0.5) -> void:
	var track_name: StringName = _pick_track(track)
	if track_name:
		music_player.play_clip(track_name, volume)


func stop_music() -> void:
	music_player.stop()


func _pick_clip(clip: Clip) -> StringName:
	match clip:
		Clip.BC_ABILITY_CHARGE:
			return &'BC Ability Charge'
		Clip.BC_ABILITY_SLAM:
			return &'BC Ability Slam'
		Clip.BC_ATTACK:
			return &'BC Attack'
		Clip.BHC_ABILITY:
			return &'BHC Ability'
		Clip.BHC_ATTACK:
			return &'BHC Attack'
		Clip.EC_ABILITY:
			return &'EC Ability'
		Clip.EC_ATTACK:
			return &'EC Attack'
		Clip.EC_ATTACK_NO_FUSE:
			return &'EC Attack No Fuse'
		Clip.GC_ABILITY:
			return &'GC Ability'
		Clip.GC_ATTACK:
			return &'GC Attack'
		Clip.PC_ABILITY:
			return &'PC Ability'
		Clip.PC_ATTACK:
			return &'PC Attack'
		Clip.RC_ABILITY:
			return &'RC Ability'
		Clip.RC_ATTACK:
			return &'RC Attack'
		Clip.SC_ABILITY:
			return &'SC Ability'
		Clip.SC_ATTACK:
			return &'SC Attack'
		Clip.NC_ABILITY:
			return &'NC Ability'
		Clip.NC_ATTACK:
			return &'NC Attack'
		Clip.EAT_CRUNCH:
			return &'Eat Crunch'
		Clip.UI_BUTTON:
			return &'UI Button'
	
	return &''


func _pick_track(track: Track) -> StringName:
	match track:
		Track.TRACK1:
			return &'Track 1'
		Track.TRACK2:
			return &'Track 2'
	
	return &''
