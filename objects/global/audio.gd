extends Node


## TODO: Add one item per Wwise event.
enum Event {
	NONE,
	WWISE_EVENT1,
	WWISE_EVENT2,
}

## TODO: Add one item per Wwise StateGroup+State combination.
enum State {
	NONE,
	WWISE_STATE1,
	WWISE_STATE2,
}

## TODO: Add one item per Wwise SwitchGroup.
enum Switch {
	NONE,
	WWISE_SWITCH1,
	WWISE_SWITCH2,
}

## TODO: Deprecated! Replace with the enums above.
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

## TODO: Deprecated! Replace with the enums above.
enum Track {
	TRACK1,
	TRACK2,
}

var master_volume: float = 0.5
var music_volume: float = 0.5
var sfx_volume: float = 0.5

var audio_components: Array[CharacterAudio] = []

## TODO: Both deprecated! Remove after Wwise migration.
var sfx_player_template: PackedScene = preload('res://objects/audio/sfx_player.tscn')
var music_player_template: PackedScene = preload('res://objects/audio/music_player.tscn')

## TODO: Both deprecated! Remove after Wwise migration.
var sfx_player: SFXPlayer
var music_player: MusicPlayer


## TODO: Deprecated! Remove/Replace after Wwise migration.
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


func post_event(event: Event) -> void:
	var event_name: String = _event_name(event)
	if event_name:
		Wwise.post_event(event_name, self)


func set_state(state: State) -> void:
	var state_group: String = _state(state)['group']
	var state_value: String = _state(state)['value']
	if state_group:
		Wwise.set_state(state_group, state_value)


func set_switch(switch: Switch, switch_value: String) -> void:
	var switch_group: String = _switch_group(switch)
	if switch_group:
		Wwise.set_switch(switch_group, switch_value, self)


## TODO: Deprecated! Replaced with the functions above.
func play_sfx(clip: Clip, volume: float = 0.5) -> void:
	var clip_name: StringName = _pick_clip(clip)
	if clip_name:
		sfx_player.play_clip(clip_name, volume)


## TODO: Deprecated! Replaced with the functions above.
func play_music(track: Track, volume: float = 0.5) -> void:
	var track_name: StringName = _pick_track(track)
	if track_name:
		music_player.play_clip(track_name, volume)


## TODO: Deprecated! Replaced with the functions above.
func stop_music() -> void:
	music_player.stop()


func _event_name(event: Event) -> String:
	match event:
		Event.WWISE_EVENT1:
			return 'WwiseEvent1Name'
		Event.WWISE_EVENT2:
			return 'WwiseEvent2Name'
	
	return ''


func _state(state: State) -> Dictionary[String, String]:
	match state:
		State.WWISE_STATE1:
			return {
				'group': 'WwiseState1GroupName',
				'value': 'WwiseState1Name'
			}
		State.WWISE_STATE2:
			return {
				'group': 'WwiseState2GroupName',
				'value': 'WwiseState2Name'
			}
	
	return {
		'group': '',
		'value': ''
	}


func _switch_group(switch: Switch) -> String:
	match switch:
		Switch.WWISE_SWITCH1:
			return 'WwiseSwitch1GroupName'
		Switch.WWISE_SWITCH2:
			return 'WwiseSwitch2GroupName'
	
	return ''


## TODO: Deprecated! Replaced with the functions above.
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


## TODO: Deprecated! Replaced with the functions above.
func _pick_track(track: Track) -> StringName:
	match track:
		Track.TRACK1:
			return &'Track 1'
		Track.TRACK2:
			return &'Track 2'
	
	return &''
